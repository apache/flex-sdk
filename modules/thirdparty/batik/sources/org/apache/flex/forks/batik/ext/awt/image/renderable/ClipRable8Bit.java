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
package org.apache.flex.forks.batik.ext.awt.image.renderable;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.Rectangle;
import java.awt.RenderingHints;
import java.awt.Shape;
import java.awt.geom.AffineTransform;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.awt.image.RenderedImage;
import java.awt.image.renderable.RenderContext;

import org.apache.flex.forks.batik.ext.awt.image.GraphicsUtil;
import org.apache.flex.forks.batik.ext.awt.image.PadMode;
import org.apache.flex.forks.batik.ext.awt.image.rendered.BufferedImageCachableRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.CachableRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.MultiplyAlphaRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.PadRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.RenderedImageCachableRed;

/**
 * ClipRable implementation
 *
 * @author <a href="mailto:Thomas.DeWeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: ClipRable8Bit.java 478276 2006-11-22 18:33:37Z dvholten $
 */
public class ClipRable8Bit
    extends    AbstractRable
    implements ClipRable {

    protected boolean useAA;

    /**
     * The node who's outline specifies our mask.
     */
    protected Shape clipPath;

    public ClipRable8Bit(Filter src, Shape clipPath) {
        super(src, null);
        setClipPath(clipPath);
        setUseAntialiasedClip(false);
    }

    public ClipRable8Bit(Filter src, Shape clipPath, boolean useAA) {
        super(src, null);
        setClipPath(clipPath);
        setUseAntialiasedClip(useAA);
    }

    /**
     * The source to be masked by the mask node.
     * @param src The Image to be masked.
     */
    public void setSource(Filter src) {
        init(src, null);
    }

    /**
     * This returns the current image being masked by the mask node.
     * @return The image to mask
     */
    public Filter getSource() {
        return (Filter)getSources().get(0);
    }

    /**
     * Set the default behaviour of anti-aliased clipping.
     * for this clip object.
     */
    public void setUseAntialiasedClip(boolean useAA) {
        touch();
        this.useAA = useAA;
    }

    /**
     * Resturns true if the default behaviour should be to use
     * anti-aliased clipping.
     */
    public boolean getUseAntialiasedClip() {
        return useAA;
    }


    /**
     * Set the clip path to use.
     * The path will be filled with opaque white.
     * @param clipPath The clip path to use
     */
    public void setClipPath(Shape clipPath) {
        touch();
        this.clipPath = clipPath;
    }

      /**
       * Returns the Shape that the cliprable will use to
       * define the clip path.
       * @return The shape that defines the clip path.
       */
    public Shape getClipPath() {
        return clipPath;
    }

    /**
     * Pass-through: returns the source's bounds
     */
    public Rectangle2D getBounds2D(){
        return getSource().getBounds2D();
    }

    public RenderedImage createRendering(RenderContext rc) {

        AffineTransform usr2dev = rc.getTransform();

        // Just copy over the rendering hints.
        RenderingHints rh = rc.getRenderingHints();
        if (rh == null)  rh = new RenderingHints(null);

        Shape aoi = rc.getAreaOfInterest();
        if (aoi == null) aoi = getBounds2D();

        Rectangle2D rect     = getBounds2D();
        Rectangle2D clipRect = clipPath.getBounds2D();
        Rectangle2D aoiRect  = aoi.getBounds2D();

        if ( ! rect.intersects(clipRect) )
            return null;
        Rectangle2D.intersect(rect, clipRect, rect);


        if ( ! rect.intersects(aoiRect) )
            return null;
        Rectangle2D.intersect(rect, aoi.getBounds2D(), rect);

        Rectangle devR = usr2dev.createTransformedShape(rect).getBounds();

        if ((devR.width == 0) || (devR.height == 0))
            return null;

        BufferedImage bi = new BufferedImage(devR.width, devR.height,
                                             BufferedImage.TYPE_BYTE_GRAY);

        Shape devShape = usr2dev.createTransformedShape(getClipPath());
        Rectangle devAOIR;
        devAOIR = usr2dev.createTransformedShape(aoi).getBounds();

        Graphics2D g2d = GraphicsUtil.createGraphics(bi, rh);

        if (false) {
            java.util.Set s = rh.keySet();
            java.util.Iterator i = s.iterator();
            while (i.hasNext()) {
                Object o = i.next();
                System.out.println("XXX: " + o + " -> " + rh.get(o));
            }
        }
        g2d.translate(-devR.x, -devR.y);
        g2d.setPaint(Color.white);
        g2d.fill(devShape);
        g2d.dispose();

        RenderedImage ri;
        ri = getSource().createRendering(new RenderContext(usr2dev, rect, rh));

        CachableRed cr, clipCr;
        cr = RenderedImageCachableRed.wrap(ri);
        clipCr = new BufferedImageCachableRed(bi, devR.x, devR.y);
        CachableRed ret = new MultiplyAlphaRed(cr, clipCr);

          // Pad back out to the proper size...
        ret = new PadRed(ret, devAOIR, PadMode.ZERO_PAD, rh);

        return ret;
    }
}
