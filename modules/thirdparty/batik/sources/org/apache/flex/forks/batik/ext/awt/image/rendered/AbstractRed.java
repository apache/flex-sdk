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
import java.awt.Shape;
import java.awt.Transparency;
import java.awt.color.ColorSpace;
import java.awt.image.ColorModel;
import java.awt.image.ComponentColorModel;
import java.awt.image.DataBuffer;
import java.awt.image.Raster;
import java.awt.image.RenderedImage;
import java.awt.image.SampleModel;
import java.awt.image.WritableRaster;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Vector;

import org.apache.flex.forks.batik.ext.awt.image.GraphicsUtil;


// import org.apache.flex.forks.batik.ext.awt.image.DataBufferReclaimer;
// import java.awt.image.DataBufferInt;
// import java.awt.image.SinglePixelPackedSampleModel;


/**
 * This is an abstract base class that takes care of most of the
 * normal issues surrounding the implementation of the CachableRed
 * (RenderedImage) interface.  It tries to make no assumptions about
 * the subclass implementation.
 *
 * @author <a href="mailto:Thomas.DeWeeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: AbstractRed.java 489226 2006-12-21 00:05:36Z cam $
 */
public abstract class AbstractRed implements CachableRed {

    protected Rectangle   bounds;
    protected Vector      srcs;
    protected Map         props;
    protected SampleModel sm;
    protected ColorModel  cm;
    protected int         tileGridXOff, tileGridYOff;
    protected int         tileWidth,    tileHeight;
    protected int         minTileX,     minTileY;
    protected int         numXTiles,    numYTiles;

    /**
     * void constructor. The subclass must call one of the
     * flavors of init before the object becomes usable.
     * This is useful when the proper parameters to the init
     * method need to be computed in the subclasses constructor.
     */
    protected AbstractRed() {
    }


    /**
     * Construct an Abstract RenderedImage from a bounds rect and props
     * (may be null).  The srcs Vector will be empty.
     * @param bounds this defines the extent of the rable in the
     * user coordinate system.
     * @param props this initializes the props Map (may be null)
     */
    protected AbstractRed(Rectangle bounds, Map props) {
        init((CachableRed)null, bounds, null, null,
             bounds.x, bounds.y, props);
    }

    /**
     * Construct an Abstract RenderedImage from a source image and
     * props (may be null).
     * @param src will be the first (and only) member of the srcs
     * Vector. Src is also used to set the bounds, ColorModel,
     * SampleModel, and tile grid offsets.
     * @param props this initializes the props Map.  */
    protected AbstractRed(CachableRed src, Map props) {
        init(src, src.getBounds(), src.getColorModel(), src.getSampleModel(),
             src.getTileGridXOffset(),
             src.getTileGridYOffset(),
             props);
    }

    /**
     * Construct an Abstract RenderedImage from a source image, bounds
     * rect and props (may be null).
     * @param src will be the first (and only) member of the srcs
     * Vector. Src is also used to set the ColorModel, SampleModel,
     * and tile grid offsets.
     * @param bounds The bounds of this image.
     * @param props this initializes the props Map.  */
    protected AbstractRed(CachableRed src, Rectangle bounds, Map props) {
        init(src, bounds, src.getColorModel(), src.getSampleModel(),
             src.getTileGridXOffset(),
             src.getTileGridYOffset(),
             props);
    }

