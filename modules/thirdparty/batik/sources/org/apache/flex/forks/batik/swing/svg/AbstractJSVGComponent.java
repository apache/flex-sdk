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

import java.awt.Cursor;
import java.awt.Dimension;
import java.awt.EventQueue;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.Shape;
import java.awt.event.ComponentAdapter;
import java.awt.event.ComponentEvent;
import java.awt.event.KeyEvent;
import java.awt.event.MouseEvent;
import java.awt.geom.AffineTransform;
import java.awt.geom.Dimension2D;
import java.awt.geom.NoninvertibleTransformException;
import java.awt.geom.Point2D;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.net.URL;

import javax.swing.JOptionPane;

import org.apache.flex.forks.batik.bridge.BridgeContext;
import org.apache.flex.forks.batik.bridge.BridgeException;
import org.apache.flex.forks.batik.bridge.BridgeExtension;
import org.apache.flex.forks.batik.bridge.DefaultScriptSecurity;
import org.apache.flex.forks.batik.bridge.DocumentLoader;
import org.apache.flex.forks.batik.bridge.ErrorConstants;
import org.apache.flex.forks.batik.bridge.ExternalResourceSecurity;
import org.apache.flex.forks.batik.bridge.RelaxedExternalResourceSecurity;
import org.apache.flex.forks.batik.bridge.ScriptSecurity;
import org.apache.flex.forks.batik.bridge.UpdateManager;
import org.apache.flex.forks.batik.bridge.UpdateManagerEvent;
import org.apache.flex.forks.batik.bridge.UpdateManagerListener;
import org.apache.flex.forks.batik.bridge.UserAgent;
import org.apache.flex.forks.batik.bridge.ViewBox;
import org.apache.flex.forks.batik.bridge.svg12.SVG12BridgeContext;
import org.apache.flex.forks.batik.dom.svg.SVGDOMImplementation;
import org.apache.flex.forks.batik.dom.svg.SVGOMDocument;
import org.apache.flex.forks.batik.dom.util.DOMUtilities;
import org.apache.flex.forks.batik.dom.util.XLinkSupport;
import org.apache.flex.forks.batik.ext.awt.image.spi.ImageTagRegistry;
import org.apache.flex.forks.batik.gvt.CanvasGraphicsNode;
import org.apache.flex.forks.batik.gvt.CompositeGraphicsNode;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.gvt.event.EventDispatcher;
import org.apache.flex.forks.batik.gvt.text.Mark;
import org.apache.flex.forks.batik.gvt.renderer.ImageRenderer;
import org.apache.flex.forks.batik.swing.gvt.GVTTreeRendererEvent;
import org.apache.flex.forks.batik.swing.gvt.JGVTComponent;
import org.apache.flex.forks.batik.swing.gvt.JGVTComponentListener;
import org.apache.flex.forks.batik.util.ParsedURL;
import org.apache.flex.forks.batik.util.RunnableQueue;
import org.apache.flex.forks.batik.util.SVGConstants;
import org.apache.flex.forks.batik.util.SVGFeatureStrings;
import org.apache.flex.forks.batik.util.XMLResourceDescriptor;

import org.w3c.dom.Document;
import org.w3c.dom.DOMImplementation;
import org.w3c.dom.Element;
import org.w3c.dom.svg.SVGAElement;
import org.w3c.dom.svg.SVGDocument;
import org.w3c.dom.svg.SVGSVGElement;

/**
 * This class represents a swing component that can display SVG documents. This
 * component also lets you translate, zoom and rotate the document being
 * displayed. This is the fundamental class for rendering SVG documents in a
 * swing application.
 *
 * This class is made abstract so that concrete versions can be made
 * for different JDK versions.  In particular, this is for MouseWheelEvent
 * support, which only exists in JDKs &gt;= 1.4.
 *
 * <h2>Rendering Process</h2>
 *
 * <p>The rendering process can be broken down into five phases. Not all of
 * those steps are required - depending on the method used to specify the SVG
 * document to display, but basically the steps in the rendering process
 * are:</p>
 *
 * <ol>
 *
 * <li><b>Building a DOM tree</b>
 *
 * <blockquote>If the <tt>{@link #loadSVGDocument(String)}</tt> method is used,
 * the SVG file is parsed and an SVG DOM Tree is built.</blockquote></li>
 *
 * <li><b>Building a GVT tree</b>
 *
 * <blockquote>Once an SVGDocument is created (using the step 1 or if the
 * <tt>{@link #setSVGDocument(SVGDocument)}</tt> method has been used) - a GVT
 * tree is constructed. The GVT tree is the data structure used internally to
 * render an SVG document. see the <tt>{@link org.apache.flex.forks.batik.gvt}
 * package.</tt></blockquote></li>
 *
 * <li><b>Executing the SVGLoad event handlers</b>
 *
 * <blockquote>
 *    If the document is dynamic, the scripts are initialized and the
 *    SVGLoad event is dispatched before the initial rendering.
 * </blockquote></li>
 *
 * <li><b>Rendering the GVT tree</b>
 *
 * <blockquote>Then the GVT tree is rendered. see the <tt>{@link
 * org.apache.flex.forks.batik.gvt.renderer}</tt> package.</blockquote></li>
 *
 * <li><b>Running the document</b>
 *
 * <blockquote>
 *    If the document is dynamic, the update threads are started.
 * </blockquote></li>
 *
 * </ol>
 *
 * <p>Those steps are performed in a separate thread. To be notified to what
 * happens and eventually perform some operations - such as resizing the window
 * to the size of the document or get the SVGDocument built via a URI, five
 * different listeners are provided (one per step):
 * <tt>{@link SVGDocumentLoaderListener}</tt>,
 * <tt>{@link GVTTreeBuilderListener}</tt>,
 * <tt>{@link SVGLoadEventDispatcherListener}</tt>,
 * <tt>{@link org.apache.flex.forks.batik.swing.gvt.GVTTreeRendererListener}</tt>,
 * <tt>{@link org.apache.flex.forks.batik.bridge.UpdateManagerListener}</tt>.</p>
 *
 * <p>Each listener has methods to be notified of the start of a phase,
 *    and methods to be notified of the end of a phase.
 *    A phase cannot start before the preceding has finished.</p>
 *
 * <p>The following example shows how you can get the size of an SVG
 * document. Note that due to how SVG is designed (units, percentages...), the
 * size of an SVG document can be known only once the SVGDocument has been
 * analyzed (ie. the GVT tree has been constructed).</p>
 *
 * <pre>
 * final JSVGComponent svgComp = new JSVGComponent();
 * svgComp.loadSVGDocument("foo.svg");
 * svgComp.addGVTTreeBuilderListener(new GVTTreeBuilderAdapter() {
 *     public void gvtBuildCompleted(GVTTreeBuilderEvent evt) {
 *         Dimension2D size = svgComp.getSVGDocumentSize();
 *         // ...
 *     }
 * });
 * </pre>
 *
 * <p>The second example shows how you can access to the DOM tree when a URI has
 * been used to display an SVG document.
 *
 * <pre>
 * final JSVGComponent svgComp = new JSVGComponent();
 * svgComp.loadSVGDocument("foo.svg");
 * svgComp.addSVGDocumentLoaderListener(new SVGDocumentLoaderAdapter() {
 *     public void documentLoadingCompleted(SVGDocumentLoaderEvent evt) {
 *         SVGDocument svgDoc = svgComp.getSVGDocument();
 *         //...
 *     }
 * });
 * </pre>
 *
 * <p>Conformed to the <a href=
 * "http://java.sun.com/docs/books/tutorial/uiswing/overview/threads.html">
 * single thread rule of swing</a>, the listeners are executed in the swing
 * thread. The sequence of the method calls for a particular listener and
 * the order of the listeners themselves are <em>guaranteed</em>.</p>
 *
 * <h2>User Agent</h2>
 *
 * <p>The <tt>JSVGComponent</tt> can pick up some informations to a user
 * agent. The <tt>{@link SVGUserAgent}</tt> provides a way to control the
 * resolution used to display an SVG document (controling the pixel to
 * millimeter conversion factor), perform an operation in respond to a click on
 * an hyperlink, control the default language to use, or specify a user
 * stylesheet, or how to display errors when an error occured while
 * building/rendering a document (invalid XML file, missing attributes...).</p>
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: AbstractJSVGComponent.java 598530 2007-11-27 06:53:38Z cam $
 */
public class AbstractJSVGComponent extends JGVTComponent {

    /**
     * Means that the component must auto detect whether
     * the current document is static or dynamic.
     */
    public static final int AUTODETECT = 0;

    /**
     * Means that all document must be considered as dynamic.
     *
     * Indicates that all DOM listeners should be registered. This supports
     * 'interactivity' (anchors and cursors), as well as DOM modifications
     * listeners to update the GVT rendering tree.
     */
    public static final int ALWAYS_DYNAMIC = 1;

    /**
     * Means that all document must be considered as static.
     *
     * Indicates that no DOM listeners should be registered.
     * In this case the generated GVT tree should be totally
     * independent of the DOM tree (in practice text holds
     * references to the source text elements for font resolution).
     */
    public static final int ALWAYS_STATIC = 2;

    /**
     * Means that all document must be considered as interactive.
     *
     * Indicates that DOM listeners should be registered to support,
     * 'interactivity' this includes anchors and cursors, but does not
     * include support for DOM modifications.
     */
    public static final int ALWAYS_INTERACTIVE = 3;

    /**
     * String constant for the resource with the text for a script alert
     * dialog. Must have a substitution for one string.
     */
    public static final String SCRIPT_ALERT = "script.alert";

    /**
     * String constant for the resource with the text for a script
     * prompt dialog. Must have a substitution for one string.
     */
    public static final String SCRIPT_PROMPT = "script.prompt";

    /**
     * String constant for the resource with the text for a script
     * confim dialog. Must have a substitution for one string.
     */
    public static final String SCRIPT_CONFIRM = "script.confirm";

    /**
     * String constant for the resource with the text for the title
     * of the info tooltip for brokin link images.
     * No string substitution.
     */
    public static final String BROKEN_LINK_TITLE = "broken.link.title";

    /**
     * The document loader.
     */
    protected SVGDocumentLoader documentLoader;

    /**
     * The next document loader to run.
     */
    protected SVGDocumentLoader nextDocumentLoader;

    /**
     * The concrete bridge document loader.
     */
    protected DocumentLoader loader;

    /**
     * The GVT tree builder.
     */
    protected GVTTreeBuilder gvtTreeBuilder;

    /**
     * The next GVT tree builder to run.
     */
    protected GVTTreeBuilder nextGVTTreeBuilder;

    /**
     * The SVGLoadEventDispatcher.
     */
    protected SVGLoadEventDispatcher svgLoadEventDispatcher;

    /**
     * The update manager.
     */
    protected UpdateManager updateManager;

    /**
     * The next update manager.
     */
    protected UpdateManager nextUpdateManager;

    /**
     * The current SVG document.
     */
    protected SVGDocument svgDocument;

    /**
     * The document loader listeners.
     */
    protected List svgDocumentLoaderListeners = new LinkedList();

    /**
     * The GVT tree builder listeners.
     */
    protected List gvtTreeBuilderListeners = new LinkedList();

    /**
     * The SVG onload dispatcher listeners.
     */
    protected List svgLoadEventDispatcherListeners = new LinkedList();

    /**
     * The link activation listeners.
     */
    protected List linkActivationListeners = new LinkedList();

    /**
     * The update manager listeners.
     */
    protected List updateManagerListeners = new LinkedList();

    /**
     * The user agent.
     */
    protected UserAgent userAgent;

    /**
     * The SVG user agent.
     */
    protected SVGUserAgent svgUserAgent;

    /**
     * The current bridge context.
     */
    protected BridgeContext bridgeContext;

    /**
     * The current document fragment identifier.
     */
    protected String fragmentIdentifier;

    /**
     * Whether the current document has dynamic features.
     */
    protected boolean isDynamicDocument;

    /**
     * Whether the current document has dynamic features.
     */
    protected boolean isInteractiveDocument;

    /**
     * Set to true before component calls setDisableInteractors
     * so it knows that the users isn't the one calling it.
     */
    protected boolean selfCallingDisableInteractions = false;

