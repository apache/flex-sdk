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
package org.apache.flex.forks.batik.dom.svg;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Locale;
import java.util.MissingResourceException;

import org.apache.flex.forks.batik.css.engine.CSSNavigableDocument;
import org.apache.flex.forks.batik.css.engine.CSSNavigableDocumentListener;
import org.apache.flex.forks.batik.css.engine.CSSStylableElement;
import org.apache.flex.forks.batik.dom.AbstractStylableDocument;
import org.apache.flex.forks.batik.dom.GenericAttr;
import org.apache.flex.forks.batik.dom.GenericAttrNS;
import org.apache.flex.forks.batik.dom.GenericCDATASection;
import org.apache.flex.forks.batik.dom.GenericComment;
import org.apache.flex.forks.batik.dom.GenericDocumentFragment;
import org.apache.flex.forks.batik.dom.GenericElement;
import org.apache.flex.forks.batik.dom.GenericEntityReference;
import org.apache.flex.forks.batik.dom.GenericProcessingInstruction;
import org.apache.flex.forks.batik.dom.GenericText;
import org.apache.flex.forks.batik.dom.StyleSheetFactory;
import org.apache.flex.forks.batik.dom.events.EventSupport;
import org.apache.flex.forks.batik.dom.util.XMLSupport;
import org.apache.flex.forks.batik.i18n.Localizable;
import org.apache.flex.forks.batik.i18n.LocalizableSupport;
import org.apache.flex.forks.batik.util.ParsedURL;
import org.apache.flex.forks.batik.util.SVGConstants;
import org.apache.flex.forks.batik.util.XMLConstants;

import org.w3c.dom.Attr;
import org.w3c.dom.CDATASection;
import org.w3c.dom.Comment;
import org.w3c.dom.DOMException;
import org.w3c.dom.DOMImplementation;
import org.w3c.dom.Document;
import org.w3c.dom.DocumentFragment;
import org.w3c.dom.DocumentType;
import org.w3c.dom.Element;
import org.w3c.dom.EntityReference;
import org.w3c.dom.Node;
import org.w3c.dom.ProcessingInstruction;
import org.w3c.dom.Text;
import org.w3c.dom.css.CSSStyleDeclaration;
import org.w3c.dom.css.DocumentCSS;
import org.w3c.dom.events.Event;
import org.w3c.dom.events.EventListener;
import org.w3c.dom.events.MutationEvent;
import org.w3c.dom.svg.SVGDocument;
import org.w3c.dom.svg.SVGLangSpace;
import org.w3c.dom.svg.SVGSVGElement;

/**
 * This class implements {@link SVGDocument}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMDocument.java 580678 2007-09-30 05:10:20Z cam $
 */
