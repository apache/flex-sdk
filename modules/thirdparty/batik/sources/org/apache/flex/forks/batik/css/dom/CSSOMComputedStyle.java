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
package org.apache.flex.forks.batik.css.dom;

import java.util.HashMap;
import java.util.Map;

import org.apache.flex.forks.batik.css.engine.CSSEngine;
import org.apache.flex.forks.batik.css.engine.CSSStylableElement;
import org.apache.flex.forks.batik.css.engine.value.Value;
import org.w3c.dom.DOMException;
import org.w3c.dom.css.CSSRule;
import org.w3c.dom.css.CSSStyleDeclaration;
import org.w3c.dom.css.CSSValue;

/**
 * This class represents the computed style of an element.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: CSSOMComputedStyle.java 475685 2006-11-16 11:16:05Z cam $
 */
public class CSSOMComputedStyle implements CSSStyleDeclaration {

    /**
     * The CSS engine used to compute the values.
     */
    protected CSSEngine cssEngine;

    /**
     * The associated element.
     */
    protected CSSStylableElement element;

    /**
     * The optional pseudo-element.
     */
    protected String pseudoElement;

    /**
     * The CSS values.
     */
    protected Map values = new HashMap();

    /**
     * Creates a new computed style.
     */
    public CSSOMComputedStyle(CSSEngine e,
                              CSSStylableElement elt,
                              String pseudoElt) {
        cssEngine = e;
        element = elt;
        pseudoElement = pseudoElt;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.css.CSSStyleDeclaration#getCssText()}.
     */
    public String getCssText() {
        StringBuffer sb = new StringBuffer();
        for (int i = 0; i < cssEngine.getNumberOfProperties(); i++) {
            sb.append(cssEngine.getPropertyName(i));
            sb.append(": ");
            sb.append(cssEngine.getComputedStyle(element, pseudoElement,
                                                 i).getCssText());
            sb.append(";\n");
        }
        return sb.toString();
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.css.CSSStyleDeclaration#setCssText(String)}.
     * Throws a NO_MODIFICATION_ALLOWED_ERR {@link org.w3c.dom.DOMException}.
     */
    public void setCssText(String cssText) throws DOMException {
        throw new DOMException(DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.css.CSSStyleDeclaration#getPropertyValue(String)}.
     */
    public String getPropertyValue(String propertyName) {
        int idx = cssEngine.getPropertyIndex(propertyName);
        if (idx == -1) {
            return "";
        }
        Value v = cssEngine.getComputedStyle(element, pseudoElement, idx);
        return v.getCssText();
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.css.CSSStyleDeclaration#getPropertyCSSValue(String)}.
     */
    public CSSValue getPropertyCSSValue(String propertyName) {
        CSSValue result = (CSSValue)values.get(propertyName);
        if (result == null) {
            int idx = cssEngine.getPropertyIndex(propertyName);
            if (idx != -1) {
                result = createCSSValue(idx);
                values.put(propertyName, result);
            }
        }
        return result;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.css.CSSStyleDeclaration#removeProperty(String)}.
     */
    public String removeProperty(String propertyName) throws DOMException {
        throw new DOMException(DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.css.CSSStyleDeclaration#getPropertyPriority(String)}.
     */
    public String getPropertyPriority(String propertyName) {
        return "";
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.css.CSSStyleDeclaration#setProperty(String,String,String)}.
     */
    public void setProperty(String propertyName, String value, String prio)
        throws DOMException {
        throw new DOMException(DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.css.CSSStyleDeclaration#getLength()}.
     */
    public int getLength() {
        return cssEngine.getNumberOfProperties();
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.css.CSSStyleDeclaration#item(int)}.
     */
    public String item(int index) {
        if (index < 0 || index >= cssEngine.getNumberOfProperties()) {
            return "";
        }
        return cssEngine.getPropertyName(index);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.css.CSSStyleDeclaration#getParentRule()}.
     * @return null.
     */
    public CSSRule getParentRule() {
        return null;
    }

    /**
     * Creates a CSSValue to manage the value at the given index.
     */
    protected CSSValue createCSSValue(int idx) {
        return new ComputedCSSValue(idx);
    }

    /**
     * To manage a computed CSSValue.
     */
    public class ComputedCSSValue
        extends CSSOMValue
        implements CSSOMValue.ValueProvider {
        
        /**
         * The index of the associated value.
         */
        protected int index;

        /**
         * Creates a new ComputedCSSValue.
         */
        public ComputedCSSValue(int idx) {
            super(null);
            valueProvider = this;
            index = idx;
        }

        /**
         * Returns the Value associated with this object.
         */
        public Value getValue() {
            return cssEngine.getComputedStyle(element, pseudoElement, index);
        }
    }
}
