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
package org.apache.flex.forks.batik.swing;

import java.awt.Dimension;
import java.awt.EventQueue;
// import java.awt.Rectangle;
import java.awt.event.ActionEvent;
import java.awt.event.InputEvent;
import java.awt.event.KeyEvent;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.event.MouseMotionAdapter;
import java.awt.geom.AffineTransform;
import java.beans.PropertyChangeListener;
import java.beans.PropertyChangeSupport;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.WeakHashMap;

import javax.swing.AbstractAction;
import javax.swing.ActionMap;
import javax.swing.InputMap;
import javax.swing.JComponent;
import javax.swing.JDialog;
import javax.swing.JOptionPane;
import javax.swing.KeyStroke;
import javax.swing.ToolTipManager;

import org.apache.flex.forks.batik.bridge.UserAgent;
import org.apache.flex.forks.batik.css.engine.CSSEngine;
import org.apache.flex.forks.batik.dom.events.NodeEventTarget;
import org.apache.flex.forks.batik.swing.gvt.AbstractImageZoomInteractor;
import org.apache.flex.forks.batik.swing.gvt.AbstractPanInteractor;
import org.apache.flex.forks.batik.swing.gvt.AbstractResetTransformInteractor;
import org.apache.flex.forks.batik.swing.gvt.AbstractRotateInteractor;
import org.apache.flex.forks.batik.swing.gvt.AbstractZoomInteractor;
import org.apache.flex.forks.batik.swing.gvt.Interactor;
// import org.apache.flex.forks.batik.swing.gvt.Overlay;
import org.apache.flex.forks.batik.swing.svg.JSVGComponent;
import org.apache.flex.forks.batik.swing.svg.SVGDocumentLoaderEvent;
import org.apache.flex.forks.batik.swing.svg.SVGUserAgent;
import org.apache.flex.forks.batik.util.SVGConstants;
import org.apache.flex.forks.batik.util.XMLConstants;
// import org.apache.flex.forks.batik.util.gui.DOMViewer;
// import org.apache.flex.forks.batik.util.gui.DOMViewerController;
// import org.apache.flex.forks.batik.util.gui.ElementOverlayManager;
import org.apache.flex.forks.batik.util.gui.JErrorPane;

// import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.events.Event;
import org.w3c.dom.events.EventListener;
import org.w3c.dom.events.EventTarget;
import org.w3c.dom.svg.SVGDocument;

/**
 * This class represents a general-purpose swing SVG component. The
 * <tt>JSVGCanvas</tt> does not provided additional functionalities compared to
 * the <tt>JSVGComponent</tt> but simply provides an API conformed to the
 * JavaBean specification. The only major change between the
 * <tt>JSVGComponent</tt> and this component is that interactors and text
 * selection are activated by default.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: JSVGCanvas.java 594379 2007-11-13 01:08:28Z cam $
 */
public class JSVGCanvas extends JSVGComponent {

    /**
     * The key for the Action to scroll right.
     */
    public static final String SCROLL_RIGHT_ACTION = "ScrollRight";

    /**
     * The key for the Action to scroll left.
     */
    public static final String SCROLL_LEFT_ACTION = "ScrollLeft";

    /**
     * The key for the Action to scroll up.
     */
    public static final String SCROLL_UP_ACTION = "ScrollUp";

    /**
     * The key for the Action to scroll down.
     */
    public static final String SCROLL_DOWN_ACTION = "ScrollDown";

    /**
     * The key for the Action to quickly scroll right.
     */
    public static final String FAST_SCROLL_RIGHT_ACTION = "FastScrollRight";

    /**
     * The key for the Action to quickly scroll left.
     */
    public static final String FAST_SCROLL_LEFT_ACTION = "FastScrollLeft";

    /**
     * The key for the Action to quickly scroll up.
     */
    public static final String FAST_SCROLL_UP_ACTION = "FastScrollUp";

    /**
     * The key for the Action to quickly scroll down.
     */
    public static final String FAST_SCROLL_DOWN_ACTION = "FastScrollDown";

    /**
     * The key for the Action to zoom in.
     */
    public static final String ZOOM_IN_ACTION = "ZoomIn";

    /**
     * The key for the Action to zoom out.
     */
    public static final String ZOOM_OUT_ACTION = "ZoomOut";

    /**
     * The key for the Action to reset the transform.
     */
    public static final String RESET_TRANSFORM_ACTION = "ResetTransform";

    /**
     * This flag bit indicates whether or not the zoom interactor is
     * enabled. True means the zoom interactor is functional.
     */
    private boolean isZoomInteractorEnabled = true;

    /**
     * This flag bit indicates whether or not the image zoom interactor is
     * enabled. True means the image zoom interactor is functional.
     */
    private boolean isImageZoomInteractorEnabled = true;

    /**
     * This flag bit indicates whether or not the pan interactor is
     * enabled. True means the pan interactor is functional.
     */
    private boolean isPanInteractorEnabled = true;

    /**
     * This flag bit indicates whether or not the rotate interactor is
     * enabled. True means the rotate interactor is functional.
     */
    private boolean isRotateInteractorEnabled = true;

