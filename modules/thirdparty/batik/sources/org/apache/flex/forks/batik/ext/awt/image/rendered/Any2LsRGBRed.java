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


import java.awt.Point;
import java.awt.Rectangle;
import java.awt.color.ColorSpace;
import java.awt.image.BandCombineOp;
import java.awt.image.BufferedImage;
import java.awt.image.ColorConvertOp;
import java.awt.image.ColorModel;
import java.awt.image.DataBuffer;
import java.awt.image.Raster;
import java.awt.image.SampleModel;
import java.awt.image.SinglePixelPackedSampleModel;
import java.awt.image.WritableRaster;

import org.apache.flex.forks.batik.ext.awt.image.GraphicsUtil;

/**
 * This function will tranform an image from any colorspace into a
 * luminance image.  The alpha channel if any will be copied to the
 * new image.
 *
 * @author <a href="mailto:Thomas.DeWeeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: Any2LsRGBRed.java 478276 2006-11-22 18:33:37Z dvholten $ */
public class Any2LsRGBRed extends AbstractRed {

    boolean srcIssRGB = false;

    /**
     * Construct a luminace image from src.
     *
     * @param src The image to convert to a luminance image
     */
    public Any2LsRGBRed(CachableRed src) {
        super(src,src.getBounds(),
              fixColorModel(src),
              fixSampleModel(src),
              src.getTileGridXOffset(),
              src.getTileGridYOffset(),
              null);

        ColorModel srcCM = src.getColorModel();
        if (srcCM == null) return;
        ColorSpace srcCS = srcCM.getColorSpace();
        if (srcCS == ColorSpace.getInstance(ColorSpace.CS_sRGB))
            srcIssRGB = true;
    }

    /**
     * Gamma for linear to sRGB convertion
     */
    private static final double GAMMA = 2.4;
    private static final double LFACT = 1.0/12.92;


    public static final double sRGBToLsRGB(double value) {
        if(value <= 0.003928)
            return value*LFACT;
        return Math.pow((value+0.055)/1.055, GAMMA);
    }

    /**
     * Lookup tables for RGB lookups. The linearToSRGBLut is used
     * when noise values are considered to be on a linearScale. The
     * linearToLinear table is used when the values are considered to
     * be on the sRGB scale to begin with.
     */
    private static final int[] sRGBToLsRGBLut = new int[256];
    static {
        final double scale = 1.0/255;

        // System.out.print("S2L: ");
        for(int i=0; i<256; i++){
            double value = sRGBToLsRGB(i*scale);
            sRGBToLsRGBLut[i] = (int)Math.round(value*255.0);
            // System.out.print(sRGBToLsRGBLut[i] + ",");
        }
        // System.out.println("");
    }

