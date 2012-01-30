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

import mx.events.FlexEvent;

import spark.components.TextArea;
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
 public class TextAreaSkin extends MobileSkin 
 {      
     //--------------------------------------------------------------------------
     //
     //  Class statics
     //
     //--------------------------------------------------------------------------
     private static const HORIZONTAL_PADDING:int = 8;
     private static const VERTICAL_PADDING:int = 12;
     private static const TEXT_HEIGHT_PADDING:int = 6;
     private static const CORNER_ELLIPSE_SIZE:uint = 16;
     
     //--------------------------------------------------------------------------
     //
     //  Constructor
     //
     //--------------------------------------------------------------------------
    public function TextAreaSkin()
    {
        super();
    }
    
    /**
     *  A strongly typed property that references the component to which this skin is applied.
     */
    public var hostComponent:TextArea; // SkinnableComponent will populate
      
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
        textDisplay.multiline = true;
        textDisplay.wordWrap = true;
        textDisplay.addEventListener(Event.CHANGE, textDisplay_changeHandler);
        textDisplay.addEventListener(FlexEvent.VALUE_COMMIT, textDisplay_changeHandler);
        addChild(textDisplay);
    }
    
    /**
     *  @private
     */
    override protected function measure():void
    {
        super.measure();
        
        // TextDisplay always defaults to 440 pixels wide, and tall enough to 
        // show all text.
        // 
        // You can set an explicit width and the height will adjust accordingly. The opposite
        // is not true: setting an explicit height will not adjust the width accordingly.
        textDisplay.commitStyles();
        measuredWidth = 440;
        measuredHeight = Math.max(textDisplay.textHeight + (VERTICAL_PADDING * 2), 55);
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
        resizePart(textDisplay, unscaledWidth - (HORIZONTAL_PADDING * 2), unscaledHeight - (VERTICAL_PADDING * 2) + TEXT_HEIGHT_PADDING);
        positionPart(textDisplay, HORIZONTAL_PADDING, VERTICAL_PADDING); 
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
    private function textDisplay_changeHandler(event:Event):void
    {
        invalidateSize();
    }
}
}