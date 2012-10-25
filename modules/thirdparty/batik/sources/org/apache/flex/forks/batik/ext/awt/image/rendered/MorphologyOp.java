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

import java.awt.Rectangle;
import java.awt.RenderingHints;
import java.awt.color.ColorSpace;
import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.awt.image.BufferedImageOp;
import java.awt.image.ColorModel;
import java.awt.image.DataBuffer;
import java.awt.image.DataBufferInt;
import java.awt.image.DirectColorModel;
import java.awt.image.Raster;
import java.awt.image.RasterOp;
import java.awt.image.SampleModel;
import java.awt.image.SinglePixelPackedSampleModel;
import java.awt.image.WritableRaster;

import org.apache.flex.forks.batik.ext.awt.image.GraphicsUtil;

/**
 * This class provides an implementation for the SVG
 * feMorphology filter, as defined in Chapter 15, section 20
 * of the SVG specification.
 *
 * @author <a href="mailto:sheng.pei@sun.com">Sheng Pei</a>
 * @version $Id: MorphologyOp.java 489226 2006-12-21 00:05:36Z cam $
 */
public class MorphologyOp implements BufferedImageOp, RasterOp {
    /**
     * The radius of the operation on X axis
     */
    private int radiusX;
    /**
     * The radius of the operation on Y axis
     */
    private int radiusY;
    /*
     * Determine whether to do the dilation or erosion operation.
     * Will do dilation when it's true and erosion when it's false.
     */
    private boolean doDilation;

    /*
     * rangeX is 2*radiusX+1, which is the width of the Kernel
     */
    private final int rangeX;

    /*
     * rangeY is 2*radiusY+1, which is the height of the Kernel
     */
    private final int rangeY;

    /*
     * sRGB ColorSpace instance used for compatibility checking
     */
    private final ColorSpace sRGB = ColorSpace.getInstance(ColorSpace.CS_sRGB);

    /*
     * Linear RGB ColorSpace instance used for compatibility checking
     */
    private final ColorSpace lRGB = ColorSpace.getInstance(ColorSpace.CS_LINEAR_RGB);

    /**
     * @param radiusX defines the radius of filter operation on X-axis. Should not be negative.
     *        A value of zero will disable the effect of the operation on X-axis, as described
     *        in the SVG specification.
     * @param radiusY defines the radius of filter operation on Y-axis. Should not be negative.
     *        A value of zero will disable the effect of the operation on Y-axis, as described
     *        in the SVG specification.
     * @param doDilation defines whether to do dilation or erosion operation. Will do dilation
     *        when the value is true, erosion when false.
     */
    public MorphologyOp (int radiusX, int radiusY, boolean doDilation){
        if (radiusX<=0 || radiusY<=0){
            throw new IllegalArgumentException( "The radius of X-axis or Y-axis should not be Zero or Negatives." );
        }
        else {
            this.radiusX = radiusX;
            this.radiusY = radiusY;
            this.doDilation = doDilation;
            rangeX = 2*radiusX + 1;
            rangeY = 2*radiusY + 1;
        }
    }

    public Rectangle2D getBounds2D(Raster src){
        checkCompatible(src.getSampleModel());
        return new Rectangle(src.getMinX(), src.getMinY(), src.getWidth(), src.getHeight());
    }

    public Rectangle2D getBounds2D(BufferedImage src){
        return new Rectangle(0, 0, src.getWidth(), src.getHeight());
    }

    public Point2D getPoint2D(Point2D srcPt, Point2D destPt){
        // This operation does not affect pixel location
        if(destPt==null)
            destPt = new Point2D.Float();
        destPt.setLocation(srcPt.getX(), srcPt.getY());
        return destPt;
    }

    private void checkCompatible(ColorModel colorModel,
                                 SampleModel sampleModel){
        ColorSpace cs = colorModel.getColorSpace();

        // Check that model is sRGB or linear RGB
        if((!cs .equals (sRGB)) && (!cs .equals( lRGB)))
            throw new IllegalArgumentException("Expected CS_sRGB or CS_LINEAR_RGB color model");

        // Check ColorModel is of type DirectColorModel
        if(!(colorModel instanceof DirectColorModel))
            throw new IllegalArgumentException("colorModel should be an instance of DirectColorModel");

        // Check transfer type
        if(sampleModel.getDataType() != DataBuffer.TYPE_INT)
            throw new IllegalArgumentException("colorModel's transferType should be DataBuffer.TYPE_INT");

        // Check red, green, blue and alpha mask
        DirectColorModel dcm = (DirectColorModel)colorModel;
        if(dcm.getRedMask() != 0x00ff0000)
            throw new IllegalArgumentException("red mask in source should be 0x00ff0000");
        if(dcm.getGreenMask() != 0x0000ff00)
            throw new IllegalArgumentException("green mask in source should be 0x0000ff00");
        if(dcm.getBlueMask() != 0x000000ff)
            throw new IllegalArgumentException("blue mask in source should be 0x000000ff");
        if(dcm.getAlphaMask() != 0xff000000)
            throw new IllegalArgumentException("alpha mask in source should be 0xff000000");
    }

    private boolean isCompatible(ColorModel colorModel,
                                 SampleModel sampleModel){
        ColorSpace cs = colorModel.getColorSpace();
        // Check that model is sRGB or linear RGB
        if((cs != ColorSpace.getInstance(ColorSpace.CS_sRGB))
           &&
           (cs != ColorSpace.getInstance(ColorSpace.CS_LINEAR_RGB)))
            return false;

        // Check ColorModel is of type DirectColorModel
        if(!(colorModel instanceof DirectColorModel))
            return false;

        // Check transfer type
        if(sampleModel.getDataType() != DataBuffer.TYPE_INT)
            return false;

        // Check red, green, blue and alpha mask
        DirectColorModel dcm = (DirectColorModel)colorModel;
        if(dcm.getRedMask() != 0x00ff0000)
            return false;
        if(dcm.getGreenMask() != 0x0000ff00)
            return false;
        if(dcm.getBlueMask() != 0x000000ff)
            return false;
        if(dcm.getAlphaMask() != 0xff000000)
            return false;
        return true;
    }

