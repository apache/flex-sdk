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
import spark.components.supportClasses.MobileTextField;
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
    public var textDisplay:MobileTextField;
    
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
        
        textDisplay = MobileTextField(createInFontContext(MobileTextField));
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
        graphics.drawRoundRect(2, 2, unscaledWidth - 4, unscaledHeight - 4, 4, 4);
        graphics.endFill();
        
        // position & size border
        border.x = border.y = 0;
        border.width = unscaledWidth;
        border.height = unscaledHeight;
        
        // position & size the text
        textDisplay.commitStyles();
        textDisplay.x = HORIZONTAL_PADDING;
        textDisplay.width = unscaledWidth - (HORIZONTAL_PADDING * 2);
        textDisplay.y = VERTICAL_PADDING;
        textDisplay.height = unscaledHeight - (VERTICAL_PADDING * 2) + TEXT_HEIGHT_PADDING;
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
    private function textDisplay_changeHandler(event:Event):void
    {
        invalidateSize();
    }
}
}