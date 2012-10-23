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

import java.awt.Graphics2D;
import java.awt.Point;
import java.awt.RenderingHints;
import java.awt.Transparency;
import java.awt.color.ColorSpace;
import java.awt.image.BandedSampleModel;
import java.awt.image.BufferedImage;
import java.awt.image.ColorConvertOp;
import java.awt.image.ColorModel;
import java.awt.image.ComponentColorModel;
import java.awt.image.DataBuffer;
import java.awt.image.DataBufferByte;
import java.awt.image.DirectColorModel;
import java.awt.image.Raster;
import java.awt.image.RenderedImage;
import java.awt.image.WritableRaster;

import org.apache.flex.forks.batik.ext.awt.color.ICCColorSpaceExt;


/**
 * This implementation of rendered image forces a color profile
 * on its source
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: ProfileRed.java 504084 2007-02-06 11:24:46Z dvholten $
 */
public class ProfileRed extends AbstractRed {
    private static final ColorSpace sRGBCS
        = ColorSpace.getInstance(ColorSpace.CS_sRGB);
    private static final ColorModel sRGBCM
        = new DirectColorModel(sRGBCS,
                               32,
                               0x00ff0000,
                               0x0000ff00,
                               0x000000ff,
                               0xff000000,
                               false,
                               DataBuffer.TYPE_INT);

    private ICCColorSpaceExt colorSpace;

    /**
     * @param src Images on which the input ColorSpace should
     *        be forced
     * @param colorSpace colorSpace that should be forced on the
     *        source
     */
    public ProfileRed(CachableRed src,
                      ICCColorSpaceExt colorSpace){
        this.colorSpace = colorSpace;

        init(src, src.getBounds(),
             sRGBCM, sRGBCM.createCompatibleSampleModel(src.getWidth(),
                                                        src.getHeight()),
             src.getTileGridXOffset(), src.getTileGridYOffset(), null);

    }

    public CachableRed getSource() {
        return (CachableRed)getSources().get(0);
    }

