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

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import org.apache.flex.forks.batik.dom.events.DOMMutationEvent;
import org.apache.flex.forks.batik.dom.events.EventSupport;
import org.apache.flex.forks.batik.dom.events.NodeEventTarget;
import org.apache.flex.forks.batik.dom.util.DOMUtilities;
import org.apache.flex.forks.batik.dom.util.XMLSupport;
import org.apache.flex.forks.batik.dom.xbl.NodeXBL;
import org.apache.flex.forks.batik.dom.xbl.XBLManagerData;
import org.apache.flex.forks.batik.util.ParsedURL;
import org.apache.flex.forks.batik.util.XMLConstants;

import org.w3c.dom.Attr;
import org.w3c.dom.DOMException;
import org.w3c.dom.Document;
import org.w3c.dom.DocumentType;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.w3c.dom.UserDataHandler;
import org.w3c.dom.events.Event;
import org.w3c.dom.events.EventException;
import org.w3c.dom.events.EventListener;
import org.w3c.dom.events.MutationEvent;

/**
 * This class implements the {@link org.w3c.dom.Node} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: AbstractNode.java 594018 2007-11-12 04:17:41Z cam $
 */
public abstract class AbstractNode
    implements ExtendedNode,
               NodeXBL,
               XBLManagerData,
               Serializable {

    /**
     * An empty instance of NodeList.
     */
    public static final NodeList EMPTY_NODE_LIST = new NodeList() {
        public Node item(int i) { return null; }
        public int  getLength() { return 0; }
    };

    /**
     * The owner document.
     */
    protected AbstractDocument ownerDocument;

    /**
     * The event support.
     */
    protected transient EventSupport eventSupport;

    /**
     * User data.
     */
    protected HashMap userData;

    /**
     * User data handlers.
     */
    protected HashMap userDataHandlers;

    /**
     * The XBL manager data.
     */
    protected Object managerData;

    /**
     * Sets the name of this node.
     * Do nothing.
     */
    public void setNodeName(String v) {
    }

    /**
     * Sets the owner document of this node.
     */
    public void setOwnerDocument(Document doc) {
        ownerDocument = (AbstractDocument)doc;
    }

     /**
     * Sets the value of the specified attribute. This method only applies
     * to Attr objects.
     */
    public void setSpecified(boolean v) {
        throw createDOMException(DOMException.INVALID_STATE_ERR,
                                 "node.type",
                                 new Object[] { new Integer(getNodeType()),
                                                getNodeName()});
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getNodeValue()}.
     * @return null.
     */
    public String getNodeValue() throws DOMException {
        return null;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#setNodeValue(String)}.
     * Do nothing.
     */
    public void setNodeValue(String nodeValue) throws DOMException {
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getParentNode()}.
     * @return null.
     */
    public Node getParentNode() {
        return null;
    }

    /**
     * Sets the parent node.
     * Throws a HIERARCHY_REQUEST_ERR {@link org.w3c.dom.DOMException}.
     */
    public void setParentNode(Node v) {
        throw createDOMException(DOMException.HIERARCHY_REQUEST_ERR,
                                 "parent.not.allowed",
                                 new Object[] { new Integer(getNodeType()),
                                                getNodeName() });
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getChildNodes()}.
     * @return {@link #EMPTY_NODE_LIST}.
     */
    public NodeList getChildNodes() {
        return EMPTY_NODE_LIST;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getFirstChild()}.
     * @return null.
     */
    public Node getFirstChild() {
        return null;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getLastChild()}.
     * @return null.
     */
    public Node getLastChild() {
        return null;
    }

    /**
     * Sets the node immediately preceding this node.
     * Throws a HIERARCHY_REQUEST_ERR {@link org.w3c.dom.DOMException}.
     */
    public void setPreviousSibling(Node n) {
        throw createDOMException(DOMException.HIERARCHY_REQUEST_ERR,
                                 "sibling.not.allowed",
                                 new Object[] { new Integer(getNodeType()),
                                                getNodeName() });
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getPreviousSibling()}.
     * @return null.
     */
    public Node getPreviousSibling() {
        return null;
    }

    /**
     * Sets the node immediately following this node.
     * Throws a HIERARCHY_REQUEST_ERR {@link org.w3c.dom.DOMException}.
     */
    public void setNextSibling(Node n) {
        throw createDOMException(DOMException.HIERARCHY_REQUEST_ERR,
                                 "sibling.not.allowed",
                                 new Object[] { new Integer(getNodeType()),
                                                getNodeName() });
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getNextSibling()}.
     * @return null.
     */
    public Node getNextSibling() {
        return null;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#hasAttributes()}.
     * @return false.
     */
    public boolean hasAttributes() {
        return false;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getAttributes()}.
     * @return null.
     */
    public NamedNodeMap getAttributes() {
        return null;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getOwnerDocument()}.
     * @return {@link #ownerDocument}.
     */
    public Document getOwnerDocument() {
        return ownerDocument;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getNamespaceURI()}.
     * @return null.
     */
    public String getNamespaceURI() {
        return null;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.Node#insertBefore(Node, Node)}.
     * Throws a HIERARCHY_REQUEST_ERR {@link org.w3c.dom.DOMException}.
     */
    public Node insertBefore(Node newChild, Node refChild)
        throws DOMException {
        throw createDOMException(DOMException.HIERARCHY_REQUEST_ERR,
                                 "children.not.allowed",
                                 new Object[] { new Integer(getNodeType()),
                                                getNodeName() });
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.Node#replaceChild(Node, Node)}.
     * Throws a HIERARCHY_REQUEST_ERR {@link org.w3c.dom.DOMException}.
     */
    public Node replaceChild(Node newChild, Node oldChild)
        throws DOMException {
        throw createDOMException(DOMException.HIERARCHY_REQUEST_ERR,
                                 "children.not.allowed",
                                 new Object[] { new Integer(getNodeType()),
                                                getNodeName()});
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#removeChild(Node)}.
     * Throws a HIERARCHY_REQUEST_ERR {@link org.w3c.dom.DOMException}.
     */
    public Node removeChild(Node oldChild) throws DOMException {
        throw createDOMException(DOMException.HIERARCHY_REQUEST_ERR,
                                 "children.not.allowed",
                                 new Object[] { new Integer(getNodeType()),
                                                getNodeName() });
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#appendChild(Node)}.
     * Throws a HIERARCHY_REQUEST_ERR {@link org.w3c.dom.DOMException}.
     */
    public Node appendChild(Node newChild) throws DOMException {
        throw createDOMException(DOMException.HIERARCHY_REQUEST_ERR,
                                 "children.not.allowed",
                                 new Object[] { new Integer(getNodeType()),
                                                getNodeName() });
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#hasChildNodes()}.
     * @return false.
     */
    public boolean hasChildNodes() {
        return false;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#cloneNode(boolean)}.
     */
    public Node cloneNode(boolean deep) {
        Node n = deep ? deepCopyInto(newNode()) : copyInto(newNode());
        fireUserDataHandlers(UserDataHandler.NODE_CLONED, this, n);
        return n;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#normalize()}.
     * Do nothing.
     */
    public void normalize() {
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.Node#isSupported(String,String)}.
     */
    public boolean isSupported(String feature, String version) {
        return getCurrentDocument().getImplementation().hasFeature(feature,
                                                                   version);
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getPrefix()}.
     */
    public String getPrefix() {
        return (getNamespaceURI() == null)
            ? null
            : DOMUtilities.getPrefix(getNodeName());
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#setPrefix(String)}.
     */
    public void setPrefix(String prefix) throws DOMException {
        if (isReadonly()) {
            throw createDOMException(DOMException.NO_MODIFICATION_ALLOWED_ERR,
                                     "readonly.node",
                                     new Object[] { new Integer(getNodeType()),
                                                    getNodeName() });
        }
        String uri = getNamespaceURI();
        if (uri == null) {
            throw createDOMException(DOMException.NAMESPACE_ERR,
                                     "namespace",
                                     new Object[] { new Integer(getNodeType()),
                                                    getNodeName() });
        }

        String name = getLocalName();
        if (prefix == null) {
            // prefix null is explicitly allowed by org.w3c.dom.Node#setPrefix(String)
            setNodeName(name);
            return;
        }

        // prefix is guaranteed to be non-null here...
        if (!prefix.equals("") && !DOMUtilities.isValidName(prefix)) {
            throw createDOMException(DOMException.INVALID_CHARACTER_ERR,
                                     "prefix",
                                     new Object[] { new Integer(getNodeType()),
                                                    getNodeName(),
                                                    prefix });
        }
        if (!DOMUtilities.isValidPrefix(prefix)) {
            throw createDOMException(DOMException.NAMESPACE_ERR,
                                     "prefix",
                                     new Object[] { new Integer(getNodeType()),
                                                    getNodeName(),
                                                    prefix });
        }
        if ((prefix.equals("xml") &&
             !XMLSupport.XML_NAMESPACE_URI.equals(uri)) ||
            (prefix.equals("xmlns") &&
             !XMLSupport.XMLNS_NAMESPACE_URI.equals(uri))) {
            throw createDOMException(DOMException.NAMESPACE_ERR,
                                     "namespace.uri",
                                     new Object[] { new Integer(getNodeType()),
                                                    getNodeName(),
                                                    uri });
        }
        setNodeName(prefix + ':' + name);
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getLocalName()}.
     */
    public String getLocalName() {
        return (getNamespaceURI() == null)
            ? null
            : DOMUtilities.getLocalName(getNodeName());
    }

    /**
     * Creates an exception with the appropriate error message.
     */
    public DOMException createDOMException(short    type,
                                           String   key,
                                           Object[] args) {
        try {
            return new DOMException
                (type, getCurrentDocument().formatMessage(key, args));
        } catch (Exception e) {
            return new DOMException(type, key);
        }
    }

    /**
     * Returns the xml:base attribute value of the given element,
     * resolving any dependency on parent bases if needed.
     */
    protected String getCascadedXMLBase(Node node) {
        String base = null;
        Node n = node.getParentNode();
        while (n != null) {
            if (n.getNodeType() == Node.ELEMENT_NODE) {
                base = getCascadedXMLBase(n);
                break;
            }
            n = n.getParentNode();
        }
        if (base == null) {
            AbstractDocument doc;
            if (node.getNodeType() == Node.DOCUMENT_NODE) {
                doc = (AbstractDocument) node;
            } else {
                doc = (AbstractDocument) node.getOwnerDocument();
            }
            base = doc.getDocumentURI();
        }
        while (node != null && node.getNodeType() != Node.ELEMENT_NODE) {
            node = node.getParentNode();
        }
        if (node == null) {
            return base;
        }
        Element e = (Element) node;
        Attr attr = e.getAttributeNodeNS(XMLConstants.XML_NAMESPACE_URI,
                                         XMLConstants.XML_BASE_ATTRIBUTE);
        if (attr != null) {
            if (base == null) {
                base = attr.getNodeValue();
            } else {
                base = new ParsedURL(base, attr.getNodeValue()).toString();
            }
        }
        return base;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getBaseURI()}.
     */
    public String getBaseURI() {
        return getCascadedXMLBase(this);
    }

    public static String getBaseURI(Node n) {
        return ((AbstractNode) n).getBaseURI();
    }

    // DocumentPosition constants from DOM Level 3 Core org.w3c.dom.Node
    // interface.

    public static final short DOCUMENT_POSITION_DISCONNECTED = 0x01;
    public static final short DOCUMENT_POSITION_PRECEDING = 0x02;
    public static final short DOCUMENT_POSITION_FOLLOWING = 0x04;
    public static final short DOCUMENT_POSITION_CONTAINS = 0x08;
    public static final short DOCUMENT_POSITION_CONTAINED_BY = 0x10;
    public static final short DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC = 0x20;

    /**
     * <b>DOM</b>: Implements
     * {@link org.w3c.dom.Node#compareDocumentPosition(Node)}.
     * XXX Doesn't handle notation or entity nodes.
     */
    public short compareDocumentPosition(Node other) throws DOMException {
        if (this == other) {
            return 0;
        }
        ArrayList a1 = new ArrayList(10);
        ArrayList a2 = new ArrayList(10);
        int c1 = 0;
        int c2 = 0;
        Node n;
        if (getNodeType() == ATTRIBUTE_NODE) {
            a1.add(this);
            c1++;
            n = ((Attr) this).getOwnerElement();
            if (other.getNodeType() == ATTRIBUTE_NODE) {
                Attr otherAttr = (Attr) other;
                if (n == otherAttr.getOwnerElement()) {
                    if (hashCode() < ((Attr) other).hashCode()) {
                        return DOCUMENT_POSITION_PRECEDING
                            | DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
                    } else {
                        return DOCUMENT_POSITION_FOLLOWING
                            | DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC;
                    }
                }
            }
        } else {
            n = this;
        }
        while (n != null) {
            if (n == other) {
                return DOCUMENT_POSITION_CONTAINED_BY
                    | DOCUMENT_POSITION_FOLLOWING;
            }
            a1.add(n);
            c1++;
            n = n.getParentNode();
        }
        if (other.getNodeType() == ATTRIBUTE_NODE) {
            a2.add(other);
            c2++;
            n = ((Attr) other).getOwnerElement();
        } else {
            n = other;
        }
        while (n != null) {
            if (n == this) {
                return DOCUMENT_POSITION_CONTAINS
                    | DOCUMENT_POSITION_PRECEDING;
            }
            a2.add(n);
            c2++;
            n = n.getParentNode();
        }
        int i1 = c1 - 1;
        int i2 = c2 - 1;
        if (a1.get(i1) != a2.get(i2)) {
            if (hashCode() < other.hashCode()) {
                return DOCUMENT_POSITION_DISCONNECTED
                    | DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC
                    | DOCUMENT_POSITION_PRECEDING;
            } else {
                return DOCUMENT_POSITION_DISCONNECTED
                    | DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC
                    | DOCUMENT_POSITION_FOLLOWING;
            }
        }
        Object n1 = a1.get(i1);
        Object n2 = a2.get(i2);
        while (n1 == n2) {
            n = (Node) n1;
            n1 = a1.get(--i1);
            n2 = a2.get(--i2);
        }
        for (n = n.getFirstChild(); n != null; n = n.getNextSibling()) {
            if (n == n1) {
                return DOCUMENT_POSITION_PRECEDING;
            } else if (n == n2) {
                return DOCUMENT_POSITION_FOLLOWING;
            }
        }
        return DOCUMENT_POSITION_DISCONNECTED;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getTextContent()}.
     */
    public String getTextContent() {
        return null;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#setTextContent(String)}.
     */
    public void setTextContent(String s) throws DOMException {
        if (isReadonly()) {
            throw createDOMException(DOMException.NO_MODIFICATION_ALLOWED_ERR,
                                     "readonly.node",
                                     new Object[] { new Integer(getNodeType()),
                                                    getNodeName() });
        }
        if (getNodeType() != DOCUMENT_TYPE_NODE) {
            while (getFirstChild() != null) {
                removeChild(getFirstChild());
            }
            appendChild(getOwnerDocument().createTextNode(s));
        }
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#isSameNode(Node)}.
     */
    public boolean isSameNode(Node other) {
        return this == other;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#lookupPrefix(String)}.
     */
    public String lookupPrefix(String namespaceURI) {
        if (namespaceURI == null || namespaceURI.length() == 0) {
            return null;
        }
        int type = getNodeType();
        switch (type) {
            case Node.ELEMENT_NODE:
                return lookupNamespacePrefix(namespaceURI, (Element) this);
            case Node.DOCUMENT_NODE:
                AbstractNode de
                    = (AbstractNode) ((Document) this).getDocumentElement();
                return de.lookupPrefix(namespaceURI);
            case Node.ENTITY_NODE :
            case Node.NOTATION_NODE:
            case Node.DOCUMENT_FRAGMENT_NODE:
            case Node.DOCUMENT_TYPE_NODE:
                return null;
            case Node.ATTRIBUTE_NODE:
                AbstractNode ownerElement
                    = (AbstractNode) ((Attr) this).getOwnerElement();
                if (ownerElement != null) {
                    return ownerElement.lookupPrefix(namespaceURI);
                }
                return null;
            default:
                for (Node n = this.getParentNode();
                        n != null;
                        n = n.getParentNode()) {
                    if (n.getNodeType() == ELEMENT_NODE) {
                        return ((AbstractNode) n).lookupPrefix(namespaceURI);
                    }
                }
                return null;
        }
    }

    /**
     * Helper function for {@link #lookupPrefix}.
     */
    protected String lookupNamespacePrefix(String namespaceURI,
                                           Element originalElement) {
        String ns = originalElement.getNamespaceURI();
        String prefix = originalElement.getPrefix();
        if (ns != null
                && ns.equals(namespaceURI)
                && prefix != null) {
            String pns =
                ((AbstractNode) originalElement).lookupNamespaceURI(prefix);
            if (pns != null && pns.equals(namespaceURI)) {
                return prefix;
            }
        }
        NamedNodeMap nnm = originalElement.getAttributes();
        if (nnm != null) {
            for (int i = 0; i < nnm.getLength(); i++) {
                Node attr = nnm.item(i);
                if (XMLConstants.XMLNS_PREFIX.equals(attr.getPrefix())
                        && attr.getNodeValue().equals(namespaceURI)) {
                    String ln = attr.getLocalName();
                    AbstractNode oe = (AbstractNode) originalElement;
                    String pns = oe.lookupNamespaceURI(ln);
                    if (pns != null && pns.equals(namespaceURI)) {
                        return ln;
                    }
                }
            }
        }
        for (Node n = getParentNode(); n != null; n = n.getParentNode()) {
            if (n.getNodeType() == ELEMENT_NODE) {
                return ((AbstractNode) n).lookupNamespacePrefix
                    (namespaceURI, originalElement);
            }
        }
        return null;
    }

    /**
     * <b>DOM</b>: Implements
     * {@link org.w3c.dom.Node#isDefaultNamespace(String)}.
     */
    public boolean isDefaultNamespace(String namespaceURI) {
        switch (getNodeType()) {
            case DOCUMENT_NODE:
                AbstractNode de
                    = (AbstractNode) ((Document) this).getDocumentElement();
                return de.isDefaultNamespace(namespaceURI);
            case ENTITY_NODE:
            case NOTATION_NODE:
            case DOCUMENT_TYPE_NODE:
            case DOCUMENT_FRAGMENT_NODE:
                return false;
            case ATTRIBUTE_NODE:
                AbstractNode owner
                    = (AbstractNode) ((Attr) this).getOwnerElement();
                if (owner != null) {
                    return owner.isDefaultNamespace(namespaceURI);
                }
                return false;
            case ELEMENT_NODE:
                if (getPrefix() == null) {
                    String ns = getNamespaceURI();
                    return ns == null && namespaceURI == null
                        || ns != null && ns.equals(namespaceURI);
                }
                NamedNodeMap nnm = getAttributes();
                if (nnm != null) {
                    for (int i = 0; i < nnm.getLength(); i++) {
                        Node attr = nnm.item(i);
                        if (XMLConstants.XMLNS_PREFIX
                                .equals(attr.getLocalName())) {
                            return attr.getNodeValue().equals(namespaceURI);
                        }
                    }
                }
                // fall through
            default:
                for (Node n = this; n != null; n = n.getParentNode()) {
                    if (n.getNodeType() == ELEMENT_NODE) {
                        AbstractNode an = (AbstractNode) n;
                        return an.isDefaultNamespace(namespaceURI);
                    }
                }
                return false;
        }
    }

    /**
     * <b>DOM</b>: Implements
     * {@link org.w3c.dom.Node#lookupNamespaceURI(String)}.
     */
    public String lookupNamespaceURI(String prefix) {
        switch (getNodeType()) {
            case DOCUMENT_NODE:
                AbstractNode de =
                    (AbstractNode) ((Document) this).getDocumentElement();
                return de.lookupNamespaceURI(prefix);
            case ENTITY_NODE:
            case NOTATION_NODE:
            case DOCUMENT_TYPE_NODE:
            case DOCUMENT_FRAGMENT_NODE:
                return null;
            case ATTRIBUTE_NODE:
                AbstractNode owner
                    = (AbstractNode) ((Attr) this).getOwnerElement();
                if (owner != null) {
                    return owner.lookupNamespaceURI(prefix);
                }
                return null;
            case ELEMENT_NODE:
                /*String ns = getNamespaceURI();
                if (ns != null && compareStrings(getPrefix(), prefix)) {
                    return getNamespaceURI();
                } */
                NamedNodeMap nnm = getAttributes();
                if (nnm != null) {
                    for (int i = 0; i < nnm.getLength(); i++) {
                        Node attr = nnm.item(i);
                        String attrPrefix = attr.getPrefix();
                        String localName = attr.getLocalName();
                        if (localName == null) {
                            localName = attr.getNodeName();
                        }
                        if (XMLConstants.XMLNS_PREFIX.equals(attrPrefix)
                                && compareStrings(localName, prefix)
                                || XMLConstants.XMLNS_PREFIX.equals(localName)
                                && prefix == null) {
                            String value = attr.getNodeValue();
                            if (value.length() > 0) {
                                return value;
                            }
                            return null;
                        }
                    }
                }
                // fall through
            default:
                for (Node n = this.getParentNode(); n != null; n = n.getParentNode()) {
                    if (n.getNodeType() == ELEMENT_NODE) {
                        AbstractNode an = (AbstractNode) n;
                        return an.lookupNamespaceURI(prefix);
                    }
                }
                return null;
        }
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#isEqualNode(Node)}.
     */
    public boolean isEqualNode(Node other) {
        if (other == null) {
            return false;
        }
        int nt = other.getNodeType();
        if (nt != getNodeType()
                || !compareStrings(getNodeName(), other.getNodeName())
                || !compareStrings(getLocalName(), other.getLocalName())
                || !compareStrings(getPrefix(), other.getPrefix())
                || !compareStrings(getNodeValue(), other.getNodeValue())
                || !compareStrings(getNodeValue(), other.getNodeValue())
                || !compareNamedNodeMaps(getAttributes(),
                                         other.getAttributes())) {
            return false;
        }
        if (nt == Node.DOCUMENT_TYPE_NODE) {
            DocumentType dt1 = (DocumentType) this;
            DocumentType dt2 = (DocumentType) other;
            if (!compareStrings(dt1.getPublicId(), dt2.getPublicId())
                    || !compareStrings(dt1.getSystemId(), dt2.getSystemId())
                    || !compareStrings(dt1.getInternalSubset(),
                                       dt2.getInternalSubset())
                    || !compareNamedNodeMaps(dt1.getEntities(),
                                             dt2.getEntities())
                    || !compareNamedNodeMaps(dt1.getNotations(),
                                             dt2.getNotations())) {
                return false;
            }
        }
        Node n = getFirstChild();
        Node m = other.getFirstChild();
        if (n != null && m != null) {
            if (!((AbstractNode) n).isEqualNode(m)) {
                return false;
            }
        }
        return n == m;
    }

    /**
     * Compare two strings for equality.
     */
    protected boolean compareStrings(String s1, String s2) {
        return s1 != null && s1.equals(s2) || s1 == null && s2 == null;
    }

    /**
     * Compare two NamedNodeMaps for equality.
     */
    protected boolean compareNamedNodeMaps(NamedNodeMap nnm1,
                                           NamedNodeMap nnm2) {
        if (nnm1 == null && nnm2 != null
                || nnm1 != null && nnm2 == null) {
            return false;
        }
        if (nnm1 != null) {
            int len = nnm1.getLength();
            if (len != nnm2.getLength()) {
                return false;
            }
            for (int i = 0; i < len; i++) {
                Node n1 = nnm1.item(i);
                String n1ln = n1.getLocalName();
                Node n2;
                if (n1ln != null) {
                    n2 = nnm2.getNamedItemNS(n1.getNamespaceURI(), n1ln);
                } else {
                    n2 = nnm2.getNamedItem(n1.getNodeName());
                }
                if (!((AbstractNode) n1).isEqualNode(n2)) {
                    return false;
                }
            }
        }
        return true;
    }

    /**
     * <b>DOM</b>: Implements
     * {@link org.w3c.dom.Node#getFeature(String,String)}.
     */
    public Object getFeature(String feature, String version) {
        return null;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getUserData(String)}.
     */
    public Object getUserData(String key) {
        if (userData == null) {
            return null;
        }
        return userData.get(key);
    }

    /**
     * <b>DOM</b>: Implements
     * {@link org.w3c.dom.Node#setUserData(String,Object,UserDataHandler)}.
     */
    public Object setUserData(String key, Object data, UserDataHandler handler) {
        if (userData == null) {
            userData = new HashMap();
            userDataHandlers = new HashMap();
        }
        if (data == null) {
            userData.remove(key);
            return userDataHandlers.remove(key);
        }
        userDataHandlers.put(key, handler);
        return userData.put(key, data);
    }

    /**
     * Fire any UserDataHandlers on the given oldNode.
     */
    protected void fireUserDataHandlers(short type,
                                        Node oldNode,
                                        Node newNode) {
        AbstractNode an = (AbstractNode) oldNode;
        if (an.userData != null) {
            Iterator i = an.userData.entrySet().iterator();
            while (i.hasNext()) {
                Map.Entry e = (Map.Entry) i.next();
                UserDataHandler h
                    = (UserDataHandler) an.userDataHandlers.get(e.getKey());
                if (h != null) {
                    h.handle(type,
                             (String) e.getKey(),
                             e.getValue(),
                             oldNode,
                             newNode);
                }
            }
        }
    }

    // EventTarget ////////////////////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements
     * {@link
     * org.w3c.dom.events.EventTarget#addEventListener(String,EventListener,boolean)}.
     */
    public void addEventListener(String type,
                                 EventListener listener,
                                 boolean useCapture) {
        if (eventSupport == null) {
            initializeEventSupport();
        }
        eventSupport.addEventListener(type, listener, useCapture);
    }

    /**
     * <b>DOM</b>: Implements
     * {@link
     * NodeEventTarget#addEventListenerNS(String,String,EventListener,boolean,Object)}.
     */
    public void addEventListenerNS(String namespaceURI,
                                   String type,
                                   EventListener listener,
                                   boolean useCapture,
                                   Object evtGroup) {
        if (eventSupport == null) {
            initializeEventSupport();
        }
        if (namespaceURI != null && namespaceURI.length() == 0) {
            namespaceURI = null;
        }
        eventSupport.addEventListenerNS(namespaceURI,
                                        type,
                                        listener,
                                        useCapture,
                                        evtGroup);
    }

    /**
     * <b>DOM</b>: Implements
     * {@link
     * org.w3c.dom.events.EventTarget#removeEventListener(String,EventListener,boolean)}.
     */
    public void removeEventListener(String type,
                                    EventListener listener,
                                    boolean useCapture) {
        if (eventSupport != null) {
            eventSupport.removeEventListener(type, listener, useCapture);
        }
    }

    /**
     * <b>DOM</b>: Implements
     * {@link
     * NodeEventTarget#removeEventListenerNS(String,String,EventListener,boolean)}.
     */
    public void removeEventListenerNS(String namespaceURI,
                                      String type,
                                      EventListener listener,
                                      boolean useCapture) {
        if (eventSupport != null) {
            if (namespaceURI != null && namespaceURI.length() == 0) {
                namespaceURI = null;
            }
            eventSupport.removeEventListenerNS(namespaceURI,
                                               type,
                                               listener,
                                               useCapture);
        }
    }

    /**
     * Implements {@link
     * org.apache.flex.forks.batik.dom.events.NodeEventTarget#getParentNodeEventTarget()}.
     */
    public NodeEventTarget getParentNodeEventTarget() {
        return (NodeEventTarget) getXblParentNode();
    }

    /**
     * <b>DOM</b>: Implements
     * {@link org.w3c.dom.events.EventTarget#dispatchEvent(Event)}.
     */
    public boolean dispatchEvent(Event evt) throws EventException {
        if (eventSupport == null) {
            initializeEventSupport();
        }
        return eventSupport.dispatchEvent(this, evt);
    }

    /**
     * <b>DOM</b>: Implements
     * <code>EventTarget#willTriggerNS(String,String)</code> from an old draft
     * of DOM Level 3 Events.
     */
    public boolean willTriggerNS(String namespaceURI, String type) {
        return true;
    }

    /**
     * <b>DOM</b>: Implements
     * <code>EventTarget.hasEventListenerNS(String,String)</code> from an old
     * draft of DOM Level 3 Events.
     */
    public boolean hasEventListenerNS(String namespaceURI, String type) {
        if (eventSupport == null) {
            return false;
        }
        if (namespaceURI != null && namespaceURI.length() == 0) {
            namespaceURI = null;
        }
        return eventSupport.hasEventListenerNS(namespaceURI, type);
    }

    /**
     * Returns the event support instance for this node, or null if any.
     */
    public EventSupport getEventSupport() {
        return eventSupport;
    }

    /**
     * Initializes the event support instance for this node if it has not
     * been already, and returns it.
     */
    public EventSupport initializeEventSupport() {
        if (eventSupport == null) {
            AbstractDocument doc = getCurrentDocument();
            AbstractDOMImplementation di
                = (AbstractDOMImplementation) doc.getImplementation();
            eventSupport = di.createEventSupport(this);
            doc.setEventsEnabled(true);
        }
        return eventSupport;
    }

    /**
     * Recursively fires a DOMNodeInsertedIntoDocument event.
     */
    public void fireDOMNodeInsertedIntoDocumentEvent() {
        AbstractDocument doc = getCurrentDocument();
        if (doc.getEventsEnabled()) {
            DOMMutationEvent ev =
                (DOMMutationEvent)doc.createEvent("MutationEvents");
            ev.initMutationEventNS(XMLConstants.XML_EVENTS_NAMESPACE_URI,
                                   "DOMNodeInsertedIntoDocument",
                                   true,   // canBubbleArg
                                   false,  // cancelableArg
                                   null,   // relatedNodeArg
                                   null,   // prevValueArg
                                   null,   // newValueArg
                                   null,   // attrNameArg
                                   MutationEvent.ADDITION);
            dispatchEvent(ev);
        }
    }

    /**
     * Recursively fires a DOMNodeRemovedFromDocument event.
     */
    public void fireDOMNodeRemovedFromDocumentEvent() {
        AbstractDocument doc = getCurrentDocument();
        if (doc.getEventsEnabled()) {
            DOMMutationEvent ev
                = (DOMMutationEvent) doc.createEvent("MutationEvents");
            ev.initMutationEventNS(XMLConstants.XML_EVENTS_NAMESPACE_URI,
                                   "DOMNodeRemovedFromDocument",
                                   true,   // canBubbleArg
                                   false,  // cancelableArg
                                   null,   // relatedNodeArg
                                   null,   // prevValueArg
                                   null,   // newValueArg
                                   null,   // attrNameArg
                                   MutationEvent.REMOVAL);
            dispatchEvent(ev);
        }
    }

    /**
     * Fires a DOMCharacterDataModified event.
     */
    protected void fireDOMCharacterDataModifiedEvent(String oldv,
                                                     String newv) {
        AbstractDocument doc = getCurrentDocument();
        if (doc.getEventsEnabled()) {
            DOMMutationEvent ev
                = (DOMMutationEvent) doc.createEvent("MutationEvents");
            ev.initMutationEventNS(XMLConstants.XML_EVENTS_NAMESPACE_URI,
                                   "DOMCharacterDataModified",
                                   true,  // canBubbleArg
                                   false, // cancelableArg
                                   null,  // relatedNodeArg
                                   oldv,  // prevValueArg
                                   newv,  // newValueArg
                                   null,  // attrNameArg
                                   MutationEvent.MODIFICATION);
            dispatchEvent(ev);
        }
    }

    /**
     * Returns the current document.
     */
    protected AbstractDocument getCurrentDocument() {
        return ownerDocument;
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected abstract Node newNode();

    /**
     * Exports this node to the given document.
     */
    protected Node export(Node n, AbstractDocument d) {
        AbstractNode p = (AbstractNode)n;
        p.ownerDocument = d;
        p.setReadonly(false);
        return n;
    }

    /**
     * Deeply exports this node to the given document.
     */
    protected Node deepExport(Node n, AbstractDocument d) {
        AbstractNode p = (AbstractNode)n;
        p.ownerDocument = d;
        p.setReadonly(false);
        return n;
    }

    /**
     * Copy the fields of the current node into the given node.
     * @param n a node of the type of this.
     */
    protected Node copyInto(Node n) {
        AbstractNode an = (AbstractNode)n;
        an.ownerDocument = ownerDocument;
        return n;
    }

    /**
     * Deeply copy the fields of the current node into the given node.
     * @param n a node of the type of this.
     */
    protected Node deepCopyInto(Node n) {
        AbstractNode an = (AbstractNode)n;
        an.ownerDocument = ownerDocument;
        return n;
    }

    /**
     * Checks the validity of a node to be inserted.
     */
    protected void checkChildType(Node n, boolean replace) {
        throw createDOMException(DOMException.HIERARCHY_REQUEST_ERR,
                                 "children.not.allowed",
                                 new Object[] { new Integer(getNodeType()),
                                                getNodeName() });
    }

    // NodeXBL //////////////////////////////////////////////////////////////

    /**
     * Get the parent of this node in the fully flattened tree.
     */
    public Node getXblParentNode() {
        return ownerDocument.getXBLManager().getXblParentNode(this);
    }

    /**
     * Get the list of child nodes of this node in the fully flattened tree.
     */
    public NodeList getXblChildNodes() {
        return ownerDocument.getXBLManager().getXblChildNodes(this);
    }

    /**
     * Get the list of child nodes of this node in the fully flattened tree
     * that are within the same shadow scope.
     */
    public NodeList getXblScopedChildNodes() {
        return ownerDocument.getXBLManager().getXblScopedChildNodes(this);
    }

    /**
     * Get the first child node of this node in the fully flattened tree.
     */
    public Node getXblFirstChild() {
        return ownerDocument.getXBLManager().getXblFirstChild(this);
    }

    /**
     * Get the last child node of this node in the fully flattened tree.
     */
    public Node getXblLastChild() {
        return ownerDocument.getXBLManager().getXblLastChild(this);
    }

    /**
     * Get the node which directly precedes the current node in the
     * xblParentNode's xblChildNodes list.
     */
    public Node getXblPreviousSibling() {
        return ownerDocument.getXBLManager().getXblPreviousSibling(this);
    }

    /**
     * Get the node which directly follows the current node in the
     * xblParentNode's xblChildNodes list.
     */
    public Node getXblNextSibling() {
        return ownerDocument.getXBLManager().getXblNextSibling(this);
    }

    /**
     * Get the first element child of this node in the fully flattened tree.
     */
    public Element getXblFirstElementChild() {
        return ownerDocument.getXBLManager().getXblFirstElementChild(this);
    }

    /**
     * Get the last element child of this node in the fully flattened tree.
     */
    public Element getXblLastElementChild() {
        return ownerDocument.getXBLManager().getXblLastElementChild(this);
    }

    /**
     * Get the first element that precedes the current node in the
     * xblParentNode's xblChildNodes list.
     */
    public Element getXblPreviousElementSibling() {
        return ownerDocument.getXBLManager().getXblPreviousElementSibling(this);
    }

    /**
     * Get the first element that follows the current node in the
     * xblParentNode's xblChildNodes list.
     */
    public Element getXblNextElementSibling() {
        return ownerDocument.getXBLManager().getXblNextElementSibling(this);
    }

    /**
     * Get the bound element whose shadow tree this current node resides in.
     */
    public Element getXblBoundElement() {
        return ownerDocument.getXBLManager().getXblBoundElement(this);
    }

    /**
     * Get the shadow tree of this node.
     */
    public Element getXblShadowTree() {
        return ownerDocument.getXBLManager().getXblShadowTree(this);
    }

    /**
     * Get the xbl:definition elements currently binding this element.
     */
    public NodeList getXblDefinitions() {
        return ownerDocument.getXBLManager().getXblDefinitions(this);
    }

    // XBLManagerData ////////////////////////////////////////////////////////

    /**
     * Returns the XBL manager associated data for this node.
     */
    public Object getManagerData() {
        return managerData;
    }

    /**
     * Sets the XBL manager associated data for this node.
     */
    public void setManagerData(Object data) {
        managerData = data;
    }
}
