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
 * An SVG length value in the animation system.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: AnimatableLengthValue.java 478160 2006-11-22 13:35:06Z dvholten $
 */
public class AnimatableLengthValue extends AnimatableValue {

    /**
     * Length units.
     */
    protected static final String[] UNITS = {
        "", "%", "em", "ex", "px", "cm", "mm", "in", "pt", "pc"
    };

    /**
     * The length type.
     */
    protected short lengthType;

    /**
     * The length value.  This should be one of the constants defined in
     * {@link SVGLength}.
     */
    protected float lengthValue;

    /**
     * How to interpret percentage values.  One of the
     * {@link AnimationTarget}.PERCENTAGE_* constants.
     */
    protected short percentageInterpretation;

    /**
     * Creates a new AnimatableLengthValue with no length.
     */
    protected AnimatableLengthValue(AnimationTarget target) {
        super(target);
    }

    /**
     * Creates a new AnimatableLengthValue.
     */
    public AnimatableLengthValue(AnimationTarget target, short type, float v,
                                 short pcInterp) {
        super(target);
        lengthType = type;
        lengthValue = v;
        percentageInterpretation = pcInterp;
    }

    /**
     * Performs interpolation to the given value.
     */
    public AnimatableValue interpolate(AnimatableValue result,
                                       AnimatableValue to,
                                       float interpolation,
                                       AnimatableValue accumulation,
                                       int multiplier) {
        AnimatableLengthValue res;
        if (result == null) {
            res = new AnimatableLengthValue(target);
        } else {
            res = (AnimatableLengthValue) result;
        }

        short oldLengthType = res.lengthType;
        float oldLengthValue = res.lengthValue;
        short oldPercentageInterpretation = res.percentageInterpretation;

        res.lengthType = lengthType;
        res.lengthValue = lengthValue;
        res.percentageInterpretation = percentageInterpretation;

        if (to != null) {
            AnimatableLengthValue toLength = (AnimatableLengthValue) to;
            float toValue;
            if (!compatibleTypes
                    (res.lengthType, res.percentageInterpretation,
                     toLength.lengthType, toLength.percentageInterpretation)) {
                res.lengthValue = target.svgToUserSpace
                    (res.lengthValue, res.lengthType,
                     res.percentageInterpretation);
                res.lengthType = SVGLength.SVG_LENGTHTYPE_NUMBER;
                toValue = toLength.target.svgToUserSpace
                    (toLength.lengthValue, toLength.lengthType,
                     toLength.percentageInterpretation);
            } else {
                toValue = toLength.lengthValue;
            }
            res.lengthValue += interpolation * (toValue - res.lengthValue);
        }

        if (accumulation != null) {
            AnimatableLengthValue accLength = (AnimatableLengthValue) accumulation;
            float accValue;
            if (!compatibleTypes
                    (res.lengthType, res.percentageInterpretation,
                     accLength.lengthType,
                     accLength.percentageInterpretation)) {
                res.lengthValue = target.svgToUserSpace
                    (res.lengthValue, res.lengthType,
                     res.percentageInterpretation);
                res.lengthType = SVGLength.SVG_LENGTHTYPE_NUMBER;
                accValue = accLength.target.svgToUserSpace
                    (accLength.lengthValue, accLength.lengthType,
                     accLength.percentageInterpretation);
            } else {
                accValue = accLength.lengthValue;
            }
            res.lengthValue += multiplier * accValue;
        }

        if (oldPercentageInterpretation != res.percentageInterpretation
                || oldLengthType != res.lengthType
                || oldLengthValue != res.lengthValue) {
            res.hasChanged = true;
        }
        return res;
    }

    /**
     * Determines if two SVG length types are compatible.
     * @param t1 the first SVG length type
     * @param pi1 the first percentage interpretation type
     * @param t2 the second SVG length type
     * @param pi2 the second percentage interpretation type
     */
    public static boolean compatibleTypes(short t1, short pi1, short t2,
                                          short pi2) {
        return t1 == t2
            && (t1 != SVGLength.SVG_LENGTHTYPE_PERCENTAGE || pi1 == pi2)
            || t1 == SVGLength.SVG_LENGTHTYPE_NUMBER
                && t2 == SVGLength.SVG_LENGTHTYPE_PX
            || t1 == SVGLength.SVG_LENGTHTYPE_PX
                && t2 == SVGLength.SVG_LENGTHTYPE_NUMBER;
    }

    /**
     * Returns the unit type of this length value.
     */
    public int getLengthType() {
        return lengthType;
    }

    /**
     * Returns the magnitude of this length value.
     */
    public float getLengthValue() {
        return lengthValue;
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
        AnimatableLengthValue o = (AnimatableLengthValue) other;
        float v1 = target.svgToUserSpace(lengthValue, lengthType,
                                         percentageInterpretation);
        float v2 = target.svgToUserSpace(o.lengthValue, o.lengthType,
                                         o.percentageInterpretation);
        return Math.abs(v1 - v2);
    }

    /**
     * Returns a zero value of this AnimatableValue's type.
     */
    public AnimatableValue getZeroValue() {
        return new AnimatableLengthValue
            (target, SVGLength.SVG_LENGTHTYPE_NUMBER, 0f,
             percentageInterpretation);
    }

    /**
     * Returns the CSS text representation of the value.  This could use
     * org.apache.flex.forks.batik.css.engine.value.FloatValue.getCssText, but we don't
     * want a dependency on the CSS package.
     */
    public String getCssText() {
        return formatNumber(lengthValue) + UNITS[lengthType - 1];
    }
}
