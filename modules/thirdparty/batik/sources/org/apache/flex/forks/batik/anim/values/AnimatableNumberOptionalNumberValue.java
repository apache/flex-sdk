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
 * A number-optional-number value in the animation system.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: AnimatableNumberOptionalNumberValue.java 475477 2006-11-15 22:44:28Z cam $
 */
public class AnimatableNumberOptionalNumberValue extends AnimatableValue {

    /**
     * The first number.
     */
    protected float number;

    /**
     * Whether the optional number is present.
     */
    protected boolean hasOptionalNumber;

    /**
     * The optional number.
     */
    protected float optionalNumber;

    /**
     * Creates a new, uninitialized AnimatableNumberOptionalNumberValue.
     */
    protected AnimatableNumberOptionalNumberValue(AnimationTarget target) {
        super(target);
    }
    
    /**
     * Creates a new AnimatableNumberOptionalNumberValue with one number.
     */
    public AnimatableNumberOptionalNumberValue(AnimationTarget target,
                                               float n) {
        super(target);
        number = n;
    }

    /**
     * Creates a new AnimatableNumberOptionalNumberValue with two numbers.
     */
    public AnimatableNumberOptionalNumberValue(AnimationTarget target, float n,
                                               float on) {
        super(target);
        number = n;
        optionalNumber = on;
        hasOptionalNumber = true;
    }

    /**
     * Performs interpolation to the given value.  Number-optional-number
     * values cannot be interpolated.
     */
    public AnimatableValue interpolate(AnimatableValue result,
                                       AnimatableValue to,
                                       float interpolation,
                                       AnimatableValue accumulation,
                                       int multiplier) {
        AnimatableNumberOptionalNumberValue res;
        if (result == null) {
            res = new AnimatableNumberOptionalNumberValue(target);
        } else {
            res = (AnimatableNumberOptionalNumberValue) result;
        }

        float newNumber, newOptionalNumber;
        boolean newHasOptionalNumber;

        if (to != null && interpolation >= 0.5) {
            AnimatableNumberOptionalNumberValue toValue
                = (AnimatableNumberOptionalNumberValue) to;
            newNumber = toValue.number;
            newOptionalNumber = toValue.optionalNumber;
            newHasOptionalNumber = toValue.hasOptionalNumber;
        } else {
            newNumber = number;
            newOptionalNumber = optionalNumber;
            newHasOptionalNumber = hasOptionalNumber;
        }

        if (res.number != newNumber
                || res.hasOptionalNumber != newHasOptionalNumber
                || res.optionalNumber != newOptionalNumber) {
            res.number = number;
            res.optionalNumber = optionalNumber;
            res.hasOptionalNumber = hasOptionalNumber;
            res.hasChanged = true;
        }
        return res;
    }

    /**
     * Returns the first number.
     */
    public float getNumber() {
        return number;
    }

    /**
     * Returns whether the optional number is present.
     */
    public boolean hasOptionalNumber() {
        return hasOptionalNumber;
    }

    /**
     * Returns the optional number.
     */
    public float getOptionalNumber() {
        return optionalNumber;
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
        if (hasOptionalNumber) {
            return new AnimatableNumberOptionalNumberValue(target, 0f, 0f);
        }
        return new AnimatableNumberOptionalNumberValue(target, 0f);
    }

    /**
     * Returns the CSS text representation of the value.
     */
    public String getCssText() {
        StringBuffer sb = new StringBuffer();
        sb.append(formatNumber(number));
        if (hasOptionalNumber) {
            sb.append(' ');
            sb.append(formatNumber(optionalNumber));
        }
        return sb.toString();
    }
}
