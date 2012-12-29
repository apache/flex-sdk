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
 * The listener interface for receiving graphics node key events.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: GraphicsNodeKeyListener.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface GraphicsNodeKeyListener extends EventListener {

    /**
     * Invoked when a key has been pressed.
     * @param evt the graphics node key event
     */
    void keyPressed(GraphicsNodeKeyEvent evt);

    /**
     * Invoked when a key has been released.
     * @param evt the graphics node key event
     */
    void keyReleased(GraphicsNodeKeyEvent evt);

    /**
     * Invoked when a key has been typed.
     * @param evt the graphics node key event
     */
    void keyTyped(GraphicsNodeKeyEvent evt);

}
