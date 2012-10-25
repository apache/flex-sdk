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
package org.apache.flex.forks.batik.ext.awt.image.renderable;

import java.awt.geom.Rectangle2D;

import org.apache.flex.forks.batik.ext.awt.image.PadMode;

/**
 * Pads image to the given Rectangle (the rect may be smaller than the
 * image in which case this is actually a crop). The rectangle is
 * specified in the user coordinate system of this Renderable.
 *
 * @author <a href="mailto:Thomas.DeWeeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: PadRable.java 478276 2006-11-22 18:33:37Z dvholten $ */
public interface PadRable extends Filter {
    /**
     * Returns the source to be padded
     */
    Filter getSource();

    /**
     * Sets the source to be padded
     * @param src image to offset.
     */
    void setSource(Filter src);

    /**
     * Set the current rectangle for padding.
     * @param rect the new rectangle to use for pad.
     */
    void setPadRect(Rectangle2D rect);

    /**
     * Get the current rectangle for padding
     * @return Rectangle currently in use for pad.
     */
    Rectangle2D getPadRect();

    /**
     * Set the current extension mode for pad
     * @param mode the new pad mode
     */
    void setPadMode(PadMode mode);

    /**
     * Get the current extension mode for pad
     * @return Mode currently in use for pad
     */
    PadMode getPadMode();
}
