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
 * Implements a GaussianBlur operation, where the blur size is
 * defined by standard deviations along the x and y axis.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: GaussianBlurRable.java 478276 2006-11-22 18:33:37Z dvholten $
 */
public interface GaussianBlurRable extends FilterColorInterpolation {

    /**
     * Returns the source to be Blurred
     */
    Filter getSource();

    /**
     * Sets the source to be blurred.
     * @param src image to blurred.
     */
    void setSource(Filter src);

    /**
     * The deviation along the x axis, in user space.
     * @param stdDeviationX should be greater than zero.
     */
    void setStdDeviationX(double stdDeviationX);

    /**
     * The deviation along the y axis, in user space.
     * @param stdDeviationY should be greater than zero
     */
    void setStdDeviationY(double stdDeviationY);

    /**
     * Returns the deviation along the x-axis, in user space.
     */
    double getStdDeviationX();

    /**
     * Returns the deviation along the y-axis, in user space.
     */
    double getStdDeviationY();
}
