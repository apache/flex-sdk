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
 * This class implements the {@link org.w3c.dom.Element} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: GenericElementNS.java 475685 2006-11-16 11:16:05Z cam $
 */
public class GenericElementNS extends AbstractElementNS {
    /**
     * The node name.
     */
    protected String nodeName;

    /**
     * Is this element immutable?
     */
    protected boolean readonly;

    /**
     * Creates a new Element object.
     */
    protected GenericElementNS() {
    }

    /**
     * Creates a new Element object.
     * @param nsURI The element namespace URI.
     * @param name  The element qualified name.
     * @param owner The owner document.
     * @exception DOMException
     *    INVALID_CHARACTER_ERR: Raised if the specified qualified name 
     *   contains an illegal character.
     *   <br> NAMESPACE_ERR: Raised if the <code>qualifiedName</code> is 
     *   malformed, if the <code>qualifiedName</code> has a prefix and the 
     *   <code>namespaceURI</code> is <code>null</code> or an empty string, 
     *   or if the <code>qualifiedName</code> has a prefix that is "xml" and 
     *   the <code>namespaceURI</code> is different from 
     *   "http://www.w3.org/XML/1998/namespace"  .
     */
    public GenericElementNS(String nsURI, String name,
                            AbstractDocument owner) {
        super(nsURI, name, owner);
        nodeName = name;
    }

    /**
     * Sets the name of this node.
     */
    public void setNodeName(String v) {
        nodeName = v;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getNodeName()}.
     * @return {@link #nodeName}
     */
    public String getNodeName() {
        return nodeName;
    }

    // ExtendedNode ///////////////////////////////////////////////////

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
     * Exports this node to the given document.
     */
    protected Node export(Node n, AbstractDocument d) {
        GenericElementNS ge = (GenericElementNS)super.export(n, d);
        ge.nodeName = nodeName;
        return n;
    }

    /**
     * Deeply exports this node to the given document.
     */
    protected Node deepExport(Node n, AbstractDocument d) {
        GenericElementNS ge = (GenericElementNS)super.deepExport(n, d);
        ge.nodeName = nodeName;
        return n;
    }

    /**
     * Copy the fields of the current node into the given node.
     * @param n a node of the type of this.
     */
    protected Node copyInto(Node n) {
        GenericElementNS ge = (GenericElementNS)super.copyInto(n);
        ge.nodeName = nodeName;
        return n;
    }

    /**
     * Deeply copy the fields of the current node into the given node.
     * @param n a node of the type of this.
     */
    protected Node deepCopyInto(Node n) {
        GenericElementNS ge = (GenericElementNS)super.deepCopyInto(n);
        ge.nodeName = nodeName;
        return n;
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new GenericElementNS();
    }
}
