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
package org.apache.flex.forks.batik.bridge;

import org.apache.flex.forks.batik.dom.events.DOMUIEvent;
import org.apache.flex.forks.batik.dom.events.NodeEventTarget;
import org.apache.flex.forks.batik.util.XMLConstants;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.events.DocumentEvent;
import org.w3c.dom.events.Event;
import org.w3c.dom.events.EventListener;
import org.w3c.dom.events.EventTarget;
import org.w3c.dom.events.MouseEvent;

/**
 * A class that manages focus on elements.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: FocusManager.java 475477 2006-11-15 22:44:28Z cam $
 */
public class FocusManager {

    /**
     * The element that has the focus so far.
     */
    protected EventTarget lastFocusEventTarget;

    /**
     * The document.
     */
    protected Document document;

    /**
     * The EventListener that tracks 'mouseclick' events.
     */
    protected EventListener mouseclickListener;

    /**
     * The EventListener that tracks 'DOMFocusIn' events.
     */
    protected EventListener domFocusInListener;

    /**
     * The EventListener that tracks 'DOMFocusOut' events.
     */
    protected EventListener domFocusOutListener;

    /**
     * The EventListener that tracks 'mouseover' events.
     */
    protected EventListener mouseoverListener;

    /**
     * The EventListener that tracks 'mouseout' events.
     */
    protected EventListener mouseoutListener;

    /**
     * Constructs a new <tt>FocusManager</tt> for the specified document.
     *
     * @param doc the document
     */
    public FocusManager(Document doc) {
        document = doc;
        addEventListeners(doc);
    }

    /**
     * Adds the event listeners to the document.
     */
    protected void addEventListeners(Document doc) {
        NodeEventTarget target = (NodeEventTarget) doc;

        mouseclickListener = new MouseClickTracker();
        target.addEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "click",
             mouseclickListener, true, null);

        mouseoverListener = new MouseOverTracker();
        target.addEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "mouseover",
             mouseoverListener, true, null);

        mouseoutListener = new MouseOutTracker();
        target.addEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "mouseout",
             mouseoutListener, true, null);

        domFocusInListener = new DOMFocusInTracker();
        target.addEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMFocusIn",
             domFocusInListener, true, null);

        domFocusOutListener = new DOMFocusOutTracker();
        target.addEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI,
             "DOMFocusOut",
             domFocusOutListener, true, null);
    }

    /**
     * Removes the event listeners from the document.
     */
    protected void removeEventListeners(Document doc) {
        NodeEventTarget target = (NodeEventTarget) doc;

        target.removeEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "click",
             mouseclickListener, true);
        target.removeEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "mouseover",
             mouseoverListener, true);
        target.removeEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "mouseout",
             mouseoutListener, true);
        target.removeEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMFocusIn",
             domFocusInListener, true);
        target.removeEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMFocusOut",
             domFocusOutListener, true);
    }

    /**
     * Returns the current element that has the focus or null if any.
     */
    public EventTarget getCurrentEventTarget() {
        return lastFocusEventTarget;
    }

    /**
     * Removes all listeners attached to the document and that manage focus.
     */
    public void dispose() {
        if (document == null) return;
        removeEventListeners(document);
        lastFocusEventTarget = null;
        document = null;
    }

    /**
     * The class that is responsible for tracking 'mouseclick' changes.
     */
    protected class MouseClickTracker implements EventListener {

        public void handleEvent(Event evt) {
            MouseEvent mevt = (MouseEvent)evt;
            fireDOMActivateEvent(evt.getTarget(), mevt.getDetail());
        }
    }

    /**
     * The class that is responsible for tracking 'DOMFocusIn' changes.
     */
    protected class DOMFocusInTracker implements EventListener {

        public void handleEvent(Event evt) {
            EventTarget newTarget = evt.getTarget();
            if (lastFocusEventTarget != null && 
                lastFocusEventTarget != newTarget) {
                fireDOMFocusOutEvent(lastFocusEventTarget, newTarget);
            }
            lastFocusEventTarget = evt.getTarget();
        }
    }

    /**
     * The class that is responsible for tracking 'DOMFocusOut' changes.
     */
    protected class DOMFocusOutTracker implements EventListener {

        public DOMFocusOutTracker() {
        }

        public void handleEvent(Event evt) {
            lastFocusEventTarget = null;
        }
    }

    /**
     * The class that is responsible to update the focus according to
     * 'mouseover' event.
     */
    protected class MouseOverTracker implements EventListener {

        public void handleEvent(Event evt) {
            MouseEvent me = (MouseEvent) evt;
            EventTarget target = evt.getTarget();
            EventTarget relatedTarget = me.getRelatedTarget();
            fireDOMFocusInEvent(target, relatedTarget);
        }
    }

    /**
     * The class that is responsible to update the focus according to
     * 'mouseout' event.
     */
    protected class MouseOutTracker implements EventListener {

        public void handleEvent(Event evt) {
            MouseEvent me = (MouseEvent) evt;
            EventTarget target = evt.getTarget();
            EventTarget relatedTarget = me.getRelatedTarget();
            fireDOMFocusOutEvent(target, relatedTarget);
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
                            true,    // canBubbleArg
                            false,   // cancelableArg
                            null,    // viewArg
                            0);      // detailArg
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
                            true,    // canBubbleArg
                            false,   // cancelableArg
                            null,    // viewArg
                            0);      // detailArg
        target.dispatchEvent(uiEvt);
    }
    
    /**
     * Fires a 'DOMActivate' event to the specified target.
     *
     * @param target the event target
     * @param detailArg the detailArg parameter of the event
     */
    protected void fireDOMActivateEvent(EventTarget target, int detailArg) {
        DocumentEvent docEvt = 
            (DocumentEvent)((Element)target).getOwnerDocument();
        DOMUIEvent uiEvt = (DOMUIEvent)docEvt.createEvent("UIEvents");
        uiEvt.initUIEventNS(XMLConstants.XML_EVENTS_NAMESPACE_URI,
                            "DOMActivate",
                            true,    // canBubbleArg
                            true,    // cancelableArg
                            null,    // viewArg
                            0);      // detailArg
        target.dispatchEvent(uiEvt);
    }
}
