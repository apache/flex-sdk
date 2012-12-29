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
import java.awt.Shape;
import java.awt.image.BufferedImage;
import java.awt.image.ColorModel;
import java.awt.image.Raster;
import java.awt.image.RenderedImage;
import java.awt.image.SampleModel;
import java.awt.image.WritableRaster;
import java.util.Vector;


/**
 * This implements CachableRed around a RenderedImage.
 * You can use this to wrap a RenderedImage that you want to
 * appear as a CachableRed.
 * It essentially ignores the dependency and dirty region methods.
 *
 * @author <a href="mailto:Thomas.DeWeeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: RenderedImageCachableRed.java 478363 2006-11-22 23:01:13Z dvholten $
 */
public class RenderedImageCachableRed implements CachableRed {

    public static CachableRed wrap(RenderedImage ri) {
        if (ri instanceof CachableRed)
            return (CachableRed) ri;
        if (ri instanceof BufferedImage)
            return new BufferedImageCachableRed((BufferedImage)ri);
        return new RenderedImageCachableRed(ri);
    }

    private RenderedImage src;
    private Vector srcs = new Vector(0);

    public RenderedImageCachableRed(RenderedImage src) {
        if(src == null){
            throw new IllegalArgumentException();
        }
        this.src = src;
    }

    public Vector getSources() {
        return srcs; // should always be empty...
    }

    public Rectangle getBounds() { 
        return new Rectangle(getMinX(),    // could we cache the rectangle??
                             getMinY(),
                             getWidth(),
                             getHeight());
    }

    public int getMinX() {
        return src.getMinX();
    }
    public int getMinY() {
        return src.getMinY();
    }

    public int getWidth() {
        return src.getWidth();
    }
    public int getHeight() {
        return src.getHeight();
    }

    public ColorModel getColorModel() {
        return src.getColorModel();
    }

    public SampleModel getSampleModel() {
        return src.getSampleModel();
    }

    public int getMinTileX() {
        return src.getMinTileX();
    }
    public int getMinTileY() {
        return src.getMinTileY();
    }

    public int getNumXTiles() {
        return src.getNumXTiles();
    }
    public int getNumYTiles() {
        return src.getNumYTiles();
    }

    public int getTileGridXOffset() {
        return src.getTileGridXOffset();
    }

    public int getTileGridYOffset() {
        return src.getTileGridYOffset();
    }

    public int getTileWidth() {
        return src.getTileWidth();
    }
    public int getTileHeight() {
        return src.getTileHeight();
    }

    public Object getProperty(String name) {
        return src.getProperty(name);
    }

    public String[] getPropertyNames() {
        return src.getPropertyNames();
    }

    public Raster getTile(int tileX, int tileY) {
        return src.getTile(tileX, tileY);
    }

    public WritableRaster copyData(WritableRaster raster) {
        return src.copyData(raster);
    }

    public Raster getData() {
        return src.getData();
    }

    public Raster getData(Rectangle rect) {
        return src.getData(rect);
    }

    public Shape getDependencyRegion(int srcIndex, Rectangle outputRgn) {
        throw new IndexOutOfBoundsException
            ("Nonexistant source requested.");
    }

    public Shape getDirtyRegion(int srcIndex, Rectangle inputRgn) {
        throw new IndexOutOfBoundsException
            ("Nonexistant source requested.");
    }
}
