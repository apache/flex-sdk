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
import flash.text.FontType;
import flash.text.StyleSheet;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.text.TextInteractionMode;
import flash.text.TextLineMetrics;
import flash.ui.Keyboard;
import flash.utils.Dictionary;

import mx.core.DesignLayer;
import mx.core.FlexGlobals;
import mx.core.FlexTextField;
import mx.core.IInvalidating;
import mx.core.IVisualElement;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.TouchInteractionEvent;
import mx.events.TouchInteractionReason;
import mx.geom.TransformOffsets;
import mx.managers.SystemManager;
import mx.resources.IResourceManager;
import mx.resources.ResourceManager;
import mx.styles.CSSStyleDeclaration;
import mx.styles.ISimpleStyleClient;
import mx.styles.IStyleClient;
import mx.utils.MatrixUtil;

import spark.components.Application;
import spark.components.Scroller;
import spark.core.IEditableText;
import spark.events.TextOperationEvent;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

include "../../styles/metadata/StyleableTextFieldTextStyles.as"

[ResourceBundle("core")]

//
// To use:
//   in createChildren():
//       var tf:StyleableTextField = createInFontContext(StyleableTextField);
//       tf.styleName = this;
//       tf.editable = true|false;       // for editable text
//       tf.multiline = true|false;      // for multiline text
//       tf.wordWrap = true|false;       // for word wrapping
//       tf.cacheAsBitmap = true|false;  // use true if text in item renderer
//       addChild(tf);
//
//   in commitProperties():
//       tf.text = "...." - if needed
//
//   in measure();
//       if (tf.isTruncated)     // if text may be truncated
//           tf.text = "...";
//       tf.commitStyles();    // Always call this. No-op if styles already applied.
//       Use getElementPreferredWidth(tf), getElementPreferredHeight(tf)
//
//   in updateDisplayList():
//       if (tf.isTruncated)    // if text may be truncated
//           tf.text = "...";
//       tf.commitStyles();    // Always call this. No-op if styles already applied.
//       setElementSize(tf, width, height);
//       setElementPosition(x, y);
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
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class StyleableTextField extends FlexTextField
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
    
    /**
     *  @private
     */
    override public function set width(value:Number):void
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
    
    /**
     * 
     *  Name of the style to use for determining the text color
     */
    private var _colorName:String = "color";
    
    mx_internal function set colorName(value:String):void
    {
        if (_colorName == value)
            return;
        
        _colorName = value;
        invalidateStyleFlag = true;
    }
    
    /**
     *  @private
     */
    mx_internal function get colorName():String
    {
        return _colorName;
    }
    
    /**
     *  @private
     *  Used in place of TextField#textWidth and TextField#textHeight to
     *  provide consistent size values when accounting for player scaling
     *  and presence on the stage. Accounts for textIndent and TextField
     *  gutters.
     */
    mx_internal function get measuredTextSize():Point
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
            var textScaleX:Number = 1;
            var textScaleY:Number = 1;
            
            // concatenatedMatrix is not valid when off the stage
            if (!stage)
            {
                var application:Application = (FlexGlobals.topLevelApplication as Application);
                var sm:SystemManager = (application) ? (application.systemManager as SystemManager) : null;
                
                if (sm)
                {
                    textScaleX = sm.densityScale;
                    textScaleY = sm.densityScale; 
                }
            }
            else
            {
                MatrixUtil.decomposeMatrix(decomposition, transform.concatenatedMatrix, 0, 0);
                textScaleX = decomposition[3]
                textScaleY = decomposition[4]
            }
            
            // short circuit measurement when not scaling
            if (embedFonts || (textScaleX == 1 && textScaleY == 1))
            {
                _measuredTextSize.x = textWidth + TEXT_WIDTH_PADDING
                _measuredTextSize.y = textHeight + TEXT_HEIGHT_PADDING;
                
                // add textIndent for single line only
                if (!multiline)
                    _measuredTextSize.x += getStyle("textIndent");
            }
            else
            {
                // for consistent, scaled measurement:
                // If on the stage, use width and height
                // If not on the stage, scale the TextField then inverse scale
                // the width and height 
                
                // Use TextFieldAutoSize.LEFT to compact the text field. 
                // Using autoSize will change the current size.
                // Must save, then restore current state.
                var oldWidth:Number = width;
                var oldHeight:Number = height;
                var oldAutoSize:String = autoSize;
                
                // right and bottom edges close-in on text content
                autoSize = TextFieldAutoSize.LEFT;
                
                // apply application scale factor while off stage
                if (!stage)
                {
                    var oldScaleX:Number = this.scaleX;
                    var oldScaleY:Number = this.scaleY;
                    
                    this.scaleX *= textScaleX;
                    this.scaleY *= textScaleY;
                    
                    // apply inverse scaling on the on the scaled TextField size
                    // this accounts for font scaling behavior in the player
                    _measuredTextSize.x = width / textScaleX;
                    _measuredTextSize.y = height / textScaleY;
                    
                    // remove application scale factor
                    this.scaleX = oldScaleX;
                    this.scaleY = oldScaleY;
                }
                else
                {
                    _measuredTextSize.x = width;
                    _measuredTextSize.y = height;
                }
                
                // restore previous size
                autoSize = oldAutoSize;
                
                if (autoSize == TextFieldAutoSize.NONE)
                {
                    super.width = oldWidth;
                    super.height = oldHeight;
                }
            }
            
            // Multi-line text enables internal scrolling if we use textHeight. Adding
            // leading solves that problem.
            if (numLines > 1)
                _measuredTextSize.y += getStyle("leading");
            
            // account for floating point errors to fix accidental clipping
            // or truncation
            _measuredTextSize.x = Math.ceil(_measuredTextSize.x);
            _measuredTextSize.y = Math.ceil(_measuredTextSize.y);
            
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
     *  @playerversion AIR 2.5
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
     *  @playerversion AIR 2.5
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
    private function get tightTextTopOffset():Number
    {
        updateTightTextSizes();
        
        return _tightTextTopOffset;
    }
    
    /**
     *  @private
     *  The height of the first line of text to the baseline of the bottom line
     *  of text.  Handles both single line and multiline text.
     */
    private function get tightTextHeight() :Number
    {
        updateTightTextSizes();
        
        return _tightTextHeight;
    }
    
    private function updateTightTextSizes():void
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
            
            _tightTextTopOffset = getTextTopOffset(defaultTextFormat, styleSheet);
            _tightTextHeight = measuredTextSize.y - _tightTextTopOffset - bottomOffset;
            
            if (isEmpty)
                text = "";
            
            invalidateTightTextHeight = false;
        }
    }
    
    /**
     *  @private
     *  Finds the distance from the top edge of the containing text field to the text for
     *  a particular font, size, weight and style combination.  This value accounts for
     *  the difference between the metrics.ascent and the true top of the text within the
     *  text field and the top gutter
     * 
     *  If a styleSheet is specified it will be used, otherwise the textFormat will be used.
     */
    private static function getTextTopOffset(textFormat:TextFormat, styleSheet:StyleSheet=null):Number
    {
        // Try to find the top offset for the font, size, weight and style in our table.
        // We only store offets for unique font, size, weight and style combinations.
        // There could be some other factors that affect textFormat...if we find 
        // more of them, we will have to change the key to take that into account.
        var key:String = textFormat.font + "_" + textFormat.size + "_" + textFormat.bold + "_" + textFormat.italic;
        var topOffset:Number = textTopOffsetTable[key];
        
        // if we can't find the value in our table let's calculate it
        if (isNaN(topOffset))
        {
            // default offset is top gutter
            topOffset = StyleableTextField.TEXT_HEIGHT_PADDING/2;
            
            // create sample text field
            var field:TextField = new TextField();
            if (styleSheet)
                field.styleSheet = styleSheet;
            else
                field.defaultTextFormat = textFormat;
            field.embedFonts = isFontEmbedded(textFormat);
            field.textColor = 0x000000; // make sure our text is black so it will show up against white
            field.text = "T"; // use "T" as our standard
            
            // Bitmap data requires non-zero size
            if ((field.textWidth > 0) && (field.textHeight > 0))
            {
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
                
                if (i < bitmapData.height)
                    topOffset = i;
            }
            
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
     *  @playerversion AIR 2.5
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
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get isTruncated():Boolean
    {
        return _isTruncated;
    }
    
    //----------------------------------
    //  minHeight
    //----------------------------------
    
    /**
     *  @copy mx.core.UIComponent#minHeight
     *
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var minHeight:Number;
    
    //----------------------------------
    //  minWidth
    //----------------------------------
    
    /**
     *  @copy mx.core.UIComponent#minWidth
     *
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var  minWidth:Number;
    
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
     *  @default true if type is TextFieldType.INPUT, otherwise false.
     *
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get editable():Boolean
    {
        return type == TextFieldType.INPUT;
    }
    
    public function set editable(value:Boolean):void
    {
        if (value == editable)
            return;
        
        type = value ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
        
        // changing editability, changes size
        invalidateTightTextHeight = true;
        invalidateTextSizeFlag = true;
        
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
     *  @playerversion AIR 2.5
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
     *  @playerversion AIR 2.5
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
     *  @playerversion AIR 2.5
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
     *  @playerversion AIR 2.5
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
     *  @playerversion AIR 2.5
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
     *  @playerversion AIR 2.5
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
     *  @playerversion AIR 2.5
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
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function scrollToRange(anchorPosition:int, activePosition:int):void
    {
        // Pass to delegate, if defined
        if (scrollToRangeDelegate != null)
        {
            scrollToRangeDelegate(anchorPosition, activePosition);
            return;
        }
        
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
     *  @throws Error This method or property cannot be used on a text field with a style sheet.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function insertText(text:String):void
    {
        if (styleSheet)
        {
            const resourceManager:IResourceManager = ResourceManager.getInstance();
            const message:String = 
                resourceManager.getString("components", "styleSheetError");
            throw(new Error(message));
        }
        
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
     *  @playerversion AIR 2.5
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
     *  @playerversion AIR 2.5
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
     *  @playerversion AIR 2.5
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
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function setFocus():void
    {
        // if we already have the focus, no need to set it again.
        // if we do indeed set it again, we might end up scrolling the 
        // TextField when we don't want that to happen (SDK-29453)
        if (stage.focus != this)
            stage.focus = this;
        
        // Work around a runtime bug where calling setSelection(0,0) doesn't
        // work if the text field is not in focus. 
        // This handles the read-only, non-selectable case
        if (selectable == false)
            setSelection(0,0);
        
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
     *  @playerversion AIR 2.5
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
            
            // most components ignore margin and just set x and y, but some (like TextInput)
            // set the margin increase their hitArea
            textFormat.leftMargin = leftMargin;
            textFormat.rightMargin = rightMargin;
            
            // Check for embedded fonts
            embedFonts = isFontEmbedded(textFormat);
            
            // It is an error to set defaultTextFormat or call setTextFormat if there is a 
            // styleSheet.
            if (!styleSheet)
            {
                defaultTextFormat = textFormat;
                setTextFormat(textFormat);
            }
            
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
     *  @playerversion AIR 2.5
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
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function setStyle(styleProp:String, value:*):void
    {
        if (!_inlineStyleObject)
            _inlineStyleObject = {};
        
        if (value == null)
            delete  _inlineStyleObject[styleProp];
        else
            _inlineStyleObject[styleProp] = value;
        
        styleChanged(styleProp);
    }
    
    /**
     *  @copy mx.core.UIComponent#styleChanged()
     *
     *  @param styleProp The style property that changed.
     *
     *  @langversion 3.0
     *  @playerversion AIR 2.5
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
        if (leftMargin is Number)
            w -= Number(leftMargin);
        if (rightMargin is Number)
            w -= Number(rightMargin);
        
        _isTruncated = false;
        
        // Need to check if we should truncate, but it
        // could be due to rounding error.  Let's check that it's not.
        // Examples of rounding errors happen with "South Africa" and "Game"
        // with verdana.ttf.
        
        if (originalText != "" && measuredTextSize.x > w + 0.00000000000001)
        {
            // This should get us into the ballpark.
            var s:String = originalText;
            
            // TODO (rfrishbe): why is this here below...it does nothing (see SDK-26438)
            //originalText.slice(0,
            //    Math.floor((w / (textWidth + TEXT_WIDTH_PADDING)) * originalText.length));
            
            while (s.length > 1 && (measuredTextSize.x > w))
            {
                s = s.slice(0, -1);
                super.text = s + truncationIndicator;
                
                invalidateTextSizeFlag = true;
            }
            
            _isTruncated = true;
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
            
            // embedAsCFF is not supported for StyleableTextField
            // reporting CFF as not embedded degrades to default device font
            if (font.fontName == format.font &&
                (font.fontType != FontType.EMBEDDED_CFF))
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
        // Cancelling an ACTIVATING event will close the softKeyboard if it is 
        // currently active on iOS only. Add a check to only cancel the event
        // if the softKeyboard is not active. Otherwise, the softKeyboard will
        // close if you start a touch scroll from a text component.
        var topLevelApp:Application = FlexGlobals.topLevelApplication as Application;
        
        if (!(topLevelApp && topLevelApp.isSoftKeyboardActive))
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
            return width - StyleableTextField.TEXT_GUTTER * 2;
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
            return x + StyleableTextField.TEXT_GUTTER;
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
            return y + tightTextTopOffset;
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
        return isNaN(minHeight) ? 0 : minHeight;
    }
    
    /**
     * @private
     */
    public function getMinBoundsWidth(postLayoutTransform:Boolean=true):Number
    {
        return isNaN(minWidth) ? 0 : minWidth;
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
            return measuredTextSize.x - StyleableTextField.TEXT_GUTTER * 2;
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
    public function setLayoutBoundsPosition(x:Number, y:Number, postLayoutTransform:Boolean=true):void
    {
        if (useTightTextBounds)
        {
            // offset the positions by the left gutters and the top offset
            this.x = x - StyleableTextField.TEXT_GUTTER;
            this.y = y - tightTextTopOffset;
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
        
        if (useTightTextBounds)
        {
            if (newHeight > 0)
            {
                var bottomOffset:Number = measuredTextSize.y - tightTextTopOffset - tightTextHeight;
                
                // when clipping, allow gutter to be outside of height
                // use 2x gutter (actual gutter is not part of tight text height)
                // when newHeight==1, actual visible height==3 (1px + 1x gutter)
                if (newHeight < tightTextHeight)
                    bottomOffset = StyleableTextField.TEXT_HEIGHT_PADDING;
                
                // re-add the top and bottom offsets.  (measuredTextSize.y - tightTextHeight) gives us
                // the sum of top and bottom offsets
                newHeight += (tightTextTopOffset + bottomOffset);
            }
        }
        
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
            if (useTightTextBounds)
            {
                _baselinePosition = tightTextHeight;
            }
            else
            {
                // getLineMetrics() returns strange numbers for an empty string,
                // so instead we get the metrics for a non-empty string.
                var isEmpty:Boolean = (text == "");
                if (isEmpty)
                    super.text = "Wj";
                
                _baselinePosition = getLineMetrics(0).ascent + (StyleableTextField.TEXT_HEIGHT_PADDING / 2);
                
                if (isEmpty)
                    super.text = "";
            }
            
            invalidateBaselinePosition = false;
        }
        
        return _baselinePosition;
    }
    
    //----------------------------------
    //  bottom
    //----------------------------------
    
    private var _bottom:Object;
    
    /**
     * @private
     */
    public function get bottom():Object
    {
        return _bottom;
    }
    
    /**
     * @private
     */
    public function set bottom(value:Object):void
    {
        if (_bottom == value)
            return;
        
        _bottom = value;
        invalidateParentSizeAndDisplayList();
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
    
    private var _left:Object;
    
    /**
     * @private
     */
    public function get left():Object
    {
        return _left;
    }
    
    /**
     * @private
     */
    public function set left(value:Object):void
    {
        if (_left == value)
            return;
        
        _left = value;
        invalidateParentSizeAndDisplayList();
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
    
    private var _right:Object;
    
    /**
     * @private
     */
    public function get right():Object
    {
        return _right;;
    }
    
    /**
     * @private
     */
    public function set right(value:Object):void
    {
        if (_right == value)
            return;
        
        _right = value;
        invalidateParentSizeAndDisplayList();
    }
    
    //----------------------------------
    //  top
    //----------------------------------
    
    private var _top:Object;
    
    /**
     * @private
     */
    public function get top():Object
    {
        return _top;
    }
    
    /**
     * @private
     */
    public function set top(value:Object):void
    {
        if (_top == value)
            return;
        
        _top = value;
        invalidateParentSizeAndDisplayList();
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
    
    
    /**
     *  Helper method to invalidate parent size and display list if
     *  this object affects its layout (includeInLayout is true).
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    private function invalidateParentSizeAndDisplayList():void
    {
        // We want to invalidate both the parent size and parent display list.
        if (parent && parent is IInvalidating)
        {
            IInvalidating(parent).invalidateSize();
            IInvalidating(parent).invalidateDisplayList();
        }
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
        
    // Whether or not we want to size and position the text field based upon its
    // tight text bounds.  Use useTightTextBounds == true when you want precise
    // text placement.
    mx_internal var useTightTextBounds:Boolean = true;
    
    // Delegate function for scrollToRange. If defined, the scrollToRange
    // method is delegated to this function.
    mx_internal var scrollToRangeDelegate:Function;
    
    // the left and right margin for this StyleableTextField.  By default
    // it is null, which corresponds to 0.
    mx_internal var leftMargin:Object;
    mx_internal var rightMargin:Object;
    
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
     *  For text measurement when scaling
     */
    private static var decomposition:Vector.<Number> = new <Number>[0,0,0,0,0];
    
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
     */
    private var _tightTextTopOffset:Number;
    
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
     *  The width of the gutter between the edge of the text field 
     *  and the text. 
     */
    mx_internal static const TEXT_GUTTER:int = 2;
    
    /**
     *  @private
     *  The padding to be added to textHeight to get the height
     *  of a TextField that can display the text without clipping.
     */
    mx_internal static const TEXT_HEIGHT_PADDING:int = 4;
}
}