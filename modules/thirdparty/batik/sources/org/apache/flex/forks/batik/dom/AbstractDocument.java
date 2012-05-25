/*

   Copyright 2000-2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.dom;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.MissingResourceException;
import java.util.WeakHashMap;

import org.apache.flex.forks.batik.dom.events.DocumentEventSupport;
import org.apache.flex.forks.batik.dom.traversal.TraversalSupport;
import org.apache.flex.forks.batik.i18n.Localizable;
import org.apache.flex.forks.batik.i18n.LocalizableSupport;
import org.apache.flex.forks.batik.util.CleanerThread;
import org.apache.flex.forks.batik.util.SoftDoublyIndexedTable;
import org.w3c.dom.Attr;
import org.w3c.dom.DOMException;
import org.w3c.dom.DOMImplementation;
import org.w3c.dom.Document;
import org.w3c.dom.DocumentType;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.events.DocumentEvent;
import org.w3c.dom.events.Event;
import org.w3c.dom.traversal.DocumentTraversal;
import org.w3c.dom.traversal.NodeFilter;
import org.w3c.dom.traversal.NodeIterator;
import org.w3c.dom.traversal.TreeWalker;

/**
 * This class implements the {@link org.w3c.dom.Document} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: AbstractDocument.java,v 1.27 2005/03/03 01:19:53 deweese Exp $
 */
