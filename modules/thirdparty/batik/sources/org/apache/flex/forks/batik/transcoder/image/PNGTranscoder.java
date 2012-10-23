/*

   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.transcoder.image;

import java.awt.image.BufferedImage;
import java.awt.image.SinglePixelPackedSampleModel;
import java.io.OutputStream;

import org.apache.flex.forks.batik.bridge.UserAgent;
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
 * @version $Id: PNGTranscoder.java 475477 2006-11-15 22:44:28Z cam $
 */
public class PNGTranscoder extends ImageTranscoder {

    /**
     * Constructs a new transcoder that produces png images.
     */
    public PNGTranscoder() {
        hints.put(KEY_FORCE_TRANSPARENT_WHITE, Boolean.FALSE);
    }

    /** @return the transcoder's user agent */
    public UserAgent getUserAgent() {
        return this.userAgent;
    }
    
    /**
     * Creates a new ARGB image with the specified dimension.
     * @param width the image width in pixels
     * @param height the image height in pixels
     */
    public BufferedImage createImage(int width, int height) {
        return new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
    }

    private WriteAdapter getWriteAdapter(String className) {
        WriteAdapter adapter;
        try {
            Class clazz = Class.forName(className);
            adapter = (WriteAdapter)clazz.newInstance();
            return adapter;
        } catch (ClassNotFoundException e) {
            return null;
        } catch (InstantiationException e) {
            return null;
        } catch (IllegalAccessException e) {
            return null;
        }
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

        if (hints.containsKey(PNGTranscoder.KEY_FORCE_TRANSPARENT_WHITE)) {
            forceTransparentWhite =
                ((Boolean)hints.get
                 (PNGTranscoder.KEY_FORCE_TRANSPARENT_WHITE)).booleanValue();
        }

        if (forceTransparentWhite) {
            SinglePixelPackedSampleModel sppsm;
            sppsm = (SinglePixelPackedSampleModel)img.getSampleModel();
            forceTransparentWhite(img, sppsm);
        }

        WriteAdapter adapter = getWriteAdapter(
                "org.apache.flex.forks.batik.ext.awt.image.codec.png.PNGTranscoderInternalCodecWriteAdapter");
        if (adapter == null) {
            adapter = getWriteAdapter(
                "org.apache.flex.forks.batik.transcoder.image.PNGTranscoderImageIOWriteAdapter");
        }
        if (adapter == null) {
            throw new TranscoderException(
                    "Could not write PNG file because no WriteAdapter is availble");
        }
        adapter.writeImage(this, img, output);
    }
    
    // --------------------------------------------------------------------
    // PNG specific interfaces
    // --------------------------------------------------------------------

    /**
     * This interface is used by <tt>PNGTranscoder</tt> to write PNG images 
     * through different codecs.
     *
     * @version $Id: PNGTranscoder.java 475477 2006-11-15 22:44:28Z cam $
     */
    public interface WriteAdapter {
        
        /**
         * Writes the specified image to the specified output.
         * @param transcoder the calling PNGTranscoder
         * @param img the image to write
         * @param output the output where to store the image
         * @throws TranscoderException if an error occured while storing the image
         */
        void writeImage(PNGTranscoder transcoder, BufferedImage img, 
                TranscoderOutput output) throws TranscoderException;

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
