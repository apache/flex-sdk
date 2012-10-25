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
import java.util.List;

import org.apache.flex.forks.batik.ext.awt.image.ARGBChannel;
import org.apache.flex.forks.batik.ext.awt.image.GraphicsUtil;
import org.apache.flex.forks.batik.ext.awt.image.rendered.AffineRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.CachableRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.DisplacementMapRed;

/**
 * Implements a DisplacementMap operation, which takes pixel values from
 * another image to spatially displace the input image
 *
 * @author <a href="mailto:sheng.pei@eng.sun.com">Sheng Pei</a>
 * @version $Id: DisplacementMapRable8Bit.java 479564 2006-11-27 09:56:57Z dvholten $
 */
public class DisplacementMapRable8Bit
    extends    AbstractColorInterpolationRable
    implements DisplacementMapRable {

    /**
     * Displacement scale factor
     */
    private double scale;

    /**
     * Defines which channel in the second source is used
     * to displace along the x axis
     */
    private ARGBChannel xChannelSelector;

    /**
     * Defines which channel in the second source is used
     * to displace along the y axis.
     */
    private ARGBChannel yChannelSelector;

    public DisplacementMapRable8Bit(List sources,
                                    double scale,
                                    ARGBChannel xChannelSelector,
                                    ARGBChannel yChannelSelector){
        setSources(sources);
        setScale(scale);
        setXChannelSelector(xChannelSelector);
        setYChannelSelector(yChannelSelector);
    }

    public Rectangle2D getBounds2D(){
        return ((Filter)(getSources().get(0))).getBounds2D();
    }

    /**
     * The displacement scale factor
     * @param scale can be any number.
     */
    public void setScale(double scale){
        touch();
        this.scale = scale;
    }

    /**
     * Returns the displacement scale factor
     */
    public double getScale(){
        return scale;
    }

    /**
     * Sets this filter sources.
     */
    public void setSources(List sources){
        if(sources.size() != 2){
            throw new IllegalArgumentException();
        }
        init(sources, null);
    }

    /**
     * Select which component values will be used
     * for displacement along the X axis
     * @param xChannelSelector value is among R,
     * G, B and A.
     */
    public void setXChannelSelector(ARGBChannel xChannelSelector){
        if(xChannelSelector == null){
            throw new IllegalArgumentException();
        }
        touch();
        this.xChannelSelector = xChannelSelector;
    }

    /**
     * Returns the xChannelSelector
     */
    public ARGBChannel getXChannelSelector(){
        return xChannelSelector;
    }

    /**
     * Select which component values will be used
     * for displacement along the Y axis
     * @param yChannelSelector value is among R,
     * G, B and A.
     */
    public void setYChannelSelector(ARGBChannel yChannelSelector){
        if(yChannelSelector == null){
            throw new IllegalArgumentException();
        }
        touch();
        this.yChannelSelector = yChannelSelector;
    }

    /**
     * Returns the yChannelSelector
     */
    public ARGBChannel getYChannelSelector(){
        return yChannelSelector;
    }

    public RenderedImage createRendering(RenderContext rc) {
        // The source image to be displaced.
        Filter displaced = (Filter)getSources().get(0);
        // The map giving the displacement.
        Filter map = (Filter)getSources().get(1);

        RenderingHints rh = rc.getRenderingHints();
        if (rh == null) rh = new RenderingHints(null);

        // update the current affine transform
        AffineTransform at = rc.getTransform();

        // This splits out the scale from the rest of
        // the transformation.
        double sx = at.getScaleX();
        double sy = at.getScaleY();

        double shx = at.getShearX();
        double shy = at.getShearY();

        double tx = at.getTranslateX();
        double ty = at.getTranslateY();

        // The Scale is the "hypotonose" of the matrix vectors.
        double atScaleX = Math.sqrt(sx*sx + shy*shy);
        double atScaleY = Math.sqrt(sy*sy + shx*shx);

        // Now, apply the filter
        //
        float scaleX = (float)(scale*atScaleX);
        float scaleY = (float)(scale*atScaleY);

        // If both scale factors are zero then we don't
        // affect the source image so just return it...
        if ((scaleX == 0) && (scaleY == 0))
            return displaced.createRendering(rc);

        // if ((scaleX > 255) || (scaleY > 255)) {
        //   System.out.println("Scales: [" + scaleX + ", " + scaleY + "]");
        // }

        AffineTransform srcAt
            = AffineTransform.getScaleInstance(atScaleX, atScaleY);

        Shape origAOI = rc.getAreaOfInterest();
        if (origAOI == null)
            origAOI = getBounds2D();

        Rectangle2D aoiR = origAOI.getBounds2D();

        RenderContext srcRc = new RenderContext(srcAt, aoiR, rh);
        RenderedImage mapRed = map.createRendering(srcRc);

        if (mapRed == null) return null;

        // Grow the area of interest in user space. to account for
        // the max surround needs of displacement map.
        aoiR = new Rectangle2D.Double(aoiR.getX()      - scale/2,
                                      aoiR.getY()      - scale/2,
                                      aoiR.getWidth()  + scale,
                                      aoiR.getHeight() + scale);

        Rectangle2D displacedRect = displaced.getBounds2D();
        if ( ! aoiR.intersects(displacedRect) )
            return null;

        aoiR = aoiR.createIntersection(displacedRect);
        srcRc = new RenderContext(srcAt, aoiR, rh);
        RenderedImage displacedRed = displaced.createRendering(srcRc);

        if (displacedRed == null) return null;

        mapRed = convertSourceCS(mapRed);

        //
        // Build a Displacement Map Red from the two sources
        //

        CachableRed cr = new DisplacementMapRed
            (GraphicsUtil.wrap(displacedRed),
             GraphicsUtil.wrap(mapRed),
             xChannelSelector, yChannelSelector,
             scaleX, scaleY, rh);
        //
        // Apply the non scaling part of the transform now,
        // if different from identity.
        //
        AffineTransform resAt
            = new AffineTransform(sx/atScaleX, shy/atScaleX,
                                  shx/atScaleY,  sy/atScaleY,
                                  tx, ty);

        if(!resAt.isIdentity())
            cr = new AffineRed(cr, resAt, rh);

        return cr;
    }

    /**
     * Returns the region of input data is is required to generate
     * outputRgn.
     * @param srcIndex  The source to do the dependency calculation for.
     * @param outputRgn The region of output you are interested in
     *  generating dependencies for.  The is given in the user coordiate
     *  system for this node.
     * @return The region of input required.  This is in the user
     * coordinate system for the source indicated by srcIndex.
     */
    public Shape getDependencyRegion(int srcIndex, Rectangle2D outputRgn){
        // NOTE: This needs to grow the region!!!
        //       Morphology actually needs a larger area of input than
        //       it outputs.
        return super.getDependencyRegion(srcIndex, outputRgn);
    }

    /**
     * This calculates the region of output that is affected by a change
     * in a region of input.
     * @param srcIndex The input that inputRgn reflects changes in.
     * @param inputRgn the region of input that has changed, used to
     *  calculate the returned shape.  This is given in the user
     *  coordinate system of the source indicated by srcIndex.
     * @return The region of output that would be invalid given
     *  a change to inputRgn of the source selected by srcIndex.
     *  this is in the user coordinate system of this node.
     */
    public Shape getDirtyRegion(int srcIndex, Rectangle2D inputRgn){
        // NOTE: This needs to grow the region!!!
        //       Changes in the input region affect a larger area of
        //       output than the input.
        return super.getDirtyRegion(srcIndex, inputRgn);
    }

}
