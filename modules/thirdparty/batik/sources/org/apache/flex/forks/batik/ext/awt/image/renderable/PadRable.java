/*

   Copyright 2001,2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.ext.awt.image.renderable;

import java.awt.geom.Rectangle2D;

import org.apache.flex.forks.batik.ext.awt.image.PadMode;

/**
 * Pads image to the given Rectangle (the rect may be smaller than the
 * image in which case this is actually a crop). The rectangle is
 * specified in the user coordinate system of this Renderable.
 *
 * @author <a href="mailto:Thomas.DeWeeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: PadRable.java,v 1.6 2005/03/27 08:58:33 cam Exp $ */
public interface PadRable extends Filter {
    /**
     * Returns the source to be padded
     */
    public Filter getSource();

    /**
     * Sets the source to be padded
     * @param src image to offset.
     */
    public void setSource(Filter src);

    /**
     * Set the current rectangle for padding.
     * @param rect the new rectangle to use for pad.
     */
    public void setPadRect(Rectangle2D rect);

    /**
     * Get the current rectangle for padding
     * @return Rectangle currently in use for pad.
     */
    public Rectangle2D getPadRect();

    /**
     * Set the current extension mode for pad
     * @param mode the new pad mode
     */
    public void setPadMode(PadMode mode);

    /**
     * Get the current extension mode for pad
     * @return Mode currently in use for pad
     */
    public PadMode getPadMode();
}
