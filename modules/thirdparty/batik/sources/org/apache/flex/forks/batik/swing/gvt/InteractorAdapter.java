/*

   Copyright 2001  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.swing.gvt;

import java.awt.event.InputEvent;
import java.awt.event.KeyEvent;
import java.awt.event.MouseEvent;

/**
 * This class represents an interactor which never interacts.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: InteractorAdapter.java,v 1.3 2004/08/18 07:15:32 vhardy Exp $
 */
public class InteractorAdapter implements Interactor {
    
    /**
     * Tells whether the given event will start the interactor.
     */
    public boolean startInteraction(InputEvent ie) {
        return false;
    }

    /**
     * Tells whether the interaction has finished.
     */
    public boolean endInteraction() {
        return false;
    }

    // KeyListener //////////////////////////////////////////////////////////

    /**
     * Invoked when a key has been typed.
     * This event occurs when a key press is followed by a key release.
     */
    public void keyTyped(KeyEvent e) {
    }
        
    /**
     * Invoked when a key has been pressed.
     */
    public void keyPressed(KeyEvent e) {
    }

    /**
     * Invoked when a key has been released.
     */
    public void keyReleased(KeyEvent e) {
    }

    // MouseListener ///////////////////////////////////////////////////////
        
    /**
     * Invoked when the mouse has been clicked on a component.
     */
    public void mouseClicked(MouseEvent e) {
    }

    /**
     * Invoked when a mouse button has been pressed on a component.
     */
    public void mousePressed(MouseEvent e) {
    }

    /**
     * Invoked when a mouse button has been released on a component.
     */
    public void mouseReleased(MouseEvent e) {
    }

    /**
     * Invoked when the mouse enters a component.
     */
    public void mouseEntered(MouseEvent e) {
    }

    /**
     * Invoked when the mouse exits a component.
     */
    public void mouseExited(MouseEvent e) {

    }

    // MouseMotionListener /////////////////////////////////////////////////

    /**
     * Invoked when a mouse button is pressed on a component and then 
     * dragged.  Mouse drag events will continue to be delivered to
     * the component where the first originated until the mouse button is
     * released (regardless of whether the mouse position is within the
     * bounds of the component).
     */
    public void mouseDragged(MouseEvent e) {
    }

    /**
     * Invoked when the mouse button has been moved on a component
     * (with no buttons no down).
     */
    public void mouseMoved(MouseEvent e) {
    }
}
