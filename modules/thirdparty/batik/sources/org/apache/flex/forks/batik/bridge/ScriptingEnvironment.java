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

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Reader;
import java.io.StringReader;
import java.io.UnsupportedEncodingException;
import java.io.Writer;
import java.net.URL;
import java.net.URLConnection;
import java.util.HashMap;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;
import java.util.zip.DeflaterOutputStream;
import java.util.zip.GZIPOutputStream;

import org.apache.flex.forks.batik.dom.GenericDOMImplementation;
import org.apache.flex.forks.batik.dom.events.NodeEventTarget;
import org.apache.flex.forks.batik.dom.svg.SAXSVGDocumentFactory;
import org.apache.flex.forks.batik.dom.svg.SVGOMDocument;
import org.apache.flex.forks.batik.dom.util.DOMUtilities;
import org.apache.flex.forks.batik.dom.util.SAXDocumentFactory;
import org.apache.flex.forks.batik.dom.util.XLinkSupport;
import org.apache.flex.forks.batik.script.Interpreter;
import org.apache.flex.forks.batik.script.InterpreterException;
import org.apache.flex.forks.batik.script.ScriptEventWrapper;
import org.apache.flex.forks.batik.util.EncodingUtilities;
import org.apache.flex.forks.batik.util.ParsedURL;
import org.apache.flex.forks.batik.util.RunnableQueue;
import org.apache.flex.forks.batik.util.SVGConstants;
import org.apache.flex.forks.batik.util.XMLConstants;
import org.apache.flex.forks.batik.util.XMLResourceDescriptor;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.events.Event;
import org.w3c.dom.events.EventListener;
import org.w3c.dom.events.MutationEvent;
import org.w3c.dom.svg.SVGDocument;

/**
 * This class contains the informations needed by the SVG scripting.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: ScriptingEnvironment.java 594367 2007-11-13 00:40:53Z cam $
 */
public class ScriptingEnvironment extends BaseScriptingEnvironment {

    public static final String [] SVG_EVENT_ATTRS = {
        "onabort",     // SVG element
        "onerror",     // SVG element
        "onresize",    // SVG element
        "onscroll",    // SVG element
        "onunload",    // SVG element
        "onzoom",      // SVG element

        "onbegin",     // SMIL
        "onend",       // SMIL
        "onrepeat",    // SMIL

        "onfocusin",   // UI Events
        "onfocusout",  // UI Events
        "onactivate",  // UI Events
        "onclick",     // UI Events

        "onmousedown", // UI Events
        "onmouseup",   // UI Events
        "onmouseover", // UI Events
        "onmouseout",  // UI Events
        "onmousemove", // UI Events

        "onkeypress",  // UI Events
        "onkeydown",   // UI Events
        "onkeyup"      // UI Events
    };

    public static final String [] SVG_DOM_EVENT = {
        "SVGAbort",    // SVG element
        "SVGError",    // SVG element
        "SVGResize",   // SVG element
        "SVGScroll",   // SVG element
        "SVGUnload",   // SVG element
        "SVGZoom",     // SVG element

        "beginEvent",  // SMIL
        "endEvent",    // SMIL
        "repeatEvent", // SMIL

        "DOMFocusIn",  // UI Events
        "DOMFocusOut", // UI Events
        "DOMActivate", // UI Events
        "click",       // UI Events
        "mousedown",   // UI Events
        "mouseup",     // UI Events
        "mouseover",   // UI Events
        "mouseout",    // UI Events
        "mousemove",   // UI Events
        "keypress",    // UI Events
        "keydown",     // UI Events
        "keyup"        // UI Events
    };

    /**
     * The timer for periodic or delayed tasks.
     */
    protected Timer timer = new Timer(true);

    /**
     * The update manager.
     */
    protected UpdateManager updateManager;

    /**
     * The update runnable queue.
     */
    protected RunnableQueue updateRunnableQueue;

    /**
     * The DOMNodeInserted event listener.
     */
    protected EventListener domNodeInsertedListener;

    /**
     * The DOMNodeRemoved event listener.
     */
    protected EventListener domNodeRemovedListener;

    /**
     * The DOMAttrModified event listener.
     */
    protected EventListener domAttrModifiedListener;

    /**
     * The SVGAbort event listener.
     */
    protected EventListener svgAbortListener =
        new ScriptingEventListener("onabort");

    /**
     * The SVGError event listener.
     */
    protected EventListener svgErrorListener =
        new ScriptingEventListener("onerror");

    /**
     * The SVGResize event listener.
     */
    protected EventListener svgResizeListener =
        new ScriptingEventListener("onresize");

