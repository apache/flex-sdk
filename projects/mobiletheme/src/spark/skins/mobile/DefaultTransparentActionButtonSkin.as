////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2011 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.skins.mobile
{
import mx.core.mx_internal;

use namespace mx_internal;

/**
 *  Emphasized button uses accentColor instead of chromeColor. Replaces the
 *  TransparentActionButtonSkin.
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.6
 */
public class DefaultTransparentActionButtonSkin extends TransparentActionButtonSkin
{   
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     * 
     */
    public function DefaultTransparentActionButtonSkin()
    {
        super();
        
        fillColorStyleName = "accentColor";
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     * @private
     */
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        // omit super.drawBackground() to drawRect instead
        // always draw accentColor regardless of skin state
        graphics.beginFill(getStyle(fillColorStyleName));
        graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
        graphics.endFill();
    }
}
}