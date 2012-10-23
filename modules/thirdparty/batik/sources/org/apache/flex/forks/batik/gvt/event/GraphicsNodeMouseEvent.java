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

import java.awt.Point;
import java.awt.event.MouseEvent;
import java.awt.geom.Point2D;

import org.apache.flex.forks.batik.gvt.GraphicsNode;

/**
 * An event which indicates that a mouse action occurred in a graphics node.
 *
 * @author <a href="mailto:cjolif@ilog.fr">Christophe Jolif</a>
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: GraphicsNodeMouseEvent.java 575202 2007-09-13 07:45:18Z cam $
 */
public class GraphicsNodeMouseEvent extends GraphicsNodeInputEvent {

    /**
     * The first number in the range of ids used for mouse events.
     */
    static final int MOUSE_FIRST = 500;

    /**
     * The id for the "mouseClicked" event. This MouseEvent occurs when a mouse
     * button is pressed and released.
     */
    public static final int MOUSE_CLICKED = MOUSE_FIRST;

    /**
     * The id for the "mousePressed" event. This MouseEvent occurs when a mouse
     * button is pushed down.
     */
    public static final int MOUSE_PRESSED = MOUSE_FIRST + 1;

    /**
     * The id for the "mouseReleased" event. This MouseEvent occurs when a mouse
     * button is let up.
     */
    public static final int MOUSE_RELEASED = MOUSE_FIRST + 2;

    /**
     * The id for the "mouseMoved" event. This MouseMotionEvent occurs
     * when the mouse position changes.
     */
    public static final int MOUSE_MOVED = MOUSE_FIRST + 3;

    /**
     * The id for the "mouseEntered" event. This MouseEvent occurs
     * when the mouse cursor enters a graphics node's area.
     */
    public static final int MOUSE_ENTERED = MOUSE_FIRST + 4;

    /**
     * The id for the "mouseExited" event. This MouseEvent occurs when
     * the mouse cursor leaves a graphics node's area.
     */
    public static final int MOUSE_EXITED = MOUSE_FIRST + 5;

    /**
     * The id for the "mouseDragged" event. This MouseEvent
     * occurs when the mouse position changes while the "drag"
     * modifier is active (for example, the shift key).
     */
    public static final int MOUSE_DRAGGED = MOUSE_FIRST + 6;

    /**
     * The graphics node mouse events x coordinate.
     * The x value is relative to the graphics node that fired the event.
     */
    float x;

    /**
     * The graphics node mouse events y coordinate.
     * The y value is relative to the graphics node that fired the event.
     */
    float y;

    int clientX;

    int clientY;

    int screenX;

    int screenY;

    /**
     * Indicates the number of quick consecutive clicks of a mouse button.
     */
    int clickCount;

    /**
     * The mouse button that changed state.
     */
    int button;
    
    /**
     * Additional information. For a MOUSE_EXITED, this will contain the
     * destination node, for a MOUSE_ENTERED the last node and for
     * a MOUSE_DRAGGED the node under the mouse pointer.
     */
    GraphicsNode relatedNode = null;

    /**
     * Constructs a new graphics node mouse event.
     * @param source the graphics node where the event originated
     * @param id the id of this event
     * @param when the time the event occurred
     * @param modifiers the modifier keys down when event occurred
     * @param lockState the lock keys active when the event occurred
     * @param button the mouse button that changed state
     * @param x the mouse x coordinate
     * @param y the mouse y coordinate
     * @param screenX the mouse x coordinate relative to the screen
     * @param screenY the mouse y coordinate relative to the screen
     * @param clickCount the number of clicks
     * @param relatedNode the related node
     * @see #getRelatedNode
     */
    public GraphicsNodeMouseEvent(GraphicsNode source, int id,
                                  long when, int modifiers, int lockState,
                                  int button, float x, float y, 
                                  int clientX, int clientY,
                                  int screenX, int screenY, 
                                  int clickCount,
                                  GraphicsNode relatedNode) {
        super(source, id, when, modifiers, lockState);
        this.button = button;
        this.x = x;
        this.y = y;
        this.clientX = clientX;
        this.clientY = clientY;
        this.screenX = screenX;
        this.screenY = screenY;
        this.clickCount = clickCount;
        this.relatedNode = relatedNode;
    }

    /**
     * Constructs a new graphics node mouse event from an AWT MouseEvent.
     * @param source the source where the event originated
     * @param evt the AWT mouse event which is the source of this
     *            GraphicsNodeEvent
     */
    public GraphicsNodeMouseEvent(GraphicsNode source,
                                  MouseEvent evt,
                                  int button,
                                  int lockState) {
        super(source, evt, lockState);
        this.button = button;
        this.x = evt.getX();
        this.y = evt.getY();
        this.clickCount = evt.getClickCount();
    }

    /**
     * Returns the mouse button that changed state.
     */
    public int getButton() {
        return button;
    }

    /**
     * Returns the horizontal x position of the event relative to the
     * source graphics node.
     * @return x a float indicating horizontal position relative to the node
     */
    public float getX() {
        return x;
    }

    /**
     * Returns the vertical y position of the event relative to the source node.
     * @return y a float indicating vertical position relative to the node
     */
    public float getY() {
        return y;
    }

    /**
     * Returns the horizontal x position of the event relative to the
     * source graphics node.
     * @return x a float indicating horizontal position relative to the node
     */
    public float getClientX() {
        return clientX;
    }

    /**
     * Returns the vertical y position of the event relative to the source node.
     * @return y a float indicating vertical position relative to the node
     */
    public float getClientY() {
        return clientY;
    }

    /**
     * Returns the horizontal x position of the event relative to the
     * screen.
     * @return x a float indicating horizontal position relative to the screen
     */
    public int getScreenX() {
        return screenX;
    }

    /**
     * Returns the vertical y position of the event relative to the screen.
     * @return y a float indicating vertical position relative to the screen
     */
    public int getScreenY() {
        return screenY;
    }

    /**
     * Returns the (x, y) position of the event relative to the screen.
     * @return a Point object containing the x and y coordinates
     */
    public Point getScreenPoint() {
        return new Point(screenX, screenY);
    }

    /**
     * Returns the (x, y) position of the event relative to the screen.
     * @return a Point object containing the x and y coordinates
     */
    public Point getClientPoint() {
        return new Point(clientX, clientY);
    }

    /**
     * Returns the (x, y) position of the event relative to the source node.
     * @return a Point object containing the x and y coordinates
     */
    public Point2D getPoint2D() {
        return new Point2D.Float(x, y);
    }

    /**
     * Returns the number of mouse clicks associated with this event.
     * @return integer value for the number of clicks
     */
    public int getClickCount() {
        return clickCount;
    }

    /**
     * Returns the related node for this <code>GraphicsNodeMouseEvent</code>.
     * For a <code>MOUSE_ENTERED</code> event it is the previous node target,
     * for a <code>MOUSE_EXITED</code> event it is the next node target and
     * for a <code>MOUSE_DRAGGED</code> event it is the node under the mouse
     * pointer. Otherwise the value is <code>null</code>.
     */
    public GraphicsNode getRelatedNode() {
        return relatedNode;
    }
}
