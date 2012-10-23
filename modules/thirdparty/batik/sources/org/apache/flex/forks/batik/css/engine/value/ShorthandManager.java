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
package org.apache.flex.forks.batik.css.engine.value;

import org.apache.flex.forks.batik.css.engine.CSSEngine;
import org.w3c.css.sac.LexicalUnit;
import org.w3c.dom.DOMException;

/**
 * This interface represents the objects which provide support for
 * shorthand properties.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: ShorthandManager.java 478160 2006-11-22 13:35:06Z dvholten $
 */
public interface ShorthandManager {

    /**
     * Returns the name of the property handled.
     */
    String getPropertyName();

    /**
     * Whether the handled property can be animated.
     */
    boolean isAnimatableProperty();

    /**
     * Whether the handled property can be additively animated.
     */
    boolean isAdditiveProperty();

    /**
     * Sets the properties which are affected by this shorthand
     * property.
     * @param eng  The current CSSEngine.
     * @param ph   The property handler to use.
     * @param lu   The SAC lexical unit used to create the value.
     * @param imp  The property priority.
     */
    void setValues(CSSEngine eng,
                   PropertyHandler ph,
                   LexicalUnit lu,
                   boolean imp)
        throws DOMException;

    /**
     * To handle a property value created by a ShorthandManager.
     */
    interface PropertyHandler {
        void property(String name, LexicalUnit value,
                             boolean important);
    }
}
