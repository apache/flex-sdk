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
package org.apache.flex.forks.batik.ext.awt.g2d;

import java.awt.AlphaComposite;
import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Composite;
import java.awt.Font;
import java.awt.Paint;
import java.awt.Rectangle;
import java.awt.RenderingHints;
import java.awt.Shape;
import java.awt.Stroke;
import java.awt.font.FontRenderContext;
import java.awt.geom.AffineTransform;
import java.awt.geom.Area;
import java.awt.geom.GeneralPath;
import java.awt.geom.NoninvertibleTransformException;
import java.util.Map;
import java.util.List;
import java.util.ArrayList;

/**
 * Handles the attributes in a graphic context:<br>
 * + Composite <br>
 * + Font <br>
 * + Paint <br>
 * + Stroke <br>
 * + Clip <br>
 * + RenderingHints <br>
 * + AffineTransform <br>
 *
 * @author <a href="mailto:cjolif@ilog.fr">Christophe Jolif</a>
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: GraphicContext.java 479564 2006-11-27 09:56:57Z dvholten $
 */
public class GraphicContext implements Cloneable{
    /**
     * Default Transform to be used for creating FontRenderContext.
     */
    protected AffineTransform defaultTransform = new AffineTransform();

    /**
     * Current AffineTransform. This is the concatenation
     * of the original AffineTransform (i.e., last setTransform
     * invocation) and the following transform invocations,
     * as captured by originalTransform and the transformStack.
     */
    protected AffineTransform transform = new AffineTransform();

    /**
     * Transform stack
     */
    protected List transformStack = new ArrayList();

    /**
     * Defines whether the transform stack is valide or not.
     * This is for use by the class clients. The client should
     * validate the stack every time it starts using it. The
     * stack becomes invalid when a new transform is set.
     * @see #invalidateTransformStack()
     * @see #isTransformStackValid
     * @see #setTransform
     */
    protected boolean transformStackValid = true;

    /**
     * Current Paint
     */
    protected Paint paint = Color.black;

    /**
     * Current Stroke
     */
    protected Stroke stroke = new BasicStroke();

    /**
     * Current Composite
     */
    protected Composite composite = AlphaComposite.SrcOver;

    /**
     * Current clip
     */
    protected Shape clip = null;

    /**
     * Current set of RenderingHints
     */
    protected RenderingHints hints = new RenderingHints(null);

    /**
     * Current Font
     */
    protected Font font = new Font("sanserif", Font.PLAIN, 12);

    /**
     * Current background color.
     */
    protected Color background = new Color(0, 0, 0, 0);

    /**
     * Current foreground color
     */
    protected Color foreground = Color.black;

    /**
     * Default constructor
     */
    public GraphicContext() {
        // to workaround a JDK bug
        hints.put(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_DEFAULT);
    }

    /**
     * @param defaultDeviceTransform Default affine transform applied to map the user space to the
     *                               user space.
     */
    public GraphicContext(AffineTransform defaultDeviceTransform) {
        this();
        defaultTransform = new AffineTransform(defaultDeviceTransform);
        transform = new AffineTransform(defaultTransform);
        if (!defaultTransform.isIdentity())
            transformStack.add(TransformStackElement.createGeneralTransformElement(defaultTransform));
    }

    /**
     * @return a deep copy of this context
     */
    public Object clone(){
        GraphicContext copyGc = new GraphicContext(defaultTransform);

        //
        // Now, copy each GC element in turn
        //

        // Default transform
        /* Set in constructor */

        // Transform
        copyGc.transform = new AffineTransform(this.transform);

        // Transform stack
        copyGc.transformStack = new ArrayList( transformStack.size() );
        for(int i=0; i<this.transformStack.size(); i++){
            TransformStackElement stackElement =
                (TransformStackElement)this.transformStack.get(i);
            copyGc.transformStack.add(stackElement.clone());
        }

        // Transform stack validity
        copyGc.transformStackValid = this.transformStackValid;

        // Paint (immutable by requirement)
        copyGc.paint = this.paint;

        // Stroke (immutable by requirement)
        copyGc.stroke = this.stroke;

        // Composite (immutable by requirement)
        copyGc.composite = this.composite;

        // Clip
        if(clip != null)
            copyGc.clip = new GeneralPath(clip);
        else
            copyGc.clip = null;

        // RenderingHints
        copyGc.hints = (RenderingHints)this.hints.clone();

        // Font (immutable)
        copyGc.font = this.font;

        // Background, Foreground (immutable)
        copyGc.background = this.background;
        copyGc.foreground = this.foreground;

        return copyGc;
    }

