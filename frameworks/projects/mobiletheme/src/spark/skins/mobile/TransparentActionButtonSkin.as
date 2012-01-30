////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.skins.mobile
{
import flash.display.DisplayObject;
import flash.display.Graphics;

import mx.core.DPIClassification;
import mx.core.mx_internal;

import spark.skins.mobile.assets.TransparentActionButton_down;
import spark.skins.mobile.assets.TransparentActionButton_up;
import spark.skins.mobile.supportClasses.ActionBarButtonSkinBase;
import spark.skins.mobile.supportClasses.MobileSkin;
import spark.skins.mobile320.assets.TransparentActionButton_down;
import spark.skins.mobile320.assets.TransparentActionButton_up;

use namespace mx_internal;

/**
 *  The default skin class for buttons in the action area of the Spark ActionBar component 
 *  in mobile applications.  
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class TransparentActionButtonSkin extends ActionBarButtonSkinBase
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
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function TransparentActionButtonSkin()
    {
        super();
        
        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                upBorderSkin = spark.skins.mobile320.assets.TransparentActionButton_up;
                downBorderSkin = spark.skins.mobile320.assets.TransparentActionButton_down;
                
                break;
            }
            default:
            {
                upBorderSkin = spark.skins.mobile.assets.TransparentActionButton_up;
                downBorderSkin = spark.skins.mobile.assets.TransparentActionButton_down;
                
                break;
            }
        }
    }
    
    override mx_internal function layoutBorder(unscaledWidth:Number, unscaledHeight:Number):void
    {
        // don't call super, don't layout twice
        // leading vertical separator is outside the left bounds of the button
        setElementSize(border, unscaledWidth + layoutBorderSize, unscaledHeight);
        setElementPosition(border, -layoutBorderSize, 0);
    }
}
}