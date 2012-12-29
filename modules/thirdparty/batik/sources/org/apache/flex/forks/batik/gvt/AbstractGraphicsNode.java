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

import java.awt.AlphaComposite;
import java.awt.Composite;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.Shape;
import java.awt.geom.AffineTransform;
import java.awt.geom.NoninvertibleTransformException;
import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;
import java.lang.ref.WeakReference;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.swing.event.EventListenerList;

import org.apache.flex.forks.batik.ext.awt.RenderingHintsKeyExt;
import org.apache.flex.forks.batik.ext.awt.image.renderable.ClipRable;
import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.gvt.event.GraphicsNodeChangeEvent;
import org.apache.flex.forks.batik.gvt.event.GraphicsNodeChangeListener;
import org.apache.flex.forks.batik.gvt.filter.GraphicsNodeRable;
import org.apache.flex.forks.batik.gvt.filter.GraphicsNodeRable8Bit;
import org.apache.flex.forks.batik.gvt.filter.Mask;
import org.apache.flex.forks.batik.util.HaltingThread;

/**
 * A partial implementation of the <tt>GraphicsNode</tt> interface.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @author <a href="mailto:etissandier@ilog.fr">Emmanuel Tissandier</a>
 * @author <a href="mailto:Thomas.DeWeeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: AbstractGraphicsNode.java 504084 2007-02-06 11:24:46Z dvholten $
 */
public abstract class AbstractGraphicsNode implements GraphicsNode {

    /**
     * The listeners list.
     */
    protected EventListenerList listeners;

    /**
     * The transform of this graphics node.
     */
    protected AffineTransform transform;

    /**
     * The inverse transform for this node, i.e., from parent node
     * to this node.
     */
    protected AffineTransform inverseTransform;

    /**
     * The compositing operation to be used when a graphics node is
     * painted on top of another one.
     */
    protected Composite composite;

    /**
     * This flag bit indicates whether or not this graphics node is visible.
     */
    protected boolean isVisible = true;

    /**
     * The clipping filter for this graphics node.
     */
    protected ClipRable clip;

    /**
     * The rendering hints that control the quality to use when rendering
     * this graphics node.
     */
    protected RenderingHints hints;

    /**
     * The parent of this graphics node.
     */
    protected CompositeGraphicsNode parent;

    /**
     * The root of the GVT tree.
     */
    protected RootGraphicsNode root;

    /**
     * The mask of this graphics node.
     */
    protected Mask mask;

    /**
     * The filter of this graphics node.
     */
    protected Filter filter;

    /**
     * Indicates how this graphics node reacts to events.
     */
    protected int pointerEventType = VISIBLE_PAINTED;

    /**
     * The GraphicsNodeRable for this node.
     */
    protected WeakReference graphicsNodeRable;

    /**
     * The GraphicsNodeRable for this node with all filtering applied
     */
    protected WeakReference enableBackgroundGraphicsNodeRable;

    /**
     * A Weak Reference to this.
     */
    protected WeakReference weakRef;

    /**
     * Internal Cache: node bounds
     */
    private Rectangle2D bounds;


    protected GraphicsNodeChangeEvent changeStartedEvent   = null;
    protected GraphicsNodeChangeEvent changeCompletedEvent = null;

    /**
     * Constructs a new graphics node.
     */
    protected AbstractGraphicsNode() {}

    /**
     * Returns a canonical WeakReference to this GraphicsNode.
     * This is suitable for use as a key value in a hash map
     */
    public WeakReference getWeakReference() {
        if (weakRef == null)
            weakRef =  new WeakReference(this);
        return weakRef;
    }

    //
    // Properties methods
    //

    /**
     * Returns the type that describes how this graphics node reacts to events.
     *
     * @return VISIBLE_PAINTED | VISIBLE_FILL | VISIBLE_STROKE | VISIBLE |
     * PAINTED | FILL | STROKE | ALL | NONE
     */
    public int getPointerEventType() {
        return pointerEventType;
    }

