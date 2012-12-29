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

import org.w3c.dom.svg.SVGLength;

/**
 * An SVG length-or-identifier value in the animation system.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: AnimatableLengthOrIdentValue.java 475477 2006-11-15 22:44:28Z cam $
 */
public class AnimatableLengthOrIdentValue extends AnimatableLengthValue {

    /**
     * Whether this value is an identifier.
     */
    protected boolean isIdent;
    
    /**
     * The identifier.
     */
    protected String ident;
    
    /**
     * Creates a new, uninitialized AnimatableLengthOrIdentValue.
     */
    protected AnimatableLengthOrIdentValue(AnimationTarget target) {
        super(target);
    }
    
    /**
     * Creates a new AnimatableLengthOrIdentValue for a length value.
     */
    public AnimatableLengthOrIdentValue(AnimationTarget target, short type,
                                        float v, short pcInterp) {
        super(target, type, v, pcInterp);
    }

    /**
     * Creates a new AnimatableLengthOrIdentValue for an identifier value.
     */
    public AnimatableLengthOrIdentValue(AnimationTarget target, String ident) {
        super(target);
        this.ident = ident;
        this.isIdent = true;
    }

    /**
     * Returns whether this value is an identifier or a length.
     */
    public boolean isIdent() {
        return isIdent;
    }

    /**
     * Returns the identifier.
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
        return new AnimatableLengthOrIdentValue
            (target, SVGLength.SVG_LENGTHTYPE_NUMBER, 0f,
             percentageInterpretation);
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
        AnimatableLengthOrIdentValue res;
        if (result == null) {
            res = new AnimatableLengthOrIdentValue(target);
        } else {
            res = (AnimatableLengthOrIdentValue) result;
        }
        
        if (to == null) {
            if (isIdent) {
                res.hasChanged = !res.isIdent || !res.ident.equals(ident);
                res.ident = ident;
                res.isIdent = true;
            } else {
                short oldLengthType = res.lengthType;
                float oldLengthValue = res.lengthValue;
                short oldPercentageInterpretation = res.percentageInterpretation;
                super.interpolate(res, to, interpolation, accumulation,
                                  multiplier);
                if (res.lengthType != oldLengthType
                        || res.lengthValue != oldLengthValue
                        || res.percentageInterpretation
                            != oldPercentageInterpretation) {
                    res.hasChanged = true;
                }
            }
        } else {
            AnimatableLengthOrIdentValue toValue
                = (AnimatableLengthOrIdentValue) to;
            if (isIdent || toValue.isIdent) {
                if (interpolation >= 0.5) {
                    if (res.isIdent != toValue.isIdent
                            || res.lengthType != toValue.lengthType
                            || res.lengthValue != toValue.lengthValue
                            || res.isIdent && toValue.isIdent
                                && !toValue.ident.equals(ident)) {
                        res.isIdent = toValue.isIdent;
                        res.ident = toValue.ident;
                        res.lengthType = toValue.lengthType;
                        res.lengthValue = toValue.lengthValue;
                        res.hasChanged = true;
                    }
                } else {
                    if (res.isIdent != isIdent
                            || res.lengthType != lengthType
                            || res.lengthValue != lengthValue
                            || res.isIdent && isIdent
                                && !res.ident.equals(ident)) {
                        res.isIdent = isIdent;
                        res.ident = ident;
                        res.ident = ident;
                        res.lengthType = lengthType;
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
