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
import java.net.URL;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.MissingResourceException;
import java.util.ResourceBundle;
import java.util.StringTokenizer;

import javax.swing.AbstractAction;
import javax.swing.Action;
import javax.swing.BorderFactory;
import javax.swing.DefaultListModel;
import javax.swing.Icon;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.ListCellRenderer;
import javax.swing.ListSelectionModel;
import javax.swing.event.ListSelectionEvent;
import javax.swing.event.ListSelectionListener;

import org.apache.flex.forks.batik.util.gui.resource.ActionMap;
import org.apache.flex.forks.batik.util.gui.resource.ButtonFactory;
import org.apache.flex.forks.batik.util.gui.resource.MissingListenerException;
import org.apache.flex.forks.batik.util.resources.ResourceManager;

/**
 * This class represents a language selection dialog.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @author <a href="mailto:cjolif@ilog.fr">Christophe Jolif</a>
 * @version $Id: LanguageDialog.java 592619 2007-11-07 05:47:24Z cam $
 */
public class LanguageDialog extends JDialog implements ActionMap {

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
        "org.apache.flex.forks.batik.util.gui.resources.LanguageDialogMessages";

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
     * The map that contains the listeners
     */
    protected Map listeners = new HashMap();

    /**
     * The user languages panel.
     */
    protected Panel panel = new Panel();

    /**
     * The last return code.
     */
    protected int returnCode;

    /**
     * Creates a new LanguageDialog object.
     */
    public LanguageDialog(JFrame f) {
        super(f);
        setModal(true);
        setTitle(resources.getString("Dialog.title"));

        listeners.put("OKButtonAction",             new OKButtonAction());
        listeners.put("CancelButtonAction",         new CancelButtonAction());

        getContentPane().add(panel);
        getContentPane().add( createButtonsPanel(), BorderLayout.SOUTH );

        pack();
    }

    /**
     * Shows the dialog.
     * @return OK_CANCEL or CANCEL_OPTION.
     */
    public int showDialog() {
        setVisible(true);
        return returnCode;
    }

    /**
     * Sets the user languages.
     */
    public void setLanguages(String s) {
        panel.setLanguages(s);
    }

    /**
     * Returns the user languages.
     */
    public String getLanguages() {
        return panel.getLanguages();
    }

    // ActionMap implementation ///////////////////////////////////////

