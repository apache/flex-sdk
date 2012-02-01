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
     *  @throws SecurityError The <code>target</code> object and  all of its child
     *  objects do not come from the same domain as the caller,
     *  or are not in a content that is accessible to the caller by having called the
     *  <code>Security.allowDomain()</code> method.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static function getSnapshot(target:IUIComponent):BitmapData
    {
        // DisplayObject.getBounds() is not sufficient; we need the same
        // bounds as those used internally by the player
        var m:Matrix = MatrixUtil.getConcatenatedMatrix(target as DisplayObject);
        var bounds:Rectangle = getRealBounds(DisplayObject(target), m);
        if (bounds.width == 0 || bounds.height == 0)
            return null;
        if (m)
            m.translate(-(Math.floor(bounds.x)), -(Math.floor(bounds.y)));
        var bmData:BitmapData = new BitmapData(bounds.width, bounds.height, true, 0);
        bmData.draw(IBitmapDrawable(target), m);

        return bmData;
    }

    /**
     *  @private
     *  Returns a rectangle that describes the visible region of the target, 
     *  including any filters. The padding argument specifies how much space
     *  to pad the temporary BitmapData with, to capture any extra visible pixels
     *  from things like filters.
     *  Note that this actually captures the full bounds of an object as seen
     *  by the player, including any transparent areas. For example, the player 
     *  pads significantly around text objects and slightly around filtered areas.
     *  To deal with this, we render our object with an opaque background into
     *  our temporary bitmap and examine the result for pixels that were written to.
     *  When the player exposes an API for getting the real, internal bounds (which
     *  getBounds() does not do), then we can remove this code and use that 
     *  API instead.
     *  @param targ The target object whose bounds are requested
     *  @param m The transform matrix for the target object. This should be the
     *  object's concatenatedMatrix, since we want the real bounds of the object
     *  on the stage, which should include any transformations on the object.
     *  @param padding The amount of padding to use to catch any pixels
     *  outside the core object area (such as filtered or text objects have).
     */
    private static function getRealBounds(targ:DisplayObject, m:Matrix = null,
        padding:int = 10):Rectangle
    {
        var bitmap:BitmapData = new BitmapData(targ.width + 2*padding, 
            targ.height + 2*padding, true, 0x00000000);
        if (!m)
            m = new Matrix();
        var tx:Number = m.tx;
        var ty:Number = m.ty;
        m.translate(-tx + padding, -ty + padding);
        var tmpOpaqueBackground:Object = targ.opaqueBackground;
        targ.opaqueBackground = 0xFFFFFFFF;
        bitmap.draw(targ, m);
        // restore the matrix translation
        m.translate(tx - padding, ty - padding);
        targ.opaqueBackground = tmpOpaqueBackground;
        // getColorBoundsRect() will find the inner rect of opaque pixels,
        // consistent with the player's view of the object bounds
        var actualBounds:Rectangle = bitmap.getColorBoundsRect(
            0xFF000000, 0x0, false);
        if ((actualBounds.width == 0 || actualBounds.height == 0) ||
            (actualBounds.x > 0 && actualBounds.y > 0 &&
             actualBounds.right < bitmap.width &&
             actualBounds.bottom < bitmap.height))
        {
            actualBounds.x = actualBounds.x + tx - padding;
            actualBounds.y = actualBounds.y + ty - padding;
            bitmap.dispose();
            return actualBounds;
        }
        else
        {
            // If we ran right up to the borders of our bitmap,
            // then we may not have created a large enough bitmap - do it
            // again with twice the padding.
            
            // padding shouldn't be zero, but just in case...
            var newPadding:int = (padding == 0) ? 10 : 2 * padding;
            
            bitmap.dispose();
            return getRealBounds(targ, m, newPadding);
        }
    }
}
}