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

/**
 * A number-or-identifier value in the animation system.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: AnimatableNumberOrIdentValue.java 492528 2007-01-04 11:45:47Z cam $
 */
public class AnimatableNumberOrIdentValue extends AnimatableNumberValue {

    /**
     * Whether this value is an identifier.
     */
    protected boolean isIdent;
    
    /**
     * The identifier.
     */
    protected String ident;
    
    /**
     * Whether numbers should be considered as numeric keywords, as with the
     * font-weight property.
     */
    protected boolean numericIdent;

    /**
     * Creates a new, uninitialized AnimatableNumberOrIdentValue.
     */
    protected AnimatableNumberOrIdentValue(AnimationTarget target) {
        super(target);
    }
    
    /**
     * Creates a new AnimatableNumberOrIdentValue for a Number value.
     */
    public AnimatableNumberOrIdentValue(AnimationTarget target, float v,
                                        boolean numericIdent) {
        super(target, v);
        this.numericIdent = numericIdent;
    }

    /**
     * Creates a new AnimatableNumberOrIdentValue for an identifier value.
     */
    public AnimatableNumberOrIdentValue(AnimationTarget target, String ident) {
        super(target);
        this.ident = ident;
        this.isIdent = true;
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
        return new AnimatableNumberOrIdentValue(target, 0f, numericIdent);
    }

    /**
     * Returns the CSS text representation of the value.
     */
    public String getCssText() {
        if (isIdent) {
            return ident;
        }
        if (numericIdent) {
            return Integer.toString((int) value);
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
        AnimatableNumberOrIdentValue res;
        if (result == null) {
            res = new AnimatableNumberOrIdentValue(target);
        } else {
            res = (AnimatableNumberOrIdentValue) result;
        }
        
        if (to == null) {
            if (isIdent) {
                res.hasChanged = !res.isIdent || !res.ident.equals(ident);
                res.ident = ident;
                res.isIdent = true;
            } else if (numericIdent) {
                res.hasChanged = res.value != value || res.isIdent;
                res.value = value;
                res.isIdent = false;
                res.hasChanged = true;
                res.numericIdent = true;
            } else {
                float oldValue = res.value;
                super.interpolate(res, to, interpolation, accumulation,
                                  multiplier);
                res.numericIdent = false;
                if (res.value != oldValue) {
                    res.hasChanged = true;
                }
            }
        } else {
            AnimatableNumberOrIdentValue toValue
                = (AnimatableNumberOrIdentValue) to;
            if (isIdent || toValue.isIdent || numericIdent) {
                if (interpolation >= 0.5) {
                    if (res.isIdent != toValue.isIdent
                            || res.value != toValue.value
                            || res.isIdent && toValue.isIdent
                                && !toValue.ident.equals(ident)) {
                        res.isIdent = toValue.isIdent;
                        res.ident = toValue.ident;
                        res.value = toValue.value;
                        res.numericIdent = toValue.numericIdent;
                        res.hasChanged = true;
                    }
                } else {
                    if (res.isIdent != isIdent
                            || res.value != value
                            || res.isIdent && isIdent
                                && !res.ident.equals(ident)) {
                        res.isIdent = isIdent;
                        res.ident = ident;
                        res.value = value;
                        res.numericIdent = numericIdent;
                        res.hasChanged = true;
                    }
                }
            } else {
                super.interpolate(res, to, interpolation, accumulation,
                                  multiplier);
                res.numericIdent = false;
            }
        }
        return res;
    }
}
