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

import mx.core.mx_internal;
import mx.events.FlexEvent;

import spark.components.TextArea;
import spark.skins.mobile.supportClasses.MobileSkin;
import spark.skins.mobile.supportClasses.TextSkinBase;
import spark.skins.mobile160.assets.TextInput_border;
import spark.skins.mobile240.assets.TextInput_border;

use namespace mx_internal;

/**
 *  Base mobile skin for spark.components.TextArea
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class TextAreaSkin extends TextSkinBase 
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    public function TextAreaSkin()
    {
        super();
        
        useChromeColor = false;
        
        switch (targetDensity)
        {
            case MobileSkin.PPI240:
            {
                borderClass = spark.skins.mobile240.assets.TextInput_border;
                layoutCornerEllipseSize = 16;
                layoutMeasuredWidth = 440;
                layoutMeasuredHeight = 55;
                layoutBorderSize = 1;
                
                break;
            }
            default:
            {
                // TODO (jasonsj) 160ppi XD spec
                // default PPI160
                borderClass = spark.skins.mobile160.assets.TextInput_border;
                layoutCornerEllipseSize = 16;
                layoutMeasuredWidth = 440;
                layoutMeasuredHeight = 55;
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
    
    public var hostComponent:TextArea;
    
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
        
        textDisplay.multiline = true;
        textDisplay.wordWrap = true;
        textDisplay.addEventListener(Event.CHANGE, textDisplay_changeHandler);
        textDisplay.addEventListener(FlexEvent.VALUE_COMMIT, textDisplay_changeHandler);
    }
    
    /**
     *  @private
     */
    override protected function measure():void
    {
        super.measure();
        
        var paddingTop:Number = getStyle("paddingTop");
        var paddingBottom:Number = getStyle("paddingBottom");
        
        // TextDisplay always defaults to 440 pixels wide, and tall enough to 
        // show all text.
        // 
        // You can set an explicit width and the height will adjust accordingly. The opposite
        // is not true: setting an explicit height will not adjust the width accordingly.
        textDisplay.commitStyles();
        measuredWidth = layoutMeasuredWidth;
        measuredHeight = Math.max(textDisplay.textHeight + paddingTop + paddingBottom + (TEXT_HEIGHT_PADDING * 2), layoutMeasuredHeight);
    }
    
    /**
     *  @private
     *  Default verticalAlign="top"
     */
    override mx_internal function getTextTop(unscaledHeight:Number, paddingTop:Number, paddingBottom:Number):Number
    {
        return paddingTop;
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