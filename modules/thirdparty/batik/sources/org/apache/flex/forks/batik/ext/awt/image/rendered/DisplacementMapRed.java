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
import java.awt.image.ColorModel;
import java.awt.image.DataBufferInt;
import java.awt.image.Raster;
import java.awt.image.SinglePixelPackedSampleModel;
import java.awt.image.WritableRaster;

import org.apache.flex.forks.batik.ext.awt.image.ARGBChannel;
import org.apache.flex.forks.batik.ext.awt.image.GraphicsUtil;
import org.apache.flex.forks.batik.ext.awt.image.PadMode;


/**
 * This implementation of RenderableImage will render its input
 * GraphicsNode on demand for tiles.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: DisplacementMapRed.java 478276 2006-11-22 18:33:37Z dvholten $
 */
public class DisplacementMapRed extends AbstractRed {
    // Use these to control timing and Nearest Neighbot vs. Bilinear Interp.
    private static final boolean TIME   = false;
    private static final boolean USE_NN = false;

    /**
     * The displacement scale factor along the x axis
     */
    private float scaleX;

    /**
     * The displacement scale factor along the y axis
     */
    private float scaleY;

    /**
     * The channel type of the operation on X axis
     */
    private ARGBChannel xChannel;

    /**
     * The channel type of the operation on Y axis
     */
    private ARGBChannel yChannel;

    /**
     * The image to distort.
     */
    CachableRed image;

    /**
     * The offset image (displacement map).
     */
    CachableRed offsets;

    /**
     * The maximum possible offsets in x and y
     */
    int maxOffX, maxOffY;

    /**
     * The set of rendering hints
     */
    RenderingHints hints;

    /**
     * Computed tile Offsets Soft referencces to TileOffsets instances...
     */
    TileOffsets [] xOffsets;
    TileOffsets [] yOffsets;

    static class TileOffsets {
        int [] tile;
        int [] off;
        TileOffsets(int len, int base, int stride,
                    int loc, int endLoc, int slop, int tile, int endTile) {
            this.tile = new int[len+1];
            this.off  = new int[len+1];

            if (tile == endTile) endLoc -= slop;

            for (int i=0; i<len; i++) {
                this.tile[i] = tile;
                this.off [i] = base+(loc*stride);
                loc++;
                if (loc == endLoc) {
                    loc = 0;
                    tile++;
                    if (tile == endTile) endLoc -=slop;
                }
            }
            this.tile[len] = this.tile[len-1];
            this.off [len] = this.off [len-1];
        }
    }

    /**
     * @param image the image to distort
     * @param offsets the displacement map
     * @param xChannel defines the channel of off whose values will be
     *                 on X-axis operation
     * @param yChannel defines the channel of off whose values will be
     * @param scaleX defines the scale factor of the filter operation
     *               on the X axis.
     * @param scaleY defines the scale factor of the filter operation
     *               on the Y axis
     * @param rh the rendering hints
     */
    public DisplacementMapRed(CachableRed image,
                              CachableRed offsets,
                              ARGBChannel xChannel,
                              ARGBChannel yChannel,
                              float scaleX, float scaleY,
                              RenderingHints rh) {

        if(xChannel == null){
            throw new IllegalArgumentException("Must provide xChannel");
        }

        if(yChannel == null){
            throw new IllegalArgumentException("Must provide yChannel");
        }

        this.offsets = offsets;
        this.scaleX = scaleX;
        this.scaleY = scaleY;
        this.xChannel = xChannel;
        this.yChannel = yChannel;
        this.hints   = rh;

        maxOffX = (int)Math.ceil(scaleX/2);
        maxOffY = (int)Math.ceil(scaleY/2);

        Rectangle rect = image.getBounds();

        Rectangle r    = image.getBounds();
        r.x -= maxOffX; r.width  += 2*maxOffX;
        r.y -= maxOffY; r.height += 2*maxOffY;
        image = new PadRed(image, r, PadMode.ZERO_PAD, null);
        image = new TileCacheRed(image);
        this.image = image;
        ColorModel cm = image.getColorModel();
        if (!USE_NN)
            // For Bilinear we need alpha premult.
            cm = GraphicsUtil.coerceColorModel(cm, true);

        init(image, rect, cm, image.getSampleModel(),
             rect.x, rect.y, null);

        xOffsets = new TileOffsets[getNumXTiles()];
        yOffsets = new TileOffsets[getNumYTiles()];
    }

