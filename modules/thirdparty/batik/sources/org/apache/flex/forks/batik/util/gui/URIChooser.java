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
import javax.swing.JDialog;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.event.DocumentEvent;
import javax.swing.event.DocumentListener;
import javax.swing.filechooser.FileFilter;

import org.apache.flex.forks.batik.util.gui.resource.ActionMap;
import org.apache.flex.forks.batik.util.gui.resource.ButtonFactory;
import org.apache.flex.forks.batik.util.gui.resource.MissingListenerException;
import org.apache.flex.forks.batik.util.resources.ResourceManager;

/**
 * This class is a dialog used to enter an URI or to choose a local file.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: URIChooser.java 592619 2007-11-07 05:47:24Z cam $
 */
public class URIChooser extends JDialog implements ActionMap {

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
        "org.apache.flex.forks.batik.util.gui.resources.URIChooserMessages";

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
     * The button factory
     */
    protected ButtonFactory buttonFactory;

    /**
     * The text field
     */
    protected JTextField textField;

    /**
     * The OK button
     */
    protected JButton okButton;

    /**
     * The Clear button
     */
    protected JButton clearButton;

    /**
     * The current path.
     */
    protected String currentPath = ".";

    /**
     * The file filter.
     */
    protected FileFilter fileFilter;

    /**
     * The last return code.
     */
    protected int returnCode;

    /**
     * The last chosen path.
     */
    protected String chosenPath;

    /**
     * Creates a new URIChooser.
     * @param d the parent dialog
     */
    public URIChooser(JDialog d) {
        super(d);
        initialize();
    }

    /**
     * Creates a new URIChooser.
     * @param f the parent frame
     */
    public URIChooser(JFrame f) {
        super(f);
        initialize();
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
     * Returns the text entered by the user.
     */
    public String getText() {
        return chosenPath;
    }

    /**
     * Sets the file filter to use with the file selector.
     */
    public void setFileFilter(FileFilter ff) {
        fileFilter = ff;
    }

    /**
     * Initializes the dialog
     */
    protected void initialize() {
        setModal(true);

        listeners.put("BrowseButtonAction", new BrowseButtonAction());
        listeners.put("OKButtonAction",     new OKButtonAction());
        listeners.put("CancelButtonAction", new CancelButtonAction());
        listeners.put("ClearButtonAction",  new ClearButtonAction());

        setTitle(resources.getString("Dialog.title"));
        buttonFactory = new ButtonFactory(bundle, this);

        getContentPane().add( createURISelectionPanel(), BorderLayout.NORTH );
        getContentPane().add( createButtonsPanel(),      BorderLayout.SOUTH );
    }

    /**
     * Creates the URI selection panel
     */
    protected JPanel createURISelectionPanel() {
        JPanel p = new JPanel(new GridBagLayout());
        p.setBorder(BorderFactory.createEmptyBorder(5, 5, 5, 5));

        ExtendedGridBagConstraints constraints;
        constraints = new ExtendedGridBagConstraints();

        constraints.insets = new Insets(5, 5, 5, 5);
        constraints.weightx = 0;
        constraints.weighty = 0;
        constraints.fill = GridBagConstraints.HORIZONTAL;
        constraints.setGridBounds(0, 0, 2, 1);
        p.add(new JLabel(resources.getString("Dialog.label")), constraints);

        textField = new JTextField(30);
        textField.getDocument().addDocumentListener(new DocumentAdapter());
        constraints.weightx = 1.0;
        constraints.weighty = 0;
        constraints.fill = GridBagConstraints.HORIZONTAL;
        constraints.setGridBounds(0, 1, 1, 1);
        p.add(textField, constraints);

        constraints.weightx = 0;
        constraints.weighty = 0;
        constraints.fill = GridBagConstraints.NONE;
        constraints.setGridBounds(1, 1, 1, 1);
        p.add(buttonFactory.createJButton("BrowseButton"), constraints);

        return p;
    }

    /**
     * Creates the buttons panel
     */
    protected JPanel createButtonsPanel() {
        JPanel  p = new JPanel(new FlowLayout());

        p.add(okButton = buttonFactory.createJButton("OKButton"));
        p.add(buttonFactory.createJButton("CancelButton"));
        p.add(clearButton = buttonFactory.createJButton("ClearButton"));

        okButton.setEnabled(false);
        clearButton.setEnabled(false);

        return p;
    }

    /**
     * To update the state of the OK button
     */
    protected void updateOKButtonAction() {
        okButton.setEnabled(!textField.getText().equals(""));
    }

    /**
     * To update the state of the Clear button
     */
    protected void updateClearButtonAction() {
        clearButton.setEnabled(!textField.getText().equals(""));
    }

    /**
     * To listen to the document changes
     */
    protected class DocumentAdapter implements DocumentListener {
        public void changedUpdate(DocumentEvent e) {
            updateOKButtonAction();
            updateClearButtonAction();
        }

        public void insertUpdate(DocumentEvent e) {
            updateOKButtonAction();
            updateClearButtonAction();
        }

        public void removeUpdate(DocumentEvent e) {
            updateOKButtonAction();
            updateClearButtonAction();
        }
    }

    /**
     * The action associated with the 'browse' button
     */
    protected class BrowseButtonAction extends AbstractAction {
        public void actionPerformed(ActionEvent e) {
            JFileChooser fileChooser = new JFileChooser(currentPath);
            fileChooser.setFileHidingEnabled(false);
            fileChooser.setFileSelectionMode
                (JFileChooser.FILES_AND_DIRECTORIES);
            if (fileFilter != null) {
                fileChooser.setFileFilter(fileFilter);
            }

            int choice = fileChooser.showOpenDialog(URIChooser.this);
            if (choice == JFileChooser.APPROVE_OPTION) {
                File f = fileChooser.getSelectedFile();
                try {
                    textField.setText(currentPath = f.getCanonicalPath());
                } catch (IOException ex) {
                }
            }
        }
    }

    /**
     * The action associated with the 'OK' button of the URI chooser
     */
    protected class OKButtonAction extends AbstractAction {
        public void actionPerformed(ActionEvent e) {
            returnCode = OK_OPTION;
            chosenPath = textField.getText();
            dispose();
        }
    }

    /**
     * The action associated with the 'Cancel' button of the URI chooser
     */
    protected class CancelButtonAction extends AbstractAction {
        public void actionPerformed(ActionEvent e) {
            returnCode = CANCEL_OPTION;
            dispose();
            textField.setText(chosenPath);
        }
    }

    /**
     * The action associated with the 'Clear' button of the URI chooser
     */
    protected class ClearButtonAction extends AbstractAction {
        public void actionPerformed(ActionEvent e) {
            textField.setText("");
        }
    }

    // ActionMap implementation

    /**
     * The map that contains the listeners
     */
    protected Map listeners = new HashMap(10);

    /**
     * Returns the action associated with the given string
     * or null on error
     * @param key the key mapped with the action to get
     * @throws MissingListenerException if the action is not found
     */
    public Action getAction(String key) throws MissingListenerException {
        return (Action)listeners.get(key);
    }
}
