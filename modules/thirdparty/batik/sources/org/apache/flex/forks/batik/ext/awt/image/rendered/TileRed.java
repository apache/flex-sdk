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

import java.awt.AlphaComposite;
import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.RenderingHints;
import java.awt.geom.AffineTransform;
import java.awt.image.BufferedImage;
import java.awt.image.ColorModel;
import java.awt.image.DataBufferInt;
import java.awt.image.Raster;
import java.awt.image.RenderedImage;
import java.awt.image.SampleModel;
import java.awt.image.SinglePixelPackedSampleModel;
import java.awt.image.WritableRaster;

import org.apache.flex.forks.batik.ext.awt.image.GraphicsUtil;
import org.apache.flex.forks.batik.util.HaltingThread;

/**
 * This filter simply tiles its tile starting from the upper
 * left corner of the tiled region.
 * 
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: TileRed.java 509851 2007-02-21 01:12:30Z deweese $
 */
public class TileRed extends AbstractRed implements TileGenerator {
    static final AffineTransform IDENTITY = new AffineTransform();

    /**
     * Area tiled by this filter. 
     */
    Rectangle tiledRegion;

    int xStep;
    int yStep;

    TileStore tiles;

    private RenderingHints  hints;

    final boolean is_INT_PACK;

    /**
     * Tile
     */
    RenderedImage  tile   = null;
    WritableRaster raster = null;


    public TileRed(RenderedImage tile,
                   Rectangle tiledRegion) {
        this(tile, tiledRegion, tile.getWidth(), tile.getHeight(), null);
    }

    public TileRed(RenderedImage tile,
                   Rectangle tiledRegion,
                   RenderingHints hints) {
        this(tile, tiledRegion, tile.getWidth(), tile.getHeight(), hints);
    }

    public TileRed(RenderedImage tile, 
                   Rectangle tiledRegion,
                   int xStep, int yStep) {
        this(tile, tiledRegion, xStep, yStep, null);
    }

    public TileRed(RenderedImage tile, 
                   Rectangle tiledRegion,
                   int xStep, int yStep,
                   RenderingHints hints) {
        if(tiledRegion == null){
            throw new IllegalArgumentException();
        }

        if(tile == null){
            throw new IllegalArgumentException();
        }

        // org.apache.flex.forks.batik.test.gvt.ImageDisplay.showImage("Tile: ", tile);
        this.tiledRegion  = tiledRegion;
        this.xStep        = xStep;
        this.yStep        = yStep;
        this.hints        = hints;

        SampleModel sm = fixSampleModel(tile, xStep, yStep, 
                                        tiledRegion.width,
                                        tiledRegion.height);
        ColorModel cm  = tile.getColorModel();

        double smSz   = AbstractTiledRed.getDefaultTileSize();
        smSz = smSz*smSz;

        double stepSz = (xStep*(double)yStep);
        // be prepaired to grow the default tile size quite a bit if
        // it means the image tile will fit in it...
        if (16.1*smSz > stepSz) {
            int xSz = xStep;
            int ySz = yStep;

            // If the pattern size is small then have multiple copies
            // in our tile.
            if (4*stepSz <= smSz) {
                int mult = (int)Math.ceil(Math.sqrt(smSz/stepSz));
                xSz *= mult;
                ySz *= mult;
            }
            // System.out.println("Using Raster for pattern");
            sm = sm.createCompatibleSampleModel(xSz, ySz);
            raster = Raster.createWritableRaster
                (sm, new Point(tile.getMinX(), tile.getMinY()));
        }
        
        is_INT_PACK = GraphicsUtil.is_INT_PACK_Data(sm, false);
        // System.out.println("Is INT PACK: " + is_INT_PACK);

        // Initialize our base class We set our bounds be we will
        // respond with data for any area we cover.  This is needed
        // because the userRegion passed into PatterPaintContext
        // doesn't account for stroke So we use that as a basis but
        // when the context asks us for stuff outside that region we
        // complie.
        init((CachableRed)null, tiledRegion, cm, sm, 
             tile.getMinX(), tile.getMinY(), null);

        if (raster != null) {
            WritableRaster fromRaster = raster.createWritableChild
                (tile.getMinX(), tile.getMinY(), 
                 xStep, yStep, tile.getMinX(), tile.getMinY(), null);

            // Fill one 'tile' of the input....
            fillRasterFrom(fromRaster, tile);
            fillOutRaster(raster);
        }
        else {
            this.tile        = new TileCacheRed(GraphicsUtil.wrap(tile));
        }
    }

