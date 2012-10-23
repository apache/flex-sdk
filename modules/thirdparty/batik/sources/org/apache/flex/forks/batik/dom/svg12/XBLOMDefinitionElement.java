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
package org.apache.flex.forks.batik.dom.svg12;

import org.apache.flex.forks.batik.dom.AbstractDocument;
import org.apache.flex.forks.batik.dom.util.DOMUtilities;

import org.w3c.dom.DOMException;
import org.w3c.dom.Node;

/**
 * This class implements the xbl:definition element.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: XBLOMDefinitionElement.java 475477 2006-11-15 22:44:28Z cam $
 */
public class XBLOMDefinitionElement extends XBLOMElement {

    /**
     * Creates a new XBLOMDefinitionElement.
     */
    protected XBLOMDefinitionElement() {
    }

    /**
     * Creates a new XBLOMDefinitionElement.
     * @param prefix The namespace prefix.
     * @param owner  The owner document.
     */
    public XBLOMDefinitionElement(String prefix, AbstractDocument owner) {
        super(prefix, owner);
    }

    /**
     * <b>DOM</b>: Implements {@link Node#getLocalName()}.
     */
    public String getLocalName() {
        return XBL_DEFINITION_TAG;
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new XBLOMDefinitionElement();
    }

    /**
     * Returns the namspace URI of elements this definition will bind.
     */
    public String getElementNamespaceURI() {
        String qname = getAttributeNS(null, XBL_ELEMENT_ATTRIBUTE);
        String prefix = DOMUtilities.getPrefix(qname);
        String ns = lookupNamespaceURI(prefix);
        if (ns == null) {
            throw createDOMException
                        (DOMException.NAMESPACE_ERR,
                         "prefix",
                         new Object[] { new Integer(getNodeType()),
                                        getNodeName(),
                                        prefix });
        }
        return ns;
    }

    /**
     * Returns the local name of elements this definition will bind.
     */
    public String getElementLocalName() {
        String qname = getAttributeNS(null, "element");
        return DOMUtilities.getLocalName(qname);
    }
}
