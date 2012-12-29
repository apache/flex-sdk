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
package org.apache.flex.forks.batik.anim.values;

import java.util.Iterator;
import java.util.Vector;
import java.util.List;

import org.apache.flex.forks.batik.dom.anim.AnimationTarget;
import org.apache.flex.forks.batik.dom.svg.AbstractSVGTransform;
import org.apache.flex.forks.batik.dom.svg.SVGOMTransform;

import org.w3c.dom.svg.SVGMatrix;
import org.w3c.dom.svg.SVGTransform;

/**
 * An SVG transform list value in the animation system.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: AnimatableTransformListValue.java 515307 2007-03-06 21:15:58Z cam $
 */
public class AnimatableTransformListValue extends AnimatableValue {

    /**
     * Identity transform value of type 'skewX'.
     */
    protected static SVGOMTransform IDENTITY_SKEWX = new SVGOMTransform();

    /**
     * Identity transform value of type 'skewY'.
     */
    protected static SVGOMTransform IDENTITY_SKEWY = new SVGOMTransform();

    /**
     * Identity transform value of type 'scale'.
     */
    protected static SVGOMTransform IDENTITY_SCALE = new SVGOMTransform();

    /**
     * Identity transform value of type 'rotate'.
     */
    protected static SVGOMTransform IDENTITY_ROTATE = new SVGOMTransform();

    /**
     * Identity transform value of type 'translate'.
     */
    protected static SVGOMTransform IDENTITY_TRANSLATE = new SVGOMTransform();

    static {
        IDENTITY_SKEWX.setSkewX(0f);
        IDENTITY_SKEWY.setSkewY(0f);
        IDENTITY_SCALE.setScale(0f, 0f);
        IDENTITY_ROTATE.setRotate(0f, 0f, 0f);
        IDENTITY_TRANSLATE.setTranslate(0f, 0f);
    }

    /**
     * List of transforms.
     */
    protected Vector transforms;

    /**
     * Creates a new, uninitialized AnimatableTransformListValue.
     */
    protected AnimatableTransformListValue(AnimationTarget target) {
        super(target);
    }

    /**
     * Creates a new AnimatableTransformListValue with a single transform.
     */
    public AnimatableTransformListValue(AnimationTarget target,
                                        AbstractSVGTransform t) {
        super(target);
        this.transforms = new Vector();
        this.transforms.add(t);
    }

    /**
     * Creates a new AnimatableTransformListValue with a transform list.
     */
    public AnimatableTransformListValue(AnimationTarget target,
                                        List transforms) {
        super(target);

        this.transforms = new Vector( transforms );

    }

