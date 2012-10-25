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

import java.awt.Shape;
import java.awt.geom.Rectangle2D;
import java.awt.image.renderable.RenderableImage;

/**
 * This is an extension of RenderableImage that adds some needed
 * functionality for tracking dirty regions and determining image
 * dependancies.
 *
 * @author <a href="mailto:Thomas.DeWeeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: Filter.java 478276 2006-11-22 18:33:37Z dvholten $
 */
public interface Filter extends RenderableImage {

    /**
     * Returns the bounds of the current image.
     * This should be 'in sync' with getMinX, getMinY, getWidth, getHeight
     */
    Rectangle2D getBounds2D();

    /**
     * Returns the current modification timestamp on this Renderable
     * node.  This value will change whenever cached output data becomes
     * invalid.
     * @return Current modification timestamp value.
     */
    long getTimeStamp();

    /**
     * Returns the region of input data is is required to generate
     * outputRgn.
     * @param srcIndex  The source to do the dependency calculation for.
     * @param outputRgn The region of output you are interested in
     *  generating dependencies for.  The is given in the user coordiate
     *  system for this node.
     * @return The region of input required.  This is in the user
     * coordinate system for the source indicated by srcIndex.
     */
    Shape getDependencyRegion(int srcIndex, Rectangle2D outputRgn);

    /**
     * This calculates the region of output that is affected by a change
     * in a region of input.
     * @param srcIndex The input that inputRgn reflects changes in.
     * @param inputRgn the region of input that has changed, used to
     *  calculate the returned shape.  This is given in the user
     *  coordinate system of the source indicated by srcIndex.
     * @return The region of output that would be invalid given
     *  a change to inputRgn of the source selected by srcIndex.
     *  this is in the user coordinate system of this node.
     */
    Shape getDirtyRegion(int srcIndex, Rectangle2D inputRgn);
}

