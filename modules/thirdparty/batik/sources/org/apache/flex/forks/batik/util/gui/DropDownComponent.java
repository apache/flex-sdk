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
import java.awt.Color;
import java.awt.Component;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.GridLayout;
import java.awt.Point;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;
import java.util.EventListener;
import java.util.EventObject;
import java.util.Locale;
import java.util.ResourceBundle;

import javax.swing.BorderFactory;
import javax.swing.Icon;
import javax.swing.JButton;
import javax.swing.JComponent;
import javax.swing.JPanel;
import javax.swing.JPopupMenu;
import javax.swing.JScrollPane;
import javax.swing.ScrollPaneConstants;
import javax.swing.SwingUtilities;
import javax.swing.UIManager;
import javax.swing.event.EventListenerList;
import javax.swing.plaf.basic.BasicButtonUI;

import org.apache.flex.forks.batik.util.resources.ResourceManager;

/**
 * The drop down menu component. Supports drop down popup menu and the main
 * button.
 *
 * @version $Id$
 */
public class DropDownComponent extends JPanel {

    /**
     * The main button for this component.
     */
    private JButton mainButton;

    /**
     * The drop down button. When clicked the dropdown popup menu appears.
     */
    private JButton dropDownButton;

    /**
     * The icon for enabled drop down button.
     */
    private Icon enabledDownArrow;

    /**
     * The icon for disabled drop down button.
     */
    private Icon disabledDownArrow;

    /**
     * The scrollable pop up menu.
     */
    private ScrollablePopupMenu popupMenu;

    /**
     * If drop down menu appears when clicked on dropdown button.
     */
    private boolean isDropDownEnabled;

    /**
     * Creates the dropdown menu with the given main button.
     *
     * @param mainButton
     *            the components main button
     */
    public DropDownComponent(JButton mainButton) {
        super(new BorderLayout());

        // Initializes pop up menu
        popupMenu = getPopupMenu();

        this.mainButton = mainButton;
        add(this.mainButton, BorderLayout.WEST);
        this.mainButton.setMaximumSize(new Dimension(24, 24));
        this.mainButton.setPreferredSize(new Dimension(24, 24));

        // Initializes dropdown button and icons for dropdown button
        enabledDownArrow = new SmallDownArrow();
        disabledDownArrow = new SmallDisabledDownArrow();
        dropDownButton = new JButton(disabledDownArrow);
        dropDownButton.setBorderPainted(false);
        dropDownButton.setDisabledIcon(disabledDownArrow);
        dropDownButton.addMouseListener(new DropDownListener());
        dropDownButton.setMaximumSize(new Dimension(18, 24));
        dropDownButton.setMinimumSize(new Dimension(18, 10));
        dropDownButton.setPreferredSize(new Dimension(18, 10));
        dropDownButton.setFocusPainted(false);
        add(dropDownButton, BorderLayout.EAST);

        setEnabled(false);
    }

    /**
     * Gets the dropdown popup menu.
     *
     * @return ScrollablePopupMenu
     */
    public ScrollablePopupMenu getPopupMenu() {
        if (popupMenu == null) {
            popupMenu = new ScrollablePopupMenu(this);
            popupMenu.setEnabled(false);
            // If the pop up menu gets disabled,
            // the dropdown buttons should be disabled as well
            popupMenu.addPropertyChangeListener
                ("enabled",
                 new PropertyChangeListener() {
                     public void propertyChange(PropertyChangeEvent evt) {
                         setEnabled
                            (((Boolean) evt.getNewValue()).booleanValue());
                     }
                 });

            // Listens for the changes in the scrollable pop up menu
            popupMenu.addListener
                (new ScrollablePopupMenuAdapter() {

                     public void itemsWereAdded(ScrollablePopupMenuEvent ev) {
                         updateMainButtonTooltip(ev.getDetails());
                     }

                     public void itemsWereRemoved(ScrollablePopupMenuEvent ev) {
                         updateMainButtonTooltip(ev.getDetails());
                     }
                 });
        }
        return popupMenu;
    }

    public void setEnabled(boolean enable) {
        isDropDownEnabled = enable;
        mainButton.setEnabled(enable);
        dropDownButton.setEnabled(enable);
        dropDownButton.setIcon(enable ? enabledDownArrow : disabledDownArrow);
    }

    public boolean isEnabled() {
        return isDropDownEnabled;
    }

