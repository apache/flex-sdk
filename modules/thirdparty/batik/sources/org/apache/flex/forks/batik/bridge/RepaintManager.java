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
package org.apache.flex.forks.batik.bridge;

import java.awt.Rectangle;
import java.awt.Shape;
import java.awt.geom.AffineTransform;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.util.ArrayList;
import java.util.List;
import java.util.Iterator;
import java.util.Collection;

import org.apache.flex.forks.batik.gvt.renderer.ImageRenderer;
import org.apache.flex.forks.batik.ext.awt.geom.RectListManager;

/**
 * This class manages the rendering of a GVT tree.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @author <a href="mailto:vincent.hardy@sun.com">Vincent Hardy</a>
 * @version $Id: RepaintManager.java 478160 2006-11-22 13:35:06Z dvholten $
 */
public class RepaintManager {
    static final int COPY_OVERHEAD      = 10000;
    static final int COPY_LINE_OVERHEAD = 10;

    /**
     * The renderer used to repaint the buffer.
     */
    protected ImageRenderer renderer;

    /**
     * Creates a new repaint manager.
     */
    public RepaintManager(ImageRenderer r) {
        renderer = r;
    }

    /**
     * Updates the rendering buffer.
     * @param areas The areas of interest in renderer space units.
     * @return the list of the rectangles to repaint.
     */
    public Collection updateRendering(Collection areas)
        throws InterruptedException {
        renderer.flush(areas);
        List rects = new ArrayList(areas.size());
        AffineTransform at = renderer.getTransform();

        Iterator i = areas.iterator();
        while (i.hasNext()) {
            Shape s = (Shape)i.next();
            s = at.createTransformedShape(s);
            Rectangle2D r2d = s.getBounds2D();
            int x0 = (int)Math.floor(r2d.getX());
            int y0 = (int)Math.floor(r2d.getY());
            int x1 = (int)Math.ceil(r2d.getX()+r2d.getWidth());
            int y1 = (int)Math.ceil(r2d.getY()+r2d.getHeight());
            // This rectangle must be outset one pixel to ensure
            // it includes the effects of anti-aliasing on objects.
            Rectangle r = new Rectangle(x0-1, y0-1, x1-x0+3, y1-y0+3);

            rects.add(r);
        }
        RectListManager devRLM =null;
        try {
             devRLM = new RectListManager(rects);
             devRLM.mergeRects(COPY_OVERHEAD, COPY_LINE_OVERHEAD);
        } catch(Exception e) {
            e.printStackTrace();
        }

        renderer.repaint(devRLM);
        return devRLM;
    }

    /**
     * Sets up the renderer so that it is ready to render for the new
     * 'context' defined by the user to device transform, double buffering
     * state, area of interest and width/height.
     * @param u2d The user to device transform.
     * @param dbr Whether the double buffering should be used.
     * @param aoi The area of interest in the renderer space units.
     * @param width The offscreen buffer width.
     * @param height The offscreen buffer width.
     */
    public void setupRenderer(AffineTransform u2d,
                              boolean dbr,
                              Shape aoi,
                              int width,
                              int height) {
        renderer.setTransform(u2d);
        renderer.setDoubleBuffered(dbr);
        renderer.updateOffScreen(width, height);
        renderer.clearOffScreen();
    }

    /**
     * Returns the renderer's offscreen, i.e., the current state as rendered
     * by the associated renderer.
     */
    public BufferedImage getOffScreen(){
        return renderer.getOffScreen();
    }
}
