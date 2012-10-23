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

import java.awt.geom.AffineTransform;
import java.awt.Rectangle;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.util.Collection;

/**
 * Interface for GVT Renderers that render into raster images.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: ImageRenderer.java 504760 2007-02-08 01:40:53Z deweese $
 */
public interface ImageRenderer extends Renderer{

    /**
     * release resources associated with this object.
     */
    void dispose();

    /**
     * Update the required size of the offscreen buffer.
     */
    void updateOffScreen(int width, int height);

    /**
     * Sets the transform from the current user space (as defined by
     * the top node of the GVT tree, to the associated device space.
     *
     * @param usr2dev the new user space to device space transform. If null,
     *        the identity transform will be set.
     */
    void setTransform(AffineTransform usr2dev);

    /**
     * Returns the transform from the current user space (as defined
     * by the top node of the GVT tree) to the device space.
     */
    public AffineTransform getTransform();

    /**
     * Sets the specified rendering hints to be used for future renderings.
     * This replaces current set of rendering hints.
     * @param rh the rendering hints to use
     */
    void setRenderingHints(RenderingHints rh);

    /**
     * Returns the rendering hints this ImageRenderer is using for its
     * rendering.
     * @return the rendering hints being used
     */
    RenderingHints getRenderingHints();

    /**
     * Get the Current offscreen buffer used for rendering
     */
    BufferedImage getOffScreen();

    /**
     * Tells renderer to clear current contents of offscreen buffer
     */
    void clearOffScreen();

    /**
     * Flush any cached image data (preliminary interface).
     */
    void flush();

    /**
     * Flush a rectangle of cached image data (preliminary interface).
     */
    void flush(Rectangle r);

    /**
     * Flush a list of rectangles of cached image data (preliminary
     * interface). Each area are transformed via the usr2dev's renderer
     * transform before the flush(Rectangle) is called.
     */
    void flush(Collection areas);
}
