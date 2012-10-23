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
 * A percentage value in the animation system.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: AnimatablePercentageValue.java 475477 2006-11-15 22:44:28Z cam $
 */
public class AnimatablePercentageValue extends AnimatableNumberValue {

    /**
     * Creates a new, uninitialized AnimatablePercentageValue.
     */
    protected AnimatablePercentageValue(AnimationTarget target) {
        super(target);
    }
    
    /**
     * Creates a new AnimatablePercentageValue.
     */
    public AnimatablePercentageValue(AnimationTarget target, float v) {
        super(target, v);
    }
    
    /**
     * Performs interpolation to the given value.
     */
    public AnimatableValue interpolate(AnimatableValue result,
                                       AnimatableValue to,
                                       float interpolation,
                                       AnimatableValue accumulation,
                                       int multiplier) {
        if (result == null) {
            result = new AnimatablePercentageValue(target);
        }
        return super.interpolate
            (result, to, interpolation, accumulation, multiplier);
    }

    /**
     * Returns a zero value of this AnimatableValue's type.
     */
    public AnimatableValue getZeroValue() {
        return new AnimatablePercentageValue(target, 0);
    }

    /**
     * Returns the CSS text representation of the value.
     */
    public String getCssText() {
        return super.getCssText() + "%";
    }
}
