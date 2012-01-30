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

[ExcludeClass]

public class MyFlexContentHolder extends FlexContentHolder
{
    public function MyFlexContentHolder()
    {
        super();

        addChild(new FlexContentHolderThumbnail());
        
        // now need to re-measure ourselves:
        var bounds:Rectangle = getBounds(this);
        _width = bounds.width;
        _height = bounds.height;
        mx_internal::$scaleX = mx_internal::$scaleY = 1;         
    }
}
}