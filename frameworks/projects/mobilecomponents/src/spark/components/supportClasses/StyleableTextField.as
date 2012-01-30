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

package spark.components.supportClasses
{
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.TextEvent;
import flash.geom.Rectangle;
import flash.text.Font;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.ui.Keyboard;

import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.resources.ResourceManager;
import mx.styles.IStyleClient;

import spark.core.IEditableText;
import spark.events.TextOperationEvent;

use namespace mx_internal;

[ResourceBundle("core")]

//
// To use:
//   in createChildren():
//       var tf:MobileTextField = createInFontContext(MobileTextField);
//       tf.styleProvider = this;
//       tf.editable = true|false;   // for editable text
//       tf.multiline = true|false;  // for multiline text
//       tf.wordWrap = true|false;   // for word wrapping
//       addChild(tf);
//
//   in commitProperties():
//       tf.text = "...." - if needed
// 
//   in measure();
//       Use UIComponent.measureText()
//
//   in updateDisplayList():
//       tf.commitStyles();    // Always call this. No-op if styles already applied.
//       tf.x = ...
//       tf.y = ...
//       tf.width = ...
//       tf.height = ...
//       // if you want truncated text:
//       tf.truncateToFit();
//
//   in styleChanged():
//       tf.styleChanged(styleProp);
//
// Supported styles: textAlign, fontFamily, fontWeight, "colorName", fontSize, fontStyle, 
//                   textDecoration, textIndent, leading, letterSpacing
 
/**
 *  The MobileTextField class is a text primitive for use in ActionScript
 *  skins and item renderers. It cannot be used in MXML markup.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
public class MobileTextField extends TextField implements IEditableText
{        
    
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Most resources are fetched on the fly from the ResourceManager,
     *  so they automatically get the right resource when the locale changes.
     *  But since truncateToFit() can be called frequently,
     *  this class caches this resource value in this variable.
     *  Note that this class does _not_ support runtime local changes to
     *  the truncation indicator. The dynamic local change code in UITextField 
     *  can be used here, if needed.
     */ 
    private static var truncationIndicatorResource:String;
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    public function MobileTextField()
    {
        super();
        
        // RichEditableText is double-clickable by default, so we will be too.
        doubleClickEnabled = true;
        
        // Add a high priority change handler so we can capture the event
        // and re-dispatch as a TextOperationEvent
        addEventListener(Event.CHANGE, changeHandler, false, 100);
        
        // Add a textInput handler so we can capture and re-dispatch as
        // a TextOperationEvent "changing" event.
        addEventListener(TextEvent.TEXT_INPUT, textInputHandler);
        
        // Add a key down listener to listen for enter key
        addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
        
        if (!truncationIndicatorResource)
        {
            truncationIndicatorResource = ResourceManager.getInstance().
                getString("core", "truncationIndicator");
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  IDisplayText implementation
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  text
    //----------------------------------
    
    /**
     *  The text displayed by this text component.
     *
     *  <p>The formatting of this text is controlled by CSS styles.
     *  The supported styles depend on the subclass.</p>
     *
     *  @default ""
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    override public function get text():String
    {
        return super.text;
    }
    
    override public function set text(value:String):void
    {
        // TextField's text property can't be set to null.
        if (!value)
            value = "";

        super.text = value;
        _isTruncated = false;
        dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
    }
            
    //----------------------------------
    //  isTruncated
    //----------------------------------
    
    /**
     *  A flag that indicates whether the text has been truncated.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get isTruncated():Boolean
    {
        return _isTruncated;
    }
    
    //--------------------------------------------------------------------------
    //
    //  IEditableText implementation
    //
    //--------------------------------------------------------------------------        
    
    //----------------------------------
    //  editable
    //----------------------------------
    
    /**
     *  Flag that indicates whether the text is editable.
     * 
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get editable():Boolean
    {
        return type == TextFieldType.INPUT;
    }
    
    public function set editable(value:Boolean):void
    {
        type = value ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
    }
    
    //----------------------------------
    //  focusEnabled
    //----------------------------------
    
    private var _focusEnabled:Boolean = true;
    
    /**
     *  @copy mx.core.UIComponent#focusEnabled
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get focusEnabled():Boolean
    {
        return _focusEnabled;
    }
    
    public function set focusEnabled(value:Boolean):void
    {
        _focusEnabled = value;
    }
    
    //----------------------------------
    //  enabled
    //----------------------------------
    
    private var _enabled:Boolean = true;
    
    /**
     *  @copy mx.core.UIComponent#enabled
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get enabled():Boolean
    {
        return _enabled;
    }
    
    public function set enabled(value:Boolean):void
    {
        _enabled = mouseEnabled = value;
    }
    
    //----------------------------------
    //  horizontalScrollPostion
    //----------------------------------
    
    /**
     *  The horizontal scroll position of the text.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get horizontalScrollPosition():Number
    {
        return scrollH;
    }
    
    public function set horizontalScrollPosition(value:Number):void
    {
        scrollH = Math.min(Math.max(0, int(value)), maxScrollH);
    }
    
    //----------------------------------
    //  lineBreak
    //----------------------------------
    
    /**
     *  Controls word wrapping within the text. This property corresponds
     *  to the lineBreak style.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get lineBreak():String
    {
        return wordWrap ? "toFit" : "explicit";
    }
    
    public function set lineBreak(value:String):void
    {
        wordWrap = !(value == "explicit");
    }
    
    //----------------------------------
    //  selectionActivePosition
    //----------------------------------
    
    /**
     *  The active, or last clicked position, of the selection.
     *  If the implementation does not support selection anchor
     *  this is the last character of the selection.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get selectionActivePosition():int
    {
        // TextField doesn't have selection "active" position
        return selectionEndIndex;
    }
    
    //----------------------------------
    //  selectionAnchorPosition
    //----------------------------------
    
    /**
     *  The anchor, or first clicked position, of the selection.
     *  If the implementation does not support selection anchor
     *  this is the first character of the selection.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get selectionAnchorPosition():int
    {
        // TextField doesn't have selection "anchor" position
        return selectionBeginIndex;
    }
    
    //----------------------------------
    //  verticalScrollPosition
    //----------------------------------
    
    /**
     *  The vertical scroll position of the text.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get verticalScrollPosition():Number
    {
        return scrollV;
    }
    
    public function set verticalScrollPosition(value:Number):void
    {
        scrollV = Math.min(Math.max(0, int(value)), maxScrollV);
    }    
    
    //--------------------------------------------------------------------------
    //
    //  IEditableText Methods
    //
    //--------------------------------------------------------------------------        

    /**
     *  Scroll so the specified range is in view.
     *  
     *  @param anchorPosition The anchor position of the selection range.
     *  @param activePosition The active position of the selection range.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function scrollToRange(anchorPosition:int, activePosition:int):void
    {
        // If either part of the selection is in range (determined by 
        // a non-null return value from getCharBoundaries()), we
        // don't need to do anything.
        if (getCharBoundaries(anchorPosition) || getCharBoundaries(activePosition))
            return;
        
        // Scroll so the anchor position is visible on the top line.
        verticalScrollPosition = getLineIndexOfChar(anchorPosition);
    }
    
    /**
     *  Inserts the specified text into the text component
     *  as if you had typed it.
     *
     *  <p>If a range was selected, the new text replaces the selected text.
     *  If there was an insertion point, the new text is inserted there.</p>
     *
     *  <p>An insertion point is then set after the new text.
     *  If necessary, the text will scroll to ensure
     *  that the insertion point is visible.</p>
     *
     *  @param text The text to be inserted.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function insertText(text:String):void
    {
        replaceText(selectionAnchorPosition, selectionActivePosition, text);
		dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
    }
	
	/**
	 *  Appends the specified text to the end of the text component,
	 *  as if you had clicked at the end and typed.
	 *
	 *  <p>An insertion point is then set after the new text.
	 *  If necessary, the text will scroll to ensure
	 *  that the insertion point is visible.</p>
	 *
	 *  @param text The text to be appended.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10.1
	 *  @playerversion AIR 2.0
	 *  @productversion Flex 4.5
	 */
	override public function appendText(text:String):void
	{
		super.appendText(text);
		dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
	}
    
    /**
     *  Selects a specified range of characters.
     *
     *  <p>If either position is negative, it will deselect the text range.</p>
     *
     *  @param anchorPosition The character position specifying the end
     *  of the selection that stays fixed when the selection is extended.
     *
     *  @param activePosition The character position specifying the end
     *  of the selection that moves when the selection is extended.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */ 
    public function selectRange(anchorIndex:int, activeIndex:int):void
    {
        setSelection(Math.min(anchorIndex, activeIndex),
                     Math.max(anchorIndex, activeIndex));
    }
    
    /**
     *  Selects all of the text.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */         
    public function selectAll():void
    {
        setSelection(0, length);
    }
     
    /**
     *  Set focus to this text field.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */         
    public function setFocus():void
    {
        stage.focus = this;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  styleProvider
    //----------------------------------
    
   /**
     *  The object that provides styles for this text component. This
     *  property must be set for the text to pick up the correct styles.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public var styleProvider:IStyleClient;
    
    /**
     *  @private
     *  An mx_internal hook developers can set to control where the styles 
     *  come from for the MobileTextField.  By default, MobileTextField
     *  uses a function that just grabs the styles from styleProvider.
     * 
     *  <p>This takes precedence over styleProvider and should never 
     *  be set to null.</p>
     */
    mx_internal var getStyleFunction:Function = defaultGetStyleFunction;
    
    /**
     *  @private
     *  The object that provides styles for this text component. This
     *  property must be set for the text to pick up the correct styles.
     */
    private function defaultGetStyleFunction(styleProp:String):*
    {
        return styleProvider.getStyle(styleProp);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Commit the styles into the TextField. This method must be called
     *  before the text is displayed, and any time the styles have changed.
     *  This method does nothing if the styles have already been committed.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function commitStyles():void
    {
        if ((getStyleFunction != defaultGetStyleFunction || styleProvider) && invalidateStyleFlag)
        {
            var align:String = getStyleFunction("textAlign");
            if (align == "start")
                align = TextFormatAlign.LEFT;
            if (align == "end")
                align = TextFormatAlign.RIGHT;
            textFormat.align = align;
            textFormat.font = getStyleFunction("fontFamily");
            textFormat.bold = getStyleFunction("fontWeight") == "bold";
            textFormat.color = getStyleFunction(colorName);
            textFormat.size = getStyleFunction("fontSize");
            textFormat.italic = getStyleFunction("fontStyle") == "italic";
            textFormat.underline = getStyleFunction("textDecoration") == "underline";
            textFormat.indent = getStyleFunction("textIndent");
            textFormat.leading = getStyleFunction("leading");
            textFormat.letterSpacing = getStyleFunction("letterSpacing");
            
            // ignore padding in the text...most components deal with it themselves
            //textFormat.leftMargin = getStyleFunction("paddingLeft");
            //textFormat.rightMargin = getStyleFunction("paddingRight");

            // Check for embedded fonts
            embedFonts = isFontEmbedded(textFormat);
            
            defaultTextFormat = textFormat;
            setTextFormat(textFormat);
            invalidateStyleFlag = false;
        }
    }
    
    /**
     *  Notify the text field that a style is changed. This method is typically
     *  called by the styleChanged() method of the style provider.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function styleChanged(styleProp:String):void
    {
        if (styleProp == null || styleProp == "styleName"
            || supportedStyles.indexOf(styleProp) >= 0
            || styleProp == colorName)
        {
            invalidateStyleFlag = true;
        }
    }
    
    /**
     *  Truncate text to make it fit horizontally in the area defined for the control, 
     *  and append an ellipsis, three periods (...), to the text.
     *
     *  @param truncationIndicator The text to be appended after truncation.
     *  If you pass <code>null</code>, a localizable string
     *  such as <code>"..."</code> will be used.
     *
     *  @return <code>true</code> if the text needed truncation.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function truncateToFit(truncationIndicator:String = "..."):Boolean
    {
        if (!truncationIndicator)
            truncationIndicator = truncationIndicatorResource;
        
        var originalText:String = super.text;
        var oldIsTruncated:Boolean = _isTruncated;
        var w:Number = width;
        
        _isTruncated = false;
        
        // Need to check if we should truncate, but it 
        // could be due to rounding error.  Let's check that it's not.
        // Examples of rounding errors happen with "South Africa" and "Game"
        // with verdana.ttf.
        if (originalText != "" && textWidth + TEXT_WIDTH_PADDING > w + 0.00000000000001)
        {
            // This should get us into the ballpark.
            var s:String = super.text = originalText;
            originalText.slice(0,
                Math.floor((w / (textWidth + TEXT_WIDTH_PADDING)) * originalText.length));
            
            while (s.length > 1 && textWidth + TEXT_WIDTH_PADDING > w)
            {
                s = s.slice(0, -1);
                super.text = s + truncationIndicator;
            }
            
            _isTruncated = true;
        }
        
        // Dispatch "isTruncatedChange"
        if (_isTruncated != oldIsTruncated)
            dispatchEvent(new Event("isTruncatedChanged"));
        
        return _isTruncated;
    }
    
    /**
     *  @private
     */
    private function isFontEmbedded(format:TextFormat):Boolean
    {
        if (!embeddedFonts)
            embeddedFonts = Font.enumerateFonts();
        
        for (var i:int = 0; i < embeddedFonts.length; i++)
        {
            var font:Font = Font(embeddedFonts[i]);
            if (font.fontName == format.font)
            {
                var style:String = "regular";
                if (format.bold && format.italic)
                    style = "boldItalic";
                else if (format.bold)
                    style = "bold";
                else if (format.italic)
                    style = "italic";
                
                if (font.fontStyle == style)
                    return true;
            }
        }
        
        return false;
    }
    
    /**
     *  @private
     */
    private function changeHandler(event:Event):void
    {
        if (!(event is TextOperationEvent))
        {
            var newEvent:TextOperationEvent = new TextOperationEvent(event.type);
            
            // stop immediate propagation of the old event
            event.stopImmediatePropagation();
            
            // dispatch the new event
            dispatchEvent(newEvent);
        }
    }
    
    /**
     *  @private
     */
    private function keyDownHandler(event:KeyboardEvent):void
    {
        if (event.isDefaultPrevented())
            return;
        
        // Dispatch an "enter" event
        if (event.keyCode == Keyboard.ENTER)
        {
            dispatchEvent(new FlexEvent(FlexEvent.ENTER));
        }
    }
    
    /**
     *  @private
     */
    private function textInputHandler(event:TextEvent):void
    {
        // Dispatch a "changing" event
        var e:TextOperationEvent = new TextOperationEvent(TextOperationEvent.CHANGING);
        var operation:TextInputOperation = new TextInputOperation();
        operation.text = event.text;
        e.operation = operation;
        
        if (!dispatchEvent(e))
            event.preventDefault();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------   
    
    // Name of the style to use for determining the text color
    mx_internal var colorName:String = "color";
        
    private static var supportedStyles:String = "textAlign fontFamily fontWeight fontStyle color fontSize textDecoration textIndent leading letterSpacing"
    private var invalidateStyleFlag:Boolean = true;
    private static var textFormat:TextFormat = new TextFormat();
    private var _isTruncated:Boolean = false;
    private static var embeddedFonts:Array;
    
    /**
     *  @private
     *  The padding to be added to textWidth to get the width
     *  of a TextField that can display the text without clipping.
     */ 
    private static const TEXT_WIDTH_PADDING:int = 5;
    
    /**
     *  @private
     *  The padding to be added to textHeight to get the height
     *  of a TextField that can display the text without clipping.
     */ 
    private static const TEXT_HEIGHT_PADDING:int = 4;
}
}