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
import java.awt.image.ColorModel;
import java.awt.image.ConvolveOp;
import java.awt.image.DataBuffer;
import java.awt.image.DataBufferInt;
import java.awt.image.DirectColorModel;
import java.awt.image.Kernel;
import java.awt.image.Raster;
import java.awt.image.SampleModel;
import java.awt.image.SinglePixelPackedSampleModel;
import java.awt.image.WritableRaster;

import org.apache.flex.forks.batik.ext.awt.image.GraphicsUtil;

/**
 * This implementation of RenderableImage will render its input
 * GraphicsNode on demand for tiles.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: GaussianBlurRed8Bit.java 478276 2006-11-22 18:33:37Z dvholten $
 */
public class GaussianBlurRed8Bit extends AbstractRed {

    int xinset, yinset;
    double stdDevX, stdDevY;
    RenderingHints hints;
    ConvolveOp [] convOp = new ConvolveOp [2];
    int dX, dY;

    /**
     * Construct a blurred version of <tt>src</tt>, by blurring with a
     * gaussian kernel with standard Deviation of <tt>stdDev</tt> pixels.
     * @param src The source image to blur
     * @param stdDev The Standard Deviation of the Gaussian kernel.
     * @param rh     Rendering hints.
     */
    public GaussianBlurRed8Bit(CachableRed    src,
                               double         stdDev,
                               RenderingHints rh) {
        this(src, stdDev, stdDev, rh);
    }

    /**
     * Construct a blurred version of <tt>src</tt>, by blurring with a
     * gaussian kernel with standard Deviation of <tt>stdDev</tt> pixels.
     * @param src The source image to blur
     * @param stdDevX The Standard Deviation of the Gaussian kernel in X
     * @param stdDevY The Standard Deviation of the Gaussian kernel in Y
     * @param rh     Rendering hints.
     */
    public GaussianBlurRed8Bit(CachableRed src,
                               double stdDevX, double stdDevY,
                               RenderingHints rh) {
        super(); // Remember to call super.init()

        this.stdDevX = stdDevX;
        this.stdDevY = stdDevY;
        this.hints   = rh;

        xinset = surroundPixels(stdDevX, rh);
        yinset = surroundPixels(stdDevY, rh);

        Rectangle myBounds = src.getBounds();
        myBounds.x      += xinset;
        myBounds.y      += yinset;
        myBounds.width  -= 2*xinset;
        myBounds.height -= 2*yinset;
        if ((myBounds.width <= 0) ||
            (myBounds.height <= 0)) {
            myBounds.width=0;
            myBounds.height=0;
        }

        ColorModel cm  = fixColorModel(src);
        SampleModel sm = src.getSampleModel();
        int tw = sm.getWidth();
        int th = sm.getHeight();
        if (tw > myBounds.width)  tw = myBounds.width;
        if (th > myBounds.height) th = myBounds.height;
        sm = cm.createCompatibleSampleModel(tw, th);

        init(src, myBounds, cm, sm,
             src.getTileGridXOffset()+xinset,
             src.getTileGridYOffset()+yinset, null);

        boolean highQuality = ((hints != null) &&
                               RenderingHints.VALUE_RENDER_QUALITY.equals
                               (hints.get(RenderingHints.KEY_RENDERING)));

        // System.out.println("StdDev: " + stdDevX + "x" + stdDevY);
        if ((xinset != 0) && ((stdDevX < 2) || highQuality))
            convOp[0] = new ConvolveOp(makeQualityKernelX(xinset*2+1));
        else
            dX = (int)Math.floor(DSQRT2PI*stdDevX+0.5f);

        if ((yinset != 0) && ((stdDevY < 2) || highQuality))
            convOp[1] = new ConvolveOp(makeQualityKernelY(yinset*2+1));
        else
            dY = (int)Math.floor(DSQRT2PI*stdDevY+0.5f);
    }

    /**
     * Constant: sqrt(2*PI)
     */
    static final float SQRT2PI = (float)Math.sqrt(2*Math.PI);

    /**
     * Constant: 3*sqrt(2*PI)/4
     */
    static final float DSQRT2PI = SQRT2PI*3f/4f;

