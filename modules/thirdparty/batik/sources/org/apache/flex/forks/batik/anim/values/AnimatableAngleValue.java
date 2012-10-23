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

import org.apache.flex.forks.batik.dom.anim.AnimationTarget;

import org.w3c.dom.svg.SVGAngle;

/**
 * An SVG angle value in the animation system.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: AnimatableAngleValue.java 532986 2007-04-27 06:30:58Z cam $
 */
public class AnimatableAngleValue extends AnimatableNumberValue {

    /**
     * The unit string representations.
     */
    protected static final String[] UNITS = {
        "", "", "deg", "rad", "grad"
    };

    /**
     * The angle unit.
     */
    protected short unit;

    /**
     * Creates a new, uninitialized AnimatableAngleValue.
     */
    public AnimatableAngleValue(AnimationTarget target) {
        super(target);
    }

    /**
     * Creates a new AnimatableAngleValue.
     */
    public AnimatableAngleValue(AnimationTarget target, float v, short unit) {
        super(target, v);
        this.unit = unit;
    }

    /**
     * Performs interpolation to the given value.
     */
    public AnimatableValue interpolate(AnimatableValue result,
                                       AnimatableValue to,
                                       float interpolation,
                                       AnimatableValue accumulation,
                                       int multiplier) {
        AnimatableAngleValue res;
        if (result == null) {
            res = new AnimatableAngleValue(target);
        } else {
            res = (AnimatableAngleValue) result;
        }

        float v = value;
        short u = unit;
        if (to != null) {
            AnimatableAngleValue toAngle = (AnimatableAngleValue) to;
            if (toAngle.unit != u) {
                v = rad(v, u);
                v += interpolation * (rad(toAngle.value, toAngle.unit) - v);
                u = SVGAngle.SVG_ANGLETYPE_RAD;
            } else {
                v += interpolation * (toAngle.value - v);
            }
        }
        if (accumulation != null) {
            AnimatableAngleValue accAngle = (AnimatableAngleValue) accumulation;
            if (accAngle.unit != u) {
                v += multiplier * rad(accAngle.value, accAngle.unit);
                u = SVGAngle.SVG_ANGLETYPE_RAD;
            } else {
                v += multiplier * accAngle.value;
            }
        }

        if (res.value != v || res.unit != u) {
            res.value = v;
            res.unit = u;
            res.hasChanged = true;
        }
        return res;
    }

    /**
     * Returns the angle unit.
     */
    public short getUnit() {
        return unit;
    }

    /**
     * Returns the absolute distance between this value and the specified other
     * value.
     */
    public float distanceTo(AnimatableValue other) {
        AnimatableAngleValue o = (AnimatableAngleValue) other;
        return Math.abs(rad(value, unit) - rad(o.value, o.unit));
    }

    /**
     * Returns a zero value of this AnimatableValue's type.
     */
    public AnimatableValue getZeroValue() {
        return new AnimatableAngleValue
            (target, 0, SVGAngle.SVG_ANGLETYPE_UNSPECIFIED);
    }

    /**
     * Returns the CSS text representation of the value.
     */
    public String getCssText() {
        return super.getCssText() + UNITS[unit];
    }

    /**
     * Converts an angle value to radians.
     */
    public static float rad(float v, short unit) {
        switch (unit) {
            case SVGAngle.SVG_ANGLETYPE_RAD:
                return v;
            case SVGAngle.SVG_ANGLETYPE_GRAD:
                return (float) Math.PI * v / 200;
            default:
                return (float) Math.PI * v / 180;
        }
    }
}