    /**
     * The SVGScroll event listener.
     */
    protected EventListener svgScrollListener =
        new ScriptingEventListener("onscroll");

    /**
     * The SVGUnload event listener.
     */
    protected EventListener svgUnloadListener =
        new ScriptingEventListener("onunload");

    /**
     * The SVGZoom event listener.
     */
    protected EventListener svgZoomListener =
        new ScriptingEventListener("onzoom");

    /**
     * The begin event listener.
     */
    protected EventListener beginListener =
        new ScriptingEventListener("onbegin");

    /**
     * The end event listener.
     */
    protected EventListener endListener =
        new ScriptingEventListener("onend");

    /**
     * The repeat event listener.
     */
    protected EventListener repeatListener =
        new ScriptingEventListener("onrepeat");

    /**
     * The focusin event listener.
     */
    protected EventListener focusinListener =
        new ScriptingEventListener("onfocusin");

    /**
     * The focusout event listener.
     */
    protected EventListener focusoutListener =
        new ScriptingEventListener("onfocusout");

    /**
     * The activate event listener.
     */
    protected EventListener activateListener =
        new ScriptingEventListener("onactivate");

    /**
     * The click event listener.
     */
    protected EventListener clickListener =
        new ScriptingEventListener("onclick");

    /**
     * The mousedown event listener.
     */
    protected EventListener mousedownListener =
        new ScriptingEventListener("onmousedown");

    /**
     * The mouseup event listener.
     */
    protected EventListener mouseupListener =
        new ScriptingEventListener("onmouseup");

    /**
     * The mouseover event listener.
     */
    protected EventListener mouseoverListener =
        new ScriptingEventListener("onmouseover");

    /**
     * The mouseout event listener.
     */
    protected EventListener mouseoutListener =
        new ScriptingEventListener("onmouseout");

    /**
     * The mousemove event listener.
     */
    protected EventListener mousemoveListener =
        new ScriptingEventListener("onmousemove");

    /**
     * The keypress event listener.
     */
    protected EventListener keypressListener =
        new ScriptingEventListener("onkeypress");

    /**
     * The keydown event listener.
     */
    protected EventListener keydownListener =
        new ScriptingEventListener("onkeydown");

    /**
     * The keyup event listener.
     */
    protected EventListener keyupListener =
        new ScriptingEventListener("onkeyup");


    protected EventListener [] listeners = {
        svgAbortListener,
        svgErrorListener,
        svgResizeListener,
        svgScrollListener,
        svgUnloadListener,
        svgZoomListener,

        beginListener,
        endListener,
        repeatListener,

        focusinListener,
        focusoutListener,
        activateListener,
        clickListener,

        mousedownListener,
        mouseupListener,
        mouseoverListener,
        mouseoutListener,
        mousemoveListener,

        keypressListener,
        keydownListener,
        keyupListener
    };

    Map attrToDOMEvent = new HashMap(SVG_EVENT_ATTRS.length);
    Map attrToListener = new HashMap(SVG_EVENT_ATTRS.length);
    {
        for (int i=0; i<SVG_EVENT_ATTRS.length; i++) {
            attrToDOMEvent.put(SVG_EVENT_ATTRS[i], SVG_DOM_EVENT[i]);
            attrToListener.put(SVG_EVENT_ATTRS[i], listeners[i]);
        }
    }

    /**
     * Creates a new ScriptingEnvironment.
     * @param ctx the bridge context
     */
    public ScriptingEnvironment(BridgeContext ctx) {
        super(ctx);
        updateManager = ctx.getUpdateManager();
        updateRunnableQueue = updateManager.getUpdateRunnableQueue();

        // Add the scripting listeners.
        addScriptingListeners(document.getDocumentElement());

        // Add the listeners responsible of updating the event attributes
        addDocumentListeners();
    }