    /**
     * Performs interpolation to the given value.
     */
    public AnimatableValue interpolate(AnimatableValue result,
                                       AnimatableValue to,
                                       float interpolation,
                                       AnimatableValue accumulation,
                                       int multiplier) {

        AnimatableTransformListValue toTransformList =
            (AnimatableTransformListValue) to;
        AnimatableTransformListValue accTransformList =
            (AnimatableTransformListValue) accumulation;

        int accSize = accumulation == null ? 0 : accTransformList.transforms.size();
        int newSize = transforms.size() + accSize * multiplier;

        AnimatableTransformListValue res;
        if (result == null) {
            res = new AnimatableTransformListValue(target);
            res.transforms = new Vector(newSize);
            res.transforms.setSize(newSize);
        } else {
            res = (AnimatableTransformListValue) result;
            if (res.transforms == null) {
                res.transforms = new Vector(newSize);
                res.transforms.setSize(newSize);
            } else if (res.transforms.size() != newSize) {
                res.transforms.setSize(newSize);
            }
        }

        int index = 0;
        for (int j = 0; j < multiplier; j++) {
            for (int i = 0; i < accSize; i++, index++) {
                res.transforms.setElementAt
                    (accTransformList.transforms.elementAt(i), index);
            }
        }
        for (int i = 0; i < transforms.size() - 1; i++, index++) {
            res.transforms.setElementAt(transforms.elementAt(i), index);
        }

        if (to != null) {
            AbstractSVGTransform tt =
                (AbstractSVGTransform) toTransformList.transforms.lastElement();
            AbstractSVGTransform ft = null;
            int type;
            if (transforms.isEmpty()) {
                // For the case of an additive animation with an underlying
                // transform list of zero elements.
                type = tt.getType();
                switch (type) {
                    case SVGTransform.SVG_TRANSFORM_SKEWX:
                        ft = IDENTITY_SKEWX;
                        break;
                    case SVGTransform.SVG_TRANSFORM_SKEWY:
                        ft = IDENTITY_SKEWY;
                        break;
                    case SVGTransform.SVG_TRANSFORM_SCALE:
                        ft = IDENTITY_SCALE;
                        break;
                    case SVGTransform.SVG_TRANSFORM_ROTATE:
                        ft = IDENTITY_ROTATE;
                        break;
                    case SVGTransform.SVG_TRANSFORM_TRANSLATE:
                        ft = IDENTITY_TRANSLATE;
                        break;
                }
            } else {
                ft = (AbstractSVGTransform) transforms.lastElement();
                type = ft.getType();
            }
            if (type == tt.getType()) {
                AbstractSVGTransform t;
                if (res.transforms.isEmpty()) {
                    t = new SVGOMTransform();
                    res.transforms.add(t);
                } else {
                    t = (AbstractSVGTransform) res.transforms.elementAt(index);
                    if (t == null) {
                        t = new SVGOMTransform();
                        res.transforms.setElementAt(t, index);
                    }
                }
                float x, y, r = 0;
                switch (type) {
                    case SVGTransform.SVG_TRANSFORM_SKEWX:
                    case SVGTransform.SVG_TRANSFORM_SKEWY:
                        r = ft.getAngle();
                        r += interpolation * (tt.getAngle() - r);
                        if (type == SVGTransform.SVG_TRANSFORM_SKEWX) {
                            t.setSkewX(r);
                        } else if (type == SVGTransform.SVG_TRANSFORM_SKEWY) {
                            t.setSkewY(r);
                        }
                        break;
                    case SVGTransform.SVG_TRANSFORM_SCALE: {
                        SVGMatrix fm = ft.getMatrix();
                        SVGMatrix tm = tt.getMatrix();
                        x = fm.getA();
                        y = fm.getD();
                        x += interpolation * (tm.getA() - x);
                        y += interpolation * (tm.getD() - y);
                        t.setScale(x, y);
                        break;
                    }
                    case SVGTransform.SVG_TRANSFORM_ROTATE: {
                        x = ft.getX();
                        y = ft.getY();
                        x += interpolation * (tt.getX() - x);
                        y += interpolation * (tt.getY() - y);
                        r = ft.getAngle();
                        r += interpolation * (tt.getAngle() - r);
                        t.setRotate(r, x, y);
                        break;
                    }
                    case SVGTransform.SVG_TRANSFORM_TRANSLATE: {
                        SVGMatrix fm = ft.getMatrix();
                        SVGMatrix tm = tt.getMatrix();
                        x = fm.getE();
                        y = fm.getF();
                        x += interpolation * (tm.getE() - x);
                        y += interpolation * (tm.getF() - y);
                        t.setTranslate(x, y);
                        break;
                    }
                }
            }
        } else {
            AbstractSVGTransform ft =
                (AbstractSVGTransform) transforms.lastElement();
            AbstractSVGTransform t =
                (AbstractSVGTransform) res.transforms.elementAt(index);
            if (t == null) {
                t = new SVGOMTransform();
                res.transforms.setElementAt(t, index);
            }
            t.assign(ft);
        }

        // XXX Do better checking for changes.
        res.hasChanged = true;

        return res;
    }

