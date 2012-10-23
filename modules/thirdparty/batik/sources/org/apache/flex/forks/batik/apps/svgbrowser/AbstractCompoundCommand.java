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

/**
 * Abstract compound command. Supports the execute / undo / redo of more than
 * one command
 *
 * @version $Id$
 */
public abstract class AbstractCompoundCommand extends AbstractUndoableCommand {

    /**
     * The atom UndoableCommand command list.
     */
    protected ArrayList atomCommands;

    /**
     * Constructor.
     */
    public AbstractCompoundCommand() {
        this.atomCommands = new ArrayList();
    }

    /**
     * Adds the given command to the atomCommand list.
     *
     * @param command
     *            The given command
     */
    public void addCommand(UndoableCommand command) {
        if (command.shouldExecute()) {
            atomCommands.add(command);
        }
    }

    public void execute() {
        int n = atomCommands.size();
        for (int i = 0; i < n; i++) {
            UndoableCommand cmd = (UndoableCommand) atomCommands.get(i);
            cmd.execute();
        }
    }

    public void undo() {
        int size = atomCommands.size();
        for (int i = size - 1; i >= 0; i--) {
            UndoableCommand command = (UndoableCommand) atomCommands.get(i);
            command.undo();
        }
    }

    public void redo() {
        int n = atomCommands.size();
        for (int i = 0; i < n; i++) {
            UndoableCommand cmd = (UndoableCommand) atomCommands.get(i);
            cmd.redo();
        }
    }

    public boolean shouldExecute() {
        boolean shouldExecute = true;
        if (atomCommands.size() == 0) {
            shouldExecute = false;
        }
        int n = atomCommands.size();
        for (int i = 0; i < n && shouldExecute; i++) {
            UndoableCommand command = (UndoableCommand) atomCommands.get(i);
            shouldExecute = command.shouldExecute() && shouldExecute;
        }
        return shouldExecute;
    }

    /**
     * Returns the command number that this compound command contains.
     *
     * @return The atom command number
     */
    public int getCommandNumber() {
        return atomCommands.size();
    }
}
