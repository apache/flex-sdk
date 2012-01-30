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
    private static const HORIZONTAL_PADDING:int = 8;
    private static const VERTICAL_PADDING:int = 12;
    private static const TEXT_WIDTH_PADDING:int = 4;
    private static const TEXT_HEIGHT_PADDING:int = 2;
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
     *  @private
     * 
     *  Instance of the border graphics.
     */
    private var border:DisplayObject;
        
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
    }
    
    /**
     *  @private
     */
    override protected function measure():void
    {
        super.measure();
        
        // commit styles so we can get a valid textHeight
        textDisplay.commitStyles();
        
        // Width is based on maxChars (if set), or hard-coded to 440
        if (hostComponent && hostComponent.maxChars)
        {
            // Grab the fontSize and subtract 2 as the pixel value for each character.
            // This is just an approximation, but it appears to be a reasonable one
            // for most input and most font.
            var characterWidth:int = Math.max(1, (getStyle("fontSize") - 2));
            measuredWidth =  (characterWidth * hostComponent.maxChars) + 
                (HORIZONTAL_PADDING * 2) + TEXT_WIDTH_PADDING;
        }
        else
        {
            measuredWidth = 440;
        }
        
        measuredHeight = textDisplay.textHeight + VERTICAL_PADDING * 2 + TEXT_HEIGHT_PADDING;
    }
    
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        // Draw the contentBackgroundColor
        graphics.clear();
        graphics.beginFill(getStyle("contentBackgroundColor"), getStyle("contentBackgroundAlpha"));
        graphics.drawRoundRect(1, 1, unscaledWidth - 2, unscaledHeight - 2, CORNER_ELLIPSE_SIZE, CORNER_ELLIPSE_SIZE);
        graphics.endFill();

        // position & size border
        resizePart(border, unscaledWidth, unscaledHeight);
        positionPart(border, 0, 0);

        // position & size the text
        textDisplay.commitStyles();
		var textHeight:Number = textDisplay.textHeight + TEXT_HEIGHT_PADDING;
        resizePart(textDisplay, unscaledWidth - (HORIZONTAL_PADDING * 2), textHeight);
        positionPart(textDisplay, HORIZONTAL_PADDING, Math.round((unscaledHeight - textHeight) / 2));  
    }
    
    /**
     *  @private
     */
    override public function styleChanged(styleProp:String):void
    {
        if (textDisplay)
            textDisplay.styleChanged(styleProp);
        super.styleChanged(styleProp);
    }
	
	/**
	 *  @private
	 */
	override protected function commitCurrentState():void
	{
		super.commitCurrentState();
		
		if (currentState == "normal")
			alpha = 1;
		else
			alpha = 0.5;
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