    /**
     * This flag bit indicates whether or not the reset transform interactor is
     * enabled. True means the reset transform interactor is functional.
     */
    private boolean isResetTransformInteractorEnabled = true;

    /**
     * The <tt>PropertyChangeSupport</tt> used to fire
     * <tt>PropertyChangeEvent</tt>.
     */
    protected PropertyChangeSupport pcs = new PropertyChangeSupport(this);

    /**
     * The URI of the current document being displayed.
     */
    protected String uri;

    /**
     * Keeps track of the last known mouse position over the canvas.
     * This is used for displaying tooltips at the right location.
     */
    protected LocationListener locationListener = new LocationListener();

    /**
     * Mapping of elements to listeners so they can be removed,
     * if the tooltip is removed.
     */
    protected Map toolTipMap = null;
    protected EventListener toolTipListener = new ToolTipModifier();
    protected EventTarget   lastTarget = null;
    protected Map toolTipDocs = null;
    /**
     * This is used as the value in the toolTipDocs WeakHashMap.
     * This way we can tell if a document has already been added.
     */
    protected static final Object MAP_TOKEN = new Object();
    /**
     * The time of the last tool tip event.
     */
    protected long lastToolTipEventTimeStamp;

    /**
     * The target for which the last tool tip event was fired.
     */
    protected EventTarget lastToolTipEventTarget;



    /**
     * Creates a new JSVGCanvas.
     */
    public JSVGCanvas() {
        this(null, true, true);
        addMouseMotionListener(locationListener);
    }

    /**
     * Creates a new JSVGCanvas.
     *
     * @param ua a SVGUserAgent instance or null.
     * @param eventsEnabled Whether the GVT tree should be reactive to mouse
     *                      and key events.
     * @param selectableText Whether the text should be selectable.
     */
    public JSVGCanvas(SVGUserAgent ua,
                      boolean eventsEnabled,
                      boolean selectableText) {

        super(ua, eventsEnabled, selectableText);

        setPreferredSize(new Dimension(200, 200));
        setMinimumSize(new Dimension(100, 100));

        List intl = getInteractors();
        intl.add(zoomInteractor);
        intl.add(imageZoomInteractor);
        intl.add(panInteractor);
        intl.add(rotateInteractor);
        intl.add(resetTransformInteractor);

        installActions();

        if (eventsEnabled) {
            addMouseListener(new MouseAdapter() {
                public void mousePressed(MouseEvent evt) {
                    requestFocus();
                }
            });

            installKeyboardActions();
        }
        addMouseMotionListener(locationListener);
    }

    /**
     * Builds the ActionMap of this canvas with a set of predefined
     * <tt>Action</tt>s.
     */
    protected void installActions() {
        ActionMap actionMap = getActionMap();

        actionMap.put(SCROLL_RIGHT_ACTION, new ScrollRightAction(10));
        actionMap.put(SCROLL_LEFT_ACTION, new ScrollLeftAction(10));
        actionMap.put(SCROLL_UP_ACTION, new ScrollUpAction(10));
        actionMap.put(SCROLL_DOWN_ACTION, new ScrollDownAction(10));

        actionMap.put(FAST_SCROLL_RIGHT_ACTION, new ScrollRightAction(30));
        actionMap.put(FAST_SCROLL_LEFT_ACTION, new ScrollLeftAction(30));
        actionMap.put(FAST_SCROLL_UP_ACTION, new ScrollUpAction(30));
        actionMap.put(FAST_SCROLL_DOWN_ACTION, new ScrollDownAction(30));

        actionMap.put(ZOOM_IN_ACTION, new ZoomInAction());
        actionMap.put(ZOOM_OUT_ACTION, new ZoomOutAction());

        actionMap.put(RESET_TRANSFORM_ACTION, new ResetTransformAction());
    }

    public void setDisableInteractions(boolean b) {
        super.setDisableInteractions(b);
        ActionMap actionMap = getActionMap();

        actionMap.get(SCROLL_RIGHT_ACTION)     .setEnabled(!b);
        actionMap.get(SCROLL_LEFT_ACTION)      .setEnabled(!b);
        actionMap.get(SCROLL_UP_ACTION)        .setEnabled(!b);
        actionMap.get(SCROLL_DOWN_ACTION)      .setEnabled(!b);

        actionMap.get(FAST_SCROLL_RIGHT_ACTION).setEnabled(!b);
        actionMap.get(FAST_SCROLL_LEFT_ACTION) .setEnabled(!b);
        actionMap.get(FAST_SCROLL_UP_ACTION)   .setEnabled(!b);
        actionMap.get(FAST_SCROLL_DOWN_ACTION) .setEnabled(!b);

        actionMap.get(ZOOM_IN_ACTION)          .setEnabled(!b);
        actionMap.get(ZOOM_OUT_ACTION)         .setEnabled(!b);
        actionMap.get(RESET_TRANSFORM_ACTION)  .setEnabled(!b);
    }


