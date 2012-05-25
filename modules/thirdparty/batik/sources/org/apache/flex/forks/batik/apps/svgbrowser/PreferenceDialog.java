/*

   Copyright 2001-2003  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

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
import java.awt.Component;
import java.awt.Container;
import java.awt.FlowLayout;
import java.awt.Frame;
import java.awt.Rectangle;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Map;

import javax.swing.AbstractButton;
import javax.swing.BorderFactory;
import javax.swing.ButtonGroup;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JDialog;
import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.JPanel;
import javax.swing.JRadioButton;
import javax.swing.JScrollPane;
import javax.swing.JTabbedPane;
import javax.swing.JTextField;
import javax.swing.ListCellRenderer;
import javax.swing.UIManager;
import javax.swing.border.Border;
import javax.swing.event.ListSelectionEvent;
import javax.swing.event.ListSelectionListener;

import org.apache.flex.forks.batik.ext.swing.GridBagConstants;
import org.apache.flex.forks.batik.ext.swing.JGridBagPanel;
import org.apache.flex.forks.batik.util.PreferenceManager;
import org.apache.flex.forks.batik.util.gui.CSSMediaPanel;
import org.apache.flex.forks.batik.util.gui.LanguageDialog;
import org.apache.flex.forks.batik.util.gui.UserStyleDialog;

/**
 * Dialog that displays user preferences.
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: PreferenceDialog.java,v 1.21 2004/08/18 07:12:27 vhardy Exp $
 */