    private void checkCompatible(SampleModel model){
        // Check model is ok: should be SinglePixelPackedSampleModel
        if(!(model instanceof SinglePixelPackedSampleModel))
            throw new IllegalArgumentException
                ("MorphologyOp only works with Rasters " +
                 "using SinglePixelPackedSampleModels");
        // Check number of bands
        int nBands = model.getNumBands();
        if(nBands!=4)
            throw new IllegalArgumentException
                ("MorphologyOp only words with Rasters having 4 bands");
        // Check that integer packed.
        if(model.getDataType()!=DataBuffer.TYPE_INT)
            throw new IllegalArgumentException
                ("MorphologyOp only works with Rasters using DataBufferInt");

        // Check bit masks
        int[] bitOffsets=((SinglePixelPackedSampleModel)model).getBitOffsets();
        for(int i=0; i<bitOffsets.length; i++){
            if(bitOffsets[i]%8 != 0)
                throw new IllegalArgumentException
                    ("MorphologyOp only works with Rasters using 8 bits " +
                     "per band : " + i + " : " + bitOffsets[i]);
        }
    }

    public RenderingHints getRenderingHints(){
        return null;
    }

    public WritableRaster createCompatibleDestRaster(Raster src){
        checkCompatible(src.getSampleModel());
        // Src Raster is OK: create a similar Raster for destination.
        return src.createCompatibleWritableRaster();
    }

    public BufferedImage createCompatibleDestImage(BufferedImage src,
                                                   ColorModel destCM){
        BufferedImage dest = null;
        if(destCM==null)
            destCM = src.getColorModel();

        WritableRaster wr;
        wr = destCM.createCompatibleWritableRaster(src.getWidth(),
                                                   src.getHeight());
        checkCompatible(destCM, wr.getSampleModel());

        dest = new BufferedImage(destCM, wr,
                                 destCM.isAlphaPremultiplied(), null);
        return dest;
    }

    /*
     * This method compares the two input variables according
     * to the doDilation boolean variable.
     */
    static final boolean isBetter (final int v1, final int v2, final boolean doDilation) {
        if (v1 > v2)
            return doDilation;
        if (v1 < v2)
            return !doDilation;
        return true;
    }

    /*
     * This method deals with the condition that the Kernel is wider than
     * the Image
     */
    private void specialProcessRow(Raster src, WritableRaster dest){
        final int w = src.getWidth();
        final int h = src.getHeight();

        // Access the integer buffer for each image.
        DataBufferInt srcDB = (DataBufferInt)src.getDataBuffer();
        DataBufferInt dstDB = (DataBufferInt)dest.getDataBuffer();

        // Offset defines where in the stack the real data begin
        SinglePixelPackedSampleModel sppsm;
        sppsm = (SinglePixelPackedSampleModel)src.getSampleModel();

        final int srcOff = srcDB.getOffset() +
            sppsm.getOffset(src.getMinX() - src.getSampleModelTranslateX(),
                            src.getMinY() - src.getSampleModelTranslateY());


        sppsm = (SinglePixelPackedSampleModel)dest.getSampleModel();
        final int dstOff = dstDB.getOffset() +
            sppsm.getOffset(dest.getMinX() - dest.getSampleModelTranslateX(),
                            dest.getMinY() - dest.getSampleModelTranslateY());

        // Stride is the distance between two consecutive column elements,
        // in the one-dimention dataBuffer
        final int srcScanStride = ((SinglePixelPackedSampleModel)src.getSampleModel()).getScanlineStride();
        final int dstScanStride = ((SinglePixelPackedSampleModel)dest.getSampleModel()).getScanlineStride();

        // Access the pixel value array
        final int[] srcPixels = srcDB.getBankData()[0];
        final int[] destPixels = dstDB.getBankData()[0];

        // The pointer of src and dest indicating where the pixel values are
        int sp, dp;

        // Declaration for the circular buffer's implementation
        // These are the circular buffers' head pointer and
        // the index pointers

        // bufferHead points to the leftmost element in the circular buffer
        int bufferHead;

        int maxIndexA;
        int maxIndexR;
        int maxIndexG;
        int maxIndexB;

        // Temp variables
        int pel, currentPixel, lastPixel;
        int a,r,g,b;
        int a1,r1,g1,b1;

        // If image width is less than or equal to the radiusX,
        // all the pixels share the same max/min value
        if (w<=radiusX){
            for (int i=0; i<h; i++){
                // pointing to the first pixels of each row
                sp = srcOff + i*srcScanStride;
                dp = dstOff + i*dstScanStride;
                pel = srcPixels[sp++];
                a = pel>>>24;
                r = pel&0xff0000;
                g = pel&0xff00;
                b = pel&0xff;

                for (int k=1; k<w; k++){
                    currentPixel = srcPixels[sp++];
                    a1 = currentPixel>>>24;
                    r1 = currentPixel&0xff0000;
                    g1 = currentPixel&0xff00;
                    b1 = currentPixel&0xff;

                    if (isBetter(a1, a, doDilation)){
                        a = a1;
                    }
                    if (isBetter(r1, r, doDilation)){
                        r = r1;
                    }
                    if (isBetter(g1, g, doDilation)){
                        g = g1;
                    }
                    if (isBetter(b1, b, doDilation)){
                        b = b1;
                    }
                }
                // all the element share the same max/min value
                for (int k=0; k<w; k++){
                    destPixels[dp++] = (a << 24) | r | g | b;
                }
            }
        }

        // When radiusX < w <= 2*radiusX
        else {

            // The width of the circular buffer is w
            final int [] bufferA = new int [w];
            final int [] bufferR = new int [w];
            final int [] bufferG = new int [w];
            final int [] bufferB = new int [w];

            for (int i=0; i<h; i++){
                // initialization of pointers, indice
                // at the head of each row
                sp = srcOff + i*srcScanStride;
                dp = dstOff + i*dstScanStride;

                bufferHead = 0;
                maxIndexA = 0;
                maxIndexR = 0;
                maxIndexG = 0;
                maxIndexB = 0;

                pel = srcPixels[sp++];
                a = pel>>>24;
                r = pel&0xff0000;
                g = pel&0xff00;
                b = pel&0xff;
                bufferA[0] = a;
                bufferR[0] = r;
                bufferG[0] = g;
                bufferB[0] = b;

                for (int k=1; k<=radiusX; k++){
                    currentPixel = srcPixels[sp++];
                    a1 = currentPixel>>>24;
                    r1 = currentPixel&0xff0000;
                    g1 = currentPixel&0xff00;
                    b1 = currentPixel&0xff;
                    bufferA[k] = a1;
                    bufferR[k] = r1;
                    bufferG[k] = g1;
                    bufferB[k] = b1;

                    if (isBetter(a1, a, doDilation)){
                        a = a1;
                        maxIndexA = k;
                    }
                    if (isBetter(r1, r, doDilation)){
                        r = r1;
                        maxIndexR = k;
                    }
                    if (isBetter(g1, g, doDilation)){
                        g = g1;
                        maxIndexG = k;
                    }
                    if (isBetter(b1, b, doDilation)){
                        b = b1;
                        maxIndexB = k;
                    }
                }
                destPixels[dp++] = (a << 24) | r | g | b;

                //
                // 1 <= j <= w-radiusX-1 : The left margin of each row.
                //
                for (int j=1; j<=w-radiusX-1; j++){
                    lastPixel = srcPixels[sp++];

                    // here is the Alpha channel

                    // we retrieve the previous max/min value
                    a = bufferA[maxIndexA];
                    a1 = lastPixel>>>24;
                    bufferA[j+radiusX] = a1;
                    if (isBetter(a1, a, doDilation)){
                        a = a1;
                        maxIndexA = j+radiusX;
                    }

                    // now we deal with the Red channel

                    r = bufferR[maxIndexR];
                    r1 = lastPixel&0xff0000;
                    bufferR[j+radiusX] = r1;
                    if (isBetter(r1, r, doDilation)){
                        r = r1;
                        maxIndexR = j+radiusX;
                    }

                    // now we deal with the Green channel

                    g = bufferG[maxIndexG];
                    g1 = lastPixel&0xff00;
                    bufferG[j+radiusX] = g1;
                    if (isBetter(g1, g, doDilation)){
                        g = g1;
                        maxIndexG = j+radiusX;
                    }

                    // now we deal with the Blue channel

                    b = bufferB[maxIndexB];
                    b1 = lastPixel&0xff;
                    bufferB[j+radiusX] = b1;
                    if (isBetter(b1, b, doDilation)){
                        b = b1;
                        maxIndexB = j+radiusX;
                    }
                    // now we have gone through the four channels and
                    // updated the index array. then we'll pack the
                    // new max/min value according to each channel's
                    // max/min vlue

                    destPixels[dp++] = (a << 24) | r | g | b;
                }
                // Now is the inner body of the row:
                // all elements in this segment share the same max/min value
                for (int j = w-radiusX; j<= radiusX; j++){
                    destPixels[dp] = destPixels[dp-1];
                    dp++;
                }
                // Now the circular buffer is full
                // Now is the right margin of the row when radiusX < w <= 2*radiusX
                for (int j = radiusX+1; j<w; j++){

                    if (maxIndexA == bufferHead){
                        a = bufferA[bufferHead+1];
                        maxIndexA = bufferHead+1;
                        for (int m= bufferHead+2; m< w; m++){
                            a1 = bufferA[m];
                            if (isBetter(a1, a, doDilation)){
                                a = a1;
                                maxIndexA = m;
                            }
                        }
                    }
                    else {
                        a = bufferA[maxIndexA];
                    }
                    if (maxIndexR == bufferHead){
                        r = bufferR[bufferHead+1];
                        maxIndexR = bufferHead+1;
                        for (int m= bufferHead+2; m< w; m++){
                            r1 = bufferR[m];
                            if (isBetter(r1, r, doDilation)){
                                r = r1;
                                maxIndexR = m;
                            }
                        }
                    }
                    else {
                        r = bufferR[maxIndexR];
                    }

                    if (maxIndexG == bufferHead){
                        g = bufferG[bufferHead+1];
                        maxIndexG = bufferHead+1;
                        for (int m= bufferHead+2; m< w; m++){
                            g1 = bufferG[m];
                            if (isBetter(g1, g, doDilation)){
                                g = g1;
                                maxIndexG = m;
                            }
                        }
                    }
                    // we can reuse the previous max/min value
                    else {
                        g = bufferG[maxIndexG];
                    }

                    if (maxIndexB == bufferHead){
                        b = bufferB[bufferHead+1];
                        maxIndexB = bufferHead+1;
                        for (int m= bufferHead+2; m< w; m++){
                            b1 = bufferB[m];
                            if (isBetter(b1, b, doDilation)){
                                b = b1;
                                maxIndexB = m;
                            }
                        }
                    }
                    // we can reuse the previous max/min value
                    else {
                        b = bufferB[maxIndexB];
                    }

                    // discard the leftmost element
                    bufferHead++;

                    destPixels[dp++] = (a << 24) | r | g | b;
                }
                // return to the first pixel of the next row
            }
        }// When radiusX < w <=2*radiusX
    }