    /**
     * Gets this graphics context's current color.
     * @return    this graphics context's current color.
     * @see       java.awt.Color
     * @see       java.awt.Graphics#setColor
     */
    public Color getColor(){
        return foreground;
    }

    /**
     * Sets this graphics context's current color to the specified
     * color. All subsequent graphics operations using this graphics
     * context use this specified color.
     * @param     c   the new rendering color.
     * @see       java.awt.Color
     * @see       java.awt.Graphics#getColor
     */
    public void setColor(Color c){
        if(c == null)
            return;

        if(paint != c)
            setPaint(c);
    }

    /**
     * Gets the current font.
     * @return    this graphics context's current font.
     * @see       java.awt.Font
     * @see       java.awt.Graphics#setFont
     */
    public Font getFont(){
        return font;
    }

    /**
     * Sets this graphics context's font to the specified font.
     * All subsequent text operations using this graphics context
     * use this font.
     * @param  font   the font.
     * @see     java.awt.Graphics#getFont
     */
    public void setFont(Font font){
        if(font != null)
            this.font = font;
    }

    /**
     * Returns the bounding rectangle of the current clipping area.
     * This method refers to the user clip, which is independent of the
     * clipping associated with device bounds and window visibility.
     * If no clip has previously been set, or if the clip has been
     * cleared using <code>setClip(null)</code>, this method returns
     * <code>null</code>.
     * The coordinates in the rectangle are relative to the coordinate
     * system origin of this graphics context.
     * @return      the bounding rectangle of the current clipping area,
     *              or <code>null</code> if no clip is set.
     * @see         java.awt.Graphics#getClip
     * @see         java.awt.Graphics#clipRect
     * @see         java.awt.Graphics#setClip(int, int, int, int)
     * @see         java.awt.Graphics#setClip(Shape)
     * @since       JDK1.1
     */
    public Rectangle getClipBounds(){
        Shape c = getClip();
        if(c==null)
            return null;
        else
            return c.getBounds();
    }


    /**
     * Intersects the current clip with the specified rectangle.
     * The resulting clipping area is the intersection of the current
     * clipping area and the specified rectangle.  If there is no
     * current clipping area, either because the clip has never been
     * set, or the clip has been cleared using <code>setClip(null)</code>,
     * the specified rectangle becomes the new clip.
     * This method sets the user clip, which is independent of the
     * clipping associated with device bounds and window visibility.
     * This method can only be used to make the current clip smaller.
     * To set the current clip larger, use any of the setClip methods.
     * Rendering operations have no effect outside of the clipping area.
     * @param x the x coordinate of the rectangle to intersect the clip with
     * @param y the y coordinate of the rectangle to intersect the clip with
     * @param width the width of the rectangle to intersect the clip with
     * @param height the height of the rectangle to intersect the clip with
     * @see #setClip(int, int, int, int)
     * @see #setClip(Shape)
     */
    public void clipRect(int x, int y, int width, int height){
        clip(new Rectangle(x, y, width, height));
    }


    /**
     * Sets the current clip to the rectangle specified by the given
     * coordinates.  This method sets the user clip, which is
     * independent of the clipping associated with device bounds
     * and window visibility.
     * Rendering operations have no effect outside of the clipping area.
     * @param       x the <i>x</i> coordinate of the new clip rectangle.
     * @param       y the <i>y</i> coordinate of the new clip rectangle.
     * @param       width the width of the new clip rectangle.
     * @param       height the height of the new clip rectangle.
     * @see         java.awt.Graphics#clipRect
     * @see         java.awt.Graphics#setClip(Shape)
     * @since       JDK1.1
     */
    public void setClip(int x, int y, int width, int height){
        setClip(new Rectangle(x, y, width, height));
    }