    /**
     * Constant: precision used in computation of the Kernel radius
     */
    static final float precision = 0.499f;

    /**
     * Calculate the number of surround pixels required for a given
     * standard Deviation.
     */
    public static int surroundPixels(double stdDev) {
        return surroundPixels(stdDev, null);
    }

    /**
     * Calculate the number of surround pixels required for a given
     * standard Deviation.  Also takes into account rendering quality
     * hint.
     */
    public static int surroundPixels(double stdDev, RenderingHints hints) {
        boolean highQuality = ((hints != null) &&
                               RenderingHints.VALUE_RENDER_QUALITY.equals
                               (hints.get(RenderingHints.KEY_RENDERING)));

        if ((stdDev < 2) || highQuality) {
            // Start with 1/2 the zero box enery.
            float areaSum = (float)(0.5/(stdDev*SQRT2PI));
            int i=0;
            while (areaSum < precision) {
                areaSum += (float)(Math.pow(Math.E, -i*i/(2*stdDev*stdDev)) /
                                   (stdDev*SQRT2PI));
                i++;
            }

            return i;
        }

        //compute d
        int diam = (int)Math.floor(DSQRT2PI*stdDev+0.5f);
        if (diam%2 == 0)
            return diam-1 + diam/2; // even case
        else
            return diam-2 + diam/2;   // Odd case
    }

    /*
     * Here we compute the data for the one-dimensional kernel of
     * length '2*(radius-1) + 1'
     *
     * @param radius stdDeviationX or stdDeviationY.
     * @see #makeQualityKernels */
    private float [] computeQualityKernelData(int len, double stdDev){
        final float[] kernelData = new float [len];

        int mid = len/2;
        float sum = 0; // Used to normalise the kernel
        for(int i=0; i<len; i++){
            kernelData[i] = (float)(Math.pow(Math.E, -(i-mid)*(i-mid)/
                                             (2*stdDev*stdDev)) /
                                    (SQRT2PI*stdDev));
            sum += kernelData[i];
        }

        // Normalise: make elements sum to 1
        for (int i=0; i<len; i++)
            kernelData[i] /= sum;

        return kernelData;
    }

    private Kernel makeQualityKernelX(int len) {
        return new Kernel(len, 1, computeQualityKernelData(len, stdDevX));
    }

    private Kernel makeQualityKernelY(int len) {
        return new Kernel(1, len, computeQualityKernelData(len, stdDevY));
    }

