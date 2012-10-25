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
 * Defines the interface expected from a color matrix
 * operation
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: ColorMatrixRable.java 478276 2006-11-22 18:33:37Z dvholten $
 */
public interface ColorMatrixRable extends FilterColorInterpolation {

    /**
     * Identifier used to refer to predefined matrices
     */
    int TYPE_MATRIX             = 0;
    int TYPE_SATURATE           = 1;
    int TYPE_HUE_ROTATE         = 2;
    int TYPE_LUMINANCE_TO_ALPHA = 3;

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
     * Returns the type of this color matrix.
     * @return one of TYPE_MATRIX, TYPE_SATURATE, TYPE_HUE_ROTATE,
     *         TYPE_LUMINANCE_TO_ALPHA
     */
    int getType();

    /**
     * Returns the rows of the color matrix. This uses
     * the same convention as BandCombineOp.
     */
    float[][] getMatrix();

}
