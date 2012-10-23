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
package org.apache.flex.forks.batik.swing.gvt;

import java.awt.AlphaComposite;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.EventQueue;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Rectangle;
import java.awt.RenderingHints;
import java.awt.Toolkit;
import java.awt.Shape;
import java.awt.datatransfer.Clipboard;
import java.awt.datatransfer.StringSelection;
import java.awt.event.ComponentAdapter;
import java.awt.event.ComponentEvent;
import java.awt.event.InputEvent;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.MouseMotionListener;
import java.awt.geom.AffineTransform;
import java.awt.geom.NoninvertibleTransformException;
import java.awt.image.BufferedImage;
import java.text.CharacterIterator;
import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import javax.swing.JComponent;

import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.gvt.event.AWTEventDispatcher;
import org.apache.flex.forks.batik.gvt.event.EventDispatcher;
import org.apache.flex.forks.batik.gvt.event.SelectionAdapter;
import org.apache.flex.forks.batik.gvt.event.SelectionEvent;
import org.apache.flex.forks.batik.gvt.renderer.ConcreteImageRendererFactory;
import org.apache.flex.forks.batik.gvt.renderer.ImageRenderer;
import org.apache.flex.forks.batik.gvt.renderer.ImageRendererFactory;
import org.apache.flex.forks.batik.gvt.text.Mark;
import org.apache.flex.forks.batik.util.HaltingThread;
import org.apache.flex.forks.batik.util.Platform;

/**
 * This class represents a component which can display a GVT tree.
 *
 * This class is made abstract so that concrete versions can be made
 * for different JDK versions.  In particular, this is for MouseWheelEvent
 * support, which only exists in JDKs &gt;= 1.4.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: AbstractJGVTComponent.java 607659 2007-12-31 04:02:11Z cam $
 */
public abstract class AbstractJGVTComponent extends JComponent {

    /**
     * The listener.
     */
    protected Listener listener;

    /**
     * The GVT tree renderer.
     */
    protected GVTTreeRenderer gvtTreeRenderer;

    /**
     * The GVT tree root.
     */
    protected GraphicsNode gvtRoot;

    /**
     * The renderer factory.
     */
    protected ImageRendererFactory rendererFactory =
        new ConcreteImageRendererFactory();

    /**
     * The current renderer.
     */
    protected ImageRenderer renderer;

    /**
     * The GVT tree renderer listeners.
     */
    protected List gvtTreeRendererListeners =
        Collections.synchronizedList(new LinkedList());

    /**
     * Whether a render was requested.
     */
    protected boolean needRender;

    /**
     * Whether to allow progressive paint.
     */
    protected boolean progressivePaint;

    /**
     * The progressive paint thread.
     */
    protected HaltingThread progressivePaintThread;

    /**
     * The image to paint.
     */
    protected BufferedImage image;

    /**
     * The initial rendering transform.
     */
    protected AffineTransform initialTransform = new AffineTransform();

    /**
     * The transform used for rendering.
     */
    protected AffineTransform renderingTransform = new AffineTransform();

    /**
     * The transform used for painting.
     */
    protected AffineTransform paintingTransform;

    /**
     * The interactor list.
     */
    protected List interactors = new LinkedList();

    /**
     * The current interactor.
     */
    protected Interactor interactor;

    /**
     * The overlays.
     */
    protected List overlays = new LinkedList();

    /**
     * The JGVTComponentListener list.
     */
    protected List jgvtListeners = null;

    /**
     * The event dispatcher.
     */
    protected AWTEventDispatcher eventDispatcher;

    /**
     * The text selection manager.
     */
    protected TextSelectionManager textSelectionManager;

    /**
     * Whether the double buffering is enabled.
     */
    protected boolean doubleBufferedRendering;

    /**
     * Whether the GVT tree should be reactive to mouse and key events.
     */
    protected boolean eventsEnabled;

    /**
     * Whether the text should be selectable if eventEnabled is false,
     * this flag is ignored.
     */
    protected boolean selectableText;

