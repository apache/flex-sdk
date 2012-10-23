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

import java.util.EventListener;

/**
 * The listener interface for receiving graphics node mouse events.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: GraphicsNodeMouseListener.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface GraphicsNodeMouseListener extends EventListener {

    /**
     * Invoked when the mouse has been clicked on a graphics node.
     * @param evt the graphics node mouse event
     */
    void mouseClicked(GraphicsNodeMouseEvent evt);

    /**
     * Invoked when a mouse button has been pressed on a graphics node.
     * @param evt the graphics node mouse event
     */
    void mousePressed(GraphicsNodeMouseEvent evt);

    /**
     * Invoked when a mouse button has been released on a graphics node.
     * @param evt the graphics node mouse event
     */
    void mouseReleased(GraphicsNodeMouseEvent evt);

    /**
     * Invoked when the mouse enters a graphics node.
     * @param evt the graphics node mouse event
     */
    void mouseEntered(GraphicsNodeMouseEvent evt);

    /**
     * Invoked when the mouse exits a graphics node.
     * @param evt the graphics node mouse event
     */
    void mouseExited(GraphicsNodeMouseEvent evt);

    /**
     * Invoked when a mouse button is pressed on a graphics node and then
     * dragged.
     * @param evt the graphics node mouse event
     */
    void mouseDragged(GraphicsNodeMouseEvent evt);

    /**
     * Invoked when the mouse button has been moved on a node.
     * @param evt the graphics node mouse event
     */
    void mouseMoved(GraphicsNodeMouseEvent evt);
}
