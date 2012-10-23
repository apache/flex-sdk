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

import java.awt.Component;
import java.awt.Dimension;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.util.Hashtable;

import javax.swing.BorderFactory;
import javax.swing.JLabel;
import javax.swing.JSlider;

import org.apache.flex.forks.batik.util.gui.ExtendedGridBagConstraints;

/**
 * This class represents a panel to control jpeg encoding quality.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: JPEGOptionPanel.java 475685 2006-11-16 11:16:05Z cam $
 */
public class JPEGOptionPanel extends OptionPanel {
    /**
     * The jpeg encoding quality.
     */
    protected JSlider quality;

    /**
     * Creates a new panel.
     */
    public JPEGOptionPanel() {
        super(new GridBagLayout());

        ExtendedGridBagConstraints constraints = 
            new ExtendedGridBagConstraints();

        
        constraints.insets = new Insets(5, 5, 5, 5);

        constraints.weightx = 0;
        constraints.weighty = 0;
        constraints.fill = GridBagConstraints.NONE;
        constraints.setGridBounds(0, 0, 1, 1);
        add(new JLabel(resources.getString("JPEGOptionPanel.label")), 
            constraints);

        quality = new JSlider();
        quality.setMinimum(0);
        quality.setMaximum(100);
        quality.setMajorTickSpacing(10);
        quality.setMinorTickSpacing(5);
        quality.setPaintTicks(true);
        quality.setPaintLabels(true);
        quality.setBorder(BorderFactory.createEmptyBorder(0,0,10,0));
        Hashtable labels = new Hashtable();
        for (int i=0; i < 100; i+=10) {
            labels.put(new Integer(i), new JLabel("0."+i/10));
        }
        labels.put(new Integer(100), new JLabel("1"));
        quality.setLabelTable(labels);

        Dimension dim = quality.getPreferredSize();
        quality.setPreferredSize(new Dimension(350, dim.height));

        constraints.weightx = 1.0;
        constraints.fill = GridBagConstraints.HORIZONTAL;
        constraints.setGridBounds(1, 0, 1, 1);
        add(quality, constraints);
    }

    /**
     * Returns the jpeg quality.
     */
    public float getQuality() {
        return quality.getValue()/100f;
    }

    /**
     * Shows a dialog to choose the jpeg encoding quality and return
     * the quality as a float.  
     */
    public static float showDialog(Component parent) {
        String title = resources.getString("JPEGOptionPanel.dialog.title");
        JPEGOptionPanel panel = new JPEGOptionPanel();
        Dialog dialog = new Dialog(parent, title, panel);
        dialog.pack();
        dialog.setVisible(true);
        return panel.getQuality();
    }
}
