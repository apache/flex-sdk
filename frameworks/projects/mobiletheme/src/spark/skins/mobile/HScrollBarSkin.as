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

import mx.core.DPIClassification;

import spark.components.Button;
import spark.components.HScrollBar;
import spark.skins.mobile.supportClasses.MobileSkin;
import mx.core.mx_internal;
use namespace mx_internal;

/**
 *  ActionScript-based skin for HScrollBar components in mobile applications. 
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
 public class HScrollBarSkin extends MobileSkin 
{   
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function HScrollBarSkin()
    {
        super();
        
        useChromeColor = true;

		layoutMeasuredWidth = 20;
        thumbSkinClass = HScrollBarThumbSkin;
        var paddingBottom:int;
        var paddingHorizontal:int;
		
		// Depending on density set our measured height
        switch (applicationDPI)
        {
			case DPIClassification.DPI_320:
			{
				layoutMeasuredHeight = 12;   
                paddingBottom = HScrollBarThumbSkin.PADDING_BOTTOM_320DPI;
                paddingHorizontal = HScrollBarThumbSkin.PADDING_HORIZONTAL_320DPI;
				break;
			}
            case DPIClassification.DPI_240:
            {
                layoutMeasuredHeight = 9;   
                paddingBottom = HScrollBarThumbSkin.PADDING_BOTTOM_240DPI;
                paddingHorizontal = HScrollBarThumbSkin.PADDING_HORIZONTAL_240DPI;
                break;
            }
            default:
            {
                // default PPI160
                layoutMeasuredHeight = 6;              
                paddingBottom = HScrollBarThumbSkin.PADDING_BOTTOM_DEFAULTDPI;
                paddingHorizontal = HScrollBarThumbSkin.PADDING_HORIZONTAL_DEFAULTDPI;
                break;
            }
        }

        // The minimum width is set such that, at it's smallest size, the thumb appears
        // as wide as it is high.
        minThumbWidth = (layoutMeasuredHeight - paddingBottom) + (paddingHorizontal * 2);   
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    /** 
     *  @copy spark.skins.spark.ApplicationSkin#hostComponent
     */
    public var hostComponent:HScrollBar;
    
    /**
     *  @private 
     */
    private var minThumbWidth:Number;

    /**
     *  Skin to use for the thumb Button skin part
     */
    protected var thumbSkinClass:Class;
    
    //--------------------------------------------------------------------------
    //
    //  Skin parts 
    //
    //--------------------------------------------------------------------------
    /**
     *  HScrollbar track skin part.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */  
    public var track:Button;
    
    /**
     *  HScrollbar thumb skin part.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */  
    public var thumb:Button;
    
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    /**
     *  @private 
     */ 
    override protected function createChildren():void
    {
        // Create our skin parts if necessary: track and thumb.
        if (!track)
        {
            // We don't want a visible track so we set the skin to MobileSkin
            track = new Button();
            track.setStyle("skinClass", spark.skins.mobile.supportClasses.MobileSkin);
            track.width = layoutMeasuredWidth;
            track.height = layoutMeasuredHeight;
            addChild(track);
        }
        
        if (!thumb)
        {
            thumb = new Button();
            thumb.minWidth = minThumbWidth;
            thumb.setStyle("skinClass", thumbSkinClass);
            thumb.width = layoutMeasuredHeight;
            thumb.height = layoutMeasuredHeight;
            addChild(thumb);
        }
    }
    
    /**
     *  @private 
     */
    override protected function measure():void
    {
        measuredWidth = layoutMeasuredWidth;
        measuredHeight = layoutMeasuredHeight;
    }
    
    /**
     *  @private 
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        setElementSize(track, unscaledWidth, unscaledHeight);
    }
}
}