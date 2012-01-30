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

import mx.core.DPIClassification;
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
        
        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                borderClass = spark.skins.mobile320.assets.TextInput_border;
                layoutCornerEllipseSize = 24;
                measuredDefaultWidth = 600;
                measuredDefaultHeight = 66;
                layoutBorderSize = 2;
                
                break;
            }
            case DPIClassification.DPI_240:
            {
                borderClass = spark.skins.mobile240.assets.TextInput_border;
                layoutCornerEllipseSize = 12;
                measuredDefaultWidth = 440;
                measuredDefaultHeight = 50;
                layoutBorderSize = 1;
                
                break;
            }
            default:
            {
                borderClass = spark.skins.mobile160.assets.TextInput_border;
                layoutCornerEllipseSize = 12;
                measuredDefaultWidth = 300;
                measuredDefaultHeight = 33;
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
        
        // width is based on maxChars (if set)
        if (hostComponent && hostComponent.maxChars)
        {
            // Grab the fontSize and subtract 2 as the pixel value for each character.
            // This is just an approximation, but it appears to be a reasonable one
            // for most input and most font.
            var characterWidth:int = Math.max(1, (getStyle("fontSize") - 2));
            measuredWidth =  (characterWidth * hostComponent.maxChars) + 
                paddingLeft + paddingRight + StyleableTextField.TEXT_WIDTH_PADDING;
        }
        
        measuredHeight = paddingTop + textHeight + paddingBottom;
    }
    
    /**
     *  @private
     */
    override protected function layoutContents(unscaledWidth:Number, 
                                               unscaledHeight:Number):void
    {
        super.layoutContents(unscaledWidth, unscaledHeight);
        
        // position & size border
        if (border)
        {
            setElementSize(border, unscaledWidth, unscaledHeight);
            setElementPosition(border, 0, 0);
        }
        
        // position & size the text
        var paddingLeft:Number = getStyle("paddingLeft");
        var paddingRight:Number = getStyle("paddingRight");
        var paddingTop:Number = getStyle("paddingTop");
        var paddingBottom:Number = getStyle("paddingBottom");
        
        var unscaledTextWidth:Number = unscaledWidth - paddingLeft - paddingRight;
        var unscaledTextHeight:Number = unscaledHeight - paddingTop - paddingBottom;
        
        // default vertical positioning is ascent centered
        var textHeight:Number = getElementPreferredHeight(textDisplay);
        var textY:Number = Math.round(0.5 * (unscaledTextHeight - textHeight)) + paddingTop;

        if (textDisplay)
        {
            // We're going to do a few tricks to try to increase the size of our hitArea to make it 
            // easier for users to select text or put the caret in a certain spot.  To do that, 
            // rather than set textDisplay.x=paddingLeft,  we are going to set 
            // textDisplay.leftMargin = paddingLeft.  In addition, we're going to size the height 
            // of the textDisplay larger than just the size of the text inside to increase the hitArea
            // on the bottom.  We'll also assign textDisplay.rightMargin = paddingRight to increase the 
            // the hitArea on the right.  Unfortunately, there's no way to increase the hitArea on the top
            // just yet, but these three tricks definitely help out with regards to user experience.  
            // See http://bugs.adobe.com/jira/browse/SDK-29406 and http://bugs.adobe.com/jira/browse/SDK-29405
            
            // set leftMargin, rightMargin to increase the hitArea.  Need to set it before calling commitStyles().
            var marginChanged:Boolean = ((textDisplay.leftMargin != paddingLeft) || 
                (textDisplay.rightMargin != paddingRight));
            
            textDisplay.leftMargin = paddingLeft;
            textDisplay.rightMargin = paddingRight;
            
            // need to force a styleChanged() after setting leftMargin, rightMargin if they 
            // changed values.  Then we can validate the styles through commitStyles()
            if (marginChanged)
                textDisplay.styleChanged(null);
            textDisplay.commitStyles();
            
            // the height of the textDisplay to unscaledTextHeight + paddingBottom to increase hitArea on bottom
            setElementSize(textDisplay, unscaledWidth, unscaledTextHeight + paddingBottom);
            // set x=0 since we're using textDisplay.leftMargin = paddingLeft
            setElementPosition(textDisplay, 0, textY);
        }
        
        if (promptDisplay)
        {
            promptDisplay.commitStyles();
            setElementSize(promptDisplay, unscaledTextWidth, unscaledTextHeight);
            setElementPosition(promptDisplay, paddingLeft, textY);
        }
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