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

package org.apache.flex.forks.batik.gvt.flow;

import java.awt.Shape;

/**
 * This class holds the neccessary information to render a
 * &lt;batik:flowRegion> that is defined within the &lt;batik:flowRoot>
 * element.  Namely it holds the bounds of the region and the desired
 * vertical alignment.
 *
 * @author <a href="mailto:thomas.deweese@kodak.com">Thomas DeWeese</a>
 * @version $Id: RegionInfo.java 475477 2006-11-15 22:44:28Z cam $
 */
public class RegionInfo {

    /**
     * The shape that defines the region.
     */
    private Shape shape;

    /**
     * The alignment proportion.
     */
    private float verticalAlignment;

    /**
     * Creates a new RegionInfo with the given shape and alignment.
     */
    public RegionInfo(Shape s, float verticalAlignment) {
        this.shape = s;
        this.verticalAlignment = verticalAlignment;
    }

    /**
     * Returns the flow region shape.
     */
    public Shape getShape() {
        return shape;
    }

    /**
     * Sets the flow region shape.
     */
    public void setShape(Shape s) {
        this.shape = s;
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
