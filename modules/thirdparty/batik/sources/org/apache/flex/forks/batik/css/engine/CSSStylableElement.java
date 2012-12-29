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
package org.apache.flex.forks.batik.css.engine;

import org.apache.flex.forks.batik.util.ParsedURL;

import org.w3c.dom.Element;

/**
 * This interface must be implemented by the DOM elements which needs
 * CSS support.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: CSSStylableElement.java 579230 2007-09-25 12:52:48Z cam $
 */
public interface CSSStylableElement extends Element {
    
    /**
     * Returns the computed style of this element/pseudo-element.
     */
    StyleMap getComputedStyleMap(String pseudoElement);

    /**
     * Sets the computed style of this element/pseudo-element.
     */
    void setComputedStyleMap(String pseudoElement, StyleMap sm);

    /**
     * Returns the ID of this element.
     */
    String getXMLId();

    /**
     * Returns the class of this element.
     */
    String getCSSClass();

    /**
     * Returns the CSS base URL of this element.
     */
    ParsedURL getCSSBase();

    /**
     * Tells whether this element is an instance of the given pseudo
     * class.
     */
    boolean isPseudoInstanceOf(String pseudoClass);

    /**
     * Returns the object that gives access to the underlying
     * {@link StyleDeclaration} for the override style of this element.
     */
    StyleDeclarationProvider getOverrideStyleDeclarationProvider();
}
