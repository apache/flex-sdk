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

/**
 * Implements a Morphology operation, where the kernel size is
 * defined by radius along the x and y axis.
 *
 * @author <a href="mailto:sheng.pei@eng.sun.com">Sheng Pei</a>
 * @version $Id: MorphologyRable.java 478276 2006-11-22 18:33:37Z dvholten $
 */
public interface MorphologyRable extends Filter {
    /**
     * Returns the source to be offset.
     */
    Filter getSource();

    /**
     * Sets the source to be offset.
     * @param src image to offset.
     */
    void setSource(Filter src);

    /**
     * The radius along the x axis, in user space.
     * @param radiusX should be greater than zero.
     */
    void setRadiusX(double radiusX);

    /**
     * The radius along the y axis, in user space.
     * @param radiusY should be greater than zero.
     */
    void setRadiusY(double radiusY);

    /**
     * The switch that determines if the operation
     * is to "dilate" or "erode".
     * @param doDilation do "dilation" when true and "erosion" when false
     */
    void setDoDilation(boolean doDilation);

    /**
     * Returns whether the operation is "dilation" or not("erosion")
     */
    boolean getDoDilation();

    /**
     * Returns the radius along the x-axis, in user space.
     */
    double getRadiusX();

    /**
     * Returns the radius along the y-axis, in user space.
     */
    double getRadiusY();
}