    /**
     * Performs a two-way interpolation between the specified values.
     * value[12] and to[12] must all be of the same type, either scale or
     * translation transforms, or all null.
     */
    public static AnimatableTransformListValue interpolate
            (AnimatableTransformListValue res,
             AnimatableTransformListValue value1,
             AnimatableTransformListValue value2,
             AnimatableTransformListValue to1,
             AnimatableTransformListValue to2,
             float interpolation1,
             float interpolation2,
             AnimatableTransformListValue accumulation,
             int multiplier) {

        int accSize = accumulation == null ? 0 : accumulation.transforms.size();
        int newSize = accSize * multiplier + 1;

        if (res == null) {
            res = new AnimatableTransformListValue(to1.target);
            res.transforms = new Vector(newSize);
            res.transforms.setSize(newSize);
        } else {
            if (res.transforms == null) {
                res.transforms = new Vector(newSize);
                res.transforms.setSize(newSize);
            } else if (res.transforms.size() != newSize) {
                res.transforms.setSize(newSize);
            }
        }

        int index = 0;
        for (int j = 0; j < multiplier; j++) {
            for (int i = 0; i < accSize; i++, index++) {
                res.transforms.setElementAt
                    (accumulation.transforms.elementAt(i), index);
            }
        }

        AbstractSVGTransform ft1 =
            (AbstractSVGTransform) value1.transforms.lastElement();
        AbstractSVGTransform ft2 =
            (AbstractSVGTransform) value2.transforms.lastElement();

        AbstractSVGTransform t =
            (AbstractSVGTransform) res.transforms.elementAt(index);
        if (t == null) {
            t = new SVGOMTransform();
            res.transforms.setElementAt(t, index);
        }

        int type = ft1.getType();

        float x, y;
        if (type == SVGTransform.SVG_TRANSFORM_SCALE) {
            x = ft1.getMatrix().getA();
            y = ft2.getMatrix().getD();
        } else {
            x = ft1.getMatrix().getE();
            y = ft2.getMatrix().getF();
        }

        if (to1 != null) {
            AbstractSVGTransform tt1 =
                (AbstractSVGTransform) to1.transforms.lastElement();
            AbstractSVGTransform tt2 =
                (AbstractSVGTransform) to2.transforms.lastElement();

            if (type == SVGTransform.SVG_TRANSFORM_SCALE) {
                x += interpolation1 * (tt1.getMatrix().getA() - x);
                y += interpolation2 * (tt2.getMatrix().getD() - y);
            } else {
                x += interpolation1 * (tt1.getMatrix().getE() - x);
                y += interpolation2 * (tt2.getMatrix().getF() - y);
            }
        }

        if (type == SVGTransform.SVG_TRANSFORM_SCALE) {
            t.setScale(x, y);
        } else {
            t.setTranslate(x, y);
        }

        // XXX Do better checking for changes.
        res.hasChanged = true;

        return res;
    }

    /**
     * Performs a three-way interpolation between the specified values.
     * value[123] and to[123] must all be single rotation transforms,
     * or all null.
     */
    public static AnimatableTransformListValue interpolate
            (AnimatableTransformListValue res,
             AnimatableTransformListValue value1,
             AnimatableTransformListValue value2,
             AnimatableTransformListValue value3,
             AnimatableTransformListValue to1,
             AnimatableTransformListValue to2,
             AnimatableTransformListValue to3,
             float interpolation1,
             float interpolation2,
             float interpolation3,
             AnimatableTransformListValue accumulation,
             int multiplier) {

        int accSize = accumulation == null ? 0 : accumulation.transforms.size();
        int newSize = accSize * multiplier + 1;

        if (res == null) {
            res = new AnimatableTransformListValue(to1.target);
            res.transforms = new Vector(newSize);
            res.transforms.setSize(newSize);
        } else {
            if (res.transforms == null) {
                res.transforms = new Vector(newSize);
                res.transforms.setSize(newSize);
            } else if (res.transforms.size() != newSize) {
                res.transforms.setSize(newSize);
            }
        }

        int index = 0;
        for (int j = 0; j < multiplier; j++) {
            for (int i = 0; i < accSize; i++, index++) {
                res.transforms.setElementAt
                    (accumulation.transforms.elementAt(i), index);
            }
        }

        AbstractSVGTransform ft1 =
            (AbstractSVGTransform) value1.transforms.lastElement();
        AbstractSVGTransform ft2 =
            (AbstractSVGTransform) value2.transforms.lastElement();
        AbstractSVGTransform ft3 =
            (AbstractSVGTransform) value3.transforms.lastElement();

        AbstractSVGTransform t =
            (AbstractSVGTransform) res.transforms.elementAt(index);
        if (t == null) {
            t = new SVGOMTransform();
            res.transforms.setElementAt(t, index);
        }

        float x, y, r;
        r = ft1.getAngle();
        x = ft2.getX();
        y = ft3.getY();

        if (to1 != null) {
            AbstractSVGTransform tt1 =
                (AbstractSVGTransform) to1.transforms.lastElement();
            AbstractSVGTransform tt2 =
                (AbstractSVGTransform) to2.transforms.lastElement();
            AbstractSVGTransform tt3 =
                (AbstractSVGTransform) to3.transforms.lastElement();

            r += interpolation1 * (tt1.getAngle() - r);
            x += interpolation2 * (tt2.getX() - x);
            y += interpolation3 * (tt3.getY() - y);
        }
        t.setRotate(r, x, y);

        // XXX Do better checking for changes.
        res.hasChanged = true;

        return res;
    }

