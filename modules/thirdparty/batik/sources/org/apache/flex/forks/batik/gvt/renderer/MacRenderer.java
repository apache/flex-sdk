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
package org.apache.flex.forks.batik.gvt.renderer;

import java.awt.AlphaComposite;
import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.Rectangle;
import java.awt.RenderingHints;
import java.awt.Shape;
import java.awt.geom.AffineTransform;
import java.awt.image.BufferedImage;
import java.util.Collection;
import java.util.Iterator;

import org.apache.flex.forks.batik.ext.awt.geom.RectListManager;
import org.apache.flex.forks.batik.ext.awt.image.GraphicsUtil;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.util.HaltingThread;

/**
 * Simple implementation of the Renderer that supports dynamic updates.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: MacRenderer.java 504819 2007-02-08 08:23:19Z dvholten $
 */
public class MacRenderer implements ImageRenderer {

    static final int COPY_OVERHEAD      = 1000;
    static final int COPY_LINE_OVERHEAD = 10;
    static final AffineTransform IDENTITY = new AffineTransform();

    protected RenderingHints renderingHints;
    protected AffineTransform usr2dev;

    protected GraphicsNode rootGN;

    protected int offScreenWidth;
    protected int offScreenHeight;
    protected boolean isDoubleBuffered;
    protected BufferedImage currImg;
    protected BufferedImage workImg;
    protected RectListManager damagedAreas;

    public static int IMAGE_TYPE = BufferedImage.TYPE_INT_ARGB_PRE;
    public static Color TRANSPARENT_WHITE = new Color(255, 255, 255, 0);

    protected static RenderingHints defaultRenderingHints;
    static {
        defaultRenderingHints = new RenderingHints(null);
        defaultRenderingHints.put(RenderingHints.KEY_ANTIALIASING,
                                  RenderingHints.VALUE_ANTIALIAS_ON);

        defaultRenderingHints.put(RenderingHints.KEY_INTERPOLATION,
                                  RenderingHints.VALUE_INTERPOLATION_BILINEAR);
    }

    /**
     * Constructs a new dynamic renderer with the specified buffer image.
     */
    public MacRenderer() {
        renderingHints = new RenderingHints(null);
        renderingHints.add(defaultRenderingHints);
        usr2dev = new AffineTransform();
    }

    public MacRenderer(RenderingHints rh,
                       AffineTransform at){
        renderingHints = new RenderingHints(null);
        renderingHints.add(rh);
        if (at == null) at = new AffineTransform();
        else            at = new AffineTransform(at);
    }

    public void dispose() {
        rootGN  = null;
        currImg = null;
        workImg = null;
        renderingHints = null;
        usr2dev = null;
        if ( damagedAreas != null ){
            damagedAreas.clear();
        }
        damagedAreas = null;
    }
    /**
     * This associates the given GVT Tree with this renderer.
     * Any previous tree association is forgotten.
     * Not certain if this should be just GraphicsNode, or CanvasGraphicsNode.
     */
    public void setTree(GraphicsNode treeRoot) {
        rootGN = treeRoot;
    }

    /**
     * Returns the GVT tree associated with this renderer
     */
    public GraphicsNode getTree() {
        return rootGN;
    }

    /**
     * Sets the transform from the current user space (as defined by
     * the top node of the GVT tree, to the associated device space.
     */
    public void setTransform(AffineTransform usr2dev) {
        if(usr2dev == null)
            this.usr2dev = new AffineTransform();
        else
            this.usr2dev = new AffineTransform(usr2dev);
        if (workImg == null) return;
        synchronized (workImg) {
            Graphics2D g2d = workImg.createGraphics();
            g2d.setComposite(AlphaComposite.Clear);
            g2d.fillRect(0, 0, workImg.getWidth(), workImg.getHeight());
            g2d.dispose();
        }
        damagedAreas = null;
    }

    /**
     * Returns the transform from the current user space (as defined
     * by the top node of the GVT tree) to the device space.
     */
    public AffineTransform getTransform() {
        return usr2dev;
    }

    /**
     * @param rh Set of rendering hints to use for future renderings
     */
    public void setRenderingHints(RenderingHints rh) {
        this.renderingHints = new RenderingHints(null);
        this.renderingHints.add(rh);
        damagedAreas = null;
    }

    /**
     * @return the RenderingHints which the Renderer is using for its
     *         rendering
     */
    public RenderingHints getRenderingHints() {
        return renderingHints;
    }

    /**
     * Returns true if the Renderer is currently doubleBuffering is
     * rendering requests.  If it is then getOffscreen will only
     * return completed renderings (or null if nothing is available).
     */
    public boolean isDoubleBuffered(){
        return isDoubleBuffered;
    }

    /**
     * Turns on/off double buffering in renderer.  Turning off
     * double buffering makes it possible to see the ongoing results
     * of a render operation.
     *
     * @param isDoubleBuffered the new value for double buffering
     */
    public void setDoubleBuffered(boolean isDoubleBuffered){
        if (this.isDoubleBuffered == isDoubleBuffered)
            return;

        this.isDoubleBuffered = isDoubleBuffered;
        if (isDoubleBuffered) {
            workImg = null;  // start double buffer, split buffers
        } else {
            // No longer double buffering so delete second offscreen
            workImg = currImg;
            damagedAreas = null;
        }
    }

    /**
     * Update the size of the image to be returned by getOffScreen.
     * Note that this change will not be reflected by calls to
     * getOffscreen until either clearOffScreen has completed (when
     * isDoubleBuffered is false) or reapint has completed (when
     * isDoubleBuffered is true).
     *
     */
    public void updateOffScreen(int width, int height) {
        offScreenWidth  = width;
        offScreenHeight = height;
    }