    /**
     * Sets new tooltip text to the main button.
     *
     * @param newTooltip
     *            the new tooltip text
     */
    public void updateMainButtonTooltip(String newTooltip) {
        mainButton.setToolTipText(newTooltip);
    }

    /**
     * Shows the pop up menu when clicked.
     */
    private class DropDownListener extends MouseAdapter {
        public void mousePressed(MouseEvent e) {
            if (popupMenu.isShowing() && isDropDownEnabled) {
                popupMenu.setVisible(false);
            } else if (isDropDownEnabled) {
                popupMenu.showMenu
                    ((Component) e.getSource(), DropDownComponent.this);
            }
        }
        public void mouseEntered(MouseEvent ev) {
            dropDownButton.setBorderPainted(true);
        }
        public void mouseExited(MouseEvent ev) {
            dropDownButton.setBorderPainted(false);
        }
    }

    /**
     * A small downward-pointing arrow icon.
     */
    private static class SmallDownArrow implements Icon {

        /**
         * The arrow color.
         */
        protected Color arrowColor = Color.black;

        public void paintIcon(Component c, Graphics g, int x, int y) {
            g.setColor(arrowColor);
            g.drawLine(x, y, x + 4, y);
            g.drawLine(x + 1, y + 1, x + 3, y + 1);
            g.drawLine(x + 2, y + 2, x + 2, y + 2);
        }

        public int getIconWidth() {
            return 6;
        }

        public int getIconHeight() {
            return 4;
        }
    }

    /**
     * A disabled small downward-pointing arrow icon.
     */
    private static class SmallDisabledDownArrow extends SmallDownArrow {

        /**
         * Constructor.
         */
        public SmallDisabledDownArrow() {
            arrowColor = new Color(140, 140, 140);
        }

        public void paintIcon(Component c, Graphics g, int x, int y) {
            super.paintIcon(c, g, x, y);
            g.setColor(Color.white);
            g.drawLine(x + 3, y + 2, x + 4, y + 1);
            g.drawLine(x + 3, y + 3, x + 5, y + 1);
        }
    }

    /**
     * The scrollable pop up menu item.
     */
    public static interface ScrollablePopupMenuItem {

        /**
         * Selects and deselects the item.
         *
         * @param selected
         *            is selected
         */
        void setSelected(boolean selected);

        /**
         * Checks if the item is selected.
         *
         * @return True if selected
         */
        boolean isSelected();

        /**
         * Returns the item name.
         *
         * @return the name
         */
        String getText();

        /**
         * Sets the item name.
         *
         * @param text
         *            The new item name
         */
        void setText(String text);

        /**
         * Enables / disables the item
         *
         * @param enabled
         *            True - enables the item
         */
        void setEnabled(boolean enabled);
    }

    /**
     * Default implementation of the scrollable popup menu item.
     */
    public static class DefaultScrollablePopupMenuItem extends JButton
            implements ScrollablePopupMenuItem {

        /**
         * The selected item background color.
         */
        public static final Color MENU_HIGHLIGHT_BG_COLOR =
            UIManager.getColor("MenuItem.selectionBackground");

        /**
         * The selected item foreground color.
         */
        public static final Color MENU_HIGHLIGHT_FG_COLOR =
            UIManager.getColor("MenuItem.selectionForeground");

        /**
         * The item background color.
         */
        public static final Color MENUITEM_BG_COLOR =
            UIManager.getColor("MenuItem.background");

        /**
         * The item foreground color.
         */
        public static final Color MENUITEM_FG_COLOR =
            UIManager.getColor("MenuItem.foreground");

        /**
         * The parent scrollable popup menu.
         */
        private ScrollablePopupMenu parent;

        /**
         * Constructor.
         */
        public DefaultScrollablePopupMenuItem(ScrollablePopupMenu parent,
                                              String text) {
            super(text);
            this.parent = parent;
            init();
        }

        /**
         * Initializes this item.
         */
        private void init() {
            this.setUI(BasicButtonUI.createUI(this));
            setBorder(BorderFactory.createEmptyBorder(5, 15, 5, 20));
            setMenuItemDefaultColors();
            this.setAlignmentX(JButton.LEFT_ALIGNMENT);
            setSelected(false);

            this.addMouseListener
                (new MouseAdapter() {

                     public void mouseEntered(MouseEvent e) {
                         if (DefaultScrollablePopupMenuItem.this.isEnabled()) {
                             setSelected(true);
                             parent.selectionChanged
                                 (DefaultScrollablePopupMenuItem.this, true);
                         }
                     }

                     public void mouseExited(MouseEvent e) {
                         if (DefaultScrollablePopupMenuItem.this.isEnabled()) {
                             setSelected(false);
                             parent.selectionChanged
                                (DefaultScrollablePopupMenuItem.this, false);
                         }
                     }

                     public void mouseClicked(MouseEvent e) {
                         parent.processItemClicked();
                     }
                 });
        }

        /**
         * Sets the default item colors.
         */
        private void setMenuItemDefaultColors() {
            setBackground(MENUITEM_BG_COLOR);
            setForeground(MENUITEM_FG_COLOR);
        }

        public void setSelected(boolean selected) {
            super.setSelected(selected);
            if (selected) {
                setBackground(MENU_HIGHLIGHT_BG_COLOR);
                setForeground(MENU_HIGHLIGHT_FG_COLOR);
            } else {
                setMenuItemDefaultColors();
            }
        }

        public String getText() {
            return super.getText();
        }

        public void setText(String text) {
            super.setText(text);
        }

        public void setEnabled(boolean b) {
            super.setEnabled(b);
        }
    }

