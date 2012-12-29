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
package org.apache.flex.forks.batik.dom.events;

import java.util.HashSet;
import java.util.Iterator;

import org.w3c.dom.events.EventTarget;
import org.w3c.dom.events.MouseEvent;
import org.w3c.dom.views.AbstractView;

/**
 * The MouseEvent class provides specific contextual information
 * associated with Mouse events.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: DOMMouseEvent.java 598494 2007-11-27 02:46:33Z cam $
 */
public class DOMMouseEvent extends DOMUIEvent implements MouseEvent {

    private int screenX;
    private int screenY;
    private int clientX;
    private int clientY;
    private short button;
    private EventTarget relatedTarget;

    /**
     * The modifier keys in effect at the time of the event.
     */
    protected HashSet modifierKeys = new HashSet();

    /**
     * DOM: <code>screenX</code> indicates the horizontal coordinate
     * at which the event occurred relative to the origin of the
     * screen coordinate system.
     */
    public int getScreenX() {
        return screenX;
    }

    /**
     * DOM: <code>screenY</code> indicates the vertical coordinate at
     * which the event occurred relative to the origin of the screen
     * coordinate system.
     */
    public int getScreenY() {
        return screenY;
    }

    /**
     * DOM: <code>clientX</code> indicates the horizontal coordinate
     * at which the event occurred relative to the DOM
     * implementation's client area.
     */
    public int getClientX() {
        return clientX;
    }

    /**
     * DOM: <code>clientY</code> indicates the vertical coordinate at
     * which the event occurred relative to the DOM implementation's
     * client area.
     */
    public int getClientY() {
        return clientY;
    }

    /**
     * DOM: <code>ctrlKey</code> indicates whether the 'ctrl' key was
     * depressed during the firing of the event.
     */
    public boolean getCtrlKey() {
        return modifierKeys.contains(DOMKeyboardEvent.KEY_CONTROL);
    }

    /**
     * DOM: <code>shiftKey</code> indicates whether the 'shift' key
     * was depressed during the firing of the event.
     */
    public boolean getShiftKey() {
        return modifierKeys.contains(DOMKeyboardEvent.KEY_SHIFT);
    }

    /**
     * DOM: <code>altKey</code> indicates whether the 'alt' key was
     * depressed during the firing of the event.  On some platforms
     * this key may map to an alternative key name.
     */
    public boolean getAltKey() {
        return modifierKeys.contains(DOMKeyboardEvent.KEY_ALT);
    }

    /**
     * DOM: <code>metaKey</code> indicates whether the 'meta' key was
     * depressed during the firing of the event.  On some platforms
     * this key may map to an alternative key name.
     */
    public boolean getMetaKey() {
        return modifierKeys.contains(DOMKeyboardEvent.KEY_META);
    }

    /**
     * DOM: During mouse events caused by the depression or release of
     * a mouse button, <code>button</code> is used to indicate which
     * mouse button changed state.  The values for <code>button</code>
     * range from zero to indicate the left button of the mouse, one
     * to indicate the middle button if present, and two to indicate
     * the right button.  For mice configured for left handed use in
     * which the button actions are reversed the values are instead
     * read from right to left.
     */
    public short getButton() {
        return button;
    }

    /**
     * DOM: Used to identify a secondary <code>EventTarget</code> related
     * to a UI
     * event.  Currently this attribute is used with the mouseover event to
     * indicate the <code>EventTarget</code> which the pointing device exited
     * and with the mouseout event to indicate the  <code>EventTarget</code>
     * which the pointing device entered.
     */
    public EventTarget getRelatedTarget() {
        return relatedTarget;
    }

    /**
     * <b>DOM</b>: Returns whether the given modifier key was pressed at the
     * time of the event.
     */
    public boolean getModifierState(String keyIdentifierArg) {
        return modifierKeys.contains(keyIdentifierArg);
    }

    /**
     * Returns the modifiers string for this event.
     */
    public String getModifiersString() {
        if (modifierKeys.isEmpty()) {
            return "";
        }
        StringBuffer sb = new StringBuffer(modifierKeys.size() * 8);
        Iterator i = modifierKeys.iterator();
        sb.append((String) i.next());
        while (i.hasNext()) {
             sb.append(' ');
             sb.append((String) i.next());
        }
        return sb.toString();
    }

