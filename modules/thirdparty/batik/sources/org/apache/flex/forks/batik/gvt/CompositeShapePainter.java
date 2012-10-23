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

import java.awt.Graphics2D;
import java.awt.Shape;
import java.awt.geom.Area;
import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;

/**
 * A shape painter which consists of multiple shape painters.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: CompositeShapePainter.java 479564 2006-11-27 09:56:57Z dvholten $
 */
public class CompositeShapePainter implements ShapePainter {

    /**
     * The shape associated with this painter
     */
    protected Shape shape;

    /**
     * The enclosed <tt>ShapePainter</tt>s of this composite shape painter.
     */
    protected ShapePainter [] painters;

    /**
     * The number of shape painter.
     */
    protected int count;

    /**
     * Constructs a new empty <tt>CompositeShapePainter</tt>.
     */
    public CompositeShapePainter(Shape shape) {
        if (shape == null) {
            throw new IllegalArgumentException();
        }
        this.shape = shape;
    }

    /**
     * Adds the specified shape painter to the shape painter..
     *
     * @param shapePainter the shape painter to add
     */
    public void addShapePainter(ShapePainter shapePainter) {
        if (shapePainter == null) {
            return;
        }
        if (shape != shapePainter.getShape()) {
            shapePainter.setShape(shape);
        }
        if (painters == null) {
            painters = new ShapePainter[2];
        }
        if (count == painters.length) {
            ShapePainter [] newPainters = new ShapePainter[ count + count/2 + 1];
            System.arraycopy(painters, 0, newPainters, 0, count);
            painters = newPainters;
        }
        painters[count++] = shapePainter;
    }

    /**
     * Sets to the specified index, the specified ShapePainter.
     *
     * @param index the index where to set the ShapePainter
     * @param shapePainter the ShapePainter to set
     */
    /*    public void setShapePainter(int index, ShapePainter shapePainter) {
        if (shapePainter == null) {
            return;
        }
        if (this.shape != shapePainter.getShape()) {
            shapePainter.setShape(shape);
        }
        if (painters == null || index >= painters.length) {
            throw new IllegalArgumentException("Bad index: "+index);
        }
        painters[index] = shapePainter;
        }*/

    /**
     * Returns the shape painter at the specified index.
     *
     * @param index the index of the shape painter to return
     */
    public ShapePainter getShapePainter(int index) {
        return painters[index];
    }

    /**
     * Returns the number of shape painter of this composite shape painter.
     */
    public int getShapePainterCount() {
        return count;
    }

    /**
     * Paints the specified shape using the specified Graphics2D.
     *
     * @param g2d the Graphics2D to use
     */
    public void paint(Graphics2D g2d) {
        if (painters != null) {
            for (int i=0; i < count; ++i) {
                painters[i].paint(g2d);
            }
        }
    }

    /**
     * Returns the area painted by this shape painter.
     */
    public Shape getPaintedArea(){
        if (painters == null)
            return null;
        Area paintedArea = new Area();
        for (int i=0; i < count; ++i) {
            Shape s = painters[i].getPaintedArea();
            if (s != null) {
                paintedArea.add(new Area(s));
            }
        }
        return paintedArea;
    }

    /**
     * Returns the bounds of the area painted by this shape painter
     */
    public Rectangle2D getPaintedBounds2D(){
        if (painters == null)
            return null;

        Rectangle2D bounds = null;
        for (int i=0; i < count; ++i) {
            Rectangle2D pb = painters[i].getPaintedBounds2D();
            if (pb == null) continue;
            if (bounds == null) bounds = (Rectangle2D)pb.clone();
            else                bounds.add(pb);
        }
        return bounds;
    }

    /**
     * Returns true if pt is in the area painted by this shape painter
     */
    public boolean inPaintedArea(Point2D pt){
        if (painters == null)
            return false;
        for (int i=0; i < count; ++i) {
            if (painters[i].inPaintedArea(pt))
                return true;
        }
        return false;
    }

    /**
     * Returns the area covered by this shape painter (even if nothing
     * is painted there).
     */
    public Shape getSensitiveArea() {
        if (painters == null)
            return null;
        Area paintedArea = new Area();
        for (int i=0; i < count; ++i) {
            Shape s = painters[i].getSensitiveArea();
            if (s != null) {
                paintedArea.add(new Area(s));
            }
        }
        return paintedArea;
    }

    /**
     * Returns the bounds of the area painted by this shape painter
     */
    public Rectangle2D getSensitiveBounds2D() {
        if (painters == null)
            return null;

        Rectangle2D bounds = null;
        for (int i=0; i < count; ++i) {
            Rectangle2D pb = painters[i].getSensitiveBounds2D();
            if (bounds == null) bounds = (Rectangle2D)pb.clone();
            else                bounds.add(pb);
        }
        return bounds;
    }

    /**
     * Returns true if pt is in the area painted by this shape painter
     */
    public boolean inSensitiveArea(Point2D pt){
        if (painters == null)
            return false;
        for (int i=0; i < count; ++i) {
            if (painters[i].inSensitiveArea(pt))
                return true;
        }
        return false;
    }

    /**
     * Sets the Shape this shape painter is associated with.
     *
     * @param shape new shape this painter should be associated with.
     * Should not be null.
     */
    public void setShape(Shape shape){
        if (shape == null) {
            throw new IllegalArgumentException();
        }
        if (painters != null) {
            for (int i=0; i < count; ++i) {
                painters[i].setShape(shape);
            }
        }
        this.shape = shape;
    }

    /**
     * Gets the Shape this shape painter is associated with.
     *
     * @return shape associated with this painter
     */
    public Shape getShape(){
        return shape;
    }
}
