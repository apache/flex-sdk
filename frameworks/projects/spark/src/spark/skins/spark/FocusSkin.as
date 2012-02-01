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

package spark.skins.spark
{

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.IBitmapDrawable;
import flash.events.Event;
import flash.filters.GlowFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.FlexEvent;

import spark.components.supportClasses.Skin;
import spark.components.supportClasses.SkinnableComponent;
import spark.core.DisplayObjectSharingMode;
import spark.core.IGraphicElement;

use namespace mx_internal;

/**
 *  Defines the "glow" around Spark components when the component has focus.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class FocusSkin extends HighlightBitmapCaptureSkin
{
    include "../../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
        
    // Number to multiply focusThickness by to determine the blur value
    private const BLUR_MULTIPLIER:Number = 2.5;
    
    // Number to multiply focusAlpha by to determine the filter alpha value
    private const ALPHA_MULTIPLIER:Number = 1.5454;
    
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------
    
    private static var colorTransform:ColorTransform = new ColorTransform(
                1.01, 1.01, 1.01, 2);
    private static var glowFilter:GlowFilter = new GlowFilter(
                0x70B2EE, 0.85, 5, 5, 3, 1, false, true);
    private static var rect:Rectangle = new Rectangle();;
    private static var filterPt:Point = new Point();
                 
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     * Constructor.
     */
    public function FocusSkin()
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @inheritDoc
     */
    override protected function get borderWeight() : Number
    {
        if (target)
            return target.getStyle("focusThickness");
        
        // No target, return default value
        return getStyle("focusThickness");
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     * @inheritDoc
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {   
        super.updateDisplayList(unscaledWidth, unscaledHeight);
         
        if (target)
            blendMode = target.getStyle("focusBlendMode");
    }
    
    /**
     *  @private
     */
    override protected function processBitmap() : void
    {
        // Apply the glow filter
        rect.x = rect.y = 0;
        rect.width = bitmap.width;
        rect.height = bitmap.height;
        // If the focusObject has an errorString, use "errorColor" instead of "focusColor" 
        if (target.errorString != null && target.errorString != "" && target.getStyle("showErrorSkin")) 
        {
            glowFilter.color = target.getStyle("errorColor");
        }
        else
        {
            glowFilter.color = target.getStyle("focusColor");
        }
        glowFilter.blurX = glowFilter.blurY = borderWeight * BLUR_MULTIPLIER;
        glowFilter.alpha = target.getStyle("focusAlpha") * ALPHA_MULTIPLIER;
        
        bitmap.bitmapData.applyFilter(bitmap.bitmapData, rect, filterPt, glowFilter);         
    }
}
}        
