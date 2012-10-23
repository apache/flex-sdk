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

package org.apache.flex.forks.batik.util.gui.resource;

import java.util.Iterator;
import java.util.List;
import java.util.MissingResourceException;
import java.util.ResourceBundle;

import javax.swing.JButton;
import javax.swing.JToolBar;

import org.apache.flex.forks.batik.util.resources.ResourceFormatException;
import org.apache.flex.forks.batik.util.resources.ResourceManager;

/**
 * This class represents a tool bar factory which builds
 * tool bars from the content of a resource file. <br>
 *
 * The resource entries format is (for a tool bar named 'ToolBar'):<br>
 * <pre>
 *   ToolBar           = Item1 Item2 - Item3 ...
 *   See ButtonFactory.java for details about the items
 *   ...
 * '-' represents a separator
 * </pre>
 * All entries are optional.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: ToolBarFactory.java 592619 2007-11-07 05:47:24Z cam $
 */
public class ToolBarFactory extends ResourceManager {
    // Constants
    //
    private static final String SEPARATOR = "-";

    /**
     * The button factory
     */
    private ButtonFactory buttonFactory;

    /**
     * Creates a new tool bar factory
     * @param rb the resource bundle that contains the menu bar
     *           description.
     * @param am the actions to add to menu items
     */
    public ToolBarFactory(ResourceBundle rb, ActionMap am) {
        super(rb);
        buttonFactory = new ButtonFactory(rb, am);
    }

    /**
     * Creates a tool bar
     * @param name the name of the menu bar in the resource bundle
     * @throws MissingResourceException if one of the keys that compose the
     *         tool bar is missing.
     *         It is not thrown if the action key is missing.
     * @throws ResourceFormatException  if a boolean is malformed
     * @throws MissingListenerException if an item action is not found in the
     * action map.
     */
    public JToolBar createJToolBar(String name)
        throws MissingResourceException,
               ResourceFormatException,
               MissingListenerException {
        JToolBar result  = new JToolBar();
        List     buttons = getStringList(name);
        Iterator it      = buttons.iterator();

        while (it.hasNext()) {
            String s = (String)it.next();
            if (s.equals(SEPARATOR)) {
                result.add(new JToolbarSeparator());
            } else {
                result.add(createJButton(s));
            }
        }
        return result;
    }

    /**
     * Creates and returns a new swing button
     * @param name the name of the button in the resource bundle
     * @throws MissingResourceException if key is not the name of a button.
     *         It is not thrown if the mnemonic and the action keys are missing
     * @throws ResourceFormatException if the mnemonic is not a single
     *         character
     * @throws MissingListenerException if the button action is not found in
     *         the action map.
     */
    public JButton createJButton(String name)
        throws MissingResourceException,
               ResourceFormatException,
               MissingListenerException {
        return buttonFactory.createJToolbarButton(name);
    }
}
