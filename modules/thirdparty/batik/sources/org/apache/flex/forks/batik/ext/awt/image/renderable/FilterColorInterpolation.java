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

import java.awt.color.ColorSpace;

/**
 * This is an extension of our Filter interface that adds support for
 * a color-interpolation specification which indicates what colorspace the
 * operation should take place in.
 *
 * @author <a href="mailto:Thomas.DeWeeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: FilterColorInterpolation.java,v 1.3 2004/08/18 07:13:59 vhardy Exp $
 */
public interface FilterColorInterpolation extends Filter {

    /**
     * Returns true if this operation is to be performed in
     * the linear sRGB colorspace, returns false if the
     * operation is performed in gamma corrected sRGB.
     */
    public boolean isColorSpaceLinear();

    /**
     * Sets the colorspace the operation will be performed in.
     * @param csLinear if true this operation will be performed in the
     * linear sRGB colorspace, if false the operation will be performed in
     * gamma corrected sRGB.
     */
    public void setColorSpaceLinear(boolean csLinear);

    /**
     * Returns the ColorSpace that the object will perform
     * it's work in.
     */
    public ColorSpace getOperationColorSpace();
}
