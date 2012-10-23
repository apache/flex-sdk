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
import java.awt.Shape;
import java.awt.geom.AffineTransform;
import java.awt.geom.Rectangle2D;

/**
 * A graphics node which provides a placeholder for another graphics node. This
 * node is self defined except that it delegates to the enclosed (proxied)
 * graphics node, its paint routine and bounds computation.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: ProxyGraphicsNode.java 475477 2006-11-15 22:44:28Z cam $ 
 */
public class ProxyGraphicsNode extends AbstractGraphicsNode {

    /**
     * The graphics node to proxy.
     */
    protected GraphicsNode source;

    /**
     * Constructs a new empty proxy graphics node.
     */
    public ProxyGraphicsNode() {}

    /**
     * Sets the graphics node to proxy to the specified graphics node.
     *
     * @param source the graphics node to proxy
     */
    public void setSource(GraphicsNode source) {
        this.source = source;
    }

    /**
     * Returns the proxied graphics node.
     */
    public GraphicsNode getSource() {
        return source;
    }

    /**
     * Paints this node without applying Filter, Mask, Composite and clip.
     *
     * @param g2d the Graphics2D to use
     */
    public void primitivePaint(Graphics2D g2d) {
        if (source != null) {
            source.paint(g2d);
        }
    }

    /**
     * Returns the bounds of the area covered by this node's primitive paint.
     */
    public Rectangle2D getPrimitiveBounds() {
        if (source == null) 
            return null;

        return source.getBounds();
    }

    /**
     * Returns the bounds of this node's primitivePaint after applying
     * the input transform (if any), concatenated with this node's
     * transform (if any).
     *
     * @param txf the affine transform with which this node's transform should
     *        be concatenated. Should not be null.  */
    public Rectangle2D getTransformedPrimitiveBounds(AffineTransform txf) {
        if (source == null) 
            return null;

        AffineTransform t = txf;
        if (transform != null) {
            t = new AffineTransform(txf);
            t.concatenate(transform);
        }
        return source.getTransformedPrimitiveBounds(t);
    }

    /**
     * Returns the bounds of the area covered by this node, without
     * taking any of its rendering attribute into account. That is,
     * exclusive of any clipping, masking, filtering or stroking, for
     * example.
     */
    public Rectangle2D getGeometryBounds() {
        if (source == null) 
            return null;

        return source.getGeometryBounds();
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
    public Rectangle2D getTransformedGeometryBounds(AffineTransform txf) {
        if (source == null) 
            return null;

        AffineTransform t = txf;
        if (transform != null) {
            t = new AffineTransform(txf);
            t.concatenate(transform);
        }
        return source.getTransformedGeometryBounds(t);
    }


    /**
     * Returns the bounds of the sensitive area covered by this node,
     * This includes the stroked area but does not include the effects
     * of clipping, masking or filtering.
     */
    public Rectangle2D getSensitiveBounds() {
        if (source == null) 
            return null;

        return source.getSensitiveBounds();
    }

    /**
     * Returns the outline of this node.
     */
    public Shape getOutline() {
        if (source == null) 
            return null;

        return source.getOutline();
    }
}
