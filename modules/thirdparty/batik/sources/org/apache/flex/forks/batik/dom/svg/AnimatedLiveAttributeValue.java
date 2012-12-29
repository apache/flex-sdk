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

import org.apache.flex.forks.batik.anim.values.AnimatableValue;
import org.apache.flex.forks.batik.dom.anim.AnimationTarget;

/**
 * An interface for {@link LiveAttributeValue}s that have an animated value
 * component.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: AnimatedLiveAttributeValue.java 489964 2006-12-24 01:30:23Z cam $
 */
public interface AnimatedLiveAttributeValue extends LiveAttributeValue {

    /**
     * Returns the namespace URI of this animated live attribute.
     */
    String getNamespaceURI();

    /**
     * Returns the local name of this animated live attribute.
     */
    String getLocalName();

    /**
     * Returns the base value of the attribute as an {@link AnimatableValue}.
     */
    AnimatableValue getUnderlyingValue(AnimationTarget target);

    /**
     * Adds a listener for changes to the animated value.
     */
    void addAnimatedAttributeListener(AnimatedAttributeListener aal);

    /**
     * Removes a listener for changes to the animated value.
     */
    void removeAnimatedAttributeListener(AnimatedAttributeListener aal);
}
