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

import java.util.ArrayList;
import java.util.Locale;
import java.util.ResourceBundle;

import org.apache.flex.forks.batik.util.gui.DropDownComponent.DefaultScrollablePopupMenuItem;
import org.apache.flex.forks.batik.util.gui.DropDownComponent.ScrollablePopupMenu;
import org.apache.flex.forks.batik.util.gui.DropDownComponent.ScrollablePopupMenuEvent;
import org.apache.flex.forks.batik.util.gui.DropDownComponent.ScrollablePopupMenuItem;
import org.apache.flex.forks.batik.util.gui.DropDownComponent.ScrollablePopupMenuModel;
import org.apache.flex.forks.batik.apps.svgbrowser.HistoryBrowser.CommandNamesInfo;
import org.apache.flex.forks.batik.apps.svgbrowser.HistoryBrowser.HistoryBrowserAdapter;
import org.apache.flex.forks.batik.apps.svgbrowser.HistoryBrowser.HistoryBrowserEvent;
import org.apache.flex.forks.batik.util.resources.ResourceManager;

/**
 * The history scrollable popup menu model. Used for undo / redo drop down
 * components.
 *
 * @version $Id$
 */
public class DropDownHistoryModel implements ScrollablePopupMenuModel {

    /**
     * The resource file name.
     */
    private static final String RESOURCES =
        "org.apache.flex.forks.batik.apps.svgbrowser.resources.DropDownHistoryModelMessages";

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
     * Scrollable popup menu items.
     */
    protected ArrayList items = new ArrayList();

    /**
     * The history browser interface.
     */
    protected HistoryBrowserInterface historyBrowserInterface;

    /**
     * The parent scrollable popup menu.
     */
    protected ScrollablePopupMenu parent;

    /**
     * Creates the history pop up menu model.
     *
     * @param parent
     *            The parent ScrollablePopupMenu
     * @param historyBrowserInterface
     *            The historyBrowserInterface. Used to update the parent pop
     *            up menu when the HistoryBrowser fires the events
     */
    public DropDownHistoryModel(ScrollablePopupMenu parent,
            HistoryBrowserInterface historyBrowserInterface) {
        this.parent = parent;
        this.historyBrowserInterface = historyBrowserInterface;

        // Handle the history reset event
        historyBrowserInterface.getHistoryBrowser().addListener
            (new HistoryBrowserAdapter() {
                public void historyReset(HistoryBrowserEvent event) {
                    clearAllScrollablePopupMenuItems("");
                }
             });
    }

    /**
     * Gets the footer text.
     *
     * @return footer text
     */
    public String getFooterText() {
        return "";
    }

    /**
     * Creates the ScrollablePopupMenuItem with the specific name.
     *
     * @param itemName
     *            the name of the item
     * @return the item
     */
    public ScrollablePopupMenuItem createItem(String itemName) {
        return new DefaultScrollablePopupMenuItem(parent, itemName);
    }

    /**
     * Adds the ScrollablePopupMenuItem to the item list and to the parent.
     * Fires the event 'itemsWereAdded' on the parent pop up menu
     *
     * @param item
     *            The item to add
     * @param details
     *            The details for the 'itemsWereAdded' event
     */
    protected void addItem(ScrollablePopupMenuItem item, String details) {
        int oldSize = items.size();
        items.add(0, item);
        parent.add(item, 0, oldSize, items.size());
        parent.fireItemsWereAdded
            (new ScrollablePopupMenuEvent(parent,
                                          ScrollablePopupMenuEvent.ITEMS_ADDED,
                                          1,
                                          details));
    }

    /**
     * Removes the ScrollablePopupMenuItem from the item list and from the
     * parent. Fires the event 'itemsWereRemoved' on the parent pop up menu
     *
     * @param item
     *            The item to remove
     * @param details
     *            The details for the 'itemsWereRemoved' event
     */
    protected void removeItem(ScrollablePopupMenuItem item, String details) {
        int oldSize = items.size();
        items.remove(item);
        parent.remove(item, oldSize, items.size());
        parent.fireItemsWereRemoved
            (new ScrollablePopupMenuEvent(parent,
                                          ScrollablePopupMenuEvent.ITEMS_REMOVED,
                                          1,
                                          details));
    }

    /**
     * Removes the last scrollable popup menu item from the items list and
     * from the parent pop up menu.
     *
     * @param details
     *            The details for the 'itemsWereRemoved' event
     * @return True if item was successfully removed
     */
    protected boolean removeLastScrollablePopupMenuItem(String details) {
        for (int i = items.size() - 1; i >= 0; i--) {
            ScrollablePopupMenuItem item =
                (ScrollablePopupMenuItem) items.get(i);
            removeItem(item, details);
            return true;
        }
        return false;
    }

    /**
     * Removes the first scrollable popup menu item from the items list and
     * from the parent pop up menu.
     *
     * @param details
     *            The details for the 'itemsWereRemoved' event
     * @return True if item was successfully removed
     */
    protected boolean removeFirstScrollablePopupMenuItem(String details) {
        for (int i = 0; i < items.size(); i++) {
            ScrollablePopupMenuItem item =
                (ScrollablePopupMenuItem) items.get(i);
            removeItem(item, details);
            return true;
        }
        return false;
    }

    /**
     * Removes all scrollable popup menu items from the items list and from
     * the parent pop up menu.
     *
     * @param details
     *            The details for the event
     */
    protected void clearAllScrollablePopupMenuItems(String details) {
        while (removeLastScrollablePopupMenuItem(details)) {
        }
    }

