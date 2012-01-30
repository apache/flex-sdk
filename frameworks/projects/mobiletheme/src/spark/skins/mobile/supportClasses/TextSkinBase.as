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

package spark.skins.mobile.supportClasses
{

import flash.display.DisplayObject;

import mx.core.mx_internal;
import mx.events.PropertyChangeEvent;

import spark.components.supportClasses.StyleableTextField;
import spark.skins.mobile.assets.TextInput_border;

use namespace mx_internal;

/**
 *  Actionscript based skin for mobile text input. 
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class TextSkinBase extends MobileSkin 
{
    //--------------------------------------------------------------------------
    //
    //  Class statics
    //
    //--------------------------------------------------------------------------
    
    // StylableTextField padding
    protected static const TEXT_WIDTH_PADDING:int = 4;
    protected static const TEXT_HEIGHT_PADDING:int = 2;
    
    // FXG measurements
    private static const BORDER_SIZE:uint = 1;
    private static const CORNER_ELLIPSE_SIZE:uint = 16;
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    public function TextSkinBase()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  textDisplay skin part.
     */
    public var textDisplay:StyleableTextField;
    
    [Bindable]
    /**
     *  Bindable promptDisplay skin part. Bindings fire when promptDisplay is
     *  removed and added for proper updating by the SkinnableTextBase.
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
        
        var unscaledTextWidth:Number = unscaledWidth - paddingLeft - paddingRight;
        var unscaledTextHeight:Number = unscaledHeight - paddingTop;
        var textTopPosition:Number = getTextTop(unscaledHeight, paddingTop, paddingBottom);
        
        if (textDisplay)
        {
            textDisplay.commitStyles();
            
            resizePart(textDisplay, unscaledTextWidth, unscaledTextHeight);
            positionPart(textDisplay, paddingLeft, textTopPosition);
        }
        
        if (promptDisplay)
        {
            promptDisplay.commitStyles();
            resizePart(promptDisplay, unscaledTextWidth, unscaledTextHeight);
            positionPart(promptDisplay, paddingLeft, textTopPosition);
        }
    }
    
    /**
     *  @private
     *  Specifies the location of the textDisplay and promptDisplay skin parts.
     *  Position is based on the following in-order: verticalAlign="middle",
     *  paddingTop, paddingBottom.
     */
    mx_internal function getTextTop(unscaledHeight:Number, paddingTop:Number, paddingBottom:Number):Number
    {
        var textTop:Number = paddingTop;
        
        if (textDisplay)
        {
            // verticalAlign=middle or paddingTop
            textTop = Math.max((unscaledHeight - textDisplay.textHeight) / 2, paddingTop);
            
            // nudge up if paddingBottom is greater than the remaining space
            var bottomSpace:Number = unscaledHeight - (textTop + textDisplay.textHeight);
            bottomSpace = paddingBottom - bottomSpace;
            textTop = (bottomSpace > 0) ? Math.max(paddingTop, textTop - bottomSpace) : textTop;
        }
        
        return textTop;
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
        }
        else if (!showPrompt && promptDisplay)
        {
            removeChild(promptDisplay);
            promptDisplay = null;
        }
    }
}
}