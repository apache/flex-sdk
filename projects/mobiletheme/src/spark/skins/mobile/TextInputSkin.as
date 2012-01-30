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

import flash.display.DisplayObject;
import flash.events.Event;
import flash.text.TextLineMetrics;

import spark.components.TextInput;
import spark.components.supportClasses.StyleableTextField;
import spark.skins.mobile.assets.TextInput_border;
import spark.skins.mobile.supportClasses.MobileSkin;

/**
 *  Actionscript based skin for mobile text input. 
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class TextInputSkin extends MobileSkin 
{
    //--------------------------------------------------------------------------
    //
    //  Class statics
    //
    //--------------------------------------------------------------------------
    
    // StylableTextField padding
    private static const TEXT_WIDTH_PADDING:int = 4;
    private static const TEXT_HEIGHT_PADDING:int = 2;
    
    // FXG measurements
    private static const BORDER_SIZE:uint = 1;
    private static const CORNER_ELLIPSE_SIZE:uint = 16;
    
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
     *  textDisplay skin part.
     */
    public var textDisplay:StyleableTextField;
    
    /**
     *  promptDisplay skin part.
     */
    public var promptDisplay:StyleableTextField;
    
    /**
     *  @private
     * 
     *  Instance of the border graphics.
     */
    private var border:DisplayObject;
    
    private var borderVisibleChanged:Boolean = false;
    
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
        super.createChildren();
        
        border = new TextInput_border;
        addChild(border);
        
        textDisplay = StyleableTextField(createInFontContext(StyleableTextField));
        textDisplay.styleProvider = this;
        textDisplay.editable = true;
        textDisplay.addEventListener("editableChanged", editableChangedHandler);
        addChild(textDisplay);
        
        createPromptDisplay();
    }
    
    protected function createPromptDisplay():void
    {
        promptDisplay = StyleableTextField(createInFontContext(StyleableTextField));
        promptDisplay.styleProvider = this;
        promptDisplay.editable = false;
        promptDisplay.mouseEnabled = false;
        addChild(promptDisplay);
    }
    
    /**
     *  @private 
     */ 
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (borderVisibleChanged)
        {
            borderVisibleChanged = false;
            
            var borderVisible:Boolean = getStyle("borderVisible") == true;
            
            if (borderVisible && !border)
            {
                border = new TextInput_border();
                addChild(border);
            }
            else if (!borderVisible && border)
            {
                removeChild(border);
                border = null;
            }
        }
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
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        var borderSize:uint = (border) ? BORDER_SIZE : 0;
        var borderWidth:uint = borderSize * 2;
        
        // Draw the contentBackgroundColor
        graphics.clear();
        graphics.beginFill(getStyle("contentBackgroundColor"), getStyle("contentBackgroundAlpha"));
        graphics.drawRoundRect(borderSize, borderSize, unscaledWidth - borderWidth, unscaledHeight - borderWidth, CORNER_ELLIPSE_SIZE, CORNER_ELLIPSE_SIZE);
        graphics.endFill();
        
        // position & size border
        if (border)
        {
            resizePart(border, unscaledWidth, unscaledHeight);
            positionPart(border, 0, 0);
        }
        
        // position & size the text
        var paddingLeft:Number = getStyle("paddingLeft");
        var paddingRight:Number = getStyle("paddingRight");
        var paddingTop:Number = getStyle("paddingTop");
        var paddingBottom:Number = getStyle("paddingBottom");
        
        if (textDisplay)
        {
            textDisplay.commitStyles();
            
            var textHeight:Number = textDisplay.textHeight;
            var textTop:Number = Math.round((unscaledHeight - textHeight) / 2);
            
            // verticalAlign=middle
            textTop = Math.max(textTop, paddingTop);
            
            resizePart(textDisplay, unscaledWidth - paddingLeft - paddingRight, unscaledHeight - paddingTop - paddingBottom);
            positionPart(textDisplay, paddingLeft, textTop);
        }
        
        if (promptDisplay)
        {
            promptDisplay.commitStyles();
            resizePart(promptDisplay, unscaledWidth - paddingLeft - paddingRight, unscaledHeight - paddingTop - paddingBottom);
            positionPart(promptDisplay, paddingLeft, textTop);
        }
    }
    
    /**
     *  @private
     */
    override public function styleChanged(styleProp:String):void
    {
        var allStyles:Boolean = !styleProp || styleProp == "styleName";
        
        if (allStyles || styleProp == "borderVisible")
        {
            borderVisibleChanged = true;
            invalidateProperties();
        }
        
        if (allStyles || styleProp.indexOf("padding") == 0)
        {
            invalidateDisplayList();
        }
        
        if (textDisplay)
            textDisplay.styleChanged(styleProp);
        
        if (promptDisplay)
            promptDisplay.styleChanged(styleProp);
        
        super.styleChanged(styleProp);
    }
    
    /**
     *  @private
     */
    override protected function commitCurrentState():void
    {
        super.commitCurrentState();
        
        alpha = currentState.indexOf("disabled") == -1 ? 1 : 0.5;
        
        var showPrompt:Boolean = currentState.indexOf("WithPrompt") >= 0;
        
        if (showPrompt && !promptDisplay)
        {
            createPromptDisplay();
            invalidateDisplayList();
        }
        else if (!showPrompt && promptDisplay)
        {
            removeChild(promptDisplay);
            promptDisplay = null;
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