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
package org.apache.flex.forks.batik.gvt;

import java.awt.PaintContext;
import java.awt.Rectangle;
import java.awt.RenderingHints;
import java.awt.color.ColorSpace;
import java.awt.geom.AffineTransform;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.awt.image.ColorModel;
import java.awt.image.Raster;
import java.awt.image.RenderedImage;
import java.awt.image.WritableRaster;
import java.awt.image.renderable.RenderContext;

import org.apache.flex.forks.batik.ext.awt.image.GraphicsUtil;
import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.ext.awt.image.renderable.TileRable;
import org.apache.flex.forks.batik.ext.awt.image.renderable.TileRable8Bit;
import org.apache.flex.forks.batik.ext.awt.image.rendered.TileCacheRed;

/**
 * <tt>PaintContext</tt> for the <tt>ConcretePatterPaint</tt>
 * paint implementation.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: PatternPaintContext.java 475477 2006-11-15 22:44:28Z cam $
 */
public class PatternPaintContext implements PaintContext {

    /**
     * ColorModel for the Rasters created by this Paint
     */
    private ColorModel rasterCM;

    /**
     * Working Raster
     */
    private WritableRaster raster;

    /**
     * Tile
     */
    private RenderedImage tiled;

    protected AffineTransform usr2dev;

    public AffineTransform getUsr2Dev() { return usr2dev; }

    private static Rectangle EVERYTHING = 
        new Rectangle(Integer.MIN_VALUE/4, Integer.MIN_VALUE/4, 
                      Integer.MAX_VALUE/2, Integer.MAX_VALUE/2);

    /**
     * @param destCM     ColorModel that receives the paint data
     * @param usr2dev    user space to device space transform
     * @param hints      RenderingHints
     * @param patternRegion region tiled by this paint. In user space.
     * @param overflow   controls whether the pattern region clips the
     *                   pattern tile
     */
    public PatternPaintContext(ColorModel      destCM,
                               AffineTransform usr2dev,
                               RenderingHints  hints,
                               Filter          tile,
                               Rectangle2D     patternRegion,
                               boolean         overflow) {

        if(usr2dev == null){
            throw new IllegalArgumentException();
        }

        if(hints == null){
            hints = new RenderingHints(null);
        }

        if(tile == null){
            throw new IllegalArgumentException();
        }

        this.usr2dev    = usr2dev;

        // System.out.println("PatB: " + patternRegion);
        // System.out.println("Tile: " + tile);

        TileRable tileRable = new TileRable8Bit(tile,
                                                EVERYTHING,
                                                patternRegion,
                                                overflow);
        ColorSpace destCS = destCM.getColorSpace();
        if (destCS == ColorSpace.getInstance(ColorSpace.CS_sRGB))
            tileRable.setColorSpaceLinear(false);
        else if (destCS == ColorSpace.getInstance(ColorSpace.CS_LINEAR_RGB))
            tileRable.setColorSpaceLinear(true);

        RenderContext rc = new RenderContext(usr2dev,  EVERYTHING, hints);
        tiled = tileRable.createRendering(rc);
        // System.out.println("tileRed: " + tiled);
        // org.apache.flex.forks.batik.test.gvt.ImageDisplay.showImage("Tiled: ", tiled);

        //System.out.println("Created rendering");
        if(tiled != null) {
            Rectangle2D devRgn = usr2dev.createTransformedShape
                (patternRegion).getBounds();
            if ((devRgn.getWidth() > 128) ||
                (devRgn.getHeight() > 128))
                tiled = new TileCacheRed(GraphicsUtil.wrap(tiled), 256, 64);
        } else {
            //System.out.println("Tile was null");
            rasterCM = ColorModel.getRGBdefault();
            WritableRaster wr;
            wr = rasterCM.createCompatibleWritableRaster(32, 32);
            tiled = GraphicsUtil.wrap
                (new BufferedImage(rasterCM, wr, false, null));
            return;
        }

        rasterCM = tiled.getColorModel();
        if (rasterCM.hasAlpha()) {
            if (destCM.hasAlpha()) 
                rasterCM = GraphicsUtil.coerceColorModel
                    (rasterCM, destCM.isAlphaPremultiplied());
            else 
                rasterCM = GraphicsUtil.coerceColorModel(rasterCM, false);
        }
    }

    public void dispose(){
        raster = null;
    }

    public ColorModel getColorModel(){
        return rasterCM;
    }

    public Raster getRaster(int x, int y, int width, int height){

        // System.out.println("GetRaster: [" + x + ", " + y + ", " 
        //                    + width + ", " + height + "]");
        if ((raster == null)             ||
            (raster.getWidth() < width)  ||
            (raster.getHeight() < height)) {
            raster = rasterCM.createCompatibleWritableRaster(width, height);
        }

        WritableRaster wr
            = raster.createWritableChild(0, 0, width, height, x, y, null);

        tiled.copyData(wr);
        GraphicsUtil.coerceData(wr, tiled.getColorModel(), 
                                rasterCM.isAlphaPremultiplied());

        // On Mac OS X it always wants the raster at 0,0 if the
        // requested width and height matches raster we can just
        // return it.  Otherwise we create a translated child that
        // lives at 0,0.
        if ((raster.getWidth()  == width) &&
            (raster.getHeight() == height))
            return raster;

        return wr.createTranslatedChild(0,0);
    }
}
