/*

   Copyright 2001-2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.svggen;

import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;

import javax.swing.JComponent;

/**
 * Simple component which displays the rendering created by
 * a <tt>Painter</tt>.
 *
 * @author <a href="mailto:vincent.hardy@sun.com">Vincent Hardy</a>
 * @version $Id: JPainterComponent.java,v 1.5 2004/08/18 07:16:45 vhardy Exp $
 */
public class JPainterComponent extends JComponent {
    /**
     * <tt>Painter</tt>
     */
    protected Painter painter;

    /**
     * Delegates to its <tt>Painter</tt>
     */
    public void paint(Graphics _g){
        Graphics2D g = (Graphics2D)_g;
        BufferedImage buf = new BufferedImage(getWidth(), getHeight(), BufferedImage.TYPE_INT_ARGB);
        painter.paint(buf.createGraphics());
        g.drawImage(buf, 0, 0, null);
    }

    /**
     * Constructor
     */
    public JPainterComponent(Painter painter){
        this.painter = painter;
    }

}