        /**
     * Builds the InputMap of this canvas with a set of predefined
     * <tt>Action</tt>s.
     */
    protected void installKeyboardActions() {

        InputMap inputMap = getInputMap(JComponent.WHEN_FOCUSED);
        KeyStroke key;

        key = KeyStroke.getKeyStroke(KeyEvent.VK_RIGHT, 0);
        inputMap.put(key, SCROLL_RIGHT_ACTION);

        key = KeyStroke.getKeyStroke(KeyEvent.VK_LEFT, 0);
        inputMap.put(key, SCROLL_LEFT_ACTION);

        key = KeyStroke.getKeyStroke(KeyEvent.VK_UP, 0);
        inputMap.put(key, SCROLL_UP_ACTION);

        key = KeyStroke.getKeyStroke(KeyEvent.VK_DOWN, 0);
        inputMap.put(key, SCROLL_DOWN_ACTION);

        key = KeyStroke.getKeyStroke(KeyEvent.VK_RIGHT, KeyEvent.SHIFT_MASK);
        inputMap.put(key, FAST_SCROLL_RIGHT_ACTION);

        key = KeyStroke.getKeyStroke(KeyEvent.VK_LEFT, KeyEvent.SHIFT_MASK);
        inputMap.put(key, FAST_SCROLL_LEFT_ACTION);

        key = KeyStroke.getKeyStroke(KeyEvent.VK_UP, KeyEvent.SHIFT_MASK);
        inputMap.put(key, FAST_SCROLL_UP_ACTION);

        key = KeyStroke.getKeyStroke(KeyEvent.VK_DOWN, KeyEvent.SHIFT_MASK);
        inputMap.put(key, FAST_SCROLL_DOWN_ACTION);

        key = KeyStroke.getKeyStroke(KeyEvent.VK_I, KeyEvent.CTRL_MASK);
        inputMap.put(key, ZOOM_IN_ACTION);

        key = KeyStroke.getKeyStroke(KeyEvent.VK_O, KeyEvent.CTRL_MASK);
        inputMap.put(key, ZOOM_OUT_ACTION);

        key = KeyStroke.getKeyStroke(KeyEvent.VK_T, KeyEvent.CTRL_MASK);
        inputMap.put(key, RESET_TRANSFORM_ACTION);
    }

    /**
     * Adds the specified <tt>PropertyChangeListener</tt>.
     *
     * @param pcl the property change listener to add
     */
    public void addPropertyChangeListener(PropertyChangeListener pcl) {
        pcs.addPropertyChangeListener(pcl);
    }

    /**
     * Removes the specified <tt>PropertyChangeListener</tt>.
     *
     * @param pcl the property change listener to remove
     */
    public void removePropertyChangeListener(PropertyChangeListener pcl) {
        pcs.removePropertyChangeListener(pcl);
    }

    /**
     * Adds the specified <tt>PropertyChangeListener</tt> for the specified
     * property.
     *
     * @param propertyName the name of the property to listen on
     * @param pcl the property change listener to add
     */
    public void addPropertyChangeListener(String propertyName,
                                          PropertyChangeListener pcl) {
        pcs.addPropertyChangeListener(propertyName, pcl);
    }

    /**
     * Removes the specified <tt>PropertyChangeListener</tt> for the specified
     * property.
     *
     * @param propertyName the name of the property that was listened on
     * @param pcl the property change listener to remove
     */
    public void removePropertyChangeListener(String propertyName,
                                             PropertyChangeListener pcl) {
        pcs.removePropertyChangeListener(propertyName, pcl);
    }

    /**
     * Determines whether the zoom interactor is enabled or not.
     */
    public void setEnableZoomInteractor(boolean b) {
        if (isZoomInteractorEnabled != b) {
            boolean oldValue = isZoomInteractorEnabled;
            isZoomInteractorEnabled = b;
            if (isZoomInteractorEnabled) {
                getInteractors().add(zoomInteractor);
            } else {
                getInteractors().remove(zoomInteractor);
            }
            pcs.firePropertyChange("enableZoomInteractor", oldValue, b);
        }
    }

    /**
     * Returns true if the zoom interactor is enabled, false otherwise.
     */
    public boolean getEnableZoomInteractor() {
        return isZoomInteractorEnabled;
    }

    /**
     * Determines whether the image zoom interactor is enabled or not.
     */
    public void setEnableImageZoomInteractor(boolean b) {
        if (isImageZoomInteractorEnabled != b) {
            boolean oldValue = isImageZoomInteractorEnabled;
            isImageZoomInteractorEnabled = b;
            if (isImageZoomInteractorEnabled) {
                getInteractors().add(imageZoomInteractor);
            } else {
                getInteractors().remove(imageZoomInteractor);
            }
            pcs.firePropertyChange("enableImageZoomInteractor", oldValue, b);
        }
    }

    /**
     * Returns true if the image zoom interactor is enabled, false otherwise.
     */
    public boolean getEnableImageZoomInteractor() {
        return isImageZoomInteractorEnabled;
    }

    /**
     * Determines whether the pan interactor is enabled or not.
     */
    public void setEnablePanInteractor(boolean b) {
        if (isPanInteractorEnabled != b) {
            boolean oldValue = isPanInteractorEnabled;
            isPanInteractorEnabled = b;
            if (isPanInteractorEnabled) {
                getInteractors().add(panInteractor);
            } else {
                getInteractors().remove(panInteractor);
            }
            pcs.firePropertyChange("enablePanInteractor", oldValue, b);
        }
    }