    /**
     * Sets the type that describes how this graphics node reacts to events.
     *
     * @param pointerEventType VISIBLE_PAINTED | VISIBLE_FILL | VISIBLE_STROKE |
     * VISIBLE | PAINTED | FILL | STROKE | ALL | NONE
     */
    public void setPointerEventType(int pointerEventType) {
        this.pointerEventType = pointerEventType;
    }

    /**
     * Sets the transform of this node.
     *
     * @param newTransform the new transform of this node
     */
    public void setTransform(AffineTransform newTransform) {
        fireGraphicsNodeChangeStarted();
        this.transform = newTransform;
        if(transform.getDeterminant() != 0){
            try{
                inverseTransform = transform.createInverse();
            }catch(NoninvertibleTransformException e){
                // Should never happen.
                throw new Error( e.getMessage() );
            }
        } else {
            // The transform is not invertible. Use the same
            // transform.
            inverseTransform = transform;
        }
        if (parent != null)
            parent.invalidateGeometryCache();
        fireGraphicsNodeChangeCompleted();
    }

    /**
     * Returns the transform of this node or null if any.
     */
    public AffineTransform getTransform() {
        return transform;
    }

    /**
     * Returns the inverse transform for this node.
     */
    public AffineTransform getInverseTransform(){
        return inverseTransform;
    }

    /**
     * Returns the concatenated transform of this node. That is, this
     * node's transform preconcatenated with it's parent's transforms.
     */
    public AffineTransform getGlobalTransform(){
        AffineTransform ctm = new AffineTransform();
        GraphicsNode node = this;
        while (node != null) {
            if(node.getTransform() != null){
                ctm.preConcatenate(node.getTransform());
            }
            node = node.getParent();
        }
        return ctm;
    }

    /**
     * Sets the composite of this node.
     *
     * @param newComposite the composite of this node
     */
    public void setComposite(Composite newComposite) {
        fireGraphicsNodeChangeStarted();
        invalidateGeometryCache();
        this.composite = newComposite;
        fireGraphicsNodeChangeCompleted();
    }

    /**
     * Returns the composite of this node or null if any.
     */
    public Composite getComposite() {
        return composite;
    }

    /**
     * Sets if this node is visible or not depending on the specified value.
     *
     * @param isVisible If true this node is visible
     */
    public void setVisible(boolean isVisible) {
        fireGraphicsNodeChangeStarted();
        this.isVisible = isVisible;
        invalidateGeometryCache();
        fireGraphicsNodeChangeCompleted();
    }

    /**
     * Returns true if this node is visible, false otherwise.
     */
    public boolean isVisible() {
        return isVisible;
    }

    public void setClip(ClipRable newClipper) {
        if ((newClipper == null) && (this.clip == null))
            return; // No change still no clip.

        fireGraphicsNodeChangeStarted();
        invalidateGeometryCache();
        this.clip = newClipper;
        fireGraphicsNodeChangeCompleted();
    }

    /**
     * Returns the clipping filter of this node or null if any.
     */
    public ClipRable getClip() {
        return clip;
    }

    /**
     * Maps the specified key to the specified value in the rendering hints of
     * this node.
     *
     * @param key the key of the hint to be set
     * @param value the value indicating preferences for the specified
     * hint category.
     */
    public void setRenderingHint(RenderingHints.Key key, Object value) {
        fireGraphicsNodeChangeStarted();
        if (this.hints == null) {
            this.hints = new RenderingHints(key, value);
        } else {
            hints.put(key, value);
        }
        fireGraphicsNodeChangeCompleted();
    }

    /**
     * Copies all of the mappings from the specified Map to the
     * rendering hints of this node.
     *
     * @param hints the rendering hints to be set
     */
    public void setRenderingHints(Map hints) {
        fireGraphicsNodeChangeStarted();
        if (this.hints == null) {
            this.hints = new RenderingHints(hints);
        } else {
            this.hints.putAll(hints);
        }
        fireGraphicsNodeChangeCompleted();
    }

