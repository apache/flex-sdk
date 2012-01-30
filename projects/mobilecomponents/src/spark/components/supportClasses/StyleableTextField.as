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

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.SoftKeyboardEvent;
import flash.events.TextEvent;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Vector3D;
import flash.text.Font;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.text.TextInteractionMode;
import flash.text.TextLineMetrics;
import flash.ui.Keyboard;
import flash.utils.Dictionary;

import mx.core.DesignLayer;
import mx.core.IVisualElement;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.TouchInteractionEvent;
import mx.events.TouchInteractionReason;
import mx.geom.TransformOffsets;
import mx.resources.ResourceManager;
import mx.styles.CSSStyleDeclaration;
import mx.styles.ISimpleStyleClient;
import mx.styles.IStyleClient;

import spark.components.Scroller;
import spark.core.IEditableText;
import spark.events.TextOperationEvent;

use namespace mx_internal;

[ResourceBundle("core")]

//
// To use:
//   in createChildren():
//       var tf:StyleableTextField = createInFontContext(StyleableTextField);
//       tf.styleName = this;
//       tf.editable = true|false;   // for editable text
//       tf.multiline = true|false;  // for multiline text
//       tf.wordWrap = true|false;   // for word wrapping
//       addChild(tf);
//
//   in commitProperties():
//       tf.text = "...." - if needed
// 
//   in measure();
//       if (tf.isTruncated)     // if text may be truncated
//           tf.text = "...";
//       tf.commitStyles();    // Always call this. No-op if styles already applied.
//       Use tf.textWidth, tf.textHeight;
//
//   in updateDisplayList():
//       if (tf.isTruncated)    // if text may be truncated
//           tf.text = "...";
//       tf.commitStyles();    // Always call this. No-op if styles already applied.
//       tf.x = ...
//       tf.y = ...
//       tf.width = ...
//       tf.height = ...
//       // if you want truncated text:
//       tf.truncateToFit();
//
// Supported styles: textAlign, fontFamily, fontWeight, "colorName", fontSize, fontStyle, 
//                   textDecoration, textIndent, leading, letterSpacing

