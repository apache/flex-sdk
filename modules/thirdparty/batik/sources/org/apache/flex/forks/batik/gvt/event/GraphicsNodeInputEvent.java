/*

   Copyright 2000,2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.gvt.event;

import java.awt.event.InputEvent;

import org.apache.flex.forks.batik.gvt.GraphicsNode;

/**
 * The root event class for all graphics node-level input events.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: GraphicsNodeInputEvent.java,v 1.6 2005/02/22 09:13:02 cam Exp $
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
    public static final int BUTTON1_MASK = InputEvent.BUTTON1_MASK;

    /**
     * The mouse button2 modifier constant.
     */
    public static final int BUTTON2_MASK = InputEvent.ALT_MASK;

    /**
     * The mouse button3 modifier constant.
     */
    public static final int BUTTON3_MASK = InputEvent.META_MASK;

    /**
     * The graphics node input events Time stamp. The time stamp is in
     * UTC format that indicates when the input event was
     * created.
     */
    long when;

    /**
     * The state of the modifier key at the time the graphics node
     * input event was fired.
     */
    int modifiers;

    /**
     * Constructs a new graphics node input event.
     * @param source the graphics node where the event originated
     * @param id the id of this event
     * @param when the time the event occurred
     * @param modifiers the modifier keys down while event occurred
     */
    protected GraphicsNodeInputEvent(GraphicsNode source, int id,
                                     long when, int modifiers) {
        super(source, id);
        this.when = when;
        this.modifiers = modifiers;
    }

    /**
     * Constructs a new graphics node input event from an AWT InputEvent.
     * @param source the graphics node where the event originated
     * @param evt the AWT InputEvent triggering this event's creation
     */
    protected GraphicsNodeInputEvent(GraphicsNode source, InputEvent evt) {
        super(source, evt.getID());
        this.when = evt.getWhen();
        this.modifiers = evt.getModifiers();
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
        return (modifiers & META_MASK) != 0;
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
}
