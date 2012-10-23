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

package org.apache.flex.forks.batik.swing.svg;

import java.awt.Component;
import javax.swing.JDialog;
import javax.swing.JOptionPane;
import org.apache.flex.forks.batik.util.gui.JErrorPane;

/**
 * One line Class Desc
 *
 * Methods users may want to implement:
 *    displayMessage
 *
 * @author <a href="mailto:deweese@apache.org">deweese</a>
 * @version $Id: SVGUserAgentGUIAdapter.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SVGUserAgentGUIAdapter extends SVGUserAgentAdapter{
    public Component parentComponent;
    public SVGUserAgentGUIAdapter(Component parentComponent) {
        this.parentComponent = parentComponent;
    }

    /**
     * Displays an error message.
     */
    public void displayError(String message) {
        JOptionPane pane = new JOptionPane(message, JOptionPane.ERROR_MESSAGE);
        JDialog dialog = pane.createDialog(parentComponent, "ERROR");
        dialog.setModal(false);
        dialog.setVisible(true);
    }

    /**
     * Displays an error resulting from the specified Exception.
     */
    public void displayError(Exception ex) {
        JErrorPane pane = new JErrorPane(ex, JOptionPane.ERROR_MESSAGE);
        JDialog dialog = pane.createDialog(parentComponent, "ERROR");
        dialog.setModal(false);
        dialog.setVisible(true);
    }

    /**
     * Displays a message in the User Agent interface.
     * The given message is typically displayed in a status bar.
     */
    public void displayMessage(String message) {
        // Can't do anything don't have a status bar...
    }

    /**
     * Shows an alert dialog box.
     */
    public void showAlert(String message) {
        String str = "Script alert:\n" + message;
        JOptionPane.showMessageDialog(parentComponent, str);
    }

    /**
     * Shows a prompt dialog box.
     */
    public String showPrompt(String message) {
        String str = "Script prompt:\n" + message;
        return JOptionPane.showInputDialog(parentComponent, str);
    }
    
    /**
     * Shows a prompt dialog box.
     */
    public String showPrompt(String message, String defaultValue) {
        String str = "Script prompt:\n" + message;
        return (String)JOptionPane.showInputDialog
            (parentComponent, str, null,
             JOptionPane.PLAIN_MESSAGE,
             null, null, defaultValue);
    }

    /**
     * Shows a confirm dialog box.
     */
    public boolean showConfirm(String message) {
        String str = "Script confirm:\n" + message;
        return JOptionPane.showConfirmDialog
            (parentComponent, str, 
             "Confirm", JOptionPane.YES_NO_OPTION) == JOptionPane.YES_OPTION;
    }
}