    /**
     * This method will turn the input image in an sRGB image as follows.
     * If there is no colorSpace defined, then the input image is
     * simply converted to singlePixelPacked sRGB if needed.
     * If there is a colorSpace defined, the the image data is 'interpreted'
     * as being in that space, instead of that of the image's colorSpace.
     *
     * Here is how the input image is processed:
     * a. It is converted to using a ComponentColorModel
     * b. Its data is extracted, ignoring it's ColorSpace
     * c. A new ComponentColorModel is built for the replacing colorSpace
     *    Note that if the number of components in the input image and
     *    the number of components in the replacing ColorSpace do not
     *    match, it is not possible to apply the conversion.
     * d. A new BufferedImage is built, using the new
     *    ComponentColorModel and the data from the original image
     *    converted to the ComponentColorModel built in a. The alpha
     *    channel is excluded from that new BufferedImage.
     * e. The BufferedImage created in d. is converted to sRGB using
     *    ColorConvertOp
     * f. The alpha channel information is integrated back into the image.
     *
     * IMPORTANT NOTE: The code uses a BandedSampleModel in c.) and
     * d.) and discard the alpha channel during the color conversions
     * (it is restored in f.)), because of bugs in the interleaved
     * model with alpha. The BandedSampleModel did not cause any bug
     * as of JDK 1.3.
     */
    public WritableRaster copyData(WritableRaster argbWR){
        try{
            RenderedImage img = getSource();

            /**
             * Check that the number of color components match in the input
             * image and in the replacing profile.
             */
            ColorModel imgCM = img.getColorModel();
            ColorSpace imgCS = imgCM.getColorSpace();
            int nImageComponents = imgCS.getNumComponents();
            int nProfileComponents = colorSpace.getNumComponents();
            if(nImageComponents != nProfileComponents){
                // Should we go in error???? Here we simply trace an error
                // and return null
                System.err.println("Input image and associated color profile have" +
                                   " mismatching number of color components: conversion is not possible");
                return argbWR;
            }

            /**
             * Get the data from the source for the requested region
             */
            int w = argbWR.getWidth();
            int h = argbWR.getHeight();
            int minX = argbWR.getMinX();
            int minY = argbWR.getMinY();
            WritableRaster srcWR =
                imgCM.createCompatibleWritableRaster(w, h);
            srcWR = srcWR.createWritableTranslatedChild(minX, minY);
            img.copyData(srcWR);

            /**
             * If the source data is not a ComponentColorModel using a
             * BandedSampleModel, do the conversion now.
             */
            if(!(imgCM instanceof ComponentColorModel) ||
               !(img.getSampleModel() instanceof BandedSampleModel) ||
               (imgCM.hasAlpha() && imgCM.isAlphaPremultiplied() )) {
                ComponentColorModel imgCompCM
                    = new ComponentColorModel
                        (imgCS,                      // Same ColorSpace as img
                         imgCM.getComponentSize(),   // Number of bits/comp
                         imgCM.hasAlpha(),             // Same alpha as img
                         false, // unpremult alpha (so we can remove it next).
                         imgCM.getTransparency(),      // Same trans as img
                         DataBuffer.TYPE_BYTE);        // 8 bit/component.

                WritableRaster wr = Raster.createBandedRaster
                    (DataBuffer.TYPE_BYTE,
                     argbWR.getWidth(), argbWR.getHeight(),
                     imgCompCM.getNumComponents(),
                     new Point(0, 0));

                BufferedImage imgComp = new BufferedImage
                    (imgCompCM, wr, imgCompCM.isAlphaPremultiplied(), null);

                BufferedImage srcImg = new BufferedImage
                    (imgCM, srcWR.createWritableTranslatedChild(0, 0),
                     imgCM.isAlphaPremultiplied(), null);

                Graphics2D g = imgComp.createGraphics();
                g.setRenderingHint(RenderingHints.KEY_COLOR_RENDERING,
                                   RenderingHints.VALUE_COLOR_RENDER_QUALITY);
                g.drawImage(srcImg, 0, 0, null);
                img = imgComp;
                imgCM = imgCompCM;
                srcWR = wr.createWritableTranslatedChild(minX, minY);
            }

            /**
             * Now, the input image is using a component color
             * model. We can therefore create an image with the new
             * profile, using a ComponentColorModel as well, because
             * we know the number of components match (this was
             * checked at the begining of this routine).  */
            ComponentColorModel newCM = new ComponentColorModel
                (colorSpace,                    // **** New ColorSpace ****
                 imgCM.getComponentSize(),      // Array of number of bits per components
                 false,                         // No alpa
                 false,                         // Not premultiplied
                 Transparency.OPAQUE,           // No transparency
                 DataBuffer.TYPE_BYTE);         // 8 Bits

            // Build a raster with bands 0, 1 and 2 of img's raster
            DataBufferByte data = (DataBufferByte)srcWR.getDataBuffer();
            srcWR = Raster.createBandedRaster
                (data, argbWR.getWidth(), argbWR.getHeight(),
                 argbWR.getWidth(), new int[]{0, 1, 2},
                 new int[]{0, 0, 0}, new Point(0, 0));
            BufferedImage newImg = new BufferedImage
                (newCM, srcWR, newCM.isAlphaPremultiplied(), null);

            /**
             * Now, convert the image to sRGB
             */
            ComponentColorModel sRGBCompCM = new ComponentColorModel
                (ColorSpace.getInstance(ColorSpace.CS_sRGB),
                 new int[]{8, 8, 8},
                 false,
                 false,
                 Transparency.OPAQUE,
                 DataBuffer.TYPE_BYTE);

            WritableRaster wr = Raster.createBandedRaster
                (DataBuffer.TYPE_BYTE, argbWR.getWidth(), argbWR.getHeight(),
                 sRGBCompCM.getNumComponents(), new Point(0, 0));

            BufferedImage sRGBImage = new BufferedImage
                (sRGBCompCM, wr, false, null);
            ColorConvertOp colorConvertOp = new ColorConvertOp(null);
            colorConvertOp.filter(newImg, sRGBImage);

            /**
             * Integrate alpha back into the image if there is any
             */
            if (imgCM.hasAlpha()){
                DataBufferByte rgbData = (DataBufferByte)wr.getDataBuffer();
                byte[][] imgBanks = data.getBankData();
                byte[][] rgbBanks = rgbData.getBankData();

                byte[][] argbBanks = {rgbBanks[0], rgbBanks[1],
                                      rgbBanks[2], imgBanks[3]};
                DataBufferByte argbData = new DataBufferByte(argbBanks, imgBanks[0].length);
                srcWR = Raster.createBandedRaster
                    (argbData, argbWR.getWidth(), argbWR.getHeight(),
                     argbWR.getWidth(), new int[]{0, 1, 2, 3},
                     new int[]{0, 0, 0, 0}, new Point(0, 0));
                sRGBCompCM = new ComponentColorModel
                    (ColorSpace.getInstance(ColorSpace.CS_sRGB),
                     new int[]{8, 8, 8, 8},
                     true,
                     false,
                     Transparency.TRANSLUCENT,
                     DataBuffer.TYPE_BYTE);
                sRGBImage = new BufferedImage(sRGBCompCM,
                                              srcWR,
                                              false,
                                              null);

            }

            /*BufferedImage result = new BufferedImage(img.getWidth(),
              img.getHeight(),
              BufferedImage.TYPE_INT_ARGB);*/
            BufferedImage result = new BufferedImage(sRGBCM,
                                                     argbWR.createWritableTranslatedChild(0, 0),
                                                     false,
                                                     null);


            ///////////////////////////////////////////////
            // BUG IN ColorConvertOp: The following breaks:
            // colorConvertOp.filter(sRGBImage, result);
            //
            // Using Graphics2D instead....
            ///////////////////////////////////////////////
            Graphics2D g = result.createGraphics();
            g.setRenderingHint(RenderingHints.KEY_COLOR_RENDERING,
                               RenderingHints.VALUE_COLOR_RENDER_QUALITY);
            g.drawImage(sRGBImage, 0, 0, null);
            g.dispose();

            return argbWR;
        }catch(Exception e){
            e.printStackTrace();
            throw new Error( e.getMessage() );
        }
    }

}
