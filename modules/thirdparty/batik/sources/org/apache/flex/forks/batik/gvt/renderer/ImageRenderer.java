/*

   Copyright 2001-2003  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.gvt.renderer;

import java.awt.Rectangle;
import java.awt.image.BufferedImage;
import java.util.Collection;

/**
 * Interface for GVT Renderers that render into raster images.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: ImageRenderer.java,v 1.7 2004/08/18 07:14:38 vhardy Exp $
 */
public interface ImageRenderer extends Renderer{
    /**
     * Update the required size of the offscreen buffer.
     */
    public void updateOffScreen(int width, int height);

    /**
     * Get the Current offscreen buffer used for rendering
     */
    public BufferedImage getOffScreen();

    /**
     * Tells renderer to clear current contents of offscreen buffer
     */
    public void clearOffScreen();

    /**
     * Flush any cached image data (preliminary interface).
     */
    public void flush();

    /**
     * Flush a rectangle of cached image data (preliminary interface).
     */
    public void flush(Rectangle r);

    /**
     * Flush a list of rectangles of cached image data (preliminary
     * interface). Each area are transformed via the usr2dev's renderer
     * transform before the flush(Rectangle) is called.
     */
    public void flush(Collection areas);
}
