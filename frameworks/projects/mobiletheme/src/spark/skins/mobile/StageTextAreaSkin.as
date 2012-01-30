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
import mx.core.DPIClassification;

import spark.components.TextArea;
import spark.components.supportClasses.StyleableTextField;
import spark.skins.mobile.supportClasses.StageTextSkinBase;

/**
 *  ActionScript-based skin for TextArea controls in mobile applications. 
 * 
 *  @see spark.components.TextArea
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3.0 
 *  @productversion Flex 4.5.2
 */
public class StageTextAreaSkin extends StageTextSkinBase
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
     *  @playerversion AIR 3.0
     *  @productversion Flex 4.5.2
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
            textDisplay.commitStyles();
            setElementSize(textDisplay, unscaledTextWidth, unscaledTextHeight);
            setElementPosition(textDisplay, paddingLeft, paddingTop);
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