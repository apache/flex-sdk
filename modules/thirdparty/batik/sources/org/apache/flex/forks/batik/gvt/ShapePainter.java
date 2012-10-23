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
import java.awt.geom.Rectangle2D;
import java.awt.geom.Point2D;

/**
 * Renders the shape of a <tt>ShapeNode</tt>.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: ShapePainter.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface ShapePainter {

    /**
     * Paints the specified shape using the specified Graphics2D.
     *
     * @param g2d the Graphics2D to use
     */
    void paint(Graphics2D g2d);

    /**
     * Returns the area painted by this shape painter.
     */
    Shape getPaintedArea();

    /**
     * Returns the bounds of the area painted by this shape painter
     */
    Rectangle2D getPaintedBounds2D();

    /**
     * Returns true if <tt>pt</tt> is in the painted area.
     */
    boolean inPaintedArea(Point2D pt);

    /**
     * Returns the area covered by this shape painter (even if nothing
     * is painted there).
     */
    Shape getSensitiveArea();

    /**
     * Returns the bounds of the area covered by this shape painter
     * (even if nothing is painted there).
     */
    Rectangle2D getSensitiveBounds2D();

    /**
     * Returns true if <tt>pt</tt> is in the sensitive area.
     */
    boolean inSensitiveArea(Point2D pt);

    /**
     * Sets the Shape this shape painter is associated with.
     *
     * @param shape new shape this painter should be associated with.
     * Should not be null.  
     */
    void setShape(Shape shape);

    /**
     * Gets the shape this shape painter is associated with.
     *
     * @return shape associated with this painter
     */
    Shape getShape();
}