    /**
     * Construct an Abstract RenderedImage from a source image, bounds
     * rect and props (may be null).
     * @param src if not null, will be the first (and only) member
     * of the srcs Vector. Also if it is not null it provides the
     * tile grid offsets, otherwise they are zero.
     * @param bounds The bounds of this image.
     * @param cm The ColorModel to use. If null it will default to
     * ComponentColorModel.
     * @param sm The sample model to use. If null it will construct
     * a sample model the matches the given/generated ColorModel and is
     * the size of bounds.
     * @param props this initializes the props Map.  */
    protected AbstractRed(CachableRed src, Rectangle bounds,
                          ColorModel cm, SampleModel sm,
                          Map props) {
        init(src, bounds, cm, sm,
             (src==null)?0:src.getTileGridXOffset(),
             (src==null)?0:src.getTileGridYOffset(),
             props);
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
    protected AbstractRed(CachableRed src, Rectangle bounds,
                          ColorModel cm, SampleModel sm,
                          int tileGridXOff, int tileGridYOff,
                          Map props) {
        init(src, bounds, cm, sm, tileGridXOff, tileGridYOff, props);
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
        this.srcs         = new Vector(1);
        if (src != null) {
            this.srcs.add(src);
            if (bounds == null) bounds = src.getBounds();
            if (cm     == null) cm     = src.getColorModel();
            if (sm     == null) sm     = src.getSampleModel();
        }

        this.bounds       = bounds;
        this.tileGridXOff = tileGridXOff;
        this.tileGridYOff = tileGridYOff;

        this.props        = new HashMap();
        if(props != null){
            this.props.putAll(props);
        }

        if (cm == null)
            cm = new ComponentColorModel
                (ColorSpace.getInstance(ColorSpace.CS_GRAY),
                 new int [] { 8 }, false, false, Transparency.OPAQUE,
                 DataBuffer.TYPE_BYTE);

        this.cm = cm;

        if (sm == null)
            sm = cm.createCompatibleSampleModel(bounds.width, bounds.height);
        this.sm = sm;

        // Recompute tileWidth/Height, minTileX/Y, numX/YTiles.
        updateTileGridInfo();
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
    protected AbstractRed(List srcs, Rectangle bounds, Map props) {
        init(srcs, bounds, null, null, bounds.x, bounds.y, props);
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
    protected AbstractRed(List srcs, Rectangle bounds,
                          ColorModel cm, SampleModel sm,
                          Map props) {
        init(srcs, bounds, cm, sm, bounds.x, bounds.y, props);
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
    protected AbstractRed(List srcs, Rectangle bounds,
                          ColorModel cm, SampleModel sm,
                          int tileGridXOff, int tileGridYOff,
                          Map props) {
        init(srcs, bounds, cm, sm, tileGridXOff, tileGridYOff, props);
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
        this.srcs = new Vector();
        if(srcs != null){
            this.srcs.addAll(srcs);
        }

        if (srcs.size() != 0) {
            CachableRed src = (CachableRed)srcs.get(0);
            if (bounds == null) bounds = src.getBounds();
            if (cm     == null) cm     = src.getColorModel();
            if (sm     == null) sm     = src.getSampleModel();
        }

        this.bounds       = bounds;
        this.tileGridXOff = tileGridXOff;
        this.tileGridYOff = tileGridYOff;
        this.props        = new HashMap();
        if(props != null){
            this.props.putAll(props);
        }

        if (cm == null)
            cm = new ComponentColorModel
                (ColorSpace.getInstance(ColorSpace.CS_GRAY),
                 new int [] { 8 }, false, false, Transparency.OPAQUE,
                 DataBuffer.TYPE_BYTE);

        this.cm = cm;

        if (sm == null)
            sm = cm.createCompatibleSampleModel(bounds.width, bounds.height);
        this.sm = sm;

        // Recompute tileWidth/Height, minTileX/Y, numX/YTiles.
        updateTileGridInfo();
    }

    /**
     * This function computes all the basic information about the tile
     * grid based on the data stored in sm, and tileGridX/YOff.
     * It is responsible for updating tileWidth, tileHeight,
     * minTileX/Y, and numX/YTiles.
     */
    protected void updateTileGridInfo() {
        this.tileWidth  = sm.getWidth();
        this.tileHeight = sm.getHeight();

        int x1, y1, maxTileX, maxTileY;

        // This computes and caches important information about the
        // structure of the tile grid in general.
        minTileX = getXTile(bounds.x);
        minTileY = getYTile(bounds.y);

        x1       = bounds.x + bounds.width-1;     // Xloc of right edge
        maxTileX = getXTile(x1);
        numXTiles = maxTileX-minTileX+1;

        y1       = bounds.y + bounds.height-1;     // Yloc of right edge
        maxTileY = getYTile(y1);
        numYTiles = maxTileY-minTileY+1;
    }


    public Rectangle getBounds() {
        return new Rectangle(getMinX(),
                             getMinY(),
                             getWidth(),
                             getHeight());
    }

    public Vector getSources() {
        return srcs;
    }

    public ColorModel getColorModel() {
        return cm;
    }

    public SampleModel getSampleModel() {
        return sm;
    }

    public int getMinX() {
        return bounds.x;
    }
    public int getMinY() {
        return bounds.y;
    }

    public int getWidth() {
        return bounds.width;
    }

    public int getHeight() {
        return bounds.height;
    }

    public int getTileWidth() {
        return tileWidth;
    }

    public int getTileHeight() {
        return tileHeight;
    }

    public int getTileGridXOffset() {
        return tileGridXOff;
    }

    public int getTileGridYOffset() {
        return tileGridYOff;
    }

    public int getMinTileX() {
        return minTileX;
    }

    public int getMinTileY() {
        return minTileY;
    }

    public int getNumXTiles() {
        return numXTiles;
    }

    public int getNumYTiles() {
        return numYTiles;
    }

    public Object getProperty(String name) {
        Object ret = props.get(name);
        if (ret != null) return ret;
        Iterator i = srcs.iterator();
        while (i.hasNext()) {
            RenderedImage ri = (RenderedImage)i.next();
            ret = ri.getProperty(name);
            if (ret != null) return ret;
        }
        return null;
    }

    public String [] getPropertyNames() {
        Set keys = props.keySet();
        String[] ret  = new String[keys.size()];
        keys.toArray( ret );

//        Iterator iter = keys.iterator();
//        int i=0;
//        while (iter.hasNext()) {
//            ret[i++] = (String)iter.next();
//        }

        Iterator iter = srcs.iterator();
        while (iter.hasNext()) {
            RenderedImage ri = (RenderedImage)iter.next();
            String [] srcProps = ri.getPropertyNames();
            if (srcProps.length != 0) {
                String [] tmp = new String[ret.length+srcProps.length];
                System.arraycopy(ret,0,tmp,0,ret.length);
                /// ??? System.arraycopy((tmp,ret.length,srcProps,0,srcProps.length);
                System.arraycopy( srcProps, 0, tmp, ret.length, srcProps.length);
                ret = tmp;
            }
        }

        return ret;
    }

    public Shape getDependencyRegion(int srcIndex, Rectangle outputRgn) {
        if ((srcIndex < 0) || (srcIndex > srcs.size()))
            throw new IndexOutOfBoundsException
                ("Nonexistant source requested.");

        // Return empty rect if they don't intersect.
        if ( ! outputRgn.intersects(bounds) )
            return new Rectangle();

        // We only depend on our source for stuff that is inside
        // our bounds...
        return outputRgn.intersection(bounds);
    }

    public Shape getDirtyRegion(int srcIndex, Rectangle inputRgn) {
        if (srcIndex != 0)
            throw new IndexOutOfBoundsException
                ("Nonexistant source requested.");

        // Return empty rect if they don't intersect.
        if ( ! inputRgn.intersects(bounds) )
            return new Rectangle();

        // Changes in the input region don't propogate outside our
        // bounds.
        return inputRgn.intersection(bounds);
    }


    // This is not included but can be implemented by the following.
    // In which case you _must_ reimplement getTile.
    // public WritableRaster copyData(WritableRaster wr) {
    //     copyToRaster(wr);
    //     return wr;
    // }

    public Raster getTile(int tileX, int tileY) {
        WritableRaster wr = makeTile(tileX, tileY);
        return copyData(wr);
    }

    public Raster getData() {
        return getData(bounds);
    }

    public Raster getData(Rectangle rect) {
        SampleModel smRet = sm.createCompatibleSampleModel
            (rect.width, rect.height);

        Point pt = new Point(rect.x, rect.y);
        WritableRaster wr = Raster.createWritableRaster(smRet, pt);

        // System.out.println("GD DB: " + wr.getDataBuffer().getSize());
        return copyData(wr);
    }

    /**
     * Returns the x index of tile under xloc.
     * @param  xloc the x location (in pixels) to get tile for.
     * @return The tile index under xloc (may be outside tile grid).
     */
    public final int getXTile(int xloc) {
        int tgx = xloc-tileGridXOff;
        // We need to round to -infinity...
        if (tgx>=0)
            return tgx/tileWidth;
        else
            return (tgx-tileWidth+1)/tileWidth;
    }

    /**
     * Returns the y index of tile under yloc.
     * @param  yloc the y location (in pixels) to get tile for.
     * @return The tile index under yloc (may be outside tile grid).
     */
    public final int getYTile(int yloc) {
        int tgy = yloc-tileGridYOff;
        // We need to round to -infinity...
        if (tgy>=0)
            return tgy/tileHeight;
        else
            return (tgy-tileHeight+1)/tileHeight;
    }

    /**
     * Copies data from this images tile grid into wr.  wr may
     * extend outside the bounds of this image in which case the
     * data in wr outside the bounds will not be touched.
     * @param wr Raster to fill with image data.
     */
    public void copyToRaster(WritableRaster wr) {
        int tx0 = getXTile(wr.getMinX());
        int ty0 = getYTile(wr.getMinY());
        int tx1 = getXTile(wr.getMinX()+wr.getWidth() -1);
        int ty1 = getYTile(wr.getMinY()+wr.getHeight()-1);

        if (tx0 < minTileX) tx0 = minTileX;
        if (ty0 < minTileY) ty0 = minTileY;

        if (tx1 >= minTileX+numXTiles) tx1 = minTileX+numXTiles-1;
        if (ty1 >= minTileY+numYTiles) ty1 = minTileY+numYTiles-1;

        final boolean is_INT_PACK =
            GraphicsUtil.is_INT_PACK_Data(getSampleModel(), false);

        for (int y=ty0; y<=ty1; y++)
            for (int x=tx0; x<=tx1; x++) {
                Raster r = getTile(x, y);
                if (is_INT_PACK)
                    GraphicsUtil.copyData_INT_PACK(r, wr);
                else
                    GraphicsUtil.copyData_FALLBACK(r, wr);
            }
    }


    // static DataBufferReclaimer reclaim = new DataBufferReclaimer();

    /**
     * This is a helper function that will create the tile requested
     * Including properly subsetting the bounds of the tile to the
     * bounds of the current image.
     * @param tileX The x index of the tile to be built
     * @param tileY The y index of the tile to be built
     * @return The tile requested
     * @exception IndexOutOfBoundsException if the requested tile index
     *   falles outside of the bounds of the tile grid for the image.
     */
    public WritableRaster makeTile(int tileX, int tileY) {
        if ((tileX < minTileX) || (tileX >= minTileX+numXTiles) ||
            (tileY < minTileY) || (tileY >= minTileY+numYTiles))
            throw new IndexOutOfBoundsException
                ("Requested Tile (" + tileX + ',' + tileY +
                 ") lies outside the bounds of image");

        Point pt = new Point(tileGridXOff+tileX*tileWidth,
                             tileGridYOff+tileY*tileHeight);

        WritableRaster wr;
        wr = Raster.createWritableRaster(sm, pt);
        // if (!(sm instanceof SinglePixelPackedSampleModel))
        //     wr = Raster.createWritableRaster(sm, pt);
        // else {
        //     SinglePixelPackedSampleModel sppsm;
        //     sppsm = (SinglePixelPackedSampleModel)sm;
        //     int stride = sppsm.getScanlineStride();
        //     int sz = stride*sppsm.getHeight();
        //
        //     int [] data = reclaim.request(sz);
        //     DataBuffer db = new DataBufferInt(data, sz);
        //
        //     reclaim.register(db);
        //
        //     wr = Raster.createWritableRaster(sm, db, pt);
        // }

        // System.out.println("MT DB: " + wr.getDataBuffer().getSize());

        int x0 = wr.getMinX();
        int y0 = wr.getMinY();
        int x1 = x0+wr.getWidth() -1;
        int y1 = y0+wr.getHeight()-1;

        if ((x0 < bounds.x) || (x1 >= (bounds.x+bounds.width)) ||
            (y0 < bounds.y) || (y1 >= (bounds.y+bounds.height))) {
            // Part of this raster lies outside our bounds so subset
            // it so it only advertises the stuff inside our bounds.
            if (x0 < bounds.x) x0 = bounds.x;
            if (y0 < bounds.y) y0 = bounds.y;
            if (x1 >= (bounds.x+bounds.width))  x1 = bounds.x+bounds.width-1;
            if (y1 >= (bounds.y+bounds.height)) y1 = bounds.y+bounds.height-1;

            wr = wr.createWritableChild(x0, y0, x1-x0+1, y1-y0+1,
                                        x0, y0, null);
        }
        return wr;
    }

    public static void copyBand(Raster         src, int srcBand,
                                WritableRaster dst, int dstBand) {
        Rectangle srcR = new Rectangle(src.getMinX(),  src.getMinY(),
                                       src.getWidth(), src.getHeight());
        Rectangle dstR = new Rectangle(dst.getMinX(),  dst.getMinY(),
                                       dst.getWidth(), dst.getHeight());

        Rectangle cpR  = srcR.intersection(dstR);

        int [] samples = null;
        for (int y=cpR.y; y< cpR.y+cpR.height; y++) {
            samples = src.getSamples(cpR.x, y, cpR.width, 1, srcBand, samples);
            dst.setSamples(cpR.x, y, cpR.width, 1, dstBand, samples);
        }
    }
}

