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

import java.awt.BorderLayout;
import java.awt.Component;
import java.awt.FlowLayout;
import java.awt.LayoutManager;
import java.awt.event.ActionEvent;
import java.util.Locale;
import java.util.ResourceBundle;

import javax.swing.AbstractAction;
import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JOptionPane;
import javax.swing.JPanel;

import org.apache.flex.forks.batik.util.resources.ResourceManager;

/**
 * This class represents a panel to present users with options.
 *
 * @author <a href="mailto:deweese@apache.org">Thomas DeWeese</a>
 * @version $Id: OptionPanel.java 592619 2007-11-07 05:47:24Z cam $
 */
public class OptionPanel extends JPanel {

    /**
     * The gui resources file name
     */
    public static final String RESOURCES =
        "org.apache.flex.forks.batik.apps.svgbrowser.resources.GUI";

    /**
     * The resource bundle
     */
    protected static ResourceBundle bundle;

    /**
     * The resource manager
     */
    protected static ResourceManager resources;

    static {
        bundle = ResourceBundle.getBundle(RESOURCES, Locale.getDefault());
        resources = new ResourceManager(bundle);
    }

    /**
     * Creates a new panel.
     */
    public OptionPanel(LayoutManager layout) {
        super(layout);
    }

    /**
     * This class is modal dialog to choose the jpeg encoding quality.
     */
    public static class Dialog extends JDialog {

        /**
         * The 'ok' button.
         */
        protected JButton ok;

        /**
         * The 'ok' button.
         */
        protected JPanel panel;

        public Dialog(Component parent, String title, JPanel panel) {
            super(JOptionPane.getFrameForComponent(parent), title);
            setModal(true);
            this.panel = panel;
            getContentPane().add(panel, BorderLayout.CENTER);
            getContentPane().add(createButtonPanel(), BorderLayout.SOUTH);
        }

        /**
         * Creates the button panel.
         */
        protected JPanel createButtonPanel() {
            JPanel panel = new JPanel(new FlowLayout());
            ok = new JButton(resources.getString("OKButton.text"));
            ok.addActionListener(new OKButtonAction());
            panel.add(ok);
            return panel;
        }

        /**
         * The action associated to the 'ok' button.
         */
        protected class OKButtonAction extends AbstractAction {

            public void actionPerformed(ActionEvent evt) {
                dispose();
            }
        }
    }
}

