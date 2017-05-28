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
package org.apache.flex.forks.batik.ext.awt.image.codec.png;

import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.OutputStream;

import org.apache.flex.forks.batik.ext.awt.image.rendered.IndexImage;
import org.apache.flex.forks.batik.transcoder.TranscoderException;
import org.apache.flex.forks.batik.transcoder.TranscoderOutput;
import org.apache.flex.forks.batik.transcoder.TranscodingHints;
import org.apache.flex.forks.batik.transcoder.image.PNGTranscoder;

/**
 * This class is a helper to <tt>PNGTranscoder</tt> that writes PNG images
 * through the internal PNG codec.
 *
 * @version $Id: PNGTranscoderInternalCodecWriteAdapter.java 502538 2007-02-02 08:52:56Z dvholten $
 */
public class PNGTranscoderInternalCodecWriteAdapter implements
        PNGTranscoder.WriteAdapter {

    /**
     * @throws TranscoderException
     * @see org.apache.flex.forks.batik.transcoder.image.PNGTranscoder.WriteAdapter#writeImage(org.apache.flex.forks.batik.transcoder.image.PNGTranscoder, java.awt.image.BufferedImage, org.apache.flex.forks.batik.transcoder.TranscoderOutput)
     */
    public void writeImage(PNGTranscoder transcoder, BufferedImage img,
            TranscoderOutput output) throws TranscoderException {
        TranscodingHints hints = transcoder.getTranscodingHints();

        int n=-1;
        if (hints.containsKey(PNGTranscoder.KEY_INDEXED)) {
            n= (Integer) hints.get(PNGTranscoder.KEY_INDEXED);
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
        if (hints.containsKey(PNGTranscoder.KEY_GAMMA)) {
            float gamma = (Float) hints.get(PNGTranscoder.KEY_GAMMA);
            if (gamma > 0) {
                params.setGamma(gamma);
            }
            params.setChromaticity(PNGTranscoder.DEFAULT_CHROMA);
        }  else {
            // We generally want an sRGB chunk and our encoding intent
            // is perceptual
            params.setSRGBIntent(PNGEncodeParam.INTENT_PERCEPTUAL);
        }


        float PixSzMM = transcoder.getUserAgent().getPixelUnitToMillimeter();
        // num Pixs in 1 Meter
        int numPix      = (int)((1000/PixSzMM)+0.5);
        params.setPhysicalDimension(numPix, numPix, 1); // 1 means 'pix/meter'

        try {
            OutputStream ostream = output.getOutputStream();
            PNGImageEncoder pngEncoder = new PNGImageEncoder(ostream, params);
            pngEncoder.encode(img);
            ostream.flush();
        } catch (IOException ex) {
            throw new TranscoderException(ex);
        }
    }

}
