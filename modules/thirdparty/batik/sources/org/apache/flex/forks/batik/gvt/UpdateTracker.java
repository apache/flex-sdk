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

import java.awt.Shape;
import java.awt.Rectangle;
import java.awt.geom.AffineTransform;
import java.awt.geom.Rectangle2D;
import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.flex.forks.batik.gvt.event.GraphicsNodeChangeAdapter;
import org.apache.flex.forks.batik.gvt.event.GraphicsNodeChangeEvent;
import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;

/**
 * This class tracks the changes on a GVT tree
 *
 * @author <a href="mailto:Thomas.DeWeeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: UpdateTracker.java 479559 2006-11-27 09:46:16Z dvholten $
 */
public class UpdateTracker extends GraphicsNodeChangeAdapter {

    Map dirtyNodes = null;
    Map fromBounds = new HashMap();
    protected static Rectangle2D NULL_RECT = new Rectangle();

    public UpdateTracker(){
    }

    /**
     * Tells whether the GVT tree has changed.
     */
    public boolean hasChanged() {
        return (dirtyNodes != null);
    }

    /**
     * Returns the list of dirty areas on GVT.
     */
    public List getDirtyAreas() {
        if (dirtyNodes == null)
            return null;

        List ret = new LinkedList();
        Set keys = dirtyNodes.keySet();
        Iterator i = keys.iterator();
        while (i.hasNext()) {
            WeakReference gnWRef = (WeakReference)i.next();
            GraphicsNode  gn     = (GraphicsNode)gnWRef.get();
            // GraphicsNode  srcGN  = gn;

            // if the weak ref has been cleared then this node is no
            // longer part of the GVT tree (and the change should be
            // reflected in some ancestor that should also be in the
            // dirty list).
            if (gn == null) continue;

            AffineTransform oat;
            oat = (AffineTransform)dirtyNodes.get(gnWRef);
            if (oat != null){
                oat = new AffineTransform(oat);
            }

            Rectangle2D srcORgn = (Rectangle2D)fromBounds.remove(gnWRef);

            Rectangle2D srcNRgn = null;
            AffineTransform nat = null;
            if (!(srcORgn instanceof ChngSrcRect)) {
                // For change srcs don't use the new bounds of parent node.
                srcNRgn = gn.getBounds();
                nat = gn.getTransform();
                if (nat != null)
                    nat = new AffineTransform(nat);
            }


            // System.out.println("Rgns: " + srcORgn + " - " + srcNRgn);
            // System.out.println("ATs: " + oat + " - " + nat);
            do {
                // f.invalidateCache(oRng);
                // f.invalidateCache(nRng);

                // f = gn.getEnableBackgroundGraphicsNodeRable(false);
                // (need to push rgn through filter chain if any...)
                // f.invalidateCache(oRng);
                // f.invalidateCache(nRng);

                gn = gn.getParent();
                if (gn == null)
                    break; // We reached the top of the tree

                Filter f= gn.getFilter();
                if ( f != null) {
                    srcNRgn = f.getBounds2D();
                    nat = null;
                }

                // Get the parent's current Affine
                AffineTransform at = gn.getTransform();
                // Get the parent's Affine last time we rendered.
                gnWRef = gn.getWeakReference();
                AffineTransform poat = (AffineTransform)dirtyNodes.get(gnWRef);
                if (poat == null) poat = at;
                if (poat != null) {
                    if (oat != null)
                        oat.preConcatenate(poat);
                    else
                        oat = new AffineTransform(poat);
                }

                if (at != null){
                    if (nat != null)
                        nat.preConcatenate(at);
                    else
                        nat = new AffineTransform(at);
                }
            } while (true);

            if (gn == null) {
                // We made it to the root graphics node so add them.
                // System.out.println
                //      ("Adding: " + oat + " - " + nat + "\n" +
                //       srcORgn + "\n" + srcNRgn + "\n");
                // <!>
                Shape oRgn = srcORgn;
                if ((oRgn != null) && (oRgn != NULL_RECT)) {
                    if (oat != null)
                        oRgn = oat.createTransformedShape(srcORgn);
                    // System.err.println("GN: " + srcGN);
                    // System.err.println("Src: " + oRgn.getBounds2D());
                    ret.add(oRgn);
                }

                if (srcNRgn != null) {
                    Shape nRgn = srcNRgn;
                    if (nat != null)
                        nRgn = nat.createTransformedShape(srcNRgn);
                    if (nRgn != null)
                        ret.add(nRgn);
                }
            }
        }

        fromBounds.clear();
        dirtyNodes.clear();
        return ret;
    }

