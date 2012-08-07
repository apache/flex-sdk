////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package components {

import spark.components.supportClasses.ScrollBarBase;

public class CircularScrollBar extends ScrollBarBase
{
    public function CircularScrollBar()
    {
        super();
    }

    /**
     *  @private
     */
    override protected function pointToValue(x:Number, y:Number):Number
    {
        if (!track || !thumb)
            return 0;

        var cx:Number = x + (thumb.width / 2) - (track.width / 2);
        var cy:Number = y + (thumb.height / 2) - (track.height / 2);
        var angle:Number = Math.atan2(cy, cx);
        if (angle < 0) angle += 2 * Math.PI;
        return (maximum - minimum) * (angle / (2 * Math.PI));
    }

    /**
     *  @private
     */
    override protected function updateSkinDisplayList():void
    {
        var range:Number = maximum - minimum;
        if (!thumb || !track || (range <= 0))
            return;

        var radius:Number = width / 2;
        var angle:Number = ((value - minimum) / range) * 2 * Math.PI;
        var thumbX:Number = (width / 2)  + (radius * Math.cos(angle)) - (thumb.width / 2);
        var thumbY:Number = (height / 2) + (radius * Math.sin(angle)) - (thumb.height / 2);
        thumb.setLayoutBoundsPosition(thumbX, thumbY);

    }

}
}