    /**
     * Sets the rendering hints of this node.
     *
     * @param newHints the new rendering hints of this node
     */
    public void setRenderingHints(RenderingHints newHints) {
        fireGraphicsNodeChangeStarted();
        hints = newHints;
        fireGraphicsNodeChangeCompleted();
    }

    /**
     * Returns the rendering hints of this node or null if any.
     */
    public RenderingHints getRenderingHints() {
        return hints;
    }

    /**
     * Sets the mask of this node.
     *
     * @param newMask the new mask of this node
     */
    public void setMask(Mask newMask) {
        if ((newMask == null) && (mask == null))
            return; // No change still no mask.

        fireGraphicsNodeChangeStarted();
        invalidateGeometryCache();
        mask = newMask;
        fireGraphicsNodeChangeCompleted();
    }

    /**
     * Returns the mask of this node or null if any.
     */
    public Mask getMask() {
        return mask;
    }

    /**
     * Sets the filter of this node.
     *
     * @param newFilter the new filter of this node
     */
    public void setFilter(Filter newFilter) {
        if ((newFilter == null) && (filter == null))
            return; // No change still no filter.

        fireGraphicsNodeChangeStarted();
        invalidateGeometryCache();
        filter = newFilter;
        fireGraphicsNodeChangeCompleted();
    }

    /**
     * Returns the filter of this node or null if any.
     */
    public Filter getFilter() {
        return filter;
    }

    /**
     * Returns the GraphicsNodeRable for this node.  This
     * GraphicsNodeRable is the Renderable (Filter) before any of the
     * filter operations have been applied.
     */
    public Filter getGraphicsNodeRable(boolean createIfNeeded) {
        GraphicsNodeRable ret = null;
        if (graphicsNodeRable != null) {
            ret = (GraphicsNodeRable)graphicsNodeRable.get();
            if (ret != null) return ret;
        }
        if (createIfNeeded) {
        ret = new GraphicsNodeRable8Bit(this);
        graphicsNodeRable = new WeakReference(ret);
        }
        return ret;
    }

    /**
     * Returns the GraphicsNodeRable for this node.  This
     * GraphicsNodeRable is the Renderable (Filter) after all of the
     * filter operations have been applied.
     */
    public Filter getEnableBackgroundGraphicsNodeRable
        (boolean createIfNeeded) {
        GraphicsNodeRable ret = null;
        if (enableBackgroundGraphicsNodeRable != null) {
            ret = (GraphicsNodeRable)enableBackgroundGraphicsNodeRable.get();
            if (ret != null) return ret;
        }
        if (createIfNeeded) {
            ret = new GraphicsNodeRable8Bit(this);
            ret.setUsePrimitivePaint(false);
            enableBackgroundGraphicsNodeRable = new WeakReference(ret);
        }
        return ret;
    }

    //
    // Drawing methods
    //

