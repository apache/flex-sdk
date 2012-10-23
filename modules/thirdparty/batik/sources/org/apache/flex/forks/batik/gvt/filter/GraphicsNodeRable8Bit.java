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

import java.awt.Composite;
import java.awt.Graphics2D;
import java.awt.color.ColorSpace;
import java.awt.geom.AffineTransform;
import java.awt.geom.Rectangle2D;
import java.awt.image.RenderedImage;
import java.awt.image.renderable.RenderContext;
import java.util.Map;

import org.apache.flex.forks.batik.ext.awt.image.GraphicsUtil;
import org.apache.flex.forks.batik.ext.awt.image.SVGComposite;
import org.apache.flex.forks.batik.ext.awt.image.renderable.AbstractRable;
import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.ext.awt.image.renderable.PaintRable;
import org.apache.flex.forks.batik.ext.awt.image.rendered.CachableRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.TranslateRed;
import org.apache.flex.forks.batik.gvt.GraphicsNode;

/**
 * This implementation of RenderableImage will render its input
 * GraphicsNode into a BufferedImage upon invokation of one of its
 * createRendering methods.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: GraphicsNodeRable8Bit.java 475477 2006-11-15 22:44:28Z cam $
 */
public class GraphicsNodeRable8Bit 
    extends    AbstractRable 
    implements GraphicsNodeRable, PaintRable {

    private AffineTransform cachedGn2dev   = null;
    private AffineTransform cachedUsr2dev  = null;
    private CachableRed     cachedRed      = null;
    private Rectangle2D     cachedBounds = null;
    /**
     * Should GraphicsNodeRable call primitivePaint or Paint.
     */
    private boolean usePrimitivePaint = true;

    /**
     * Returns true if this Rable get's it's contents by calling
     * primitivePaint on the associated <tt>GraphicsNode</tt> or
     * false if it uses paint.
     */
    public boolean getUsePrimitivePaint() {
        return usePrimitivePaint;
    }

    /**
     * Set to true if this Rable should get it's contents by calling
     * primitivePaint on the associated <tt>GraphicsNode</tt> or false
     * if it should use paint.  
     */
    public void setUsePrimitivePaint(boolean usePrimitivePaint) {
        this.usePrimitivePaint = usePrimitivePaint;
    }

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
     * Clear any cached Red.
     */
    public void clearCache() {
        cachedRed     = null;
        cachedUsr2dev = null;
        cachedGn2dev  = null;
        cachedBounds  = null;
    }

    /**
     * @param node The GraphicsNode this image should represent
     */
    public GraphicsNodeRable8Bit(GraphicsNode node){
        if(node == null)
            throw new IllegalArgumentException();

        this.node = node;
        this.usePrimitivePaint = true;
    }

    /**
     * @param node The GraphicsNode this image should represent
     * @param props The Properties for this image.
     */
    public GraphicsNodeRable8Bit(GraphicsNode node,
                                 Map props){
        super((Filter)null, props);

        if(node == null)
            throw new IllegalArgumentException();

        this.node = node;
        this.usePrimitivePaint = true;
    }

    /**
     * @param node      the GraphicsNode this image should represent
     * @param usePrimitivePaint indicates if the image should
     *        include any filters or mask operations on <tt>node</tt>
     */
    public GraphicsNodeRable8Bit(GraphicsNode node, 
                                 boolean      usePrimitivePaint){
        if(node == null)
            throw new IllegalArgumentException();

        this.node = node;
        this.usePrimitivePaint = usePrimitivePaint;
    }

    /**
     * Returns the bounds of this Rable in the user coordinate system.
     */
    public Rectangle2D getBounds2D(){
        if (usePrimitivePaint){
            Rectangle2D primitiveBounds = node.getPrimitiveBounds();
            if(primitiveBounds == null)
                return new Rectangle2D.Double(0, 0, 0, 0);

            return (Rectangle2D)(primitiveBounds.clone());
        }

        // When not using Primitive paint we return out bounds in our
        // parent's user space.  This makes sense since this is the
        // space that we will draw our selves into (since paint unlike
        // primitivePaint incorporates the transform from our user
        // space to our parents user space).
        Rectangle2D bounds = node.getBounds();
        if(bounds == null){
            return new Rectangle2D.Double(0, 0, 0, 0);
        }

        AffineTransform at = node.getTransform();
        if (at != null){
           bounds = at.createTransformedShape(bounds).getBounds2D();
        }
        return bounds;
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
        
        ColorSpace g2dCS = GraphicsUtil.getDestinationColorSpace(g2d);
        if ((g2dCS == null) ||
            (g2dCS != ColorSpace.getInstance(ColorSpace.CS_sRGB))){
            // Only draw directly into sRGB destinations...
            return false;
        }

        // System.out.println("drawImage GNR: " + g2dCS);
        GraphicsNode gn = getGraphicsNode();
        if (getUsePrimitivePaint()){
            gn.primitivePaint(g2d);
        }
        else{
            gn.paint(g2d);
        }

        // Paint did the work...
        return true;
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
        // Get user space to device space transform
        AffineTransform usr2dev = renderContext.getTransform();

        AffineTransform gn2dev;
        if (usr2dev == null) {
            usr2dev = new AffineTransform();
            gn2dev  = usr2dev;
        } else {
            gn2dev = (AffineTransform)usr2dev.clone();
        }

        // Get the nodes transform (so we can pick up changes in this.
        AffineTransform gn2usr = node.getTransform();
        if (gn2usr != null) {
            gn2dev.concatenate(gn2usr);
        }

        Rectangle2D bounds2D = getBounds2D();

        if ((cachedBounds != null)                            &&
            (cachedGn2dev != null)                            &&
            (cachedBounds.equals(bounds2D))                   &&
            (gn2dev.getScaleX()  == cachedGn2dev.getScaleX()) &&
            (gn2dev.getScaleY()  == cachedGn2dev.getScaleY()) &&
            (gn2dev.getShearX()  == cachedGn2dev.getShearX()) &&
            (gn2dev.getShearY()  == cachedGn2dev.getShearY()))
        {
            // Just some form of Translation
            double deltaX = (usr2dev.getTranslateX() - 
                             cachedUsr2dev.getTranslateX());
            double deltaY = (usr2dev.getTranslateY() - 
                             cachedUsr2dev.getTranslateY());

            // System.out.println("Using Cached Red!!! " + 
            //                    deltaX + "x" + deltaY);
            if ((deltaX ==0) && (deltaY == 0))
                // Actually no translation
                return cachedRed;

            // System.out.println("Delta: [" + deltaX + ", " + deltaY + "]");

            // Integer translation in device space..
            if ((deltaX == (int)deltaX) &&
                (deltaY == (int)deltaY)) {
                return new TranslateRed
                    (cachedRed, 
                     (int)Math.round(cachedRed.getMinX()+deltaX),
                     (int)Math.round(cachedRed.getMinY()+deltaY));
            }
        }

        // Fell through let's do a new rendering...
        if (false) {
            System.out.println("Not using Cached Red: " + usr2dev);
            System.out.println("Old:                  " + cachedUsr2dev);
        }

        if((bounds2D.getWidth()  > 0) && 
           (bounds2D.getHeight() > 0)) {
            cachedUsr2dev = (AffineTransform)usr2dev.clone();
            cachedGn2dev  = gn2dev;
            cachedBounds  = bounds2D;
            cachedRed =  new GraphicsNodeRed8Bit
                (node, usr2dev, usePrimitivePaint, 
                 renderContext.getRenderingHints());
            return cachedRed;
        }

        cachedUsr2dev = null;
        cachedGn2dev  = null;
        cachedBounds  = null;
        cachedRed     = null;
        return null;
    }
}
