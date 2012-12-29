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

import org.w3c.dom.Element;

/**
 * This class provides an implementation of the
 * {@link org.w3c.css.sac.AttributeCondition} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: CSSBeginHyphenAttributeCondition.java 478160 2006-11-22 13:35:06Z dvholten $
 */
public class CSSBeginHyphenAttributeCondition
    extends CSSAttributeCondition {

    /**
     * Creates a new CSSAttributeCondition object.
     */
    public CSSBeginHyphenAttributeCondition(String localName,
                                              String namespaceURI,
                                              boolean specified,
                                              String value) {
        super(localName, namespaceURI, specified, value);
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.Condition#getConditionType()}.
     */
    public short getConditionType() {
        return SAC_BEGIN_HYPHEN_ATTRIBUTE_CONDITION;
    }

    /**
     * Tests whether this condition matches the given element.
     */
    public boolean match(Element e, String pseudoE) {
        return e.getAttribute(getLocalName()).startsWith(getValue());
    }

    /**
     * Returns a text representation of this object.
     */
    public String toString() {
        return '[' + getLocalName() + "|=\"" + getValue() + "\"]";
    }
}
