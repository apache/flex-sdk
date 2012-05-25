/*

   Copyright 2001-2004  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.apps.svgbrowser;

import java.awt.BorderLayout;
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
import javax.swing.JPanel;
import javax.swing.JTextArea;
import javax.swing.JWindow;
import javax.swing.SwingConstants;
import javax.swing.border.BevelBorder;

import org.apache.flex.forks.batik.Version;

/**
 * A dialog showing the revision of the Batik viewer as well
 * as the list of contributors.
 * The dialog can be dismissed by click or by escaping.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: AboutDialog.java,v 1.14 2004/08/18 07:12:26 vhardy Exp $
 */
public class AboutDialog extends JWindow {

    public static final String ICON_BATIK_SPLASH 
        = "AboutDialog.icon.batik.splash";

    public static final String ICON_APACHE_LOGO
        = "AboutDialog.icon.apache.logo";

    public static final String LABEL_APACHE_BATIK_PROJECT
        = "AboutDialog.label.apache.batik.project";

    public static final String LABEL_CONTRIBUTORS
        = "AboutDialog.label.contributors";

    /**
     * Default constructor
     */
    public AboutDialog(){
        super();
        buildGUI();
    }

    public AboutDialog(Frame owner){
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
     * Populates this window
     */
    protected void buildGUI(){
        JPanel panel = new JPanel(new BorderLayout(5, 5));
        panel.setBackground(Color.white);

        ClassLoader cl = this.getClass().getClassLoader();

        //
        // Top is made of the Apache feather, the 
        // name of the project and URL
        //
        URL url = cl.getResource(Resources.getString(ICON_APACHE_LOGO));
        JLabel l = new JLabel(Resources.getString(LABEL_APACHE_BATIK_PROJECT),
                              new ImageIcon(url),
                              SwingConstants.LEFT);
        panel.add(BorderLayout.NORTH, l);

        //
        // Add splash image
        //
        url = cl.getResource(Resources.getString(ICON_BATIK_SPLASH));
        panel.add(BorderLayout.CENTER, new JLabel(new ImageIcon(url)));

        //
        // Add exact revision information
        //
        String tagName = Version.getVersion();

        panel.add(BorderLayout.SOUTH, new JLabel(tagName, SwingConstants.RIGHT));

        setBackground(Color.white);
        getContentPane().setBackground(Color.white);

        JPanel p = new JPanel(new BorderLayout());
        p.setBackground(Color.white);
        p.add(panel, BorderLayout.CENTER);

        JTextArea contributors 
            = new JTextArea(Resources.getString(LABEL_CONTRIBUTORS)){ 
                    {setLineWrap(true); setWrapStyleWord(true); setEnabled(false); setRows(11); }
                };

        contributors.setBorder(BorderFactory.createEmptyBorder(5, 10, 5, 10));

        p.add(contributors,
              BorderLayout.SOUTH);
        ((JComponent)getContentPane()).setBorder
            (BorderFactory.createCompoundBorder
             (BorderFactory.createBevelBorder(BevelBorder.RAISED, Color.gray, Color.black),
              BorderFactory.createCompoundBorder
             (BorderFactory.createCompoundBorder
              (BorderFactory.createEmptyBorder(3, 3, 3, 3),
               BorderFactory.createLineBorder(Color.black)),
              BorderFactory.createEmptyBorder(10, 10, 10, 10))));
        
        getContentPane().add(p);
        pack();
    }
}
