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
 * An event which indicates that a mouse whwel action occurred in a graphics
 * node.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: GraphicsNodeMouseWheelEvent.java 475477 2006-11-15 22:44:28Z cam $
 */
public class GraphicsNodeMouseWheelEvent extends GraphicsNodeInputEvent {

    /**
     * The id for the "mouseWheelMoved" event.
     */
    public static final int MOUSE_WHEEL = 600;

    /**
     * Indicates the number of wheel notches have been moved.
     * Positive for scrolling up/left, negative for down/right.
     */
    protected int wheelDelta;

    /**
     * Constructs a new graphics node mouse wheel event.
     * @param source the graphics node where the event originated
     * @param id the id of this event
     * @param when the time the event occurred
     * @param wheelDelta the number of clicks
     */
    public GraphicsNodeMouseWheelEvent(GraphicsNode source, int id,
                                       long when, int modifiers, int lockState,
                                       int wheelDelta) {
        super(source, id, when, modifiers, lockState);
        this.wheelDelta = wheelDelta;
    }

    /**
     * Returns the number of clicks the wheel has been moved.
     */
    public int getWheelDelta() {
        return wheelDelta;
    }
}
