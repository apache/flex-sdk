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
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.styles.IStyleClient;

import spark.core.IEditableText;
import spark.events.TextOperationEvent;

use namespace mx_internal;

// TODO:
//  - load truncation indicator from resource
//  - verify focusEnabled functionality
//  - implement heightInLines/widthInChars (or remove)
//  - implement scrollToRange()
//  - dispatch isTruncatedChanged
//
//
// To use:
//   in createChildren():
//       var tf:MobileTextField = new MobileTextField();
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
// Supported styles: textAlign, fontFamily, fontWeight, "colorName", fontSize, fontStyle, textDecoration, textIndent, leading, letterSpacing, paddingLeft, paddingRight
 
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
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    public function MobileTextField()
    {
        super();
        // Add a high priority change handler so we can capture the event
        // and re-dispatch as a TextOperationEvent
        addEventListener(Event.CHANGE, changeHandler, false, 100);
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
        // TODO: range check?
        scrollH = int(value);
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
    
 
    ///////
    /// TODO: Figure out if we can implement these properties. If not, they should
    //  be removed from this class and IEditableText.
    ///////
    
    public function get heightInLines():Number
    {
        // TODO: implement me (or remove)
        return 1; 
    }
    
    public function set heightInLines(value:Number):void
    {
        // TODO: implement me (or remove)
    }
    
    public function get widthInChars():Number
    {
        // TODO: implement me (or remove)
        return 1;
    }
    
    public function set widthInChars(value:Number):void
    {
        // TODO: implement me (or remove)
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
        // TODO: implement me
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
        replaceSelectedText(text);
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
        // TODO: normalize?
        setSelection(anchorIndex, activeIndex);
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
    
    // TODO: consider adding lineBreak property instead of using a style.
    public function setStyle(styleProp:String, value:*):void // Only used for setStyle("lineBreak", "explicit")
    {
        if (styleProp == "lineBreak")
            wordWrap = !(value == "explicit");
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
        if (styleProvider && invalidateStyleFlag)
        {
            var align:String = styleProvider.getStyle("textAlign");
            if (align == "start")
                align = TextFormatAlign.LEFT;
            if (align == "end")
                align = TextFormatAlign.RIGHT;
            textFormat.align = align;
            textFormat.font = styleProvider.getStyle("fontFamily");
            textFormat.bold = styleProvider.getStyle("fontWeight") == "bold";
            textFormat.color = styleProvider.getStyle(colorName);
            textFormat.size = styleProvider.getStyle("fontSize");
            textFormat.italic = styleProvider.getStyle("fontStyle") == "italic";
            textFormat.underline = styleProvider.getStyle("textDecoration") == "underline";
            textFormat.indent = styleProvider.getStyle("textIndent");
            textFormat.leading = styleProvider.getStyle("leading");
            textFormat.letterSpacing = styleProvider.getStyle("letterSpacing");
            
            // ignore padding in the text...most components deal with it themselves
            //textFormat.leftMargin = styleProvider.getStyle("paddingLeft");
            //textFormat.rightMargin = styleProvider.getStyle("paddingRight");

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
    //    if (!truncationIndicator)
    //          truncationIndicator = truncationIndicatorResource;
        
        // Ensure that the proper CSS styles get applied to the textField
        // before measuring text.
        // Otherwise the callLater(validateNow) in styleChanged()
        // can apply the CSS styles too late.
    //     commitStyles();
        
        var originalText:String = super.text;
        
        untruncatedText = originalText;
        
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
            return true;
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
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------   
    
    // Name of the style to use for determining the text color
    mx_internal var colorName:String = "color";
    
    
    private static var supportedStyles:String = "textAlign fontFamily fontWeight color fontSize textDecoration textIndent leading letterSpacing paddingLeft paddingRight"
    private var invalidateStyleFlag:Boolean = true;
    private static var textFormat:TextFormat = new TextFormat();
    private var untruncatedText:String;  // TODO: Use it or loose it
    private var _isTruncated:Boolean = false;
    
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