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

import java.awt.BorderLayout;
import java.awt.Component;
import java.awt.FlowLayout;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.ResourceBundle;
import java.util.StringTokenizer;

import javax.swing.AbstractAction;
import javax.swing.Action;
import javax.swing.BorderFactory;
import javax.swing.DefaultListModel;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JDialog;
import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.ListSelectionModel;
import javax.swing.event.ListDataEvent;
import javax.swing.event.ListDataListener;
import javax.swing.event.ListSelectionEvent;
import javax.swing.event.ListSelectionListener;

import org.apache.flex.forks.batik.util.gui.resource.ActionMap;
import org.apache.flex.forks.batik.util.gui.resource.ButtonFactory;
import org.apache.flex.forks.batik.util.gui.resource.MissingListenerException;
import org.apache.flex.forks.batik.util.resources.ResourceManager;

/**
 * This class represents a panel to edit/add/remove CSS media.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: CSSMediaPanel.java 592619 2007-11-07 05:47:24Z cam $
 */
public class CSSMediaPanel extends JPanel implements ActionMap {

    /**
     * The resource file name
     */
    protected static final String RESOURCES =
        "org.apache.flex.forks.batik.util.gui.resources.CSSMediaPanel";

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
     * The button to remove a CSS medium from the list.
     */
    protected JButton removeButton;

    /**
     * The button to add a CSS medium from the list.
     */
    protected JButton addButton;

    /**
     * The button to clear the CSS media list.
     */
    protected JButton clearButton;

    /**
     * The list that represents the CSS media.
     */
    protected DefaultListModel listModel = new DefaultListModel();

    /**
     * The list that represents the CSS media.
     */
    protected JList mediaList;

    /**
     * Constructs a new panel to edit CSS media.
     */
    public CSSMediaPanel() {
        super(new GridBagLayout());

        listeners.put("AddButtonAction", new AddButtonAction());
        listeners.put("RemoveButtonAction", new RemoveButtonAction());
        listeners.put("ClearButtonAction", new ClearButtonAction());

        setBorder(BorderFactory.createTitledBorder
                  (BorderFactory.createEtchedBorder(),
                   resources.getString("Panel.title")));

        ExtendedGridBagConstraints constraints =
            new ExtendedGridBagConstraints();

        constraints.insets = new Insets(5, 5, 5, 5);

        mediaList = new JList();
        mediaList.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        mediaList.setModel(listModel);
        mediaList.addListSelectionListener(new MediaListSelectionListener());
        listModel.addListDataListener(new MediaListDataListener());

        JScrollPane scrollPane = new JScrollPane();
        scrollPane.setBorder(BorderFactory.createLoweredBevelBorder());
        constraints.weightx = 1.0;
        constraints.weighty = 1.0;
        constraints.fill = GridBagConstraints.BOTH;
        constraints.setGridBounds(0, 0, 1, 3);
        scrollPane.getViewport().add(mediaList);
        add(scrollPane, constraints);

        ButtonFactory bf = new ButtonFactory(bundle, this);
        constraints.weightx = 0;
        constraints.weighty = 0;
        constraints.fill = GridBagConstraints.HORIZONTAL;
        constraints.anchor = GridBagConstraints.NORTH;

        addButton = bf.createJButton("AddButton");
        constraints.setGridBounds(1, 0, 1, 1);
        add(addButton, constraints);

        removeButton = bf.createJButton("RemoveButton");
        constraints.setGridBounds(1, 1, 1, 1);
        add(removeButton, constraints);

        clearButton = bf.createJButton("ClearButton");
        constraints.setGridBounds(1, 2, 1, 1);
        add(clearButton, constraints);

        updateButtons();
    }

    /**
     * Updates the button states.
     */
    protected void updateButtons() {
        removeButton.setEnabled(!mediaList.isSelectionEmpty());
        clearButton.setEnabled(!listModel.isEmpty());
    }

    /**
     * Sets the list of media to edit.
     *
     * @param mediaList the list of media to edit
     */
    public void setMedia(List mediaList) {
        listModel.removeAllElements();
        Iterator iter = mediaList.iterator();
        while (iter.hasNext()) {
            listModel.addElement(iter.next());
        }
    }

    /**
     * Sets the list of media to edit to the specified media list (separated by
     * space).
     *
     * @param media the media separated by space
     */
    public void setMedia(String media) {
        listModel.removeAllElements();
        StringTokenizer tokens = new StringTokenizer(media, " ");
        while (tokens.hasMoreTokens()) {
            listModel.addElement(tokens.nextToken());
        }
    }

    /**
     * Returns the list of media.
     */
    public List getMedia() {
        List media = new ArrayList(listModel.size());
        Enumeration e = listModel.elements();
        while (e.hasMoreElements()) {
            media.add(e.nextElement());
        }
        return media;
    }

