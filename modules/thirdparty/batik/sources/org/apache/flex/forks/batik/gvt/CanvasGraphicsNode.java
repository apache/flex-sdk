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
import java.awt.Paint;
import java.awt.geom.AffineTransform;
import java.awt.geom.NoninvertibleTransformException;

/**
 * The graphics node container with a background color.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: CanvasGraphicsNode.java 504084 2007-02-06 11:24:46Z dvholten $
 */
public class CanvasGraphicsNode extends CompositeGraphicsNode {

    /**
     * This is the position transform for this graphics node.
     * This is needed because getCTM returns the transform
     * to the viewport coordinate system which is after viewing but
     * before positioning.
     */
    protected AffineTransform positionTransform;
    /**
     * This is the viewing transform for this graphics node.
     * This is needed because getCTM returns the transform
     * to the viewport coordinate system which is after viewing but
     * before positioning.
     */
    protected AffineTransform viewingTransform;

    /**
     * The background of this canvas graphics node.
     */
    protected Paint backgroundPaint;

    /**
     * Constructs a new empty <tt>CanvasGraphicsNode</tt>.
     */
    public CanvasGraphicsNode() {}

    //
    // Properties methods
    //

    /**
     * Sets the background paint of this canvas graphics node.
     *
     * @param newBackgroundPaint the new background paint
     */
    public void setBackgroundPaint(Paint newBackgroundPaint) {
        this.backgroundPaint = newBackgroundPaint;
    }

    /**
     * Returns the background paint of this canvas graphics node.
     */
    public Paint getBackgroundPaint() {
        return backgroundPaint;
    }

    public void setPositionTransform(AffineTransform at) {
        fireGraphicsNodeChangeStarted();
        invalidateGeometryCache();
        this.positionTransform = at;
        if (positionTransform != null) {
            transform = new AffineTransform(positionTransform);
            if (viewingTransform != null)
                transform.concatenate(viewingTransform);
        } else if (viewingTransform != null)
            transform = new AffineTransform(viewingTransform);
        else
            transform = new AffineTransform();

        if (transform.getDeterminant() != 0){
            try{
                inverseTransform = transform.createInverse();
            }catch(NoninvertibleTransformException e){
                // Should never happen.
                throw new Error( e.getMessage() );
            }
        }
        else{
            // The transform is not invertible. Use the same
            // transform.
            inverseTransform = transform;
        }
        fireGraphicsNodeChangeCompleted();
    }

    public AffineTransform getPositionTransform() {
        return positionTransform;
    }

    public void setViewingTransform(AffineTransform at) {
        fireGraphicsNodeChangeStarted();
        invalidateGeometryCache();
        this.viewingTransform = at;
        if (positionTransform != null) {
            transform = new AffineTransform(positionTransform);
            if (viewingTransform != null)
                transform.concatenate(viewingTransform);
        } else if (viewingTransform != null)
            transform = new AffineTransform(viewingTransform);
        else
            transform = new AffineTransform();

        if(transform.getDeterminant() != 0){
            try{
                inverseTransform = transform.createInverse();
            }catch(NoninvertibleTransformException e){
                // Should never happen.
                throw new Error( e.getMessage() );
            }
        }
        else{
            // The transform is not invertible. Use the same
            // transform.
            inverseTransform = transform;
        }
        fireGraphicsNodeChangeCompleted();
    }

    public AffineTransform getViewingTransform() {
        return viewingTransform;
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
        if (backgroundPaint != null) {
            g2d.setPaint(backgroundPaint);
            g2d.fill(g2d.getClip()); // Fast paint for huge background area
        }
        super.primitivePaint(g2d);
    }
}