    /**
     * Set to true if the user ever calls setDisableInteractions
     */
    protected boolean userSetDisableInteractions = false;

    /**
     * The document state.
     */
    protected int documentState;

    protected Dimension prevComponentSize;

    protected Runnable afterStopRunnable = null;

    protected SVGUpdateOverlay updateOverlay; // = new SVGUpdateOverlay(20, 4);

    protected boolean recenterOnResize = true;

    protected AffineTransform viewingTransform = null;

    /**
     * The animation limiting mode.
     */
    protected int animationLimitingMode;

    /**
     * The amount of animation limiting.
     */
    protected float animationLimitingAmount;

    /**
     * Creates a new AbstractJSVGComponent.
     */
    public AbstractJSVGComponent() {
        this(null, false, false);
    }

    /**
     * Creates a new AbstractJSVGComponent.
     * @param ua a SVGUserAgent instance or null.
     * @param eventsEnabled Whether the GVT tree should be reactive
     *        to mouse and key events.
     * @param selectableText Whether the text should be selectable.
     */
    public AbstractJSVGComponent(SVGUserAgent ua, boolean eventsEnabled,
                                 boolean selectableText) {
        super(eventsEnabled, selectableText);

        svgUserAgent = ua;

        userAgent = new BridgeUserAgentWrapper(createUserAgent());

        addSVGDocumentLoaderListener((SVGListener)listener);
        addGVTTreeBuilderListener((SVGListener)listener);
        addSVGLoadEventDispatcherListener((SVGListener)listener);
        if (updateOverlay != null)
            getOverlays().add(updateOverlay);
    }

    public void dispose() {
        setSVGDocument(null);
    }

    public void setDisableInteractions(boolean b) {
        super.setDisableInteractions(b);
        if (!selfCallingDisableInteractions)
            userSetDisableInteractions = true;
    }

    /**
     * Clears the boolean that indicates the 'user'
     * has set disable interactions so that the canvas
     * uses the value from documents.
     */
    public void clearUserSetDisableInteractions() {
        userSetDisableInteractions = false;
        updateZoomAndPanEnable(svgDocument);
    }

    /**
     * Enables/Disables Zoom And Pan based on the zoom and
     * pan attribute of the currently installed document,
     * Unless the user has set the Interactions State.
     */
    public void updateZoomAndPanEnable(Document doc) {
        if (userSetDisableInteractions) return;
        if (doc == null) return;
        try {
            Element root = doc.getDocumentElement();
            String znp = root.getAttributeNS
                (null, SVGConstants.SVG_ZOOM_AND_PAN_ATTRIBUTE);
            boolean enable = SVGConstants.SVG_MAGNIFY_VALUE.equals(znp);
            selfCallingDisableInteractions = true;
            setDisableInteractions(!enable);
        } finally {
            selfCallingDisableInteractions = false;
        }
    }

    /**
     * Indicates if the canvas should recenter the content after
     * the canvas is resized.  If true it will try and keep the
     * point that was at the center at the center after resize.
     * Otherwise the upper left corner will be kept at the same point.
     */
    public boolean getRecenterOnResize() {
        return recenterOnResize;
    }
    /**
     * Returns sate of the recenter on resize flag.
     */
    public void setRecenterOnResize(boolean recenterOnResize) {
        this.recenterOnResize = recenterOnResize;
    }

    /**
     * Tells whether the component use dynamic features to
     * process the current document.
     */
    public boolean isDynamic() {
        return isDynamicDocument;
    }

    /**
     * Tells whether the component use dynamic features to
     * process the current document.
     */
    public boolean isInteractive() {
        return isInteractiveDocument;
    }

    /**
     * Sets the document state. The given value must be one of
     * AUTODETECT, ALWAYS_DYNAMIC or ALWAYS_STATIC.  This only
     * effects the loading of subsequent documents, it has no
     * effect on the currently loaded document.
     */
    public void setDocumentState(int state) {
        documentState = state;
    }

    /**
     * Returns the current update manager.  The update manager becomes
     * available after the first rendering completes.  You can be
     * notifed when the rendering completes by registering a
     * GVTTreeRendererListener with the component and waiting for the
     * <tt>gvtRenderingCompleted</tt> event.
     *
     * An UpdateManager is only created for Dynamic documents.  By
     * default the Canvas attempts to autodetect dynamic documents by
     * looking for script elements and/or event attributes in the
     * document, if it does not find these it assumes the document is
     * static.  Callers of this method will almost certainly want to
     * call setDocumentState(ALWAYS_DYNAMIC) before loading the document
     * (with setURI, setDocument, setSVGDocument etc.) so that an
     * UpdateManager is always created (even for apparently static documents).
     */
    public UpdateManager getUpdateManager() {
        if (svgLoadEventDispatcher != null) {
            return svgLoadEventDispatcher.getUpdateManager();
        }
        if (nextUpdateManager != null) {
            return nextUpdateManager;
        }
        return updateManager;
    }

    /**
     * Resumes the processing of the current document.
     */
    public void resumeProcessing() {
        if (updateManager != null) {
            updateManager.resume();
        }
    }

    /**
     * Suspend the processing of the current document.
     */
    public void suspendProcessing() {
        if (updateManager != null) {
            updateManager.suspend();
        }
    }

    /**
     * Stops the processing of the current document.
     */
    public void stopProcessing() {
        nextDocumentLoader = null;
        nextGVTTreeBuilder = null;

        if (documentLoader != null) {
            documentLoader.halt();
        }
        if (gvtTreeBuilder != null) {
            gvtTreeBuilder.halt();
        }
        if (svgLoadEventDispatcher != null) {
            svgLoadEventDispatcher.halt();
        }
        if (nextUpdateManager != null) {
            nextUpdateManager.interrupt();
            nextUpdateManager = null;
        }
        if (updateManager != null) {
            updateManager.interrupt();
        }
        super.stopProcessing();
    }

    /**
     * Loads a SVG document from the given URL.
     * <em>Note: Because the loading is multi-threaded, the current
     * SVG document is not garanteed to be updated after this method
     * returns. The only way to be notified a document has been loaded
     * is to listen to the <tt>SVGDocumentLoaderEvent</tt>s.</em>
     */
    public void loadSVGDocument(String url) {
        String oldURI = null;
        if (svgDocument != null) {
            oldURI = svgDocument.getURL();
        }
        final ParsedURL newURI = new ParsedURL(oldURI, url);

        stopThenRun(new Runnable() {
                public void run() {
                    String url = newURI.toString();
                    fragmentIdentifier = newURI.getRef();

                    loader = new DocumentLoader(userAgent);
                    nextDocumentLoader = new SVGDocumentLoader(url, loader);
                    nextDocumentLoader.setPriority(Thread.MIN_PRIORITY);

                    Iterator it = svgDocumentLoaderListeners.iterator();
                    while (it.hasNext()) {
                        nextDocumentLoader.addSVGDocumentLoaderListener
                            ((SVGDocumentLoaderListener)it.next());
                    }
                    startDocumentLoader();
                }
            });
    }

    /**
     * Starts a loading thread.
     */
    private void startDocumentLoader() {
        documentLoader = nextDocumentLoader;
        nextDocumentLoader = null;
        documentLoader.start();
    }

    /**
     * Sets the Document to display.  If the document does not use
     * Batik's SVG DOM Implemenation it will be cloned into that
     * implementation.  In this case you should use 'getSVGDocument()'
     * to get the actual DOM that is attached to the rendering interface.
     *
     * Note that the prepartation for rendering and the rendering it's
     * self occur asynchronously so you need to register event handlers
     * if you want to know when the document is truely displayed.
     *
     * Notes for documents that you want to change in Java:
     * From this point on you may only modify the
     * the document in the UpdateManager thread @see #getUpdateManager.
     * In many cases you also need to tell Batik to treat the document
     * as a dynamic document by calling setDocumentState(ALWAYS_DYNAMIC).
     */
    public void setDocument(Document doc) {
        if ((doc != null) &&
            !(doc.getImplementation() instanceof SVGDOMImplementation)) {
            DOMImplementation impl;
            impl = SVGDOMImplementation.getDOMImplementation();
            Document d = DOMUtilities.deepCloneDocument(doc, impl);
            doc = d;
        }
        setSVGDocument((SVGDocument)doc);
    }

    /**
     * Sets the SVGDocument to display.  If the document does not use
     * Batik's SVG DOM Implemenation it will be cloned into that
     * implementation.  In this case you should use 'getSVGDocument()'
     * to get the actual DOM that is attached to the rendering
     * interface.
     *
     * Note that the prepartation for rendering and the rendering it's
     * self occur asynchronously so you need to register event handlers
     * if you want to know when the document is truely displayed.
     *
     * Notes for documents that you want to change in Java.
     * From this point on you may only modify the
     * the document in the UpdateManager thread @see #getUpdateManager.
     * In many cases you also need to tell Batik to treat the document
     * as a dynamic document by calling setDocumentState(ALWAYS_DYNAMIC).
     */
    public void setSVGDocument(SVGDocument doc) {
        if ((doc != null) &&
            !(doc.getImplementation() instanceof SVGDOMImplementation)) {
            DOMImplementation impl;
            impl = SVGDOMImplementation.getDOMImplementation();
            Document d = DOMUtilities.deepCloneDocument(doc, impl);
            doc = (SVGDocument)d;
        }

        final SVGDocument svgdoc = doc;
        stopThenRun(new Runnable() {
                public void run() {
                    installSVGDocument(svgdoc);
                }
            });
    }

    /**
     * This method calls stop processing waits for all
     * threads to die then runs the Runnable in the event
     * queue thread.  It returns immediately.
     */
    protected void stopThenRun(final Runnable r) {
        if (afterStopRunnable != null) {
            // Have it run our new runnable, and not
                // run the 'old' runnable.
            afterStopRunnable = r;
            return;
        }
        afterStopRunnable = r;

        stopProcessing();

        if ((documentLoader         == null) &&
            (gvtTreeBuilder         == null) &&
            (gvtTreeRenderer        == null) &&
            (svgLoadEventDispatcher == null) &&
            (nextUpdateManager      == null) &&
            (updateManager          == null)) {
            Runnable asr = afterStopRunnable;
            afterStopRunnable = null;
            asr.run();
        }
    }

    /**
     * This does the real work of installing the SVG Document after
     * the update manager from the previous document (if any) has been
     * properly 'shut down'.
     */
    protected void installSVGDocument(SVGDocument doc) {
        svgDocument = doc;

        if (bridgeContext != null) {
            bridgeContext.dispose();
            bridgeContext = null;
        }

        releaseRenderingReferences();

        if (doc == null) {
            isDynamicDocument = false;
            isInteractiveDocument = false;
            disableInteractions = true;
            initialTransform = new AffineTransform();
            setRenderingTransform(initialTransform, false);
            Rectangle vRect = getRenderRect();
            repaint(vRect.x,     vRect.y,
                    vRect.width, vRect.height);
            return;
        }

        bridgeContext = createBridgeContext((SVGOMDocument) doc);

        switch (documentState) {
        case ALWAYS_STATIC:
            isDynamicDocument = false;
            isInteractiveDocument = false;
            break;
        case ALWAYS_INTERACTIVE:
            isDynamicDocument = false;
            isInteractiveDocument = true;
            break;
        case ALWAYS_DYNAMIC:
            isDynamicDocument = true;
            isInteractiveDocument = true;
            break;
        case AUTODETECT:
            isDynamicDocument = bridgeContext.isDynamicDocument(doc);
            isInteractiveDocument =
                isDynamicDocument || bridgeContext.isInteractiveDocument(doc);
        }

        if (isInteractiveDocument) {
            if (isDynamicDocument)
                bridgeContext.setDynamicState(BridgeContext.DYNAMIC);
            else
                bridgeContext.setDynamicState(BridgeContext.INTERACTIVE);
        }

        setBridgeContextAnimationLimitingMode();

        updateZoomAndPanEnable(doc);

        nextGVTTreeBuilder = new GVTTreeBuilder(doc, bridgeContext);
        nextGVTTreeBuilder.setPriority(Thread.MIN_PRIORITY);

        Iterator it = gvtTreeBuilderListeners.iterator();
        while (it.hasNext()) {
            nextGVTTreeBuilder.addGVTTreeBuilderListener
                ((GVTTreeBuilderListener)it.next());
        }

        initializeEventHandling();

        if (gvtTreeBuilder == null &&
            documentLoader == null &&
            gvtTreeRenderer == null &&
            svgLoadEventDispatcher == null &&
            updateManager == null) {
            startGVTTreeBuilder();
        }
    }

