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

import java.awt.Color;
import java.awt.Rectangle;
import java.awt.Point;
import java.awt.RenderingHints;
import java.awt.geom.AffineTransform;
import java.awt.image.BufferedImage;
import java.awt.image.Raster;
import java.awt.image.SampleModel;
import java.awt.image.WritableRaster;
import java.util.Collection;
import java.util.Iterator;

import org.apache.flex.forks.batik.ext.awt.geom.RectListManager;
import org.apache.flex.forks.batik.ext.awt.image.GraphicsUtil;
import org.apache.flex.forks.batik.ext.awt.image.PadMode;
import org.apache.flex.forks.batik.ext.awt.image.rendered.CachableRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.PadRed;
import org.apache.flex.forks.batik.util.HaltingThread;

/**
 * Simple implementation of the Renderer that supports dynamic updates.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: DynamicRenderer.java 489226 2006-12-21 00:05:36Z cam $
 */
public class DynamicRenderer extends StaticRenderer {

    static final int COPY_OVERHEAD      = 1000;
    static final int COPY_LINE_OVERHEAD = 10;

    /**
     * Constructs a new dynamic renderer with the specified buffer image.
     */
    public DynamicRenderer() {
        super();
    }

    public DynamicRenderer(RenderingHints rh,
                           AffineTransform at){
        super(rh, at);
    }

    RectListManager damagedAreas;

    protected CachableRed setupCache(CachableRed img) {
        // Don't do any caching of content for dynamic case
        return img;
    }

    public void flush(Rectangle r) {
        // Since we don't cache we don't need to flush
        return;
    }

    /**
     * Flush a list of rectangles of cached image data.
     */
    public void flush(Collection areas) {
        // Since we don't cache we don't need to flush
        return;
    }

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

        if ((workingBaseRaster == null) ||
            (workingBaseRaster.getWidth()  < w) ||
            (workingBaseRaster.getHeight() < h)) {

            sm = sm.createCompatibleSampleModel(w, h);

            workingBaseRaster
                = Raster.createWritableRaster(sm, new Point(0,0));

            workingRaster = workingBaseRaster.createWritableChild
                (0, 0, w, h, 0, 0, null);

            workingOffScreen =  new BufferedImage
                (rootCR.getColorModel(),
                 workingRaster,
                 rootCR.getColorModel().isAlphaPremultiplied(), null);
        }

        if (!isDoubleBuffered) {
            currentOffScreen  = workingOffScreen;
            currentBaseRaster = workingBaseRaster;
            currentRaster     = workingRaster;
        }
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

        // long t0 = System.currentTimeMillis();
        // if (lastFrame != -1) {
        //     System.out.println("InterFrame time: " + (t0-lastFrame));
        // }
        // lastFrame = t0;

        CachableRed cr;
        WritableRaster syncRaster;
        WritableRaster copyRaster;

        updateWorkingBuffers();
        if ((rootCR == null)           ||
            (workingBaseRaster == null)) {
            // System.err.println("RootCR: " + rootCR);
            // System.err.println("wrkBaseRaster: " + workingBaseRaster);
            return;
        }
        cr = rootCR;
        syncRaster = workingBaseRaster;
        copyRaster = workingRaster;

        Rectangle srcR = rootCR.getBounds();
        // System.out.println("RootCR: " + srcR);
        Rectangle dstR = workingRaster.getBounds();
        if ((dstR.x < srcR.x) ||
            (dstR.y < srcR.y) ||
            (dstR.x+dstR.width  > srcR.x+srcR.width) ||
            (dstR.y+dstR.height > srcR.y+srcR.height))
            cr = new PadRed(cr, dstR, PadMode.ZERO_PAD, null);

        boolean repaintAll = false;

        Rectangle dr = copyRaster.getBounds();

        // Ensure only one thread works on baseRaster at a time...
        synchronized (syncRaster) {
            // System.out.println("Dynamic:");
            if (repaintAll) {
                // System.out.println("Repainting All");
                cr.copyData(copyRaster);
            } else {
                java.awt.Graphics2D g2d = null;
                if (false) {
                    BufferedImage tmpBI = new BufferedImage
                        (workingOffScreen.getColorModel(),
                         copyRaster.createWritableTranslatedChild(0, 0),
                         workingOffScreen.isAlphaPremultiplied(), null);
                    g2d = GraphicsUtil.createGraphics(tmpBI);
                    g2d.translate(-copyRaster.getMinX(),
                                  -copyRaster.getMinY());
                }


                if ((isDoubleBuffered) &&
                    (currentRaster != null) &&
                    (damagedAreas  != null)) {
                    damagedAreas.subtract(devRLM, COPY_OVERHEAD,
                                          COPY_LINE_OVERHEAD);
                    damagedAreas.mergeRects(COPY_OVERHEAD,
                                            COPY_LINE_OVERHEAD);

                    // color-objects are immutable, so we can reuse this handful of instances
                    Color fillColor   = new Color( 0, 0, 255, 50 );
                    Color borderColor = new Color( 0, 0,   0, 50 );

                    Iterator iter = damagedAreas.iterator();
                    while (iter.hasNext()) {
                        Rectangle r = (Rectangle)iter.next();
                        if (!dr.intersects(r)) continue;
                        r = dr.intersection(r);
                        // System.err.println("Copy: " + r);
                        Raster src = currentRaster.createWritableChild
                            (r.x, r.y, r.width, r.height, r.x, r.y, null);
                        GraphicsUtil.copyData(src, copyRaster);
                        if (g2d != null) {
                            g2d.setPaint( fillColor );
                            g2d.fill(r);
                            g2d.setPaint( borderColor );
                            g2d.draw(r);
                        }
                    }
                }

                Color fillColor   = new Color( 255, 0, 0, 50 );
                Color borderColor = new Color(   0, 0, 0, 50 );

                Iterator iter = devRLM.iterator();
                while (iter.hasNext()) {
                    Rectangle r = (Rectangle)iter.next();
                    if (!dr.intersects(r)) continue;
                    r = dr.intersection(r);

                    // System.err.println("Render: " + r);
                    WritableRaster dst = copyRaster.createWritableChild
                        (r.x, r.y, r.width, r.height, r.x, r.y, null);
                    cr.copyData(dst);
                    if (g2d != null) {
                        g2d.setPaint( fillColor );
                        g2d.fill(r);
                        g2d.setPaint( borderColor );
                        g2d.draw(r);
                    }
                }
            }
        }

        if (HaltingThread.hasBeenHalted())
            return;

        // System.out.println("Dmg: "   + damagedAreas);
        // System.out.println("Areas: " + devRects);

        // Swap the buffers if the rendering completed cleanly.
        BufferedImage tmpBI = workingOffScreen;

        workingBaseRaster = currentBaseRaster;
        workingRaster     = currentRaster;
        workingOffScreen  = currentOffScreen;

        currentRaster     = copyRaster;
        currentBaseRaster = syncRaster;
        currentOffScreen  = tmpBI;

        damagedAreas = devRLM;
    }
}
