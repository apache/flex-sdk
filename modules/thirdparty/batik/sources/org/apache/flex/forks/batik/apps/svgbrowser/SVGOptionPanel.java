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
import java.awt.BorderLayout;

import javax.swing.JLabel;
import javax.swing.JCheckBox;

/**
 * This class represents a panel to control svg encoding options.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: SVGOptionPanel.java 475685 2006-11-16 11:16:05Z cam $
 */
public class SVGOptionPanel extends OptionPanel {
    /**
     * The svg encoding options.
     */
    protected JCheckBox xmlbaseCB;
    protected JCheckBox prettyPrintCB;

    /**
     * Creates a new panel.
     */
    public SVGOptionPanel() {
        super(new BorderLayout());
        add(new JLabel(resources.getString("SVGOptionPanel.label")), 
            BorderLayout.NORTH);

        xmlbaseCB = new JCheckBox
            (resources.getString("SVGOptionPanel.UseXMLBase"));
        xmlbaseCB.setSelected
            (resources.getBoolean("SVGOptionPanel.UseXMLBaseDefault"));
        add(xmlbaseCB, BorderLayout.CENTER);
             
        prettyPrintCB = new JCheckBox
            (resources.getString("SVGOptionPanel.PrettyPrint"));
        prettyPrintCB.setSelected
            (resources.getBoolean("SVGOptionPanel.PrettyPrintDefault"));
        add(prettyPrintCB, BorderLayout.SOUTH);
    }

    /**
     * Returns true if the output should use xml:base.
     */
    public boolean getUseXMLBase() {
        return xmlbaseCB.isSelected();
    }

    /**
     * Returns true if the output should use xml:base.
     */
    public boolean getPrettyPrint() {
        return prettyPrintCB.isSelected();
    }

    /**
     * Shows a dialog to choose the jpeg encoding quality and return
     * the quality as a float.  
     */
    public static SVGOptionPanel showDialog(Component parent) {
        String title = resources.getString("SVGOptionPanel.dialog.title");
        SVGOptionPanel panel = new SVGOptionPanel();
        Dialog dialog = new Dialog(parent, title, panel);
        dialog.pack();
        dialog.setVisible(true);
        return panel;
    }
}
