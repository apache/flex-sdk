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
 * A string value in the animation system.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: AnimatableStringValue.java 475477 2006-11-15 22:44:28Z cam $
 */
public class AnimatableStringValue extends AnimatableValue {

    /**
     * The string value.
     */
    protected String string;
    
    /**
     * Creates a new, uninitialized AnimatableStringValue.
     */
    protected AnimatableStringValue(AnimationTarget target) {
        super(target);
    }

    /**
     * Creates a new AnimatableStringValue.
     */
    public AnimatableStringValue(AnimationTarget target, String s) {
        super(target);
        string = s;
    }
    
    /**
     * Performs interpolation to the given value.  String values cannot be
     * interpolated.
     */
    public AnimatableValue interpolate(AnimatableValue result,
                                       AnimatableValue to, float interpolation,
                                       AnimatableValue accumulation,
                                       int multiplier) {
        AnimatableStringValue res;
        if (result == null) {
            res = new AnimatableStringValue(target);
        } else {
            res = (AnimatableStringValue) result;
        }

        String newString;
        if (to != null && interpolation >= 0.5) {
            AnimatableStringValue toValue =
                (AnimatableStringValue) to;
            newString = toValue.string;
        } else {
            newString = string;
        }

        if (res.string == null || !res.string.equals(newString)) {
            res.string = newString;
            res.hasChanged = true;
        }
        return res;
    }

    /**
     * Returns the string.
     */
    public String getString() {
        return string;
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
        return new AnimatableStringValue(target, "");
    }

    /**
     * Returns the CSS text representation of the value.
     */
    public String getCssText() {
        return string;
    }
}
