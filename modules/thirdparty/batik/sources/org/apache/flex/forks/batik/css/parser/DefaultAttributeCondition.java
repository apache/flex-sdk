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
package org.apache.flex.forks.batik.css.parser;


/**
 * This class provides an implementation of the
 * {@link org.w3c.flex.forks.css.sac.AttributeCondition} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: DefaultAttributeCondition.java,v 1.4 2004/08/18 07:13:02 vhardy Exp $
 */
public class DefaultAttributeCondition extends AbstractAttributeCondition {

    /**
     * The attribute's local name.
     */
    protected String localName;

    /**
     * The attribute's namespace URI.
     */
    protected String namespaceURI;

    /**
     * Whether this condition applies to specified attributes.
     */
    protected boolean specified;

    /**
     * Creates a new DefaultAttributeCondition object.
     */
    public DefaultAttributeCondition(String localName,
                                     String namespaceURI,
                                     boolean specified,
                                     String value) {
	super(value);
	this.localName = localName;
	this.namespaceURI = namespaceURI;
	this.specified = specified;
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.flex.forks.css.sac.Condition#getConditionType()}.
     */    
    public short getConditionType() {
	return SAC_ATTRIBUTE_CONDITION;
    }
    
    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.flex.forks.css.sac.AttributeCondition#getNamespaceURI()}.
     */    
    public String getNamespaceURI() {
	return namespaceURI;
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.flex.forks.css.sac.AttributeCondition#getLocalName()}.
     */
    public String getLocalName() {
	return localName;
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.flex.forks.css.sac.AttributeCondition#getSpecified()}.
     */
    public boolean getSpecified() {
	return specified;
    }

    /**
     * Returns a text representation of this object.
     */
    public String toString() {
	if (value == null) {
	    return "[" + localName + "]";
	}
	return "[" + localName + "=\"" + value + "\"]";
    }
}