    /**
     * Returns true if the pan interactor is enabled, false otherwise.
     */
    public boolean getEnablePanInteractor() {
        return isPanInteractorEnabled;
    }

    /**
     * Determines whether the rotate interactor is enabled or not.
     */
    public void setEnableRotateInteractor(boolean b) {
        if (isRotateInteractorEnabled != b) {
            boolean oldValue = isRotateInteractorEnabled;
            isRotateInteractorEnabled = b;
            if (isRotateInteractorEnabled) {
                getInteractors().add(rotateInteractor);
            } else {
                getInteractors().remove(rotateInteractor);
            }
            pcs.firePropertyChange("enableRotateInteractor", oldValue, b);
        }
    }

    /**
     * Returns true if the rotate interactor is enabled, false otherwise.
     */
    public boolean getEnableRotateInteractor() {
        return isRotateInteractorEnabled;
    }

    /**
     * Determines whether the reset transform interactor is enabled or not.
     */
    public void setEnableResetTransformInteractor(boolean b) {
        if (isResetTransformInteractorEnabled != b) {
            boolean oldValue = isResetTransformInteractorEnabled;
            isResetTransformInteractorEnabled = b;
            if (isResetTransformInteractorEnabled) {
                getInteractors().add(resetTransformInteractor);
            } else {
                getInteractors().remove(resetTransformInteractor);
            }
            pcs.firePropertyChange("enableResetTransformInteractor",
                                   oldValue,
                                   b);
        }
    }

    /**
     * Returns true if the reset transform interactor is enabled, false
     * otherwise.
     */
    public boolean getEnableResetTransformInteractor() {
        return isResetTransformInteractorEnabled;
    }

    /**
     * Returns the URI of the current document.
     */
    public String getURI() {
        return uri;
    }

    /**
     * Sets the URI to the specified uri. If the input 'newURI'
     * string is null, then the canvas will display an empty
     * document.
     *
     * @param newURI the new uri of the document to display
     */
    public void setURI(String newURI) {
        String oldValue = uri;
        this.uri = newURI;
        if (uri != null) {
            loadSVGDocument(uri);
        } else {
            setSVGDocument(null);
        }

        pcs.firePropertyChange("URI", oldValue, uri);
    }

    /**
     * Creates a UserAgent.
     */
    protected UserAgent createUserAgent() {
        return new CanvasUserAgent();
    }

    /**
     * Creates an instance of Listener.
     */
    protected Listener createListener() {
        return new CanvasSVGListener();
    }

    /**
     * To hide the listener methods. This class just reset the tooltip.
     */
    protected class CanvasSVGListener extends ExtendedSVGListener {

        /**
         * Called when the loading of a document was started.
         */
        public void documentLoadingStarted(SVGDocumentLoaderEvent e) {
            super.documentLoadingStarted(e);
            JSVGCanvas.this.setToolTipText(null);
        }

    }

    protected void installSVGDocument(SVGDocument doc) {
        if (toolTipDocs != null) {
            Iterator i = toolTipDocs.keySet().iterator();
            while (i.hasNext()) {
                SVGDocument ttdoc;
                ttdoc = (SVGDocument)i.next();
                if (ttdoc == null) continue;

                NodeEventTarget root;
                root = (NodeEventTarget)ttdoc.getRootElement();
                if (root == null) continue;
                root.removeEventListenerNS
                    (XMLConstants.XML_EVENTS_NAMESPACE_URI,
                     SVGConstants.SVG_EVENT_MOUSEOVER,
                     toolTipListener, false);
                root.removeEventListenerNS
                    (XMLConstants.XML_EVENTS_NAMESPACE_URI,
                     SVGConstants.SVG_EVENT_MOUSEOUT,
                     toolTipListener, false);
            }
            toolTipDocs = null;
        }
        lastTarget = null;

        if (toolTipMap != null) {
            toolTipMap.clear();
        }

        super.installSVGDocument(doc);
    }

//     // DOMViewerController
// 
//     /**
//      * DOMViewerController implementation.
//      */
//     protected class CanvasDOMViewerController implements DOMViewerController {
// 
//         public boolean canEdit() {
//             return getUpdateManager() != null;
//         }
// 
//         public ElementOverlayManager createSelectionManager() {
//             if (canEdit()) {
//                 return new ElementOverlayManager(JSVGCanvas.this);
//             }
//             return null;
//         }
// 
//         public Document getDocument() {
//             return svgDocument;
//         }
// 
//         public void performUpdate(Runnable r) {
//             if (canEdit()) {
//                 getUpdateManager().getUpdateRunnableQueue().invokeLater(r);
//             } else {
//                 r.run();
//             }
//         }
// 
//         public void removeSelectionOverlay(Overlay selectionOverlay) {
//             getOverlays().remove(selectionOverlay);
//         }
// 
//         public void selectNode(Node node) {
//             DOMViewer domViewer = new DOMViewer(this);
//             Rectangle fr = getBounds();
//             Dimension td = domViewer.getSize();
//             domViewer.setLocation(fr.x + (fr.width - td.width) / 2,
//                                   fr.y + (fr.height - td.height) / 2);
//             domViewer.setVisible(true);
//             domViewer.selectNode(node);
//         }
//     }

