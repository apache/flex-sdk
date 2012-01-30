////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.skins.mobile 
{

import flash.display.DisplayObject;

import spark.components.TextInput;
import spark.components.supportClasses.MobileTextField;
import spark.skins.MobileSkin;

/**
 *  Actionscript based skin for mobile text input. 
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.0
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
        addChild(textDisplay);
    }
    
    /**
     *  @private
     */
    override protected function measure():void
    {
        super.measure();
        
        // TODO: Don't use hard-coded values
        measuredWidth = 440;
        measuredHeight = 55;
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
        textDisplay.height = unscaledHeight - (VERTICAL_PADDING * 2);
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
}
}