    /**
     * Returns the action associated with the given string
     * or null on error
     * @param key the key mapped with the action to get
     * @throws MissingListenerException if the action is not found   todo does it throw ?? seems to return null
     */
    public Action getAction(String key) throws MissingListenerException {
        return (Action)listeners.get(key);
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
     * The language selection panel.
     */
    public static class Panel extends JPanel implements ActionMap {
        /**
         * The user languages list
         */
        protected JList userList;

        /**
         * The languages list
         */
        protected JList languageList;

        /**
         * The user list model
         */
        protected DefaultListModel userListModel = new DefaultListModel();

        /**
         * The language list model
         */
        protected DefaultListModel languageListModel = new DefaultListModel();

        /**
         * The AddLanguageButton.
         */
        protected JButton addLanguageButton;

        /**
         * The RemoveLanguageButton.
         */
        protected JButton removeLanguageButton;

        /**
         * The UpLanguageButton.
         */
        protected JButton upLanguageButton;

        /**
         * The DownLanguageButton.
         */
        protected JButton downLanguageButton;

        /**
         * The ClearLanguageButton.
         */
        protected JButton clearLanguageButton;

        /**
         * The map that contains the listeners
         */
        protected Map listeners = new HashMap();

        /**
         * The cached map for country icons (takes more than 2 secs.
         * to be computed).
         */
        private static Map iconMap = null;

        /**
         * Creates a new Panel object.
         */
        public Panel() {
            super(new GridBagLayout());

            initCountryIcons();

            setBorder(BorderFactory.createTitledBorder
                      (BorderFactory.createEtchedBorder(),
                       resources.getString("Panel.title")));

            listeners.put("AddLanguageButtonAction",
                          new AddLanguageButtonAction());
            listeners.put("RemoveLanguageButtonAction",
                          new RemoveLanguageButtonAction());
            listeners.put("UpLanguageButtonAction",
                          new UpLanguageButtonAction());
            listeners.put("DownLanguageButtonAction",
                          new DownLanguageButtonAction());
            listeners.put("ClearLanguageButtonAction",
                          new ClearLanguageButtonAction());

            // Initalize the lists
            userList = new JList(userListModel);
            userList.setCellRenderer(new IconAndTextCellRenderer());

            languageList = new JList(languageListModel);
            languageList.setCellRenderer(new IconAndTextCellRenderer());

            StringTokenizer st;
            st = new StringTokenizer(resources.getString("Country.list"), " ");
            while (st.hasMoreTokens()) {
                languageListModel.addElement(st.nextToken());
            }

            // Layout out the children
            ExtendedGridBagConstraints constraints =
                new ExtendedGridBagConstraints();
            constraints.insets = new Insets(5, 5, 5, 5);

            constraints.weightx = 1.0;
            constraints.weighty = 1.0;
            constraints.fill = GridBagConstraints.BOTH;

            // The languages list
            constraints.setGridBounds(0, 0, 1, 1);
            JScrollPane sp = new JScrollPane();
            sp.setBorder(BorderFactory.createCompoundBorder
                         (BorderFactory.createTitledBorder
                          (BorderFactory.createEmptyBorder(),
                           resources.getString("Languages.title")),
                          BorderFactory.createLoweredBevelBorder()));
            sp.getViewport().add(languageList);
            this.add(sp, constraints);

            languageList.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
            languageList.addListSelectionListener
                (new LanguageListSelectionListener());

            // The user languages list
            constraints.setGridBounds(2, 0, 1, 1);

            JScrollPane sp2 = new JScrollPane();
            sp2.setBorder(BorderFactory.createCompoundBorder
                          (BorderFactory.createTitledBorder
                           (BorderFactory.createEmptyBorder(),
                            resources.getString("User.title")),
                           BorderFactory.createLoweredBevelBorder()));
            sp2.getViewport().add(userList);
            this.add(sp2, constraints);

            userList.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
            userList.addListSelectionListener(new UserListSelectionListener());

            // The info label
            constraints.setGridBounds(0, 1, 3, 1);
            constraints.weightx = 0;
            constraints.weighty = 0;
            this.add(new JLabel(resources.getString("InfoLabel.text")),
                     constraints);

            // The buttons
            ButtonFactory bf = new ButtonFactory(bundle, this);
            JPanel p = new JPanel(new GridLayout(5, 1, 0, 3));
            p.add(addLanguageButton = bf.createJButton("AddLanguageButton"));
            addLanguageButton.setEnabled(false);
            p.add(removeLanguageButton =
                  bf.createJButton("RemoveLanguageButton"));
            removeLanguageButton.setEnabled(false);
            p.add(upLanguageButton = bf.createJButton("UpLanguageButton"));
            upLanguageButton.setEnabled(false);
            p.add(downLanguageButton = bf.createJButton("DownLanguageButton"));
            downLanguageButton.setEnabled(false);
            p.add(clearLanguageButton =
                  bf.createJButton("ClearLanguageButton"));
            clearLanguageButton.setEnabled(false);

            JPanel t = new JPanel(new GridBagLayout());
            constraints.setGridBounds(1, 0, 1, 1);
            this.add(t, constraints);

            constraints.fill = GridBagConstraints.HORIZONTAL;
            constraints.setGridBounds(0, 0, 1, 1);
            constraints.insets = new Insets(0, 0, 0, 0);
            t.add(p, constraints);

            sp2.setPreferredSize(sp.getPreferredSize());
        }

        /**
         * Allows to pre-initialize icons used by the <code>Panel</code>
         * constructor. It is not neccessary to call it and it should
         * be called only once.
         * This method is safe to be called by another thread than the
         * event thread as it doesn't manipulate Swing <code>JComponent</code>
         * instances.
         */
        public static synchronized void initCountryIcons()
        {
            // don't need to init several times...
            if (iconMap == null) {
                iconMap = new HashMap();
                StringTokenizer st;
                st = new StringTokenizer(resources.getString("Country.list"),
                                         " ");
                while (st.hasMoreTokens()) {
                    computeCountryIcon(LanguageDialog.Panel.class,
                                       st.nextToken());
                }
            }
        }

        /**
         * Returns the selected user languages.
         */
        public String getLanguages() {
            StringBuffer result = new StringBuffer();
            if (userListModel.getSize() > 0) {
                result.append(userListModel.getElementAt(0));

                for (int i = 1; i < userListModel.getSize(); i++) {
                    result.append( ',' );
                    result.append( userListModel.getElementAt(i) );
                }
            }
            return result.toString();
        }

        /**
         * Sets the user languages.
         */
        public void setLanguages(String str) {
            int len = userListModel.getSize();
            for (int i = 0; i < len; i++) {
                Object o = userListModel.getElementAt(0);
                userListModel.removeElementAt(0);
                String userListModelStr = (String)o;

                int size = languageListModel.getSize();
                int n = 0;
                while (n < size) {
                    String s = (String)languageListModel.getElementAt(n);
                    if (userListModelStr.compareTo(s) > 0) {
                        break;
                    }
                    n++;
                }
                languageListModel.insertElementAt(o, n);
            }

            StringTokenizer st;
            st = new StringTokenizer(str, ",");
            while (st.hasMoreTokens()) {
                String s = st.nextToken();
                userListModel.addElement(s);
                languageListModel.removeElement(s);
            }

            updateButtons();
        }

        /**
         * Updates the state of the buttons
         */
        protected void updateButtons() {
            int size = userListModel.size();
            int i    = userList.getSelectedIndex();

            boolean empty        = size == 0;
            boolean selected     = i != -1;
            boolean zeroSelected = i == 0;
            boolean lastSelected = i == size - 1;

            removeLanguageButton.setEnabled(!empty && selected);
            upLanguageButton.setEnabled(!empty && selected && !zeroSelected);
            downLanguageButton.setEnabled(!empty && selected && !lastSelected);
            clearLanguageButton.setEnabled(!empty);

            size = languageListModel.size();
            i = languageList.getSelectedIndex();

            empty    = size == 0;
            selected = i != -1;

            addLanguageButton.setEnabled(!empty && selected);
        }

        /**
         * returns the full string associated with a country code.
         */
        protected String getCountryText(String code) {
            return resources.getString(code + ".text");
        }

        /**
         * returns the icon associated with a country code.
         */
        protected Icon getCountryIcon(String code) {
            return computeCountryIcon(getClass(), code);
        }

        private static Icon computeCountryIcon(Class ref,
                                               String code) {
            ImageIcon icon = null;
            try {
                if ((icon = (ImageIcon)iconMap.get(code)) != null)
                    return icon;
                String s = resources.getString(code + ".icon");
                URL url  = ref.getResource(s);
                if (url != null) {
                    iconMap.put(code, icon = new ImageIcon(url));
                    return icon;
                }
            } catch (MissingResourceException e) {
            }
            return new ImageIcon(ref.getResource("resources/blank.gif"));
        }

        // ActionMap implementation ///////////////////////////////////////

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
         * The action associated with the 'add' button
         */
        protected class AddLanguageButtonAction extends AbstractAction {
            public void actionPerformed(ActionEvent e) {
                int    i = languageList.getSelectedIndex();
                Object o = languageListModel.getElementAt(i);
                languageListModel.removeElementAt(i);
                userListModel.addElement(o);
                userList.setSelectedValue(o, true);
            }
        }

        /**
         * The action associated with the 'remove' button
         */
        protected class RemoveLanguageButtonAction extends AbstractAction {
            public void actionPerformed(ActionEvent e) {
                int i = userList.getSelectedIndex();
                Object o = userListModel.getElementAt(i);
                userListModel.removeElementAt(i);
                String userListModelStr = (String)o;
                int size = languageListModel.getSize();
                int n = 0;
                while (n < size) {
                    String s = (String)languageListModel.getElementAt(n);
                    if (userListModelStr.compareTo(s) > 0) {
                        break;
                    }
                    n++;
                }
                languageListModel.insertElementAt(o, n);
                languageList.setSelectedValue(o, true);
                updateButtons();
            }
        }

        /**
         * The action associated with the 'up' button
         */
        protected class UpLanguageButtonAction extends AbstractAction {
            public void actionPerformed(ActionEvent e) {
                int    i = userList.getSelectedIndex();
                Object o = userListModel.getElementAt(i);
                userListModel.removeElementAt(i);
                userListModel.insertElementAt(o, i - 1);
                userList.setSelectedIndex(i - 1);
            }
        }

        /**
         * The action associated with the 'down' button
         */
        protected class DownLanguageButtonAction extends AbstractAction {
            public void actionPerformed(ActionEvent e) {
                int    i = userList.getSelectedIndex();
                Object o = userListModel.getElementAt(i);
                userListModel.removeElementAt(i);
                userListModel.insertElementAt(o, i + 1);
                userList.setSelectedIndex(i + 1);
            }
        }

        /**
         * The action associated with the 'clear' button
         */
        protected class ClearLanguageButtonAction extends AbstractAction {
            public void actionPerformed(ActionEvent e) {
                int len = userListModel.getSize();
                for (int i = 0; i < len; i++) {
                    Object o = userListModel.getElementAt(0);
                    userListModel.removeElementAt(0);
                    String userListModelStr = (String)o;

                    int size = languageListModel.getSize();
                    int n = 0;
                    while (n < size) {
                        String s = (String)languageListModel.getElementAt(n);
                        if (userListModelStr.compareTo(s) > 0) {
                            break;
                        }
                        n++;
                    }
                    languageListModel.insertElementAt(o, n);
                }
                updateButtons();
            }
        }

        /**
         * To manage selection modifications
         */
        protected class LanguageListSelectionListener
            implements ListSelectionListener {
            public void valueChanged(ListSelectionEvent e) {
                int i = languageList.getSelectedIndex();
                userList.getSelectionModel().clearSelection();
                languageList.setSelectedIndex(i);
                updateButtons();
            }
        }

        /**
         * To manage selection modifications
         */
        protected class UserListSelectionListener
            implements ListSelectionListener {
            public void valueChanged(ListSelectionEvent e) {
                int i = userList.getSelectedIndex();
                languageList.getSelectionModel().clearSelection();
                userList.setSelectedIndex(i);
                updateButtons();
            }
        }

        /**
         * To display icons and text in the lists.
         */
        protected class IconAndTextCellRenderer
            extends    JLabel
            implements ListCellRenderer {
            public IconAndTextCellRenderer() {
                this.setOpaque(true);
                this.setBorder(BorderFactory.createEmptyBorder(3, 3, 3, 3));
            }
            public Component getListCellRendererComponent(JList   list,
                                                          Object  value,
                                                          int     index,
                                                          boolean isSelected,
                                                          boolean cellHasFocus){
                String s = (String)value;
                this.setText(getCountryText(s));
                this.setIcon(getCountryIcon(s));
                this.setEnabled(list.isEnabled());
                this.setFont(list.getFont());
                if (isSelected) {
                    this.setBackground(list.getSelectionBackground());
                    this.setForeground(list.getSelectionForeground());
                } else {
                    this.setBackground(list.getBackground());
                    this.setForeground(list.getForeground());
                }
                return this;
            }
        }
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