    /**
     * Paints this node.
     *
     * @param g2d the Graphics2D to use
     */
    public void paint(Graphics2D g2d){
        if ((composite != null) &&
            (composite instanceof AlphaComposite)) {
            AlphaComposite ac = (AlphaComposite)composite;
            if (ac.getAlpha() < 0.001)
                return;         // No point in drawing
        }
        Rectangle2D bounds = getBounds();
        if (bounds == null) return;

        // Set up graphic context. It is important to setup the
        // transform first, because the clip is defined in this node's
        // user space.
        Composite       defaultComposite = null;
        AffineTransform defaultTransform = null;
        RenderingHints  defaultHints     = null;
        Graphics2D      baseG2d          = null;

        if (clip != null)  {
            baseG2d = g2d;
            g2d = (Graphics2D)g2d.create();
            if (hints != null)
                g2d.addRenderingHints(hints);
            if (transform != null)
                g2d.transform(transform);
            if (composite != null)
                g2d.setComposite(composite);
            g2d.clip(clip.getClipPath());
        } else {
            if (hints != null) {
                defaultHints = g2d.getRenderingHints();
                g2d.addRenderingHints(hints);
            }
            if (transform != null) {
                defaultTransform = g2d.getTransform();
                g2d.transform(transform);
            }
            if (composite != null) {
                defaultComposite = g2d.getComposite();
                g2d.setComposite(composite);
            }
        }

        Shape curClip = g2d.getClip();
        g2d.setRenderingHint(RenderingHintsKeyExt.KEY_AREA_OF_INTEREST,
                             curClip);

        // Check if any painting is needed at all. Get the clip (in user space)
        // and see if it intersects with this node's bounds (in user space).
        boolean paintNeeded = true;
        Shape g2dClip = curClip; //g2d.getClip();
        if (g2dClip != null) {
            Rectangle2D cb = g2dClip.getBounds2D();
            if(!bounds.intersects(cb.getX(),     cb.getY(),
                                  cb.getWidth(), cb.getHeight()))
                paintNeeded = false;
        }

        // Only paint if needed.
        if (paintNeeded){
            boolean antialiasedClip = false;
            if ((clip != null) && clip.getUseAntialiasedClip()) {
                antialiasedClip = isAntialiasedClip(g2d.getTransform(),
                                                    g2d.getRenderingHints(),
                                                    clip.getClipPath());
            }

            boolean useOffscreen = isOffscreenBufferNeeded();

            useOffscreen |= antialiasedClip;

            if (!useOffscreen) {
                // Render on this canvas.
                primitivePaint(g2d);
            } else {
                Filter filteredImage = null;

                if(filter == null){
                    filteredImage = getGraphicsNodeRable(true);
                }
                else {
                    // traceFilter(filter, "=====>> ");
                    filteredImage = filter;
                }

                if (mask != null) {
                    if (mask.getSource() != filteredImage){
                        mask.setSource(filteredImage);
                    }
                    filteredImage = mask;
                }

                if (clip != null && antialiasedClip) {
                    if (clip.getSource() != filteredImage){
                        clip.setSource(filteredImage);
                    }
                    filteredImage = clip;
                }

                baseG2d = g2d;
                // Only muck with the clip on a 'child'
                // graphics 2D otherwise when we restore the
                // clip it might 'wander' by a pixel.
                g2d = (Graphics2D)g2d.create();

                if(antialiasedClip){
                    // Remove hard edged clip
                    g2d.setClip(null);
                }

                Rectangle2D filterBounds = filteredImage.getBounds2D();
                g2d.clip(filterBounds);

                org.apache.flex.forks.batik.ext.awt.image.GraphicsUtil.drawImage
                    (g2d, filteredImage);

                g2d.dispose();
                g2d = baseG2d;
                baseG2d = null;// Don't leave null we need g2d restored...
            }
        }

        // Restore default rendering attributes
        if (baseG2d != null) {
            g2d.dispose();
        } else {
            if (defaultHints != null)
                g2d.setRenderingHints(defaultHints);
            if (defaultTransform != null)
                g2d.setTransform(defaultTransform);
            if (defaultComposite != null) {
                g2d.setComposite(defaultComposite);
            }
        }
    }

    /**
     * DEBUG: Trace filter chain
     */
    private void traceFilter(Filter filter, String prefix){
        System.out.println(prefix + filter.getClass().getName());
        System.out.println(prefix + filter.getBounds2D());
        List sources = filter.getSources();
        int nSources = sources != null ? sources.size() : 0;
        prefix += "\t";
        for(int i=0; i<nSources; i++){
            Filter source = (Filter)sources.get(i);
            traceFilter(source, prefix);
        }

        System.out.flush();
    }

    /**
     * Returns true of an offscreen buffer is needed to render this node, false
     * otherwise.
     */
    protected boolean isOffscreenBufferNeeded() {
        return ((filter != null) ||
                (mask != null) ||
                (composite != null &&
                 !AlphaComposite.SrcOver.equals(composite)));
    }

