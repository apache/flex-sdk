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
import java.util.EventListener;
import java.util.EventObject;

import javax.swing.event.EventListenerList;

/**
 * History browser. Manages perform of execute, undo and redo actions.
 */
public class HistoryBrowser {

    // The history browser states. Show whether the history browser is busy
    // performing execute, undo or redo, or whether is idle.
    /**
     * The history browser is executing the command(s).
     */
    public static final int EXECUTING = 1;

    /**
     * The history browser is undoing the command(s).
     */
    public static final int UNDOING = 2;

    /**
     * The history browser is redoing the command(s).
     */
    public static final int REDOING = 3;

    /**
     * The history browser is in idle state - no command is being executed,
     * undone or redone.
     */
    public static final int IDLE = 4;

    /**
     * Listeners list.
     */
    protected EventListenerList eventListeners =
        new EventListenerList();

    /**
     * Command history.
     */
    protected ArrayList history;

    /**
     * Current command pointer in history array.
     */
    protected int currentCommandIndex = -1;

    /**
     * History size.
     */
    protected int historySize = 1000;

    /**
     * The current state of the history browser.
     */
    protected int state = IDLE;

    /**
     * Tells the history browser how to execute, undo and redo the commands.
     * Wraps the execute, undo and redo methods
     */
    protected CommandController commandController;

    /**
     * Constructor.
     */
    public HistoryBrowser(CommandController commandController) {
        this.history = new ArrayList();
        this.commandController = commandController;
    }

    /**
     * Constructor.
     * @param historySize    History size
     */
    public HistoryBrowser(int historySize) {
        this.history = new ArrayList();
        setHistorySize(historySize);
    }

    /**
     * Setter for the history size.
     *
     * @param size
     *        New history size
     */
    protected void setHistorySize(int size) {
        historySize = size;
    }

    /**
     * Sets the commandController.
     *
     * @param newCommandController
     *            The newCommandController to set
     */
    public void setCommandController(CommandController newCommandController) {
        this.commandController = newCommandController;
    }

    /**
     * Adds the given command to history array and executes it.
     *
     * @param command
     *            The given command
     */
    public void addCommand(UndoableCommand command) {
        // When the command is added to history array, the commands from the
        // current position to the end of the list are removed from history
        int n = history.size();
        for (int i = n - 1; i > currentCommandIndex; i--) {
            history.remove(i);
        }
        // Executes the command
        if (commandController != null) {
            commandController.execute(command);
        } else {
            state = EXECUTING;
            command.execute();
            state = IDLE;
        }
        // Adds it to the history array
        history.add(command);

        // Updates the pointer to the current command
        currentCommandIndex = history.size() - 1;
        if (currentCommandIndex >= historySize) {
            history.remove(0);
            currentCommandIndex--;
        }
        fireExecutePerformed(new HistoryBrowserEvent(new CommandNamesInfo(
                command.getName(), getLastUndoableCommandName(),
                getLastRedoableCommandName())));
    }

    /**
     * Undoes the last executed or 'redone' command.
     */
    public void undo() {
        // If history is empty, or the current command index is out of bounds
        if (history.isEmpty() || currentCommandIndex < 0) {
            return;
        }
        // Gets the command and performs undo
        UndoableCommand command = (UndoableCommand) history
                .get(currentCommandIndex);
        if (commandController != null) {
            commandController.undo(command);
        } else {
            state = UNDOING;
            command.undo();
            state = IDLE;
        }
        // Updates the current command index
        currentCommandIndex--;
        fireUndoPerformed(new HistoryBrowserEvent(new CommandNamesInfo(command
                .getName(), getLastUndoableCommandName(),
                getLastRedoableCommandName())));
    }

    /**
     * Redoes the last 'undone' command.
     */
    public void redo() {
        // If history is empty, or the current command index is out of bounds
        if (history.isEmpty() || currentCommandIndex == history.size() - 1) {
            return;
        }
        // Increases the current command index and redoes the command
        UndoableCommand command = (UndoableCommand) history
                .get(++currentCommandIndex);
        if (commandController != null) {
            commandController.redo(command);
        } else {
            state = REDOING;
            command.redo();
            state = IDLE;
        }
        fireRedoPerformed(new HistoryBrowserEvent(new CommandNamesInfo(command
                .getName(), getLastUndoableCommandName(),
                getLastRedoableCommandName())));
    }

    /**
     * Performs undo action the given number of times.
     *
     * @param undoNumber
     *            The given number of undo actions to perform
     */
    public void compoundUndo(int undoNumber) {
        for (int i = 0; i < undoNumber; i++) {
            undo();
        }
    }

