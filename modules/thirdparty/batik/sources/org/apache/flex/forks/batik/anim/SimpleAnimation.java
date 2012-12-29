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

import java.awt.geom.Point2D;

import org.apache.flex.forks.batik.anim.timing.TimedElement;
import org.apache.flex.forks.batik.anim.values.AnimatableValue;
import org.apache.flex.forks.batik.dom.anim.AnimatableElement;
import org.apache.flex.forks.batik.ext.awt.geom.Cubic;
import org.apache.flex.forks.batik.util.SMILConstants;

/**
 * An animation class for 'animate' animations.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: SimpleAnimation.java 492528 2007-01-04 11:45:47Z cam $
 */
public class SimpleAnimation extends InterpolatingAnimation {

    /**
     * Values between which to interpolate.
     */
    protected AnimatableValue[] values;

    /**
     * Starting value of the animation.
     */
    protected AnimatableValue from;

    /**
     * Ending value of the animation.
     */
    protected AnimatableValue to;

    /**
     * Relative offset value for the animation.
     */
    protected AnimatableValue by;

    /**
     * Creates a new SimpleAnimation.
     */
    public SimpleAnimation(TimedElement timedElement,
                           AnimatableElement animatableElement,
                           int calcMode,
                           float[] keyTimes,
                           float[] keySplines,
                           boolean additive,
                           boolean cumulative,
                           AnimatableValue[] values,
                           AnimatableValue from,
                           AnimatableValue to,
                           AnimatableValue by) {
        super(timedElement, animatableElement, calcMode, keyTimes, keySplines,
              additive, cumulative);
        this.from = from;
        this.to = to;
        this.by = by;

        if (values == null) {
            if (from != null) {
                values = new AnimatableValue[2];
                values[0] = from;
                if (to != null) {
                    values[1] = to;
                } else if (by != null) {
                    values[1] = from.interpolate(null, null, 0f, by, 1); 
                } else {
                    throw timedElement.createException
                        ("values.to.by.missing", new Object[] { null });
                }
            } else {
                if (to != null) {
                    values = new AnimatableValue[2];
                    values[0] = animatableElement.getUnderlyingValue();
                    values[1] = to;
                    this.cumulative = false;
                    toAnimation = true;
                } else if (by != null) {
                    this.additive = true;
                    values = new AnimatableValue[2];
                    values[0] = by.getZeroValue();
                    values[1] = by;
                } else {
                    throw timedElement.createException
                        ("values.to.by.missing", new Object[] { null });
                }
            }
        }
        this.values = values;

        if (this.keyTimes != null && calcMode != CALC_MODE_PACED) {
            if (this.keyTimes.length != values.length) {
                throw timedElement.createException
                    ("attribute.malformed",
                     new Object[] { null,
                                    SMILConstants.SMIL_KEY_TIMES_ATTRIBUTE });
            }
        } else {
            if (calcMode == CALC_MODE_LINEAR || calcMode == CALC_MODE_SPLINE
                    || calcMode == CALC_MODE_PACED && !values[0].canPace()) {
                int count = values.length == 1 ? 2 : values.length;
                this.keyTimes = new float[count];
                for (int i = 0; i < count; i++) {
                    this.keyTimes[i] = (float) i / (count - 1);
                }
            } else if (calcMode == CALC_MODE_DISCRETE) {
                int count = values.length;
                this.keyTimes = new float[count];
                for (int i = 0; i < count; i++) {
                    this.keyTimes[i] = (float) i / count;
                }
            } else { // CALC_MODE_PACED
                // This corrects the keyTimes to be paced, so from now on
                // it can be considered the same as CALC_MODE_LINEAR.
                int count = values.length;
                float[] cumulativeDistances = new float[count];
                cumulativeDistances[0] = 0;
                for (int i = 1; i < count; i++) {
                    cumulativeDistances[i] = cumulativeDistances[i - 1]
                        + values[i - 1].distanceTo(values[i]);
                }
                float totalLength = cumulativeDistances[count - 1];
                this.keyTimes = new float[count];
                this.keyTimes[0] = 0;
                for (int i = 1; i < count - 1; i++) {
                    this.keyTimes[i] = cumulativeDistances[i] / totalLength;
                }
                this.keyTimes[count - 1] = 1;
            }
        }

        if (calcMode == CALC_MODE_SPLINE
                && keySplines.length != (this.keyTimes.length - 1) * 4) {
            throw timedElement.createException
                ("attribute.malformed",
                 new Object[] { null,
                                SMILConstants.SMIL_KEY_SPLINES_ATTRIBUTE });
        }
    }

    /**
     * Called when the element is sampled at the given unit time.  This updates
     * the {@link #value} of the animation if active.
     */
    protected void sampledAtUnitTime(float unitTime, int repeatIteration) {
        AnimatableValue value, accumulation, nextValue;
        float interpolation = 0;
        if (unitTime != 1) {
            int keyTimeIndex = 0;
            while (keyTimeIndex < keyTimes.length - 1
                    && unitTime >= keyTimes[keyTimeIndex + 1]) {
                keyTimeIndex++;
            }
            value = values[keyTimeIndex];
            if (calcMode == CALC_MODE_LINEAR
                    || calcMode == CALC_MODE_PACED
                    || calcMode == CALC_MODE_SPLINE) {
                nextValue = values[keyTimeIndex + 1];
                interpolation = (unitTime - keyTimes[keyTimeIndex])
                    / (keyTimes[keyTimeIndex + 1] - keyTimes[keyTimeIndex]);
                if (calcMode == CALC_MODE_SPLINE && unitTime != 0) {
                    // XXX This could be done better, e.g. with
                    //     Newton-Raphson.
                    Cubic c = keySplineCubics[keyTimeIndex];
                    float tolerance = 0.001f;
                    float min = 0;
                    float max = 1;
                    Point2D.Double p;
                    for (;;) {
                        float t = (min + max) / 2;
                        p = c.eval(t);
                        double x = p.getX();
                        if (Math.abs(x - interpolation) < tolerance) {
                            break;
                        }
                        if (x < interpolation) {
                            min = t;
                        } else {
                            max = t;
                        }
                    }
                    interpolation = (float) p.getY();
                }
            } else {
                nextValue = null;
            }
        } else {
            value = values[values.length - 1];
            nextValue = null;
        }
        if (cumulative) {
            accumulation = values[values.length - 1];
        } else {
            accumulation = null;
        }

        this.value = value.interpolate(this.value, nextValue, interpolation,
                                       accumulation, repeatIteration);
        if (this.value.hasChanged()) {
            markDirty();
        }
    }
}
