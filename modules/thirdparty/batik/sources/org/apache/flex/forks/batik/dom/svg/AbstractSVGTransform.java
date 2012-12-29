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

import java.awt.geom.AffineTransform;

import org.w3c.dom.svg.SVGMatrix;
import org.w3c.dom.svg.SVGTransform;

/**
 * Abstract implementation of {@link SVGTransform}.
 * 
 * @author nicolas.socheleau@bitflash.com
 * @version $Id: AbstractSVGTransform.java 475477 2006-11-15 22:44:28Z cam $
 */
public abstract class AbstractSVGTransform implements SVGTransform {

    /**
     * Type of the transformation.  Before any values are set, the type
     * is unknown.
     */
    protected short type = SVG_TRANSFORM_UNKNOWN;

    /**
     * The transformation as a Java2D {link AffineTransform}.
     */
    protected AffineTransform affineTransform;

    /**
     * The angle of the transformation, if this transformation is a rotation
     * or a skew.  This is stored to avoid extracting the angle from the
     * transformation matrix.
     */
    protected float angle;

    /**
     * The x coordinate of the center of the rotation, if this transformation
     * is a rotation.
     */
    protected float x;

    /**
     * The y coordinate of the center of the rotation, if this transformation
     * is a rotation.
     */
    protected float y;

    /**
     * Creates and returns a new {@link SVGMatrix} for exposing the
     * transformation as a matrix.
     * @return SVGMatrix representing the transformation
     */
    protected abstract SVGMatrix createMatrix();

    /**
     * Sets the type of transformation.
     */
    protected void setType(short type) {
        this.type = type;
    }

    /**
     * Returns the x coordinate of the center of the rotation, if this
     * transformation is a rotation.
     */
    public float getX() {
        return x;
    }

    /**
     * Returns the y coordinate of the center of the rotation, if this
     * transformation is a rotation.
     */
    public float getY() {
        return y;
    }

    /**
     * Copies the value of the specified transformation into this object.
     */
    public void assign(AbstractSVGTransform t) {
        this.type = t.type;
        this.affineTransform = t.affineTransform;
        this.angle = t.angle;
        this.x = t.x;
        this.y = t.y;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGTransform#getType()}.
     */
    public short getType() {
        return type;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGTransform#getMatrix()}.
     */
    public SVGMatrix getMatrix() {
        return createMatrix();
    }

    /**
     * <b>DOM</b>: Implements {@link SVGTransform#getAngle()}.
     */
    public float getAngle() {
        return angle;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGTransform#setMatrix(SVGMatrix)}.
     */
    public void setMatrix(SVGMatrix matrix) {
        type = SVG_TRANSFORM_MATRIX;
        affineTransform =
            new AffineTransform(matrix.getA(), matrix.getB(), matrix.getC(),
                                matrix.getD(), matrix.getE(), matrix.getF());
    }

    /**
     * <b>DOM</b>: Implements {@link SVGTransform#setTranslate(float,float)}.
     */
    public void setTranslate(float tx, float ty) {
        type = SVG_TRANSFORM_TRANSLATE;
        affineTransform = AffineTransform.getTranslateInstance(tx, ty);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGTransform#setScale(float,float)}.
     */
    public void setScale(float sx, float sy) {
        type = SVG_TRANSFORM_SCALE;
        affineTransform = AffineTransform.getScaleInstance(sx, sy);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGTransform#setRotate(float,float,float)}.
     */
    public void setRotate(float angle, float cx, float cy) {
        type = SVG_TRANSFORM_ROTATE;
        affineTransform =
            AffineTransform.getRotateInstance(Math.toRadians(angle), cx, cy);
        this.angle = angle;
        this.x = cx;
        this.y = cy;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGTransform#setSkewX(float)}.
     */
    public void setSkewX(float angle) {
        type = SVG_TRANSFORM_SKEWX;
        affineTransform =
            AffineTransform.getShearInstance(Math.tan(Math.toRadians(angle)),
                                             0.0);
        this.angle = angle;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGTransform#setSkewY(float)}.
     */
    public void setSkewY(float angle) {
        type = SVG_TRANSFORM_SKEWY;
        affineTransform =
            AffineTransform.getShearInstance(0.0,
                                             Math.tan(Math.toRadians(angle)));
        this.angle = angle;
    }
}
