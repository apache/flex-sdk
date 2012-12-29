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
package org.apache.flex.forks.batik.dom.svg;

import org.w3c.dom.smil.ElementTimeControl;
import org.w3c.dom.svg.SVGElement;

/**
 * Context class for SVG animation elements to support extra methods.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: SVGAnimationContext.java 580685 2007-09-30 09:07:29Z cam $
 */
public interface SVGAnimationContext extends SVGContext, ElementTimeControl {

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGAnimationElement#getTargetElement()}.
     */
    SVGElement getTargetElement();

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGAnimationElement#getStartTime()}.
     */
    float getStartTime();

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGAnimationElement#getCurrentTime()}.
     */
    float getCurrentTime();

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGAnimationElement#getSimpleDuration()}.  With the
     * difference that an indefinite simple duration is returned as
     * {@link org.apache.flex.forks.batik.anim.timing.TimedElement#INDEFINITE}, rather than
     * throwing an exception.
     */
    float getSimpleDuration();

    /**
     * Returns the time that the document would seek to if this animation
     * element were hyperlinked to, or <code>NaN</code> if there is no
     * such begin time.
     */
    float getHyperlinkBeginTime();
}
