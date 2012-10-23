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
package org.apache.flex.forks.batik.swing.gvt;

import java.awt.Dimension;
import java.awt.event.InputEvent;
import java.awt.event.MouseEvent;
import java.awt.geom.AffineTransform;

/**
 * This class represents a rotate interactor.
 * To use it, just redefine the {@link
 * InteractorAdapter#startInteraction(InputEvent)} method.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: AbstractRotateInteractor.java 475477 2006-11-15 22:44:28Z cam $
 */
public class AbstractRotateInteractor extends InteractorAdapter {

    /**
     * Whether the interactor has finished.
     */
    protected boolean finished;

    /**
     * The initial rotation angle.
     */
    protected double initialRotation;

    /**
     * Tells whether the interactor has finished.
     */
    public boolean endInteraction() {
        return finished;
    }

    // MouseListener ///////////////////////////////////////////////////////
        
    /**
     * Invoked when a mouse button has been pressed on a component.
     */
    public void mousePressed(MouseEvent e) {
        finished = false;
        JGVTComponent c = (JGVTComponent)e.getSource();

        Dimension d = c.getSize();
        double dx = e.getX() - d.width / 2;
        double dy = e.getY() - d.height / 2;
        double cos = -dy / Math.sqrt(dx * dx + dy * dy);
        initialRotation = (dx > 0) ? Math.acos(cos) : -Math.acos(cos);
    }

    /**
     * Invoked when a mouse button has been released on a component.
     */
    public void mouseReleased(MouseEvent e) {
        finished = true;
        JGVTComponent c = (JGVTComponent)e.getSource();

        AffineTransform at = rotateTransform(c.getSize(), e.getX(), e.getY());
        at.concatenate(c.getRenderingTransform());
        c.setRenderingTransform(at);
    }

    /**
     * Invoked when the mouse exits a component.
     */
    public void mouseExited(MouseEvent e) {
        finished = true;
        JGVTComponent c = (JGVTComponent)e.getSource();
        c.setPaintingTransform(null);
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
        JGVTComponent c = (JGVTComponent)e.getSource();

        c.setPaintingTransform(rotateTransform(c.getSize(), e.getX(), e.getY()));
    }

    /**
     * Returns the rotate transform.
     */
    protected AffineTransform rotateTransform(Dimension d, int x, int y) {
        double dx = x - d.width / 2;
        double dy = y - d.height / 2;
        double cos = -dy / Math.sqrt(dx * dx + dy * dy);
        double angle = (dx > 0) ? Math.acos(cos) : -Math.acos(cos);

        angle -= initialRotation;

        return AffineTransform.getRotateInstance(angle, d.width / 2, d.height / 2);
    }
}