    /**
     * Gets the current clipping area.
     * This method returns the user clip, which is independent of the
     * clipping associated with device bounds and window visibility.
     * If no clip has previously been set, or if the clip has been
     * cleared using <code>setClip(null)</code>, this method returns
     * <code>null</code>.
     * @return      a <code>Shape</code> object representing the
     *              current clipping area, or <code>null</code> if
     *              no clip is set.
     * @see         java.awt.Graphics#getClipBounds()
     * @see         java.awt.Graphics#clipRect
     * @see         java.awt.Graphics#setClip(int, int, int, int)
     * @see         java.awt.Graphics#setClip(Shape)
     * @since       JDK1.1
     */
    public Shape getClip(){
        try{
            return transform.createInverse().createTransformedShape(clip);
        }catch(NoninvertibleTransformException e){
            return null;
        }
    }


    /**
     * Sets the current clipping area to an arbitrary clip shape.
     * Not all objects that implement the <code>Shape</code>
     * interface can be used to set the clip.  The only
     * <code>Shape</code> objects that are guaranteed to be
     * supported are <code>Shape</code> objects that are
     * obtained via the <code>getClip</code> method and via
     * <code>Rectangle</code> objects.  This method sets the
     * user clip, which is independent of the clipping associated
     * with device bounds and window visibility.
     * @param clip the <code>Shape</code> to use to set the clip
     * @see         java.awt.Graphics#getClip()
     * @see         java.awt.Graphics#clipRect
     * @see         java.awt.Graphics#setClip(int, int, int, int)
     * @since       JDK1.1
     */
    public void setClip(Shape clip) {
        if (clip != null)
            this.clip = transform.createTransformedShape(clip);
        else
            this.clip = null;
    }

    /**
     * Sets the <code>Composite</code> for the <code>Graphics2D</code> context.
     * The <code>Composite</code> is used in all drawing methods such as
     * <code>drawImage</code>, <code>drawString</code>, <code>draw</code>,
     * and <code>fill</code>.  It specifies how new pixels are to be combined
     * with the existing pixels on the graphics device during the rendering
     * process.
     * <p>If this <code>Graphics2D</code> context is drawing to a
     * <code>Component</code> on the display screen and the
     * <code>Composite</code> is a custom object rather than an
     * instance of the <code>AlphaComposite</code> class, and if
     * there is a security manager, its <code>checkPermission</code>
     * method is called with an <code>AWTPermission("readDisplayPixels")</code>
     * permission.
     *
     * @param comp the <code>Composite</code> object to be used for rendering
     * @throws SecurityException
     *         if a custom <code>Composite</code> object is being
     *         used to render to the screen and a security manager
     *         is set and its <code>checkPermission</code> method
     *         does not allow the operation.
     * @see java.awt.Graphics#setXORMode
     * @see java.awt.Graphics#setPaintMode
     * @see java.awt.AlphaComposite
     */
    public void setComposite(Composite comp){
        this.composite = comp;
    }


    /**
     * Sets the <code>Paint</code> attribute for the
     * <code>Graphics2D</code> context.  Calling this method
     * with a <code>null</code> <code>Paint</code> object does
     * not have any effect on the current <code>Paint</code> attribute
     * of this <code>Graphics2D</code>.
     * @param paint the <code>Paint</code> object to be used to generate
     * color during the rendering process, or <code>null</code>
     * @see java.awt.Graphics#setColor
     * @see java.awt.GradientPaint
     * @see java.awt.TexturePaint
     */
    public void setPaint( Paint paint ){
        if(paint == null)
            return;

        this.paint = paint;
        if(paint instanceof Color)
            foreground = (Color)paint;
    }


    /**
     * Sets the <code>Stroke</code> for the <code>Graphics2D</code> context.
     * @param s the <code>Stroke</code> object to be used to stroke a
     * <code>Shape</code> during the rendering process
     * @see BasicStroke
     */
    public void setStroke(Stroke s){
        stroke = s;
    }

