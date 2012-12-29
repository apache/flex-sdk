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

import org.apache.flex.forks.batik.dom.util.DOMUtilities;
import org.w3c.dom.DOMException;
import org.w3c.dom.EntityReference;
import org.w3c.dom.Node;

/**
 * This class implements the {@link org.w3c.dom.EntityReference} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: AbstractEntityReference.java 475685 2006-11-16 11:16:05Z cam $
 */
public abstract class AbstractEntityReference
    extends    AbstractParentChildNode
    implements EntityReference {

    /**
     * The node name.
     */
    protected String nodeName;

    /**
     * Creates a new EntityReference object.
     */
    protected AbstractEntityReference() {
    }

    /**
     * Creates a new EntityReference object.
     * @param name The entity name.
     * @param owner The owner document.
     * @exception DOMException
     *   INVALID_CHARACTER_ERR: Raised if the specified name contains an 
     *   illegal character.
     */
    protected AbstractEntityReference(String name, AbstractDocument owner)
        throws DOMException {
        ownerDocument = owner;

        if (owner.getStrictErrorChecking() && !DOMUtilities.isValidName(name)) {
            throw createDOMException(DOMException.INVALID_CHARACTER_ERR,
                                     "xml.name",
                                     new Object[] { name });
        }
        nodeName = name;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getNodeType()}.
     * @return {@link org.w3c.dom.Node#ENTITY_REFERENCE_NODE}
     */
    public short getNodeType() {
        return ENTITY_REFERENCE_NODE;
    }

    /**
     * Sets the name of this node.
     */
    public void setNodeName(String v) {
        nodeName = v;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getNodeName()}.
     * @return {@link #nodeName}.
     */
    public String getNodeName() {
        return nodeName;
    }

    /**
     * Exports this node to the given document.
     */
    protected Node export(Node n, AbstractDocument d) {
        super.export(n, d);
        AbstractEntityReference ae = (AbstractEntityReference)n;
        ae.nodeName = nodeName;
        return n;
    }

    /**
     * Deeply exports this node to the given document.
     */
    protected Node deepExport(Node n, AbstractDocument d) {
        super.deepExport(n, d);
        AbstractEntityReference ae = (AbstractEntityReference)n;
        ae.nodeName = nodeName;
        return n;
    }

    /**
     * Copy the fields of the current node into the given node.
     * @param n a node of the type of this.
     */
    protected Node copyInto(Node n) {
        super.copyInto(n);
        AbstractEntityReference ae = (AbstractEntityReference)n;
        ae.nodeName = nodeName;
        return n;
    }

    /**
     * Deeply copy the fields of the current node into the given node.
     * @param n a node of the type of this.
     */
    protected Node deepCopyInto(Node n) {
        super.deepCopyInto(n);
        AbstractEntityReference ae = (AbstractEntityReference)n;
        ae.nodeName = nodeName;
        return n;
    }

    /**
     * Checks the validity of a node to be inserted.
     */
    protected void checkChildType(Node n, boolean replace) {
        switch (n.getNodeType()) {
        case ELEMENT_NODE:
        case PROCESSING_INSTRUCTION_NODE:
        case COMMENT_NODE:
        case TEXT_NODE:
        case CDATA_SECTION_NODE:
        case ENTITY_REFERENCE_NODE:
        case DOCUMENT_FRAGMENT_NODE:
            break;
        default:
            throw createDOMException
                (DOMException.HIERARCHY_REQUEST_ERR,
                 "child.type",
                 new Object[] { new Integer(getNodeType()),
                                getNodeName(),
                                new Integer(n.getNodeType()),
                                n.getNodeName() });
        }
    }
}