    // ----------------------------------------------------------------------
    // Actions
    // ----------------------------------------------------------------------

    /**
     * A swing action to reset the rendering transform of the canvas.
     */
    public class ResetTransformAction extends AbstractAction {
        public void actionPerformed(ActionEvent evt) {
            fragmentIdentifier = null;
            resetRenderingTransform();
        }
    }

    /**
     * A swing action to append an affine transform to the current
     * rendering transform.  Before the rendering transform is
     * applied the method translates the center of the display to
     * 0,0 so scale and rotate occur around the middle of
     * the display.
     */
    public class AffineAction extends AbstractAction {
        AffineTransform at;
        public AffineAction(AffineTransform at) {
            this.at = at;
        }

        public void actionPerformed(ActionEvent evt) {
            if (gvtRoot == null) {
                return;
            }
            AffineTransform rat = getRenderingTransform();
            if (at != null) {
                Dimension dim = getSize();
                int x = dim.width / 2;
                int y = dim.height / 2;
                AffineTransform t = AffineTransform.getTranslateInstance(x, y);
                t.concatenate(at);
                t.translate(-x, -y);
                t.concatenate(rat);
                setRenderingTransform(t);
            }
        }
    }

    /**
     * A swing action to apply a zoom factor to the canvas.
     * This can be used to zoom in (scale > 1) and out (scale <1).
     */
    public class ZoomAction extends AffineAction {
        public ZoomAction(double scale) {
            super(AffineTransform.getScaleInstance(scale, scale));
        }
        public ZoomAction(double scaleX, double scaleY) {
            super(AffineTransform.getScaleInstance(scaleX, scaleY));
        }
    }

    /**
     * A swing action to zoom in the canvas.
     */
    public class ZoomInAction extends ZoomAction {
        ZoomInAction() { super(2); }
    }

    /**
     * A swing action to zoom out the canvas.
     */
    public class ZoomOutAction extends ZoomAction {
        ZoomOutAction() { super(.5); }
    }

    /**
     * A swing action to Rotate the canvas.
     */
    public class RotateAction extends AffineAction {
        public RotateAction(double theta) {
            super(AffineTransform.getRotateInstance(theta));
        }
    }

    /**
     * A swing action to Pan/scroll the canvas.
     */
    public class ScrollAction extends AffineAction {
        public ScrollAction(double tx, double ty) {
            super(AffineTransform.getTranslateInstance(tx, ty));
        }
    }

    /**
     * A swing action to scroll the canvas to the right,
     * by a fixed amount
     */
    public class ScrollRightAction extends ScrollAction {
        public ScrollRightAction(int inc) {
            super(-inc, 0);
        }
    }

    /**
     * A swing action to scroll the canvas to the left,
     * by a fixed amount
     */
    public class ScrollLeftAction extends ScrollAction {
        public ScrollLeftAction(int inc) {
            super(inc, 0);
        }
    }

    /**
     * A swing action to scroll the canvas up,
     * by a fixed amount
     */
    public class ScrollUpAction extends ScrollAction {
        public ScrollUpAction(int inc) {
            super(0, inc);
        }
    }

    /**
     * A swing action to scroll the canvas down,
     * by a fixed amount
     */
    public class ScrollDownAction extends ScrollAction {
        public ScrollDownAction(int inc) {
            super(0, -inc);
        }
    }

    // ----------------------------------------------------------------------
    // Interactors
    // ----------------------------------------------------------------------

    /**
     * An interactor to perform a zoom.
     * <p>Binding: BUTTON1 + CTRL Key</p>
     */
    protected Interactor zoomInteractor = new AbstractZoomInteractor() {
        public boolean startInteraction(InputEvent ie) {
            int mods = ie.getModifiers();
            return
                ie.getID() == MouseEvent.MOUSE_PRESSED &&
                (mods & InputEvent.BUTTON1_MASK) != 0 &&
                (mods & InputEvent.CTRL_MASK) != 0;
        }
    };

    /**
     * An interactor to perform a realtime zoom.
     * <p>Binding: BUTTON3 + SHIFT Key</p>
     */
    protected Interactor imageZoomInteractor
        = new AbstractImageZoomInteractor() {
        public boolean startInteraction(InputEvent ie) {
            int mods = ie.getModifiers();
            return
                ie.getID() == MouseEvent.MOUSE_PRESSED &&
                (mods & InputEvent.BUTTON3_MASK) != 0 &&
                (mods & InputEvent.SHIFT_MASK) != 0;
        }
    };

    /**
     * An interactor to perform a translation.
     * <p>Binding: BUTTON1 + SHIFT Key</p>
     */
    protected Interactor panInteractor = new AbstractPanInteractor() {
        public boolean startInteraction(InputEvent ie) {
            int mods = ie.getModifiers();
            return
                ie.getID() == MouseEvent.MOUSE_PRESSED &&
                (mods & InputEvent.BUTTON1_MASK) != 0 &&
                (mods & InputEvent.SHIFT_MASK) != 0;
        }
    };

