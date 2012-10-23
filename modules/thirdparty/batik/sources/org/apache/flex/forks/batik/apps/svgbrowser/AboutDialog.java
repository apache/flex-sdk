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
package org.apache.flex.forks.batik.apps.svgbrowser;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Frame;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.net.URL;

import javax.swing.BorderFactory;
import javax.swing.ImageIcon;
import javax.swing.JComponent;
import javax.swing.JLabel;
import javax.swing.JLayeredPane;
import javax.swing.JWindow;
import javax.swing.border.BevelBorder;

import org.apache.flex.forks.batik.Version;

/**
 * A dialog showing the revision of the Batik viewer as well
 * as the list of contributors.
 * The dialog can be dismissed by click or by escaping.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: AboutDialog.java 496989 2007-01-17 11:06:49Z cam $
 */
public class AboutDialog extends JWindow {

    public static final String ICON_BATIK_SPLASH 
        = "AboutDialog.icon.batik.splash";

    /**
     * Creates a new AboutDialog.
     */
    public AboutDialog() {
        buildGUI();
    }

    /**
     * Creates a new AboutDialog with a given owner.
     */
    public AboutDialog(Frame owner) {
        super(owner);
        buildGUI();

        addKeyListener(new KeyAdapter(){
                public void keyPressed(KeyEvent e){
                    if(e.getKeyCode() == KeyEvent.VK_ESCAPE){
                        setVisible(false);
                        dispose();
                    }
                }
            });

        addMouseListener(new MouseAdapter(){
                public void mousePressed(MouseEvent e){
                    setVisible(false);
                    dispose();
                }
            });
    }

    public void setLocationRelativeTo(Frame f) {
        Dimension invokerSize = f.getSize();
        Point loc = f.getLocation();
        Point invokerScreenLocation = new Point(loc.x, loc.y);

        Rectangle bounds = getBounds();
        int  dx = invokerScreenLocation.x+((invokerSize.width-bounds.width)/2);
        int  dy = invokerScreenLocation.y+((invokerSize.height - bounds.height)/2);
        Dimension screenSize = getToolkit().getScreenSize();

        if (dy+bounds.height>screenSize.height) {
            dy = screenSize.height-bounds.height;
            dx = invokerScreenLocation.x<(screenSize.width>>1) ? invokerScreenLocation.x+invokerSize.width :
                invokerScreenLocation.x-bounds.width;
        }
        if (dx+bounds.width>screenSize.width) {
            dx = screenSize.width-bounds.width;
        }

        if (dx<0) dx = 0;
        if (dy<0) dy = 0;
        setLocation(dx, dy);
    }

    /**
     * Populates this window.
     */
    protected void buildGUI() {
        getContentPane().setBackground(Color.white);

        ClassLoader cl = this.getClass().getClassLoader();
        URL url = cl.getResource(Resources.getString(ICON_BATIK_SPLASH));
        ImageIcon icon = new ImageIcon(url);
        int w = icon.getIconWidth();
        int h = icon.getIconHeight();

        JLayeredPane p = new JLayeredPane();
        p.setSize(600, 425);
        getContentPane().add(p);

        JLabel l = new JLabel(icon);
        l.setBounds(0, 0, w, h);
        p.add(l, new Integer(0));

        JLabel l2 = new JLabel("Batik " + Version.getVersion());
        l2.setForeground(new Color(232, 232, 232, 255));
        l2.setOpaque(false);
        l2.setBackground(new Color(0, 0, 0, 0));
        l2.setHorizontalAlignment(JLabel.RIGHT);
        l2.setVerticalAlignment(JLabel.BOTTOM);
        l2.setBounds(w - 320, h - 117, 300, 100);
        p.add(l2, new Integer(2));

        ((JComponent)getContentPane()).setBorder
            (BorderFactory.createCompoundBorder
             (BorderFactory.createBevelBorder(BevelBorder.RAISED, Color.gray, Color.black),
              BorderFactory.createCompoundBorder
             (BorderFactory.createCompoundBorder
              (BorderFactory.createEmptyBorder(3, 3, 3, 3),
               BorderFactory.createLineBorder(Color.black)),
              BorderFactory.createEmptyBorder(10, 10, 10, 10))));
    }
}
