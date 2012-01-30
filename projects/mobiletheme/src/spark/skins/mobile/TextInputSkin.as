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
import flash.events.Event;

import mx.core.DeviceDensity;
import mx.core.mx_internal;

import spark.components.TextInput;
import spark.components.supportClasses.StyleableTextField;
import spark.skins.mobile.supportClasses.TextSkinBase;
import spark.skins.mobile160.assets.TextInput_border;
import spark.skins.mobile240.assets.TextInput_border;
import spark.skins.mobile320.assets.TextInput_border;

use namespace mx_internal;

/**
 *  ActionScript-based skin for TextInput controls in mobile applications. 
 * 
 * @see spark.components.TextInput
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class TextInputSkin extends TextSkinBase 
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
     */
    public function TextInputSkin()
    {
        super();
        
        useChromeColor = false;
        
        switch (authorDensity)
        {
            case DeviceDensity.PPI_320:
            {
                borderClass = spark.skins.mobile320.assets.TextInput_border;
                layoutCornerEllipseSize = 24;
                layoutMeasuredWidth = 600;
                layoutMeasuredHeight = 66;
                layoutBorderSize = 2;
                
                break;
            }
            case DeviceDensity.PPI_240:
            {
                borderClass = spark.skins.mobile240.assets.TextInput_border;
                layoutCornerEllipseSize = 12;
                layoutMeasuredWidth = 440;
                layoutMeasuredHeight = 50;
                layoutBorderSize = 1;
                
                break;
            }
            default:
            {
                borderClass = spark.skins.mobile160.assets.TextInput_border;
                layoutCornerEllipseSize = 12;
                layoutMeasuredWidth = 300;
                layoutMeasuredHeight = 33;
                layoutBorderSize = 1;
                
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
    public var hostComponent:TextInput;  // SkinnableComponent will populate
    
    /**
     *  @private
     */
    override protected function createChildren():void
    {
        super.createChildren();
        
        textDisplay.addEventListener("editableChanged", editableChangedHandler);
    }
    
    /**
     *  @private
     */
    override protected function measure():void
    {
        super.measure();
        
        var paddingLeft:Number = getStyle("paddingLeft");
        var paddingRight:Number = getStyle("paddingRight");
        var paddingTop:Number = getStyle("paddingTop");
        var paddingBottom:Number = getStyle("paddingBottom");
        var textHeight:Number = getStyle("fontSize") as Number;
        
        if (textDisplay)
        {
            // temporarily change text for measurement
            var oldText:String = textDisplay.text;
            
            // commit styles so we can get a valid textHeight
            textDisplay.text = "Wj";
            textDisplay.commitStyles();
            
            textHeight = textDisplay.measuredTextSize.y;
            textDisplay.text = oldText;
        }
        
        // Width is based on maxChars (if set), or hard-coded to 440
        if (hostComponent && hostComponent.maxChars)
        {
            // Grab the fontSize and subtract 2 as the pixel value for each character.
            // This is just an approximation, but it appears to be a reasonable one
            // for most input and most font.
            var characterWidth:int = Math.max(1, (getStyle("fontSize") - 2));
            measuredWidth =  (characterWidth * hostComponent.maxChars) + 
                paddingLeft + paddingRight + StyleableTextField.TEXT_WIDTH_PADDING;
        }
        else
        {
            measuredWidth = layoutMeasuredWidth;
        }
        
        measuredHeight = Math.max(paddingTop + textHeight + paddingBottom, layoutMeasuredHeight);
    }
    
    /**
     *  @private
     */
    private function editableChangedHandler(event:Event):void
    {
        invalidateDisplayList();
    }
}
}