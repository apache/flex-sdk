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

import mx.core.DeviceDensity;
import mx.core.UIComponent;

import spark.components.Button;
import spark.components.VScrollBar;
import spark.skins.mobile.supportClasses.MobileSkin;


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
        
        // Depending on density set our measured width and height
        switch (authorDensity)
        {
            case DeviceDensity.PPI_240:
            {
                layoutMeasuredWidth = 9;
                layoutMeasuredHeight = 40;
                break;
            }
            default:
            {
                // default PPI160
                layoutMeasuredWidth = 6;
                layoutMeasuredHeight = 20;
                
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
            thumb.setStyle("skinClass", spark.skins.mobile.VScrollBarThumbSkin);
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