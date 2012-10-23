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
import java.awt.Color;
import java.awt.Cursor;
import java.awt.Dimension;
import java.awt.Event;
import java.awt.EventQueue;
import java.awt.FileDialog;
import java.awt.Font;
import java.awt.Graphics2D;
import java.awt.Rectangle;
import java.awt.Toolkit;
import java.awt.event.ActionEvent;
import java.awt.event.ComponentAdapter;
import java.awt.event.ComponentEvent;
import java.awt.event.KeyEvent;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.event.MouseMotionAdapter;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.awt.geom.AffineTransform;
import java.awt.geom.NoninvertibleTransformException;
import java.awt.geom.Point2D;
import java.awt.image.BufferedImage;
import java.awt.print.PrinterException;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FilenameFilter;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Reader;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.MalformedURLException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.MissingResourceException;
import java.util.ResourceBundle;
import java.util.Vector;

import javax.swing.AbstractAction;
import javax.swing.Action;
import javax.swing.BorderFactory;
import javax.swing.ButtonGroup;
import javax.swing.JComponent;
import javax.swing.JDialog;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JRadioButtonMenuItem;
import javax.swing.JScrollPane;
import javax.swing.JToolBar;
import javax.swing.JWindow;
import javax.swing.KeyStroke;
import javax.swing.filechooser.FileFilter;
import javax.swing.text.Document;

import org.apache.flex.forks.batik.bridge.DefaultExternalResourceSecurity;
import org.apache.flex.forks.batik.bridge.DefaultScriptSecurity;
import org.apache.flex.forks.batik.bridge.EmbededExternalResourceSecurity;
import org.apache.flex.forks.batik.bridge.EmbededScriptSecurity;
import org.apache.flex.forks.batik.bridge.ExternalResourceSecurity;
import org.apache.flex.forks.batik.bridge.NoLoadExternalResourceSecurity;
import org.apache.flex.forks.batik.bridge.NoLoadScriptSecurity;
import org.apache.flex.forks.batik.bridge.RelaxedExternalResourceSecurity;
import org.apache.flex.forks.batik.bridge.RelaxedScriptSecurity;
import org.apache.flex.forks.batik.bridge.ScriptSecurity;
import org.apache.flex.forks.batik.bridge.UpdateManager;
import org.apache.flex.forks.batik.bridge.UpdateManagerEvent;
import org.apache.flex.forks.batik.bridge.UpdateManagerListener;
import org.apache.flex.forks.batik.dom.StyleSheetProcessingInstruction;
import org.apache.flex.forks.batik.dom.svg.SVGOMDocument;
import org.apache.flex.forks.batik.dom.util.HashTable;
import org.apache.flex.forks.batik.dom.util.DOMUtilities;
import org.apache.flex.forks.batik.ext.swing.JAffineTransformChooser;
import org.apache.flex.forks.batik.swing.JSVGCanvas;
import org.apache.flex.forks.batik.swing.gvt.GVTTreeRendererEvent;
import org.apache.flex.forks.batik.swing.gvt.GVTTreeRendererListener;
import org.apache.flex.forks.batik.swing.gvt.Overlay;
import org.apache.flex.forks.batik.swing.svg.GVTTreeBuilderEvent;
import org.apache.flex.forks.batik.swing.svg.GVTTreeBuilderListener;
import org.apache.flex.forks.batik.swing.svg.LinkActivationEvent;
import org.apache.flex.forks.batik.swing.svg.LinkActivationListener;
import org.apache.flex.forks.batik.swing.svg.SVGDocumentLoaderEvent;
import org.apache.flex.forks.batik.swing.svg.SVGDocumentLoaderListener;
import org.apache.flex.forks.batik.swing.svg.SVGFileFilter;
import org.apache.flex.forks.batik.swing.svg.SVGLoadEventDispatcherEvent;
import org.apache.flex.forks.batik.swing.svg.SVGLoadEventDispatcherListener;
import org.apache.flex.forks.batik.swing.svg.SVGUserAgent;
import org.apache.flex.forks.batik.transcoder.TranscoderInput;
import org.apache.flex.forks.batik.transcoder.TranscoderOutput;
import org.apache.flex.forks.batik.transcoder.image.ImageTranscoder;
import org.apache.flex.forks.batik.transcoder.image.JPEGTranscoder;
import org.apache.flex.forks.batik.transcoder.image.PNGTranscoder;
import org.apache.flex.forks.batik.transcoder.image.TIFFTranscoder;
import org.apache.flex.forks.batik.transcoder.print.PrintTranscoder;
import org.apache.flex.forks.batik.transcoder.svg2svg.SVGTranscoder;
import org.apache.flex.forks.batik.util.ParsedURL;
import org.apache.flex.forks.batik.util.Platform;
import org.apache.flex.forks.batik.util.Service;
import org.apache.flex.forks.batik.util.SVGConstants;
import org.apache.flex.forks.batik.util.XMLConstants;
import org.apache.flex.forks.batik.util.gui.JErrorPane;
import org.apache.flex.forks.batik.util.gui.LocationBar;
import org.apache.flex.forks.batik.util.gui.MemoryMonitor;
import org.apache.flex.forks.batik.util.gui.URIChooser;
import org.apache.flex.forks.batik.util.gui.resource.ActionMap;
import org.apache.flex.forks.batik.util.gui.resource.JComponentModifier;
import org.apache.flex.forks.batik.util.gui.resource.MenuFactory;
import org.apache.flex.forks.batik.util.gui.resource.MissingListenerException;
import org.apache.flex.forks.batik.util.gui.resource.ToolBarFactory;
import org.apache.flex.forks.batik.util.gui.xmleditor.XMLDocument;
import org.apache.flex.forks.batik.util.gui.xmleditor.XMLTextEditor;
import org.apache.flex.forks.batik.util.resources.ResourceManager;
import org.apache.flex.forks.batik.xml.XMLUtilities;

import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.css.ViewCSS;
import org.w3c.dom.svg.SVGDocument;

/**
 * This class represents a SVG viewer swing frame.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: JSVGViewerFrame.java 599194 2007-11-28 23:16:02Z cam $
 */
