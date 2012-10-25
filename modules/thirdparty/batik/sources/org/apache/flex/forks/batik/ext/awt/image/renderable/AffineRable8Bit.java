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

import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.Shape;
import java.awt.geom.AffineTransform;
import java.awt.geom.NoninvertibleTransformException;
import java.awt.geom.Rectangle2D;
import java.awt.image.RenderedImage;
import java.awt.image.renderable.RenderContext;

import org.apache.flex.forks.batik.ext.awt.image.GraphicsUtil;

/**
 * Concrete implementation of the AffineRable interface.
 * This adjusts the input images coordinate system by a general affine
 *
 * @author <a href="mailto:Thomas.DeWeeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: AffineRable8Bit.java 475477 2006-11-15 22:44:28Z cam $
 */
public class AffineRable8Bit 
    extends    AbstractRable
    implements AffineRable, PaintRable {

    AffineTransform affine;
    AffineTransform invAffine;

    public AffineRable8Bit(Filter src, AffineTransform affine) {
        init(src);
        setAffine(affine);
    }

    public Rectangle2D getBounds2D() {
        Filter src = getSource();
        Rectangle2D r = src.getBounds2D();
        return affine.createTransformedShape(r).getBounds2D();
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
        init(src);
    }

      /**
       * Set the affine transform.
       * @param affine the new Affine transform to apply.
       */
    public void setAffine(AffineTransform affine) {
        touch();
        this.affine = affine;
        try {
            invAffine = affine.createInverse();
        } catch (NoninvertibleTransformException e) {
            invAffine = null;
        }
    }

      /**
       * Get the Affine.
       * @return the Affine transform currently in effect.
       */
    public AffineTransform getAffine() {
        return (AffineTransform)affine.clone();
    }

    /**
     * Should perform the equivilent action as 
     * createRendering followed by drawing the RenderedImage.
     *
     * @param g2d The Graphics2D to draw to.
     * @return true if the paint call succeeded, false if
     *         for some reason the paint failed (in which 
     *         case a createRendering should be used).
     */
    public boolean paintRable(Graphics2D g2d) {
        AffineTransform at = g2d.getTransform();

        g2d.transform(getAffine());
        GraphicsUtil.drawImage(g2d, getSource());

        g2d.setTransform(at);

        return true;
    }


    public RenderedImage createRendering(RenderContext rc) {
        // Degenerate Affine no output image..
        if (invAffine == null) return null;

        // Just copy over the rendering hints.
        RenderingHints rh = rc.getRenderingHints();
        if (rh == null) rh = new RenderingHints(null);

        // Map the area of interest to our input...
        Shape aoi = rc.getAreaOfInterest();
        if (aoi != null)
            aoi = invAffine.createTransformedShape(aoi);

        // update the current affine transform
        AffineTransform at = rc.getTransform();
        at.concatenate(affine);

        // Return what our input creates (it should factor in our affine).
        return getSource().createRendering(new RenderContext(at, aoi, rh));
    }

    public Shape getDependencyRegion(int srcIndex, Rectangle2D outputRgn) {
        if (srcIndex != 0)
            throw new IndexOutOfBoundsException("Affine only has one input");
        if (invAffine == null)
            return null;
        return invAffine.createTransformedShape(outputRgn);
    }

    public Shape getDirtyRegion(int srcIndex, Rectangle2D inputRgn) {
        if (srcIndex != 0)
            throw new IndexOutOfBoundsException("Affine only has one input");
        return affine.createTransformedShape(inputRgn);
    }

}
