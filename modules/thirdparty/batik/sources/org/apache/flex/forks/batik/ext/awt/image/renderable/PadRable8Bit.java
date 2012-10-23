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

import java.awt.Composite;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.Shape;
import java.awt.geom.AffineTransform;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.awt.image.RenderedImage;
import java.awt.image.renderable.RenderContext;

import org.apache.flex.forks.batik.ext.awt.image.GraphicsUtil;
import org.apache.flex.forks.batik.ext.awt.image.PadMode;
import org.apache.flex.forks.batik.ext.awt.image.SVGComposite;
import org.apache.flex.forks.batik.ext.awt.image.rendered.CachableRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.PadRed;

/**
 * Concrete implementation of the PadRable interface.
 * This pads the image to a specified rectangle in user coord system.
 *
 * @author <a href="mailto:Thomas.DeWeeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: PadRable8Bit.java 478276 2006-11-22 18:33:37Z dvholten $
 */
public class PadRable8Bit extends AbstractRable
    implements PadRable, PaintRable {

    PadMode           padMode;
    Rectangle2D       padRect;

    public PadRable8Bit(Filter src,
                        Rectangle2D padRect,
                        PadMode     padMode) {
        super.init(src, null);
        this.padRect = padRect;
        this.padMode = padMode;
    }

    /**
     * Returns the source to be affine.
     */
    public Filter getSource() {
        return (Filter)srcs.get(0);
    }

    /**
     * Sets the source to be affine.
     * @param src image to affine.
     */
    public void setSource(Filter src) {
        super.init(src, null);
    }

    public Rectangle2D getBounds2D() {
        return (Rectangle2D)padRect.clone();
    }

    /**
     * Set the current rectangle for padding.
     * @param rect the new rectangle to use for pad.
     */
    public void setPadRect(Rectangle2D rect) {
        touch();
        this.padRect = rect;
    }

    /**
     * Get the current rectangle for padding
     * @return Rectangle currently in use for pad.
     */
    public Rectangle2D getPadRect() {
        return (Rectangle2D)padRect.clone();
    }

    /**
     * Set the current extension mode for pad
     * @param padMode the new pad mode
     */
    public void setPadMode(PadMode padMode) {
        touch();
        this.padMode = padMode;
    }

    /**
     * Get the current extension mode for pad
     * @return Mode currently in use for pad
     */
    public PadMode getPadMode() {
        return padMode;
    }

    /**
     * Should perform the equivilent action as
     * createRendering followed by drawing the RenderedImage to
     * Graphics2D, or return false.
     *
     * @param g2d The Graphics2D to draw to.
     * @return true if the paint call succeeded, false if
     *         for some reason the paint failed (in which
     *         case a createRendering should be used).
     */
    public boolean paintRable(Graphics2D g2d) {
        // This optimization only apply if we are using
        // SrcOver.  Otherwise things break...
        Composite c = g2d.getComposite();
        if (!SVGComposite.OVER.equals(c))
            return false;

        if (getPadMode() != PadMode.ZERO_PAD)
            return false;

        Rectangle2D padBounds = getPadRect();

        Shape clip = g2d.getClip();
        g2d.clip(padBounds);
        GraphicsUtil.drawImage(g2d, getSource());
        g2d.setClip(clip);
        return true;
    }

    public RenderedImage createRendering(RenderContext rc) {
        RenderingHints rh = rc.getRenderingHints();
        if (rh == null) rh = new RenderingHints(null);

        Filter src = getSource();
        Shape aoi = rc.getAreaOfInterest();

        if(aoi == null){
            aoi = getBounds2D();
        }

        AffineTransform usr2dev = rc.getTransform();

        // We only depend on our source for stuff that is inside
        // our bounds and his bounds (remember our bounds may be
        // tighter than his in one or both directions).
        Rectangle2D srect = src.getBounds2D();
        Rectangle2D rect  = getBounds2D();
        Rectangle2D arect = aoi.getBounds2D();

        // System.out.println("Rects Src:" + srect +
        //                    "My: " + rect +
        //                    "AOI: " + arect);
        if ( ! arect.intersects(rect) )
            return null;
        Rectangle2D.intersect(arect, rect, arect);

        RenderedImage ri = null;
        if ( arect.intersects(srect) ) {
            srect = (Rectangle2D)srect.clone();
            Rectangle2D.intersect(srect, arect, srect);

            RenderContext srcRC = new RenderContext(usr2dev, srect, rh);
            ri = src.createRendering(srcRC);

            // System.out.println("Pad filt: " + src + " R: " +
            //                    src.getBounds2D());
        }

        // No source image so create a 1,1 transparent one...
        if (ri == null)
            ri = new BufferedImage(1, 1, BufferedImage.TYPE_INT_ARGB);

        // org.apache.flex.forks.batik.test.gvt.ImageDisplay.showImage("Paded: ", ri);
        // System.out.println("RI: " + ri + " R: " + srect);

        CachableRed cr = GraphicsUtil.wrap(ri);

        arect = usr2dev.createTransformedShape(arect).getBounds2D();

        // System.out.println("Pad rect : " + arect);
        // Use arect (my bounds intersect area of interest)
        cr = new PadRed(cr, arect.getBounds(), padMode, rh);
        return cr;
    }

    public Shape getDependencyRegion(int srcIndex, Rectangle2D outputRgn) {
        if (srcIndex != 0)
            throw new IndexOutOfBoundsException("Affine only has one input");

        // We only depend on our source for stuff that is inside
        // our bounds and his bounds (remember our bounds may be
        // tighter than his in one or both directions).
        Rectangle2D srect = getSource().getBounds2D();
        if ( ! srect.intersects(outputRgn) )
            return new Rectangle2D.Float();
        Rectangle2D.intersect(srect, outputRgn, srect);

        Rectangle2D bounds = getBounds2D();
        if ( ! srect.intersects(bounds) )
            return new Rectangle2D.Float();
        Rectangle2D.intersect(srect, bounds, srect);
        return srect;
    }

    public Shape getDirtyRegion(int srcIndex, Rectangle2D inputRgn) {
        if (srcIndex != 0)
            throw new IndexOutOfBoundsException("Affine only has one input");

        inputRgn = (Rectangle2D)inputRgn.clone();
        Rectangle2D bounds = getBounds2D();
        // Changes in the input region don't propogate outside our
        // bounds.
        if ( ! inputRgn.intersects(bounds) )
            return new Rectangle2D.Float();
        Rectangle2D.intersect(inputRgn, bounds, inputRgn);
        return inputRgn;
    }

}
