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

import org.apache.flex.forks.batik.bridge.UserAgent;
import org.apache.flex.forks.batik.transcoder.TranscoderException;
import org.apache.flex.forks.batik.transcoder.TranscoderOutput;
import org.apache.flex.forks.batik.transcoder.TranscodingHints;
import org.apache.flex.forks.batik.transcoder.keys.StringKey;


/**
 * This class is an <tt>ImageTranscoder</tt> that produces a TIFF image.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: TIFFTranscoder.java 475477 2006-11-15 22:44:28Z cam $
 */
public class TIFFTranscoder extends ImageTranscoder {

    /**
     * Constructs a new transcoder that produces tiff images.
     */
    public TIFFTranscoder() { 
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
                "org.apache.flex.forks.batik.ext.awt.image.codec.tiff.TIFFTranscoderInternalCodecWriteAdapter");
        if (adapter == null) {
            adapter = getWriteAdapter(
                "org.apache.flex.forks.batik.transcoder.image.TIFFTranscoderImageIOWriteAdapter");
        }
        if (adapter == null) {
            throw new TranscoderException(
                    "Could not write TIFF file because no WriteAdapter is availble");
        }
        adapter.writeImage(this, img, output);
    }
    
    // --------------------------------------------------------------------
    // TIFF specific interfaces
    // --------------------------------------------------------------------

    /**
     * This interface is used by <tt>TIFFTranscoder</tt> to write TIFF images 
     * through different codecs.
     *
     * @version $Id: TIFFTranscoder.java 475477 2006-11-15 22:44:28Z cam $
     */
    public interface WriteAdapter {
        
        /**
         * Writes the specified image to the specified output.
         * @param transcoder the calling PNGTranscoder
         * @param img the image to write
         * @param output the output where to store the image
         * @throws TranscoderException if an error occured while storing the image
         */
        void writeImage(TIFFTranscoder transcoder, BufferedImage img, 
                TranscoderOutput output) throws TranscoderException;

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

    /**
     * The compression method for the image.
     * <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="1">
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Key: </TH>
     * <TD VALIGN="TOP">KEY_COMPRESSION_METHOD</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Value: </TH>
     * <TD VALIGN="TOP">String ("none", "packbits", "jpeg" etc.)</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Default: </TH>
     * <TD VALIGN="TOP">"none" (no compression)</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Required: </TH>
     * <TD VALIGN="TOP">Recommended</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Description: </TH>
     * <TD VALIGN="TOP">Specify the compression method used to encode the image.</TD></TR>
     * </TABLE>
     */
    public static final TranscodingHints.Key KEY_COMPRESSION_METHOD
        = new StringKey();
    
}
