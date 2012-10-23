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
package org.apache.flex.forks.batik.gvt.filter;

import java.awt.geom.Rectangle2D;
import java.awt.image.RenderedImage;
import java.awt.image.renderable.RenderContext;

import org.apache.flex.forks.batik.ext.awt.image.GraphicsUtil;
import org.apache.flex.forks.batik.ext.awt.image.PadMode;
import org.apache.flex.forks.batik.ext.awt.image.renderable.AbstractRable;
import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.ext.awt.image.renderable.FilterAsAlphaRable;
import org.apache.flex.forks.batik.ext.awt.image.renderable.PadRable;
import org.apache.flex.forks.batik.ext.awt.image.renderable.PadRable8Bit;
import org.apache.flex.forks.batik.ext.awt.image.rendered.CachableRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.MultiplyAlphaRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.RenderedImageCachableRed;
import org.apache.flex.forks.batik.gvt.GraphicsNode;

/**
 * MaskRable implementation
 *
 * @author <a href="mailto:Thomas.DeWeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: MaskRable8Bit.java 475477 2006-11-15 22:44:28Z cam $
 */
public class MaskRable8Bit
    extends    AbstractRable
    implements Mask {

    /**
     * The node who's outline specifies our mask.
     */
    protected GraphicsNode mask;

    /**
     * Region to which the mask applies
     */
    protected Rectangle2D filterRegion;

    public MaskRable8Bit(Filter src, GraphicsNode mask, 
                             Rectangle2D filterRegion) {
        super(src, null);
        setMaskNode(mask);
        setFilterRegion(filterRegion);
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
     * The region to which this mask applies
     */
    public Rectangle2D getFilterRegion(){
        return (Rectangle2D)filterRegion.clone();
    }

    /**
     * Returns the filter region to which this mask applies
     */
    public void setFilterRegion(Rectangle2D filterRegion){
        if(filterRegion == null){
            throw new IllegalArgumentException();
        }

        this.filterRegion = filterRegion;
    }

    /**
     * Set the masking image to that described by gn.
     * If gn is an rgba image then the alpha is premultiplied and then
     * the rgb is converted to alpha via the standard feColorMatrix
     * rgb to luminance conversion.
     * In the case of an rgb only image, just the rgb to luminance
     * conversion is performed.
     * @param mask The graphics node that defines the mask image.
     */
    public void setMaskNode(GraphicsNode mask) {
        touch();
        this.mask = mask;
    }

      /**
       * Returns the Graphics node that the mask operation will use to
       * define the masking image.
       * @return The graphics node that defines the mask image.
       */
    public GraphicsNode getMaskNode() {
        return mask;
    }

    /**
     * Pass-through: returns the source's bounds
     */
    public Rectangle2D getBounds2D(){
        return (Rectangle2D)filterRegion.clone();
    }

    public RenderedImage createRendering(RenderContext rc) {
        //
        // Get the mask content
        //
        Filter   maskSrc = getMaskNode().getGraphicsNodeRable(true);
        PadRable maskPad = new PadRable8Bit(maskSrc, getBounds2D(),
                                                PadMode.ZERO_PAD);
        maskSrc = new FilterAsAlphaRable(maskPad);
        RenderedImage ri = maskSrc.createRendering(rc);
        if (ri == null)
            return null;

        CachableRed maskCr = RenderedImageCachableRed.wrap(ri);

        //
        // Get the masked content
        //
        PadRable maskedPad = new PadRable8Bit(getSource(),
                                                  getBounds2D(),
                                                  PadMode.ZERO_PAD);

        ri = maskedPad.createRendering(rc);
        if (ri == null)
            return null;

        CachableRed cr;
        cr = GraphicsUtil.wrap(ri);
        cr = GraphicsUtil.convertToLsRGB(cr);

        // org.apache.flex.forks.batik.test.gvt.ImageDisplay.showImage("Src: ", cr);
        // org.apache.flex.forks.batik.test.gvt.ImageDisplay.showImage("Mask: ", maskCr);

        CachableRed ret = new MultiplyAlphaRed(cr, maskCr);

        // org.apache.flex.forks.batik.test.gvt.ImageDisplay.showImage("Masked: ", ret);


        // ret = new PadRed(ret, cr.getBounds(), PadMode.ZERO_PAD, rh);

        return ret;
    }
}