    /**
     * This returns the dirty region for gn in the coordinate system
     * given by <code>at</code>.
     * @param gn Node tree to return dirty region for.
     * @param at Affine transform to coordinate space to accumulate
     *           dirty regions in.
     */
    public Rectangle2D getNodeDirtyRegion(GraphicsNode gn,
                                          AffineTransform at) {
        WeakReference gnWRef = gn.getWeakReference();
        AffineTransform nat = (AffineTransform)dirtyNodes.get(gnWRef);
        if (nat == null) nat = gn.getTransform();
        if (nat != null) {
            at = new AffineTransform(at);
            at.concatenate(nat);
        }

        Filter f= gn.getFilter();
        Rectangle2D ret = null;
        if (gn instanceof CompositeGraphicsNode) {
            CompositeGraphicsNode cgn = (CompositeGraphicsNode)gn;
            Iterator iter = cgn.iterator();

            while (iter.hasNext()) {
                GraphicsNode childGN = (GraphicsNode)iter.next();
                Rectangle2D r2d = getNodeDirtyRegion(childGN, at);
                if (r2d != null) {
                    if (f != null) {
                        // If we have a filter and a change region
                        // Update our full filter extents.
                        Shape s = at.createTransformedShape(f.getBounds2D());
                        ret = s.getBounds2D();
                        break;
                    }
                    if ((ret == null) || (ret == NULL_RECT)) ret = r2d;
                    //else ret = ret.createUnion(r2d);
                    else ret.add(r2d);
                }
            }
        } else {
            ret = (Rectangle2D)fromBounds.remove(gnWRef);
            if (ret == null) {
                if (f != null) ret = f.getBounds2D();
                else           ret = gn.getBounds();
            } else if (ret == NULL_RECT)
                ret = null;
            if (ret != null)
                ret = at.createTransformedShape(ret).getBounds2D();
        }
        return ret;
    }

    public Rectangle2D getNodeDirtyRegion(GraphicsNode gn) {
        return getNodeDirtyRegion(gn, new AffineTransform());
    }

    /**
     * Receives notification of a change to a GraphicsNode.
     * @param gnce The event object describing the GraphicsNode change.
     */
    public void changeStarted(GraphicsNodeChangeEvent gnce) {
        // System.out.println("A node has changed for: " + this);
        GraphicsNode gn = gnce.getGraphicsNode();
        WeakReference gnWRef = gn.getWeakReference();

        boolean doPut = false;
        if (dirtyNodes == null) {
            dirtyNodes = new HashMap();
            doPut = true;
        } else if (!dirtyNodes.containsKey(gnWRef))
            doPut = true;

        if (doPut) {
            AffineTransform at = gn.getTransform();
            if (at != null) at = (AffineTransform)at.clone();
            else            at = new AffineTransform();
            dirtyNodes.put(gnWRef, at);
        }

        GraphicsNode chngSrc = gnce.getChangeSrc();
        Rectangle2D rgn = null;
        if (chngSrc != null) {
            // A child node is moving in the tree so assign it's dirty
            // regions to this node before it moves.
            Rectangle2D drgn = getNodeDirtyRegion(chngSrc);
            if (drgn != null)
                rgn = new ChngSrcRect(drgn);
        } else {
            // Otherwise just use gn's current region.
            rgn = gn.getBounds();
        }
        // Add this dirty region to any existing dirty region.
        Rectangle2D r2d = (Rectangle2D)fromBounds.remove(gnWRef);
        if (rgn != null) {
            if ((r2d != null) && (r2d != NULL_RECT)) {
                // System.err.println("GN: " + gn);
                // System.err.println("R2d: " + r2d);
                // System.err.println("Rgn: " + rgn);
                //r2d = r2d.createUnion(rgn);
                r2d.add(rgn);
                // System.err.println("Union: " + r2d);
            }
            else             r2d = rgn;
        }

        // if ((gn instanceof CompositeGraphicsNode) &&
        //     (r2d.getWidth() > 200)) {
        //     new Exception("Adding Large: " + gn).printStackTrace();
        // }

        // Store the bounds for the future.
        if (r2d == null)
            r2d = NULL_RECT;
        fromBounds.put(gnWRef, r2d);
    }

    class ChngSrcRect extends Rectangle2D.Float {
        ChngSrcRect(Rectangle2D r2d) {
            super((float)r2d.getX(), (float)r2d.getY(),
                  (float)r2d.getWidth(), (float)r2d.getHeight());
        }
    }

    /**
     * Clears the tracker.
     */
    public void clear() {
        dirtyNodes = null;
    }
}
