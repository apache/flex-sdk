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
 * A point value in the animation system from a motion animation.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: AnimatableMotionPointValue.java 475477 2006-11-15 22:44:28Z cam $
 */
public class AnimatableMotionPointValue extends AnimatableValue {

    /**
     * The x coordinate.
     */
    protected float x;

    /**
     * The y coordinate.
     */
    protected float y;

    /**
     * The rotation angle in radians.
     */
    protected float angle;

    /**
     * Creates a new, uninitialized AnimatableMotionPointValue.
     */
    protected AnimatableMotionPointValue(AnimationTarget target) {
        super(target);
    }
    
    /**
     * Creates a new AnimatableMotionPointValue with one x.
     */
    public AnimatableMotionPointValue(AnimationTarget target, float x, float y,
                                     float angle) {
        super(target);
        this.x = x;
        this.y = y;
        this.angle = angle;
    }

    /**
     * Performs interpolation to the given value.
     */
    public AnimatableValue interpolate(AnimatableValue result,
                                       AnimatableValue to,
                                       float interpolation,
                                       AnimatableValue accumulation,
                                       int multiplier) {
        AnimatableMotionPointValue res;
        if (result == null) {
            res = new AnimatableMotionPointValue(target);
        } else {
            res = (AnimatableMotionPointValue) result;
        }

        float newX = x, newY = y, newAngle = angle;
        int angleCount = 1;

        if (to != null) {
            AnimatableMotionPointValue toValue =
                (AnimatableMotionPointValue) to;
            newX += interpolation * (toValue.x - x);
            newY += interpolation * (toValue.y - y);
            newAngle += toValue.angle;
            angleCount++;
        }
        if (accumulation != null && multiplier != 0) {
            AnimatableMotionPointValue accValue =
                (AnimatableMotionPointValue) accumulation;
            newX += multiplier * accValue.x;
            newY += multiplier * accValue.y;
            newAngle += accValue.angle;
            angleCount++;
        }
        newAngle /= angleCount;

        if (res.x != newX || res.y != newY || res.angle != newAngle) {
            res.x = newX;
            res.y = newY;
            res.angle = newAngle;
            res.hasChanged = true;
        }
        return res;
    }

    /**
     * Returns the x coordinate.
     */
    public float getX() {
        return x;
    }

    /**
     * Returns the y coordinate.
     */
    public float getY() {
        return y;
    }

    /**
     * Returns the rotation angle.
     */
    public float getAngle() {
        return angle;
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
        AnimatableMotionPointValue o = (AnimatableMotionPointValue) other;
        float dx = x - o.x;
        float dy = y - o.y;
        return (float) Math.sqrt(dx * dx + dy * dy);
    }

    /**
     * Returns a zero value of this AnimatableValue's type.
     */
    public AnimatableValue getZeroValue() {
        return new AnimatableMotionPointValue(target, 0f, 0f, 0f);
    }

    /**
     * Returns a string representation of this object.
     */
    public String toStringRep() {
        StringBuffer sb = new StringBuffer();
        sb.append(formatNumber(x));
        sb.append(',');
        sb.append(formatNumber(y));
        sb.append(',');
        sb.append(formatNumber(angle));
        sb.append("rad");
        return sb.toString();
    }
}