    /**
     * Adds DOM listeners to the document.
     */
    protected void addDocumentListeners() {
        domNodeInsertedListener = new DOMNodeInsertedListener();
        domNodeRemovedListener = new DOMNodeRemovedListener();
        domAttrModifiedListener = new DOMAttrModifiedListener();
        NodeEventTarget et = (NodeEventTarget) document;
        et.addEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMNodeInserted",
             domNodeInsertedListener, false, null);
        et.addEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMNodeRemoved",
             domNodeRemovedListener, false, null);
        et.addEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMAttrModified",
             domAttrModifiedListener, false, null);
    }

    /**
     * Removes DOM listeners from the document.
     */
    protected void removeDocumentListeners() {
        NodeEventTarget et = (NodeEventTarget) document;
        et.removeEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMNodeInserted",
             domNodeInsertedListener, false);
        et.removeEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMNodeRemoved",
             domNodeRemovedListener, false);
        et.removeEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMAttrModified",
             domAttrModifiedListener, false);
    }

    /**
     * Creates a new Window object.
     */
    public org.apache.flex.forks.batik.script.Window createWindow(Interpreter interp,
                                                       String lang) {
        return new Window(interp, lang);
    }

    /**
     * Runs an event handler.
     */
    public void runEventHandler(String script, Event evt,
                                String lang, String desc) {
        Interpreter interpreter = getInterpreter(lang);
        if (interpreter == null)
            return;

        try {
            checkCompatibleScriptURL(lang, docPURL);

            Object event;
            if (evt instanceof ScriptEventWrapper) {
                event = ((ScriptEventWrapper) evt).getEventObject();
            } else {
                event = evt;
            }
            interpreter.bindObject(EVENT_NAME, event);
            interpreter.bindObject(ALTERNATE_EVENT_NAME, event);
            interpreter.evaluate(new StringReader(script), desc);
        } catch (IOException ioe) {
            // Do nothing, can't really happen with StringReader
        } catch (InterpreterException ie) {
            handleInterpreterException(ie);
        } catch (SecurityException se) {
            handleSecurityException(se);
        }
    }

    /**
     * Interrupts the periodic tasks and dispose this ScriptingEnvironment.
     */
    public void interrupt() {
        timer.cancel();
        // Remove the scripting listeners.
        removeScriptingListeners(document.getDocumentElement());

        // Remove the listeners responsible of updating the event attributes
        removeDocumentListeners();
    }

    /**
     * Adds the scripting listeners to the given element and all of
     * its descendants.
     */
    public void addScriptingListeners(Node node) {
        if (node.getNodeType() == Node.ELEMENT_NODE) {
            addScriptingListenersOn((Element) node);
        }

        // Adds the listeners to the children
        for (Node n = node.getFirstChild();
             n != null;
             n = n.getNextSibling()) {
            addScriptingListeners(n);
        }
    }

    /**
     * Adds the scripting listeners to the given element.
     */
    protected void addScriptingListenersOn(Element elt) {
        // Attach the listeners
        NodeEventTarget target = (NodeEventTarget)elt;
        if (SVGConstants.SVG_NAMESPACE_URI.equals(elt.getNamespaceURI())) {
            if (SVGConstants.SVG_SVG_TAG.equals(elt.getLocalName())) {
                // <svg> listeners
                if (elt.hasAttributeNS(null, "onabort")) {
                    target.addEventListenerNS
                        (XMLConstants.XML_EVENTS_NAMESPACE_URI, "SVGAbort",
                         svgAbortListener, false, null);
                }
                if (elt.hasAttributeNS(null, "onerror")) {
                    target.addEventListenerNS
                        (XMLConstants.XML_EVENTS_NAMESPACE_URI, "SVGError",
                         svgErrorListener, false, null);
                }
                if (elt.hasAttributeNS(null, "onresize")) {
                    target.addEventListenerNS
                        (XMLConstants.XML_EVENTS_NAMESPACE_URI, "SVGResize",
                         svgResizeListener, false, null);
                }
                if (elt.hasAttributeNS(null, "onscroll")) {
                    target.addEventListenerNS
                        (XMLConstants.XML_EVENTS_NAMESPACE_URI, "SVGScroll",
                         svgScrollListener, false, null);
                }
                if (elt.hasAttributeNS(null, "onunload")) {
                    target.addEventListenerNS
                        (XMLConstants.XML_EVENTS_NAMESPACE_URI, "SVGUnload",
                         svgUnloadListener, false, null);
                }
                if (elt.hasAttributeNS(null, "onzoom")) {
                    target.addEventListenerNS
                        (XMLConstants.XML_EVENTS_NAMESPACE_URI, "SVGZoom",
                         svgZoomListener, false, null);
                }
            } else {
                String name = elt.getLocalName();
                if (name.equals(SVGConstants.SVG_SET_TAG) ||
                    name.startsWith("animate")) {
                    // animation listeners
                    if (elt.hasAttributeNS(null, "onbegin")) {
                        target.addEventListenerNS
                            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "beginEvent",
                             beginListener, false, null);
                    }
                    if (elt.hasAttributeNS(null, "onend")) {
                        target.addEventListenerNS
                            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "endEvent",
                             endListener, false, null);
                    }
                    if (elt.hasAttributeNS(null, "onrepeat")) {
                        target.addEventListenerNS
                            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "repeatEvent",
                             repeatListener, false, null);
                    }
                    return;
                }
            }
        }

        // UI listeners
        if (elt.hasAttributeNS(null, "onfocusin")) {
            target.addEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMFocusIn",
                 focusinListener, false, null);
        }
        if (elt.hasAttributeNS(null, "onfocusout")) {
            target.addEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMFocusOut",
                 focusoutListener, false, null);
        }
        if (elt.hasAttributeNS(null, "onactivate")) {
            target.addEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMActivate",
                 activateListener, false, null);
        }
        if (elt.hasAttributeNS(null, "onclick")) {
            target.addEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, "click",
                 clickListener, false, null);
        }
        if (elt.hasAttributeNS(null, "onmousedown")) {
            target.addEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, "mousedown",
                 mousedownListener, false, null);
        }
        if (elt.hasAttributeNS(null, "onmouseup")) {
            target.addEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, "mouseup",
                 mouseupListener, false, null);
        }
        if (elt.hasAttributeNS(null, "onmouseover")) {
            target.addEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, "mouseover",
                 mouseoverListener, false, null);
        }
        if (elt.hasAttributeNS(null, "onmouseout")) {
            target.addEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, "mouseout",
                 mouseoutListener, false, null);
        }
        if (elt.hasAttributeNS(null, "onmousemove")) {
            target.addEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, "mousemove",
                 mousemoveListener, false, null);
        }
        if (elt.hasAttributeNS(null, "onkeypress")) {
            target.addEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, "keypress",
                 keypressListener, false, null);
        }
        if (elt.hasAttributeNS(null, "onkeydown")) {
            target.addEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, "keydown",
                 keydownListener, false, null);
        }
        if (elt.hasAttributeNS(null, "onkeyup")) {
            target.addEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, "keyup",
                 keyupListener, false, null);
        }
    }

    /**
     * Removes the scripting listeners from the given element and all
     * of its descendants.
     */
    protected void removeScriptingListeners(Node node) {
        if (node.getNodeType() == Node.ELEMENT_NODE) {
            // Detach the listeners
            removeScriptingListenersOn((Element) node);
        }

        // Removes the listeners from the children
        for (Node n = node.getFirstChild();
             n != null;
             n = n.getNextSibling()) {
            removeScriptingListeners(n);
        }
    }

    /**
     * Removes the scripting listeners from the given element.
     */
    protected void removeScriptingListenersOn(Element elt) {
        NodeEventTarget target = (NodeEventTarget)elt;
        if (SVGConstants.SVG_NAMESPACE_URI.equals(elt.getNamespaceURI())) {
            if (SVGConstants.SVG_SVG_TAG.equals(elt.getLocalName())) {
                // <svg> listeners
                target.removeEventListenerNS
                    (XMLConstants.XML_EVENTS_NAMESPACE_URI, "SVGAbort",
                     svgAbortListener, false);
                target.removeEventListenerNS
                    (XMLConstants.XML_EVENTS_NAMESPACE_URI, "SVGError",
                     svgErrorListener, false);
                target.removeEventListenerNS
                    (XMLConstants.XML_EVENTS_NAMESPACE_URI, "SVGResize",
                     svgResizeListener, false);
                target.removeEventListenerNS
                    (XMLConstants.XML_EVENTS_NAMESPACE_URI, "SVGScroll",
                     svgScrollListener, false);
                target.removeEventListenerNS
                    (XMLConstants.XML_EVENTS_NAMESPACE_URI, "SVGUnload",
                     svgUnloadListener, false);
                target.removeEventListenerNS
                    (XMLConstants.XML_EVENTS_NAMESPACE_URI, "SVGZoom",
                     svgZoomListener, false);
            } else {
                String name = elt.getLocalName();
                if (name.equals(SVGConstants.SVG_SET_TAG) ||
                    name.startsWith("animate")) {
                    // animation listeners
                    target.removeEventListenerNS
                        (XMLConstants.XML_EVENTS_NAMESPACE_URI, "beginEvent",
                         beginListener, false);
                    target.removeEventListenerNS
                        (XMLConstants.XML_EVENTS_NAMESPACE_URI, "endEvent",
                         endListener, false);
                    target.removeEventListenerNS
                        (XMLConstants.XML_EVENTS_NAMESPACE_URI, "repeatEvent",
                         repeatListener , false);
                    return;
                }
            }
        }

        // UI listeners
        target.removeEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMFocusIn",
             focusinListener, false);
        target.removeEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMFocusOut",
             focusoutListener, false);
        target.removeEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "DOMActivate",
             activateListener, false);
        target.removeEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "click",
             clickListener, false);
        target.removeEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "mousedown",
             mousedownListener, false);
        target.removeEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "mouseup",
             mouseupListener, false);
        target.removeEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "mouseover",
             mouseoverListener, false);
        target.removeEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "mouseout",
             mouseoutListener, false);
        target.removeEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "mousemove",
             mousemoveListener, false);
        target.removeEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "keypress",
             keypressListener, false);
        target.removeEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "keydown",
             keydownListener, false);
        target.removeEventListenerNS
            (XMLConstants.XML_EVENTS_NAMESPACE_URI, "keyup",
             keyupListener, false);
    }

    /**
     * Updates the registration of a listener on the given element.
     */
    protected void updateScriptingListeners(Element elt, String attr) {
        String domEvt = (String) attrToDOMEvent.get(attr);
        if (domEvt == null) {
            return;  // Not an event attr.
        }
        EventListener listener = (EventListener) attrToListener.get(attr);
        NodeEventTarget target = (NodeEventTarget) elt;
        if (elt.hasAttributeNS(null, attr)) {
            target.addEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, domEvt,
                 listener, false, null);
        } else {
            target.removeEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, domEvt,
                 listener, false);
        }
    }


    /**
     * To interpret a script.
     */
    protected class EvaluateRunnable implements Runnable {
        protected Interpreter interpreter;
        protected String script;
        public EvaluateRunnable(String s, Interpreter interp) {
            interpreter = interp;
            script = s;
        }
        public void run() {
            try {
                interpreter.evaluate(script);
            } catch (InterpreterException ie) {
                handleInterpreterException(ie);
            }
        }
    }

    /**
     * To interpret a script.
     */
    protected class EvaluateIntervalRunnable implements Runnable {
        /**
         * Incremented each time this runnable is added to the queue.
         */
        public int count;
        public boolean error;

        protected Interpreter interpreter;
        protected String script;

        public EvaluateIntervalRunnable(String s, Interpreter interp) {
            interpreter = interp;
            script = s;
        }
        public void run() {
            synchronized (this) {
                if (error)
                    return;
                count--;
            }
            try {
                interpreter.evaluate(script);
            } catch (InterpreterException ie) {
                handleInterpreterException(ie);
                synchronized (this) {
                    error = true;
                }
            } catch (Exception e) {
                if (userAgent != null) {
                    userAgent.displayError(e);
                } else {
                    e.printStackTrace(); // No UA so just output...
                }
                synchronized (this) {
                    error = true;
                }
            }
        }
    }

    /**
     * To call a Runnable.
     */
    protected class EvaluateRunnableRunnable implements Runnable {
        /**
         * Incremented each time this runnable is put in the queue.
         */
        public int count;
        public boolean error;

        protected Runnable runnable;

        public EvaluateRunnableRunnable(Runnable r) {
            runnable = r;
        }
        public void run() {
            synchronized (this) {
                if (error)
                    return;
                count--;
            }
            try {
                runnable.run();
            } catch (Exception e) {
                if (userAgent != null) {
                    userAgent.displayError(e);
                } else {
                    e.printStackTrace(); // No UA so just output...
                }
                synchronized (this) {
                    error = true;
                }
            }
        }
    }

    /**
     * Represents the window object of this environment.
     */
    protected class Window implements org.apache.flex.forks.batik.script.Window {

        /**
         * The associated interpreter.
         */
        protected Interpreter interpreter;

        /**
         * The associated language.
         */
        protected String language;

        /**
         * Creates a new Window for the given language.
         */
        public Window(Interpreter interp, String lang) {
            interpreter = interp;
            language = lang;
        }

        /**
         * Implements {@link
         * org.apache.flex.forks.batik.script.Window#setInterval(String,long)}.
         */
        public Object setInterval(final String script, long interval) {
            TimerTask tt = new TimerTask() {
                    EvaluateIntervalRunnable eir =
                        new EvaluateIntervalRunnable(script, interpreter);
                    public void run() {
                        synchronized (eir) {
                            if (eir.count > 1)
                                return;
                            eir.count++;
                        }
                        synchronized (updateRunnableQueue.getIteratorLock()) {
                            if (updateRunnableQueue.getThread() == null) {
                                cancel();
                                return;
                            }
                            updateRunnableQueue.invokeLater(eir);
                        }
                        synchronized (eir) {
                            if (eir.error)
                                cancel();
                        }
                    }
                };

            timer.schedule(tt, interval, interval);
            return tt;
        }

        /**
         * Implements {@link
         * org.apache.flex.forks.batik.script.Window#setInterval(Runnable,long)}.
         */
        public Object setInterval(final Runnable r, long interval) {
            TimerTask tt = new TimerTask() {
                    EvaluateRunnableRunnable eihr =
                        new EvaluateRunnableRunnable(r);
                    public void run() {
                        synchronized (eihr) {
                            if (eihr.count > 1)
                                return;
                            eihr.count++;
                        }
                        updateRunnableQueue.invokeLater(eihr);
                        synchronized (eihr) {
                            if (eihr.error)
                                cancel();
                        }
                    }
                };

            timer.schedule(tt, interval, interval);
            return tt;
        }

        /**
         * Implements {@link
         * org.apache.flex.forks.batik.script.Window#clearInterval(Object)}.
         */
        public void clearInterval(Object interval) {
            if (interval == null) return;
            ((TimerTask)interval).cancel();
        }

        /**
         * Implements {@link
         * org.apache.flex.forks.batik.script.Window#setTimeout(String,long)}.
         */
        public Object setTimeout(final String script, long timeout) {
            TimerTask tt = new TimerTask() {
                    public void run() {
                        updateRunnableQueue.invokeLater
                            (new EvaluateRunnable(script, interpreter));
                    }
                };

            timer.schedule(tt, timeout);
            return tt;
        }

        /**
         * Implements {@link
         * org.apache.flex.forks.batik.script.Window#setTimeout(Runnable,long)}.
         */
        public Object setTimeout(final Runnable r, long timeout) {
            TimerTask tt = new TimerTask() {
                    public void run() {
                        updateRunnableQueue.invokeLater(new Runnable() {
                                public void run() {
                                    try {
                                        r.run();
                                    } catch (Exception e) {
                                        if (userAgent != null) {
                                            userAgent.displayError(e);
                                        }
                                    }
                                }
                            });
                    }
                };

            timer.schedule(tt, timeout);
            return tt;
        }

        /**
         * Implements {@link
         * org.apache.flex.forks.batik.script.Window#clearTimeout(Object)}.
         */
        public void clearTimeout(Object timeout) {
            if (timeout == null) return;
            ((TimerTask)timeout).cancel();
        }

        /**
         * Implements {@link
         * org.apache.flex.forks.batik.script.Window#parseXML(String,Document)}.
         */
        public Node parseXML(String text, Document doc) {
            // Try and parse it as an SVGDocument
            SAXSVGDocumentFactory df = new SAXSVGDocumentFactory
                (XMLResourceDescriptor.getXMLParserClassName());
            URL urlObj = null;
            if (doc instanceof SVGOMDocument) {
                urlObj = ((SVGOMDocument) doc).getURLObject();
            }
            if (urlObj == null) {
                urlObj = ((SVGOMDocument) bridgeContext.getDocument())
                        .getURLObject();
            }
            String uri = (urlObj == null) ? "" : urlObj.toString();
            Node res = DOMUtilities.parseXML(text, doc, uri, null, null, df);
            if (res != null) {
                return res;
            }
            if (doc instanceof SVGOMDocument) {
                // Try and parse with an 'svg' element wrapper - for
                // things like '<rect ../>' - ensure that rect ends up
                // in SVG namespace - xlink namespace is declared etc...

                // Only do this when generating a doc fragment, since
                // a 'rect' element can not be root of SVG Document
                // (only an svg element can be).
                Map prefixes = new HashMap();
                prefixes.put(XMLConstants.XMLNS_PREFIX,
                        XMLConstants.XMLNS_NAMESPACE_URI);
                prefixes.put(XMLConstants.XMLNS_PREFIX + ':'
                        + XMLConstants.XLINK_PREFIX,
                        XLinkSupport.XLINK_NAMESPACE_URI);
                res = DOMUtilities.parseXML(text, doc, uri, prefixes,
                        SVGConstants.SVG_SVG_TAG, df);
                if (res != null) {
                    return res;
                }
            }
            // Parse as a generic XML document.
            SAXDocumentFactory sdf;
            if (doc != null) {
                sdf = new SAXDocumentFactory(doc.getImplementation(),
                        XMLResourceDescriptor.getXMLParserClassName());
            } else {
                sdf = new SAXDocumentFactory(new GenericDOMImplementation(),
                        XMLResourceDescriptor.getXMLParserClassName());
            }
            return DOMUtilities.parseXML(text, doc, uri, null, null, sdf);
        }

        /**
         * Implements {@link
         * org.apache.flex.forks.batik.script.Window#getURL(String,org.apache.flex.forks.batik.script.Window.URLResponseHandler)}.
         */
        public void getURL(String uri, org.apache.flex.forks.batik.script.Window.URLResponseHandler h) {
            getURL(uri, h, null);
        }

        static final String DEFLATE="deflate";
        static final String GZIP   ="gzip";
        static final String UTF_8  ="UTF-8";
        /**
         * Implements {@link
         * org.apache.flex.forks.batik.script.Window#getURL(String,org.apache.flex.forks.batik.script.Window.URLResponseHandler,String)}.
         */
        public void getURL(final String uri,
                           final org.apache.flex.forks.batik.script.Window.URLResponseHandler h,
                           final String enc) {
            Thread t = new Thread() {
                    public void run() {
                        try {
                            ParsedURL burl;
                            burl = ((SVGOMDocument)document).getParsedURL();
                            final ParsedURL purl = new ParsedURL(burl, uri);
                            String e = null;
                            if (enc != null) {
                                e = EncodingUtilities.javaEncoding(enc);
                                e = ((e == null) ? enc : e);
                            }

                            InputStream is = purl.openStream();
                            Reader r;
                            if (e == null) {
                                // Not really a char encoding.
                                r = new InputStreamReader(is);
                            } else {
                                try {
                                    r = new InputStreamReader(is, e);
                                } catch (UnsupportedEncodingException uee) {
                                    // Try with no encoding.
                                    r = new InputStreamReader(is);
                                }
                            }
                            r = new BufferedReader(r);
                            final StringBuffer sb = new StringBuffer();
                            int read;
                            char[] buf = new char[4096];
                            while ((read = r.read(buf, 0, buf.length)) != -1) {
                                sb.append(buf, 0, read);
                            }
                            r.close();

                            updateRunnableQueue.invokeLater(new Runnable() {
                                    public void run() {
                                        try {
                                            h.getURLDone(true,
                                                         purl.getContentType(),
                                                         sb.toString());
                                        } catch (Exception e){
                                            if (userAgent != null) {
                                                userAgent.displayError(e);
                                            }
                                        }
                                    }
                                });
                        } catch (Exception e) {
                            if (e instanceof SecurityException) {
                                userAgent.displayError(e);
                            }
                            updateRunnableQueue.invokeLater(new Runnable() {
                                    public void run() {
                                        try {
                                            h.getURLDone(false, null, null);
                                        } catch (Exception e){
                                            if (userAgent != null) {
                                                userAgent.displayError(e);
                                            }
                                        }
                                    }
                                });
                        }
                    }

                };
            t.setPriority(Thread.MIN_PRIORITY);
            t.start();
        }


        public void postURL(String uri, String content,
                            org.apache.flex.forks.batik.script.Window.URLResponseHandler h) {
            postURL(uri, content, h, "text/plain", null);
        }

        public void postURL(String uri, String content,
                            org.apache.flex.forks.batik.script.Window.URLResponseHandler h,
                     String mimeType) {
            postURL(uri, content, h, mimeType, null);
        }

        public void postURL(final String uri,
                            final String content,
                            final org.apache.flex.forks.batik.script.Window.URLResponseHandler h,
                            final String mimeType,
                            final String fEnc) {
            Thread t = new Thread() {
                    public void run() {
                        try {
                            String base =
                                ((SVGOMDocument)document).getDocumentURI();
                            URL url;
                            if (base == null) {
                                url = new URL(uri);
                            } else {
                                url = new URL(new URL(base), uri);
                            }
                            // TODO: Change this to use ParsedURL for the POST?
                            final URLConnection conn = url.openConnection();
                            conn.setDoOutput(true);
                            conn.setDoInput(true);
                            conn.setUseCaches(false);
                            conn.setRequestProperty("Content-Type", mimeType);

                            OutputStream os = conn.getOutputStream();
                            String e=null, enc = fEnc;
                            if (enc != null) {
                                if (enc.startsWith(DEFLATE)) {
                                    os = new DeflaterOutputStream(os);

                                    if (enc.length() > DEFLATE.length())
                                        enc = enc.substring(DEFLATE.length()+1);
                                    else
                                        enc = "";
                                    conn.setRequestProperty("Content-Encoding",
                                                            DEFLATE);
                                }
                                if (enc.startsWith(GZIP)) {
                                    os = new GZIPOutputStream(os);
                                    if (enc.length() > GZIP.length())
                                        enc = enc.substring(GZIP.length()+1);
                                    else
                                        enc ="";
                                    conn.setRequestProperty("Content-Encoding",
                                                            DEFLATE);
                                }
                                if (enc.length() != 0) {
                                    e = EncodingUtilities.javaEncoding(enc);
                                    if (e == null) e = UTF_8;
                                } else {
                                    e = UTF_8;
                                }
                            }
                            Writer w;
                            if (e == null)
                                w = new OutputStreamWriter(os);
                            else
                                w = new OutputStreamWriter(os, e);
                            w.write(content);
                            w.flush();
                            w.close();
                            os.close();

                            InputStream is = conn.getInputStream();
                            Reader r;
                            e = UTF_8;
                            if (e == null)
                                r = new InputStreamReader(is);
                            else
                                r = new InputStreamReader(is, e);
                            r = new BufferedReader(r);

                            final StringBuffer sb = new StringBuffer();
                            int read;
                            char[] buf = new char[4096];
                            while ((read = r.read(buf, 0, buf.length)) != -1) {
                                sb.append(buf, 0, read);
                            }
                            r.close();

                            updateRunnableQueue.invokeLater(new Runnable() {
                                    public void run() {
                                        try {
                                            h.getURLDone(true,
                                                         conn.getContentType(),
                                                         sb.toString());
                                        } catch (Exception e){
                                            if (userAgent != null) {
                                                userAgent.displayError(e);
                                            }
                                        }
                                    }
                                });
                        } catch (Exception e) {
                            if (e instanceof SecurityException) {
                                userAgent.displayError(e);
                            }
                            updateRunnableQueue.invokeLater(new Runnable() {
                                    public void run() {
                                        try {
                                            h.getURLDone(false, null, null);
                                        } catch (Exception e){
                                            if (userAgent != null) {
                                                userAgent.displayError(e);
                                            }
                                        }
                                    }
                                });
                        }
                    }

                };
            t.setPriority(Thread.MIN_PRIORITY);
            t.start();
        }

        /**
         * Displays an alert dialog box.
         */
        public void alert(String message) {
            if (userAgent != null) {
                userAgent.showAlert(message);
            }
        }

        /**
         * Displays a confirm dialog box.
         */
        public boolean confirm(String message) {
            if (userAgent != null) {
                return userAgent.showConfirm(message);
            }
            return false;
        }

        /**
         * Displays an input dialog box.
         */
        public String prompt(String message) {
            if (userAgent != null) {
                return userAgent.showPrompt(message);
            }
            return null;
        }

        /**
         * Displays an input dialog box, given the default value.
         */
        public String prompt(String message, String defVal) {
            if (userAgent != null) {
                return userAgent.showPrompt(message, defVal);
            }
            return null;
        }

        /**
         * Returns the current BridgeContext.
         */
        public BridgeContext getBridgeContext() {
            return bridgeContext;
        }

        /**
         * Returns the associated interpreter.
         */
        public Interpreter getInterpreter() {
            return interpreter;
        }
    }

    /**
     * The listener class for 'DOMNodeInserted' event.
     */
    protected class DOMNodeInsertedListener implements EventListener {
        public void handleEvent(Event evt) {
            addScriptingListeners((Node)evt.getTarget());
        }
    }

    /**
     * The listener class for 'DOMNodeRemoved' event.
     */
    protected class DOMNodeRemovedListener implements EventListener {
        public void handleEvent(Event evt) {
            removeScriptingListeners((Node)evt.getTarget());
        }
    }

    protected class DOMAttrModifiedListener implements EventListener {
        public void handleEvent (Event evt) {
            MutationEvent me = (MutationEvent)evt;
            if (me.getAttrChange() != MutationEvent.MODIFICATION)
                updateScriptingListeners((Element)me.getTarget(),
                                         me.getAttrName());
        }
    }

    /**
     * To handle a scripting event.
     */
    protected class ScriptingEventListener implements EventListener {

        /**
         * The script attribute.
         */
        protected String attribute;

        /**
         * Creates a new ScriptingEventListener.
         */
        public ScriptingEventListener(String attr) {
            attribute = attr;
        }

        /**
         * Runs the script.
         */
        public void handleEvent(Event evt) {
            Element elt = (Element)evt.getCurrentTarget();
            // Evaluate the script
            String script = elt.getAttributeNS(null, attribute);
            if (script.length() == 0)
                return;

            DocumentLoader dl = bridgeContext.getDocumentLoader();
            SVGDocument d = (SVGDocument)elt.getOwnerDocument();
            int line = dl.getLineNumber(elt);
            final String desc = Messages.formatMessage
                (EVENT_SCRIPT_DESCRIPTION,
                 new Object [] {d.getURL(), attribute, new Integer(line)});

            // Find the scripting language
            Element e = elt;
            while (e != null &&
                   (!SVGConstants.SVG_NAMESPACE_URI.equals
                    (e.getNamespaceURI()) ||
                    !SVGConstants.SVG_SVG_TAG.equals(e.getLocalName()))) {
                e = SVGUtilities.getParentElement(e);
            }
            if (e == null)
                return;

            String lang = e.getAttributeNS
                (null, SVGConstants.SVG_CONTENT_SCRIPT_TYPE_ATTRIBUTE);

            runEventHandler(script, evt, lang, desc);
        }
    }
}