public abstract class AbstractDocument
    extends    AbstractParentNode
    implements Document,
               DocumentEvent,
               DocumentTraversal,
               Localizable {

    /**
     * The error messages bundle class name.
     */
    protected final static String RESOURCES =
        "org.apache.flex.forks.batik.dom.resources.Messages";

    /**
     * The localizable support for the error messages.
     */
    protected transient LocalizableSupport localizableSupport =
        new LocalizableSupport
        (RESOURCES, getClass().getClassLoader());

    /**
     * The DOM implementation.
     */
    protected transient DOMImplementation implementation;

    /**
     * The traversal support.
     */
    protected transient TraversalSupport traversalSupport;

    /**
     * The DocumentEventSupport.
     */
    protected transient DocumentEventSupport documentEventSupport;

    /**
     * Whether the event dispatching must be done.
     */
    protected transient boolean eventsEnabled;

    /**
     * The ElementsByTagName lists.
     */
    protected transient WeakHashMap elementsByTagNames;

    /**
     * The ElementsByTagNameNS lists.
     */
    protected transient WeakHashMap elementsByTagNamesNS;

    /**
     * The elementsById lists.
     * This is keyed on 'id'.  the entry is either
     * a IdSoftReference to the element or a List of
     * IdSoftReferences (if there is more than one element
     * owned by this document with a particular 'id').
     */
    protected transient Map elementsById;

    /**
     * Creates a new document.
     */
    protected AbstractDocument() {
    }

    /**
     * Creates a new document.
     */
    public AbstractDocument(DocumentType dt, DOMImplementation impl) {
	implementation = impl;
        if (dt != null) {
            if (dt instanceof GenericDocumentType) {
                GenericDocumentType gdt = (GenericDocumentType)dt;
                if (gdt.getOwnerDocument() == null) 
                    gdt.setOwnerDocument(this);
            }
            appendChild(dt);
        }
    }

    /**
     * Implements {@link org.apache.flex.forks.batik.i18n.Localizable#setLocale(Locale)}.
     */
    public void setLocale(Locale l) {
	localizableSupport.setLocale(l);
    }

    /**
     * Implements {@link org.apache.flex.forks.batik.i18n.Localizable#getLocale()}.
     */
    public Locale getLocale() {
        return localizableSupport.getLocale();
    }

    /**
     * Implements {@link
     * org.apache.flex.forks.batik.i18n.Localizable#formatMessage(String,Object[])}.
     */
    public String formatMessage(String key, Object[] args)
        throws MissingResourceException {
        return localizableSupport.formatMessage(key, args);
    }

    /**
     * Tests whether the event dispatching must be done.
     */
    public boolean getEventsEnabled() {
	return eventsEnabled;
    }

    /**
     * Sets the eventsEnabled property.
     */
    public void setEventsEnabled(boolean b) {
	eventsEnabled = b;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getNodeName()}.
     * @return "#document".
     */
    public String getNodeName() {
	return "#document";
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getNodeType()}.
     * @return {@link org.w3c.dom.Node#DOCUMENT_NODE}
     */
    public short getNodeType() {
	return DOCUMENT_NODE;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Document#getDoctype()}.
     */
    public DocumentType getDoctype() {
	for (Node n = getFirstChild(); n != null; n = n.getNextSibling()) {
	    if (n.getNodeType() == DOCUMENT_TYPE_NODE) {
		return (DocumentType)n;
	    }
	}
	return null;
    }

    /**
     * Sets the document type node.
     */
    public void setDoctype(DocumentType dt) {
	if (dt != null) {
	    appendChild(dt);
	    ((ExtendedNode)dt).setReadonly(true);
	}
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Document#getImplementation()}.
     * @return {@link #implementation}
     */
    public DOMImplementation getImplementation() {
	return implementation;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.Document#getDocumentElement()}.
     */
    public Element getDocumentElement() {
	for (Node n = getFirstChild(); n != null; n = n.getNextSibling()) {
	    if (n.getNodeType() == ELEMENT_NODE) {
		return (Element)n;
	    }
	}
	return null;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.Document#importNode(Node,boolean)}.
     */
    public Node importNode(Node importedNode, boolean deep)
        throws DOMException {
        return importNode(importedNode, deep, false);
    }

    /**
     * Imports the given node 'importNode' to this document.
     * It does so deeply if 'deep' is set to true.
     * It will not mark id attributes as id's if 'trimId' is set false.
     * this is used primarily for the clone trees of the 'use' element
     * so they don't clutter the hashtable.
     */
    public Node importNode(Node importedNode, boolean deep, boolean trimId) {
        /*
         * The trimming of id's is used by the 'use' element to keep 
         * down the amount of 'bogus' id's in the hashtable.
         */
        Node result;
        switch (importedNode.getNodeType()) {
        case ELEMENT_NODE:
            Element e = createElementNS(importedNode.getNamespaceURI(),
                                        importedNode.getNodeName());
            result = e;
            if (importedNode.hasAttributes()) {
                NamedNodeMap attr = importedNode.getAttributes();
                int len = attr.getLength();
                for (int i = 0; i < len; i++) {
                    Attr a = (Attr)attr.item(i);
                    if (!a.getSpecified()) continue;
                    AbstractAttr aa = (AbstractAttr)importNode(a, true);
                    if (trimId && aa.isId())
                        aa.setIsId(false); // don't consider this an Id.
                    e.setAttributeNodeNS(aa);
                }
            }
            break;
            
        case ATTRIBUTE_NODE:
            result = createAttributeNS(importedNode.getNamespaceURI(),
                                       importedNode.getNodeName());
            break;
            
        case TEXT_NODE:
            result = createTextNode(importedNode.getNodeValue());
            deep = false;
            break;
            
        case CDATA_SECTION_NODE:
            result = createCDATASection(importedNode.getNodeValue());
            deep = false;
            break;
            
        case ENTITY_REFERENCE_NODE:
            result = createEntityReference(importedNode.getNodeName());
            break;
            
        case PROCESSING_INSTRUCTION_NODE:
            result = createProcessingInstruction
                (importedNode.getNodeName(),
                 importedNode.getNodeValue());
            deep = false;
            break;
            
        case COMMENT_NODE:
            result = createComment(importedNode.getNodeValue());
            deep = false;
            break;
            
        case DOCUMENT_FRAGMENT_NODE:
            result = createDocumentFragment();
            break;

        default:
            throw createDOMException(DOMException.NOT_SUPPORTED_ERR,
                                     "import.node",
                                     new Object[] {});
        }
        
        if (deep) {
            for (Node n = importedNode.getFirstChild();
                 n != null;
                 n = n.getNextSibling()) {
                result.appendChild(importNode(n, true));
            }
        }
        return result;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#cloneNode(boolean)}.
     */
    public Node cloneNode(boolean deep) {
        Document n = (Document)newNode();
        copyInto(n);
        if (deep) {
            for (Node c = getFirstChild();
                 c != null;
                 c = c.getNextSibling()) {
                n.appendChild(n.importNode(c, deep));
            }
        }
        return n;
    }

    public abstract boolean isId(Attr node);

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.Document#getElementById(String)}.
     */
    public Element getElementById(String id) {
        return getChildElementById(getDocumentElement(), id);
    }

    /**
     * Finds an element that is in the same document fragment as
     * 'requestor' that has 'id'.
     */
    public Element getChildElementById(Node requestor, String id) {
        if ((id == null) || (id.length()==0)) return null;
        if (elementsById == null) return null;

        Node root = getRoot(requestor);

        Object o = elementsById.get(id);
        if (o == null) return null;
        if (o instanceof IdSoftRef) {
            o = ((IdSoftRef)o).get();
            if (o == null) {
                elementsById.remove(id);
                return null;
            }
            Element e = (Element)o;
            if (getRoot(e) == root)
                return e;
            return null;
        }
        
        // Not a IdSoftRef so it must be a list.
        List l = (List)o;
        Iterator li = l.iterator();
        while (li.hasNext()) {
            IdSoftRef sr = (IdSoftRef)li.next();
            o = sr.get();
            if (o == null) {
                li.remove();
            } else {
                Element e = (Element)o;
                if (getRoot(e) == root)
                    return e;
            }
        }
        return null;
    }

    protected Node getRoot(Node n) {
        Node r = n;
        while (n != null) {
            r = n;
            n = n.getParentNode();
        }
        return r;
    }

    protected class IdSoftRef extends CleanerThread.SoftReferenceCleared {
        String id;
        List   list;
        IdSoftRef(Object o, String id) { 
            super(o);
            this.id = id; 
        }
        IdSoftRef(Object o, String id, List list) {
            super(o);
            this.id = id;
            this.list = list;
        }
        public void setList(List list) {
            this.list = list;
        }
        public void cleared() {
            if (elementsById == null) return;
            synchronized (elementsById) {
                if (list != null) 
                    list.remove(this);
                else {
                  Object o = elementsById.remove(id);
                  if (o != this) // oops not us!
                      elementsById.put(id, o);
                }
            }
        }
    }

    /**
     * Remove the mapping for <tt>element</tt> to <tt>id</tt>
     */
    public void removeIdEntry(Element e, String id) {
        // Remove old Id mapping if we have one.
        if (id == null) return;
        if (elementsById == null) return;

        synchronized (elementsById) {
            Object o = elementsById.get(id);
            if (o == null) return;

            if (o instanceof IdSoftRef) {
                elementsById.remove(id);
                return;
            } 
            
            List l = (List)o;
            Iterator li = l.iterator();
            while (li.hasNext()) {
                IdSoftRef ip = (IdSoftRef)li.next();
                o = ip.get();
                if (o == null) {
                    li.remove();
                } else if (e == o) {
                    li.remove();
                    break;
                }
            }
            
            if (l.size() == 0)
                elementsById.remove(id);
        }
    }

    public void addIdEntry(Element e, String id) {
        if (id == null) return;

        if (elementsById == null) {
            Map tmp = new HashMap();
            synchronized (tmp) {
                elementsById = tmp;
                elementsById.put(id, new IdSoftRef(e, id));
            }
            return;
        }

        synchronized (elementsById) {
            // Add new Id mapping.
            Object o = elementsById.get(id);
            if (o == null) {
                elementsById.put(id, new IdSoftRef(e, id));
                return;
            }
            if (o instanceof IdSoftRef) {
                IdSoftRef ip = (IdSoftRef)o;
                Object r = ip.get();
                if (r == null) { // reference is gone so replace it.
                    elementsById.put(id, new IdSoftRef(e, id));
                    return;
                }
                
                // Create new List for this id.
                List l = new ArrayList(4);
                ip.setList(l);
                l.add(ip);
                l.add(new IdSoftRef(e, id, l));
                elementsById.put(id, l);
                return;
            }
            
            List l = (List)o;
            l.add(new IdSoftRef(e, id, l));
        }
    }

    public void updateIdEntry(Element e, String oldId, String newId) {
        if ((oldId == newId) || 
            ((oldId != null) && (oldId.equals(newId)))) 
            return;

        removeIdEntry(e, oldId);

        addIdEntry(e, newId);
    }


    /**
     * Returns an ElementsByTagName object from the cache, if any.
     */
    public ElementsByTagName getElementsByTagName(Node n, String ln) {
        if (elementsByTagNames == null) {
            return null;
        }
        SoftDoublyIndexedTable t;
        t = (SoftDoublyIndexedTable)elementsByTagNames.get(n);
        if (t == null) {
            return null;
        }
        return (ElementsByTagName)t.get(null, ln);
    }

    /**
     * Puts an ElementsByTagName object in the cache.
     */
    public void putElementsByTagName(Node n, String ln, ElementsByTagName l) {
        if (elementsByTagNames == null) {
            elementsByTagNames = new WeakHashMap(11);
        }
        SoftDoublyIndexedTable t;
        t = (SoftDoublyIndexedTable)elementsByTagNames.get(n);
        if (t == null) {
            elementsByTagNames.put(n, t = new SoftDoublyIndexedTable());
        }
        t.put(null, ln, l);
    }

    /**
     * Returns an ElementsByTagNameNS object from the cache, if any.
     */
    public ElementsByTagNameNS getElementsByTagNameNS(Node n,
                                                    String ns,
                                                    String ln) {
        if (elementsByTagNamesNS == null) {
            return null;
        }
        SoftDoublyIndexedTable t;
        t = (SoftDoublyIndexedTable)elementsByTagNamesNS.get(n);
        if (t == null) {
            return null;
        }
        return (ElementsByTagNameNS)t.get(ns, ln);
    }

    /**
     * Puts an ElementsByTagNameNS object in the cache.
     */
    public void putElementsByTagNameNS(Node n, String ns, String ln,
                                       ElementsByTagNameNS l) {
        if (elementsByTagNamesNS == null) {
            elementsByTagNamesNS = new WeakHashMap(11);
        }
        SoftDoublyIndexedTable t;
        t = (SoftDoublyIndexedTable)elementsByTagNamesNS.get(n);
        if (t == null) {
            elementsByTagNamesNS.put(n, t = new SoftDoublyIndexedTable());
        }
        t.put(ns, ln, l);
    }

    // DocumentEvent /////////////////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.events.DocumentEvent#createEvent(String)}.
     */
    public Event createEvent(String eventType) throws DOMException {
        if (documentEventSupport == null) {
            documentEventSupport =
                ((AbstractDOMImplementation)implementation).
                    createDocumentEventSupport();
        }
	return documentEventSupport.createEvent(eventType);
    }

    // DocumentTraversal /////////////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link
     * DocumentTraversal#createNodeIterator(Node,int,NodeFilter,boolean)}.
     */
    public NodeIterator createNodeIterator(Node root,
                                           int whatToShow, 
                                           NodeFilter filter, 
                                           boolean entityReferenceExpansion)
        throws DOMException {
        if (traversalSupport == null) {
            traversalSupport = new TraversalSupport();
        }
        return traversalSupport.createNodeIterator(this, root, whatToShow,
                                                   filter,
                                                   entityReferenceExpansion);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * DocumentTraversal#createTreeWalker(Node,int,NodeFilter,boolean)}.
     */
    public TreeWalker createTreeWalker(Node root, 
                                       int whatToShow, 
                                       NodeFilter filter, 
                                       boolean entityReferenceExpansion)
        throws DOMException {
        return TraversalSupport.createTreeWalker(this, root, whatToShow,
                                                 filter,
                                                 entityReferenceExpansion);
    }

    /**
     * Detaches the given node iterator from this document.
     */
    public void detachNodeIterator(NodeIterator it) {
        traversalSupport.detachNodeIterator(it);
    }

    /**
     * Notifies this document that a node will be removed.
     */
    public void nodeToBeRemoved(Node node) {
        if (traversalSupport != null) {
            traversalSupport.nodeToBeRemoved(node);
        }
    }

    /**
     * Returns the current document.
     */
    protected AbstractDocument getCurrentDocument() {
	return this;
    }

    /**
     * Exports this node to the given document.
     * @param n The clone node.
     * @param d The destination document.
     */
    protected Node export(Node n, Document d) {
	throw createDOMException(DOMException.NOT_SUPPORTED_ERR,
				 "import.document",
				 new Object[] {});
    }

    /**
     * Deeply exports this node to the given document.
     * @param n The clone node.
     * @param d The destination document.
     */
    protected Node deepExport(Node n, Document d) {
	throw createDOMException(DOMException.NOT_SUPPORTED_ERR,
				 "import.document",
				 new Object[] {});
    }

    /**
     * Copy the fields of the current node into the given node.
     * @param n a node of the type of this.
     */
    protected Node copyInto(Node n) {
	super.copyInto(n);
	AbstractDocument ad = (AbstractDocument)n;
	ad.implementation = implementation;
        ad.localizableSupport = new LocalizableSupport
            (RESOURCES, getClass().getClassLoader());
	return n;
    }

    /**
     * Deeply copy the fields of the current node into the given node.
     * @param n a node of the type of this.
     */
    protected Node deepCopyInto(Node n) {
	super.deepCopyInto(n);
	AbstractDocument ad = (AbstractDocument)n;
	ad.implementation = implementation;
        ad.localizableSupport = new LocalizableSupport
            (RESOURCES, getClass().getClassLoader());
	return n;
    }

    /**
     * Checks the validity of a node to be inserted.
     */
    protected void checkChildType(Node n, boolean replace) {
	short t = n.getNodeType();
	switch (t) {
	case ELEMENT_NODE:
	case PROCESSING_INSTRUCTION_NODE:
	case COMMENT_NODE:
	case DOCUMENT_TYPE_NODE:
	case DOCUMENT_FRAGMENT_NODE:
	    break;
	default:
	    throw createDOMException(DOMException.HIERARCHY_REQUEST_ERR,
				     "child.type",
				     new Object[] { new Integer(getNodeType()),
						    getNodeName(),
		                                    new Integer(t),
						    n.getNodeName() });
	}
	if (!replace &&
            (t == ELEMENT_NODE && getDocumentElement() != null) ||
	    (t == DOCUMENT_TYPE_NODE && getDoctype() != null)) {
	    throw createDOMException(DOMException.HIERARCHY_REQUEST_ERR,
				     "child.type",
				     new Object[] { new Integer(getNodeType()),
						    getNodeName(),
		                                    new Integer(t),
						    n.getNodeName() });
	}
    }

    // Serializable /////////////////////////////////////////////////

    private void writeObject(ObjectOutputStream s) throws IOException {
        s.defaultWriteObject();

        s.writeObject(implementation.getClass().getName());
    }

    private void readObject(ObjectInputStream s) 
        throws IOException, ClassNotFoundException {
        s.defaultReadObject();

        localizableSupport = new LocalizableSupport
            (RESOURCES, getClass().getClassLoader());

        Class c = Class.forName((String)s.readObject());

        try {
            Method m = c.getMethod("getDOMImplementation", null);
            implementation = (DOMImplementation)m.invoke(null, null);
        } catch (Exception e) {
            try {
                implementation = (DOMImplementation)c.newInstance();
            } catch (Exception ex) {
            }
        }
    }
}
