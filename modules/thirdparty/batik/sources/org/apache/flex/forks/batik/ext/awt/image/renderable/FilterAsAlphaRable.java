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

import java.awt.RenderingHints;
import java.awt.Shape;
import java.awt.geom.AffineTransform;
import java.awt.geom.Rectangle2D;
import java.awt.image.RenderedImage;
import java.awt.image.renderable.RenderContext;

import org.apache.flex.forks.batik.ext.awt.ColorSpaceHintKey;
import org.apache.flex.forks.batik.ext.awt.RenderingHintsKeyExt;
import org.apache.flex.forks.batik.ext.awt.image.rendered.CachableRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.FilterAsAlphaRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.RenderedImageCachableRed;

/**
 * FilterAsAlphaRable implementation.
 *
 * This will take any source Filter and convert it to an alpha channel
 * according the the SVG Mask operation.
 *
 * @author <a href="mailto:Thomas.DeWeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: FilterAsAlphaRable.java 475477 2006-11-15 22:44:28Z cam $
 */
public class FilterAsAlphaRable
    extends    AbstractRable {

    public FilterAsAlphaRable(Filter src) {
        super(src, null);
    }

    public Filter getSource() {
        return (Filter)getSources().get(0);
    }

    /**
     * Pass-through: returns the source's bounds
     */
    public Rectangle2D getBounds2D(){
        return getSource().getBounds2D();
    }

    public RenderedImage createRendering(RenderContext rc) {
        // Source gets my usr2dev transform
        AffineTransform at = rc.getTransform();

        // Just copy over the rendering hints.
        RenderingHints rh = rc.getRenderingHints();
        if (rh == null) rh = new RenderingHints(null);

        // if we didn't have an aoi specify our bounds as the aoi.
        Shape aoi = rc.getAreaOfInterest();
        if (aoi == null) {
            aoi = getBounds2D();
        }

        rh.put(RenderingHintsKeyExt.KEY_COLORSPACE, 
               ColorSpaceHintKey.VALUE_COLORSPACE_ALPHA_CONVERT);

        RenderedImage ri;
        ri = getSource().createRendering(new RenderContext(at, aoi, rh));
        if (ri == null)
            return null;

        CachableRed cr = RenderedImageCachableRed.wrap(ri);

        Object val = cr.getProperty(ColorSpaceHintKey.PROPERTY_COLORSPACE);
        if (val == ColorSpaceHintKey.VALUE_COLORSPACE_ALPHA_CONVERT)
            return cr;

        return new FilterAsAlphaRed(cr);
    }
}
