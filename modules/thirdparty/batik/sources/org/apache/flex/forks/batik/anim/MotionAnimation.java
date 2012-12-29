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
import org.apache.flex.forks.batik.anim.values.AnimatableAngleValue;
import org.apache.flex.forks.batik.anim.values.AnimatableMotionPointValue;
import org.apache.flex.forks.batik.anim.values.AnimatableValue;
import org.apache.flex.forks.batik.dom.anim.AnimatableElement;
import org.apache.flex.forks.batik.ext.awt.geom.Cubic;
import org.apache.flex.forks.batik.ext.awt.geom.ExtendedGeneralPath;
import org.apache.flex.forks.batik.ext.awt.geom.ExtendedPathIterator;
import org.apache.flex.forks.batik.ext.awt.geom.PathLength;
import org.apache.flex.forks.batik.util.SMILConstants;

/**
 * An animation class for 'animateMotion' animations.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: MotionAnimation.java 575201 2007-09-13 07:41:26Z cam $
 */
public class MotionAnimation extends InterpolatingAnimation {

    /**
     * The path that describes the motion.
     */
    protected ExtendedGeneralPath path;

    /**
     * The path length calculation object.
     */
    protected PathLength pathLength;

    /**
     * The points defining the distance along the path that the
     * keyTimes apply.
     */
    protected float[] keyPoints;

    /**
     * Whether automatic rotation should be performed.
     */
    protected boolean rotateAuto;

    /**
     * Whether the automatic rotation should be reversed.
     */
    protected boolean rotateAutoReverse;

    /**
     * The angle of rotation (in radians) to use when automatic rotation is
     * not being used.
     */
    protected float rotateAngle;

    /**
     * Creates a new MotionAnimation.
     */
    public MotionAnimation(TimedElement timedElement,
                           AnimatableElement animatableElement,
                           int calcMode,
                           float[] keyTimes,
                           float[] keySplines,
                           boolean additive,
                           boolean cumulative,
                           AnimatableValue[] values,
                           AnimatableValue from,
                           AnimatableValue to,
                           AnimatableValue by,
                           ExtendedGeneralPath path,
                           float[] keyPoints,
                           boolean rotateAuto,
                           boolean rotateAutoReverse,
                           float rotateAngle,
                           short rotateAngleUnit) {
        super(timedElement, animatableElement, calcMode, keyTimes, keySplines,
              additive, cumulative);
        this.rotateAuto = rotateAuto;
        this.rotateAutoReverse = rotateAutoReverse;
        this.rotateAngle = AnimatableAngleValue.rad(rotateAngle, rotateAngleUnit);

        if (path == null) {
            path = new ExtendedGeneralPath();
            if (values == null || values.length == 0) {
                if (from != null) {
                    AnimatableMotionPointValue fromPt = (AnimatableMotionPointValue) from;
                    float x = fromPt.getX();
                    float y = fromPt.getY();
                    path.moveTo(x, y);
                    if (to != null) {
                        AnimatableMotionPointValue toPt = (AnimatableMotionPointValue) to;
                        path.lineTo(toPt.getX(), toPt.getY());
                    } else if (by != null) {
                        AnimatableMotionPointValue byPt = (AnimatableMotionPointValue) by;
                        path.lineTo(x + byPt.getX(), y + byPt.getY());
                    } else {
                        throw timedElement.createException
                            ("values.to.by.path.missing",
                             new Object[] { null });
                    }
                } else {
                    if (to != null) {
                        AnimatableMotionPointValue unPt = (AnimatableMotionPointValue)
                            animatableElement.getUnderlyingValue();
                        AnimatableMotionPointValue toPt = (AnimatableMotionPointValue) to;
                        path.moveTo(unPt.getX(), unPt.getY());
                        path.lineTo(toPt.getX(), toPt.getY());
                        this.cumulative = false;
                    } else if (by != null) {
                        AnimatableMotionPointValue byPt = (AnimatableMotionPointValue) by;
                        path.moveTo(0, 0);
                        path.lineTo(byPt.getX(), byPt.getY());
                        this.additive = true;
                    } else {
                        throw timedElement.createException
                            ("values.to.by.path.missing",
                             new Object[] { null });
                    }
                }
            } else {
                AnimatableMotionPointValue pt = (AnimatableMotionPointValue) values[0];
                path.moveTo(pt.getX(), pt.getY());
                for (int i = 1; i < values.length; i++) {
                    pt = (AnimatableMotionPointValue) values[i];
                    path.lineTo(pt.getX(), pt.getY());
                }
            }
        }
        this.path = path;
        pathLength = new PathLength(path);
        int segments = 0;
        ExtendedPathIterator epi = path.getExtendedPathIterator();
        while (!epi.isDone()) {
            int type = epi.currentSegment();
            if (type != ExtendedPathIterator.SEG_MOVETO) {
                segments++;
            }
            epi.next();
        }

        int count = keyPoints == null ? segments + 1 : keyPoints.length;
        float totalLength = pathLength.lengthOfPath();
        if (this.keyTimes != null && calcMode != CALC_MODE_PACED) {
            if (this.keyTimes.length != count) {
                throw timedElement.createException
                    ("attribute.malformed",
                     new Object[] { null,
                                    SMILConstants.SMIL_KEY_TIMES_ATTRIBUTE });
            }
        } else {
            if (calcMode == CALC_MODE_LINEAR || calcMode == CALC_MODE_SPLINE) {
                this.keyTimes = new float[count];
                for (int i = 0; i < count; i++) {
                    this.keyTimes[i] = (float) i / (count - 1);
                }
            } else if (calcMode == CALC_MODE_DISCRETE) {
                this.keyTimes = new float[count];
                for (int i = 0; i < count; i++) {
                    this.keyTimes[i] = (float) i / count;
                }
            } else { // CALC_MODE_PACED
                // This corrects the keyTimes to be paced, so from now on
                // it can be considered the same as CALC_MODE_LINEAR.
                epi = path.getExtendedPathIterator();
                this.keyTimes = new float[count];
                int j = 0;
                for (int i = 0; i < count - 1; i++) {
                    while (epi.currentSegment() ==
                            ExtendedPathIterator.SEG_MOVETO) {
                        j++;
                        epi.next();
                    }
                    this.keyTimes[i] =
                        pathLength.getLengthAtSegment(j) / totalLength;
                    j++;
                    epi.next();
                }
                this.keyTimes[count - 1] = 1f;
            }
        }

        if (keyPoints != null) {
            if (keyPoints.length != this.keyTimes.length) {
                throw timedElement.createException
                    ("attribute.malformed",
                     new Object[] { null,
                                    SMILConstants.SMIL_KEY_POINTS_ATTRIBUTE });
            }
        } else {
            epi = path.getExtendedPathIterator();
            keyPoints = new float[count];
            int j = 0;
            for (int i = 0; i < count - 1; i++) {
                while (epi.currentSegment() ==
                        ExtendedPathIterator.SEG_MOVETO) {
                    j++;
                    epi.next();
                }
                keyPoints[i] = pathLength.getLengthAtSegment(j) / totalLength;
                j++;
                epi.next();
            }
            keyPoints[count - 1] = 1f;
        }
        this.keyPoints = keyPoints;
    }