    /*
     * This method deals with the condition when the Kernel is
     * higher than the image.
     */
    private void specialProcessColumn(Raster src, WritableRaster dest){

        final int w = src.getWidth();
        final int h = src.getHeight();

        // Access the integer buffer for each image.
        DataBufferInt dstDB = (DataBufferInt)dest.getDataBuffer();

        // Offset defines where in the stack the real data begin
        final int dstOff = dstDB.getOffset();

        // Stride is the distance between two consecutive column elements,
        // in the one-dimention dataBuffer
        final int dstScanStride = ((SinglePixelPackedSampleModel)dest.getSampleModel()).getScanlineStride();

        // Access the pixel value array
        final int[] destPixels = dstDB.getBankData()[0];

        // The pointer of src and dest indicating where the pixel values are
        int dp, cp;

        // Declaration for the circular buffer's implementation
        // These are the circular buffers' head pointer and
        // the index pointers

        // bufferHead points to the leftmost element in the circular buffer
        int bufferHead;

        int maxIndexA;
        int maxIndexR;
        int maxIndexG;
        int maxIndexB;

        // Temp variables
        int pel, currentPixel, lastPixel;
        int a,r,g,b;
        int a1,r1,g1,b1;

        // Here all the pixels share the same
        // max/min value
        if (h<=radiusY){
            for (int j=0; j<w; j++){
                dp = dstOff + j;
                cp = dstOff + j;
                pel = destPixels[cp];
                cp += dstScanStride;
                a = pel>>>24;
                r = pel&0xff0000;
                g = pel&0xff00;
                b = pel&0xff;

                for (int k=1; k<h; k++){
                    currentPixel = destPixels[cp];
                    cp += dstScanStride;
                    a1 = currentPixel>>>24;
                    r1 = currentPixel&0xff0000;
                    g1 = currentPixel&0xff00;
                    b1 = currentPixel&0xff;

                    if (isBetter(a1, a, doDilation)){
                        a = a1;
                    }
                    if (isBetter(r1, r, doDilation)){
                        r = r1;
                    }
                    if (isBetter(g1, g, doDilation)){
                        g = g1;
                    }
                    if (isBetter(b1, b, doDilation)){
                        b = b1;
                    }
                }
                for (int k=0; k<h; k++){
                    destPixels[dp] = (a << 24) | r | g | b;
                    dp += dstScanStride;
                }
                // return to the first pixel of the next column
            }
        }

        // When radiusY < h <= 2*radiusY
        else {

            // The height of the circular buffer is h
            final int [] bufferA = new int [h];
            final int [] bufferR = new int [h];
            final int [] bufferG = new int [h];
            final int [] bufferB = new int [h];

            for (int j=0; j<w; j++){
                // initialization of pointers, indice
                // at the head of each column
                dp = dstOff + j;
                cp = dstOff + j;

                bufferHead = 0;
                maxIndexA = 0;
                maxIndexR = 0;
                maxIndexG = 0;
                maxIndexB = 0;

                pel = destPixels[cp];
                cp += dstScanStride;
                a = pel>>>24;
                r = pel&0xff0000;
                g = pel&0xff00;
                b = pel&0xff;
                bufferA[0] = a;
                bufferR[0] = r;
                bufferG[0] = g;
                bufferB[0] = b;

                for (int k=1; k<=radiusY; k++){
                    currentPixel = destPixels[cp];
                    cp += dstScanStride;
                    a1 = currentPixel>>>24;
                    r1 = currentPixel&0xff0000;
                    g1 = currentPixel&0xff00;
                    b1 = currentPixel&0xff;
                    bufferA[k] = a1;
                    bufferR[k] = r1;
                    bufferG[k] = g1;
                    bufferB[k] = b1;

                    if (isBetter(a1, a, doDilation)){
                        a = a1;
                        maxIndexA = k;
                    }
                    if (isBetter(r1, r, doDilation)){
                        r = r1;
                        maxIndexR = k;
                    }
                    if (isBetter(g1, g, doDilation)){
                        g = g1;
                        maxIndexG = k;
                    }
                    if (isBetter(b1, b, doDilation)){
                        b = b1;
                        maxIndexB = k;
                    }
                }
                // fill the first pixel of each column
                destPixels[dp] = (a << 24) | r | g | b;
                dp += dstScanStride;

                //
                // 1 <= i <= h-1-radiusY : The upper margin of each column.
                //
                for (int i=1; i<=h-radiusY-1; i++){
                    lastPixel = destPixels[cp];
                    cp += dstScanStride;

                    // here is the Alpha channel

                    a = bufferA[maxIndexA];
                    a1 = lastPixel>>>24;
                    bufferA[i+radiusY] = a1;
                    if (isBetter(a1, a, doDilation)){
                        a = a1;
                        maxIndexA = i+radiusY;
                    }

                    // now we deal with the Red channel

                    r = bufferR[maxIndexR];
                    r1 = lastPixel&0xff0000;
                    bufferR[i+radiusY] = r1;
                    if (isBetter(r1, r, doDilation)){
                        r = r1;
                        maxIndexR = i+radiusY;
                    }

                    // now we deal with the Green channel

                    g = bufferG[maxIndexG];
                    g1 = lastPixel&0xff00;
                    bufferG[i+radiusY] = g1;
                    if (isBetter(g1, g, doDilation)){
                        g = g1;
                        maxIndexG = i+radiusY;
                    }

                    // now we deal with the Blue channel

                    b = bufferB[maxIndexB];
                    b1 = lastPixel&0xff;
                    bufferB[i+radiusY] = b1;
                    if (isBetter(b1, b, doDilation)){
                        b = b1;
                        maxIndexB = i+radiusY;
                    }
                    // now we have gone through the four channels and
                    // updated the index array. then we'll pack the
                    // new max/min value according to each channel's
                    // max/min vlue

                    destPixels[dp] = (a << 24) | r | g | b;
                    dp += dstScanStride;
                }
                // Now is the inner body of the column
                // when radiusY < h <= 2*radiusY
                for (int i = h-radiusY; i<= radiusY; i++){
                    destPixels[dp] = destPixels[dp-dstScanStride];
                    dp += dstScanStride;
                }
                // The circular buffer is full now

                for (int i = radiusY+1; i<h; i++){

                    if (maxIndexA == bufferHead){
                        a = bufferA[bufferHead+1];
                        maxIndexA = bufferHead+1;
                        for (int m= bufferHead+2; m< h; m++){
                            a1 = bufferA[m];
                            if (isBetter(a1, a, doDilation)){
                                a = a1;
                                maxIndexA = m;
                            }
                        }
                    }
                    else {
                        a = bufferA[maxIndexA];
                    }
                    if (maxIndexR == bufferHead){
                        r = bufferR[bufferHead+1];
                        maxIndexR = bufferHead+1;
                        for (int m= bufferHead+2; m< h; m++){
                            r1 = bufferR[m];
                            if (isBetter(r1, r, doDilation)){
                                r = r1;
                                maxIndexR = m;
                            }
                        }
                    }
                    else {
                        r = bufferR[maxIndexR];
                    }

                    if (maxIndexG == bufferHead){
                        g = bufferG[bufferHead+1];
                        maxIndexG = bufferHead+1;
                        for (int m= bufferHead+2; m< h; m++){
                            g1 = bufferG[m];
                            if (isBetter(g1, g, doDilation)){
                                g = g1;
                                maxIndexG = m;
                            }
                        }
                    }
                    // we can reuse the previous max/min value
                    else {
                        g = bufferG[maxIndexG];
                    }

                    if (maxIndexB == bufferHead){
                        b = bufferB[bufferHead+1];
                        maxIndexB = bufferHead+1;
                        for (int m= bufferHead+2; m< h; m++){
                            b1 = bufferB[m];
                            if (isBetter(b1, b, doDilation)){
                                b = b1;
                                maxIndexB = m;
                            }
                        }
                    }
                    // we can reuse the previous max/min value
                    else {
                        b = bufferB[maxIndexB];
                    }

                    // discard the leftmost element
                    bufferHead++;

                    destPixels[dp] = (a << 24) | r | g | b;
                    dp += dstScanStride;
                }
                // return to the first pixel of the next column
            }
        } // when radiusY < h <= 2*radiusY
    }

