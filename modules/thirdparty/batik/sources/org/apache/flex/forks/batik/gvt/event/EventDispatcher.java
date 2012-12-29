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
import java.awt.geom.AffineTransform;
import java.util.EventListener;
import java.util.EventObject;

import org.apache.flex.forks.batik.gvt.GraphicsNode;

/**
 * Interface for receiving and dispatching events down to a GVT tree.
 *
 * <p>Mouse events are dispatched to their "containing" node (the
 * GraphicsNode corresponding to the mouse event coordinate). Searches
 * for containment are performed from the EventDispatcher's "root"
 * node.</p>
 *
 * @author <a href="mailto:bill.haneman@ireland.sun.com">Bill Haneman</a>
 * @author <a href="mailto:tkormann@ilog.fr">Thierry Kormann</a>
 * @version $Id: EventDispatcher.java 475477 2006-11-15 22:44:28Z cam $ */
public interface EventDispatcher {

    /**
     * Sets the root node for MouseEvent dispatch containment searches
     * and field selections.
     * @param root the root node
     */
    void setRootNode(GraphicsNode root);

    /**
     * Returns the root node for MouseEvent dispatch containment
     * searches and field selections.
     */
    GraphicsNode getRootNode();

    /**
     * Sets the base transform applied to MouseEvent coordinates prior
     * to dispatch.
     * @param t the affine transform
     */
    void setBaseTransform(AffineTransform t);

    /**
     * Returns the base transform applied to MouseEvent coordinates prior
     * to dispatch.
     */
    AffineTransform getBaseTransform();

    /**
     * Dispatched the specified event object.
     *
     * <p>Converts the EventObject to a corresponding GraphicsNodeEvent
     * and dispatch it to the appropriate GraphicsNode(s). If the
     * event is a MouseEvent the dispatch is performed to each
     * GraphicsNode which contains the MouseEvent coordinate, until
     * the event is consumed. If the event is a KeyEvent, it is
     * dispatched to the currently selected GraphicsNode.</p>
     *
     * @param e the event to dispatch
     */
    void dispatchEvent(EventObject e);

    //
    // Global GVT listeners support
    //

    /**
     * Adds the specified 'global' GraphicsNodeMouseListener which is
     * notified of all MouseEvents dispatched.
     * @param l the listener to add
     */
    void addGraphicsNodeMouseListener(GraphicsNodeMouseListener l);

    /**
     * Removes the specified 'global' GraphicsNodeMouseListener which is
     * notified of all MouseEvents dispatched.
     * @param l the listener to remove
     */
    void removeGraphicsNodeMouseListener(GraphicsNodeMouseListener l);

    /**
     * Adds the specified 'global' GraphicsNodeMouseWheelListener which is
     * notified of all MouseWheelEvents dispatched.
     * @param l the listener to add
     */
    void addGraphicsNodeMouseWheelListener(GraphicsNodeMouseWheelListener l);

    /**
     * Removes the specified 'global' GraphicsNodeMouseWheelListener which is
     * notified of all MouseWheelEvents dispatched.
     * @param l the listener to remove
     */
    void removeGraphicsNodeMouseWheelListener(GraphicsNodeMouseWheelListener l);

    /**
     * Adds the specified 'global' GraphicsNodeKeyListener which is
     * notified of all KeyEvents dispatched.
     * @param l the listener to add
     */
    void addGraphicsNodeKeyListener(GraphicsNodeKeyListener l);

    /**
     * Removes the specified 'global' GraphicsNodeKeyListener which is
     * notified of all KeyEvents dispatched.
     * @param l the listener to remove
     */
    void removeGraphicsNodeKeyListener(GraphicsNodeKeyListener l);

    /**
     * Returns an array of listeners that were added to this event
     * dispatcher and of the specified type.
     * @param listenerType the type of the listeners to return
     */
    EventListener [] getListeners(Class listenerType);

    /**
     * Associates all InputEvents of type <tt>e.getID()</tt>
     * with "incrementing" of the currently selected GraphicsNode.
     */
    void setNodeIncrementEvent(InputEvent e);

    /**
     * Associates all InputEvents of type <tt>e.getID()</tt>
     * with "decrementing" of the currently selected GraphicsNode.
     * The notion of "currently selected" GraphicsNode is used
     * for dispatching KeyEvents.
     */
    void setNodeDecrementEvent(InputEvent e);

}

