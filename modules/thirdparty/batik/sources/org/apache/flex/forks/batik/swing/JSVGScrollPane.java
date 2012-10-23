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

import java.awt.Component;
import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.Rectangle;

import java.awt.event.ComponentAdapter;
/*
import java.awt.event.MouseWheelEvent;
import java.awt.event.MouseWheelListener;
*/

import java.awt.geom.Rectangle2D;
import java.awt.geom.AffineTransform;

import java.awt.event.ComponentEvent;

import javax.swing.BoundedRangeModel;
import javax.swing.JScrollBar;
import javax.swing.Box;
import javax.swing.JPanel;

import javax.swing.event.ChangeListener;
import javax.swing.event.ChangeEvent;

import org.apache.flex.forks.batik.bridge.ViewBox;
import org.apache.flex.forks.batik.bridge.UpdateManagerListener;
import org.apache.flex.forks.batik.bridge.UpdateManagerEvent;
import org.apache.flex.forks.batik.dom.events.NodeEventTarget;

import org.apache.flex.forks.batik.gvt.GraphicsNode;

import org.apache.flex.forks.batik.swing.gvt.JGVTComponentListener;
import org.apache.flex.forks.batik.swing.gvt.GVTTreeRendererListener;
import org.apache.flex.forks.batik.swing.gvt.GVTTreeRendererEvent;
import org.apache.flex.forks.batik.swing.svg.SVGDocumentLoaderAdapter;
import org.apache.flex.forks.batik.swing.svg.SVGDocumentLoaderEvent;
import org.apache.flex.forks.batik.swing.svg.SVGDocumentLoaderListener;
import org.apache.flex.forks.batik.swing.svg.GVTTreeBuilderListener;
import org.apache.flex.forks.batik.swing.svg.GVTTreeBuilderEvent;

import org.apache.flex.forks.batik.util.SVGConstants;
import org.apache.flex.forks.batik.util.XMLConstants;

import org.w3c.dom.svg.SVGSVGElement;
import org.w3c.dom.svg.SVGDocument;

import org.w3c.dom.events.Event;
import org.w3c.dom.events.EventListener;


/**
 * A Swing component that consists of a JSVGCanvas with optional scroll
 * bars.
 * <p>
 *   Reimplementation, rather than imlementing the Scrollable interface,
 *   provides several advantages. The main advantage is the ability to
 *   control more precisely ScrollBar events; fewer JSVGCanvas updates
 *   are required when scrolling. This creates a significant performance
 *   (reflected by an increase in scroll speed) advantage compared to
 *   implementing the Scrollable interface.
 * </p>
 * @author Zach DelProposto
 * @version $Id: JSVGScrollPane.java 579882 2007-09-27 03:53:32Z cam $
 */
public class JSVGScrollPane extends JPanel
{
    protected JSVGCanvas canvas;

    protected JPanel horizontalPanel;
    protected JScrollBar vertical;
    protected JScrollBar horizontal;
    protected Component cornerBox;
    protected boolean scrollbarsAlwaysVisible = false;

    protected SBListener hsbListener;
    protected SBListener vsbListener;

    protected Rectangle2D viewBox = null; // SVG Root element viewbox
    protected boolean ignoreScrollChange = false;

    /**
     * Creates a JSVGScrollPane, which will scroll an JSVGCanvas.
     */
    public JSVGScrollPane(JSVGCanvas canvas) {
        super();

        this.canvas = canvas;
        canvas.setRecenterOnResize(false);

        // create components
        vertical   = new JScrollBar(JScrollBar.VERTICAL,   0, 0, 0, 0);
        horizontal = new JScrollBar(JScrollBar.HORIZONTAL, 0, 0, 0, 0);

        // create a spacer next to the horizontal bar
        horizontalPanel = new JPanel(new BorderLayout());
        horizontalPanel.add(horizontal, BorderLayout.CENTER);
        cornerBox = Box.createRigidArea
            (new Dimension(vertical.getPreferredSize().width,
                           horizontal.getPreferredSize().height));
        horizontalPanel.add(cornerBox, BorderLayout.EAST);

        // listeners
        hsbListener = createScrollBarListener(false);
        horizontal.getModel().addChangeListener(hsbListener);

        vsbListener = createScrollBarListener(true);
        vertical.getModel().addChangeListener(vsbListener);

        // by default, scrollbars are not needed
        updateScrollbarState(false, false);

        // addMouseWheelListener(new WheelListener());

        // layout
        setLayout(new BorderLayout());
        add(canvas, BorderLayout.CENTER);
        add(vertical, BorderLayout.EAST);
        add(horizontalPanel, BorderLayout.SOUTH);

        // inform of ZOOM events (to print sizes, such as in a status bar)
        canvas.addSVGDocumentLoaderListener(createLoadListener());

        // canvas listeners
        ScrollListener xlistener = createScrollListener();
        addComponentListener(xlistener);
        canvas.addGVTTreeRendererListener(xlistener);
        canvas.addJGVTComponentListener  (xlistener);
        canvas.addGVTTreeBuilderListener (xlistener);
        canvas.addUpdateManagerListener  (xlistener);
    }// JSVGScrollPane()