    /**
     * Whether the JGVTComponent should adhere to 'Unix' text
     * selection semantics where as soon as text is selected it
     * is copied to the clipboard.  If users want Mac/Windows
     * behaviour they need to handle selections them selves.
     */
    protected boolean useUnixTextSelection = true;

    /**
     * Whether to suspend interactions.
     */
    protected boolean suspendInteractions;

    /**
     * Whether to unconditionally disable interactions.
     */
    protected boolean disableInteractions;

    /**
     * Creates a new AbstractJGVTComponent.
     */
    public AbstractJGVTComponent() {
        this(false, false);
    }

    /**
     * Creates a new abstract JGVTComponent.
     * @param eventsEnabled Whether the GVT tree should be reactive
     *        to mouse and key events.
     * @param selectableText Whether the text should be selectable.
     *        if eventEnabled is false, this flag is ignored.
     */
    public AbstractJGVTComponent(boolean eventsEnabled,
                                 boolean selectableText) {
        setBackground(Color.white);
        // setDoubleBuffered(false);

        this.eventsEnabled = eventsEnabled;
        this.selectableText = selectableText;

        listener = createListener();

        addAWTListeners();

        addGVTTreeRendererListener(listener);

        addComponentListener(new ComponentAdapter() {
                public void componentResized(ComponentEvent e) {
                    if (updateRenderingTransform())
                        scheduleGVTRendering();
                }
            });

    }

    /**
     * Adds the AWT listeners.
     */
    protected void addAWTListeners() {
        addKeyListener(listener);
        addMouseListener(listener);
        addMouseMotionListener(listener);
    }

    /**
     * Turn off all 'interactor' objects (pan, zoom, etc) if
     * 'b' is true, turn them on if 'b' is false.
     */
    public void setDisableInteractions(boolean b) {
        disableInteractions = b;
    }

    /**
     * Returns true if all 'interactor' objects
     * (pan, zoom, etc) are disabled.
     */
    public boolean getDisableInteractions() {
        return disableInteractions;
    }

    /**
     * If 'b' is true text selections will copied to
     * the clipboard immediately.  If 'b' is false
     * then nothing will be done when selections are
     * made (the application is responsable for copying
     * the selection in response to user actions).
     */
    public void setUseUnixTextSelection(boolean b) {
        useUnixTextSelection = b;
    }

    /**
     * Returns true if the canvas will copy selections
     * to the clipboard when they are completed.
     */
    public void getUseUnixTextSelection(boolean b) {
        useUnixTextSelection = b;
    }

    /**
     * Returns the interactor list.
     */
    public List getInteractors() {
        return interactors;
    }

    /**
     * Returns the overlay list.
     */
    public List getOverlays() {
        return overlays;
    }

    /**
     * Returns the off-screen image, if any.
     */
    public BufferedImage getOffScreen() {
        return image;
    }


    public void addJGVTComponentListener(JGVTComponentListener listener) {
        if (jgvtListeners == null)
            jgvtListeners = new LinkedList();
        jgvtListeners.add(listener);
    }

    public void removeJGVTComponentListener(JGVTComponentListener listener) {
        if (jgvtListeners == null) return;
        jgvtListeners.remove(listener);
    }

    /**
     * Resets the rendering transform to its initial value.
     */
    public void resetRenderingTransform() {
        setRenderingTransform(initialTransform);
    }

    /**
     * Stops the processing of the current tree.
     */
    public void stopProcessing() {
        if (gvtTreeRenderer != null) {
            needRender = false;
            gvtTreeRenderer.halt();
            haltProgressivePaintThread();
        }
    }

    /**
     * Returns the root of the GVT tree displayed by this component, if any.
     */
    public GraphicsNode getGraphicsNode() {
        return gvtRoot;
    }

    /**
     * Sets the GVT tree to display.
     */
    public void setGraphicsNode(GraphicsNode gn) {
        setGraphicsNode(gn, true);
        initialTransform = new AffineTransform();
        updateRenderingTransform();
        setRenderingTransform(initialTransform, true);
    }

