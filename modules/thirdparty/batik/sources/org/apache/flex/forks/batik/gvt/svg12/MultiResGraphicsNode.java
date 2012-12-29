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
package org.apache.flex.forks.batik.gvt.svg12;

import java.awt.Dimension;
import java.awt.Graphics2D;
import java.awt.Shape;
import java.awt.geom.AffineTransform;
import java.awt.geom.Rectangle2D;
import java.lang.ref.SoftReference;

import org.apache.flex.forks.batik.bridge.BridgeContext;
import org.apache.flex.forks.batik.bridge.GVTBuilder;
import org.apache.flex.forks.batik.gvt.AbstractGraphicsNode;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.util.SVGConstants;
import org.w3c.dom.Element;

/**
 * RasterRable This is used to wrap a Rendered Image back into the
 * RenderableImage world.
 *
 * @author <a href="mailto:Thomas.DeWeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: MultiResGraphicsNode.java 475477 2006-11-15 22:44:28Z cam $
 */
public class MultiResGraphicsNode
    extends AbstractGraphicsNode implements SVGConstants {

    SoftReference [] srcs;
    Element       [] srcElems;
    Dimension     [] minSz;
    Dimension     [] maxSz;
    Rectangle2D      bounds;

    BridgeContext  ctx;

    Element multiImgElem;

    public MultiResGraphicsNode(Element multiImgElem,
                                Rectangle2D  bounds,
                                Element   [] srcElems,
                                Dimension [] minSz,
                                Dimension [] maxSz,
                                BridgeContext ctx) {

        this.multiImgElem = multiImgElem;
        this.srcElems     = new Element  [srcElems.length];
        this.minSz        = new Dimension[srcElems.length];
        this.maxSz        = new Dimension[srcElems.length];
        this.ctx          = ctx;

        for (int i=0; i<srcElems.length; i++) {
            this.srcElems[i] = srcElems[i];
            this.minSz[i]    = minSz[i];
            this.maxSz[i]    = maxSz[i];
        }

        this.srcs = new SoftReference[srcElems.length];
        this.bounds = bounds;
    }

    /**
     * Paints this node without applying Filter, Mask, Composite, and clip.
     *
     * @param g2d the Graphics2D to use
     */
    public void primitivePaint(Graphics2D g2d) {
        // get the current affine transform
        AffineTransform at = g2d.getTransform();

        double scx = Math.sqrt(at.getShearY()*at.getShearY()+
                               at.getScaleX()*at.getScaleX());
        double scy = Math.sqrt(at.getShearX()*at.getShearX()+
                               at.getScaleY()*at.getScaleY());

        GraphicsNode gn = null;
        int idx =-1;
        double w = bounds.getWidth()*scx;
        double minDist = calcDist(w, minSz[0], maxSz[0]);
        int    minIdx = 0;
        // System.err.println("Width: " + w);
        for (int i=0; i<minSz.length; i++) {
            double dist = calcDist(w, minSz[i], maxSz[i]);
            // System.err.println("Dist: " + dist);
            if (dist < minDist) {
                minDist = dist;
                minIdx = i;
            } 
                
            if (((minSz[i] == null) || (w >= minSz[i].width)) &&
                ((maxSz[i] == null) || (w <= maxSz[i].width))) {
                // We have a range match
                // System.err.println("Match: " + i + " " + 
                //                    minSz[i] + " -> " + maxSz[i]);
                if ((idx == -1) || (minIdx == i)) {
                    idx = i;
                }
            }
        }

        if (idx == -1)
            idx = minIdx;
        gn = getGraphicsNode(idx);
        if (gn == null) return;

        // This makes sure that the image 'pushes out' to it's pixel
        // bounderies.
        Rectangle2D gnBounds = gn.getBounds();
        if (gnBounds == null) return;

        double gnDevW = gnBounds.getWidth()*scx;
        double gnDevH = gnBounds.getHeight()*scy;
        double gnDevX = gnBounds.getX()*scx;
        double gnDevY = gnBounds.getY()*scy;
        double gnDevX0, gnDevX1, gnDevY0, gnDevY1;
        if (gnDevW < 0) {
            gnDevX0 = gnDevX+gnDevW;
            gnDevX1 = gnDevX;
        } else {
            gnDevX0 = gnDevX;
            gnDevX1 = gnDevX+gnDevW;
        }
        if (gnDevH < 0) {
            gnDevY0 = gnDevY+gnDevH;
            gnDevY1 = gnDevY;
        } else {
            gnDevY0 = gnDevY;
            gnDevY1 = gnDevY+gnDevH;
        }
        // This calculate the width/height in pixels given 'worst
        // case' assessment.
        gnDevW = (int)(Math.ceil(gnDevX1)-Math.floor(gnDevX0));
        gnDevH = (int)(Math.ceil(gnDevY1)-Math.floor(gnDevY0));
        scx = (gnDevW/gnBounds.getWidth())/scx;
        scy = (gnDevH/gnBounds.getHeight())/scy;

        // This scales things up slightly so our edges fall on device
        // pixel boundries.
        AffineTransform nat = g2d.getTransform();
        nat = new AffineTransform(nat.getScaleX()*scx, nat.getShearY()*scx,
                                 nat.getShearX()*scy, nat.getScaleY()*scy,
                                 nat.getTranslateX(), nat.getTranslateY());
        g2d.setTransform(nat);

        // double sx = bounds.getWidth()/sizes[idx].getWidth();
        // double sy = bounds.getHeight()/sizes[idx].getHeight();
        // System.err.println("Scale: [" + sx + ", " + sy + "]");

        gn.paint(g2d);
    }

    // This function can be tweaked to any extent.  This is a very
    // simple measure of 'goodness'.  It has two main flaws as is,
    // mostly in regards to distance calc with 'unbounded' ranges.
    // First it doesn't punish if the distance is the wrong way on the
    // unbounded range (so over a max by 10 is the same as under a max
    // by 10) this is compensated by the absolute preference for
    // matches 'in range' above.  The other issue is that unbounded
    // ranages tend to 'win' when the value is near the boundry point
    // since they use distance from the boundry point rather than the
    // middle of the range.  As it is this seems to meet all the
    // requirements of the SVG specification however.
    public double calcDist(double loc, Dimension min, Dimension max) {
        if (min == null) {
            if (max == null) 
                return 10E10; // very large number.
            else
                return Math.abs(loc-max.width);
        } else {
            if (max == null) 
                return Math.abs(loc-min.width);
            else {
                double mid = (max.width+min.width)/2.0;
                return Math.abs(loc-mid);
            }
        }
    }

    /**
     * Returns the bounds of the area covered by this node's primitive paint.
     */
    public Rectangle2D getPrimitiveBounds() {
        return bounds;
    }

    public Rectangle2D getGeometryBounds(){
        return bounds;
    }

    public Rectangle2D getSensitiveBounds(){
        return bounds;
    }

    /**
     * Returns the outline of this node.
     */
    public Shape getOutline() {
        return bounds;
    }

    public GraphicsNode getGraphicsNode(int idx) {
        if (srcs[idx] != null) {
            Object o = srcs[idx].get();
            if (o != null) 
                return (GraphicsNode)o;
        }
        
        try {
            GVTBuilder builder = ctx.getGVTBuilder();
            GraphicsNode gn;
            gn = builder.build(ctx, srcElems[idx]);
            srcs[idx] = new SoftReference(gn);
            return gn;
        } catch (Exception ex) { ex.printStackTrace();  }

        return null;
    }
}    

