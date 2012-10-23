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
package org.apache.flex.forks.batik.bridge.svg12;

import org.apache.flex.forks.batik.bridge.FocusManager;
import org.apache.flex.forks.batik.dom.AbstractNode;
import org.apache.flex.forks.batik.dom.events.AbstractEvent;
import org.apache.flex.forks.batik.dom.events.DOMUIEvent;
import org.apache.flex.forks.batik.dom.events.EventSupport;
import org.apache.flex.forks.batik.dom.svg12.XBLEventSupport;
import org.apache.flex.forks.batik.util.XMLConstants;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.events.DocumentEvent;
import org.w3c.dom.events.Event;
import org.w3c.dom.events.EventTarget;

/**
 * Focus manager for SVG 1.2 documents.  Ensures bubble limits of DOM
 * focus events are set appropriately for sXBL. support.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: SVG12FocusManager.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SVG12FocusManager extends FocusManager {

    /**
     * Constructs a new <tt>SVG12FocusManager</tt> for the specified document.
     *
     * @param doc the document
     */
    public SVG12FocusManager(Document doc) {
        super(doc);
    }

    /**
     * Adds the event listeners to the document.
     */
    protected void addEventListeners(Document doc) {
        AbstractNode n = (AbstractNode) doc;
        XBLEventSupport es = (XBLEventSupport) n.initializeEventSupport();

        mouseclickListener = new MouseClickTracker();
        es.addImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "click",
             mouseclickListener, true);

        mouseoverListener = new MouseOverTracker();
        es.addImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "mouseover",
             mouseoverListener, true);

        mouseoutListener = new MouseOutTracker();
        es.addImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "mouseout",
             mouseoutListener, true);

        domFocusInListener = new DOMFocusInTracker();
        es.addImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMFocusIn",
             domFocusInListener, true);

        domFocusOutListener = new DOMFocusOutTracker();
        es.addImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMFocusOut",
             domFocusOutListener, true);
    }

    /**
     * Removes the event listeners from the document.
     */
    protected void removeEventListeners(Document doc) {
        AbstractNode n = (AbstractNode) doc;
        XBLEventSupport es = (XBLEventSupport) n.getEventSupport();

        es.removeImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "click",
             mouseclickListener, true);
        es.removeImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "mouseover",
             mouseoverListener, true);
        es.removeImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "mouseout",
             mouseoutListener, true);
        es.removeImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMFocusIn",
             domFocusInListener, true);
        es.removeImplementationEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMFocusOut",
             domFocusOutListener, true);
    }

    /**
     * The class that is responsible for tracking 'mouseclick' changes.
     */
    protected class MouseClickTracker extends FocusManager.MouseClickTracker {
        public void handleEvent(Event evt) {
            super.handleEvent(EventSupport.getUltimateOriginalEvent(evt));
        }
    }

    /**
     * The class that is responsible for tracking 'DOMFocusIn' changes.
     */
    protected class DOMFocusInTracker extends FocusManager.DOMFocusInTracker {
        public void handleEvent(Event evt) {
            super.handleEvent(EventSupport.getUltimateOriginalEvent(evt));
        }
    }

    /**
     * The class that is responsible for tracking 'mouseover' changes.
     */
    protected class MouseOverTracker extends FocusManager.MouseOverTracker {
        public void handleEvent(Event evt) {
            super.handleEvent(EventSupport.getUltimateOriginalEvent(evt));
        }
    }

    /**
     * The class that is responsible for tracking 'mouseout' changes.
     */
    protected class MouseOutTracker extends FocusManager.MouseOutTracker {
        public void handleEvent(Event evt) {
            super.handleEvent(EventSupport.getUltimateOriginalEvent(evt));
        }
    }

    /**
     * Fires a 'DOMFocusIn' event to the specified target.
     *
     * @param target the newly focussed event target
     * @param relatedTarget the previously focussed event target
     */
    protected void fireDOMFocusInEvent(EventTarget target,
                                       EventTarget relatedTarget) {
        DocumentEvent docEvt = 
            (DocumentEvent)((Element)target).getOwnerDocument();
        DOMUIEvent uiEvt = (DOMUIEvent)docEvt.createEvent("UIEvents");
        uiEvt.initUIEventNS(XMLConstants.XML_EVENTS_NAMESPACE_URI,
                            "DOMFocusIn",
                            true,
                            false,  // canBubbleArg
                            null,   // cancelableArg
                            0);     // detailArg
        int limit = DefaultXBLManager.computeBubbleLimit((Node) relatedTarget,
                                                         (Node) target);
        ((AbstractEvent) uiEvt).setBubbleLimit(limit);
        target.dispatchEvent(uiEvt);
    }

    /**
     * Fires a 'DOMFocusOut' event to the specified target.
     *
     * @param target the previously focussed event target
     * @param relatedTarget the newly focussed event target
     */
    protected void fireDOMFocusOutEvent(EventTarget target,
                                        EventTarget relatedTarget) {
        DocumentEvent docEvt = 
            (DocumentEvent)((Element)target).getOwnerDocument();
        DOMUIEvent uiEvt = (DOMUIEvent)docEvt.createEvent("UIEvents");
        uiEvt.initUIEventNS(XMLConstants.XML_EVENTS_NAMESPACE_URI,
                            "DOMFocusOut",
                            true,
                            false,  // canBubbleArg
                            null,   // cancelableArg
                            0);     // detailArg
        int limit = DefaultXBLManager.computeBubbleLimit((Node) target,
                                                         (Node) relatedTarget);
        ((AbstractEvent) uiEvt).setBubbleLimit(limit);
        target.dispatchEvent(uiEvt);
    }
}