    /**
     * Starts a tree builder.
     */
    protected void startGVTTreeBuilder() {
        gvtTreeBuilder = nextGVTTreeBuilder;
        nextGVTTreeBuilder = null;
        gvtTreeBuilder.start();
    }

    /**
     * Returns the current SVG document.
     */
    public SVGDocument getSVGDocument() {
        return svgDocument;
    }

    /**
     * Returns the size of the SVG document.
     */
    public Dimension2D getSVGDocumentSize() {
        return bridgeContext.getDocumentSize();
    }

    /**
     * Returns the current's document fragment identifier.
     */
    public String getFragmentIdentifier() {
        return fragmentIdentifier;
    }

    /**
     * Sets the current fragment identifier.
     */
    public void setFragmentIdentifier(String fi) {
        fragmentIdentifier = fi;
        if (computeRenderingTransform())
            scheduleGVTRendering();
    }

    /**
     * Removes all images from the image cache.
     */
    public void flushImageCache() {
        ImageTagRegistry reg = ImageTagRegistry.getRegistry();
        reg.flushCache();
    }

    public void setGraphicsNode(GraphicsNode gn, boolean createDispatcher) {
        Dimension2D dim = bridgeContext.getDocumentSize();
        Dimension   mySz = new Dimension((int)dim.getWidth(),
                                         (int)dim.getHeight());
        AbstractJSVGComponent.this.setMySize(mySz);
        SVGSVGElement elt = svgDocument.getRootElement();
        prevComponentSize = getSize();
        AffineTransform at = calculateViewingTransform
            (fragmentIdentifier, elt);
        CanvasGraphicsNode cgn = getCanvasGraphicsNode(gn);
        cgn.setViewingTransform(at);
        viewingTransform = null;
        initialTransform = new AffineTransform();
        setRenderingTransform(initialTransform, false);
        jsvgComponentListener.updateMatrix(initialTransform);
        addJGVTComponentListener(jsvgComponentListener);
        addComponentListener(jsvgComponentListener);
        super.setGraphicsNode(gn, createDispatcher);
    }

    /**
     * Creates a new bridge context.
     */
    protected BridgeContext createBridgeContext(SVGOMDocument doc) {
        if (loader == null) {
            loader = new DocumentLoader(userAgent);
        }
        BridgeContext result;
        if (doc.isSVG12()) {
            result = new SVG12BridgeContext(userAgent, loader);
        } else {
            result = new BridgeContext(userAgent, loader);
        }
        return result;
    }

    /**
     * Starts a SVGLoadEventDispatcher thread.
     */
    protected void startSVGLoadEventDispatcher(GraphicsNode root) {
        UpdateManager um = new UpdateManager(bridgeContext,
                                             root,
                                             svgDocument);
        svgLoadEventDispatcher =
            new SVGLoadEventDispatcher(root,
                                       svgDocument,
                                       bridgeContext,
                                       um);
        Iterator it = svgLoadEventDispatcherListeners.iterator();
        while (it.hasNext()) {
            svgLoadEventDispatcher.addSVGLoadEventDispatcherListener
                ((SVGLoadEventDispatcherListener)it.next());
        }

        svgLoadEventDispatcher.start();
    }

    /**
     * Creates a new renderer.
     */
    protected ImageRenderer createImageRenderer() {
        if (isDynamicDocument) {
            return rendererFactory.createDynamicImageRenderer();
        } else {
            return rendererFactory.createStaticImageRenderer();
        }
    }

    public CanvasGraphicsNode getCanvasGraphicsNode() {
        return getCanvasGraphicsNode(gvtRoot);

    }

    protected CanvasGraphicsNode getCanvasGraphicsNode(GraphicsNode gn) {
        if (!(gn instanceof CompositeGraphicsNode))
            return null;
        CompositeGraphicsNode cgn = (CompositeGraphicsNode)gn;
        List children = cgn.getChildren();
        if (children.size() == 0)
            return null;
        gn = (GraphicsNode)children.get(0);
        if (!(gn instanceof CanvasGraphicsNode))
            return null;
        return (CanvasGraphicsNode)gn;
    }

    public AffineTransform getViewingTransform() {
        AffineTransform vt;
        synchronized (this) {
            vt = viewingTransform;
            if (vt == null) {
                CanvasGraphicsNode cgn = getCanvasGraphicsNode();
                if (cgn != null)
                    vt = cgn.getViewingTransform();
            }
        }
        return vt;
    }

    /**
     * Returns the transform from viewBox coords to screen coords
     */
    public AffineTransform getViewBoxTransform() {
        AffineTransform at = getRenderingTransform();
        if (at == null) at = new AffineTransform();
        else            at = new AffineTransform(at);
        AffineTransform vt = getViewingTransform();
        if (vt != null) {
            at.concatenate(vt);
        }
        return at;
    }

    /**
     * Computes the transform used for rendering.
     * Returns true if the component needs to be repainted.
     */
    protected boolean computeRenderingTransform() {
        if ((svgDocument == null) || (gvtRoot == null))
            return false;

        boolean ret = updateRenderingTransform();
        initialTransform = new AffineTransform();
        if (!initialTransform.equals(getRenderingTransform())) {
            setRenderingTransform(initialTransform, false);
            ret = true;
        }
        return ret;
    }

    protected AffineTransform calculateViewingTransform
        (String fragIdent, SVGSVGElement svgElt) {
        Dimension d = getSize();
        if (d.width  < 1) d.width  = 1;
        if (d.height < 1) d.height = 1;
        return ViewBox.getViewTransform
            (fragIdent, svgElt, d.width, d.height, bridgeContext);
    }

    /**
     * Updates the value of the transform used for rendering.
     * Return true if a repaint is required, otherwise false.
     */
    protected boolean updateRenderingTransform() {
        if ((svgDocument == null) || (gvtRoot == null))
            return false;

        try {
            SVGSVGElement elt = svgDocument.getRootElement();
            Dimension d = getSize();
            Dimension oldD = prevComponentSize;
            if (oldD == null) oldD = d;
            prevComponentSize = d;
            if (d.width  < 1) d.width  = 1;
            if (d.height < 1) d.height = 1;
            final AffineTransform at = calculateViewingTransform
                (fragmentIdentifier, elt);
            AffineTransform vt = getViewingTransform();
            if (at.equals(vt)) {
                // No new transform
                // Only repaint if size really changed.
                return ((oldD.width != d.width) || (oldD.height != d.height));
            }

            if (!recenterOnResize)
                return true;

            // Here we map the old center of the component down to
            // the user coodinate system with the old viewing
            // transform and then back to the screen with the
            // new viewing transform.  We then adjust the rendering
            // transform so it lands in the same place.
            Point2D pt = new Point2D.Float(oldD.width/2.0f,
                                           oldD.height/2.0f);
            AffineTransform rendAT = getRenderingTransform();
            if (rendAT != null) {
                try {
                    AffineTransform invRendAT = rendAT.createInverse();
                    pt = invRendAT.transform(pt, null);
                } catch (NoninvertibleTransformException e) { }
            }
            if (vt != null) {
                try {
                    AffineTransform invVT = vt.createInverse();
                    pt = invVT.transform(pt, null);
                } catch (NoninvertibleTransformException e) { }
            }
            if (at != null)
                pt = at.transform(pt, null);
            if (rendAT != null)
                pt = rendAT.transform(pt, null);

            // Now figure out how far we need to shift things
            // to get the center point to line up again.
            float dx = (float)((d.width/2.0f) -pt.getX());
            float dy = (float)((d.height/2.0f)-pt.getY());
            // Round the values to nearest integer.
            dx = (int)((dx < 0)?(dx - .5):(dx + .5));
            dy = (int)((dy < 0)?(dy - .5):(dy + .5));
            if ((dx != 0) || (dy != 0)) {
                rendAT.preConcatenate
                    (AffineTransform.getTranslateInstance(dx, dy));
                setRenderingTransform(rendAT, false);
            }
            synchronized (this) {
                viewingTransform = at;
            }
            Runnable r = new Runnable() {
                    AffineTransform myAT = at;
                    CanvasGraphicsNode myCGN = getCanvasGraphicsNode();
                    public void run() {
                        synchronized (AbstractJSVGComponent.this) {
                            myCGN.setViewingTransform(myAT);
                            if (viewingTransform == myAT)
                                viewingTransform = null;
                        }
                    }
                };
            UpdateManager um = getUpdateManager();
            if (um != null) um.getUpdateRunnableQueue().invokeLater(r);
            else             r.run();
        } catch (BridgeException e) {
            userAgent.displayError(e);
        }
        return true;
    }

    /**
     * Renders the GVT tree.
     */
    protected void renderGVTTree() {
        if (!isInteractiveDocument ||
            updateManager == null ||
            !updateManager.isRunning()) {
            super.renderGVTTree();
            return;
        }

        final Rectangle visRect = getRenderRect();
        if ((gvtRoot == null)    ||
            (visRect.width <= 0) ||
            (visRect.height <= 0)) {
            return;
        }

        // Area of interest computation.
        AffineTransform inv = null;
        try {
            inv = renderingTransform.createInverse();
        } catch (NoninvertibleTransformException e) {
        }
        final Shape s;
        if (inv == null) s = visRect;
        else             s = inv.createTransformedShape(visRect);

        class UpdateRenderingRunnable implements Runnable {
            AffineTransform at;
            boolean         doubleBuf;
            boolean         clearPaintTrans;
            Shape           aoi;
            int             width;
            int             height;

            boolean active;

            public UpdateRenderingRunnable(AffineTransform at,
                                           boolean doubleBuf,
                                           boolean clearPaintTrans,
                                           Shape aoi,
                                           int width, int height) {
                updateInfo(at, doubleBuf, clearPaintTrans, aoi, width, height);
                active = true;
            }

            public void updateInfo(AffineTransform at,
                                   boolean doubleBuf,
                                   boolean clearPaintTrans,
                                   Shape aoi,
                                   int width, int height) {
                this.at              = at;
                this.doubleBuf       = doubleBuf;
                this.clearPaintTrans = clearPaintTrans;
                this.aoi             = aoi;
                this.width           = width;
                this.height          = height;
                active = true;
            }

            public void deactivate() {
                active = false;
            }
            public void run() {
                if (!active) return;

                updateManager.updateRendering
                    (at, doubleBuf, clearPaintTrans, aoi, width, height);
            }
        }
        RunnableQueue rq = updateManager.getUpdateRunnableQueue();

        // Events compression.
        synchronized (rq.getIteratorLock()) {
            Iterator it = rq.iterator();
            while (it.hasNext()) {
                Object next = it.next();
                if (next instanceof UpdateRenderingRunnable) {
                    ((UpdateRenderingRunnable)next).deactivate();
                }
            }
        }

        rq.invokeLater(new UpdateRenderingRunnable
                       (renderingTransform,
                        doubleBufferedRendering, true, s,
                        visRect.width, visRect.height));
    }

    /**
     * Handles an exception.
     */
    protected void handleException(Exception e) {
        userAgent.displayError(e);
    }

    /**
     * Adds a SVGDocumentLoaderListener to this component.
     */
    public void addSVGDocumentLoaderListener(SVGDocumentLoaderListener l) {
        svgDocumentLoaderListeners.add(l);
    }

    /**
     * Removes a SVGDocumentLoaderListener from this component.
     */
    public void removeSVGDocumentLoaderListener(SVGDocumentLoaderListener l) {
        svgDocumentLoaderListeners.remove(l);
    }

    /**
     * Adds a GVTTreeBuilderListener to this component.
     */
    public void addGVTTreeBuilderListener(GVTTreeBuilderListener l) {
        gvtTreeBuilderListeners.add(l);
    }

    /**
     * Removes a GVTTreeBuilderListener from this component.
     */
    public void removeGVTTreeBuilderListener(GVTTreeBuilderListener l) {
        gvtTreeBuilderListeners.remove(l);
    }

