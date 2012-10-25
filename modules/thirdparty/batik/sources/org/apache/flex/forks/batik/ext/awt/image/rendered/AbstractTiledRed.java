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
import java.awt.image.ColorModel;
import java.awt.image.DataBufferInt;
import java.awt.image.Raster;
import java.awt.image.SampleModel;
import java.awt.image.WritableRaster;
import java.util.List;
import java.util.Map;

import org.apache.flex.forks.batik.ext.awt.image.GraphicsUtil;
import org.apache.flex.forks.batik.util.HaltingThread;

/**
 * This is an abstract base class that takes care of most of the
 * normal issues surrounding the implementation of the CachableRed
 * (RenderedImage) interface.  It tries to make no assumptions about
 * the subclass implementation.
 *
 * @author <a href="mailto:Thomas.DeWeeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: AbstractTiledRed.java 489226 2006-12-21 00:05:36Z cam $
 */
public abstract class AbstractTiledRed
    extends    AbstractRed
    implements TileGenerator {

    private TileStore tiles;

    private static int defaultTileSize = 128;
    public static int getDefaultTileSize() { return defaultTileSize; }

    /**
     * void constructor. The subclass must call one of the
     * flavors of init before the object becomes usable.
     * This is useful when the proper parameters to the init
     * method need to be computed in the subclasses constructor.
     */
    protected AbstractTiledRed() { }


    /**
     * Construct an Abstract RenderedImage from a bounds rect and props
     * (may be null).  The srcs Vector will be empty.
     * @param bounds this defines the extent of the rable in the
     * user coordinate system.
     * @param props this initializes the props Map (may be null)
     */
    protected AbstractTiledRed(Rectangle bounds, Map props) {
        super(bounds, props);
    }

    /**
     * Construct an Abstract RenderedImage from a source image and
     * props (may be null).
     * @param src will be the first (and only) member of the srcs
     * Vector. Src is also used to set the bounds, ColorModel,
     * SampleModel, and tile grid offsets.
     * @param props this initializes the props Map.  */
    protected AbstractTiledRed(CachableRed src, Map props) {
        super(src, props);
    }

    /**
     * Construct an Abstract RenderedImage from a source image, bounds
     * rect and props (may be null).
     * @param src will be the first (and only) member of the srcs
     * Vector. Src is also used to set the ColorModel, SampleModel,
     * and tile grid offsets.
     * @param bounds The bounds of this image.
     * @param props this initializes the props Map.  */
    protected AbstractTiledRed(CachableRed src, Rectangle bounds, Map props) {
        super(src, bounds, props);
    }

    /**
     * Construct an Abstract RenderedImage from a source image, bounds
     * rect and props (may be null).
     * @param src will be the first (and only) member of the srcs
     * Vector. Src is also used to set the ColorModel, SampleModel,
     * and tile grid offsets.
     * @param bounds The bounds of this image.
     * @param cm The ColorModel to use. If null it will default to
     * ComponentColorModel.
     * @param sm The sample model to use. If null it will construct
     * a sample model the matches the given/generated ColorModel and is
     * the size of bounds.
     * @param props this initializes the props Map.  */
    protected AbstractTiledRed(CachableRed src, Rectangle bounds,
                          ColorModel cm, SampleModel sm,
                          Map props) {
        super(src, bounds, cm, sm, props);
    }

    /**
     * Construct an Abstract Rable from a bounds rect and props
     * (may be null).  The srcs Vector will be empty.
     * @param src will be the first (and only) member of the srcs
     * Vector. Src is also used to set the ColorModel, SampleModel,
     * and tile grid offsets.
     * @param bounds this defines the extent of the rable in the
     * user coordinate system.
     * @param cm The ColorModel to use. If null it will default to
     * ComponentColorModel.
     * @param sm The sample model to use. If null it will construct
     * a sample model the matches the given/generated ColorModel and is
     * the size of bounds.
     * @param tileGridXOff The x location of tile 0,0.
     * @param tileGridYOff The y location of tile 0,0.
     * @param props this initializes the props Map.
     */
    protected AbstractTiledRed(CachableRed src, Rectangle bounds,
                          ColorModel cm, SampleModel sm,
                          int tileGridXOff, int tileGridYOff,
                          Map props) {
        super(src, bounds, cm, sm, tileGridXOff, tileGridYOff, props);
    }

    /**
     * This is one of two basic init function (this is for single
     * source rendereds).
     * It is provided so subclasses can compute various values
     * before initializing all the state in the base class.
     * You really should call this method before returning from
     * your subclass constructor.
     *
     * @param src    The source for the filter
     * @param bounds The bounds of the image
     * @param cm     The ColorModel to use. If null it defaults to
     *               ComponentColorModel/ src's ColorModel.
     * @param sm     The Sample modle to use. If this is null it will
     *               use the src's sample model if that is null it will
     *               construct a sample model that matches the ColorModel
     *               and is the size of the whole image.
     * @param tileGridXOff The x location of tile 0,0.
     * @param tileGridYOff The y location of tile 0,0.
     * @param props  Any properties you want to associate with the image.
     */
    protected void init(CachableRed src, Rectangle   bounds,
                        ColorModel  cm,   SampleModel sm,
                        int tileGridXOff, int tileGridYOff,
                        Map props) {
        init(src, bounds, cm, sm, tileGridXOff, tileGridYOff, null, props);
    }


    /**
     * This is one of two basic init function (this is for single
     * source rendereds).
     * It is provided so subclasses can compute various values
     * before initializing all the state in the base class.
     * You really should call this method before returning from
     * your subclass constructor.
     *
     * @param src    The source for the filter
     * @param bounds The bounds of the image
     * @param cm     The ColorModel to use. If null it defaults to
     *               ComponentColorModel/ src's ColorModel.
     * @param sm     The Sample modle to use. If this is null it will
     *               use the src's sample model if that is null it will
     *               construct a sample model that matches the ColorModel
     *               and is the size of the whole image.
     * @param tileGridXOff The x location of tile 0,0.
     * @param tileGridYOff The y location of tile 0,0.
     * @param tiles  The tileStore to use (or null).
     * @param props  Any properties you want to associate with the image.
     */
    protected void init(CachableRed src, Rectangle   bounds,
                        ColorModel  cm,   SampleModel sm,
                        int tileGridXOff, int tileGridYOff,
                        TileStore tiles,
                        Map props) {
        super.init(src, bounds, cm, sm, tileGridXOff, tileGridYOff, props);
        this.tiles = tiles;
        if (this.tiles == null)
            this.tiles = createTileStore();
    }

    /**
     * Construct an Abstract Rable from a List of sources a bounds rect
     * and props (may be null).
     * @param srcs This is used to initialize the srcs Vector.  All
     * the members of srcs must be CachableRed otherwise an error
     * will be thrown.
     * @param bounds this defines the extent of the rendered in pixels
     * @param props this initializes the props Map.
     */
    protected AbstractTiledRed(List srcs, Rectangle bounds, Map props) {
        super(srcs, bounds, props);
    }

    /**
     * Construct an Abstract RenderedImage from a bounds rect,
     * ColorModel (may be null), SampleModel (may be null) and props
     * (may be null).  The srcs Vector will be empty.
     * @param srcs This is used to initialize the srcs Vector.  All
     * the members of srcs must be CachableRed otherwise an error
     * will be thrown.
     * @param bounds this defines the extent of the rendered in pixels
     * @param cm The ColorModel to use. If null it will default to
     * ComponentColorModel.
     * @param sm The sample model to use. If null it will construct
     * a sample model the matches the given/generated ColorModel and is
     * the size of bounds.
     * @param props this initializes the props Map.
     */
    protected AbstractTiledRed(List srcs, Rectangle bounds,
                          ColorModel cm, SampleModel sm,
                          Map props) {
        super(srcs, bounds, cm, sm, props);
    }

    /**
     * Construct an Abstract RenderedImage from a bounds rect,
     * ColorModel (may be null), SampleModel (may be null), tile grid
     * offsets and props (may be null).  The srcs Vector will be
     * empty.
     * @param srcs This is used to initialize the srcs Vector.  All
     * the members of srcs must be CachableRed otherwise an error
     * will be thrown.
     * @param bounds this defines the extent of the rable in the
     * user coordinate system.
     * @param cm The ColorModel to use. If null it will default to
     * ComponentColorModel.
     * @param sm The sample model to use. If null it will construct
     * a sample model the matches the given/generated ColorModel and is
     * the size of bounds.
     * @param tileGridXOff The x location of tile 0,0.
     * @param tileGridYOff The y location of tile 0,0.
     * @param props this initializes the props Map.
     */
    protected AbstractTiledRed(List srcs, Rectangle bounds,
                          ColorModel cm, SampleModel sm,
                          int tileGridXOff, int tileGridYOff,
                          Map props) {
        super(srcs, bounds, cm, sm, tileGridXOff, tileGridYOff, props);
    }

    /**
     * This is the basic init function.
     * It is provided so subclasses can compute various values
     * before initializing all the state in the base class.
     * You really should call this method before returning from
     * your subclass constructor.
     *
     * @param srcs   The list of sources
     * @param bounds The bounds of the image
     * @param cm     The ColorModel to use. If null it defaults to
     *               ComponentColorModel.
     * @param sm     The Sample modle to use. If this is null it will
     *               construct a sample model that matches the ColorModel
     *               and is the size of the whole image.
     * @param tileGridXOff The x location of tile 0,0.
     * @param tileGridYOff The y location of tile 0,0.
     * @param props  Any properties you want to associate with the image.
     */
    protected void init(List srcs, Rectangle bounds,
                        ColorModel cm, SampleModel sm,
                        int tileGridXOff, int tileGridYOff,
                        Map props) {
        super.init(srcs, bounds, cm, sm, tileGridXOff, tileGridYOff, props);
        tiles = createTileStore();
    }

    public TileStore getTileStore() {
        return tiles;
    }

    protected void setTileStore(TileStore tiles) {
        this.tiles = tiles;
    }

    protected TileStore createTileStore() {
        return TileCache.getTileMap(this);
    }

    public WritableRaster copyData(WritableRaster wr) {
        copyToRasterByBlocks(wr);
        return wr;
    }


    public Raster getData(Rectangle rect) {
        int xt0 = getXTile(rect.x);
        int xt1 = getXTile(rect.x+rect.width-1);
        int yt0 = getYTile(rect.y);
        int yt1 = getYTile(rect.y+rect.height-1);

        if ((xt0 == xt1) && (yt0 == yt1)) {
            Raster r = getTile(xt0, yt0);
            return r.createChild(rect.x, rect.y, rect.width, rect.height,
                                 rect.x, rect.y, null);
        }
        // rect crosses tile boundries...
        return super.getData(rect);
    }


    public Raster getTile(int x, int y) {
        return tiles.getTile(x, y);
    }

    public Raster genTile(int x, int y) {
        WritableRaster wr = makeTile(x, y);
        genRect(wr);
        return wr;
    }

    public abstract void genRect(WritableRaster wr);
    // { copyToRaster(wr); }


    public void setTile(int x, int y, Raster ras) {
        tiles.setTile(x, y, ras);
    }

    public void copyToRasterByBlocks(WritableRaster wr) {
        final boolean is_INT_PACK =
            GraphicsUtil.is_INT_PACK_Data(getSampleModel(), false);

        Rectangle bounds = getBounds();
        Rectangle wrR    = wr.getBounds();

        int tx0 = getXTile(wrR.x);
        int ty0 = getYTile(wrR.y);
        int tx1 = getXTile(wrR.x+wrR.width -1);
        int ty1 = getYTile(wrR.y+wrR.height-1);

        if (tx0 < minTileX) tx0 = minTileX;
        if (ty0 < minTileY) ty0 = minTileY;

        if (tx1 >= minTileX+numXTiles) tx1 = minTileX+numXTiles-1;
        if (ty1 >= minTileY+numYTiles) ty1 = minTileY+numYTiles-1;

        if ((tx1 < tx0) || (ty1 < ty0))
            return;

        // System.out.println("WR: " + wrR);
        // System.out.println("ME: " + bounds);

        int insideTx0 = tx0;
        int insideTx1 = tx1;

        int insideTy0 = ty0;
        int insideTy1 = ty1;

        // Now figure out what tiles lie completely inside wr...
        int tx, ty;
        tx = tx0*tileWidth+tileGridXOff;
        if ((tx < wrR.x)  && (bounds.x != wrR.x))
            // Partial tile off the left.
            insideTx0++;

        ty= ty0*tileHeight+tileGridYOff;
        if ((ty < wrR.y) && (bounds.y != wrR.y))
            // Partial tile off the top.
            insideTy0++;

        tx= (tx1+1)*tileWidth+tileGridXOff-1;
        if ((tx >= (wrR.x+wrR.width)) &&
            ((bounds.x+bounds.width) != (wrR.x+wrR.width)))
            // Partial tile off right
            insideTx1--;

        ty= (ty1+1)*tileHeight+tileGridYOff-1;
        if ((ty >= (wrR.y+wrR.height)) &&
            ((bounds.y+bounds.height) != (wrR.y+wrR.height)))
            // Partial tile off bottom
            insideTy1--;

        int xtiles = insideTx1-insideTx0+1;
        int ytiles = insideTy1-insideTy0+1;
        boolean [] occupied = null;
        if ((xtiles > 0) && (ytiles > 0))
            occupied = new boolean[xtiles*ytiles];

        boolean [] got = new boolean[2*(tx1-tx0+1) + 2*(ty1-ty0+1)];
        int idx = 0;
        int numFound = 0;
        // Collect all the tiles that we currently have in cache...
        for (int y=ty0; y<=ty1; y++) {
            for (int x=tx0; x<=tx1; x++) {
                Raster ras = tiles.getTileNoCompute(x, y);
                boolean found = (ras != null);
                if ((y>=insideTy0) && (y<=insideTy1) &&
                    (x>=insideTx0) && (x<=insideTx1))
                    occupied[(x-insideTx0)+(y-insideTy0)*xtiles] = found;
                else
                    got[idx++] = found;

                if (!found) continue;

                numFound++;

                if (is_INT_PACK)
                    GraphicsUtil.copyData_INT_PACK(ras, wr);
                else
                    GraphicsUtil.copyData_FALLBACK(ras, wr);
            }
        }

        // System.out.println("Found: " + numFound + " out of " +
        //                    ((tx1-tx0+1)*(ty1-ty0+1)));

        // Compute the stuff from the middle in the largest possible Chunks.
        if ((xtiles > 0) && (ytiles > 0)) {
            TileBlock block = new TileBlock
                (insideTx0, insideTy0, xtiles, ytiles, occupied,
                 0, 0, xtiles, ytiles);
            // System.out.println("Starting Splits");
            drawBlock(block, wr);
            // Exception e= new Exception("Foo");
            // e.printStackTrace();
        }

        // Check If we should halt early.
        Thread currentThread = Thread.currentThread();
        if (HaltingThread.hasBeenHalted())
            return;

        idx = 0;
        // Fill in the ones that weren't in the cache.
        for (ty=ty0; ty<=ty1; ty++) {

            for (tx=tx0; tx<=tx1; tx++) {
                // At least touch the tile...
                Raster ras = tiles.getTileNoCompute(tx, ty);

                if ((ty>=insideTy0) && (ty<=insideTy1) &&
                    (tx>=insideTx0) && (tx<=insideTx1)) {

                    if (ras != null) continue;

                    // Fill the tile from wr (since wr is full now
                    // at least in the middle).
                    WritableRaster tile = makeTile(tx, ty);
                    if (is_INT_PACK)
                        GraphicsUtil.copyData_INT_PACK(wr, tile);
                    else
                        GraphicsUtil.copyData_FALLBACK(wr, tile);

                    tiles.setTile(tx, ty, tile);
                }
                else {
                    if (got[idx++]) continue;

                    // System.out.println("Computing : " + x + "," + y);

                    ras = getTile(tx, ty);// Compute the tile..
                    // Check If we should halt early.
                    if (HaltingThread.hasBeenHalted( currentThread ))
                        return;

                    if (is_INT_PACK)
                        GraphicsUtil.copyData_INT_PACK(ras, wr);
                    else
                        GraphicsUtil.copyData_FALLBACK(ras, wr);
                }
            }
        }

        // System.out.println("Ending Computation: " + this);
    }

    /**
     * Copies data from this images tile grid into wr.  wr may
     * extend outside the bounds of this image in which case the
     * data in wr outside the bounds will not be touched.
     * @param wr Raster to fill with image data.
     */
    public void copyToRaster(WritableRaster wr) {
        Rectangle wrR = wr.getBounds();

        int tx0 = getXTile(wrR.x);
        int ty0 = getYTile(wrR.y);
        int tx1 = getXTile(wrR.x+wrR.width -1);
        int ty1 = getYTile(wrR.y+wrR.height-1);

        if (tx0 < minTileX) tx0 = minTileX;
        if (ty0 < minTileY) ty0 = minTileY;

        if (tx1 >= minTileX+numXTiles) tx1 = minTileX+numXTiles-1;
        if (ty1 >= minTileY+numYTiles) ty1 = minTileY+numYTiles-1;

        final boolean is_INT_PACK =
            GraphicsUtil.is_INT_PACK_Data(getSampleModel(), false);

        int xtiles = (tx1-tx0+1);
        boolean [] got = new boolean[xtiles*(ty1-ty0+1)];

        // Run through and get the tiles that are just sitting in the
        // cache...
        for (int y=ty0; y<=ty1; y++)
            for (int x=tx0; x<=tx1; x++) {
                Raster r = tiles.getTileNoCompute(x, y);
                if (r == null) continue; // Not there.

                got[x-tx0 + (y-ty0)*xtiles] = true;

                if (is_INT_PACK)
                    GraphicsUtil.copyData_INT_PACK(r, wr);
                else
                    GraphicsUtil.copyData_FALLBACK(r, wr);
            }

        // Run through and pick up the ones we need to compute...
        for (int y=ty0; y<=ty1; y++)
            for (int x=tx0; x<=tx1; x++) {
                if (got[x-tx0 + (y-ty0)*xtiles]) continue; // already have.

                Raster r = getTile(x, y);
                if (is_INT_PACK)
                    GraphicsUtil.copyData_INT_PACK(r, wr);
                else
                    GraphicsUtil.copyData_FALLBACK(r, wr);
            }
    }

    protected void drawBlock( TileBlock block, WritableRaster wr ) {
        TileBlock [] blocks = block.getBestSplit();
        if ( blocks == null ) {
            return;
        }

        drawBlockInPlace( blocks, wr );
    }

    protected void drawBlockAndCopy( TileBlock []blocks, WritableRaster wr ) {

        if ( blocks.length == 1 ) {
            TileBlock curr = blocks[ 0 ];
            int xloc = curr.getXLoc() * tileWidth + tileGridXOff;
            int yloc = curr.getYLoc() * tileHeight + tileGridYOff;
            if ( ( xloc == wr.getMinX() ) &&
                 ( yloc == wr.getMinY() ) ) {
                // Safe to draw in place...
                drawBlockInPlace( blocks, wr );
                return;
            }
        }

        int workTileWidth = tileWidth;    // local is cheaper
        int workTileHeight = tileHeight;  // local is cheaper
        int maxTileSize = 0;
        for ( int i = 0; i < blocks.length; i++ ) {
            TileBlock curr = blocks[ i ];
            int sz = ( ( curr.getWidth() * workTileWidth ) *
                       ( curr.getHeight() * workTileHeight ) );
            if ( sz > maxTileSize ) {
                maxTileSize = sz;
            }
        }
        DataBufferInt dbi = new DataBufferInt( maxTileSize );
        int [] masks = {0x00FF0000, 0x0000FF00, 0x000000FF, 0xFF000000};
        boolean use_INT_PACK = GraphicsUtil.is_INT_PACK_Data( wr.getSampleModel(), false );

        // cache for reuse in hasBeenHalted()
        Thread currentThread = Thread.currentThread();

        for ( int i = 0; i < blocks.length; i++ ) {
            TileBlock curr = blocks[ i ];
            int xloc = curr.getXLoc() * workTileWidth + tileGridXOff;
            int yloc = curr.getYLoc() * workTileHeight + tileGridYOff;
            Rectangle tb = new Rectangle( xloc, yloc,
                    curr.getWidth() * workTileWidth,
                    curr.getHeight() * workTileHeight );
            tb = tb.intersection( bounds );
            Point loc = new Point( tb.x, tb.y );
            WritableRaster child = Raster.createPackedRaster( dbi, tb.width, tb.height, tb.width, masks, loc );
            genRect( child );
            if ( use_INT_PACK ) {
                GraphicsUtil.copyData_INT_PACK( child, wr );
            } else {
                GraphicsUtil.copyData_FALLBACK( child, wr );
            }

            // Check If we should halt early.
            if ( HaltingThread.hasBeenHalted( currentThread ) ) {
                return;
            }
        }
    }


    protected void drawBlockInPlace( TileBlock [] blocks, WritableRaster wr ) {
        // System.out.println("Ending Splits: " + blocks.length);

        // cache for reuse in hasBeenHalted()
        Thread currentThread = Thread.currentThread();

        int workTileWidth = tileWidth;    // local is cheaper
        int workTileHeight = tileHeight;  // local is cheaper

        for ( int i = 0; i < blocks.length; i++ ) {
            TileBlock curr = blocks[ i ];

            // System.out.println("Block " + i + ":\n" + curr);

            int xloc = curr.getXLoc() * workTileWidth + tileGridXOff;
            int yloc = curr.getYLoc() * workTileHeight + tileGridYOff;
            Rectangle tb = new Rectangle( xloc, yloc,
                    curr.getWidth() * workTileWidth,
                    curr.getHeight() * workTileHeight );
            tb = tb.intersection( bounds );

            WritableRaster child =
                    wr.createWritableChild( tb.x, tb.y, tb.width, tb.height,
                            tb.x, tb.y, null );
            // System.out.println("Computing : " + child);
            genRect( child );

            // Check If we should halt early.
            if ( HaltingThread.hasBeenHalted( currentThread ) ) {
                return;
            }
        }
    }
}

