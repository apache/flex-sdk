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

import java.awt.Point;
import java.awt.event.KeyEvent;
import java.awt.geom.Point2D;

import org.apache.flex.forks.batik.bridge.BridgeContext;
import org.apache.flex.forks.batik.bridge.BridgeEventSupport;
import org.apache.flex.forks.batik.bridge.FocusManager;
import org.apache.flex.forks.batik.bridge.UserAgent;
import org.apache.flex.forks.batik.dom.events.AbstractEvent;
import org.apache.flex.forks.batik.dom.events.DOMKeyboardEvent;
import org.apache.flex.forks.batik.dom.events.DOMMouseEvent;
import org.apache.flex.forks.batik.dom.events.DOMTextEvent;
import org.apache.flex.forks.batik.dom.events.NodeEventTarget;
import org.apache.flex.forks.batik.dom.svg12.SVGOMWheelEvent;
import org.apache.flex.forks.batik.dom.util.DOMUtilities;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.gvt.event.EventDispatcher;
import org.apache.flex.forks.batik.gvt.event.GraphicsNodeKeyEvent;
import org.apache.flex.forks.batik.gvt.event.GraphicsNodeMouseEvent;
import org.apache.flex.forks.batik.gvt.event.GraphicsNodeMouseWheelEvent;
import org.apache.flex.forks.batik.gvt.event.GraphicsNodeMouseWheelListener;
import org.apache.flex.forks.batik.util.XMLConstants;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.events.DocumentEvent;
import org.w3c.dom.events.EventListener;
import org.w3c.dom.events.EventTarget;

/**
 * This class is responsible for tracking GraphicsNodeMouseEvents and
 * forwarding them to the DOM as regular DOM MouseEvents.  This SVG 1.2
 * specific class handles DOM Level 3 keyboard events and also ensures
 * that mouse events under sXBL have appropriate bubble limits.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: SVG12BridgeEventSupport.java 575202 2007-09-13 07:45:18Z cam $
 */
public abstract class SVG12BridgeEventSupport extends BridgeEventSupport {

    protected SVG12BridgeEventSupport() {}

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
                dispatcher.addGraphicsNodeMouseWheelListener(listener);
                dispatcher.addGraphicsNodeKeyListener(listener);
                // add an unload listener on the SVGDocument to remove
                // that listener for dispatching events
                EventListener l = new GVTUnloadListener(dispatcher, listener);
                NodeEventTarget target = (NodeEventTarget) doc;
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
     * A GraphicsNodeMouseListener that dispatch DOM events accordingly.
     */
    protected static class Listener
            extends BridgeEventSupport.Listener 
            implements GraphicsNodeMouseWheelListener {

        /**
         * The BridgeContext downcasted to an SVG12BridgeContext.
         */
        protected SVG12BridgeContext ctx12;

        public Listener(BridgeContext ctx, UserAgent u) {
            super(ctx, u);
            ctx12 = (SVG12BridgeContext) ctx;
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
                dispatchKeyboardEvent("keydown", evt);
            }
            if (evt.getKeyChar() == KeyEvent.CHAR_UNDEFINED) {
                // We will not get a KEY_TYPED event for this char
                // so generate a keypress event here.
                dispatchTextEvent(evt);
            }
        }

        /**
         * Invoked when a key has been released.
         * @param evt the graphics node key event
         */
        public void keyReleased(GraphicsNodeKeyEvent evt) {
            dispatchKeyboardEvent("keyup", evt);
            isDown = false;
        }

        /**
         * Invoked when a key has been typed.
         * @param evt the graphics node key event
         */
        public void keyTyped(GraphicsNodeKeyEvent evt) {
            dispatchTextEvent(evt);
        }

        /**
         * Dispatch a DOM 3 Keyboard event.
         */
        protected void dispatchKeyboardEvent(String eventType,
                                             GraphicsNodeKeyEvent evt) {
            FocusManager fmgr = context.getFocusManager();
            if (fmgr == null) {
                return;
            }

            Element targetElement = (Element) fmgr.getCurrentEventTarget();
            if (targetElement == null) {
                targetElement = context.getDocument().getDocumentElement();
            }
            DocumentEvent d = (DocumentEvent) targetElement.getOwnerDocument();
            DOMKeyboardEvent keyEvt
                = (DOMKeyboardEvent) d.createEvent("KeyboardEvent");
            String modifiers
                = DOMUtilities.getModifiersList(evt.getLockState(),
                                                evt.getModifiers());
            keyEvt.initKeyboardEventNS(XMLConstants.XML_EVENTS_NAMESPACE_URI,
                                       eventType, 
                                       true,
                                       true,
                                       null,
                                       mapKeyCodeToIdentifier(evt.getKeyCode()),
                                       mapKeyLocation(evt.getKeyLocation()),
                                       modifiers);

            try {
                ((EventTarget)targetElement).dispatchEvent(keyEvt);
            } catch (RuntimeException e) {
                ua.displayError(e);
            }
        }