    /**
     * Gets the transforms.
     */
    public Iterator getTransforms() {
        return transforms.iterator();
    }

    /**
     * Returns whether two values of this type can have their distance
     * computed, as needed by paced animation.
     */
    public boolean canPace() {
        return true;
    }

    /**
     * Returns the absolute distance between this value and the specified other
     * value.
     */
    public float distanceTo(AnimatableValue other) {
        AnimatableTransformListValue o = (AnimatableTransformListValue) other;
        if (transforms.isEmpty() || o.transforms.isEmpty()) {
            return 0f;
        }
        AbstractSVGTransform t1 = (AbstractSVGTransform) transforms.lastElement();
        AbstractSVGTransform t2 = (AbstractSVGTransform) o.transforms.lastElement();
        short type1 = t1.getType();
        if (type1 != t2.getType()) {
            return 0f;
        }
        SVGMatrix m1 = t1.getMatrix();
        SVGMatrix m2 = t2.getMatrix();
        switch (type1) {
            case SVGTransform.SVG_TRANSFORM_TRANSLATE:
                return Math.abs(m1.getE() - m2.getE()) + Math.abs(m1.getF() - m2.getF());
            case SVGTransform.SVG_TRANSFORM_SCALE:
                return Math.abs(m1.getA() - m2.getA()) + Math.abs(m1.getD() - m2.getD());
            case SVGTransform.SVG_TRANSFORM_ROTATE:
            case SVGTransform.SVG_TRANSFORM_SKEWX:
            case SVGTransform.SVG_TRANSFORM_SKEWY:
                return Math.abs(t1.getAngle() - t2.getAngle());
        }
        return 0f;
    }

    /**
     * Returns the distance between this value's first component and the
     * specified other value's first component.
     */
    public float distanceTo1(AnimatableValue other) {
        AnimatableTransformListValue o = (AnimatableTransformListValue) other;
        if (transforms.isEmpty() || o.transforms.isEmpty()) {
            return 0f;
        }
        AbstractSVGTransform t1 = (AbstractSVGTransform) transforms.lastElement();
        AbstractSVGTransform t2 = (AbstractSVGTransform) o.transforms.lastElement();
        short type1 = t1.getType();
        if (type1 != t2.getType()) {
            return 0f;
        }
        SVGMatrix m1 = t1.getMatrix();
        SVGMatrix m2 = t2.getMatrix();
        switch (type1) {
            case SVGTransform.SVG_TRANSFORM_TRANSLATE:
                return Math.abs(m1.getE() - m2.getE());
            case SVGTransform.SVG_TRANSFORM_SCALE:
                return Math.abs(m1.getA() - m2.getA());
            case SVGTransform.SVG_TRANSFORM_ROTATE:
            case SVGTransform.SVG_TRANSFORM_SKEWX:
            case SVGTransform.SVG_TRANSFORM_SKEWY:
                return Math.abs(t1.getAngle() - t2.getAngle());
        }
        return 0f;
    }

