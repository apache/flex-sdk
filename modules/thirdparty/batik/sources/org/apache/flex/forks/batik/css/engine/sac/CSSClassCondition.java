/*

   Copyright 2002-2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.css.engine.sac;

import org.apache.flex.forks.batik.css.engine.CSSStylableElement;
import org.w3c.dom.Element;

/**
 * This class provides an implementation of the
 * {@link org.w3c.flex.forks.css.sac.AttributeCondition} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: CSSClassCondition.java,v 1.6 2004/08/18 07:12:51 vhardy Exp $
 */
public class CSSClassCondition extends CSSAttributeCondition {

    /**
     * Creates a new CSSAttributeCondition object.
     */
    public CSSClassCondition(String localName,
                             String namespaceURI,
                             String value) {
	super(localName, namespaceURI, true, value);
    }
    
    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.flex.forks.css.sac.Condition#getConditionType()}.
     */    
    public short getConditionType() {
	return SAC_CLASS_CONDITION;
    }
    
    /**
     * Tests whether this condition matches the given element.
     */
    public boolean match(Element e, String pseudoE) {
        if (!(e instanceof CSSStylableElement))
            return false;  // Can't match an unstylable element.
	String attr = ((CSSStylableElement)e).getCSSClass();
	String val = getValue();
	int i = attr.indexOf(val);
	if (i == -1) {
	    return false;
	}
	if (i != 0 && !Character.isSpaceChar(attr.charAt(i - 1))) {
	    return false;
	}
	int j = i + val.length();
	return (j == attr.length() ||
		(j < attr.length() && Character.isSpaceChar(attr.charAt(j))));
    }

    /**
     * Returns a text representation of this object.
     */
    public String toString() {
	return "." + getValue();
    }
}
