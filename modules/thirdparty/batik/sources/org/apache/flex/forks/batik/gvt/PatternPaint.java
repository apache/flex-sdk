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
package org.apache.flex.forks.batik.gvt;

import java.awt.Paint;
import java.awt.PaintContext;
import java.awt.Rectangle;
import java.awt.RenderingHints;
import java.awt.geom.AffineTransform;
import java.awt.geom.Rectangle2D;
import java.awt.image.ColorModel;
import java.awt.image.Raster;

import org.apache.flex.forks.batik.ext.awt.image.PadMode;
import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.ext.awt.image.renderable.PadRable8Bit;

/**
 * The PatternPaint class provides a way to fill a Shape with a a pattern
 * defined as a GVT Tree.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: PatternPaint.java 478188 2006-11-22 15:19:17Z dvholten $
 */
public class PatternPaint implements Paint {

    /**
     * The <tt>GraphicsNode</tt> that this <tt>Paint</tt> uses to
     * produce the pixel pattern
     */
    private GraphicsNode node;

    /**
     * The region to which this paint is constrained
     */
    private Rectangle2D patternRegion;

    /**
     * Additional pattern transform, added on top of the
     * user space to device space transform (i.e., before
     * the tiling space
     */
    private AffineTransform patternTransform;

    /*
     * The basic tile to fill the region with.
     * we replicate this out in the Context.
     */
    private Filter tile;

    /**
     * Controls whether or not the pattern overflows
     * the pattern tile
     */
    private boolean overflow;

    private PatternPaintContext lastContext;

    /**
     * Constructs a new <tt>PatternPaint</tt>.
     *
     * @param node Used to generate the paint pixel pattern
     * @param patternRegion Region to which this paint is constrained
     * @param overflow controls whether or not the node can overflow
     *        the patternRegion.
     * @param patternTransform additional transform added on
     *        top of the user space to device space transform.
     */
    public PatternPaint(GraphicsNode node,
                        Rectangle2D patternRegion,
                        boolean overflow,
                        AffineTransform patternTransform){

        if (node == null) {
            throw new IllegalArgumentException();
        }

        if (patternRegion == null) {
            throw new IllegalArgumentException();
        }

        this.node             = node;
        this.patternRegion    = patternRegion;
        this.overflow         = overflow;
        this.patternTransform = patternTransform;

        // Wrap the input node so that the primitivePaint
        // in GraphicsNodeRable takes the filter, clip....
        // into account.
        CompositeGraphicsNode comp = new CompositeGraphicsNode();
        comp.getChildren().add(node);
        Filter gnr = comp.getGraphicsNodeRable(true);

        Rectangle2D padBounds = (Rectangle2D)patternRegion.clone();

        // When there is overflow, make sure we take the full node bounds into
        // account.
        if (overflow) {
            Rectangle2D nodeBounds = comp.getBounds();
            // System.out.println("Comp Bounds    : " + nodeBounds);
            // System.out.println("Node Bounds    : " + node.getBounds(gnrc));
            padBounds.add(nodeBounds);
        }

        // System.out.println("Pattern region : " + patternRegion);
        // System.out.println("Node txf       : " + node.getTransform());
        tile = new PadRable8Bit(gnr, padBounds, PadMode.ZERO_PAD);
    }

    /**
     * Returns the graphics node that define the pattern.
     */
    public GraphicsNode getGraphicsNode(){
        return node;
    }

    /**
     * Returns the pattern region.
     */
    public Rectangle2D getPatternRect(){
        return (Rectangle2D)patternRegion.clone();
    }

    /**
     * Returns the additional transform of the pattern paint.
     */
    public AffineTransform getPatternTransform(){
        return patternTransform;
    }

    public boolean getOverflow() {
        return overflow;
    }

    /**
     * Creates and returns a context used to generate the pattern.
     */
    public PaintContext createContext(ColorModel      cm,
                                      Rectangle       deviceBounds,
                                      Rectangle2D     userBounds,
                                      AffineTransform xform,
                                      RenderingHints  hints) {
        // Concatenate the patternTransform to xform
        if (patternTransform != null) {
            xform = new AffineTransform(xform);
            xform.concatenate(patternTransform);
        }

        if ((lastContext!= null) &&
            lastContext.getColorModel().equals(cm)) {

            double[] p = new double[6];
            double[] q = new double[6];
            xform.getMatrix(p);
            lastContext.getUsr2Dev().getMatrix(q);
            if ((p[0] == q[0]) && (p[1] == q[1]) &&
                (p[2] == q[2]) && (p[3] == q[3])) {
                if ((p[4] == q[4]) && (p[5] == q[5]))
                    return lastContext;
                else
                    return new PatternPaintContextWrapper
                        (lastContext,
                         (int)(q[4]-p[4]+0.5),
                         (int)(q[5]-p[5]+0.5));
            }
        }
        // System.out.println("CreateContext Called: " + this);
        // System.out.println("CM : " + cm);
        // System.out.println("xForm : " + xform);

        lastContext = new PatternPaintContext(cm, xform,
                                       hints, tile,
                                       patternRegion,
                                       overflow);
        return lastContext;
    }

    /**
     * Returns the transparency mode for this pattern paint.
     */
    public int getTransparency(){
        return TRANSLUCENT;
    }

    static class PatternPaintContextWrapper implements PaintContext {
        PatternPaintContext ppc;
        int xShift, yShift;
        PatternPaintContextWrapper(PatternPaintContext ppc,
                            int xShift, int yShift) {
            this.ppc = ppc;
            this.xShift = xShift;
            this.yShift = yShift;
        }

        public void dispose(){ }

        public ColorModel getColorModel(){
            return ppc.getColorModel();
        }
        public Raster getRaster(int x, int y, int width, int height){
            return ppc.getRaster(x+xShift, y+yShift, width, height);
        }
    }
}