    /**
     * Returns the distance between this value's second component and the
     * specified other value's second component.
     */
    public float distanceTo2(AnimatableValue other) {
        AnimatableTransformListValue o = (AnimatableTransformListValue) other;
        if (transforms.isEmpty() || o.transforms.isEmpty()) {
            return 0f;
        }
        AbstractSVGTransform t1 = (AbstractSVGTransform) transforms.lastElement();
        AbstractSVGTransform t2 = (AbstractSVGTransform) o.transforms.lastElement();
        short type1 = t1.getType();
        if (type1 != t2.getType()) {
            return 0f;
        }
        SVGMatrix m1 = t1.getMatrix();
        SVGMatrix m2 = t2.getMatrix();
        switch (type1) {
            case SVGTransform.SVG_TRANSFORM_TRANSLATE:
                return Math.abs(m1.getF() - m2.getF());
            case SVGTransform.SVG_TRANSFORM_SCALE:
                return Math.abs(m1.getD() - m2.getD());
            case SVGTransform.SVG_TRANSFORM_ROTATE:
                return Math.abs(t1.getX() - t2.getX());
        }
        return 0f;
    }

    /**
     * Returns the distance between this value's third component and the
     * specified other value's third component.
     */
    public float distanceTo3(AnimatableValue other) {
        AnimatableTransformListValue o = (AnimatableTransformListValue) other;
        if (transforms.isEmpty() || o.transforms.isEmpty()) {
            return 0f;
        }
        AbstractSVGTransform t1 = (AbstractSVGTransform) transforms.lastElement();
        AbstractSVGTransform t2 = (AbstractSVGTransform) o.transforms.lastElement();
        short type1 = t1.getType();
        if (type1 != t2.getType()) {
            return 0f;
        }
        if (type1 == SVGTransform.SVG_TRANSFORM_ROTATE) {
            return Math.abs(t1.getY() - t2.getY());
        }
        return 0f;
    }

    /**
     * Returns a zero value of this AnimatableValue's type.  This returns an
     * empty transform list.
     */
    public AnimatableValue getZeroValue() {
        return new AnimatableTransformListValue(target, new Vector(5));
    }

    /**
     * Returns the CSS text representation of the value.
     */
    public String toStringRep() {
        StringBuffer sb = new StringBuffer();
        Iterator i = transforms.iterator();
        while (i.hasNext()) {
            AbstractSVGTransform t = (AbstractSVGTransform) i.next();
            if (t == null) {
                sb.append("null");
            } else {
                SVGMatrix m = t.getMatrix();
                switch (t.getType()) {
                    case SVGTransform.SVG_TRANSFORM_TRANSLATE:
                        sb.append("translate(");
                        sb.append(m.getE());
                        sb.append(',');
                        sb.append(m.getF());
                        sb.append(')');
                        break;
                    case SVGTransform.SVG_TRANSFORM_SCALE:
                        sb.append("scale(");
                        sb.append(m.getA());
                        sb.append(',');
                        sb.append(m.getD());
                        sb.append(')');
                        break;
                    case SVGTransform.SVG_TRANSFORM_SKEWX:
                        sb.append("skewX(");
                        sb.append(t.getAngle());
                        sb.append(')');
                        break;
                    case SVGTransform.SVG_TRANSFORM_SKEWY:
                        sb.append("skewY(");
                        sb.append(t.getAngle());
                        sb.append(')');
                        break;
                    case SVGTransform.SVG_TRANSFORM_ROTATE:
                        sb.append("rotate(");
                        sb.append(t.getAngle());
                        sb.append(',');
                        sb.append(t.getX());
                        sb.append(',');
                        sb.append(t.getY());
                        sb.append(')');
                        break;
                }
            }
            if (i.hasNext()) {
                sb.append(' ');
            }
        }
        return sb.toString();
    }
}