    /**
     * DOM: The <code>initMouseEvent</code> method is used to
     * initialize the value of a <code>MouseEvent</code> created
     * through the <code>DocumentEvent</code> interface.  This method
     * may only be called before the <code>MouseEvent</code> has been
     * dispatched via the <code>dispatchEvent</code> method, though it
     * may be called multiple times during that phase if necessary.
     * If called multiple times, the final invocation takes
     * precedence.
     *
     * @param typeArg Specifies the event type.
     * @param canBubbleArg Specifies whether or not the event can bubble.
     * @param cancelableArg Specifies whether or not the event's default
     *   action can be prevented.
     * @param viewArg Specifies the <code>Event</code>'s
     *   <code>AbstractView</code>.
     * @param detailArg Specifies the <code>Event</code>'s mouse click count.
     * @param screenXArg Specifies the <code>Event</code>'s screen x coordinate
     * @param screenYArg Specifies the <code>Event</code>'s screen y coordinate
     * @param clientXArg Specifies the <code>Event</code>'s client x coordinate
     * @param clientYArg Specifies the <code>Event</code>'s client y coordinate
     * @param ctrlKeyArg Specifies whether or not control key was depressed
     *   during the <code>Event</code>.
     * @param altKeyArg Specifies whether or not alt key was depressed during
     *   the  <code>Event</code>.
     * @param shiftKeyArg Specifies whether or not shift key was depressed
     *   during the <code>Event</code>.
     * @param metaKeyArg Specifies whether or not meta key was depressed
     *   during the  <code>Event</code>.
     * @param buttonArg Specifies the <code>Event</code>'s mouse button.
     * @param relatedTargetArg Specifies the <code>Event</code>'s related
     *   <code>EventTarget</code>.
     */
    public void initMouseEvent(String typeArg,
                               boolean canBubbleArg,
                               boolean cancelableArg,
                               AbstractView viewArg,
                               int detailArg,
                               int screenXArg,
                               int screenYArg,
                               int clientXArg,
                               int clientYArg,
                               boolean ctrlKeyArg,
                               boolean altKeyArg,
                               boolean shiftKeyArg,
                               boolean metaKeyArg,
                               short buttonArg,
                               EventTarget relatedTargetArg) {
        initUIEvent(typeArg, canBubbleArg, cancelableArg,
                    viewArg, detailArg);
        this.screenX = screenXArg;
        this.screenY = screenYArg;
        this.clientX = clientXArg;
        this.clientY = clientYArg;
        if (ctrlKeyArg) {
            modifierKeys.add(DOMKeyboardEvent.KEY_CONTROL);
        }
        if (altKeyArg) {
            modifierKeys.add(DOMKeyboardEvent.KEY_ALT);
        }
        if (shiftKeyArg) {
            modifierKeys.add(DOMKeyboardEvent.KEY_SHIFT);
        }
        if (metaKeyArg) {
            modifierKeys.add(DOMKeyboardEvent.KEY_META);
        }
        this.button = buttonArg;
        this.relatedTarget = relatedTargetArg;
    }

    /**
     * <b>DOM</b>: Initializes this event object.
     */
    public void initMouseEventNS(String namespaceURIArg,
                                 String typeArg,
                                 boolean canBubbleArg,
                                 boolean cancelableArg,
                                 AbstractView viewArg,
                                 int detailArg,
                                 int screenXArg,
                                 int screenYArg,
                                 int clientXArg,
                                 int clientYArg,
                                 short buttonArg,
                                 EventTarget relatedTargetArg,
                                 String modifiersList) {
        initUIEventNS(namespaceURIArg,
                      typeArg,
                      canBubbleArg,
                      cancelableArg,
                      viewArg,
                      detailArg);
        screenX = screenXArg;
        screenY = screenYArg;
        clientX = clientXArg;
        clientY = clientYArg;
        button = buttonArg;
        relatedTarget = relatedTargetArg;
        modifierKeys.clear();
        String[] modifiers = split(modifiersList);
        for (int i = 0; i < modifiers.length; i++) {
            modifierKeys.add(modifiers[i]);
        }
    }
}
