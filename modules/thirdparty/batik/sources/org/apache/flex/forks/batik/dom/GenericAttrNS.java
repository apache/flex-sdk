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
package org.apache.flex.forks.batik.dom;

import org.w3c.dom.DOMException;
import org.w3c.dom.Node;

/**
 * This class implements the {@link org.w3c.dom.Attr} interface with
 * support for namespaces.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: GenericAttrNS.java 475685 2006-11-16 11:16:05Z cam $
 */
public class GenericAttrNS extends AbstractAttrNS {

    /**
     * Is this attribute immutable?
     */
    protected boolean readonly;

    /**
     * Creates a new Attr object.
     */
    protected GenericAttrNS() {
    }

    /**
     * Creates a new Attr object.
     * @param nsURI The element namespace URI.
     * @param qname The attribute qualified name for validation purposes.
     * @param owner The owner document.
     * @exception DOMException
     *    INVALID_CHARACTER_ERR: Raised if the specified qualified name 
     *   contains an illegal character.
     *   <br> NAMESPACE_ERR: Raised if the <code>qualifiedName</code> is 
     *   malformed, if the <code>qualifiedName</code> has a prefix and the 
     *   <code>namespaceURI</code> is <code>null</code> or an empty string, 
     *   if the <code>qualifiedName</code> has a prefix that is "xml" and the 
     *   <code>namespaceURI</code> is different from 
     *   "http://www.w3.org/XML/1998/namespace", if the 
     *   <code>qualifiedName</code> has a prefix that is "xmlns" and the 
     *   <code>namespaceURI</code> is different from 
     *   "http://www.w3.org/2000/xmlns/", or if the <code>qualifiedName</code>
     *    is "xmlns" and the <code>namespaceURI</code> is different from 
     *   "http://www.w3.org/2000/xmlns/".
     */
    public GenericAttrNS(String nsURI, String qname, AbstractDocument owner)
        throws DOMException {
        super(nsURI, qname, owner);
        setNodeName(qname);
    }

    /**
     * Tests whether this node is readonly.
     */
    public boolean isReadonly() {
        return readonly;
    }

    /**
     * Sets this node readonly attribute.
     */
    public void setReadonly(boolean v) {
        readonly = v;
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new GenericAttrNS();
    }
}