    /**
     * Sets the value of a single preference for the rendering algorithms.
     * Hint categories include controls for rendering quality and overall
     * time/quality trade-off in the rendering process.  Refer to the
     * <code>RenderingHints</code> class for definitions of some common
     * keys and values.
     * @param hintKey the key of the hint to be set.
     * @param hintValue the value indicating preferences for the specified
     * hint category.
     * @see RenderingHints
     */
    public void setRenderingHint(RenderingHints.Key hintKey, Object hintValue){
        hints.put(hintKey, hintValue);
    }


    /**
     * Returns the value of a single preference for the rendering algorithms.
     * Hint categories include controls for rendering quality and overall
     * time/quality trade-off in the rendering process.  Refer to the
     * <code>RenderingHints</code> class for definitions of some common
     * keys and values.
     * @param hintKey the key corresponding to the hint to get.
     * @return an object representing the value for the specified hint key.
     * Some of the keys and their associated values are defined in the
     * <code>RenderingHints</code> class.
     * @see RenderingHints
     */
    public Object getRenderingHint(RenderingHints.Key hintKey){
        return hints.get(hintKey);
    }


    /**
     * Replaces the values of all preferences for the rendering
     * algorithms with the specified <code>hints</code>.
     * The existing values for all rendering hints are discarded and
     * the new set of known hints and values are initialized from the
     * specified {@link Map} object.
     * Hint categories include controls for rendering quality and
     * overall time/quality trade-off in the rendering process.
     * Refer to the <code>RenderingHints</code> class for definitions of
     * some common keys and values.
     * @param hints the rendering hints to be set
     * @see RenderingHints
     */
    public void setRenderingHints(Map hints){
        this.hints = new RenderingHints(hints);
    }


    /**
     * Sets the values of an arbitrary number of preferences for the
     * rendering algorithms.
     * Only values for the rendering hints that are present in the
     * specified <code>Map</code> object are modified.
     * All other preferences not present in the specified
     * object are left unmodified.
     * Hint categories include controls for rendering quality and
     * overall time/quality trade-off in the rendering process.
     * Refer to the <code>RenderingHints</code> class for definitions of
     * some common keys and values.
     * @param hints the rendering hints to be set
     * @see RenderingHints
     */
    public void addRenderingHints(Map hints){
        this.hints.putAll(hints);
    }


    /**
     * Gets the preferences for the rendering algorithms.  Hint categories
     * include controls for rendering quality and overall time/quality
     * trade-off in the rendering process.
     * Returns all of the hint key/value pairs that were ever specified in
     * one operation.  Refer to the
     * <code>RenderingHints</code> class for definitions of some common
     * keys and values.
     * @return a reference to an instance of <code>RenderingHints</code>
     * that contains the current preferences.
     * @see RenderingHints
     */
    public RenderingHints getRenderingHints(){
        return hints;
    }

    /**
     * Translates the origin of the graphics context to the point
     * (<i>x</i>,&nbsp;<i>y</i>) in the current coordinate system.
     * Modifies this graphics context so that its new origin corresponds
     * to the point (<i>x</i>,&nbsp;<i>y</i>) in this graphics context's
     * original coordinate system.  All coordinates used in subsequent
     * rendering operations on this graphics context will be relative
     * to this new origin.
     * @param  x   the <i>x</i> coordinate.
     * @param  y   the <i>y</i> coordinate.
     */
    public void translate(int x, int y){
        if(x!=0 || y!=0){
            transform.translate(x, y);
            transformStack.add(TransformStackElement.createTranslateElement(x, y));
        }
    }


    /**
     * Concatenates the current
     * <code>Graphics2D</code> <code>Transform</code>
     * with a translation transform.
     * Subsequent rendering is translated by the specified
     * distance relative to the previous position.
     * This is equivalent to calling transform(T), where T is an
     * <code>AffineTransform</code> represented by the following matrix:
     * <pre>
     *          [   1    0    tx  ]
     *          [   0    1    ty  ]
     *          [   0    0    1   ]
     * </pre>
     * @param tx the distance to translate along the x-axis
     * @param ty the distance to translate along the y-axis
     */
    public void translate(double tx, double ty){
        transform.translate(tx, ty);
        transformStack.add(TransformStackElement.createTranslateElement(tx, ty));
    }

