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

import java.io.Serializable;

import org.apache.flex.forks.batik.dom.events.EventSupport;
import org.apache.flex.forks.batik.dom.events.NodeEventTarget;
import org.apache.flex.forks.batik.dom.util.DOMUtilities;
import org.apache.flex.forks.batik.dom.util.XMLSupport;
import org.w3c.dom.DOMException;
import org.w3c.dom.Document;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.w3c.dom.events.DocumentEvent;
import org.w3c.dom.events.Event;
import org.w3c.dom.events.EventException;
import org.w3c.dom.events.EventListener;
import org.w3c.dom.events.MutationEvent;

/**
 * This class implements the {@link org.w3c.dom.Node} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: AbstractNode.java,v 1.19 2005/03/27 08:58:32 cam Exp $
 */
public abstract class AbstractNode
    implements ExtendedNode,
               Serializable {

    /**
     * An empty instance of NodeList.
     */
    protected final static NodeList EMPTY_NODE_LIST = new NodeList() {
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
        return (deep) ? deepCopyInto(newNode()) : copyInto(newNode());
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
            setNodeName(name);
        }
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
        setNodeName(prefix + ":" + name);
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
            eventSupport = new EventSupport();
            AbstractDocument doc = getCurrentDocument();
            doc.setEventsEnabled(true);
        }
        eventSupport.addEventListener(type, listener, useCapture);
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
     * Implements {@link
     * org.apache.flex.forks.batik.dom.events.NodeEventTarget#getParentNodeEventTarget()}.
     */
    public NodeEventTarget getParentNodeEventTarget() {
        return (NodeEventTarget)getParentNode();
    }

    /**
     * <b>DOM</b>: Implements
     * {@link org.w3c.dom.events.EventTarget#dispatchEvent(Event)}.
     */
    public boolean dispatchEvent(Event evt) throws EventException {
        return EventSupport.dispatchEvent(this, evt);
    }

    /**
     * Returns the event support instance for this node, or null if any.
     */
    public EventSupport getEventSupport() {
        return eventSupport;
    }

    /**
     * Recursively fires a DOMNodeInsertedIntoDocument event.
     */
    public void fireDOMNodeInsertedIntoDocumentEvent() {
        AbstractDocument doc = getCurrentDocument();
        if (doc.getEventsEnabled()) {
            DocumentEvent de = (DocumentEvent)doc;
            MutationEvent ev = (MutationEvent)de.createEvent("MutationEvents");
            ev.initMutationEvent("DOMNodeInsertedIntoDocument",
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
            DocumentEvent de = (DocumentEvent)doc;
            MutationEvent ev = (MutationEvent)de.createEvent("MutationEvents");
            ev.initMutationEvent("DOMNodeRemovedFromDocument",
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
            DocumentEvent de = (DocumentEvent)doc;
            MutationEvent ev = (MutationEvent)de.createEvent("MutationEvents");
            ev.initMutationEvent("DOMCharacterDataModified",
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
}