    /**
     * Adds a SVGLoadEventDispatcherListener to this component.
     */
    public void addSVGLoadEventDispatcherListener
        (SVGLoadEventDispatcherListener l) {
        svgLoadEventDispatcherListeners.add(l);
    }

    /**
     * Removes a SVGLoadEventDispatcherListener from this component.
     */
    public void removeSVGLoadEventDispatcherListener
        (SVGLoadEventDispatcherListener l) {
        svgLoadEventDispatcherListeners.remove(l);
    }

    /**
     * Adds a LinkActivationListener to this component.
     */
    public void addLinkActivationListener(LinkActivationListener l) {
        linkActivationListeners.add(l);
    }

    /**
     * Removes a LinkActivationListener from this component.
     */
    public void removeLinkActivationListener(LinkActivationListener l) {
        linkActivationListeners.remove(l);
    }

    /**
     * Adds a UpdateManagerListener to this component.
     */
    public void addUpdateManagerListener(UpdateManagerListener l) {
        updateManagerListeners.add(l);
    }

    /**
     * Removes a UpdateManagerListener from this component.
     */
    public void removeUpdateManagerListener(UpdateManagerListener l) {
        updateManagerListeners.remove(l);
    }

    /**
     * Shows an alert dialog box.
     */
    public void showAlert(String message) {
        JOptionPane.showMessageDialog
            (this, Messages.formatMessage(SCRIPT_ALERT,
                                          new Object[] { message }));
    }

    /**
     * Shows a prompt dialog box.
     */
    public String showPrompt(String message) {
        return JOptionPane.showInputDialog
            (this, Messages.formatMessage(SCRIPT_PROMPT,
                                          new Object[] { message }));
    }

    /**
     * Shows a prompt dialog box.
     */
    public String showPrompt(String message, String defaultValue) {
        return (String)JOptionPane.showInputDialog
            (this,
             Messages.formatMessage(SCRIPT_PROMPT,
                                    new Object[] { message }),
             null,
             JOptionPane.PLAIN_MESSAGE,
             null, null, defaultValue);
    }

    /**
     * Shows a confirm dialog box.
     */
    public boolean showConfirm(String message) {
        return JOptionPane.showConfirmDialog
            (this, Messages.formatMessage(SCRIPT_CONFIRM,
                                          new Object[] { message }),
             "Confirm", JOptionPane.YES_NO_OPTION) == JOptionPane.YES_OPTION;
    }


    /**
     * This method is called when the component knows the desired
     * size of the window (based on width/height of outermost SVG
     * element).
     * The default implementation simply calls setPreferredSize,
     * and invalidate.
     * However it is often useful to pack the window containing
     * this component.
     */
    public void setMySize(Dimension d) {
        setPreferredSize(d);
        invalidate();
    }

    /**
     * Sets the animation limiting mode to "none".
     */
    public void setAnimationLimitingNone() {
        animationLimitingMode = 0;
        if (bridgeContext != null) {
            setBridgeContextAnimationLimitingMode();
        }
    }

    /**
     * Sets the animation limiting mode to a percentage of CPU.
     * @param pc the maximum percentage of CPU to use (0 &lt; pc ≤ 1)
     */
    public void setAnimationLimitingCPU(float pc) {
        animationLimitingMode = 1;
        animationLimitingAmount = pc;
        if (bridgeContext != null) {
            setBridgeContextAnimationLimitingMode();
        }
    }

    /**
     * Sets the animation limiting mode to a number of frames per second.
     * @param fps the maximum number of frames per second (fps &gt; 0)
     */
    public void setAnimationLimitingFPS(float fps) {
        animationLimitingMode = 2;
        animationLimitingAmount = fps;
        if (bridgeContext != null) {
            setBridgeContextAnimationLimitingMode();
        }
    }

    /**
     * Sets the animation limiting mode on the current bridge context.
     */
    protected void setBridgeContextAnimationLimitingMode() {
        switch (animationLimitingMode) {
            case 0: // unlimited
                bridgeContext.setAnimationLimitingNone();
                break;
            case 1: // %cpu
                bridgeContext.setAnimationLimitingCPU(animationLimitingAmount);
                break;
            case 2: // fps
                bridgeContext.setAnimationLimitingFPS(animationLimitingAmount);
                break;
        }
    }

    /**
     * The JGVTComponentListener.
     */
    protected JSVGComponentListener jsvgComponentListener =
        new JSVGComponentListener();

    protected class JSVGComponentListener extends ComponentAdapter
        implements JGVTComponentListener {
        float prevScale = 0;
        float prevTransX = 0;
        float prevTransY = 0;

        public void componentResized(ComponentEvent ce) {
            if (isDynamicDocument &&
                (updateManager != null) && updateManager.isRunning()) {
                updateManager.getUpdateRunnableQueue().invokeLater
                    (new Runnable() {
                        public void run() {
                            try {
                                updateManager.dispatchSVGResizeEvent();
                            } catch (InterruptedException ie) {
                            }
                        }});
            }
        }

        public void componentTransformChanged(ComponentEvent event) {
            AffineTransform at = getRenderingTransform();

            float currScale  = (float)Math.sqrt(at.getDeterminant());
            float currTransX = (float)at.getTranslateX();
            float currTransY = (float)at.getTranslateY();

            final boolean dispatchZoom    = (currScale != prevScale);
            final boolean dispatchScroll  = ((currTransX != prevTransX) ||
                                             (currTransY != prevTransY));
            if (isDynamicDocument &&
                (updateManager != null) && updateManager.isRunning()) {
                updateManager.getUpdateRunnableQueue().invokeLater
                    (new Runnable() {
                        public void run() {
                            try {
                                if (dispatchZoom)
                                    updateManager.dispatchSVGZoomEvent();
                                if (dispatchScroll)
                                    updateManager.dispatchSVGScrollEvent();
                            } catch (InterruptedException ie) {
                            }
                        }});
            }
            prevScale = currScale;
            prevTransX = currTransX;
            prevTransY = currTransY;
        }

        public void updateMatrix(AffineTransform at) {
            prevScale  = (float)Math.sqrt(at.getDeterminant());
            prevTransX = (float)at.getTranslateX();
            prevTransY = (float)at.getTranslateY();
        }
    }


    /**
     * Creates an instance of Listener.
     */
    protected Listener createListener() {
        return new SVGListener();
    }