    /**
     * Concatenates the current <code>Graphics2D</code>
     * <code>Transform</code> with a rotation transform.
     * Subsequent rendering is rotated by the specified radians relative
     * to the previous origin.
     * This is equivalent to calling <code>transform(R)</code>, where R is an
     * <code>AffineTransform</code> represented by the following matrix:
     * <pre>
     *          [   cos(theta)    -sin(theta)    0   ]
     *          [   sin(theta)     cos(theta)    0   ]
     *          [       0              0         1   ]
     * </pre>
     * Rotating with a positive angle theta rotates points on the positive
     * x axis toward the positive y axis.
     * @param theta the angle of rotation in radians
     */
    public void rotate(double theta){
        transform.rotate(theta);
        transformStack.add(TransformStackElement.createRotateElement(theta));
    }

    /**
     * Concatenates the current <code>Graphics2D</code>
     * <code>Transform</code> with a translated rotation
     * transform.  Subsequent rendering is transformed by a transform
     * which is constructed by translating to the specified location,
     * rotating by the specified radians, and translating back by the same
     * amount as the original translation.  This is equivalent to the
     * following sequence of calls:
     * <pre>
     *          translate(x, y);
     *          rotate(theta);
     *          translate(-x, -y);
     * </pre>
     * Rotating with a positive angle theta rotates points on the positive
     * x axis toward the positive y axis.
     * @param theta the angle of rotation in radians
     * @param x x coordinate of the origin of the rotation
     * @param y y coordinate of the origin of the rotation
     */
    public void rotate(double theta, double x, double y){
        transform.rotate(theta, x, y);
        transformStack.add(TransformStackElement.createTranslateElement(x, y));
        transformStack.add(TransformStackElement.createRotateElement(theta));
        transformStack.add(TransformStackElement.createTranslateElement(-x, -y));
    }

    /**
     * Concatenates the current <code>Graphics2D</code>
     * <code>Transform</code> with a scaling transformation
     * Subsequent rendering is resized according to the specified scaling
     * factors relative to the previous scaling.
     * This is equivalent to calling <code>transform(S)</code>, where S is an
     * <code>AffineTransform</code> represented by the following matrix:
     * <pre>
     *          [   sx   0    0   ]
     *          [   0    sy   0   ]
     *          [   0    0    1   ]
     * </pre>
     * @param sx the amount by which X coordinates in subsequent
     * rendering operations are multiplied relative to previous
     * rendering operations.
     * @param sy the amount by which Y coordinates in subsequent
     * rendering operations are multiplied relative to previous
     * rendering operations.
     */
    public void scale(double sx, double sy){
        transform.scale(sx, sy);
        transformStack.add(TransformStackElement.createScaleElement(sx, sy));
    }

    /**
     * Concatenates the current <code>Graphics2D</code>
     * <code>Transform</code> with a shearing transform.
     * Subsequent renderings are sheared by the specified
     * multiplier relative to the previous position.
     * This is equivalent to calling <code>transform(SH)</code>, where SH
     * is an <code>AffineTransform</code> represented by the following
     * matrix:
     * <pre>
     *          [   1   shx   0   ]
     *          [  shy   1    0   ]
     *          [   0    0    1   ]
     * </pre>
     * @param shx the multiplier by which coordinates are shifted in
     * the positive X axis direction as a function of their Y coordinate
     * @param shy the multiplier by which coordinates are shifted in
     * the positive Y axis direction as a function of their X coordinate
     */
    public void shear(double shx, double shy){
        transform.shear(shx, shy);
        transformStack.add(TransformStackElement.createShearElement(shx, shy));
    }

