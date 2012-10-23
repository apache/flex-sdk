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

import java.awt.BorderLayout;
import java.awt.CardLayout;
import java.awt.Color;
import java.awt.Component;
import java.awt.Container;
import java.awt.FileDialog;
import java.awt.FlowLayout;
import java.awt.Font;
import java.awt.Frame;
import java.awt.Insets;
import java.awt.Dimension;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.ItemEvent;
import java.awt.event.ItemListener;
import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.io.File;
import java.io.IOException;
import java.util.Enumeration;
import java.util.StringTokenizer;

import javax.swing.AbstractButton;
import javax.swing.BorderFactory;
import javax.swing.ButtonGroup;
import javax.swing.DefaultListModel;
import javax.swing.Icon;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JComboBox;
import javax.swing.JDialog;
import javax.swing.JFileChooser;
import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.JPanel;
import javax.swing.JRadioButton;
import javax.swing.JScrollPane;
import javax.swing.JTextField;
import javax.swing.JToggleButton;
import javax.swing.JToolBar;
import javax.swing.LookAndFeel;
import javax.swing.ListSelectionModel;
import javax.swing.SwingConstants;
import javax.swing.UIManager;
import javax.swing.event.ListDataEvent;
import javax.swing.event.ListDataListener;
import javax.swing.event.ListSelectionEvent;
import javax.swing.event.ListSelectionListener;

import org.apache.flex.forks.batik.ext.swing.GridBagConstants;
import org.apache.flex.forks.batik.ext.swing.JGridBagPanel;
import org.apache.flex.forks.batik.util.Platform;
import org.apache.flex.forks.batik.util.PreferenceManager;
import org.apache.flex.forks.batik.util.gui.CSSMediaPanel;
import org.apache.flex.forks.batik.util.gui.LanguageDialog;

/**
 * Dialog that displays user preferences.
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: PreferenceDialog.java 498740 2007-01-22 18:35:57Z dvholten $
 */