    /**
     * To hide the listener methods.
     */
    protected class SVGListener
        extends ExtendedListener
        implements SVGDocumentLoaderListener,
                   GVTTreeBuilderListener,
                   SVGLoadEventDispatcherListener,
                   UpdateManagerListener {

        /**
         * Creates a new SVGListener.
         */
        protected SVGListener() {
        }

        // SVGDocumentLoaderListener /////////////////////////////////////////

        /**
         * Called when the loading of a document was started.
         */
        public void documentLoadingStarted(SVGDocumentLoaderEvent e) {
        }

        /**
         * Called when the loading of a document was completed.
         */
        public void documentLoadingCompleted(SVGDocumentLoaderEvent e) {
            if (nextDocumentLoader != null) {
                startDocumentLoader();
                return;
            }

            documentLoader = null;
            if (afterStopRunnable != null) {
                EventQueue.invokeLater(afterStopRunnable);
                afterStopRunnable = null;
                return;
            }

            setSVGDocument(e.getSVGDocument());
        }

        /**
         * Called when the loading of a document was cancelled.
         */
        public void documentLoadingCancelled(SVGDocumentLoaderEvent e) {
            if (nextDocumentLoader != null) {
                startDocumentLoader();
                return;
            }

            documentLoader = null;
            if (afterStopRunnable != null) {
                EventQueue.invokeLater(afterStopRunnable);
                afterStopRunnable = null;
                return;
            }

            if (nextGVTTreeBuilder != null) {
                startGVTTreeBuilder();
                return;
            }
        }

        /**
         * Called when the loading of a document has failed.
         */
        public void documentLoadingFailed(SVGDocumentLoaderEvent e) {
            if (nextDocumentLoader != null) {
                startDocumentLoader();
                return;
            }

            documentLoader = null;
            userAgent.displayError(((SVGDocumentLoader)e.getSource()).
                                   getException());

            if (afterStopRunnable != null) {
                EventQueue.invokeLater(afterStopRunnable);
                afterStopRunnable = null;
                return;
            }
            if (nextGVTTreeBuilder != null) {
                startGVTTreeBuilder();
                return;
            }
        }

        // GVTTreeBuilderListener ////////////////////////////////////////////

        /**
         * Called when a build started.
         * The data of the event is initialized to the old document.
         */
        public void gvtBuildStarted(GVTTreeBuilderEvent e) {
            removeJGVTComponentListener(jsvgComponentListener);
            removeComponentListener(jsvgComponentListener);
        }

        /**
         * Called when a build was completed.
         */
        public void gvtBuildCompleted(GVTTreeBuilderEvent e) {
            if (nextGVTTreeBuilder != null) {
                startGVTTreeBuilder();
                return;
            }

            loader = null;
            gvtTreeBuilder = null;

            if (afterStopRunnable != null) {
                EventQueue.invokeLater(afterStopRunnable);
                afterStopRunnable = null;
                return;
            }

            if (nextDocumentLoader != null) {
                startDocumentLoader();
                return;
            }

            gvtRoot = null;

            if (isDynamicDocument && AbstractJSVGComponent.this.eventsEnabled) {
                startSVGLoadEventDispatcher(e.getGVTRoot());
            } else {
                if (isInteractiveDocument) {
                    nextUpdateManager = new UpdateManager(bridgeContext,
                                                          e.getGVTRoot(),
                                                          svgDocument);
                }

                AbstractJSVGComponent.this.setGraphicsNode
                    (e.getGVTRoot(), false);
                scheduleGVTRendering();
            }
        }

        /**
         * Called when a build was cancelled.
         */
        public void gvtBuildCancelled(GVTTreeBuilderEvent e) {
            if (nextGVTTreeBuilder != null) {
                startGVTTreeBuilder();
                return;
            }

            loader = null;
            gvtTreeBuilder = null;

            if (afterStopRunnable != null) {
                EventQueue.invokeLater(afterStopRunnable);
                afterStopRunnable = null;
                return;
            }

            if (nextDocumentLoader != null) {
                startDocumentLoader();
                return;
            }
            AbstractJSVGComponent.this.image = null;
            repaint();
        }

        /**
         * Called when a build failed.
         */
        public void gvtBuildFailed(GVTTreeBuilderEvent e) {
            if (nextGVTTreeBuilder != null) {
                startGVTTreeBuilder();
                return;
            }

            loader = null;
            gvtTreeBuilder = null;

            if (afterStopRunnable != null) {
                EventQueue.invokeLater(afterStopRunnable);
                afterStopRunnable = null;
                return;
            }

            if (nextDocumentLoader != null) {
                startDocumentLoader();
                return;
            }

            GraphicsNode gn = e.getGVTRoot();
            if (gn == null) {
                AbstractJSVGComponent.this.image = null;
                repaint();
            } else {
                AbstractJSVGComponent.this.setGraphicsNode(gn, false);
                computeRenderingTransform();
            }
            userAgent.displayError(((GVTTreeBuilder)e.getSource())
                                   .getException());
        }

        // SVGLoadEventDispatcherListener ////////////////////////////////////

        /**
         * Called when a onload event dispatch started.
         */
        public void svgLoadEventDispatchStarted
            (SVGLoadEventDispatcherEvent e) {
        }

        /**
         * Called when a onload event dispatch was completed.
         */
        public void svgLoadEventDispatchCompleted
            (SVGLoadEventDispatcherEvent e) {
            nextUpdateManager = svgLoadEventDispatcher.getUpdateManager();
            svgLoadEventDispatcher = null;

            if (afterStopRunnable != null) {
                nextUpdateManager.interrupt();
                nextUpdateManager = null;

                EventQueue.invokeLater(afterStopRunnable);
                afterStopRunnable = null;
                return;
            }

            if (nextGVTTreeBuilder != null) {
                nextUpdateManager.interrupt();
                nextUpdateManager = null;

                startGVTTreeBuilder();
                return;
            }
            if (nextDocumentLoader != null) {
                nextUpdateManager.interrupt();
                nextUpdateManager = null;

                startDocumentLoader();
                return;
            }

            AbstractJSVGComponent.this.setGraphicsNode
                (e.getGVTRoot(), false);
            scheduleGVTRendering();
        }

        /**
         * Called when a onload event dispatch was cancelled.
         */
        public void svgLoadEventDispatchCancelled
            (SVGLoadEventDispatcherEvent e) {
            nextUpdateManager = svgLoadEventDispatcher.getUpdateManager();
            svgLoadEventDispatcher = null;

            nextUpdateManager.interrupt();
            nextUpdateManager = null;

            if (afterStopRunnable != null) {
                EventQueue.invokeLater(afterStopRunnable);
                afterStopRunnable = null;
                return;
            }

            if (nextGVTTreeBuilder != null) {
                startGVTTreeBuilder();
                return;
            }
            if (nextDocumentLoader != null) {
                startDocumentLoader();
                return;
            }
        }

        /**
         * Called when a onload event dispatch failed.
         */
        public void svgLoadEventDispatchFailed
            (SVGLoadEventDispatcherEvent e) {
            nextUpdateManager = svgLoadEventDispatcher.getUpdateManager();
            svgLoadEventDispatcher = null;

            nextUpdateManager.interrupt();
            nextUpdateManager = null;

            if (afterStopRunnable != null) {
                EventQueue.invokeLater(afterStopRunnable);
                afterStopRunnable = null;
                return;
            }

            if (nextGVTTreeBuilder != null) {
                startGVTTreeBuilder();
                return;
            }
            if (nextDocumentLoader != null) {
                startDocumentLoader();
                return;
            }

            GraphicsNode gn = e.getGVTRoot();
            if (gn == null) {
                AbstractJSVGComponent.this.image = null;
                repaint();
            } else {
                AbstractJSVGComponent.this.setGraphicsNode(gn, false);
                computeRenderingTransform();
            }
            userAgent.displayError(((SVGLoadEventDispatcher)e.getSource())
                                   .getException());
        }

        // GVTTreeRendererListener ///////////////////////////////////////////

        /**
         * Called when a rendering was completed.
         */
        public void gvtRenderingCompleted(GVTTreeRendererEvent e) {
            super.gvtRenderingCompleted(e);

            if (afterStopRunnable != null) {
                if (nextUpdateManager != null) {
                    nextUpdateManager.interrupt();
                    nextUpdateManager = null;
                }
                EventQueue.invokeLater(afterStopRunnable);
                afterStopRunnable = null;
                return;
            }

            if (nextGVTTreeBuilder != null) {
                if (nextUpdateManager != null) {
                    nextUpdateManager.interrupt();
                    nextUpdateManager = null;
                }
                startGVTTreeBuilder();
                return;
            }
            if (nextDocumentLoader != null) {
                if (nextUpdateManager != null) {
                    nextUpdateManager.interrupt();
                    nextUpdateManager = null;
                }
                startDocumentLoader();
                return;
            }

            if (nextUpdateManager != null) {
                updateManager = nextUpdateManager;
                nextUpdateManager = null;
                updateManager.addUpdateManagerListener(this);
                updateManager.manageUpdates(renderer);
            }
        }

        /**
         * Called when a rendering was cancelled.
         */
        public void gvtRenderingCancelled(GVTTreeRendererEvent e) {
            super.gvtRenderingCancelled(e);

            if (afterStopRunnable != null) {
                if (nextUpdateManager != null) {
                    nextUpdateManager.interrupt();
                    nextUpdateManager = null;
                }

                EventQueue.invokeLater(afterStopRunnable);
                afterStopRunnable = null;
                return;
            }

            if (nextGVTTreeBuilder != null) {
                if (nextUpdateManager != null) {
                    nextUpdateManager.interrupt();
                    nextUpdateManager = null;
                }

                startGVTTreeBuilder();
                return;
            }
            if (nextDocumentLoader != null) {
                if (nextUpdateManager != null) {
                    nextUpdateManager.interrupt();
                    nextUpdateManager = null;
                }
                startDocumentLoader();
                return;
            }
        }

        /**
         * Called when a rendering failed.
         */
        public void gvtRenderingFailed(GVTTreeRendererEvent e) {
            super.gvtRenderingFailed(e);

            if (afterStopRunnable != null) {
                if (nextUpdateManager != null) {
                    nextUpdateManager.interrupt();
                    nextUpdateManager = null;
                }

                EventQueue.invokeLater(afterStopRunnable);
                afterStopRunnable = null;
                return;
            }

            if (nextGVTTreeBuilder != null) {
                if (nextUpdateManager != null) {
                    nextUpdateManager.interrupt();
                    nextUpdateManager = null;
                }

                startGVTTreeBuilder();
                return;
            }
            if (nextDocumentLoader != null) {
                if (nextUpdateManager != null) {
                    nextUpdateManager.interrupt();
                    nextUpdateManager = null;
                }

                startDocumentLoader();
                return;
            }
        }

        // UpdateManagerListener //////////////////////////////////////////

        /**
         * Called when the manager was started.
         */
        public void managerStarted(final UpdateManagerEvent e) {
            EventQueue.invokeLater(new Runnable() {
                    public void run() {
                        suspendInteractions = false;

                        Object[] dll = updateManagerListeners.toArray();

                        if (dll.length > 0) {
                            for (int i = 0; i < dll.length; i++) {
                                ((UpdateManagerListener)dll[i]).
                                    managerStarted(e);
                            }
                        }
                    }
                });
        }

        /**
         * Called when the manager was suspended.
         */
        public void managerSuspended(final UpdateManagerEvent e) {
            EventQueue.invokeLater(new Runnable() {
                    public void run() {
                        Object[] dll = updateManagerListeners.toArray();

                        if (dll.length > 0) {
                            for (int i = 0; i < dll.length; i++) {
                                ((UpdateManagerListener)dll[i]).
                                    managerSuspended(e);
                            }
                        }
                    }
                });
        }

        /**
         * Called when the manager was resumed.
         */
        public void managerResumed(final UpdateManagerEvent e) {
            EventQueue.invokeLater(new Runnable() {
                    public void run() {
                        Object[] dll = updateManagerListeners.toArray();

                        if (dll.length > 0) {
                            for (int i = 0; i < dll.length; i++) {
                                ((UpdateManagerListener)dll[i]).
                                    managerResumed(e);
                            }
                        }
                    }
                });
        }

        /**
         * Called when the manager was stopped.
         */
        public void managerStopped(final UpdateManagerEvent e) {
            EventQueue.invokeLater(new Runnable() {
                    public void run() {
                        updateManager = null;


                        Object[] dll = updateManagerListeners.toArray();

                        if (dll.length > 0) {
                            for (int i = 0; i < dll.length; i++) {
                                ((UpdateManagerListener)dll[i]).
                                    managerStopped(e);
                            }
                        }

                        if (afterStopRunnable != null) {
                            EventQueue.invokeLater(afterStopRunnable);
                            afterStopRunnable = null;
                            return;
                        }

                        if (nextGVTTreeBuilder != null) {
                            startGVTTreeBuilder();
                            return;
                        }
                        if (nextDocumentLoader != null) {
                            startDocumentLoader();
                            return;
                        }
                    }
                });
        }

        /**
         * Called when an update started.
         */
        public void updateStarted(final UpdateManagerEvent e) {
            EventQueue.invokeLater(new Runnable() {
                    public void run() {
                        if (!doubleBufferedRendering) {
                            image = e.getImage();
                        }

                        Object[] dll = updateManagerListeners.toArray();

                        if (dll.length > 0) {
                            for (int i = 0; i < dll.length; i++) {
                                ((UpdateManagerListener)dll[i]).
                                    updateStarted(e);
                            }
                        }
                    }
                });
        }

        /**
         * Called when an update was completed.
         */
        public void updateCompleted(final UpdateManagerEvent e) {
            // IMPORTANT:
            // ==========
            //
            // The following call is 'invokeAndWait' and not
            // 'invokeLater' because it is essential that the
            // UpdateManager thread (which invokes this
            // 'updateCompleted' method, blocks until the repaint
            // has completed. Otherwise, there is a possibility
            // that internal buffers would get updated in the
            // middle of a swing repaint.
            //
            try {
                EventQueue.invokeAndWait(new Runnable() {
                        public void run() {
                            image = e.getImage();
                            if (e.getClearPaintingTransform())
                                paintingTransform = null;

                            List l = e.getDirtyAreas();
                            if (l != null) {
                                Iterator i = l.iterator();
                                while (i.hasNext()) {
                                    Rectangle r = (Rectangle)i.next();
                                    if (updateOverlay != null) {
                                        updateOverlay.addRect(r);
                                        r = getRenderRect();
                                    }

                                    if (doubleBufferedRendering)
                                        repaint(r);
                                    else
                                        paintImmediately(r);
                                }
                                if (updateOverlay != null)
                                    updateOverlay.endUpdate();
                            }
                            suspendInteractions = false;
                        }
                    });
            } catch (Exception ex) {
            }


            EventQueue.invokeLater(new Runnable() {
                    public void run() {
                        Object[] dll = updateManagerListeners.toArray();

                        if (dll.length > 0) {
                            for (int i = 0; i < dll.length; i++) {
                                ((UpdateManagerListener)dll[i]).
                                    updateCompleted(e);
                            }
                        }
                    }
                });
        }

        /**
         * Called when an update failed.
         */
        public void updateFailed(final UpdateManagerEvent e) {
            EventQueue.invokeLater(new Runnable() {
                    public void run() {
                        Object[] dll = updateManagerListeners.toArray();

                        if (dll.length > 0) {
                            for (int i = 0; i < dll.length; i++) {
                                ((UpdateManagerListener)dll[i]).
                                    updateFailed(e);
                            }
                        }
                    }
                });
        }

        // Event propagation to GVT ///////////////////////////////////////

        /**
         * Dispatches the event to the GVT tree.
         */
        protected void dispatchKeyTyped(final KeyEvent e) {
            if (!isDynamicDocument) {
                super.dispatchKeyTyped(e);
                return;
            }

            if (updateManager != null && updateManager.isRunning()) {
                updateManager.getUpdateRunnableQueue().invokeLater
                    (new Runnable() {
                        public void run() {
                            eventDispatcher.keyTyped(e);
                        }
                    });
            }

        }

        /**
         * Dispatches the event to the GVT tree.
         */
        protected void dispatchKeyPressed(final KeyEvent e) {
            if (!isDynamicDocument) {
                super.dispatchKeyPressed(e);
                return;
            }

            if (updateManager != null && updateManager.isRunning()) {
                updateManager.getUpdateRunnableQueue().invokeLater
                    (new Runnable() {
                        public void run() {
                            eventDispatcher.keyPressed(e);
                        }
                    });
            }
        }

        /**
         * Dispatches the event to the GVT tree.
         */
        protected void dispatchKeyReleased(final KeyEvent e) {
            if (!isDynamicDocument) {
                super.dispatchKeyReleased(e);
                return;
            }

            if (updateManager != null && updateManager.isRunning()) {
                updateManager.getUpdateRunnableQueue().invokeLater
                    (new Runnable() {
                        public void run() {
                            eventDispatcher.keyReleased(e);
                        }
                    });
            }
        }

        /**
         * Dispatches the event to the GVT tree.
         */
        protected void dispatchMouseClicked(final MouseEvent e) {
            if (!isInteractiveDocument) {
                super.dispatchMouseClicked(e);
                return;
            }

            if (updateManager != null && updateManager.isRunning()) {
                updateManager.getUpdateRunnableQueue().invokeLater
                    (new Runnable() {
                        public void run() {
                            eventDispatcher.mouseClicked(e);

                        }
                    });
            }
        }

        /**
         * Dispatches the event to the GVT tree.
         */
        protected void dispatchMousePressed(final MouseEvent e) {
            if (!isDynamicDocument) {
                super.dispatchMousePressed(e);
                return;
            }

            if (updateManager != null && updateManager.isRunning()) {
                updateManager.getUpdateRunnableQueue().invokeLater
                    (new Runnable() {
                        public void run() {
                            eventDispatcher.mousePressed(e);
                        }
                    });
            }
        }

        /**
         * Dispatches the event to the GVT tree.
         */
        protected void dispatchMouseReleased(final MouseEvent e) {
            if (!isDynamicDocument) {
                super.dispatchMouseReleased(e);
                return;
            }

            if (updateManager != null && updateManager.isRunning()) {
                updateManager.getUpdateRunnableQueue().invokeLater
                    (new Runnable() {
                        public void run() {
                            eventDispatcher.mouseReleased(e);
                        }
                    });
            }
        }

        /**
         * Dispatches the event to the GVT tree.
         */
        protected void dispatchMouseEntered(final MouseEvent e) {
            if (!isInteractiveDocument) {
                super.dispatchMouseEntered(e);
                return;
            }

            if (updateManager != null && updateManager.isRunning()) {
                updateManager.getUpdateRunnableQueue().invokeLater
                    (new Runnable() {
                        public void run() {
                            eventDispatcher.mouseEntered(e);
                        }
                    });
            }
        }

        /**
         * Dispatches the event to the GVT tree.
         */
        protected void dispatchMouseExited(final MouseEvent e) {
            if (!isInteractiveDocument) {
                super.dispatchMouseExited(e);
                return;
            }

            if (updateManager != null && updateManager.isRunning()) {
                updateManager.getUpdateRunnableQueue().invokeLater
                    (new Runnable() {
                        public void run() {
                            eventDispatcher.mouseExited(e);
                        }
                    });
            }
        }

        /**
         * Dispatches the event to the GVT tree.
         */
        protected void dispatchMouseDragged(MouseEvent e) {
            if (!isDynamicDocument) {
                super.dispatchMouseDragged(e);
                return;
            }

            class MouseDraggedRunnable implements Runnable {
                MouseEvent event;
                MouseDraggedRunnable(MouseEvent evt) {
                    event = evt;
                }
                public void run() {
                    eventDispatcher.mouseDragged(event);
                }
            }

            if (updateManager != null && updateManager.isRunning()) {
                RunnableQueue rq = updateManager.getUpdateRunnableQueue();

                // Events compression.
                synchronized (rq.getIteratorLock()) {
                    Iterator it = rq.iterator();
                    while (it.hasNext()) {
                        Object next = it.next();
                        if (next instanceof MouseDraggedRunnable) {
                            MouseDraggedRunnable mdr;
                            mdr = (MouseDraggedRunnable)next;
                            MouseEvent mev = mdr.event;
                            if (mev.getModifiers() == e.getModifiers()) {
                                mdr.event = e;
                            }
                            return;
                        }
                    }
                }

                rq.invokeLater(new MouseDraggedRunnable(e));
            }
        }

        /**
         * Dispatches the event to the GVT tree.
         */
        protected void dispatchMouseMoved(MouseEvent e) {
            if (!isInteractiveDocument) {
                super.dispatchMouseMoved(e);
                return;
            }

            class MouseMovedRunnable implements Runnable {
                MouseEvent event;
                MouseMovedRunnable(MouseEvent evt) {
                    event = evt;
                }
                public void run() {
                    eventDispatcher.mouseMoved(event);
                }
            }

            if (updateManager != null && updateManager.isRunning()) {
                RunnableQueue rq = updateManager.getUpdateRunnableQueue();

                // Events compression.
                int i = 0;
                synchronized (rq.getIteratorLock()) {
                    Iterator it = rq.iterator();
                    while (it.hasNext()) {
                        Object next = it.next();
                        if (next instanceof MouseMovedRunnable) {
                            MouseMovedRunnable mmr;
                            mmr = (MouseMovedRunnable)next;
                            MouseEvent mev = mmr.event;
                            if (mev.getModifiers() == e.getModifiers()) {
                                mmr.event = e;
                            }
                            return;
                        }
                        i++;
                    }

                }

                rq.invokeLater(new MouseMovedRunnable(e));
            }
        }
    }

