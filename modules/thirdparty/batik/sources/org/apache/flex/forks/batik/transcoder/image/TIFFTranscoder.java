/*

   Copyright 1999-2003  The Apache Software Foundation 

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
import java.awt.image.DataBuffer;
import java.awt.image.DataBufferInt;
import java.awt.image.PixelInterleavedSampleModel;
import java.awt.image.RenderedImage;
import java.awt.image.SampleModel;
import java.awt.image.SinglePixelPackedSampleModel;
import java.io.IOException;
import java.io.OutputStream;

import org.apache.flex.forks.batik.ext.awt.image.GraphicsUtil;
import org.apache.flex.forks.batik.ext.awt.image.codec.tiff.TIFFEncodeParam;
import org.apache.flex.forks.batik.ext.awt.image.codec.tiff.TIFFField;
import org.apache.flex.forks.batik.ext.awt.image.codec.tiff.TIFFImageDecoder;
import org.apache.flex.forks.batik.ext.awt.image.codec.tiff.TIFFImageEncoder;
import org.apache.flex.forks.batik.ext.awt.image.rendered.FormatRed;
import org.apache.flex.forks.batik.transcoder.TranscoderException;
import org.apache.flex.forks.batik.transcoder.TranscoderOutput;
import org.apache.flex.forks.batik.transcoder.TranscodingHints;
import org.apache.flex.forks.batik.transcoder.image.resources.Messages;


/**
 * This class is an <tt>ImageTranscoder</tt> that produces a TIFF image.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: TIFFTranscoder.java,v 1.10 2005/03/27 08:58:36 cam Exp $
 */
public class TIFFTranscoder extends ImageTranscoder {

    /**
     * Constructs a new transcoder that produces tiff images.
     */
    public TIFFTranscoder() { 
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
                Messages.formatMessage("tiff.badoutput", null));
        }

        TIFFEncodeParam params = new TIFFEncodeParam();

        float PixSzMM = userAgent.getPixelUnitToMillimeter();
        // num Pixs in 100 Meters
        int numPix      = (int)(((1000*100)/PixSzMM)+0.5); 
        int denom       = 100*100;  // Centimeters per 100 Meters;
        long [] rational = {numPix, denom};
        TIFFField [] fields = {
            new TIFFField(TIFFImageDecoder.TIFF_RESOLUTION_UNIT, 
                          TIFFField.TIFF_SHORT, 1, 
                          new char [] { (char)3 }),
            new TIFFField(TIFFImageDecoder.TIFF_X_RESOLUTION, 
                          TIFFField.TIFF_RATIONAL, 1, 
                          new long [][] { rational }),
            new TIFFField(TIFFImageDecoder.TIFF_Y_RESOLUTION, 
                          TIFFField.TIFF_RATIONAL, 1, 
                          new long [][] { rational }) 
                };

        params.setExtraFields(fields);

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

        int w = img.getWidth();
        int h = img.getHeight();
        SinglePixelPackedSampleModel sppsm;
        sppsm = (SinglePixelPackedSampleModel)img.getSampleModel();

        if (forceTransparentWhite) {
            //
            // This is a trick so that viewers which do not support
            // the alpha channel will see a white background (and not
            // a black one).
            //
            DataBufferInt biDB=(DataBufferInt)img.getRaster().getDataBuffer();
            int scanStride = sppsm.getScanlineStride();
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

        try {
            TIFFImageEncoder tiffEncoder = 
                new TIFFImageEncoder(ostream, params);
            int bands = sppsm.getNumBands();
            int [] off = new int[bands];
            for (int i=0; i<bands; i++)
                off[i] = i;
            SampleModel sm = new PixelInterleavedSampleModel
                (DataBuffer.TYPE_BYTE, w, h, bands, w*bands, off);
            
            RenderedImage rimg = new FormatRed(GraphicsUtil.wrap(img), sm);
            tiffEncoder.encode(rimg);
        } catch (IOException ex) {
            throw new TranscoderException(ex);
        }
    }


    // --------------------------------------------------------------------
    // Keys definition
    // --------------------------------------------------------------------

    /**
     * The forceTransparentWhite key.
     *
     * <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="1">
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Key: </TH>
     * <TD VALIGN="TOP">KEY_FORCE_TRANSPARENT_WHITE</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Value: </TH>
     * <TD VALIGN="TOP">Boolean</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Default: </TH>
     * <TD VALIGN="TOP">false</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Required: </TH>
     * <TD VALIGN="TOP">No</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Description: </TH>
     * <TD VALIGN="TOP">It controls whether the encoder should
     * force the image's fully transparent pixels to be fully transparent
     * white instead of fully transparent black.  This is usefull when the
     * encoded TIFF is displayed in a viewer which does not support TIFF
     * transparency and lets the image display with a white background instead
     * of a black background. <br /> 
     *
     * However, note that the modified image will display differently
     * over a white background in a viewer that supports
     * transparency.</TD></TR>
     * </TABLE> 
     */
    public static final TranscodingHints.Key KEY_FORCE_TRANSPARENT_WHITE
        = ImageTranscoder.KEY_FORCE_TRANSPARENT_WHITE;

}
