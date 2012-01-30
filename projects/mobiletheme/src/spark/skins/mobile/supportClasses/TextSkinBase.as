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
    
    // FIXME (jasonsj) how do PPI skins handle text gutter?
    // StylableTextField padding
    protected static const TEXT_WIDTH_PADDING:int = 4;
    
    protected static const TEXT_HEIGHT_PADDING:int = 2;
    
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
    //  Graphics variables
    //
    //--------------------------------------------------------------------------
    
    protected var borderClass:Class;
    
    //--------------------------------------------------------------------------
    //
    //  Layout variables
    //
    //--------------------------------------------------------------------------
    
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
    mx_internal var border:DisplayObject;
    
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
    
    override public function get isFocusColorSupported():Boolean
    {
        return false;
    }
    
    /**
     *  @private
     */
    override protected function createChildren():void
    {
        super.createChildren();
        
        border = new borderClass();
        addChild(border);
        
        textDisplay = StyleableTextField(createInFontContext(StyleableTextField));
        textDisplay.styleName = this;
        textDisplay.editable = true;
        addChild(textDisplay);
        
        createPromptDisplay();
    }
    
    protected function createPromptDisplay():void
    {
        promptDisplay = StyleableTextField(createInFontContext(StyleableTextField));
        promptDisplay.styleName = this;
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
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
		graphics.clear();
		
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        drawBackground(unscaledWidth, unscaledHeight);

        layoutContents(unscaledWidth, unscaledHeight);
    }
	
	/**
	 *  Renders a background for the skin
	 * 
	 *  <p>This method, along with <code>layoutContents()</code>, is called 
	 *  by the <code>updateDisplayList()</code> method.</p>
	 * 
	 *  @param unscaledWidth Specifies the width of the component, in pixels,
	 *  in the component's coordinates, regardless of the value of the
	 *  <code>scaleX</code> property of the component.
	 *
	 *  @param unscaledHeight Specifies the height of the component, in pixels,
	 *  in the component's coordinates, regardless of the value of the
	 *  <code>scaleY</code> property of the component.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10.1
	 *  @playerversion AIR 2.5
	 *  @productversion Flex 4.5
	 */
	protected function drawBackground(unscaledWidth:Number, 
									  unscaledHeight:Number):void
	{
		var borderSize:uint = (border) ? layoutBorderSize : 0;
		var borderWidth:uint = borderSize * 2;
		
		// Draw the contentBackgroundColor
		graphics.clear();
		graphics.beginFill(getStyle("contentBackgroundColor"), getStyle("contentBackgroundAlpha"));
		graphics.drawRoundRect(borderSize, borderSize, unscaledWidth - borderWidth, unscaledHeight - borderWidth, layoutCornerEllipseSize, layoutCornerEllipseSize);
		graphics.endFill();
	}
    
	/**
	 *  Positions the children for this skin
	 * 
	 *  <p>This method, along with <code>drawBackground()</code>, is called 
	 *  by the <code>updateDisplayList()</code> method.</p>
	 * 
	 *  <p>This method positions the <code>textDisplay</code> component.  
	 *  Subclasses should override this to position their children.</p>
	 * 
	 *  @param unscaledWidth Specifies the width of the component, in pixels,
	 *  in the component's coordinates, regardless of the value of the
	 *  <code>scaleX</code> property of the component.
	 *
	 *  @param unscaledHeight Specifies the height of the component, in pixels,
	 *  in the component's coordinates, regardless of the value of the
	 *  <code>scaleY</code> property of the component.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10.1
	 *  @playerversion AIR 2.5
	 *  @productversion Flex 4.5
	 */
	protected function layoutContents(unscaledWidth:Number, 
									  unscaledHeight:Number):void
	{
		// position & size border
		if (border)
		{
			resizeElement(border, unscaledWidth, unscaledHeight);
			positionElement(border, 0, 0);
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
			
			resizeElement(textDisplay, unscaledTextWidth, unscaledTextHeight);
			positionElement(textDisplay, paddingLeft, textTopPosition);
		}
		
		if (promptDisplay)
		{
			promptDisplay.commitStyles();
			resizeElement(promptDisplay, unscaledTextWidth, unscaledTextHeight);
			positionElement(promptDisplay, paddingLeft, textTopPosition);
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
            // FIXME (jasonsj) use measuredHeight
            // var textHeight:Number = textDisplay.measuredHeight;
            // textTop = Math.max((unscaledHeight - textHeight) / 2, paddingTop);
            // var bottomSpace:Number = unscaledHeight - (textTop + textHeight);
            
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