    public boolean getScrollbarsAlwaysVisible() {
        return scrollbarsAlwaysVisible;
    }

    public void setScrollbarsAlwaysVisible(boolean vis) {
        scrollbarsAlwaysVisible = vis;
        resizeScrollBars();
    }

    /**
     * Scrollbar listener factory method so subclasses can
     * override the default SBListener behaviour.
     */
    protected SBListener createScrollBarListener(boolean isVertical) {
        return new SBListener(isVertical);
    }

    /**
     * Factory method so subclasses can override the default listener behaviour
     */
    protected ScrollListener createScrollListener() {
        return new ScrollListener();
    }


    /**
     * Factory method so subclasses can override the default load listener.
     */
    protected SVGDocumentLoaderListener createLoadListener() {
        return new SVGScrollDocumentLoaderListener();
    }

    public JSVGCanvas getCanvas() {
        return canvas;
    }


    class SVGScrollDocumentLoaderListener extends SVGDocumentLoaderAdapter {
        public void documentLoadingCompleted(SVGDocumentLoaderEvent e) {
            NodeEventTarget root
                = (NodeEventTarget) e.getSVGDocument().getRootElement();
            root.addEventListenerNS
                (XMLConstants.XML_EVENTS_NAMESPACE_URI,
                 SVGConstants.SVG_SVGZOOM_EVENT_TYPE,
                 new EventListener() {
                     public void handleEvent(Event evt) {
                         if (!(evt.getTarget() instanceof SVGSVGElement))
                             return;
                         // assert(evt.getType() ==
                         //        SVGConstants.SVG_SVGZOOM_EVENT_TYPE);
                         SVGSVGElement svg = (SVGSVGElement) evt.getTarget();
                         scaleChange(svg.getCurrentScale());
                     } // handleEvent()
                 }, false, null);
        }// documentLoadingCompleted()
    }


    /**
     *        Resets this object (for reloads),
     *        releasing any cached data and recomputing
     *        scroll extents.
     */
    public void reset() {
        viewBox = null;
        updateScrollbarState(false, false);
        revalidate();
    }// reset()


    /**
     *        Sets the translation portion of the transform based upon the
     *        current scroll bar position
     */
    protected void setScrollPosition() {
        checkAndSetViewBoxRect();
        if (viewBox == null) return;

        AffineTransform crt = canvas.getRenderingTransform();
        AffineTransform vbt = canvas.getViewBoxTransform();
        if (crt == null) crt = new AffineTransform();
        if (vbt == null) vbt = new AffineTransform();

        Rectangle r2d = vbt.createTransformedShape(viewBox).getBounds();
        // System.err.println("Pre : " + r2d);
        int tx = 0, ty = 0;
        if (r2d.x < 0) tx -= r2d.x;
        if (r2d.y < 0) ty -= r2d.y;

        int deltaX = horizontal.getValue()-tx;
        int deltaY = vertical.getValue()  -ty;

        // System.err.println("tx = "+tx+"; ty = "+ty);
        // System.err.println("dx = "+deltaX+"; dy = "+deltaY);
        // System.err.println("Pre CRT: " + crt);

        crt.preConcatenate
            (AffineTransform.getTranslateInstance(-deltaX, -deltaY));
        canvas.setRenderingTransform(crt);
    }// setScrollPosition()



