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
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;

import javax.swing.JCheckBox;
import javax.swing.JLabel;

import org.apache.flex.forks.batik.util.gui.ExtendedGridBagConstraints;

/**
 * This class represents a panel to choose the color model
 * of the PNG, i.e. RGB or INDEXED.
 *
 * @author <a href="mailto:jun@oop-reserch.com">Jun Inamori</a>
 * @version $Id: PNGOptionPanel.java 498740 2007-01-22 18:35:57Z dvholten $
 */
public class PNGOptionPanel extends OptionPanel {

    /**
     * The check box for outputing an indexed PNG.
     */
    protected JCheckBox check;

    /**
     * Creates a new panel.
     */
    public PNGOptionPanel() {
        super(new GridBagLayout());

        ExtendedGridBagConstraints constraints =
            new ExtendedGridBagConstraints();


        constraints.insets = new Insets(5, 5, 5, 5);

        constraints.weightx = 0;
        constraints.weighty = 0;
        constraints.fill = GridBagConstraints.NONE;
        constraints.setGridBounds(0, 0, 1, 1);
        add(new JLabel(resources.getString("PNGOptionPanel.label")),
            constraints);

        check=new JCheckBox();

        constraints.weightx = 1.0;
        constraints.fill = GridBagConstraints.HORIZONTAL;
        constraints.setGridBounds(1, 0, 1, 1);
        add(check, constraints);
    }

    /**
     * Returns if indexed or not
     */
    public boolean isIndexed() {
        return check.isSelected();
    }

    /**
     * Shows a dialog to choose the indexed PNG.
     */
    public static boolean showDialog(Component parent) {
        String title = resources.getString("PNGOptionPanel.dialog.title");
        PNGOptionPanel panel = new PNGOptionPanel();
        Dialog dialog = new Dialog(parent, title, panel);
        dialog.pack();
        dialog.setVisible(true);
        return panel.isIndexed();
    }
}