    public WritableRaster copyData(WritableRaster wr) {
        // Get my source.
        CachableRed src = (CachableRed)getSources().get(0);

        Rectangle r = wr.getBounds();
        r.x      -=   xinset;
        r.y      -=   yinset;
        r.width  += 2*xinset;
        r.height += 2*yinset;

        // System.out.println("Gaussian GenR: " + wr);
        // System.out.println("SrcReq: " + r);

        ColorModel srcCM = src.getColorModel();

        WritableRaster tmpR1=null, tmpR2=null;

        tmpR1 = srcCM.createCompatibleWritableRaster(r.width, r.height);
        {
            WritableRaster fill;
            fill = tmpR1.createWritableTranslatedChild(r.x, r.y);
            src.copyData(fill);
        }
        if (srcCM.hasAlpha() && !srcCM.isAlphaPremultiplied())
            GraphicsUtil.coerceData(tmpR1, srcCM, true);

        // For the blur box approx we can use dest as our intermediate
        // otherwise we let it default to null which means we create a new
        // one...

        // this lets the Vertical conv know how much is junk, so it
        // doesn't bother to convolve the top and bottom edges
        int skipX;
        // long t1 = System.currentTimeMillis();
        if (xinset == 0) {
            skipX = 0;
        } else if (convOp[0] != null) {
            tmpR2 = getColorModel().createCompatibleWritableRaster
                (r.width, r.height);
            tmpR2 = convOp[0].filter(tmpR1, tmpR2);
            skipX = convOp[0].getKernel().getXOrigin();

            // Swap them...
            WritableRaster tmp = tmpR1;
            tmpR1 = tmpR2;
            tmpR2 = tmp;
        } else {
            if ((dX&0x01) == 0){
                tmpR1 = boxFilterH(tmpR1, tmpR1, 0,    0,   dX,   dX/2);
                tmpR1 = boxFilterH(tmpR1, tmpR1, dX/2, 0,   dX,   dX/2-1);
                tmpR1 = boxFilterH(tmpR1, tmpR1, dX-1, 0,   dX+1, dX/2);
                skipX = dX-1 + dX/2;
            } else {
                tmpR1 = boxFilterH(tmpR1, tmpR1, 0,    0,   dX, dX/2);
                tmpR1 = boxFilterH(tmpR1, tmpR1, dX/2, 0,   dX, dX/2);
                tmpR1 = boxFilterH(tmpR1, tmpR1, dX-2, 0,   dX, dX/2);
                skipX = dX-2 + dX/2;
            }
        }

        if (yinset == 0) {
            tmpR2 = tmpR1;
        } else if (convOp[1] != null) {
            if (tmpR2 == null) {
                tmpR2 = getColorModel().createCompatibleWritableRaster
                    (r.width, r.height);
            }
            tmpR2 = convOp[1].filter(tmpR1, tmpR2);
        } else {
            if ((dY&0x01) == 0){
                tmpR1 = boxFilterV(tmpR1, tmpR1, skipX, 0,    dY,   dY/2);
                tmpR1 = boxFilterV(tmpR1, tmpR1, skipX, dY/2, dY,   dY/2-1);
                tmpR1 = boxFilterV(tmpR1, tmpR1, skipX, dY-1, dY+1, dY/2);
            }
            else {
                tmpR1 = boxFilterV(tmpR1, tmpR1, skipX, 0,    dY, dY/2);
                tmpR1 = boxFilterV(tmpR1, tmpR1, skipX, dY/2, dY, dY/2);
                tmpR1 = boxFilterV(tmpR1, tmpR1, skipX, dY-2, dY, dY/2);
            }
            tmpR2 = tmpR1;
        }
        // long t2 = System.currentTimeMillis();
        // System.out.println("Time: " + (t2-t1) +
        //                       (((convOp[0] != null) || (convOp[1] != null))?
        //                        " ConvOp":""));
        // System.out.println("Rasters  WR :" + wr.getBounds());
        // System.out.println("         tmp:" + tmpR2.getBounds());
        // System.out.println("      bounds:" + getBounds());
        // System.out.println("       skipX:" + skipX +
        //                    " dx:" + dX + " Dy: " + dY);
        tmpR2 = tmpR2.createWritableTranslatedChild(r.x, r.y);
        GraphicsUtil.copyData(tmpR2, wr);

        return wr;
    }

