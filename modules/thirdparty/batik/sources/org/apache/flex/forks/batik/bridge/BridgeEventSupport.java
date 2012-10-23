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

import java.awt.Point;
import java.awt.event.KeyEvent;
import java.awt.geom.NoninvertibleTransformException;
import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;
import java.lang.ref.SoftReference;
import java.text.AttributedCharacterIterator;
import java.util.List;

import org.apache.flex.forks.batik.dom.events.DOMKeyEvent;
import org.apache.flex.forks.batik.dom.events.DOMMouseEvent;
import org.apache.flex.forks.batik.dom.events.NodeEventTarget;
import org.apache.flex.forks.batik.dom.util.DOMUtilities;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.gvt.TextNode;
import org.apache.flex.forks.batik.gvt.event.EventDispatcher;
import org.apache.flex.forks.batik.gvt.event.GraphicsNodeKeyEvent;
import org.apache.flex.forks.batik.gvt.event.GraphicsNodeKeyListener;
import org.apache.flex.forks.batik.gvt.event.GraphicsNodeMouseEvent;
import org.apache.flex.forks.batik.gvt.event.GraphicsNodeMouseListener;
import org.apache.flex.forks.batik.gvt.renderer.StrokingTextPainter;
import org.apache.flex.forks.batik.gvt.text.GVTAttributedCharacterIterator;
import org.apache.flex.forks.batik.gvt.text.TextHit;
import org.apache.flex.forks.batik.gvt.text.TextSpanLayout;
import org.apache.flex.forks.batik.util.SVGConstants;
import org.apache.flex.forks.batik.util.XMLConstants;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.events.DocumentEvent;
import org.w3c.dom.events.Event;
import org.w3c.dom.events.EventListener;
import org.w3c.dom.events.EventTarget;

/**
 * This class is responsible of tracking GraphicsNodeMouseEvent and
 * fowarding them to the DOM as regular DOM MouseEvent.
 *
 * @author <a href="mailto:tkormann@ilog.fr">Thierry Kormann</a>
 * @version $Id: BridgeEventSupport.java 580012 2007-09-27 13:33:47Z cam $
 */
public abstract class BridgeEventSupport implements SVGConstants {

    public static final
        AttributedCharacterIterator.Attribute TEXT_COMPOUND_ID =
        GVTAttributedCharacterIterator.TextAttribute.TEXT_COMPOUND_ID;

    protected BridgeEventSupport() {}

    /**
     * Is called only for the root element in order to dispatch GVT
     * events to the DOM.
     */
    public static void addGVTListener(BridgeContext ctx, Document doc) {
        UserAgent ua = ctx.getUserAgent();
        if (ua != null) {
            EventDispatcher dispatcher = ua.getEventDispatcher();
            if (dispatcher != null) {
                final Listener listener = new Listener(ctx, ua);
                dispatcher.addGraphicsNodeMouseListener(listener);
                dispatcher.addGraphicsNodeKeyListener(listener);
                // add an unload listener on the SVGDocument to remove
                // that listener for dispatching events
                EventListener l = new GVTUnloadListener(dispatcher, listener);
                NodeEventTarget target = (NodeEventTarget)doc;
                target.addEventListenerNS
                    (XMLConstants.XML_EVENTS_NAMESPACE_URI,
                     "SVGUnload",
                     l, false, null);
                storeEventListenerNS
                    (ctx, target,
                     XMLConstants.XML_EVENTS_NAMESPACE_URI,
                     "SVGUnload",
                     l, false);
            }
        }
    }

    /**
     * Calls storeEventListener on the given BridgeContext.
     */
    protected static void storeEventListener(BridgeContext ctx,
                                             EventTarget e,
                                             String t,
                                             EventListener l,
                                             boolean c) {
        ctx.storeEventListener(e, t, l, c);
    }