    public WritableRaster copyData(WritableRaster wr) {
        copyToRaster(wr);
        return wr;
    }

    public Raster getTile(int tileX, int tileY) {
        WritableRaster dest = makeTile(tileX, tileY);
        Rectangle srcR   = dest.getBounds();

        // Get Raster from offsetes
        Raster     mapRas = offsets.getData(srcR);
        ColorModel mapCM  = offsets.getColorModel();
        // ensure map isn't pre-multiplied.
        GraphicsUtil.coerceData((WritableRaster)mapRas, mapCM, false);

        TileOffsets xinfo = getXOffsets(tileX);
        TileOffsets yinfo = getYOffsets(tileY);

        if (USE_NN)
            filterNN(mapRas, dest,
                     xinfo.tile, xinfo.off,
                     yinfo.tile, yinfo.off);
        else if (image.getColorModel().isAlphaPremultiplied())
            filterBL(mapRas, dest,
                     xinfo.tile, xinfo.off,
                     yinfo.tile, yinfo.off);
        else
            filterBLPre(mapRas, dest,
                        xinfo.tile, xinfo.off,
                        yinfo.tile, yinfo.off);

        return dest;
    }

    public TileOffsets getXOffsets(int xTile) {
        TileOffsets ret = xOffsets[xTile-getMinTileX()];
        if (ret != null)
            return ret;

        SinglePixelPackedSampleModel sppsm;
        sppsm = (SinglePixelPackedSampleModel)getSampleModel();
        int base  = sppsm.getOffset(0, 0);
        int tw    = sppsm.getWidth();

        // The span we need to cover in the input image.
        int width = tw+2*maxOffX;

        // The start and end X in image's tile coordinate system...
        int x0      = getTileGridXOffset() + xTile * tw - maxOffX
                          - image.getTileGridXOffset();
        int x1      = x0 + width-1;

        int tile    = (int)Math.floor(x0/(double)tw);
        int endTile = (int)Math.floor(x1/(double)tw);
        int loc     = x0-(tile*tw);
        int endLoc  = tw;

        // Amount not used from right edge tile
        int slop = ((endTile+1)*tw-1) - x1;

        ret = new TileOffsets(width, base, 1,
                              loc, endLoc, slop, tile, endTile);

        xOffsets[xTile-getMinTileX()] = ret;
        return ret;
    }

    public TileOffsets getYOffsets(int yTile) {
        TileOffsets ret = yOffsets[yTile-getMinTileY()];
        if (ret != null)
            return ret;

        SinglePixelPackedSampleModel sppsm;
        sppsm = (SinglePixelPackedSampleModel)getSampleModel();
        int stride  = sppsm.getScanlineStride();
        int th      = sppsm.getHeight();

        // The span we need to cover in the input image.
        int height  = th+2*maxOffY;

        // The start and end Y in image's tile coordinate system...
        int y0      = getTileGridYOffset() + yTile * th - maxOffY
                          - image.getTileGridYOffset();
        int y1      = y0 + height - 1;

        int tile    = (int)Math.floor(y0/(double)th);
        int endTile = (int)Math.floor(y1/(double)th);
        int loc     = y0-(tile*th);
        int endLoc  = th;

        // Amount not used from bottom edge tile
        int slop = ((endTile+1)*th-1) - y1;

        ret = new TileOffsets(height, 0, stride,
                              loc, endLoc, slop, tile, endTile);

        yOffsets[yTile-getMinTileY()] = ret;
        return ret;
    }