    /**
     * The scrollable popup menu model.
     */
    public static interface ScrollablePopupMenuModel {

        /**
         * Gets the footer text for the ScrollablePopupMenu's footer item.
         * @return    the footer text.
         */
        String getFooterText();

        /**
         * Processes the click on the pop up menu item.
         */
        void processItemClicked();

        /**
         * Processes the showing of the pop up menu. Invoked before showing the
         * pop up menu
         */
        void processBeforeShowed();

        /**
         * Processes the showing of the pop up menu. Invoked after showing the
         * pop up menu
         */
        void processAfterShowed();
    }

    /**
     * The Scrollable Popup Menu Component.
     */
    public static class ScrollablePopupMenu extends JPopupMenu {

        /**
         * The resource file name.
         */
        private static final String RESOURCES =
            "org.apache.flex.forks.batik.util.gui.resources.ScrollablePopupMenuMessages";

        /**
         * The resource bundle.
         */
        private static ResourceBundle bundle;

        /**
         * The resource manager.
         */
        private static ResourceManager resources;
        static {
            bundle = ResourceBundle.getBundle(RESOURCES, Locale.getDefault());
            resources = new ResourceManager(bundle);
        }

        /**
         * The menu panel.
         */
        private JPanel menuPanel = new JPanel();

        /**
         * The scroll pane.
         */
        private JScrollPane scrollPane;

        /**
         * Max menu height.
         */
        private int preferredHeight = resources.getInteger("PreferredHeight");

        /**
         * The model for this component.
         */
        private ScrollablePopupMenuModel model;

        /**
         * The owner component.
         */
        private JComponent ownerComponent;

        /**
         * Footer item. Should be always shown at the bottom of this pop up.
         */
        private ScrollablePopupMenuItem footer;

        /**
         * Listeners list.
         */
        private EventListenerList eventListeners = new EventListenerList();

        /**
         * Constructor.
         *
         * @param owner
         *            The owner component
         */
        public ScrollablePopupMenu(JComponent owner) {
            super();
            this.setLayout(new BorderLayout());
            menuPanel.setLayout(new GridLayout(0, 1));
            ownerComponent = owner;
            init();
        }

        /**
         * Initializes this popup menu.
         */
        private void init() {
            super.removeAll();
            scrollPane = new JScrollPane();
            scrollPane.setViewportView(menuPanel);
            scrollPane.setBorder(null);
            int minWidth = resources.getInteger("ScrollPane.minWidth");
            int minHeight = resources.getInteger("ScrollPane.minHeight");
            int maxWidth = resources.getInteger("ScrollPane.maxWidth");
            int maxHeight = resources.getInteger("ScrollPane.maxHeight");
            scrollPane.setMinimumSize(new Dimension(minWidth, minHeight));
            scrollPane.setMaximumSize(new Dimension(maxWidth, maxHeight));
            scrollPane.setHorizontalScrollBarPolicy
                (ScrollPaneConstants.HORIZONTAL_SCROLLBAR_NEVER);
            add(scrollPane, BorderLayout.CENTER);
            addFooter(new DefaultScrollablePopupMenuItem(this, ""));
        }