    /**
     * MouseWheel listener.
     * <p>
     * Provides mouse wheel support. The mouse wheel will scroll the currently
     * displayed scroll bar, if only one is displayed. If two scrollbars are
     * displayed, the mouse wheel will only scroll the vertical scrollbar.
     *
     * This is commented out because it requires JDK 1.4 and currently
     * Batik targets JDK 1.3.
     *
     * TODO Move this to a JDK 1.4 specific class in sources-1.4.
     */
    /*
    protected class WheelListener implements MouseWheelListener
    {
        public void mouseWheelMoved(MouseWheelEvent e)
        {
            final JScrollBar sb = (vertical.isVisible()) ?
                vertical : horizontal;        // vertical is preferred

            if(e.getScrollType() == MouseWheelEvent.WHEEL_UNIT_SCROLL) {
                final int amt = e.getUnitsToScroll() * sb.getUnitIncrement();
                sb.setValue(sb.getValue() + amt);
            } else if(e.getScrollType() == MouseWheelEvent.WHEEL_BLOCK_SCROLL){
                final int amt = e.getWheelRotation() * sb.getBlockIncrement();
                sb.setValue(sb.getValue() + amt);
            }

        }// mouseWheelMoved()
    }// inner class WheelListener
    */


    /**
     * Advanced JScrollBar listener.
     * <p>
     *   <b>A separate listener must be attached to each scrollbar,
     *     since we keep track of mouse state for each scrollbar
     *     separately!</b>
     * </p>
     * <p>
     *   This coalesces drag events so we don't track them, and
     *   'passes through' click events. It doesn't coalesce as many
     *   events as it should, but it helps considerably.
     * </p>
     */
    protected class SBListener implements ChangeListener
    {
        // 'true' if we are in a drag (versus a click)
        protected boolean inDrag = false;
        protected int startValue;

        protected boolean isVertical;

        public SBListener(boolean vertical)
        {
            isVertical = vertical;
        }// SBListener()

        public synchronized void stateChanged(ChangeEvent e)
        {
            // only respond to changes if we are NOT being dragged
            // and ignoreScrollChange is not set
            if(ignoreScrollChange) return;

            Object src = e.getSource();
            if (!(src instanceof BoundedRangeModel))
                return;

            int val = ((isVertical)?vertical.getValue():
                       horizontal.getValue());

            BoundedRangeModel brm = (BoundedRangeModel)src;
            if (brm.getValueIsAdjusting()) {
                if (!inDrag) {
                    inDrag = true;
                    startValue = val;
                } else {
                    AffineTransform at;
                    if (isVertical) {
                        at = AffineTransform.getTranslateInstance
                            (0, startValue-val);
                    } else {
                        at = AffineTransform.getTranslateInstance
                            (startValue-val, 0);
                    }
                    canvas.setPaintingTransform(at);
                }
            } else {
                if (inDrag) {
                    inDrag = false;
                    if (val == startValue) {
                        canvas.setPaintingTransform(new AffineTransform());
                        return;
                    }
                }
                setScrollPosition();
            }
        }// stateChanged()
    }// inner class SBListener


