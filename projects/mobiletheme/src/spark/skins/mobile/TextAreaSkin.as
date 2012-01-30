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
import flash.events.KeyboardEvent;
import flash.geom.Rectangle;
import flash.system.Capabilities;
import flash.ui.Keyboard;

import mx.core.DPIClassification;
import mx.core.mx_internal;
import mx.events.FlexEvent;

import spark.components.Scroller;
import spark.components.TextArea;
import spark.components.VGroup;
import spark.components.supportClasses.StyleableTextField;
import spark.skins.mobile.supportClasses.TextSkinBase;
import spark.skins.mobile160.assets.TextInput_border;
import spark.skins.mobile240.assets.TextInput_border;
import spark.skins.mobile320.assets.TextInput_border;

use namespace mx_internal;

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
                minWidth = 48;
                minHeight = 106;
                layoutBorderSize = 2;
                
                break;
            }
            case DPIClassification.DPI_240:
            {
                borderClass = spark.skins.mobile240.assets.TextInput_border;
                layoutCornerEllipseSize = 12;
                layoutMeasuredWidth = 440;
                minWidth = 24;
                minHeight = 70;
                layoutBorderSize = 1;
                
                break;
            }
            default:
            {
                borderClass = spark.skins.mobile160.assets.TextInput_border;
                layoutCornerEllipseSize = 12;
                layoutMeasuredWidth = 306;
                minWidth = 24;
                minHeight = 53;
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
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Default width per DPI.
     */
    private var layoutMeasuredWidth:Number;
    
    /**
     *  @private
     *  The width of the component on the previous layout manager 
     *  pass.  This gets set in updateDisplayList() and used in measure() on 
     *  the next layout pass.  This is so our "guessed width" in measure() 
     *  will be as accurate as possible since textDisplay is multiline and 
     *  the textDisplay height is dependent on the width.
     * 
     *  In the constructor this is actually set based on the DPI.
     */
    private var oldUnscaledWidth:Number;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    private var textDisplayGroup:VGroup;
    
    private var _isIOS:Boolean;
    
    private var invalidateCaretPosition:Boolean = true;
    
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
            
            // on iOS, resize the TextField and let the native control handle scrolling
            _isIOS = (Capabilities.version.indexOf("IOS") == 0);
            
            if (!_isIOS)
                textDisplay.addEventListener(KeyboardEvent.KEY_DOWN, textDisplay_keyHandler);
            
            textDisplay.addEventListener(Event.CHANGE, textDisplay_changeHandler);
            textDisplay.addEventListener(FlexEvent.VALUE_COMMIT, textDisplay_changeHandler);
            
            // wrap StyleableTextComponent in Group for viewport
            textDisplayGroup = new VGroup();
            textDisplayGroup.clipAndEnableScrolling = true;
            textDisplayGroup.addElement(textDisplay);
        }
        
        if (!scroller)
        {
            scroller = new Scroller();
            scroller.minViewportInset = 0;
            scroller.measuredSizeIncludesScrollBars = false;
            scroller.ensureFocusedElementIsVisible = false;
            addChild(scroller);
        }
        
        if (!scroller.viewport)
            scroller.viewport = textDisplayGroup;
        
        super.createChildren();
    }
    
    /**
     *  @private
     *  TextArea prompt supports wrapping and multiline
     */
    override protected function createPromptDisplay():StyleableTextField
    {
        var prompt:StyleableTextField = super.createPromptDisplay();
        prompt.editable = true;
        prompt.wordWrap = true;
        
        return prompt;
    }
    
    /**
     *  @private
     */
    override protected function measure():void
    {
        super.measure();
        
        var paddingTop:Number = getStyle("paddingTop");
        var paddingBottom:Number = getStyle("paddingBottom");
        var paddingLeft:Number = getStyle("paddingLeft");
        var paddingRight:Number = getStyle("paddingRight");
        
        // TextDisplay always defaults to 440 pixels wide (the value is DPI dependent), 
        // and tall enough to show all text.
        // 
        // You can set an explicit width and the height will adjust accordingly. The opposite
        // is not true: setting an explicit height will not adjust the width accordingly.
        
        measuredWidth = layoutMeasuredWidth;
        
        // now we need to measure textDisplay's height.  Unfortunately, this is tricky and 
        // is dependent on textDisplay's width.  Let's use the heuristic that our width 
        // is the same as our last width.
        // We don't use layoutMeasuredWidth, because that value is just a constant and doesn't
        // take into account the fact that the TextArea could have an explicitWidth or could 
        // be constrained by some value.  However, we still default oldTextDisplayWidth to 
        // be layoutMeasuredWidth the first time through.
        var textDisplayEstimatedWidth:Number = oldUnscaledWidth - paddingLeft - paddingRight;
        
        // now we need to measure textDisplay's height.  Unfortunately, this is tricky and 
        // is dependent on textDisplay's width.  
        // Use the old textDisplay width as an estimte for the new one.  
        // If we are wrong, we'll find out in updateDisplayList()
        textDisplay.commitStyles();
        setElementSize(textDisplay, textDisplayEstimatedWidth, NaN);
        
        measuredHeight = getElementPreferredHeight(textDisplay) + paddingTop + paddingBottom;
    }
    
    override protected function layoutContents(unscaledWidth:Number, 
                                               unscaledHeight:Number):void
    {
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
        var unscaledTextHeight:Number = unscaledHeight - paddingTop - paddingBottom;
        var textHeight:Number = unscaledTextHeight;
        
        // set width first to measure height correctly
        textDisplay.commitStyles();
        textDisplay.width = unscaledTextWidth;
        
        // TextField height should match its content or the TextArea bounds at minimum
        // iOS special case to prevent Flex Scroller scrolling when editable
        if (!_isIOS || !textDisplay.editable)
            textHeight = Math.max(textDisplay.measuredTextSize.y, textHeight);
        
        // FIXME (jasonsj): iOS native scroll bar appears even when explictHeight
        //                  is not specified. Focus-in is jumpy.
        
        if (promptDisplay)
        {
            promptDisplay.commitStyles();
            setElementSize(promptDisplay, unscaledTextWidth, textHeight);
            setElementPosition(promptDisplay, paddingLeft, paddingTop);
            
            // no need to update textDisplay if promptDisplay is present
            return;
        }
        
        // TextField will auto scroll to a new line before we can resize it to
        // fit the new text. Adjust scrollV so that all text is visible.
        // FIXME (jasonsj): is this needed for iOS?
        if (textDisplay.scrollV > 1)
            textDisplay.scrollV = 1;
        
        // grab old measured textDisplay height before resizing it
        var oldPreferredTextHeight:Number = getElementPreferredHeight(textDisplay);
        
        // keep track of oldUnscaledWidth so we have a good guess as to the width 
        // of the textDisplay on the next measure() pass
        oldUnscaledWidth = unscaledWidth;
        
        // set the width of textDisplay to textWidth.
        // set the height to oldTextHeight.  If the height's actually wrong, 
        // we'll invalidateSize() and go through this layout pass again anyways
        setElementSize(textDisplay, unscaledTextWidth, textHeight);
        
        // grab new measured textDisplay height after the textDisplay has taken its final width
        var newPreferredTextHeight:Number = getElementPreferredHeight(textDisplay);
        
        // if the resize caused the textDisplay's height to change (because of 
        // text reflow), then we need to remeasure ourselves with our new width
        if (oldPreferredTextHeight != newPreferredTextHeight)
            invalidateSize();
        
        // if height is unspecified, grow the StyleableTextField
        if (isNaN(hostComponent.explicitHeight))
        {
            // explicitly size the scroller since the StyleableTextField does not
            // invalidate it's parent
            setElementSize(scroller, unscaledWidth, textHeight + paddingTop + paddingBottom);
        }
        else if (invalidateCaretPosition)
        {
            // if the caret is outside the viewport, update the Group verticalScrollPosition
            var charIndex:int = textDisplay.selectionBeginIndex;
            var caretBounds:Rectangle = textDisplay.getCharBoundaries(charIndex);
            var lineIndex:int = textDisplay.getLineIndexOfChar(charIndex);
            
            // getCharBoundaries() returns null for new lines
            if (!caretBounds)
            {
                // temporarily insert a character at the caretIndex
                textDisplay.replaceText(charIndex, charIndex, "W");
                caretBounds = textDisplay.getCharBoundaries(charIndex);
                lineIndex = textDisplay.getLineIndexOfChar(charIndex);
                textDisplay.replaceText(charIndex, charIndex + 1, "");
            }
            
            if (caretBounds)
            {
                // caretTopPositon and caretBottomPosition are TextField-relative positions
                // the TextField is inset by padding styles of the TextArea (via the VGroup)
                
                // adjust top position to 0 when on the first line
                // caretTopPosition will be negative when off stage
                var caretTopPosition:Number = ((caretBounds.y) < 0 || (lineIndex == 0))
                    ? 0 : caretBounds.y;
                
                // caretBottomPosition is the y coordinate of the bottom bounds of the caret
                var caretBottomPosition:Number = caretBounds.y + caretBounds.height;
                
                // note that verticalScrollPosition min/max do not account for padding
                var vspTop:Number = textDisplayGroup.verticalScrollPosition;
                
                // vspBottom should be the max visible Y in the TextField
                // coordinate space.
                // remove paddingBottom for some clearance between caret and border
                var vspBottom:Number = vspTop + unscaledHeight - paddingTop - paddingBottom;
                
                // is the caret in or below the padding and viewport?
                if (caretBottomPosition > vspBottom)
                {
                    // adjust caretBottomPosition to max scroll position when on the last line
                    if (lineIndex + 1 == textDisplay.numLines)
                    {
                        // use textHeight+paddings instead of textDisplayGroup.contentHeight
                        // Group has not been resized by this point
                        textDisplayGroup.verticalScrollPosition = (textHeight + paddingTop + paddingBottom) - textDisplayGroup.height;
                    }
                    else
                    {
                        // bottom edge of the caret moves just inside the bottom edge of the scroller
                        // add delta between caret and vspBottom
                        textDisplayGroup.verticalScrollPosition = vspTop + (caretBottomPosition - vspBottom);
                    }
                }
                // is the caret above the viewport?
                else if (caretTopPosition < vspTop)
                {
                    // top edge of the caret moves inside the top edge of the scroller
                    textDisplayGroup.verticalScrollPosition = caretTopPosition;
                }
            }
            
            invalidateCaretPosition = false;
        }
    }
    
    /**
     *  @private
     *  Handle size and caret position changes that occur when text content
     *  changes.
     */
    private function textDisplay_changeHandler(event:Event):void
    {
        invalidateDisplayList();
        invalidateCaretPosition = true;
        
        if (isNaN(hostComponent.explicitHeight))
        {
            // invalidate TextAreaSkin size to grow/shrink with content
            invalidateSize();
        }
        else
        {
            // invalidate the Group size to update the Scroller
            textDisplayGroup.invalidateSize();
        }
    }
    
    /**
     *  @private
     *  Adjust viewport when using key navigation
     */
    private function textDisplay_keyHandler(event:KeyboardEvent):void
    {
        // update scroll position when caret changes
        if (!isNaN(hostComponent.explicitHeight) &&
            (event.keyCode == Keyboard.UP
                || event.keyCode == Keyboard.DOWN
                || event.keyCode == Keyboard.LEFT
                || event.keyCode == Keyboard.RIGHT))
        {
            invalidateDisplayList();
            invalidateCaretPosition = true;
        }
    }
    
    /**
     *  @private
     */
    override public function styleChanged(styleProp:String):void
    {
        super.styleChanged(styleProp);
        
        // propogate styleChanged explicitly to textDisplay
        if (textDisplay)
            textDisplay.styleChanged(styleProp);
    }
}
}