    /**
     * Filters src and writes result into dest. If dest if null, then
     * a Raster is created. If dest and src refer to the same object,
     * then the source is modified.
     * <p>
     * The filtering kernel(the operation range for each pixel) is a
     * rectangle of width 2*radiusX+1 and height radiusY+1
     * <p>
     * @param src the Raster to be filtered
     * @param dest stores the filtered image. If null, a destination will
     *        be created. src and dest can refer to the same Raster, in
     *        which situation the src will be modified.
     */
    public WritableRaster filter(Raster src, WritableRaster dest){

        //
        //This method sorts the pixel values in the kernel window in two steps:
        // 1. sort by row and store the result into an intermediate matrix
        // 2. sort the intermediate matrix by column and output the max/min value
        //    into the destination matrix element

        //check destation
        if(dest!=null) checkCompatible(dest.getSampleModel());
        else {
            if(src==null)
                throw new IllegalArgumentException("src should not be null when dest is null");
            else dest = createCompatibleDestRaster(src);
        }

        final int w = src.getWidth();
        final int h = src.getHeight();

        // Access the integer buffer for each image.
        DataBufferInt srcDB = (DataBufferInt)src.getDataBuffer();
        DataBufferInt dstDB = (DataBufferInt)dest.getDataBuffer();

        // Offset defines where in the stack the real data begin
        final int srcOff = srcDB.getOffset();
        final int dstOff = dstDB.getOffset();

        // Stride is the distance between two consecutive column elements,
        // in the one-dimention dataBuffer
        final int srcScanStride = ((SinglePixelPackedSampleModel)src.getSampleModel()).getScanlineStride();
        final int dstScanStride = ((SinglePixelPackedSampleModel)dest.getSampleModel()).getScanlineStride();

        // Access the pixel value array
        final int[] srcPixels = srcDB.getBankData()[0];
        final int[] destPixels = dstDB.getBankData()[0];

        // The pointer of src and dest indicating where the pixel values are
        int sp, dp, cp;

        // Declaration for the circular buffer's implementation
        // These are the circular buffers' head pointer and
        // the index pointers

        // bufferHead points to the leftmost element in the circular buffer
        int bufferHead;

        int maxIndexA;
        int maxIndexR;
        int maxIndexG;
        int maxIndexB;

        // Temp variables
        int pel, currentPixel, lastPixel;
        int a,r,g,b;
        int a1,r1,g1,b1;

        // In both round, we are using an optimization approach
        // to reduce excessive computation to sort values around
        // the current pixel. The idea is as follows:
        //           ----------------
        //           |*|V|V|$|N|V|V|&|
        //           ----------------
        // For example, suppose we've finished pixel"$" and come
        // to "N", the radius is 3. Then we must have got the max/min
        // value and index array for "$". If the max/min is at
        // "*"(using the index array to judge this),
        // we need to recompute a max/min and the index array
        // for "N"; if the max/min is not at "*", we can
        // reuse the current max/min: we simply compare it with
        // "&", and update the max/min and the index array.

        //
        // The first round: sort by row
        //
        if (w<=2*radiusX){
            specialProcessRow(src, dest);
        }

        // when the size is large enough, we can
        // use standard optimization method
        else {

            final int [] bufferA = new int [rangeX];
            final int [] bufferR = new int [rangeX];
            final int [] bufferG = new int [rangeX];
            final int [] bufferB = new int [rangeX];

            for (int i=0; i<h; i++){
                // initialization of pointers, indice
                // at the head of each row
                sp = srcOff + i*srcScanStride;
                dp = dstOff + i*dstScanStride;
                bufferHead = 0;
                maxIndexA = 0;
                maxIndexR = 0;
                maxIndexG = 0;
                maxIndexB = 0;

                //
                // j=0 : Initialization, compute the max/min and
                //       index array for the use of other pixels.
                //
                pel = srcPixels[sp++];
                a = pel>>>24;
                r = pel&0xff0000;
                g = pel&0xff00;
                b = pel&0xff;
                bufferA[0] = a;
                bufferR[0] = r;
                bufferG[0] = g;
                bufferB[0] = b;

                for (int k=1; k<=radiusX; k++){
                    currentPixel = srcPixels[sp++];
                    a1 = currentPixel>>>24;
                    r1 = currentPixel&0xff0000;
                    g1 = currentPixel&0xff00;
                    b1 = currentPixel&0xff;
                    bufferA[k] = a1;
                    bufferR[k] = r1;
                    bufferG[k] = g1;
                    bufferB[k] = b1;

                    if (isBetter(a1, a, doDilation)){
                        a = a1;
                        maxIndexA = k;
                    }
                    if (isBetter(r1, r, doDilation)){
                        r = r1;
                        maxIndexR = k;
                    }
                    if (isBetter(g1, g, doDilation)){
                        g = g1;
                        maxIndexG = k;
                    }
                    if (isBetter(b1, b, doDilation)){
                        b = b1;
                        maxIndexB = k;
                    }
                }
                destPixels[dp++] = (a << 24) | r | g | b;

                //
                // 1 <= j <= radiusX : The left margin of each row.
                //
                for (int j=1; j<=radiusX; j++){
                    lastPixel = srcPixels[sp++];

                    // here is the Alpha channel

                    // we retrieve the previous max/min value
                    a = bufferA[maxIndexA];
                    a1 = lastPixel>>>24;
                    bufferA[j+radiusX] = a1;
                    if (isBetter(a1, a, doDilation)){
                        a = a1;
                        maxIndexA = j+radiusX;
                    }

                    // now we deal with the Red channel

                    r = bufferR[maxIndexR];
                    r1 = lastPixel&0xff0000;
                    bufferR[j+radiusX] = r1;
                    if (isBetter(r1, r, doDilation)){
                        r = r1;
                        maxIndexR = j+radiusX;
                    }

                    // now we deal with the Green channel

                    g = bufferG[maxIndexG];
                    g1 = lastPixel&0xff00;
                    bufferG[j+radiusX] = g1;
                    if (isBetter(g1, g, doDilation)){
                        g = g1;
                        maxIndexG = j+radiusX;
                    }

                    // now we deal with the Blue channel

                    b = bufferB[maxIndexB];
                    b1 = lastPixel&0xff;
                    bufferB[j+radiusX] = b1;
                    if (isBetter(b1, b, doDilation)){
                        b = b1;
                        maxIndexB = j+radiusX;
                    }
                    // now we have gone through the four channels and
                    // updated the index array. then we'll pack the
                    // new max/min value according to each channel's
                    // max/min vlue

                    destPixels[dp++] = (a << 24) | r | g | b;
                }

                //
                // radiusX <= j <= w-1-radiusX : Inner body of the row, between
                //                               left and right margins
                //
                for (int j=radiusX+1; j<=w-1-radiusX; j++){
                    lastPixel = srcPixels[sp++];
                    a1 = lastPixel>>>24;
                    r1 = lastPixel&0xff0000;
                    g1 = lastPixel&0xff00;
                    b1 = lastPixel&0xff;
                    bufferA[bufferHead] = a1;
                    bufferR[bufferHead] = r1;
                    bufferG[bufferHead] = g1;
                    bufferB[bufferHead] = b1;

                    // Alpha channel:
                    // we need to recompute a local max/min
                    // and update the max/min index
                    if (maxIndexA == bufferHead){
                        a = bufferA[0];
                        maxIndexA = 0;
                        for (int m= 1; m< rangeX; m++){
                            a1 = bufferA[m];
                            if (isBetter(a1, a, doDilation)){
                                a = a1;
                                maxIndexA = m;
                            }
                        }
                    }
                    // we can reuse the previous max/min value
                    else {
                        a = bufferA[maxIndexA];
                        if (isBetter(a1, a, doDilation)){
                            a = a1;
                            maxIndexA = bufferHead;
                        }
                    }

                    // Red channel
                    // we need to recompute a local max/min
                    // and update the index array

                    if (maxIndexR == bufferHead){
                        r = bufferR[0];
                        maxIndexR = 0;
                        for (int m= 1; m< rangeX; m++){
                            r1 = bufferR[m];
                            if (isBetter(r1, r, doDilation)){
                                r = r1;
                                maxIndexR = m;
                            }
                        }
                    }
                    // we can reuse the previous max/min value
                    else {
                        r = bufferR[maxIndexR];
                        if (isBetter(r1, r, doDilation)){
                            r = r1;
                            maxIndexR = bufferHead;
                        }
                    }

                    // Green channel
                    // we need to recompute a local max/min
                    // and update the index array

                    if (maxIndexG == bufferHead){
                        g = bufferG[0];
                        maxIndexG = 0;
                        for (int m= 1; m< rangeX; m++){
                            g1 = bufferG[m];
                            if (isBetter(g1, g, doDilation)){
                                g = g1;
                                maxIndexG = m;
                            }
                        }
                    }
                    // we can reuse the previous max/min value
                    else {
                        g = bufferG[maxIndexG];
                        if (isBetter(g1, g, doDilation)){
                            g = g1;
                            maxIndexG = bufferHead;
                        }
                    }

                    // Blue channel
                    // we need to recompute a local max/min
                    // and update the index array

                    if (maxIndexB == bufferHead){
                        b = bufferB[0];
                        maxIndexB = 0;
                        for (int m= 1; m< rangeX; m++){
                            b1 = bufferB[m];
                            if (isBetter(b1, b, doDilation)){
                                b = b1;
                                maxIndexB = m;
                            }
                        }
                    }
                    // we can reuse the previous max/min value
                    else {
                        b = bufferB[maxIndexB];
                        if (isBetter(b1, b, doDilation)){
                            b = b1;
                            maxIndexB = bufferHead;
                        }
                    }
                    destPixels[dp++] = (a << 24) | r | g | b;
                    bufferHead = (bufferHead+1)%rangeX;
                }

                //
                // w-radiusX <= j < w : The right margin of the row
                //

                // Head will be updated to indicate the current head
                // of the remaining buffer
                int head;
                // Tail is where the last element is
                final int tail = (bufferHead == 0)?rangeX-1:bufferHead -1;
                int count = rangeX-1;

                for (int j=w-radiusX; j<w; j++){
                    head = (bufferHead+1)%rangeX;
                    // Dealing with Alpha Channel:
                    if (maxIndexA == bufferHead){
                        a = bufferA[tail];
                        int hd = head;
                        for(int m=1; m<count; m++) {
                            a1 = bufferA[hd];
                            if (isBetter(a1, a, doDilation)){
                                a = a1;
                                maxIndexA = hd;
                            }
                            hd = (hd+1)%rangeX;
                        }
                    }
                    // Dealing with Red Channel:
                    if (maxIndexR == bufferHead){
                        r = bufferR[tail];
                        int hd = head;
                        for(int m=1; m<count; m++) {
                            r1 = bufferR[hd];
                            if (isBetter(r1, r, doDilation)){
                                r = r1;
                                maxIndexR = hd;
                            }
                            hd = (hd+1)%rangeX;
                        }
                    }
                    // Dealing with Green Channel:
                    if (maxIndexG == bufferHead){
                        g = bufferG[tail];
                        int hd = head;
                        for(int m=1; m<count; m++) {
                            g1 = bufferG[hd];
                            if (isBetter(g1, g, doDilation)){
                                g = g1;
                                maxIndexG = hd;
                            }
                            hd = (hd+1)%rangeX;
                        }
                    }
                    // Dealing with Blue Channel:
                    if (maxIndexB == bufferHead){
                        b = bufferB[tail];
                        int hd = head;
                        for(int m=1; m<count; m++) {
                            b1 = bufferB[hd];
                            if (isBetter(b1, b, doDilation)){
                                b = b1;
                                maxIndexB = hd;
                            }
                            hd = (hd+1)%rangeX;
                        }
                    }
                    destPixels[dp++] = (a << 24) | r | g | b;
                    bufferHead = (bufferHead+1)%rangeX;
                    // we throw another element
                    count--;
                }// end of the right margin of this row

                // return to the beginning of the next row
            }
        }// end of the first round!

        //
        // Second round: sort by column
        // the difference from the first round is that
        // now we are accessing the intermediate matrix
        //

        // When the image size is smaller than the
        // Kernel size
        if (h<=2*radiusY){
            specialProcessColumn(src, dest);
        }

        // when the size is large enough, we can
        // use standard optimization method
        else {
            final int [] bufferA = new int [rangeY];
            final int [] bufferR = new int [rangeY];
            final int [] bufferG = new int [rangeY];
            final int [] bufferB = new int [rangeY];

            for (int j=0; j<w; j++){
                // initialization of pointers, indice
                // at the head of each column
                dp = dstOff + j;
                cp = dstOff + j;
                bufferHead = 0;
                maxIndexA = 0;
                maxIndexR = 0;
                maxIndexG = 0;
                maxIndexB = 0;

                // i=0 : The first pixel
                pel = destPixels[cp];
                cp += dstScanStride;
                a = pel>>>24;
                r = pel&0xff0000;
                g = pel&0xff00;
                b = pel&0xff;
                bufferA[0] = a;
                bufferR[0] = r;
                bufferG[0] = g;
                bufferB[0] = b;

                for (int k=1; k<=radiusY; k++){
                    currentPixel = destPixels[cp];
                    cp += dstScanStride;
                    a1 = currentPixel>>>24;
                    r1 = currentPixel&0xff0000;
                    g1 = currentPixel&0xff00;
                    b1 = currentPixel&0xff;
                    bufferA[k] = a1;
                    bufferR[k] = r1;
                    bufferG[k] = g1;
                    bufferB[k] = b1;

                    if (isBetter(a1, a, doDilation)){
                        a = a1;
                        maxIndexA = k;
                    }
                    if (isBetter(r1, r, doDilation)){
                        r = r1;
                        maxIndexR = k;
                    }
                    if (isBetter(g1, g, doDilation)){
                        g = g1;
                        maxIndexG = k;
                    }
                    if (isBetter(b1, b, doDilation)){
                        b = b1;
                        maxIndexB = k;
                    }
                }
                destPixels[dp] = (a << 24) | r | g | b;
                // go to the next element in the column.
                dp += dstScanStride;

                // 1 <= i <= radiusY : The upper margin of each row
                for (int i=1; i<=radiusY; i++){
                    int maxI = i+radiusY;
                    // we can reuse the previous max/min value
                    lastPixel = destPixels[cp];
                    cp += dstScanStride;

                    // here is the Alpha channel
                    a = bufferA[maxIndexA];
                    a1 = lastPixel>>>24;
                    bufferA[maxI] = a1;
                    if (isBetter(a1, a, doDilation)){
                        a = a1;
                        maxIndexA = maxI;
                    }

                    // now we deal with the Red channel
                    r = bufferR[maxIndexR];
                    r1 = lastPixel&0xff0000;
                    bufferR[maxI] = r1;
                    if (isBetter(r1, r, doDilation)){
                        r = r1;
                        maxIndexR = maxI;
                    }

                    // now we deal with the Green channel
                    g = bufferG[maxIndexG];
                    g1 = lastPixel&0xff00;
                    bufferG[maxI] = g1;
                    if (isBetter(g1, g, doDilation)){
                        g = g1;
                        maxIndexG = maxI;
                    }

                    // now we deal with the Blue channel
                    b = bufferB[maxIndexB];
                    b1 = lastPixel&0xff;
                    bufferB[maxI] = b1;
                    if (isBetter(b1, b, doDilation)){
                        b = b1;
                        maxIndexB = maxI;
                    }
                    destPixels[dp] = (a << 24) | r | g | b;
                    dp += dstScanStride;
                }

                //
                // radiusY +1 <= i <= h-1-radiusY:
                //    inner body of the column between upper and lower margins
                //

                for (int i=radiusY+1; i<=h-1-radiusY; i++){

                    lastPixel = destPixels[cp];
                    cp += dstScanStride;
                    a1 = lastPixel>>>24;
                    r1 = lastPixel&0xff0000;
                    g1 = lastPixel&0xff00;
                    b1 = lastPixel&0xff;
                    bufferA[bufferHead] = a1;
                    bufferR[bufferHead] = r1;
                    bufferG[bufferHead] = g1;
                    bufferB[bufferHead] = b1;

                    // here we check if the previous max/min value can be
                    // reused safely and, if possible, reuse the previous
                    // maximum value

                    // Alpha channel:

                    // Recompute the local max/min
                    if (maxIndexA == bufferHead){
                        a = bufferA[0];
                        maxIndexA = 0;
                        for (int m= 1; m<= 2*radiusY; m++){
                            a1 = bufferA[m];
                            if (isBetter(a1, a, doDilation)){
                                a = a1;
                                maxIndexA = m;
                            }
                        }
                    }
                    // we can reuse the previous max/min value
                    else {
                        a = bufferA[maxIndexA];
                        if (isBetter(a1, a, doDilation)){
                            a = a1;
                            maxIndexA = bufferHead;
                        }
                    }

                    // Red channel:

                    if (maxIndexR == bufferHead){
                        r = bufferR[0];
                        maxIndexR = 0;
                        for (int m= 1; m<= 2*radiusY; m++){
                            r1 = bufferR[m];
                            if (isBetter(r1, r, doDilation)){
                                r = r1;
                                maxIndexR = m;
                            }
                        }
                    }
                    // we can reuse the previous max/min value
                    else {
                        r = bufferR[maxIndexR];
                        if (isBetter(r1, r, doDilation)){
                            r = r1;
                            maxIndexR = bufferHead;
                        }
                    }

                    // Green channel
                    if (maxIndexG == bufferHead){
                        g = bufferG[0];
                        maxIndexG = 0;
                        for (int m= 1; m<= 2*radiusY; m++){
                            g1 = bufferG[m];
                            if (isBetter(g1, g, doDilation)){
                                g = g1;
                                maxIndexG = m;
                            }
                        }
                    }
                    // we can reuse the previous max/min value
                    else {
                        g = bufferG[maxIndexG];
                        if (isBetter(g1, g, doDilation)){
                            g = g1;
                            maxIndexG = bufferHead;
                        }
                    }

                    // Blue channel:
                    if (maxIndexB == bufferHead){
                        b = bufferB[0];
                        maxIndexB = 0;
                        for (int m= 1; m<= 2*radiusY; m++){
                            b1 = bufferB[m];
                            if (isBetter(b1, b, doDilation)){
                                b = b1;
                                maxIndexB = m;
                            }
                        }
                    }
                    // we can reuse the previous max/min value
                    else {
                        b = bufferB[maxIndexB];
                        if (isBetter(b1, b, doDilation)){
                            b = b1;
                            maxIndexB = bufferHead;
                        }
                    }
                    destPixels[dp] = (a << 24) | r | g | b;
                    dp += dstScanStride;
                    bufferHead = (bufferHead+1)%rangeY;
                }

                //
                // h-radiusY <= i <= h-1 : The lower margin of the column
                //

                // head will be updated to indicate the current head
                // of the remaining buffer:
                int head;
                // tail is where the last element in the buffer is
                final int tail = (bufferHead == 0)?2*radiusY:bufferHead -1;
                int count = rangeY-1;

                for (int i= h-radiusY; i<h-1; i++){
                    head = (bufferHead +1)%rangeY;

                    if (maxIndexA == bufferHead){
                        a = bufferA[tail];
                        int hd = head;
                        for (int m=1; m<count; m++){
                            a1 = bufferA[hd];
                            if (isBetter(a1, a, doDilation)){
                                a = a1;
                                maxIndexA = hd;
                            }
                            hd = (hd+1)%rangeY;
                        }
                    }
                    if (maxIndexR == bufferHead){
                        r = bufferR[tail];
                        int hd = head;
                        for (int m=1; m<count; m++){
                            r1 = bufferR[hd];
                            if (isBetter(r1, r, doDilation)){
                                r = r1;
                                maxIndexR = hd;
                            }
                            hd = (hd+1)%rangeY;
                        }
                    }
                    if (maxIndexG == bufferHead){
                        g = bufferG[tail];
                        int hd = head;
                        for (int m=1; m<count; m++){
                            g1 = bufferG[hd];
                            if (isBetter(g1, g, doDilation)){
                                g = g1;
                                maxIndexG = hd;
                            }
                            hd = (hd+1)%rangeY;
                        }
                    }
                    if (maxIndexB == bufferHead){
                        b = bufferB[tail];
                        int hd = head;
                        for (int m=1; m<count; m++){
                            b1 = bufferB[hd];
                            if (isBetter(b1, b, doDilation)){
                                b = b1;
                                maxIndexB = hd;
                            }
                            hd = (hd+1)%rangeY;
                        }
                    }
                    destPixels[dp] = (a << 24) | r | g | b;
                    dp += dstScanStride;
                    bufferHead = (bufferHead+1)%rangeY;
                    // we throw out this useless element
                    count--;
                }
                // return to the beginning of the next column
            }
        }// end of the second round!

        return dest;
    }// end of the filter() method for Raster