    /** Handle scroll, zoom, and resize events */
    protected class ScrollListener extends ComponentAdapter
        implements JGVTComponentListener, GVTTreeBuilderListener,
                   GVTTreeRendererListener, UpdateManagerListener
    {
        protected boolean isReady = false;

        public void componentTransformChanged(ComponentEvent evt)
        {
            if(isReady)
                resizeScrollBars();
        }// componentTransformChanged()


        public void componentResized(ComponentEvent evt)
        {
            if(isReady)
                resizeScrollBars();
        }// componentResized()


        public void gvtBuildStarted  (GVTTreeBuilderEvent e) {
            isReady = false;
            // Start by assuming we won't need them.
            updateScrollbarState(false, false);
        }
        public void gvtBuildCompleted(GVTTreeBuilderEvent e)
        {
            isReady = true;
            viewBox = null;   // new document forget old viewBox if any.
        }// gvtRenderingCompleted()

        public void gvtRenderingCompleted(GVTTreeRendererEvent e) {
            if (viewBox == null) {
                resizeScrollBars();
                return;
            }

            Rectangle2D newview = getViewBoxRect();
            if ((newview.getX() != viewBox.getX()) ||
                (newview.getY() != viewBox.getY()) ||
                (newview.getWidth() != viewBox.getWidth()) ||
                (newview.getHeight() != viewBox.getHeight())) {
                viewBox = newview;
                resizeScrollBars();
            }
        }

        public void updateCompleted(UpdateManagerEvent e) {
            if (viewBox == null) {
                resizeScrollBars();
                return;
            }

            Rectangle2D newview = getViewBoxRect();
            if ((newview.getX() != viewBox.getX()) ||
                (newview.getY() != viewBox.getY()) ||
                (newview.getWidth() != viewBox.getWidth()) ||
                (newview.getHeight() != viewBox.getHeight())) {
                viewBox = newview;
                resizeScrollBars();
            }
        }


        public void gvtBuildCancelled(GVTTreeBuilderEvent e) { }
        public void gvtBuildFailed   (GVTTreeBuilderEvent e) { }

        public void gvtRenderingPrepare  (GVTTreeRendererEvent e) { }
        public void gvtRenderingStarted  (GVTTreeRendererEvent e) { }
        public void gvtRenderingCancelled(GVTTreeRendererEvent e) { }
        public void gvtRenderingFailed   (GVTTreeRendererEvent e) { }

        public void managerStarted  (UpdateManagerEvent e) { }
        public void managerSuspended(UpdateManagerEvent e) { }
        public void managerResumed  (UpdateManagerEvent e) { }
        public void managerStopped  (UpdateManagerEvent e) { }
        public void updateStarted   (UpdateManagerEvent e) { }
        public void updateFailed    (UpdateManagerEvent e) { }

    }// inner class ScrollListener


    /**
     *        Compute the scrollbar extents, and determine if
     *        scrollbars should be visible.
     *
     */
    protected void resizeScrollBars()
    {
        // System.out.println("** resizeScrollBars()");

        ignoreScrollChange = true;

        checkAndSetViewBoxRect();
        if (viewBox == null) return;

        AffineTransform vbt = canvas.getViewBoxTransform();
        if (vbt == null) vbt = new AffineTransform();

        Rectangle r2d = vbt.createTransformedShape(viewBox).getBounds();
        // System.err.println("VB: " + r2d);

        // compute translation
        int maxW = r2d.width;
        int maxH = r2d.height;
        int tx = 0, ty = 0;
        if (r2d.x > 0) maxW += r2d.x;
        else           tx   -= r2d.x;
        if (r2d.y > 0) maxH += r2d.y;
        else           ty   -= r2d.y;

        // System.err.println("   maxW = "+maxW+"; maxH = "+maxH +
        //                    " tx = "+tx+"; ty = "+ty);

        // Changing scrollbar visibility may change the
        // canvas's dimensions so get the end result.
        Dimension vpSize = updateScrollbarVisibility(tx, ty, maxW, maxH);

        // set scroll params
        vertical.  setValues(ty, vpSize.height, 0, maxH);
        horizontal.setValues(tx, vpSize.width,  0, maxW);

        // set block scroll; this should be equal to a full 'page',
        // minus a small amount to keep a portion in view
        // that small amount is 10%.
        vertical.  setBlockIncrement( (int) (0.9f * vpSize.height) );
        horizontal.setBlockIncrement( (int) (0.9f * vpSize.width) );

        // set unit scroll. This is arbitrary, but we define
        // it to be 20% of the current viewport.
        vertical.  setUnitIncrement( (int) (0.2f * vpSize.height) );
        horizontal.setUnitIncrement( (int) (0.2f * vpSize.width) );

        doLayout();
        horizontalPanel.doLayout();
        horizontal.doLayout();
        vertical.doLayout();

        ignoreScrollChange = false;
        //System.out.println("  -- end resizeScrollBars()");
    }// resizeScrollBars()

