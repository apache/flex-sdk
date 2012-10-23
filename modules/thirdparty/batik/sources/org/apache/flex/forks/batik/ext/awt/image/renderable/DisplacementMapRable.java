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

import java.util.List;

import org.apache.flex.forks.batik.ext.awt.image.ARGBChannel;

/**
 * Implements a DisplacementMap operation, which takes pixel values from
 * another image to spatially displace the input image
 *
 * @author <a href="mailto:sheng.pei@eng.sun.com">Sheng Pei</a>
 * @version $Id: DisplacementMapRable.java 478276 2006-11-22 18:33:37Z dvholten $
 */
public interface DisplacementMapRable extends FilterColorInterpolation {

    int CHANNEL_R = 1;
    int CHANNEL_G = 2;
    int CHANNEL_B = 3;
    int CHANNEL_A = 4;

    /**
     * The sources to be used in the displacement operation
     * The source at index 0 is displacement by the channels
     * in source at index 1 defined by the xChannelSelector
     * and the yChannelSelector. The displacement amount is
     * defined by the scale attribute.
     *
     * @param srcs The list of images used in the operation.
     */
    void setSources(List srcs);

    /**
     * The displacement scale factor
     * @param scale can be any number.
     */
    void setScale(double scale);

    /**
     * Returns the displacement scale factor
     */
    double getScale();

    /**
     * Select which component values will be used
     * for displacement along the X axis
     * @param xChannelSelector value is among R,
     * G, B and A.
     */
    void setXChannelSelector(ARGBChannel xChannelSelector);

    /**
     * Returns the xChannelSelector
     */
    ARGBChannel getXChannelSelector();

    /**
     * Select which component values will be used
     * for displacement along the Y axis
     * @param yChannelSelector value is among R,
     * G, B and A.
     */
    void setYChannelSelector(ARGBChannel yChannelSelector);

    /**
     * Returns the yChannelSelector
     */
    ARGBChannel getYChannelSelector();

}
