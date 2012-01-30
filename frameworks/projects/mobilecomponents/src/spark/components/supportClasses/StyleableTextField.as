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
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.TextEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.text.Font;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.ui.Keyboard;

import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.resources.ResourceManager;
import mx.styles.CSSStyleDeclaration;
import mx.styles.ISimpleStyleClient;
import mx.styles.IStyleClient;

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
 *  skins and item renderers. It cannot be used in MXML markup.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
public class StyleableTextField extends TextField 
    implements IEditableText, ISimpleStyleClient
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
    
    public function get measuredTextSize():Point
    {
		// commit style to get an accurate measurement
		commitStyles();
		
        if (!_measuredTextSize)
        {
            _measuredTextSize = new Point();
            invalidateTextSizeFlag = true;
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
                
                return _measuredTextSize;
            }
            
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
        return _styleName;
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
        
        if (hasEventListener(FlexEvent.VALUE_COMMIT))
            dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
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
        invalidateTextSizeFlag = true;
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
            invalidateTextSizeFlag = true;
            
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
     *  Whether this StyleableTextField needs to be measure its unscaled size
     */
    private var invalidateTextSizeFlag:Boolean = false;
    
    private var _measuredTextSize:Point;
    
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