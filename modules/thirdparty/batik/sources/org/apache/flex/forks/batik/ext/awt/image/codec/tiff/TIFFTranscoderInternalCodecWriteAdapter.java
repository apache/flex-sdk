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
package org.apache.flex.forks.batik.ext.awt.image.codec.tiff;

import java.awt.image.BufferedImage;
import java.awt.image.DataBuffer;
import java.awt.image.PixelInterleavedSampleModel;
import java.awt.image.RenderedImage;
import java.awt.image.SampleModel;
import java.awt.image.SinglePixelPackedSampleModel;
import java.io.IOException;
import java.io.OutputStream;

import org.apache.flex.forks.batik.ext.awt.image.GraphicsUtil;
import org.apache.flex.forks.batik.ext.awt.image.rendered.FormatRed;
import org.apache.flex.forks.batik.transcoder.TranscoderException;
import org.apache.flex.forks.batik.transcoder.TranscoderOutput;
import org.apache.flex.forks.batik.transcoder.TranscodingHints;
import org.apache.flex.forks.batik.transcoder.image.TIFFTranscoder;

/**
 * This class is a helper to <tt>TIFFTranscoder</tt> that writes TIFF images
 * through the internal TIFF codec.
 *
 * @version $Id: TIFFTranscoderInternalCodecWriteAdapter.java 582434 2007-10-06 02:11:51Z cam $
 */
public class TIFFTranscoderInternalCodecWriteAdapter implements
        TIFFTranscoder.WriteAdapter {

    /**
     * @throws TranscoderException
     * @see org.apache.flex.forks.batik.transcoder.image.PNGTranscoder.WriteAdapter#writeImage(org.apache.flex.forks.batik.transcoder.image.PNGTranscoder, java.awt.image.BufferedImage, org.apache.flex.forks.batik.transcoder.TranscoderOutput)
     */
    public void writeImage(TIFFTranscoder transcoder, BufferedImage img,
            TranscoderOutput output) throws TranscoderException {
        TranscodingHints hints = transcoder.getTranscodingHints();

        TIFFEncodeParam params = new TIFFEncodeParam();

        float PixSzMM = transcoder.getUserAgent().getPixelUnitToMillimeter();
        // num Pixs in 100 Meters
        int numPix      = (int)(((1000 * 100) / PixSzMM) + 0.5);
        int denom       = 100 * 100;  // Centimeters per 100 Meters;
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

        if (hints.containsKey(TIFFTranscoder.KEY_COMPRESSION_METHOD)) {
            String method = (String)hints.get(TIFFTranscoder.KEY_COMPRESSION_METHOD);
            if ("packbits".equals(method)) {
                params.setCompression(TIFFEncodeParam.COMPRESSION_PACKBITS);
            } else if ("deflate".equals(method)) {
                params.setCompression(TIFFEncodeParam.COMPRESSION_DEFLATE);
            /* TODO: NPE occurs when used.
            } else if ("jpeg".equals(method)) {
                params.setCompression(TIFFEncodeParam.COMPRESSION_JPEG_TTN2);
            */
            } else {
                //nop
            }
        }


        try {
            int w = img.getWidth();
            int h = img.getHeight();
            SinglePixelPackedSampleModel sppsm;
            sppsm = (SinglePixelPackedSampleModel)img.getSampleModel();
            OutputStream ostream = output.getOutputStream();
            TIFFImageEncoder tiffEncoder =
                new TIFFImageEncoder(ostream, params);
            int bands = sppsm.getNumBands();
            int [] off = new int[bands];
            for (int i = 0; i < bands; i++)
                off[i] = i;
            SampleModel sm = new PixelInterleavedSampleModel
                (DataBuffer.TYPE_BYTE, w, h, bands, w * bands, off);

            RenderedImage rimg = new FormatRed(GraphicsUtil.wrap(img), sm);
            tiffEncoder.encode(rimg);
            ostream.flush();
        } catch (IOException ex) {
            throw new TranscoderException(ex);
        }
    }

}