public class PreferenceDialog extends JDialog
    implements GridBagConstants {

    /**
     * The return value if 'OK' is chosen.
     */
    public final static int OK_OPTION = 0;

    /**
     * The return value if 'Cancel' is chosen.
     */
    public final static int CANCEL_OPTION = 1;

    //////////////////////////////////////////////////////////////
    // GUI Resources Keys
    //////////////////////////////////////////////////////////////

    public static final String ICON_USER_LANGUAGE
        = "PreferenceDialog.icon.userLanguagePref";

    public static final String ICON_USER_STYLESHEET
        = "PreferenceDialog.icon.userStylesheetPref";

    public static final String ICON_BEHAVIOR
        = "PreferenceDialog.icon.behaviorsPref";

    public static final String ICON_NETWORK
        = "PreferenceDialog.icon.networkPref";

    public static final String LABEL_USER_OPTIONS
        = "PreferenceDialog.label.user.options";

    public static final String LABEL_BEHAVIOR
        = "PreferenceDialog.label.behavior";

    public static final String LABEL_NETWORK
        = "PreferenceDialog.label.network";

    public static final String LABEL_USER_LANGUAGE
        = "PreferenceDialog.label.user.language";

    public static final String LABEL_USER_STYLESHEET
        = "PreferenceDialog.label.user.stylesheet";

    public static final String LABEL_USER_FONT
        = "PreferenceDialog.label.user.font";

    public static final String LABEL_APPLICATIONS
        = "PreferenceDialog.label.applications";

    public static final String LABEL_SHOW_RENDERING
        = "PreferenceDialog.label.show.rendering";

    public static final String LABEL_AUTO_ADJUST_WINDOW
        = "PreferenceDialog.label.auto.adjust.window";

    public static final String LABEL_ENABLE_DOUBLE_BUFFERING
        = "PreferenceDialog.label.enable.double.buffering";

    public static final String LABEL_SHOW_DEBUG_TRACE
        = "PreferenceDialog.label.show.debug.trace";

    public static final String LABEL_SELECTION_XOR_MODE
        = "PreferenceDialog.label.selection.xor.mode";

    public static final String LABEL_IS_XML_PARSER_VALIDATING
        = "PreferenceDialog.label.is.xml.parser.validating";

    public static final String LABEL_ENFORCE_SECURE_SCRIPTING
        = "PreferenceDialog.label.enforce.secure.scripting";

    public static final String LABEL_SECURE_SCRIPTING_TOGGLE
        = "PreferenceDialog.label.secure.scripting.toggle";

    public static final String LABEL_GRANT_SCRIPT_FILE_ACCESS
        = "PreferenceDialog.label.grant.script.file.access";

    public static final String LABEL_GRANT_SCRIPT_NETWORK_ACCESS
        = "PreferenceDialog.label.grant.script.network.access";

    public static final String LABEL_LOAD_JAVA
        = "PreferenceDialog.label.load.java";

    public static final String LABEL_LOAD_ECMASCRIPT
        = "PreferenceDialog.label.load.ecmascript";

    public static final String LABEL_HOST
        = "PreferenceDialog.label.host";

    public static final String LABEL_PORT
        = "PreferenceDialog.label.port";

    public static final String LABEL_OK
        = "PreferenceDialog.label.ok";

    public static final String LABEL_LOAD_SCRIPTS
        = "PreferenceDialog.label.load.scripts";

    public static final String LABEL_ORIGIN_ANY
        = "PreferenceDialog.label.origin.any";

    public static final String LABEL_ORIGIN_DOCUMENT
        = "PreferenceDialog.label.origin.document";

    public static final String LABEL_ORIGIN_EMBED
        = "PreferenceDialog.label.origin.embed";

    public static final String LABEL_ORIGIN_NONE
        = "PreferenceDialog.label.origin.none";

    public static final String LABEL_SCRIPT_ORIGIN
        = "PreferenceDialog.label.script.origin";

    public static final String LABEL_RESOURCE_ORIGIN
        = "PreferenceDialog.label.resource.origin";

    public static final String LABEL_CANCEL
        = "PreferenceDialog.label.cancel";

    public static final String TITLE_BROWSER_OPTIONS
        = "PreferenceDialog.title.browser.options";

    public static final String TITLE_BEHAVIOR
        = "PreferenceDialog.title.behavior";

    public static final String TITLE_SECURITY
        = "PreferenceDialog.title.security";

    public static final String TITLE_NETWORK
        = "PreferenceDialog.title.network";

    public static final String TITLE_DIALOG
        = "PreferenceDialog.title.dialog";

    public static final String CONFIG_HOST_TEXT_FIELD_LENGTH
        = "PreferenceDialog.config.host.text.field.length";

    public static final String CONFIG_PORT_TEXT_FIELD_LENGTH
        = "PreferenceDialog.config.port.text.field.length";

    public static final String CONFIG_OK_MNEMONIC
        = "PreferenceDialog.config.ok.mnemonic";

    public static final String CONFIG_CANCEL_MNEMONIC
        = "PreferenceDialog.config.cancel.mnemonic";

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
        = "preferenced.key.grant.script.network.access";

    public static final String PREFERENCE_KEY_LOAD_ECMASCRIPT
        = "preference.key.load.ecmascript";

    public static final String PREFERENCE_KEY_LOAD_JAVA
        = "preference.key.load.java.script";

    public static final String PREFERENCE_KEY_ALLOWED_SCRIPT_ORIGIN
        = "preference.key.allowed.script.origin";

    public static final String PREFERENCE_KEY_ALLOWED_EXTERNAL_RESOURCE_ORIGIN
        = "preference.key.allowed.external.resource.origin";

    /**
     * <tt>PreferenceManager</tt> used to store and retrieve
     * preferences
     */
    protected PreferenceManager model;

    /**
     * Allows selection of the desired configuration panel
     */
    protected ConfigurationPanelSelector configPanelSelector;

    /**
     * Allows selection of the user languages
     */
    protected LanguageDialog.Panel languagePanel;

    /**
     * Allows selection of a user stylesheet
     */
    protected UserStyleDialog.Panel userStylesheetPanel;

    protected JCheckBox showRendering;

    protected JCheckBox autoAdjustWindow;

    protected JCheckBox showDebugTrace;

    protected JCheckBox enableDoubleBuffering;

    protected JCheckBox selectionXorMode;

    protected JCheckBox isXMLParserValidating;

    protected JCheckBox enforceSecureScripting;

    protected JCheckBox grantScriptFileAccess;

    protected JCheckBox grantScriptNetworkAccess;

    protected JCheckBox loadJava;

    protected JCheckBox loadEcmascript;

    protected ButtonGroup scriptOriginGroup;

    protected ButtonGroup resourceOriginGroup;

    protected JTextField host, port;

    protected CSSMediaPanel cssMediaPanel;

    /**
     * Code indicating whether the dialog was OKayed
     * or cancelled
     */
    protected int returnCode;

    /**
     * Default constructor
     */
    public PreferenceDialog(PreferenceManager model){
        super((Frame)null, true);

        if(model == null){
            throw new IllegalArgumentException();
        }

        this.model = model;
        buildGUI();
        initializeGUI();
        pack();
    }

    /**
     * Returns the preference manager used by this dialog.
     */
    public PreferenceManager getPreferenceManager() {
        return model;
    }

    /**
     * Initializes the GUI components with the values
     * from the model.
     */
    protected void initializeGUI(){
        //
        // Initialize language. The set of languages is
        // defined by a String.
        //
        String languages = model.getString(PREFERENCE_KEY_LANGUAGES);
        languagePanel.setLanguages(languages);

        //
        // Initializes the User Stylesheet
        //
        String userStylesheetPath = model.getString(PREFERENCE_KEY_USER_STYLESHEET);
        userStylesheetPanel.setPath(userStylesheetPath);

        //
        // Initializes the browser options
        //
        showRendering.setSelected(model.getBoolean(PREFERENCE_KEY_SHOW_RENDERING));
        autoAdjustWindow.setSelected(model.getBoolean(PREFERENCE_KEY_AUTO_ADJUST_WINDOW));
        enableDoubleBuffering.setSelected(model.getBoolean(PREFERENCE_KEY_ENABLE_DOUBLE_BUFFERING));
        showDebugTrace.setSelected(model.getBoolean(PREFERENCE_KEY_SHOW_DEBUG_TRACE));
        selectionXorMode.setSelected(model.getBoolean(PREFERENCE_KEY_SELECTION_XOR_MODE));

        isXMLParserValidating.setSelected(model.getBoolean(PREFERENCE_KEY_IS_XML_PARSER_VALIDATING));
        enforceSecureScripting.setSelected(model.getBoolean(PREFERENCE_KEY_ENFORCE_SECURE_SCRIPTING));
        grantScriptFileAccess.setSelected(model.getBoolean(PREFERENCE_KEY_GRANT_SCRIPT_FILE_ACCESS));
        grantScriptNetworkAccess.setSelected(model.getBoolean(PREFERENCE_KEY_GRANT_SCRIPT_NETWORK_ACCESS));
        loadJava.setSelected(model.getBoolean(PREFERENCE_KEY_LOAD_JAVA));
        loadEcmascript.setSelected(model.getBoolean(PREFERENCE_KEY_LOAD_ECMASCRIPT));

        String allowedScriptOrigin = "" + model.getInteger(PREFERENCE_KEY_ALLOWED_SCRIPT_ORIGIN);
        if (allowedScriptOrigin == null || "".equals(allowedScriptOrigin)) {
            allowedScriptOrigin = "" + ResourceOrigin.NONE;
        }

        Enumeration e = scriptOriginGroup.getElements();
        while (e.hasMoreElements()) {
            AbstractButton ab = (AbstractButton)e.nextElement();
            String ac = ab.getActionCommand();
            if (allowedScriptOrigin.equals(ac)) {
                ab.setSelected(true);
            }
        }

        String allowedResourceOrigin = "" + model.getInteger(PREFERENCE_KEY_ALLOWED_EXTERNAL_RESOURCE_ORIGIN);
        if (allowedResourceOrigin == null || "".equals(allowedResourceOrigin)) {
            allowedResourceOrigin = "" + ResourceOrigin.NONE;
        }

        e = resourceOriginGroup.getElements();
        while (e.hasMoreElements()) {
            AbstractButton ab = (AbstractButton)e.nextElement();
            String ac = ab.getActionCommand();
            if (allowedResourceOrigin.equals(ac)) {
                ab.setSelected(true);
            }
        }

        showRendering.setEnabled
            (!model.getBoolean(PREFERENCE_KEY_ENABLE_DOUBLE_BUFFERING));
        grantScriptFileAccess.setEnabled
            (model.getBoolean(PREFERENCE_KEY_ENFORCE_SECURE_SCRIPTING));
        grantScriptNetworkAccess.setEnabled
            (model.getBoolean(PREFERENCE_KEY_ENFORCE_SECURE_SCRIPTING));

        //
        // Initialize the proxy options
        //
        host.setText(model.getString(PREFERENCE_KEY_PROXY_HOST));
        port.setText(model.getString(PREFERENCE_KEY_PROXY_PORT));

        //
        // Initialize the CSS media
        //
        cssMediaPanel.setMedia(model.getString(PREFERENCE_KEY_CSS_MEDIA));
        //
        // Sets the dialog's title
        //
        setTitle(Resources.getString(TITLE_DIALOG));
    }

    /**
     * Stores current setting in PreferenceManager model
     */
    protected void savePreferences(){
        model.setString(PREFERENCE_KEY_LANGUAGES,
                        languagePanel.getLanguages());
        model.setString(PREFERENCE_KEY_USER_STYLESHEET,
                        userStylesheetPanel.getPath());
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
        model.setInteger(PREFERENCE_KEY_ALLOWED_SCRIPT_ORIGIN,
                         (new Integer(scriptOriginGroup.getSelection().getActionCommand())).intValue());
        model.setInteger(PREFERENCE_KEY_ALLOWED_EXTERNAL_RESOURCE_ORIGIN,
                         (new Integer(resourceOriginGroup.getSelection().getActionCommand())).intValue());
        model.setString(PREFERENCE_KEY_PROXY_HOST,
                        host.getText());
        model.setString(PREFERENCE_KEY_PROXY_PORT,
                        port.getText());
        model.setString(PREFERENCE_KEY_CSS_MEDIA,
                        cssMediaPanel.getMediaAsString());
    }

    /**
     * Builds the UI for this dialog
     */
    protected void buildGUI(){
        JPanel panel = new JPanel(new BorderLayout());

        Component config = buildConfigPanel();
        Component list = buildConfigPanelList();

        panel.add(list, BorderLayout.WEST);
        panel.add(config, BorderLayout.CENTER);
        panel.add(buildButtonsPanel(), BorderLayout.SOUTH);
        panel.setBorder(BorderFactory.createEmptyBorder(2, 2, 0, 0));

        getContentPane().add(panel);
    }

    /**
     * Creates the OK/Cancel buttons panel
     */
    protected JPanel buildButtonsPanel() {
        JPanel  p = new JPanel(new FlowLayout(FlowLayout.RIGHT));
        JButton okButton = new JButton(Resources.getString(LABEL_OK));
        okButton.setMnemonic(Resources.getCharacter(CONFIG_OK_MNEMONIC));
        JButton cancelButton = new JButton(Resources.getString(LABEL_CANCEL));
        cancelButton.setMnemonic(Resources.getCharacter(CONFIG_CANCEL_MNEMONIC));
        p.add(okButton);
        p.add(cancelButton);

        okButton.addActionListener(new ActionListener(){
                public void actionPerformed(ActionEvent e){
                    setVisible(false);
                    returnCode = OK_OPTION;
                    savePreferences();
                    dispose();
                }
            });

        cancelButton.addActionListener(new ActionListener(){
                public void actionPerformed(ActionEvent e){
                    setVisible(false);
                    returnCode = CANCEL_OPTION;
                    dispose();
                }
            });

        addKeyListener(new KeyAdapter(){
                public void keyPressed(KeyEvent e){
                    if(e.getKeyCode() == KeyEvent.VK_ESCAPE){
                        setVisible(false);
                        returnCode = CANCEL_OPTION;
                        dispose();
                    }
                }
            });

        return p;
    }

    protected Component buildConfigPanelList(){
        String[] configList
            = { Resources.getString(LABEL_NETWORK),
                Resources.getString(LABEL_USER_LANGUAGE),
                Resources.getString(LABEL_BEHAVIOR),
                Resources.getString(LABEL_USER_STYLESHEET),
                };

        final JList list = new JList(configList);
        list.addListSelectionListener(new ListSelectionListener(){
                public void valueChanged(ListSelectionEvent evt){
                    if(!evt.getValueIsAdjusting()){
                        configPanelSelector.select(list.getSelectedValue().toString());
                    }
                }
            });
        list.setVisibleRowCount(4);

        // Set Cell Renderer
        ClassLoader cl = this.getClass().getClassLoader();
        Map map= new Hashtable();
        map.put(Resources.getString(LABEL_USER_LANGUAGE), new ImageIcon(cl.getResource(Resources.getString(ICON_USER_LANGUAGE))));
        map.put(Resources.getString(LABEL_USER_STYLESHEET), new ImageIcon(cl.getResource(Resources.getString(ICON_USER_STYLESHEET))));
        map.put(Resources.getString(LABEL_BEHAVIOR), new ImageIcon(cl.getResource(Resources.getString(ICON_BEHAVIOR))));
        map.put(Resources.getString(LABEL_NETWORK), new ImageIcon(cl.getResource(Resources.getString(ICON_NETWORK))));

        list.setCellRenderer(new IconCellRenderer(map));

        list.setSelectedIndex(0);

        return new JScrollPane(list);
    }

    protected Component buildConfigPanel(){
        JPanel configPanel = new JPanel();
        CardLayout cardLayout = new CardLayout();
        configPanel.setLayout(cardLayout);
        configPanel.add(buildUserLanguage(),
                        Resources.getString(LABEL_USER_LANGUAGE));

        configPanel.add(buildUserStyleSheet(),
                        Resources.getString(LABEL_USER_STYLESHEET));

        configPanel.add(buildBehavior(),
                        Resources.getString(LABEL_BEHAVIOR));

        configPanel.add(buildNetwork(),
                        Resources.getString(LABEL_NETWORK));

        configPanel.add(buildApplications(),
                        Resources.getString(LABEL_APPLICATIONS));

        configPanelSelector = new ConfigurationPanelSelector(configPanel,
                                                             cardLayout);

        return configPanel;
    }

    protected Component buildUserOptions(){
        JTabbedPane p = new JTabbedPane();
        p.add(buildUserLanguage(),
              Resources.getString(LABEL_USER_LANGUAGE));
        p.add(buildUserStyleSheet(),
              Resources.getString(LABEL_USER_STYLESHEET));
        p.add(buildUserFont(),
              Resources.getString(LABEL_USER_FONT));
        return p;
    }

    protected Component buildUserLanguage(){
        languagePanel = new LanguageDialog.Panel();
        return languagePanel;
    }

    protected Component buildUserStyleSheet(){
        JPanel panel = new JPanel(new BorderLayout());
        panel.setBorder(BorderFactory.createEmptyBorder(4, 4, 4, 4));

        userStylesheetPanel = new UserStyleDialog.Panel();
        panel.add(userStylesheetPanel, BorderLayout.NORTH);

        cssMediaPanel = new CSSMediaPanel();
        panel.add(cssMediaPanel, BorderLayout.SOUTH);

        return panel;
    }

    protected Component buildUserFont(){
        return new JButton("User Font");
    }

    protected Component buildBehavior(){
        JGridBagPanel p = new JGridBagPanel();
        showRendering
            = new JCheckBox(Resources.getString(LABEL_SHOW_RENDERING));
        autoAdjustWindow
            = new JCheckBox(Resources.getString(LABEL_AUTO_ADJUST_WINDOW));
        enableDoubleBuffering
            = new JCheckBox(Resources.getString(LABEL_ENABLE_DOUBLE_BUFFERING));
        enableDoubleBuffering.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent evt) {
                showRendering.setEnabled(!enableDoubleBuffering.isSelected());
            }
        });
        showDebugTrace
            = new JCheckBox(Resources.getString(LABEL_SHOW_DEBUG_TRACE));

        selectionXorMode
            = new JCheckBox(Resources.getString(LABEL_SELECTION_XOR_MODE));

        isXMLParserValidating
            = new JCheckBox(Resources.getString(LABEL_IS_XML_PARSER_VALIDATING));

        enforceSecureScripting
            = new JCheckBox(Resources.getString(LABEL_SECURE_SCRIPTING_TOGGLE));

        grantScriptFileAccess
            = new JCheckBox(Resources.getString(LABEL_GRANT_SCRIPT_FILE_ACCESS));
        
        grantScriptNetworkAccess
            = new JCheckBox(Resources.getString(LABEL_GRANT_SCRIPT_NETWORK_ACCESS));

        JGridBagPanel scriptSecurityPanel = new JGridBagPanel();
        scriptSecurityPanel.add(enforceSecureScripting,    0, 0, 1, 1, WEST, HORIZONTAL, 1, 0);
        scriptSecurityPanel.add(grantScriptFileAccess,    1, 0, 1, 1, WEST, HORIZONTAL, 1, 0);
        scriptSecurityPanel.add(grantScriptNetworkAccess, 1, 1, 1, 1, WEST, HORIZONTAL, 1, 0);
        
        enforceSecureScripting.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent e) {
                    grantScriptFileAccess.setEnabled(enforceSecureScripting.isSelected());
                    grantScriptNetworkAccess.setEnabled(enforceSecureScripting.isSelected());
                }
            });

        loadJava
            = new JCheckBox(Resources.getString(LABEL_LOAD_JAVA));

        loadEcmascript
            = new JCheckBox(Resources.getString(LABEL_LOAD_ECMASCRIPT));

        JGridBagPanel loadScriptPanel = new JGridBagPanel();
        loadScriptPanel.add(loadJava, 0, 0, 1, 1, WEST, NONE, 1, 0);
        loadScriptPanel.add(loadEcmascript, 1, 0, 1, 1, WEST, NONE, 1, 0);

        JPanel scriptOriginPanel = new JPanel();

        scriptOriginGroup = new ButtonGroup();
        JRadioButton rb = null;

        rb = new JRadioButton(Resources.getString(LABEL_ORIGIN_ANY));
        rb.setActionCommand("" + ResourceOrigin.ANY);
        scriptOriginGroup.add(rb);
        scriptOriginPanel.add(rb);

        rb = new JRadioButton(Resources.getString(LABEL_ORIGIN_DOCUMENT));
        rb.setActionCommand("" + ResourceOrigin.DOCUMENT);
        scriptOriginGroup.add(rb);
        scriptOriginPanel.add(rb);

        rb = new JRadioButton(Resources.getString(LABEL_ORIGIN_EMBED));
        rb.setActionCommand("" + ResourceOrigin.EMBEDED);
        scriptOriginGroup.add(rb);
        scriptOriginPanel.add(rb);

        rb = new JRadioButton(Resources.getString(LABEL_ORIGIN_NONE));
        rb.setActionCommand("" + ResourceOrigin.NONE);
        scriptOriginGroup.add(rb);
        scriptOriginPanel.add(rb);

        JPanel resourceOriginPanel = new JPanel();
        resourceOriginGroup = new ButtonGroup();

        rb = new JRadioButton(Resources.getString(LABEL_ORIGIN_ANY));
        rb.setActionCommand("" + ResourceOrigin.ANY);
        resourceOriginGroup.add(rb);
        resourceOriginPanel.add(rb);

        rb = new JRadioButton(Resources.getString(LABEL_ORIGIN_DOCUMENT));
        rb.setActionCommand("" + ResourceOrigin.DOCUMENT);
        resourceOriginGroup.add(rb);
        resourceOriginPanel.add(rb);

        rb = new JRadioButton(Resources.getString(LABEL_ORIGIN_EMBED));
        rb.setActionCommand("" + ResourceOrigin.EMBEDED);
        resourceOriginGroup.add(rb);
        resourceOriginPanel.add(rb);

        rb = new JRadioButton(Resources.getString(LABEL_ORIGIN_NONE));
        rb.setActionCommand("" + ResourceOrigin.NONE);
        resourceOriginGroup.add(rb);
        resourceOriginPanel.add(rb);

        JTabbedPane browserOptions = new JTabbedPane();
        // browserOptions.setBorder(BorderFactory.createEmptyBorder(5,5,5,5));

        p.add(showRendering,    0, 0, 2, 1, WEST, HORIZONTAL, 1, 0);
        p.add(autoAdjustWindow, 0, 1, 2, 1, WEST, HORIZONTAL, 1, 0);
        p.add(enableDoubleBuffering, 0, 2, 2, 1, WEST, HORIZONTAL, 1, 0);
        p.add(showDebugTrace,   0, 3, 2, 1, WEST, HORIZONTAL, 1, 0);
        p.add(selectionXorMode,   0, 4, 2, 1, WEST, HORIZONTAL, 1, 0);
        p.add(isXMLParserValidating,   0, 5, 2, 1, WEST, HORIZONTAL, 1, 0);
        p.add(new JLabel(), 0, 11, 2, 1, WEST, BOTH, 1, 1); 

        browserOptions.addTab(Resources.getString(TITLE_BEHAVIOR), p);
        p.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));

        p = new JGridBagPanel();
        p.add(new JLabel(Resources.getString(LABEL_ENFORCE_SECURE_SCRIPTING)), 0, 6, 1, 1, NORTHWEST, NONE, 0, 0);
        p.add(scriptSecurityPanel, 1, 6, 1, 1, WEST, NONE, 0, 0);
        p.add(new JLabel(Resources.getString(LABEL_LOAD_SCRIPTS)), 0, 8, 1, 1, WEST, NONE, 0, 0);
        p.add(loadScriptPanel, 1, 8, 1, 1, WEST, NONE, 1, 0);
        p.add(new JLabel(Resources.getString(LABEL_SCRIPT_ORIGIN)), 0, 9, 1, 1, WEST, NONE, 0, 0);
        p.add(scriptOriginPanel, 1, 9, 1, 1, WEST, NONE, 1, 0);
        p.add(new JLabel(Resources.getString(LABEL_RESOURCE_ORIGIN)), 0, 10, 1, 1, WEST, NONE, 0, 0);
        p.add(resourceOriginPanel, 1, 10, 1, 1, WEST, NONE, 1, 0); 
        p.add(new JLabel(), 0, 11, 2, 1, WEST, BOTH, 1, 1); 

        browserOptions.addTab(Resources.getString(TITLE_SECURITY), p);
        p.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));

        JGridBagPanel borderedPanel = new JGridBagPanel();
        borderedPanel.add(browserOptions, 0, 0, 1, 1, WEST, BOTH, 1, 1);
        borderedPanel.setBorder(BorderFactory.createCompoundBorder
                                (BorderFactory.createTitledBorder
                                 (BorderFactory.createEtchedBorder(),
                                  Resources.getString(TITLE_BROWSER_OPTIONS)),
                                 BorderFactory.createEmptyBorder(10, 10, 10, 10)));
        
        return borderedPanel;
    }

    protected Component buildNetwork(){
        JGridBagPanel p = new JGridBagPanel();
        host = new JTextField(Resources.getInteger(CONFIG_HOST_TEXT_FIELD_LENGTH));
        JLabel hostLabel = new JLabel(Resources.getString(LABEL_HOST));
        port = new JTextField(Resources.getInteger(CONFIG_PORT_TEXT_FIELD_LENGTH));
        JLabel portLabel = new JLabel(Resources.getString(LABEL_PORT));
        p.add(hostLabel, 0, 0, 1, 1, WEST, HORIZONTAL, 0, 0);
        p.add(host, 0, 1, 1, 1, CENTER, HORIZONTAL, 1, 0);
        p.add(portLabel, 1, 0, 1, 1, WEST, HORIZONTAL, 0, 0);
        p.add(port, 1, 1, 1, 1, CENTER, HORIZONTAL, 0, 0);
        p.add(new JLabel(""), 2, 1, 1, 1, CENTER, HORIZONTAL, 0, 0);

        p.setBorder(BorderFactory.createCompoundBorder
                    (BorderFactory.createTitledBorder
                     (BorderFactory.createEtchedBorder(),
                     Resources.getString(TITLE_NETWORK)),
                     BorderFactory.createEmptyBorder(10, 10, 10, 10)));

        return p;
    }

    protected Component buildApplications(){
        return new JButton("Applications");
    }

    /**
     * Shows the dialog
     * @return OK_OPTION or CANCEL_OPTION
     */
    public int showDialog(){
        pack();
        show();
        return returnCode;
    }

    public static void main(String[] args){
        Map defaults = new Hashtable();
        defaults.put(PREFERENCE_KEY_LANGUAGES, "fr");
        defaults.put(PREFERENCE_KEY_SHOW_RENDERING, Boolean.TRUE);
        defaults.put(PREFERENCE_KEY_SELECTION_XOR_MODE, Boolean.FALSE);
        defaults.put(PREFERENCE_KEY_IS_XML_PARSER_VALIDATING, Boolean.FALSE);
        defaults.put(PREFERENCE_KEY_AUTO_ADJUST_WINDOW, Boolean.TRUE);
        defaults.put(PREFERENCE_KEY_ENABLE_DOUBLE_BUFFERING, Boolean.TRUE);
        defaults.put(PREFERENCE_KEY_SHOW_DEBUG_TRACE, Boolean.TRUE);
        defaults.put(PREFERENCE_KEY_PROXY_HOST, "webcache.eng.sun.com");
        defaults.put(PREFERENCE_KEY_PROXY_PORT, "8080");

        XMLPreferenceManager manager
            = new XMLPreferenceManager(args[0], defaults);
        PreferenceDialog dlg = new PreferenceDialog(manager);
        int c = dlg.showDialog();
        if(c == OK_OPTION){
            try{
                manager.save();
                System.out.println("Done Saving options");
                System.exit(0);
            }catch(Exception e){
                System.err.println("Could not save options");
                e.printStackTrace();
            }
        }
    }
}


