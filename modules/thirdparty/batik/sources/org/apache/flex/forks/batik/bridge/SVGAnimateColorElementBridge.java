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
package org.apache.flex.forks.batik.bridge;

import org.apache.flex.forks.batik.anim.AbstractAnimation;
import org.apache.flex.forks.batik.dom.anim.AnimationTarget;
import org.apache.flex.forks.batik.anim.ColorAnimation;
import org.apache.flex.forks.batik.anim.values.AnimatableColorValue;
import org.apache.flex.forks.batik.anim.values.AnimatablePaintValue;
import org.apache.flex.forks.batik.anim.values.AnimatableValue;
import org.apache.flex.forks.batik.util.SVGTypes;

/**
 * Bridge class for the 'animateColor' animation element.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: SVGAnimateColorElementBridge.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SVGAnimateColorElementBridge extends SVGAnimateElementBridge {

    /**
     * Returns 'animateColor'.
     */
    public String getLocalName() {
        return SVG_ANIMATE_COLOR_TAG;
    }

    /**
     * Returns a new instance of this bridge.
     */
    public Bridge getInstance() {
        return new SVGAnimateColorElementBridge();
    }

    /**
     * Creates the animation object for the animation element.
     */
    protected AbstractAnimation createAnimation(AnimationTarget target) {
        AnimatableValue from = parseAnimatableValue(SVG_FROM_ATTRIBUTE);
        AnimatableValue to = parseAnimatableValue(SVG_TO_ATTRIBUTE);
        AnimatableValue by = parseAnimatableValue(SVG_BY_ATTRIBUTE);
        return new ColorAnimation(timedElement,
                                  this,
                                  parseCalcMode(),
                                  parseKeyTimes(),
                                  parseKeySplines(),
                                  parseAdditive(),
                                  parseAccumulate(),
                                  parseValues(),
                                  from,
                                  to,
                                  by);
    }

    /**
     * Returns whether the animation element being handled by this bridge can
     * animate attributes of the specified type.
     * @param type one of the TYPE_ constants defined in {@link SVGTypes}.
     */
    protected boolean canAnimateType(int type) {
        return type == SVGTypes.TYPE_COLOR || type == SVGTypes.TYPE_PAINT;
    }

    /**
     * Returns whether the specified {@link AnimatableValue} is of a type allowed
     * by this animation.
     */
    protected boolean checkValueType(AnimatableValue v) {
        if (v instanceof AnimatablePaintValue) {
            return ((AnimatablePaintValue) v).getPaintType()
                == AnimatablePaintValue.PAINT_COLOR;
        }
        return v instanceof AnimatableColorValue;
    }
}