    /**
     * Performs redo action the given number of times.
     *
     * @param redoNumber
     *            The given number of redo actions to perform
     */
    public void compoundRedo(int redoNumber) {
        for (int i = 0; i < redoNumber; i++) {
            redo();
        }
    }

    /**
     * Gets the last undoable command name.
     *
     * @return String or "" if there's no any
     */
    public String getLastUndoableCommandName() {
        if (history.isEmpty() || currentCommandIndex < 0) {
            return "";
        }
        return ((UndoableCommand) history.get(currentCommandIndex)).getName();
    }

    /**
     * Gets the last redoable command name.
     *
     * @return String or "" if there's no any
     */
    public String getLastRedoableCommandName() {
        if (history.isEmpty() || currentCommandIndex == history.size() - 1) {
            return "";
        }
        return ((UndoableCommand) history.get(currentCommandIndex + 1))
                .getName();
    }

    /**
     * Clears the history array.
     */
    public void resetHistory() {
        history.clear();
        currentCommandIndex = -1;
        fireHistoryReset(new HistoryBrowserEvent(new Object()));
    }

    /**
     * Gets the state of this history browser.
     *
     * @return the state
     */
    public int getState() {
        if (commandController != null) {
            return commandController.getState();
        } else {
            return state;
        }
    }

    // Custom event support

    /**
     * Event to pass to listener.
     */
    public static class HistoryBrowserEvent extends EventObject {

        /**
         * @param source
         */
        public HistoryBrowserEvent(Object source) {
            super(source);
        }
    }

    /**
     * The HistoryBrowserListener.
     */
    public static interface HistoryBrowserListener extends EventListener {

        /**
         * The command has been executed.
         */
        void executePerformed(HistoryBrowserEvent event);

        /**
         * The undo has been performed on the command.
         */
        void undoPerformed(HistoryBrowserEvent event);

        /**
         * The redo has been performed on the command.
         */
        void redoPerformed(HistoryBrowserEvent event);

        /**
         * History has been reset, and all commands have been removed from the
         * history.
         */
        void historyReset(HistoryBrowserEvent event);

        /**
         * The the atom command that should be wrapped with the compound command
         * has been executed.
         */
        void doCompoundEdit(HistoryBrowserEvent event);

        /**
         * The compound command has been made from the atom commands that were
         * executed and should be wrapped.
         */
        void compoundEditPerformed(HistoryBrowserEvent event);
    }

    /**
     * The adapter to provide the default behavior.
     */
    public static class HistoryBrowserAdapter implements HistoryBrowserListener {

        public void executePerformed(HistoryBrowserEvent event) {
        }

        public void undoPerformed(HistoryBrowserEvent event) {
        }

        public void redoPerformed(HistoryBrowserEvent event) {
        }

        public void historyReset(HistoryBrowserEvent event) {
        }

        public void compoundEditPerformed(HistoryBrowserEvent event) {
        }

        public void doCompoundEdit(HistoryBrowserEvent event) {
        }
    }

    /**
     * Adds the listener to the listener list.
     *
     * @param listener
     *            The listener to add
     */
    public void addListener(HistoryBrowserListener listener) {
        eventListeners.add(HistoryBrowserListener.class, listener);
    }

    /**
     * Fires the executePerformed event.
     *
     * @param event
     *            The associated HistoryBrowserEvent event
     */
    public void fireExecutePerformed(HistoryBrowserEvent event) {
        Object[] listeners = eventListeners.getListenerList();
        int length = listeners.length;
        for (int i = 0; i < length; i += 2) {
            if (listeners[i] == HistoryBrowserListener.class) {
                ((HistoryBrowserListener) listeners[i + 1])
                        .executePerformed(event);
            }
        }
    }

    /**
     * Fires the undoPerformed event.
     *
     * @param event
     *            The associated HistoryBrowserEvent event
     */
    public void fireUndoPerformed(HistoryBrowserEvent event) {
        Object[] listeners = eventListeners.getListenerList();
        int length = listeners.length;
        for (int i = 0; i < length; i += 2) {
            if (listeners[i] == HistoryBrowserListener.class) {
                ((HistoryBrowserListener) listeners[i + 1])
                        .undoPerformed(event);
            }
        }
    }

    /**
     * Fires the redoPerformed event.
     *
     * @param event
     *            The associated HistoryBrowserEvent event
     */
    public void fireRedoPerformed(HistoryBrowserEvent event) {
        Object[] listeners = eventListeners.getListenerList();
        int length = listeners.length;
        for (int i = 0; i < length; i += 2) {
            if (listeners[i] == HistoryBrowserListener.class) {
                ((HistoryBrowserListener) listeners[i + 1])
                        .redoPerformed(event);
            }
        }
    }