    /**
     * Returns true if there is a clip and it should be antialiased
     */
    protected boolean isAntialiasedClip(AffineTransform usr2dev,
                                        RenderingHints hints,
                                        Shape clip){
        // Antialias clip if:
        // + The KEY_CLIP_ANTIALIASING is true.
        // *and*
        // + clip is not null
        // *and*
        // + clip is not a rectangle in device space.
        //
        // This leaves out the case where the node clip is a
        // rectangle and the current clip (i.e., the intersection
        // of the current Graphics2D's clip and this node's clip)
        // is not a rectangle.
        //
        if (clip == null) return false;

        Object val = hints.get(RenderingHintsKeyExt.KEY_TRANSCODING);
        if ((val == RenderingHintsKeyExt.VALUE_TRANSCODING_PRINTING) ||
            (val == RenderingHintsKeyExt.VALUE_TRANSCODING_VECTOR))
            return false;

        if(!(clip instanceof Rectangle2D &&
             usr2dev.getShearX() == 0 &&
             usr2dev.getShearY() == 0))
            return true;

        return false;
    }

    //
    // Event support methods
    //
    public void fireGraphicsNodeChangeStarted(GraphicsNode changeSrc) {
        if (changeStartedEvent == null)
            changeStartedEvent = new GraphicsNodeChangeEvent
                (this, GraphicsNodeChangeEvent.CHANGE_STARTED);
        changeStartedEvent.setChangeSrc(changeSrc);
        fireGraphicsNodeChangeStarted(changeStartedEvent);
        changeStartedEvent.setChangeSrc(null);
    }

    //
    // Event support methods
    //
    public void fireGraphicsNodeChangeStarted() {
        if (changeStartedEvent == null)
            changeStartedEvent = new GraphicsNodeChangeEvent
                (this, GraphicsNodeChangeEvent.CHANGE_STARTED);
        else {
            changeStartedEvent.setChangeSrc(null);
        }
        fireGraphicsNodeChangeStarted(changeStartedEvent);
    }

    public void fireGraphicsNodeChangeStarted
        (GraphicsNodeChangeEvent changeStartedEvent) {
        // If we had per node listeners we would fire them here...

        RootGraphicsNode rootGN = getRoot();
        if (rootGN == null) return;

        List l = rootGN.getTreeGraphicsNodeChangeListeners();
        if (l == null) return;

        Iterator i = l.iterator();
        GraphicsNodeChangeListener gncl;
        while (i.hasNext()) {
            gncl = (GraphicsNodeChangeListener)i.next();
            gncl.changeStarted(changeStartedEvent);
        }
    }

    public void fireGraphicsNodeChangeCompleted() {
        if (changeCompletedEvent == null) {
            changeCompletedEvent = new GraphicsNodeChangeEvent
                (this, GraphicsNodeChangeEvent.CHANGE_COMPLETED);
        }

        // If we had per node listeners we would fire them here...

        RootGraphicsNode rootGN = getRoot();
        if (rootGN == null) return;

        List l = rootGN.getTreeGraphicsNodeChangeListeners();
        if (l == null) return;

        Iterator i = l.iterator();
        GraphicsNodeChangeListener gncl;
        while (i.hasNext()) {
            gncl = (GraphicsNodeChangeListener)i.next();
            gncl.changeCompleted(changeCompletedEvent);
        }
    }


    //
    // Structural methods
    //

    /**
     * Returns the parent of this node or null if any.
     */
    public CompositeGraphicsNode getParent() {
        return parent;
    }

    /**
     * Returns the root of the GVT tree or null if the node is not part of a GVT
     * tree.
     */
    public RootGraphicsNode getRoot() {
        return root;
    }

    /**
     * Sets the root node of this graphics node.
     *
     * @param newRoot the new root node of this node
     */
    protected void setRoot(RootGraphicsNode newRoot) {
        this.root = newRoot;
    }