    public void filterBL(Raster off, WritableRaster dst,
                         int [] xTile, int [] xOff,
                         int [] yTile, int [] yOff) {
        final int w      = dst.getWidth();
        final int h      = dst.getHeight();
        final int xStart = maxOffX;
        final int yStart = maxOffY;
        final int xEnd   = xStart+w;
        final int yEnd   = yStart+h;

        // Access the integer buffer for each image.
        DataBufferInt dstDB = (DataBufferInt)dst.getDataBuffer();
        DataBufferInt offDB = (DataBufferInt)off.getDataBuffer();

        // Offset defines where in the stack the real data begin
        SinglePixelPackedSampleModel dstSPPSM, offSPPSM;

        dstSPPSM = (SinglePixelPackedSampleModel)dst.getSampleModel();
        final int dstOff = dstDB.getOffset() +
            dstSPPSM.getOffset(dst.getMinX() - dst.getSampleModelTranslateX(),
                               dst.getMinY() - dst.getSampleModelTranslateY());

        offSPPSM = (SinglePixelPackedSampleModel)off.getSampleModel();
        final int offOff = offDB.getOffset() +
            offSPPSM.getOffset(dst.getMinX() - off.getSampleModelTranslateX(),
                               dst.getMinY() - off.getSampleModelTranslateY());

        // Stride is the distance between two consecutive column elements,
        // in the one-dimention dataBuffer
        final int dstScanStride = dstSPPSM.getScanlineStride();
        final int offScanStride = offSPPSM.getScanlineStride();

        final int dstAdjust = dstScanStride - w;
        final int offAdjust = offScanStride - w;

        // Access the pixel value array
        final int[] dstPixels = dstDB.getBankData()[0];
        final int[] offPixels = offDB.getBankData()[0];

        // Below is the number of shifts for each axis
        // e.g when xChannel is ALPHA, the pixel needs
        // to be shifted 24, RED 16, GREEN 8 and BLUE 0
        final int xShift = xChannel.toInt()*8;
        final int yShift = yChannel.toInt()*8;

        // The pointer of img and dst indicating where the pixel values are
        int dp = dstOff, ip = offOff;

        // Fixed point representation of scale factor.
        final int fpScaleX = (int)((scaleX/255.0)*(1<<15)+0.5);
        final int fpAdjX   = (int)(-127.5*fpScaleX-0.5);
        final int fpScaleY = (int)((scaleY/255.0)*(1<<15)+0.5);
        final int fpAdjY   = (int)(-127.5*fpScaleY-0.5);

        long start = System.currentTimeMillis();

        int pel00, pel01, pel10, pel11, xFrac, yFrac, newPel;
        int sp0, sp1, pel0, pel1;

        int x, y, x0, y0, xDisplace, yDisplace, dPel;

        int xt=xTile[0]-1, yt=yTile[0]-1, xt1, yt1;
        int [] imgPix = null;

        for (y=yStart; y<yEnd; y++) {
            for (x=xStart; x<xEnd; x++, dp++, ip++) {
                dPel = offPixels[ip];

                xDisplace = (fpScaleX*((dPel>>xShift)&0xff))+fpAdjX;
                yDisplace = (fpScaleY*((dPel>>yShift)&0xff))+fpAdjY;

                x0 = x+(xDisplace>>15);
                y0 = y+(yDisplace>>15);

                if ((xt != xTile[x0]) ||
                    (yt != yTile[y0])) {
                    xt = xTile[x0]; yt = yTile[y0];
                    imgPix = ((DataBufferInt)image.getTile(xt, yt)
                              .getDataBuffer()).getBankData()[0];
                }
                pel00  = imgPix[xOff[x0]+yOff[y0]];

                xt1 = xTile[x0+1];
                yt1 = yTile[y0+1];
                if ((yt == yt1)) {
                    // Same tile vertically, check across...
                    if ((xt == xt1)) {
                        // All from same tile..
                        pel10  = imgPix[xOff[x0+1]+yOff[y0]];
                        pel01  = imgPix[xOff[x0]  +yOff[y0+1]];
                        pel11  = imgPix[xOff[x0+1]+yOff[y0+1]];
                    } else {
                        // Different tile horizontally...
                        pel01  = imgPix[xOff[x0]+yOff[y0+1]];

                        imgPix = ((DataBufferInt)image.getTile(xt1, yt)
                                  .getDataBuffer()).getBankData()[0];
                        pel10  = imgPix[xOff[x0+1]+yOff[y0]];
                        pel11  = imgPix[xOff[x0+1]+yOff[y0+1]];
                        xt = xt1;
                    }
                } else {
                    // Steped into next tile down, check across...
                    if ((xt == xt1)) {
                        // Different tile horizontally.
                        pel10  = imgPix[xOff[x0+1]+yOff[y0]];

                        imgPix = ((DataBufferInt)image.getTile(xt, yt1)
                                  .getDataBuffer()).getBankData()[0];
                        pel01  = imgPix[xOff[x0]  +yOff[y0+1]];
                        pel11  = imgPix[xOff[x0+1]+yOff[y0+1]];
                        yt = yt1;
                    } else {
                        // Ugg we are at the 4way intersection of tiles...
                        imgPix = ((DataBufferInt)image.getTile(xt, yt1)
                                  .getDataBuffer()).getBankData()[0];
                        pel01  = imgPix[xOff[x0]+yOff[y0+1]];

                        imgPix = ((DataBufferInt)image.getTile(xt1, yt1)
                                  .getDataBuffer()).getBankData()[0];
                        pel11  = imgPix[xOff[x0+1]+yOff[y0+1]];

                        imgPix = ((DataBufferInt)image.getTile(xt1, yt)
                                  .getDataBuffer()).getBankData()[0];
                        pel10  = imgPix[xOff[x0+1]+yOff[y0]];
                        xt = xt1;
                    }
                }

                xFrac = xDisplace&0x7FFF;
                yFrac = yDisplace&0x7FFF;

                // Combine the alpha channels.
                sp0  = (pel00>>>16) & 0xFF00;
                sp1  = (pel10>>>16) & 0xFF00;
                pel0 = (sp0 + (((sp1-sp0)*xFrac+0x4000)>>15)) & 0xFFFF;
                sp0  = (pel01>>>16) & 0xFF00;
                sp1  = (pel11>>>16) & 0xFF00;
                pel1 = (sp0 + (((sp1-sp0)*xFrac+0x4000)>>15)) & 0xFFFF;
                newPel = (((pel0<<15) + (pel1-pel0)*yFrac + 0x00400000)
                          &0x7F800000)<<  1;

                // Combine the red channels.
                sp0  = (pel00>>  8) & 0xFF00;
                sp1  = (pel10>>  8) & 0xFF00;
                pel0 = (sp0 + (((sp1-sp0)*xFrac+0x4000)>>15)) & 0xFFFF;
                sp0  = (pel01>>  8) & 0xFF00;
                sp1  = (pel11>>  8) & 0xFF00;
                pel1 = (sp0 + (((sp1-sp0)*xFrac+0x4000)>>15)) & 0xFFFF;
                newPel |= (((pel0<<15) + (pel1-pel0)*yFrac + 0x00400000)
                           &0x7F800000)>>> 7;

                // Combine the green channels.
                sp0  = (pel00     ) & 0xFF00;
                sp1  = (pel10     ) & 0xFF00;
                pel0 = (sp0 + (((sp1-sp0)*xFrac+0x4000)>>15)) & 0xFFFF;
                sp0  = (pel01     ) & 0xFF00;
                sp1  = (pel11     ) & 0xFF00;
                pel1 = (sp0 + (((sp1-sp0)*xFrac+0x4000)>>15)) & 0xFFFF;
                newPel |= (((pel0<<15) + (pel1-pel0)*yFrac + 0x00400000)
                           &0x7F800000)>>>15;

                // Combine the blue channels.
                sp0  = (pel00<<  8) & 0xFF00;
                sp1  = (pel10<<  8) & 0xFF00;
                pel0 = (sp0 + (((sp1-sp0)*xFrac+0x4000)>>15)) & 0xFFFF;
                sp0  = (pel01<<  8) & 0xFF00;
                sp1  = (pel11<<  8) & 0xFF00;
                pel1 = (sp0 + (((sp1-sp0)*xFrac+0x4000)>>15)) & 0xFFFF;
                newPel |= (((pel0<<15) + (pel1-pel0)*yFrac + 0x00400000)
                           &0x7F800000)>>>23;

                dstPixels[dp] = newPel;
            }

            dp += dstAdjust;
            ip += offAdjust;
        }

        if (TIME) {
            long end = System.currentTimeMillis();
            System.out.println("Time: " + (end-start));
        }
    }// end of the filter() method for Raster

