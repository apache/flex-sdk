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

import java.awt.Rectangle;
import java.awt.RenderingHints;
import java.awt.Shape;
import java.awt.geom.AffineTransform;
import java.awt.geom.Rectangle2D;
import java.awt.image.RenderedImage;
import java.awt.image.renderable.RenderContext;

import org.apache.flex.forks.batik.ext.awt.image.rendered.AffineRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.CachableRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.TranslateRed;

/**
 * RasterRable This is used to wrap a Rendered Image back into the
 * RenderableImage world.
 *
 * @author <a href="mailto:Thomas.DeWeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: RedRable.java 478276 2006-11-22 18:33:37Z dvholten $
 */
public class RedRable
    extends    AbstractRable {
    CachableRed src;

    public RedRable(CachableRed src) {
        super((Filter)null);
        this.src = src;
    }

    public CachableRed getSource() {
        return src;
    }

    public Object getProperty(String name) {
        return src.getProperty(name);
    }

    public String [] getPropertyNames() {
        return src.getPropertyNames();
    }

    public Rectangle2D getBounds2D() {
        return getSource().getBounds();
    }

    public RenderedImage createDefaultRendering() {
        return getSource();
    }


    public RenderedImage createRendering(RenderContext rc) {
        // System.out.println("RedRable Create Rendering: " + this);

        // Just copy over the rendering hints.
        RenderingHints rh = rc.getRenderingHints();
        if (rh == null) rh = new RenderingHints(null);

        Shape aoi = rc.getAreaOfInterest();
        Rectangle aoiR;
        if (aoi != null)
            aoiR = aoi.getBounds();
        else
            aoiR = getBounds2D().getBounds();

        // get the current affine transform
        AffineTransform at = rc.getTransform();

        // For high quality output we should really apply a Gaussian
        // Blur when we are scaling the image down significantly this
        // helps to prevent aliasing in the result image.
        CachableRed cr = getSource();

        if ( ! aoiR.intersects(cr.getBounds()) )
            return null;

        if (at.isIdentity()) {
            // System.out.println("Using as is");
            return cr;
        }

        if ((at.getScaleX() == 1.0) && (at.getScaleY() == 1.0) &&
            (at.getShearX() == 0.0) && (at.getShearY() == 0.0)) {
            int xloc = (int)(cr.getMinX()+at.getTranslateX());
            int yloc = (int)(cr.getMinY()+at.getTranslateY());
            double dx = xloc - (cr.getMinX()+at.getTranslateX());
            double dy = yloc - (cr.getMinY()+at.getTranslateY());
            if (((dx > -0.0001) && (dx < 0.0001)) &&
                ((dy > -0.0001) && (dy < 0.0001))) {
                // System.out.println("Using TranslateRed");
                return new TranslateRed(cr, xloc, yloc);
            }
        }

        // System.out.println("Using Full affine: " + at);
        return new AffineRed(cr, at, rh);
    }
}
