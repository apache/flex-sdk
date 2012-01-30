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

package
{
import flash.geom.Rectangle;

import mx.core.mx_internal;
import mx.flash.FlexContentHolder;

use namespace mx_internal;

[ExcludeClass]

public class MyFlexContentHolder extends FlexContentHolder
{
    public function MyFlexContentHolder()
    {
        super();
        
        // Add thumbnail first.  Then need to remeasure ourselves just 
        // like we do in the FlexContentHolder's constructor.
        // We need to re-measure ourselves even after the super() 
        // call does it because there was no content at that point.
        // Normally the "content" is baked in to the SWF tag.
        addChild(new FlexContentHolderThumbnail());
        
        // now need to re-measure ourselves:
        var bounds:Rectangle = getBounds(this);
        _width = bounds.width;
        _height = bounds.height;
        $scaleX = $scaleY = 1;
    }
}
}
