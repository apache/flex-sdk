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

import java.awt.Shape;
import java.awt.geom.AffineTransform;
import java.awt.geom.NoninvertibleTransformException;
import java.awt.geom.Rectangle2D;
import java.awt.image.RenderedImage;
import java.awt.image.renderable.RenderContext;
import java.util.Iterator;
import java.util.List;
import java.util.ArrayList;

import org.apache.flex.forks.batik.ext.awt.image.CompositeRule;
import org.apache.flex.forks.batik.ext.awt.image.PadMode;
import org.apache.flex.forks.batik.ext.awt.image.renderable.AbstractRable;
import org.apache.flex.forks.batik.ext.awt.image.renderable.AffineRable8Bit;
import org.apache.flex.forks.batik.ext.awt.image.renderable.CompositeRable8Bit;
import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.ext.awt.image.renderable.PadRable8Bit;
import org.apache.flex.forks.batik.gvt.CompositeGraphicsNode;
import org.apache.flex.forks.batik.gvt.GraphicsNode;

/**
* This implementation of RenderableImage will render its input
 * GraphicsNode into a BufferedImage upon invokation of one of its
 * createRendering methods.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: BackgroundRable8Bit.java 479559 2006-11-27 09:46:16Z dvholten $
 */
public class BackgroundRable8Bit
    extends    AbstractRable {

    /**
     * GraphicsNode this image can render
     */
    private GraphicsNode node;

    /**
     * Returns the <tt>GraphicsNode</tt> rendered by this image
     */
    public GraphicsNode getGraphicsNode(){
        return node;
    }

    /**
     * Sets the <tt>GraphicsNode</tt> this image should render
     */
    public void setGraphicsNode(GraphicsNode node){
        if(node == null){
            throw new IllegalArgumentException();
        }

        this.node = node;
    }

    /**
     * @param node The GraphicsNode this image should represent
     */
    public BackgroundRable8Bit(GraphicsNode node){
        if(node == null)
            throw new IllegalArgumentException();

        this.node = node;
    }


    // This is a utilitiy method that unions the bounds of
    // cgn upto child (if child is null it does all children).
    // It unions them with init if provided.
    static Rectangle2D addBounds(CompositeGraphicsNode cgn,
                                 GraphicsNode child,
                                 Rectangle2D  init) {
        // System.out.println("CGN: " + cgn);
        // System.out.println("Child: " + child);

        List children = cgn.getChildren();
        Iterator i = children.iterator();
        Rectangle2D r2d = null;
        while (i.hasNext()) {
            GraphicsNode gn = (GraphicsNode)i.next();
            if (gn == child)
                break;

            // System.out.println("GN: " + gn);
            Rectangle2D cr2d = gn.getBounds();
            AffineTransform at = gn.getTransform();
            if (at != null)
                cr2d = at.createTransformedShape(cr2d).getBounds2D();

            if (r2d == null) r2d = (Rectangle2D)cr2d.clone();
            else             r2d.add(cr2d);
        }

        if (r2d == null) {
            if (init == null)
                return CompositeGraphicsNode.VIEWPORT;

            return init;
        }

        if (init == null)
            return r2d;

        init.add(r2d);

        return init;
    }


    static Rectangle2D getViewportBounds(GraphicsNode gn,
                                         GraphicsNode child) {
        // See if background is enabled.
        Rectangle2D r2d = null;
        if (gn instanceof CompositeGraphicsNode) {
            CompositeGraphicsNode cgn = (CompositeGraphicsNode)gn;
            r2d = cgn.getBackgroundEnable();
        }

        if (r2d == null)
            // No background enable so check our parent's value.
            r2d = getViewportBounds(gn.getParent(), gn);

        // No background for any ancester (error) return null
        if (r2d == null)
            return null;

        // Background enabled is set, but it has no fixed bounds set.
        if (r2d == CompositeGraphicsNode.VIEWPORT) {
            // If we don't have a child then just use our bounds.
            if (child == null)
                return (Rectangle2D)gn.getPrimitiveBounds().clone();

            // gn must be composite so add all it's children's bounds
            // up to child.
            CompositeGraphicsNode cgn = (CompositeGraphicsNode)gn;
            return addBounds(cgn, child, null);
        }

        // We have a partial bound from parent, so map it to gn's
        // coordinate system...
        AffineTransform at = gn.getTransform();
        if (at != null) {
            try {
                at = at.createInverse();
                r2d = at.createTransformedShape(r2d).getBounds2D();
            } catch (NoninvertibleTransformException nte) {
                // Degenerate case return null;
                r2d = null;
            }
        }

        if (child != null) {
            // Add our childrens bounds to it...
            CompositeGraphicsNode cgn = (CompositeGraphicsNode)gn;
            r2d = addBounds(cgn, child, r2d);
        } else {
            Rectangle2D gnb = gn.getPrimitiveBounds();
            if (gnb != null)
                r2d.add(gnb);
        }

        return r2d;
    }

    // This does the leg work for getBounds().
    // It traverses the tree figuring out the bounds of the
    // background image.
    static Rectangle2D getBoundsRecursive(GraphicsNode gn,
                                          GraphicsNode child) {

        Rectangle2D r2d = null;
        if (gn == null) {
            // System.out.println("Null GN Parent: " + child );
            return null;
        }

        if (gn instanceof CompositeGraphicsNode) {
            CompositeGraphicsNode cgn = (CompositeGraphicsNode)gn;
            // See if background is enabled.
            r2d = cgn.getBackgroundEnable();
        }

        // background has definite bounds so return them.
        if (r2d != null)
            return  r2d;

        // No background enable so check our parent's value.
        r2d = getBoundsRecursive(gn.getParent(), gn);

        // No background for any ancester (error) return empty Rect...
        if (r2d == null) {
            // System.out.println("Null GetBoundsRec:" + gn + "\n\t" + child);
            return new Rectangle2D.Float(0, 0, 0, 0);
        }

        // Our parent has background but no bounds (and we must
        // have been the first child so build the new bounds...
        if (r2d == CompositeGraphicsNode.VIEWPORT)
            return r2d;

        AffineTransform at = gn.getTransform();
        if (at != null) {
            try {
                // background has a definite bound so map it to gn's
                // coordinate system...
                at = at.createInverse();
                r2d = at.createTransformedShape(r2d).getBounds2D();
            } catch (NoninvertibleTransformException nte) {
                // Degenerate case return null;
                r2d = null;
            }
        }

        return r2d;
    }

    /**
     * Returns the bounds of this Rable in the user coordinate system.
     */
    public Rectangle2D getBounds2D() {
        // System.out.println("GetBounds2D called");
        Rectangle2D r2d = getBoundsRecursive(node, null);

        // System.out.println("BoundsRec: " + r2d);

        if (r2d == CompositeGraphicsNode.VIEWPORT) {
            r2d = getViewportBounds(node, null);
            // System.out.println("BoundsViewport: " + r2d);
        }

        return r2d;
    }

    /**
     * Returns a filter that represents the background image
     * for <tt>child</tt>.
     * @param gn    Node to get background image for.
     * @param child Child to stop at when compositing children of gn into
     *              the background image.
     * @param aoi   The area of interest for rendering (used to cull
     *              nodes that don't intersect the region to render).
     */
    public Filter getBackground(GraphicsNode gn,
                                GraphicsNode child,
                                Rectangle2D aoi) {
        if (gn == null) {
            throw new IllegalArgumentException
                ("BackgroundImage requested yet no parent has " +
                 "'enable-background:new'");
        }

        Rectangle2D r2d = null;
        if (gn instanceof CompositeGraphicsNode) {
            CompositeGraphicsNode cgn = (CompositeGraphicsNode)gn;
            r2d = cgn.getBackgroundEnable();
        }

        List srcs = new ArrayList();      // this hides a member in a super-class!!
        if (r2d == null) {
            Rectangle2D paoi = aoi;
            AffineTransform at = gn.getTransform();
            if (at != null)
                paoi = at.createTransformedShape(aoi).getBounds2D();
            Filter f = getBackground(gn.getParent(), gn, paoi);

            // Don't add the nodes unless they will contribute.
            if ((f != null) && f.getBounds2D().intersects(aoi)) {
                srcs.add(f);
            }
        }

        if (child != null) {
            CompositeGraphicsNode cgn = (CompositeGraphicsNode)gn;
            List children = cgn.getChildren();
            Iterator i = children.iterator();
            while (i.hasNext()) {
                GraphicsNode childGN = (GraphicsNode)i.next();
                // System.out.println("Parent: "      + cgn +
                //                    "\n  Child: "   + child +
                //                    "\n  ChildGN: " + childGN);
                if (childGN == child)
                    break;

                Rectangle2D cbounds = childGN.getBounds();
                // System.out.println("Child : " + childGN);
                // System.out.println("Bounds: " + cbounds);
                // System.out.println("      : " + aoi);

                AffineTransform at = childGN.getTransform();
                if (at != null)
                    cbounds = at.createTransformedShape(cbounds).getBounds2D();


                if (aoi.intersects(cbounds)) {
                    srcs.add(childGN.getEnableBackgroundGraphicsNodeRable
                             (true));
                }
            }
        }

        if (srcs.size() == 0)
            return null;

        Filter ret = null;
        if (srcs.size() == 1)
            ret = (Filter)srcs.get(0);
        else
            ret = new CompositeRable8Bit(srcs, CompositeRule.OVER, false);

        if (child != null) {
            // We are returning the filter to child so make
            // sure to map the filter from the parents user space
            // to the childs user space...

            AffineTransform at = child.getTransform();
            if (at != null) {
                try {
                    at = at.createInverse();
                    ret = new AffineRable8Bit(ret, at);
                } catch (NoninvertibleTransformException nte) {
                    ret = null;
                }
            }
        }

        return ret;
    }

    /**
     * Returns true if successive renderings (that is, calls to
     * createRendering() or createScaledRendering()) with the same arguments
     * may produce different results.  This method may be used to
     * determine whether an existing rendering may be cached and
     * reused.  It is always safe to return true.
     */
    public boolean isDynamic(){
        return false;
    }

    /**
     * Creates a RenderedImage that represented a rendering of this image
     * using a given RenderContext.  This is the most general way to obtain a
     * rendering of a RenderableImage.
     *
     * <p> The created RenderedImage may have a property identified
     * by the String HINTS_OBSERVED to indicate which RenderingHints
     * (from the RenderContext) were used to create the image.
     * In addition any RenderedImages
     * that are obtained via the getSources() method on the created
     * RenderedImage may have such a property.
     *
     * @param renderContext the RenderContext to use to produce the rendering.
     * @return a RenderedImage containing the rendered data.
     */
    public RenderedImage createRendering(RenderContext renderContext){

        Rectangle2D r2d = getBounds2D();

        // System.out.println("Rendering called");

        Shape aoi = renderContext.getAreaOfInterest();
        if (aoi != null) {
            Rectangle2D aoiR2d = aoi.getBounds2D();
            // System.out.println("R2d: " + r2d);
            // System.out.println("AOI: " + aoiR2d);

            if ( ! r2d.intersects(aoiR2d) )
                return null;

            Rectangle2D.intersect(r2d, aoiR2d, r2d);
        }

        Filter background = getBackground(node, null, r2d);
        // System.out.println("BG: " + background);
        if ( background == null)
            return null;

        background = new PadRable8Bit(background, r2d, PadMode.ZERO_PAD);


        RenderedImage ri = background.createRendering
            (new RenderContext(renderContext.getTransform(), r2d,
                               renderContext.getRenderingHints()));
        // System.out.println("RI: [" + ri.getMinX() + ", "
        //                    + ri.getMinY() + ", " +
        //                    + ri.getWidth() + ", " +
        //                    + ri.getHeight() + "]");
        // org.ImageDisplay.showImage("BG: ", ri);
        return ri;
    }
}