    /**
     * Calls storeEventListenerNS on the given BridgeContext.
     */
    protected static void storeEventListenerNS(BridgeContext ctx,
                                               EventTarget e,
                                               String n,
                                               String t,
                                               EventListener l,
                                               boolean c) {
        ctx.storeEventListenerNS(e, n, t, l, c);
    }

    protected static class GVTUnloadListener implements EventListener {

        protected EventDispatcher dispatcher;
        protected Listener listener;

        public GVTUnloadListener(EventDispatcher dispatcher,
                                 Listener listener) {
            this.dispatcher = dispatcher;
            this.listener = listener;
        }

        public void handleEvent(Event evt) {
            dispatcher.removeGraphicsNodeMouseListener(listener);
            dispatcher.removeGraphicsNodeKeyListener(listener);
            NodeEventTarget et = (NodeEventTarget) evt.getTarget();
            et.removeEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI, "SVGUnload",
                 this, false);
        }
    }

    /**
     * A GraphicsNodeMouseListener that dispatch DOM events accordingly.
     */
    protected static class Listener implements GraphicsNodeMouseListener,
                                               GraphicsNodeKeyListener {

        protected BridgeContext context;
        protected UserAgent ua;
        protected Element lastTargetElement;
        protected boolean isDown;

        public Listener(BridgeContext ctx, UserAgent u) {
            context = ctx;
            ua = u;
        }

        // Key -------------------------------------------------------------

        /**
         * Invoked when a key has been pressed.
         * @param evt the graphics node key event
         */
        public void keyPressed(GraphicsNodeKeyEvent evt) {
            // XXX isDown is not preventing key repeats
            if (!isDown) {
                isDown = true;
                dispatchKeyEvent("keydown", evt);
            }
            if (evt.getKeyChar() == KeyEvent.CHAR_UNDEFINED) {
                // We will not get a KEY_TYPED event for this char
                // so generate a keypress event here.
                dispatchKeyEvent("keypress", evt);
            }
        }

        /**
         * Invoked when a key has been released.
         * @param evt the graphics node key event
         */
        public void keyReleased(GraphicsNodeKeyEvent evt) {
            dispatchKeyEvent("keyup", evt);
            isDown = false;
        }

        /**
         * Invoked when a key has been typed.
         * @param evt the graphics node key event
         */
        public void keyTyped(GraphicsNodeKeyEvent evt) {
            dispatchKeyEvent("keypress", evt);
        }

        /**
         * Dispatch a DOM 2 Draft Key event.
         */
        protected void dispatchKeyEvent(String eventType,
                                        GraphicsNodeKeyEvent evt) {
            FocusManager fmgr = context.getFocusManager();
            if (fmgr == null) return;

            Element targetElement = (Element)fmgr.getCurrentEventTarget();
            if (targetElement == null) {
                targetElement = context.getDocument().getDocumentElement();
            }
            DocumentEvent d = (DocumentEvent)targetElement.getOwnerDocument();
            DOMKeyEvent keyEvt = (DOMKeyEvent)d.createEvent("KeyEvents");
            keyEvt.initKeyEvent(eventType,
                                true,
                                true,
                                evt.isControlDown(),
                                evt.isAltDown(),
                                evt.isShiftDown(),
                                evt.isMetaDown(),
                                mapKeyCode(evt.getKeyCode()),
                                evt.getKeyChar(),
                                null);

            try {
                ((EventTarget)targetElement).dispatchEvent(keyEvt);
            } catch (RuntimeException e) {
                ua.displayError(e);
            }
        }

        /**
         * The java KeyEvent keyCodes and the DOMKeyEvent keyCodes
         * map except for the VK_ENTER code (which has a different value
         * in DOM and the VK_KANA_LOCK and VK_INPUT_METHOD_ON_OFF which
         * have no DOM equivalent.
         */
        protected final int mapKeyCode(int keyCode) {
            switch (keyCode) {
                case KeyEvent.VK_ENTER:
                    return DOMKeyEvent.DOM_VK_ENTER;
            case KeyEvent.VK_KANA_LOCK:
                return DOMKeyEvent.DOM_VK_UNDEFINED;
            case KeyEvent.VK_INPUT_METHOD_ON_OFF:
                return DOMKeyEvent.DOM_VK_UNDEFINED;
            default:
                return keyCode;
            }
        }

        // Mouse -----------------------------------------------------------

        public void mouseClicked(GraphicsNodeMouseEvent evt) {
            dispatchMouseEvent("click", evt, true);
        }

        public void mousePressed(GraphicsNodeMouseEvent evt) {
            dispatchMouseEvent("mousedown", evt, true);
        }

        public void mouseReleased(GraphicsNodeMouseEvent evt) {
            dispatchMouseEvent("mouseup", evt, true);
        }

        public void mouseEntered(GraphicsNodeMouseEvent evt) {
            Point clientXY = evt.getClientPoint();
            GraphicsNode node = evt.getGraphicsNode();
            Element targetElement = getEventTarget
                (node, new Point2D.Float(evt.getX(), evt.getY()));
            Element relatedElement = getRelatedElement(evt);
            dispatchMouseEvent("mouseover",
                               targetElement,
                               relatedElement,
                               clientXY,
                               evt,
                               true);
        }

        public void mouseExited(GraphicsNodeMouseEvent evt) {
            Point clientXY = evt.getClientPoint();
            // Get the 'new' node for the DOM event.
            GraphicsNode node = evt.getRelatedNode();
            Element targetElement = getEventTarget(node, clientXY);
            if (lastTargetElement != null) {
                dispatchMouseEvent("mouseout",
                                   lastTargetElement, // target
                                   targetElement,     // relatedTarget
                                   clientXY,
                                   evt,
                                   true);
                lastTargetElement = null;
            }
        }

        public void mouseDragged(GraphicsNodeMouseEvent evt) {
            dispatchMouseEvent("mousemove", evt, false);
        }

        public void mouseMoved(GraphicsNodeMouseEvent evt) {
            Point clientXY = evt.getClientPoint();
            GraphicsNode node = evt.getGraphicsNode();
            Element targetElement = getEventTarget(node, clientXY);
            Element holdLTE = lastTargetElement;
            if (holdLTE != targetElement) {
                if (holdLTE != null) {
                    dispatchMouseEvent("mouseout",
                                       holdLTE, // target
                                       targetElement,     // relatedTarget
                                       clientXY,
                                       evt,
                                       true);
                }
                if (targetElement != null) {
                    dispatchMouseEvent("mouseover",
                                       targetElement,     // target
                                       holdLTE, // relatedTarget
                                       clientXY,
                                       evt,
                                       true);
                }
            }
            dispatchMouseEvent("mousemove",
                               targetElement,     // target
                               null,              // relatedTarget
                               clientXY,
                               evt,
                               false);
        }

        /**
         * Dispatches a DOM MouseEvent according to the specified
         * parameters.
         *
         * @param eventType the event type
         * @param evt the GVT GraphicsNodeMouseEvent
         * @param cancelable true means the event is cancelable
         */
        protected void dispatchMouseEvent(String eventType,
                                          GraphicsNodeMouseEvent evt,
                                          boolean cancelable) {
            Point clientXY = evt.getClientPoint();
            GraphicsNode node = evt.getGraphicsNode();
            Element targetElement = getEventTarget
                (node, new Point2D.Float(evt.getX(), evt.getY()));
            Element relatedElement = getRelatedElement(evt);
            dispatchMouseEvent(eventType,
                               targetElement,
                               relatedElement,
                               clientXY,
                               evt,
                               cancelable);
        }

        /**
         * Dispatches a DOM MouseEvent according to the specified
         * parameters.
         *
         * @param eventType the event type
         * @param targetElement the target of the event
         * @param relatedElement the related target if any
         * @param clientXY the mouse coordinates in the client space
         * @param evt the GVT GraphicsNodeMouseEvent
         * @param cancelable true means the event is cancelable
         */
        protected void dispatchMouseEvent(String eventType,
                                          Element targetElement,
                                          Element relatedElement,
                                          Point clientXY,
                                          GraphicsNodeMouseEvent evt,
                                          boolean cancelable) {
            if (targetElement == null) {
                return;
            }
            /*
            if (relatedElement != null) {
                System.out.println
                    ("dispatching "+eventType+
                     " target:"+targetElement.getLocalName()+
                     " relatedElement:"+relatedElement.getLocalName());
            } else {
                System.out.println
                    ("dispatching "+eventType+
                     " target:"+targetElement.getLocalName());

            }
            */
            Point screenXY = evt.getScreenPoint();
            // create the coresponding DOM MouseEvent
            DocumentEvent d = (DocumentEvent)targetElement.getOwnerDocument();
            DOMMouseEvent mouseEvt
                = (DOMMouseEvent)d.createEvent("MouseEvents");
            String modifiers
                = DOMUtilities.getModifiersList(evt.getLockState(),
                                                evt.getModifiers());
            mouseEvt.initMouseEventNS(XMLConstants.XML_EVENTS_NAMESPACE_URI,
                                      eventType,
                                      true,
                                      cancelable,
                                      null,
                                      evt.getClickCount(),
                                      screenXY.x,
                                      screenXY.y,
                                      clientXY.x,
                                      clientXY.y,
                                      (short) (evt.getButton() - 1),
                                      (EventTarget)relatedElement,
                                      modifiers);

            try {
                ((EventTarget)targetElement).dispatchEvent(mouseEvt);
            } catch (RuntimeException e) {
                ua.displayError(e);
            } finally {
                lastTargetElement = targetElement;
            }
        }

        /**
         * Returns the related element according to the specified event.
         *
         * @param evt the GVT GraphicsNodeMouseEvent
         */
        protected Element getRelatedElement(GraphicsNodeMouseEvent evt) {
            GraphicsNode relatedNode = evt.getRelatedNode();
            Element relatedElement = null;
            if (relatedNode != null) {
                relatedElement = context.getElement(relatedNode);
            }
            return relatedElement;
        }

        /**
         * Returns the element that is the target of the specified
         * event or null if any.
         *
         * @param node the graphics node that received the event
         * @param coords the mouse coordinates in the GVT tree space
         */
        protected Element getEventTarget(GraphicsNode node, Point2D coords) {
            Element target = context.getElement(node);
            // Lookup inside the text element children to see if the target
            // is a tspan or textPath

            if (target != null && node instanceof TextNode) {
                TextNode textNode = (TextNode)node;
                List list = textNode.getTextRuns();
                Point2D pt = (Point2D)coords.clone();
                // place coords in text node coordinate system
                try {
                    node.getGlobalTransform().createInverse().transform(pt, pt);
                } catch (NoninvertibleTransformException ex) {
                }
                if (list != null){
                    for (int i = 0 ; i < list.size(); i++) {
                        StrokingTextPainter.TextRun run =
                            (StrokingTextPainter.TextRun)list.get(i);
                        AttributedCharacterIterator aci = run.getACI();
                        TextSpanLayout layout = run.getLayout();
                        float x = (float)pt.getX();
                        float y = (float)pt.getY();
                        TextHit textHit = layout.hitTestChar(x, y);
                        Rectangle2D bounds = layout.getBounds2D();
                        if ((textHit != null) &&
                            (bounds != null) && bounds.contains(x, y)) {
                            SoftReference sr;
                            sr =(SoftReference)aci.getAttribute
                                (TEXT_COMPOUND_ID);
                            Object delimiter = sr.get();
                            if (delimiter instanceof Element) {
                                return (Element)delimiter;
                            }
                        }
                    }
                }
            }
            return target;
        }
    }
}
