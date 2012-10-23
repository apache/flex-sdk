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
package org.apache.flex.forks.batik.extension;

import org.apache.flex.forks.batik.css.engine.CSSStylableElement;
import org.apache.flex.forks.batik.css.engine.StyleDeclarationProvider;
import org.apache.flex.forks.batik.css.engine.StyleMap;
import org.apache.flex.forks.batik.dom.AbstractDocument;
import org.apache.flex.forks.batik.util.ParsedURL;

import org.w3c.dom.Node;
import org.w3c.dom.css.CSSStyleDeclaration;
import org.w3c.dom.css.CSSValue;
import org.w3c.dom.svg.SVGAnimatedString;
import org.w3c.dom.svg.SVGStylable;

/**
 * This class implements the basic features an element must have in
 * order to be usable as a foreign element within an SVGOMDocument,
 * and the support for both the 'style' attribute and the style
 * attributes (ie: fill="red", ...).
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: StylableExtensionElement.java 579230 2007-09-25 12:52:48Z cam $
 */
public abstract class StylableExtensionElement
    extends ExtensionElement
    implements CSSStylableElement,
               SVGStylable {

    /**
     * The base URL.
     */
    protected ParsedURL cssBase;

    /**
     * The computed style map.
     */
    protected StyleMap computedStyleMap;

    /**
     * Creates a new Element object.
     */
    protected StylableExtensionElement() {
    }

    /**
     * Creates a new Element object.
     * @param name The element name, for validation purposes.
     * @param owner The owner document.
     */
    protected StylableExtensionElement(String name, AbstractDocument owner) {
        super(name, owner);
    }

    // CSSStylableElement //////////////////////////////////////////

    /**
     * Returns the computed style of this element/pseudo-element.
     */
    public StyleMap getComputedStyleMap(String pseudoElement) {
        return computedStyleMap;
    }

    /**
     * Sets the computed style of this element/pseudo-element.
     */
    public void setComputedStyleMap(String pseudoElement, StyleMap sm) {
        computedStyleMap = sm;
    }

    /**
     * Returns the ID of this element.
     */
    public String getXMLId() {
        return getAttributeNS(null, "id");
    }

    /**
     * Returns the class of this element.
     */
    public String getCSSClass() {
        return getAttributeNS(null, "class");
    }

    /**
     * Returns the CSS base URL of this element.
     */
    public ParsedURL getCSSBase() {
        if (cssBase == null) {
            String bu = getBaseURI();
            if (bu == null) {
                return null;
            }
            cssBase = new ParsedURL(bu);
        }
        return cssBase;
    }

    /**
     * Tells whether this element is an instance of the given pseudo
     * class.
     */
    public boolean isPseudoInstanceOf(String pseudoClass) {
        if (pseudoClass.equals("first-child")) {
            Node n = getPreviousSibling();
            while (n != null && n.getNodeType() != ELEMENT_NODE) {
                n = n.getPreviousSibling();
            }
            return n == null;
        }
        return false;
    }

    /**
     * Returns the object that gives access to the underlying
     * {@link org.apache.flex.forks.batik.css.engine.StyleDeclaration} for the override
     * style of this element.
     */
    public StyleDeclarationProvider getOverrideStyleDeclarationProvider() {
        return null;
    }

    // SVGStylable //////////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.svg.SVGStylable#getStyle()}.
     */
    public CSSStyleDeclaration getStyle() {
        throw new UnsupportedOperationException("Not implemented");
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGStylable#getPresentationAttribute(String)}.
     */
    public CSSValue getPresentationAttribute(String name) {
        throw new UnsupportedOperationException("Not implemented");
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGStylable#getClassName()}.
     */
    public SVGAnimatedString getClassName() {
        throw new UnsupportedOperationException("Not implemented");
    }
}
