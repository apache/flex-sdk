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
 * @version $Id: CSSIdCondition.java 478160 2006-11-22 13:35:06Z dvholten $
 */

public class CSSIdCondition extends AbstractAttributeCondition {

    /**
     * The id attribute namespace URI.
     */
    protected String namespaceURI;

    /**
     * The id attribute local name.
     */
    protected String localName;

    /**
     * Creates a new CSSAttributeCondition object.
     */
    public CSSIdCondition(String ns, String ln, String value) {
        super(value);
        namespaceURI = ns;
        localName = ln;
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.Condition#getConditionType()}.
     */
    public short getConditionType() {
        return SAC_ID_CONDITION;
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
        return localName;
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.AttributeCondition#getSpecified()}.
     */
    public boolean getSpecified() {
        return true;
    }

    /**
     * Tests whether this condition matches the given element.
     */
    public boolean match(Element e, String pseudoE) {
        return (e instanceof CSSStylableElement)
            ? ((CSSStylableElement)e).getXMLId().equals(getValue())
            : false;
    }

    /**
     * Fills the given set with the attribute names found in this selector.
     */
    public void fillAttributeSet(Set attrSet) {
        attrSet.add(localName);
    }

    /**
     * Returns the specificity of this condition.
     */
    public int getSpecificity() {
        return 1 << 16;
    }

    /**
     * Returns a text representation of this object.
     */
    public String toString() {
        return '#' + getValue();
    }
}