    /**
     * Creates a UserAgent.
     */
    protected UserAgent createUserAgent() {
        return new BridgeUserAgent();
    }

    /**
     * The user-agent wrapper, which call the methods in the event thread.
     */
    protected static class BridgeUserAgentWrapper implements UserAgent {

        /**
         * The wrapped user agent.
         */
        protected UserAgent userAgent;

        /**
         * Creates a new BridgeUserAgentWrapper.
         */
        public BridgeUserAgentWrapper(UserAgent ua) {
            userAgent = ua;
        }

        /**
         * Returns the event dispatcher to use.
         */
        public EventDispatcher getEventDispatcher() {
            if (EventQueue.isDispatchThread()) {
                return userAgent.getEventDispatcher();
            } else {
                class Query implements Runnable {
                    EventDispatcher result;
                    public void run() {
                        result = userAgent.getEventDispatcher();
                    }
                }
                Query q = new Query();
                invokeAndWait(q);
                return q.result;
            }
        }

        /**
         * Returns the default size of the viewport.
         */
        public Dimension2D getViewportSize() {
            if (EventQueue.isDispatchThread()) {
                return userAgent.getViewportSize();
            } else {
                class Query implements Runnable {
                    Dimension2D result;
                    public void run() {
                        result = userAgent.getViewportSize();
                    }
                }
                Query q = new Query();
                invokeAndWait(q);
                return q.result;
            }
        }

        /**
         * Displays an error resulting from the specified Exception.
         */
        public void displayError(final Exception ex) {
            if (EventQueue.isDispatchThread()) {
                userAgent.displayError(ex);
            } else {
                EventQueue.invokeLater(new Runnable() {
                        public void run() {
                            userAgent.displayError(ex);
                        }
                    });
            }
        }

        /**
         * Displays a message in the User Agent interface.
         */
        public void displayMessage(final String message) {
            if (EventQueue.isDispatchThread()) {
                userAgent.displayMessage(message);
            } else {
                EventQueue.invokeLater(new Runnable() {
                        public void run() {
                            userAgent.displayMessage(message);
                        }
                    });
            }
        }

        /**
         * Shows an alert dialog box.
         */
        public void showAlert(final String message) {
            if (EventQueue.isDispatchThread()) {
                userAgent.showAlert(message);
            } else {
                invokeAndWait(new Runnable() {
                        public void run() {
                            userAgent.showAlert(message);
                        }
                    });
            }
        }

        /**
         * Shows a prompt dialog box.
         */
        public String showPrompt(final String message) {
            if (EventQueue.isDispatchThread()) {
                return userAgent.showPrompt(message);
            } else {
                class Query implements Runnable {
                    String result;
                    public void run() {
                        result = userAgent.showPrompt(message);
                    }
                }
                Query q = new Query();
                invokeAndWait(q);
                return q.result;
            }
        }

        /**
         * Shows a prompt dialog box.
         */
        public String showPrompt(final String message,
                                 final String defaultValue) {
            if (EventQueue.isDispatchThread()) {
                return userAgent.showPrompt(message, defaultValue);
            } else {
                class Query implements Runnable {
                    String result;
                    public void run() {
                        result = userAgent.showPrompt(message, defaultValue);
                    }
                }
                Query q = new Query();
                invokeAndWait(q);
                return q.result;
            }
        }

        /**
         * Shows a confirm dialog box.
         */
        public boolean showConfirm(final String message) {
            if (EventQueue.isDispatchThread()) {
                return userAgent.showConfirm(message);
            } else {
                class Query implements Runnable {
                    boolean result;
                    public void run() {
                        result = userAgent.showConfirm(message);
                    }
                }
                Query q = new Query();
                invokeAndWait(q);
                return q.result;
            }
        }

        /**
         * Returns the size of a px CSS unit in millimeters.
         */
        public float getPixelUnitToMillimeter() {
            if (EventQueue.isDispatchThread()) {
                return userAgent.getPixelUnitToMillimeter();
            } else {
                class Query implements Runnable {
                    float result;
                    public void run() {
                        result = userAgent.getPixelUnitToMillimeter();
                    }
                }
                Query q = new Query();
                invokeAndWait(q);
                return q.result;
            }
        }

        /**
         * Returns the size of a px CSS unit in millimeters.
         * This will be removed after next release.
         * @see #getPixelUnitToMillimeter()
         */
        public float getPixelToMM() { return getPixelUnitToMillimeter(); }


        /**
         * Returns the default font family.
         */
        public String getDefaultFontFamily() {
            if (EventQueue.isDispatchThread()) {
                return userAgent.getDefaultFontFamily();
            } else {
                class Query implements Runnable {
                    String result;
                    public void run() {
                        result = userAgent.getDefaultFontFamily();
                    }
                }
                Query q = new Query();
                invokeAndWait(q);
                return q.result;
            }
        }

        public float getMediumFontSize() {
            if (EventQueue.isDispatchThread()) {
                return userAgent.getMediumFontSize();
            } else {
                class Query implements Runnable {
                    float result;
                    public void run() {
                        result = userAgent.getMediumFontSize();
                    }
                }
                Query q = new Query();
                invokeAndWait(q);
                return q.result;
            }
        }

        public float getLighterFontWeight(float f) {
            if (EventQueue.isDispatchThread()) {
                return userAgent.getLighterFontWeight(f);
            } else {
                final float ff = f;
                class Query implements Runnable {
                    float result;
                    public void run() {
                        result = userAgent.getLighterFontWeight(ff);
                    }
                }
                Query q = new Query();
                invokeAndWait(q);
                return q.result;
            }
        }

        public float getBolderFontWeight(float f) {
            if (EventQueue.isDispatchThread()) {
                return userAgent.getBolderFontWeight(f);
            } else {
                final float ff = f;
                class Query implements Runnable {
                    float result;
                    public void run() {
                        result = userAgent.getBolderFontWeight(ff);
                    }
                }
                Query q = new Query();
                invokeAndWait(q);
                return q.result;
            }
        }

        /**
         * Returns the language settings.
         */
        public String getLanguages() {
            if (EventQueue.isDispatchThread()) {
                return userAgent.getLanguages();
            } else {
                class Query implements Runnable {
                    String result;
                    public void run() {
                        result = userAgent.getLanguages();
                    }
                }
                Query q = new Query();
                invokeAndWait(q);
                return q.result;
            }
        }

        /**
         * Returns the user stylesheet uri.
         * @return null if no user style sheet was specified.
         */
        public String getUserStyleSheetURI() {
            if (EventQueue.isDispatchThread()) {
                return userAgent.getUserStyleSheetURI();
            } else {
                class Query implements Runnable {
                    String result;
                    public void run() {
                        result = userAgent.getUserStyleSheetURI();
                    }
                }
                Query q = new Query();
                invokeAndWait(q);
                return q.result;
            }
        }

        /**
         * Opens a link.
         * @param elt The activated link element.
         */
        public void openLink(final SVGAElement elt) {
            if (EventQueue.isDispatchThread()) {
                userAgent.openLink(elt);
            } else {
                EventQueue.invokeLater(new Runnable() {
                        public void run() {
                            userAgent.openLink(elt);
                        }
                    });
            }
        }

        /**
         * Informs the user agent to change the cursor.
         * @param cursor the new cursor
         */
        public void setSVGCursor(final Cursor cursor) {
            if (EventQueue.isDispatchThread()) {
                userAgent.setSVGCursor(cursor);
            } else {
                EventQueue.invokeLater(new Runnable() {
                        public void run() {
                            userAgent.setSVGCursor(cursor);
                        }
                    });
            }
        }

        /**
         * Informs the user agent that the text selection should be changed.
         * @param start The Mark for the start of the selection.
         * @param end   The Mark for the end of the selection.
         */
        public void setTextSelection(final Mark start, final Mark end) {
            if (EventQueue.isDispatchThread()) {
                userAgent.setTextSelection(start, end);
            } else {
                EventQueue.invokeLater(new Runnable() {
                        public void run() {
                            userAgent.setTextSelection(start, end);
                        }
                    });
            }
        }

        /**
         * Informs the user agent that the text should be deselected.
         */
        public void deselectAll() {
            if (EventQueue.isDispatchThread()) {
                userAgent.deselectAll();
            } else {
                EventQueue.invokeLater(new Runnable() {
                        public void run() {
                            userAgent.deselectAll();
                        }
                    });
            }
        }