        /**
         * Shows this popup menu.
         *
         * @param invoker
         *            The popup menu invoker component
         * @param refComponent
         *            The dropdown component that containts this menu
         */
        public void showMenu(Component invoker, Component refComponent) {
            model.processBeforeShowed();

            Point abs = new Point(0, refComponent.getHeight());
            SwingUtilities.convertPointToScreen(abs, refComponent);
            this.setLocation(abs);
            this.setInvoker(invoker);
            this.setVisible(true);
            this.revalidate();
            this.repaint();

            model.processAfterShowed();
        }

        /**
         * Adds the item to this component at the specified location.
         *
         * @param menuItem
         *            the item to add
         */
        public void add(ScrollablePopupMenuItem menuItem, int index,
                        int oldSize, int newSize) {
            menuPanel.add((Component) menuItem, index);
            if (oldSize == 0) {
                this.setEnabled(true);
            }
        }

        /**
         * Removes the item from this component.
         *
         * @param menuItem
         *            the item to remove
         */
        public void remove(ScrollablePopupMenuItem menuItem, int oldSize,
                           int newSize) {
            menuPanel.remove((Component) menuItem);
            if (newSize == 0) {
                this.setEnabled(false);
            }
        }

        /**
         * Gets the preferred width of this pop up menu.
         *
         * @return the preferred width
         */
        private int getPreferredWidth() {
            Component[] components = menuPanel.getComponents();
            int maxWidth = 0;
            for (int i = 0; i < components.length; i++) {
                int currentWidth = components[i].getPreferredSize().width;
                if (maxWidth < currentWidth) {
                    maxWidth = currentWidth;
                }
            }
            int footerWidth = ((Component) footer).getPreferredSize().width;
            if (footerWidth > maxWidth) {
                maxWidth = footerWidth;
            }
            int widthOffset = 30;
            return maxWidth + widthOffset;
        }

        /**
         * Gets the preferred height of this component.
         *
         * @return the preferred height
         */
        private int getPreferredHeight() {
            if (scrollPane.getPreferredSize().height < preferredHeight) {
                int heightOffset = 10;
                return scrollPane.getPreferredSize().height
                        + ((Component) footer).getPreferredSize().height
                        + heightOffset;
            }
            return preferredHeight
                    + ((Component) footer).getPreferredSize().height;
        }

        public Dimension getPreferredSize() {
            return new Dimension(getPreferredWidth(), getPreferredHeight());
        }

        /**
         * Invoked when item selection changes.
         */
        public void selectionChanged(ScrollablePopupMenuItem targetItem,
                boolean wasSelected) {
            Component[] comps = menuPanel.getComponents();
            int n = comps.length;
            // Deselect all if something was selected
            if (!wasSelected) {
                for (int i = n - 1; i >= 0; i--) {
                    ScrollablePopupMenuItem item = (ScrollablePopupMenuItem) comps[i];
                    item.setSelected(wasSelected);
                }
            } else {
                for (int i = 0; i < n; i++) {
                    ScrollablePopupMenuItem item = (ScrollablePopupMenuItem) comps[i];
                    if (item == targetItem) {
                        break;
                    }
                    item.setSelected(true);
                }
            }
            footer.setText(model.getFooterText() + getSelectedItemsCount());
            repaint();
        }

        /**
         * Sets the ScrollablePopupMenuModel.
         *
         * @param model
         *            the model to set
         */
        public void setModel(ScrollablePopupMenuModel model) {
            this.model = model;
            this.footer.setText(model.getFooterText());
        }

        /**
         * Gets the ScrollablePopupMenuModel
         *
         * @return the ScrollablePopupMenuModel model
         */
        public ScrollablePopupMenuModel getModel() {
            return model;
        }

        /**
         * Gets the number of the selected items.
         *
         * @return number of selected items
         */
        public int getSelectedItemsCount() {
            int selectionCount = 0;
            Component[] components = menuPanel.getComponents();
            for (int i = 0; i < components.length; i++) {
                ScrollablePopupMenuItem item = (ScrollablePopupMenuItem) components[i];
                if (item.isSelected()) {
                    selectionCount++;
                }
            }
            return selectionCount;
        }

        /**
         * Processes click on the pop up menu item.
         */
        public void processItemClicked() {
            footer.setText(model.getFooterText() + 0);
            setVisible(false);
            model.processItemClicked();
        }

