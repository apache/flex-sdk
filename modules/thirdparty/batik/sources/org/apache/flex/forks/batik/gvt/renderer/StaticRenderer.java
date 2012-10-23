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
import java.awt.Graphics2D;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.RenderingHints;
import java.awt.Shape;
import java.awt.geom.AffineTransform;
import java.awt.image.BufferedImage;
import java.awt.image.ColorModel;
import java.awt.image.Raster;
import java.awt.image.RenderedImage;
import java.awt.image.SampleModel;
import java.awt.image.WritableRaster;
import java.awt.image.renderable.RenderContext;
import java.lang.ref.SoftReference;
import java.util.Collection;
import java.util.Iterator;

import org.apache.flex.forks.batik.ext.awt.geom.RectListManager;
import org.apache.flex.forks.batik.ext.awt.image.GraphicsUtil;
import org.apache.flex.forks.batik.ext.awt.image.PadMode;
import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.ext.awt.image.rendered.CachableRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.PadRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.TileCacheRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.TranslateRed;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.util.HaltingThread;

/**
 * Simple implementation of the Renderer that simply does static
 * rendering in an offscreen buffer image.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: StaticRenderer.java 504819 2007-02-08 08:23:19Z dvholten $
 */
public class StaticRenderer implements ImageRenderer {

    /**
     * Tree this Renderer paints.
     */
    protected GraphicsNode      rootGN;
    protected Filter            rootFilter;
    protected CachableRed       rootCR;
    protected SoftReference     lastCR;
    protected SoftReference     lastCache;

    /**
     * Flag for double buffering.
     */
    protected boolean isDoubleBuffered = false;

    /**
     * Offscreen image where the Renderer does its rendering
     */
    protected WritableRaster currentBaseRaster;
    protected WritableRaster currentRaster;
    protected BufferedImage  currentOffScreen;

    protected WritableRaster workingBaseRaster;
    protected WritableRaster workingRaster;
    protected BufferedImage  workingOffScreen;

    protected int offScreenWidth;
    protected int offScreenHeight;

    /**
     * Passed to the GVT tree to describe the rendering environment
     */
    protected RenderingHints renderingHints;
    protected AffineTransform usr2dev;

    protected static RenderingHints defaultRenderingHints;
    static {
        defaultRenderingHints = new RenderingHints(null);
        defaultRenderingHints.put(RenderingHints.KEY_ANTIALIASING,
                                  RenderingHints.VALUE_ANTIALIAS_ON);

        defaultRenderingHints.put(RenderingHints.KEY_INTERPOLATION,
                                  RenderingHints.VALUE_INTERPOLATION_BILINEAR);
    }

    /**
     * @param rh Hints for rendering.
     * @param at Starting user to device coordinate system transform.
     */
    public StaticRenderer(RenderingHints rh,
                          AffineTransform at){
        renderingHints = new RenderingHints(null);
        renderingHints.add(rh);
        usr2dev = new AffineTransform(at);
    }

    /**
     * Creates a new StaticRenderer object.
     */
    public StaticRenderer(){
        renderingHints = new RenderingHints(null);
        renderingHints.add(defaultRenderingHints);
        usr2dev = new AffineTransform();
    }


    /**
     * Disposes all resources of this renderer.
     */
    public void dispose() {
        rootGN     = null;
        rootFilter = null;
        rootCR     = null;

        workingOffScreen = null;
        workingBaseRaster = null;
        workingRaster = null;

        currentOffScreen = null;
        currentBaseRaster = null;
        currentRaster = null;

        renderingHints = null;
        lastCache = null;
        lastCR = null;
    }

    /**
     * This associates the given GVT Tree with this renderer.
     * Any previous tree association is forgotten.
     * Not certain if this should be just GraphicsNode, or CanvasGraphicsNode.
     */
    public void setTree(GraphicsNode rootGN){
        this.rootGN = rootGN;
        rootFilter  = null;
        rootCR      = null;

        workingOffScreen = null;
        workingRaster = null;

        currentOffScreen = null;
        currentRaster = null;

        // renderingHints = new RenderingHints(defaultRenderingHints);
    }

    /**
     * @return the GVT tree associated with this renderer
     */
    public GraphicsNode getTree(){
        return rootGN;
    }

    /**
     * @param rh Set of rendering hints to use for future renderings
     */
    public void setRenderingHints(RenderingHints rh) {
        renderingHints = new RenderingHints(null);
        renderingHints.add(rh);

        rootFilter = null;
        rootCR     = null;

        workingOffScreen = null;
        workingRaster = null;

        currentOffScreen = null;
        currentRaster = null;
    }

