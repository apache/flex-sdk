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
import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;

/**
 * A graphics node that represents an image described as a graphics node.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: ImageNode.java 475477 2006-11-15 22:44:28Z cam $
 */
public class ImageNode extends CompositeGraphicsNode {

    protected boolean hitCheckChildren = false;
    
    /**
     * Constructs a new empty <tt>ImageNode</tt>.
     */
    public ImageNode() {}

    public void setVisible(boolean isVisible) {
        fireGraphicsNodeChangeStarted();
        this.isVisible = isVisible;
        invalidateGeometryCache();
        fireGraphicsNodeChangeCompleted();
    }

    public Rectangle2D getPrimitiveBounds() {
        if (!isVisible)    return null;
        return super.getPrimitiveBounds();
    }
    /**
     * If hitCheckChildren is true then nodeHitAt will return
     * child nodes of this image. Otherwise it will only
     * return this node (if the point is in the image).
     */
    public void setHitCheckChildren(boolean hitCheckChildren) {
        this.hitCheckChildren = hitCheckChildren;
    }

    public boolean getHitCheckChildren() { 
        return hitCheckChildren; 
    }

    /**
     * Paints this node.
     *
     * @param g2d the Graphics2D to use
     */
    public void paint(Graphics2D g2d) {
        if (isVisible) {
            super.paint(g2d);
        }
    }

    /**
     * Returns true if the specified Point2D is inside the boundary of this
     * node, false otherwise.
     *
     * @param p the specified Point2D in the user space
     */
    public boolean contains(Point2D p) {
        switch(pointerEventType) {
        case VISIBLE_PAINTED:
        case VISIBLE_FILL:
        case VISIBLE_STROKE:
        case VISIBLE:
            return isVisible && super.contains(p);
        case PAINTED:
        case FILL:
        case STROKE:
        case ALL:
            return super.contains(p);
        case NONE:
            return false;
        default:
            return false;
        }
    }

    /**
     * Returns the GraphicsNode containing point p if this node or one of its
     * children is sensitive to mouse events at p.
     *
     * @param p the specified Point2D in the user space
     */
    public GraphicsNode nodeHitAt(Point2D p) {
        if (hitCheckChildren) return super.nodeHitAt(p);

        return (contains(p) ? this : null);
    }

    //
    // Properties methods
    //

    /**
     * Sets the graphics node that represents the image.
     *
     * @param newImage the new graphics node that represents the image
     */
    public void setImage(GraphicsNode newImage) {
        fireGraphicsNodeChangeStarted();
        invalidateGeometryCache();
        if (count == 0) ensureCapacity(1);
        children[0] = newImage;
        ((AbstractGraphicsNode)newImage).setParent(this);
        ((AbstractGraphicsNode)newImage).setRoot(getRoot());
        count=1;
        fireGraphicsNodeChangeCompleted();
    }

    /**
     * Returns the graphics node that represents the image.
     */
    public GraphicsNode getImage() {
        if (count > 0) {
            return children[0];
        } else {
            return null;
        }
    }
}