    /**
     * Sets the parent node of this graphics node.
     *
     * @param newParent the new parent node of this node
     */
    protected void setParent(CompositeGraphicsNode newParent) {
        this. parent = newParent;
    }

    //
    // Geometric methods
    //

    /**
     * Invalidates the cached geometric bounds. This method is called
     * each time an attribute that affects the bounds of this node
     * changed.
     */
    protected void invalidateGeometryCache() {
        // If our bounds are invalid then our parents bounds
        // must be invalid also. So just return.
        //if (bounds == null) return;

        if (parent != null) {
            parent.invalidateGeometryCache();
        }
        bounds = null;
    }

    /**
     * Returns the bounds of this node in user space. This includes primitive
     * paint, filtering, clipping and masking.
     */
    public Rectangle2D getBounds(){
        // Get the primitive bounds
        // Rectangle2D bounds = null;
        if (bounds == null) {
            // The painted region, before cliping, masking and compositing is
            // either the area painted by the primitive paint or the area
            // painted by the filter.
            if(filter == null){
                bounds = getPrimitiveBounds();
            } else {
                bounds = filter.getBounds2D();
            }
            // Factor in the clipping area, if any
            if(bounds != null){
                if (clip != null) {
                    Rectangle2D clipR = clip.getClipPath().getBounds2D();
                    if (clipR.intersects(bounds))
                        Rectangle2D.intersect(bounds, clipR, bounds);
                }
                // Factor in the mask, if any
                if (mask != null) {
                    Rectangle2D maskR = mask.getBounds2D();
                    if (maskR.intersects(bounds))
                        Rectangle2D.intersect(bounds, maskR, bounds);
                }
            }

            bounds = normalizeRectangle(bounds);

            // Check If we should halt early.
            if (HaltingThread.hasBeenHalted()) {
                // The Thread has been 'halted'.
                // Invalidate any cached values and proceed.
                invalidateGeometryCache();
            }
        }

        return bounds;
    }

    /**
     * Returns the bounds of this node after applying the input transform
     * (if any), concatenated with this node's transform (if any).
     *
     * @param txf the affine transform with which this node's transform should
     *        be concatenated. Should not be null.
     */
    public Rectangle2D getTransformedBounds(AffineTransform txf){
        AffineTransform t = txf;
        if (transform != null) {
            t = new AffineTransform(txf);
            t.concatenate(transform);
        }

        // The painted region, before cliping, masking and compositing
        // is either the area painted by the primitive paint or the
        // area painted by the filter.
        Rectangle2D tBounds = null;
        if (filter == null) {
            // Use txf, not t
            tBounds = getTransformedPrimitiveBounds(txf);
        } else {
            tBounds = t.createTransformedShape
                (filter.getBounds2D()).getBounds2D();
        }
        // Factor in the clipping area, if any
        if (tBounds != null) {
            if (clip != null) {
                Rectangle2D.intersect
                    (tBounds,
                     t.createTransformedShape(clip.getClipPath()).getBounds2D(),
                     tBounds);
            }

            // Factor in the mask, if any
            if(mask != null) {
                Rectangle2D.intersect
                    (tBounds,
                     t.createTransformedShape(mask.getBounds2D()).getBounds2D(),
                     tBounds);
            }
        }

        return tBounds;
    }

    /**
     * Returns the bounds of this node's primitivePaint after applying
     * the input transform (if any), concatenated with this node's
     * transform (if any).
     *
     * @param txf the affine transform with which this node's transform should
     *        be concatenated. Should not be null.  */
    public Rectangle2D getTransformedPrimitiveBounds(AffineTransform txf) {
        Rectangle2D tpBounds = getPrimitiveBounds();
        if (tpBounds == null) {
            return null;
        }
        AffineTransform t = txf;
        if (transform != null) {
            t = new AffineTransform(txf);
            t.concatenate(transform);
        }

        return t.createTransformedShape(tpBounds).getBounds2D();
    }

