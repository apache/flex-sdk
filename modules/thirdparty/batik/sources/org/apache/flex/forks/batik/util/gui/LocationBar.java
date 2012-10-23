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
import java.awt.Dimension;
import java.awt.event.ActionListener;
import java.net.URL;
import java.util.Locale;
import java.util.MissingResourceException;
import java.util.ResourceBundle;

import javax.swing.ImageIcon;
import javax.swing.JComboBox;
import javax.swing.JLabel;
import javax.swing.JPanel;

import org.apache.flex.forks.batik.util.resources.ResourceManager;

/**
 * This class represents a location bar.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: LocationBar.java 592619 2007-11-07 05:47:24Z cam $
 */
public class LocationBar extends JPanel {
    /**
     * The gui resources file name
     */
    protected static final String RESOURCES =
        "org.apache.flex.forks.batik.util.gui.resources.LocationBar";

    /**
     * The resource bundle
     */
    protected static ResourceBundle bundle;

    /**
     * The resource manager
     */
    protected static ResourceManager rManager;
    static {
        bundle = ResourceBundle.getBundle(RESOURCES, Locale.getDefault());
        rManager = new ResourceManager(bundle);
    }

    /**
     * The combo box
     */
    protected JComboBox comboBox;

    /**
     * Creates a new location bar.
     */
    public LocationBar() {
        super(new BorderLayout(5, 5));
        JLabel label = new JLabel(rManager.getString("Panel.label"));
        add("West", label);
        try {
            String s = rManager.getString("Panel.icon");
            URL url  = getClass().getResource(s);
            if (url != null) {
                label.setIcon(new ImageIcon(url));
            }
        } catch (MissingResourceException e) {
        }
        add("Center", comboBox = new JComboBox());
        comboBox.setEditable(true);
    }

    /**
     * Adds an action listener to this component.
     */
    public void addActionListener(ActionListener listener) {
        comboBox.addActionListener(listener);
    }

    /**
     * returns the current item text.
     */
    public String getText() {
        return (String)comboBox.getEditor().getItem();
    }

    /**
     * Sets the current text.
     */
    public void setText(String text) {
        comboBox.getEditor().setItem(text);
    }

    /**
     * Adds the given text to the history.
     */
    public void addToHistory(String text) {
        comboBox.addItem(text);
        comboBox.setPreferredSize
            (new Dimension(0, comboBox.getPreferredSize().height));
    }
}
