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

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.Paint;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.image.BufferedImage;
import java.awt.image.ColorModel;
import java.awt.image.Raster;
import java.awt.image.SampleModel;
import java.awt.image.WritableRaster;

import org.apache.flex.forks.batik.ext.awt.image.GraphicsUtil;

/**
 * This implementation of RenderedImage will generate an infinate
 * field of a single color.  It reports bounds but will in fact render
 * out to infinity.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: FloodRed.java 475477 2006-11-15 22:44:28Z cam $ 
 */
public class FloodRed extends AbstractRed {

    /**
     * A single tile that we move around as needed...
     */
    private WritableRaster raster;

    /**
     * Construct a fully transparent black image <tt>bounds</tt> size.
     * @param bounds the bounds of the image (in fact will respond with
     *               any request).
     */
    public FloodRed(Rectangle bounds) {
        this(bounds, new Color(0, 0, 0, 0));
    }

    /**
     * Construct a fully transparent image <tt>bounds</tt> size, will
     * paint one tile with paint.  Thus paint should not be a pattered
     * paint or gradient but should be a solid color.
     * @param bounds the bounds of the image (in fact will respond with
     *               any request).  
     */
    public FloodRed(Rectangle bounds,
                    Paint paint) {
        super(); // We _must_ call init...

        ColorModel cm = GraphicsUtil.sRGB_Unpre;
        
        int defSz = AbstractTiledRed.getDefaultTileSize();

        int tw = bounds.width;
        if (tw > defSz) tw = defSz;
        int th = bounds.height;
        if (th > defSz) th = defSz;

        // fix my sample model so it makes sense given my size.
        SampleModel sm = cm.createCompatibleSampleModel(tw, th);

        // Finish initializing our base class...
        init((CachableRed)null, bounds, cm, sm, 0, 0, null);

        raster = Raster.createWritableRaster(sm, new Point(0, 0));
        BufferedImage offScreen = new BufferedImage(cm, raster,
                                                    cm.isAlphaPremultiplied(),
                                                    null);

        Graphics2D g = GraphicsUtil.createGraphics(offScreen);
        g.setPaint(paint);
        g.fillRect(0, 0, bounds.width, bounds.height);
        g.dispose();
    }

    public Raster getTile(int x, int y) {
        // We have a Single raster that we translate where needed
        // position.  So just offest appropriately.
        int tx = tileGridXOff+x*tileWidth;
        int ty = tileGridYOff+y*tileHeight;
        return raster.createTranslatedChild(tx, ty);
    }

    public WritableRaster copyData(WritableRaster wr) {
        int tx0 = getXTile(wr.getMinX());
        int ty0 = getYTile(wr.getMinY());
        int tx1 = getXTile(wr.getMinX()+wr.getWidth() -1);
        int ty1 = getYTile(wr.getMinY()+wr.getHeight()-1);

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

        return wr;
    }
}




