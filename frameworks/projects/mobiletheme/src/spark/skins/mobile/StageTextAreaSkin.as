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
import flash.system.Capabilities;

import mx.core.DPIClassification;
import mx.core.mx_internal;

import spark.components.TextArea;
import spark.components.supportClasses.StyleableTextField;
import spark.skins.mobile.supportClasses.StageTextSkinBase;

use namespace mx_internal;

/**
 *  ActionScript-based skin for TextArea controls in mobile applications that uses a
 *  StyleableStageText class for the text display. 
 * 
 *  @see spark.components.TextArea
 *  @see spark.components.supportClasses.StyleableStageText
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3.0 
 *  @productversion Flex 4.6
 */
public class StageTextAreaSkin extends StageTextSkinBase
{
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------

    /**
     *  The underlying native text control on iOS has internal margins of its
     *  own. In order to remain faithful to the paddingTop and paddingBottom
     *  style values that developers may specify, those internal margins need to
     *  be compensated for. This variable contains size of that compensation in
     *  pixels.
     */
    mx_internal static var iOSVerticalPaddingAdjustment:Number = 5;
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.6
     */
    public function StageTextAreaSkin()
    {
        super();
        multiline = true;
        
        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                measuredDefaultHeight = 106;
                break;
            }
            case DPIClassification.DPI_240:
            {
                measuredDefaultHeight = 70;
                break;
            }
            default:
            {
                measuredDefaultHeight = 53;
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
    public var hostComponent:TextArea;  // SkinnableComponent will populate
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function layoutContents(unscaledWidth:Number, 
                                               unscaledHeight:Number):void
    {
        // base class handles border position & size
        super.layoutContents(unscaledWidth, unscaledHeight);
        
        // position & size the text
        var paddingLeft:Number = getStyle("paddingLeft");
        var paddingRight:Number = getStyle("paddingRight");
        var paddingTop:Number = getStyle("paddingTop");
        var paddingBottom:Number = getStyle("paddingBottom");
        
        var unscaledTextWidth:Number = Math.max(0, unscaledWidth - paddingLeft - paddingRight);
        var unscaledTextHeight:Number = Math.max(0, unscaledHeight - paddingTop - paddingBottom);
        
        if (textDisplay)
        {
            var verticalPosAdjustment:Number = 0;
            var heightAdjustment:Number = 0;
            
            if (Capabilities.version.indexOf("IOS") == 0)
            {
                verticalPosAdjustment = Math.min(iOSVerticalPaddingAdjustment, paddingTop);
                heightAdjustment = verticalPosAdjustment + Math.min(iOSVerticalPaddingAdjustment, paddingBottom);
            }
            
            textDisplay.commitStyles();
            setElementSize(textDisplay, unscaledTextWidth, unscaledTextHeight + heightAdjustment);
            setElementPosition(textDisplay, paddingLeft, paddingTop - verticalPosAdjustment);
        }
        
        if (promptDisplay)
        {
            if (promptDisplay is StyleableTextField)
                StyleableTextField(promptDisplay).commitStyles();
            
            setElementSize(promptDisplay, unscaledTextWidth, unscaledTextHeight);
            setElementPosition(promptDisplay, paddingLeft, paddingTop);
        }
    }

    /**
     *  @private
     */
    override protected function measure():void
    {
        super.measure();
        measureTextComponent(hostComponent);
    }
}
}