    /**
     * Composes an <code>AffineTransform</code> object with the
     * <code>Transform</code> in this <code>Graphics2D</code> according
     * to the rule last-specified-first-applied.  If the current
     * <code>Transform</code> is Cx, the result of composition
     * with Tx is a new <code>Transform</code> Cx'.  Cx' becomes the
     * current <code>Transform</code> for this <code>Graphics2D</code>.
     * Transforming a point p by the updated <code>Transform</code> Cx' is
     * equivalent to first transforming p by Tx and then transforming
     * the result by the original <code>Transform</code> Cx.  In other
     * words, Cx'(p) = Cx(Tx(p)).  A copy of the Tx is made, if necessary,
     * so further modifications to Tx do not affect rendering.
     * @param Tx the <code>AffineTransform</code> object to be composed with
     * the current <code>Transform</code>
     * @see #setTransform
     * @see AffineTransform
     */
    public void transform(AffineTransform Tx){
        transform.concatenate(Tx);
        transformStack.add(TransformStackElement.createGeneralTransformElement(Tx));
    }

    /**
     * Sets the <code>Transform</code> in the <code>Graphics2D</code>
     * context.
     * @param Tx the <code>AffineTransform</code> object to be used in the
     * rendering process
     * @see #transform
     * @see AffineTransform
     */
    public void setTransform(AffineTransform Tx){
        transform = new AffineTransform(Tx);
        invalidateTransformStack();
        if(!Tx.isIdentity())
            transformStack.add(TransformStackElement.createGeneralTransformElement(Tx));
    }

    /**
     * Marks the GraphicContext's isNewTransformStack to false
     * as a memento that the current transform stack was read and
     * has not been reset. Only the setTransform method can
     * override this memento.
     */
    public void validateTransformStack(){
        transformStackValid = true;
    }

    /**
     * Checks the status of the transform stack
     */
    public boolean isTransformStackValid(){
        return transformStackValid;
    }

    /**
     * @return array containing the successive transforms that
     *         were concatenated with the original one.
     */
    public TransformStackElement[] getTransformStack(){
        TransformStackElement[] stack = new TransformStackElement[transformStack.size()];
        transformStack.toArray( stack );
        return stack;
    }

    /**
     * Marks the GraphicContext's isNewTransformStack to true
     * as a memento that the current transform stack was reset
     * since it was last read. Only validateTransformStack
     * can override this memento
     */
    protected void invalidateTransformStack(){
        transformStack.clear();
        transformStackValid = false;
    }

    /**
     * Returns a copy of the current <code>Transform</code> in the
     * <code>Graphics2D</code> context.
     * @return the current <code>AffineTransform</code> in the
     *             <code>Graphics2D</code> context.
     * @see #transform
     * @see #setTransform
     */
    public AffineTransform getTransform(){
        return new AffineTransform(transform);
    }

    /**
     * Returns the current <code>Paint</code> of the
     * <code>Graphics2D</code> context.
     * @return the current <code>Graphics2D</code> <code>Paint</code>,
     * which defines a color or pattern.
     * @see #setPaint
     * @see java.awt.Graphics#setColor
     */
    public Paint getPaint(){
        return paint;
    }


    /**
     * Returns the current <code>Composite</code> in the
     * <code>Graphics2D</code> context.
     * @return the current <code>Graphics2D</code> <code>Composite</code>,
     *              which defines a compositing style.
     * @see #setComposite
     */
    public Composite getComposite(){
        return composite;
    }

    /**
     * Sets the background color for the <code>Graphics2D</code> context.
     * The background color is used for clearing a region.
     * When a <code>Graphics2D</code> is constructed for a
     * <code>Component</code>, the background color is
     * inherited from the <code>Component</code>. Setting the background color
     * in the <code>Graphics2D</code> context only affects the subsequent
     * <code>clearRect</code> calls and not the background color of the
     * <code>Component</code>.  To change the background
     * of the <code>Component</code>, use appropriate methods of
     * the <code>Component</code>.
     * @param color the background color that isused in
     * subsequent calls to <code>clearRect</code>
     * @see #getBackground
     * @see java.awt.Graphics#clearRect
     */
    public void setBackground(Color color){
        if(color == null)
            return;

        background = color;
    }


    /**
     * Returns the background color used for clearing a region.
     * @return the current <code>Graphics2D</code> <code>Color</code>,
     * which defines the background color.
     * @see #setBackground
     */
    public Color getBackground(){
        return background;
    }