    /**
     * An interactor to perform a rotation.
     * <p>Binding: BUTTON3 + CTRL Key</p>
     */
    protected Interactor rotateInteractor = new AbstractRotateInteractor() {
        public boolean startInteraction(InputEvent ie) {
            int mods = ie.getModifiers();
            return
                ie.getID() == MouseEvent.MOUSE_PRESSED &&
                (mods & InputEvent.BUTTON3_MASK) != 0 &&
                (mods & InputEvent.CTRL_MASK) != 0;
        }
    };

    /**
     * An interactor to reset the rendering transform.
     * <p>Binding: CTRL+SHIFT+BUTTON3</p>
     */
    protected Interactor resetTransformInteractor =
        new AbstractResetTransformInteractor() {
        public boolean startInteraction(InputEvent ie) {
            int mods = ie.getModifiers();
            return
                ie.getID() == MouseEvent.MOUSE_CLICKED &&
                (mods & InputEvent.BUTTON3_MASK) != 0 &&
                (mods & InputEvent.SHIFT_MASK) != 0 &&
                (mods & InputEvent.CTRL_MASK) != 0;
        }
    };

    // ----------------------------------------------------------------------
    // User agent implementation
    // ----------------------------------------------------------------------

    /**
     * The <tt>CanvasUserAgent</tt> only adds tooltips to the behavior of the
     * default <tt>BridgeUserAgent</tt>. A tooltip will be displayed
     * wheneven the mouse lingers over an element which has a &lt;title&gt; or a
     * &lt;desc&gt; child element.
     */
    protected class CanvasUserAgent extends BridgeUserAgent