    /**
     * @return the RenderingHints which the Renderer is using for its
     *         rendering
     */
    public RenderingHints getRenderingHints() {
        return renderingHints;
    }

    /**
     * Sets the transform from the current user space (as defined by
     * the top node of the GVT tree, to the associated device space.
     *
     * @param usr2dev the new user space to device space transform. If null,
     *        the identity transform will be set.
     */
    public void setTransform(AffineTransform usr2dev){
        if (this.usr2dev.equals(usr2dev))
            return;

        if(usr2dev == null)
            this.usr2dev = new AffineTransform();
        else
            this.usr2dev = new AffineTransform(usr2dev);

        rootCR = null;
    }

    /**
     * Returns the transform from the current user space (as defined
     * by the top node of the GVT tree) to the device space.
     */
    public AffineTransform getTransform(){
        return usr2dev;
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
            // Now double buffering, so make sure they can't see work buffers.
            currentOffScreen  = null;
            currentBaseRaster = null;
            currentRaster     = null;
        } else {
            // No longer double buffering so join work and current buffers.
            currentOffScreen  = workingOffScreen;
            currentBaseRaster = workingBaseRaster;
            currentRaster     = workingRaster;
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

        return currentOffScreen;
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
        if ((rootCR == null)           ||
            (workingBaseRaster == null))
            return;

        ColorModel     cm         = rootCR.getColorModel();
        WritableRaster syncRaster = workingBaseRaster;

        // Ensure only one thread works on baseRaster at a time...
        synchronized (syncRaster) {
            BufferedImage bi = new BufferedImage
                (cm, workingBaseRaster, cm.isAlphaPremultiplied(), null);
            Graphics2D g2d = bi.createGraphics();
            g2d.setComposite(AlphaComposite.Clear);
            g2d.fillRect(0, 0, bi.getWidth(), bi.getHeight());
            g2d.dispose();
        }
    }


    /**
     * Repaints the associated GVT tree under <tt>area</tt>.
     *
     * If double buffered is true and this method completes cleanly it
     * will set the result of the repaint as the image returned by
     * getOffscreen otherwise the old image will still be returned.
     * If double buffered is false it is possible some effects of
     * the failed rendering will be visible in the image returned
     * by getOffscreen.
     *
     * @param area region to be repainted, in the current user space
     * coordinate system.
     */
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
     * @param areas a List of regions to be repainted, in the current
     * user space coordinate system.
     */
    public void repaint(RectListManager areas) {

        if (areas == null)
            return;

        // System.out.println("Renderer Repainting");

        // long t0 = System.currentTimeMillis();

        CachableRed cr;
        WritableRaster syncRaster;
        WritableRaster copyRaster;

        // While we are synchronized pull all the relavent info out
        // of member variables into local variables.
        updateWorkingBuffers();
        if ((rootCR == null)           ||
            (workingBaseRaster == null))
            return;

        cr = rootCR;
        syncRaster = workingBaseRaster;
        copyRaster = workingRaster;

        Rectangle srcR = rootCR.getBounds();
        Rectangle dstR = workingRaster.getBounds();
        if ((dstR.x < srcR.x) ||
            (dstR.y < srcR.y) ||
            (dstR.x+dstR.width  > srcR.x+srcR.width) ||
            (dstR.y+dstR.height > srcR.y+srcR.height))
            cr = new PadRed(cr, dstR, PadMode.ZERO_PAD, null);

        // Ensure only one thread works on baseRaster at a time...
        synchronized (syncRaster) {
            cr.copyData(copyRaster);
        }

        if (!HaltingThread.hasBeenHalted()) {
            // Swap the buffers if the rendering completed cleanly.
            BufferedImage tmpBI = workingOffScreen;

            workingBaseRaster = currentBaseRaster;
            workingRaster     = currentRaster;
            workingOffScreen  = currentOffScreen;

            currentRaster     = copyRaster;
            currentBaseRaster = syncRaster;
            currentOffScreen  = tmpBI;

            // System.out.println("Current offscreen : " + currentOffScreen);
        }
    }

    /**
     * Flush any cached image data.
     */
    public void flush() {
        if (lastCache == null) return;
        Object o = lastCache.get();
        if (o == null) return;

        TileCacheRed tcr = (TileCacheRed)o;
        tcr.flushCache(tcr.getBounds());
    }

