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

import spark.components.TextInput;
import spark.skins.mobile.supportClasses.TextSkinBase;

/**
 *  Actionscript based skin for mobile text input. 
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
    public function TextInputSkin()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  A strongly typed property that references the component to which this skin is applied.
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
        
        var textHeight:Number = 24;
        
        if (textDisplay)
        {
            // temporarily change text for measurement
            var oldText:String = textDisplay.text;
            
            // commit styles so we can get a valid textHeight
            textDisplay.text = "Wj";
            textDisplay.commitStyles();
            
            textHeight = textDisplay.textHeight;
            textDisplay.text = oldText;
        }
        
        var paddingLeft:Number = getStyle("paddingLeft");
        var paddingRight:Number = getStyle("paddingRight");
        var paddingTop:Number = getStyle("paddingTop");
        var paddingBottom:Number = getStyle("paddingBottom");
        
        // Width is based on maxChars (if set), or hard-coded to 440
        if (hostComponent && hostComponent.maxChars)
        {
            // Grab the fontSize and subtract 2 as the pixel value for each character.
            // This is just an approximation, but it appears to be a reasonable one
            // for most input and most font.
            var characterWidth:int = Math.max(1, (getStyle("fontSize") - 2));
            measuredWidth =  (characterWidth * hostComponent.maxChars) + 
                paddingLeft + paddingRight + TEXT_WIDTH_PADDING;
        }
        else
        {
            measuredWidth = 440;
        }
        
        measuredHeight = textHeight + paddingTop + paddingBottom + TEXT_HEIGHT_PADDING;
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