    protected Dimension updateScrollbarVisibility(int tx, int ty,
                                                  int maxW, int maxH) {
        // display scrollbars, if appropriate
        // (if scaled document size is larger than viewport size)
        // The tricky bit is ensuring that you properly track
        // the effects of making one scroll bar visible on the
        // need for the other scroll bar.

        Dimension vpSize = canvas.getSize();
        // maxVPW/H is the viewport W/H without scrollbars.
        // minVPW/H is the viewport W/H with scrollbars.
        int maxVPW = vpSize.width;  int minVPW = vpSize.width;
        int maxVPH = vpSize.height; int minVPH = vpSize.height;

        if (vertical.isVisible()) {
            maxVPW += vertical.getPreferredSize().width;
        } else {
            minVPW -= vertical.getPreferredSize().width;
        }
        if (horizontalPanel.isVisible()) {
            maxVPH += horizontal.getPreferredSize().height;
        } else {
            minVPH -= horizontal.getPreferredSize().height;
        }

        // System.err.println("W: [" + minVPW + "," + maxVPW + "] " +
        //                    "H: [" + minVPH + "," + maxVPH + "]");
        // System.err.println("MAX: [" + maxW + "," + maxH + "]");

        // Fist check if we need either scrollbar (given maxVPW/H).
        boolean hNeeded, vNeeded;
        Dimension ret = new Dimension();

        if (scrollbarsAlwaysVisible) {
            hNeeded = (maxW > minVPW);
            vNeeded = (maxH > minVPH);
            ret.width  = minVPW;
            ret.height = minVPH;
        } else {
            hNeeded = (maxW > maxVPW) || (tx != 0);
            vNeeded = (maxH > maxVPH) || (ty != 0);
            // System.err.println("Vis flags: " + hNeeded +", " + vNeeded);

            // This makes sure that if one scrollbar is visible
            // we 'recheck' the other scroll bar with the minVPW/H
            // since making one visible makes the room for displaying content
            // in the other dimension smaller. (This also makes the
            // 'corner box' visible if both scroll bars are visible).
            if      (vNeeded && !hNeeded) hNeeded = (maxW > minVPW);
            else if (hNeeded && !vNeeded) vNeeded = (maxH > minVPH);

            ret.width  = (hNeeded)?minVPW:maxVPW;
            ret.height = (vNeeded)?minVPH:maxVPH;
        }

        updateScrollbarState(hNeeded, vNeeded);

        //  Return the new size of the canvas.
        return ret;
    }

    protected void updateScrollbarState(boolean hNeeded, boolean vNeeded) {
        horizontal.setEnabled(hNeeded);
        vertical  .setEnabled(vNeeded);

        if (scrollbarsAlwaysVisible) {
            horizontalPanel.setVisible(true);
            vertical       .setVisible(true);
            cornerBox      .setVisible(true);
        } else {
            horizontalPanel.setVisible(hNeeded);
            vertical       .setVisible(vNeeded);
            cornerBox      .setVisible(hNeeded&&vNeeded);
        }
    }

    /**
     *        Derives the SVG Viewbox from the SVG root element.
     *        Caches it. Assumes that it will not change.
     *
     */
    protected void checkAndSetViewBoxRect() {
        if (viewBox != null) return;

        viewBox = getViewBoxRect();
        // System.out.println("  ** viewBox rect set: "+viewBox);
        // System.out.println("  ** doc size: "+
        //                    canvas.getSVGDocumentSize());
    }// checkAndSetViewBoxRect()


    protected Rectangle2D getViewBoxRect() {
        SVGDocument doc = canvas.getSVGDocument();
        if (doc == null) return null;
        SVGSVGElement el = doc.getRootElement();
        if (el == null) return null;

        String viewBoxStr = el.getAttributeNS
            (null, SVGConstants.SVG_VIEW_BOX_ATTRIBUTE);
        if (viewBoxStr.length() != 0) {
            float[] rect = ViewBox.parseViewBoxAttribute(el, viewBoxStr, null);
            return new Rectangle2D.Float(rect[0], rect[1],
                                         rect[2], rect[3]);
        }
        GraphicsNode gn = canvas.getGraphicsNode();
        if (gn == null) return null;

        Rectangle2D bounds = gn.getBounds();
        if (bounds == null) return null;

        return (Rectangle2D) bounds.clone();
    }

    /**
     * Called when the scale size changes. The scale factor
     * (1.0 == original size). By default, this method does
     * nothing, but may be overidden to display a scale
     * (zoom) factor in a status bar, for example.
     */
    public void scaleChange(float scale) {
        // do nothing
    }
}// class JSVGScrollPane
