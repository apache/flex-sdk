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
package org.apache.flex.forks.batik.ext.awt.image.rendered;

import  java.awt.image.Raster;


/**
 * This the generic interface for a TileStore.  This is used to
 * store and retrieve tiles from the cache.
 *
 * @version $Id: TileStore.java 498740 2007-01-22 18:35:57Z dvholten $
 */
public interface TileStore {

    void setTile(int x, int y, Raster ras);

    Raster getTile(int x, int y);

    // This is return the tile if it is available otherwise
    // returns null.  It will not compute the tile if it is
    // not present.
    Raster getTileNoCompute(int x, int y);
}
