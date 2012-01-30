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
import flash.events.SoftKeyboardEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.system.Capabilities;
import flash.ui.Keyboard;

import mx.core.DPIClassification;
import mx.core.mx_internal;
import mx.events.FlexEvent;

import spark.components.Group;
import spark.components.Scroller;
import spark.components.TextArea;
import spark.components.supportClasses.StyleableTextField;
import spark.events.CaretBoundsChangeEvent;
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
        
        addEventListener(Event.RESIZE, resizeHandler);
        
        switch (applicationDPI)
        {
            case DPIClassification.DPI_320:
            {
                borderClass = spark.skins.mobile320.assets.TextInput_border;
                layoutCornerEllipseSize = 24;
                measuredDefaultWidth = 612;
                measuredDefaultHeight = 106;
                layoutBorderSize = 2;
                
                break;
            }
            case DPIClassification.DPI_240:
            {
                borderClass = spark.skins.mobile240.assets.TextInput_border;
                layoutCornerEllipseSize = 12;
                measuredDefaultWidth = 440;
                measuredDefaultHeight = 70;
                layoutBorderSize = 1;
                
                break;
            }
            default:
            {
                borderClass = spark.skins.mobile160.assets.TextInput_border;
                layoutCornerEllipseSize = 12;
                measuredDefaultWidth = 306;
                measuredDefaultHeight = 53;
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
    
    /**
     *  Scroller skin part.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */ 
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
     *  The width of the component on the previous layout manager 
     *  pass.  This gets set in updateDisplayList() and used in measure() on 
     *  the next layout pass.  This is so our "guessed width" in measure() 
     *  will be as accurate as possible since textDisplay is multiline and 
     *  the textDisplay height is dependent on the width.
     * 
     *  In the constructor this is actually set based on the DPI.
     */
    mx_internal var oldUnscaledWidth:Number;
    
    private var textDisplayGroup:Group;
    private var _isIOS:Boolean;
    private var invalidateCaretPosition:Boolean = true;
    private var oldCaretBounds:Rectangle = new Rectangle(-1, -1, -1, -1);
    private var lastTextHeight:Number;
    private var lastTextWidth:Number;
    
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
        if (!textDisplay)
        {
            // wrap StyleableTextField in UIComponent
            textDisplay = StyleableTextField(createInFontContext(StyleableTextField));
            textDisplay.styleName = this;
            textDisplay.multiline = true;
            textDisplay.editable = true;
            textDisplay.lineBreak = getStyle("lineBreak");
            textDisplay.useTightTextBounds = false;
            textDisplay.scrollToRangeDelegate = scrollToRange;
            
            // on iOS, resize the TextField and let the native control handle scrolling
            _isIOS = (Capabilities.version.indexOf("IOS") == 0);
            
            if (!_isIOS)
                textDisplay.addEventListener(KeyboardEvent.KEY_DOWN, textDisplay_keyHandler);
            
            textDisplay.addEventListener(Event.CHANGE, textDisplay_changeHandler);
            textDisplay.addEventListener(FlexEvent.VALUE_COMMIT, textDisplay_changeHandler);
            textDisplay.addEventListener(Event.SCROLL, textDisplay_scrollHandler);
            textDisplay.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATE, textDisplay_softKeyboardActivateHandler);
            
            textDisplay.left = getStyle("paddingLeft");
            textDisplay.top = getStyle("paddingTop");
            textDisplay.right = getStyle("paddingRight");
            textDisplay.bottom = getStyle("paddingBottom");
            
            // wrap StyleableTextComponent in Group for viewport
            textDisplayGroup = new Group();
            textDisplayGroup.clipAndEnableScrolling = true;
            textDisplayGroup.addElement(textDisplay);
        }
        
        if (!scroller)
        {
            scroller = new Scroller();
            scroller.minViewportInset = 0;
            scroller.measuredSizeIncludesScrollBars = false;
            scroller.ensureElementIsVisibleForSoftKeyboard = false;
            
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
        
        measuredWidth = measuredDefaultWidth;
        
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
        
        // Clear min sizes first.
        textDisplay.minWidth = textDisplay.minHeight = NaN;
        
        // If lineBreak == explicit, always use NaN for estimated width
        if (getStyle("lineBreak") == "explicit")
            textDisplayEstimatedWidth = NaN;
        
        setElementSize(textDisplay, textDisplayEstimatedWidth, NaN);
        
        measuredHeight = getElementPreferredHeight(textDisplay) + paddingTop + paddingBottom;
    }
    
    /**
     *  @private
     */
    override protected function layoutContents(unscaledWidth:Number, 
                                               unscaledHeight:Number):void
    {
        super.layoutContents(unscaledWidth, unscaledHeight);
        
        // position & size border
        if (border)
        {
            setElementSize(border, unscaledWidth, unscaledHeight);
            setElementPosition(border, 0, 0);
        }
        
        setElementSize(scroller, unscaledWidth, unscaledHeight);
        setElementPosition(scroller, 0, 0);
        
        // position & size the text
        var explicitLineBreak:Boolean = getStyle("lineBreak") == "explicit";
        var paddingLeft:Number = getStyle("paddingLeft");
        var paddingRight:Number = getStyle("paddingRight");
        var paddingTop:Number = getStyle("paddingTop");
        var paddingBottom:Number = getStyle("paddingBottom");
        
        var unscaledTextWidth:Number = unscaledWidth - paddingLeft - paddingRight;
        var unscaledTextHeight:Number = unscaledHeight - paddingTop - paddingBottom;
        var textHeight:Number = unscaledTextHeight;
        var textWidth:Number = explicitLineBreak ? textDisplay.measuredTextSize.x : unscaledTextWidth;
        
        // grab old measured textDisplay height before resizing it
        var oldPreferredTextHeight:Number = getElementPreferredHeight(textDisplay);
        
        // set width first to measure height correctly
        textDisplay.commitStyles();
        textDisplay.setLayoutBoundsSize(textWidth, NaN);
        
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
        
        // keep track of oldUnscaledWidth so we have a good guess as to the width 
        // of the textDisplay on the next measure() pass
        oldUnscaledWidth = unscaledWidth;
        
        // set the width of textDisplay to textWidth.
        // set the height to oldTextHeight.  If the height's actually wrong, 
        // we'll invalidateSize() and go through this layout pass again anyways
        setElementSize(textDisplay, textWidth, textHeight);
        
        // Set minWidth/Height on the text so the textDisplayGroup sizes accordingly
        textDisplay.minWidth = textWidth;
        textDisplay.minHeight = textHeight;
        textDisplayGroup.invalidateDisplayList();
        
        // grab new measured textDisplay height after the textDisplay has taken its final width
        var newPreferredTextHeight:Number = getElementPreferredHeight(textDisplay);
        
        // if the resize caused the textDisplay's height to change (because of 
        // text reflow), then we need to remeasure ourselves with our new width
        if (oldPreferredTextHeight != newPreferredTextHeight)
            invalidateSize();
        
        // checking if text fits in TextArea
        // does not apply to iOS due to native text editing and scrolling
        // invalidateCaretPosition will never be true for iOS
        if (invalidateCaretPosition)
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
                // Scroll the internal Scroller to ensure the caret is visible
                if (textHeight > unscaledTextHeight)
                {
                    
                    if (charIndex == textDisplay.text.length)
                    {
                        // Make sure textDisplayGroup is validated, otherwise the 
                        // verticalScrollPosition may be out of bounds, which will
                        // cause a bounce effect.
                        textDisplayGroup.validateNow();
                        textDisplayGroup.verticalScrollPosition = textHeight;
                    }
                    else
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
                    
                    scroller.validateNow();
                }
                
                // Convert to local coordinates
                // Dispatch an event for an ancestor Scroller
                // It will scroll the TextArea so the caret is in view
                convertBoundsToLocal(caretBounds);
                if (caretBounds.bottom != oldCaretBounds.bottom || caretBounds.top != oldCaretBounds.top)
                    dispatchEvent(new CaretBoundsChangeEvent(CaretBoundsChangeEvent.CARET_BOUNDS_CHANGE,true,true,oldCaretBounds,caretBounds));
                
                oldCaretBounds = caretBounds;   
            }

            invalidateCaretPosition = false;
        }
        
        // Make sure final scroll position is valid
        snapTextScrollPosition();
    }

    /**
     *  @private
     *  Make sure the scroll positions are valid, and adjust if needed.
     */
    private function snapTextScrollPosition():void
    {
        var maxHsp:Number = textDisplayGroup.contentWidth > textDisplayGroup.width ? 
            textDisplayGroup.contentWidth-textDisplayGroup.width : 0; 
        textDisplayGroup.horizontalScrollPosition = 
            Math.min(Math.max(0,textDisplayGroup.horizontalScrollPosition),maxHsp);
        
        var maxVsp:Number = textDisplayGroup.contentHeight > textDisplayGroup.height ? 
            textDisplayGroup.contentHeight-textDisplayGroup.height : 0; 
        
        textDisplayGroup.verticalScrollPosition = 
            Math.min(Math.max(0,textDisplayGroup.verticalScrollPosition),maxVsp);
    }
    
    /**
     *  @private
     *  Get the bounds of the caret
     */    
    private function getCaretBounds():Rectangle
    {
        var charIndex:int = textDisplay.selectionBeginIndex;
        var caretBounds:Rectangle = textDisplay.getCharBoundaries(charIndex);
        
        if (!caretBounds)
        {
            textDisplay.replaceText(charIndex, charIndex, "W");
            caretBounds = textDisplay.getCharBoundaries(charIndex);
            textDisplay.replaceText(charIndex, charIndex + 1, "");
        }
        
        return caretBounds;
    }
    
    /**
     *  @private
     *  Convert bounds from textDisplay to local coordinates
     */
    private function convertBoundsToLocal(bounds:Rectangle):void
    {
        if (bounds)
        {
            var position:Point = new Point(bounds.x, bounds.y);
            position = textDisplay.localToGlobal(position);
            position = globalToLocal(position);
            bounds.x = position.x;
            bounds.y = position.y;
        }
    }
    
    /**
     *  @private
     */
    private function scrollToRange(anchorPosition:int, activePosition:int):void
    {
        var pos:int = Math.min(anchorPosition, activePosition);
        var bounds:Rectangle = textDisplay.getCharBoundaries(pos);
        var vsp:int = textDisplayGroup.verticalScrollPosition;
        var paddingTop:Number = getStyle("paddingTop");
        var paddingBottom:Number = getStyle("paddingBottom");
        
        if (bounds && (bounds.top < vsp - paddingTop || 
             bounds.bottom > vsp + unscaledHeight - paddingTop - paddingBottom))
        {
            textDisplayGroup.verticalScrollPosition = bounds.top + paddingTop;
            snapTextScrollPosition();
        }
    }
    
    /**
     *  @private
     *  Handle size and caret position changes that occur when text content
     *  changes.
     */
    private function textDisplay_changeHandler(event:Event):void
    {
        var tH:Number = textDisplay.textHeight;
        var tW:Number = textDisplay.textWidth;
        var explicitLineBreak:Boolean = getStyle("lineBreak") == "explicit";
        
        // Size and caret position have changed if the text height is different or
        // the text width is different and we aren't word wrapping
        if (tH != lastTextHeight || ( explicitLineBreak && tW != lastTextWidth))
        {
            invalidateSize();
            invalidateDisplayList();
            invalidateCaretPosition = true;   
        }
        
        lastTextHeight = tH;
        lastTextWidth = tW;
    }
    
    /**
     *  @private
     *  Cancels any native scroll that the Flash Player attempts to do
     */
    private function textDisplay_scrollHandler(event:Event):void
    {
        // if iOS, let the OS handle scrolling
        if (_isIOS)
            return;
        
        // If not IOS, we will handle scrolling, so don't let the native
        // flash textfield scroll at all.
        if (textDisplay.scrollV > 1)
            textDisplay.scrollV = 1;
        if (textDisplay.scrollH > 0)
            textDisplay.scrollH = 0;
    }
    
    /**
     *  @private
     *  Adjust viewport when using key navigation
     */
    private function textDisplay_keyHandler(event:KeyboardEvent):void
    {
        // update scroll position when caret changes
        if ((event.keyCode == Keyboard.UP
                || event.keyCode == Keyboard.DOWN
                || event.keyCode == Keyboard.LEFT
                || event.keyCode == Keyboard.RIGHT))
        {
            invalidateDisplayList();
            invalidateCaretPosition = true;
        }
        
        // Change event is not always sent when delete key is pressed, so
        // invalidate the size here
        if (event.keyCode == Keyboard.BACKSPACE)
        {
            invalidateSize();
        }
    }
    
    /**
     *  @private
     *  Send a caret change event to an ancestor Scroller
     */
    private function textDisplay_softKeyboardActivateHandler(event:SoftKeyboardEvent):void
    {
        var keyboardRect:Rectangle = stage.softKeyboardRect;
        
        if (keyboardRect.width > 0 && keyboardRect.height > 0)
        {
            var newCaretBounds:Rectangle = getCaretBounds();
            convertBoundsToLocal(newCaretBounds);
            
            if (oldCaretBounds != newCaretBounds)
            {
                dispatchEvent(new CaretBoundsChangeEvent(CaretBoundsChangeEvent.CARET_BOUNDS_CHANGE,true,true,oldCaretBounds,newCaretBounds));
                oldCaretBounds = newCaretBounds;
            }
        }
    }
    
    /**
     *  @private
     */
    private function resizeHandler(event:Event):void
    {
        // Resizing needs to tickle the TextArea's internal auto-scroll logic
        invalidateCaretPosition = true;
        invalidateDisplayList();
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
        
        // Check for padding style changes
        if (!styleProp || styleProp == "styleName" || styleProp.indexOf("padding") >= 0)
        {
            if (textDisplay)
            {
                textDisplay.left = getStyle("paddingLeft");
                textDisplay.top = getStyle("paddingTop");
                textDisplay.right = getStyle("paddingRight");
                textDisplay.bottom = getStyle("paddingBottom");
            }
        }
    }
}
}