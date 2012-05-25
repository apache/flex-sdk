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

import java.util.List;

import org.apache.flex.forks.batik.ext.awt.image.ARGBChannel;

/**
 * Implements a DisplacementMap operation, which takes pixel values from
 * another image to spatially displace the input image
 *
 * @author <a href="mailto:sheng.pei@eng.sun.com">Sheng Pei</a>
 * @version $Id: DisplacementMapRable.java,v 1.7 2005/03/27 08:58:33 cam Exp $
 */
public interface DisplacementMapRable extends FilterColorInterpolation {

    public static final int CHANNEL_R = 1;
    public static final int CHANNEL_G = 2;
    public static final int CHANNEL_B = 3;
    public static final int CHANNEL_A = 4;

    /**
     * The sources to be used in the displacement operation
     * The source at index 0 is displacement by the channels
     * in source at index 1 defined by the xChannelSelector
     * and the yChannelSelector. The displacement amount is
     * defined by the scale attribute.
     *
     * @param srcs The list of images used in the operation.
     */
    public void setSources(List srcs);

    /**
     * The displacement scale factor
     * @param scale can be any number.
     */
    public void setScale(double scale);

    /**
     * Returns the displacement scale factor
     */
    public double getScale();

    /**
     * Select which component values will be used
     * for displacement along the X axis
     * @param xChannelSelector value is among R,
     * G, B and A.
     */
    public void setXChannelSelector(ARGBChannel xChannelSelector);

    /**
     * Returns the xChannelSelector
     */
    public ARGBChannel getXChannelSelector();

    /**
     * Select which component values will be used
     * for displacement along the Y axis
     * @param yChannelSelector value is among R,
     * G, B and A.
     */
    public void setYChannelSelector(ARGBChannel yChannelSelector);

    /**
     * Returns the yChannelSelector
     */
    public ARGBChannel getYChannelSelector();

}
