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

package org.apache.flex.forks.batik.util.gui;

import java.awt.*;
import java.awt.event.ActionEvent;
import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.ResourceBundle;

import javax.swing.AbstractAction;
import javax.swing.Action;
import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JDialog;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;

import org.apache.flex.forks.batik.util.gui.resource.ActionMap;
import org.apache.flex.forks.batik.util.gui.resource.ButtonFactory;
import org.apache.flex.forks.batik.util.gui.resource.MissingListenerException;
import org.apache.flex.forks.batik.util.resources.ResourceManager;

/**
 * This class represents a dialog to select the user style sheet.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: UserStyleDialog.java 592619 2007-11-07 05:47:24Z cam $
 */
public class UserStyleDialog extends JDialog implements ActionMap {

    /**
     * The return value if 'OK' is chosen.
     */
    public static final int OK_OPTION = 0;

    /**
     * The return value if 'Cancel' is chosen.
     */
    public static final int CANCEL_OPTION = 1;

    /**
     * The resource file name
     */
    protected static final String RESOURCES =
        "org.apache.flex.forks.batik.util.gui.resources.UserStyleDialog";

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
     * The main panel.
     */
    protected Panel panel;

    /**
     * The chosen path.
     */
    protected String chosenPath;

    /**
     * The last return code.
     */
    protected int returnCode;

    /**
     * Creates a new user style dialog.
     */
    public UserStyleDialog(JFrame f) {
        super(f);
        setModal(true);
        setTitle(resources.getString("Dialog.title"));

        listeners.put("OKButtonAction",        new OKButtonAction());
        listeners.put("CancelButtonAction",    new CancelButtonAction());

        getContentPane().add(panel = new Panel());
        getContentPane().add( createButtonsPanel(), BorderLayout.SOUTH );
        pack();
    }

    /**
     * Shows the dialog.
     * @return OK_OPTION or CANCEL_OPTION.
     */
    public int showDialog() {
        pack();
        setVisible(true);
        return returnCode;
    }

    /**
     * Returns the chosen path or null.
     */
    public String getPath() {
        return chosenPath;
    }

    /**
     * Sets the current dialog path.
     */
    public void setPath(String s) {
        chosenPath = s;
        panel.fileTextField.setText(s);
        panel.fileCheckBox.setSelected(true);
    }

    /**
     * Creates the OK/Cancel buttons panel
     */
    protected JPanel createButtonsPanel() {
        JPanel  p = new JPanel(new FlowLayout(FlowLayout.RIGHT));
        ButtonFactory bf = new ButtonFactory(bundle, this);
        p.add(bf.createJButton("OKButton"));
        p.add(bf.createJButton("CancelButton"));

        return p;
    }

    /**
     * The action associated with the 'OK' button
     */
    protected class OKButtonAction extends AbstractAction {
        public void actionPerformed(ActionEvent e) {
            if (panel.fileCheckBox.isSelected()) {
                String path = panel.fileTextField.getText();
                if (path.equals("")) {
                    JOptionPane.showMessageDialog
                        (UserStyleDialog.this,
                         resources.getString("StyleDialogError.text"),
                         resources.getString("StyleDialogError.title"),
                         JOptionPane.ERROR_MESSAGE);
                    return;
                } else {
                    File f = new File(path);
                    if (f.exists()) {
                        if (f.isDirectory()) {
                            path = null;
                        } else {
                            path = "file:" + path;
                        }
                    }
                    chosenPath = path;
                }
            } else {
                chosenPath = null;
            }
            returnCode = OK_OPTION;
            dispose();
        }
    }

    /**
     * The action associated with the 'Cancel' button
     */
    protected class CancelButtonAction extends AbstractAction {
        public void actionPerformed(ActionEvent e) {
            returnCode = CANCEL_OPTION;
            dispose();
        }
    }

    /**
     * The map that contains the listeners
     */
    protected Map listeners = new HashMap();

    /**
     * Returns the action associated with the given string
     * or null on error
     * @param key the key mapped with the action to get
     * @throws MissingListenerException if the action is not found
     */
    public Action getAction(String key) throws MissingListenerException {
        return (Action)listeners.get(key);
    }

