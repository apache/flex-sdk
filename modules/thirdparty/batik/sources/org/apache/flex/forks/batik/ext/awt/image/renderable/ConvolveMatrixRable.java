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

import java.awt.Point;
import java.awt.image.Kernel;

import org.apache.flex.forks.batik.ext.awt.image.PadMode;

/**
 * Convolves an image with a convolution matrix.
 *
 * @author <a href="mailto:Thomas.DeWeeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: ConvolveMatrixRable.java 478276 2006-11-22 18:33:37Z dvholten $
 */
public interface ConvolveMatrixRable extends FilterColorInterpolation {

    /**
     * Returns the source to be Convolved
     */
    Filter getSource();

    /**
     * Sets the source to be Convolved
     * @param src image to Convolved.
     */
    void setSource(Filter src);


    /**
     * Returns the Convolution Kernel in use
     */
    Kernel getKernel();

    /**
     * Sets the Convolution Kernel to use.
     * @param k Kernel to use for convolution.
     */
    void setKernel(Kernel k);

    /**
     * Returns the target point of the kernel (what pixel under the kernel
     * should be set to the result of convolution).
     */
    Point getTarget();

    /**
     * Sets the target point of the kernel (what pixel under the kernel
     * should be set to the result of the convolution).
     */
    void setTarget(Point pt);

    /**
     * Returns the shift value to apply to the result of convolution
     */
    double getBias();

    /**
     * Sets the shift value to apply to the result of convolution
     */
    void setBias(double bias);

    /**
     * Returns the current edge handling mode.
     */
    PadMode getEdgeMode();

    /**
     * Sets the current edge handling mode.
     */
    void setEdgeMode(PadMode edgeMode);

    /**
     * Returns the [x,y] distance in user space between kernel values
     */
    double [] getKernelUnitLength();

    /**
     * Sets the [x,y] distance in user space between kernel values
     * If set to zero then one pixel in device space will be used.
     */
    void setKernelUnitLength(double [] kernelUnitLength);

    /**
     * Returns false if the convolution should affect the Alpha channel
     */
    boolean getPreserveAlpha();

    /**
     * Sets Alpha channel handling.
     * A value of False indicates that the convolution should apply to
     * the Alpha Channel
     */
    void setPreserveAlpha(boolean preserveAlpha);
}

