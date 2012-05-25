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

import java.awt.geom.Rectangle2D;

/**
 * A renderable that can tile its source into the tile region.
 * 
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: TileRable.java,v 1.4 2004/08/18 07:14:00 vhardy Exp $
 */
public interface TileRable extends FilterColorInterpolation {
    /**
     * Returns the tile region
     */
    public Rectangle2D getTileRegion();

    /**
     * Sets the tile region
     */
    public void setTileRegion(Rectangle2D tileRegion);

    /**
     * Returns the tiled region
     */
    public Rectangle2D getTiledRegion();

    /**
     * Sets the tile region
     */
    public void setTiledRegion(Rectangle2D tiledRegion);

    /**
     * Returns whether or not the source can overflow
     * the tile region or if the tile region should clip
     * the source
     */
    public boolean isOverflow();

    /**
     * Sets the overflow strategy
     */
    public void setOverflow(boolean overflow);

    /**
     * Sets the filter source (the tile content used to fill the 
     * tile region.
     */
    public void setSource(Filter source);

    /**
     * Return's the tile source (the tile content used to fill
     * the tile region.
     */
    public Filter getSource();
}