    private WritableRaster boxFilterH(Raster src, WritableRaster dest,
                                      int skipX, int skipY,
                                      int boxSz, int loc) {

        final int w = src.getWidth();
        final int h = src.getHeight();

          // Check if the raster is wide enough to do _any_ work
        if (w < (2*skipX)+boxSz) return dest;
        if (h < (2*skipY))       return dest;

        final SinglePixelPackedSampleModel srcSPPSM =
            (SinglePixelPackedSampleModel)src.getSampleModel();

        final SinglePixelPackedSampleModel dstSPPSM =
            (SinglePixelPackedSampleModel)dest.getSampleModel();

        // Stride is the distance between two consecutive column elements,
        // in the one-dimention dataBuffer
        final int srcScanStride = srcSPPSM.getScanlineStride();
        final int dstScanStride = dstSPPSM.getScanlineStride();

        // Access the integer buffer for each image.
        DataBufferInt srcDB = (DataBufferInt)src.getDataBuffer();
        DataBufferInt dstDB = (DataBufferInt)dest.getDataBuffer();

        // Offset defines where in the stack the real data begin
        final int srcOff
            = (srcDB.getOffset() +
               srcSPPSM.getOffset
               (src.getMinX()-src.getSampleModelTranslateX(),
                src.getMinY()-src.getSampleModelTranslateY()));
        final int dstOff
            = (dstDB.getOffset() +
               dstSPPSM.getOffset
               (dest.getMinX()-dest.getSampleModelTranslateX(),
                dest.getMinY()-dest.getSampleModelTranslateY()));

        // Access the pixel value array
        final int[] srcPixels  = srcDB.getBankData()[0];
        final int[] destPixels = dstDB.getBankData()[0];

        final int [] buffer = new int [boxSz];
        int curr, prev;

          // Fixed point normalization factor (8.24)
        int scale = (1<<24)/boxSz;

        /*
         * System.out.println("Info: srcOff: " + srcOff +
         *                    " x: " + skipX +
         *                    " y: " + skipY +
         *                    " w: " + w +
         *                    " h: " + h +
         *                    " boxSz " + boxSz +
         *                    " srcStride: " + srcScanStride);
         */

        for (int y=skipY; y<(h-skipY); y++) {
            int sp     = srcOff + y*srcScanStride;
            int dp     = dstOff + y*dstScanStride;
            int rowEnd = sp + (w-skipX);

            int k    = 0;
            int sumA = 0;
            int sumR = 0;
            int sumG = 0;
            int sumB = 0;

            sp += skipX;
            int end  = sp+boxSz;

            while (sp < end) {
                curr = buffer[k] = srcPixels[sp];
                sumA += (curr>>> 24);
                sumR += (curr >> 16)&0xFF;
                sumG += (curr >>  8)&0xFF;
                sumB += (curr      )&0xFF;
                k++;
                sp++;
            }

            dp += skipX + loc;
            prev = destPixels[dp] = (( (sumA*scale)&0xFF000000)       |
                                     (((sumR*scale)&0xFF000000)>>>8)  |
                                     (((sumG*scale)&0xFF000000)>>>16) |
                                     (((sumB*scale)&0xFF000000)>>>24));
            dp++;
            k=0;
            while (sp < rowEnd) {
                curr = buffer[k];
                if (curr == srcPixels[sp]) {
                    destPixels[dp] = prev;
                } else {
                    sumA -= (curr>>> 24);
                    sumR -= (curr >> 16)&0xFF;
                    sumG -= (curr >>  8)&0xFF;
                    sumB -= (curr      )&0xFF;

                    curr = buffer[k] = srcPixels[sp];

                    sumA += (curr>>> 24);
                    sumR += (curr >> 16)&0xFF;
                    sumG += (curr >>  8)&0xFF;
                    sumB += (curr      )&0xFF;
                    prev = destPixels[dp] = (( (sumA*scale)&0xFF000000)       |
                                             (((sumR*scale)&0xFF000000)>>>8)  |
                                             (((sumG*scale)&0xFF000000)>>>16) |
                                             (((sumB*scale)&0xFF000000)>>>24));
                }
                k = (k+1)%boxSz;
                sp++;
                dp++;
            }
        }
        return dest;
    }