        /**
         * Gets the owner component.
         * @return    the owner component
         */
        public JComponent getOwner() {
            return ownerComponent;
        }

        /**
         * Adds the footer item to this pop up menu.
         */
        private void addFooter(ScrollablePopupMenuItem footer) {
            this.footer = footer;
            this.footer.setEnabled(false);
            add((Component)this.footer, BorderLayout.SOUTH);
        }

        /**
         * Gets the footer item.
         * @return    the footer
         */
        public ScrollablePopupMenuItem getFooter() {
            return footer;
        }

        /**
         * Adds the listener to the listener list.
         *
         * @param listener
         *            The listener to add
         */
        public void addListener(ScrollablePopupMenuListener listener) {
            eventListeners.add(ScrollablePopupMenuListener.class, listener);
        }

        /**
         * Fires the itemsWereAdded event, when the items are added to this pop
         * up menu.
         *
         * @param event
         *            The associated ScrollablePopupMenuEvent event
         */
        public void fireItemsWereAdded(ScrollablePopupMenuEvent event) {
            Object[] listeners = eventListeners.getListenerList();
            int length = listeners.length;
            for (int i = 0; i < length; i += 2) {
                if (listeners[i] == ScrollablePopupMenuListener.class) {
                    ((ScrollablePopupMenuListener) listeners[i + 1])
                            .itemsWereAdded(event);
                }
            }
        }

        /**
         * Fires the itemsWereRemove event, when the items are removed from this
         * pop up menu.
         *
         * @param event
         *            The associated ScrollablePopupMenuEvent event
         */
        public void fireItemsWereRemoved(ScrollablePopupMenuEvent event) {
            Object[] listeners = eventListeners.getListenerList();
            int length = listeners.length;
            for (int i = 0; i < length; i += 2) {
                if (listeners[i] == ScrollablePopupMenuListener.class) {
                    ((ScrollablePopupMenuListener) listeners[i + 1])
                            .itemsWereRemoved(event);
                }
            }
        }
    }

    // Custom event support for ScrollablePopupMenu

    /**
     * Event to pass to listener.
     */
    public static class ScrollablePopupMenuEvent extends EventObject {

        // The codes for the event type
        public static final int ITEMS_ADDED = 1;
        public static final int ITEMS_REMOVED = 2;

        /**
         * The event type.
         */
        private int type;

        /**
         * The number of items that were added / removed.
         */
        private int itemNumber;

        /**
         * The details about the event.
         */
        private String details;

        /**
         * Creates the ScrollablePopupMenuEvent.
         *
         * @param source
         *            The source component
         * @param type
         *            The event type
         * @param itemNumber
         *            The item number
         * @param details
         *            The event details
         */
        public ScrollablePopupMenuEvent(Object source, int type,
                                        int itemNumber, String details) {
            super(source);
            initEvent(type, itemNumber, details);
        }

        /**
         * Initializes this event.
         */
        public void initEvent(int type, int itemNumber, String details) {
            this.type = type;
            this.itemNumber = itemNumber;
            this.details = details;
        }

        /**
         * Gets the event details.
         *
         * @return the details
         */
        public String getDetails() {
            return details;
        }

        /**
         * Gets the item number.
         *
         * @return the item number
         */
        public int getItemNumber() {
            return itemNumber;
        }

        /**
         * Gets the event type.
         *
         * @return the type
         */
        public int getType() {
            return type;
        }
    }

    /**
     * The ScrollablePopupMenu listener. Handles the events that
     * ScrollablePopupMenu fires
     */
    public static interface ScrollablePopupMenuListener extends EventListener {

        /**
         * Handles the 'itemsWereAdded' event.
         *
         * @param ev
         *            The associated event
         */
        void itemsWereAdded(ScrollablePopupMenuEvent ev);

        /**
         * Handles the 'itemsWereRemoved' event.
         *
         * @param ev
         *            The associated event
         */
        void itemsWereRemoved(ScrollablePopupMenuEvent ev);
    }

    /**
     * The adapter for the ScrollablePopupMenuListener.
     */
    public static class ScrollablePopupMenuAdapter
            implements ScrollablePopupMenuListener {

        public void itemsWereAdded(ScrollablePopupMenuEvent ev) {
        }

        public void itemsWereRemoved(ScrollablePopupMenuEvent ev) {
        }
    }
}
