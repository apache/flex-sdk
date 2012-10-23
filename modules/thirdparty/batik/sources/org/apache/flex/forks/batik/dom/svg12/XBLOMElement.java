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
import org.apache.flex.forks.batik.dom.svg.SVGOMElement;
import org.apache.flex.forks.batik.util.XBLConstants;

import org.w3c.dom.DOMException;
import org.w3c.dom.Node;

/**
 * Base class for all XBL elements to inherit from.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: XBLOMElement.java 476924 2006-11-19 21:13:26Z dvholten $
 */
public abstract class XBLOMElement extends SVGOMElement
                                   implements XBLConstants {

    /**
     * The element prefix.
     */
    protected String prefix;

    /**
     * Creates a new XBLOMElement.
     */
    protected XBLOMElement() {
    }

    /**
     * Creates a new XBLOMElement.
     * @param prefix The namespace prefix.
     * @param owner  The owner document.
     */
    protected XBLOMElement(String prefix, AbstractDocument owner) {
        ownerDocument = owner;
        setPrefix(prefix);
    }

    /**
     * <b>DOM</b>: Implements {@link Node#getNodeName()}.
     */
    public String getNodeName() {
        if (prefix == null || prefix.equals("")) {
            return getLocalName();
        }

        return prefix + ':' + getLocalName();
    }

    /**
     * <b>DOM</b>: Implements {@link Node#getNamespaceURI()}.
     */
    public String getNamespaceURI() {
        return XBL_NAMESPACE_URI;
    }

    /**
     * <b>DOM</b>: Implements {@link Node#setPrefix(String)}.
     */
    public void setPrefix(String prefix) throws DOMException {
        if (isReadonly()) {
            throw createDOMException(DOMException.NO_MODIFICATION_ALLOWED_ERR,
                                     "readonly.node",
                                     new Object[] { new Integer(getNodeType()),
                                                    getNodeName() });
        }
        if (prefix != null &&
            !prefix.equals("") &&
            !DOMUtilities.isValidName(prefix)) {
            throw createDOMException(DOMException.INVALID_CHARACTER_ERR,
                                     "prefix",
                                     new Object[] { new Integer(getNodeType()),
                                                    getNodeName(),
                                                    prefix });
        }
        this.prefix = prefix;
    }

    /**
     * Exports this node to the given document.
     */
    protected Node export(Node n, AbstractDocument d) {
        super.export(n, d);
        XBLOMElement e = (XBLOMElement)n;
        e.prefix = prefix;
        return n;
    }

    /**
     * Deeply exports this node to the given document.
     */
    protected Node deepExport(Node n, AbstractDocument d) {
        super.deepExport(n, d);
        XBLOMElement e = (XBLOMElement)n;
        e.prefix = prefix;
        return n;
    }

    /**
     * Copy the fields of the current node into the given node.
     * @param n a node of the type of this.
     */
    protected Node copyInto(Node n) {
        super.copyInto(n);
        XBLOMElement e = (XBLOMElement)n;
        e.prefix = prefix;
        return n;
    }

    /**
     * Deeply copy the fields of the current node into the given node.
     * @param n a node of the type of this.
     */
    protected Node deepCopyInto(Node n) {
        super.deepCopyInto(n);
        XBLOMElement e = (XBLOMElement)n;
        e.prefix = prefix;
        return n;
    }
}