public class JSVGViewerFrame
    extends    JFrame
    implements ActionMap,
               SVGDocumentLoaderListener,
               GVTTreeBuilderListener,
               SVGLoadEventDispatcherListener,
               GVTTreeRendererListener,
               LinkActivationListener,
               UpdateManagerListener {

    private static String EOL;
    static {
        try {
            EOL = System.getProperty("line.separator", "\n");
        } catch (SecurityException e) {
            EOL = "\n";
        }
    }

    /**
     * Kind of ugly, but we need to know if we are running before
     * or after 1.4...
     */
    protected static boolean priorJDK1_4 = true;

    /**
     * If the following class can be found (it appeared in JDK 1.4),
     * then we know we are post JDK 1.4.
     */
    protected static final String JDK_1_4_PRESENCE_TEST_CLASS
        = "java.util.logging.LoggingPermission";

    static {
        try {
            Class.forName(JDK_1_4_PRESENCE_TEST_CLASS);
            priorJDK1_4 = false;
        } catch (ClassNotFoundException e) {
        }
    }

    /**
     * The gui resources file name
     */
    public static final String RESOURCES =
        "org.apache.flex.forks.batik.apps.svgbrowser.resources.GUI";

    // The actions names.
    public static final String ABOUT_ACTION = "AboutAction";
    public static final String OPEN_ACTION = "OpenAction";
    public static final String OPEN_LOCATION_ACTION = "OpenLocationAction";
    public static final String NEW_WINDOW_ACTION = "NewWindowAction";
    public static final String RELOAD_ACTION = "ReloadAction";
    public static final String SAVE_AS_ACTION = "SaveAsAction";
    public static final String BACK_ACTION = "BackAction";
    public static final String FORWARD_ACTION = "ForwardAction";
    public static final String FULL_SCREEN_ACTION = "FullScreenAction";
    public static final String PRINT_ACTION = "PrintAction";
    public static final String EXPORT_AS_JPG_ACTION = "ExportAsJPGAction";
    public static final String EXPORT_AS_PNG_ACTION = "ExportAsPNGAction";
    public static final String EXPORT_AS_TIFF_ACTION = "ExportAsTIFFAction";
    public static final String PREFERENCES_ACTION = "PreferencesAction";
    public static final String CLOSE_ACTION = "CloseAction";
    public static final String VIEW_SOURCE_ACTION = "ViewSourceAction";
    public static final String EXIT_ACTION = "ExitAction";
    public static final String RESET_TRANSFORM_ACTION = "ResetTransformAction";
    public static final String ZOOM_IN_ACTION = "ZoomInAction";
    public static final String ZOOM_OUT_ACTION = "ZoomOutAction";
    public static final String PREVIOUS_TRANSFORM_ACTION = "PreviousTransformAction";
    public static final String NEXT_TRANSFORM_ACTION = "NextTransformAction";
    public static final String USE_STYLESHEET_ACTION = "UseStylesheetAction";
    public static final String PLAY_ACTION = "PlayAction";
    public static final String PAUSE_ACTION = "PauseAction";
    public static final String STOP_ACTION = "StopAction";
    public static final String MONITOR_ACTION = "MonitorAction";
    public static final String DOM_VIEWER_ACTION = "DOMViewerAction";
    public static final String SET_TRANSFORM_ACTION = "SetTransformAction";
    public static final String FIND_DIALOG_ACTION = "FindDialogAction";
    public static final String THUMBNAIL_DIALOG_ACTION = "ThumbnailDialogAction";
    public static final String FLUSH_ACTION = "FlushAction";
    public static final String TOGGLE_DEBUGGER_ACTION = "ToggleDebuggerAction";

    /**
     * The cursor indicating that an operation is pending.
     */
    public static final Cursor WAIT_CURSOR =
        new Cursor(Cursor.WAIT_CURSOR);

    /**
     * The default cursor.
     */
    public static final Cursor DEFAULT_CURSOR =
        new Cursor(Cursor.DEFAULT_CURSOR);

    /**
     * Name for the os-name property
     */
    public static final String PROPERTY_OS_NAME
        = Resources.getString("JSVGViewerFrame.property.os.name");

    /**
     * Name for the os.name default
     */
    public static final String PROPERTY_OS_NAME_DEFAULT
        = Resources.getString("JSVGViewerFrame.property.os.name.default");

    /**
     * Name for the os.name property prefix we are looking
     * for in OpenAction to work around JFileChooser bug
     */
    public static final String PROPERTY_OS_WINDOWS_PREFIX
        = Resources.getString("JSVGViewerFrame.property.os.windows.prefix");

    /**
     * Resource string name for the Open dialog.
     */
    protected static final String OPEN_TITLE = "Open.title";

    /**
     * The input handlers
     */
    protected static Vector handlers;

    /**
     * The default input handler
     */
    protected static SquiggleInputHandler defaultHandler = new SVGInputHandler();

    /**
     * The resource bundle
     */
    protected static ResourceBundle bundle;

    /**
     * The resource manager
     */
    protected static ResourceManager resources;
    static {
        bundle = ResourceBundle.getBundle(RESOURCES, Locale.getDefault());
        resources = new ResourceManager(bundle);
    }

    /**
     * The current application.
     */
    protected Application application;

    /**
     * The JSVGCanvas.
     */
    protected Canvas svgCanvas;

    /**
     * An extension of JSVGCanvas that exposes the Rhino interpreter.
     */
    protected class Canvas extends JSVGCanvas {

        /**
         * Creates a new Canvas.
         */
        public Canvas(SVGUserAgent ua, boolean eventsEnabled,
                      boolean selectableText) {
            super(ua, eventsEnabled, selectableText);
        }

        /**
         * Returns the Rhino interpreter for this canvas.
         */
        public Object getRhinoInterpreter() {
            if (bridgeContext == null) {
                return null;
            }
            return bridgeContext.getInterpreter("text/ecmascript");
        }

        /**
         * JSVGViewerFrame DOMViewerController implementation.
         */
        protected class JSVGViewerDOMViewerController
                // extends CanvasDOMViewerController {
                implements DOMViewerController {

            public boolean canEdit() {
                return getUpdateManager() != null;
            }

            public ElementOverlayManager createSelectionManager() {
                if (canEdit()) {
                    return new ElementOverlayManager(Canvas.this);
                }
                return null;
            }

            public org.w3c.dom.Document getDocument() {
                return Canvas.this.svgDocument;
            }

            public void performUpdate(Runnable r) {
                if (canEdit()) {
                    getUpdateManager().getUpdateRunnableQueue().invokeLater(r);
                } else {
                    r.run();
                }
            }

            public void removeSelectionOverlay(Overlay selectionOverlay) {
                getOverlays().remove(selectionOverlay);
            }

            public void selectNode(Node node) {
                DOMViewerAction dViewerAction =
                    (DOMViewerAction) getAction(DOM_VIEWER_ACTION);
                dViewerAction.openDOMViewer();
                domViewer.selectNode(node);
            }
        }
    }

    /**
     * The panel where the svgCanvas is displayed
     */
    protected JPanel svgCanvasPanel;

    /**
     * A window used for full screen display
     */
    protected JWindow window;

    /**
     * The memory monitor frame.
     */
    protected static JFrame memoryMonitorFrame;

    /**
     * The current path.
     */
    protected File currentPath = new File("");

    /**
     * The current export path.
     */
    protected File currentSavePath = new File("");

    /**
     * The back action
     */
    protected BackAction backAction = new BackAction();

    /**
     * The forward action
     */
    protected ForwardAction forwardAction = new ForwardAction();

    /**
     * The play action
     */
    protected PlayAction playAction = new PlayAction();

    /**
     * The pause action
     */
    protected PauseAction pauseAction = new PauseAction();

    /**
     * The stop action
     */
    protected StopAction stopAction = new StopAction();

    /**
     * The previous transform action
     */
    protected PreviousTransformAction previousTransformAction =
        new PreviousTransformAction();

    /**
     * The next transform action
     */
    protected NextTransformAction nextTransformAction =
        new NextTransformAction();

    /**
     * The use (author) stylesheet action
     */
    protected UseStylesheetAction useStylesheetAction =
        new UseStylesheetAction();

    /**
     * The debug flag.
     */
    protected boolean debug;

    /**
     * The auto adjust flag.
     */
    protected boolean autoAdjust = true;

    /**
     * Whether the update manager was stopped.
     */
    protected boolean managerStopped;

    /**
     * The SVG user agent.
     */
    protected SVGUserAgent userAgent = new UserAgent();

    /**
     * The current document.
     */
    protected SVGDocument svgDocument;

    /**
     * The URI chooser.
     */
    protected URIChooser uriChooser;

    /**
     * The DOM viewer.
     */
    protected DOMViewer domViewer;

    /**
     * The Find dialog.
     */
    protected FindDialog findDialog;

    /**
     * The Find dialog.
     */
    protected ThumbnailDialog thumbnailDialog;

    /**
     * The transform dialog
     */
    protected JAffineTransformChooser.Dialog transformDialog;

    /**
     * The location bar.
     */
    protected LocationBar locationBar;

    /**
     * The status bar.
     */
    protected StatusBar statusBar;

    /**
     * The initial frame title.
     */
    protected String title;

    /**
     * The local history.
     */
    protected LocalHistory localHistory;

    /**
     * The transform history.
     */
    protected TransformHistory transformHistory = new TransformHistory();

    /**
     * The alternate style-sheet title.
     */
    protected String alternateStyleSheet;

    /**
     * The debugger object.
     */
    protected Debugger debugger;

    /**
     * Creates a new SVG viewer frame.
     */
    public JSVGViewerFrame(Application app) {
        application = app;

        addWindowListener(new WindowAdapter() {
            public void windowClosing(WindowEvent e) {
                application.closeJSVGViewerFrame(JSVGViewerFrame.this);
            }
        });

        //
        // Set the frame's maximum size so that content
        // bigger than the screen does not cause the creation
        // of unnecessary large images.
        //
        svgCanvas = new Canvas(userAgent, true, true) {
                Dimension screenSize;

                {
                    screenSize = Toolkit.getDefaultToolkit().getScreenSize();
                    setMaximumSize(screenSize);
                }

                public Dimension getPreferredSize(){
                    Dimension s = super.getPreferredSize();
                    if (s.width > screenSize.width) s.width =screenSize.width;
                    if (s.height > screenSize.height) s.height = screenSize.height;
                    return s;
                }


                /**
                 * This method is called when the component knows the desired
                 * size of the window (based on width/height of outermost SVG
                 * element). We override it to immediately pack this frame.
                 */
                public void setMySize(Dimension d) {
                    setPreferredSize(d);
                    invalidate();
                    if (JSVGViewerFrame.this.autoAdjust) {
                        Platform.unmaximize(JSVGViewerFrame.this);
                        JSVGViewerFrame.this.pack();
                    }
                }

                public void setDisableInteractions(boolean b) {
                    super.setDisableInteractions(b);

                    // Disable/Enable all our different ways to adjust the
                    // rendering transform (menus, toolbar, thumbnail, keyboard).

                    ((Action)listeners.get(SET_TRANSFORM_ACTION)) .setEnabled(!b);

                    if (thumbnailDialog != null)
                        thumbnailDialog.setInteractionEnabled(!b);
                }
            };

        javax.swing.ActionMap map = svgCanvas.getActionMap();
        map.put(FULL_SCREEN_ACTION, new FullScreenAction());
        javax.swing.InputMap imap = svgCanvas.getInputMap(JComponent.WHEN_FOCUSED);
        KeyStroke key = KeyStroke.getKeyStroke(KeyEvent.VK_F11, 0);
        imap.put(key, FULL_SCREEN_ACTION);

        svgCanvas.setDoubleBufferedRendering(true);

        listeners.put(ABOUT_ACTION, new AboutAction());
        listeners.put(OPEN_ACTION, new OpenAction());
        listeners.put(OPEN_LOCATION_ACTION, new OpenLocationAction());
        listeners.put(NEW_WINDOW_ACTION, new NewWindowAction());
        listeners.put(RELOAD_ACTION, new ReloadAction());
        listeners.put(SAVE_AS_ACTION, new SaveAsAction());
        listeners.put(BACK_ACTION, backAction);
        listeners.put(FORWARD_ACTION, forwardAction);
        listeners.put(PRINT_ACTION, new PrintAction());
        listeners.put(EXPORT_AS_JPG_ACTION, new ExportAsJPGAction());
        listeners.put(EXPORT_AS_PNG_ACTION, new ExportAsPNGAction());
        listeners.put(EXPORT_AS_TIFF_ACTION, new ExportAsTIFFAction());
        listeners.put(PREFERENCES_ACTION, new PreferencesAction());
        listeners.put(CLOSE_ACTION, new CloseAction());
        listeners.put(EXIT_ACTION, application.createExitAction(this));
        listeners.put(VIEW_SOURCE_ACTION, new ViewSourceAction());

        javax.swing.ActionMap cMap = svgCanvas.getActionMap();
        listeners.put(RESET_TRANSFORM_ACTION,
                      cMap.get(JSVGCanvas.RESET_TRANSFORM_ACTION));
        listeners.put(ZOOM_IN_ACTION,
                      cMap.get(JSVGCanvas.ZOOM_IN_ACTION));
        listeners.put(ZOOM_OUT_ACTION,
                      cMap.get(JSVGCanvas.ZOOM_OUT_ACTION));

        listeners.put(PREVIOUS_TRANSFORM_ACTION, previousTransformAction);
        key = KeyStroke.getKeyStroke(KeyEvent.VK_K, KeyEvent.CTRL_MASK);
        imap.put(key, previousTransformAction);

        listeners.put(NEXT_TRANSFORM_ACTION, nextTransformAction);
        key = KeyStroke.getKeyStroke(KeyEvent.VK_L, KeyEvent.CTRL_MASK);
        imap.put(key, nextTransformAction);

        listeners.put(USE_STYLESHEET_ACTION, useStylesheetAction);
        listeners.put(PLAY_ACTION, playAction);
        listeners.put(PAUSE_ACTION, pauseAction);
        listeners.put(STOP_ACTION, stopAction);
        listeners.put(MONITOR_ACTION, new MonitorAction());
        listeners.put(DOM_VIEWER_ACTION, new DOMViewerAction());
        listeners.put(SET_TRANSFORM_ACTION, new SetTransformAction());
        listeners.put(FIND_DIALOG_ACTION, new FindDialogAction());
        listeners.put(THUMBNAIL_DIALOG_ACTION, new ThumbnailDialogAction());
        listeners.put(FLUSH_ACTION, new FlushAction());
        listeners.put(TOGGLE_DEBUGGER_ACTION, new ToggleDebuggerAction());

        JPanel p = null;
        try {
            // Create the menu
            MenuFactory mf = new MenuFactory(bundle, this);
            JMenuBar mb =
                mf.createJMenuBar("MenuBar", application.getUISpecialization());
            setJMenuBar(mb);

            localHistory = new LocalHistory(mb, this);

            String[] uri = application.getVisitedURIs();
            for (int i=0; i<uri.length; i++) {
                if (uri[i] != null && !"".equals(uri[i])) {
                    localHistory.update(uri[i]);
                }
            }
            p = new JPanel(new BorderLayout());

            // Create the toolbar
            ToolBarFactory tbf = new ToolBarFactory(bundle, this);
            JToolBar tb = tbf.createJToolBar("ToolBar");
            tb.setFloatable(false);
            getContentPane().add(p, BorderLayout.NORTH);
            p.add(tb, BorderLayout.NORTH);
            p.add(new javax.swing.JSeparator(), BorderLayout.CENTER);
            p.add(locationBar = new LocationBar(), BorderLayout.SOUTH);
            locationBar.setBorder(BorderFactory.createEmptyBorder(2, 2, 2, 2));

        } catch (MissingResourceException e) {
            System.out.println(e.getMessage());
            System.exit(0);
        }

        svgCanvasPanel = new JPanel(new BorderLayout());
        svgCanvasPanel.setBorder(BorderFactory.createEtchedBorder());

        svgCanvasPanel.add(svgCanvas, BorderLayout.CENTER);
        p = new JPanel(new BorderLayout());
        p.add(svgCanvasPanel, BorderLayout.CENTER);
        p.add(statusBar = new StatusBar(), BorderLayout.SOUTH);

        getContentPane().add(p, BorderLayout.CENTER);

        svgCanvas.addSVGDocumentLoaderListener(this);
        svgCanvas.addGVTTreeBuilderListener(this);
        svgCanvas.addSVGLoadEventDispatcherListener(this);
        svgCanvas.addGVTTreeRendererListener(this);
        svgCanvas.addLinkActivationListener(this);
        svgCanvas.addUpdateManagerListener(this);

        svgCanvas.addMouseMotionListener(new MouseMotionAdapter() {
                public void mouseMoved(MouseEvent e) {
                    if (svgDocument == null) {
                        statusBar.setXPosition(e.getX());
                        statusBar.setYPosition(e.getY());
                    } else {
                        try {
                            AffineTransform at;
                            at = svgCanvas.getViewBoxTransform();
                            if (at != null) {
                                at = at.createInverse();
                                Point2D p2d =
                                    at.transform(new Point2D.Float(e.getX(), e.getY()),
                                                 null);
                                statusBar.setXPosition((float)p2d.getX());
                                statusBar.setYPosition((float)p2d.getY());
                                return;
                            }
                        } catch (NoninvertibleTransformException ex) {
                        }
                        statusBar.setXPosition(e.getX());
                        statusBar.setYPosition(e.getY());
                    }
                }
            });
        svgCanvas.addMouseListener(new MouseAdapter() {
                public void mouseExited(MouseEvent e) {
                    Dimension dim = svgCanvas.getSize();
                    if (svgDocument == null) {
                        statusBar.setWidth(dim.width);
                        statusBar.setHeight(dim.height);
                    } else {
                        try {
                            AffineTransform at;
                            at = svgCanvas.getViewBoxTransform();
                            if (at != null) {
                                at = at.createInverse();
                                Point2D o =
                                    at.transform(new Point2D.Float(0, 0),
                                                 null);
                                Point2D p2d =
                                    at.transform(new Point2D.Float(dim.width,
                                                                   dim.height),
                                                 null);
                                statusBar.setWidth((float)(p2d.getX() - o.getX()));
                                statusBar.setHeight((float)(p2d.getY() - o.getY()));
                                return;
                            }
                        } catch (NoninvertibleTransformException ex) {
                        }
                        statusBar.setWidth(dim.width);
                        statusBar.setHeight(dim.height);
                    }
                }
            });
        svgCanvas.addComponentListener(new ComponentAdapter() {
                public void componentResized(ComponentEvent e) {
                    Dimension dim = svgCanvas.getSize();
                    if (svgDocument == null) {
                        statusBar.setWidth(dim.width);
                        statusBar.setHeight(dim.height);
                    } else {
                        try {
                            AffineTransform at;
                            at = svgCanvas.getViewBoxTransform();
                            if (at != null) {
                                at = at.createInverse();
                                Point2D o =
                                    at.transform(new Point2D.Float(0, 0),
                                                 null);
                                Point2D p2d =
                                    at.transform(new Point2D.Float(dim.width,
                                                                   dim.height),
                                                 null);
                                statusBar.setWidth((float)(p2d.getX() - o.getX()));
                                statusBar.setHeight((float)(p2d.getY() - o.getY()));
                                return;
                            }
                        } catch (NoninvertibleTransformException ex) {
                        }
                        statusBar.setWidth(dim.width);
                        statusBar.setHeight(dim.height);
                    }
                }
            });

        locationBar.addActionListener(new AbstractAction() {
            public void actionPerformed(ActionEvent e) {
                String st = locationBar.getText().trim();
                int i = st.indexOf( '#' );
                String t = "";
                if (i != -1) {
                    t = st.substring(i + 1);
                    st = st.substring(0, i);
                }

                if (st.equals(""))
                    return;

                try{
                    File f = new File(st);
                    if (f.exists()) {
                        if (f.isDirectory()) {
                            return;
                        } else {
                            try {
                                st = f.getCanonicalPath();
                                if (st.startsWith("/")) {
                                    st = "file:" + st;
                                } else {
                                    st = "file:/" + st;
                                }
                            } catch (IOException ex) {
                            }
                        }
                    }
                }catch(SecurityException se){
                    // Could not patch the file URI for security
                    // reasons (e.g., when run as an unsigned
                    // JavaWebStart jar): file access is not
                    // allowed. Loading will fail, but there is
                    // nothing more to do at this point.
                }

                String fi = svgCanvas.getFragmentIdentifier();
                if (svgDocument != null) {
                    ParsedURL docPURL
                        = new ParsedURL(svgDocument.getURL());
                    ParsedURL purl = new ParsedURL(docPURL, st);
                    fi = (fi == null) ? "" : fi;
                    if (docPURL.equals(purl) && t.equals(fi)) {
                        return;
                    }
                }
                if (t.length() != 0) {
                    st += '#' + t;
                }
                locationBar.setText(st);
                locationBar.addToHistory(st);
                showSVGDocument(st);
            }
        });
    }

    /**
     * Call dispose on canvas as well.
     */
    public void dispose() {
        hideDebugger();
        svgCanvas.dispose();
        super.dispose();
    }

    /**
     * Whether to show the debug traces.
     */
    public void setDebug(boolean b) {
        debug = b;
    }

    /**
     * Whether to auto adjust the canvas to the size of the document.
     */
    public void setAutoAdjust(boolean b) {
        autoAdjust = b;
    }

    /**
     * Returns the main JSVGCanvas of this frame.
     */
    public JSVGCanvas getJSVGCanvas() {
        return svgCanvas;
    }

    /**
     * Needed to work-around JFileChooser bug with abstract Files
     */
    private static File makeAbsolute(File f){
        if(!f.isAbsolute()){
            return f.getAbsoluteFile();
        }
        return f;
    }

    /**
     * Shows the Rhino debugger.
     */
    public void showDebugger() {
        if (debugger == null && Debugger.isPresent) {
            debugger = new Debugger(this, locationBar.getText());
            debugger.initialize();
        }
    }

    /**
     * Hides and destroys the Rhino debugger.
     */
    public void hideDebugger() {
        if (debugger != null) {
            debugger.clearAllBreakpoints();
            debugger.go();
            debugger.dispose();
            debugger = null;
        }
    }

    /**
     * Rhino debugger class.
     */
    protected static class Debugger {

        /**
         * Whether the Rhino debugger classes are present.
         */
        protected static boolean isPresent;

        /**
         * The Rhino debugger class.
         */
        protected static Class debuggerClass;

        /**
         * The Rhino ContextFactory class.
         */
        protected static Class contextFactoryClass;

        // Indexes into the debuggerMethods array.
        protected static final int CLEAR_ALL_BREAKPOINTS_METHOD = 0;
        protected static final int GO_METHOD                    = 1;
        protected static final int SET_EXIT_ACTION_METHOD       = 2;
        protected static final int ATTACH_TO_METHOD             = 3;
        protected static final int DETACH_METHOD                = 4;
        protected static final int DISPOSE_METHOD               = 5;
        protected static final int GET_DEBUG_FRAME_METHOD       = 6;

        /**
         * Rhino debugger class constructor.
         */
        protected static Constructor debuggerConstructor;

        /**
         * Rhino debugger class methods.
         */
        protected static Method[] debuggerMethods;

        /**
         * The RhinoInterpreter class.
         */
        protected static Class rhinoInterpreterClass;

        /**
         * The {@code getContextFactory} method on the {@link
         * org.apache.flex.forks.batik.script.rhino.RhinoInterpreter} class.
         */
        protected static Method getContextFactoryMethod;

        static {
            try {
                Class dc =
                    Class.forName("org.mozilla.javascript.tools.debugger.Main");
                Class cfc =
                    Class.forName("org.mozilla.javascript.ContextFactory");
                rhinoInterpreterClass = Class.forName
                    ("org.apache.flex.forks.batik.script.rhino.RhinoInterpreter");
                debuggerConstructor =
                    dc.getConstructor(new Class[] { String.class });
                debuggerMethods = new Method[] {
                    dc.getMethod("clearAllBreakpoints", (Class[]) null),
                    dc.getMethod("go", (Class[]) null),
                    dc.getMethod("setExitAction", new Class[] {Runnable.class}),
                    dc.getMethod("attachTo", new Class[] { cfc }),
                    dc.getMethod("detach", (Class[]) null),
                    dc.getMethod("dispose", (Class[]) null),
                    dc.getMethod("getDebugFrame", (Class[]) null)
                };
                getContextFactoryMethod =
                    rhinoInterpreterClass.getMethod("getContextFactory",
                                                    (Class[]) null);
                debuggerClass = dc;
                isPresent = true;
            } catch (ClassNotFoundException cnfe) {
            } catch (NoSuchMethodException nsme) {
            } catch (SecurityException se) {
            }
        }

        /**
         * The Rhino debugger instance.
         */
        protected Object debuggerInstance;

        /**
         * The JSVGViewerFrame.
         */
        protected JSVGViewerFrame svgFrame;

        /**
         * Creates a new Debugger.
         */
        public Debugger(JSVGViewerFrame frame, String url) {
            svgFrame = frame;
            try {
                debuggerInstance = debuggerConstructor.newInstance
                    (new Object[] { "JavaScript Debugger - " + url });
            } catch (IllegalAccessException iae) {
                throw new RuntimeException(iae.getMessage());
            } catch (InvocationTargetException ite) {
                ite.printStackTrace();
                throw new RuntimeException(ite.getMessage());
            } catch (InstantiationException ie) {
                throw new RuntimeException(ie.getMessage());
            }
        }

        /**
         * Sets the document URL to use in the window title.
         */
        public void setDocumentURL(String url) {
            getDebugFrame().setTitle("JavaScript Debugger - " + url);
        }

        /**
         * Initializes the debugger by massaging the GUI and attaching it
         * to the Rhino interpreter's {@link
         * org.mozilla.javascript.ContextFactory}.
         */
        public void initialize() {
            // Customize the menubar a bit, disable menu
            // items that can't be used and change 'Exit' to 'Close'.
            JFrame   debugGui = getDebugFrame();
            JMenuBar menuBar  = debugGui.getJMenuBar();
            JMenu    menu     = menuBar.getMenu(0);
            menu.getItem(0).setEnabled(false); // Open...
            menu.getItem(1).setEnabled(false); // Run...
            menu.getItem(3).setText
                (Resources.getString("Close.text")); // Exit -> "Close"
            menu.getItem(3).setAccelerator
                (KeyStroke.getKeyStroke(KeyEvent.VK_W, Event.CTRL_MASK));

            debugGui.setSize(600, 460);
            debugGui.pack();
            setExitAction(new Runnable() {
                    public void run() {
                        svgFrame.hideDebugger();
                    }});
            WindowAdapter wa = new WindowAdapter() {
                    public void windowClosing(WindowEvent e) {
                        svgFrame.hideDebugger();
                    }};
            debugGui.addWindowListener(wa);
            debugGui.setVisible(true);
            attach();
        }

        /**
         * Attaches the debugger to the canvas' current interpreter.
         */
        public void attach() {
            Object interpreter = svgFrame.svgCanvas.getRhinoInterpreter();
            if (interpreter != null) {
                attachTo(getContextFactory(interpreter));
            }
        }

        /**
         * Calls {@code getDebugFrame} on {@link #debuggerInstance}.
         */
        protected JFrame getDebugFrame() {
            try {
                return (JFrame) debuggerMethods[GET_DEBUG_FRAME_METHOD].invoke
                    (debuggerInstance, (Object[]) null);
            } catch (InvocationTargetException ite) {
                throw new RuntimeException(ite.getMessage());
            } catch (IllegalAccessException iae) {
                throw new RuntimeException(iae.getMessage());
            }
        }

        /**
         * Calls {@code setExitAction} on {@link #debuggerInstance}.
         */
        protected void setExitAction(Runnable r) {
            try {
                debuggerMethods[SET_EXIT_ACTION_METHOD].invoke
                    (debuggerInstance, new Object[] { r });
            } catch (InvocationTargetException ite) {
                throw new RuntimeException(ite.getMessage());
            } catch (IllegalAccessException iae) {
                throw new RuntimeException(iae.getMessage());
            }
        }

        /**
         * Calls {@code attachTo} on {@link #debuggerInstance}.
         */
        public void attachTo(Object contextFactory) {
            try {
                debuggerMethods[ATTACH_TO_METHOD].invoke
                    (debuggerInstance, new Object[] { contextFactory });
            } catch (InvocationTargetException ite) {
                throw new RuntimeException(ite.getMessage());
            } catch (IllegalAccessException iae) {
                throw new RuntimeException(iae.getMessage());
            }
        }

        /**
         * Calls {@code detach} on {@link #debuggerInstance}.
         */
        public void detach() {
            try {
                debuggerMethods[DETACH_METHOD].invoke(debuggerInstance,
                                                      (Object[]) null);
            } catch (InvocationTargetException ite) {
                throw new RuntimeException(ite.getMessage());
            } catch (IllegalAccessException iae) {
                throw new RuntimeException(iae.getMessage());
            }
        }

        /**
         * Calls {@code go} on {@link #debuggerInstance}.
         */
        public void go() {
            try {
                debuggerMethods[GO_METHOD].invoke(debuggerInstance,
                                                  (Object[]) null);
            } catch (InvocationTargetException ite) {
                throw new RuntimeException(ite.getMessage());
            } catch (IllegalAccessException iae) {
                throw new RuntimeException(iae.getMessage());
            }
        }

        /**
         * Calls {@code clearAllBreakpoints} on {@link #debuggerInstance}.
         */
        public void clearAllBreakpoints() {
            try {
                debuggerMethods[CLEAR_ALL_BREAKPOINTS_METHOD].invoke
                    (debuggerInstance, (Object[]) null);
            } catch (InvocationTargetException ite) {
                throw new RuntimeException(ite.getMessage());
            } catch (IllegalAccessException iae) {
                throw new RuntimeException(iae.getMessage());
            }
        }

        /**
         * Calls {@code dispose} on {@link #debuggerInstance}.
         */
        public void dispose() {
            try {
                debuggerMethods[DISPOSE_METHOD].invoke(debuggerInstance,
                                                       (Object[]) null);
            } catch (InvocationTargetException ite) {
                throw new RuntimeException(ite.getMessage());
            } catch (IllegalAccessException iae) {
                throw new RuntimeException(iae.getMessage());
            }
        }

        /**
         * Calls {@code getContextFactory} on the given instance of
         * {@link org.apache.flex.forks.batik.script.rhino.RhinoInterpreter}.
         */
        protected Object getContextFactory(Object rhinoInterpreter) {
            try {
                return getContextFactoryMethod.invoke(rhinoInterpreter,
                                                      (Object[]) null);
            } catch (InvocationTargetException ite) {
                throw new RuntimeException(ite.getMessage());
            } catch (IllegalAccessException iae) {
                throw new RuntimeException(iae.getMessage());
            }
        }
    }

    /**
     * To show the about dialog
     */
    public class AboutAction extends AbstractAction {
        public AboutAction(){
        }

        public void actionPerformed(ActionEvent e){
            AboutDialog dlg = new AboutDialog(JSVGViewerFrame.this);
            // Work around pack() bug on some platforms
            dlg.setSize(dlg.getPreferredSize());
            dlg.setLocationRelativeTo(JSVGViewerFrame.this);
            dlg.setVisible(true);
            dlg.toFront();
        }
    }

    /**
     * To open a new file.
     */
    public class OpenAction extends AbstractAction {

        public OpenAction() {
        }
        public void actionPerformed(ActionEvent e) {
            File f = null;
            if (Platform.isOSX) {
                FileDialog fileDialog =
                    new FileDialog(JSVGViewerFrame.this,
                                   Resources.getString(OPEN_TITLE));
                fileDialog.setFilenameFilter(new FilenameFilter() {
                    public boolean accept(File dir, String name) {
                        Iterator iter = getHandlers().iterator();
                        while (iter.hasNext()) {
                            SquiggleInputHandler handler
                                = (SquiggleInputHandler)iter.next();
                            if (handler.accept(new File(dir, name))) {
                                return true;
                            }
                        }
                        return false;
                    }
                });
                fileDialog.setVisible(true);
                String filename = fileDialog.getFile();
                if (fileDialog != null) {
                    String dirname = fileDialog.getDirectory();
                    f = new File(dirname, filename);
                }
            } else {
                JFileChooser fileChooser = null;

                // Apply work around Windows problem when security is enabled,
                // and when prior to JDK 1.4.
                String os = System.getProperty(PROPERTY_OS_NAME, PROPERTY_OS_NAME_DEFAULT);
                SecurityManager sm = System.getSecurityManager();

                if ( priorJDK1_4 && sm != null && os.indexOf(PROPERTY_OS_WINDOWS_PREFIX) != -1 ){
                    fileChooser = new JFileChooser(makeAbsolute(currentPath),
                                                   new WindowsAltFileSystemView());
                } else {
                    fileChooser = new JFileChooser(makeAbsolute(currentPath));
                }

                fileChooser.setFileHidingEnabled(false);
                fileChooser.setFileSelectionMode
                    (JFileChooser.FILES_ONLY);

                //
                // Add file filters from the handlers map
                //
                Iterator iter = getHandlers().iterator();
                while (iter.hasNext()) {
                    SquiggleInputHandler handler
                        = (SquiggleInputHandler)iter.next();
                    fileChooser.addChoosableFileFilter
                        (new SquiggleInputHandlerFilter(handler));
                }

                int choice = fileChooser.showOpenDialog(JSVGViewerFrame.this);
                if (choice == JFileChooser.APPROVE_OPTION) {
                    f = fileChooser.getSelectedFile();
                    currentPath = f;
                }
            }

            if (f != null) {
                try {
                    String furl = f.toURL().toString();
                    showSVGDocument(furl);
                } catch (MalformedURLException ex) {
                    if (userAgent != null) {
                        userAgent.displayError(ex);
                    }
                }
            }
        }
    }

    /**
     * Shows the given document into the viewer frame
     */
    public void showSVGDocument(String uri){
        try {
            ParsedURL purl = new ParsedURL(uri);
            SquiggleInputHandler
                handler = getInputHandler(purl);

            handler.handle(purl,
                           JSVGViewerFrame.this);
        } catch (Exception e) {
            if (userAgent != null) {
                userAgent.displayError(e);
            }
        }

    }

    /**
     * Returns the input handler for the given URI
     */
    public SquiggleInputHandler getInputHandler(ParsedURL purl) throws IOException {
        Iterator iter = getHandlers().iterator();
        SquiggleInputHandler handler = null;

        while (iter.hasNext()) {
            SquiggleInputHandler curHandler =
                (SquiggleInputHandler)iter.next();
            if (curHandler.accept(purl)) {
                handler = curHandler;
                break;
            }
        }

        // No handler found, use the default one.
        if (handler == null) {
            handler = defaultHandler;
        }

        return handler;
    }


    /**
     * Returns the list of input file handler.
     */
    protected static Vector getHandlers() {
        if (handlers != null) {
            return handlers;
        }

        handlers = new Vector();
        registerHandler(new SVGInputHandler());

        Iterator iter = Service.providers(SquiggleInputHandler.class);
        while (iter.hasNext()) {
            SquiggleInputHandler handler
                = (SquiggleInputHandler)iter.next();

            registerHandler(handler);
        }

        return handlers;
    }

    /**
     * Registers an input file handler by adding it to the handlers map.
     * @param handler the new input handler to register.
     */
    public static synchronized
        void registerHandler(SquiggleInputHandler handler) {
        Vector handlers = getHandlers();
        handlers.addElement(handler);
    }

    /**
     * To open a new document.
     */
    public class OpenLocationAction extends AbstractAction {
        public OpenLocationAction() {}
        public void actionPerformed(ActionEvent e) {
            if (uriChooser == null) {
                uriChooser = new URIChooser(JSVGViewerFrame.this);
                uriChooser.setFileFilter(new SVGFileFilter());
                uriChooser.pack();
                Rectangle fr = getBounds();
                Dimension sd = uriChooser.getSize();
                uriChooser.setLocation(fr.x + (fr.width  - sd.width) / 2,
                                       fr.y + (fr.height - sd.height) / 2);
            }
            if (uriChooser.showDialog() == URIChooser.OK_OPTION) {
                String s = uriChooser.getText();
                if (s == null) return;
                int i = s.indexOf( '#' );
                String t = "";
                if (i != -1) {
                    t = s.substring(i + 1);
                    s = s.substring(0, i);
                }
                if (!s.equals("")) {
                    File f = new File(s);
                    if (f.exists()) {
                        if (f.isDirectory()) {
                            s = null;
                        } else {
                            try {
                                s = f.getCanonicalPath();
                                if (s.startsWith("/")) {
                                    s = "file:" + s;
                                } else {
                                    s = "file:/" + s;
                                }
                            } catch (IOException ex) {
                            }
                        }
                    }
                    if (s != null) {
                        if (svgDocument != null) {
                            ParsedURL docPURL
                                = new ParsedURL(svgDocument.getURL());
                            ParsedURL purl = new ParsedURL(docPURL, s);
                            String fi = svgCanvas.getFragmentIdentifier();
                            if (docPURL.equals(purl) && t.equals(fi)) {
                                return;
                            }
                        }
                        if (t.length() != 0) {
                            s += '#' + t;
                        }

                        showSVGDocument(s);
                    }
                }
            }
        }
    }

    /**
     * To open a new window.
     */
    public class NewWindowAction extends AbstractAction {
        public NewWindowAction() {}
        public void actionPerformed(ActionEvent e) {
            JSVGViewerFrame vf = application.createAndShowJSVGViewerFrame();

            // Copy the current settings to the new window.
            vf.autoAdjust = autoAdjust;
            vf.debug = debug;
            vf.svgCanvas.setProgressivePaint(svgCanvas.getProgressivePaint());
            vf.svgCanvas.setDoubleBufferedRendering
                (svgCanvas.getDoubleBufferedRendering());
        }
    }

    /**
     * To show the preferences.
     */
    public class PreferencesAction extends AbstractAction {
        public PreferencesAction() {}
        public void actionPerformed(ActionEvent e) {
            application.showPreferenceDialog(JSVGViewerFrame.this);
        }
    }

    /**
     * To close the last document.
     */
    public class CloseAction extends AbstractAction {
        public CloseAction() {}
        public void actionPerformed(ActionEvent e) {
            application.closeJSVGViewerFrame(JSVGViewerFrame.this);
        }
    }

    /**
     * To reload the current document.
     */
    public class ReloadAction extends AbstractAction {
        public ReloadAction() {}
        public void actionPerformed(ActionEvent e) {
            if ((e.getModifiers() & ActionEvent.SHIFT_MASK) == 1) {
                svgCanvas.flushImageCache();
            }
            if (svgDocument != null) {
                localHistory.reload();
            }
        }
    }

    /**
     * To go back to the previous document
     */
    public class BackAction extends    AbstractAction
                            implements JComponentModifier {
        List components = new LinkedList();
        public BackAction() {}
        public void actionPerformed(ActionEvent e) {
            if (localHistory.canGoBack()) {
                localHistory.back();
            }
        }

        public void addJComponent(JComponent c) {
            components.add(c);
            c.setEnabled(false);
        }

        protected void update() {
            boolean b = localHistory.canGoBack();
            Iterator it = components.iterator();
            while (it.hasNext()) {
                ((JComponent)it.next()).setEnabled(b);
            }
        }
    }

    /**
     * To go forward to the next document
     */
    public class ForwardAction extends    AbstractAction
                               implements JComponentModifier {
        List components = new LinkedList();
        public ForwardAction() {}
        public void actionPerformed(ActionEvent e) {
            if (localHistory.canGoForward()) {
                localHistory.forward();
            }
        }

        public void addJComponent(JComponent c) {
            components.add(c);
            c.setEnabled(false);
        }

        protected void update() {
            boolean b = localHistory.canGoForward();
            Iterator it = components.iterator();
            while (it.hasNext()) {
                ((JComponent)it.next()).setEnabled(b);
            }
        }
    }

    /**
     * To print the current document.
     */
    public class PrintAction extends AbstractAction {
        public PrintAction() {}
        public void actionPerformed(ActionEvent e) {
            if (svgDocument != null) {
                final SVGDocument doc = svgDocument;
                new Thread() {
                    public void run(){
                        String uri = doc.getURL();
                        String fragment = svgCanvas.getFragmentIdentifier();
                        if (fragment != null) {
                            uri += '#' +fragment;
                        }

                        //
                        // Build a PrintTranscoder to handle printing
                        // of the svgDocument object
                        //
                        PrintTranscoder pt = new PrintTranscoder();

                        //
                        // Set transcoding hints
                        //
                        if (application.getXMLParserClassName() != null) {
                            pt.addTranscodingHint
                                (JPEGTranscoder.KEY_XML_PARSER_CLASSNAME,
                                    application.getXMLParserClassName());
                        }

                        pt.addTranscodingHint(PrintTranscoder.KEY_SHOW_PAGE_DIALOG,
                                              Boolean.TRUE);


                        pt.addTranscodingHint(PrintTranscoder.KEY_SHOW_PRINTER_DIALOG,
                                              Boolean.TRUE);

                        //
                        // Do transcoding now
                        //
                        pt.transcode(new TranscoderInput(uri), null);

                        //
                        // Print
                        //
                        try {
                            pt.print();
                        } catch (PrinterException ex) {
                            userAgent.displayError(ex);
                        }
                    }
                }.start();
            }
        }
    }

    /**
     * To save the current document as SVG.
     */
    public class SaveAsAction extends AbstractAction {
        public SaveAsAction() {}

        public void actionPerformed(ActionEvent e) {
            JFileChooser fileChooser;
            fileChooser = new JFileChooser(makeAbsolute(currentSavePath));
            fileChooser.setDialogTitle(resources.getString("SaveAs.title"));
            fileChooser.setFileHidingEnabled(false);
            fileChooser.setFileSelectionMode(JFileChooser.FILES_ONLY);
            fileChooser.addChoosableFileFilter(new ImageFileFilter(".svg"));

            int choice = fileChooser.showSaveDialog(JSVGViewerFrame.this);
            if (choice != JFileChooser.APPROVE_OPTION)
                return;

            final File f = fileChooser.getSelectedFile();

            SVGOptionPanel sop;
            sop = SVGOptionPanel.showDialog(JSVGViewerFrame.this);

            final boolean useXMLBase  = sop.getUseXMLBase();
            final boolean prettyPrint = sop.getPrettyPrint();
            sop = null;

            final SVGDocument svgDoc = svgCanvas.getSVGDocument();
            if (svgDoc == null) return;

            statusBar.setMessage(resources.getString("Message.saveAs"));
            currentSavePath = f;
            OutputStreamWriter w = null;
            try {
                OutputStream tos = null;
                tos = new FileOutputStream(f);
                tos = new BufferedOutputStream(tos);
                w = new OutputStreamWriter(tos, "utf-8");
            } catch (Exception ex) {
                userAgent.displayError(ex);
                return;
            }

            final OutputStreamWriter writer  = w;

            final Runnable doneRun = new Runnable() {
                    public void run() {
                        String doneStr = resources.getString("Message.done");
                        statusBar.setMessage(doneStr);
                    }
                };
            Runnable r = new Runnable() {
                    public void run() {
                        try {
                            // Write standard XML header.
                            writer.write
                                ("<?xml version=\"1.0\" encoding=\"utf-8\"?>");
                                writer.write (EOL);

                            Node fc = svgDoc.getFirstChild();
                            if (fc.getNodeType() != Node.DOCUMENT_TYPE_NODE) {
                                // Not DT node in Document, so
                                // provide Document Type dec.
                                writer.write ("<!DOCTYPE svg PUBLIC '");
                                writer.write (SVGConstants.SVG_PUBLIC_ID);
                                writer.write ("' '");
                                writer.write (SVGConstants.SVG_SYSTEM_ID);
                                writer.write ("'>");
                                writer.write (EOL);
                                writer.write (EOL);
                            }
                            Element root = svgDoc.getRootElement();
                            boolean doXMLBase = useXMLBase;
                            if (root.hasAttributeNS
                                (XMLConstants.XML_NAMESPACE_URI, "base"))
                                doXMLBase = false;

                            if (doXMLBase) {
                                root.setAttributeNS
                                    (XMLConstants.XML_NAMESPACE_URI,
                                     "xml:base",
                                     svgDoc.getURL());
                            }

                            if (prettyPrint) {
                                SVGTranscoder trans = new SVGTranscoder();
                                trans.transcode(new TranscoderInput(svgDoc),
                                                new TranscoderOutput(writer));
                            } else {
                                DOMUtilities.writeDocument(svgDoc, writer);
                            }

                            writer.close();

                            if (doXMLBase)
                                root.removeAttributeNS
                                    (XMLConstants.XML_NAMESPACE_URI,
                                     "xml:base");

                            if (EventQueue.isDispatchThread()) {
                                doneRun.run();
                            } else {
                                EventQueue.invokeLater(doneRun);
                            }
                        } catch (Exception ex) {
                            userAgent.displayError(ex);
                        }
                    }
                };

            UpdateManager um = svgCanvas.getUpdateManager();
            if ((um != null) && (um.isRunning())) {
                um.getUpdateRunnableQueue().invokeLater(r);
            } else {
                r.run();
            }
        }
    }

    /**
     * To save the current document as JPG.
     */
    public class ExportAsJPGAction extends AbstractAction {
        public ExportAsJPGAction() {}
        public void actionPerformed(ActionEvent e) {
            JFileChooser fileChooser =
                new JFileChooser(makeAbsolute(currentSavePath));
            fileChooser.setDialogTitle(resources.getString("ExportAsJPG.title"));
            fileChooser.setFileHidingEnabled(false);
            fileChooser.setFileSelectionMode
                (JFileChooser.FILES_ONLY);
            fileChooser.addChoosableFileFilter(new ImageFileFilter(".jpg"));

            int choice = fileChooser.showSaveDialog(JSVGViewerFrame.this);
            if (choice == JFileChooser.APPROVE_OPTION) {
                float quality =
                    JPEGOptionPanel.showDialog(JSVGViewerFrame.this);

                final File f = fileChooser.getSelectedFile();
                BufferedImage buffer = svgCanvas.getOffScreen();
                if (buffer != null) {
                    statusBar.setMessage
                        (resources.getString("Message.exportAsJPG"));

                    // create a BufferedImage of the appropriate type
                    int w = buffer.getWidth();
                    int h = buffer.getHeight();
                    final ImageTranscoder trans = new JPEGTranscoder();
                    if (application.getXMLParserClassName() != null) {
                        trans.addTranscodingHint
                            (JPEGTranscoder.KEY_XML_PARSER_CLASSNAME,
                                application.getXMLParserClassName());
                    }
                    trans.addTranscodingHint
                        (JPEGTranscoder.KEY_QUALITY, new Float(quality));

                    final BufferedImage img = trans.createImage(w, h);

                    // paint the buffer to the image
                    Graphics2D g2d = img.createGraphics();
                    g2d.setColor(Color.white);
                    g2d.fillRect(0, 0, w, h);
                    g2d.drawImage(buffer, null, 0, 0);
                    new Thread() {
                        public void run() {
                            try {
                                currentSavePath = f;
                                OutputStream ostream =
                                    new BufferedOutputStream(new FileOutputStream(f));
                                trans.writeImage(img, new TranscoderOutput(ostream));
                                ostream.close();
                            } catch (Exception ex) { }
                            statusBar.setMessage
                                (resources.getString("Message.done"));
                        }
                    }.start();
                }
            }
        }
    }

    /**
     * To save the current document as PNG.
     */
    public class ExportAsPNGAction extends AbstractAction {
        public ExportAsPNGAction() {}
        public void actionPerformed(ActionEvent e) {
            JFileChooser fileChooser =
                new JFileChooser(makeAbsolute(currentSavePath));
            fileChooser.setDialogTitle(resources.getString("ExportAsPNG.title"));
            fileChooser.setFileHidingEnabled(false);
            fileChooser.setFileSelectionMode
                (JFileChooser.FILES_ONLY);
            fileChooser.addChoosableFileFilter(new ImageFileFilter(".png"));

            int choice = fileChooser.showSaveDialog(JSVGViewerFrame.this);
            if (choice == JFileChooser.APPROVE_OPTION) {

            // Start: By Jun Inamori (jun@oop-reserch.com)
            boolean isIndexed = PNGOptionPanel.showDialog(JSVGViewerFrame.this);
            // End: By Jun Inamori (jun@oop-reserch.com)

                final File f = fileChooser.getSelectedFile();
                BufferedImage buffer = svgCanvas.getOffScreen();
                if (buffer != null) {
                    statusBar.setMessage
                        (resources.getString("Message.exportAsPNG"));

                    // create a BufferedImage of the appropriate type
                    int w = buffer.getWidth();
                    int h = buffer.getHeight();
                    final ImageTranscoder trans = new PNGTranscoder();
                    if (application.getXMLParserClassName() != null) {
                        trans.addTranscodingHint
                            (JPEGTranscoder.KEY_XML_PARSER_CLASSNAME,
                                application.getXMLParserClassName());
                    }
                    trans.addTranscodingHint(PNGTranscoder.KEY_FORCE_TRANSPARENT_WHITE,
                                             Boolean.TRUE );

            // Start: By Jun Inamori
            if(isIndexed){
                trans.addTranscodingHint(PNGTranscoder.KEY_INDEXED,new Integer(256));
            }
            // End: By Jun Inamori

                    final BufferedImage img = trans.createImage(w, h);

                    // paint the buffer to the image
                    Graphics2D g2d = img.createGraphics();
                    g2d.drawImage(buffer, null, 0, 0);
                    new Thread() {
                        public void run() {
                            try {
                                currentSavePath = f;
                                OutputStream ostream =
                                    new BufferedOutputStream(new FileOutputStream(f));
                                trans.writeImage(img,
                                                 new TranscoderOutput(ostream));
                                ostream.close();
                            } catch (Exception ex) {}
                            statusBar.setMessage
                                (resources.getString("Message.done"));
                        }
                    }.start();
                }
            }
        }
    }

    /**
     * To save the current document as TIFF.
     */
    public class ExportAsTIFFAction extends AbstractAction {
        public ExportAsTIFFAction() {}
        public void actionPerformed(ActionEvent e) {
            JFileChooser fileChooser =
                new JFileChooser(makeAbsolute(currentSavePath));
            fileChooser.setDialogTitle(resources.getString("ExportAsTIFF.title"));
            fileChooser.setFileHidingEnabled(false);
            fileChooser.setFileSelectionMode
                (JFileChooser.FILES_ONLY);
            fileChooser.addChoosableFileFilter(new ImageFileFilter(".tiff"));

            int choice = fileChooser.showSaveDialog(JSVGViewerFrame.this);
            if (choice == JFileChooser.APPROVE_OPTION) {
                final File f = fileChooser.getSelectedFile();
                BufferedImage buffer = svgCanvas.getOffScreen();
                if (buffer != null) {
                    statusBar.setMessage
                        (resources.getString("Message.exportAsTIFF"));

                    // create a BufferedImage of the appropriate type
                    int w = buffer.getWidth();
                    int h = buffer.getHeight();
                    final ImageTranscoder trans = new TIFFTranscoder();
                    if (application.getXMLParserClassName() != null) {
                        trans.addTranscodingHint
                            (JPEGTranscoder.KEY_XML_PARSER_CLASSNAME,
                                application.getXMLParserClassName());
                    }
                    final BufferedImage img = trans.createImage(w, h);

                    // paint the buffer to the image
                    Graphics2D g2d = img.createGraphics();
                    g2d.drawImage(buffer, null, 0, 0);
                    new Thread() {
                        public void run() {
                            try {
                                currentSavePath = f;
                                OutputStream ostream = new BufferedOutputStream
                                    (new FileOutputStream(f));
                                trans.writeImage
                                    (img, new TranscoderOutput(ostream));
                                ostream.close();
                            } catch (Exception ex) {}
                            statusBar.setMessage
                                (resources.getString("Message.done"));
                        }
                    }.start();
                }
            }
        }
    }

    /**
     * To view the source of the current document.
     */
    public class ViewSourceAction extends AbstractAction {
        public ViewSourceAction() {}
        public void actionPerformed(ActionEvent e) {
            if (svgDocument == null) {
                return;
            }

            final ParsedURL u = new ParsedURL(svgDocument.getURL());

            final JFrame fr = new JFrame(u.toString());
            fr.setSize(resources.getInteger("ViewSource.width"),
                       resources.getInteger("ViewSource.height"));
            final XMLTextEditor ta  = new XMLTextEditor();
            // ta.setLineWrap(true);
            ta.setFont(new Font("monospaced", Font.PLAIN, 12));

            JScrollPane scroll = new JScrollPane();
            scroll.getViewport().add(ta);
            scroll.setVerticalScrollBarPolicy
                (JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
            fr.getContentPane().add(scroll, BorderLayout.CENTER);

            new Thread() {
                public void run() {
                    char [] buffer = new char[4096];

                    try {
                        Document  doc = new XMLDocument();

                        ParsedURL purl = new ParsedURL(svgDocument.getURL());
                        InputStream is
                            = u.openStream(getInputHandler(purl).
                                           getHandledMimeTypes());
                        // u.openStream(MimeTypeConstants.MIME_TYPES_SVG);

                        Reader in = XMLUtilities.createXMLDocumentReader(is);
                        int len;
                        while ((len=in.read(buffer, 0, buffer.length)) != -1) {
                            doc.insertString(doc.getLength(),
                                             new String(buffer, 0, len), null);
                        }

                        ta.setDocument(doc);
                        ta.setEditable(false);
                        // ta.setBackground(Color.white);
                        fr.setVisible(true);
                    } catch (Exception ex) {
                        userAgent.displayError(ex);
                    }
                }
            }.start();
        }
    }

    /**
     * To flush image cache (purely for debugging purposes)
     */
    public class FlushAction extends AbstractAction {
        public FlushAction() {}
        public void actionPerformed(ActionEvent e) {
            svgCanvas.flush();
            // Force redraw...
            svgCanvas.setRenderingTransform(svgCanvas.getRenderingTransform());
        }
    }

    /**
     * To toggle visiblity of JavaScript Debugger.
     */
    public class ToggleDebuggerAction extends AbstractAction {
        public ToggleDebuggerAction() {
            super("Toggle Debugger Action");
        }

        public void actionPerformed(ActionEvent e) {
            if (debugger == null) {
                showDebugger();
            } else {
                hideDebugger();
            }
        }
    }

    /**
     * To go back to the previous transform
     */
    public class PreviousTransformAction extends    AbstractAction
                                         implements JComponentModifier {
        List components = new LinkedList();
        public PreviousTransformAction() {}
        public void actionPerformed(ActionEvent e) {
            if (transformHistory.canGoBack()) {
                transformHistory.back();
                update();
                nextTransformAction.update();
                svgCanvas.setRenderingTransform(transformHistory.currentTransform());
            }
        }

        public void addJComponent(JComponent c) {
            components.add(c);
            c.setEnabled(false);
        }

        protected void update() {
            boolean b = transformHistory.canGoBack();
            Iterator it = components.iterator();
            while (it.hasNext()) {
                ((JComponent)it.next()).setEnabled(b);
            }
        }
    }

    /**
     * To go forward to the next transform
     */
    public class NextTransformAction extends    AbstractAction
                                         implements JComponentModifier {
        List components = new LinkedList();
        public NextTransformAction() {}
        public void actionPerformed(ActionEvent e) {
            if (transformHistory.canGoForward()) {
                transformHistory.forward();
                update();
                previousTransformAction.update();
                svgCanvas.setRenderingTransform(transformHistory.currentTransform());
            }
        }

        public void addJComponent(JComponent c) {
            components.add(c);
            c.setEnabled(false);
        }

        protected void update() {
            boolean b = transformHistory.canGoForward();
            Iterator it = components.iterator();
            while (it.hasNext()) {
                ((JComponent)it.next()).setEnabled(b);
            }
        }
    }

    /**
     * To apply the selected author stylesheet
     */
    public class UseStylesheetAction extends    AbstractAction
                                     implements JComponentModifier {

        List components = new LinkedList();

        public UseStylesheetAction() {}

        public void actionPerformed(ActionEvent e) {
        }

        public void addJComponent(JComponent c) {
            components.add(c);
            c.setEnabled(false);
        }

        protected void update() {
            alternateStyleSheet = null;
            Iterator it = components.iterator();
            SVGDocument doc = svgCanvas.getSVGDocument();
            while (it.hasNext()) {
                JComponent stylesheetMenu = (JComponent)it.next();
                stylesheetMenu.removeAll();
                stylesheetMenu.setEnabled(false);

                ButtonGroup buttonGroup = new ButtonGroup();

                for (Node n = doc.getFirstChild();
                     n != null && n.getNodeType() != Node.ELEMENT_NODE;
                     n = n.getNextSibling()) {
                    if (n instanceof StyleSheetProcessingInstruction) {
                        StyleSheetProcessingInstruction sspi;
                        sspi = (StyleSheetProcessingInstruction)n;
                        HashTable attrs = sspi.getPseudoAttributes();
                        final String title = (String)attrs.get("title");
                        String alt = (String)attrs.get("alternate");
                        if (title != null && "yes".equals(alt)) {
                            JRadioButtonMenuItem button;
                            button = new JRadioButtonMenuItem(title);

                            button.addActionListener
                                (new java.awt.event.ActionListener() {
                                    public void actionPerformed(ActionEvent e) {
                                        SVGOMDocument doc;
                                        doc = (SVGOMDocument)svgCanvas.getSVGDocument();
                                        doc.clearViewCSS();
                                        alternateStyleSheet = title;
                                        svgCanvas.setSVGDocument(doc);
                                    }
                                });

                            buttonGroup.add(button);
                            stylesheetMenu.add(button);
                            stylesheetMenu.setEnabled(true);
                        }
                    }
                }
            }
        }
    }

    /**
     * To restart after a pause.
     */
    public class PlayAction extends   AbstractAction
                            implements JComponentModifier {
        List components = new LinkedList();
        public PlayAction() {}
        public void actionPerformed(ActionEvent e) {
            svgCanvas.resumeProcessing();
        }

        public void addJComponent(JComponent c) {
            components.add(c);
            c.setEnabled(false);
        }

        public void update(boolean enabled) {
            Iterator it = components.iterator();
            while (it.hasNext()) {
                ((JComponent)it.next()).setEnabled(enabled);
            }
        }
    }

    /**
     * To pause a document.
     */
    public class PauseAction extends   AbstractAction
                            implements JComponentModifier {
        List components = new LinkedList();
        public PauseAction() {}
        public void actionPerformed(ActionEvent e) {
            svgCanvas.suspendProcessing();
        }

        public void addJComponent(JComponent c) {
            components.add(c);
            c.setEnabled(false);
        }

        public void update(boolean enabled) {
            Iterator it = components.iterator();
            while (it.hasNext()) {
                ((JComponent)it.next()).setEnabled(enabled);
            }
        }
    }

    /**
     * To stop the current processing.
     */
    public class StopAction extends    AbstractAction
                            implements JComponentModifier {
        List components = new LinkedList();
        public StopAction() {}
        public void actionPerformed(ActionEvent e) {
            svgCanvas.stopProcessing();
        }

        public void addJComponent(JComponent c) {
            components.add(c);
            c.setEnabled(false);
        }

        public void update(boolean enabled) {
            Iterator it = components.iterator();
            while (it.hasNext()) {
                ((JComponent)it.next()).setEnabled(enabled);
            }
        }
    }

    /**
     * To show the set transform dialog
     */
    public class SetTransformAction extends AbstractAction {
        public SetTransformAction(){}
        public void actionPerformed(ActionEvent e){
            if (transformDialog == null){
                transformDialog
                    = JAffineTransformChooser.createDialog
                    (JSVGViewerFrame.this,
                     resources.getString("SetTransform.title"));
            }

            AffineTransform txf = transformDialog.showDialog();
            if(txf != null){
                AffineTransform at = svgCanvas.getRenderingTransform();
                if(at == null){
                    at = new AffineTransform();
                }

                txf.concatenate(at);
                svgCanvas.setRenderingTransform(txf);
            }
        }
    }

    /**
     * To display the memory monitor.
     */
    public class MonitorAction extends AbstractAction {
        public MonitorAction() {}
        public void actionPerformed(ActionEvent e) {
            if (memoryMonitorFrame == null) {
                memoryMonitorFrame = new MemoryMonitor();
                Rectangle fr = getBounds();
                Dimension md = memoryMonitorFrame.getSize();
                memoryMonitorFrame.setLocation(fr.x + (fr.width  - md.width) / 2,
                                               fr.y + (fr.height - md.height) / 2);
            }
            memoryMonitorFrame.setVisible(true);
        }
    }

    /**
     * To display the Find dialog
     */
    public class FindDialogAction extends AbstractAction {
        public FindDialogAction() {}
        public void actionPerformed(ActionEvent e) {
            if (findDialog == null) {
                findDialog = new FindDialog(JSVGViewerFrame.this, svgCanvas);
                findDialog.setGraphicsNode(svgCanvas.getGraphicsNode());
                findDialog.pack();
                Rectangle fr = getBounds();
                Dimension td = findDialog.getSize();
                findDialog.setLocation(fr.x + (fr.width  - td.width) / 2,
                                       fr.y + (fr.height - td.height) / 2);
            }
            findDialog.setVisible(true);
        }
    }

    /**
     * To display the Thumbnail dialog
     */
    public class ThumbnailDialogAction extends AbstractAction {
        public ThumbnailDialogAction() {}
        public void actionPerformed(ActionEvent e) {
            if (thumbnailDialog == null) {
                thumbnailDialog
                    = new ThumbnailDialog(JSVGViewerFrame.this, svgCanvas);
                thumbnailDialog.pack();
                Rectangle fr = getBounds();
                Dimension td = thumbnailDialog.getSize();
                thumbnailDialog.setLocation(fr.x + (fr.width  - td.width) / 2,
                                            fr.y + (fr.height - td.height) / 2);
            }
            thumbnailDialog.setInteractionEnabled
                (!svgCanvas.getDisableInteractions());
            thumbnailDialog.setVisible(true);
        }
    }

    /**
     * To display the document full screen
     */
    public class FullScreenAction extends AbstractAction {
        public FullScreenAction() {}

        public void actionPerformed(ActionEvent e) {
            if (window == null || !window.isVisible()) {
                if (window == null) {
                    window = new JWindow(JSVGViewerFrame.this);
                    Dimension size = Toolkit.getDefaultToolkit().getScreenSize();
                    window.setSize(size);
                }
                // Go to full screen in JWindow)
                svgCanvas.getParent().remove(svgCanvas);
                window.getContentPane().add(svgCanvas);
                window.setVisible(true);
                window.toFront();
                svgCanvas.requestFocus();
            } else {
                // Go back to JSVGViewerFrame display
                svgCanvas.getParent().remove(svgCanvas);
                svgCanvasPanel.add(svgCanvas, BorderLayout.CENTER);
                window.setVisible(false);
            }
        }
    }

    /**
     * To display the DOM viewer of the document
     */
    public class DOMViewerAction extends AbstractAction {

        public DOMViewerAction() {
        }

        public void actionPerformed(ActionEvent e) {
            openDOMViewer();
        }

        public void openDOMViewer() {
            if (domViewer == null || domViewer.isDisplayable()) {
                domViewer = new DOMViewer
                    (svgCanvas.new JSVGViewerDOMViewerController());
                Rectangle fr = getBounds();
                Dimension td = domViewer.getSize();
                domViewer.setLocation(fr.x + (fr.width - td.width) / 2,
                                      fr.y + (fr.height - td.height) / 2);
            }
            domViewer.setVisible(true);
        }

        public DOMViewer getDOMViewer() {
            return domViewer;
        }
    }

    // ActionMap /////////////////////////////////////////////////////

    /**
     * The map that contains the action listeners
     */
    protected Map listeners = new HashMap();

    /**
     * Returns the action associated with the given string
     * or null on error
     * @param key the key mapped with the action to get
     * @throws MissingListenerException if the action is not found
     */
    public Action getAction(String key) throws MissingListenerException {
        Action result = (Action)listeners.get(key);
        //if (result == null) {
        //result = canvas.getAction(key);
        //}
        if (result == null) {
            throw new MissingListenerException("Can't find action.", RESOURCES, key);
        }
        return result;
    }

    // SVGDocumentLoaderListener ///////////////////////////////////////////

    long time; // For debug.

    /**
     * Called when the loading of a document was started.
     */
    public void documentLoadingStarted(SVGDocumentLoaderEvent e) {
        String msg = resources.getString("Message.documentLoad");
        if (debug) {
            System.out.println(msg);
            time = System.currentTimeMillis();
        }
        statusBar.setMainMessage(msg);
        stopAction.update(true);
        svgCanvas.setCursor(WAIT_CURSOR);
    }


    /**
     * Called when the loading of a document was completed.
     */
    public void documentLoadingCompleted(SVGDocumentLoaderEvent e) {
        if (debug) {
            System.out.print(resources.getString("Message.documentLoadTime"));
            System.out.println((System.currentTimeMillis() - time) + " ms");
        }

        setSVGDocument(e.getSVGDocument(),
                       e.getSVGDocument().getURL(),
                       e.getSVGDocument().getTitle());
    }

    /**
     * Forces the viewer frame to show the input SVGDocument
     */
    public void setSVGDocument(SVGDocument svgDocument,
                               String svgDocumentURL,
                               String svgDocumentTitle) {
        this.svgDocument = svgDocument;

        if (domViewer != null) {
            if(domViewer.isVisible() && svgDocument != null) {
                domViewer.setDocument(svgDocument,
                                      (ViewCSS)svgDocument.getDocumentElement());
            } else {
                domViewer.dispose();
                domViewer = null;
            }
        }
        stopAction.update(false);
        svgCanvas.setCursor(DEFAULT_CURSOR);
        String s = svgDocumentURL;
        locationBar.setText(s);
        if (debugger != null) {
            debugger.detach();
            debugger.setDocumentURL(s);
        }
        if (title == null) {
            title = getTitle();
        }

        String dt = svgDocumentTitle;
        if (dt.length() != 0) {
            setTitle(title + ": " + dt);
        } else {
            int i = s.lastIndexOf("/");
            if (i == -1)
                i = s.lastIndexOf("\\");
            if (i == -1) {
                setTitle(title + ": " + s);
            } else {
                setTitle(title + ": " + s.substring(i + 1));
            }
        }

        localHistory.update(s);
        application.addVisitedURI(s);
        backAction.update();
        forwardAction.update();

        transformHistory = new TransformHistory();
        previousTransformAction.update();
        nextTransformAction.update();

        useStylesheetAction.update();
    }

    /**
     * Called when the loading of a document was cancelled.
     */
    public void documentLoadingCancelled(SVGDocumentLoaderEvent e) {
        String msg = resources.getString("Message.documentCancelled");
        if (debug) {
            System.out.println(msg);
        }
        statusBar.setMainMessage("");
        statusBar.setMessage(msg);
        stopAction.update(false);
        svgCanvas.setCursor(DEFAULT_CURSOR);
    }

    /**
     * Called when the loading of a document has failed.
     */
    public void documentLoadingFailed(SVGDocumentLoaderEvent e) {
        String msg = resources.getString("Message.documentFailed");
        if (debug) {
            System.out.println(msg);
        }
        statusBar.setMainMessage("");
        statusBar.setMessage(msg);
        stopAction.update(false);
        svgCanvas.setCursor(DEFAULT_CURSOR);
    }

    // GVTTreeBuilderListener //////////////////////////////////////////////

    /**
     * Called when a build started.
     * The data of the event is initialized to the old document.
     */
    public void gvtBuildStarted(GVTTreeBuilderEvent e) {
        String msg = resources.getString("Message.treeBuild");
        if (debug) {
            System.out.println(msg);
            time = System.currentTimeMillis();
        }
        statusBar.setMainMessage(msg);
        stopAction.update(true);
        svgCanvas.setCursor(WAIT_CURSOR);
    }

    /**
     * Called when a build was completed.
     */
    public void gvtBuildCompleted(GVTTreeBuilderEvent e) {
        if (debug) {
            System.out.print(resources.getString("Message.treeBuildTime"));
            System.out.println((System.currentTimeMillis() - time) + " ms");
        }
        if (findDialog != null) {
            if(findDialog.isVisible()) {
                findDialog.setGraphicsNode(svgCanvas.getGraphicsNode());
            } else {
                findDialog.dispose();
                findDialog = null;
            }
        }
        stopAction.update(false);
        svgCanvas.setCursor(DEFAULT_CURSOR);
        svgCanvas.setSelectionOverlayXORMode
            (application.isSelectionOverlayXORMode());
        svgCanvas.requestFocus();  // request focus when load completes.
        if (debugger != null) {
            debugger.attach();
        }
    }

    /**
     * Called when a build was cancelled.
     */
    public void gvtBuildCancelled(GVTTreeBuilderEvent e) {
        String msg = resources.getString("Message.treeCancelled");
        if (debug) {
            System.out.println(msg);
        }
        statusBar.setMainMessage("");
        statusBar.setMessage(msg);
        stopAction.update(false);
        svgCanvas.setCursor(DEFAULT_CURSOR);
        svgCanvas.setSelectionOverlayXORMode
            (application.isSelectionOverlayXORMode());
    }

    /**
     * Called when a build failed.
     */
    public void gvtBuildFailed(GVTTreeBuilderEvent e) {
        String msg = resources.getString("Message.treeFailed");
        if (debug) {
            System.out.println(msg);
        }
        statusBar.setMainMessage("");
        statusBar.setMessage(msg);
        stopAction.update(false);
        svgCanvas.setCursor(DEFAULT_CURSOR);
        svgCanvas.setSelectionOverlayXORMode
            (application.isSelectionOverlayXORMode());
        if (autoAdjust) {
            pack();
        }
    }

    // SVGLoadEventDispatcherListener //////////////////////////////////////

    /**
     * Called when a onload event dispatch started.
     */
    public void svgLoadEventDispatchStarted(SVGLoadEventDispatcherEvent e) {
        String msg = resources.getString("Message.onload");
        if (debug) {
            System.out.println(msg);
            time = System.currentTimeMillis();
        }
        stopAction.update(true);
        statusBar.setMainMessage(msg);
    }

    /**
     * Called when a onload event dispatch was completed.
     */
    public void svgLoadEventDispatchCompleted(SVGLoadEventDispatcherEvent e) {
        if (debug) {
            System.out.print(resources.getString("Message.onloadTime"));
            System.out.println((System.currentTimeMillis() - time) + " ms");
        }
        stopAction.update(false);
        statusBar.setMainMessage("");
        statusBar.setMessage(resources.getString("Message.done"));
    }

    /**
     * Called when a onload event dispatch was cancelled.
     */
    public void svgLoadEventDispatchCancelled(SVGLoadEventDispatcherEvent e) {
        String msg = resources.getString("Message.onloadCancelled");
        if (debug) {
            System.out.println(msg);
        }
        stopAction.update(false);
        statusBar.setMainMessage("");
        statusBar.setMessage(msg);
    }

    /**
     * Called when a onload event dispatch failed.
     */
    public void svgLoadEventDispatchFailed(SVGLoadEventDispatcherEvent e) {
        String msg = resources.getString("Message.onloadFailed");
        if (debug) {
            System.out.println(msg);
        }
        stopAction.update(false);
        statusBar.setMainMessage("");
        statusBar.setMessage(msg);
    }

    // GVTTreeRendererListener /////////////////////////////////////////////

    /**
     * Called when a rendering is in its preparing phase.
     */
    public void gvtRenderingPrepare(GVTTreeRendererEvent e) {
        if (debug) {
            String msg = resources.getString("Message.treeRenderingPrep");
            System.out.println(msg);
            time = System.currentTimeMillis();
        }
        stopAction.update(true);
        svgCanvas.setCursor(WAIT_CURSOR);
        statusBar.setMainMessage(resources.getString("Message.treeRendering"));
    }

    /**
     * Called when a rendering started.
     */
    public void gvtRenderingStarted(GVTTreeRendererEvent e) {
        if (debug) {
            String msg = resources.getString("Message.treeRenderingPrepTime");
            System.out.print(msg);
            System.out.println((System.currentTimeMillis() - time) + " ms");
            time = System.currentTimeMillis();
            msg = resources.getString("Message.treeRenderingStart");
            System.out.println(msg);
        }
        // Do nothing
    }

    /**
     * Called when a rendering was completed.
     */
    public void gvtRenderingCompleted(GVTTreeRendererEvent e) {
        if (debug) {
            String msg = resources.getString("Message.treeRenderingTime");
            System.out.print(msg);
            System.out.println((System.currentTimeMillis() - time) + " ms");
        }
        statusBar.setMainMessage("");
        statusBar.setMessage(resources.getString("Message.done"));
        if (!svgCanvas.isDynamic() || managerStopped) {
            stopAction.update(false);
        }
        svgCanvas.setCursor(DEFAULT_CURSOR);

        transformHistory.update(svgCanvas.getRenderingTransform());
        previousTransformAction.update();
        nextTransformAction.update();
    }

    /**
     * Called when a rendering was cancelled.
     */
    public void gvtRenderingCancelled(GVTTreeRendererEvent e) {
        String msg = resources.getString("Message.treeRenderingCancelled");
        if (debug) {
            System.out.println(msg);
        }
        statusBar.setMainMessage("");
        statusBar.setMessage(msg);
        if (!svgCanvas.isDynamic()) {
            stopAction.update(false);
        }
        svgCanvas.setCursor(DEFAULT_CURSOR);
    }

    /**
     * Called when a rendering failed.
     */
    public void gvtRenderingFailed(GVTTreeRendererEvent e) {
        String msg = resources.getString("Message.treeRenderingFailed");
        if (debug) {
            System.out.println(msg);
        }
        statusBar.setMainMessage("");
        statusBar.setMessage(msg);
        if (!svgCanvas.isDynamic()) {
            stopAction.update(false);
        }
        svgCanvas.setCursor(DEFAULT_CURSOR);
    }

    // LinkActivationListener /////////////////////////////////////////

    /**
     * Called when a link was activated.
     */
    public void linkActivated(LinkActivationEvent e) {
        String s = e.getReferencedURI();
        if (svgDocument != null) {
            ParsedURL docURL = new ParsedURL(svgDocument.getURL());
            ParsedURL url    = new ParsedURL(docURL, s);
            if (!url.sameFile(docURL)) {
                return;
            }

            if (s.indexOf( '#' ) != -1) {
                localHistory.update(s);
                locationBar.setText(s);
                if (debugger != null) {
                    debugger.detach();
                    debugger.setDocumentURL(s);
                }
                application.addVisitedURI(s);
                backAction.update();
                forwardAction.update();

                transformHistory = new TransformHistory();
                previousTransformAction.update();
                nextTransformAction.update();
            }
        }
    }

    // UpdateManagerListener ////////////////////////////////////////////////

    /**
     * Called when the manager was started.
     */
    public void managerStarted(UpdateManagerEvent e) {
        if (debug) {
            String msg = resources.getString("Message.updateManagerStarted");
            System.out.println(msg);
        }
        managerStopped = false;
        playAction.update(false);
        pauseAction.update(true);
        stopAction.update(true);
    }

    /**
     * Called when the manager was suspended.
     */
    public void managerSuspended(UpdateManagerEvent e) {
        if (debug) {
            String msg = resources.getString("Message.updateManagerSuspended");
            System.out.println(msg);
        }
        playAction.update(true);
        pauseAction.update(false);
    }

    /**
     * Called when the manager was resumed.
     */
    public void managerResumed(UpdateManagerEvent e) {
        if (debug) {
            String msg = resources.getString("Message.updateManagerResumed");
            System.out.println(msg);
        }
        playAction.update(false);
        pauseAction.update(true);
    }

    /**
     * Called when the manager was stopped.
     */
    public void managerStopped(UpdateManagerEvent e) {
        if (debug) {
            String msg = resources.getString("Message.updateManagerStopped");
            System.out.println(msg);
        }
        managerStopped = true;
        playAction.update(false);
        pauseAction.update(false);
        stopAction.update(false);
    }

    /**
     * Called when an update started.
     */
    public void updateStarted(final UpdateManagerEvent e) {
    }

    /**
     * Called when an update was completed.
     */
    public void updateCompleted(final UpdateManagerEvent e) {
    }

    /**
     * Called when an update failed.
     */
    public void updateFailed(UpdateManagerEvent e) {
    }

    /**
     * This class implements a SVG user agent.
     */
    protected class UserAgent implements SVGUserAgent {

        /**
         * Creates a new SVGUserAgent.
         */
        protected UserAgent() {
        }

        /**
         * Displays an error message.
         */
        public void displayError(String message) {
            if (debug) {
                System.err.println(message);
            }
            JOptionPane pane =
                new JOptionPane(message, JOptionPane.ERROR_MESSAGE);
            JDialog dialog = pane.createDialog(JSVGViewerFrame.this, "ERROR");
            dialog.setModal(false);
            dialog.setVisible(true);
        }

        /**
         * Displays an error resulting from the specified Exception.
         */
        public void displayError(Exception ex) {
            if (debug) {
                ex.printStackTrace();
            }
            JErrorPane pane =
                new JErrorPane(ex, JOptionPane.ERROR_MESSAGE);
            JDialog dialog = pane.createDialog(JSVGViewerFrame.this, "ERROR");
            dialog.setModal(false);
            dialog.setVisible(true);
        }

        /**
         * Displays a message in the User Agent interface.
         * The given message is typically displayed in a status bar.
         */
        public void displayMessage(String message) {
            statusBar.setMessage(message);
        }

        /**
         * Shows an alert dialog box.
         */
        public void showAlert(String message) {
            svgCanvas.showAlert(message);
        }

        /**
         * Shows a prompt dialog box.
         */
        public String showPrompt(String message) {
            return svgCanvas.showPrompt(message);
        }

        /**
         * Shows a prompt dialog box.
         */
        public String showPrompt(String message, String defaultValue) {
            return svgCanvas.showPrompt(message, defaultValue);
        }

        /**
         * Shows a confirm dialog box.
         */
        public boolean showConfirm(String message) {
            return svgCanvas.showConfirm(message);
        }

        /**
         * Returns the size of a px CSS unit in millimeters.
         */
        public float getPixelUnitToMillimeter() {
            return 0.26458333333333333333333333333333f; // 96dpi
        }

        /**
         * Returns the size of a px CSS unit in millimeters.
         * This will be removed after next release.
         * @see #getPixelUnitToMillimeter()
         */
        public float getPixelToMM() {
            return getPixelUnitToMillimeter();

        }

        /**
         * Returns the default font family.
         */
        public String getDefaultFontFamily() {
            return application.getDefaultFontFamily();
        }

        /**
         * Returns the  medium font size.
         */
        public float getMediumFontSize() {
            // 9pt (72pt == 1in)
            return 9f * 25.4f / (72f * getPixelUnitToMillimeter());
        }

        /**
         * Returns a lighter font-weight.
         */
        public float getLighterFontWeight(float f) {
            // Round f to nearest 100...
            int weight = ((int)((f+50)/100))*100;
            switch (weight) {
            case 100: return 100;
            case 200: return 100;
            case 300: return 200;
            case 400: return 300;
            case 500: return 400;
            case 600: return 400;
            case 700: return 400;
            case 800: return 400;
            case 900: return 400;
            default:
                throw new IllegalArgumentException("Bad Font Weight: " + f);
            }
        }

        /**
         * Returns a bolder font-weight.
         */
        public float getBolderFontWeight(float f) {
            // Round f to nearest 100...
            int weight = ((int)((f+50)/100))*100;
            switch (weight) {
            case 100: return 600;
            case 200: return 600;
            case 300: return 600;
            case 400: return 600;
            case 500: return 600;
            case 600: return 700;
            case 700: return 800;
            case 800: return 900;
            case 900: return 900;
            default:
                throw new IllegalArgumentException("Bad Font Weight: " + f);
            }
        }


        /**
         * Returns the language settings.
         */
        public String getLanguages() {
            return application.getLanguages();
        }

        /**
         * Returns the user stylesheet uri.
         * @return null if no user style sheet was specified.
         */
        public String getUserStyleSheetURI() {
            return application.getUserStyleSheetURI();
        }

        /**
         * Returns the class name of the XML parser.
         */
        public String getXMLParserClassName() {
            return application.getXMLParserClassName();
        }

        /**
         * Returns true if the XML parser must be in validation mode, false
         * otherwise.
         */
        public boolean isXMLParserValidating() {
            return application.isXMLParserValidating();
        }

        /**
         * Returns this user agent's CSS media.
         */
        public String getMedia() {
            return application.getMedia();
        }

        /**
         * Returns this user agent's alternate style-sheet title.
         */
        public String getAlternateStyleSheet() {
            return alternateStyleSheet;
        }

        /**
         * Opens a link.
         * @param uri The document URI.
         * @param newc Whether the link should be activated in a new component.
         */
        public void openLink(String uri, boolean newc) {
            if (newc) {
                application.openLink(uri);
            } else {
                showSVGDocument(uri);
            }
        }

        /**
         * Tells whether the given extension is supported by this
         * user agent.
         */
        public boolean supportExtension(String s) {
            return false;
        }

        public void handleElement(Element elt, Object data){
        }

        /**
         * Returns the security settings for the given script
         * type, script url and document url
         *
         * @param scriptType type of script, as found in the
         *        type attribute of the &lt;script&gt; element.
         * @param scriptURL url for the script, as defined in
         *        the script's xlink:href attribute. If that
         *        attribute was empty, then this parameter should
         *        be null
         * @param docURL url for the document into which the
         *        script was found.
         */
        public ScriptSecurity getScriptSecurity(String scriptType,
                                                ParsedURL scriptURL,
                                                ParsedURL docURL){
            if (!application.canLoadScriptType(scriptType)) {
                return new NoLoadScriptSecurity(scriptType);
            } else {
                switch(application.getAllowedScriptOrigin()) {
                case ResourceOrigin.ANY:
                    return new RelaxedScriptSecurity(scriptType,
                                                     scriptURL,
                                                     docURL);
                case ResourceOrigin.DOCUMENT:
                    return new DefaultScriptSecurity(scriptType,
                                                     scriptURL,
                                                     docURL);
                case ResourceOrigin.EMBEDED:
                    return new EmbededScriptSecurity(scriptType,
                                                     scriptURL,
                                                     docURL);
                default:
                    return new NoLoadScriptSecurity(scriptType);
                }
            }
        }

        /**
         * This method throws a SecurityException if the script
         * of given type, found at url and referenced from docURL
         * should not be loaded.
         *
         * This is a convenience method to call checkLoadScript
         * on the ScriptSecurity strategy returned by
         * getScriptSecurity.
         *
         * @param scriptType type of script, as found in the
         *        type attribute of the &lt;script&gt; element.
         * @param scriptURL url for the script, as defined in
         *        the script's xlink:href attribute. If that
         *        attribute was empty, then this parameter should
         *        be null
         * @param docURL url for the document into which the
         *        script was found.
         */
        public void checkLoadScript(String scriptType,
                                    ParsedURL scriptURL,
                                    ParsedURL docURL) throws SecurityException {
            ScriptSecurity s = getScriptSecurity(scriptType,
                                                     scriptURL,
                                                     docURL);

            if (s != null) {
                s.checkLoadScript();
            }
        }

        /**
         * Returns the security settings for the given
         * resource url and document url
         *
         * @param resourceURL url for the resource, as defined in
         *        the resource's xlink:href attribute. If that
         *        attribute was empty, then this parameter should
         *        be null
         * @param docURL url for the document into which the
         *        resource was found.
         */
        public ExternalResourceSecurity
            getExternalResourceSecurity(ParsedURL resourceURL,
                                        ParsedURL docURL){
            switch(application.getAllowedExternalResourceOrigin()) {
            case ResourceOrigin.ANY:
                return new RelaxedExternalResourceSecurity(resourceURL,
                                                           docURL);
            case ResourceOrigin.DOCUMENT:
                return new DefaultExternalResourceSecurity(resourceURL,
                                                           docURL);
            case ResourceOrigin.EMBEDED:
                return new EmbededExternalResourceSecurity(resourceURL);
            default:
                return new NoLoadExternalResourceSecurity();
            }
        }

        /**
         * This method throws a SecurityException if the resource
         * found at url and referenced from docURL
         * should not be loaded.
         *
         * This is a convenience method to call checkLoadExternalResource
         * on the ExternalResourceSecurity strategy returned by
         * getExternalResourceSecurity.
         *
         * @param resourceURL url for the script, as defined in
         *        the resource's xlink:href attribute. If that
         *        attribute was empty, then this parameter should
         *        be null
         * @param docURL url for the document into which the
         *        resource was found.
         */
        public void
            checkLoadExternalResource(ParsedURL resourceURL,
                                      ParsedURL docURL) throws SecurityException {
            ExternalResourceSecurity s
                =  getExternalResourceSecurity(resourceURL, docURL);

            if (s != null) {
                s.checkLoadExternalResource();
            }
        }
    }

    /**
     * A FileFilter used when exporting the SVG document as an image.
     */
    protected static class ImageFileFilter extends FileFilter {

        /** The extension of the image filename. */
        protected String extension;

        public ImageFileFilter(String extension) {
            this.extension = extension;
        }

        /**
         * Returns true if <tt>f</tt> is a file with the correct extension,
         * false otherwise.
         */
        public boolean accept(File f) {
            boolean accept = false;
            String fileName = null;
            if (f != null) {
                if (f.isDirectory()) {
                    accept = true;
                } else {
                    fileName = f.getPath().toLowerCase();
                    if (fileName.endsWith(extension)) {
                        accept = true;
                    }
                }
            }
            return accept;
        }

        /**
         * Returns the file description
         */
        public String getDescription() {
            return extension;
        }
    }
}