        implements XMLConstants {

        final String TOOLTIP_TITLE_ONLY
            = "JSVGCanvas.CanvasUserAgent.ToolTip.titleOnly";
        final String TOOLTIP_DESC_ONLY
            = "JSVGCanvas.CanvasUserAgent.ToolTip.descOnly";
        final String TOOLTIP_TITLE_AND_TEXT
            = "JSVGCanvas.CanvasUserAgent.ToolTip.titleAndDesc";

        /**
         * The handleElement method builds a tool tip from the
         * content of a &lt;title&gt; element, a &lt;desc&gt;
         * element or both. <br/>
         * Because these elements can appear in any order, here
         * is the algorithm used to build the tool tip:<br />
         * <ul>
         * <li>If a &lt;title&gt; is passed to <tt>handleElement</tt>
         *     the method checks if there is a &gt;desc&gt; peer. If
         *     there is one, nothing is done (because the desc will do
         *     it). If there in none, the tool tip is set to the value
         *     of the &lt;title&gt; element content.</li>
         * <li>If a &lt;desc&gt; is passed to <tt>handleElement</tt>
         *     the method checks if there is a &lt;title&gt; peer. If there
         *     is one, the content of that peer is pre-pended to the
         *     content of the &lt;desc&gt; element.</li>
         * </ul>
         */
        public void handleElement(Element elt, Object data){
            super.handleElement(elt, data);

            // Don't handle tool tips unless we are interactive.
            if (!isInteractive()) return;

            if (!SVGConstants.SVG_NAMESPACE_URI.equals(elt.getNamespaceURI()))
                return;

            // Don't handle tool tips for the root SVG element.
            if (elt.getParentNode() ==
                elt.getOwnerDocument().getDocumentElement()) {
                return;
            }

            Element parent;
            // When node is removed data is old parent node
            // since we can't get it otherwise.
            if (data instanceof Element) parent = (Element)data;
            else                         parent = (Element)elt.getParentNode();

            Element descPeer = null;
            Element titlePeer = null;
            if (elt.getLocalName().equals(SVGConstants.SVG_TITLE_TAG)) {
                if (data == Boolean.TRUE)
                    titlePeer = elt;
                descPeer = getPeerWithTag(parent,
                                           SVGConstants.SVG_NAMESPACE_URI,
                                           SVGConstants.SVG_DESC_TAG);
            } else if (elt.getLocalName().equals(SVGConstants.SVG_DESC_TAG)) {
                if (data == Boolean.TRUE)
                    descPeer = elt;
                titlePeer = getPeerWithTag(parent,
                                           SVGConstants.SVG_NAMESPACE_URI,
                                           SVGConstants.SVG_TITLE_TAG);
            }

            String titleTip = null;
            if (titlePeer != null) {
                titlePeer.normalize();
                if (titlePeer.getFirstChild() != null)
                    titleTip = titlePeer.getFirstChild().getNodeValue();
            }

            String descTip = null;
            if (descPeer != null) {
                descPeer.normalize();
                if (descPeer.getFirstChild() != null)
                    descTip = descPeer.getFirstChild().getNodeValue();
            }

            final String toolTip;
            if ((titleTip != null) && (titleTip.length() != 0)) {
                if ((descTip != null) && (descTip.length() != 0)) {
                    toolTip = Messages.formatMessage
                        (TOOLTIP_TITLE_AND_TEXT,
                         new Object[] { toFormattedHTML(titleTip),
                                        toFormattedHTML(descTip)});
                } else {
                    toolTip = Messages.formatMessage
                        (TOOLTIP_TITLE_ONLY,
                         new Object[]{toFormattedHTML(titleTip)});
                }
            } else {
                if ((descTip != null) && (descTip.length() != 0)) {
                    toolTip = Messages.formatMessage
                        (TOOLTIP_DESC_ONLY,
                         new Object[]{toFormattedHTML(descTip)});
                } else {
                    toolTip = null;
                }
            }

            if (toolTip == null) {
                removeToolTip(parent);
                return;
            }

            if (lastTarget != parent) {
                setToolTip(parent, toolTip);
            } else {
                // Already has focus check if it already has tip text.
                Object o = null;
                if (toolTipMap != null) {
                    o = toolTipMap.get(parent);
                    toolTipMap.put(parent, toolTip);
                }

                if (o != null) {
                    // Update components tooltip text now.
                    EventQueue.invokeLater(new Runnable() {
                            public void run() {
                                setToolTipText(toolTip);
                                MouseEvent e = new MouseEvent
                                    (JSVGCanvas.this,
                                     MouseEvent.MOUSE_MOVED,
                                     System.currentTimeMillis(),
                                     0,
                                     locationListener.getLastX(),
                                     locationListener.getLastY(),
                                     0,
                                     false);
                                ToolTipManager.sharedInstance().mouseMoved(e);
                            }
                        });
                } else {
                    EventQueue.invokeLater(new ToolTipRunnable(toolTip));
                }
            }
        }

        /**
         * Converts line breaks to HTML breaks and encodes special entities.
         * Poor way of replacing '<', '>' and '&' in content.
         */
        public String toFormattedHTML(String str) {
            StringBuffer sb = new StringBuffer(str);
            replace(sb, XML_CHAR_AMP, XML_ENTITY_AMP);  // Must go first!
            replace(sb, XML_CHAR_LT, XML_ENTITY_LT);
            replace(sb, XML_CHAR_GT, XML_ENTITY_GT);
            replace(sb, XML_CHAR_QUOT, XML_ENTITY_QUOT);
            // Dont' quote "'" apostrphe since the display doesn't
            // seem to understand it.
            // replace(sb, XML_CHAR_APOS, XML_ENTITY_APOS);
            replace(sb, '\n', "<br>");
            return sb.toString();
        }

        protected void replace(StringBuffer sb, char c, String r) {
            String v = sb.toString();
            int i = v.length();

            while( (i=v.lastIndexOf(c, i-1)) != -1 ) {
                sb.deleteCharAt(i);
                sb.insert(i, r);
            }
        }

        /**
         * Checks if there is a peer element of a given type.  This returns the
         * first occurence of the given type or null if none is found.
         */
        public Element getPeerWithTag(Element parent,
                                      String nameSpaceURI,
                                      String localName) {

            Element p = parent;
            if (p == null) {
                return null;
            }

            for (Node n=p.getFirstChild(); n!=null; n = n.getNextSibling()) {
                if (!nameSpaceURI.equals(n.getNamespaceURI())){
                    continue;
                }
                if (!localName.equals(n.getLocalName())){
                    continue;
                }
                if (n.getNodeType() == Node.ELEMENT_NODE) {
                    return (Element)n;
                }
            }
            return null;
        }

        /**
         * Returns a boolean defining whether or not there is a peer of
         * <tt>elt</tt> with the given qualified tag.
         */
        public boolean hasPeerWithTag(Element elt,
                                      String nameSpaceURI,
                                      String localName){

            return !(getPeerWithTag(elt, nameSpaceURI, localName) == null);
        }

        /**
         * Sets the tool tip on the input element.
         */
        public void setToolTip(Element elt, String toolTip){
            if (toolTipMap == null) {
                toolTipMap = new WeakHashMap();
            }
            if (toolTipDocs == null) {
                toolTipDocs = new WeakHashMap();
            }
            SVGDocument doc = (SVGDocument)elt.getOwnerDocument();
            if (toolTipDocs.put(doc, MAP_TOKEN) == null) {
                NodeEventTarget root;
                root = (NodeEventTarget)doc.getRootElement();
                // On mouseover, it sets the tooltip to the given value
                root.addEventListenerNS(XMLConstants.XML_EVENTS_NAMESPACE_URI,
                                        SVGConstants.SVG_EVENT_MOUSEOVER,
                                        toolTipListener,
                                        false, null);
                // On mouseout, it removes the tooltip
                root.addEventListenerNS(XMLConstants.XML_EVENTS_NAMESPACE_URI,
                                        SVGConstants.SVG_EVENT_MOUSEOUT,
                                        toolTipListener,
                                        false, null);
            }

            toolTipMap.put(elt, toolTip);

            if (elt == lastTarget)
                EventQueue.invokeLater(new ToolTipRunnable(toolTip));
        }

        public void removeToolTip(Element elt) {
            if (toolTipMap != null)
                toolTipMap.remove(elt);
            if (lastTarget == elt) { // clear ToolTip.
                EventQueue.invokeLater(new ToolTipRunnable(null));
            }
        }

        /**
         * Displays an error message in the User Agent interface.
         */
        public void displayError(String message) {
            if (svgUserAgent != null) {
                super.displayError(message);
            } else {
                JOptionPane pane =
                    new JOptionPane(message, JOptionPane.ERROR_MESSAGE);
                JDialog dialog =
                    pane.createDialog(JSVGCanvas.this, "ERROR");
                dialog.setModal(false);
                dialog.setVisible(true); // Safe to be called from any thread
            }
        }

        /**
         * Displays an error resulting from the specified Exception.
         */
        public void displayError(Exception ex) {
            if (svgUserAgent != null) {
                super.displayError(ex);
            } else {
                JErrorPane pane =
                    new JErrorPane(ex, JOptionPane.ERROR_MESSAGE);
                JDialog dialog = pane.createDialog(JSVGCanvas.this, "ERROR");
                dialog.setModal(false);
                dialog.setVisible(true); // Safe to be called from any thread
            }
        }
    }

