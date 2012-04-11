/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package flash.swf.builder.types;

import flash.swf.SwfConstants;
import flash.swf.types.Rect;

import java.awt.geom.Rectangle2D;

/**
 * This class is used to construct a Rect object from a Rectangle2D object.
 *
 * @author Peter Farland
 */
public final class RectBuilder
{
    private RectBuilder()
    {
    }

    public static Rect build(Rectangle2D r)
    {
        Rect rect = new Rect();

        rect.xMin = (int)Math.rint(r.getMinX() * SwfConstants.TWIPS_PER_PIXEL);
        rect.yMin = (int)Math.rint(r.getMinY() * SwfConstants.TWIPS_PER_PIXEL);
        rect.xMax = (int)Math.rint(r.getMaxX() * SwfConstants.TWIPS_PER_PIXEL);
        rect.yMax = (int)Math.rint(r.getMaxY() * SwfConstants.TWIPS_PER_PIXEL);

        return rect;
    }
}