    public WritableRaster copyData(WritableRaster wr) {
        int xOff = ((int)Math.floor(wr.getMinX()/xStep))*xStep;
        int yOff = ((int)Math.floor(wr.getMinY()/yStep))*yStep;
        int x0   = wr.getMinX()-xOff;
        int y0   = wr.getMinY()-yOff;
        int tx0 = getXTile(x0);
        int ty0 = getYTile(y0);
        int tx1 = getXTile(x0+wr.getWidth() -1);
        int ty1 = getYTile(y0+wr.getHeight()-1);

        for (int y=ty0; y<=ty1; y++)
            for (int x=tx0; x<=tx1; x++) {
                Raster r = getTile(x, y);
                r = r.createChild(r.getMinX(),      r.getMinY(), 
                                  r.getWidth(),     r.getHeight(),
                                  r.getMinX()+xOff, r.getMinY()+yOff, null);
                if (is_INT_PACK)
                    GraphicsUtil.copyData_INT_PACK(r, wr);
                else
                    GraphicsUtil.copyData_FALLBACK(r, wr);
            }
        return wr;
    }


    public Raster getTile(int x, int y) {
        
        if (raster!=null) {
            // We have a Single raster that we translate where needed
            // position.  So just offest appropriately.
            int tx = tileGridXOff+x*tileWidth;
            int ty = tileGridYOff+y*tileHeight;
            return raster.createTranslatedChild(tx, ty);
        }

        // System.out.println("Checking Cache [" + x + "," + y + "]");
        return genTile(x,y);
    }

    public Raster genTile(int x, int y) {
      // System.out.println("Cache Miss     [" + x + "," + y + "]");
        int tx = tileGridXOff+x*tileWidth;
        int ty = tileGridYOff+y*tileHeight;
        
        if (raster!=null) {
            // We have a Single raster that we translate where needed
            // position.  So just offest appropriately.
            return raster.createTranslatedChild(tx, ty);
        }

        Point pt = new Point(tx, ty);
        WritableRaster wr = Raster.createWritableRaster(sm, pt);
        fillRasterFrom(wr, tile);
        return wr;
    }

    public WritableRaster fillRasterFrom(WritableRaster wr, RenderedImage src){
        // System.out.println("Getting Raster : " + count + " " + wr.getMinX() + "/" + wr.getMinY() + "/" + wr.getWidth() + "/" + wr.getHeight());
        // System.out.println("Tile           : " + tile.getMinX() + "/" + tile.getMinY() + "/" + tile.getWidth() + "/" + tile.getHeight());

        ColorModel cm = getColorModel();
        BufferedImage bi
            = new BufferedImage(cm,
                                wr.createWritableTranslatedChild(0, 0),
                                cm.isAlphaPremultiplied(), null);

        Graphics2D g = GraphicsUtil.createGraphics(bi, hints);

        int minX = wr.getMinX();
        int minY = wr.getMinY();
        int maxX = wr.getWidth();
        int maxY = wr.getHeight();


        g.setComposite(AlphaComposite.Clear);
        g.setColor(new Color(0, 0, 0, 0));
        g.fillRect(0, 0, maxX, maxY);
        g.setComposite(AlphaComposite.SrcOver);

        g.translate(-minX, -minY);

        // Process initial translate so that tile is
        // painted to the left of the raster top-left 
        // corner on the first drawRenderedImage
        int x1 = src.getMinX()+src.getWidth()-1;
        int y1 = src.getMinY()+src.getHeight()-1;

        int tileTx = (int)Math.ceil(((minX-x1)/xStep))*xStep;
        int tileTy = (int)Math.ceil(((minY-y1)/yStep))*yStep;

        g.translate(tileTx, tileTy);

        int curX = tileTx - wr.getMinX() + src.getMinX();
        int curY = tileTy - wr.getMinY() + src.getMinY();

        // System.out.println("Wr: " + wr.getBounds());
        // System.out.println("Src : [" + src.getMinX() + ", " + 
        //                    src.getMinY()  + ", " + 
        //                    src.getWidth() + ", " +
        //                    src.getHeight() + "]");
        // System.out.println("tileTx/tileTy : " + tileTx + " / " + tileTy);
        minX = curX;
        while(curY < maxY) {
            if (HaltingThread.hasBeenHalted())
                return wr;

            while (curX < maxX) {
                // System.out.println("curX/curY : " + curX + " / " + curY);
                // System.out.println("transform : " + 
                //                    g.getTransform().getTranslateX() + 
                //                    " / " + 
                //                    g.getTransform().getTranslateY());
                GraphicsUtil.drawImage(g, src);
                curX += xStep;
                g.translate(xStep, 0);
            }
            curY += yStep;
            g.translate(minX-curX, yStep);
            curX = minX;
        }
        
        /*g.setTransform(new AffineTransform());
        g.setPaint(colors[count++]);
        count %= colors.length;

        g.fillRect(0, 0, maxX, maxY);*/

        // Don't coerceData since it will be in the proper alpha state
        // due to the drawing.
        // GraphicsUtil.coerceData(wr, src.getColorModel(), alphaPremult);
        return wr;
    }