    public void filterBLPre(Raster off, WritableRaster dst,
                            int [] xTile, int [] xOff,
                            int [] yTile, int [] yOff) {
        final int w      = dst.getWidth();
        final int h      = dst.getHeight();
        final int xStart = maxOffX;
        final int yStart = maxOffY;
        final int xEnd   = xStart+w;
        final int yEnd   = yStart+h;

        // Access the integer buffer for each image.
        DataBufferInt dstDB = (DataBufferInt)dst.getDataBuffer();
        DataBufferInt offDB = (DataBufferInt)off.getDataBuffer();

        // Offset defines where in the stack the real data begin
        SinglePixelPackedSampleModel dstSPPSM, offSPPSM;

        dstSPPSM = (SinglePixelPackedSampleModel)dst.getSampleModel();
        final int dstOff = dstDB.getOffset() +
            dstSPPSM.getOffset(dst.getMinX() - dst.getSampleModelTranslateX(),
                               dst.getMinY() - dst.getSampleModelTranslateY());

        offSPPSM = (SinglePixelPackedSampleModel)off.getSampleModel();
        final int offOff = offDB.getOffset() +
            offSPPSM.getOffset(dst.getMinX() - off.getSampleModelTranslateX(),
                               dst.getMinY() - off.getSampleModelTranslateY());

        // Stride is the distance between two consecutive column elements,
        // in the one-dimention dataBuffer
        final int dstScanStride = dstSPPSM.getScanlineStride();
        final int offScanStride = offSPPSM.getScanlineStride();

        final int dstAdjust = dstScanStride - w;
        final int offAdjust = offScanStride - w;

        // Access the pixel value array
        final int[] dstPixels = dstDB.getBankData()[0];
        final int[] offPixels = offDB.getBankData()[0];

        // Below is the number of shifts for each axis
        // e.g when xChannel is ALPHA, the pixel needs
        // to be shifted 24, RED 16, GREEN 8 and BLUE 0
        final int xShift = xChannel.toInt()*8;
        final int yShift = yChannel.toInt()*8;

        // The pointer of img and dst indicating where the pixel values are
        int dp = dstOff, ip = offOff;

        // Fixed point representation of scale factor.
        // Fixed point representation of scale factor.
        final int fpScaleX = (int)((scaleX/255.0)*(1<<15)+0.5);
        final int fpAdjX   = (int)(-127.5*fpScaleX-0.5);
        final int fpScaleY = (int)((scaleY/255.0)*(1<<15)+0.5);
        final int fpAdjY   = (int)(-127.5*fpScaleY-0.5);

        long start = System.currentTimeMillis();

        int pel00, pel01, pel10, pel11, xFrac, yFrac, newPel;
        int sp0, sp1, pel0, pel1, a00, a01, a10, a11;

        int x, y, x0, y0, xDisplace, yDisplace, dPel;
        final int norm = (1<<24)/255;

        int xt=xTile[0]-1, yt=yTile[0]-1, xt1, yt1;
        int [] imgPix = null;

        for (y=yStart; y<yEnd; y++) {
            for (x=xStart; x<xEnd; x++, dp++, ip++) {
                dPel = offPixels[ip];

                xDisplace = (fpScaleX*((dPel>>xShift)&0xff))+fpAdjX;
                yDisplace = (fpScaleY*((dPel>>yShift)&0xff))+fpAdjY;

                x0 = x+(xDisplace>>15);
                y0 = y+(yDisplace>>15);

                if ((xt != xTile[x0]) || (yt != yTile[y0])) {
                    xt = xTile[x0];
                    yt = yTile[y0];
                    imgPix = ((DataBufferInt)image.getTile(xt, yt)
                              .getDataBuffer()).getBankData()[0];
                }
                pel00  = imgPix[xOff[x0]+yOff[y0]];

                xt1 = xTile[x0+1];
                yt1 = yTile[y0+1];
                if ((yt == yt1)) {
                    // Same tile vertically, check across...
                    if ((xt == xt1)) {
                        // All from same tile..
                        pel10  = imgPix[xOff[x0+1]+yOff[y0]];
                        pel01  = imgPix[xOff[x0]  +yOff[y0+1]];
                        pel11  = imgPix[xOff[x0+1]+yOff[y0+1]];
                    } else {
                        // Different tile horizontally...
                        pel01  = imgPix[xOff[x0]+yOff[y0+1]];

                        imgPix = ((DataBufferInt)image.getTile(xt1, yt)
                                  .getDataBuffer()).getBankData()[0];
                        pel10  = imgPix[xOff[x0+1]+yOff[y0]];
                        pel11  = imgPix[xOff[x0+1]+yOff[y0+1]];
                        xt = xt1;
                    }
                } else {
                    // Steped into next tile down, check across...
                    if ((xt == xt1)) {
                        // Different tile horizontally.
                        pel10  = imgPix[xOff[x0+1]+yOff[y0]];

                        imgPix = ((DataBufferInt)image.getTile(xt, yt1)
                                  .getDataBuffer()).getBankData()[0];
                        pel01  = imgPix[xOff[x0]  +yOff[y0+1]];
                        pel11  = imgPix[xOff[x0+1]+yOff[y0+1]];
                        yt = yt1;
                    } else {
                        // Ugg we are at the 4way intersection of tiles...
                        imgPix = ((DataBufferInt)image.getTile(xt, yt1)
                                  .getDataBuffer()).getBankData()[0];
                        pel01  = imgPix[xOff[x0]+yOff[y0+1]];

                        imgPix = ((DataBufferInt)image.getTile(xt1, yt1)
                                  .getDataBuffer()).getBankData()[0];
                        pel11  = imgPix[xOff[x0+1]+yOff[y0+1]];

                        imgPix = ((DataBufferInt)image.getTile(xt1, yt)
                                  .getDataBuffer()).getBankData()[0];
                        pel10  = imgPix[xOff[x0+1]+yOff[y0]];
                        xt = xt1;
                    }
                }

                xFrac = xDisplace&0x7FFF;
                yFrac = yDisplace&0x7FFF;

                // Combine the alpha channels.
                sp0  = (pel00>>>16) & 0xFF00;
                sp1  = (pel10>>>16) & 0xFF00;
                pel0 = (sp0 + (((sp1-sp0)*xFrac+0x4000)>>15)) & 0xFFFF;
                a00 = ((sp0>>8)*norm + 0x80)>>8;
                a10 = ((sp1>>8)*norm + 0x80)>>8;

                sp0  = (pel01>>>16) & 0xFF00;
                sp1  = (pel11>>>16) & 0xFF00;
                pel1 = (sp0 + (((sp1-sp0)*xFrac+0x4000)>>15)) & 0xFFFF;
                a01 = ((sp0>>8)*norm + 0x80)>>8;
                a11 = ((sp1>>8)*norm + 0x80)>>8;
                newPel = (((pel0<<15) + (pel1-pel0)*yFrac + 0x00400000)
                          &0x7F800000)<<  1;

                // Combine the red channels.
                sp0  = ((((pel00>> 16) & 0xFF)*a00) + 0x80)>>8;
                sp1  = ((((pel10>> 16) & 0xFF)*a10) + 0x80)>>8;
                pel0 = (sp0 + (((sp1-sp0)*xFrac+0x4000)>>15)) & 0xFFFF;
                sp0  = ((((pel01>> 16) & 0xFF)*a01) + 0x80)>>8;
                sp1  = ((((pel11>> 16) & 0xFF)*a11) + 0x80)>>8;
                pel1 = (sp0 + (((sp1-sp0)*xFrac+0x4000)>>15)) & 0xFFFF;
                newPel |= (((pel0<<15) + (pel1-pel0)*yFrac + 0x00400000)
                           &0x7F800000)>>> 7;

                // Combine the green channels.
                sp0  = ((((pel00>> 8) & 0xFF)*a00) + 0x80)>>8;
                sp1  = ((((pel10>> 8) & 0xFF)*a10) + 0x80)>>8;
                pel0 = (sp0 + (((sp1-sp0)*xFrac+0x4000)>>15)) & 0xFFFF;
                sp0  = ((((pel01>> 8) & 0xFF)*a01) + 0x80)>>8;
                sp1  = ((((pel11>> 8) & 0xFF)*a11) + 0x80)>>8;
                pel1 = (sp0 + (((sp1-sp0)*xFrac+0x4000)>>15)) & 0xFFFF;
                newPel |= (((pel0<<15) + (pel1-pel0)*yFrac + 0x00400000)
                           &0x7F800000)>>>15;

                // Combine the blue channels.
                sp0  = (((pel00 & 0xFF)*a00) + 0x80)>>8;
                sp1  = (((pel10 & 0xFF)*a10) + 0x80)>>8;
                pel0 = (sp0 + (((sp1-sp0)*xFrac+0x4000)>>15)) & 0xFFFF;
                sp0  = (((pel01 & 0xFF)*a01) + 0x80)>>8;
                sp1  = (((pel11 & 0xFF)*a11) + 0x80)>>8;
                pel1 = (sp0 + (((sp1-sp0)*xFrac+0x4000)>>15)) & 0xFFFF;
                newPel |= (((pel0<<15) + (pel1-pel0)*yFrac + 0x00400000)
                           &0x7F800000)>>>23;

                dstPixels[dp] = newPel;
            }

            dp += dstAdjust;
            ip += offAdjust;
        }

        if (TIME) {
            long end = System.currentTimeMillis();
            System.out.println("Time: " + (end-start));
        }
    }// end of the filter() method for Raster

