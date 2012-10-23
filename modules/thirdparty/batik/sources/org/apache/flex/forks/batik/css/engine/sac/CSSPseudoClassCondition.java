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
package org.apache.flex.forks.batik.css.engine.sac;

import java.util.Set;

import org.apache.flex.forks.batik.css.engine.CSSStylableElement;
import org.w3c.dom.Element;

/**
 * This class provides an implementation of the
 * {@link org.w3c.css.sac.AttributeCondition} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: CSSPseudoClassCondition.java 501844 2007-01-31 13:54:05Z dvholten $
 */
public class CSSPseudoClassCondition extends AbstractAttributeCondition {
    /**
     * The namespaceURI.
     */
    protected String namespaceURI;

    /**
     * Creates a new CSSAttributeCondition object.
     */
    public CSSPseudoClassCondition(String namespaceURI, String value) {
        super(value);
        this.namespaceURI = namespaceURI;
    }

    /**
     * Indicates whether some other object is "equal to" this one.
     * @param obj the reference object with which to compare.
     */
    public boolean equals(Object obj) {
        if (!super.equals(obj)) {
            return false;
        }
        CSSPseudoClassCondition c = (CSSPseudoClassCondition)obj;
        return c.namespaceURI.equals(namespaceURI);
    }

    /**
     * equal objects should have equal hashCodes.
     * @return hashCode of this CSSPseudoClassCondition
     */
    public int hashCode() {
        return namespaceURI.hashCode();
    }


    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.Condition#getConditionType()}.
     */
    public short getConditionType() {
        return SAC_PSEUDO_CLASS_CONDITION;
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.AttributeCondition#getNamespaceURI()}.
     */
    public String getNamespaceURI() {
        return namespaceURI;
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.AttributeCondition#getLocalName()}.
     */
    public String getLocalName() {
        return null;
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.AttributeCondition#getSpecified()}.
     */
    public boolean getSpecified() {
        return false;
    }

    /**
     * Tests whether this selector matches the given element.
     */
    public boolean match(Element e, String pseudoE) {
        return (e instanceof CSSStylableElement)
            ? ((CSSStylableElement)e).isPseudoInstanceOf(getValue())
            : false;
    }

    /**
     * Fills the given set with the attribute names found in this selector.
     */
    public void fillAttributeSet(Set attrSet) {
    }

    /**
     * Returns a text representation of this object.
     */
    public String toString() {
        return ":" + getValue();
    }
}
