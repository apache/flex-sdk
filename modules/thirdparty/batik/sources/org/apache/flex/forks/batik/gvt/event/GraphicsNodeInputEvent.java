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
package org.apache.flex.forks.batik.gvt.event;

import java.awt.event.InputEvent;

import org.apache.flex.forks.batik.gvt.GraphicsNode;

/**
 * The root event class for all graphics node-level input events.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: GraphicsNodeInputEvent.java 575202 2007-09-13 07:45:18Z cam $
 */
public abstract class GraphicsNodeInputEvent extends GraphicsNodeEvent {

    /**
     * The shift key modifier constant.
     */
    public static final int SHIFT_MASK = InputEvent.SHIFT_MASK;

    /**
     * The control key modifier constant.
     */
    public static final int CTRL_MASK = InputEvent.CTRL_MASK;

    /**
     * The meta key modifier constant.
     */
    public static final int META_MASK = InputEvent.META_MASK;

    /**
     * The alt key modifier constant.
     */
    public static final int ALT_MASK = InputEvent.ALT_MASK;

    /**
     * The alt-graph key modifier constant.
     */
    public static final int ALT_GRAPH_MASK = InputEvent.ALT_GRAPH_MASK;

    /**
     * The mouse button1 modifier constant.
     */
    public static final int BUTTON1_MASK = 1 << 10; // BUTTON1_DOWN_MASK

    /**
     * The mouse button2 modifier constant.
     */
    public static final int BUTTON2_MASK = 1 << 11; // BUTTON2_DOWN_MASK

    /**
     * The mouse button3 modifier constant.
     */
    public static final int BUTTON3_MASK = 1 << 12; // BUTTON3_DOWN_MASK

    /**
     * The caps lock constant.
     */
    public static final int CAPS_LOCK_MASK = 0x01;

    /**
     * The num lock constant.
     */
    public static final int NUM_LOCK_MASK = 0x02;

    /**
     * The scroll lock constant.
     */
    public static final int SCROLL_LOCK_MASK = 0x04;

    /**
     * The kana lock constant.
     */
    public static final int KANA_LOCK_MASK = 0x08;

    /**
     * The graphics node input events Time stamp. The time stamp is in
     * UTC format that indicates when the input event was
     * created.
     */
    long when;

    /**
     * The state of the modifier keys at the time the graphics node
     * input event was fired.
     */
    int modifiers;

    /**
     * The state of the key locks at the time the graphics node input
     * event was fired.
     */
    int lockState;

    /**
     * Constructs a new graphics node input event.
     * @param source the graphics node where the event originated
     * @param id the id of this event
     * @param when the time the event occurred
     * @param modifiers the modifier keys down while event occurred
     */
    protected GraphicsNodeInputEvent(GraphicsNode source, int id,
                                     long when, int modifiers, int lockState) {
        super(source, id);
        this.when = when;
        this.modifiers = modifiers;
        this.lockState = lockState;
    }

    /**
     * Constructs a new graphics node input event from an AWT InputEvent.
     * @param source the graphics node where the event originated
     * @param evt the AWT InputEvent triggering this event's creation
     */
    protected GraphicsNodeInputEvent(GraphicsNode source,
                                     InputEvent evt,
                                     int lockState) {
        super(source, evt.getID());
        this.when = evt.getWhen();
        this.modifiers = evt.getModifiers();
        this.lockState = lockState;
    }

    /**
     * Returns whether or not the Shift modifier is down on this event.
     */
    public boolean isShiftDown() {
        return (modifiers & SHIFT_MASK) != 0;
    }

    /**
     * Returns whether or not the Control modifier is down on this event.
     */
    public boolean isControlDown() {
        return (modifiers & CTRL_MASK) != 0;
    }

    /**
     * Returns whether or not the Meta modifier is down on this event.
     */
    public boolean isMetaDown() {
        return AWTEventDispatcher.isMetaDown(modifiers);
    }

    /**
     * Returns whether or not the Alt modifier is down on this event.
     */
    public boolean isAltDown() {
        return (modifiers & ALT_MASK) != 0;
    }

    /**
     * Returns whether or not the Alt-Graph modifier is down on this event.
     */
    public boolean isAltGraphDown() {
        return (modifiers & ALT_GRAPH_MASK) != 0;
    }

    /**
     * Returns the timestamp of when this event occurred.
     */
    public long getWhen() {
        return when;
    }

    /**
     * Returns the modifiers flag for this event.
     */
    public int getModifiers() {
        return modifiers;
    }

    /**
     * Returns the lock state flags for this event.
     */
    public int getLockState() {
        return lockState;
    }
}
