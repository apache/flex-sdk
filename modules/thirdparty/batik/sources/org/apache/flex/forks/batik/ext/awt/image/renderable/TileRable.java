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

import java.awt.geom.Rectangle2D;

/**
 * A renderable that can tile its source into the tile region.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: TileRable.java 478276 2006-11-22 18:33:37Z dvholten $
 */
public interface TileRable extends FilterColorInterpolation {
    /**
     * Returns the tile region
     */
    Rectangle2D getTileRegion();

    /**
     * Sets the tile region
     */
    void setTileRegion(Rectangle2D tileRegion);

    /**
     * Returns the tiled region
     */
    Rectangle2D getTiledRegion();

    /**
     * Sets the tile region
     */
    void setTiledRegion(Rectangle2D tiledRegion);

    /**
     * Returns whether or not the source can overflow
     * the tile region or if the tile region should clip
     * the source
     */
    boolean isOverflow();

    /**
     * Sets the overflow strategy
     */
    void setOverflow(boolean overflow);

    /**
     * Sets the filter source (the tile content used to fill the
     * tile region.
     */
    void setSource(Filter source);

    /**
     * Return's the tile source (the tile content used to fill
     * the tile region.
     */
    Filter getSource();
}