class ConfigurationPanelSelector {
    private CardLayout layout;
    private Container container;

    public ConfigurationPanelSelector(Container container,
                                      CardLayout layout){
        this.layout = layout;
        this.container = container;
    }

    public void select(String panelName){
        layout.show(container, panelName);
    }
}

class IconCellRendererOld extends JLabel implements ListCellRenderer {
    Map iconMap;

    public IconCellRendererOld(Map iconMap){
        this.iconMap = iconMap;

        setBorder(BorderFactory.createEmptyBorder(5, 5, 5, 5));
    }
    public Component getListCellRendererComponent
        (
         JList list,
         Object value,            // value to display
         int index,               // cell index
         boolean isSelected,      // is the cell selected
         boolean cellHasFocus)    // the list and the cell have the focus
    {
        String s = value.toString();
        setText(s);
        ImageIcon icon = (ImageIcon)iconMap.get(s);
        if(icon != null){
            setIcon(icon);
            setHorizontalAlignment(CENTER);
            setHorizontalTextPosition(CENTER);
            setVerticalTextPosition(BOTTOM);
        }
        // if (isSelected) {
        setBackground(java.awt.Color.red); // list.getSelectionBackground());
            setForeground(list.getSelectionForeground());
            /*}
        else {
            setBackground(list.getBackground());
            setForeground(list.getForeground());
            }*/
            // setEnabled(list.isEnabled());
            // setFont(list.getFont());
        return this;
    }
}

