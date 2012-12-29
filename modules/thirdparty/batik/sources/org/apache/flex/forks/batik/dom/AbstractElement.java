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

import org.apache.flex.forks.batik.dom.events.DOMMutationEvent;
import org.apache.flex.forks.batik.dom.util.DOMUtilities;
import org.apache.flex.forks.batik.util.XMLConstants;

import org.w3c.dom.Attr;
import org.w3c.dom.DOMException;
import org.w3c.dom.Element;
import org.w3c.dom.ElementTraversal;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.TypeInfo;
import org.w3c.dom.events.MutationEvent;

/**
 * This class implements the {@link org.w3c.dom.Element} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: AbstractElement.java 601944 2007-12-07 01:01:23Z cam $
 */
public abstract class AbstractElement
    extends    AbstractParentChildNode
    implements Element, ElementTraversal {

    /**
     * The attributes of this element.
     */
    protected NamedNodeMap attributes;

    /**
     * The element type information.
     */
    protected TypeInfo typeInfo;

    /**
     * Creates a new AbstractElement object.
     */
    protected AbstractElement() {
    }

    /**
     * Creates a new AbstractElement object.
     * @param name  The element name for validation purposes.
     * @param owner The owner document.
     * @exception DOMException
     *   INVALID_CHARACTER_ERR: if name contains invalid characters,
     */
    protected AbstractElement(String name, AbstractDocument owner) {
        ownerDocument = owner;
        if (owner.getStrictErrorChecking() && !DOMUtilities.isValidName(name)) {
            throw createDOMException(DOMException.INVALID_CHARACTER_ERR,
                   "xml.name",
                   new Object[] { name });
        }
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getNodeType()}.
     *
     * @return {@link org.w3c.dom.Node#ELEMENT_NODE}
     */
    public short getNodeType() {
        return ELEMENT_NODE;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#hasAttributes()}.
     */
    public boolean hasAttributes() {
        return attributes != null && attributes.getLength() != 0;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getAttributes()}.
     */
    public NamedNodeMap getAttributes() {
        return (attributes == null)
            ? attributes = createAttributes()
            : attributes;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Element#getTagName()}.
     *
     * @return {@link #getNodeName()}.
     */
    public String getTagName() {
        return getNodeName();
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Element#hasAttribute(String)}.
     */
    public boolean hasAttribute( String name ) {
        return attributes != null && attributes.getNamedItem( name ) != null;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Element#getAttribute(String)}.
     */
    public String getAttribute(String name) {
        if ( attributes == null ) {
          return "";
        }
        Attr attr = (Attr)attributes.getNamedItem( name );
        return ( attr == null ) ? "" : attr.getValue();
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.Element#setAttribute(String,String)}.
     */
    public void setAttribute(String name, String value) throws DOMException {
        if (attributes == null) {
            attributes = createAttributes();
        }
        Attr attr = getAttributeNode(name);
        if (attr == null) {
            attr = getOwnerDocument().createAttribute(name);
            attr.setValue(value);
            attributes.setNamedItem(attr);
        } else {
            attr.setValue(value);
        }
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.Element#removeAttribute(String)}.
     */
    public void removeAttribute(String name) throws DOMException {
        if (!hasAttribute(name)) {
                  return;
        }
        attributes.removeNamedItem(name);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.Element#getAttributeNode(String)}.
     */
    public Attr getAttributeNode(String name) {
        if (attributes == null) {
            return null;
        }
        return (Attr)attributes.getNamedItem(name);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.Element#setAttributeNode(Attr)}.
     */
    public Attr setAttributeNode(Attr newAttr) throws DOMException {
        if (newAttr == null) {
            return null;
        }
        if (attributes == null) {
            attributes = createAttributes();
        }
        return (Attr)attributes.setNamedItemNS(newAttr);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.Element#removeAttributeNode(Attr)}.
     */
    public Attr removeAttributeNode(Attr oldAttr) throws DOMException {
        if (oldAttr == null) {
            return null;
        }
        if (attributes == null) {
            throw createDOMException(DOMException.NOT_FOUND_ERR,
                   "attribute.missing",
                   new Object[] { oldAttr.getName() });
        }
        String nsURI = oldAttr.getNamespaceURI();
        return (Attr)attributes.removeNamedItemNS(nsURI,
                                                  (nsURI==null
                                                   ? oldAttr.getNodeName()
                                                   : oldAttr.getLocalName()));
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#normalize()}.
     */
    public void normalize() {
        super.normalize();
        if (attributes != null) {
            NamedNodeMap map = getAttributes();
            for (int i = map.getLength() - 1; i >= 0; i--) {
                map.item(i).normalize();
            }
        }
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.Element#hasAttributeNS(String,String)}.
     */
    public boolean hasAttributeNS( String namespaceURI, String localName ) {
        if ( namespaceURI != null && namespaceURI.length() == 0 ) {
            namespaceURI = null;
        }
        return attributes != null &&
                attributes.getNamedItemNS( namespaceURI, localName ) != null;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.Element#getAttributeNS(String,String)}.
     */
    public String getAttributeNS( String namespaceURI, String localName ) {
        if ( attributes == null ) {
            return "";
        }
        if ( namespaceURI != null && namespaceURI.length() == 0 ) {
            namespaceURI = null;
        }
        Attr attr = (Attr)attributes.getNamedItemNS( namespaceURI, localName );
        return ( attr == null ) ? "" : attr.getValue();
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.Element#setAttributeNS(String,String,String)}.
     */
    public void setAttributeNS(String namespaceURI,
                               String qualifiedName,
                               String value) throws DOMException {

        if (attributes == null) {
            attributes = createAttributes();
        }
        if (namespaceURI != null && namespaceURI.length() == 0) {
            namespaceURI = null;
        }
        Attr attr = getAttributeNodeNS(namespaceURI, qualifiedName);
        if (attr == null) {
            attr = getOwnerDocument().createAttributeNS(namespaceURI,
                                                        qualifiedName);
            attr.setValue(value);
            attributes.setNamedItemNS(attr);
        } else {
            attr.setValue(value);
        }
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.Element#removeAttributeNS(String,String)}.
     */
    public void removeAttributeNS(String namespaceURI,
                                  String localName) throws DOMException {
        if (namespaceURI != null && namespaceURI.length() == 0) {
            namespaceURI = null;
        }
        if (!hasAttributeNS(namespaceURI, localName)) {
                  return;
        }
        attributes.removeNamedItemNS(namespaceURI, localName);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.Element#getAttributeNodeNS(String,String)}.
     */
    public Attr getAttributeNodeNS(String namespaceURI,
                                   String localName) {
        if (namespaceURI != null && namespaceURI.length() == 0) {
            namespaceURI = null;
        }
        if (attributes == null) {
            return null;
        }
        return (Attr)attributes.getNamedItemNS(namespaceURI, localName);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.Element#setAttributeNodeNS(Attr)}.
     */
    public Attr setAttributeNodeNS(Attr newAttr) throws DOMException {
        if (newAttr == null) {
            return null;
        }
        if (attributes == null) {
            attributes = createAttributes();
        }
        return (Attr)attributes.setNamedItemNS(newAttr);
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Element#getSchemaTypeInfo()}.
     */
    public TypeInfo getSchemaTypeInfo() {
        if (typeInfo == null) {
            typeInfo = new ElementTypeInfo();
        }
        return typeInfo;
    }

    /**
     * <b>DOM</b>: Implements
     * {@link org.w3c.dom.Element#setIdAttribute(String,boolean)}.
     */
    public void setIdAttribute(String name, boolean isId) throws DOMException {
        AbstractAttr a = (AbstractAttr) getAttributeNode(name);
        if (a == null) {
            throw createDOMException(DOMException.NOT_FOUND_ERR,
                                     "attribute.missing",
                                     new Object[] { name });
        }
        if (a.isReadonly()) {
            throw createDOMException(DOMException.NO_MODIFICATION_ALLOWED_ERR,
                                     "readonly.node",
                                     new Object[] { name });
        }
        a.isIdAttr = isId;
    }

    /**
     * <b>DOM</b>: Implements
     * {@link org.w3c.dom.Element#setIdAttributeNS(String,String,boolean)}.
     */
    public void setIdAttributeNS( String ns, String ln, boolean isId )
            throws DOMException {
        if ( ns != null && ns.length() == 0 ) {
            ns = null;
        }
        AbstractAttr a = (AbstractAttr)getAttributeNodeNS( ns, ln );
        if (a == null) {
            throw createDOMException(DOMException.NOT_FOUND_ERR,
                                     "attribute.missing",
                                     new Object[] { ns, ln });
        }
        if (a.isReadonly()) {
            throw createDOMException(DOMException.NO_MODIFICATION_ALLOWED_ERR,
                                     "readonly.node",
                                     new Object[] { a.getNodeName() });
        }
        a.isIdAttr = isId;
    }

    /**
     * <b>DOM</b>: Implements
     * {@link org.w3c.dom.Element#setIdAttributeNode(Attr,boolean)}.
     */
    public void setIdAttributeNode( Attr attr, boolean isId )
            throws DOMException {
        AbstractAttr a = (AbstractAttr)attr;
        if (a.isReadonly()) {
            throw createDOMException(DOMException.NO_MODIFICATION_ALLOWED_ERR,
                                     "readonly.node",
                                     new Object[] { a.getNodeName() });
        }
        a.isIdAttr = isId;
    }

    /**
     * Get an ID attribute.
     */
    protected Attr getIdAttribute() {
        NamedNodeMap nnm = getAttributes();
        if ( nnm == null ) {
            return null;
        }
        int len = nnm.getLength();
        for (int i = 0; i < len; i++) {
            AbstractAttr a = (AbstractAttr)nnm.item(i);
            if (a.isId()) {
                return a;
            }
        }
        return null;
    }

    /**
     * Get the ID of this element.
     */
    protected String getId() {
        Attr a = getIdAttribute();
        if (a != null) {
            String id = a.getNodeValue();
            if (id.length() > 0) {
                return id;
            }
        }
        return null;
    }

    /**
     * Called when a child node has been added.
     */
    protected void nodeAdded(Node node) {
        invalidateElementsByTagName(node);
    }

    /**
     * Called when a child node is going to be removed.
     */
    protected void nodeToBeRemoved(Node node) {
        invalidateElementsByTagName(node);
    }

    /**
     * Invalidates the ElementsByTagName objects of this node and its parents.
     */
    private void invalidateElementsByTagName(Node node) {
        if (node.getNodeType() != ELEMENT_NODE) {
            return;
        }
        AbstractDocument ad = getCurrentDocument();
        String ns = node.getNamespaceURI();
        String nm = node.getNodeName();
        String ln = (ns == null) ? node.getNodeName() : node.getLocalName();
        for (Node n = this; n != null; n = n.getParentNode()) {
            switch (n.getNodeType()) {
            case ELEMENT_NODE:      // fall-through is intended
            case DOCUMENT_NODE:
                ElementsByTagName l = ad.getElementsByTagName(n, nm);
                if (l != null) {
                    l.invalidate();
                }
                l = ad.getElementsByTagName(n, "*");
                if (l != null) {
                    l.invalidate();
                }
                ElementsByTagNameNS lns = ad.getElementsByTagNameNS(n, ns, ln);

                if (lns != null) {
                    lns.invalidate();
                }
                lns = ad.getElementsByTagNameNS(n, "*", ln);
                if (lns != null) {
                    lns.invalidate();
                }
                lns = ad.getElementsByTagNameNS(n, ns, "*");
                if (lns != null) {
                    lns.invalidate();
                }
                lns = ad.getElementsByTagNameNS(n, "*", "*");
                if (lns != null) {
                    lns.invalidate();
                }
            }
        }

        //
        // Invalidate children
        //
        Node c = node.getFirstChild();
        while (c != null) {
            invalidateElementsByTagName(c);
            c = c.getNextSibling();
        }

    }

    /**
     * Creates the attribute list.
     */
    protected NamedNodeMap createAttributes() {
        return new NamedNodeHashMap();
    }

    /**
     * Exports this node to the given document.
     * @param n The clone node.
     * @param d The destination document.
     */
    protected Node export(Node n, AbstractDocument d) {
        super.export(n, d);
        AbstractElement ae = (AbstractElement)n;
        if (attributes != null) {
            NamedNodeMap map = attributes;
            for (int i = map.getLength() - 1; i >= 0; i--) {
                AbstractAttr aa = (AbstractAttr)map.item(i);
                if (aa.getSpecified()) {
                    Attr attr = (Attr)aa.deepExport(aa.cloneNode(false), d);
                    if (aa instanceof AbstractAttrNS) {
                        ae.setAttributeNodeNS(attr);
                    } else {
                        ae.setAttributeNode(attr);
                    }
                }
            }
        }
        return n;
    }

    /**
     * Deeply exports this node to the given document.
     * @param n The clone node.
     * @param d The destination document.
     */
    protected Node deepExport(Node n, AbstractDocument d) {
        super.deepExport(n, d);
        AbstractElement ae = (AbstractElement)n;
        if (attributes != null) {
            NamedNodeMap map = attributes;
            for (int i = map.getLength() - 1; i >= 0; i--) {
                AbstractAttr aa = (AbstractAttr)map.item(i);
                if (aa.getSpecified()) {
                    Attr attr = (Attr)aa.deepExport(aa.cloneNode(false), d);
                    if (aa instanceof AbstractAttrNS) {
                        ae.setAttributeNodeNS(attr);
                    } else {
                        ae.setAttributeNode(attr);
                    }
                }
            }
        }
        return n;
    }

    /**
     * Copy the fields of the current node into the given node.
     * @param n a node of the type of this.
     */
    protected Node copyInto(Node n) {
        super.copyInto(n);
        AbstractElement ae = (AbstractElement)n;
        if (attributes != null) {
            NamedNodeMap map = attributes;
            for (int i = map.getLength() - 1; i >= 0; i--) {
                AbstractAttr aa = (AbstractAttr)map.item(i).cloneNode(true);
                if (aa instanceof AbstractAttrNS) {
                    ae.setAttributeNodeNS(aa);
                } else {
                    ae.setAttributeNode(aa);
                }
            }
        }
        return n;
    }

    /**
     * Deeply copy the fields of the current node into the given node.
     * @param n a node of the type of this.
     */
    protected Node deepCopyInto(Node n) {
        super.deepCopyInto(n);
        AbstractElement ae = (AbstractElement)n;
        if (attributes != null) {
            NamedNodeMap map = attributes;
            for (int i = map.getLength() - 1; i >= 0; i--) {
                AbstractAttr aa = (AbstractAttr)map.item(i).cloneNode(true);
                if (aa instanceof AbstractAttrNS) {
                    ae.setAttributeNodeNS(aa);
                } else {
                    ae.setAttributeNode(aa);
                }
            }
        }
        return n;
    }

    /**
     * Checks the validity of a node to be inserted.
     * @param n The node to be inserted.
     */
    protected void checkChildType(Node n, boolean replace) {
        switch (n.getNodeType()) {
        case ELEMENT_NODE:                // fall-through is intended
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

    /**
     * Fires a DOMAttrModified event.
     * WARNING: public accessor because of compilation problems
     * on Solaris. Do not change.
     *
     * @param name The attribute's name.
     * @param node The attribute's node.
     * @param oldv The old value of the attribute.
     * @param newv The new value of the attribute.
     * @param change The modification type.
     */
    public void fireDOMAttrModifiedEvent(String name, Attr node, String oldv,
                                         String newv, short change) {
        switch (change) {
        case MutationEvent.ADDITION:
            if (((AbstractAttr)node).isId())
                ownerDocument.addIdEntry(this, newv);
            attrAdded(node, newv);
            break;

        case MutationEvent.MODIFICATION:
            if (((AbstractAttr)node).isId())
                ownerDocument.updateIdEntry(this, oldv, newv);
            attrModified(node, oldv, newv);
            break;

        default: // MutationEvent.REMOVAL:
            if (((AbstractAttr)node).isId())
                ownerDocument.removeIdEntry(this, oldv);
            attrRemoved(node, oldv);
        }
        AbstractDocument doc = getCurrentDocument();
        if (doc.getEventsEnabled() && !oldv.equals(newv)) {
            DOMMutationEvent ev
                      = (DOMMutationEvent) doc.createEvent("MutationEvents");
            ev.initMutationEventNS(XMLConstants.XML_EVENTS_NAMESPACE_URI,
                                         "DOMAttrModified",
                                         true,    // canBubbleArg
                                         false,   // cancelableArg
                                         node,    // relatedNodeArg
                                         oldv,    // prevValueArg
                                         newv,    // newValueArg
                                         name,    // attrNameArg
                                         change); // attrChange
            dispatchEvent(ev);
        }
    }

    /**
     * Called when an attribute has been added.
     */
    protected void attrAdded(Attr node, String newv) {
    }

    /**
     * Called when an attribute has been modified.
     */
    protected void attrModified(Attr node, String oldv, String newv) {
    }

    /**
     * Called when an attribute has been removed.
     */
    protected void attrRemoved(Attr node, String oldv) {
    }

    // ElementTraversal //////////////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link ElementTraversal#getFirstElementChild()}.
     */
    public Element getFirstElementChild() {
        Node n = getFirstChild();
        while (n != null) {
            if (n.getNodeType() == Node.ELEMENT_NODE) {
                return (Element) n;
            }
            n = n.getNextSibling();
        }
        return null;
    }

    /**
     * <b>DOM</b>: Implements {@link ElementTraversal#getLastElementChild()}.
     */
    public Element getLastElementChild() {
        Node n = getLastChild();
        while (n != null) {
            if (n.getNodeType() == Node.ELEMENT_NODE) {
                return (Element) n;
            }
            n = n.getPreviousSibling();
        }
        return null;
    }

    /**
     * <b>DOM</b>: Implements {@link ElementTraversal#getNextElementSibling()}.
     */
    public Element getNextElementSibling() {
        Node n = getNextSibling();
        while (n != null) {
            if (n.getNodeType() == Node.ELEMENT_NODE) {
                return (Element) n;
            }
            n = n.getNextSibling();
        }
        return null;
    }

    /**
     * <b>DOM</b>: Implements {@link ElementTraversal#getPreviousElementSibling()}.
     */
    public Element getPreviousElementSibling() {
        Node n = getPreviousSibling();
        while (n != null) {
            if (n.getNodeType() == Node.ELEMENT_NODE) {
                return (Element) n;
            }
            n = n.getPreviousSibling();
        }
        return (Element) n;
    }

    /**
     * <b>DOM</b>: Implements {@link ElementTraversal#getChildElementCount()}.
     */
    public int getChildElementCount() {
        getChildNodes();
        return childNodes.elementChildren;
    }

    /**
     * An implementation of the {@link org.w3c.dom.NamedNodeMap}.
     *
     * <br>This Map is not Thread-safe, concurrent updates or reading while updating may give
     * unexpected results.
     */
    public class NamedNodeHashMap implements NamedNodeMap, Serializable {

        /**
         * The initial capacity
         */
        protected static final int INITIAL_CAPACITY = 3;

        /**
         * The underlying array
         */
        protected Entry[] table;

        /**
         * The number of entries
         */
        protected int count;

        /**
         * Creates a new NamedNodeHashMap object.
         */
        public NamedNodeHashMap() {
                  table = new Entry[INITIAL_CAPACITY];
        }

        /**
         * <b>DOM</b>: Implements {@link org.w3c.dom.NamedNodeMap#getNamedItem(String)}.
         */
        public Node getNamedItem( String name ) {
            if ( name == null ) {
                return null;
            }
            return get( null, name );
        }

        /**
         * <b>DOM</b>: Implements {@link org.w3c.dom.NamedNodeMap#setNamedItem(Node)}.
         */
        public Node setNamedItem( Node arg ) throws DOMException {
            if ( arg == null ) {
                return null;
            }
            checkNode( arg );

            return setNamedItem( null, arg.getNodeName(), arg );
        }

        /**
         * <b>DOM</b>: Implements {@link org.w3c.dom.NamedNodeMap#removeNamedItem(String)}.
         */
        public Node removeNamedItem( String name ) throws DOMException {
            return removeNamedItemNS( null, name );
        }

        /**
         * <b>DOM</b>: Implements {@link org.w3c.dom.NamedNodeMap#item(int)}.
         */
        public Node item( int index ) {
            if ( index < 0 || index >= count ) {
                return null;
            }
            int j = 0;
            for ( int i = 0; i < table.length; i++ ) {
                Entry e = table[ i ];
                if ( e == null ) {
                    continue;
                }
                do {
                    if ( j++ == index ) {
                        return e.value;
                    }
                    e = e.next;
                } while ( e != null );
            }
            return null;
        }

        /**
         * <b>DOM</b>: Implements {@link org.w3c.dom.NamedNodeMap#getLength()}.
         */
        public int getLength() {
            return count;
        }

        /**
         * <b>DOM</b>: Implements {@link
         * org.w3c.dom.NamedNodeMap#getNamedItemNS(String,String)}.
         */
        public Node getNamedItemNS( String namespaceURI, String localName ) {
            if ( namespaceURI != null && namespaceURI.length() == 0 ) {
                namespaceURI = null;
            }
            return get( namespaceURI, localName );
        }

        /**
         * <b>DOM</b>: Implements {@link org.w3c.dom.NamedNodeMap#setNamedItemNS(Node)}.
         */
        public Node setNamedItemNS( Node arg ) throws DOMException {
            if ( arg == null ) {
                return null;
            }
            String nsURI = arg.getNamespaceURI();
            return setNamedItem( nsURI,
                    ( nsURI == null )
                            ? arg.getNodeName()
                            : arg.getLocalName(), arg );
        }

        /**
         * <b>DOM</b>: Implements {@link org.w3c.dom.NamedNodeMap#removeNamedItemNS(String,String)}.
         */
        public Node removeNamedItemNS( String namespaceURI, String localName )
                throws DOMException {
            if ( isReadonly() ) {
                throw createDOMException
                        ( DOMException.NO_MODIFICATION_ALLOWED_ERR,
                                "readonly.node.map",
                                new Object[]{} );
            }
            if ( localName == null ) {
                throw createDOMException( DOMException.NOT_FOUND_ERR,
                        "attribute.missing",
                        new Object[]{""} );
            }
            if ( namespaceURI != null && namespaceURI.length() == 0 ) {
                namespaceURI = null;
            }
            AbstractAttr n = (AbstractAttr)remove( namespaceURI, localName );
            if ( n == null ) {
                throw createDOMException( DOMException.NOT_FOUND_ERR,
                        "attribute.missing",
                        new Object[]{localName} );
            }
            n.setOwnerElement( null );

            // Mutation event
            fireDOMAttrModifiedEvent( n.getNodeName(), n, n.getNodeValue(), "",
                    MutationEvent.REMOVAL );
            return n;
        }

        /**
         * Adds a node to the map.
         */
        public Node setNamedItem( String ns, String name, Node arg )
                throws DOMException {

            if ( ns != null && ns.length() == 0 ) {
                ns = null;
            }
            ( (AbstractAttr)arg ).setOwnerElement( AbstractElement.this );
            AbstractAttr result = (AbstractAttr)put( ns, name, arg );

            if ( result != null ) {
                result.setOwnerElement( null );
                fireDOMAttrModifiedEvent( name,
                        result,
                        result.getNodeValue(),
                        "",
                        MutationEvent.REMOVAL );
            }
            fireDOMAttrModifiedEvent( name,
                    (Attr)arg,
                    "",
                    arg.getNodeValue(),
                    MutationEvent.ADDITION );
            return result;
    }

        /**
         * Checks the validity of a node to add.
         */
        protected void checkNode( Node arg ) {
            if ( isReadonly() ) {
                throw createDOMException
                        ( DOMException.NO_MODIFICATION_ALLOWED_ERR,
                                "readonly.node.map",
                                new Object[]{} );
            }
            if ( getOwnerDocument() != arg.getOwnerDocument() ) {
                throw createDOMException( DOMException.WRONG_DOCUMENT_ERR,
                        "node.from.wrong.document",
                        new Object[]{new Integer( arg.getNodeType() ),
                                arg.getNodeName()} );
            }
            if ( arg.getNodeType() == ATTRIBUTE_NODE &&
                    ( (Attr)arg ).getOwnerElement() != null ) {
                throw createDOMException( DOMException.WRONG_DOCUMENT_ERR,
                        "inuse.attribute",
                        new Object[]{arg.getNodeName()} );
            }
        }

        /**
         * Gets the value of a variable
         *
         * @return the value or null
         */
        protected Node get( String ns, String nm ) {
            int hash = hashCode( ns, nm ) & 0x7FFFFFFF;
            int index = hash % table.length;

            for ( Entry e = table[ index ]; e != null; e = e.next ) {
                if ( ( e.hash == hash ) && e.match( ns, nm ) ) {
                    return e.value;
                }
            }
            return null;
        }

        /**
         * Sets a new value for the given variable
         *
         * @return the old value or null
         */
        protected Node put( String ns, String nm, Node value ) {
            int hash = hashCode( ns, nm ) & 0x7FFFFFFF;
            int index = hash % table.length;

            for ( Entry e = table[ index ]; e != null; e = e.next ) {
                if ( ( e.hash == hash ) && e.match( ns, nm ) ) {
                    Node old = e.value;
                    e.value = value;
                    return old;
                }
            }

            // The key is not in the hash table
            int len = table.length;
            if ( count++ >= ( len - ( len >> 2 ) ) ) {
                // more than 75% loaded: grow
                rehash();
                index = hash % table.length;
            }

            Entry e = new Entry( hash, ns, nm, value, table[ index ] );
            table[ index ] = e;
            return null;
        }

        /**
         * Removes an entry from the table.
         *
         * @return the value or null.
         */
        protected Node remove( String ns, String nm ) {
            int hash = hashCode( ns, nm ) & 0x7FFFFFFF;
            int index = hash % table.length;

            Entry p = null;
            for ( Entry e = table[ index ]; e != null; e = e.next ) {
                if ( ( e.hash == hash ) && e.match( ns, nm ) ) {
                    Node result = e.value;
                    if ( p == null ) {
                        table[ index ] = e.next;
                    } else {
                        p.next = e.next;
                    }
                    count--;
                    return result;
                }
                p = e;
            }
            return null;
        }

        /**
         * Rehash and grow the table.
         */
        protected void rehash () {
            Entry[] oldTable = table;

            table = new Entry[oldTable.length * 2 + 1];

            for (int i = oldTable.length-1; i >= 0; i--) {
                for (Entry old = oldTable[i]; old != null;) {
                    Entry e = old;
                    old = old.next;

                    int index = e.hash % table.length;
                    e.next = table[index];
                    table[index] = e;
                }
            }
        }

        /**
         * Computes a hash code corresponding to the given strings.
         */
        protected int hashCode(String ns, String nm) {
            int result = (ns == null) ? 0 : ns.hashCode();
            return result ^ nm.hashCode();
        }
    }

    /**
     * To manage collisions in the attributes map.
     * Implements a linked list of <code>Node</code>-objects.
     */
    protected static class Entry implements Serializable {

        /**
         * The hash code, must not change after creation.
         */
        public int hash;       // should be final - would that break Serialization?

        /**
         * The namespace URI
         */
        public String namespaceURI;

        /**
         * The node name.
         */
        public String name;

        /**
         * The value
         */
        public Node value;

        /**
         * The next entry
         */
        public Entry next;

        /**
         * Creates a new entry
         */
        public Entry(int hash, String ns, String nm, Node value, Entry next) {
            this.hash = hash;
            this.namespaceURI = ns;
            this.name = nm;
            this.value = value;
            this.next = next;
        }

        /**
         * Whether this entry match the given keys.
         */
        public boolean match(String ns, String nm) {
            if (namespaceURI != null) {
                if (!namespaceURI.equals(ns)) {
                    return false;
                }
            } else if (ns != null) {
                return false;
            }
            return name.equals(nm);
        }
    }

    /**
     * Inner class to hold type information about this element.
     */
    public class ElementTypeInfo implements TypeInfo {

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
