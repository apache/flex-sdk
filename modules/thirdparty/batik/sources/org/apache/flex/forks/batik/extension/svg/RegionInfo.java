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
package org.apache.flex.forks.batik.extension.svg;

import java.awt.geom.Rectangle2D;

/**
 * This class holds the neccessary information to render a
 * &lt;batik:flowRegion> that is defined within the &lt;batik:flowRoot>
 * element.  Namely it holds the bounds of the region and the desired
 * vertical alignment.
 *
 * @version $Id: RegionInfo.java 498740 2007-01-22 18:35:57Z dvholten $
 */
public class RegionInfo
       extends Rectangle2D.Float
{
    private float verticalAlignment = 0.0f;

    public RegionInfo(float x, float y, float w, float h,
                      float verticalAlignment) {
        super(x, y, w, h);
        this.verticalAlignment = verticalAlignment;
    }

    /**
     * Gets the vertical alignment for this flow region.
     * @return the vertical alignment for this flow region.
     *         It will be 0.0 for top, 0.5 for middle and 1.0 for bottom.
     */
    public float getVerticalAlignment() {
        return verticalAlignment;
    }

    /**
     * Sets the alignment position of the text within this flow region.
     * The value must be 0.0 for top, 0.5 for middle and 1.0 for bottom.
     * @param verticalAlignment the vertical alignment of the text.
     */
    public void setVerticalAlignment(float verticalAlignment) {
        this.verticalAlignment = verticalAlignment;
    }
}
