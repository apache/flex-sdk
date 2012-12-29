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
package org.apache.flex.forks.batik.ext.awt.image.rendered;



import java.awt.Transparency;
import java.awt.color.ColorSpace;
import java.awt.image.ComponentColorModel;
import java.awt.image.DataBuffer;
import java.awt.image.DataBufferByte;
import java.awt.image.PixelInterleavedSampleModel;
import java.awt.image.Raster;
import java.awt.image.SampleModel;
import java.awt.image.WritableRaster;

import org.apache.flex.forks.batik.ext.awt.ColorSpaceHintKey;

/**
 * This converts any source into a mask according to the SVG masking rules.
 *
 * @author <a href="mailto:Thomas.DeWeeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: FilterAsAlphaRed.java 475477 2006-11-15 22:44:28Z cam $ */
public class FilterAsAlphaRed extends AbstractRed {

    /**
     * Construct an alpah channel from the given src, according to
     * the SVG masking rules.
     *
     * @param src The image to convert to an alpha channel (mask image)
     */
    public FilterAsAlphaRed(CachableRed src) {
        super(new Any2LumRed(src),src.getBounds(), 
              new ComponentColorModel
                  (ColorSpace.getInstance(ColorSpace.CS_GRAY),
                   new int [] {8}, false, false,
                   Transparency.OPAQUE, 
                   DataBuffer.TYPE_BYTE),
              new PixelInterleavedSampleModel
                  (DataBuffer.TYPE_BYTE, 
                   src.getSampleModel().getWidth(),
                   src.getSampleModel().getHeight(),
                   1, src.getSampleModel().getWidth(),
                   new int [] { 0 }),
              src.getTileGridXOffset(),
              src.getTileGridYOffset(),
              null);

        props.put(ColorSpaceHintKey.PROPERTY_COLORSPACE,
                  ColorSpaceHintKey.VALUE_COLORSPACE_ALPHA);
    }

    public WritableRaster copyData(WritableRaster wr) {
        // Get my source.
        CachableRed srcRed = (CachableRed)getSources().get(0);

        SampleModel sm = srcRed.getSampleModel();
        if (sm.getNumBands() == 1)
            // Already one band of data so we just use it...
            return srcRed.copyData(wr);

        // Two band case so we need to multiply them...
        // Note: Our source will always have either one or two bands
        // since we insert an Any2Lum transform before ourself in the
        // rendering chain.

        Raster srcRas = srcRed.getData(wr.getBounds());
        PixelInterleavedSampleModel srcSM;
        srcSM = (PixelInterleavedSampleModel)srcRas.getSampleModel();

        DataBufferByte srcDB = (DataBufferByte)srcRas.getDataBuffer();
        byte []        src   = srcDB.getData();
        
        PixelInterleavedSampleModel dstSM;
        dstSM = (PixelInterleavedSampleModel)wr.getSampleModel();

        DataBufferByte dstDB = (DataBufferByte)wr.getDataBuffer();
        byte []        dst   = dstDB.getData();

        int srcX0 = srcRas.getMinX()-srcRas.getSampleModelTranslateX();
        int srcY0 = srcRas.getMinY()-srcRas.getSampleModelTranslateY();

        int dstX0 = wr.getMinX()-wr.getSampleModelTranslateX();
        int dstX1 = dstX0+wr.getWidth()-1;
        int dstY0 = wr.getMinY()-wr.getSampleModelTranslateY();

        int    srcStep = srcSM.getPixelStride();
        int [] offsets = srcSM.getBandOffsets();
        int    srcLOff = offsets[0];
        int    srcAOff = offsets[1];

        if (srcRed.getColorModel().isAlphaPremultiplied()) {
            // Lum is already multiplied by alpha so we just copy lum channel.
            for (int y=0; y<srcRas.getHeight(); y++) {
                int srcI  = srcDB.getOffset() + srcSM.getOffset(srcX0,  srcY0);
                int dstI  = dstDB.getOffset() + dstSM.getOffset(dstX0,  dstY0);
                int dstE  = dstDB.getOffset() + dstSM.getOffset(dstX1+1,dstY0);

                srcI += srcLOff; // Go to Lum Channel (already mult by alpha).

                while (dstI < dstE) {
                    dst[dstI++] = src[srcI];
                        srcI += srcStep; // Go to next pixel
                }
                srcY0++;
                dstY0++;
            }
        }
        else {
            // This allows me to pre-adjust my index by srcLOff
            // Then only add the offset for srcAOff
            srcAOff = srcAOff-srcLOff;

            for (int y=0; y<srcRas.getHeight(); y++) {
                int srcI  = srcDB.getOffset() + srcSM.getOffset(srcX0,  srcY0);
                int dstI  = dstDB.getOffset() + dstSM.getOffset(dstX0,  dstY0);
                int dstE  = dstDB.getOffset() + dstSM.getOffset(dstX1+1,dstY0);

                srcI += srcLOff;

                while (dstI < dstE) {
                    int sl = (src[srcI])&0xFF; // LOff already included
                    int sa = (src[srcI+srcAOff])&0xFF;
                    // the + 0x80 forces proper rounding.
                    dst[dstI++] = (byte)((sl*sa+0x80)>>8);

                    srcI+= srcStep; //  next pixel
                }
                srcY0++;
                dstY0++;
            }
        }

        return wr;
    }

}    