        /**
         * Returns the class name of the XML parser.
         */
        public String getXMLParserClassName() {
            if (EventQueue.isDispatchThread()) {
                return userAgent.getXMLParserClassName();
            } else {
                class Query implements Runnable {
                    String result;
                    public void run() {
                        result = userAgent.getXMLParserClassName();
                    }
                }
                Query q = new Query();
                invokeAndWait(q);
                return q.result;
            }
        }

        /**
         * Returns true if the XML parser must be in validation mode, false
         * otherwise.
         */
        public boolean isXMLParserValidating() {
            if (EventQueue.isDispatchThread()) {
                return userAgent.isXMLParserValidating();
            } else {
                class Query implements Runnable {
                    boolean result;
                    public void run() {
                        result = userAgent.isXMLParserValidating();
                    }
                }
                Query q = new Query();
                invokeAndWait(q);
                return q.result;
            }
        }

        /**
         * Returns the <code>AffineTransform</code> currently
         * applied to the drawing by the UserAgent.
         */
        public AffineTransform getTransform() {
            if (EventQueue.isDispatchThread()) {
                return userAgent.getTransform();
            } else {
                class Query implements Runnable {
                    AffineTransform result;
                    public void run() {
                        result = userAgent.getTransform();
                    }
                }
                Query q = new Query();
                invokeAndWait(q);
                return q.result;
            }
        }

        /**
         * Sets the <code>AffineTransform</code> to be
         * applied to the drawing by the UserAgent.
         */
        public void setTransform(AffineTransform at) {
            if (EventQueue.isDispatchThread()) {
                userAgent.setTransform(at);
            } else {
                final AffineTransform affine = at;
                class Query implements Runnable {
                    public void run() {
                        userAgent.setTransform(affine);
                    }
                }
                Query q = new Query();
                invokeAndWait(q);
            }
        }

        /**
         * Returns this user agent's CSS media.
         */
        public String getMedia() {
            if (EventQueue.isDispatchThread()) {
                return userAgent.getMedia();
            } else {
                class Query implements Runnable {
                    String result;
                    public void run() {
                        result = userAgent.getMedia();
                    }
                }
                Query q = new Query();
                invokeAndWait(q);
                return q.result;
            }
        }

        /**
         * Returns this user agent's alternate style-sheet title.
         */
        public String getAlternateStyleSheet() {
            if (EventQueue.isDispatchThread()) {
                return userAgent.getAlternateStyleSheet();
            } else {
                class Query implements Runnable {
                    String result;
                    public void run() {
                        result = userAgent.getAlternateStyleSheet();
                    }
                }
                Query q = new Query();
                invokeAndWait(q);
                return q.result;
            }
        }

        /**
         * Returns the location on the screen of the
         * client area in the UserAgent.
         */
        public Point getClientAreaLocationOnScreen() {
            if (EventQueue.isDispatchThread()) {
                return userAgent.getClientAreaLocationOnScreen();
            } else {
                class Query implements Runnable {
                    Point result;
                    public void run() {
                        result = userAgent.getClientAreaLocationOnScreen();
                    }
                }
                Query q = new Query();
                invokeAndWait(q);
                return q.result;
            }
        }

        /**
         * Tells whether the given feature is supported by this
         * user agent.
         */
        public boolean hasFeature(final String s) {
            if (EventQueue.isDispatchThread()) {
                return userAgent.hasFeature(s);
            } else {
                class Query implements Runnable {
                    boolean result;
                    public void run() {
                        result = userAgent.hasFeature(s);
                    }
                }
                Query q = new Query();
                invokeAndWait(q);
                return q.result;
            }
        }

        /**
         * Tells whether the given extension is supported by this
         * user agent.
         */
        public boolean supportExtension(final String s) {
            if (EventQueue.isDispatchThread()) {
                return userAgent.supportExtension(s);
            } else {
                class Query implements Runnable {
                    boolean result;
                    public void run() {
                        result = userAgent.supportExtension(s);
                    }
                }
                Query q = new Query();
                invokeAndWait(q);
                return q.result;
            }
        }

        /**
         * Lets the bridge tell the user agent that the following
         * extension is supported by the bridge.
         */
        public void registerExtension(final BridgeExtension ext) {
            if (EventQueue.isDispatchThread()) {
                userAgent.registerExtension(ext);
            } else {
                EventQueue.invokeLater(new Runnable() {
                        public void run() {
                            userAgent.registerExtension(ext);
                        }
                    });
            }
        }

        /**
         * Notifies the UserAgent that the input element
         * has been found in the document. This is sometimes
         * called, for example, to handle &lt;a&gt; or
         * &lt;title&gt; elements in a UserAgent-dependant
         * way.
         */
        public void handleElement(final Element elt, final Object data) {
            if (EventQueue.isDispatchThread()) {
                userAgent.handleElement(elt, data);
            } else {
                EventQueue.invokeLater(new Runnable() {
                        public void run() {
                            userAgent.handleElement(elt, data);
                        }
                    });
            }
        }

