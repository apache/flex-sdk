/*

   Copyright 2001,2003  The Apache Software Foundation 

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

import java.awt.event.MouseEvent;
import java.awt.geom.AffineTransform;

/**
 * This class represents a zoom interactor.
 * To use it, just redefine the {@link
 * InteractorAdapter#startInteraction(InputEvent)} method.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: AbstractImageZoomInteractor.java,v 1.4 2004/08/18 07:15:32 vhardy Exp $
 */
public class AbstractImageZoomInteractor extends InteractorAdapter {

    /**
     * Whether the interactor has finished.
     */
    protected boolean finished = true;

    /**
     * The mouse x start position.
     */
    protected int xStart;

    /**
     * The mouse y start position.
     */
    protected int yStart;

    /**
     * The mouse x current position.
     */
    protected int xCurrent;

    /**
     * The mouse y current position.
     */
    protected int yCurrent;

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
        if (!finished) {
            JGVTComponent c = (JGVTComponent)e.getSource();
            c.setPaintingTransform(null);
            return;
        }
        
        finished = false;

        xStart = e.getX();
        yStart = e.getY();
    }

    /**
     * Invoked when a mouse button has been released on a component.
     */
    public void mouseReleased(MouseEvent e) {
        finished = true;

        JGVTComponent c = (JGVTComponent)e.getSource();

        AffineTransform pt = c.getPaintingTransform();
        if (pt != null) {
            AffineTransform rt = (AffineTransform)c.getRenderingTransform().clone();
            rt.preConcatenate(pt);
            c.setRenderingTransform(rt);
        }
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

        xCurrent = e.getX();
        yCurrent = e.getY();

        AffineTransform at = AffineTransform.getTranslateInstance(xStart, yStart);
        int dy = yCurrent - yStart;
        if (dy < 0) {
            dy = (dy > -5) ? 15 : dy - 10;
        } else {
            dy = (dy < 5) ? 15 : dy + 10;
        }
        double s = dy / 15.0;
        s = (s > 0) ? s : -1 / s;

        at.scale(s, s);
        at.translate(-xStart, -yStart);
        c.setPaintingTransform(at);
    }
}
