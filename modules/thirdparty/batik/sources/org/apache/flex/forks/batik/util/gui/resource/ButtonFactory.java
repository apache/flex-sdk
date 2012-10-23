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

import java.net.URL;
import java.util.MissingResourceException;
import java.util.ResourceBundle;

import javax.swing.AbstractButton;
import javax.swing.Action;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JRadioButton;
import javax.swing.JToggleButton;

import org.apache.flex.forks.batik.util.resources.ResourceFormatException;
import org.apache.flex.forks.batik.util.resources.ResourceManager;

/**
 * This class represents a button factory which builds
 * buttons from the content of a resource bundle. <br>
 *
 * The resource entries format is (for a button named 'Button'):<br>
 * <pre>
 *   Button.text      = text
 *   Button.icon      = icon_name
 *   Button.mnemonic  = mnemonic
 *   Button.action    = action_name
 *   Button.selected  = true | false
 *   Button.tooltip   = tool tip text
 * where
 *   text, icon_name and action_name are strings
 *   mnemonic is a character
 * </pre>
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: ButtonFactory.java 594367 2007-11-13 00:40:53Z cam $
 */
public class ButtonFactory extends ResourceManager {
    // Constants
    //
    private static final String ICON_SUFFIX        = ".icon";
    private static final String TEXT_SUFFIX        = ".text";
    private static final String MNEMONIC_SUFFIX    = ".mnemonic";
    private static final String ACTION_SUFFIX      = ".action";
    private static final String SELECTED_SUFFIX    = ".selected";
    private static final String TOOLTIP_SUFFIX     = ".tooltip";

    /** The table which contains the actions */
    private ActionMap actions;

    /**
     * Creates a new button factory
     * @param rb the resource bundle that contains the buttons
     *           description.
     * @param am the actions to bind to the button
     */
    public ButtonFactory(ResourceBundle rb, ActionMap am) {
        super(rb);
        actions = am;
    }

    /**
     * Creates and returns a new swing button
     * @param name the name of the button in the resource bundle
     * @throws MissingResourceException if key is not the name of a button.
     *         It is not thrown if the mnemonic and the action keys are missing
     * @throws ResourceFormatException if the mnemonic is not a single
     *         character
     * @throws MissingListenerException if the button action is not found in
     *         the action map
     */
    public JButton createJButton(String name)
        throws MissingResourceException,
               ResourceFormatException,
               MissingListenerException {
        JButton result;
        try {
            result = new JButton(getString(name+TEXT_SUFFIX));
        } catch (MissingResourceException e) {
            result = new JButton();
        }
        initializeButton(result, name);
        return result;
    }

    /**
     * Creates and returns a new swing button initialised
     * to be used as a toolbar button
     * @param name the name of the button in the resource bundle
     * @throws MissingResourceException if key is not the name of a button.
     *         It is not thrown if the mnemonic and the action keys are missing
     * @throws ResourceFormatException if the mnemonic is not a single
     *         character
     * @throws MissingListenerException if the button action is not found in
     *         the action map
     */
    public JButton createJToolbarButton(String name)
        throws MissingResourceException,
               ResourceFormatException,
               MissingListenerException {
        JButton result;
        try {
            result = new JToolbarButton(getString(name+TEXT_SUFFIX));
        } catch (MissingResourceException e) {
            result = new JToolbarButton();
        }
        initializeButton(result, name);
        return result;
    }
    
    /**
     * Creates and returns a new swing button initialised
     * to be used as a toolbar toggle button
     * @param name the name of the button in the resource bundle
     * @throws MissingResourceException if key is not the name of a button.
     *         It is not thrown if the mnemonic and the action keys are missing
     * @throws ResourceFormatException if the mnemonic is not a single
     *         character
     * @throws MissingListenerException if the button action is not found in
     *         the action map
     */
    public JToggleButton createJToolbarToggleButton(String name)
        throws MissingResourceException,
               ResourceFormatException,
               MissingListenerException {
        JToggleButton result;
        try {
            result = new JToolbarToggleButton(getString(name+TEXT_SUFFIX));
        } catch (MissingResourceException e) {
            result = new JToolbarToggleButton();
        }
        initializeButton(result, name);
        return result;
    }

    /**
     * Creates and returns a new swing radio button
     * @param name the name of the button in the resource bundle
     * @throws MissingResourceException if key is not the name of a button.
     *         It is not thrown if the mnemonic and the action keys are
     *         missing.
     * @throws ResourceFormatException if the mnemonic is not a single
     *         character.
     * @throws MissingListenerException if the button action is not found in
     *         the action map.
     */
    public JRadioButton createJRadioButton(String name)
        throws MissingResourceException,
               ResourceFormatException,
               MissingListenerException {
        JRadioButton result = new JRadioButton(getString(name+TEXT_SUFFIX));
        initializeButton(result, name);

        // is the button selected?
        try {
            result.setSelected(getBoolean(name+SELECTED_SUFFIX));
        } catch (MissingResourceException e) {
        }

        return result;
    }

    /**
     * Creates and returns a new swing check box
     * @param name the name of the button in the resource bundle
     * @throws MissingResourceException if key is not the name of a button.
     *         It is not thrown if the mnemonic and the action keys are missing
     * @throws ResourceFormatException if the mnemonic is not a single
     *         character.
     * @throws MissingListenerException if the button action is not found in
     *         the action map.
     */
    public JCheckBox createJCheckBox(String name)
        throws MissingResourceException,
               ResourceFormatException,
               MissingListenerException {
        JCheckBox result = new JCheckBox(getString(name+TEXT_SUFFIX));
        initializeButton(result, name);

        // is the button selected?
        try {
            result.setSelected(getBoolean(name+SELECTED_SUFFIX));
        } catch (MissingResourceException e) {
        }

        return result;
    }

    /**
     * Initializes a button
     * @param b    the button to initialize
     * @param name the button's name
     * @throws ResourceFormatException if the mnemonic is not a single
     *         character.
     * @throws MissingListenerException if the button action is not found
     *         in the action map.
     */
    private void initializeButton(AbstractButton b, String name)
        throws ResourceFormatException, MissingListenerException {
        // Action
        try {
            Action a = actions.getAction(getString(name+ACTION_SUFFIX));
            if (a == null) {
                throw new MissingListenerException("", "Action",
                                                   name+ACTION_SUFFIX);
            }
            b.setAction(a);
            try {
                b.setText(getString(name+TEXT_SUFFIX));
            } catch (MissingResourceException mre) {
                // not all buttons have text defined so just
                // ignore this exception.
            }
            if (a instanceof JComponentModifier) {
                ((JComponentModifier)a).addJComponent(b);
            }
        } catch (MissingResourceException e) {
        }

        // Icon
        try {
            String s = getString(name+ICON_SUFFIX);
            URL url  = actions.getClass().getResource(s);
            if (url != null) {
                b.setIcon(new ImageIcon(url));
            }
        } catch (MissingResourceException e) {
        }

        // Mnemonic
        try {
            String str = getString(name+MNEMONIC_SUFFIX);
            if (str.length() == 1) {
                b.setMnemonic(str.charAt(0));
            } else {
                throw new ResourceFormatException("Malformed mnemonic",
                                                  bundle.getClass().getName(),
                                                  name+MNEMONIC_SUFFIX);
            }
        } catch (MissingResourceException e) {
        }

        // ToolTip
        try {
            String s = getString(name+TOOLTIP_SUFFIX);
            if (s != null) {
                b.setToolTipText(s);
            }
        } catch (MissingResourceException e) {
        }
    }
}