        /**
         * Returns the security settings for the given script
         * type, script url and document url
         *
         * @param scriptType type of script, as found in the
         *        type attribute of the &lt;script&gt; element.
         * @param scriptPURL url for the script, as defined in
         *        the script's xlink:href attribute. If that
         *        attribute was empty, then this parameter should
         *        be null
         * @param docPURL url for the document into which the
         *        script was found.
         */
        public ScriptSecurity getScriptSecurity(String scriptType,
                                                ParsedURL scriptPURL,
                                                ParsedURL docPURL){
            if (EventQueue.isDispatchThread()) {
                return userAgent.getScriptSecurity(scriptType,
                                                   scriptPURL,
                                                   docPURL);
            } else {
                final String st = scriptType;
                final ParsedURL sPURL= scriptPURL;
                final ParsedURL dPURL= docPURL;
                class Query implements Runnable {
                    ScriptSecurity result;
                    public void run() {
                        result = userAgent.getScriptSecurity(st, sPURL, dPURL);
                    }
                }
                Query q = new Query();
                invokeAndWait(q);
                return q.result;
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
         * @param scriptPURL url for the script, as defined in
         *        the script's xlink:href attribute. If that
         *        attribute was empty, then this parameter should
         *        be null
         * @param docPURL url for the document into which the
         *        script was found.
         */
        public void checkLoadScript(String scriptType,
                                    ParsedURL scriptPURL,
                                    ParsedURL docPURL) throws SecurityException {
            if (EventQueue.isDispatchThread()) {
                userAgent.checkLoadScript(scriptType,
                                          scriptPURL,
                                          docPURL);
            } else {
                final String st = scriptType;
                final ParsedURL sPURL= scriptPURL;
                final ParsedURL dPURL= docPURL;
                class Query implements Runnable {
                    SecurityException se = null;
                    public void run() {
                        try {
                            userAgent.checkLoadScript(st, sPURL, dPURL);
                        } catch (SecurityException se) {
                            this.se = se;
                        }
                    }
                }
                Query q = new Query();
                invokeAndWait(q);
                if (q.se != null) {
                    q.se.fillInStackTrace();
                    throw q.se;
                }
            }
        }


        /**
         * Returns the security settings for the given resource
         * url and document url
         *
         * @param resourcePURL url for the resource, as defined in
         *        the resource's xlink:href attribute. If that
         *        attribute was empty, then this parameter should
         *        be null
         * @param docPURL url for the document into which the
         *        resource was found.
         */
        public ExternalResourceSecurity
            getExternalResourceSecurity(ParsedURL resourcePURL,
                                        ParsedURL docPURL){
            if (EventQueue.isDispatchThread()) {
                return userAgent.getExternalResourceSecurity(resourcePURL,
                                                             docPURL);
            } else {
                final ParsedURL rPURL= resourcePURL;
                final ParsedURL dPURL= docPURL;
                class Query implements Runnable {
                    ExternalResourceSecurity result;
                    public void run() {
                        result = userAgent.getExternalResourceSecurity(rPURL, dPURL);
                    }
                }
                Query q = new Query();
                invokeAndWait(q);
                return q.result;
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
         * @param resourceURL url for the resource, as defined in
         *        the resource's xlink:href attribute. If that
         *        attribute was empty, then this parameter should
         *        be null
         * @param docURL url for the document into which the
         *        resource was found.
         */
        public void
            checkLoadExternalResource(ParsedURL resourceURL,
                                      ParsedURL docURL) throws SecurityException {
            if (EventQueue.isDispatchThread()) {
                userAgent.checkLoadExternalResource(resourceURL,
                                                    docURL);
            } else {
                final ParsedURL rPURL= resourceURL;
                final ParsedURL dPURL= docURL;
                class Query implements Runnable {
                    SecurityException se;
                    public void run() {
                        try {
                            userAgent.checkLoadExternalResource(rPURL, dPURL);
                        } catch (SecurityException se) {
                            this.se = se;
                        }
                    }
                }
                Query q = new Query();
                invokeAndWait(q);
                if (q.se != null) {
                    q.se.fillInStackTrace();
                    throw q.se;
                }
            }
        }


        /**
         * This Implementation simply forwards the request to the AWT thread.
         *
         * @param e   The <image> element that can't be loaded.
         * @param url The resolved url that can't be loaded.
         * @param msg As best as can be determined the reason it can't be
         *            loaded (not available, corrupt, unknown format,...).
         */
        public SVGDocument getBrokenLinkDocument(final Element e,
                                                 final String url,
                                                 final String msg) {
            if (EventQueue.isDispatchThread())
                return userAgent.getBrokenLinkDocument(e, url, msg);

            class Query implements Runnable {
                SVGDocument doc;
                RuntimeException rex = null;
                public void run() {
                    try {
                        doc = userAgent.getBrokenLinkDocument(e, url, msg);
                    } catch (RuntimeException re) { rex = re; }
                }
            }
            Query q = new Query();
            invokeAndWait(q);
            if (q.rex != null) throw q.rex;
            return q.doc;
        }


        /**
         * Invokes the given runnable from the event thread, and wait
         * for the run method to terminate.
         */
        protected void invokeAndWait(Runnable r) {
            try {
                EventQueue.invokeAndWait(r);
            } catch (Exception e) {
            }
        }
    }

    /**
     * To hide the user-agent methods.
     */
    protected class BridgeUserAgent implements UserAgent {

        /**
         * Creates a new user agent.
         */
        protected BridgeUserAgent() {
        }

        /**
         * Returns the default size of the viewport of this user agent (0, 0).
         */
        public Dimension2D getViewportSize() {
            return getSize();
        }

        /**
         * Returns the <code>EventDispatcher</code> used by the
         * <code>UserAgent</code> to dispatch events on GVT.
         */
        public EventDispatcher getEventDispatcher() {
            return AbstractJSVGComponent.this.eventDispatcher;
        }

        /**
         * Displays an error message in the User Agent interface.
         */
        public void displayError(String message) {
            if (svgUserAgent != null) {
                svgUserAgent.displayError(message);
            }
        }

        /**
         * Displays an error resulting from the specified Exception.
         */
        public void displayError(Exception ex) {
            if (svgUserAgent != null) {
                svgUserAgent.displayError(ex);
            }
        }

        /**
         * Displays a message in the User Agent interface.
         */
        public void displayMessage(String message) {
            if (svgUserAgent != null) {
                svgUserAgent.displayMessage(message);
            }
        }

        /**
         * Shows an alert dialog box.
         */
        public void showAlert(String message) {
            if (svgUserAgent != null) {
                svgUserAgent.showAlert(message);
                return;
            }
            AbstractJSVGComponent.this.showAlert(message);
        }

        /**
         * Shows a prompt dialog box.
         */
        public String showPrompt(String message) {
            if (svgUserAgent != null) {
                return svgUserAgent.showPrompt(message);
            }
            return AbstractJSVGComponent.this.showPrompt(message);
        }

        /**
         * Shows a prompt dialog box.
         */
        public String showPrompt(String message, String defaultValue) {
            if (svgUserAgent != null) {
                return svgUserAgent.showPrompt(message, defaultValue);
            }
            return AbstractJSVGComponent.this.showPrompt
                (message, defaultValue);
        }

        /**
         * Shows a confirm dialog box.
         */
        public boolean showConfirm(String message) {
            if (svgUserAgent != null) {
                return svgUserAgent.showConfirm(message);
            }
            return AbstractJSVGComponent.this.showConfirm(message);
        }

        /**
         * Returns the size of a px CSS unit in millimeters.
         */
        public float getPixelUnitToMillimeter() {
            if (svgUserAgent != null) {
                return svgUserAgent.getPixelUnitToMillimeter();
            }
            return 0.264583333333333333333f; // 96 dpi
        }

        /**
         * Returns the size of a px CSS unit in millimeters.
         * This will be removed after next release.
         * @see #getPixelUnitToMillimeter()
         */
        public float getPixelToMM() { return getPixelUnitToMillimeter(); }

        /**
         * Returns the default font family.
         */
        public String getDefaultFontFamily() {
            if (svgUserAgent != null) {
                return svgUserAgent.getDefaultFontFamily();
            }
            return "Arial, Helvetica, sans-serif";
        }

        /**
         * Returns the  medium font size.
         */
        public float getMediumFontSize() {
            if (svgUserAgent != null) {
                return svgUserAgent.getMediumFontSize();
            }
            // 9pt (72pt = 1in)
            return 9f * 25.4f / (72f * getPixelUnitToMillimeter());
        }

        /**
         * Returns a lighter font-weight.
         */
        public float getLighterFontWeight(float f) {
            if (svgUserAgent != null) {
                return svgUserAgent.getLighterFontWeight(f);
            }
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
            if (svgUserAgent != null) {
                return svgUserAgent.getBolderFontWeight(f);
            }
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
            if (svgUserAgent != null) {
                return svgUserAgent.getLanguages();
            }
            return "en";
        }

        /**
         * Returns the user stylesheet uri.
         * @return null if no user style sheet was specified.
         */
        public String getUserStyleSheetURI() {
            if (svgUserAgent != null) {
                return svgUserAgent.getUserStyleSheetURI();
            }
            return null;
        }

        /**
         * Opens a link.
         * @param elt The activated link element.
         */
        public void openLink(SVGAElement elt) {
            String show = XLinkSupport.getXLinkShow(elt);
            String href = elt.getHref().getAnimVal();
            if (show.equals("new")) {
                fireLinkActivatedEvent(elt, href);
                if (svgUserAgent != null) {
                    String oldURI = svgDocument.getURL();
                    ParsedURL newURI = null;
                    // if the anchor element is in an external resource
                    if (elt.getOwnerDocument() != svgDocument) {
                        SVGDocument doc = (SVGDocument)elt.getOwnerDocument();
                        href = new ParsedURL(doc.getURL(), href).toString();
                    }
                    newURI = new ParsedURL(oldURI, href);
                    href = newURI.toString();
                    svgUserAgent.openLink(href, true);
                } else {
                    AbstractJSVGComponent.this.loadSVGDocument(href);
                }
                return;
            }

            // Always use anchor element's document for base URI,
            // for when it comes from an external resource.
            ParsedURL newURI = new ParsedURL
                (((SVGDocument)elt.getOwnerDocument()).getURL(), href);

            // replace href with a fully resolved URI.
            href = newURI.toString();

            // Avoid reloading if possible.
            if (svgDocument != null) {

                ParsedURL oldURI = new ParsedURL(svgDocument.getURL());
                // Check if they reference the same file.
                if (newURI.sameFile(oldURI)) {
                    // They do, see if it's a new Fragment Ident.
                    String s = newURI.getRef();
                    if ((fragmentIdentifier != s) &&
                        ((s == null) || (!s.equals(fragmentIdentifier)))) {
                        // It is, so update rendering transform.
                        fragmentIdentifier = s;
                        if (computeRenderingTransform())
                            scheduleGVTRendering();
                    }
                    // Let every one know the link fired (but don't
                    // load doc, it's already loaded.).
                    fireLinkActivatedEvent(elt, href);
                    return;
                }
            }

            fireLinkActivatedEvent(elt, href);
            if (svgUserAgent != null) {
                svgUserAgent.openLink(href, false);
            } else {
                AbstractJSVGComponent.this.loadSVGDocument(href);
            }
        }

        /**
         * Fires a LinkActivatedEvent.
         */
        protected void fireLinkActivatedEvent(SVGAElement elt, String href) {
            Object[] ll = linkActivationListeners.toArray();

            if (ll.length > 0) {
                LinkActivationEvent ev;
                ev = new LinkActivationEvent
                    (AbstractJSVGComponent.this, elt, href);

                for (int i = 0; i < ll.length; i++) {
                    LinkActivationListener l = (LinkActivationListener)ll[i];
                    l.linkActivated(ev);
                }
            }
        }

        /**
         * Informs the user agent to change the cursor.
         * @param cursor the new cursor
         */
        public void setSVGCursor(Cursor cursor) {
            if (cursor != AbstractJSVGComponent.this.getCursor())
                AbstractJSVGComponent.this.setCursor(cursor);
        }

        /**
         * Informs the user agent that the text selection has changed.
         * @param start The Mark for the start of the selection.
         * @param end   The Mark for the end of the selection.
         */
        public void setTextSelection(Mark start, Mark end) {
            AbstractJSVGComponent.this.select(start, end);
        }

        /**
         * Informs the user agent that the text selection should be
         * cleared.
         */
        public void deselectAll() {
            AbstractJSVGComponent.this.deselectAll();
        }

        /**
         * Returns the class name of the XML parser.
         */
        public String getXMLParserClassName() {
            if (svgUserAgent != null) {
                return svgUserAgent.getXMLParserClassName();
            }
            return XMLResourceDescriptor.getXMLParserClassName();
        }

        /**
         * Returns true if the XML parser must be in validation mode, false
         * otherwise depending on the SVGUserAgent.
         */
        public boolean isXMLParserValidating() {
            if (svgUserAgent != null) {
                return svgUserAgent.isXMLParserValidating();
            }
            return false;
        }

        /**
         * Returns the <code>AffineTransform</code> currently
         * applied to the drawing by the UserAgent.
         */
        public AffineTransform getTransform() {
            return AbstractJSVGComponent.this.renderingTransform;
        }

        /**
         * Sets the <code>AffineTransform</code> to be
         * applied to the drawing by the UserAgent.
         */
        public void setTransform(AffineTransform at) {
            AbstractJSVGComponent.this.setRenderingTransform(at);
        }

        /**
         * Returns this user agent's CSS media.
         */
        public String getMedia() {
            if (svgUserAgent != null) {
                return svgUserAgent.getMedia();
            }
            return "screen";
        }

        /**
         * Returns this user agent's alternate style-sheet title.
         */
        public String getAlternateStyleSheet() {
            if (svgUserAgent != null) {
                return svgUserAgent.getAlternateStyleSheet();
            }
            return null;
        }

        /**
         * Returns the location on the screen of the
         * client area in the UserAgent.
         */
        public Point getClientAreaLocationOnScreen() {
            return getLocationOnScreen();
        }

        /**
         * Tells whether the given feature is supported by this
         * user agent.
         */
        public boolean hasFeature(String s) {
            return FEATURES.contains(s);
        }

        protected Map extensions = new HashMap();

        /**
         * Tells whether the given extension is supported by this
         * user agent.
         */
        public boolean supportExtension(String s) {
            if ((svgUserAgent != null) &&
                (svgUserAgent.supportExtension(s)))
                return true;

            return extensions.containsKey(s);
        }

        /**
         * Lets the bridge tell the user agent that the following
         * extension is supported by the bridge.
         */
        public void registerExtension(BridgeExtension ext) {
            Iterator i = ext.getImplementedExtensions();
            while (i.hasNext())
                extensions.put(i.next(), ext);
        }


        /**
         * Notifies the UserAgent that the input element
         * has been found in the document. This is sometimes
         * called, for example, to handle &lt;a&gt; or
         * &lt;title&gt; elements in a UserAgent-dependant
         * way.
         */
        public void handleElement(Element elt, Object data) {
            if (svgUserAgent != null) {
                svgUserAgent.handleElement(elt, data);
            }
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
            if (svgUserAgent != null){
                return svgUserAgent.getScriptSecurity(scriptType,
                                                      scriptURL,
                                                      docURL);
            } else {
                return new DefaultScriptSecurity(scriptType,
                                                 scriptURL,
                                                 docURL);
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
            if (svgUserAgent != null) {
                svgUserAgent.checkLoadScript(scriptType,
                                             scriptURL,
                                             docURL);
            } else {
                ScriptSecurity s = getScriptSecurity(scriptType,
                                                     scriptURL,
                                                     docURL);
                if (s != null) {
                    s.checkLoadScript();
                }
            }
        }

        /**
         * Returns the security settings for the given
         * resource url and document url
         *
         * @param resourceURL url for the script, as defined in
         *        the resource's xlink:href attribute. If that
         *        attribute was empty, then this parameter should
         *        be null
         * @param docURL url for the document into which the
         *        script was found.
         */
        public ExternalResourceSecurity
            getExternalResourceSecurity(ParsedURL resourceURL,
                                        ParsedURL docURL){
            if (svgUserAgent != null){
                return svgUserAgent.getExternalResourceSecurity(resourceURL,
                                                                docURL);
            } else {
                return new RelaxedExternalResourceSecurity(resourceURL,
                                                           docURL);
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
         * @param resourceURL url for the resource, as defined in
         *        the resource's xlink:href attribute. If that
         *        attribute was empty, then this parameter should
         *        be null
         * @param docURL url for the document into which the
         *        resource was found.
         */
        public void
            checkLoadExternalResource(ParsedURL resourceURL,
                                      ParsedURL docURL) throws SecurityException {
            if (svgUserAgent != null) {
                svgUserAgent.checkLoadExternalResource(resourceURL,
                                                       docURL);
            } else {
                ExternalResourceSecurity s
                    =  getExternalResourceSecurity(resourceURL, docURL);

                if (s != null) {
                    s.checkLoadExternalResource();
                }
            }
        }

        /**
         * This implementation provides a true SVG Document that it
         * annotates with some information about why the real document
         * can't be loaded (unfortunately right now tool tips are broken
         * for content referenced by images so you can't actually see
         * the info).
         *
         * @param e   The &lt;image> element that can't be loaded.
         * @param url The resolved url that can't be loaded.
         * @param message As best as can be determined the reason it can't be
         *                loaded (not available, corrupt, unknown format,...).
         */
        public SVGDocument getBrokenLinkDocument(Element e,
                                                 String url,
                                                 String message) {
            Class cls = AbstractJSVGComponent.class;
            URL blURL = cls.getResource("resources/BrokenLink.svg");
            if (blURL == null)
                throw new BridgeException
                    (bridgeContext, e, ErrorConstants.ERR_URI_IMAGE_BROKEN,
                     new Object[] { url, message });

            DocumentLoader loader  = bridgeContext.getDocumentLoader();
            SVGDocument    doc = null;

            try {
                doc  = (SVGDocument)loader.loadDocument(blURL.toString());
                if (doc == null) return doc;

                DOMImplementation impl;
                impl = SVGDOMImplementation.getDOMImplementation();
                doc  = (SVGDocument)DOMUtilities.deepCloneDocument(doc, impl);

                String title;
                Element infoE, titleE, descE;
                infoE = doc.getElementById("__More_About");
                if (infoE == null) return doc;

                titleE = doc.createElementNS(SVGConstants.SVG_NAMESPACE_URI,
                                            SVGConstants.SVG_TITLE_TAG);
                title = Messages.formatMessage(BROKEN_LINK_TITLE, null);
                titleE.appendChild(doc.createTextNode(title));

                descE = doc.createElementNS(SVGConstants.SVG_NAMESPACE_URI,
                                           SVGConstants.SVG_DESC_TAG);
                descE.appendChild(doc.createTextNode(message));

                infoE.insertBefore(descE, infoE.getFirstChild());
                infoE.insertBefore(titleE, descE);
            } catch (Exception ex) {
                throw new BridgeException
                    (bridgeContext, e, ex, ErrorConstants.ERR_URI_IMAGE_BROKEN,
                     new Object[] {url, message });
            }
            return doc;
        }
    }

    protected static final Set FEATURES = new HashSet();
    static {
        SVGFeatureStrings.addSupportedFeatureStrings(FEATURES);
    }
}
