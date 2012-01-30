////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
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