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
 * A boolean value in the animation system.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: AnimatableBooleanValue.java 475477 2006-11-15 22:44:28Z cam $
 */
public class AnimatableBooleanValue extends AnimatableValue {

    /**
     * The boolean value.
     */
    protected boolean value;
    
    /**
     * Creates a new, uninitialized AnimatableBooleanValue.
     */
    protected AnimatableBooleanValue(AnimationTarget target) {
        super(target);
    }

    /**
     * Creates a new AnimatableBooleanValue.
     */
    public AnimatableBooleanValue(AnimationTarget target, boolean b) {
        super(target);
        value = b;
    }
    
    /**
     * Performs interpolation to the given value.  Boolean values cannot be
     * interpolated.
     */
    public AnimatableValue interpolate(AnimatableValue result,
                                       AnimatableValue to, float interpolation,
                                       AnimatableValue accumulation,
                                       int multiplier) {
        AnimatableBooleanValue res;
        if (result == null) {
            res = new AnimatableBooleanValue(target);
        } else {
            res = (AnimatableBooleanValue) result;
        }

        boolean newValue;
        if (to != null && interpolation >= 0.5) {
            AnimatableBooleanValue toValue = (AnimatableBooleanValue) to;
            newValue = toValue.value;
        } else {
            newValue = value;
        }

        if (res.value != newValue) {
            res.value = newValue;
            res.hasChanged = true;
        }
        return res;
    }

    /**
     * Returns the boolean value.
     */
    public boolean getValue() {
        return value;
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
        return new AnimatableBooleanValue(target, false);
    }

    /**
     * Returns the CSS text representation of the value.
     */
    public String getCssText() {
        return (value)?"true":"false";
    }
}
