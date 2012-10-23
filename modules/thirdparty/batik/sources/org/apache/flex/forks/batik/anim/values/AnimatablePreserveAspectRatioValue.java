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
import org.apache.flex.forks.batik.util.SVGConstants;

import org.w3c.dom.svg.SVGPreserveAspectRatio;

/**
 * An SVG preserveAspectRatio value in the animation system.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: AnimatablePreserveAspectRatioValue.java 475477 2006-11-15 22:44:28Z cam $
 */
public class AnimatablePreserveAspectRatioValue extends AnimatableValue {
    
    /**
     * Strings for the 'align' values.
     */
    protected static final String[] ALIGN_VALUES = {
        null,
        SVGConstants.SVG_NONE_VALUE,
        SVGConstants.SVG_XMINYMIN_VALUE,
        SVGConstants.SVG_XMIDYMIN_VALUE,
        SVGConstants.SVG_XMAXYMIN_VALUE,
        SVGConstants.SVG_XMINYMID_VALUE,
        SVGConstants.SVG_XMIDYMID_VALUE,
        SVGConstants.SVG_XMAXYMID_VALUE,
        SVGConstants.SVG_XMINYMAX_VALUE,
        SVGConstants.SVG_XMIDYMAX_VALUE,
        SVGConstants.SVG_XMAXYMAX_VALUE
    };

    /**
     * Strings for the 'meet-or-slice' values.
     */
    protected static final String[] MEET_OR_SLICE_VALUES = {
        null,
        SVGConstants.SVG_MEET_VALUE,
        SVGConstants.SVG_SLICE_VALUE
    };

    /**
     * The align value.
     */
    protected short align;

    /**
     * The meet-or-slice value.
     */
    protected short meetOrSlice;

    /**
     * Creates a new, uninitialized AnimatablePreserveAspectRatioValue.
     */
    protected AnimatablePreserveAspectRatioValue(AnimationTarget target) {
        super(target);
    }

    /**
     * Creates a new AnimatablePreserveAspectRatioValue.
     */
    public AnimatablePreserveAspectRatioValue(AnimationTarget target,
                                              short align, short meetOrSlice) {
        super(target);
        this.align = align;
        this.meetOrSlice = meetOrSlice;
    }
    
    /**
     * Performs interpolation to the given value.  Preserve aspect ratio values
     * cannot be interpolated.
     */
    public AnimatableValue interpolate(AnimatableValue result,
                                       AnimatableValue to, float interpolation,
                                       AnimatableValue accumulation,
                                       int multiplier) {
        AnimatablePreserveAspectRatioValue res;
        if (result == null) {
            res = new AnimatablePreserveAspectRatioValue(target);
        } else {
            res = (AnimatablePreserveAspectRatioValue) result;
        }

        short newAlign, newMeetOrSlice;
        if (to != null && interpolation >= 0.5) {
            AnimatablePreserveAspectRatioValue toValue =
                (AnimatablePreserveAspectRatioValue) to;
            newAlign = toValue.align;
            newMeetOrSlice = toValue.meetOrSlice;
        } else {
            newAlign = align;
            newMeetOrSlice = meetOrSlice;
        }

        if (res.align != newAlign || res.meetOrSlice != newMeetOrSlice) {
            res.align = align;
            res.meetOrSlice = meetOrSlice;
            res.hasChanged = true;
        }
        return res;
    }

    /**
     * Returns the align value.
     */
    public short getAlign() {
        return align;
    }

    /**
     * Returns the meet-or-slice value.
     */
    public short getMeetOrSlice() {
        return meetOrSlice;
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
        return new AnimatablePreserveAspectRatioValue
            (target, SVGPreserveAspectRatio.SVG_PRESERVEASPECTRATIO_NONE,
             SVGPreserveAspectRatio.SVG_MEETORSLICE_MEET);
    }

    /**
     * Returns a string representation of this object.
     */
    public String toStringRep() {
        if (align < 1 || align > 10) {
            return null;
        }
        String value = ALIGN_VALUES[align];
        if (align == SVGPreserveAspectRatio.SVG_PRESERVEASPECTRATIO_NONE) {
            return value;
        }
        if (meetOrSlice < 1 || meetOrSlice > 2) {
            return null;
        }
        return value + ' ' + MEET_OR_SLICE_VALUES[meetOrSlice];
    }
}
