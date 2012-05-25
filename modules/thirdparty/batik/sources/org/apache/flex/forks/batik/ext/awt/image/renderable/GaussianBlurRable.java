/*

   Copyright 2001  The Apache Software Foundation 

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

/**
 * Implements a GaussianBlur operation, where the blur size is
 * defined by standard deviations along the x and y axis.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: GaussianBlurRable.java,v 1.6 2005/03/27 08:58:33 cam Exp $
 */
public interface GaussianBlurRable extends FilterColorInterpolation {

    /**
     * Returns the source to be Blurred
     */
    public Filter getSource();

    /**
     * Sets the source to be blurred.
     * @param src image to blurred.
     */
    public void setSource(Filter src);

    /**
     * The deviation along the x axis, in user space.
     * @param stdDeviationX should be greater than zero.
     */
    public void setStdDeviationX(double stdDeviationX);

    /**
     * The deviation along the y axis, in user space.
     * @param stdDeviationY should be greater than zero
     */
    public void setStdDeviationY(double stdDeviationY);

    /**
     * Returns the deviation along the x-axis, in user space.
     */
    public double getStdDeviationX();

    /**
     * Returns the deviation along the y-axis, in user space.
     */
    public double getStdDeviationY();
}
