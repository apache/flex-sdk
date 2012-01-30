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

import flash.display.Graphics;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.system.Capabilities;

import mx.core.DPIClassification;
import mx.core.mx_internal;
import mx.events.FlexEvent;

import spark.components.Group;
import spark.components.Scroller;
import spark.components.TextArea;
import spark.components.VGroup;
import spark.components.supportClasses.StyleableTextField;
import spark.skins.mobile.supportClasses.TextSkinBase;
import spark.skins.mobile160.assets.TextInput_border;
import spark.skins.mobile240.assets.TextInput_border;
import spark.skins.mobile320.assets.TextInput_border;

use namespace mx_internal;

// FIXME (jasonsj): how to support TextArea#heightInLines?
/**
 *  ActionScript-based skin for TextArea components in mobile applications.
 * 
 * @see spark.components.TextArea
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
    
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function TextAreaSkin()
    {
        super();
        
        useChromeColor = false;
        
        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                borderClass = spark.skins.mobile320.assets.TextInput_border;
                layoutCornerEllipseSize = 24;
                layoutMeasuredWidth = 612;
                layoutMeasuredHeight = 106;
                layoutBorderSize = 2;
                
                break;
            }
            case DPIClassification.DPI_240:
            {
                borderClass = spark.skins.mobile240.assets.TextInput_border;
                layoutCornerEllipseSize = 12;
                layoutMeasuredWidth = 440;
                layoutMeasuredHeight = 70;
                layoutBorderSize = 1;
                
                break;
            }
            default:
            {
                borderClass = spark.skins.mobile160.assets.TextInput_border;
                layoutCornerEllipseSize = 12;
                layoutMeasuredWidth = 306;
                layoutMeasuredHeight = 53;
                layoutBorderSize = 1;
                
                break;
            }
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Skin parts
    //
    //--------------------------------------------------------------------------
    
    public var scroller:Scroller;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    /** 
     *  @copy spark.skins.spark.ApplicationSkin#hostComponent
     */
    public var hostComponent:TextArea;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    private var textDisplayGroup:VGroup;

    private var _isIOS:Boolean;
    
    /**
     *  @private
     */
    override protected function createChildren():void
    {
        if (!textDisplay)
        {
            // wrap StyleableTextField in UIComponent
            textDisplay = StyleableTextField(createInFontContext(StyleableTextField));
            textDisplay.styleName = this;
            textDisplay.multiline = true;
            textDisplay.editable = true;
            textDisplay.wordWrap = true;
            textDisplay.addEventListener(Event.CHANGE, textDisplay_changeHandler);
            textDisplay.addEventListener(FlexEvent.VALUE_COMMIT, textDisplay_changeHandler);
            
            // on iOS, resize the TextField and let the native control handle scrolling
            _isIOS = (Capabilities.version.indexOf("IOS") == 0);
            
            // wrap StyleableTextComponent in Group for viewport
            textDisplayGroup = new VGroup();
            textDisplayGroup.clipAndEnableScrolling = true;
            textDisplayGroup.addElement(textDisplay);
            
            // scroll to the caret position
            textDisplay.addEventListener(Event.CHANGE, caret_changeHandler);
            textDisplay.addEventListener(FlexEvent.VALUE_COMMIT, caret_changeHandler);
        }
        
        if (!scroller)
        {
            scroller = new Scroller();
            scroller.minViewportInset = 0;
            scroller.measuredSizeIncludesScrollBars = false;
            addChild(scroller);
        }
        
        if (!scroller.viewport)
            scroller.viewport = textDisplayGroup;
        
        super.createChildren();
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
        
        measuredWidth = layoutMeasuredWidth;
        
        // now we need to measure textDisplay's height.  Unfortunately, this is tricky and 
        // is dependent on textDisplay's width
        
        
        measuredHeight = Math.max(layoutMeasuredHeight, textDisplay.measuredTextSize.y + paddingTop + paddingBottom);
    }
    
    /**
     * @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        drawBackground(unscaledWidth, unscaledHeight);
        
        // position & size border
        if (border)
        {
            setElementSize(border, unscaledWidth, unscaledHeight);
            setElementPosition(border, 0, 0);
        }
        
        setElementSize(scroller, unscaledWidth, unscaledHeight);
        setElementPosition(scroller, 0, 0);
        
        // position & size the text
        var paddingLeft:Number = getStyle("paddingLeft");
        var paddingRight:Number = getStyle("paddingRight");
        var paddingTop:Number = getStyle("paddingTop");
        var paddingBottom:Number = getStyle("paddingBottom");
        
        textDisplayGroup.paddingLeft = paddingLeft;
        textDisplayGroup.paddingRight = paddingRight;
        textDisplayGroup.paddingTop = paddingTop;
        textDisplayGroup.paddingBottom = paddingBottom;
        
        var unscaledTextWidth:Number = unscaledWidth - paddingLeft - paddingRight;
        
        // set width first to measure height correctly
        textDisplay.width = unscaledTextWidth;
        
        var unscaledTextHeight:Number = unscaledHeight - paddingTop - paddingBottom;
        var textHeight:Number = unscaledTextHeight;
        
        // TextField height should match it's content or the TextArea bounds
        // iOS special case to prevent Flex Scroller scrolling
        if (!_isIOS || !textDisplay.editable)
            textHeight = Math.max(textDisplay.measuredTextSize.y, textHeight);
        
        setElementSize(textDisplay, unscaledTextWidth, textHeight);
        
        // size the Group to the StyleableTextField plus padding
        setElementSize(textDisplayGroup, unscaledWidth, paddingTop + textHeight + paddingBottom);
        
        if (promptDisplay)
        {
            promptDisplay.commitStyles();
            setElementSize(promptDisplay, unscaledTextWidth, unscaledTextHeight);
            setElementPosition(promptDisplay, paddingLeft, paddingTop);
        }
    }
    
    private function caret_changeHandler(event:Event):void
    {
        // TODO (jasonsj): caret positioning on iOS
        // textDisplayGroup.verticalScrollPosition = textDisplay.getCharBoundaries(textDisplay.caretIndex).y;
    }
    
    /**
     *  @private
     */
    private function textDisplay_changeHandler(event:Event):void
    {
        textDisplayGroup.invalidateSize();
    }
}
}