        /**
         * Dispatch a DOM 3 Text event.
         */
        protected void dispatchTextEvent(GraphicsNodeKeyEvent evt) {
            FocusManager fmgr = context.getFocusManager();
            if (fmgr == null) {
                return;
            }

            Element targetElement = (Element) fmgr.getCurrentEventTarget();
            if (targetElement == null) {
                targetElement = context.getDocument().getDocumentElement();
            }
            DocumentEvent d = (DocumentEvent) targetElement.getOwnerDocument();
            DOMTextEvent textEvt = (DOMTextEvent) d.createEvent("TextEvent");
            textEvt.initTextEventNS(XMLConstants.XML_EVENTS_NAMESPACE_URI,
                                    "textInput", 
                                    true,
                                    true,
                                    null,
                                    String.valueOf(evt.getKeyChar()));

            try {
                ((EventTarget) targetElement).dispatchEvent(textEvt);
            } catch (RuntimeException e) {
                ua.displayError(e);
            }
        }

        /**
         * Maps Java KeyEvent location numbers to DOM 3 location numbers.
         */
        protected int mapKeyLocation(int location) {
            return location - 1;
        }

        /**
         * Array to hold the map of Java keycodes to DOM 3 key strings.
         */
        protected static String[][] IDENTIFIER_KEY_CODES = new String[256][];
        static {
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_0,
                                 KeyEvent.VK_0);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_1,
                                 KeyEvent.VK_1);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_2,
                                 KeyEvent.VK_2);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_3,
                                 KeyEvent.VK_3);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_4,
                                 KeyEvent.VK_4);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_5,
                                 KeyEvent.VK_5);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_6,
                                 KeyEvent.VK_6);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_7,
                                 KeyEvent.VK_7);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_8,
                                 KeyEvent.VK_8);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_9,
                                 KeyEvent.VK_9);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_ACCEPT,
                                 KeyEvent.VK_ACCEPT);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_AGAIN,
                                 KeyEvent.VK_AGAIN);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_A,
                                 KeyEvent.VK_A);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_ALL_CANDIDATES,
                                 KeyEvent.VK_ALL_CANDIDATES);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_ALPHANUMERIC,
                                 KeyEvent.VK_ALPHANUMERIC);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_ALT_GRAPH,
                                 KeyEvent.VK_ALT_GRAPH);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_ALT,
                                 KeyEvent.VK_ALT);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_AMPERSAND,
                                 KeyEvent.VK_AMPERSAND);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_APOSTROPHE,
                                 KeyEvent.VK_QUOTE);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_ASTERISK,
                                 KeyEvent.VK_ASTERISK);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_AT,
                                 KeyEvent.VK_AT);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_BACKSLASH,
                                 KeyEvent.VK_BACK_SLASH);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_BACKSPACE,
                                 KeyEvent.VK_BACK_SPACE);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_B,
                                 KeyEvent.VK_B);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_CANCEL,
                                 KeyEvent.VK_CANCEL);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_CAPS_LOCK,
                                 KeyEvent.VK_CAPS_LOCK);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_CIRCUMFLEX,
                                 KeyEvent.VK_CIRCUMFLEX);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_C,
                                 KeyEvent.VK_C);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_CLEAR,
                                 KeyEvent.VK_CLEAR);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_CODE_INPUT,
                                 KeyEvent.VK_CODE_INPUT);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_COLON,
                                 KeyEvent.VK_COLON);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_COMBINING_ACUTE,
                                 KeyEvent.VK_DEAD_ACUTE);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_COMBINING_BREVE,
                                 KeyEvent.VK_DEAD_BREVE);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_COMBINING_CARON,
                                 KeyEvent.VK_DEAD_CARON);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_COMBINING_CEDILLA,
                                 KeyEvent.VK_DEAD_CEDILLA);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_COMBINING_CIRCUMFLEX,
                                 KeyEvent.VK_DEAD_CIRCUMFLEX);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_COMBINING_DIERESIS,
                                 KeyEvent.VK_DEAD_DIAERESIS);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_COMBINING_DOT_ABOVE,
                                 KeyEvent.VK_DEAD_ABOVEDOT);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_COMBINING_DOUBLE_ACUTE,
                                 KeyEvent.VK_DEAD_DOUBLEACUTE);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_COMBINING_GRAVE,
                                 KeyEvent.VK_DEAD_GRAVE);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_COMBINING_IOTA,
                                 KeyEvent.VK_DEAD_IOTA);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_COMBINING_MACRON,
                                 KeyEvent.VK_DEAD_MACRON);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_COMBINING_OGONEK,
                                 KeyEvent.VK_DEAD_OGONEK);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_COMBINING_RING_ABOVE,
                                 KeyEvent.VK_DEAD_ABOVERING);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_COMBINING_TILDE,
                                 KeyEvent.VK_DEAD_TILDE);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_COMMA,
                                 KeyEvent.VK_COMMA);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_COMPOSE,
                                 KeyEvent.VK_COMPOSE);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_CONTROL,
                                 KeyEvent.VK_CONTROL);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_CONVERT,
                                 KeyEvent.VK_CONVERT);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_COPY,
                                 KeyEvent.VK_COPY);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_CUT,
                                 KeyEvent.VK_CUT);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_DELETE,
                                 KeyEvent.VK_DELETE);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_D,
                                 KeyEvent.VK_D);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_DOLLAR,
                                 KeyEvent.VK_DOLLAR);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_DOWN,
                                 KeyEvent.VK_DOWN);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_E,
                                 KeyEvent.VK_E);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_END,
                                 KeyEvent.VK_END);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_ENTER,
                                 KeyEvent.VK_ENTER);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_EQUALS,
                                 KeyEvent.VK_EQUALS);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_ESCAPE,
                                 KeyEvent.VK_ESCAPE);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_EURO,
                                 KeyEvent.VK_EURO_SIGN);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_EXCLAMATION,
                                 KeyEvent.VK_EXCLAMATION_MARK);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_F10,
                                 KeyEvent.VK_F10);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_F11,
                                 KeyEvent.VK_F11);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_F12,
                                 KeyEvent.VK_F12);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_F13,
                                 KeyEvent.VK_F13);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_F14,
                                 KeyEvent.VK_F14);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_F15,
                                 KeyEvent.VK_F15);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_F16,
                                 KeyEvent.VK_F16);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_F17,
                                 KeyEvent.VK_F17);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_F18,
                                 KeyEvent.VK_F18);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_F19,
                                 KeyEvent.VK_F19);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_F1,
                                 KeyEvent.VK_F1);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_F20,
                                 KeyEvent.VK_F20);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_F21,
                                 KeyEvent.VK_F21);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_F22,
                                 KeyEvent.VK_F22);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_F23,
                                 KeyEvent.VK_F23);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_F24,
                                 KeyEvent.VK_F24);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_F2,
                                 KeyEvent.VK_F2);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_F3,
                                 KeyEvent.VK_F3);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_F4,
                                 KeyEvent.VK_F4);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_F5,
                                 KeyEvent.VK_F5);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_F6,
                                 KeyEvent.VK_F6);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_F7,
                                 KeyEvent.VK_F7);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_F8,
                                 KeyEvent.VK_F8);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_F9,
                                 KeyEvent.VK_F9);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_FINAL_MODE,
                                 KeyEvent.VK_FINAL);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_FIND,
                                 KeyEvent.VK_FIND);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_F,
                                 KeyEvent.VK_F);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_FULL_STOP,
                                 KeyEvent.VK_PERIOD);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_FULL_WIDTH,
                                 KeyEvent.VK_FULL_WIDTH);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_G,
                                 KeyEvent.VK_G);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_GRAVE,
                                 KeyEvent.VK_BACK_QUOTE);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_GREATER_THAN,
                                 KeyEvent.VK_GREATER);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_HALF_WIDTH,
                                 KeyEvent.VK_HALF_WIDTH);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_HASH,
                                 KeyEvent.VK_NUMBER_SIGN);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_HELP,
                                 KeyEvent.VK_HELP);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_HIRAGANA,
                                 KeyEvent.VK_HIRAGANA);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_H,
                                 KeyEvent.VK_H);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_HOME,
                                 KeyEvent.VK_HOME);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_I,
                                 KeyEvent.VK_I);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_INSERT,
                                 KeyEvent.VK_INSERT);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_INVERTED_EXCLAMATION,
                                 KeyEvent.VK_INVERTED_EXCLAMATION_MARK);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_JAPANESE_HIRAGANA,
                                 KeyEvent.VK_JAPANESE_HIRAGANA);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_JAPANESE_KATAKANA,
                                 KeyEvent.VK_JAPANESE_KATAKANA);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_JAPANESE_ROMAJI,
                                 KeyEvent.VK_JAPANESE_ROMAN);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_J,
                                 KeyEvent.VK_J);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_KANA_MODE,
                                 KeyEvent.VK_KANA_LOCK);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_KANJI_MODE,
                                 KeyEvent.VK_KANJI);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_KATAKANA,
                                 KeyEvent.VK_KATAKANA);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_K,
                                 KeyEvent.VK_K);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_LEFT_BRACE,
                                 KeyEvent.VK_BRACELEFT);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_LEFT,
                                 KeyEvent.VK_LEFT);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_LEFT_PARENTHESIS,
                                 KeyEvent.VK_LEFT_PARENTHESIS);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_LEFT_SQUARE_BRACKET,
                                 KeyEvent.VK_OPEN_BRACKET);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_LESS_THAN,
                                 KeyEvent.VK_LESS);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_L,
                                 KeyEvent.VK_L);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_META,
                                 KeyEvent.VK_META);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_META,
                                 KeyEvent.VK_META);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_MINUS,
                                 KeyEvent.VK_MINUS);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_M,
                                 KeyEvent.VK_M);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_MODE_CHANGE,
                                 KeyEvent.VK_MODECHANGE);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_N,
                                 KeyEvent.VK_N);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_NONCONVERT,
                                 KeyEvent.VK_NONCONVERT);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_NUM_LOCK,
                                 KeyEvent.VK_NUM_LOCK);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_NUM_LOCK,
                                 KeyEvent.VK_NUM_LOCK);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_O,
                                 KeyEvent.VK_O);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_PAGE_DOWN,
                                 KeyEvent.VK_PAGE_DOWN);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_PAGE_UP,
                                 KeyEvent.VK_PAGE_UP);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_PASTE,
                                 KeyEvent.VK_PASTE);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_PAUSE,
                                 KeyEvent.VK_PAUSE);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_P,
                                 KeyEvent.VK_P);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_PLUS,
                                 KeyEvent.VK_PLUS);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_PREVIOUS_CANDIDATE,
                                 KeyEvent.VK_PREVIOUS_CANDIDATE);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_PRINT_SCREEN,
                                 KeyEvent.VK_PRINTSCREEN);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_PROPS,
                                 KeyEvent.VK_PROPS);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_Q,
                                 KeyEvent.VK_Q);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_QUOTE,
                                 KeyEvent.VK_QUOTEDBL);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_RIGHT_BRACE,
                                 KeyEvent.VK_BRACERIGHT);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_RIGHT,
                                 KeyEvent.VK_RIGHT);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_RIGHT_PARENTHESIS,
                                 KeyEvent.VK_RIGHT_PARENTHESIS);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_RIGHT_SQUARE_BRACKET,
                                 KeyEvent.VK_CLOSE_BRACKET);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_R,
                                 KeyEvent.VK_R);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_ROMAN_CHARACTERS,
                                 KeyEvent.VK_ROMAN_CHARACTERS);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_SCROLL,
                                 KeyEvent.VK_SCROLL_LOCK);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_SCROLL,
                                 KeyEvent.VK_SCROLL_LOCK);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_SEMICOLON,
                                 KeyEvent.VK_SEMICOLON);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_SEMIVOICED_SOUND,
                                 KeyEvent.VK_DEAD_SEMIVOICED_SOUND);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_SHIFT,
                                 KeyEvent.VK_SHIFT);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_SHIFT,
                                 KeyEvent.VK_SHIFT);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_S,
                                 KeyEvent.VK_S);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_SLASH,
                                 KeyEvent.VK_SLASH);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_SPACE,
                                 KeyEvent.VK_SPACE);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_STOP,
                                 KeyEvent.VK_STOP);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_TAB,
                                 KeyEvent.VK_TAB);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_T,
                                 KeyEvent.VK_T);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_U,
                                 KeyEvent.VK_U);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_UNDERSCORE,
                                 KeyEvent.VK_UNDERSCORE);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_UNDO,
                                 KeyEvent.VK_UNDO);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_UNIDENTIFIED,
                                 KeyEvent.VK_UNDEFINED);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_UP,
                                 KeyEvent.VK_UP);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_V,
                                 KeyEvent.VK_V);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_VOICED_SOUND,
                                 KeyEvent.VK_DEAD_VOICED_SOUND);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_W,
                                 KeyEvent.VK_W);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_X,
                                 KeyEvent.VK_X);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_Y,
                                 KeyEvent.VK_Y);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_Z,
                                 KeyEvent.VK_Z);
            // Java keycodes for duplicate keys
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_0,
                                 KeyEvent.VK_NUMPAD0);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_1,
                                 KeyEvent.VK_NUMPAD1);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_2,
                                 KeyEvent.VK_NUMPAD2);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_3,
                                 KeyEvent.VK_NUMPAD3);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_4,
                                 KeyEvent.VK_NUMPAD4);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_5,
                                 KeyEvent.VK_NUMPAD5);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_6,
                                 KeyEvent.VK_NUMPAD6);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_7,
                                 KeyEvent.VK_NUMPAD7);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_8,
                                 KeyEvent.VK_NUMPAD8);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_9,
                                 KeyEvent.VK_NUMPAD9);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_ASTERISK,
                                 KeyEvent.VK_MULTIPLY);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_DOWN,
                                 KeyEvent.VK_KP_DOWN);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_FULL_STOP,
                                 KeyEvent.VK_DECIMAL);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_LEFT,
                                 KeyEvent.VK_KP_LEFT);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_MINUS,
                                 KeyEvent.VK_SUBTRACT);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_PLUS,
                                 KeyEvent.VK_ADD);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_RIGHT,
                                 KeyEvent.VK_KP_RIGHT);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_SLASH,
                                 KeyEvent.VK_DIVIDE);
            putIdentifierKeyCode(DOMKeyboardEvent.KEY_UP,
                                 KeyEvent.VK_KP_UP);
        }

        /**
         * Put a key code to key identifier mapping into the
         * IDENTIFIER_KEY_CODES table.
         */
        protected static void putIdentifierKeyCode(String keyIdentifier,
                                                   int keyCode) {
            if (IDENTIFIER_KEY_CODES[keyCode / 256] == null) {
                IDENTIFIER_KEY_CODES[keyCode / 256] = new String[256];
            }
            IDENTIFIER_KEY_CODES[keyCode / 256][keyCode % 256] = keyIdentifier;
        }

        /**
         * Convert a Java key code to a DOM 3 key string.
         */
        protected String mapKeyCodeToIdentifier(int keyCode) {
            String[] a = IDENTIFIER_KEY_CODES[keyCode / 256];
            if (a == null) {
                return DOMKeyboardEvent.KEY_UNIDENTIFIED;
            }
            return a[keyCode % 256];
        }

        // MouseWheel ------------------------------------------------------

        public void mouseWheelMoved(GraphicsNodeMouseWheelEvent evt) {
            Document doc = context.getPrimaryBridgeContext().getDocument();
            Element targetElement = doc.getDocumentElement();
            DocumentEvent d = (DocumentEvent) doc;
            SVGOMWheelEvent wheelEvt
                = (SVGOMWheelEvent) d.createEvent("WheelEvent");
            wheelEvt.initWheelEventNS(XMLConstants.XML_EVENTS_NAMESPACE_URI,
                                      "wheel", 
                                      true,
                                      true,
                                      null,
                                      evt.getWheelDelta());

            try {
                ((EventTarget)targetElement).dispatchEvent(wheelEvt);
            } catch (RuntimeException e) {
                ua.displayError(e);
            }
        }

        // Mouse -----------------------------------------------------------

        public void mouseEntered(GraphicsNodeMouseEvent evt) {
            Point clientXY = evt.getClientPoint();
            GraphicsNode node = evt.getGraphicsNode();
            Element targetElement = getEventTarget
                (node, new Point2D.Float(evt.getX(), evt.getY()));
            Element relatedElement = getRelatedElement(evt);
            int n = 0;
            if (relatedElement != null && targetElement != null) {
                n = DefaultXBLManager.computeBubbleLimit(targetElement,
                                                         relatedElement);
            }
            dispatchMouseEvent("mouseover", 
                               targetElement,
                               relatedElement,
                               clientXY, 
                               evt, 
                               true,
                               n);
        }

        public void mouseExited(GraphicsNodeMouseEvent evt) {
            Point clientXY = evt.getClientPoint();
            // Get the 'new' node for the DOM event.
            GraphicsNode node = evt.getRelatedNode();
            Element targetElement = getEventTarget(node, clientXY);
            if (lastTargetElement != null) {
                int n = 0;
                if (targetElement != null) {
                    // moving from one element to another
                    n = DefaultXBLManager.computeBubbleLimit(lastTargetElement,
                                                             targetElement);
                }
                dispatchMouseEvent("mouseout", 
                                   lastTargetElement, // target
                                   targetElement,     // relatedTarget
                                   clientXY,
                                   evt,
                                   true,
                                   n);
                lastTargetElement = null;
            }
        }

        public void mouseMoved(GraphicsNodeMouseEvent evt) {
            Point clientXY = evt.getClientPoint();
            GraphicsNode node = evt.getGraphicsNode();
            Element targetElement = getEventTarget(node, clientXY);
            Element holdLTE = lastTargetElement;
            if (holdLTE != targetElement) {
                if (holdLTE != null) {
                    int n = 0;
                    if (targetElement != null) {
                        n = DefaultXBLManager.computeBubbleLimit(holdLTE,
                                                                 targetElement);
                    }
                    dispatchMouseEvent("mouseout", 
                                       holdLTE, // target
                                       targetElement,     // relatedTarget
                                       clientXY,
                                       evt,
                                       true,
                                       n);
                }
                if (targetElement != null) {
                    int n = 0;
                    if (holdLTE != null) {
                        n = DefaultXBLManager.computeBubbleLimit(targetElement,
                                                                 holdLTE);
                    }
                    dispatchMouseEvent("mouseover", 
                                       targetElement,     // target
                                       holdLTE, // relatedTarget
                                       clientXY,
                                       evt,
                                       true,
                                       n);
                }
            }
            dispatchMouseEvent("mousemove", 
                               targetElement,     // target
                               null,              // relatedTarget
                               clientXY,
                               evt,
                               false,
                               0);
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
            dispatchMouseEvent(eventType, targetElement, relatedElement,
                               clientXY, evt, cancelable, 0);
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
         * @param bubbleLimit the limit to the number of nodes the event
         *                    will bubble to
         */
        protected void dispatchMouseEvent(String eventType,
                                          Element targetElement,
                                          Element relatedElement,
                                          Point clientXY,
                                          GraphicsNodeMouseEvent evt,
                                          boolean cancelable,
                                          int bubbleLimit) {
            if (ctx12.mouseCaptureTarget != null) {
                NodeEventTarget net = null;
                if (targetElement != null) {
                    net = (NodeEventTarget) targetElement;
                    while (net != null && net != ctx12.mouseCaptureTarget) {
                        net = net.getParentNodeEventTarget();
                    }
                }
                if (net == null) {
                    if (ctx12.mouseCaptureSendAll) {
                        targetElement = (Element) ctx12.mouseCaptureTarget;
                    } else {
                        targetElement = null;
                    }
                }
            }

            if (targetElement != null) {
                Point screenXY = evt.getScreenPoint();
                // create the coresponding DOM MouseEvent
                DocumentEvent d
                    = (DocumentEvent) targetElement.getOwnerDocument();
                DOMMouseEvent mouseEvt
                    = (DOMMouseEvent) d.createEvent("MouseEvents");
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
                                          (EventTarget) relatedElement,
                                          modifiers);

                ((AbstractEvent) mouseEvt).setBubbleLimit(bubbleLimit);

                try {
                    ((EventTarget) targetElement).dispatchEvent(mouseEvt);
                } catch (RuntimeException e) {
                    ua.displayError(e);
                } finally {
                    lastTargetElement = targetElement;
                }
            }

            if (ctx12.mouseCaptureTarget != null
                    && ctx12.mouseCaptureAutoRelease
                    && "mouseup".equals(eventType)) {
                ctx12.stopMouseCapture();
            }
        }
    }
}