    /**
     * Flush a list of rectangles of cached image data.
     */
    public void flush(Collection areas) {
        AffineTransform at = getTransform();
        Iterator i = areas.iterator();
        while (i.hasNext()) {
            Shape s = (Shape)i.next();
            Rectangle r = at.createTransformedShape(s).getBounds();
            flush(r);
        }
    }

    /**
     * Flush a rectangle of cached image data.
     */
    public void flush(Rectangle r) {
        if (lastCache == null) return;
        Object o = lastCache.get();
        if (o == null) return;

        TileCacheRed tcr = (TileCacheRed)o;
        r = (Rectangle)r.clone();
        r.x -= Math.round((float)usr2dev.getTranslateX());
        r.y -= Math.round((float)usr2dev.getTranslateY());
        // System.out.println("Flushing Rect:" + r);
        tcr.flushCache(r);
    }

    protected CachableRed setupCache(CachableRed img) {
        if ((lastCR == null) ||
            (img != lastCR.get())) {
            lastCR    = new SoftReference(img);
            lastCache = null;
        }

        Object o = null;
        if (lastCache != null)
            o = lastCache.get();
        if (o != null)
            return (CachableRed)o;

        img       = new TileCacheRed(img);
        lastCache = new SoftReference(img);
        return img;
    }

    protected CachableRed renderGNR() {
        AffineTransform at, rcAT;
        at = usr2dev;
        rcAT = new AffineTransform(at.getScaleX(), at.getShearY(),
                                   at.getShearX(), at.getScaleY(),
                                   0, 0);

        RenderContext rc = new RenderContext(rcAT, null, renderingHints);

        RenderedImage ri = rootFilter.createRendering(rc);
        if (ri == null)
            return null;

        CachableRed ret;
        ret = GraphicsUtil.wrap(ri);
        ret = setupCache(ret);

        int dx = Math.round((float)at.getTranslateX());
        int dy = Math.round((float)at.getTranslateY());
        ret = new TranslateRed(ret, ret.getMinX()+dx, ret.getMinY()+dy);
        ret = GraphicsUtil.convertTosRGB(ret);

        return ret;
    }


    /**
     * Internal method used to synchronize local state in response to
     * various set methods.
     */
    protected void updateWorkingBuffers() {
        if (rootFilter == null) {
            rootFilter = rootGN.getGraphicsNodeRable(true);
            rootCR = null;
        }

        rootCR = renderGNR();
        if (rootCR == null) {
            // No image to display so clear everything out...
            workingRaster = null;
            workingOffScreen = null;
            workingBaseRaster = null;

            currentOffScreen = null;
            currentBaseRaster = null;
            currentRaster = null;
            return;
        }

        SampleModel sm = rootCR.getSampleModel();
        int         w  = offScreenWidth;
        int         h  = offScreenHeight;

        int tw = sm.getWidth();
        int th = sm.getHeight();
        w = (((w+tw-1)/tw)+1)*tw;
        h = (((h+th-1)/th)+1)*th;

        if ((workingBaseRaster == null) ||
            (workingBaseRaster.getWidth()  < w) ||
            (workingBaseRaster.getHeight() < h)) {

            sm = sm.createCompatibleSampleModel(w, h);

            workingBaseRaster
                = Raster.createWritableRaster(sm, new Point(0,0));
        }

        int tgx = -rootCR.getTileGridXOffset();
        int tgy = -rootCR.getTileGridYOffset();
        int xt, yt;
        if (tgx>=0) xt = tgx/tw;
        else        xt = (tgx-tw+1)/tw;
        if (tgy>=0) yt = tgy/th;
        else        yt = (tgy-th+1)/th;

        int xloc = xt*tw - tgx;
        int yloc = yt*th - tgy;

        // System.out.println("Info: [" +
        //                    xloc + "," + yloc + "] [" +
        //                    tgx  + "," + tgy  + "] [" +
        //                    xt   + "," + yt   + "] [" +
        //                    tw   + "," + th   + "]");
        // This raster should be aligned with cr's tile grid.
        workingRaster = workingBaseRaster.createWritableChild
          (0, 0, w, h, xloc, yloc, null);

        workingOffScreen =  new BufferedImage
          (rootCR.getColorModel(),
           workingRaster.createWritableChild (0, 0, offScreenWidth,
                                           offScreenHeight, 0, 0, null),
           rootCR.getColorModel().isAlphaPremultiplied(), null);


        if (!isDoubleBuffered) {
            currentOffScreen  = workingOffScreen;
            currentBaseRaster = workingBaseRaster;
            currentRaster     = workingRaster;
        }
    }
}
