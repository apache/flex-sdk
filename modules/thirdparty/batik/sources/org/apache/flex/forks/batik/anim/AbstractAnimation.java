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
package org.apache.flex.forks.batik.anim;

import org.apache.flex.forks.batik.anim.timing.TimedElement;
import org.apache.flex.forks.batik.anim.values.AnimatableValue;
import org.apache.flex.forks.batik.dom.anim.AnimatableElement;

// import org.apache.flex.forks.batik.anim.timing.Trace;

/**
 * An abstract base class for the different types of animation.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: AbstractAnimation.java 478283 2006-11-22 18:53:40Z dvholten $
 */
public abstract class AbstractAnimation {

    // Constants for calcMode.
    public static final short CALC_MODE_DISCRETE = 0;
    public static final short CALC_MODE_LINEAR   = 1;
    public static final short CALC_MODE_PACED    = 2;
    public static final short CALC_MODE_SPLINE   = 3;

    /**
     * The TimedElement that controls the timing of this animation.
     */
    protected TimedElement timedElement;

    /**
     * The AnimatableElement that gives access to underlying values in the
     * document.
     */
    protected AnimatableElement animatableElement;

    /**
     * The animation that is lower in the sandwich.
     */
    protected AbstractAnimation lowerAnimation;

    /**
     * The animation that is higher in the sandwich.
     */
    protected AbstractAnimation higherAnimation;

    /**
     * Whether this animation needs recomputing.
     */
    protected boolean isDirty;

    /**
     * Whether this animation is active.
     */
    protected boolean isActive;

    /**
     * Whether this animation is frozen.
     */
    protected boolean isFrozen;

    /**
     * The time at which this animation became active.  Used for ensuring the
     * sandwich order is correct when multiple animations become active
     * simultaneously.
     */
    protected float beginTime;

    /**
     * The value of this animation.
     */
    protected AnimatableValue value;

    /**
     * The value of this animation composed with any others.
     */
    protected AnimatableValue composedValue;

    /**
     * Whether this animation depends on the underlying value.
     */
    protected boolean usesUnderlyingValue;

    /**
     * Whether this animation is a 'to-animation'.
     */
    protected boolean toAnimation;

    /**
     * Creates a new Animation.
     */
    protected AbstractAnimation(TimedElement timedElement,
                                AnimatableElement animatableElement) {
        this.timedElement = timedElement;
        this.animatableElement = animatableElement;
    }

    /**
     * Returns the TimedElement for this animation.
     */
    public TimedElement getTimedElement() {
        return timedElement;
    }

    /**
     * Returns the value of this animation, or null if it isn't active.
     */
    public AnimatableValue getValue() {
        if (!isActive && !isFrozen) {
            return null;
        }
        return value;
    }

    /**
     * Returns the composed value of this animation, or null if it isn't active.
     */
    public AnimatableValue getComposedValue() {
        // Trace.enter(this, "getComposedValue", null); try {
        // Trace.print("isActive == " + isActive + ", isFrozen == " + isFrozen + ", isDirty == " + isDirty);
        if (!isActive && !isFrozen) {
            return null;
        }
        if (isDirty) {
            // Trace.print("willReplace() == " + willReplace());
            // Trace.print("value == " + value);
            AnimatableValue lowerValue = null;
            if (!willReplace()) {
                // Trace.print("lowerAnimation == " + lowerAnimation);
                if (lowerAnimation == null) {
                    lowerValue = animatableElement.getUnderlyingValue();
                    usesUnderlyingValue = true;
                } else {
                    lowerValue = lowerAnimation.getComposedValue();
                    usesUnderlyingValue = false;
                }
                // Trace.print("lowerValue == " + lowerValue);
            }
            composedValue =
                value.interpolate(composedValue, null, 0f, lowerValue, 1);
            // Trace.print("composedValue == " + composedValue);
            isDirty = false;
        }
        return composedValue;
        // } finally { Trace.exit(); }
    }

    /**
     * Returns a string representation of this animation.
     */
    public String toString() {
        return timedElement.toString();
    }

    /**
     * Returns whether this animation depends on the underlying value.
     */
    public boolean usesUnderlyingValue() {
        return usesUnderlyingValue || toAnimation;
    }

    /**
     * Returns whether this animation will replace values on animations
     * lower in the sandwich.
     */
    protected boolean willReplace() {
        return true;
    }

    /**
     * Marks this animation and any animation that depends on it
     * as dirty.
     */
    protected void markDirty() {
        isDirty = true;
        if (higherAnimation != null
                && !higherAnimation.willReplace()
                && !higherAnimation.isDirty) {
            higherAnimation.markDirty();
        }
    }

    /**
     * Called when the element is sampled for its "last" value.
     */
    protected void sampledLastValue(int repeatIteration) {
    }

    /**
     * Called when the element is sampled at the given time.  This updates
     * the {@link #value} of the animation if active.
     */
    protected abstract void sampledAt(float simpleTime, float simpleDur,
                                      int repeatIteration);
}