    /**
     * Returns the media list as a string separated by space.
     */
    public String getMediaAsString() {
        StringBuffer buffer = new StringBuffer();
        Enumeration e = listModel.elements();
        while (e.hasMoreElements()) {
            buffer.append((String)e.nextElement());
            buffer.append( ' ' );
        }
        return buffer.toString();
    }

    /**
     * Brings up a modal dialog to edit/add/remove CSS media.
     *
     * @param parent the parent of this dialog
     * @param title the title of this dialog
     */
    public static int showDialog(Component parent, String title) {
        return showDialog(parent, title, "");
    }

    /**
     * Brings up a modal dialog to edit/add/remove CSS media.
     *
     * @param parent the parent of this dialog
     * @param title the title of this dialog
     * @param mediaList the list of media
     */
    public static int showDialog(Component parent,
                                 String title,
                                 List mediaList) {
        Dialog dialog = new Dialog(parent, title, mediaList);
        dialog.setModal(true);
        dialog.pack();
        dialog.setVisible(true);
        return dialog.getReturnCode();
    }

    /**
     * Brings up a modal dialog to edit/add/remove CSS media.
     *
     * @param parent the parent of this dialog
     * @param title the title of this dialog
     * @param media the list of media
     */
    public static int showDialog(Component parent,
                                 String title,
                                 String media) {
        Dialog dialog = new Dialog(parent, title, media);
        dialog.setModal(true);
        dialog.pack();
        dialog.setVisible(true);
        return dialog.getReturnCode();
    }

    /**
     * The map that contains the listeners
     */
    protected Map listeners = new HashMap();

    /**
     * Returns the action associated with the given string or null on error
     *
     * @param key the key mapped with the action to get
     * @throws MissingListenerException if the action is not found
     */
    public Action getAction(String key) throws MissingListenerException {
        return (Action)listeners.get(key);
    }

    /**
     * The action associated with the 'Add' button
     */
    protected class AddButtonAction extends AbstractAction {
        public void actionPerformed(ActionEvent e) {
            AddMediumDialog dialog = new AddMediumDialog(CSSMediaPanel.this);
            dialog.pack();
            dialog.setVisible(true);

            if ((dialog.getReturnCode() == AddMediumDialog.CANCEL_OPTION) ||
                (dialog.getMedium() == null)) {
                return;
            }

            String medium = dialog.getMedium().trim();
            if (medium.length() == 0 || listModel.contains(medium)) {
                return;
            }

            for (int i = 0; i < listModel.size() && medium != null; ++i) {
                String s = (String)listModel.getElementAt(i);
                int c = medium.compareTo(s);
                if (c == 0) {
                    medium = null;
                } else if (c < 0) {
                    listModel.insertElementAt(medium, i);
                    medium = null;
                }
            }
            if (medium != null) {
                listModel.addElement(medium);
            }
        }
    }

    /**
     * The action associated with the 'Remove' button
     */
    protected class RemoveButtonAction extends AbstractAction {
        public void actionPerformed(ActionEvent e) {
            int index = mediaList.getSelectedIndex();
            mediaList.clearSelection();
            if (index >= 0) {
                listModel.removeElementAt(index);
            }
        }
    }

    /**
     * The action associated with the 'Clear' button
     */
    protected class ClearButtonAction extends AbstractAction {
        public void actionPerformed(ActionEvent e) {
            mediaList.clearSelection();
            listModel.removeAllElements();
        }
    }

    /**
     * To manage selection modifications
     */
    protected class MediaListSelectionListener
        implements ListSelectionListener {

        public void valueChanged(ListSelectionEvent e) {
            updateButtons();
        }
    }

    /**
     * To manage data modifications in the media list.
     */
    protected class MediaListDataListener implements ListDataListener {

        public void contentsChanged(ListDataEvent e) {
            updateButtons();
        }

        public void intervalAdded(ListDataEvent e) {
            updateButtons();
        }

        public void intervalRemoved(ListDataEvent e) {
            updateButtons();
        }
    }

    ///////////////////////////////////////////////////////////////////////////

    /**
     * A dialog to add a new CSS medium.
     */
    public static class AddMediumDialog extends JDialog implements ActionMap {

        /**
         * The return value if 'OK' is chosen.
         */
        public static final int OK_OPTION = 0;

        /**
         * The return value if 'Cancel' is chosen.
         */
        public static final int CANCEL_OPTION = 1;

        /**
         * The new medium.
         */
        protected JComboBox medium;

        /**
         * The return code.
         */
        protected int returnCode;

        /**
         * Constructs a new AddMediumDialog.
         *
         * @param parent the parent of this dialog
         */
        public AddMediumDialog(Component parent) {
            super(JOptionPane.getFrameForComponent(parent),
                  resources.getString("AddMediumDialog.title"));
            setModal(true);

            listeners.put("OKButtonAction", new OKButtonAction());
            listeners.put("CancelButtonAction", new CancelButtonAction());

            getContentPane().add(createContentPanel(), BorderLayout.CENTER);
            getContentPane().add(createButtonsPanel(), BorderLayout.SOUTH);
        }

