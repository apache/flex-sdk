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
 * An SVG color value in the animation system.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: AnimatableColorValue.java 501495 2007-01-30 18:00:36Z dvholten $
 */
public class AnimatableColorValue extends AnimatableValue {

    /**
     * The red component.
     */
    protected float red;

    /**
     * The green component.
     */
    protected float green;

    /**
     * The blue component.
     */
    protected float blue;

    /**
     * Creates a new AnimatableColorValue.
     */
    protected AnimatableColorValue(AnimationTarget target) {
        super(target);
    }

    /**
     * Creates a new AnimatableColorValue.
     */
    public AnimatableColorValue(AnimationTarget target,
                                float r, float g, float b) {
        super(target);
        red = r;
        green = g;
        blue = b;
    }

    /**
     * Performs interpolation to the given value.
     */
    public AnimatableValue interpolate(AnimatableValue result,
                                       AnimatableValue to,
                                       float interpolation,
                                       AnimatableValue accumulation,
                                       int multiplier) {
        AnimatableColorValue res;
        if (result == null) {
            res = new AnimatableColorValue(target);
        } else {
            res = (AnimatableColorValue) result;
        }

        float oldRed = res.red;
        float oldGreen = res.green;
        float oldBlue = res.blue;

        res.red = red;
        res.green = green;
        res.blue = blue;

        AnimatableColorValue toColor = (AnimatableColorValue) to;
        AnimatableColorValue accColor = (AnimatableColorValue) accumulation;

        // XXX Should handle non-sRGB colours and non-sRGB interpolation.

        if (to != null) {
            res.red += interpolation * (toColor.red - res.red);
            res.green += interpolation * (toColor.green - res.green);
            res.blue += interpolation * (toColor.blue - res.blue);
        }

        if (accumulation != null) {
            res.red += multiplier * accColor.red;
            res.green += multiplier * accColor.green;
            res.blue += multiplier * accColor.blue;
        }

        if (res.red != oldRed || res.green != oldGreen || res.blue != oldBlue) {
            res.hasChanged = true;
        }
        return res;
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
        AnimatableColorValue o = (AnimatableColorValue) other;
        float dr = red - o.red;
        float dg = green - o.green;
        float db = blue - o.blue;
        return (float) Math.sqrt(dr * dr + dg * dg + db * db);
    }

    /**
     * Returns a zero value of this AnimatableValue's type.
     */
    public AnimatableValue getZeroValue() {
        return new AnimatableColorValue(target, 0f, 0f, 0f);
    }

    /**
     * Returns the CSS text representation of the value.
     */
    public String getCssText() {
        return "rgb(" + Math.round(red * 255) + ','
                + Math.round(green * 255) + ','
                + Math.round(blue * 255) + ')';
    }
}