    /**
     * Called when the element is sampled at the given unit time.  This updates
     * the {@link #value} of the animation if active.
     */
    protected void sampledAtUnitTime(float unitTime, int repeatIteration) {
        AnimatableValue value, accumulation;
        float interpolation = 0;
        if (unitTime != 1) {
            int keyTimeIndex = 0;
            while (keyTimeIndex < keyTimes.length - 1
                    && unitTime >= keyTimes[keyTimeIndex + 1]) {
                keyTimeIndex++;
            }
            if (keyTimeIndex == keyTimes.length - 1 && calcMode == CALC_MODE_DISCRETE) {
                keyTimeIndex = keyTimes.length - 2;
                interpolation = 1;
            } else {
                if (calcMode == CALC_MODE_LINEAR || calcMode == CALC_MODE_PACED
                        || calcMode == CALC_MODE_SPLINE) {
                    if (unitTime == 0) {
                        interpolation = 0;
                    } else {
                        interpolation = (unitTime - keyTimes[keyTimeIndex])
                            / (keyTimes[keyTimeIndex + 1] - keyTimes[keyTimeIndex]);
                    }
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
                }
            }
            float point = keyPoints[keyTimeIndex];
            if (interpolation != 0) {
                point += interpolation *
                    (keyPoints[keyTimeIndex + 1] - keyPoints[keyTimeIndex]);
            }
            point *= pathLength.lengthOfPath();
            Point2D p = pathLength.pointAtLength(point);
            float ang;
            if (rotateAuto) {
                ang = pathLength.angleAtLength(point);
                if (rotateAutoReverse) {
                    ang += Math.PI;
                }
            } else {
                ang = rotateAngle;
            }
            value = new AnimatableMotionPointValue(null, (float) p.getX(),
                                                   (float) p.getY(), ang);
        } else {
            Point2D p = pathLength.pointAtLength(pathLength.lengthOfPath());
            float ang;
            if (rotateAuto) {
                ang = pathLength.angleAtLength(pathLength.lengthOfPath());
                if (rotateAutoReverse) {
                    ang += Math.PI;
                }
            } else {
                ang = rotateAngle;
            }
            value = new AnimatableMotionPointValue(null, (float) p.getX(),
                                                   (float) p.getY(), ang);
        }
        if (cumulative) {
            Point2D p = pathLength.pointAtLength(pathLength.lengthOfPath());
            float ang;
            if (rotateAuto) {
                ang = pathLength.angleAtLength(pathLength.lengthOfPath());
                if (rotateAutoReverse) {
                    ang += Math.PI;
                }
            } else {
                ang = rotateAngle;
            }
            accumulation = new AnimatableMotionPointValue(null, (float) p.getX(),
                                                          (float) p.getY(), ang);
        } else {
            accumulation = null;
        }

        this.value = value.interpolate(this.value, null, interpolation,
                                       accumulation, repeatIteration);
        if (this.value.hasChanged()) {
            markDirty();
        }
    }
}