    /**
     * Does displacement map using Nearest neighbor interpolation
     *
     * @param off the displacement map
     * @param dst stores the filtered image. If null, a destination will
     *        be created. img and dst can refer to the same Raster, in
     *        which situation the img will be modified.
     */
    public void filterNN(Raster off, WritableRaster dst,
                         int [] xTile, int [] xOff,
                         int [] yTile, int [] yOff) {
        final int w      = dst.getWidth();
        final int h      = dst.getHeight();
        final int xStart = maxOffX;
        final int yStart = maxOffY;
        final int xEnd   = xStart+w;
        final int yEnd   = yStart+h;

        // Access the integer buffer for each image.
        DataBufferInt dstDB = (DataBufferInt)dst.getDataBuffer();
        DataBufferInt offDB = (DataBufferInt)off.getDataBuffer();

        // Offset defines where in the stack the real data begin
        SinglePixelPackedSampleModel dstSPPSM, offSPPSM;

        dstSPPSM = (SinglePixelPackedSampleModel)dst.getSampleModel();
        final int dstOff = dstDB.getOffset() +
            dstSPPSM.getOffset(dst.getMinX() - dst.getSampleModelTranslateX(),
                               dst.getMinY() - dst.getSampleModelTranslateY());

        offSPPSM = (SinglePixelPackedSampleModel)off.getSampleModel();
        final int offOff = offDB.getOffset() +
            offSPPSM.getOffset(off.getMinX() - off.getSampleModelTranslateX(),
                               off.getMinY() - off.getSampleModelTranslateY());

        // Stride is the distance between two consecutive column elements,
        // in the one-dimention dataBuffer
        final int dstScanStride = dstSPPSM.getScanlineStride();
        final int offScanStride = offSPPSM.getScanlineStride();

        final int dstAdjust = dstScanStride - w;
        final int offAdjust = offScanStride - w;

        // Access the pixel value array
        final int[] dstPixels = dstDB.getBankData()[0];
        final int[] offPixels = offDB.getBankData()[0];

        // Below is the number of shifts for each axis
        // e.g when xChannel is ALPHA, the pixel needs
        // to be shifted 24, RED 16, GREEN 8 and BLUE 0
        final int xShift = xChannel.toInt()*8;
        final int yShift = yChannel.toInt()*8;

        final int fpScaleX = (int)((scaleX/255.0)*(1<<15)+0.5);
        final int fpScaleY = (int)((scaleY/255.0)*(1<<15)+0.5);

        // Calculate the shift to make '.5' no movement.
        // This also includes rounding factor (0x4000) for Fixed Point stuff.
        final int fpAdjX   = (int)(-127.5*fpScaleX-0.5) + 0x4000;
        final int fpAdjY   = (int)(-127.5*fpScaleY-0.5) + 0x4000;

        // The pointer of img and dst indicating where the pixel values are
        int dp = dstOff, ip = offOff;

        long start = System.currentTimeMillis();
        int y=yStart, xt=xTile[0]-1, yt=yTile[0]-1;
        int [] imgPix = null;

        int x0, y0, xDisplace, yDisplace, dPel;
        while (y<yEnd) {
            int x=xStart;
            while (x<xEnd) {
                dPel = offPixels[ip];

                xDisplace = (fpScaleX*((dPel>>xShift)&0xff))+fpAdjX;
                yDisplace = (fpScaleY*((dPel>>yShift)&0xff))+fpAdjY;

                x0 = x+(xDisplace>>15);
                y0 = y+(yDisplace>>15);

                if ((xt != xTile[x0]) ||
                    (yt != yTile[y0])) {
                    xt = xTile[x0]; yt = yTile[y0];
                    imgPix = ((DataBufferInt)image.getTile(xt, yt)
                              .getDataBuffer()).getBankData()[0];
                }
                dstPixels[dp] = imgPix[xOff[x0]+yOff[y0]];

                dp++;
                ip++;
                x++;
            }

            dp += dstAdjust;
            ip += offAdjust;
            y++;
        }
        if (TIME) {
            long end = System.currentTimeMillis();
            System.out.println("Time: " + (end-start));
        }
    }// end of the filter() method for Raster
}