    /**
     * Processes click on the pop up menu item.
     */
    public void processItemClicked() {
    }

    public void processBeforeShowed() {
        // Performs current command from the history browser
        historyBrowserInterface.performCurrentCompoundCommand();
    }

    public void processAfterShowed() {
    }

    /**
     * The undo pop up menu model.
     */
    public static class UndoPopUpMenuModel extends DropDownHistoryModel {

        /**
         * The undo footer text. Used for the footer item.
         */
        protected static String UNDO_FOOTER_TEXT =
            resources.getString("UndoModel.footerText");

        /**
         * The prefix for the last undoable command. E.g. (Undo change
         * selection)
         */
        protected static String UNDO_TOOLTIP_PREFIX =
            resources.getString("UndoModel.tooltipPrefix");

        /**
         * Creates the unod pop up menu model
         *
         * @param parent
         *            The parent scrollable popup menu
         * @param historyBrowserInterface
         *            the historyBrowserInterface
         */
        public UndoPopUpMenuModel
                (ScrollablePopupMenu parent,
                 HistoryBrowserInterface historyBrowserInterface) {

            super(parent, historyBrowserInterface);
            init();
        }

        /**
         * Initializes this model. Adds the listeners to the history browser.
         */
        private void init() {
            historyBrowserInterface.getHistoryBrowser().addListener
                (new HistoryBrowserAdapter() {
                     public void executePerformed(HistoryBrowserEvent event) {
                         CommandNamesInfo info =
                             (CommandNamesInfo) event.getSource();
                         String details = UNDO_TOOLTIP_PREFIX
                                 + info.getLastUndoableCommandName();
                         addItem(createItem(info.getCommandName()), details);
                     }

                     public void undoPerformed(HistoryBrowserEvent event) {
                         CommandNamesInfo info =
                             (CommandNamesInfo) event.getSource();
                         String details = UNDO_TOOLTIP_PREFIX
                                 + info.getLastUndoableCommandName();
                         removeFirstScrollablePopupMenuItem(details);
                     }

                     public void redoPerformed(HistoryBrowserEvent event) {
                         CommandNamesInfo info =
                             (CommandNamesInfo) event.getSource();
                         String details = UNDO_TOOLTIP_PREFIX
                                 + info.getLastUndoableCommandName();
                         addItem(createItem(info.getCommandName()), details);
                     }

                     public void doCompoundEdit(HistoryBrowserEvent event) {
                         if (!parent.isEnabled()) {
                             parent.setEnabled(true);
                         }
                     }

                     public void compoundEditPerformed
                             (HistoryBrowserEvent event) {
                     }
                });
        }

        public String getFooterText() {
            return UNDO_FOOTER_TEXT;
        }

        public void processItemClicked() {
            historyBrowserInterface.getHistoryBrowser().compoundUndo
                (parent.getSelectedItemsCount());
        }
    }

    /**
     * The redo pop up menu model.
     */
    public static class RedoPopUpMenuModel extends DropDownHistoryModel {

        /**
         * The redo footer text. Used for the footer item.
         */
        protected static String REDO_FOOTER_TEXT =
            resources.getString("RedoModel.footerText");

        /**
         * The prefix for the last redoable command. E.g. (Redo change
         * selection)
         */
        protected static String REDO_TOOLTIP_PREFIX =
            resources.getString("RedoModel.tooltipPrefix");

        /**
         * Creates the redo pop up menu model
         *
         * @param parent
         *            The parent scrollable popup menu
         * @param historyBrowserInterface
         *            the historyBrowserInterface
         */
        public RedoPopUpMenuModel
                    (ScrollablePopupMenu parent,
                     HistoryBrowserInterface historyBrowserInterface) {

            super(parent, historyBrowserInterface);
            init();
        }

        /**
         * Initializes this model. Adds the listeners to the history browser.
         */
        private void init() {
            historyBrowserInterface.getHistoryBrowser().addListener
                (new HistoryBrowserAdapter() {

                     public void executePerformed(HistoryBrowserEvent event) {
                         CommandNamesInfo info =
                            (CommandNamesInfo) event.getSource();
                         String details = REDO_TOOLTIP_PREFIX
                                 + info.getLastRedoableCommandName();
                         clearAllScrollablePopupMenuItems(details);
                     }

                     public void undoPerformed(HistoryBrowserEvent event) {
                         CommandNamesInfo info =
                            (CommandNamesInfo) event.getSource();
                         String details = REDO_TOOLTIP_PREFIX
                                 + info.getLastRedoableCommandName();
                         addItem(createItem(info.getCommandName()), details);
                     }

                     public void redoPerformed(HistoryBrowserEvent event) {
                         CommandNamesInfo info =
                            (CommandNamesInfo) event.getSource();
                         String details = REDO_TOOLTIP_PREFIX
                                 + info.getLastRedoableCommandName();
                         removeFirstScrollablePopupMenuItem(details);
                     }

                     public void doCompoundEdit(HistoryBrowserEvent event) {
                         if (parent.isEnabled()) {
                             parent.setEnabled(false);
                         }
                     }

                     public void compoundEditPerformed
                            (HistoryBrowserEvent event) {
                     }
                 });
        }

        public String getFooterText() {
            return REDO_FOOTER_TEXT;
        }

        public void processItemClicked() {
            historyBrowserInterface.getHistoryBrowser().compoundRedo
                (parent.getSelectedItemsCount());
        }
    }
}
