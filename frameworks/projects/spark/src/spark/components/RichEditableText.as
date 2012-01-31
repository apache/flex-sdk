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

package flex.component
{

import flash.display.Graphics;
import flash.events.Event;
import flash.text.engine.ElementFormat;
import flash.text.engine.FontDescription;
import flash.text.engine.FontPosture;
import flash.text.engine.FontWeight;
import flash.text.engine.Kerning;
import flash.text.engine.TextBlock;
import flash.text.engine.TextElement;
import flash.text.engine.TextLine;

import flex.events.TextOperationEvent;
import flex.utils.TextUtil;

import mx.core.UIComponent;

import text.container.IContainerController;
import text.edit.ContainerStyleChangeOperation;
import text.edit.EditManager;
import text.edit.FlowOperation;
import text.edit.ISelectionManager;
import text.edit.OperationEvent;
import text.edit.ParagraphStyleChangeOperation;
import text.edit.SelectionChangedEvent;
import text.edit.SelectionColor;
import text.edit.SelectionState;
import text.edit.SplitParOperation;
import text.edit.StyleChangeOperation;
import text.elements.FlowElement;
import text.elements.ParagraphElement;
import text.elements.SpanElement;
import text.elements.TextFlow;
import text.events.ComposeDoneEvent;
import text.formats.BlockProgression;
import text.formats.CharacterFormat;
import text.formats.ContainerFormat;
import text.formats.Direction;
import text.formats.ICharacterFormat;
import text.formats.IContainerFormat;
import text.formats.IParagraphFormat;
import text.formats.LineBreak;
import text.formats.ParagraphFormat;
import text.formats.TextAlign;
import text.formats.TextDecoration;
import text.formats.VerticalAlign;
import text.formats.WhitespaceCollapse;
import text.importExport.TextFilter;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispached after the <code>selectionAnchorIndex</code> and/or
 *  <code>selectionActiveIndex</code> properties have changed.
 *  due to a user interaction.
 */
[Event(name="selectionChange", type="flash.events.Event")]

/**
 *  Dispatched before a user editing operation occurs.
 *  You can alter the operation, or cancel the event
 *  to prevent the operation from being processed.
 */
[Event(name="changing", type="flex.events.TextOperationEvent")]

/**
 *  Dispatched after a user editing operation is complete.
 */
[Event(name="change", type="flex.events.TextOperationEvent")]

/**
 *  Dispatched when the user pressed the Enter key.
 */
[Event(name="enter", type="flash.events.Event")]

[DefaultProperty("content")]

/**
 *  The TextView class ...
 */
public class TextView extends UIComponent
{
    include "../core/Version.as";
        
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor. 
     */
    public function TextView()
    {
        super();

        _content = textFlow = createEmptyTextFlow();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private var textFlow:TextFlow;
            
    /**
     *  @private
     */
    private var textAttributeChanged:Boolean = true;

    /**
     *  @private
     */
    private var fontMetricsInvalid:Boolean = true;
    
    /**
     *  @private
     */
    private var textInvalid:Boolean = false;
        
    /**
     *  @private
     */
    private var ascent:Number;
    
    /**
     *  @private
     */
    private var descent:Number;

    /**
     *  @private
     */
    private var charWidth:Number;

    //--------------------------------------------------------------------------
    //
    //  Properties: Text formatting
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  blockProgression
    //----------------------------------

    /**
     *  @private
     */
    private var _blockProgression:String = BlockProgression.TOP_TO_BOTTOM;

    /**
     *  Documentation is not currently available.
     */
    public function get blockProgression():String
    {
        return _blockProgression;
    }

    /**
     *  @private
     */
    public function set blockProgression(value:String):void
    {
        if (value == _blockProgression)
            return;

        _blockProgression = value;
        textAttributeChanged = true;
        
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }

    //----------------------------------
    //  color
    //----------------------------------

    /**
     *  @private
     */
    private var _color:uint = 0x000000;

    /**
     *  The color of the text.
     *
     *  @default 0x000000
     */
    public function get color():uint
    {
        return _color;
    }

    /**
     *  @private
     */
    public function set color(value:uint):void
    {
        if (value == _color)
            return;
        
        _color = value;
        textAttributeChanged = true;
        
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }

    //----------------------------------
    //  direction
    //----------------------------------

    /**
     *  @private
     */
    private var _direction:String = Direction.LEFT_TO_RIGHT;

    /**
     *  Documentation is not currently available.
     */
    public function get direction():String
    {
        return _direction;
    }

    /**
     *  @private
     */
    public function set direction(value:String):void
    {
        if (value == _direction)
            return;

        _direction = value;
        textAttributeChanged = true;
        
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }

    //----------------------------------
    //  fontFamily
    //----------------------------------

    /**
     *  @private
     */
    private var _fontFamily:String = "Times New Roman";

    /**
     *  The name of the font used to render the text.
     *
     *  @default "Times New Roman"
     */
    public function get fontFamily():String
    {
        return _fontFamily;
    }

    /**
     *  @private
     */
    public function set fontFamily(value:String):void
    {
        if (value == _fontFamily)
            return;

        _fontFamily = value;
        textAttributeChanged = true;
        fontMetricsInvalid = true;
        
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }

    //----------------------------------
    //  fontSize
    //----------------------------------

    /**
     *  @private
     */
    private var _fontSize:Number = 12;

    /**
     *  The size, in pixels, of the font used to render the text.
     *
     *  @default 12
     */
    public function get fontSize():Number
    {
        return _fontSize;
    }

    /**
     *  @private
     */
    public function set fontSize(value:Number):void
    {
        if (value == _fontSize)
            return;

        _fontSize = value;
        textAttributeChanged = true;
        fontMetricsInvalid = true;
        
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }

    //----------------------------------
    //  fontStyle
    //----------------------------------

    /**
     *  @private
     */
    private var _fontStyle:String = FontPosture.NORMAL;

    /**
     *  Determines whether the text is italic.
     *  Recognized values are <code>"normal"</code> and <code>"italic"</code>.
     * 
     *  @default "normal"
     */
    public function get fontStyle():String
    {
        return _fontStyle;
    }

    /**
     *  @private
     */
    public function set fontStyle(value:String):void
    {
        if (value == _fontStyle)
            return;

        _fontStyle = value;
        textAttributeChanged = true;
        fontMetricsInvalid = true;
        
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }

    //----------------------------------
    //  fontWeight
    //----------------------------------

    /**
     *  @private
     */
    private var _fontWeight:String = FontWeight.NORMAL;

    /**
     *  Determines whether the text is boldface.
     *  Recognized values are <code>"normal"</code> and <code>"bold"</code>.
     * 
     *  @default "normal"
     */
    public function get fontWeight():String
    {
        return _fontWeight;
    }

    /**
     *  @private
     */
    public function set fontWeight(value:String):void
    {
        if (value == _fontWeight)
            return;

        _fontWeight = value;
        textAttributeChanged = true;
        fontMetricsInvalid = true;

        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }

    //----------------------------------
    //  kerning
    //----------------------------------

    /**
     *  @private
     */
    private var _kerning:String = Kerning.AUTO;

    /**
     *  Documentation is not currrently available.
     */
    public function get kerning():String
    {
        return _kerning;
    }

    /**
     *  @private
     */
    public function set kerning(value:String):void
    {
        if (value == _kerning)
            return;

        _kerning = value;
        textAttributeChanged = true;
        fontMetricsInvalid = true;

        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }

    //----------------------------------
    //  lineBreak
    //----------------------------------

    /**
     *  @private
     */
    private var _lineBreak:String = LineBreak.TO_FIT;

    /**
     *  Documentation is not currrently available.
     */
    public function get lineBreak():String
    {
        return _lineBreak;
    }

    /**
     *  @private
     */
    public function set lineBreak(value:String):void
    {
        if (value == _lineBreak)
            return;

        _lineBreak = value;
        textAttributeChanged = true;
        fontMetricsInvalid = true;

        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }

    //----------------------------------
    //  lineHeight
    //----------------------------------

    /**
     *  @private
     */
    private var _lineHeight:Object = "120%";

    /**
     *  Documentation is not currrently available.
     */
    public function get lineHeight():Object
    {
        return _lineHeight;
    }

    /**
     *  @private
     */
    public function set lineHeight(value:Object):void
    {
        if (value == _lineHeight)
            return;

        _lineHeight = value;
        textAttributeChanged = true;
        fontMetricsInvalid = true;

        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }

    //----------------------------------
    //  lineThrough
    //----------------------------------

    /**
     *  @private
     */
    private var _lineThrough:Boolean = false;

    /**
     *  Documentation is not currrently available.
     */
    public function get lineThrough():Boolean
    {
        return _lineThrough;
    }

    /**
     *  @private
     */
    public function set lineThrough(value:Boolean):void
    {
        if (value == _lineThrough)
            return;

        _lineThrough = value;
        textAttributeChanged = true;
        fontMetricsInvalid = true;

        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }

    //----------------------------------
    //  marginBottom
    //----------------------------------

    /**
     *  @private
     */
    private var _marginBottom:Number = 0;

    /**
     *  Documentation is not currently available.
     */
    public function get marginBottom():Number
    {
        return _marginBottom;
    }

    /**
     *  @private
     */
    public function set marginBottom(value:Number):void
    {
        if (value == _marginBottom)
            return;

        _marginBottom = value;
        textAttributeChanged = true;
        fontMetricsInvalid = true;
        
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }

    //----------------------------------
    //  marginLeft
    //----------------------------------

    /**
     *  @private
     */
    private var _marginLeft:Number = 0;

    /**
     *  Documentation is not currently available.
     */
    public function get marginLeft():Number
    {
        return _marginLeft;
    }

    /**
     *  @private
     */
    public function set marginLeft(value:Number):void
    {
        if (value == _marginLeft)
            return;

        _marginLeft = value;
        textAttributeChanged = true;
        fontMetricsInvalid = true;
        
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }

    //----------------------------------
    //  marginRight
    //----------------------------------

    /**
     *  @private
     */
    private var _marginRight:Number = 0;

    /**
     *  Documentation is not currently available.
     */
    public function get marginRight():Number
    {
        return _marginRight;
    }

    /**
     *  @private
     */
    public function set marginRight(value:Number):void
    {
        if (value == _marginRight)
            return;

        _marginRight = value;
        textAttributeChanged = true;
        fontMetricsInvalid = true;
        
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }

    //----------------------------------
    //  marginTop
    //----------------------------------

    /**
     *  @private
     */
    private var _marginTop:Number = 0;

    /**
     *  Documentation is not currently available.
     */
    public function get marginTop():Number
    {
        return _marginTop;
    }

    /**
     *  @private
     */
    public function set marginTop(value:Number):void
    {
        if (value == _marginTop)
            return;

        _marginTop = value;
        textAttributeChanged = true;
        fontMetricsInvalid = true;
        
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }

    //----------------------------------
    //  paddingBottom
    //----------------------------------

    /**
     *  @private
     */
    private var _paddingBottom:Number = 0;

    /**
     *  Documentation is not currently available.
     */
    public function get paddingBottom():Number
    {
        return _paddingBottom;
    }

    /**
     *  @private
     */
    public function set paddingBottom(value:Number):void
    {
        if (value == _paddingBottom)
            return;

        _paddingBottom = value;
        textAttributeChanged = true;
        fontMetricsInvalid = true;
        
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }

    //----------------------------------
    //  paddingLeft
    //----------------------------------

    /**
     *  @private
     */
    private var _paddingLeft:Number = 0;

    /**
     *  Documentation is not currently available.
     */
    public function get paddingLeft():Number
    {
        return _paddingLeft;
    }

    /**
     *  @private
     */
    public function set paddingLeft(value:Number):void
    {
        if (value == _paddingLeft)
            return;

        _paddingLeft = value;
        textAttributeChanged = true;
        fontMetricsInvalid = true;
        
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }

    //----------------------------------
    //  paddingRight
    //----------------------------------

    /**
     *  @private
     */
    private var _paddingRight:Number = 0;

    /**
     *  Documentation is not currently available.
     */
    public function get paddingRight():Number
    {
        return _paddingRight;
    }

    /**
     *  @private
     */
    public function set paddingRight(value:Number):void
    {
        if (value == _paddingRight)
            return;

        _paddingRight = value;
        textAttributeChanged = true;
        fontMetricsInvalid = true;
        
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }

    //----------------------------------
    //  paddingTop
    //----------------------------------

    /**
     *  @private
     */
    private var _paddingTop:Number = 0;

    /**
     *  Documentation is not currently available.
     */
    public function get paddingTop():Number
    {
        return _paddingTop;
    }

    /**
     *  @private
     */
    public function set paddingTop(value:Number):void
    {
        if (value == _paddingTop)
            return;

        _paddingTop = value;
        textAttributeChanged = true;
        fontMetricsInvalid = true;
        
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }

    //----------------------------------
    //  textAlign
    //----------------------------------

    /**
     *  @private
     */
    private var _textAlign:String = TextAlign.START;

    /**
     *  Documentation is not currrently available.
     */
    public function get textAlign():String
    {
        return _textAlign;
    }

    /**
     *  @private
     */
    public function set textAlign(value:String):void
    {
        if (value == _textAlign)
            return;

        _textAlign = value;
        textAttributeChanged = true;
        fontMetricsInvalid = true;

        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }

    //----------------------------------
    //  textAlignLast
    //----------------------------------

    /**
     *  @private
     */
    private var _textAlignLast:String = TextAlign.START;

    /**
     *  Documentation is not currrently available.
     */
    public function get textAlignLast():String
    {
        return _textAlignLast;
    }

    /**
     *  @private
     */
    public function set textAlignLast(value:String):void
    {
        if (value == _textAlignLast)
            return;

        _textAlignLast = value;
        textAttributeChanged = true;
        fontMetricsInvalid = true;

        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }

    //----------------------------------
    //  textAlpha
    //----------------------------------

    /**
     *  @private
     */
    private var _textAlpha:Number = 1.0;

    /**
     *  Documentation is not currently available.
     */
    public function get textAlpha():Number
    {
        return _textAlpha;
    }

    /**
     *  @private
     */
    public function set textAlpha(value:Number):void
    {
        if (value == _textAlpha)
            return;

        _textAlpha = value;
        textAttributeChanged = true;
        fontMetricsInvalid = true;
        
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }

    //----------------------------------
    //  textDecoration
    //----------------------------------

    /**
     *  @private
     */
    private var _textDecoration:String = TextDecoration.NONE;

    /**
     *  Documentation is not currrently available.
     */
    public function get textDecoration():String
    {
        return _textDecoration;
    }

    /**
     *  @private
     */
    public function set textDecoration(value:String):void
    {
        if (value == _textDecoration)
            return;

        _textDecoration = value;
        textAttributeChanged = true;
        fontMetricsInvalid = true;

        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }

    //----------------------------------
    //  textIndent
    //----------------------------------

    /**
     *  @private
     */
    private var _textIndent:Number = 0;

    /**
     *  Documentation is not currently available.
     */
    public function get textIndent():Number
    {
        return _textIndent;
    }

    /**
     *  @private
     */
    public function set textIndent(value:Number):void
    {
        if (value == _textIndent)
            return;

        _textIndent = value;
        textAttributeChanged = true;
        fontMetricsInvalid = true;
        
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }

    //----------------------------------
    //  tracking
    //----------------------------------

    /**
     *  @private
     */
    private var _tracking:Object = 0;

    /**
     *  Documentation is not currrently available.
     */
    public function get tracking():Object
    {
        return _tracking;
    }

    /**
     *  @private
     */
    public function set tracking(value:Object):void
    {
        if (value == _tracking)
            return;

        _tracking = value;
        textAttributeChanged = true;
        fontMetricsInvalid = true;

        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }

    //----------------------------------
    //  verticalAlign
    //----------------------------------

    /**
     *  @private
     */
    private var _verticalAlign:String = VerticalAlign.TOP;

    /**
     *  Documentation is not currrently available.
     */
    public function get verticalAlign():String
    {
        return _verticalAlign;
    }

    /**
     *  @private
     */
    public function set verticalAlign(value:String):void
    {
        if (value == _verticalAlign)
            return;

        _verticalAlign = value;
        textAttributeChanged = true;
        fontMetricsInvalid = true;

        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }

    //----------------------------------
    //  whiteSpaceCollapse
    //----------------------------------

    /**
     *  @private
     */
    private var _whiteSpaceCollapse:String = WhitespaceCollapse.PRESERVE;

    /**
     *  Documentation is not currrently available.
     */
    public function get whiteSpaceCollapse():String
    {
        return _whiteSpaceCollapse;
    }

    /**
     *  @private
     */
    public function set whiteSpaceCollapse(value:String):void
    {
        if (value == _whiteSpaceCollapse)
            return;

        _whiteSpaceCollapse = value;
        textAttributeChanged = true;
        fontMetricsInvalid = true;

        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  content
    //----------------------------------

    /**
     *  @private
     */
    private var _content:Object;

    /**
     *  @private
     */
    private var contentChanged:Boolean = false;

    /**
     *  Documentation is not currently available.
     */
    public function get content():Object
    {
        return _content;
    }

    /**
     *  @private
     */
    public function set content(value:Object):void
    {
        if (value == _content)
            return;

        _content = value;
        contentChanged = true;
        textInvalid = true;

        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }
    
    //----------------------------------
    //  contentHeight
    //----------------------------------

    /**
     *  @private
     */
    private var _contentHeight:Number = 0;

    [Bindable("contentSizeChanged")]
    
    /**
     *  Documentation is not currently available.
     */
    public function get contentHeight():Number
    {
        return _contentHeight;
    }

    //----------------------------------
    //  contentWidth
    //----------------------------------

    /**
     *  @private
     */
    private var _contentWidth:Number = 0;

    [Bindable("contentSizeChanged")]
    
    /**
     *  Documentation is not currently available.
     */
    public function get contentWidth():Number
    {
        return _contentWidth;
    }

    //----------------------------------
    //  heightInLines
    //----------------------------------

    /**
     *  @private
     */
    private var _heightInLines:int = 10;

    /**
     *  @private
     */
    private var heightInLinesChanged:Boolean = false;
    
    /**
     *  TBD
     */
    public function get heightInLines():int
    {
        return _heightInLines;
    }

    /**
     *  @private
     */
    public function set heightInLines(value:int):void
    {
        if (value == _heightInLines)
            return;

        _heightInLines = value;
        heightInLinesChanged = true;

        invalidateSize();
        invalidateDisplayList();
    }
    
    //----------------------------------
    //  horizontalScrollPosition
    //----------------------------------

    /**
     *  @private
     */
    private var _horizontalScrollPosition:Number = 0;

    /**
     *  @private
     */
    private var horizontalScrollPositionChanged:Boolean = false;
 
    /**
     *  Documentation is not currently available.
     */
    public function get horizontalScrollPosition():Number
    {
        return _horizontalScrollPosition;
    }

    /**
     *  @private
     */
    public function set horizontalScrollPosition(value:Number):void
    {
        if (value == _horizontalScrollPosition)
            return;

        _horizontalScrollPosition = value;
        horizontalScrollPositionChanged = true;

        invalidateProperties();
    }
        
    //----------------------------------
    //  multiline
    //----------------------------------

    /**
     *  @private
     */
    private var _multiline:Boolean = true;

    /**
     *  Determines whether the user can enter multiline text.
     *  If <code>true</code>, the Enter key starts a new paragraph.
     *  If <code>false</code>, the Enter key doesn't affect the text
     *  but causes the TextView to dispatch an <code>"enter"</code> event.
     * 
     *  @default true
     */
    public function get multiline():Boolean 
    {
        return _multiline;
    }
    
    /**
     *  @private
     */
    public function set multiline(value:Boolean):void
    {
        _multiline = value;
    }

    //----------------------------------
    //  selectionActiveIndex
    //----------------------------------

    /**
     *  @private
     */
    private var _selectionActiveIndex:int = -1;

    /**
     *  @private
     */
    private var selectionActiveIndexChanged:Boolean = false;
    
    /**
     *  The active index of the selection.
     *  The "active" point is the end of the selection
     *  which is changed when the selection is extended.
     *  The active index may be either the start
     *  or the end of the selection. 
     *
     *  @default -1
     */
    public function get selectionActiveIndex():int
    {
        return _selectionActiveIndex;
    }

    /**
     *  @private
     */
    public function set selectionActiveIndex(value:int):void
    {
        if (value == _selectionActiveIndex)
            return;
        
        _selectionActiveIndex = value;
        selectionActiveIndexChanged = true;

        invalidateProperties();
    }

    //----------------------------------
    //  selectionAnchorIndex
    //----------------------------------
    
    /**
     *  @private
     */
    private var _selectionAnchorIndex:int = -1;

    /**
     *  @private
     */
    private var selectionAnchorIndexChanged:Boolean = false;
    
    /**
     *  The anchor index of the selection.
     *  The "anchor" point is the stable end of the selection
     *  when the selection is extended.
     *  The anchor index may be either the start
     *  or the end of the selection.
     *
     *  @default -1
     */
    public function get selectionAnchorIndex():int
    {
        return _selectionAnchorIndex;
    }

    /**
     *  @private
     */
    public function set selectionAnchorIndex(value:int):void
    {
        if (value == _selectionAnchorIndex)
            return;
        
        _selectionAnchorIndex = value;
        selectionAnchorIndexChanged = true;

        invalidateProperties();
    }

    //----------------------------------
    //  text
    //----------------------------------

    /**
     *  @private
     */
    private var _text:String = "";

    /**
     *  @private
     */
    private var textChanged:Boolean = false;

    /**
     *  The text String displayed by this TextView..
     */
    public function get text():String 
    {
        if (textInvalid)
        {
            _text = TextUtil.extractText(textFlow);
            textInvalid = false;
        }

        return _text;
    }
    
    /**
     *  @private
     */
    public function set text(value:String):void
    {
        if (value == _text)
            return;

        _text = value;
        textChanged = true;
        
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }
    
    //----------------------------------
    //  verticalScrollPosition
    //----------------------------------

    /**
     *  @private
     */
    private var _verticalScrollPosition:Number = 0;

    /**
     *  @private
     */
    private var verticalScrollPositionChanged:Boolean = false;
 
    /**
     *  Documentation is not currently available.
     */
    public function get verticalScrollPosition():Number
    {
        return _verticalScrollPosition;
    }

    /**
     *  @private
     */
    public function set verticalScrollPosition(value:Number):void
    {
        if (value == _verticalScrollPosition)
            return;

        _verticalScrollPosition = value;
        verticalScrollPositionChanged = true;

        invalidateProperties();
    }
        
    //----------------------------------
    //  widthInChars
    //----------------------------------

    /**
     *  @private
     */
    private var _widthInChars:int = 20;

    /**
     *  @private
     */
    private var widthInCharsChanged:Boolean = true;
        
    /**
     *  The default width for the TextInput, measured in characters.
     *  The width of the "0" character is used for the calculation,
     *  since in most fonts the digits all have the same width.
     *  So if you set this property to 5, it will be wide enough
     *  to let the user enter 5 digits.
     *
     *  @default
     */
    public function get widthInChars():int 
    {
        return _widthInChars;
    }
    
    /**
     *  @private
     */
    public function set widthInChars(value:int):void
    {
        if (value == _widthInChars)
            return;

        _widthInChars = value;
        widthInCharsChanged = true;
        
        invalidateSize();
        invalidateDisplayList();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods: UIComponent
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function commitProperties():void 
    {
        super.commitProperties();

        // Recalculate the ascent, descent, and charWidth
        // if these might have changed.
        if (fontMetricsInvalid)
        {
            calculateFontMetrics();

            fontMetricsInvalid = false;
        }
        
        // Regenerate TextLines if necessary.
        if (textChanged || contentChanged || textAttributeChanged)
        {
            // Eliminate detritus from the previous TextFlow.
            if (textFlow)
            {
                var controller:IContainerController = textFlow.controller;
                if (controller)
                {
                    controller.clearAllSelectionShapes();
                    controller.clearCompositionResults();
                    controller.rootElement = null;
                }
                textFlow.container = null;
            }

            // Create a new TextFlow for the current text.
            _content = textFlow = createTextFlow();
                        
            // Tell it where to create its TextLines.
            textFlow.container = this;
            
            // Give it an EditManager to make it editable.
            textFlow.selectionManager = new TextViewEditManager(); 
            
            // Listen to events from the TextFlow and its EditManager.
            addListeners(textFlow);
            
            textChanged = false;
            contentChanged = false;
            textAttributeChanged = false;
        }

        // Apply the specified selection indices to the TextFlow.
        if (selectionAnchorIndexChanged || selectionActiveIndexChanged)
        {
            textFlow.selectionManager.setActiveSelection(
                _selectionAnchorIndex, _selectionActiveIndex);
            
            selectionAnchorIndexChanged = false;
            selectionActiveIndexChanged = false;
        }

        if (horizontalScrollPositionChanged)
        {
            textFlow.controller.horizontalScrollPosition =
                _horizontalScrollPosition;
            horizontalScrollPositionChanged = false;
        }

        if (verticalScrollPositionChanged)
        {
            textFlow.controller.verticalScrollPosition =
                _verticalScrollPosition;
            verticalScrollPositionChanged = false;
        }
    }

    /**
     *  @private
     */
    override protected function measure():void 
    {
        super.measure();

        measuredWidth = paddingLeft + widthInChars * charWidth + paddingRight;
        
        measuredHeight = paddingTop +
                         heightInLines * (ascent + descent) +
                         paddingBottom;

        //trace("measure", measuredWidth, measuredHeight);
    }

    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void 
    {
        //trace("updateDisplayList", unscaledWidth, unscaledHeight);

        super.updateDisplayList(unscaledWidth, unscaledHeight);

        /*
        var g:Graphics = graphics;
        g.clear();
        g.lineStyle(NaN);
        g.beginFill(0xEEEEEE, 1.0);
        g.drawRect(0, 0, unscaledWidth, unscaledHeight);
        g.endFill();
        */
        
        // Tell the TextFlow to generate TextLines within the
        // rectangle (0, 0, unscaledWidth, unscaledHeight).
        textFlow.controller.updateComposeSize(unscaledWidth, unscaledHeight);
        textFlow.controller.updateDisplay();
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  This method is called when anything affecting the
     *  default font, size, weight, etc. changes.
     *  It calculates the 'ascent', 'descent', and 'charWidth'
     *  instance variables, which are used in measure().
     */
    private function calculateFontMetrics():void
    {
        var fontDescription:FontDescription = new FontDescription();
        fontDescription.fontName = fontFamily;
        
        var elementFormat:ElementFormat = new ElementFormat();
        elementFormat.fontDescription = fontDescription;
        elementFormat.fontSize = fontSize;
        
        var textElement:TextElement = new TextElement();
        textElement.elementFormat = elementFormat;
        textElement.text = "0";
        
        var textBlock:TextBlock = new TextBlock();
        textBlock.content = textElement;
        
        var textLine:TextLine = textBlock.createTextLine(null, 1000);
        
        ascent = textLine.ascent;
        descent = textLine.descent;
        charWidth = textLine.textWidth;
    }
    
	/**
	 *  @private
	 */
	private function createEmptyTextFlow():TextFlow
	{
		var textFlow:TextFlow = new TextFlow();
		var p:ParagraphElement = new ParagraphElement();
		var span:SpanElement = new SpanElement();
		textFlow.replaceElements(0, 0, p);
		p.replaceElements(0, 0, span);
		return textFlow;
	}
	
	/**
	 *  @private
	 */
	private function importMarkup(markup:String):TextFlow
	{
		markup =
			'<TextGraphic xmlns="http://ns.adobe.com/fxg/2008">' +
			    '<content>' + markup + '</content>' +
			'</TextGraphic>';
		
		return TextFilter.importFromString(markup, TextFilter.FXG_FORMAT);
	}

	/**
	 *  @private
	 */
	private function createTextFlow():TextFlow
	{
		if (contentChanged)
		{
            if (content is TextFlow)
            {
                textFlow = TextFlow(content);
            }
            else if (content is Array)
            {
                textFlow = createEmptyTextFlow();
                textFlow.mxmlChildren = content as Array;
            }
            else if (content is FlowElement)
            {
                textFlow = createEmptyTextFlow();
                textFlow.mxmlChildren = [ content ];
            }
			else if (content is String)
			{
				textFlow = importMarkup(String(content));
			}
			else if (content == null)
			{
				textFlow = createEmptyTextFlow();
			}
            else
            {
                throw new Error("invalid content");
            }
		}
		else if (textChanged)
		{
			if (text != null && text != "")
			{
				textFlow = TextFilter.importFromString(text, TextFilter.PLAIN_TEXT_FORMAT);
			}
			else
			{
				textFlow = createEmptyTextFlow();
			}
		}

		contentChanged = false;
		textChanged = false;

        var containerFormat:IContainerFormat =
            textFlow.containerFormat;
        var paragraphFormat:IParagraphFormat =
            textFlow.paragraphFormat;
        var characterFormat:ICharacterFormat =
            textFlow.characterFormat;
        
        if (!containerFormat || containerFormat.blockProgression == null)
            textFlow.blockProgression = blockProgression;
        if (!characterFormat || characterFormat.color == null)
            textFlow.color = color;
        if (!paragraphFormat || paragraphFormat.direction == null)
            textFlow.direction = direction;
		if (!characterFormat || characterFormat.fontFamily == null)
            textFlow.fontFamily = fontFamily;
		if (!characterFormat || characterFormat.fontSize == null)
            textFlow.fontSize = fontSize;
		if (!characterFormat || characterFormat.fontStyle == null)
		    textFlow.fontStyle = fontStyle;
		if (!characterFormat || characterFormat.fontWeight == null)
		    textFlow.fontWeight = fontWeight;
		if (!characterFormat || characterFormat.kerning == null)
		    textFlow.kerning = kerning;
		if (!characterFormat || characterFormat.lineHeight == null)
		    textFlow.lineHeight = lineHeight;
		if (!containerFormat || containerFormat.lineBreak == null)
		    textFlow.lineBreak = lineBreak;
		if (!characterFormat || characterFormat.lineThrough == null)
		    textFlow.lineThrough = lineThrough;
        if (!paragraphFormat || paragraphFormat.marginBottom == null)
		    textFlow.marginBottom = marginBottom;
        if (!paragraphFormat || paragraphFormat.marginLeft == null)
		    textFlow.marginLeft = marginLeft;
        if (!paragraphFormat || paragraphFormat.marginRight == null)
		    textFlow.marginRight = marginRight;
        if (!paragraphFormat || paragraphFormat.marginTop == null)
		    textFlow.marginTop = marginTop;
        if (!containerFormat || containerFormat.paddingBottom == null)
		    textFlow.paddingBottom = paddingBottom;
        if (!containerFormat || containerFormat.paddingLeft == null)
		    textFlow.paddingLeft = paddingLeft;
        if (!containerFormat || containerFormat.paddingRight == null)
		    textFlow.paddingRight = paddingRight;
        if (!containerFormat || containerFormat.paddingTop == null)
		    textFlow.paddingTop = paddingTop;
        if (!paragraphFormat || paragraphFormat.textAlign == null)
		    textFlow.textAlign = textAlign;
        if (!paragraphFormat || paragraphFormat.textAlignLast == null)
		    textFlow.textAlignLast = textAlignLast;
		if (!characterFormat || characterFormat.textAlpha == null)
		    textFlow.textAlpha = textAlpha;
		if (!characterFormat || characterFormat.textDecoration == null)
		    textFlow.textDecoration = textDecoration;
        if (!paragraphFormat || paragraphFormat.textIndent == null)
		    textFlow.textIndent = textIndent;
		if (!characterFormat || characterFormat.trackingRight == null)
		    textFlow.trackingRight = tracking; // what about trackingLeft?
        if (!containerFormat || containerFormat.verticalAlign == null)
		    textFlow.verticalAlign = verticalAlign;
		if (!characterFormat || characterFormat.whitespaceCollapse == null)
		    textFlow.whitespaceCollapse = whiteSpaceCollapse; // different case

		return textFlow;
	}

    /**
     *  @private
     */
    private function addListeners(textFlow:TextFlow):void
    {
        textFlow.addEventListener(ComposeDoneEvent.COMPOSE_DONE,
                                  textFlow_composeDoneHandler);
        
        textFlow.selectionManager.addEventListener(
            SelectionChangedEvent.SELECTION_CHANGED,
            editManager_selectionChangeHandler);

        textFlow.selectionManager.addEventListener(
            OperationEvent.OPERATION_BEGIN, editManager_operationBeginHandler);

        textFlow.selectionManager.addEventListener(
            OperationEvent.OPERATION_END, editManager_operationEndHandler);
    }

    /**
     *  Sets the selection range.
     */
    public function setSelection(anchorIndex:int = 0,
                                 activeIndex:int = int.MAX_VALUE):void
    {
        textFlow.selectionManager.setActiveSelection(anchorIndex, activeIndex,
                                                     true);
    }
    
    /**
     *  Inserts the specified text as if you had typed it.
     *  If a range was selected, the new text replaces the selected text;
     *  if there was an insertion point, the new text is inserted there.
     *  An insertion point is then set after the new text.
     */
    public function insertText(text:String):void
    {
        EditManager(textFlow.selectionManager).insertText(text);
    }
    
    /**
     *  Appends the specified text to the end of the TextView,
     *  as if you had clicked at the end and typed it.
     *  When TextView supports vertical scrolling,
     *  it will scroll to ensure that the last line
     *  of the inserted text is visible.
     */
    public function appendText(text:String):void
    {
        textFlow.selectionManager.setActiveSelection(int.MAX_VALUE, int.MAX_VALUE);
        EditManager(textFlow.selectionManager).insertText(text);
    }

    /**
     *  Returns a String containing markup describing
     *  this TextView's TextFlow.
     *  This markup String has the appropriate format
     *  for setting the <code>content</code> property.
     */
    public function export():XML
    {
        return TextFilter.export(textFlow, TextFilter.TCAL_FORMAT).children()[0];
    }

    /**
     *  Returns an Object containing name/value pairs of text attributes
     *  for the specified range.
     *  If an attribute is not consistently set across the entire range,
     *  its value will be null.
     *  You can specify an Array containing names of the attributes
     *  that you want returned; if you don't, all attributes will be returned.
     *  If you don't specify a range, the selected range is used.
     *  For example, calling
     *  <code>getAttributes()</code>
     *  might return <code>({ fontSize: 12, color: null })</code>
     *  if the selection is uniformly 12-point but has multiple colors.
     *  The supported attributes are those in the
     *  ICharacterAttributes and IParagraphAttributes interfaces.
     */
    public function getAttributes(names:Array = null):Object
    {
        var selectionManager:ISelectionManager = textFlow.selectionManager;
                
        var p:String;
        var kind:String;
        
        var needContainerFormat:Boolean = false;
        var needParagraphFormat:Boolean = false;
        var needCharacterFormat:Boolean = false;

        if (!names)
        {
            names = TextUtil.ALL_FORMAT_NAMES;
            
            needContainerFormat = true;
            needParagraphFormat = true;
            needCharacterFormat = true;
        }
        else
        {
            for each (p in names)
            {
                kind = TextUtil.FORMAT_MAP[p];

                if (kind == TextUtil.CONTAINER)
                    needContainerFormat = true;
                else if (kind == TextUtil.PARAGRAPH)
                    needParagraphFormat = true;
                else if (kind == TextUtil.CHARACTER)
                    needCharacterFormat = true;
            }
        }
        
        var containerFormat:IContainerFormat;
        var paragraphFormat:IParagraphFormat;
        var characterFormat:ICharacterFormat;
        
        if (needContainerFormat)
        {
            containerFormat =
                selectionManager.getCommonContainerFormat();
        }
        
        if (needParagraphFormat)
        {
            paragraphFormat =
                selectionManager.getCommonParagraphFormat();
        }

        if (needCharacterFormat)
        {
            characterFormat =
                selectionManager.getCommonCharacterFormat();
        }

        var format:Object = {};
        
        for each (p in names)
        {
            kind = TextUtil.FORMAT_MAP[p];
            
            if (kind == TextUtil.CONTAINER)
                format[p] = containerFormat[p];
            else if (kind == TextUtil.PARAGRAPH)
                format[p] = paragraphFormat[p];
            else if (kind == TextUtil.CHARACTER)
                format[p] = characterFormat[p];
        }
        
        return format;
    }

    /**
     *  Applies a set of name/value pairs of text attributes
     *  to the specified range.
     *  A value of null does not get applied.
     *  If you don't specify a range, the selected range is used.
     *  For example, calling
     *  <code>setAttributes({ fontSize: 12, color: 0xFF0000 })</code>
     *  will set the fontSize and color of the selection.
     *  The supported attributes are those in the
     *  ICharacterFormat and IParagraphFormat interfaces.
     */
    public function setAttributes(attributes:Object):void
    {
        var containerFormat:ContainerFormat;
        var paragraphFormat:ParagraphFormat;
        var characterFormat:CharacterFormat;
        
        for (var p:String in attributes)
        {
            var kind:String = TextUtil.FORMAT_MAP[p];
            
            if (kind == TextUtil.CONTAINER)
            {
                if (!containerFormat)
                   containerFormat =  new ContainerFormat();
                containerFormat[p] = attributes[p];
            }
            else if (kind == TextUtil.PARAGRAPH)
            {
                if (!paragraphFormat)
                   paragraphFormat =  new ParagraphFormat();
                paragraphFormat[p] = attributes[p];
            }
            else if (kind == TextUtil.CHARACTER)
            {
                if (!characterFormat)
                   characterFormat =  new CharacterFormat();
                characterFormat[p] = attributes[p];
            }
        }
        
        var editManager:TextViewEditManager =
            TextViewEditManager(textFlow.selectionManager);
        
        if (containerFormat)
        {
            editManager.execute(new ContainerStyleChangeOperation(
                editManager, containerFormat));
        }

        if (paragraphFormat)
        {
            editManager.execute(new ParagraphStyleChangeOperation(
                editManager, paragraphFormat));
        }

        if (characterFormat)
        {
            editManager.execute(new StyleChangeOperation(
                editManager, characterFormat));
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private function textFlow_composeDoneHandler(event:ComposeDoneEvent):void
    {
        var newContentWidth:Number =
            textFlow.controller.maxHorizontalScrollPosition;
        var newContentHeight:Number =
            textFlow.controller.maxVerticalScrollPosition;
        
        if (newContentWidth != _contentWidth ||
            newContentHeight != _contentHeight)
        {
            _contentWidth = newContentWidth;
            _contentHeight = newContentHeight;
        
            dispatchEvent(new Event("contentSizeChanged"));
        }
    }
    
    /**
     *  @private
     *  Called when the EditManager dispatches a 'selectionChange' event.
     */
    private function editManager_selectionChangeHandler(event:SelectionChangedEvent):void
    {
        _selectionAnchorIndex = textFlow.selectionManager.selectionAnchorIndex; // event.target isn't useful
        _selectionActiveIndex = textFlow.selectionManager.selectionActiveIndex;
        
        dispatchEvent(new Event("selectionChange"));
    }
    
    /**
     *  @private
     *  Called when the EditManager dispatches an 'operationEnd' event
     *  before an editing operation.
     */
    private function editManager_operationBeginHandler(
                                    event:OperationEvent):void
    {
        //trace("operationBegin");
        
        var op:FlowOperation = event.operation;

        // If the user presses the Enter key in a single-line TextView,
        // we cancel the paragraph-splitting operation and instead
        // simply dispatch an 'enter' event.
        if (op is SplitParOperation && !multiline)
        {
            event.preventDefault();
            dispatchEvent(new Event("enter"));
        }
        
        // Otherwise, we dispatch a 'changing' event from the TextView
        // as notification that an editing operation is about to occur.
        else
        {
            var newEvent:TextOperationEvent =
                new TextOperationEvent(TextOperationEvent.CHANGING);
            newEvent.operation = op;
            dispatchEvent(newEvent);
            
            // If the event dispatched from this TextView is canceled,
            // cancel the one from the EditManager, which will prevent
            // the editing operation from being processed.
            if (newEvent.isDefaultPrevented())
                event.preventDefault();
        }
    }
    
    /**
     *  @private
     *  Called when the EditManager dispatches an 'operationEnd' event
     *  after an editing operation.
     */
    private function editManager_operationEndHandler(event:OperationEvent):void
    {
        //trace("operationEnd");

        // Since the text may have changed, set a flag which will
        // cause the 'text' getter to call extractText() to extract
        // the text by walking the TextFlow.
        textInvalid = true;

        // Dispatch a 'change' event from the TextView
        // as notification that an editing operation has occurred.
        var newEvent:TextOperationEvent =
            new TextOperationEvent(TextOperationEvent.CHANGE);
        newEvent.operation = event.operation;
        dispatchEvent(newEvent);
    }
}

}

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: TextViewEditManager
//
////////////////////////////////////////////////////////////////////////////////

import text.edit.EditManager;
import text.edit.FlowOperation;

class TextViewEditManager extends EditManager
{
    public function TextViewEditManager()
    {
        super();
    }

    public function execute(flowOperation:FlowOperation):void
    {
        doop(flowOperation);
    }
}
