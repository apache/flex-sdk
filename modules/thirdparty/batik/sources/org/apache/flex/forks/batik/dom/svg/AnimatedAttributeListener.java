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

import org.w3c.dom.Element;

/**
 * An interface to listen for changes on any animatable XML attribute in
 * an {@link SVGOMDocument}.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: AnimatedAttributeListener.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface AnimatedAttributeListener {

    /**
     * Called to notify an object of a change to the animated value of
     * an animatable XML attribute.
     * @param e the owner element of the changed animatable attribute
     * @param alav the AnimatedLiveAttributeValue that changed
     */
    void animatedAttributeChanged(Element e, AnimatedLiveAttributeValue alav);

    /**
     * Called to notify an object of a change to the value of an 'other'
     * animation.
     * @param e the element being animated
     * @param type the type of animation whose value changed
     */
    void otherAnimationChanged(Element e, String type);
}