    /**
     * This class represents the main panel of the dialog.
     */
    public static class Panel extends JPanel {
        /**
         * The file check box
         */
        protected JCheckBox fileCheckBox;

        /**
         * The file label
         */
        protected JLabel fileLabel;

        /**
         * The file text field
         */
        protected JTextField fileTextField;

        /**
         * The browse button
         */
        protected JButton browseButton;

        /**
         * Creates a new Panel object.
         */
        public Panel() {
            super(new GridBagLayout());
            setBorder(BorderFactory.createTitledBorder
                      (BorderFactory.createEtchedBorder(),
                       resources.getString("Panel.title")));

            ExtendedGridBagConstraints constraints =
                new ExtendedGridBagConstraints();
            constraints.insets = new Insets(5, 5, 5, 5);

            fileCheckBox =
                new JCheckBox(resources.getString("PanelFileCheckBox.text"));
            fileCheckBox.addChangeListener(new FileCheckBoxChangeListener());
            constraints.weightx = 0;
            constraints.weighty = 0;
            constraints.fill = GridBagConstraints.HORIZONTAL;
            constraints.setGridBounds(0, 2, 3, 1);
            this.add(fileCheckBox, constraints);

            fileLabel = new JLabel(resources.getString("PanelFileLabel.text"));
            constraints.weightx = 0;
            constraints.weighty = 0;
            constraints.fill = GridBagConstraints.HORIZONTAL;
            constraints.setGridBounds(0, 3, 3, 1);
            this.add(fileLabel, constraints);

            fileTextField = new JTextField(30);
            constraints.weightx = 1.0;
            constraints.weighty = 0;
            constraints.fill = GridBagConstraints.HORIZONTAL;
            constraints.setGridBounds(0, 4, 2, 1);
            this.add(fileTextField, constraints);

            ButtonFactory bf = new ButtonFactory(bundle, null);
            constraints.weightx = 0;
            constraints.weighty = 0;
            constraints.fill = GridBagConstraints.NONE;
            constraints.anchor = GridBagConstraints.EAST;
            constraints.setGridBounds(2, 4, 1, 1);
            browseButton = bf.createJButton("PanelFileBrowseButton");
            this.add(browseButton, constraints);
            browseButton.addActionListener(new FileBrowseButtonAction());

            fileLabel.setEnabled(false);
            fileTextField.setEnabled(false);
            browseButton.setEnabled(false);
        }

        /**
         * Returns the chosen path or null.
         */
        public String getPath() {
            if(fileCheckBox.isSelected()){
                return fileTextField.getText();
            }
            else{
                return null;
            }
        }

        /**
         * Sets the current dialog path.
         */
        public void setPath(String s) {
            if(s == null){
                fileTextField.setEnabled(false);
                fileCheckBox.setSelected(false);
            }
            else{
                fileTextField.setEnabled(true);
                fileTextField.setText(s);
                fileCheckBox.setSelected(true);
            }
        }

        /**
         * To listen to the file checkbox
         */
        protected class FileCheckBoxChangeListener implements ChangeListener {
            public void stateChanged(ChangeEvent e) {
                boolean selected = fileCheckBox.isSelected();
                fileLabel.setEnabled(selected);
                fileTextField.setEnabled(selected);
                browseButton.setEnabled(selected);
            }
        }

        /**
         * The action associated with the 'browse' button
         */
        protected class FileBrowseButtonAction extends AbstractAction {
            public void actionPerformed(ActionEvent e) {
                JFileChooser fileChooser = new JFileChooser(new File("."));
                fileChooser.setFileHidingEnabled(false);

                int choice = fileChooser.showOpenDialog(Panel.this);
                if (choice == JFileChooser.APPROVE_OPTION) {
                    File f = fileChooser.getSelectedFile();
                    try {
                        fileTextField.setText(f.getCanonicalPath());
                    } catch (IOException ex) {
                    }
                }
            }
        }
    }
}
