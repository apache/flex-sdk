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
 * An SVG angle-or-identifier value in the animation system.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: AnimatableAngleOrIdentValue.java 475477 2006-11-15 22:44:28Z cam $
 */
public class AnimatableAngleOrIdentValue extends AnimatableAngleValue {

    /**
     * Whether this value is an identifier.
     */
    protected boolean isIdent;
    
    /**
     * The identifier.
     */
    protected String ident;
    
    /**
     * Creates a new, uninitialized AnimatableAngleOrIdentValue.
     */
    protected AnimatableAngleOrIdentValue(AnimationTarget target) {
        super(target);
    }
    
    /**
     * Creates a new AnimatableAngleOrIdentValue for an angle value.
     */
    public AnimatableAngleOrIdentValue(AnimationTarget target, float v, short unit) {
        super(target, v, unit);
    }

    /**
     * Creates a new AnimatableAngleOrIdentValue for an identifier value.
     */
    public AnimatableAngleOrIdentValue(AnimationTarget target, String ident) {
        super(target);
        this.ident = ident;
        this.isIdent = true;
    }

    /**
     * Returns whether the value is an identifier.
     */
    public boolean isIdent() {
        return isIdent;
    }

    /**
     * Returns the identifiers.
     */
    public String getIdent() {
        return ident;
    }

    /**
     * Returns whether two values of this type can have their distance
     * computed, as needed by paced animation.
     */
    public boolean canPace() {
        return false;
    }

    /**
     * Returns the absolute distance between this value and the specified other
     * value.
     */
    public float distanceTo(AnimatableValue other) {
        return 0f;
    }

    /**
     * Returns a zero value of this AnimatableValue's type.
     */
    public AnimatableValue getZeroValue() {
        return new AnimatableAngleOrIdentValue
            (target, 0, SVGAngle.SVG_ANGLETYPE_UNSPECIFIED);
    }

    /**
     * Returns the CSS text representation of the value.
     */
    public String getCssText() {
        if (isIdent) {
            return ident;
        }
        return super.getCssText();
    }

    /**
     * Performs interpolation to the given value.
     */
    public AnimatableValue interpolate(AnimatableValue result,
                                       AnimatableValue to, float interpolation,
                                       AnimatableValue accumulation,
                                       int multiplier) {
        AnimatableAngleOrIdentValue res;
        if (result == null) {
            res = new AnimatableAngleOrIdentValue(target);
        } else {
            res = (AnimatableAngleOrIdentValue) result;
        }

        if (to == null) {
            if (isIdent) {
                res.hasChanged = !res.isIdent || !res.ident.equals(ident);
                res.ident = ident;
                res.isIdent = true;
            } else {
                short oldUnit = res.unit;
                float oldValue = res.value;
                super.interpolate(res, to, interpolation, accumulation,
                                  multiplier);
                if (res.unit != oldUnit || res.value != oldValue) {
                    res.hasChanged = true;
                }
            }
        } else {
            AnimatableAngleOrIdentValue toValue
                = (AnimatableAngleOrIdentValue) to;
            if (isIdent || toValue.isIdent) {
                if (interpolation >= 0.5) {
                    if (res.isIdent != toValue.isIdent
                            || res.unit != toValue.unit
                            || res.value != toValue.value
                            || res.isIdent && toValue.isIdent
                                && !toValue.ident.equals(ident)) {
                        res.isIdent = toValue.isIdent;
                        res.ident = toValue.ident;
                        res.unit = toValue.unit;
                        res.value = toValue.value;
                        res.hasChanged = true;
                    }
                } else {
                    if (res.isIdent != isIdent
                            || res.unit != unit
                            || res.value != value
                            || res.isIdent && isIdent
                                && !res.ident.equals(ident)) {
                        res.isIdent = isIdent;
                        res.ident = ident;
                        res.unit = unit;
                        res.value = value;
                        res.hasChanged = true;
                    }
                }
            } else {
                super.interpolate(res, to, interpolation, accumulation,
                                  multiplier);
            }
        }

        return res;
    }
}