    protected void fillOutRaster(WritableRaster wr) {
        if (is_INT_PACK)
            fillOutRaster_INT_PACK(wr);
        else
            fillOutRaster_FALLBACK(wr);
        
    }

    protected void fillOutRaster_INT_PACK(WritableRaster wr) {
        // System.out.println("Fast copyData");
        int x0 = wr.getMinX();
        int y0 = wr.getMinY();
        int width  = wr.getWidth();
        int height = wr.getHeight();

        SinglePixelPackedSampleModel sppsm;
        sppsm = (SinglePixelPackedSampleModel)wr.getSampleModel();

        final int     scanStride = sppsm.getScanlineStride();
        DataBufferInt db         = (DataBufferInt)wr.getDataBuffer();
        final int []  pixels     = db.getBankData()[0];
        final int     base =
            (db.getOffset() +
             sppsm.getOffset(x0-wr.getSampleModelTranslateX(),
                             y0-wr.getSampleModelTranslateY()));
        int step = xStep;
        for (int x=xStep; x<width; x+=step, step*=2) {
            int w = step;
            if (x+w > width) w = width-x;
            if (w >= 128) {
                int srcSP = base;
                int dstSP = base+x;
                for(int y=0; y<yStep; y++) {
                    System.arraycopy(pixels, srcSP, pixels, dstSP, w);
                    srcSP += scanStride;
                    dstSP += scanStride;
                }
            } else {
                int srcSP = base;
                int dstSP = base+x;
                for(int y=0; y<yStep; y++) {
                    int end = srcSP;
                    srcSP += w-1;
                    dstSP += w-1;
                    while(srcSP>=end)
                        pixels[dstSP--] = pixels[srcSP--];
                    srcSP+=scanStride+1;
                    dstSP+=scanStride+1;
                }
            }
        }

        step = yStep;
        for (int y=yStep; y<height; y+=step, step*=2) {
            int h = step;
            if (y+h > height) h = height-y;
            int dstSP = base+y*scanStride;
            System.arraycopy(pixels, base, pixels, dstSP, h*scanStride);
        }
    }

    protected void fillOutRaster_FALLBACK(WritableRaster wr) {
        // System.out.println("Fast copyData");
        int width  = wr.getWidth();
        int height = wr.getHeight();

        Object data = null;

        int step = xStep;
        for (int x=xStep; x<width; x+=step, step*=4) {
            int w = step;
            if (x+w > width) w = width-x;
            data = wr.getDataElements(0, 0, w, yStep, data);
            wr.setDataElements(x, 0, w, yStep, data);
            x+=w;

            if (x >= width) break;
            if (x+w > width) w = width-x;
            wr.setDataElements(x, 0, w, yStep, data);
            x+=w;

            if (x >= width) break;
            if (x+w > width) w = width-x;
            wr.setDataElements(x, 0, w, yStep, data);
        }

        step = yStep;
        for (int y=yStep; y<height; y+=step, step*=4) {
            int h = step;
            if (y+h > height) h = height-y;
            data = wr.getDataElements(0, 0, width, h, data);
            wr.setDataElements(0, y, width, h, data);
            y+=h;

            if (h >= height) break;
            if (y+h > height) h = height-y;
            wr.setDataElements(0, y, width, h, data);
            y+=h;

            if (h >= height) break;
            if (y+h > height) h = height-y;
            wr.setDataElements(0, y, width, h, data);
            y+=h;
        }
    }

    /**
     * This function 'fixes' the source's sample model.
     * right now it just ensures that the sample model isn't
     * much larger than my width.
     */
    protected static SampleModel fixSampleModel(RenderedImage src,
                                                int stepX, int stepY,
                                                int width, int height) {
        int defSz = AbstractTiledRed.getDefaultTileSize();
        SampleModel sm = src.getSampleModel();
        int w = sm.getWidth();
        if (w < defSz) w = defSz;
        if (w > stepX)  w = stepX;
        // if (w > width)  w = width;
        int h = sm.getHeight();
        if (h < defSz) h = defSz;
        if (h > stepY) h = stepY;
        // if (h > height) h = height;
        return sm.createCompatibleSampleModel(w, h);
    }
}