    /**
     * Returns the current <code>Stroke</code> in the
     * <code>Graphics2D</code> context.
     * @return the current <code>Graphics2D</code> <code>Stroke</code>,
     *                 which defines the line style.
     * @see #setStroke
     */
    public Stroke getStroke(){
        return stroke;
    }


    /**
     * Intersects the current <code>Clip</code> with the interior of the
     * specified <code>Shape</code> and sets the <code>Clip</code> to the
     * resulting intersection.  The specified <code>Shape</code> is
     * transformed with the current <code>Graphics2D</code>
     * <code>Transform</code> before being intersected with the current
     * <code>Clip</code>.  This method is used to make the current
     * <code>Clip</code> smaller.
     * To make the <code>Clip</code> larger, use <code>setClip</code>.
     * The <i>user clip</i> modified by this method is independent of the
     * clipping associated with device bounds and visibility.  If no clip has
     * previously been set, or if the clip has been cleared using
     * {@link java.awt.Graphics#setClip(Shape) setClip} with a
     * <code>null</code> argument, the specified <code>Shape</code> becomes
     * the new user clip.
     * @param s the <code>Shape</code> to be intersected with the current
     *          <code>Clip</code>.  If <code>s</code> is <code>null</code>,
     *          this method clears the current <code>Clip</code>.
     */
    public void clip(Shape s){
        if (s != null)
            s = transform.createTransformedShape(s);

        if (clip != null) {
            Area newClip = new Area(clip);
            newClip.intersect(new Area(s));
            clip = new GeneralPath(newClip);
        } else {
            clip = s;
        }
    }

    /**
     * Get the rendering context of the <code>Font</code> within this
     * <code>Graphics2D</code> context.
     * The {@link FontRenderContext}
     * encapsulates application hints such as anti-aliasing and
     * fractional metrics, as well as target device specific information
     * such as dots-per-inch.  This information should be provided by the
     * application when using objects that perform typographical
     * formatting, such as <code>Font</code> and
     * <code>TextLayout</code>.  This information should also be provided
     * by applications that perform their own layout and need accurate
     * measurements of various characteristics of glyphs such as advance
     * and line height when various rendering hints have been applied to
     * the text rendering.
     *
     * @return a reference to an instance of FontRenderContext.
     * @see java.awt.font.FontRenderContext
     * @see java.awt.Font#createGlyphVector(FontRenderContext,char[])
     * @see java.awt.font.TextLayout
     * @since     JDK1.2
     */
    public FontRenderContext getFontRenderContext(){
        //
        // Find if antialiasing should be used.
        //
        Object antialiasingHint = hints.get(RenderingHints.KEY_TEXT_ANTIALIASING);
        boolean isAntialiased = true;
        if(antialiasingHint != RenderingHints.VALUE_TEXT_ANTIALIAS_ON &&
           antialiasingHint != RenderingHints.VALUE_TEXT_ANTIALIAS_DEFAULT){

            // If antialias was not turned off, then use the general rendering
            // hint.
            if(antialiasingHint != RenderingHints.VALUE_TEXT_ANTIALIAS_OFF){
                antialiasingHint = hints.get(RenderingHints.KEY_ANTIALIASING);

                // Test general hint
                if(antialiasingHint != RenderingHints.VALUE_ANTIALIAS_ON &&
                   antialiasingHint != RenderingHints.VALUE_ANTIALIAS_DEFAULT){
                    // Antialiasing was not requested. However, if it was not turned
                    // off explicitly, use it.
                    if(antialiasingHint == RenderingHints.VALUE_ANTIALIAS_OFF)
                        isAntialiased = false;
                }
            }
            else
                isAntialiased = false;

        }

        //
        // Find out whether fractional metrics should be used.
        //
        boolean useFractionalMetrics = true;
        if(hints.get(RenderingHints.KEY_FRACTIONALMETRICS)
           == RenderingHints.VALUE_FRACTIONALMETRICS_OFF)
            useFractionalMetrics = false;

        FontRenderContext frc = new FontRenderContext(defaultTransform,
                                                      isAntialiased,
                                                      useFractionalMetrics);
        return frc;
    }
}
