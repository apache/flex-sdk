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
package org.apache.flex.forks.batik.css.parser;

/**
 * This class provides an implementation of the
 * {@link org.w3c.flex.forks.css.sac.AttributeCondition} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: DefaultIdCondition.java,v 1.3 2004/08/18 07:13:02 vhardy Exp $
 */
public class DefaultIdCondition extends AbstractAttributeCondition {

    /**
     * Creates a new DefaultAttributeCondition object.
     */
    public DefaultIdCondition(String value) {
	super(value);
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.flex.forks.css.sac.Condition#getConditionType()}.
     */    
    public short getConditionType() {
	return SAC_ID_CONDITION;
    }
    
    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.flex.forks.css.sac.AttributeCondition#getNamespaceURI()}.
     */    
    public String getNamespaceURI() {
	return null;
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.flex.forks.css.sac.AttributeCondition#getLocalName()}.
     */
    public String getLocalName() {
	return "id";
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.flex.forks.css.sac.AttributeCondition#getSpecified()}.
     */
    public boolean getSpecified() {
	return true;
    }

    /**
     * Returns a text representation of this object.
     */
    public String toString() {
	return "#" + getValue();
    }
}
