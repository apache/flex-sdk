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
import spark.components.VScrollBar;
import spark.skins.mobile.supportClasses.MobileSkin;


/**
 *  ActionScript-based skin for VScrollBar components in mobile applications. 
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class VScrollBarSkin extends MobileSkin
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
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     * 
     */
    public function VScrollBarSkin()
    {
        super();
        
        useChromeColor = true;
        layoutMeasuredHeight = 20;
        thumbSkinClass = VScrollBarThumbSkin;
        
        // Depending on density set our measured width
        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                layoutMeasuredWidth = 12;
                break;
            }
            case DPIClassification.DPI_240:
            {
                layoutMeasuredWidth = 9;
                break;
            }
            default:
            {
                // default PPI160
                layoutMeasuredWidth = 6;
                break;
            }
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /** 
     *  @copy spark.skins.spark.ApplicationSkin#hostComponent
     */
    public var hostComponent:VScrollBar;
    
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
     *  VScrollbar track skin part
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */   
    public var track:Button;
    
    /**
     *  VScrollbar thumb skin part
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
            thumb.setStyle("skinClass", thumbSkinClass);
            thumb.width = layoutMeasuredWidth;
            thumb.height = layoutMeasuredWidth;
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