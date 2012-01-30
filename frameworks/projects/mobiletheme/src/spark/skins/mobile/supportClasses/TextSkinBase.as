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

import spark.components.supportClasses.StyleableTextField;

use namespace mx_internal;

/**
 *  ActionScript-based skin for text input controls in mobile applications that
 *  uses a StyleableTextField class for the text display. 
 * 
 *  @see spark.components.supportClasses.StyleableTextField
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
    public function TextSkinBase()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Graphics variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Defines the border.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */  
    protected var borderClass:Class;
    
    //--------------------------------------------------------------------------
    //
    //  Layout variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Defines the corner radius.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */  
    protected var layoutCornerEllipseSize:uint;
    
    protected var layoutBorderSize:uint;
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     * 
     *  Instance of the border graphics.
     */
    protected var border:DisplayObject;
    
    private var borderVisibleChanged:Boolean = false;
    
    //--------------------------------------------------------------------------
    //
    //  Skin parts
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
        
        if (!textDisplay)
        {
            textDisplay = StyleableTextField(createInFontContext(StyleableTextField));
            textDisplay.styleName = this;
            textDisplay.editable = true;
            textDisplay.useTightTextBounds = false;
            addChild(textDisplay);
        }
        
        if (!border)
        {
            border = new borderClass();
            addChild(border);
        }
    }
    
    /**
     *  @private 
     */ 
    protected function createPromptDisplay():StyleableTextField
    {
        var prompt:StyleableTextField = StyleableTextField(createInFontContext(StyleableTextField));
        prompt.styleName = this;
        prompt.editable = false;
        prompt.mouseEnabled = false;
        prompt.useTightTextBounds = false;
        
        return prompt;
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
                border = new borderClass();
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
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.drawBackground(unscaledWidth, unscaledHeight);
        
        var borderSize:uint = (border) ? layoutBorderSize : 0;
        var borderWidth:uint = borderSize * 2;
        
        // Draw the contentBackgroundColor
        graphics.beginFill(getStyle("contentBackgroundColor"), getStyle("contentBackgroundAlpha"));
        graphics.drawRoundRect(borderSize, borderSize, unscaledWidth - borderWidth, unscaledHeight - borderWidth, layoutCornerEllipseSize, layoutCornerEllipseSize);
        graphics.endFill();
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
            promptDisplay = createPromptDisplay();
            addChild(promptDisplay);
        }
        else if (!showPrompt && promptDisplay)
        {
            removeChild(promptDisplay);
            promptDisplay = null;
        }
        
        invalidateDisplayList();
    }   
}
}