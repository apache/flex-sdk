/*

   Copyright 2000,2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.util.gui.resource;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;

import javax.swing.JComponent;

/**
 * This class represents a separator for the toolbar buttons.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: JToolbarSeparator.java,v 1.4 2004/08/18 07:15:56 vhardy Exp $
 */
public class JToolbarSeparator extends JComponent {
    /**
     * Creates a new JToolbarSeparator object.
     */
    public JToolbarSeparator() {
        setMaximumSize(new Dimension(15, Integer.MAX_VALUE));
    }

    protected void paintComponent(Graphics g) {
        super.paintComponent(g);

        Dimension size = getSize();
        int pos = size.width / 2;
        g.setColor(Color.gray);
        g.drawLine(pos, 3, pos, size.height - 5);
        g.drawLine(pos, 2, pos + 1, 2);
        g.setColor(Color.white);
        g.drawLine(pos + 1, 3, pos + 1, size.height - 5);
        g.drawLine(pos, size.height - 4, pos + 1, size.height - 4);
    }
}