    private WritableRaster boxFilterV(Raster src, WritableRaster dest,
                                      int skipX, int skipY,
                                      int boxSz, int loc) {

        final int w = src.getWidth();
        final int h = src.getHeight();

          // Check if the raster is wide enough to do _any_ work
        if (w < (2*skipX))       return dest;
        if (h < (2*skipY)+boxSz) return dest;

        final SinglePixelPackedSampleModel srcSPPSM =
            (SinglePixelPackedSampleModel)src.getSampleModel();

        final SinglePixelPackedSampleModel dstSPPSM =
            (SinglePixelPackedSampleModel)dest.getSampleModel();

        // Stride is the distance between two consecutive column elements,
        // in the one-dimention dataBuffer
        final int srcScanStride = srcSPPSM.getScanlineStride();
        final int dstScanStride = dstSPPSM.getScanlineStride();

        // Access the integer buffer for each image.
        DataBufferInt srcDB = (DataBufferInt)src.getDataBuffer();
        DataBufferInt dstDB = (DataBufferInt)dest.getDataBuffer();

        // Offset defines where in the stack the real data begin
        final int srcOff
            = (srcDB.getOffset() +
               srcSPPSM.getOffset
               (src.getMinX()-src.getSampleModelTranslateX(),
                src.getMinY()-src.getSampleModelTranslateY()));
        final int dstOff
            = (dstDB.getOffset() +
               dstSPPSM.getOffset
               (dest.getMinX()-dest.getSampleModelTranslateX(),
                dest.getMinY()-dest.getSampleModelTranslateY()));


        // Access the pixel value array
        final int[] srcPixels  = srcDB.getBankData()[0];
        final int[] destPixels = dstDB.getBankData()[0];

        final int [] buffer = new int [boxSz];
        int curr, prev;

          // Fixed point normalization factor (8.24)
        final int scale = (1<<24)/boxSz;

        /*
         * System.out.println("Info: srcOff: " + srcOff +
         *                    " x: " + skipX +
         *                    " y: " + skipY +
         *                    " w: " + w +
         *                    " h: " + h +
         *                    " boxSz " + boxSz +
         *                    " srcStride: " + srcScanStride);
         */

        for (int x=skipX; x<(w-skipX); x++) {
            int sp = srcOff + x;
            int dp = dstOff + x;
            int colEnd = sp + (h-skipY)*srcScanStride;

            int k=0;
            int sumA = 0;
            int sumR = 0;
            int sumG = 0;
            int sumB = 0;

            sp += skipY*srcScanStride;
            int end  = sp+(boxSz*srcScanStride);

            while (sp < end) {
                curr = buffer[k] = srcPixels[sp];
                sumA += (curr>>> 24);
                sumR += (curr >> 16)&0xFF;
                sumG += (curr >>  8)&0xFF;
                sumB += (curr      )&0xFF;
                k++;
                sp+=srcScanStride;
            }


            dp += (skipY + loc)*dstScanStride;
            prev = destPixels[dp] = (( (sumA*scale)&0xFF000000)       |
                                     (((sumR*scale)&0xFF000000)>>>8)  |
                                     (((sumG*scale)&0xFF000000)>>>16) |
                                     (((sumB*scale)&0xFF000000)>>>24));
            dp+=dstScanStride;
            k=0;
            while (sp < colEnd) {
                curr = buffer[k];
                if (curr == srcPixels[sp]) {
                    destPixels[dp] = prev;
                } else {
                    sumA -= (curr>>> 24);
                    sumR -= (curr >> 16)&0xFF;
                    sumG -= (curr >>  8)&0xFF;
                    sumB -= (curr      )&0xFF;

                    curr = buffer[k] = srcPixels[sp];

                    sumA += (curr>>> 24);
                    sumR += (curr >> 16)&0xFF;
                    sumG += (curr >>  8)&0xFF;
                    sumB += (curr      )&0xFF;
                    prev = destPixels[dp] = (( (sumA*scale)&0xFF000000)       |
                                             (((sumR*scale)&0xFF000000)>>>8)  |
                                             (((sumG*scale)&0xFF000000)>>>16) |
                                             (((sumB*scale)&0xFF000000)>>>24));
                }
                k = (k+1)%boxSz;
                sp+=srcScanStride;
                dp+=dstScanStride;
            }
        }
        return dest;
    }

    protected static ColorModel fixColorModel(CachableRed src) {
        ColorModel  cm = src.getColorModel();

        int b = src.getSampleModel().getNumBands();
        int [] masks = new int[4];
        switch (b) {
        case 1:
            masks[0] = 0xFF;
            break;
        case 2:
            masks[0] = 0x00FF;
            masks[3] = 0xFF00;
            break;
        case 3:
            masks[0] = 0xFF0000;
            masks[1] = 0x00FF00;
            masks[2] = 0x0000FF;
            break;
        case 4:
            masks[0] = 0x00FF0000;
            masks[1] = 0x0000FF00;
            masks[2] = 0x000000FF;
            masks[3] = 0xFF000000;
            break;
        default:
            throw new IllegalArgumentException
                ("GaussianBlurRed8Bit only supports one to four band images");
        }
        ColorSpace cs = cm.getColorSpace();
        return new DirectColorModel(cs, 8*b, masks[0], masks[1],
                                    masks[2], masks[3],
                                    true, DataBuffer.TYPE_INT);
    }
}