    /**
     * Sets the GVT tree to display.
     */
    protected void setGraphicsNode(GraphicsNode gn, boolean createDispatcher) {
        gvtRoot = gn;
        if (gn != null && createDispatcher) {
            initializeEventHandling();
        }
        if (eventDispatcher != null) {
            eventDispatcher.setRootNode(gn);
        }
    }

    /**
     * Initializes the event handling classes.
     */
    protected void initializeEventHandling() {
        if (eventsEnabled) {
            eventDispatcher = new AWTEventDispatcher();
            if (selectableText) {
                textSelectionManager = createTextSelectionManager
                    (eventDispatcher);
                textSelectionManager.addSelectionListener
                     (new UnixTextSelectionListener());
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////
    // Selection methods
    ////////////////////////////////////////////////////////////////////////

    protected TextSelectionManager 
        createTextSelectionManager(EventDispatcher ed) {
        return new TextSelectionManager(this, ed);
    }

    /**
     * Returns the current Text selection manager for the Component.
     * Users can register with this to be notifed of changes in
     * the text selection.
     */
    public TextSelectionManager getTextSelectionManager() {
        return textSelectionManager;
    }

    /**
     * Sets the color of the selection overlay to the specified color.
     *
     * @param color the new color of the selection overlay
     */
    public void setSelectionOverlayColor(Color color) {
        if (textSelectionManager != null) {
            textSelectionManager.setSelectionOverlayColor(color);
        }
    }

    /**
     * Returns the color of the selection overlay.
     */
    public Color getSelectionOverlayColor() {
        if (textSelectionManager != null) {
            return textSelectionManager.getSelectionOverlayColor();
        } else {
            return null;
        }
    }

    /**
     * Sets the color of the outline of the selection overlay to the specified
     * color.
     *
     * @param color the new color of the outline of the selection overlay
     */
    public void setSelectionOverlayStrokeColor(Color color) {
        if (textSelectionManager != null) {
            textSelectionManager.setSelectionOverlayStrokeColor(color);
        }
    }

    /**
     * Returns the color of the outline of the selection overlay.
     */
    public Color getSelectionOverlayStrokeColor() {
        if (textSelectionManager != null) {
            return textSelectionManager.getSelectionOverlayStrokeColor();
        } else {
            return null;
        }
    }

    /**
     * Sets whether or not the selection overlay will be painted in XOR mode,
     * depending on the specified parameter.
     *
     * @param state true implies the selection overlay will be in XOR mode
     */
    public void setSelectionOverlayXORMode(boolean state) {
        if (textSelectionManager != null) {
            textSelectionManager.setSelectionOverlayXORMode(state);
        }
    }

    /**
     * Returns true if the selection overlay is painted in XOR mode, false
     * otherwise.
     */
    public boolean isSelectionOverlayXORMode() {
        if (textSelectionManager != null) {
            return textSelectionManager.isSelectionOverlayXORMode();
        } else {
            return false;
        }
    }

    /**
     * Sets the selection to the specified start and end mark.
     *
     * @param start the mark used to define where the selection starts
     * @param end the mark used to define where the selection ends
     */
    public void select(Mark start, Mark end) {
        if (textSelectionManager != null) {
            textSelectionManager.setSelection(start, end);
        }
    }

    /**
     * Deselects all.
     */
    public void deselectAll() {
        if (textSelectionManager != null) {
            textSelectionManager.clearSelection();
        }
    }

    ////////////////////////////////////////////////////////////////////////
    // Painting methods
    ////////////////////////////////////////////////////////////////////////

    /**
     * Whether to enable the progressive paint.
     */
    public void setProgressivePaint(boolean b) {
        if (progressivePaint != b) {
            progressivePaint = b;
            haltProgressivePaintThread();
        }
    }

    /**
     * Tells whether the progressive paint is enabled.
     */
    public boolean getProgressivePaint() {
        return progressivePaint;
    }

    public Rectangle getRenderRect() {
        Dimension d = getSize();
        return new Rectangle(0, 0, d.width, d.height);
    }

    /**
     * Repaints immediately the component.
     */
    public void immediateRepaint() {
        if (EventQueue.isDispatchThread()) {
            Rectangle visRect = getRenderRect();
            if (doubleBufferedRendering)
                repaint(visRect.x,     visRect.y,
                        visRect.width, visRect.height);
            else
                paintImmediately(visRect.x,     visRect.y,
                                 visRect.width, visRect.height);
        } else {
            try {
                EventQueue.invokeAndWait(new Runnable() {
                        public void run() {
                            Rectangle visRect = getRenderRect();
                            if (doubleBufferedRendering)
                                repaint(visRect.x,     visRect.y,
                                        visRect.width, visRect.height);
                            else
                                paintImmediately(visRect.x,    visRect.y,
                                                 visRect.width,visRect.height);
                        }
                    });
            } catch (Exception e) {
            }
        }
    }

    /**
     * Paints this component.
     */
    public void paintComponent(Graphics g) {
        super.paintComponent(g);

        Graphics2D g2d = (Graphics2D)g;

        Rectangle visRect = getRenderRect();
        g2d.setComposite(AlphaComposite.SrcOver);
        g2d.setPaint(getBackground());
        g2d.fillRect(visRect.x,     visRect.y,
                     visRect.width, visRect.height);

        if (image != null) {
            if (paintingTransform != null) {
                g2d.transform(paintingTransform);
            }
            g2d.drawRenderedImage(image, null);
            g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING,
                                 RenderingHints.VALUE_ANTIALIAS_OFF);
            Iterator it = overlays.iterator();
            while (it.hasNext()) {
                ((Overlay)it.next()).paint(g);
            }
        }
    }

    /**
     * Sets the painting transform. A null transform is the same as
     * an identity transform.
     * The next repaint will use the given transform.
     */
    public void setPaintingTransform(AffineTransform at) {
        paintingTransform = at;
        immediateRepaint();
    }

    /**
     * Returns the current painting transform.
     */
    public AffineTransform getPaintingTransform() {
        return paintingTransform;
    }

    /**
     * Sets the rendering transform.
     * Calling this method causes a rendering to be performed.
     */
    public void setRenderingTransform(AffineTransform at) {
        setRenderingTransform(at, true);
    }

    public void setRenderingTransform(AffineTransform at,
                                      boolean performRedraw) {
        renderingTransform = new AffineTransform(at);
        suspendInteractions = true;
        if (eventDispatcher != null) {
            try {
                eventDispatcher.setBaseTransform
                    (renderingTransform.createInverse());
            } catch (NoninvertibleTransformException e) {
                handleException(e);
            }
        }
        if (jgvtListeners != null) {
            Iterator iter = jgvtListeners.iterator();
            ComponentEvent ce = new ComponentEvent
                (this, JGVTComponentListener.COMPONENT_TRANSFORM_CHANGED);
            while (iter.hasNext()) {
                JGVTComponentListener l = (JGVTComponentListener)iter.next();
                l.componentTransformChanged(ce);
            }
        }

        if (performRedraw)
            scheduleGVTRendering();
    }

    /**
     * Returns the initial transform.
     */
    public AffineTransform getInitialTransform() {
        return new AffineTransform(initialTransform);
    }

    /**
     * Returns the current rendering transform.
     */
    public AffineTransform getRenderingTransform() {
        return new AffineTransform(renderingTransform);
    }

    /**
     * Sets whether this component should use double buffering to render
     * SVG documents. The change will be effective during the next
     * rendering.
     */
    public void setDoubleBufferedRendering(boolean b) {
        doubleBufferedRendering = b;
    }

    /**
     * Tells whether this component use double buffering to render
     * SVG documents.
     */
    public boolean getDoubleBufferedRendering() {
        return doubleBufferedRendering;
    }

    /**
     * Adds a GVTTreeRendererListener to this component.
     */
    public void addGVTTreeRendererListener(GVTTreeRendererListener l) {
        gvtTreeRendererListeners.add(l);
    }

    /**
     * Removes a GVTTreeRendererListener from this component.
     */
    public void removeGVTTreeRendererListener(GVTTreeRendererListener l) {
        gvtTreeRendererListeners.remove(l);
    }

    /**
     * Flush any cached image data (preliminary interface,
     * may be removed or modified in the future).
     */
    public void flush() {
        renderer.flush();
    }

    /**
     * Flush a rectangle of cached image data (preliminary interface,
     * may be removed or modified in the future).
     */
    public void flush(Rectangle r) {
        renderer.flush(r);
    }

    /**
     * Creates a new renderer.
     */
    protected ImageRenderer createImageRenderer() {
        return rendererFactory.createStaticImageRenderer();
    }

    /**
     * Renders the GVT tree.
     */
    protected void renderGVTTree() {
        Rectangle visRect = getRenderRect();
        if (gvtRoot == null || visRect.width <= 0 || visRect.height <= 0) {
            return;
        }

        // Renderer setup.
        if (renderer == null || renderer.getTree() != gvtRoot) {
            renderer = createImageRenderer();
            renderer.setTree(gvtRoot);
        }

        // Area of interest computation.
        AffineTransform inv;
        try {
            inv = renderingTransform.createInverse();
        } catch (NoninvertibleTransformException e) {
            throw new IllegalStateException( "NoninvertibleTransformEx:" + e.getMessage() );
        }
        Shape s = inv.createTransformedShape(visRect);

        // Rendering thread setup.
        gvtTreeRenderer = new GVTTreeRenderer(renderer, renderingTransform,
                                              doubleBufferedRendering, s,
                                              visRect.width, visRect.height);
        gvtTreeRenderer.setPriority(Thread.MIN_PRIORITY);

        Iterator it = gvtTreeRendererListeners.iterator();
        while (it.hasNext()) {
            gvtTreeRenderer.addGVTTreeRendererListener
                ((GVTTreeRendererListener)it.next());
        }

        // Disable the dispatch during the rendering
        // to avoid concurrent access to the GVT tree.
        if (eventDispatcher != null) {
            eventDispatcher.setEventDispatchEnabled(false);
        }

        gvtTreeRenderer.start();
    }

    /**
     * Computes the initial value of the transform used for rendering.
     * Return true if a repaint is required, otherwise false.
     */
    protected boolean computeRenderingTransform() {
        initialTransform = new AffineTransform();
        if (!initialTransform.equals(renderingTransform)) {
            setRenderingTransform(initialTransform, false);
            return true;
        }
        return false;
    }

    /**
     * Updates the value of the transform used for rendering.
     * Return true if a repaint is required, otherwise false.
     */
    protected boolean updateRenderingTransform() {
        // Do nothing.
        return false;
    }

    /**
     * Handles an exception.
     */
    protected void handleException(Exception e) {
        // Do nothing.
    }

    /**
     * Releases the references to the rendering resources,
     */
    protected void releaseRenderingReferences() {
        eventDispatcher = null;
        if (textSelectionManager != null) {
            overlays.remove(textSelectionManager.getSelectionOverlay());
            textSelectionManager = null;
        }
        renderer = null;
        image = null;
        gvtRoot = null;
    }

    /**
     * Schedules a new GVT rendering.
     */
    protected void scheduleGVTRendering() {
        if (gvtTreeRenderer != null) {
            needRender = true;
            gvtTreeRenderer.halt();
        } else {
            renderGVTTree();
        }
    }

    private void haltProgressivePaintThread() {
        if (progressivePaintThread != null) {
            progressivePaintThread.halt();
            progressivePaintThread = null;
        }
    }

    /**
     * Creates an instance of Listener.
     */
    protected Listener createListener() {
        return new Listener();
    }

    /**
     * To hide the listener methods.
     */
    protected class Listener
        implements GVTTreeRendererListener,
                   KeyListener,
                   MouseListener,
                   MouseMotionListener {
        boolean checkClick = false;
        boolean hadDrag = false;
        int startX, startY;
        long startTime, fakeClickTime;
        int MAX_DISP = 4*4;
        long CLICK_TIME = 200;

        /**
         * Creates a new Listener.
         */
        protected Listener() {
        }

        // GVTTreeRendererListener ///////////////////////////////////////////

        /**
         * Called when a rendering is in its preparing phase.
         */
        public void gvtRenderingPrepare(GVTTreeRendererEvent e) {
            suspendInteractions = true;
            if (!progressivePaint && !doubleBufferedRendering) {
                image = null;
            }
        }

        /**
         * Called when a rendering started.
         */
        public void gvtRenderingStarted(GVTTreeRendererEvent e) {
            if (progressivePaint && !doubleBufferedRendering) {
                image = e.getImage();
                progressivePaintThread = new HaltingThread() {
                    public void run() {
                        final Thread thisThread = this;
                        try {
                            while (!hasBeenHalted()) {
                                EventQueue.invokeLater(new Runnable() {
                                    public void run() {
                                        if (progressivePaintThread ==
                                            thisThread) {
                                            Rectangle vRect = getRenderRect();
                                            repaint(vRect.x,     vRect.y,
                                                    vRect.width, vRect.height);
                                        }
                                    }
                                });
                                sleep(200);
                            }
                        } catch (InterruptedException ie) {
                        } catch (ThreadDeath td) {
                            throw td;
                        } catch (Throwable t) {
                            t.printStackTrace();
                        }
                    }
                };
                progressivePaintThread.setPriority(Thread.MIN_PRIORITY + 1);
                progressivePaintThread.start();
            }
            if (!doubleBufferedRendering) {
                paintingTransform = null;
                suspendInteractions = false;
            }
        }

        /**
         * Called when a rendering was completed.
         */
        public void gvtRenderingCompleted(GVTTreeRendererEvent e) {
            haltProgressivePaintThread();

            if (doubleBufferedRendering) {
                paintingTransform = null;
                suspendInteractions = false;
            }

            gvtTreeRenderer = null;
            if (needRender) {
                renderGVTTree();
                needRender = false;
            } else {
                image = e.getImage();
                immediateRepaint();
            }
            if (eventDispatcher != null) {
                eventDispatcher.setEventDispatchEnabled(true);
            }
        }

        /**
         * Called when a rendering was cancelled.
         */
        public void gvtRenderingCancelled(GVTTreeRendererEvent e) {
            renderingStopped();
        }

        /**
         * Called when a rendering failed.
         */
        public void gvtRenderingFailed(GVTTreeRendererEvent e) {
            renderingStopped();
        }

        /**
         * The actual implementation of gvtRenderingCancelled() and
         * gvtRenderingFailed().
         */
        private void renderingStopped() {
            haltProgressivePaintThread();

            if (doubleBufferedRendering) {
                suspendInteractions = false;
            }

            gvtTreeRenderer = null;
            if (needRender) {
                renderGVTTree();
                needRender = false;
            } else {
                immediateRepaint();
            }

            if (eventDispatcher != null) {
                eventDispatcher.setEventDispatchEnabled(true);
            }
        }

        // KeyListener //////////////////////////////////////////////////////

        /**
         * Invoked when a key has been typed.
         * This event occurs when a key press is followed by a key release.
         */
        public void keyTyped(KeyEvent e) {
            selectInteractor(e);
            if (interactor != null) {
                interactor.keyTyped(e);
                deselectInteractor();
            } else if (eventDispatcher != null) {
                dispatchKeyTyped(e);
            }
        }

        /**
         * Dispatches the event to the GVT tree.
         */
        protected void dispatchKeyTyped(KeyEvent e) {
            eventDispatcher.keyTyped(e);
        }

        /**
         * Invoked when a key has been pressed.
         */
        public void keyPressed(KeyEvent e) {
            selectInteractor(e);
            if (interactor != null) {
                interactor.keyPressed(e);
                deselectInteractor();
            } else if (eventDispatcher != null) {
                dispatchKeyPressed(e);
            }
        }

        /**
         * Dispatches the event to the GVT tree.
         */
        protected void dispatchKeyPressed(KeyEvent e) {
            eventDispatcher.keyPressed(e);
        }

        /**
         * Invoked when a key has been released.
         */
        public void keyReleased(KeyEvent e) {
            selectInteractor(e);
            if (interactor != null) {
                interactor.keyReleased(e);
                deselectInteractor();
            } else if (eventDispatcher != null) {
                dispatchKeyReleased(e);
            }
        }

        /**
         * Dispatches the event to the GVT tree.
         */
        protected void dispatchKeyReleased(KeyEvent e) {
            eventDispatcher.keyReleased(e);
        }

        // MouseListener ////////////////////////////////////////////////////

        /**
         * Invoked when the mouse has been clicked on a component.
         */
        public void mouseClicked(MouseEvent e) {
            // Supress mouse click if we generated a
            // fake click with the same time stamp.
            if (fakeClickTime != e.getWhen())
                handleMouseClicked(e);
        }

        public void handleMouseClicked(MouseEvent e) {
            selectInteractor(e);
            if (interactor != null) {
                interactor.mouseClicked(e);
                deselectInteractor();
            } else if (eventDispatcher != null) {
                dispatchMouseClicked(e);
            }
        }

        /**
         * Dispatches the event to the GVT tree.
         */
        protected void dispatchMouseClicked(MouseEvent e) {
            eventDispatcher.mouseClicked(e);
        }

        /**
         * Invoked when a mouse button has been pressed on a component.
         */
        public void mousePressed(MouseEvent e) {
            startX = e.getX();
            startY = e.getY();
            startTime = e.getWhen();

            checkClick = true;

            selectInteractor(e);
            if (interactor != null) {
                interactor.mousePressed(e);
                deselectInteractor();
            } else if (eventDispatcher != null) {
                dispatchMousePressed(e);
            }
        }

        /**
         * Dispatches the event to the GVT tree.
         */
        protected void dispatchMousePressed(MouseEvent e) {
            eventDispatcher.mousePressed(e);
        }

        /**
         * Invoked when a mouse button has been released on a component.
         */
        public void mouseReleased(java.awt.event.MouseEvent e) {
            if ((checkClick) && hadDrag) {
                int dx = startX-e.getX();
                int dy = startY-e.getY();
                long cTime = e.getWhen();
                if ((dx*dx+dy*dy < MAX_DISP) &&
                    (cTime-startTime) < CLICK_TIME) {
                    // our drag was short! dispatch a CLICK event.
                    //
                    MouseEvent click = new MouseEvent
                        (e.getComponent(),
                         MouseEvent.MOUSE_CLICKED,
                         e.getWhen(),
                         e.getModifiers(),
                         e.getX(),
                         e.getY(),
                         e.getClickCount(),
                         e.isPopupTrigger());

                    fakeClickTime = click.getWhen();
                    handleMouseClicked(click);
                }
            }
            checkClick = false;
            hadDrag = false;

            selectInteractor(e);
            if (interactor != null) {
                interactor.mouseReleased(e);
                deselectInteractor();
            } else if (eventDispatcher != null) {
                dispatchMouseReleased(e);
            }
        }

        /**
         * Dispatches the event to the GVT tree.
         */
        protected void dispatchMouseReleased(MouseEvent e) {
            eventDispatcher.mouseReleased(e);
        }

        /**
         * Invoked when the mouse enters a component.
         */
        public void mouseEntered(MouseEvent e) {
            // requestFocus();  // This would grab focus every time mouse enters!
            selectInteractor(e);
            if (interactor != null) {
                interactor.mouseEntered(e);
                deselectInteractor();
            } else if (eventDispatcher != null) {
                dispatchMouseEntered(e);
            }
        }

        /**
         * Dispatches the event to the GVT tree.
         */
        protected void dispatchMouseEntered(MouseEvent e) {
            eventDispatcher.mouseEntered(e);
        }

        /**
         * Invoked when the mouse exits a component.
         */
        public void mouseExited(MouseEvent e) {
            selectInteractor(e);
            if (interactor != null) {
                interactor.mouseExited(e);
                deselectInteractor();
            } else if (eventDispatcher != null) {
                dispatchMouseExited(e);
            }
        }

        /**
         * Dispatches the event to the GVT tree.
         */
        protected void dispatchMouseExited(MouseEvent e) {
            eventDispatcher.mouseExited(e);
        }

        // MouseMotionListener //////////////////////////////////////////////

        /**
         * Invoked when a mouse button is pressed on a component and then
         * dragged.  Mouse drag events will continue to be delivered to
         * the component where the first originated until the mouse button is
         * released (regardless of whether the mouse position is within the
         * bounds of the component).
         */
        public void mouseDragged(MouseEvent e) {
            hadDrag = true;
            int dx = startX-e.getX();
            int dy = startY-e.getY();
            if (dx*dx+dy*dy > MAX_DISP)
                checkClick = false;

            selectInteractor(e);
            if (interactor != null) {
                interactor.mouseDragged(e);
                deselectInteractor();
            } else if (eventDispatcher != null) {
                dispatchMouseDragged(e);
            }
        }

        /**
         * Dispatches the event to the GVT tree.
         */
        protected void dispatchMouseDragged(MouseEvent e) {
            eventDispatcher.mouseDragged(e);
        }

        /**
         * Invoked when the mouse button has been moved on a component
         * (with no buttons no down).
         */
        public void mouseMoved(MouseEvent e) {
            selectInteractor(e);
            if (interactor != null) {
            	// because the mouseDragged event doesn't seem to be generated on OSX when ctrl is held down
            	if (Platform.isOSX &&
            		interactor instanceof AbstractZoomInteractor)
            		mouseDragged(e);
            	else
            		interactor.mouseMoved(e);
                deselectInteractor();
            } else if (eventDispatcher != null) {
                dispatchMouseMoved(e);
            }
        }

        /**
         * Dispatches the event to the GVT tree.
         */
        protected void dispatchMouseMoved(MouseEvent e) {
            eventDispatcher.mouseMoved(e);
        }

        /**
         * Selects an interactor, given an input event.
         */
        protected void selectInteractor(InputEvent ie) {
            if (!disableInteractions &&
                !suspendInteractions &&
                interactor == null &&
                gvtRoot != null) {
                Iterator it = interactors.iterator();
                while (it.hasNext()) {
                    Interactor i = (Interactor)it.next();
                    if (i.startInteraction(ie)) {
                        interactor = i;
                        break;
                    }
                }
            }
        }

        /**
         * Deselects an interactor, if the interaction has finished.
         */
        protected void deselectInteractor() {
            if (interactor.endInteraction()) {
                interactor = null;
            }
        }
    }

    protected class UnixTextSelectionListener
        extends SelectionAdapter {

        public void selectionDone(SelectionEvent evt) {
            if (!useUnixTextSelection) return;

            Object o = evt.getSelection();
            if (!(o instanceof CharacterIterator))
                return;
            CharacterIterator iter = (CharacterIterator) o;

            // first see if we can access the clipboard
            SecurityManager securityManager;
            securityManager = System.getSecurityManager();
            if (securityManager != null) {
                try {
                    securityManager.checkSystemClipboardAccess();
                } catch (SecurityException e) {
                    return; // Can't access clipboard.
                }
            }

            int sz = iter.getEndIndex()-iter.getBeginIndex();
            if (sz == 0) return;

            char[] cbuff = new char[sz];
            cbuff[0] = iter.first();
            for (int i=1; i<cbuff.length;++i) {
                cbuff[i] = iter.next();
            }
            final String strSel = new String(cbuff);
            // HACK: getSystemClipboard sometimes deadlocks on
            // linux when called from the AWT Thread. The Thread
            // creation prevents that.
            new Thread() {
                public void run() {
                    Clipboard cb;
                    cb = Toolkit.getDefaultToolkit().getSystemClipboard();
                    StringSelection sel;
                    sel = new StringSelection(strSel);
                    cb.setContents(sel, sel);
                }
            }.start();
        }
    }


}
