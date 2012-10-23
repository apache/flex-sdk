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
package org.apache.flex.forks.batik.dom.svg;

import org.w3c.dom.DOMException;
import org.w3c.dom.svg.SVGMatrix;
import org.w3c.dom.svg.SVGPoint;

/**
 * An implementation of {@link SVGPoint} that is not associated with any
 * attribute.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMPoint.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SVGOMPoint implements SVGPoint {

    /**
     * The x coordinate.
     */
    protected float x;
    
    /**
     * The y coordinate.
     */
    protected float y;

    /**
     * Creates a new SVGOMPoint with coordinates set to <code>0</code>.
     */
    public SVGOMPoint() {
    }

    /**
     * Creates a new SVGOMPoint with coordinates set to the specified values.
     */
    public SVGOMPoint(float x, float y) {
        this.x = x;
        this.y = y;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGPoint#getX()}.
     */
    public float getX() {
        return x;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGPoint#setX(float)}.
     */
    public void setX(float x) throws DOMException {
        this.x = x;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGPoint#getY()}.
     */
    public float getY() {
        return y;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGPoint#setY(float)}.
     */
    public void setY(float y) throws DOMException {
        this.y = y;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGPoint#matrixTransform(SVGMatrix)}.
     */
    public SVGPoint matrixTransform(SVGMatrix matrix) {
        return matrixTransform(this, matrix);
    }

    /**
     * Transforms an {@link SVGPoint} by an {@link SVGMatrix} and returns
     * the new point.
     */
    public static SVGPoint matrixTransform(SVGPoint point, SVGMatrix matrix) {
        float newX = matrix.getA() * point.getX() + matrix.getC() * point.getY()
            + matrix.getE();
        float newY = matrix.getB() * point.getX() + matrix.getD() * point.getY()
            + matrix.getF();
        return new SVGOMPoint(newX, newY);
    }
}