    /**
     * Returns the bounds of the area covered by this node, without
     * taking any of its rendering attribute into accoun. That is,
     * exclusive of any clipping, masking, filtering or stroking, for
     * example. The returned value is transformed by the concatenation
     * of the input transform and this node's transform.
     *
     * @param txf the affine transform with which this node's transform should
     *        be concatenated. Should not be null.
     */
    public Rectangle2D getTransformedGeometryBounds(AffineTransform txf) {
        Rectangle2D tpBounds = getGeometryBounds();
        if (tpBounds == null) {
            return null;
        }
        AffineTransform t = txf;
        if (transform != null) {
            t = new AffineTransform(txf);
            t.concatenate(transform);
        }

        return t.createTransformedShape(tpBounds).getBounds2D();
    }

    /**
     * Returns the bounds of the sensitive area covered by this node,
     * This includes the stroked area but does not include the effects
     * of clipping, masking or filtering. The returned value is
     * transformed by the concatenation of the input transform and
     * this node's transform.
     *
     * @param txf the affine transform with which this node's
     * transform should be concatenated. Should not be null.
     */
    public Rectangle2D getTransformedSensitiveBounds(AffineTransform txf) {
        Rectangle2D sBounds = getSensitiveBounds();
        if (sBounds == null) {
            return null;
        }
        AffineTransform t = txf;
        if (transform != null) {
            t = new AffineTransform(txf);
            t.concatenate(transform);
        }

        return t.createTransformedShape(sBounds).getBounds2D();
    }

    /**
     * Returns true if the specified Point2D is inside the boundary of this
     * node, false otherwise.
     *
     * @param p the specified Point2D in the user space
     */
    public boolean contains(Point2D p) {
        Rectangle2D b = getSensitiveBounds();
        if (b == null || !b.contains(p)) {
            return false;
        }
        switch(pointerEventType) {
        case VISIBLE_PAINTED:
        case VISIBLE_FILL:
        case VISIBLE_STROKE:
        case VISIBLE:
            return isVisible;
        case PAINTED:
        case FILL:
        case STROKE:
        case ALL:
            return true;
        case NONE:
        default:
            return false;
        }
    }

    /**
     * Returns true if the interior of this node intersects the interior of a
     * specified Rectangle2D, false otherwise.
     *
     * @param r the specified Rectangle2D in the user node space
     */
    public boolean intersects(Rectangle2D r) {
        Rectangle2D b = getBounds();
        if (b == null) return false;

        return b.intersects(r);
    }

    /**
     * Returns the GraphicsNode containing point p if this node or one of its
     * children is sensitive to mouse events at p.
     *
     * @param p the specified Point2D in the user space
     */
    public GraphicsNode nodeHitAt(Point2D p) {
        return (contains(p) ? this : null);
    }

    static double EPSILON = 1e-6;

    /**
     * This method makes sure that neither the width nor height of the
     * rectangle is zero.  But it tries to make them very small
     * relatively speaking.
     */
    protected Rectangle2D normalizeRectangle(Rectangle2D bounds) {
        if (bounds == null) return null;

        if ((bounds.getWidth() < EPSILON)) {
            if (bounds.getHeight() < EPSILON) {
                AffineTransform gt = getGlobalTransform();
                double det = Math.sqrt(gt.getDeterminant());
                return new Rectangle2D.Double
                    (bounds.getX(), bounds.getY(), EPSILON/det, EPSILON/det);
            } else {
                double tmpW = bounds.getHeight()*EPSILON;
                if (tmpW < bounds.getWidth())
                    tmpW = bounds.getWidth();
                return new Rectangle2D.Double
                    (bounds.getX(), bounds.getY(),
                     tmpW, bounds.getHeight());
            }
        } else if (bounds.getHeight() < EPSILON) {
            double tmpH = bounds.getWidth()*EPSILON;
            if (tmpH < bounds.getHeight())
                tmpH = bounds.getHeight();
            return new Rectangle2D.Double
                (bounds.getX(), bounds.getY(),
                 bounds.getWidth(), tmpH);
        }
        return bounds;
    }

}
