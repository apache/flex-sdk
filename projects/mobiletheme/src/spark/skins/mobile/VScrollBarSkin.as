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
import mx.core.mx_internal;

import spark.components.Button;
import spark.components.VScrollBar;
import spark.skins.mobile.supportClasses.MobileSkin;

use namespace mx_internal;

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
        
        minHeight = 20;
        thumbSkinClass = VScrollBarThumbSkin;
        var paddingRight:int;
        var paddingVertical:int;
        
        // Depending on density set our measured width
        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                minWidth = 12;
                paddingRight = VScrollBarThumbSkin.PADDING_RIGHT_320DPI;
                paddingVertical = VScrollBarThumbSkin.PADDING_VERTICAL_320DPI;
                break;
            }
            case DPIClassification.DPI_240:
            {
                minWidth = 9;
                paddingRight = VScrollBarThumbSkin.PADDING_RIGHT_240DPI;
                paddingVertical = VScrollBarThumbSkin.PADDING_VERTICAL_240DPI;
                break;
            }
            default:
            {
                // default DPI_160
                minWidth = 6;
                paddingRight = VScrollBarThumbSkin.PADDING_RIGHT_DEFAULTDPI;
                paddingVertical = VScrollBarThumbSkin.PADDING_VERTICAL_DEFAULTDPI;
                break;
            }
        }
        
        // The minimum height is set such that, at it's smallest size, the thumb appears
        // as high as it is wide.
        minThumbHeight = (minWidth - paddingRight) + (paddingVertical * 2);   
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
     *  Minimum height for the thumb
     */
    protected var minThumbHeight:Number;
    
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
            track.width = minWidth;
            track.height = minHeight;
            addChild(track);
        }
        if (!thumb)
        {
            thumb = new Button();
            thumb.minHeight = minThumbHeight; 
            thumb.setStyle("skinClass", thumbSkinClass);
            thumb.width = minWidth;
            thumb.height = minWidth;
            addChild(thumb);
        }
    }
    
    /**
     *  @private 
     */
    override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.layoutContents(unscaledWidth, unscaledHeight);
        
        setElementSize(track, unscaledWidth, unscaledHeight);
    }
}
}