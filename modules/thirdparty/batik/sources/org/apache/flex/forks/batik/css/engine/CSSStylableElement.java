/*

   Copyright 2002  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.css.engine;

import java.net.URL;

import org.w3c.dom.Element;

/**
 * This interface must be implemented by the DOM elements which needs
 * CSS support.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: CSSStylableElement.java,v 1.3 2004/08/18 07:12:48 vhardy Exp $
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
    URL getCSSBase();

    /**
     * Tells whether this element is an instance of the given pseudo
     * class.
     */
    boolean isPseudoInstanceOf(String pseudoClass);
}
