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
package org.apache.flex.forks.batik.ext.awt;

import java.awt.RenderingHints;

/**
 * A transcoding Key represented as a boolean to indicate whether tiling of
 * bitmaps is undesired by the destination.
 *
 * @version $Id: AvoidTilingHintKey.java 489226 2006-12-21 00:05:36Z cam $
 */
public class AvoidTilingHintKey extends RenderingHints.Key {

    AvoidTilingHintKey(int number) { super(number); }

    public boolean isCompatibleValue(Object v) {
        if (v == null) return false;
        return ((v == RenderingHintsKeyExt.VALUE_AVOID_TILE_PAINTING_ON)  ||
                (v == RenderingHintsKeyExt.VALUE_AVOID_TILE_PAINTING_OFF) ||
                (v == RenderingHintsKeyExt.VALUE_AVOID_TILE_PAINTING_DEFAULT));
    }
}
