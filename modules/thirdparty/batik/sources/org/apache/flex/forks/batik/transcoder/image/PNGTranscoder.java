/*

   Copyright 2001-2003  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.transcoder.image;

import java.awt.image.BufferedImage;
import java.awt.image.DataBufferInt;
import java.awt.image.SinglePixelPackedSampleModel;
import java.io.IOException;
import java.io.OutputStream;

import org.apache.flex.forks.batik.ext.awt.image.codec.PNGEncodeParam;
import org.apache.flex.forks.batik.ext.awt.image.codec.PNGImageEncoder;
import org.apache.flex.forks.batik.ext.awt.image.rendered.IndexImage;
import org.apache.flex.forks.batik.transcoder.TranscoderException;
import org.apache.flex.forks.batik.transcoder.TranscoderOutput;
import org.apache.flex.forks.batik.transcoder.TranscodingHints;
import org.apache.flex.forks.batik.transcoder.image.resources.Messages;
import org.apache.flex.forks.batik.transcoder.keys.FloatKey;
import org.apache.flex.forks.batik.transcoder.keys.IntegerKey;

/**
 * This class is an <tt>ImageTranscoder</tt> that produces a PNG image.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: PNGTranscoder.java,v 1.23 2005/03/27 08:58:36 cam Exp $
 */
public class PNGTranscoder extends ImageTranscoder {

    /**
     * Constructs a new transcoder that produces png images.
     */
    public PNGTranscoder() {
        hints.put(KEY_FORCE_TRANSPARENT_WHITE, Boolean.FALSE);
    }

    /**
     * Creates a new ARGB image with the specified dimension.
     * @param width the image width in pixels
     * @param height the image height in pixels
     */
    public BufferedImage createImage(int width, int height) {
        return new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
    }

    /**
     * Writes the specified image to the specified output.
     * @param img the image to write
     * @param output the output where to store the image
     * @throws TranscoderException if an error occured while storing the image
     */
    public void writeImage(BufferedImage img, TranscoderOutput output)
            throws TranscoderException {

        OutputStream ostream = output.getOutputStream();
        if (ostream == null) {
            throw new TranscoderException(
                Messages.formatMessage("png.badoutput", null));
        }

        //
        // This is a trick so that viewers which do not support the alpha
        // channel will see a white background (and not a black one).
        //
        boolean forceTransparentWhite = false;

        if (hints.containsKey(KEY_FORCE_TRANSPARENT_WHITE)) {
            forceTransparentWhite =
                ((Boolean)hints.get
                 (KEY_FORCE_TRANSPARENT_WHITE)).booleanValue();
        }

        if (forceTransparentWhite) {
            int w = img.getWidth(), h = img.getHeight();
            DataBufferInt biDB = (DataBufferInt)img.getRaster().getDataBuffer();
            int scanStride = ((SinglePixelPackedSampleModel)
                              img.getSampleModel()).getScanlineStride();
            int dbOffset = biDB.getOffset();
            int pixels[] = biDB.getBankData()[0];
            int p = dbOffset;
            int adjust = scanStride - w;
            int a=0, r=0, g=0, b=0, pel=0;
            for(int i=0; i<h; i++){
                for(int j=0; j<w; j++){
                    pel = pixels[p];
                    a = (pel >> 24) & 0xff;
                    r = (pel >> 16) & 0xff;
                    g = (pel >> 8 ) & 0xff;
                    b =  pel        & 0xff;
                    r = (255*(255 -a) + a*r)/255;
                    g = (255*(255 -a) + a*g)/255;
                    b = (255*(255 -a) + a*b)/255;
                    pixels[p++] =
                        (a<<24 & 0xff000000) |
                        (r<<16 & 0xff0000) |
                        (g<<8  & 0xff00) |
                        (b     & 0xff);
                }
                p += adjust;
            }
        }

        int n=-1;
        if (hints.containsKey(KEY_INDEXED)) {
            n=((Integer)hints.get(KEY_INDEXED)).intValue();
            if (n==1||n==2||n==4||n==8) 
                //PNGEncodeParam.Palette can handle these numbers only.
                img = IndexImage.getIndexedImage(img,1<<n);
        }

        PNGEncodeParam params = PNGEncodeParam.getDefaultEncodeParam(img);
        if (params instanceof PNGEncodeParam.RGB) {
            ((PNGEncodeParam.RGB)params).setBackgroundRGB
                (new int [] { 255, 255, 255 });
        }

        // If they specify GAMMA key with a value of '0' then omit
        // gamma chunk.  If they do not provide a GAMMA then just
        // generate an sRGB chunk. Otherwise supress the sRGB chunk
        // and just generate gamma and chroma chunks.
        if (hints.containsKey(KEY_GAMMA)) {
            float gamma = ((Float)hints.get(KEY_GAMMA)).floatValue();
            if (gamma > 0) {
                params.setGamma(gamma);
            }
            params.setChromaticity(DEFAULT_CHROMA);
        }  else {
            // We generally want an sRGB chunk and our encoding intent
            // is perceptual
            params.setSRGBIntent(PNGEncodeParam.INTENT_PERCEPTUAL);
        }


        float PixSzMM = userAgent.getPixelUnitToMillimeter();
        // num Pixs in 1 Meter
        int numPix      = (int)((1000/PixSzMM)+0.5);
        params.setPhysicalDimension(numPix, numPix, 1); // 1 means 'pix/meter'

        try {
            PNGImageEncoder pngEncoder = new PNGImageEncoder(ostream, params);
            pngEncoder.encode(img);
            ostream.flush();
        } catch (IOException ex) {
            throw new TranscoderException(ex);
        }
    }

    // --------------------------------------------------------------------
    // Keys definition
    // --------------------------------------------------------------------

    /**
     * The gamma correction key.
     *
     * <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="1">
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Key: </TH>
     * <TD VALIGN="TOP">KEY_GAMMA</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Value: </TH>
     * <TD VALIGN="TOP">Float</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Default: </TH>
     * <TD VALIGN="TOP">PNGEncodeParam.INTENT_PERCEPTUAL</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Required: </TH>
     * <TD VALIGN="TOP">No</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Description: </TH>
     * <TD VALIGN="TOP">Controls the gamma correction of the png image. 
     *                  A value of zero for gamma disables the generation 
     *                  of a gamma chunk.  No value causes an sRGB chunk 
     *                  to be generated.</TD>
     * </TR>
     * </TABLE>
     */
    public static final TranscodingHints.Key KEY_GAMMA
        = new FloatKey();

    /**
     * The default Primary Chromaticities for sRGB imagery.
     */
    public static final float[] DEFAULT_CHROMA = {
        0.31270F, 0.329F, 0.64F, 0.33F, 0.3F, 0.6F, 0.15F, 0.06F
    };


    /**
     * The color indexed image key to specify number of colors used in
     * palette.
     *
     * <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="1">
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Key: </TH>
     * <TD VALIGN="TOP">KEY_INDEXED</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Value: </TH>
     * <TD VALIGN="TOP">Integer</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Default: </TH>
     * <TD VALIGN="TOP">none/true color image</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Required: </TH>
     * <TD VALIGN="TOP">No</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Description: </TH>
     * <TD VALIGN="TOP">Turns on the reduction of the image to index 
     *     colors by specifying color bit depth, 1,2,4,8. The resultant 
     *     PNG will be an indexed PNG with color bit depth specified.</TD>
     * </TR>
     * </TABLE> 
     */
    public static final TranscodingHints.Key KEY_INDEXED
        = new IntegerKey();
}
