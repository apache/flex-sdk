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
import org.apache.flex.forks.batik.dom.anim.AnimatableElement;
import org.apache.flex.forks.batik.ext.awt.geom.Cubic;
import org.apache.flex.forks.batik.util.SMILConstants;

/**
 * An abstract animation class for those animations that interpolate
 * values.  Specifically, this is for animations that have the 'calcMode',
 * 'keyTimes', 'keySplines', 'additive' and 'cumulative' attributes.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: InterpolatingAnimation.java 475477 2006-11-15 22:44:28Z cam $
 */
public abstract class InterpolatingAnimation extends AbstractAnimation {

    /**
     * The interpolation mode of this animator.  This should take one
     * of the CALC_MODE_* constants defined in {@link AbstractAnimation}.
     */
    protected int calcMode;

    /**
     * Time values to control the pacing of the animation.
     */
    protected float[] keyTimes;

    /**
     * Bezier control points that control the pacing of the animation.
     */
    protected float[] keySplines;

    /**
     * Cubics built from the bezier control points in {@link #keySplines}.
     */
    protected Cubic[] keySplineCubics;
    
    /**
     * Whether this animation adds to ones below it in the animation sandwich
     * or replaces them.
     */
    protected boolean additive;

    /**
     * Whether this animation accumulates from previous iterations.
     */
    protected boolean cumulative;

    /**
     * Creates a new InterpolatingAnimation.
     */
    public InterpolatingAnimation(TimedElement timedElement,
                                  AnimatableElement animatableElement,
                                  int calcMode,
                                  float[] keyTimes,
                                  float[] keySplines,
                                  boolean additive,
                                  boolean cumulative) {
        super(timedElement, animatableElement);
        this.calcMode = calcMode;
        this.keyTimes = keyTimes;
        this.keySplines = keySplines;
        this.additive = additive;
        this.cumulative = cumulative;

        if (calcMode == CALC_MODE_SPLINE) {
            if (keySplines == null || keySplines.length % 4 != 0) {
                throw timedElement.createException
                    ("attribute.malformed",
                     new Object[] { null,
                                    SMILConstants.SMIL_KEY_SPLINES_ATTRIBUTE });
            }
            keySplineCubics = new Cubic[keySplines.length / 4];
            for (int i = 0; i < keySplines.length / 4; i++) {
                keySplineCubics[i] = new Cubic(0, 0,
                                               keySplines[i * 4],
                                               keySplines[i * 4 + 1],
                                               keySplines[i * 4 + 2],
                                               keySplines[i * 4 + 3],
                                               1, 1);
            }
        }

        if (keyTimes != null) {
            boolean invalidKeyTimes = false;
            if ((calcMode == CALC_MODE_LINEAR || calcMode == CALC_MODE_SPLINE
                        || calcMode == CALC_MODE_PACED)
                    && (keyTimes.length < 2
                        || keyTimes[0] != 0
                        || keyTimes[keyTimes.length - 1] != 1)
                    || calcMode == CALC_MODE_DISCRETE
                        && (keyTimes.length == 0 || keyTimes[0] != 0)) {
                invalidKeyTimes = true;
            }
            if (!invalidKeyTimes) {
                for (int i = 1; i < keyTimes.length; i++) {
                    if (keyTimes[i] < 0 || keyTimes[1] > 1
                            || keyTimes[i] < keyTimes[i - 1]) {
                        invalidKeyTimes = true;
                        break;
                    }
                }
            }
            if (invalidKeyTimes) {
                throw timedElement.createException
                    ("attribute.malformed",
                     new Object[] { null,
                                    SMILConstants.SMIL_KEY_TIMES_ATTRIBUTE });
            }
        }
    }

    /**
     * Returns whether this animation will replace values on animations
     * lower in the sandwich.
     */
    protected boolean willReplace() {
        return !additive;
    }

    /**
     * Called when the element is sampled for its "last" value.
     */
    protected void sampledLastValue(int repeatIteration) {
        sampledAtUnitTime(1f, repeatIteration);
    }

    /**
     * Called when the element is sampled at the given time.
     */
    protected void sampledAt(float simpleTime, float simpleDur,
                             int repeatIteration) {
        float unitTime;
        if (simpleDur == TimedElement.INDEFINITE) {
            unitTime = 0;
        } else {
            unitTime = simpleTime / simpleDur;
        }
        sampledAtUnitTime(unitTime, repeatIteration);
    }

    /**
     * Called when the element is sampled at the given unit time.  This updates
     * the {@link #value} of the animation if active.
     */
    protected abstract void sampledAtUnitTime(float unitTime,
                                              int repeatIteration);
}
