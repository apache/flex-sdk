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

import org.apache.flex.forks.batik.dom.anim.AnimationTargetListener;

/**
 * Context interface for elements that can be the target of animations.
 * This exposes the ability to attach {@link AnimationTargetListener}s
 * to the element.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: SVGAnimationTargetContext.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface SVGAnimationTargetContext extends SVGContext {

    /**
     * Adds a listener for changes to the given CSS property.
     */
    void addTargetListener(String pn, AnimationTargetListener l);

    /**
     * Removes a listener for changes to the given attribute value.
     */
    void removeTargetListener(String pn, AnimationTargetListener l);
}