class IconCellRenderer extends JLabel
    implements ListCellRenderer
{
    protected Map map;
    protected static Border noFocusBorder;

    /**
     * Constructs a default renderer object for an item
     * in a list.
     */
    public IconCellRenderer(Map map) {
        super();
    this.map = map;
        noFocusBorder = BorderFactory.createEmptyBorder(1, 1, 1, 1);
        setOpaque(true);
        setBorder(noFocusBorder);
    }


    public Component getListCellRendererComponent(
        JList list,
        Object value,
        int index,
        boolean isSelected,
        boolean cellHasFocus)
    {

        setComponentOrientation(list.getComponentOrientation());

        if (isSelected) {
            setBackground(list.getSelectionBackground());
            setForeground(list.getSelectionForeground());
        }
        else {
            setBackground(list.getBackground());
            setForeground(list.getForeground());
        }

        setBorder((cellHasFocus) ? UIManager.getBorder("List.focusCellHighlightBorder") : noFocusBorder);

        /*if (value instanceof Icon) {
            setIcon((Icon)value);
            setText("");
        }
        else {
            setIcon(null);
            setText((value == null) ? "" : value.toString());
        }*/

    setText(value.toString());
        ImageIcon icon = (ImageIcon)map.get(value.toString());
        if(icon != null){
            setIcon(icon);
            setHorizontalAlignment(CENTER);
            setHorizontalTextPosition(CENTER);
            setVerticalTextPosition(BOTTOM);
        }
        setEnabled(list.isEnabled());
        setFont(list.getFont());

        return this;
    }


   /**
    * Overridden for performance reasons.
    * See the <a href="#override">Implementation Note</a>
    * for more information.
    */
    public void validate() {}

   /**
    * Overridden for performance reasons.
    * See the <a href="#override">Implementation Note</a>
    * for more information.
    */
    public void revalidate() {}
   /**
    * Overridden for performance reasons.
    * See the <a href="#override">Implementation Note</a>
    * for more information.
    */
    public void repaint(long tm, int x, int y, int width, int height) {}

   /**
    * Overridden for performance reasons.
    * See the <a href="#override">Implementation Note</a>
    * for more information.
    */
    public void repaint(Rectangle r) {}

   /**
    * Overridden for performance reasons.
    * See the <a href="#override">Implementation Note</a>
    * for more information.
    */
    protected void firePropertyChange(String propertyName, Object oldValue, Object newValue) {
        // Strings get interned...
        if (propertyName=="text")
            super.firePropertyChange(propertyName, oldValue, newValue);
    }

   /**
    * Overridden for performance reasons.
    * See the <a href="#override">Implementation Note</a>
    * for more information.
    */
    public void firePropertyChange(String propertyName, byte oldValue, byte newValue) {}

   /**
    * Overridden for performance reasons.
    * See the <a href="#override">Implementation Note</a>
    * for more information.
    */
    public void firePropertyChange(String propertyName, char oldValue, char newValue) {}

   /**
    * Overridden for performance reasons.
    * See the <a href="#override">Implementation Note</a>
    * for more information.
    */
    public void firePropertyChange(String propertyName, short oldValue, short newValue) {}

   /**
    * Overridden for performance reasons.
    * See the <a href="#override">Implementation Note</a>
    * for more information.
    */
    public void firePropertyChange(String propertyName, int oldValue, int newValue) {}

   /**
    * Overridden for performance reasons.
    * See the <a href="#override">Implementation Note</a>
    * for more information.
    */
    public void firePropertyChange(String propertyName, long oldValue, long newValue) {}

   /**
    * Overridden for performance reasons.
    * See the <a href="#override">Implementation Note</a>
    * for more information.
    */
    public void firePropertyChange(String propertyName, float oldValue, float newValue) {}

   /**
    * Overridden for performance reasons.
    * See the <a href="#override">Implementation Note</a>
    * for more information.
    */
    public void firePropertyChange(String propertyName, double oldValue, double newValue) {}

   /**
    * Overridden for performance reasons.
    * See the <a href="#override">Implementation Note</a>
    * for more information.
    */
    public void firePropertyChange(String propertyName, boolean oldValue, boolean newValue) {}
}