    // ----------------------------------------------------------------------
    // Tooltip
    // ----------------------------------------------------------------------

    /**
     * Sets the time and element of the last tool tip event handled.
     */
    public void setLastToolTipEvent(long t, EventTarget et) {
        lastToolTipEventTimeStamp = t;
        lastToolTipEventTarget = et;
    }

    /**
     * Checks if the specified event time and element are the same
     * as the last tool tip event.
     */
    public boolean matchLastToolTipEvent(long t, EventTarget et) {
        return lastToolTipEventTimeStamp == t
            && lastToolTipEventTarget == et;
    }

    /**
     * Helper class. Simply keeps track of the last known mouse
     * position over the canvas.
     */
    protected class LocationListener extends MouseMotionAdapter {

        protected int lastX, lastY;

        public LocationListener () {
            lastX = 0; lastY = 0;
        }

        public void mouseMoved(MouseEvent evt) {
            lastX = evt.getX();
            lastY = evt.getY();
        }

        public int getLastX() {
            return lastX;
        }

        public int getLastY() {
            return lastY;
        }
    }

    /**
     * Sets a specific tooltip on the JSVGCanvas when a given event occurs.
     * This listener is used in the handleElement method to set, remove or
     * modify the JSVGCanvas tooltip on mouseover and on mouseout.<br/>
     *
     * Because we are on a single <tt>JComponent</tt> we trigger an artificial
     * <tt>MouseEvent</tt> when the toolTip is set to a non-null value, so as
     * to make sure it will show after the <tt>ToolTipManager</tt>'s default
     * delay.
     */
    protected class ToolTipModifier implements EventListener {
        /**
         * The CanvasUserAgent used to track the last tool tip event.
         */
        protected CanvasUserAgent canvasUserAgent;

        /**
         * Creates a new ToolTipModifier object.
         */
        public ToolTipModifier() {
        }

        public void handleEvent(Event evt){
            // Don't set the tool tip if another ToolTipModifier
            // has already handled this event (as it will have been
            // a higher priority tool tip).
            if (matchLastToolTipEvent(evt.getTimeStamp(), evt.getTarget())) {
                return;
            }
            setLastToolTipEvent(evt.getTimeStamp(), evt.getTarget());
            EventTarget prevLastTarget = lastTarget;
            if (SVGConstants.SVG_EVENT_MOUSEOVER.equals(evt.getType())) {
                lastTarget = evt.getTarget();
            } else if (SVGConstants.SVG_EVENT_MOUSEOUT.equals(evt.getType())) {
                // related target is one it is entering or null.
                org.w3c.dom.events.MouseEvent mouseEvt;
                mouseEvt = ((org.w3c.dom.events.MouseEvent)evt);
                lastTarget = mouseEvt.getRelatedTarget();
            }

            if (toolTipMap != null) {
                Element e = (Element)lastTarget;
                Object o = null;
                while (e != null) {
                    // Search the parents of the current node for ToolTips.
                    o = toolTipMap.get(e);
                    if (o != null) {
                        break;
                    }
                    e = CSSEngine.getParentCSSStylableElement(e);
                }
                final String theToolTip = (String)o;
                if (prevLastTarget != lastTarget)
                    EventQueue.invokeLater(new ToolTipRunnable(theToolTip));
            }
        }
    }

    protected class ToolTipRunnable implements Runnable {
        String theToolTip;
        public ToolTipRunnable(String toolTip) {
            this.theToolTip = toolTip;
        }

        public void run() {
            setToolTipText(theToolTip);

            MouseEvent e;
            if (theToolTip != null) {
                e = new MouseEvent
                    (JSVGCanvas.this,
                     MouseEvent.MOUSE_ENTERED,
                     System.currentTimeMillis(),
                     0,
                     locationListener.getLastX(),
                     locationListener.getLastY(),
                     0,
                     false);
                ToolTipManager.sharedInstance().mouseEntered(e);
                e = new MouseEvent
                    (JSVGCanvas.this,
                     MouseEvent.MOUSE_MOVED,
                     System.currentTimeMillis(),
                     0,
                     locationListener.getLastX(),
                     locationListener.getLastY(),
                     0,
                     false);
                ToolTipManager.sharedInstance().mouseMoved(e);
            } else {
                e = new MouseEvent
                    (JSVGCanvas.this,
                     MouseEvent.MOUSE_MOVED,
                     System.currentTimeMillis(),
                     0,
                     locationListener.getLastX(),
                     locationListener.getLastY(),
                     0,
                     false);
                ToolTipManager.sharedInstance().mouseMoved(e);
            }
        }
    }
}