      /**
       * This implementation of filter does the morphology operation
       * on a premultiplied alpha image.  This tends to muddy the
       * colors.  so something that is supposed to be a mostly
       * transparent bright red may well become a muddy opaque red.
       * Where as I think it should become a bright opaque red. Which
       * is the result you would get if you were using unpremult data.
       */
    public BufferedImage filter(BufferedImage src, BufferedImage dest){
        if (src == null)
            throw new NullPointerException("Source image should not be null");

        BufferedImage origSrc   = src;
        BufferedImage finalDest = dest;

        if (!isCompatible(src.getColorModel(), src.getSampleModel())) {
            src = new BufferedImage(src.getWidth(), src.getHeight(),
                                    BufferedImage.TYPE_INT_ARGB_PRE);
            GraphicsUtil.copyData(origSrc, src);
        }
        else if (!src.isAlphaPremultiplied()) {
            // Get a Premultipled CM.
            ColorModel    srcCM, srcCMPre;
            srcCM    = src.getColorModel();
            srcCMPre = GraphicsUtil.coerceColorModel(srcCM, true);

            src = new BufferedImage(srcCMPre, src.getRaster(),
                                    true, null);

            GraphicsUtil.copyData(origSrc, src);
        }


        if (dest == null) {
            dest = createCompatibleDestImage(src, null);
            finalDest = dest;
        } else if (!isCompatible(dest.getColorModel(),
                                 dest.getSampleModel())) {
            dest = createCompatibleDestImage(src, null);
        } else if (!dest.isAlphaPremultiplied()) {
            // Get a Premultipled CM.
            ColorModel    dstCM, dstCMPre;
            dstCM    = dest.getColorModel();
            dstCMPre = GraphicsUtil.coerceColorModel(dstCM, true);

            dest = new BufferedImage(dstCMPre, finalDest.getRaster(),
                                     true, null);
        }

        filter(src.getRaster(), dest.getRaster());

        // Check to see if we need to 'fix' our source (divide out alpha).
        if ((src.getRaster() == origSrc.getRaster()) &&
            (src.isAlphaPremultiplied() != origSrc.isAlphaPremultiplied())) {
            // Copy our source back the way it was...
            GraphicsUtil.copyData(src, origSrc);
        }

        // Check to see if we need to store our result...
        if ((dest.getRaster() != finalDest.getRaster()) ||
            (dest.isAlphaPremultiplied() != finalDest.isAlphaPremultiplied())){
            // Coerce our source back the way it was requested...
            GraphicsUtil.copyData(dest, finalDest);
        }

        return finalDest;
    }
      /*
       * This commented out implementation of filter does the
       * morphology operation on unpremultiplied alpha image data.
       * This tends to leave colors bright.
       */
      /*
    public BufferedImage filter(BufferedImage src, BufferedImage dest){
        if (src == null && dest == null)
            throw new NullPointerException("Source image should not be null");

        BufferedImage origSrc   = src;
        BufferedImage finalDest = dest;

        if (!isCompatible(src.getColorModel(), src.getSampleModel())) {
            src = new BufferedImage(src.getWidth(), src.getHeight(),
                                    BufferedImage.TYPE_INT_ARGB);
            GraphicsUtil.copyData(origSrc, src);
        }
        else if (src.isAlphaPremultiplied()) {
            ColorModel    srcCM, srcCMUnpre;
            srcCM = src.getColorModel();
            srcCMUnpre = GraphicsUtil.coerceColorModel(srcCM, false);
            src = new BufferedImage(srcCMUnpre, src.getRaster(),
                                    false, null);

            GraphicsUtil.copyData(origSrc, src);
        }


        if (dest == null) {
            dest = new BufferedImage(src.getWidth(), src.getHeight(),
                                          BufferedImage.TYPE_INT_ARGB);
            finalDest = dest;
        } else if (!isCompatible(dest.getColorModel(),
                                 dest.getSampleModel())) {
            dest = new BufferedImage(src.getWidth(), src.getHeight(),
                                     BufferedImage.TYPE_INT_ARGB);
        } else if (dest.isAlphaPremultiplied()) {
            ColorModel    dstCM, dstCMUnpre;
            dstCM      = dest.getColorModel();
            dstCMUnpre = GraphicsUtil.coerceColorModel(dstCM, false);
            dest = new BufferedImage(dstCMUnpre, finalDest.getRaster(),
                                     false, null);
        }

        // We now have two compatible images. We can safely filter the rasters
        filter(src.getRaster(), dest.getRaster());

        // Check to see if we need to 'fix' our source (divide out alpha).
        if ((src.getRaster() == origSrc.getRaster()) &&
            (src.isAlphaPremultiplied() != origSrc.isAlphaPremultiplied())) {
            GraphicsUtil.copyData(src, origSrc);
        }

        // Check to see if we need to store our result...
        if ((dest.getRaster() != finalDest.getRaster()) ||
            (dest.isAlphaPremultiplied() != finalDest.isAlphaPremultiplied())){
            // Coerce our source back the way it was...
            System.out.println("Dest: " + dest.isAlphaPremultiplied() +
                               " finalDest: " +
                               finalDest.isAlphaPremultiplied());

            GraphicsUtil.copyData(dest, finalDest);
        }
        return finalDest;
    }
      */
}