        /**
         * Returns the medium that might be added or null if any.
         */
        public String getMedium() {
            return (String)medium.getSelectedItem();
        }

        /**
         * Returns the panel to enter a new CSS medium.
         */
        protected Component createContentPanel() {
            JPanel panel = new JPanel(new BorderLayout());
            panel.setBorder(BorderFactory.createEmptyBorder(4, 4, 4, 4));
            panel.add(new JLabel(resources.getString("AddMediumDialog.label")),
                      BorderLayout.WEST);

            medium = new JComboBox();
            medium.setEditable(true);
            String media = resources.getString("Media.list");
            StringTokenizer tokens = new StringTokenizer(media, " ");
            while (tokens.hasMoreTokens()) {
                medium.addItem(tokens.nextToken());
            }
            panel.add(medium, BorderLayout.CENTER);
            return panel;
        }

        /**
         * Returns the button panel.
         */
        protected Component createButtonsPanel() {
            JPanel panel = new JPanel(new FlowLayout(FlowLayout.RIGHT));
            ButtonFactory bf = new ButtonFactory(bundle, this);
            panel.add(bf.createJButton("OKButton"));
            panel.add(bf.createJButton("CancelButton"));
            return panel;
        }

        /**
         * Returns the code that describes how the dialog has been closed (OK or
         * CANCEL).
         */
        public int getReturnCode() {
            return returnCode;
        }

        /**
         * The map that contains the listeners
         */
        protected Map listeners = new HashMap();

        /**
         * Returns the action associated with the given string or null on error
         *
         * @param key the key mapped with the action to get
         * @throws MissingListenerException if the action is not found
         */
        public Action getAction(String key) throws MissingListenerException {
            return (Action)listeners.get(key);
        }

        /**
         * The action associated with the 'OK' button
         */
        protected class OKButtonAction extends AbstractAction {
            public void actionPerformed(ActionEvent e) {
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
    }

    ///////////////////////////////////////////////////////////////////////////

    /**
     * A dialog to edit/add/remove CSS media.
     */
    public static class Dialog extends JDialog implements ActionMap {

        /**
         * The return value if 'OK' is chosen.
         */
        public static final int OK_OPTION = 0;

        /**
         * The return value if 'Cancel' is chosen.
         */
        public static final int CANCEL_OPTION = 1;

        /**
         * The return code.
         */
        protected int returnCode;

        /**
         * Constructs a new Dialog to edit/add/remove CSS media.
         */
        public Dialog() {
            this(null, "", "");
        }

        /**
         * Constructs a new Dialog to edit/add/remove CSS media.
         *
         * @param parent the parent of this dialog
         * @param title the title of this dialog
         * @param mediaList the media list
         */
        public Dialog(Component parent, String title, List mediaList) {
            super(JOptionPane.getFrameForComponent(parent), title);

            listeners.put("OKButtonAction", new OKButtonAction());
            listeners.put("CancelButtonAction", new CancelButtonAction());

            CSSMediaPanel panel = new CSSMediaPanel();
            panel.setMedia(mediaList);
            getContentPane().add(panel, BorderLayout.CENTER);
            getContentPane().add(createButtonsPanel(), BorderLayout.SOUTH);
        }

        /**
         * Constructs a new Dialog to edit/add/remove CSS media.
         *
         * @param parent the parent of this dialog
         * @param title the title of this dialog
         * @param media the media list
         */
        public Dialog(Component parent, String title, String media) {
            super(JOptionPane.getFrameForComponent(parent), title);

            listeners.put("OKButtonAction", new OKButtonAction());
            listeners.put("CancelButtonAction", new CancelButtonAction());

            CSSMediaPanel panel = new CSSMediaPanel();
            panel.setMedia(media);
            getContentPane().add(panel, BorderLayout.CENTER);
            getContentPane().add(createButtonsPanel(), BorderLayout.SOUTH);
        }

        /**
         * Returns the code that describes how the dialog has been closed (OK or
         * CANCEL).
         */
        public int getReturnCode() {
            return returnCode;
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
         * The map that contains the listeners
         */
        protected Map listeners = new HashMap();

        /**
         * Returns the action associated with the given string or null on error
         *
         * @param key the key mapped with the action to get
         * @throws MissingListenerException if the action is not found
         */
        public Action getAction(String key) throws MissingListenerException {
            return (Action)listeners.get(key);
        }

        /**
         * The action associated with the 'OK' button
         */
        protected class OKButtonAction extends AbstractAction {
            public void actionPerformed(ActionEvent e) {
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
    }

    /**
     * Main - debug -
     */
    public static void main(String [] args) {
        String media = "all aural braille embossed handheld print projection screen tty tv";
        int code = CSSMediaPanel.showDialog(null, "Test", media);
        System.out.println(code);
        System.exit(0);
    }
}
