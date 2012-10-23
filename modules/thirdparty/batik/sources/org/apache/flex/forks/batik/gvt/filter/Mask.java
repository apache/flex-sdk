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
package org.apache.flex.forks.batik.gvt.filter;

import java.awt.geom.Rectangle2D;

import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.gvt.GraphicsNode;

/**
 * Implements a masking operation.  This masks the source by the result
 * of converting the GraphicsNode to a mask image.
 *
 * @author <a href="mailto:Thomas.DeWeeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: Mask.java 478188 2006-11-22 15:19:17Z dvholten $
 */
public interface Mask extends Filter {
    /**
     * The region to which this mask applies
     */
    Rectangle2D getFilterRegion();

    /**
     * Returns the filter region to which this mask applies
     */
    void setFilterRegion(Rectangle2D filterRegion);

    /**
     * The source to be masked by the mask node.
     * @param src The Image to be masked.
     */
    void setSource(Filter src);

    /**
     * This returns the current image being masked by the mask node.
     * @return The image to mask
     */
    Filter getSource();

    /**
     * Set the masking image to that described by gn.
     * If gn is an rgba image then the alpha is premultiplied and then
     * the rgb is converted to alpha via the standard feColorMatrix
     * rgb to luminance conversion.
     * In the case of an rgb only image, just the rgb to luminance
     * conversion is performed.
     * @param gn The graphics node that defines the mask image.
     */
    void setMaskNode(GraphicsNode gn);

    /**
     * Returns the Graphics node that the mask operation will use to
     * define the masking image.
     * @return The graphics node that defines the mask image.
     */
    GraphicsNode getMaskNode();
}