public class PreferenceDialog extends JDialog
    implements GridBagConstants {

    /**
     * The return value if 'OK' is chosen.
     */
    public static final int OK_OPTION = 0;

    /**
     * The return value if 'Cancel' is chosen.
     */
    public static final int CANCEL_OPTION = 1;

    //////////////////////////////////////////////////////////////
    // GUI Resources Keys
    //////////////////////////////////////////////////////////////

    public static final String PREFERENCE_KEY_TITLE_PREFIX
        = "PreferenceDialog.title.";

    public static final String PREFERENCE_KEY_TITLE_DIALOG
        = "PreferenceDialog.title.dialog";

    public static final String PREFERENCE_KEY_LABEL_RENDERING_OPTIONS
        = "PreferenceDialog.label.rendering.options";

    public static final String PREFERENCE_KEY_LABEL_ANIMATION_RATE_LIMITING
        = "PreferenceDialog.label.animation.rate.limiting";

    public static final String PREFERENCE_KEY_LABEL_OTHER_OPTIONS
        = "PreferenceDialog.label.other.options";

    public static final String PREFERENCE_KEY_LABEL_ENABLE_DOUBLE_BUFFERING
        = "PreferenceDialog.label.enable.double.buffering";

    public static final String PREFERENCE_KEY_LABEL_SHOW_RENDERING
        = "PreferenceDialog.label.show.rendering";

    public static final String PREFERENCE_KEY_LABEL_AUTO_ADJUST_WINDOW
        = "PreferenceDialog.label.auto.adjust.window";

    public static final String PREFERENCE_KEY_LABEL_SELECTION_XOR_MODE
        = "PreferenceDialog.label.selection.xor.mode";

    public static final String PREFERENCE_KEY_LABEL_ANIMATION_LIMIT_CPU
        = "PreferenceDialog.label.animation.limit.cpu";

    public static final String PREFERENCE_KEY_LABEL_PERCENT
        = "PreferenceDialog.label.percent";

    public static final String PREFERENCE_KEY_LABEL_ANIMATION_LIMIT_FPS
        = "PreferenceDialog.label.animation.limit.fps";

    public static final String PREFERENCE_KEY_LABEL_FPS
        = "PreferenceDialog.label.fps";

    public static final String PREFERENCE_KEY_LABEL_ANIMATION_LIMIT_UNLIMITED
        = "PreferenceDialog.label.animation.limit.unlimited";

    public static final String PREFERENCE_KEY_LABEL_SHOW_DEBUG_TRACE
        = "PreferenceDialog.label.show.debug.trace";

    public static final String PREFERENCE_KEY_LABEL_IS_XML_PARSER_VALIDATING
        = "PreferenceDialog.label.is.xml.parser.validating";

    public static final String PREFERENCE_KEY_LABEL_GRANT_SCRIPTS_ACCESS_TO
        = "PreferenceDialog.label.grant.scripts.access.to";

    public static final String PREFERENCE_KEY_LABEL_LOAD_SCRIPTS
        = "PreferenceDialog.label.load.scripts";

    public static final String PREFERENCE_KEY_LABEL_ALLOWED_SCRIPT_ORIGIN
        = "PreferenceDialog.label.allowed.script.origin";

    public static final String PREFERENCE_KEY_LABEL_ALLOWED_RESOURCE_ORIGIN
        = "PreferenceDialog.label.allowed.resource.origin";

    public static final String PREFERENCE_KEY_LABEL_ENFORCE_SECURE_SCRIPTING
        = "PreferenceDialog.label.enforce.secure.scripting";

    public static final String PREFERENCE_KEY_LABEL_FILE_SYSTEM
        = "PreferenceDialog.label.file.system";

    public static final String PREFERENCE_KEY_LABEL_ALL_NETWORK
        = "PreferenceDialog.label.all.network";

    public static final String PREFERENCE_KEY_LABEL_JAVA_JAR_FILES
        = "PreferenceDialog.label.java.jar.files";

    public static final String PREFERENCE_KEY_LABEL_ECMASCRIPT
        = "PreferenceDialog.label.ecmascript";

    public static final String PREFERENCE_KEY_LABEL_ORIGIN_ANY
        = "PreferenceDialog.label.origin.any";

    public static final String PREFERENCE_KEY_LABEL_ORIGIN_DOCUMENT
        = "PreferenceDialog.label.origin.document";

    public static final String PREFERENCE_KEY_LABEL_ORIGIN_EMBEDDED
        = "PreferenceDialog.label.origin.embedded";

    public static final String PREFERENCE_KEY_LABEL_ORIGIN_NONE
        = "PreferenceDialog.label.origin.none";

    public static final String PREFERENCE_KEY_LABEL_USER_STYLESHEET
        = "PreferenceDialog.label.user.stylesheet";

    public static final String PREFERENCE_KEY_LABEL_CSS_MEDIA_TYPES
        = "PreferenceDialog.label.css.media.types";

    public static final String PREFERENCE_KEY_LABEL_ENABLE_USER_STYLESHEET
        = "PreferenceDialog.label.enable.user.stylesheet";

    public static final String PREFERENCE_KEY_LABEL_BROWSE
        = "PreferenceDialog.label.browse";

    public static final String PREFERENCE_KEY_LABEL_ADD
        = "PreferenceDialog.label.add";

    public static final String PREFERENCE_KEY_LABEL_REMOVE
        = "PreferenceDialog.label.remove";

    public static final String PREFERENCE_KEY_LABEL_CLEAR
        = "PreferenceDialog.label.clear";

    public static final String PREFERENCE_KEY_LABEL_HTTP_PROXY
        = "PreferenceDialog.label.http.proxy";

    public static final String PREFERENCE_KEY_LABEL_HOST
        = "PreferenceDialog.label.host";

    public static final String PREFERENCE_KEY_LABEL_PORT
        = "PreferenceDialog.label.port";

    public static final String PREFERENCE_KEY_LABEL_COLON
        = "PreferenceDialog.label.colon";

    public static final String PREFERENCE_KEY_BROWSE_TITLE
        = "PreferenceDialog.BrowseWindow.title";


    //////////////////////////////////////////////////////////////
    // Following are the preference keys used in the
    // PreferenceManager model.
    //////////////////////////////////////////////////////////////

    public static final String PREFERENCE_KEY_LANGUAGES
        = "preference.key.languages";

    public static final String PREFERENCE_KEY_IS_XML_PARSER_VALIDATING
        = "preference.key.is.xml.parser.validating";

    public static final String PREFERENCE_KEY_USER_STYLESHEET
        = "preference.key.user.stylesheet";

    public static final String PREFERENCE_KEY_USER_STYLESHEET_ENABLED
        = "preference.key.user.stylesheet.enabled";

    public static final String PREFERENCE_KEY_SHOW_RENDERING
        = "preference.key.show.rendering";

    public static final String PREFERENCE_KEY_AUTO_ADJUST_WINDOW
        = "preference.key.auto.adjust.window";

    public static final String PREFERENCE_KEY_ENABLE_DOUBLE_BUFFERING
        = "preference.key.enable.double.buffering";

    public static final String PREFERENCE_KEY_SHOW_DEBUG_TRACE
        = "preference.key.show.debug.trace";

    public static final String PREFERENCE_KEY_SELECTION_XOR_MODE
        = "preference.key.selection.xor.mode";

    public static final String PREFERENCE_KEY_PROXY_HOST
        = "preference.key.proxy.host";

    public static final String PREFERENCE_KEY_CSS_MEDIA
        = "preference.key.cssmedia";

    public static final String PREFERENCE_KEY_DEFAULT_FONT_FAMILY
        = "preference.key.default.font.family";

    public static final String PREFERENCE_KEY_PROXY_PORT
        = "preference.key.proxy.port";

    public static final String PREFERENCE_KEY_ENFORCE_SECURE_SCRIPTING
        = "preference.key.enforce.secure.scripting";

    public static final String PREFERENCE_KEY_GRANT_SCRIPT_FILE_ACCESS
        = "preference.key.grant.script.file.access";

    public static final String PREFERENCE_KEY_GRANT_SCRIPT_NETWORK_ACCESS
        = "preference.key.grant.script.network.access";

    public static final String PREFERENCE_KEY_LOAD_ECMASCRIPT
        = "preference.key.load.ecmascript";

    public static final String PREFERENCE_KEY_LOAD_JAVA
        = "preference.key.load.java.script";

    public static final String PREFERENCE_KEY_ALLOWED_SCRIPT_ORIGIN
        = "preference.key.allowed.script.origin";

    public static final String PREFERENCE_KEY_ALLOWED_EXTERNAL_RESOURCE_ORIGIN
        = "preference.key.allowed.external.resource.origin";

    public static final String PREFERENCE_KEY_ANIMATION_RATE_LIMITING_MODE
        = "preference.key.animation.rate.limiting.mode";

    public static final String PREFERENCE_KEY_ANIMATION_RATE_LIMITING_CPU
        = "preference.key.animation.rate.limiting.cpu";

    public static final String PREFERENCE_KEY_ANIMATION_RATE_LIMITING_FPS
        = "preference.key.animation.rate.limiting.fps";

    public static final String LABEL_OK
        = "PreferenceDialog.label.ok";

    public static final String LABEL_CANCEL
        = "PreferenceDialog.label.cancel";

    /**
     * <tt>PreferenceManager</tt> used to store and retrieve
     * preferences
     */
    protected PreferenceManager model;

    /**
     * The configuration panel that holds each of the configuration pages.
     */
    protected JConfigurationPanel configurationPanel;

    protected JCheckBox userStylesheetEnabled;
    protected JLabel userStylesheetLabel;
    protected JTextField userStylesheet;
    protected JButton userStylesheetBrowse;
    protected JCheckBox showRendering;
    protected JCheckBox autoAdjustWindow;
    protected JCheckBox enableDoubleBuffering;
    protected JCheckBox showDebugTrace;
    protected JCheckBox selectionXorMode;
    protected JCheckBox isXMLParserValidating;
    protected JRadioButton animationLimitUnlimited;
    protected JRadioButton animationLimitCPU;
    protected JRadioButton animationLimitFPS;
    protected JLabel animationLimitCPULabel;
    protected JLabel animationLimitFPSLabel;
    protected JTextField animationLimitCPUAmount;
    protected JTextField animationLimitFPSAmount;
    protected JCheckBox enforceSecureScripting;
    protected JCheckBox grantScriptFileAccess;
    protected JCheckBox grantScriptNetworkAccess;
    protected JCheckBox loadJava;
    protected JCheckBox loadEcmascript;
    protected JComboBox allowedScriptOrigin;
    protected JComboBox allowedResourceOrigin;
    protected JList mediaList;
    protected JButton mediaListRemoveButton;
    protected JButton mediaListClearButton;
    protected JTextField host;
    protected JTextField port;
    protected LanguageDialog.Panel languagePanel;
    protected DefaultListModel mediaListModel = new DefaultListModel();

    /**
     * Code indicating whether the dialog was okayed or cancelled.
     */
    protected int returnCode;

    /**
     * Returns whether the current LAF is Metal Steel.
     */
    protected static boolean isMetalSteel() {
        if (!UIManager.getLookAndFeel().getName().equals("Metal")) {
            return false;
        }
        try {
            LookAndFeel laf = UIManager.getLookAndFeel();
            laf.getClass().getMethod("getCurrentTheme", new Class[0]);
            return false;
        } catch (Exception e) {
        }
        return true;
    }

    /**
     * Creates a new PreferenceDialog with the given model.
     */
    public PreferenceDialog(Frame owner, PreferenceManager model) {
        super(owner, true);

        if (model == null) {
            throw new IllegalArgumentException();
        }

        this.model = model;
        buildGUI();
        initializeGUI();
        pack();

        addWindowListener(new WindowAdapter() {
            public void windowClosing(WindowEvent e) {
                if (Platform.isOSX) {
                    savePreferences();
                }
            }
        });
    }

    /**
     * Returns the preference manager used by this dialog.
     */
    public PreferenceManager getPreferenceManager() {
        return model;
    }

    /**
     * Initializes the GUI components with the values from the model.
     */
    protected void initializeGUI() {
        boolean b;
        float f;
        int i;
        String s;

        // General options
        enableDoubleBuffering.setSelected
            (model.getBoolean(PREFERENCE_KEY_ENABLE_DOUBLE_BUFFERING));
        showRendering.setSelected
            (model.getBoolean(PREFERENCE_KEY_SHOW_RENDERING));
        autoAdjustWindow.setSelected
            (model.getBoolean(PREFERENCE_KEY_AUTO_ADJUST_WINDOW));
        selectionXorMode.setSelected
            (model.getBoolean(PREFERENCE_KEY_SELECTION_XOR_MODE));

        switch (model.getInteger(PREFERENCE_KEY_ANIMATION_RATE_LIMITING_MODE)) {
            case 0: // unlimited
                animationLimitUnlimited.setSelected(true);
                break;
            case 2: // fps
                animationLimitFPS.setSelected(true);
                break;
            // case 1: // %cpu
            default:
                animationLimitCPU.setSelected(true);
                break;
        }
        f = model.getFloat(PREFERENCE_KEY_ANIMATION_RATE_LIMITING_CPU);
        if (f <= 0f || f > 100f) {
            f = 85f;
        } else {
            f *= 100;
        }
        if (((int) f) == f) {
            animationLimitCPUAmount.setText(Integer.toString((int) f));
        } else {
            animationLimitCPUAmount.setText(Float.toString(f));
        }
        f = model.getFloat(PREFERENCE_KEY_ANIMATION_RATE_LIMITING_FPS);
        if (f <= 0f) {
            f = 10f;
        }
        if (((int) f) == f) {
            animationLimitFPSAmount.setText(Integer.toString((int) f));
        } else {
            animationLimitFPSAmount.setText(Float.toString(f));
        }

        showDebugTrace.setSelected
            (model.getBoolean(PREFERENCE_KEY_SHOW_DEBUG_TRACE));
        isXMLParserValidating.setSelected
            (model.getBoolean(PREFERENCE_KEY_IS_XML_PARSER_VALIDATING));

        // Security options
        enforceSecureScripting.setSelected
            (model.getBoolean(PREFERENCE_KEY_ENFORCE_SECURE_SCRIPTING));
        grantScriptFileAccess.setSelected
            (model.getBoolean(PREFERENCE_KEY_GRANT_SCRIPT_FILE_ACCESS));
        grantScriptNetworkAccess.setSelected
            (model.getBoolean(PREFERENCE_KEY_GRANT_SCRIPT_NETWORK_ACCESS));
        loadJava.setSelected
            (model.getBoolean(PREFERENCE_KEY_LOAD_JAVA));
        loadEcmascript.setSelected
            (model.getBoolean(PREFERENCE_KEY_LOAD_ECMASCRIPT));

        i = model.getInteger(PREFERENCE_KEY_ALLOWED_SCRIPT_ORIGIN);
        switch (i) {
            case ResourceOrigin.ANY:
                allowedScriptOrigin.setSelectedIndex(0);
                break;
            case ResourceOrigin.DOCUMENT:
                allowedScriptOrigin.setSelectedIndex(1);
                break;
            case ResourceOrigin.EMBEDED:
                allowedScriptOrigin.setSelectedIndex(2);
                break;
            default:
                allowedScriptOrigin.setSelectedIndex(3);
                break;
        }

        i = model.getInteger(PREFERENCE_KEY_ALLOWED_EXTERNAL_RESOURCE_ORIGIN);
        switch (i) {
            case ResourceOrigin.ANY:
                allowedResourceOrigin.setSelectedIndex(0);
                break;
            case ResourceOrigin.DOCUMENT:
                allowedResourceOrigin.setSelectedIndex(1);
                break;
            case ResourceOrigin.EMBEDED:
                allowedResourceOrigin.setSelectedIndex(2);
                break;
            default:
                allowedResourceOrigin.setSelectedIndex(3);
                break;
        }

        // Language options
        languagePanel.setLanguages(model.getString(PREFERENCE_KEY_LANGUAGES));

        // Stylesheet options
        s = model.getString(PREFERENCE_KEY_CSS_MEDIA);
        mediaListModel.removeAllElements();
        StringTokenizer st = new StringTokenizer(s, " ");
        while (st.hasMoreTokens()) {
            mediaListModel.addElement(st.nextToken());
        }

        userStylesheet.setText(model.getString(PREFERENCE_KEY_USER_STYLESHEET));
        b = model.getBoolean(PREFERENCE_KEY_USER_STYLESHEET_ENABLED);
        userStylesheetEnabled.setSelected(b);

        // Network options
        host.setText(model.getString(PREFERENCE_KEY_PROXY_HOST));
        port.setText(model.getString(PREFERENCE_KEY_PROXY_PORT));

        // Set some components disabled initially
        b = enableDoubleBuffering.isSelected();
        showRendering.setEnabled(b);

        b = animationLimitCPU.isSelected();
        animationLimitCPUAmount.setEnabled(b);
        animationLimitCPULabel.setEnabled(b);

        b = animationLimitFPS.isSelected();
        animationLimitFPSAmount.setEnabled(b);
        animationLimitFPSLabel.setEnabled(b);

        b = enforceSecureScripting.isSelected();
        grantScriptFileAccess.setEnabled(b);
        grantScriptNetworkAccess.setEnabled(b);

        b = userStylesheetEnabled.isSelected();
        userStylesheetLabel.setEnabled(b);
        userStylesheet.setEnabled(b);
        userStylesheetBrowse.setEnabled(b);

        mediaListRemoveButton.setEnabled(!mediaList.isSelectionEmpty());
        mediaListClearButton.setEnabled(!mediaListModel.isEmpty());
    }

    /**
     * Stores the current settings in the PreferenceManager model.
     */
    protected void savePreferences() {
        model.setString(PREFERENCE_KEY_LANGUAGES,
                        languagePanel.getLanguages());
        model.setString(PREFERENCE_KEY_USER_STYLESHEET,
                        userStylesheet.getText());
        model.setBoolean(PREFERENCE_KEY_USER_STYLESHEET_ENABLED,
                         userStylesheetEnabled.isSelected());
        model.setBoolean(PREFERENCE_KEY_SHOW_RENDERING,
                         showRendering.isSelected());
        model.setBoolean(PREFERENCE_KEY_AUTO_ADJUST_WINDOW,
                         autoAdjustWindow.isSelected());
        model.setBoolean(PREFERENCE_KEY_ENABLE_DOUBLE_BUFFERING,
                         enableDoubleBuffering.isSelected());
        model.setBoolean(PREFERENCE_KEY_SHOW_DEBUG_TRACE,
                         showDebugTrace.isSelected());
        model.setBoolean(PREFERENCE_KEY_SELECTION_XOR_MODE,
                         selectionXorMode.isSelected());
        model.setBoolean(PREFERENCE_KEY_IS_XML_PARSER_VALIDATING,
                         isXMLParserValidating.isSelected());
        model.setBoolean(PREFERENCE_KEY_ENFORCE_SECURE_SCRIPTING,
                         enforceSecureScripting.isSelected());
        model.setBoolean(PREFERENCE_KEY_GRANT_SCRIPT_FILE_ACCESS,
                         grantScriptFileAccess.isSelected());
        model.setBoolean(PREFERENCE_KEY_GRANT_SCRIPT_NETWORK_ACCESS,
                         grantScriptNetworkAccess.isSelected());
        model.setBoolean(PREFERENCE_KEY_LOAD_JAVA,
                         loadJava.isSelected());
        model.setBoolean(PREFERENCE_KEY_LOAD_ECMASCRIPT,
                         loadEcmascript.isSelected());
        int i;
        switch (allowedScriptOrigin.getSelectedIndex()) {
            case 0:
                i = ResourceOrigin.ANY;
                break;
            case 1:
                i = ResourceOrigin.DOCUMENT;
                break;
            case 2:
                i = ResourceOrigin.EMBEDED;
                break;
            // case 3:
            default:
                i = ResourceOrigin.NONE;
                break;
        }
        model.setInteger(PREFERENCE_KEY_ALLOWED_SCRIPT_ORIGIN, i);
        switch (allowedResourceOrigin.getSelectedIndex()) {
            case 0:
                i = ResourceOrigin.ANY;
                break;
            case 1:
                i = ResourceOrigin.DOCUMENT;
                break;
            case 2:
                i = ResourceOrigin.EMBEDED;
                break;
            // case 3:
            default:
                i = ResourceOrigin.NONE;
                break;
        }
        model.setInteger(PREFERENCE_KEY_ALLOWED_EXTERNAL_RESOURCE_ORIGIN, i);
        i = 1;
        if (animationLimitFPS.isSelected()) {
            i = 2;
        } else if (animationLimitUnlimited.isSelected()) {
            i = 0;
        }
        model.setInteger(PREFERENCE_KEY_ANIMATION_RATE_LIMITING_MODE, i);
        float f;
        try {
            f = Float.parseFloat(animationLimitCPUAmount.getText()) / 100;
            if (f <= 0f || f >= 1.0f) {
                f = 0.85f;
            }
        } catch (NumberFormatException e) {
            f = 0.85f;
        }
        model.setFloat(PREFERENCE_KEY_ANIMATION_RATE_LIMITING_CPU, f);
        try {
            f = Float.parseFloat(animationLimitFPSAmount.getText());
            if (f <= 0) {
                f = 15f;
            }
        } catch (NumberFormatException e) {
            f = 15f;
        }
        model.setFloat(PREFERENCE_KEY_ANIMATION_RATE_LIMITING_FPS, f);
        model.setString(PREFERENCE_KEY_PROXY_HOST,
                        host.getText());
        model.setString(PREFERENCE_KEY_PROXY_PORT,
                        port.getText());
        StringBuffer sb = new StringBuffer();
        Enumeration e = mediaListModel.elements();
        while (e.hasMoreElements()) {
            sb.append((String) e.nextElement());
            sb.append(' ');
        }
        model.setString(PREFERENCE_KEY_CSS_MEDIA, sb.toString());
    }

    /**
     * Builds the UI for this dialog.
     */
    protected void buildGUI() {
        JPanel panel = new JPanel(new BorderLayout());

        configurationPanel = new JConfigurationPanel();
        addConfigPanel("general", buildGeneralPanel());
        addConfigPanel("security", buildSecurityPanel());
        addConfigPanel("language", buildLanguagePanel());
        addConfigPanel("stylesheet", buildStylesheetPanel());
        addConfigPanel("network", buildNetworkPanel());

        panel.add(configurationPanel);

        if (!Platform.isOSX) {
            setTitle(Resources.getString(PREFERENCE_KEY_TITLE_DIALOG));
            panel.add(buildButtonsPanel(), BorderLayout.SOUTH);
        }
        setResizable(false);

        getContentPane().add(panel);
    }

    /**
     * Adds a panel to the configuration panel.
     */
    protected void addConfigPanel(String id, JPanel c) {
        String name = Resources.getString(PREFERENCE_KEY_TITLE_PREFIX + id);
        ImageIcon icon1 =
            new ImageIcon(PreferenceDialog.class.getResource
                              ("resources/icon-" + id + ".png"));
        ImageIcon icon2 =
            new ImageIcon(PreferenceDialog.class.getResource
                              ("resources/icon-" + id + "-dark.png"));
        configurationPanel.addPanel(name, icon1, icon2, c);
    }

    /**
     * Creates the OK/Cancel button panel.
     */
    protected JPanel buildButtonsPanel() {
        JPanel p = new JPanel(new FlowLayout(FlowLayout.RIGHT));
        JButton okButton = new JButton(Resources.getString(LABEL_OK));
        JButton cancelButton = new JButton(Resources.getString(LABEL_CANCEL));
        p.add(okButton);
        p.add(cancelButton);

        okButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent e) {
                    setVisible(false);
                    returnCode = OK_OPTION;
                    savePreferences();
                    dispose();
                }
            });

        cancelButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent e) {
                    setVisible(false);
                    returnCode = CANCEL_OPTION;
                    dispose();
                }
            });

        addKeyListener(new KeyAdapter() {
                public void keyPressed(KeyEvent e) {
                    switch (e.getKeyCode()) {
                        case KeyEvent.VK_ESCAPE:
                            returnCode = CANCEL_OPTION;
                            break;
                        case KeyEvent.VK_ENTER:
                            returnCode = OK_OPTION;
                            break;
                        default:
                            return;
                    }
                    setVisible(false);
                    dispose();
                }
            });

        return p;
    }

    /**
     * Builds the General panel.
     */
    protected JPanel buildGeneralPanel() {
        JGridBagPanel.InsetsManager im = new JGridBagPanel.InsetsManager() {
            protected Insets i1 = new Insets(5, 5, 0, 0);
            protected Insets i2 = new Insets(5, 0, 0, 0);
            protected Insets i3 = new Insets(0, 5, 0, 0);
            protected Insets i4 = new Insets(0, 0, 0, 0);

            public Insets getInsets(int x, int y) {
                if (y == 4 || y == 9) {
                    return x == 0 ? i2 : i1;
                }
                return x == 0 ? i4 : i3;
            }
        };

        JGridBagPanel p = new JGridBagPanel(im);
        p.setBorder(BorderFactory.createEmptyBorder(16, 16, 16, 16));

        JLabel renderingLabel = new JLabel(Resources.getString(PREFERENCE_KEY_LABEL_RENDERING_OPTIONS));
        enableDoubleBuffering = new JCheckBox(Resources.getString(PREFERENCE_KEY_LABEL_ENABLE_DOUBLE_BUFFERING));
        enableDoubleBuffering.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent evt) {
                showRendering.setEnabled(enableDoubleBuffering.isSelected());
            }
        });
        showRendering = new JCheckBox(Resources.getString(PREFERENCE_KEY_LABEL_SHOW_RENDERING));
        Insets in = showRendering.getMargin();
        showRendering.setMargin(new Insets(in.top, in.left + 24, in.bottom, in.right));
        selectionXorMode = new JCheckBox(Resources.getString(PREFERENCE_KEY_LABEL_SELECTION_XOR_MODE));
        autoAdjustWindow = new JCheckBox(Resources.getString(PREFERENCE_KEY_LABEL_AUTO_ADJUST_WINDOW));
        JLabel animLabel = new JLabel(Resources.getString(PREFERENCE_KEY_LABEL_ANIMATION_RATE_LIMITING));
        animationLimitCPU = new JRadioButton(Resources.getString(PREFERENCE_KEY_LABEL_ANIMATION_LIMIT_CPU));
        JPanel cpuPanel = new JPanel();
        cpuPanel.setLayout(new FlowLayout(FlowLayout.LEADING, 3, 0));
        cpuPanel.setBorder(BorderFactory.createEmptyBorder(0, 24, 0, 0));
        animationLimitCPUAmount = new JTextField();
        animationLimitCPUAmount.setPreferredSize(new Dimension(40, 20));
        cpuPanel.add(animationLimitCPUAmount);
        animationLimitCPULabel = new JLabel(Resources.getString(PREFERENCE_KEY_LABEL_PERCENT));
        cpuPanel.add(animationLimitCPULabel);
        animationLimitFPS = new JRadioButton(Resources.getString(PREFERENCE_KEY_LABEL_ANIMATION_LIMIT_FPS));
        JPanel fpsPanel = new JPanel();
        fpsPanel.setLayout(new FlowLayout(FlowLayout.LEADING, 3, 0));
        fpsPanel.setBorder(BorderFactory.createEmptyBorder(0, 24, 0, 0));
        animationLimitFPSAmount = new JTextField();
        animationLimitFPSAmount.setPreferredSize(new Dimension(40, 20));
        fpsPanel.add(animationLimitFPSAmount);
        animationLimitFPSLabel = new JLabel(Resources.getString(PREFERENCE_KEY_LABEL_FPS));
        fpsPanel.add(animationLimitFPSLabel);
        animationLimitUnlimited = new JRadioButton(Resources.getString(PREFERENCE_KEY_LABEL_ANIMATION_LIMIT_UNLIMITED));
        ButtonGroup g = new ButtonGroup();
        g.add(animationLimitCPU);
        g.add(animationLimitFPS);
        g.add(animationLimitUnlimited);
        ActionListener l = new ActionListener() {
            public void actionPerformed(ActionEvent evt) {
                boolean b = animationLimitCPU.isSelected();
                animationLimitCPUAmount.setEnabled(b);
                animationLimitCPULabel.setEnabled(b);
                b = animationLimitFPS.isSelected();
                animationLimitFPSAmount.setEnabled(b);
                animationLimitFPSLabel.setEnabled(b);
            }
        };
        animationLimitCPU.addActionListener(l);
        animationLimitFPS.addActionListener(l);
        animationLimitUnlimited.addActionListener(l);
        JLabel otherLabel = new JLabel(Resources.getString(PREFERENCE_KEY_LABEL_OTHER_OPTIONS));
        showDebugTrace = new JCheckBox(Resources.getString(PREFERENCE_KEY_LABEL_SHOW_DEBUG_TRACE));
        isXMLParserValidating = new JCheckBox(Resources.getString(PREFERENCE_KEY_LABEL_IS_XML_PARSER_VALIDATING));

        p.add(renderingLabel,          0, 0, 1, 1, EAST, NONE, 0, 0);
        p.add(enableDoubleBuffering,   1, 0, 1, 1, WEST, NONE, 0, 0);
        p.add(showRendering,           1, 1, 1, 1, WEST, NONE, 0, 0);
        p.add(autoAdjustWindow,        1, 2, 1, 1, WEST, NONE, 0, 0);
        p.add(selectionXorMode,        1, 3, 1, 1, WEST, NONE, 0, 0);
        p.add(animLabel,               0, 4, 1, 1, EAST, NONE, 0, 0);
        p.add(animationLimitCPU,       1, 4, 1, 1, WEST, NONE, 0, 0);
        p.add(cpuPanel,                1, 5, 1, 1, WEST, NONE, 0, 0);
        p.add(animationLimitFPS,       1, 6, 1, 1, WEST, NONE, 0, 0);
        p.add(fpsPanel,                1, 7, 1, 1, WEST, NONE, 0, 0);
        p.add(animationLimitUnlimited, 1, 8, 1, 1, WEST, NONE, 0, 0);
        p.add(otherLabel,              0, 9, 1, 1, EAST, NONE, 0, 0);
        p.add(showDebugTrace,          1, 9, 1, 1, WEST, NONE, 0, 0);
        p.add(isXMLParserValidating,   1,10, 1, 1, WEST, NONE, 0, 0);

        return p;
    }

    /**
     * Builds the Security panel.
     */
    protected JPanel buildSecurityPanel() {
        JGridBagPanel.InsetsManager im = new JGridBagPanel.InsetsManager() {
            protected Insets i1 = new Insets(5, 5, 0, 0);
            protected Insets i2 = new Insets(5, 0, 0, 0);
            protected Insets i3 = new Insets(0, 5, 0, 0);
            protected Insets i4 = new Insets(0, 0, 0, 0);

            public Insets getInsets(int x, int y) {
                if (y == 1 || y == 3 || y == 5 || y == 6) {
                    return x == 0 ? i2 : i1;
                }
                return x == 0 ? i4 : i3;
            }
        };

        JGridBagPanel p = new JGridBagPanel(im);
        p.setBorder(BorderFactory.createEmptyBorder(16, 16, 16, 16));

        enforceSecureScripting = new JCheckBox(Resources.getString(PREFERENCE_KEY_LABEL_ENFORCE_SECURE_SCRIPTING));
        enforceSecureScripting.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                boolean b = enforceSecureScripting.isSelected();
                grantScriptFileAccess.setEnabled(b);
                grantScriptNetworkAccess.setEnabled(b);
            }
        });

        JLabel grantScript = new JLabel(Resources.getString(PREFERENCE_KEY_LABEL_GRANT_SCRIPTS_ACCESS_TO));
        grantScript.setVerticalAlignment(SwingConstants.TOP);
        grantScript.setOpaque(true);
        grantScriptFileAccess = new JCheckBox(Resources.getString(PREFERENCE_KEY_LABEL_FILE_SYSTEM));
        grantScriptNetworkAccess = new JCheckBox(Resources.getString(PREFERENCE_KEY_LABEL_ALL_NETWORK));

        JLabel loadScripts = new JLabel(Resources.getString(PREFERENCE_KEY_LABEL_LOAD_SCRIPTS));
        loadScripts.setVerticalAlignment(SwingConstants.TOP);
        loadJava = new JCheckBox(Resources.getString(PREFERENCE_KEY_LABEL_JAVA_JAR_FILES));
        loadEcmascript = new JCheckBox(Resources.getString(PREFERENCE_KEY_LABEL_ECMASCRIPT));

        String[] origins = {
            Resources.getString(PREFERENCE_KEY_LABEL_ORIGIN_ANY),
            Resources.getString(PREFERENCE_KEY_LABEL_ORIGIN_DOCUMENT),
            Resources.getString(PREFERENCE_KEY_LABEL_ORIGIN_EMBEDDED),
            Resources.getString(PREFERENCE_KEY_LABEL_ORIGIN_NONE)
        };
        JLabel scriptOriginLabel = new JLabel(Resources.getString(PREFERENCE_KEY_LABEL_ALLOWED_SCRIPT_ORIGIN));
        allowedScriptOrigin = new JComboBox(origins);
        JLabel resourceOriginLabel = new JLabel(Resources.getString(PREFERENCE_KEY_LABEL_ALLOWED_RESOURCE_ORIGIN));
        allowedResourceOrigin = new JComboBox(origins);

        p.add(enforceSecureScripting,   1, 0, 1, 1, WEST, NONE, 1, 0);
        p.add(grantScript,              0, 1, 1, 1, EAST, NONE, 1, 0);
        p.add(grantScriptFileAccess,    1, 1, 1, 1, WEST, NONE, 1, 0);
        p.add(grantScriptNetworkAccess, 1, 2, 1, 1, WEST, NONE, 1, 0);
        p.add(loadScripts,              0, 3, 1, 1, EAST, NONE, 1, 0);
        p.add(loadJava,                 1, 3, 1, 1, WEST, NONE, 1, 0);
        p.add(loadEcmascript,           1, 4, 1, 1, WEST, NONE, 1, 0);
        p.add(scriptOriginLabel,        0, 5, 1, 1, EAST, NONE, 1, 0);
        p.add(allowedScriptOrigin,      1, 5, 1, 1, WEST, NONE, 1, 0);
        p.add(resourceOriginLabel,      0, 6, 1, 1, EAST, NONE, 1, 0);
        p.add(allowedResourceOrigin,    1, 6, 1, 1, WEST, NONE, 1, 0);

        return p;
    }

    /**
     * Builds the Language panel.
     */
    protected JPanel buildLanguagePanel() {
        JPanel p = new JPanel();
        p.setBorder(BorderFactory.createEmptyBorder(16, 16, 16, 16));
        languagePanel = new LanguageDialog.Panel();
        languagePanel.setBorder(BorderFactory.createEmptyBorder());
        Color c = UIManager.getColor("Window.background");
        languagePanel.getComponent(0).setBackground(c);
        languagePanel.getComponent(1).setBackground(c);
        p.add(languagePanel);
        return p;
    }

    /**
     * Builds the Stylesheet panel.
     */
    protected JPanel buildStylesheetPanel() {
        JGridBagPanel.InsetsManager im = new JGridBagPanel.InsetsManager() {
            protected Insets i1 = new Insets(5, 5, 0, 0);
            protected Insets i2 = new Insets(5, 0, 0, 0);
            protected Insets i3 = new Insets(0, 5, 0, 0);
            protected Insets i4 = new Insets(0, 0, 0, 0);

            public Insets getInsets(int x, int y) {
                if (y >= 1 && y <= 5) {
                    return x == 0 ? i2 : i1;
                }
                return x == 0 ? i4 : i3;
            }
        };

        JGridBagPanel p = new JGridBagPanel(im);
        p.setBorder(BorderFactory.createEmptyBorder(16, 16, 16, 16));

        userStylesheetEnabled = new JCheckBox(Resources.getString(PREFERENCE_KEY_LABEL_ENABLE_USER_STYLESHEET));
        userStylesheetEnabled.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                boolean b = userStylesheetEnabled.isSelected();
                userStylesheetLabel.setEnabled(b);
                userStylesheet.setEnabled(b);
                userStylesheetBrowse.setEnabled(b);
            }
        });

        userStylesheetLabel = new JLabel(Resources.getString(PREFERENCE_KEY_LABEL_USER_STYLESHEET));
        userStylesheet = new JTextField();
        userStylesheetBrowse = new JButton(Resources.getString(PREFERENCE_KEY_LABEL_BROWSE));
        userStylesheetBrowse.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                File f = null;
                if (Platform.isOSX) {
                    FileDialog fileDialog =
                        new FileDialog
                            ((Frame) getOwner(),
                             Resources.getString(PREFERENCE_KEY_BROWSE_TITLE));
                    fileDialog.setVisible(true);
                    String filename = fileDialog.getFile();
                    if (filename != null) {
                        String dirname = fileDialog.getDirectory();
                        f = new File(dirname, filename);
                    }
                } else {
                    JFileChooser fileChooser = new JFileChooser(new File("."));
                    fileChooser.setDialogTitle
                        (Resources.getString(PREFERENCE_KEY_BROWSE_TITLE));
                    fileChooser.setFileHidingEnabled(false);

                    int choice =
                    fileChooser.showOpenDialog(PreferenceDialog.this);
                    if (choice == JFileChooser.APPROVE_OPTION) {
                        f = fileChooser.getSelectedFile();
                    }
                }
                if (f != null) {
                    try {
                        userStylesheet.setText(f.getCanonicalPath());
                    } catch (IOException ex) {
                    }
                }
            }
        });

        JLabel mediaLabel = new JLabel(Resources.getString(PREFERENCE_KEY_LABEL_CSS_MEDIA_TYPES));
        mediaLabel.setVerticalAlignment(SwingConstants.TOP);
        mediaList = new JList();
        mediaList.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        mediaList.setModel(mediaListModel);
        mediaList.addListSelectionListener(new ListSelectionListener() {
            public void valueChanged(ListSelectionEvent e) {
                updateMediaListButtons();
            }
        });
        mediaListModel.addListDataListener(new ListDataListener() {
            public void contentsChanged(ListDataEvent e) {
                updateMediaListButtons();
            }
            public void intervalAdded(ListDataEvent e) {
                updateMediaListButtons();
            }
            public void intervalRemoved(ListDataEvent e) {
                updateMediaListButtons();
            }
        });
        JScrollPane scrollPane = new JScrollPane();
        scrollPane.setBorder(BorderFactory.createLoweredBevelBorder());
        scrollPane.getViewport().add(mediaList);

        JButton addButton = new JButton(Resources.getString(PREFERENCE_KEY_LABEL_ADD));
        addButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                CSSMediaPanel.AddMediumDialog dialog =
                    new CSSMediaPanel.AddMediumDialog(PreferenceDialog.this);
                dialog.pack();
                dialog.setVisible(true);

                if (dialog.getReturnCode() ==
                            CSSMediaPanel.AddMediumDialog.CANCEL_OPTION
                        || dialog.getMedium() == null) {
                    return;
                }

                String medium = dialog.getMedium().trim();
                if (medium.length() == 0 || mediaListModel.contains(medium)) {
                    return;
                }

                for (int i = 0;
                        i < mediaListModel.size() && medium != null;
                        ++i) {
                    String s = (String) mediaListModel.getElementAt(i);
                    int c = medium.compareTo(s);
                    if (c == 0) {
                        medium = null;
                    } else if (c < 0) {
                        mediaListModel.insertElementAt(medium, i);
                        medium = null;
                    }
                }
                if (medium != null) {
                    mediaListModel.addElement(medium);
                }
            }
        });

        mediaListRemoveButton = new JButton(Resources.getString(PREFERENCE_KEY_LABEL_REMOVE));
        mediaListRemoveButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                int index = mediaList.getSelectedIndex();
                mediaList.clearSelection();
                if (index >= 0) {
                    mediaListModel.removeElementAt(index);
                }
            }
        });

        mediaListClearButton = new JButton(Resources.getString(PREFERENCE_KEY_LABEL_CLEAR));
        mediaListClearButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                mediaList.clearSelection();
                mediaListModel.removeAllElements();
            }
        });

        p.add(userStylesheetEnabled, 1, 0, 2, 1, WEST, NONE, 0, 0);
        p.add(userStylesheetLabel,   0, 1, 1, 1, EAST, NONE, 0, 0);
        p.add(userStylesheet,        1, 1, 1, 1, WEST, HORIZONTAL, 1, 0);
        p.add(userStylesheetBrowse,  2, 1, 1, 1, WEST, HORIZONTAL, 0, 0);
        p.add(mediaLabel,            0, 2, 1, 1, EAST, VERTICAL, 0, 0);
        p.add(scrollPane,            1, 2, 1, 4, WEST, BOTH, 1, 1);
        p.add(new JPanel(),          2, 2, 1, 1, WEST, BOTH, 0, 1);
        p.add(addButton,             2, 3, 1, 1, SOUTHWEST, HORIZONTAL, 0, 0);
        p.add(mediaListRemoveButton, 2, 4, 1, 1, SOUTHWEST, HORIZONTAL, 0, 0);
        p.add(mediaListClearButton,  2, 5, 1, 1, SOUTHWEST, HORIZONTAL, 0, 0);

        return p;
    }

    /**
     * Updates the disabled state of the buttons next to the media type list.
     */
    protected void updateMediaListButtons() {
        mediaListRemoveButton.setEnabled(!mediaList.isSelectionEmpty());
        mediaListClearButton.setEnabled(!mediaListModel.isEmpty());
    }

    /**
     * Builds the Network panel.
     */
    protected JPanel buildNetworkPanel() {
        JGridBagPanel p = new JGridBagPanel();
        p.setBorder(BorderFactory.createEmptyBorder(16, 16, 16, 16));

        JLabel proxyLabel = new JLabel(Resources.getString(PREFERENCE_KEY_LABEL_HTTP_PROXY));
        JLabel hostLabel = new JLabel(Resources.getString(PREFERENCE_KEY_LABEL_HOST));
        JLabel portLabel = new JLabel(Resources.getString(PREFERENCE_KEY_LABEL_PORT));
        JLabel colonLabel = new JLabel(Resources.getString(PREFERENCE_KEY_LABEL_COLON));
        Font f = hostLabel.getFont();
        float size = f.getSize2D() * 0.85f;
        f = f.deriveFont(size);
        hostLabel.setFont(f);
        portLabel.setFont(f);
        host = new JTextField();
        host.setPreferredSize(new Dimension(200, 20));
        port = new JTextField();
        port.setPreferredSize(new Dimension(40, 20));

        p.add(proxyLabel, 0, 0, 1, 1, EAST, NONE, 0, 0);
        p.add(host,       1, 0, 1, 1, WEST, HORIZONTAL, 0, 0);
        p.add(colonLabel, 2, 0, 1, 1, WEST, NONE, 0, 0);
        p.add(port,       3, 0, 1, 1, WEST, HORIZONTAL, 0, 0);
        p.add(hostLabel,  1, 1, 1, 1, WEST, NONE, 0, 0);
        p.add(portLabel,  3, 1, 1, 1, WEST, NONE, 0, 0);

        return p;
    }

    /**
     * Shows the dialog.
     */
    public int showDialog() {
        if (Platform.isOSX) {
            // No OK/Cancel buttons in OS X, so always save the options.
            returnCode = OK_OPTION;
        } else {
            // Default to Cancel on other platforms, if the window is closed
            // without clicking one of the buttons.
            returnCode = CANCEL_OPTION;
        }
        pack();
        setVisible(true);
        return returnCode;
    }

    /**
     * A paged panel for configuration windows.
     */
    protected class JConfigurationPanel extends JPanel {

        /**
         * The toolbar that allows selection between the pages.
         */
        protected JToolBar toolbar;

        /**
         * The panel that holds the configuration pages.
         */
        protected JPanel panel;

        /**
         * The layout manager for the configuration pages.
         */
        protected CardLayout layout;

        /**
         * The button group for the configuration page buttons.
         */
        protected ButtonGroup group;

        /**
         * The currently selected page.
         */
        protected int page = -1;

        /**
         * Creates a new JConfigurationPanel.
         */
        public JConfigurationPanel() {
            toolbar = new JToolBar();
            toolbar.setFloatable(false);
            toolbar.setLayout(new FlowLayout(FlowLayout.LEADING, 0, 0));
            toolbar.add(new JToolBar.Separator(new Dimension(8, 8)));
            if (Platform.isOSX || isMetalSteel()) {
                toolbar.setBackground(new Color(0xf8, 0xf8, 0xf8));
            }
            toolbar.setOpaque(true);
            panel = new JPanel();
            layout = Platform.isOSX ? new ResizingCardLayout() : new CardLayout();
            group = new ButtonGroup();
            setLayout(new BorderLayout());
            panel.setLayout(layout);
            add(toolbar, BorderLayout.NORTH);
            add(panel);
        }

        /**
         * Adds a panel to this configuration panel.
         * @param text the text to use on the toolbar button
         * @param icon the icon to use on the toolbar button
         * @param icon2 the icon to use on the toolbar button when the mouse
         *              button is held down
         * @param p the configuration panel page
         */
        public void addPanel(String text, Icon icon, Icon icon2, JPanel p) {
            JToggleButton button = new JToggleButton(text, icon);
            button.setVerticalTextPosition(AbstractButton.BOTTOM);
            button.setHorizontalTextPosition(AbstractButton.CENTER);
            button.setContentAreaFilled(false);
            try {
                // JDK 1.4+
                // button.setIconTextGap(0);
                AbstractButton.class.getMethod
                    ("setIconTextGap", new Class[] { Integer.TYPE })
                    .invoke(button, new Object[] { new Integer(0) });
            } catch (Exception ex) {
            }
            button.setPressedIcon(icon2);
            group.add(button);
            toolbar.add(button);
            toolbar.setBorder(BorderFactory.createMatteBorder(0, 0, 1, 0, Color.gray));
            button.addItemListener(new ItemListener() {
                public void itemStateChanged(ItemEvent e) {
                    JToggleButton b = (JToggleButton) e.getSource();
                    switch (e.getStateChange()) {
                        case ItemEvent.SELECTED:
                            select(b);
                            break;
                        case ItemEvent.DESELECTED:
                            unselect(b);
                            break;
                    }
                }
            });
            if (panel.getComponentCount() == 0) {
                button.setSelected(true);
                page = 0;
            } else {
                unselect(button);
            }
            panel.add(p, text.intern());
        }

        /**
         * Returns the index of the given configuration page.
         */
        protected int getComponentIndex(Component c) {
            Container p = c.getParent();
            int count = p.getComponentCount();
            for (int i = 0; i < count; i++) {
                if (p.getComponent(i) == c) {
                    return i;
                }
            }
            return -1;
        }

        /**
         * Updates the style of the given button to indicate that it is
         * selected.
         */
        protected void select(JToggleButton b) {
            b.setOpaque(true);
            b.setBackground
                (Platform.isOSX ? new Color(0xd8, 0xd8, 0xd8)
                       : UIManager.getColor("List.selectionBackground"));
            b.setForeground(UIManager.getColor("List.selectionForeground"));
            b.setBorder(BorderFactory.createCompoundBorder
                            (BorderFactory.createMatteBorder
                                 (0, 1, 0, 1, new Color(160, 160, 160)),
                             BorderFactory.createEmptyBorder(4, 3, 4, 3)));
            layout.show(panel, b.getText().intern());
            page = getComponentIndex(b) - 1;
            if (Platform.isOSX) {
                PreferenceDialog.this.setTitle(b.getText());
            }
            PreferenceDialog.this.pack();
            panel.grabFocus();
        }

        /**
         * Updates the style of the given button to indicate that it is
         * unselected.
         */
        protected void unselect(JToggleButton b) {
            b.setOpaque(false);
            b.setBackground(null);
            b.setForeground(UIManager.getColor("Button.foreground"));
            b.setBorder(BorderFactory.createEmptyBorder(5, 4, 5, 4));
        }

        /**
         * A CardLayout that returns a preferred height based on the currently
         * displayed component.
         */
        protected class ResizingCardLayout extends CardLayout {

            /**
             * Creates a new ResizingCardLayout.
             */
            public ResizingCardLayout() {
                super(0, 0);
            }

            public Dimension preferredLayoutSize(Container parent) {
                Dimension d = super.preferredLayoutSize(parent);
                if (page != -1) {
                    Dimension cur = panel.getComponent(page).getPreferredSize();
                    d = new Dimension((int) d.getWidth(),
                                      (int) cur.getHeight());
                }
                return d;
            }
        }
    }
}
