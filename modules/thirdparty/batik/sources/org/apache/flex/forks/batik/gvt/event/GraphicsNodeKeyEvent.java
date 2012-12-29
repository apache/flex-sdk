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

import org.apache.flex.forks.batik.gvt.GraphicsNode;

/**
 * An event which indicates that a keystroke occurred in a graphics node.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: GraphicsNodeKeyEvent.java 475477 2006-11-15 22:44:28Z cam $
 */
public class GraphicsNodeKeyEvent extends GraphicsNodeInputEvent {

    static final int KEY_FIRST = 400;

    /**
     * The "key typed" event.  This event is generated when a character is
     * entered.  In the simplest case, it is produced by a single key press.
     * Often, however, characters are produced by series of key presses, and
     * the mapping from key pressed events to key typed events may be
     * many-to-one or many-to-many.
     */
    public static final int KEY_TYPED = KEY_FIRST;

    /**
     * The "key pressed" event. This event is generated when a key
     * is pushed down.
     */
    public static final int KEY_PRESSED = 1 + KEY_FIRST;

    /**
     * The "key released" event. This event is generated when a key
     * is let up.
     */
    public static final int KEY_RELEASED = 2 + KEY_FIRST;

    /**
     * The unique value assigned to each of the keys on the
     * keyboard.  There is a common set of key codes that
     * can be fired by most keyboards.
     * The symbolic name for a key code should be used rather
     * than the code value itself.
     */
    protected int keyCode;

    /**
     * <code>keyChar</code> is a valid unicode character
     * that is fired by a key or a key combination on
     * a keyboard.
     */
    protected char keyChar;

    /**
     * The key location.
     */
    protected int keyLocation;

    /**
     * Constructs a new graphics node key event.
     * @param source the graphics node where the event originated
     * @param id the id of this event
     * @param when the time the event occurred
     * @param modifiers the modifier keys down while event occurred
     * @param lockState bitmask indicating which key locks were activated
     * @param keyCode the Java key code
     * @param keyChar the generated character
     * @param keyLocation the location of the key
     */
    public GraphicsNodeKeyEvent(GraphicsNode source, int id,
                                long when, int modifiers, int lockState,
                                int keyCode, char keyChar, int keyLocation) {
        super(source, id, when, modifiers, lockState);
        this.keyCode = keyCode;
        this.keyChar = keyChar;
        this.keyLocation = keyLocation;
    }

    /**
     * Return the integer code for the physical key pressed. Not localized.
     */
    public int getKeyCode() {
        return keyCode;
    }

    /**
     * Return a character corresponding to physical key pressed.
     * May be localized.
     */
    public char getKeyChar() {
        return keyChar;
    }

    /**
     * Returns the key location.
     */
    public int getKeyLocation() {
        return keyLocation;
    }
}