    /**
     * Fires the historyReset event.
     *
     * @param event
     *            The associated HistoryBrowserEvent event
     */
    public void fireHistoryReset(HistoryBrowserEvent event) {
        Object[] listeners = eventListeners.getListenerList();
        int length = listeners.length;
        for (int i = 0; i < length; i += 2) {
            if (listeners[i] == HistoryBrowserListener.class) {
                ((HistoryBrowserListener) listeners[i + 1])
                        .historyReset(event);
            }
        }
    }

    /**
     * Fires the doCompoundEdit event.
     *
     * @param event
     *            The associated HistoryBrowserEvent event
     */
    public void fireDoCompoundEdit(HistoryBrowserEvent event) {
        Object[] listeners = eventListeners.getListenerList();
        int length = listeners.length;
        for (int i = 0; i < length; i += 2) {
            if (listeners[i] == HistoryBrowserListener.class) {
                ((HistoryBrowserListener) listeners[i + 1])
                        .doCompoundEdit(event);
            }
        }
    }

    /**
     * Fires the compoundEditPerformed event.
     *
     * @param event
     *            The associated HistoryBrowserEvent event
     */
    public void fireCompoundEditPerformed(HistoryBrowserEvent event) {
        Object[] listeners = eventListeners.getListenerList();
        int length = listeners.length;
        for (int i = 0; i < length; i += 2) {
            if (listeners[i] == HistoryBrowserListener.class) {
                ((HistoryBrowserListener) listeners[i + 1])
                        .compoundEditPerformed(event);
            }
        }
    }

    /**
     * Contains the info on the command name being executed, undone or redone and
     * last undoable and redoable command names.
     */
    public static class CommandNamesInfo {

        /**
         * The name of the last undoable command in the history.
         */
        private String lastUndoableCommandName;

        /**
         * The name of the last redoable command in the history.
         */
        private String lastRedoableCommandName;

        /**
         * The command name being executed, undone or redone.
         */
        private String commandName;

        /**
         * Constructor.
         *
         * @param commandName
         *            The current command name being executed/undone/redone
         * @param lastUndoableCommandName
         *            The last undoable command name
         * @param lastRedoableCommandName
         *            The last redoable command name
         */
        public CommandNamesInfo(String commandName,
                                String lastUndoableCommandName,
                                String lastRedoableCommandName) {
            this.lastUndoableCommandName = lastUndoableCommandName;
            this.lastRedoableCommandName = lastRedoableCommandName;
            this.commandName = commandName;
        }

        /**
         * Gets the name of the last undoable command.
         *
         * @return the lastUndoableCommandName
         */
        public String getLastRedoableCommandName() {
            return lastRedoableCommandName;
        }

        /**
         * Gets the name of the last redoable command.
         *
         * @return the lastRedoableCommandName
         */
        public String getLastUndoableCommandName() {
            return lastUndoableCommandName;
        }

        /**
         * Gets the command name.
         *
         * @return the command name
         */
        public String getCommandName() {
            return commandName;
        }
    }

    /**
     * Wrapps the command's execute, undo and redo methods.
     */
    public static interface CommandController {

        /**
         * Wrapps the execute method.
         */
        void execute(UndoableCommand command);

        /**
         * Wrapps the undo method.
         */
        void undo(UndoableCommand command);

        /**
         * Wrapps the redo method.
         */
        void redo(UndoableCommand command);

        /**
         * Gets the state of the command controller.
         * @return    HistoryBrowserState
         */
        int getState();
    }

    /**
     * Lets the DOMViewerController wrap the commands.
     */
    public static class DocumentCommandController implements CommandController {

        /**
         * The DOMViewerController.
         */
        protected DOMViewerController controller;

        /**
         * The current state of the command controller.
         */
        protected int state = HistoryBrowser.IDLE;

        /**
         * The constructor.
         *
         * @param controller
         *            The DOMViewerController
         */
        public DocumentCommandController(DOMViewerController controller) {
            this.controller = controller;
        }

        public void execute(final UndoableCommand command) {
            Runnable r = new Runnable() {
                public void run() {
                    state = HistoryBrowser.EXECUTING;
                    command.execute();
                    state = HistoryBrowser.IDLE;
                }
            };
            controller.performUpdate(r);
        }

        public void undo(final UndoableCommand command) {
            Runnable r = new Runnable() {
                public void run() {
                    state = HistoryBrowser.UNDOING;
                    command.undo();
                    state = HistoryBrowser.IDLE;
                }
            };
            controller.performUpdate(r);
        }

        public void redo(final UndoableCommand command) {
            Runnable r = new Runnable() {
                public void run() {
                    state = HistoryBrowser.REDOING;
                    command.redo();
                    state = HistoryBrowser.IDLE;
                }
            };
            controller.performUpdate(r);
        }

        public int getState() {
            return state;
        }
    }
}
