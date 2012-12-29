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

import org.apache.flex.forks.batik.css.engine.CSSNavigableDocumentListener;
import org.apache.flex.forks.batik.dom.svg.SVGOMDocument;
import org.apache.flex.forks.batik.util.XMLConstants;

import org.w3c.dom.DOMImplementation;
import org.w3c.dom.DocumentType;
import org.w3c.dom.Node;
import org.w3c.dom.events.EventListener;
import org.w3c.dom.svg.SVGDocument;

/**
 * This class implements {@link SVGDocument} and provides support for
 * SVG 1.2 specifics.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: SVG12OMDocument.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SVG12OMDocument extends SVGOMDocument {

    /**
     * Creates a new uninitialized document.
     */
    protected SVG12OMDocument() {
    }

    /**
     * Creates a new SVG12OMDocument.
     */
    public SVG12OMDocument(DocumentType dt, DOMImplementation impl) {
        super(dt, impl);
    }

    // AbstractDocument ///////////////////////////////////////////////

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVG12OMDocument();
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

        XBLEventSupport es = (XBLEventSupport) initializeEventSupport();

        es.addImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMNodeInserted",
             nodeInserted, false);
        es.addImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMNodeRemoved",
             nodeRemoved, false);
        es.addImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMSubtreeModified",
             subtreeModified, false);
        es.addImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMCharacterDataModified",
             cdataModified, false);
        es.addImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMAttrModified",
             attrModified, false);
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

        XBLEventSupport es = (XBLEventSupport) initializeEventSupport();

        es.removeImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMNodeInserted",
             listeners[0], false);
        es.removeImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMNodeRemoved",
             listeners[1], false);
        es.removeImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMSubtreeModified",
             listeners[2], false);
        es.removeImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMCharacterDataModified",
             listeners[3], false);
        es.removeImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMAttrModified",
             listeners[4], false);

        cssNavigableDocumentListeners.remove(l);
    }
}
