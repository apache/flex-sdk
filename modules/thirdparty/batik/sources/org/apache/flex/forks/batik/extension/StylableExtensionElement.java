/*

   Copyright 1999-2003  The Apache Software Foundation 

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

package org.apache.flex.forks.batik.extension;

import java.net.MalformedURLException;
import java.net.URL;

import org.apache.flex.forks.batik.css.engine.CSSStylableElement;
import org.apache.flex.forks.batik.css.engine.StyleMap;
import org.apache.flex.forks.batik.dom.AbstractDocument;
import org.apache.flex.forks.batik.dom.svg.XMLBaseSupport;
import org.w3c.dom.Node;
import org.w3c.dom.css.CSSStyleDeclaration;
import org.w3c.dom.css.CSSValue;
import org.w3c.flex.forks.dom.svg.SVGAnimatedString;
import org.w3c.flex.forks.dom.svg.SVGStylable;

/**
 * This class implements the basic features an element must have in
 * order to be usable as a foreign element within an SVGOMDocument,
 * and the support for both the 'style' attribute and the style
 * attributes (ie: fill="red", ...).
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: StylableExtensionElement.java,v 1.7 2005/02/22 09:13:02 cam Exp $
 */
public abstract class StylableExtensionElement
    extends ExtensionElement
    implements CSSStylableElement,
               SVGStylable {

    /**
     * The base URL.
     */
    protected URL cssBase;

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
    public URL getCSSBase() {
        if (cssBase == null) {
            try {
                String bu = XMLBaseSupport.getCascadedXMLBase(this);
                if (bu == null) {
                    return null;
                }
                cssBase = new URL(XMLBaseSupport.getCascadedXMLBase(this));
            } catch (MalformedURLException e) {
                // !!! TODO
                e.printStackTrace();
                throw new InternalError();
            }
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

    // SVGStylable //////////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link org.w3c.flex.forks.dom.svg.SVGStylable#getStyle()}.
     */
    public CSSStyleDeclaration getStyle() {
        throw new InternalError("Not implemented");
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGStylable#getPresentationAttribute(String)}.
     */
    public CSSValue getPresentationAttribute(String name) {
        throw new InternalError("Not implemented");
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGStylable#getClassName()}.
     */
    public SVGAnimatedString getClassName() {
        throw new InternalError("Not implemented");
    }
}