    public WritableRaster copyData(WritableRaster wr) {
        // Get my source.
        CachableRed src   = (CachableRed)getSources().get(0);
        ColorModel  srcCM = src.getColorModel();
        SampleModel srcSM = src.getSampleModel();

        // Fast case, SRGB source, INT Pack writable raster...
        if (srcIssRGB &&
            Any2sRGBRed.is_INT_PACK_COMP(wr.getSampleModel())) {
            src.copyData(wr);
            if (srcCM.hasAlpha())
                GraphicsUtil.coerceData(wr, srcCM, false);
            Any2sRGBRed.applyLut_INT(wr, sRGBToLsRGBLut);
            return wr;
        }

        if (srcCM == null) {
            // We don't really know much about this source, let's
            // guess based on the number of bands...

            float [][] matrix = null;
            switch (srcSM.getNumBands()) {
            case 1:
                matrix = new float[1][3];
                matrix[0][0] = 1; // Red
                matrix[0][1] = 1; // Grn
                matrix[0][2] = 1; // Blu
                break;
            case 2:
                matrix = new float[2][4];
                matrix[0][0] = 1; // Red
                matrix[0][1] = 1; // Grn
                matrix[0][2] = 1; // Blu
                matrix[1][3] = 1; // Alpha
                break;
            case 3:
                matrix = new float[3][3];
                matrix[0][0] = 1; // Red
                matrix[1][1] = 1; // Grn
                matrix[2][2] = 1; // Blu
                break;
            default:
                matrix = new float[srcSM.getNumBands()][4];
                matrix[0][0] = 1; // Red
                matrix[1][1] = 1; // Grn
                matrix[2][2] = 1; // Blu
                matrix[3][3] = 1; // Alpha
                break;
            }

            Raster srcRas = src.getData(wr.getBounds());
            BandCombineOp op = new BandCombineOp(matrix, null);
            op.filter(srcRas, wr);
        } else {
            ColorModel dstCM = getColorModel();
            BufferedImage dstBI;

            if (!dstCM.hasAlpha()) {
                // No alpha ao we don't have to work around the bug
                // in the color convert op.
                dstBI = new BufferedImage
                    (dstCM, wr.createWritableTranslatedChild(0,0),
                     dstCM.isAlphaPremultiplied(), null);
            } else {
                // All this nonsense is to work around the fact that
                // the Color convert op doesn't properly copy the
                // Alpha from src to dst.
                SinglePixelPackedSampleModel dstSM;
                dstSM = (SinglePixelPackedSampleModel)wr.getSampleModel();
                int [] masks = dstSM.getBitMasks();
                SampleModel dstSMNoA = new SinglePixelPackedSampleModel
                    (dstSM.getDataType(), dstSM.getWidth(), dstSM.getHeight(),
                     dstSM.getScanlineStride(),
                     new int[] {masks[0], masks[1], masks[2]});
                ColorModel dstCMNoA = GraphicsUtil.Linear_sRGB;

                WritableRaster dstWr;
                dstWr = Raster.createWritableRaster(dstSMNoA,
                                                    wr.getDataBuffer(),
                                                    new Point(0,0));
                dstWr = dstWr.createWritableChild
                    (wr.getMinX()-wr.getSampleModelTranslateX(),
                     wr.getMinY()-wr.getSampleModelTranslateY(),
                     wr.getWidth(), wr.getHeight(),
                     0, 0, null);

                dstBI = new BufferedImage(dstCMNoA, dstWr, false, null);
            }

            // Divide out alpha if we have it.  We need to do this since
            // the color convert may not be a linear operation which may
            // lead to out of range values.
            ColorModel srcBICM = srcCM;
            WritableRaster srcWr;
            if ( srcCM.hasAlpha() && srcCM.isAlphaPremultiplied() ) {
                Rectangle wrR = wr.getBounds();
                SampleModel sm = srcCM.createCompatibleSampleModel
                    (wrR.width, wrR.height);

                srcWr = Raster.createWritableRaster
                    (sm, new Point(wrR.x, wrR.y));
                src.copyData(srcWr);
                srcBICM = GraphicsUtil.coerceData(srcWr, srcCM, false);
            } else {
                Raster srcRas = src.getData(wr.getBounds());
                srcWr = GraphicsUtil.makeRasterWritable(srcRas);
            }

            BufferedImage srcBI;
            srcBI = new BufferedImage(srcBICM,
                                      srcWr.createWritableTranslatedChild(0,0),
                                      false,
                                      null);

            /*
             * System.out.println("src: " + srcBI.getWidth() + "x" +
             *                    srcBI.getHeight());
             * System.out.println("dst: " + dstBI.getWidth() + "x" +
             *                    dstBI.getHeight());
             */

            ColorConvertOp op = new ColorConvertOp(null);
            op.filter(srcBI, dstBI);

            if (dstCM.hasAlpha())
                copyBand(srcWr, srcSM.getNumBands()-1,
                         wr,    getSampleModel().getNumBands()-1);
        }
        return wr;
    }

        /**
         * This function 'fixes' the source's color model.  Right now
         * it just selects if it should have one or two bands based on
         * if the source had an alpha channel.
         */
    protected static ColorModel fixColorModel(CachableRed src) {
        ColorModel  cm = src.getColorModel();
        if (cm != null) {
            if (cm.hasAlpha())
                return GraphicsUtil.Linear_sRGB_Unpre;

            return GraphicsUtil.Linear_sRGB;
        }
        else {
            // No ColorModel so try to make some intelligent
            // decisions based just on the number of bands...
            // 1 bands -> replicated into RGB
            // 2 bands -> Band 0 replicated into RGB & Band 1 -> alpha premult
            // 3 bands -> sRGB (not-linear?)
            // 4 bands -> sRGB premult (not-linear?)
            SampleModel sm = src.getSampleModel();

            switch (sm.getNumBands()) {
            case 1:
                return GraphicsUtil.Linear_sRGB;
            case 2:
                return GraphicsUtil.Linear_sRGB_Unpre;
            case 3:
                return GraphicsUtil.Linear_sRGB;
            }
            return GraphicsUtil.Linear_sRGB_Unpre;
        }
    }

    /**
     * This function 'fixes' the source's sample model.
     * Right now it just selects if it should have 3 or 4 bands
     * based on if the source had an alpha channel.
     */
    protected static SampleModel fixSampleModel(CachableRed src) {
        SampleModel sm = src.getSampleModel();
        ColorModel  cm = src.getColorModel();

        boolean alpha = false;

        if (cm != null)
            alpha = cm.hasAlpha();
        else {
            switch (sm.getNumBands()) {
            case 1: case 3:
                alpha = false;
                break;
            default:
                alpha = true;
                break;
            }
        }
        if (alpha)
            return new SinglePixelPackedSampleModel
                (DataBuffer.TYPE_INT,
                 sm.getWidth(),
                 sm.getHeight(),
                 new int [] {0xFF0000, 0xFF00, 0xFF, 0xFF000000});
        else
            return new SinglePixelPackedSampleModel
                (DataBuffer.TYPE_INT,
                 sm.getWidth(),
                 sm.getHeight(),
                 new int [] {0xFF0000, 0xFF00, 0xFF});
    }
}
