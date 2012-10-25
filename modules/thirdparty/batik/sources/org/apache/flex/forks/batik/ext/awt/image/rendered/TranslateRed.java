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
import java.awt.image.Raster;
import java.awt.image.WritableRaster;

/**
 * This is a special case of an Affine that only contains integer
 * translations, this allows it to do it's work by simply changing
 * the coordinate system of the tiles.
 *
 * @author <a href="mailto:Thomas.DeWeeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: TranslateRed.java 478363 2006-11-22 23:01:13Z dvholten $
 */
public class TranslateRed extends AbstractRed {

    protected int deltaX;
    protected int deltaY;

    /**
     * Construct an instance of TranslateRed
     * @param xloc The new x coordinate of cr.getMinX().
     * @param yloc The new y coordinate of cr.getMinY().
     */
    public TranslateRed(CachableRed cr, int xloc, int yloc) {
        super(cr, new Rectangle(xloc,  yloc,
                                cr.getWidth(), cr.getHeight()),
              cr.getColorModel(), cr.getSampleModel(),
              cr.getTileGridXOffset()+xloc-cr.getMinX(),
              cr.getTileGridYOffset()+yloc-cr.getMinY(),
              null);
        deltaX = xloc-cr.getMinX();
        deltaY = yloc-cr.getMinY();
    }

    /**
     * The delata translation in x (absolute loc is available from getMinX())
     */
    public int getDeltaX() { return deltaX; }

    /**
     * The delata translation in y (absolute loc is available from getMinY())
     */
    public int getDeltaY() { return deltaY; }

    /**
     * fetch the source image for this node.
     */
    public CachableRed getSource() {
        return (CachableRed)getSources().get(0);
    }

    public Object getProperty(String name) {
        return getSource().getProperty(name);
    }

    public String [] getPropertyNames() {
        return getSource().getPropertyNames();
    }

    public Raster getTile(int tileX, int tileY) {
        Raster r = getSource().getTile(tileX, tileY);

        return r.createTranslatedChild(r.getMinX()+deltaX,
                                       r.getMinY()+deltaY);
    }

    public Raster getData() {
        Raster r = getSource().getData();
        return r.createTranslatedChild(r.getMinX()+deltaX,
                                       r.getMinY()+deltaY);
    }

    public Raster getData(Rectangle rect) {
        Rectangle r = (Rectangle)rect.clone();
        r.translate(-deltaX, -deltaY);
        Raster ret = getSource().getData(r);
        return ret.createTranslatedChild(ret.getMinX()+deltaX,
                                         ret.getMinY()+deltaY);
    }

    public WritableRaster copyData(WritableRaster wr) {
        WritableRaster wr2 = wr.createWritableTranslatedChild
            (wr.getMinX()-deltaX, wr.getMinY()-deltaY);

        getSource().copyData(wr2);

        return wr;
    }
}