    /**
     * Returns the current offscreen image.
     *
     * The exact symantics of this vary base on the value of
     * isDoubleBuffered.  If isDoubleBuffered is false this will
     * return the image currently being worked on as soon as it is
     * available.
     *
     * if isDoubleBuffered is false this will return the most recently
     * completed result of repaint.
     */
    public BufferedImage getOffScreen() {
        if (rootGN == null)
            return null;

        return currImg;
    }

    /**
     * Sets up and clears the current offscreen buffer.
     *
     * When not double buffering one should call this method before
     * calling getOffscreen to get the offscreen being drawn into.
     * This ensures the buffer is up to date and doesn't contain junk.
     *
     * When double buffering this call can effectively be skipped,
     * since getOffscreen will only refect the new rendering after
     * repaint completes.
     */
    public void clearOffScreen() {
        // No need to clear in double buffer case people will
        // only see it when it is done...
        if (isDoubleBuffered)
            return;

        updateWorkingBuffers();
        if (workImg == null) return;

        synchronized (workImg) {
            Graphics2D g2d = workImg.createGraphics();
            g2d.setComposite(AlphaComposite.Clear);
            g2d.fillRect(0, 0, workImg.getWidth(), workImg.getHeight());
            g2d.dispose();
        }
        damagedAreas = null;
    }

    public void flush() {
        // Since we don't cache we don't need to flush
    }
    public void flush(Rectangle r) {
        // Since we don't cache we don't need to flush
    }

    /**
     * Flush a list of rectangles of cached image data.
     */
    public void flush(Collection areas) {
        // Since we don't cache we don't need to flush
    }

    protected void updateWorkingBuffers() {
        if (rootGN == null) {
            currImg = null;
            workImg = null;
            return;
        }

        int         w  = offScreenWidth;
        int         h  = offScreenHeight;
        if ((workImg == null)         ||
            (workImg.getWidth()  < w) ||
            (workImg.getHeight() < h)) {
            workImg = new BufferedImage(w, h, IMAGE_TYPE);
            // workImg = new BI(w, h, IMAGE_TYPE);
        }

        if (!isDoubleBuffered) {
            currImg = workImg;
        }
    }

    public void repaint(Shape area) {
        if (area == null) return;
        RectListManager rlm = new RectListManager();
        rlm.add(usr2dev.createTransformedShape(area).getBounds());
        repaint(rlm);
    }

    /**
     * Repaints the associated GVT tree under the list of <tt>areas</tt>.
     *
     * If double buffered is true and this method completes cleanly it
     * will set the result of the repaint as the image returned by
     * getOffscreen otherwise the old image will still be returned.
     * If double buffered is false it is possible some effects of
     * the failed rendering will be visible in the image returned
     * by getOffscreen.
     *
     * @param devRLM regions to be repainted, in the current
     * user space coordinate system.
     */
    // long lastFrame = -1;
    public void repaint(RectListManager devRLM) {
        if (devRLM == null)
            return;

        updateWorkingBuffers();
        if ((rootGN == null) || (workImg == null))
            return;

        try {
        // Ensure only one thread works on WorkImg at a time...
        synchronized (workImg) {
            Graphics2D g2d = GraphicsUtil.createGraphics
                (workImg, renderingHints);

            Rectangle dr;
            dr = new Rectangle(0, 0, offScreenWidth, offScreenHeight);

            if ((isDoubleBuffered) &&
                (currImg != null) &&
                (damagedAreas  != null)) {

                damagedAreas.subtract(devRLM, COPY_OVERHEAD,
                                      COPY_LINE_OVERHEAD);

                damagedAreas.mergeRects(COPY_OVERHEAD,
                                        COPY_LINE_OVERHEAD);

                Iterator iter = damagedAreas.iterator();
                g2d.setComposite(AlphaComposite.Src);
                while (iter.hasNext()) {
                    Rectangle r = (Rectangle)iter.next();
                    if (!dr.intersects(r)) continue;
                    r = dr.intersection(r);
                    g2d.setClip     (r.x, r.y, r.width, r.height);
                    g2d.setComposite(AlphaComposite.Clear);
                    g2d.fillRect    (r.x, r.y, r.width, r.height);
                    g2d.setComposite(AlphaComposite.SrcOver);
                    g2d.drawImage   (currImg, 0, 0, null);
                }
            }


            Iterator iter = devRLM.iterator();
            while (iter.hasNext()) {
                Rectangle r = (Rectangle)iter.next();
                if (!dr.intersects(r)) continue;
                r = dr.intersection(r);
                g2d.setTransform(IDENTITY);
                g2d.setClip(r.x, r.y, r.width, r.height);
                g2d.setComposite(AlphaComposite.Clear);
                g2d.fillRect(r.x, r.y, r.width, r.height);
                g2d.setComposite(AlphaComposite.SrcOver);
                g2d.transform(usr2dev);
                rootGN.paint(g2d);
            }
            g2d.dispose();
        }
        } catch (Throwable t) { t.printStackTrace(); }
        if (HaltingThread.hasBeenHalted())
            return;

        // System.out.println("Dmg: "   + damagedAreas);
        // System.out.println("Areas: " + devRects);

        // Swap the buffers if the rendering completed cleanly.
        if (isDoubleBuffered) {
            BufferedImage tmpImg = workImg;
            workImg = currImg;
            currImg = tmpImg;
            damagedAreas = devRLM;
        }
    }
}
