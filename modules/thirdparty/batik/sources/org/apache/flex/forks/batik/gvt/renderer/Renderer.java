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
package org.apache.flex.forks.batik.gvt.renderer;

import java.awt.Shape;
import java.awt.geom.AffineTransform;

import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.ext.awt.geom.RectListManager;

/**
 * Interface for GVT Renderers.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: Renderer.java 478188 2006-11-22 15:19:17Z dvholten $
 */
public interface Renderer {

    /**
     * This associates the given GVT Tree with this renderer.
     * Any previous tree association is forgotten.
     * Not certain if this should be just GraphicsNode, or CanvasGraphicsNode.
     */
    void setTree(GraphicsNode treeRoot);

    /**
     * Returns the GVT tree associated with this renderer
     */
    GraphicsNode getTree();

    /**
     * Repaints the associated GVT tree at least under <tt>area</tt>.
     *
     * @param area the region to be repainted, in the current user
     * space coordinate system.
     */
    void repaint(Shape area);

    /**
     * Repaints the associated GVT tree at least in areas under the
     * list of <tt>areas</tt>.
     *
     * @param areas a List of regions to be repainted, in the current
     * user space coordinate system.
     */
    void repaint(RectListManager areas);

    /**
     * Sets the transform from the current user space (as defined by
     * the top node of the GVT tree, to the associated device space.
     */
    void setTransform(AffineTransform usr2dev);

    /**
     * Returns a copy of the transform from the current user space (as
     * defined by the top node of the GVT tree) to the device space (1
     * unit = 1/72nd of an inch / 1 pixel, roughly speaking
     */
    AffineTransform getTransform();

    /**
     * Returns true if the Renderer is currently doubleBuffering is
     * rendering requests.  If it is then getOffscreen will only
     * return completed renderings (or null if nothing is available).
     */
    boolean isDoubleBuffered();

    /**
     * Turns on/off double buffering in renderer.  Turning off
     * double buffering makes it possible to see the ongoing results
     * of a render operation.
     */
    void setDoubleBuffered(boolean isDoubleBuffered);

    /**
     * Cause the renderer to ask to be removed from external reference
     * lists, de-register as a listener to events, etc.  This is so that
     * in the absence of other existing references, it can be
     * removed by the garbage collector.
     */
    void dispose();

}