/**
 *  The StyleableTextField class is a text primitive for use in ActionScript
 *  skins and item renderers. It cannot be used in MXML markup and is not
 *  compatible with effects.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
public class StyleableTextField extends TextField 
    implements IEditableText, ISimpleStyleClient, IVisualElement
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
    
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function StyleableTextField()
    {
        super();
        
        // RichEditableText is double-clickable by default, so we will be too.
        doubleClickEnabled = true;
        
        // make our width 400 by default.  this is just a heuristic, but it helps
        // get the right measurement the first time for a multi-line TextField.
        // The developer should still be setting the textField's width to 
        // the estimatedWidth to get a more accurate representation, but 
        // sometimes there is no estimated width, and this will be a good
        // heuristic in cases where they forget to do that.
        width = 400;
        
        // Add a high priority change handler so we can capture the event
        // and re-dispatch as a TextOperationEvent
        addEventListener(Event.CHANGE, changeHandler, false, 100);
        
        // Add a textInput handler so we can capture and re-dispatch as
        // a TextOperationEvent "changing" event.
        addEventListener(TextEvent.TEXT_INPUT, textInputHandler);
        
        // Add a key down listener to listen for enter key
        addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);

		addEventListener(TouchInteractionEvent.TOUCH_INTERACTION_STARTING, 
			touchInteractionStartingHandler);
		addEventListener(TouchInteractionEvent.TOUCH_INTERACTION_START, 
			touchInteractionStartHandler);
		addEventListener(TouchInteractionEvent.TOUCH_INTERACTION_END, 
			touchInteractionEndHandler);

        if (!truncationIndicatorResource)
        {
            truncationIndicatorResource = ResourceManager.getInstance().
                getString("core", "truncationIndicator");
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
	override public function set width(value:Number): void
	{
		super.width = value;
		
		// If we're multiline we need to invalidate our size since our height
		// may have changed
		if (multiline) 
		{
			invalidateTightTextHeight = true;
			invalidateTextSizeFlag = true;	
		}
	}

    public function get measuredTextSize():Point
    {
        // commit style to get an accurate measurement
        commitStyles();
        
        if (!_measuredTextSize)
        {
            _measuredTextSize = new Point();
            invalidateTextSizeFlag = true;
			invalidateTightTextHeight = true;
        }
        
        if (invalidateTextSizeFlag)
        {
            // size always includes textIndent and TextField gutters
            var textIndent:Number = getStyle("textIndent");
            const m:Matrix = transform.concatenatedMatrix;
            
            // short circuit scaling workaround if off stage, using embedded fonts, or no scaling
            if (!stage || embedFonts || (m.a == 1 && m.d == 1))
            {
                _measuredTextSize.x = textWidth + textIndent + TEXT_WIDTH_PADDING
                _measuredTextSize.y = textHeight + TEXT_HEIGHT_PADDING;
            }
			else
			{
	            // when scaling, remove/add to stage for consistent measurement
	            var originalParent:DisplayObjectContainer = parent;
	            var index:int = parent.getChildIndex(this);
	            
	            // remove from display list
	            if (originalParent is UIComponent)
	                UIComponent(originalParent).$removeChild(this);
	            else
	                originalParent.removeChild(this);
	            
	            _measuredTextSize.x = textWidth + textIndent + TEXT_WIDTH_PADDING
	            _measuredTextSize.y = textHeight + TEXT_HEIGHT_PADDING;
	            
	            // add to display list
	            if (originalParent is UIComponent)
	                UIComponent(originalParent).$addChildAt(this, index);
	            else
	                originalParent.addChildAt(this, index);
	            
	            // If we use device fonts, then the unscaled sizes are
	            // textWidth * scaleX / scaleY
	            // textHeight * scaleX / scaleY 
	            if (m.a != m.d)
	            {
	                var scaleFactor:Number = (m.a / m.d);
	                
	                // textIndent and gutter are also scaled
	                _measuredTextSize.x = Math.abs(_measuredTextSize.x * scaleFactor);
	                _measuredTextSize.y = Math.abs(_measuredTextSize.y * scaleFactor);
	            }
			}
			
			invalidateTextSizeFlag = false;
        }
        
        return _measuredTextSize;
    }
    
    //----------------------------------
    //  styleDeclaration
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the styleDeclaration property.
     */
    private var _styleDeclaration:CSSStyleDeclaration;
    
    [Inspectable(environment="none")]
    
    /**
     *  Storage for the inline inheriting styles on this object.
     *  This CSSStyleDeclaration is created the first time that
     *  the <code>setStyle()</code> method
     *  is called on this component to set an inheriting style.
     *  Developers typically never need to access this property directly.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get styleDeclaration():CSSStyleDeclaration
    {
        return _styleDeclaration;
    }
    
    /**
     *  @private
     */
    public function set styleDeclaration(value:CSSStyleDeclaration):void
    {
        _styleDeclaration = value;
    }
    
    //----------------------------------
    //  styleName
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the styleName property.
     */
    private var _styleName:Object /* UIComponent */;
    
    /**
     *  The class style used by this component. This should be an IStyleClient.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get styleName():Object /* UIComponent */
    {
        if (_styleName)
            return _styleName;
        
        if (parent is IStyleClient)
            return parent;
        
        return null;
    }
    
    /**
     *  @private
     */
    public function set styleName(value:Object /* UIComponent */):void
    {
        if (_styleName === value)
            return;
        
        _styleName = value;
        
        styleChanged("styleName");
    }
    
	//----------------------------------
	//  Text alignment helpers
	//----------------------------------	
	/**
	 *  @private
	 *  The height of the first line of text to the baseline of the bottom line
	 *  of text.  Handles both single line and multiline text. 
	 */
	private function get tightTextHeight() :Number
	{
		commitStyles();
		
		// figure out distance from text bottom to last baseline
		if (invalidateTightTextHeight)
		{
			// getLineMetrics() returns strange numbers for an empty string,
			// so instead we get the metrics for a non-empty string.
			var isEmpty:Boolean = (text == "");
			
			if (isEmpty)
				text = "Wj";
			
			var metrics:TextLineMetrics = getLineMetrics(0);
			
			// bottom gutter and descent
			var bottomOffset:Number = StyleableTextField.TEXT_HEIGHT_PADDING/2 + metrics.descent;	
			if (numLines == 1) // account for the extra leading on single line text
				bottomOffset += metrics.leading;
			
			var topOffset:Number = getTextTopOffset(defaultTextFormat);
			_tightTextHeight = measuredTextSize.y - topOffset - bottomOffset;
			
			if (isEmpty)
				text = "";
			
			invalidateTightTextHeight = false;	
		}
		
		return _tightTextHeight;
	}
	
	/**
	 *  @private
	 *  Finds the distance from the top edge of the containing text field to the text for 
	 *  a particular font, size, weight and style combination.  This value accounts for
	 *  the difference between the metrics.ascent and the true top of the text within the 
	 *  text field and the top gutter
	 */
	private static function getTextTopOffset(textFormat:TextFormat):Number
	{
		// try to find the top offset for the font, size, weight and style in our table
		// we only store offets for unique font, size, weight and style combinations
		// FIXME (mcho)  are there more properties that affect the top offset we should 
		// take into account?
		var key:String = textFormat.font + "_" + textFormat.size + "_" + textFormat.bold + "_" + textFormat.italic;
		var topOffset:Number = textTopOffsetTable[key];
		
		// if we can't find the value in our table let's calculate it
		if (isNaN(topOffset))
		{
			// create sample text field
			var field:TextField = new TextField();
			field.defaultTextFormat = textFormat;
			field.embedFonts = isFontEmbedded(textFormat);
			field.textColor = 0x000000; // make sure our text is black so it will show up against white
			field.text = "T"; // use "T" as our standard
			field.width = field.textWidth;
			field.height = field.textHeight;
			
			// draw the field into a bitmap data - note default bg color of bitmapData is white.
			var bitmapData:BitmapData = new BitmapData(field.width, field.height);
			bitmapData.draw(field);
			
			// search vertically for the first non white pixel
			var col:int = Math.round(bitmapData.width/2);
			for (var i:int = 0; i < bitmapData.height; i++)
			{
				if (bitmapData.getPixel(col, i) != 0xFFFFFF)
					break;
			}
			
			if (i == bitmapData.height) 
				topOffset = StyleableTextField.TEXT_HEIGHT_PADDING/2; // if we didn't find a non white pixel set top offset to top gutter
			else
				topOffset = i;
			
			// store the offset value in our look up table
			textTopOffsetTable[key] = topOffset; 
		}

		return topOffset;
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
        invalidateTextSizeFlag = true;
		invalidateTightTextHeight = true;
        
        if (hasEventListener(FlexEvent.VALUE_COMMIT))
            dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
    }
    
    //----------------------------------
    //  $text
    //----------------------------------
    
    /**
     *  @private
     *  This property allows access to the Player's native implementation
     *  of the 'text' property, which can be useful since components
     *  can override 'text' and thereby hide the native implementation.
     *  Note that this "base property" is final and cannot be overridden,
     *  so you can count on it to reflect what is happening at the player level.
     */
    mx_internal final function get $text():String
    {
        return super.text;
    }
    
    mx_internal final function set $text(value:String):void
    {
        super.text = value;
    }
    
    //----------------------------------
    //  isTruncated
    //----------------------------------
    
    /**
     *  Indicates whether the text has been truncated, <code>true</code>, 
     *  or not, <code>false</code>.
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
     *  Specifies whether the text is editable, <code>true</code>, 
     *  or not, <code>false</code>.
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
        dispatchEvent(new Event("editableChanged"));
    }
    
    //----------------------------------
    //  focusEnabled
    //----------------------------------
    
    private var _focusEnabled:Boolean = true;
    
    /**
     *  Indicates whether the component can receive focus when tabbed to. 
     *  You can set <code>focusEnabled</code> to <code>false</code> when a 
     *  component is used as a subcomponent of another component so that 
     *  the outer component becomes the focusable entity. 
     *  If this property is <code>false</code>, focus is transferred to 
     *  the first parent that has <code>focusEnable</code> set to <code>true</code>. 
     *
     *  @default true
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
     *  Whether the component can accept user interaction. 
     *  After setting the <code>enabled</code> property to <code>false</code>, 
     *  some components still respond to mouse interactions such as <code>mouseOver</code>. 
     *  As a result, to fully disable the component, you should also set the value 
     *  of the <code>mouseEnabled</code> property to <code>false</code>.  
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
     *  Controls word wrapping within the text. 
     *  This property corresponds to the <code>lineBreak</code> style.
     *
     *  <p>Text may be set to fit the width of the container (<code>LineBreak.TO_FIT</code>), 
     *  or can be set to break only at explicit return or line feed characters (<code>LineBreak.EXPLICIT</code>).</p>
     *
     *  <p>Legal values are <code>flashx.textLayout.formats.LineBreak.EXPLICIT</code>, 
     *  <code>flashx.textLayout.formats.LineBreak.TO_FIT</code>, and 
     *  <code>flashx.textLayout.formats.FormatValue.INHERIT</code>.</p>
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
        invalidateTextSizeFlag = true;
		invalidateTightTextHeight = true;
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
		
		// Make sure insertion point is at the end of the text
		var textLength:int = this.text.length;
		setSelection(textLength, textLength);
		
        dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
        invalidateTextSizeFlag = true;
		invalidateTightTextHeight = true;
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
        
        if (editable)
            requestSoftKeyboard();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
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
        if (invalidateStyleFlag)
        {
            var align:String = getStyle("textAlign");
            if (align == "start")
                align = TextFormatAlign.LEFT;
            if (align == "end")
                align = TextFormatAlign.RIGHT;
            textFormat.align = align;
            textFormat.font = getStyle("fontFamily");
            textFormat.bold = getStyle("fontWeight") == "bold";
            textFormat.color = getStyle(colorName);
            textFormat.size = getStyle("fontSize");
            textFormat.italic = getStyle("fontStyle") == "italic";
            textFormat.underline = getStyle("textDecoration") == "underline";
            textFormat.indent = getStyle("textIndent");
            textFormat.leading = getStyle("leading");
            textFormat.letterSpacing = getStyle("letterSpacing");
            var kerning:* = getStyle("kerning");
            if (kerning == "auto" || kerning == "on")
                kerning = true;
            else if (kerning == "default" || kerning == "off")
                kerning = false;
            textFormat.kerning = kerning;
            
            antiAliasType = getStyle("fontAntiAliasType");
            gridFitType = getStyle("fontGridFitType");
            sharpness = getStyle("fontSharpness");
            thickness = getStyle("fontThickness");
            
            // ignore padding in the text...most components deal with it themselves
            //textFormat.leftMargin = getStyle("paddingLeft");
            //textFormat.rightMargin = getStyle("paddingRight");
            
            // Check for embedded fonts
            embedFonts = isFontEmbedded(textFormat);
            
            defaultTextFormat = textFormat;
            setTextFormat(textFormat);
            
            // If our text is empty we need to force the style changes in order for
            // textHeight to be valid. Setting the width is sufficient, and should
            // have minimal overhead since we don't have any text.
            if (text == "")
            {
                // Set the width to the fontSize + padding, which is big enough to hold one
                // character. 
                width = textFormat.size + TEXT_WIDTH_PADDING;
            }
            
            invalidateStyleFlag = false;
            
            // now that we've pushed the new styles in, our size might have 
            // changed
            invalidateTextSizeFlag = true;
            invalidateBaselinePosition = true;
			invalidateTightTextHeight = true;
        }
    }
    
    /**
     *  @copy mx.core.UIComponent#getStyle()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function getStyle(styleProp:String):*
    {
        // check out inline style first
        if (_inlineStyleObject && _inlineStyleObject[styleProp] !== undefined)
            return _inlineStyleObject[styleProp];
        
        // check styles that are on us via styleDeclaration
        if (styleDeclaration && styleDeclaration.getStyle(styleProp) !== undefined)
            return styleDeclaration.getStyle(styleProp);
        
        // if not inlined, check our style provider
        if (styleName is IStyleClient)
            return IStyleClient(styleName).getStyle(styleProp);
        
        // if can't find it, return undefined
        return undefined;
    }
    
    /**
     *  @copy mx.core.UIComponent#setStyle()
     *
     *  @param styleProp Name of the style property.
     *
     *  @param newValue New value for the style.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function setStyle(styleProp:String, value:*):void
    {
        if (!_inlineStyleObject)
            _inlineStyleObject = {};
        
        _inlineStyleObject[styleProp] = value;
        
        styleChanged(styleProp);
    }
    
    /**
     *  @copy mx.core.UIComponent#styleChanged()
     *
     *  @param styleProp The style property that changed.
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
            
            // invalidateSizeFlag doesn't get set until commitStyles() when 
            // the new styles are actually pushed in and the textWidth/textHeight changes
        }
    }
    
    /**
     *  Truncate text to make it fit horizontally in the area defined for the control, 
     *  and append an ellipsis, three periods (...), to the text. This function
     *  only works for single line text.
     *
     *  @param truncationIndicator The text to be appended after truncation.
     *  If you pass <code>null</code>, a localizable string
     *  such as <code>"..."</code> will be used.
     *
     *  @return <code>true</code> if the text needed truncation.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
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
            // TODO (rfrishbe): why is this here below...it does nothing (see SDK-26438)
            //originalText.slice(0,
            //    Math.floor((w / (textWidth + TEXT_WIDTH_PADDING)) * originalText.length));
            
            while (s.length > 1 && textWidth + TEXT_WIDTH_PADDING > w)
            {
                s = s.slice(0, -1);
                super.text = s + truncationIndicator;
            }
            
            _isTruncated = true;
            invalidateTextSizeFlag = true;
            invalidateBaselinePosition = true;
			invalidateTightTextHeight = true;
            
            // Make sure all text is visible
            scrollH = 0;
        }
        
        // Dispatch "isTruncatedChange"
        if (_isTruncated != oldIsTruncated)
        {
            if (hasEventListener("isTruncatedChanged"))
                dispatchEvent(new Event("isTruncatedChanged"));
        }
        
        return _isTruncated;
    }
    
    /**
     *  @private
     */
    private static function isFontEmbedded(format:TextFormat):Boolean
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
            invalidateTextSizeFlag = true;
			invalidateTightTextHeight = true;
            
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
	
	/**
	 *  @private
	 */
	private function touchInteractionStartingHandler(event:TouchInteractionEvent):void
	{
		// When in text selection mode, tell the Scroller to use the special text
		// selection auto-scroll mode, and pass the top/bottom of this component as
		// the scroll range.
		if (textInteractionMode == TextInteractionMode.SELECTION)
		{
			var focusThickness:Number = getStyle("focusThickness");
			var scroller:Scroller = event.relatedObject as Scroller;
			
			// Early exit if the event isn't a SCROLL event or doesn't have a Scroller
			if (event.reason != TouchInteractionReason.SCROLL || !scroller)
				return;
            
            // if already in text selection mode with another scroller, cancel this scroller
            if (scrollerInTextSelectionMode)
            {
                event.preventDefault();
                return;
            }
			
			var minVScrollPos:Number;
			var maxVScrollPos:Number;
			var minHScrollPos:Number;
			var maxHScrollPos:Number;
			
			var pt:Point = new Point(0, 0);
			
			// Offset by our position within the skin/component. The scrolling is 
			// constrained by the component boundaries, not by the boundaries of
			// this text field. We don't have a reliable way to determine the 
			// component boundaries, so we use our x,y position as an estimate.
			pt.offset(-x, -y);
			
			// Include the focus thickness in the min/max scroll positions
			pt.offset(-focusThickness, -focusThickness);
			
			pt = localToGlobal(pt);
			pt = DisplayObject(scroller.viewport).globalToLocal(pt);
			minHScrollPos = Math.max(0, pt.x);
			minVScrollPos = Math.max(0, pt.y);
			
			pt.x = width;
			pt.y = height;
			
			// We can't reliably find our position relative to the bottom of the skin/
			// component, so use our top position as an estimate
			pt.offset(x, y);
			
			// Include focus thickness
			pt.offset(focusThickness, focusThickness);
			
			pt = parent.localToGlobal(pt);
			pt = DisplayObject(scroller.viewport).globalToLocal(pt);
			maxHScrollPos = pt.x - scroller.width;
			maxVScrollPos = pt.y - scroller.height;
			
            scrollerInTextSelectionMode = scroller;
			scroller.enableTextSelectionAutoScroll(true, minHScrollPos, maxHScrollPos,
				minVScrollPos, maxVScrollPos);
		}
	}
	
	/**
	 *  @private
	 */
	private function touchInteractionStartHandler(event:TouchInteractionEvent):void
	{
		// During a touch scroll we don't want the keyboard to activate. Add a
		// "softKeyboardActivating" handler to cancel the event.
		addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATING, 
			softKeyboardActivatingHandler);
	}
	
	/**
	 *  @private
	 */
	private function touchInteractionEndHandler(event:TouchInteractionEvent):void
	{
		// Remove the soft keyboard activate cancelling handler.
		removeEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATING, 
			softKeyboardActivatingHandler);
		
		if (textInteractionMode == TextInteractionMode.SELECTION)
		{
			var scroller:Scroller = event.relatedObject as Scroller;
			
			// Turn off text selection auto-scroll.
            scrollerInTextSelectionMode = null;
			if (scroller)
				scroller.enableTextSelectionAutoScroll(false);
		}
	}
	
	/**
	 *  @private
	 * 
	 *  This handler is only added during touch scroll events. It prevents
	 *  the onscreen keyboard from activating if a scroll occurred.
	 */
	private function softKeyboardActivatingHandler(event:SoftKeyboardEvent):void
	{
		event.preventDefault();
	}
    
    //--------------------------------------------------------------------------
    //
    //  IVisualElement implementation
    //
    //--------------------------------------------------------------------------
    
    /**
     * @private
     */
    public function getBoundsXAtSize(width:Number, height:Number, postLayoutTransform:Boolean=true):Number
    {
        return x;
    }
    
    /**
     * @private
     */
    public function getBoundsYAtSize(width:Number, height:Number, postLayoutTransform:Boolean=true):Number
    {
        return y;
    }
    
    /**
     * @private
     */
    public function getLayoutBoundsHeight(postLayoutTransform:Boolean=true):Number
    {
		if (useTightTextBounds) 
		{
			// we want to return the text field height without the top and bottom offsets
			// (measuredTextSize.y - tightTextHeight) gives us the sum of top and bottom offsets
			return height - (measuredTextSize.y - tightTextHeight);
		}
		else
		{
			return height;
		}
    }
    
    /**
     * @private
     */
    public function getLayoutBoundsWidth(postLayoutTransform:Boolean=true):Number
    {
		if (useTightTextBounds)
		{
			// return the text field width without the left and right gutters
			return width - StyleableTextField.TEXT_WIDTH_PADDING;
		}
		else
		{
			return width;
		}
    }
    
    /**
     * @private
     */
    public function getLayoutBoundsX(postLayoutTransform:Boolean=true):Number
    {
		if (useTightTextBounds)
		{
			// return the x position of the text within the text field.  we calculate this value
			// using text field's x, offset by the left gutter
			return x + StyleableTextField.TEXT_WIDTH_PADDING/2;
		}
		else
		{
			return x;
		}
    }
	
    
    /**
     * @private
     */
    public function getLayoutBoundsY(postLayoutTransform:Boolean=true):Number
    {
		if (useTightTextBounds)
		{
			// return the y position of the text within the text field.  we calculate this value
			// using text field's y, offset by the text top offset
			return y + getTextTopOffset(defaultTextFormat);
		}
		else
		{
			return y;
		}
    }
    
    /**
     * @private
     */
    public function getLayoutMatrix():Matrix
    {
        return transform.matrix;
    }
    
    /**
     * @private
     */
    public function getLayoutMatrix3D():Matrix3D
    {
        return transform.matrix3D;
    }
    
    /**
     * @private
     */
    public function getMaxBoundsHeight(postLayoutTransform:Boolean=true):Number
    {
        return UIComponent.DEFAULT_MAX_WIDTH;
    }
    
    /**
     * @private
     */
    public function getMaxBoundsWidth(postLayoutTransform:Boolean=true):Number
    {
        return UIComponent.DEFAULT_MAX_WIDTH;
    }
    
    /**
     * @private
     */
    public function getMinBoundsHeight(postLayoutTransform:Boolean=true):Number
    {
        return 0;
    }
    
    /**
     * @private
     */
    public function getMinBoundsWidth(postLayoutTransform:Boolean=true):Number
    {
        return 0;
    }
    
    /**
     * @private
     */
    public function getPreferredBoundsHeight(postLayoutTransform:Boolean=true):Number
    {
		if (useTightTextBounds)
		{
			// The height from the top of the text to the baseline of the
			// last line of text.  This is the height used for positioning text 
			// according to its baseline
			return tightTextHeight;			
		}
		else
		{
			return measuredTextSize.y;
		}
    }
    
    /**
     * @private
     */
    public function getPreferredBoundsWidth(postLayoutTransform:Boolean=true):Number
    {
		if (useTightTextBounds)
		{
			// The measuredTextSize without the left and right gutters
			return measuredTextSize.x - StyleableTextField.TEXT_WIDTH_PADDING;
		}
		else
		{
			return measuredTextSize.x;
		}
    }
    
    /**
     * @private
     */
    public function invalidateLayoutDirection():void
    {
        // do nothing
    }
    
    /**
     * @private
     */
    public function setEstimatedSize(estimatedWidth:Number=NaN, estimatedHeight:Number=NaN, invalidateSize:Boolean=true):void
    {
        // TODO (jasonsj)
    }
    
    /**
     * @private
     */
    public function setLayoutBoundsPosition(x:Number, y:Number, postLayoutTransform:Boolean=true):void
    {
		if (useTightTextBounds)
		{
			// offset the positions by the left gutters and the top offset
			this.x = x - StyleableTextField.TEXT_WIDTH_PADDING/2;
			this.y = y - getTextTopOffset(defaultTextFormat);	
		}
		else
		{
			this.x = x;
			this.y = y;
		}
    }
    
    /**
     * @private
     */
    public function setLayoutBoundsSize(width:Number, height:Number, postLayoutTransform:Boolean=true):void
    {	
		// width
		var newWidth:Number = width;
		if (isNaN(newWidth))
			newWidth = getPreferredBoundsWidth();
		
		// re-add the left and right gutters
		if (useTightTextBounds)
			newWidth += StyleableTextField.TEXT_WIDTH_PADDING;

		this.width = newWidth;
		
		// height
		var newHeight:Number = height;
		if (isNaN(newHeight))
			newHeight = getPreferredBoundsHeight();
		
		// re-add the top and bottom offsets.  (measuredTextSize.y - tightTextHeight) gives us 
		// the sum of top and bottom offsets 
		if (useTightTextBounds)
			newHeight += (measuredTextSize.y - tightTextHeight);
		
		this.height = newHeight;		
    }
    
    /**
     * @private
     */
    public function setLayoutMatrix(value:Matrix, invalidateLayout:Boolean):void
    {
        // do nothing
    }
    
    /**
     * @private
     */
    public function setLayoutMatrix3D(value:Matrix3D, invalidateLayout:Boolean):void
    {
        // do nothing
    }
    
    /**
     * @private
     */
    public function transformAround(transformCenter:Vector3D, scale:Vector3D=null, rotation:Vector3D=null, translation:Vector3D=null, postLayoutScale:Vector3D=null, postLayoutRotation:Vector3D=null, postLayoutTranslation:Vector3D=null, invalidateLayout:Boolean=true):void
    {
        // do nothing
    }
    
    //----------------------------------
    //  layoutDirection
    //----------------------------------
    
    /**
     * @private
     */
    public function get layoutDirection():String
    {
        return null;
    }
    
    /**
     * @private
     */
    public function set layoutDirection(value:String):void
    {
        // do nothing
    }
    
    //----------------------------------
    //  baseline
    //----------------------------------
    
    /**
     * @private
     */
    public function get baseline():Object
    {
        return null;
    }
    
    /**
     * @private
     */
    public function set baseline(value:Object):void
    {
        // do nothing
    }
    
    //----------------------------------
    //  baselinePosition
    //----------------------------------
    
    /**
     * @private
     */
    public function get baselinePosition():Number
    {
        commitStyles();
        
        if (invalidateBaselinePosition)
        {
            // getLineMetrics() returns strange numbers for an empty string,
            // so instead we get the metrics for a non-empty string.
            var isEmpty:Boolean = (text == "");
            if (isEmpty)
                super.text = "Wj";
            
            _baselinePosition = getLineMetrics(0).ascent;
            
            if (isEmpty)
                super.text = "";
            
            // baseline = add top gutter
            _baselinePosition += (StyleableTextField.TEXT_HEIGHT_PADDING / 2)
            
            invalidateBaselinePosition = false;
        }
        
        return _baselinePosition;
    }
    
    //----------------------------------
    //  bottom
    //----------------------------------
    
    /**
     * @private
     */
    public function get bottom():Object
    {
        return null;
    }
    
    /**
     * @private
     */
    public function set bottom(value:Object):void
    {
        // do nothing
    }
    
    //----------------------------------
    //  estimatedHeight
    //----------------------------------
    
    /**
     * @private
     */
    public function get estimatedHeight():Number
    {
        return NaN;
    }
    
    //----------------------------------
    //  estimatedWidth
    //----------------------------------
    
    /**
     * @private
     */
    public function get estimatedWidth():Number
    {
        return NaN;
    }
    
    //----------------------------------
    //  hasLayoutMatrix3D
    //----------------------------------
    
    /**
     * @private
     */
    public function get hasLayoutMatrix3D():Boolean
    {
        return false;
    }
    
    //----------------------------------
    //  horizontalCenter
    //----------------------------------
    
    /**
     * @private
     */
    public function get horizontalCenter():Object
    {
        return null;
    }
    
    /**
     * @private
     */
    public function set horizontalCenter(value:Object):void
    {
        // do nothing
    }
    
    //----------------------------------
    //  includeInLayout
    //----------------------------------
    
    /**
     * @private
     */
    public function get includeInLayout():Boolean
    {
        return true;
    }
    
    /**
     * @private
     */
    public function set includeInLayout(value:Boolean):void
    {
        // do nothing
    }
    
    //----------------------------------
    //  left
    //----------------------------------
    
    /**
     * @private
     */
    public function get left():Object
    {
        return null;
    }
    
    /**
     * @private
     */
    public function set left(value:Object):void
    {
        // do nothing
    }
    
    //----------------------------------
    //  percentHeight
    //----------------------------------
    
    /**
     * @private
     */
    public function get percentHeight():Number
    {
        return NaN;
    }
    
    /**
     * @private
     */
    public function set percentHeight(value:Number):void
    {
        // do nothing
    }
    
    //----------------------------------
    //  percentWidth
    //----------------------------------
    
    /**
     * @private
     */
    public function get percentWidth():Number
    {
        return NaN;
    }
    
    /**
     * @private
     */
    public function set percentWidth(value:Number):void
    {
        // do nothing
    }
    
    //----------------------------------
    //  right
    //----------------------------------
    
    /**
     * @private
     */
    public function get right():Object
    {
        return null;
    }
    
    /**
     * @private
     */
    public function set right(value:Object):void
    {
        // do nothing
    }
    
    //----------------------------------
    //  top
    //----------------------------------
    
    /**
     * @private
     */
    public function get top():Object
    {
        return null;
    }
    
    /**
     * @private
     */
    public function set top(value:Object):void
    {
        // do nothing
    }
    
    //----------------------------------
    //  verticalCenter
    //----------------------------------
    
    /**
     * @private
     */
    public function get verticalCenter():Object
    {
        return null;
    }
    
    /**
     * @private
     */
    public function set verticalCenter(value:Object):void
    {
        // do nothing
    }
    
    //----------------------------------
    //  depth
    //----------------------------------
    
    /**
     * @private
     */
    public function get depth():Number
    {
        return 0;
    }
    
    /**
     * @private
     */
    public function set depth(value:Number):void
    {
        // do nothing
    }
    
    //----------------------------------
    //  designLayer
    //----------------------------------
    
    /**
     * @private
     */
    public function get designLayer():DesignLayer
    {
        return null;
    }
    
    /**
     * @private
     */
    public function set designLayer(value:DesignLayer):void
    {
        // do nothing
    }
    
    //----------------------------------
    //  is3D
    //----------------------------------
    
    /**
     * @private
     */
    public function get is3D():Boolean
    {
        return false;
    }
    
    //----------------------------------
    //  owner
    //----------------------------------
    
    /**
     * @private
     */
    public function get owner():DisplayObjectContainer
    {
        return null;
    }
    
    /**
     * @private
     */
    public function set owner(value:DisplayObjectContainer):void
    {
        // do nothing
    }
    
    //----------------------------------
    //  postLayoutTransformOffsets
    //----------------------------------
    
    /**
     * @private
     */
    public function get postLayoutTransformOffsets():TransformOffsets
    {
        return null;
    }
    
    /**
     * @private
     */
    public function set postLayoutTransformOffsets(value:TransformOffsets):void
    {
        // do nothing
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Storage for the inline styles on this StyleableTextField instance
     * 
     *  There's no real need for _inlineStyleObject because we could 
     *  just piggy-back off of styleDeclaration (and create a new 
     *  CSSStyleDeclaration when setStyle() is called, but this is easier 
     *  and there seems to be less overhead with this approach).
     */
    private var _inlineStyleObject:Object;
    
    // Name of the style to use for determining the text color
    mx_internal var colorName:String = "color";
    
	// Whether or not we want to size and position the text field based upon its 
	// tight text bounds.  Use useTightTextBounds == true when you want precise
	// text placement.
	mx_internal var useTightTextBounds:Boolean = true;
	
    private static var supportedStyles:String = "textAlign fontFamily fontWeight fontStyle color fontSize textDecoration textIndent leading letterSpacing"
    
    private var invalidateStyleFlag:Boolean = true;
    
    private static var textFormat:TextFormat = new TextFormat();
    
    private var _isTruncated:Boolean = false;
    
    private static var embeddedFonts:Array;


	/**
	 *  @private
	 *  Table of text top offsets for different fonts, sizes, weights and styles
	 */	
	private static var textTopOffsetTable:Dictionary = new Dictionary();

    /**
     *  @private
     *  Whether this StyleableTextField needs to be measure its unscaled size
     */
    private var invalidateTextSizeFlag:Boolean = false;
    
    /**
     *  @private
     */
    private var _measuredTextSize:Point;
    
    /**
     *  @private
     */
    private var invalidateBaselinePosition:Boolean = true;
    
    /**
     *  @private
     */
    private var _baselinePosition:Number;
    
	/**
	 *  @private
	 */
	private var invalidateTightTextHeight:Boolean = true;
	
	/**
	 *  @private
	 */
	private var _tightTextHeight:Number;
    
    /**
     *  @private
     *  Used to keep track if this StyleableTextField is already in "scrolling mode"
     *  and what scroller it is using to scroll.  This is so we can respond appropriately 
     *  to other touchInteractionStarting and touchInteractionEnd events.
     */
    private var scrollerInTextSelectionMode:Scroller;
	
    /**
     *  @private
     *  The padding to be added to textWidth to get the width
     *  of a TextField that can display the text without clipping.
     */ 
    mx_internal static const TEXT_WIDTH_PADDING:int = 5;
    
    /**
     *  @private
     *  The padding to be added to textHeight to get the height
     *  of a TextField that can display the text without clipping.
     */ 
    mx_internal static const TEXT_HEIGHT_PADDING:int = 4;
}
}