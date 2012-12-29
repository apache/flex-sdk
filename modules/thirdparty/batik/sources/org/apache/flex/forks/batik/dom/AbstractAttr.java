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
import org.w3c.dom.Attr;
import org.w3c.dom.DOMException;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.TypeInfo;
import org.w3c.dom.events.MutationEvent;

/**
 * This class implements the {@link org.w3c.dom.Attr} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: AbstractAttr.java 479349 2006-11-26 11:54:23Z cam $
 */
public abstract class AbstractAttr extends AbstractParentNode implements Attr {

    /**
     * The name of this node.
     */
    protected String nodeName;

    /**
     * Whether this attribute was not specified in the original document.
     */
    protected boolean unspecified;

    /**
     * Whether this attribute is an ID attribute
     */
    protected boolean isIdAttr;

    /**
     * The owner element.
     */
    protected AbstractElement ownerElement;

    /**
     * The attribute type information.
     */
    protected TypeInfo typeInfo;

    /**
     * Creates a new Attr object.
     */
    protected AbstractAttr() {
    }

    /**
     * Creates a new Attr object.
     * @param name  The attribute name for validation purposes.
     * @param owner The owner document.
     * @exception DOMException
     *   INVALID_CHARACTER_ERR: if name contains invalid characters,
     */
    protected AbstractAttr(String name, AbstractDocument owner)
        throws DOMException {
        ownerDocument = owner;
        if (owner.getStrictErrorChecking() && !DOMUtilities.isValidName(name)) {
            throw createDOMException(DOMException.INVALID_CHARACTER_ERR,
                                     "xml.name",
                                     new Object[] { name });
        }
    }

    /**
     * Sets the node name.
     */
    public void setNodeName(String v) {
        nodeName = v;
        isIdAttr = ownerDocument.isId(this);
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getNodeName()}.
     * @return {@link #nodeName}.
     */
    public String getNodeName() {
        return nodeName;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getNodeType()}.
     * @return {@link org.w3c.dom.Node#ATTRIBUTE_NODE}
     */
    public short getNodeType() {
        return ATTRIBUTE_NODE;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getNodeValue()}.
     * @return The content of the attribute.
     */
    public String getNodeValue() throws DOMException {
        Node first = getFirstChild();
        if (first == null) {
            return "";
        }
        Node n = first.getNextSibling();
        if (n == null) {
            return first.getNodeValue();
        }
        StringBuffer result = new StringBuffer(first.getNodeValue());
        do {
            result.append(n.getNodeValue());
            n = n.getNextSibling();
        } while (n != null);
        return result.toString();
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#setNodeValue(String)}.
     */
    public void setNodeValue(String nodeValue) throws DOMException {
        if (isReadonly()) {
            throw createDOMException(DOMException.NO_MODIFICATION_ALLOWED_ERR,
                                     "readonly.node",
                                     new Object[] { new Integer(getNodeType()),
                                                    getNodeName() });
        }

        String s = getNodeValue();

        // Remove all the children
        Node n;
        while ((n = getFirstChild()) != null) {
            removeChild(n);
        }

        String val = (nodeValue == null) ? "" : nodeValue;

        // Create and append a new child.
        n = getOwnerDocument().createTextNode(val);
        appendChild(n);

        if (ownerElement != null) {
            ownerElement.fireDOMAttrModifiedEvent(nodeName,
                                                  this,
                                                  s,
                                                  val,
                                                  MutationEvent.MODIFICATION);
        }
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Attr#getName()}.
     * @return {@link #getNodeName()}.
     */
    public String getName() {
        return getNodeName();
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Attr#getSpecified()}.
     * @return !{@link #unspecified}.
     */
    public boolean getSpecified() {
        return !unspecified;
    }

    /**
     * Sets the specified attribute.
     */
    public void setSpecified(boolean v) {
        unspecified = !v;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Attr#getValue()}.
     * @return {@link #getNodeValue()}.
     */
    public String getValue() {
        return getNodeValue();
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Attr#setValue(String)}.
     */
    public void setValue(String value) throws DOMException {
        setNodeValue(value);
    }

    /**
     * Sets the owner element.
     */
    public void setOwnerElement(AbstractElement v) {
        ownerElement = v;
    }
    
    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Attr#getOwnerElement()}.
     */
    public Element getOwnerElement() {
        return ownerElement;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Attr#getSchemaTypeInfo()}.
     */
    public TypeInfo getSchemaTypeInfo() {
        if (typeInfo == null) {
            typeInfo = new AttrTypeInfo();
        }
        return typeInfo;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Attr#isId()}.
     */
    public boolean isId() {
        return isIdAttr;
    }

    /**
     * Sets whether this attribute is an ID attribute.
     */
    public void setIsId(boolean isId) {
        isIdAttr = isId;
    }

    /**
     * Called when a child node has been added.
     */
    protected void nodeAdded(Node n) {
        setSpecified(true);
    }

    /**
     * Called when a child node is going to be removed.
     */
    protected void nodeToBeRemoved(Node n) {
        setSpecified(true);
    }

    /**
     * Exports this node to the given document.
     */
    protected Node export(Node n, AbstractDocument d) {
        super.export(n, d);
        AbstractAttr aa = (AbstractAttr)n;
        aa.nodeName     = nodeName;
        aa.unspecified  = false;
        aa.isIdAttr     = d.isId(aa);
        return n;
    }

    /**
     * Deeply exports this node to the given document.
     */
    protected Node deepExport(Node n, AbstractDocument d) {
        super.deepExport(n, d);
        AbstractAttr aa = (AbstractAttr)n;
        aa.nodeName     = nodeName;
        aa.unspecified  = false;
        aa.isIdAttr     = d.isId(aa);
        return n;
    }

    /**
     * Copy the fields of the current node into the given node.
     * @param n a node of the type of this.
     */
    protected Node copyInto(Node n) {
        super.copyInto(n);
        AbstractAttr aa = (AbstractAttr)n;
        aa.nodeName     = nodeName;
        aa.unspecified  = unspecified;
        aa.isIdAttr     = isIdAttr;
        return n;
    }

    /**
     * Deeply copy the fields of the current node into the given node.
     * @param n a node of the type of this.
     */
    protected Node deepCopyInto(Node n) {
        super.deepCopyInto(n);
        AbstractAttr aa = (AbstractAttr)n;
        aa.nodeName     = nodeName;
        aa.unspecified  = unspecified;
        aa.isIdAttr     = isIdAttr;
        return n;
    }

    /**
     * Checks the validity of a node to be inserted.
     */
    protected void checkChildType(Node n, boolean replace) {
        switch (n.getNodeType()) {
        case TEXT_NODE:
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

    /**
     * Fires a DOMSubtreeModified event.
     */
    protected void fireDOMSubtreeModifiedEvent() {
        AbstractDocument doc = getCurrentDocument();
        if (doc.getEventsEnabled()) {
            super.fireDOMSubtreeModifiedEvent();
            if (getOwnerElement() != null) {
                ((AbstractElement)getOwnerElement()).
                    fireDOMSubtreeModifiedEvent();
            }
        }
    }

    /**
     * Inner class to hold type information about this attribute.
     */
    public class AttrTypeInfo implements TypeInfo {

        /**
         * Type namespace.
         */
        public String getTypeNamespace() {
            return null;
        }

        /**
         * Type name.
         */
        public String getTypeName() {
            return null;
        }

        /**
         * Returns whether this type derives from the given type.
         */
        public boolean isDerivedFrom(String ns, String name, int method) {
            return false;
        }
    }
}
