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
import org.apache.flex.forks.batik.anim.SetAnimation;
import org.apache.flex.forks.batik.anim.values.AnimatableValue;

/**
 * A bridge class for the 'set' animation element.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: SVGSetElementBridge.java 478160 2006-11-22 13:35:06Z dvholten $
 */
public class SVGSetElementBridge extends SVGAnimationElementBridge {

    /**
     * Returns 'set'.
     */
    public String getLocalName() {
        return SVG_SET_TAG;
    }

    /**
     * Returns a new instance of this bridge.
     */
    public Bridge getInstance() {
        return new SVGSetElementBridge();
    }

    /**
     * Creates the animation object for the animation element.
     */
    protected AbstractAnimation createAnimation(AnimationTarget target) {
        AnimatableValue to = parseAnimatableValue(SVG_TO_ATTRIBUTE);
        return new SetAnimation(timedElement, this, to);
    }

    /**
     * Returns whether the animation element being handled by this bridge can
     * animate attributes of the specified type.
     * @param type one of the TYPE_ constants defined in {@link org.apache.flex.forks.batik.util.SVGTypes}.
     */
    protected boolean canAnimateType(int type) {
        return true;
    }

    /**
     * Returns whether this is a constant animation (i.e., a 'set' animation).
     */
    protected boolean isConstantAnimation() {
        return true;
    }
}