public class SVGOMDocument
    extends    AbstractStylableDocument
    implements SVGDocument,
               SVGConstants,
               CSSNavigableDocument,
               IdContainer {

    /**
     * The error messages bundle class name.
     */
    protected static final String RESOURCES =
        "org.apache.flex.forks.batik.dom.svg.resources.Messages";

    /**
     * The localizable support for the error messages.
     */
    protected transient LocalizableSupport localizableSupport =
        new LocalizableSupport(RESOURCES, getClass().getClassLoader());

    /**
     * The string representing the referrer.
     */
    protected String referrer = "";

    /**
     * The URL of the document.
     */
    protected ParsedURL url;

    /**
     * Is this document immutable?
     */
    protected transient boolean readonly;

    /**
     * Whether the document supports SVG 1.2.
     */
    protected boolean isSVG12;

    /**
     * Map of CSSNavigableDocumentListeners to an array of wrapper
     * DOM listeners.
     */
    protected HashMap cssNavigableDocumentListeners = new HashMap();

    /**
     * The main {@link AnimatedAttributeListener} that redispatches to all
     * listeners in {@link #animatedAttributeListeners}.
     */
    protected AnimatedAttributeListener mainAnimatedAttributeListener =
        new AnimAttrListener();

    /**
     * List of {@link AnimatedAttributeListener}s attached to this document.
     */
    protected LinkedList animatedAttributeListeners = new LinkedList();

    /**
     * The SVG context.
     */
    protected transient SVGContext svgContext;

    /**
     * Creates a new uninitialized document.
     */
    protected SVGOMDocument() {
    }

    /**
     * Creates a new document.
     */
    public SVGOMDocument(DocumentType dt, DOMImplementation impl) {
        super(dt, impl);
    }

    /**
     * Implements {@link Localizable#setLocale(Locale)}.
     */
    public void setLocale(Locale l) {
        super.setLocale(l);
        localizableSupport.setLocale(l);
    }

    /**
     * Implements {@link Localizable#formatMessage(String,Object[])}.
     */
    public String formatMessage(String key, Object[] args)
        throws MissingResourceException {
        try {
            return super.formatMessage(key, args);
        } catch (MissingResourceException e) {
            return localizableSupport.formatMessage(key, args);
        }
    }

    /**
     * <b>DOM</b>: Implements {@link SVGDocument#getTitle()}.
     */
    public String getTitle() {
        StringBuffer sb = new StringBuffer();
        boolean preserve = false;

        for (Node n = getDocumentElement().getFirstChild();
             n != null;
             n = n.getNextSibling()) {
            String ns = n.getNamespaceURI();
            if (ns != null && ns.equals(SVG_NAMESPACE_URI)) {
                if (n.getLocalName().equals(SVG_TITLE_TAG)) {
                    preserve = ((SVGLangSpace)n).getXMLspace().equals("preserve");
                    for (n = n.getFirstChild();
                         n != null;
                         n = n.getNextSibling()) {
                        if (n.getNodeType() == Node.TEXT_NODE) {
                            sb.append(n.getNodeValue());
                        }
                    }
                    break;
                }
            }
        }

        String s = sb.toString();
        return (preserve)
            ? XMLSupport.preserveXMLSpace(s)
            : XMLSupport.defaultXMLSpace(s);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGDocument#getReferrer()}.
     */
    public String getReferrer() {
        return referrer;
    }

    /**
     * Sets the referrer string.
     */
    public void setReferrer(String s) {
        referrer = s;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGDocument#getDomain()}.
     */
    public String getDomain() {
        return (url == null) ? null : url.getHost();
    }

    /**
     * <b>DOM</b>: Implements {@link SVGDocument#getRootElement()}.
     */
    public SVGSVGElement getRootElement() {
        return (SVGSVGElement)getDocumentElement();
    }

    /**
     * <b>DOM</b>: Implements {@link SVGDocument#getURL()}
     */
    public String getURL() {
        return documentURI;
    }

    /**
     * Returns the URI of the document.  If the document URI cannot be
     * represented as a {@link URL} (for example if it uses a <code>data:</code>
     * URI scheme), then <code>null</code> will be returned.
     */
    public URL getURLObject() {
        try {
            return new URL(documentURI);
        } catch (MalformedURLException e) {
            return null;
        }
    }

    /**
     * Returns the URI of the document.
     */
    public ParsedURL getParsedURL() {
        return url;
    }

    /**
     * Sets the URI of the document.
     */
    public void setURLObject(URL url) {
        setParsedURL(new ParsedURL(url));
    }

    /**
     * Sets the URI of the document.
     */
    public void setParsedURL(ParsedURL url) {
        this.url = url;
        documentURI = url == null ? null : url.toString();
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Document#setDocumentURI(String)}.
     */
    public void setDocumentURI(String uri) {
        documentURI = uri;
        url = uri == null ? null : new ParsedURL(uri);
    }

    /**
     * <b>DOM</b>: Implements {@link Document#createElement(String)}.
     */
    public Element createElement(String tagName) throws DOMException {
        return new GenericElement(tagName.intern(), this);
    }

    /**
     * <b>DOM</b>: Implements {@link Document#createDocumentFragment()}.
     */
    public DocumentFragment createDocumentFragment() {
        return new GenericDocumentFragment(this);
    }

    /**
     * <b>DOM</b>: Implements {@link Document#createTextNode(String)}.
     */
    public Text createTextNode(String data) {
        return new GenericText(data, this);
    }

    /**
     * <b>DOM</b>: Implements {@link Document#createComment(String)}.
     */
    public Comment createComment(String data) {
        return new GenericComment(data, this);
    }

    /**
     * <b>DOM</b>: Implements {@link Document#createCDATASection(String)}
     */
    public CDATASection createCDATASection(String data) throws DOMException {
        return new GenericCDATASection(data, this);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * Document#createProcessingInstruction(String,String)}.
     * @return a SVGStyleSheetProcessingInstruction if target is
     *         "xml-stylesheet" or a GenericProcessingInstruction otherwise.
     */
    public ProcessingInstruction createProcessingInstruction(String target,
                                                             String data)
        throws DOMException {
        if ("xml-stylesheet".equals(target)) {
            return new SVGStyleSheetProcessingInstruction
                (data, this, (StyleSheetFactory)getImplementation());
        }
        return new GenericProcessingInstruction(target, data, this);
    }

    /**
     * <b>DOM</b>: Implements {@link Document#createAttribute(String)}.
     */
    public Attr createAttribute(String name) throws DOMException {
        return new GenericAttr(name.intern(), this);
    }

    /**
     * <b>DOM</b>: Implements {@link Document#createEntityReference(String)}.
     */
    public EntityReference createEntityReference(String name)
        throws DOMException {
        return new GenericEntityReference(name, this);
    }

    /**
     * <b>DOM</b>: Implements {@link Document#createAttributeNS(String,String)}.
     */
    public Attr createAttributeNS(String namespaceURI, String qualifiedName)
        throws DOMException {
        if (namespaceURI == null) {
            return new GenericAttr(qualifiedName.intern(), this);
        } else {
            return new GenericAttrNS(namespaceURI.intern(),
                                     qualifiedName.intern(),
                                     this);
        }
    }

    /**
     * <b>DOM</b>: Implements {@link Document#createElementNS(String,String)}.
     */
    public Element createElementNS(String namespaceURI, String qualifiedName)
        throws DOMException {
        SVGDOMImplementation impl = (SVGDOMImplementation)implementation;
        return impl.createElementNS(this, namespaceURI, qualifiedName);
    }

    /**
     * Returns whether the document supports SVG 1.2.
     */
    public boolean isSVG12() {
        return isSVG12;
    }

    /**
     * Sets whether the document supports SVG 1.2.
     */
    public void setIsSVG12(boolean b) {
        isSVG12 = b;
    }

    /**
     * Returns true if the given Attr node represents an 'id'
     * for this document.
     */
    public boolean isId(Attr node) {
        if (node.getNamespaceURI() == null) {
            return SVG_ID_ATTRIBUTE.equals(node.getNodeName());
        }
        return node.getNodeName().equals(XML_ID_QNAME);
    }

    /**
     * Sets the SVG context to use to get SVG specific informations.
     *
     * @param ctx the SVG context
     */
    public void setSVGContext(SVGContext ctx) {
        svgContext = ctx;
    }

    /**
     * Returns the SVG context used to get SVG specific informations.
     */
    public SVGContext getSVGContext() {
        return svgContext;
    }

    // CSSNavigableDocument ///////////////////////////////////////////

    /**
     * Adds an event listener for mutations on the
     * CSSNavigableDocument tree.
     */
    public void addCSSNavigableDocumentListener
            (CSSNavigableDocumentListener l) {
        if (cssNavigableDocumentListeners.containsKey(l)) {
            return;
        }

        DOMNodeInsertedListenerWrapper nodeInserted
            = new DOMNodeInsertedListenerWrapper(l);
        DOMNodeRemovedListenerWrapper nodeRemoved
            = new DOMNodeRemovedListenerWrapper(l);
        DOMSubtreeModifiedListenerWrapper subtreeModified
            = new DOMSubtreeModifiedListenerWrapper(l);
        DOMCharacterDataModifiedListenerWrapper cdataModified
            = new DOMCharacterDataModifiedListenerWrapper(l);
        DOMAttrModifiedListenerWrapper attrModified
            = new DOMAttrModifiedListenerWrapper(l);

        cssNavigableDocumentListeners.put
            (l, new EventListener[] { nodeInserted,
                                      nodeRemoved,
                                      subtreeModified,
                                      cdataModified,
                                      attrModified });

        addEventListenerNS(XMLConstants.XML_EVENTS_NAMESPACE_URI,
                           "DOMNodeInserted", nodeInserted, false, null);
        addEventListenerNS(XMLConstants.XML_EVENTS_NAMESPACE_URI,
                           "DOMNodeRemoved", nodeRemoved, false, null);
        addEventListenerNS(XMLConstants.XML_EVENTS_NAMESPACE_URI,
                           "DOMSubtreeModified", subtreeModified, false, null);
        addEventListenerNS(XMLConstants.XML_EVENTS_NAMESPACE_URI,
                           "DOMCharacterDataModified", cdataModified, false,
                           null);
        addEventListenerNS(XMLConstants.XML_EVENTS_NAMESPACE_URI,
                           "DOMAttrModified", attrModified, false, null);
    }

    /**
     * Removes an event listener for mutations on the
     * CSSNavigableDocument tree.
     */
    public void removeCSSNavigableDocumentListener
            (CSSNavigableDocumentListener l) {
        EventListener[] listeners
            = (EventListener[]) cssNavigableDocumentListeners.get(l);
        if (listeners == null) {
            return;
        }

        removeEventListenerNS(XMLConstants.XML_EVENTS_NAMESPACE_URI,
                              "DOMNodeInserted", listeners[0], false);
        removeEventListenerNS(XMLConstants.XML_EVENTS_NAMESPACE_URI,
                              "DOMNodeRemoved", listeners[1], false);
        removeEventListenerNS(XMLConstants.XML_EVENTS_NAMESPACE_URI,
                              "DOMSubtreeModified", listeners[2], false);
        removeEventListenerNS(XMLConstants.XML_EVENTS_NAMESPACE_URI,
                              "DOMCharacterDataModified", listeners[3], false);
        removeEventListenerNS(XMLConstants.XML_EVENTS_NAMESPACE_URI,
                              "DOMAttrModified", listeners[4], false);

        cssNavigableDocumentListeners.remove(l);
    }

    /**
     * Returns the {@link AnimatedAttributeListener} for the document.
     */
    protected AnimatedAttributeListener getAnimatedAttributeListener() {
        return mainAnimatedAttributeListener;
    }

    /**
     * The text of the override style declaration for this element has been
     * modified.
     */
    protected void overrideStyleTextChanged(CSSStylableElement e, String text) {
        Iterator i = cssNavigableDocumentListeners.keySet().iterator();
        while (i.hasNext()) {
            CSSNavigableDocumentListener l =
                (CSSNavigableDocumentListener) i.next();
            l.overrideStyleTextChanged(e, text);
        }
    }

    /**
     * A property in the override style declaration has been removed.
     */
    protected void overrideStylePropertyRemoved(CSSStylableElement e,
                                                String name) {
        Iterator i = cssNavigableDocumentListeners.keySet().iterator();
        while (i.hasNext()) {
            CSSNavigableDocumentListener l =
                (CSSNavigableDocumentListener) i.next();
            l.overrideStylePropertyRemoved(e, name);
        }
    }

    /**
     * A property in the override style declaration has been changed.
     */
    protected void overrideStylePropertyChanged
            (CSSStylableElement e, String name, String value, String prio) {
        Iterator i = cssNavigableDocumentListeners.keySet().iterator();
        while (i.hasNext()) {
            CSSNavigableDocumentListener l =
                (CSSNavigableDocumentListener) i.next();
            l.overrideStylePropertyChanged(e, name, value, prio);
        }
    }

    /**
     * Adds an {@link AnimatedAttributeListener} to this document, to be
     * notified of animated XML attribute changes.
     */
    public void addAnimatedAttributeListener
            (AnimatedAttributeListener aal) {
        if (animatedAttributeListeners.contains(aal)) {
            return;
        }
        animatedAttributeListeners.add(aal);
    }

    /**
     * Removes an {@link AnimatedAttributeListener} from this document.
     */
    public void removeAnimatedAttributeListener
            (AnimatedAttributeListener aal) {
        animatedAttributeListeners.remove(aal);
    }

    /**
     * DOM node inserted listener wrapper.
     */
    protected class DOMNodeInsertedListenerWrapper implements EventListener {

        /**
         * The CSSNavigableDocumentListener.
         */
        protected CSSNavigableDocumentListener listener;

        /**
         * Creates a new DOMNodeInsertedListenerWrapper.
         */
        public DOMNodeInsertedListenerWrapper(CSSNavigableDocumentListener l) {
            listener = l;
        }

        /**
         * Handles the event.
         */
        public void handleEvent(Event evt) {
            evt = EventSupport.getUltimateOriginalEvent(evt);
            listener.nodeInserted((Node) evt.getTarget());
        }
    }

    /**
     * DOM node removed listener wrapper.
     */
    protected class DOMNodeRemovedListenerWrapper implements EventListener {

        /**
         * The CSSNavigableDocumentListener.
         */
        protected CSSNavigableDocumentListener listener;

        /**
         * Creates a new DOMNodeRemovedListenerWrapper.
         */
        public DOMNodeRemovedListenerWrapper(CSSNavigableDocumentListener l) {
            listener = l;
        }

        /**
         * Handles the event.
         */
        public void handleEvent(Event evt) {
            evt = EventSupport.getUltimateOriginalEvent(evt);
            listener.nodeToBeRemoved((Node) evt.getTarget());
        }
    }

    /**
     * DOM subtree modified listener wrapper.
     */
    protected class DOMSubtreeModifiedListenerWrapper implements EventListener {

        /**
         * The CSSNavigableDocumentListener.
         */
        protected CSSNavigableDocumentListener listener;

        /**
         * Creates a new DOMSubtreeModifiedListenerWrapper.
         */
        public DOMSubtreeModifiedListenerWrapper
                (CSSNavigableDocumentListener l) {
            listener = l;
        }

        /**
         * Handles the event.
         */
        public void handleEvent(Event evt) {
            evt = EventSupport.getUltimateOriginalEvent(evt);
            listener.subtreeModified((Node) evt.getTarget());
        }
    }

    /**
     * DOM character data modified listener wrapper.
     */
    protected class DOMCharacterDataModifiedListenerWrapper
            implements EventListener {

        /**
         * The CSSNavigableDocumentListener.
         */
        protected CSSNavigableDocumentListener listener;

        /**
         * Creates a new DOMCharacterDataModifiedListenerWrapper.
         */
        public DOMCharacterDataModifiedListenerWrapper
                (CSSNavigableDocumentListener l) {
            listener = l;
        }

        /**
         * Handles the event.
         */
        public void handleEvent(Event evt) {
            evt = EventSupport.getUltimateOriginalEvent(evt);
            listener.subtreeModified((Node) evt.getTarget());
        }
    }

    /**
     * DOM attribute modified listener wrapper.
     */
    protected class DOMAttrModifiedListenerWrapper implements EventListener {

        /**
         * The CSSNavigableDocumentListener.
         */
        protected CSSNavigableDocumentListener listener;

        /**
         * Creates a new DOMAttrModifiedListenerWrapper.
         */
        public DOMAttrModifiedListenerWrapper(CSSNavigableDocumentListener l) {
            listener = l;
        }

        /**
         * Handles the event.
         */
        public void handleEvent(Event evt) {
            evt = EventSupport.getUltimateOriginalEvent(evt);
            MutationEvent mevt = (MutationEvent) evt;
            listener.attrModified((Element) evt.getTarget(),
                                  (Attr) mevt.getRelatedNode(),
                                  mevt.getAttrChange(),
                                  mevt.getPrevValue(),
                                  mevt.getNewValue());
        }
    }

    /**
     * Listener class for animated attribute changes.
     */
    protected class AnimAttrListener implements AnimatedAttributeListener {

        /**
         * Called to notify an object of a change to the animated value of
         * an animatable XML attribute.
         * @param e the owner element of the changed animatable attribute
         * @param alav the AnimatedLiveAttributeValue that changed
         */
        public void animatedAttributeChanged(Element e,
                                             AnimatedLiveAttributeValue alav) {
            Iterator i = animatedAttributeListeners.iterator();
            while (i.hasNext()) {
                AnimatedAttributeListener aal =
                    (AnimatedAttributeListener) i.next();
                aal.animatedAttributeChanged(e, alav);
            }
        }

        /**
         * Called to notify an object of a change to the value of an 'other'
         * animation.
         * @param e the element being animated
         * @param type the type of animation whose value changed
         */
        public void otherAnimationChanged(Element e, String type) {
            Iterator i = animatedAttributeListeners.iterator();
            while (i.hasNext()) {
                AnimatedAttributeListener aal =
                    (AnimatedAttributeListener) i.next();
                aal.otherAnimationChanged(e, type);
            }
        }
    }

    // DocumentCSS ////////////////////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements
     * {@link DocumentCSS#getOverrideStyle(Element,String)}.
     */
    public CSSStyleDeclaration getOverrideStyle(Element elt,
                                                String pseudoElt) {
        if (elt instanceof SVGStylableElement && pseudoElt == null) {
            return ((SVGStylableElement) elt).getOverrideStyle();
        }
        return null;
    }

    // AbstractDocument ///////////////////////////////////////////////

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
        return new SVGOMDocument();
    }

    /**
     * Copy the fields of the current node into the given node.
     * @param n a node of the type of this.
     */
    protected Node copyInto(Node n) {
        super.copyInto(n);
        SVGOMDocument sd = (SVGOMDocument)n;
        sd.localizableSupport = new LocalizableSupport
            (RESOURCES, getClass().getClassLoader());
        sd.referrer = referrer;
        sd.url = url;
        return n;
    }

    /**
     * Deeply copy the fields of the current node into the given node.
     * @param n a node of the type of this.
     */
    protected Node deepCopyInto(Node n) {
        super.deepCopyInto(n);
        SVGOMDocument sd = (SVGOMDocument)n;
        sd.localizableSupport = new LocalizableSupport
            (RESOURCES, getClass().getClassLoader());
        sd.referrer = referrer;
        sd.url = url;
        return n;
    }

    // Serialization //////////////////////////////////////////////////////

    /**
     * Reads the object from the given stream.
     */
    private void readObject(ObjectInputStream s)
        throws IOException, ClassNotFoundException {
        s.defaultReadObject();

        localizableSupport = new LocalizableSupport
            (RESOURCES, getClass().getClassLoader());
    }
}
