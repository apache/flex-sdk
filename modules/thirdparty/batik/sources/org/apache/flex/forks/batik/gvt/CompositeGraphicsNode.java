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

import java.awt.Graphics2D;
import java.awt.Rectangle;
import java.awt.Shape;
import java.awt.geom.AffineTransform;
import java.awt.geom.GeneralPath;
import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;
import java.util.Collection;
import java.util.ConcurrentModificationException;
import java.util.Iterator;
import java.util.List;
import java.util.ListIterator;
import java.util.NoSuchElementException;

import org.apache.flex.forks.batik.util.HaltingThread;

/**
 * A CompositeGraphicsNode is a graphics node that can contain graphics nodes.
 *
 * <br>Note: this class is a 'little bit aware of' other threads, but not really threadsafe.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: CompositeGraphicsNode.java 489226 2006-12-21 00:05:36Z cam $
 */
public class CompositeGraphicsNode extends AbstractGraphicsNode
    implements List {

    public static final Rectangle2D VIEWPORT  = new Rectangle();
    public static final Rectangle2D NULL_RECT = new Rectangle();

    /**
     * The children of this composite graphics node.
     */
    protected GraphicsNode [] children;

    /**
     * The number of children of this composite graphics node.
     */
    protected volatile int count;

    /**
     * The number of times the children list has been structurally modified.
     */
    protected volatile int modCount;

    /**
     * This flag indicates if this node has BackgroundEnable = 'new'.
     * If so traversal of the gvt tree can halt here.
     */
    protected Rectangle2D backgroundEnableRgn = null;

    /**
     * Internal Cache: Geometry bounds for this node, not taking into
     * account any of its children rendering attributes into account
     */
    private volatile Rectangle2D geometryBounds;

    /**
     * Internal Cache: Primitive bounds.
     */
    private volatile Rectangle2D primitiveBounds;

    /**
     * Internal Cache: Sensitive bounds.
     */
    private volatile Rectangle2D sensitiveBounds;

    /**
     * Internal Cache: the outline.
     */
    private Shape outline;

    /**
     * Constructs a new empty <tt>CompositeGraphicsNode</tt>.
     */
    public CompositeGraphicsNode() {}

    //
    // Structural methods
    //

    /**
     * Returns the list of children.
     */
    public List getChildren() {
        return this;
    }

    /**
     * Sets the enable background property to the specified rectangle.
     *
     * @param bgRgn the region that defines the background enable property
     */
    public void setBackgroundEnable(Rectangle2D bgRgn) {
        backgroundEnableRgn = bgRgn;
    }

    /**
     * Returns the region defining the background enable property.
     */
    public Rectangle2D getBackgroundEnable() {
        return backgroundEnableRgn;
    }

    /**
     * Sets if this node is visible or not depending on the specified value.
     * Don't fire a graphicsNodeChange event because this doesn't really
     * effect us (it effects our children through CSS inheritence).
     *
     * @param isVisible If true this node is visible
     */
    public void setVisible(boolean isVisible) {
        // fireGraphicsNodeChangeStarted();
        this.isVisible = isVisible;
        // fireGraphicsNodeChangeCompleted();
    }


    //
    // Drawing methods
    //

    /**
     * Paints this node without applying Filter, Mask, Composite, and clip.
     *
     * @param g2d the Graphics2D to use
     */
    public void primitivePaint(Graphics2D g2d) {
        if (count == 0) {
            return;
        }

        // Thread.currentThread() is potentially expensive, so reuse my instance in hasBeenHalted()
        Thread currentThread = Thread.currentThread();

        // Paint children
        for (int i=0; i < count; ++i) {
            if (HaltingThread.hasBeenHalted( currentThread ))
                return;

            GraphicsNode node = children[i];
            if (node == null) {
                continue;
            }
            node.paint(g2d);

        }
    }

    //
    // Event support methods
    //


    //
    // Geometric methods
    //

    /**
     * Invalidates the cached geometric bounds. This method is called
     * each time an attribute that affects the bounds of this node
     * changed.
     */
    protected void invalidateGeometryCache() {
        super.invalidateGeometryCache();
        geometryBounds = null;
        primitiveBounds = null;
        sensitiveBounds = null;
        outline = null;
    }

    /**
     * Returns the bounds of the area covered by this node's primitive paint.
     */
    public Rectangle2D getPrimitiveBounds() {
        if (primitiveBounds != null) {
            if (primitiveBounds == NULL_RECT) return null;
            return primitiveBounds;
        }

        // Thread.currentThread() is potentially expensive, so reuse my instance in hasBeenHalted()
        Thread currentThread = Thread.currentThread();

        int i=0;
        Rectangle2D bounds = null;
        while ((bounds == null) && i < count) {
            bounds = children[i++].getTransformedBounds(IDENTITY);
            if (((i & 0x0F) == 0) && HaltingThread.hasBeenHalted( currentThread ))
                break; // check every 16 children if we have been interrupted.
        }
        if (HaltingThread.hasBeenHalted( currentThread )) {
            invalidateGeometryCache();
            return null;
        }

        if (bounds == null) {
            primitiveBounds = NULL_RECT;
            return null;
        }

        primitiveBounds = bounds;

        while (i < count) {
            Rectangle2D ctb = children[i++].getTransformedBounds(IDENTITY);
            if (ctb != null) {
                if (primitiveBounds == null) {
                    // another thread has set the primitive bounds to null,
                    // need to recall this function
                    return null;
                } else {
                    primitiveBounds.add(ctb);
                }
            }

            if (((i & 0x0F) == 0) && HaltingThread.hasBeenHalted( currentThread ))
                break; // check every 16 children if we have been interrupted.
        }

        // Check If we should halt early.
        if (HaltingThread.hasBeenHalted( currentThread )) {
            // The Thread has been halted.
            // Invalidate any cached values and proceed.
            invalidateGeometryCache();
        }
        return primitiveBounds;
    }

    /**
     * Transforms a Rectangle 2D by an affine transform.  It assumes the transform
     * is only scale/translate so there is no loss of precision over transforming
     * the source geometry.
     */
    public static Rectangle2D  getTransformedBBox(Rectangle2D r2d, AffineTransform t) {
        if ((t  == null) || (r2d == null)) return r2d;

        double x  = r2d.getX();
        double w  = r2d.getWidth();
        double y  = r2d.getY();
        double h  = r2d.getHeight();

        double sx = t.getScaleX();
        double sy = t.getScaleY();
        if (sx < 0) {
            x = -(x + w);
            sx = -sx;
        }
        if (sy < 0) {
            y = -(y + h);
            sy = -sy;
        }

        return new Rectangle2D.Float
            ((float)(x*sx+t.getTranslateX()),
             (float)(y*sy+t.getTranslateY()),
             (float)(w*sx), (float)(h*sy));
    }

    /**
     * Returns the bounds of this node's primitivePaint after applying
     * the input transform (if any), concatenated with this node's
     * transform (if any).
     *
     * @param txf the affine transform with which this node's transform should
     *        be concatenated. Should not be null.
     */
    public Rectangle2D getTransformedPrimitiveBounds(AffineTransform txf) {
        AffineTransform t = txf;
        if (transform != null) {
            t = new AffineTransform(txf);
            t.concatenate(transform);
        }

        if ((t == null) || ((t.getShearX() == 0) && (t.getShearY() == 0))) {
            // No rotation it's safe to simply transform our bounding box.
            return getTransformedBBox(getPrimitiveBounds(), t);
        }

        int i = 0;
        Rectangle2D tpb = null;
        while (tpb == null && i < count) {
            tpb = children[i++].getTransformedBounds(t);
        }

        while (i < count) {
            Rectangle2D ctb = children[i++].getTransformedBounds(t);
            if(ctb != null){
                tpb.add(ctb);
            }
        }

        return tpb;
    }

    /**
     * Returns the bounds of the area covered by this node, without
     * taking any of its rendering attributes into account. That is,
     * exclusive of any clipping, masking, filtering or stroking, for
     * example.
     */
    public Rectangle2D getGeometryBounds() {
        if (geometryBounds == null) {
            // System.err.println("geometryBounds are null");
            int i=0;
            while(geometryBounds == null && i < count){
                geometryBounds =
                children[i++].getTransformedGeometryBounds (IDENTITY);
            }

            while (i<count) {
                Rectangle2D cgb = children[i++].getTransformedGeometryBounds(IDENTITY);
                if (cgb != null) {
                    if (geometryBounds == null) {
                        // another thread has set the geometry bounds to null,
                        // need to recall this function
                        return getGeometryBounds();
                    } else {
                        geometryBounds.add(cgb);
                    }
                }
            }
        }

        return geometryBounds;
    }

    /**
     * Returns the bounds of the area covered by this node, without taking any
     * of its rendering attribute into accoun. That is, exclusive of any clipping,
     * masking, filtering or stroking, for example. The returned value is
     * transformed by the concatenation of the input transform and this node's
     * transform.
     *
     * @param txf the affine transform with which this node's transform should
     *        be concatenated. Should not be null.
     */
    public Rectangle2D getTransformedGeometryBounds(AffineTransform txf) {
        AffineTransform t = txf;
        if (transform != null) {
            t = new AffineTransform(txf);
            t.concatenate(transform);
        }

        if ((t == null) || ((t.getShearX() == 0) && (t.getShearY() == 0))) {
            // No rotation it's safe to simply transform our bounding box.
            return getTransformedBBox(getGeometryBounds(), t);
        }

        Rectangle2D gb = null;
        int i=0;
        while (gb == null && i < count) {
            gb = children[i++].getTransformedGeometryBounds(t);
        }

        Rectangle2D cgb = null;
        while (i < count) {
            cgb = children[i++].getTransformedGeometryBounds(t);
            if (cgb != null) {
                gb.add(cgb);
            }
        }

        return gb;
    }

    /**
     * Returns the bounds of the sensitive area covered by this node,
     * This includes the stroked area but does not include the effects
     * of clipping, masking or filtering.
     */
    public Rectangle2D getSensitiveBounds() {
        if (sensitiveBounds != null)
            return sensitiveBounds;

        // System.out.println("sensitiveBoundsBounds are null");
        int i=0;
        while(sensitiveBounds == null && i < count){
            sensitiveBounds =
                children[i++].getTransformedSensitiveBounds(IDENTITY);
        }

        while (i<count) {
            Rectangle2D cgb = children[i++].getTransformedSensitiveBounds(IDENTITY);
            if (cgb != null) {
                if (sensitiveBounds == null)
                    // another thread has set the geometry bounds to null,
                    // need to recall this function
                    return getSensitiveBounds();

                sensitiveBounds.add(cgb);
            }
        }

        return sensitiveBounds;
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
        AffineTransform t = txf;
        if (transform != null) {
            t = new AffineTransform(txf);
            t.concatenate(transform);
        }

        if ((t == null) || ((t.getShearX() == 0) && (t.getShearY() == 0))) {
            // No rotation it's safe to simply transform our bounding box.
            return getTransformedBBox(getSensitiveBounds(), t);
        }

        Rectangle2D sb = null;
        int i=0;
        while (sb == null && i < count) {
            sb = children[i++].getTransformedSensitiveBounds(t);
        }

        while (i < count) {
            Rectangle2D csb = children[i++].getTransformedSensitiveBounds(t);
            if (csb != null) {
                sb.add(csb);
            }
        }

        return sb;
    }

    /**
     * Returns true if the specified Point2D is inside the boundary of this
     * node, false otherwise.
     *
     * @param p the specified Point2D in the user space
     */
    public boolean contains(Point2D p) {
        Rectangle2D bounds = getSensitiveBounds();
        if (count > 0 && bounds != null && bounds.contains(p)) {
            Point2D pt = null;
            Point2D cp = null; // Propagated to children
            for (int i=0; i < count; ++i) {
                AffineTransform t = children[i].getInverseTransform();
                if(t != null){
                    pt = t.transform(p, pt);
                    cp = pt;
                } else {
                    cp = p;
                }
                if (children[i].contains(cp)) {
                    return true;
                }
            }
        }

        return false;
    }


    /**
     * Returns the GraphicsNode containing point p if this node or one of its
     * children is sensitive to mouse events at p.
     *
     * @param p the specified Point2D in the user space
     */
    public GraphicsNode nodeHitAt(Point2D p) {
        Rectangle2D bounds = getSensitiveBounds();
        if (count > 0 && bounds != null && bounds.contains(p)) {
            // Go backward because the children are in rendering order
            Point2D pt = null;
            Point2D cp = null; // Propagated to children
            for (int i=count-1; i >= 0; --i) {
                AffineTransform t = children[i].getInverseTransform();
                if(t != null){
                    pt = t.transform(p, pt);
                    cp = pt;
                } else {
                    cp = p;
                }
                GraphicsNode node = children[i].nodeHitAt(cp);
                if (node != null) {
                    return node;
                }
            }
        }

        return null;
    }

    /**
     * Returns the outline of this node.
     */
    public Shape getOutline() {
        if (outline != null)
            return outline;

        outline = new GeneralPath();
        for (int i = 0; i < count; i++) {
            Shape childOutline = children[i].getOutline();
            if (childOutline != null) {
                AffineTransform tr = children[i].getTransform();
                if (tr != null) {
                    ((GeneralPath)outline).append(tr.createTransformedShape(childOutline), false);
                } else {
                    ((GeneralPath)outline).append(childOutline, false);
                }
            }
        }

        return outline;
    }

    //
    // Structural info
    //

    /**
     * Sets the root node of this grahics node and modify all its children.
     */
    protected void setRoot(RootGraphicsNode newRoot) {
        super.setRoot(newRoot);
        for (int i=0; i < count; ++i) {
            GraphicsNode node = children[i];
            ((AbstractGraphicsNode)node).setRoot(newRoot);
        }
    }

    //
    // List implementation
    //

    /**
     * Returns the number of children of this composite graphics node.
     */
    public int size() {
        return count;
    }

    /**
     * Returns true if this composite graphics node does not contain
     * graphics node, false otherwise.
     */
    public boolean isEmpty() {
        return (count == 0);
    }

    /**
     * Returns true if this composite graphics node contains the
     * specified graphics node, false otherwise.
     * @param node the node to check
     */
    public boolean contains(Object node) {
        return (indexOf(node) >= 0);
    }

    /**
     * Returns an iterator over the children of this graphics node.
     */
    public Iterator iterator() {
        return new Itr();
    }

    /**
     * Returns an array containing all of the graphics node in the children list
     * of this composite graphics node in the correct order.
     */
    public Object [] toArray() {
        GraphicsNode [] result = new GraphicsNode[count];

        System.arraycopy( children, 0, result, 0, count );

        return result;
    }

    /**
     * Returns an array containing all of the graphics node in the
     * children list of this composite graphics node in the correct
     * order. If the children list fits in the specified array, it is
     * returned therein. Otherwise, a new array is allocated.
     *
     * @param a the array to fit if possible
     */
    public Object[] toArray(Object [] a) {
        if (a.length < count) {
            a = new GraphicsNode[count];
        }
        System.arraycopy(children, 0, a, 0, count);
        if (a.length > count) {
            a[count] = null;
        }
        return a;
    }

    /**
     * Returns the graphics node at the specified position in the children list.
     *
     * @param index the index of the graphics node to return
     * @exception IndexOutOfBoundsException if the index is out of range
     */
    public Object get(int index) {
        checkRange(index);
        return children[index];
    }

    // Modification Operations

    /**
     * Replaces the graphics node at the specified position in the children list
     * with the specified graphics node.
     *
     * @param index the index of the graphics node to replace
     * @param o the graphics node to be stored at the specified position
     * @return the graphics node previously  at the specified position
     * @exception IndexOutOfBoundsException if the index is out of range
     * @exception IllegalArgumentException if the node is not an
     * instance of GraphicsNode
     */
    public Object set(int index, Object o) {
        // Check for correct arguments
        if (!(o instanceof GraphicsNode)) {
            throw new IllegalArgumentException(o+" is not a GraphicsNode");
        }
        checkRange(index);
        GraphicsNode node = (GraphicsNode) o;
        {
            fireGraphicsNodeChangeStarted(node);
        }
        // Reparent the graphics node and tidy up the tree's state
        if (node.getParent() != null) {
            node.getParent().getChildren().remove(node);
        }
        // Replace the node to the children list
        GraphicsNode oldNode = children[index];
        children[index] = node;
        // Set the parents of the graphics nodes
        ((AbstractGraphicsNode) node).setParent(this);
        ((AbstractGraphicsNode) oldNode).setParent(null);
        // Set the root of the graphics node
        ((AbstractGraphicsNode) node).setRoot(this.getRoot());
        ((AbstractGraphicsNode) oldNode).setRoot(null);
        // Invalidates cached values
        invalidateGeometryCache();
        // Create and dispatch events
        // int id = CompositeGraphicsNodeEvent.GRAPHICS_NODE_REMOVED;
        // dispatchEvent(new CompositeGraphicsNodeEvent(this, id, oldNode));
        // id = CompositeGraphicsNodeEvent.GRAPHICS_NODE_ADDED;
        // dispatchEvent(new CompositeGraphicsNodeEvent(this, id, node));
        fireGraphicsNodeChangeCompleted();
        return oldNode;
     }

    /**
     * Adds the specified graphics node to this composite graphics node.
     *
     * @param o the graphics node to add
     * @return true (as per the general contract of Collection.add)
     * @exception IllegalArgumentException if the node is not an
     * instance of GraphicsNode
     */
    public boolean add(Object o) {
        // Check for correct argument
        if (!(o instanceof GraphicsNode)) {
            throw new IllegalArgumentException(o+" is not a GraphicsNode");
        }
        GraphicsNode node = (GraphicsNode) o;
        {
            fireGraphicsNodeChangeStarted(node);
        }
        // Reparent the graphics node and tidy up the tree's state
        if (node.getParent() != null) {
            node.getParent().getChildren().remove(node);
        }
        // Add the graphics node to the children list
        ensureCapacity(count + 1);  // Increments modCount!!
        children[count++] = node;
        // Set the parent of the graphics node
        ((AbstractGraphicsNode) node).setParent(this);
        // Set the root of the graphics node
        ((AbstractGraphicsNode) node).setRoot(this.getRoot());
        // Invalidates cached values
        invalidateGeometryCache();
        // Create and dispatch event
        // int id = CompositeGraphicsNodeEvent.GRAPHICS_NODE_ADDED;
        // dispatchEvent(new CompositeGraphicsNodeEvent(this, id, node));
        fireGraphicsNodeChangeCompleted();
        return true;
    }

    /**
     * Inserts the specified graphics node at the specified position in this
     * children list. Shifts the graphics node currently at that position (if
     * any) and any subsequent graphics nodes to the right (adds one to their
     * indices).
     *
     * @param index the position at which the specified graphics node is to
     * be inserted.
     * @param o the graphics node to be inserted.
     * @exception IndexOutOfBoundsException if the index is out of range
     * @exception IllegalArgumentException if the node is not an
     * instance of GraphicsNode
     */
    public void add(int index, Object o) {
        // Check for correct arguments
        if (!(o instanceof GraphicsNode)) {
            throw new IllegalArgumentException(o+" is not a GraphicsNode");
        }
        if (index > count || index < 0) {
            throw new IndexOutOfBoundsException(
                "Index: "+index+", Size: "+count);
        }
        GraphicsNode node = (GraphicsNode) o;
        {
            fireGraphicsNodeChangeStarted(node);
        }
        // Reparent the graphics node and tidy up the tree's state
        if (node.getParent() != null) {
            node.getParent().getChildren().remove(node);
        }
        // Insert the node to the children list
        ensureCapacity(count+1);  // Increments modCount!!
        System.arraycopy(children, index, children, index+1, count-index);
        children[index] = node;
        count++;
        // Set parent of the graphics node
        ((AbstractGraphicsNode) node).setParent(this);
        // Set root of the graphics node
        ((AbstractGraphicsNode) node).setRoot(this.getRoot());
        // Invalidates cached values
        invalidateGeometryCache();
        // Create and dispatch event
        // int id = CompositeGraphicsNodeEvent.GRAPHICS_NODE_ADDED;
        // dispatchEvent(new CompositeGraphicsNodeEvent(this, id, node));
        fireGraphicsNodeChangeCompleted();
    }

    /**
     * <b>Not supported</b> -
     * Throws <tt>UnsupportedOperationException</tt> exception.
     */
    public boolean addAll(Collection c) {
        throw new UnsupportedOperationException();
    }

    /**
     * <b>Not supported</b> -
     * Throws <tt>UnsupportedOperationException</tt> exception.
     */
    public boolean addAll(int index, Collection c) {
        throw new UnsupportedOperationException();
    }

    /**
     * Removes the first instance of the specified graphics node from the children list.
     *
     * @param o the node the remove
     * @return true if the children list contains the specified graphics node
     * @exception IllegalArgumentException if the node is not an
     * instance of GraphicsNode
     * @exception IndexOutOfBoundsException when o is not in children list
     */
    public boolean remove(Object o) {
        // Check for correct argument
        if (!(o instanceof GraphicsNode)) {
            throw new IllegalArgumentException(o+" is not a GraphicsNode");
        }
        GraphicsNode node = (GraphicsNode) o;
        if (node.getParent() != this) {
            return false;
        }
        // Remove the node
        int index = 0;
        for (; node != children[index]; index++);     // fires exception when node not found!
        remove(index);
        return true;
    }

    /**
     * Removes the graphics node at the specified position in the children list.
     * Shifts any subsequent graphics nodes to the left (subtracts one from
     * their indices).
     *
     * @param index the position of the graphics node to remove
     * @return the graphics node that was removed
     * @exception IndexOutOfBoundsException if index out of range <tt>
     */
    public Object remove(int index) {
        // Check for correct argument
        checkRange(index);
        GraphicsNode oldNode = children[index];
        {
            fireGraphicsNodeChangeStarted(oldNode);
        }
        // Remove the node at the specified index
        modCount++;
        int numMoved = count - index - 1;
        if (numMoved > 0) {
            System.arraycopy(children, index+1, children, index, numMoved);
        }
        children[--count] = null; // Let gc do its work
        if (count == 0) {
            children = null;
        }
        // Set parent of the node
        ((AbstractGraphicsNode) oldNode).setParent(null);
        // Set root of the node
        ((AbstractGraphicsNode) oldNode).setRoot(null);
        // Invalidates cached values
        invalidateGeometryCache();
        // Create and dispatch event
        // int id = CompositeGraphicsNodeEvent.GRAPHICS_NODE_REMOVED;
        // dispatchEvent(new CompositeGraphicsNodeEvent(this, id, oldNode));
        fireGraphicsNodeChangeCompleted();
        return oldNode;
    }

    /**
     * <b>Not supported</b> -
     * Throws <tt>UnsupportedOperationException</tt> exception.
     */
    public boolean removeAll(Collection c) {
        throw new UnsupportedOperationException();
    }

    /**
     * <b>Not supported</b> -
     * Throws <tt>UnsupportedOperationException</tt> exception.
     */
    public boolean retainAll(Collection c) {
        throw new UnsupportedOperationException();
    }

    /**
     * <b>Not supported</b> -
     * Throws <tt>UnsupportedOperationException</tt> exception.
     */
    public void clear() {
        throw new UnsupportedOperationException();
    }

    /**
     * Returns true if this composite graphics node contains all the graphics
     * node in the specified collection, false otherwise.
     *
     * @param c the collection to be checked for containment
     */
    public boolean containsAll(Collection c) {
        Iterator i = c.iterator();
        while (i.hasNext()) {
            if (!contains(i.next())) {
                    return false;
            }
        }
        return true;
    }

    // Search Operations

    /**
     * Returns the index in the children list of the specified graphics node or
     * -1 if the children list does not contain this graphics node.
     *
     * @param node the graphics node to search for
     */
    public int indexOf(Object node) {
        if (node == null || !(node instanceof GraphicsNode)) {
            return -1;
        }
        if (((GraphicsNode) node).getParent() == this) {
            int iCount = count;                  // local is cheaper
            GraphicsNode[] workList = children;  // local is cheaper
            for (int i = 0; i < iCount; i++) {
                if (node == workList[ i ]) {
                    return i;
                }
            }
        }
        return -1;
    }

    /**
     * Returns the index in this children list of the last occurence of the
     * specified graphics node, or -1 if the list does not contain this graphics
     * node.
     *
     * @param node the graphics node to search for
     */
    public int lastIndexOf(Object node) {
        if (node == null || !(node instanceof GraphicsNode)) {
            return -1;
        }
        if (((GraphicsNode) node).getParent() == this) {
            for (int i = count-1; i >= 0; i--) {
                if (node == children[i]) {
                    return i;
                }
            }
        }
        return -1;
    }

    // List Iterators

    /**
     * Returns an iterator over the children of this graphics node.
     */
    public ListIterator listIterator() {
        return listIterator(0);
    }

    /**
     * Returns an iterator over the children of this graphics node, starting at
     * the specified position in the children list.
     *
     * @param index the index of the first graphics node to return
     * from the children list
     */
    public ListIterator listIterator(int index) {
        if (index < 0 || index > count) {
            throw new IndexOutOfBoundsException("Index: "+index);
        }
        return new ListItr(index);
    }

    // View

    /**
     * <b>Not supported</b> -
     * Throws <tt>UnsupportedOperationException</tt> exception.
     */
    public List subList(int fromIndex, int toIndex) {
        throw new UnsupportedOperationException();
    }

    /**
     * Checks if the given index is in range.  If not, throws an appropriate
     * runtime exception.
     *
     * @param index the index to check
     */
    private void checkRange(int index) {
        if (index >= count || index < 0) {
            throw new IndexOutOfBoundsException(
                "Index: "+index+", Size: "+count);
        }
    }

    /**
     * Increases the capacity of the children list, if necessary, to ensure that
     * it can hold at least the number of graphics nodes specified by the
     * minimum capacity argument.
     *
     * @param minCapacity the desired minimum capacity.
     */
    public void ensureCapacity(int minCapacity) {
        if (children == null) {
            children = new GraphicsNode[4];
        }
        modCount++;
        int oldCapacity = children.length;
        if (minCapacity > oldCapacity) {
            GraphicsNode [] oldData = children;
            int newCapacity = oldCapacity + oldCapacity/2 + 1;
            if (newCapacity < minCapacity) {
                newCapacity = minCapacity;
            }
            children = new GraphicsNode[newCapacity];
            System.arraycopy(oldData, 0, children, 0, count);
        }
    }

    /**
     * An implementation of the java.util.Iterator interface.
     */
    private class Itr implements Iterator {

        /**
         * Index of graphics node to be returned by subsequent call to next.
         */
        int cursor = 0;

        /**
         * Index of graphics node returned by most recent call to next or
         * previous.  Reset to -1 if this graphics node is deleted by a call
         * to remove.
         */
        int lastRet = -1;

        /**
         * The modCount value that the iterator believes that the backing
         * List should have.  If this expectation is violated, the iterator
         * has detected concurrent modification.
         */
        int expectedModCount = modCount;

        public boolean hasNext() {
            return cursor != count;
        }

        public Object next() {
            try {
                Object next = get(cursor);
                checkForComodification();
                lastRet = cursor++;
                return next;
            } catch(IndexOutOfBoundsException e) {
                checkForComodification();
                throw new NoSuchElementException();
            }
        }

        public void remove() {
            if (lastRet == -1) {
                throw new IllegalStateException();
            }
            checkForComodification();

            try {
                CompositeGraphicsNode.this.remove(lastRet);
                if (lastRet < cursor) {
                    cursor--;
                }
                lastRet = -1;
                expectedModCount = modCount;
            } catch(IndexOutOfBoundsException e) {
                throw new ConcurrentModificationException();
            }
        }

        final void checkForComodification() {
            if (modCount != expectedModCount) {
                throw new ConcurrentModificationException();
            }
        }
    }


    /**
     * An implementation of the java.util.ListIterator interface.
     */
    private class ListItr extends Itr implements ListIterator {

        ListItr(int index) {
            cursor = index;
        }

        public boolean hasPrevious() {
            return cursor != 0;
        }

        public Object previous() {
            try {
                Object previous = get(--cursor);
                checkForComodification();
                lastRet = cursor;
                return previous;
            } catch(IndexOutOfBoundsException e) {
                checkForComodification();
                throw new NoSuchElementException();
            }
        }

        public int nextIndex() {
            return cursor;
        }

        public int previousIndex() {
            return cursor-1;
        }

        public void set(Object o) {
            if (lastRet == -1) {
                throw new IllegalStateException();
            }
            checkForComodification();
            try {
                CompositeGraphicsNode.this.set(lastRet, o);
                expectedModCount = modCount;
            } catch(IndexOutOfBoundsException e) {
                throw new ConcurrentModificationException();
            }
        }

        public void add(Object o) {
            checkForComodification();
            try {
                CompositeGraphicsNode.this.add(cursor++, o);
                lastRet = -1;
                expectedModCount = modCount;
            } catch(IndexOutOfBoundsException e) {
                throw new ConcurrentModificationException();
            }
        }
    }
}
