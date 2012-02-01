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

package spark.utils
{
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.IBitmapDrawable;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Rectangle;

import mx.core.IUIComponent;
import mx.utils.MatrixUtil;

/**
 *  This class provides bitmap-related utility functions 
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class BitmapUtil
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Creates a BitmapData representation of the target object.
     *
     *  @param target The object to capture in the resulting BitmapData  
     *
     *  @return A BitmapData object containing the image.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static function getSnapshot(target:IUIComponent):BitmapData
    {
        var topLevel:Sprite = Sprite(IUIComponent(target).systemManager.getSandboxRoot());   
        var rectBounds:Rectangle = target.getBounds(topLevel);
        // Can't use target's concatenatedMatrix, as it is sometimes wrong
        var m:Matrix = MatrixUtil.getConcatenatedMatrix(target as DisplayObject);
        // truncate position because the fractional offset will already be figured
        // into the filter placement onto the target. 
        // FIXME (chaase): There are still some offset
        // problems with objects inside of rotated parents, depending on the angle.
        if (m)
            m.translate(-(Math.floor(rectBounds.x)), -(Math.floor(rectBounds.y)));
        var bmData:BitmapData = new BitmapData(rectBounds.width, 
            rectBounds.height, true, 0);
        bmData.draw(IBitmapDrawable(target), m);

        return bmData;
    }

}
}