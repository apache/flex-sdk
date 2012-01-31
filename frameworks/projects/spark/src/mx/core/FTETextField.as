////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008-2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
//////////////////////////////////////////////////////////////////////////////////
//
//ADOBE SYSTEMS INCORPORATED
//Copyright 2009 Adobe Systems Incorporated
//All Rights Reserved.
//
//in accordance with the terms of the license agreement accompanying it.
//
package flashx.textLayout.controls
{

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.text.AntiAliasType;
import flash.text.GridFitType;
import flash.text.StyleSheet;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.text.TextLineMetrics;
import flash.text.engine.FontPosture;
import flash.text.engine.FontWeight;
import flash.text.engine.Kerning;
import flash.text.engine.TextLine;

import flashx.textLayout.conversion.ITextImporter;
import flashx.textLayout.conversion.TextConverter;
import flashx.textLayout.debug.assert;
import flashx.textLayout.compose.ITextLineCreator;
import flashx.textLayout.factory.StringTextLineFactory;
import flashx.textLayout.formats.LineBreak;
import flashx.textLayout.formats.TextDecoration;
import flashx.textLayout.formats.TextLayoutFormatValueHolder;

/**
 *  TLFTextField is a Sprite which displays text by using the new
 *  Text Layout Framework to implement the old TextField API.
 * @playerversion Flash 10
 * @playerversion AIR 1.5
 * @langversion 3.0
 */
public class TLFTextField extends Sprite
{
    // Current slot count: 32
    // (1 for every type except 2 for Number)

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Masks for bits inside the 'flags' var
	 *  which store the state of Boolean TextField properties.
	 */
	private static const FLAG_ALWAYS_SHOW_SELECTION:uint = 1 << 0;
	private static const FLAG_BACKGROUND:uint = 1 << 1;
	private static const FLAG_BORDER:uint = 1 << 2;
	private static const FLAG_CONDENSE_WHITE:uint = 1 << 3;
	private static const FLAG_DISPLAY_AS_PASSWORD:uint = 1 << 4;
	private static const FLAG_EMBED_FONTS:uint = 1 << 5;
	private static const FLAG_MOUSE_WHEEL_ENABLED:uint = 1 << 6;
	private static const FLAG_MULTILINE:uint = 1 << 7;
	private static const FLAG_SELECTABLE:uint = 1 << 8;
	private static const FLAG_WORD_WRAP:uint = 1 << 9;
	private static const FLAG_USE_RICH_TEXT_CLIPBOARD:uint = 1 << 10;
	
	/**
	 *  @private
	 *  Masks for bits inside the 'flags' var
	 *  which control what work validateNow() needs to do.
	 */
	private static const FLAG_GRAPHICS_INVALID:uint = 1 << 11;
	private static const FLAG_TEXT_LINES_INVALID:uint = 1 << 12;
	private static const FLAG_SCROLL_POSITION_INVALID:uint = 1 << 13;
	private static const FLAG_SELECTION_INVALID:uint = 1 << 14;
	private static const FLAG_DEFAULT_TEXT_FORMAT_CHANGED:uint = 1 << 15;
	private static const FLAG_HTML_TEXT_CHANGED:uint = 1 << 16;
	private static const FLAG_TEXT_CHANGED:uint = 1 << 17;
	private static const FLAG_WORD_WRAP_CHANGED:uint = 1 << 18;
	
	/**
	 * @private
	 * Masks for bits inside the 'flags' var
	 * tracking misc boolean variables.
	 */
	private static const FLAG_SCROLL_RECT_IS_SET:uint = 1 << 19;
	private static const FLAG_VALIDATE_IN_PROGRESS:uint = 1 << 20;
	
	/**
	 *  @private
	 */
	private static const ALL_INVALIDATION_FLAGS:uint =
		FLAG_GRAPHICS_INVALID |
		FLAG_TEXT_LINES_INVALID |
		FLAG_SCROLL_POSITION_INVALID |
		FLAG_SELECTION_INVALID |
		FLAG_DEFAULT_TEXT_FORMAT_CHANGED |
		FLAG_HTML_TEXT_CHANGED |
		FLAG_TEXT_CHANGED |
		FLAG_WORD_WRAP_CHANGED;
		
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private static var textImporter:ITextImporter =
    	TextConverter.getImporter(TextConverter.PLAIN_TEXT_FORMAT);
    	
    /**
     *  @private
     */
    private static var htmlTextImporter:ITextImporter =
    	TextConverter.getImporter(TextConverter.TEXT_LAYOUT_FORMAT);
    	// TLF needs TEXT_FIELD_HTML_FORMAT
    	
    private static var factory:StringTextLineFactory = new StringTextLineFactory();
    	    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
	/**
	 *  Constructor.
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 */
	public function TLFTextField()
	{
		super();
		addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
	}
	
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
	/**
	 *  @private
	 *  Apps are likely to create thousands of instances of TLFTextField,
	 *  so in order to minimize memory usage we store flags as 1 bit
	 *  inside a uint instead of making each one a 4-byte Boolean var.
	 *  
	 *  Note: FLAGAULT_TEXT_FORMAT_CHANGED and FLAG_WORD_WRAP_CHANGED
	 *  are initialized to true so that the host formats are set properly
	 *  on first validation.
     */
 	private var flags:uint = FLAG_MOUSE_WHEEL_ENABLED |
							 FLAG_SELECTABLE |
							 FLAG_DEFAULT_TEXT_FORMAT_CHANGED |
							 FLAG_WORD_WRAP_CHANGED;
	    
    /**
     *  @private
     */
    private var hostContainerFormat:TextLayoutFormatValueHolder = new TextLayoutFormatValueHolder();
    private var hostParagraphFormat:TextLayoutFormatValueHolder = new TextLayoutFormatValueHolder();
    private var hostCharacterFormat:TextLayoutFormatValueHolder = new TextLayoutFormatValueHolder();
    
    /**
    * @private
    */
    private var _textLineCreator:ITextLineCreator;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties: DisplayObject
    //
    //--------------------------------------------------------------------------
    
    
    //----------------------------------
    //  height
    //----------------------------------

    /**
     *  @private
     */
	private var _height:Number = 100;

    /**
     *  @private
     */
    override public function get height():Number
    {
    	// If we're autosizing, _height may be invalid.
    	// For example, the 'text' may have been set
    	// but the TextLines for that text haven't
    	// been created yet.
    	if (autoSize != TextFieldAutoSize.NONE)
    		validateNow();
    	
    	return _height;
    }
    
    /**
     *  @private
     */
    override public function set height(value:Number):void
    {
    	// TODO: What does TextField do if height is set to
    	// NaN, or Infinity, a negative value, or a very large value?
    	
    	if (value == _height)
    		return;
    		
    	_height = value;
    	
   		// The border and background need to be redrawn,
    	// and the TextLines may need to be recreated.
    	// TODO: Figure out when the TextLines really are invalid.
    	setFlag(FLAG_GRAPHICS_INVALID | FLAG_TEXT_LINES_INVALID);
    	
    	invalidate();
    	
    	// Side effects:
    	// maxScrollV
    	// scrollV/bottomScrollV?
    }
    
    //----------------------------------
    //  width
    //----------------------------------

    /**
     *  @private
     */
	private var _width:Number = 100;

    /**
     *  @private
     */
    override public function get width():Number
    {
    	// If we're autosizing, _width may be invalid.
    	// For example, the 'text' may have been set
    	// but the TextLines for that text haven't
    	// been created yet.
	   	if (autoSize != TextFieldAutoSize.NONE)
    		validateNow();
    	
    	return _width;
    }
    
    /**
     *  @private
     */
    override public function set width(value:Number):void
    {
    	// TODO: What does TextField do if height is set to
    	// NaN, or Infinity, a negative value, or a very large value?
    	
    	if (value == _width)
    		return;
    		
    	_width = value;
    	
   		// The border and background need to be redrawn,
    	// and the TextLines may need to be recreated.
    	// TODO: Figure out when the TextLines really are invalid.
    	setFlag(FLAG_GRAPHICS_INVALID |	FLAG_TEXT_LINES_INVALID);
    	
    	invalidate();
    	
    	// Side effects:
    	// height
    	// textWidth/textHeight
    	// numLines
    	// maxScrollH/maxScrollV
    	// scrollH/scrollV/bottomScrollV?
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties: TextField
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  alwaysShowSelection
    //----------------------------------
    
    /**
     *  @copy flash.text.TextField#alwaysShowSelection
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get alwaysShowSelection():Boolean
    {
    	return testFlag(FLAG_ALWAYS_SHOW_SELECTION);
    }
    public function set alwaysShowSelection(value:Boolean):void
    {
    	if (value == alwaysShowSelection)
    		return;
    	
    	setFlagToValue(FLAG_ALWAYS_SHOW_SELECTION,value);
    	
    	// The selection may need to be redrawn.
    	setFlag(FLAG_SELECTION_INVALID);
    	
    	invalidate();
    	
    	// Side effects:
    	// selectionBeginIndex/selectionEndIndex/caretIndex?
    }

    //----------------------------------
    //  antiAliasType
    //----------------------------------
    
    /**
     *  @private
     */
    private var _antiAliasType:String = AntiAliasType.NORMAL;
    
    /**
     *  @copy flash.text.TextField#antiAliasType
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get antiAliasType():String
    {
     	return _antiAliasType;
    }
    
    /**
     *  @private
     */
    public function set antiAliasType(value:String):void
    {
    	// TextField apparently treats invalid values as "normal".
    	if (value != AntiAliasType.NORMAL &&
    	    value != AntiAliasType.ADVANCED)
    	{
    		value = AntiAliasType.NORMAL;
    	}
    	
    	_antiAliasType = value;
    	
		// Setting this property does not affect
		// the appearance of TLFTextField.
		// Setting it to "advanced" means that TextField
		// should use its Saffron renderer
		// but FTE doesn't have a Saffron renderer.
		
		// Side effects:
		// none
    }

    //----------------------------------
    //  autoSize
    //----------------------------------
    
    /**
     *  @private
     */
    private var _autoSize:String = TextFieldAutoSize.NONE;
    
    /**
     *  @copy flash.text.TextField#autoSize
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get autoSize():String
    {
    	return _autoSize;
    }
    
    /**
     *  @private
     */
    public function set autoSize(value:String):void
    {
    	// TextField throws when invalid values are set.
    	if (value != TextFieldAutoSize.NONE &&
    		value != TextFieldAutoSize.LEFT &&
    		value != TextFieldAutoSize.CENTER &&
    		value != TextFieldAutoSize.RIGHT)
    	{
    		throw new ArgumentError("Parameter autoSize must be one of the accepted values.");
    	}
    	
    	if (value == autoSize)
    		return;
    		
    	_autoSize = value;
    	
    	if ( _autoSize != TextFieldAutoSize.NONE )
    		_maxScrollH = 0;
    	
    	// The border and background may need to be redrawn,
    	// and the TextLines may need to be recreated.
    	setFlag(FLAG_GRAPHICS_INVALID |	FLAG_TEXT_LINES_INVALID);
    	
     	invalidate();
     	
     	// Side effects:
    	// x
    	// width/height
    	// textWidth/textHeight
    	// numLines
    	// maxScrollH/maxScrollV
    	// scrollH/scrollV/bottomScrollV
    }

    //----------------------------------
    //  background
    //----------------------------------
    
    /**
     *  @copy flash.text.TextField#background
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get background():Boolean
    {
    	return testFlag(FLAG_BACKGROUND);
    }
    
    /**
     *  @private
     */
    public function set background(value:Boolean):void
    {
    	if (value == background)
    		return;
    	setFlagToValue(FLAG_BACKGROUND,value);
    	
    	// The border and background need to be redrawn.
    	setFlag(FLAG_GRAPHICS_INVALID);
    	
    	invalidate();
    	
    	// Side effects:
    	// none
    }

    //----------------------------------
    //  backgroundColor
    //----------------------------------
    
    /**
     *  @private
     */
    private var _backgroundColor:uint = 0xFFFFFF;
    
    /**
     *  @copy flash.text.TextField#backgroundColor
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get backgroundColor():uint
    {
    	return _backgroundColor;
    }
    
    /**
     *  @private
     */
    public function set backgroundColor(value:uint):void
    {
    	if (value == _backgroundColor)
    		return;
    		   			
    	_backgroundColor = value;
    	
    	// The border and background need to be redrawn.
    	setFlag(FLAG_GRAPHICS_INVALID);
    	
    	invalidate();
    	
    	// Side effects:
    	// none
    }

    //----------------------------------
    //  border
    //----------------------------------
    
    /**
     *  @copy flash.text.TextField#border
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get border():Boolean
    {
    	return testFlag(FLAG_BORDER);
    }
    
    /**
     *  @private
     */
    public function set border(value:Boolean):void
    {
    	if (value == border)
    		return;
    	
	    setFlagToValue(FLAG_BORDER,value);
    	
    	// The border and background need to be redrawn.
    	setFlag(FLAG_GRAPHICS_INVALID);
    	
    	invalidate();
    	
    	// Side effects:
    	// none
    }

    //----------------------------------
    //  borderColor
    //----------------------------------
    
    /**
     *  @private
     */
    private var _borderColor:uint = 0x000000;
    
    /**
     *  @copy flash.text.TextField#borderColor
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get borderColor():uint
    {
    	return _borderColor;
    }
    
    /**
     *  @private
     */
    public function set borderColor(value:uint):void
    {
    	if (value == _borderColor)
    		return;
    		
     	_borderColor = value;

    	// The border and background need to be redrawn.
    	setFlag(FLAG_GRAPHICS_INVALID);
    	
    	invalidate();
    	
    	// Side effects:
    	// none
    }

    //----------------------------------
    //  bottomScrollV
    //----------------------------------
    
    /**
     *  @private
     */
    private var _bottomScrollV:int = 1;
    
    /**
     *  @copy flash.text.TextField#bottomScrollV
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get bottomScrollV():int
    {
     	validateNow();
    	
    	// TODO: Compute this properly.
    	return _bottomScrollV;
    }

    //----------------------------------
    //  caretIndex
    //----------------------------------
    
    /**
     *  @copy flash.text.TextField#caretIndex
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get caretIndex():int
    {
    	// TODO: Implement this.
    	return 0;
    }
    	
    //----------------------------------
    //  condenseWhite
    //----------------------------------
    
    /**
     *  @copy flash.text.TextField#condenseWhite
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get condenseWhite():Boolean
    {
    	return testFlag(FLAG_CONDENSE_WHITE);
    }
    
    /**
     *  @private
     */
    public function set condenseWhite(value:Boolean):void
    {
    	setFlagToValue(FLAG_CONDENSE_WHITE, value);
    	
    	// Note: There is nothing else to do immediately;
    	// the new value doesn't have any effect
    	// until 'htmlText' is set later.
    	
    	// Side effects:
    	// none
    }

    //----------------------------------
    //  defaultTextFormat
    //----------------------------------
    static private function createDefaultTextFormat( ): TextFormat
    {
      	// TODO: is font value platform-dependent???
	  	var ret:TextFormat = new TextFormat("Times New Roman", 12, 0x000000, false, false, false, "", "", TextFormatAlign.LEFT, 0, 0, 0, 0);
		ret.blockIndent = 0;
		ret.bullet = false;
		ret.kerning = false;
		ret.leading = 0;
		ret.letterSpacing = 0;
		ret.tabStops = new Array(); // does not work. Flash apparently detects when an empty array is assigned to tabStops and assigns null instead.
		return ret;
    }
  
    static private function createTextFormatCopy( obj:TextFormat ): TextFormat
    {
    	var ret:TextFormat = new TextFormat(obj.font,obj.size,obj.color,obj.bold,obj.italic,obj.underline,obj.url,obj.target,obj.align,obj.leftMargin,obj.rightMargin,obj.indent);
		ret.blockIndent = obj.blockIndent;
		ret.bullet = obj.bullet;
		ret.kerning = obj.kerning;
		ret.leading = obj.leading;
		ret.letterSpacing = obj.letterSpacing;
		ret.tabStops = obj.tabStops;
		return ret;
    } 
    
    /**
     *  @private
     */
    private var _defaultTextFormat:TextFormat = createDefaultTextFormat( );

    /**
     *  @copy flash.text.TextField#defaultTextFormat
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get defaultTextFormat():TextFormat
    {
    	return _defaultTextFormat;    	
    }

    /**
     *  @private
     */
    public function set defaultTextFormat(value:TextFormat):void
    {
    	// TextField throws if a null value is set.
    	if (!value)
    		throw new TypeError("Parameter format must be non-null.");
    	
    	if (value == _defaultTextFormat)
    		return;
    		
    	_defaultTextFormat = createTextFormatCopy( value );
    	
    	setFlag(FLAG_DEFAULT_TEXT_FORMAT_CHANGED);
 
    	invalidate();
    	
    	// Note: Setting this does NOT cause already-rendered text
    	// to change its format.
    	// If establishes the formatting for text set or added later.
    	
    	// Side effects:
    	// none
    }

    //----------------------------------
    //  displayAsPassword
    //----------------------------------
    
    /**
     *  @copy flash.text.TextField#displayAsPassword
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get displayAsPassword():Boolean
    {
     	return testFlag(FLAG_DISPLAY_AS_PASSWORD);
    }
    
    /**
     *  @private
     */
    public function set displayAsPassword(value:Boolean):void
    {
     	if (value == displayAsPassword)
    		return;
    		
    	setFlagToValue(FLAG_DISPLAY_AS_PASSWORD, value);
    	
    	// The border and background may need to be redrawn
    	// (because the size may have changed)
    	// and the TextLines need to be recreated.
		setFlag(FLAG_GRAPHICS_INVALID | FLAG_TEXT_LINES_INVALID);

    	invalidate();
    	
    	// Side effects:
    	// x
    	// width/height
    	// textWidth/textHeight
    	// numLines
    	// maxScrollH/maxScrollV
    	// scrollH/scrollV/bottomScrollV?
    }

    //----------------------------------
    //  embedFonts
    //----------------------------------
    
    /**
     *  @copy flash.text.TextField#embedFonts
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get embedFonts():Boolean
    {
    	return testFlag(FLAG_EMBED_FONTS);
    }
    
    /**
     *  @private
     */
    public function set embedFonts(value:Boolean):void
    {
    	if (value == embedFonts)
    		return;
    		
    	setFlagToValue(FLAG_EMBED_FONTS, value);
    	
   		// The border and background may need to be redrawn
    	// (because the size may have changed)
    	// and the TextLines need to be recreated.
		setFlag(FLAG_GRAPHICS_INVALID |	FLAG_TEXT_LINES_INVALID);

    	invalidate();
    	
    	// Side effects:
    	// none
    }

    //----------------------------------
    //  gridFitType
    //----------------------------------
    
    /**
     *  @private
     */
    private var _gridFitType:String = GridFitType.PIXEL;
    
    /**
     *  @copy flash.text.TextField#gridFitType
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get gridFitType():String
    {
    	return _gridFitType;
    }
    
    /**
     *  @private
     */
    public function set gridFitType(value:String):void
    {
    	// TextField apparently treats invalid values as "none".
    	if (value != GridFitType.NONE &&
    	    value != GridFitType.PIXEL &&
    	    value != GridFitType.SUBPIXEL)
    	{
    		value = GridFitType.NONE;
    	}
    	    	
    	_gridFitType = value;
    	
 		// Setting this property does not affect
		// the appearance of TLFTextField.
		// It is a setting for TextField's Saffron renderer
		// (i.e., it applies when antiAliasType == "advanced").
		// and isn't relevant to FTE's CFF renderer.
		
		// Side effects
		// none
    }

    //----------------------------------
    //  htmlText
    //----------------------------------
    
    /**
     *  @private
     */
    private var _htmlText:String = null;
    
    /**
     *  @copy flash.text.TextField#htmlText
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get htmlText():String
    {
    	if (_htmlText == null)
    	{
			var htmlPreText:String;
			if ( _text.length && _text.charCodeAt( _text.length - 1 ) == 13 )
				htmlPreText = _text.substr(0, _text.length - 1); // trim at most 1 trailing CR
			else
				htmlPreText = _text;
			var lines:Array =  htmlPreText.split( /\r/ );
			
			// TODO: is font value platform-dependent???
			var htmlFont:String = _defaultTextFormat.font ? _defaultTextFormat.font : "Times New Roman";
			var htmlSize:String = _defaultTextFormat.size ? String(_defaultTextFormat.size) : "12";
			var htmlColor:String = intToHexColor(_defaultTextFormat.color ? _defaultTextFormat.color : 0);
			var htmlLetterSpacing:String = _defaultTextFormat.letterSpacing ? String(_defaultTextFormat.letterSpacing) : "0";
			var htmlKerning:String = _defaultTextFormat.kerning ? "1" : "0";
			_htmlText = "";
			for each (var line:String in lines)
			{
				_htmlText += "<P ALIGN=\"LEFT\"><FONT FACE=\"" + htmlFont; 
				_htmlText += "\" SIZE=\"" + htmlSize;
				_htmlText += "\" COLOR=\"#" + htmlColor;
				_htmlText += "\" LETTERSPACING=\"" + htmlLetterSpacing;
				_htmlText += "\" KERNING=\"" + htmlKerning;
				_htmlText += "\">" + line + "</FONT></P>";
			}
    	}
     	return _htmlText;
    }
    
    /**
     *  @private
     */
    public function set htmlText(value:String):void
    {
    	// TextField throws if a null value is set.
    	if (value == null)
    	{
    		throw new TypeError("Parameter text must be non-null.");
    		// Note: It seems like this should say
    		// "Parameter htmlText must be non-null",
    		// but that's not what TextField does.
    	}
    	
    	if (value == htmlText)
    		return;
    		
    	_htmlText = value;
    	
    	setFlag(FLAG_HTML_TEXT_CHANGED |
				FLAG_GRAPHICS_INVALID |
				FLAG_TEXT_LINES_INVALID);
	
	   	invalidate();
	   	
	   	// NOTE: With hmtlText, what you set is NOT what you get.
	   	// You can set incomplete (or no) markup
	   	// and get back complete markup.
	   	
	   	// Side effects:
	   	// text
	   	// length
	   	// x
	   	// width/height
	   	// textWidth/textHeight
	   	// numLines
	   	// maxScrollH/maxScrollV
	   	// scrollH/scrollV/bottomScrollV?
	   	// selectionBeginIndex/selectionEndIndex/caretIndex
    }

    //----------------------------------
    //  length
    //----------------------------------
    
    /**
     *  @copy flash.text.TextField#length
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get length():int
    {
    	return text.length;
    }

    //----------------------------------
    //  maxChars
    //----------------------------------
    
    /**
     *  @private
     */
    private var _maxChars:int = 0;
    
    /**
     *  @copy flash.text.TextField#maxChars
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get maxChars():int
    {
     	return _maxChars;
    }
    
    /**
     *  @private
     */
    public function set maxChars(value:int):void
    {
    	// TextField apparently allows maxChars to be set
 		// to negative integers.
 		
     	_maxChars = value;
    	
    	// Note: There is nothing to do immediately;
    	// the new value doesn't have any effect
    	// until the user types or pastes text.
    	
    	// Side effects:
    	// none
    }

    //----------------------------------
    //  maxScrollH
    //----------------------------------
    
    /**
     *  @private
     */
    private var _maxScrollH:int = 0;
    
    /**
     *  @copy flash.text.TextField#maxScrollH
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get maxScrollH():int
    {
    	if ( _autoSize == TextFieldAutoSize.NONE )
    		validateNow();
    	
    	return _maxScrollH;
    }

    //----------------------------------
    //  maxScrollV
    //----------------------------------
    
    /**
     *  @private
     */
    private var _maxScrollV:int = 1;
    
    /**
     *  @copy flash.text.TextField#maxScrollV
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get maxScrollV():int
    {
    	validateNow();
    	
    	return _maxScrollV;
    }

    //----------------------------------
    //  mouseWheelEnabled
    //----------------------------------
    
    /**
     *  @copy flash.text.TextField#mouseWheelEnabled
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get mouseWheelEnabled():Boolean
    {
     	return testFlag(FLAG_MOUSE_WHEEL_ENABLED);
    }
    
    /**
     *  @private
     */
    public function set mouseWheelEnabled(value:Boolean):void
    {
    	setFlagToValue(FLAG_MOUSE_WHEEL_ENABLED, value);
    	
    	// Note: There is nothing to do immediately;
    	// the new value doesn't have any effect
    	// until the user turns the mousewheel.
    	
    	// Side effects:
    	// none
    }

    //----------------------------------
    //  multiline
    //----------------------------------
    
     /**
     *  @copy flash.text.TextField#multiline
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get multiline():Boolean
    {
     	return testFlag(FLAG_MULTILINE);
    }
    
    /**
     *  @private
     */
    public function set multiline(value:Boolean):void
    {
    	setFlagToValue(FLAG_MULTILINE, value);
    	
    	// Note: There is nothing to do immediately;
    	// the new value doesn't have any effect
    	// until the user types or pastes text.
    	
    	// Side effects:
    	// none
    }

    //----------------------------------
    //  numLines
    //----------------------------------
    
    /**
     *  @private
     */
    private var _numLines:int = 0;
    
    /**
     *  @copy flash.text.TextField#numLines
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get numLines():int
    {
    	validateNow();
    	
    	return _numLines == 0 ? 1 : _numLines;
    }

    //----------------------------------
    //  restrict
    //----------------------------------
    
    /**
     *  @private
     */
    private var _restrict:String = null;
    
    /**
     *  @copy flash.text.TextField#restrict
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get restrict():String
    {
     	return _restrict;
    }
    
    /**
     *  @private
     */
    public function set restrict(value:String):void
    {
    	_restrict = value;
    	
    	// Note: There is nothing to do immediately;
    	// the new value doesn't have any effect
    	// until the user types or pastes text.
    	
    	// Side effects:
    	// none
    }

    //----------------------------------
    //  scrollH
    //----------------------------------
    
    /**
     *  @private
     */
    private var _scrollH:int = 0;
    
    /**
     *  @copy flash.text.TextField#scrollH
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get scrollH():int
    {
    	validateNow();
    	
    	return _scrollH;
    }
    
    /**
     *  @private
     */
    public function set scrollH(value:int):void
    {
    	// What does TextField do if you set negative value,
    	// or a positive value greater than maxScrollH?
    	
    	if (value == _scrollH)
    		return;
    		
    	_scrollH = (value >= 1) ? ((value <= _maxScrollH) ? value : _maxScrollH ) : 1 ;
   	
    	setFlag(FLAG_SCROLL_POSITION_INVALID);
    	
    	invalidate();
    	
    	// Side effects:
    	// none
    }

    //----------------------------------
    //  scrollV
    //----------------------------------
    
    /**
     *  @private
     */
    private var _scrollV:int = 1;
    
    /**
     *  @copy flash.text.TextField#scrollV
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get scrollV():int
    {
    	validateNow();
    	
    	return _scrollV;    	
    }
    
    /**
     *  @private
     */
    public function set scrollV(value:int):void
    {
   		// What does TextField do if you set negative value,
    	// or a positive value greater than maxScrollV?
    	
    	if (value == _scrollV)
    		return;
    	
    	_scrollV = (value >= 1) ? ((value <= _maxScrollV) ? value : _maxScrollV ) : 1 ;

    	setFlag(FLAG_SCROLL_POSITION_INVALID);
     	
     	invalidate();
     	
     	// Side effects:
     	// none
    }

    //----------------------------------
    //  selectable
    //----------------------------------
    
    /**
     *  @copy flash.text.TextField#selectable
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get selectable():Boolean
    {
    	return testFlag(FLAG_SELECTABLE);
    }
    
    /**
     *  @private
     */
    public function set selectable(value:Boolean):void
    {
    	if (value == selectable)
    		return;
    		
    	setFlagToValue(FLAG_SELECTABLE, value);
    	
    	setFlag(FLAG_SELECTION_INVALID);
    	
    	invalidate();
    	
    	// Side effects:
    	// selectionBeginIndex/selectionEndIndex/caretIndex?
    }

    //----------------------------------
    //  selectionBeginIndex
    //----------------------------------
    
    /**
     *  @copy flash.text.TextField#selectionBeginIndex
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get selectionBeginIndex():int
    {
    	validateNow();
    	
    	// TODO: Compute this properly.
    	return 0;
     }

    //----------------------------------
    //  selectionEndIndex
    //----------------------------------
    
    /**
     *  @copy flash.text.TextField#selectionEndIndex
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get selectionEndIndex():int
    {
    	validateNow();
    	
    	// TODO: Compute this properly.
    	return 0;
    }

    //----------------------------------
    //  sharpness
    //----------------------------------
    
    /**
     *  @private
     */
    private var _sharpness:Number = 0;
    
    /**
     *  @copy flash.text.TextField#sharpness
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get sharpness():Number
    {
    	return _sharpness;
    }
    
    /**
     *  @private
     */
    public function set sharpness(value:Number):void
    {
    	// TextField apparently allows NaN as a value
    	// but clamps non-NaN values to [-400, 400],
    	const LIMIT:Number = 400;
    	if (value < -LIMIT)
    		value = -LIMIT;
    	else if (value > LIMIT)
    		value = LIMIT;
    		
    	_sharpness = value;
 		
 		// Setting this property does not affect
		// the appearance of TLFTextField.
		// It is a setting for TextField's Saffron renderer
		// (i.e., it applies when antiAliasType == "advanced").
		// and isn't relevant to FTE's CFF renderer.
		
		// Side effects:
		// none
    }

    //----------------------------------
    //  styleSheet
    //----------------------------------
    
    /**
     *  @private
     */
    private var _styleSheet:StyleSheet = null;
    
    /**
     *  @copy flash.text.TextField#styleSheet
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get styleSheet():StyleSheet
    {
    	return _styleSheet;
    }
    
    /**
     *  @private
     */
    public function set styleSheet(value:StyleSheet):void
    {
    	// TextField allows a null value to be set;
    	// in fact, this is the default.
    	
    	if (value == _styleSheet)
    		return;
    		
    	_styleSheet = value;
    	
    	setFlag(FLAG_GRAPHICS_INVALID |	FLAG_TEXT_LINES_INVALID);

    	invalidate();
    	
    	// Side effects:
    	// x
    	// width/height
    	// textWidth/textHeight
    	// numLines
    	// maxScrollH/maxScrollV
    	// scrollH/scrollV/bottomScrollV?
    }

    /**
     *  @private
     */
    static private function intToHexColor( color:Object ):String
    {
    	if ( color == null )
    		return "000000";
    	var colorInt:int = int(color);
    	var s:String = new String();
    	var hexCode:Array = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"];
    	for (var i:int = 0; i < 6; ++i)
    	{
    		var c:int = colorInt & 15;
    		s = hexCode[c] + s; 
    		colorInt >>= 4;
    	} 
    	return s;
    } 
    

    //----------------------------------
    //  text
    //----------------------------------
    
    /**
     *  @private
     */
    private var _text:String = "";
    
    /**
     *  @copy flash.text.TextField#text
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get text():String
    {
    	return _text;
    }
    
    /**
     *  @private
     */
    public function set text(value:String):void
    {
    	// TextField throws if a null value is set.
    	if (value == null)
    		throw new TypeError("Parameter text must be non-null.");
    		
    	var noNewlineText:String = value.replace( /\n/g, "\r" );
    	
    	if (noNewlineText == _text)
    		return;
    	
    	// Does TLF treat \r and \n the same as TextField?
    	
    	_text = noNewlineText;
    	
    	// signals that htmlText needs to be regenerated
    	_htmlText = null;


		
    	setFlag(FLAG_TEXT_CHANGED |
    			FLAG_GRAPHICS_INVALID |
    			FLAG_TEXT_LINES_INVALID);

    	invalidate();
   	
    	// Side effects:
    	// htmlText
    	// length
    	// x
    	// width/height
    	// textWidth/textHeight
    	// numLines
    	// maxScrollH/maxScrollV
    	// scrollH/scrollV/bottomScrollV?
    	// selectionBeginIndex/selectionEndIndex/caretIndex?
    }

    //----------------------------------
    //  textColor
    //----------------------------------
    
    /**
     *  @private
     */
    private var _textColor:uint = 0x000000;
    
    /**
     *  @copy flash.text.TextField#textColor
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get textColor():uint
    {
    	return _textColor;
    }
    
    /**
     *  @private
     *  Setting the textColor changes defaultTextFormat.color 
     *  and redraws the text in the new color.
     */
    public function set textColor(value:uint):void
    {
    	if (value == _textColor)
    		return;
    		
    	_textColor = value;
    	_defaultTextFormat.color = value; // have verified that changing textColor on TextField alters the defaultTextFormat's color property
    	
    	setFlag(FLAG_TEXT_LINES_INVALID);

    	invalidate();
    	
    	// Side effects:
    	// none
    }

    //----------------------------------
    //  textHeight
    //----------------------------------
    
    /**
     *  @private
     */
    private var _textHeight:Number = 0;
    
    /**
     *  @copy flash.text.TextField#textHeight
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get textHeight():Number
    {
    	validateNow();
    	
    	return _textHeight;
    }

    //----------------------------------
    //  textWidth
    //----------------------------------
    
    /**
     *  @private
     */
    private var _textWidth:Number = 0;
    
    /**
     *  @copy flash.text.TextField#textWidth
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get textWidth():Number
    {
    	validateNow();
    	
    	return _textWidth;
    }

    //----------------------------------
    //  thickness
    //----------------------------------
    
    /**
     *  @private
     */
    private var _thickness:Number = 0;
    
    /**
     *  @copy flash.text.TextField#thickness
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get thickness():Number
    {
    	return _thickness;
    }
    
    /**
     *  @private
     */
    public function set thickness(value:Number):void
    {
    	// TextField apparently allows NaN as a value
    	// but clamps non-NaN values to [-400, 400],
    	const LIMIT:Number = 200;
    	if (value < -LIMIT)
    		value = -LIMIT;
    	else if (value > LIMIT)
    		value = LIMIT;
    		
    	_thickness = value;
 		
 		// Setting this property does not affect
		// the appearance of TLFTextField.
		// It is a setting for TextField's Saffron renderer
		// (i.e., it applies when antiAliasType == "advanced").
		// and isn't relevant to FTE's CFF renderer.
		
		// Side effects:
		// none
    }

    //----------------------------------
    //  type
    //----------------------------------
    
    private var _type:String = TextFieldType.DYNAMIC;
    
    /**
     *  @copy flash.text.TextField#type
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get type():String
    {
     	return _type;
    }
    
    /**
     *  @private
     */
    public function set type(value:String):void
    {
   		// TextField throws when invalid values are set.
    	if (value != TextFieldType.DYNAMIC &&
    		value != TextFieldType.INPUT)
    	{
    		throw new ArgumentError("Parameter type must be one of the accepted values.");
    	}
    	
    	if (value == _type)
    		return;
    		
    	_type = value;
    	
    	// set some flags
    	
     	invalidate();
     	
     	// Side effects:
     	// selectable?
     	// selectionBeginIndex/selectionEndIndex/caretIndex?
    }

    //----------------------------------
    //  useRichTextClipboard
    //----------------------------------

    /**
     *  @private
     */
    public function get useRichTextClipboard():Boolean
    {
     	return testFlag(FLAG_USE_RICH_TEXT_CLIPBOARD);
    }
    /**
     *  @copy flash.text.TextField#useRichTextClipboard
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function set useRichTextClipboard(value:Boolean):void
    {
    	setFlagToValue(FLAG_USE_RICH_TEXT_CLIPBOARD, value);
     		
    	// Note: There is nothing to do immediately;
    	// the new value doesn't have any effect
    	// until the user pastes.
    	
    	// Side effects:
    	// none
    }
    
    //----------------------------------
    //  wordWrap
    //----------------------------------
    
    /**
     *  @copy flash.text.TextField#wordWrap
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get wordWrap():Boolean
    {
    	return testFlag(FLAG_WORD_WRAP);
    }
    
    /**
     *  @private
     */
    public function set wordWrap(value:Boolean):void
    {
    	if (value == wordWrap)
    		return;
    		
    	setFlagToValue(FLAG_WORD_WRAP, value);
    	
    	setFlag(FLAG_WORD_WRAP_CHANGED |
				FLAG_TEXT_LINES_INVALID);

    	invalidate();
   	
    	// Side effects:
    	// x?
    	// width/height?
    	// textWidth/textHeight
    	// numLines
    	// maxScrollH/maxScrollV
    	// scrollH/scrollV/bottomScrollV?
    }

    /**
	 * Gets and sets the ITextLineCreator instance to be used for creating TextLines.  Override this if you need lines to be created in a different
	 * SWF context than the one containing the TLF code.  The framework will supply a default implementation of ITextLineCreator if none is supplied by the caller.
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function get textLineCreator():ITextLineCreator
    {
    	return _textLineCreator;
    }
    public function set textLineCreator(value:ITextLineCreator):void
    {
    	_textLineCreator = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods: TextField
    //
    //--------------------------------------------------------------------------

    /**
     *  @copy flash.text.TextField#appendText()
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function appendText(newText:String):void
    {
    	text = text + newText;
    }

    /**
     *  @copy flash.text.TextField#getCharBoundaries()
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function getCharBoundaries(charIndex:int):Rectangle
    {
    	throw new Error("Not implemented: getCharBoundaries()");
    }

    /**
     *  @copy flash.text.TextField#getCharIndexAtPoint()
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function getCharIndexAtPoint(x:Number, y:Number):int
    {
    	throw new Error("Not implemented: getCharIndexAtPoint()");
    }

    /**
     *  @copy flash.text.TextField#getFirstCharInParagraph()
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function getFirstCharInParagraph(charIndex:int):int
    {
    	throw new Error("Not implemented: getFirstCharInParagraph()");
    }

    /**
     *  @copy flash.text.TextField#getLineIndexAtPoint()
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function getLineIndexAtPoint(x:Number, y:Number):int
    {
    	throw new Error("Not implemented: getLineIndexAtPoint()");
    }

    /**
     *  @copy flash.text.TextField#getLineIndexOfChar()
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function getLineIndexOfChar(charIndex:int):int
    {
    	throw new Error("Not implemented: getLineIndexOfChar()");
    }

    /**
     *  @copy flash.text.TextField#getLineLength()
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function getLineLength(lineIndex:int):int
    {
    	throw new Error("Not implemented: getLineLength()")
    }

    /**
     *  @copy flash.text.TextField#getLineMetrics()
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function getLineMetrics(lineIndex:int):TextLineMetrics
    {
    	validateNow();
    	
    	if ( lineIndex < 0 || lineIndex >= numChildren )
    		throw new RangeError( "The supplied index is out of bounds" ); // matching TextField behavior

    	var textLine:TextLine = TextLine( getChildAt( lineIndex ) );
    	var height:Number;
    	if (lineIndex == this.numChildren - 1)
    	 	height = Number(_defaultTextFormat.size) + 2; /// how to correctly determine "height" here?
    	else
    	{
	    	var nextTextLine:TextLine = TextLine( getChildAt( lineIndex + 1 ) );
    		height = nextTextLine.y - textLine.y;
    	}
    	return new TextLineMetrics( textLine.x, textLine.width, height, textLine.ascent, textLine.descent, height - textLine.ascent - textLine.descent );
    }

    /**
     *  @copy flash.text.TextField#getLineOffset()
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function getLineOffset(lineIndex:int):int
    {
    	throw new Error("Not implemented: getLineOffset()")
    }

    /**
     *  @copy flash.text.TextField#getLineText()
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function getLineText(lineIndex:int):String
    {
    	throw new Error("Not implemented: getLineText()")
    }

    /**
     *  @copy flash.text.TextField#getParagraphLength()
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function getParagraphLength(charIndex:int):int
    {
    	throw new Error("Not implemented: getParagraphLength()")
    }

    /**
     *  @copy flash.text.TextField#getTextFormat()
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function getTextFormat(beginIndex:int = -1, endIndex:int = -1):TextFormat
    {
    	return _defaultTextFormat;
    }

    /**
     *  @copy flash.text.TextField#replaceSelectedText()
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function replaceSelectedText(value:String):void
    {
    	throw new Error("Not implemented: replaceSelectedText()")
    }

    /**
     *  @copy flash.text.TextField#replaceText()
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function replaceText(beginIndex:int, endIndex:int,
    							newText:String):void
    {
    	if ( beginIndex <= endIndex )
    		text = text.substring( 0, beginIndex ) + newText + text.substring( endIndex );
    }

    /**
     *  @copy flash.text.TextField#setSelection()
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function setSelection(beginIndex:int, endIndex:int):void
    {
    	throw new Error("Not implemented: setSelection()")
    }

    /**
     *  @copy flash.text.TextField#setTextFormat()
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function setTextFormat(format:TextFormat,
                           		  beginIndex:int = -1,
                           		  endIndex:int = -1):void
    {
    	// XXXXXX XXXXXX XXXXX TODO!!!!!!!!!!!!!!!!! XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    	//throw new Error("Not implemented: setTextFormat()");
    	// XXXXXX XXXXXX XXXXX TODO!!!!!!!!!!!!!!!!! XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    }

    /**
     *  @copy flash.text.TextField#getImageReference()
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @langversion 3.0
     */
    public function getImageReference(id:String):DisplayObject
    {
    	throw new Error("Not implemented: getImageReference()");
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private function testFlag(mask:uint):Boolean
    { return (flags & mask) != 0; }

    /**
     *  @private
     */
    private function setFlag(mask:uint):void
    { flags |= mask; }
    
    private function clearFlag(mask:uint):void
    { flags &= ~mask; }
    
    private function setFlagToValue(mask:uint,value:Boolean):void
    {
    	if (value)
    		flags |= mask;
    	else
    		flags &=~ mask;
    }
    
    /**
     *  @private
     *  This method will cause a 'render' event later,
     *  in response to which validateNow() will get called.
     */
    private function invalidate():void
    {
		CONFIG::debug { assert( !testFlag(FLAG_VALIDATE_IN_PROGRESS), "invalidating during validateNow()"); }

    	if (stage)
    		stage.invalidate();
    }
    
    static private function rint(x:Number):Number
    {
    	var i:Number = Math.round(x);
    	if ( i - 0.5 == x && i & 1 )
    		--i;
    	return i;
    }
    
    /**
     *  @private
     *  This method is the workhorse of TLFTextField.
     *  It puts it into a state where all properties are consistent
     *  with each other and where it is rendering what the properties
     *  specify.
     */
    private function validateNow():void
    {
    	if ( !testFlag( ALL_INVALIDATION_FLAGS ) || testFlag( FLAG_VALIDATE_IN_PROGRESS) )
    		return;
    	setFlag(FLAG_VALIDATE_IN_PROGRESS);
    	
    	// Determine the TLF formats based on the TextField's defaultTextFormat.
    	if (testFlag(FLAG_DEFAULT_TEXT_FORMAT_CHANGED))
    	{
			textFormatToTLFFormats();
								   
			hostContainerFormat.lineBreak = LineBreak.EXPLICIT;
			hostContainerFormat.paddingLeft = 2;
			hostContainerFormat.paddingTop = 4;
			hostContainerFormat.paddingRight = 2;
			hostContainerFormat.paddingBottom = 2;
   		}
    	
    	if (testFlag(FLAG_WORD_WRAP_CHANGED))
    	{
    		hostContainerFormat.lineBreak =
    			wordWrap ? LineBreak.TO_FIT : LineBreak.EXPLICIT;
    	}
    	
    	// Compose TextLines.
    	if (testFlag(FLAG_TEXT_LINES_INVALID))
    		composeTextLines();
     	
    	// Draw the border and background last,
    	// once the width and height are known.
    	if (testFlag(FLAG_GRAPHICS_INVALID))
    	{
			var g:Graphics = graphics;
    		g.clear();
    		// First draw the background, then draw the border.
    		// This is because TextField actually does something strange --- it expands itselft 1 pixel right and down when drawing a border
    		// and fill without the stroke with the required stroking path does not match the "background sans border" behavior of TextField.
    		if (background)
    		{
    			// Width/Height rounding differences between TextField and TLFTextField...
    			// For width or height of the form E.5 where E is a positive even integer, Flash 10 on Windows seems to 
    			// "round to even", i.e., round the dimension down to E rather than up to E+1. However we currently just 
    			// round consistently up to E+1 using Math.round() here since for now are willing to live with this difference.
    			var w:Number = rint(_width);
    			var h:Number = rint(_height);

    			g.beginFill(backgroundColor);
	    		g.drawRect(0, 0, w, h);
    			g.endFill();
    		}
    		
    		if (border)
    		{
    			g.lineStyle(1, borderColor);
	    		g.drawRect(0.5, 0.5, _width, _height); // TextField actually expands by a pixel down and to the right when it has a border!
    		}
    	}

    	clearFlag(ALL_INVALIDATION_FLAGS|FLAG_VALIDATE_IN_PROGRESS);
    }
    
    /**
     *  @private
     */
    private function textFormatToTLFFormats():void
    {
    	hostParagraphFormat.textAlign = _defaultTextFormat.align ? _defaultTextFormat.align : TextFormatAlign.LEFT;;
    	hostParagraphFormat.textAlignLast = hostParagraphFormat.textAlign;
    	//_defaultTextFormat.blockIndent
    	hostCharacterFormat.fontWeight = _defaultTextFormat.bold ?
    								 FontWeight.BOLD :
    								 FontWeight.NORMAL;
    	//_defaultTextFormat.bullet
    	hostCharacterFormat.color = _defaultTextFormat.color ? _defaultTextFormat.color : 0;
    	// TODO: is font value platform-dependent???
    	hostCharacterFormat.fontFamily = _defaultTextFormat.font ? _defaultTextFormat.font : "Times New Roman";
    	//_defaultTextFormat.indent;
    	hostCharacterFormat.fontStyle = _defaultTextFormat.italic ?
    								FontPosture.ITALIC :
    								FontPosture.NORMAL;
    	hostCharacterFormat.kerning = _defaultTextFormat.kerning ?
    							  Kerning.ON :
    							  Kerning.OFF;
    	hostCharacterFormat.fontLookup = testFlag(FLAG_EMBED_FONTS) ?
    								flash.text.engine.FontLookup.EMBEDDED_CFF :
    								flash.text.engine.FontLookup.DEVICE;
    	//_defaultTextFormat.leading
    	hostParagraphFormat.paragraphStartIndent = _defaultTextFormat.leftMargin ? _defaultTextFormat.leftMargin : 0;
    	hostCharacterFormat.trackingRight = _defaultTextFormat.letterSpacing? _defaultTextFormat.letterSpacing : 0;
    	hostParagraphFormat.paragraphEndIndent = _defaultTextFormat.rightMargin ? _defaultTextFormat.rightMargin : 0;
    	hostCharacterFormat.fontSize = _defaultTextFormat.size ? _defaultTextFormat.size : 12;
    	hostParagraphFormat.tabStops = _defaultTextFormat.tabStops;
    	//_defaultTextFormat.target
    	hostCharacterFormat.textDecoration = _defaultTextFormat.underline ?
    									 TextDecoration.UNDERLINE :
    									 TextDecoration.NONE;
    	//textFormat.url
    }
    
    /**
     *  @private
     */
    private function composeTextLines():void
    {
    	removeTextLines();
    	
    	var r:Rectangle;
    	if (_autoSize == TextFieldAutoSize.NONE)
    		r = new Rectangle(0, 0, Math.round(_width), Math.round(_height));
    	else if (wordWrap)
    		r = new Rectangle(0, 0, Math.round(_width), NaN);
    	else
    		r = new Rectangle(0, 0, NaN, NaN);
    	
    	_bottomScrollV = 0;
    	
    	factory.text = _text;
    	factory.compositionBounds = r;
    	factory.spanFormat = hostCharacterFormat;
    	factory.paragraphFormat = hostParagraphFormat;
    	factory.textFlowFormat = hostContainerFormat;
    	factory.textLineCreator = _textLineCreator;
    	factory.createTextLines(textLineFactoryCallback);
    		
    	if (_bottomScrollV == 0)
    	{
    		_bottomScrollV = 1;
			_maxScrollV = 1;
    	}
    	else 	
    		_maxScrollV = 1 + (_numLines - _bottomScrollV);
    		
		// NOTE: It is understood that  the Flash TextField clipping of text clips to a margin rect INSET from the TextField's boundary
		// and that we currently (intentionally) do not match this behavior as a speed/memory optimization. 

		// Compute bounds of text content		
		var textBounds:Rectangle = new Rectangle(0,0,0,0);
		if ( numChildren )
		{
			var textLine : TextLine = TextLine(getChildAt(0));
			textBounds.x = textLine.x;
			textBounds.y = 0; // textLine.y - textLine.textHeight; Not quite right?
			textBounds.width = textLine.textWidth;
			textBounds.height = textLine.textHeight;
			for (var i:int = 1; i < numChildren; ++i)
			{
				textLine = TextLine(getChildAt(i));
				var r2:Rectangle = new Rectangle( textLine.x, textLine.y - textLine.textHeight, textLine.textWidth, textLine.textHeight );
				textBounds = textBounds.union( r2 );
			}
			if ( !textBounds.isEmpty() )
				textBounds = textBounds.union( new Rectangle(textBounds.x, 0, textBounds.y, textBounds.bottom) );
		}

    	_textWidth = textBounds.width;
    	_textHeight = textBounds.height + textBounds.y;
    	
    	if ( _autoSize == TextFieldAutoSize.NONE )
    	{
	    	_maxScrollH = _textWidth + hostContainerFormat.paddingLeft + hostContainerFormat.paddingRight - width;
	    	if ( _maxScrollH < 0 )
	    		_maxScrollH = 0;
	    }
	    else 
    	{
    		_maxScrollH = 0;
    		var origX:Number = x;
    		var origWidth:Number = _width; 
    		var origHeight:Number = _height; 
    		_height = Math.ceil(_textHeight) + 4; // + 4 for standard margin size (possibly revisit this in the future)
    		if ( !wordWrap )
    		{
	    		_width = Math.ceil(_textWidth) + 3; // + 3 for standard margin size (possibly revisit this in the future) 
	    		
	    		// adjust x for CENTER and RIGHT cases
	    		if ( _autoSize == TextFieldAutoSize.RIGHT )
	    			x += origWidth - _width;
	    		else if ( _autoSize == TextFieldAutoSize.CENTER )
	    			x += (origWidth - _width) / 2;
	    	}
    		if ( _height != origHeight || _width != origWidth || x != origX )
				setFlag( FLAG_GRAPHICS_INVALID );
    	}

		
    	//trace( "textBounds = ("+textBounds.x + "," + textBounds.y + "," + textBounds.right + "," + textBounds.bottom + ")"); 
    	//trace( "     r = ("+r.x + "," + r.y + "," + r.right + "," + r.bottom + ")"); 
    	if (textBounds.left < r.left ||
    	    textBounds.top < r.top ||
    	    textBounds.right > r.right ||
    	    textBounds.bottom > r.bottom)
    	{
    		if (border)
    		{
    			// trying to match TextField behavior of border
    			r.width += 1;
    			r.height += 1;
    		}
    		//trace( "clipping to w = " + r.width + ", h = " + r.height );
            scrollRect = r;
    		setFlag(FLAG_SCROLL_RECT_IS_SET );
    	}
    	else 
    	{
    		//trace( "not clipping" );
			if ( testFlag(FLAG_SCROLL_RECT_IS_SET) )
			{
	    		scrollRect = null;
	    		clearFlag(FLAG_SCROLL_RECT_IS_SET);
	  		}
    	}
    }
    
    /**
     *  @private
     */
    private function removeTextLines():void
    {
    	while (numChildren > 0)
    	{
    		removeChildAt(0);
    	}
    	
    	_numLines = 0;
    	_textWidth = 0;
    	_textHeight = 0;
    }
    
    /**
     *  @private
     */
    private function textLineFactoryCallback(displayObject:DisplayObject):void
    {
    	if (displayObject is TextLine)
    	{
    		var textLine:TextLine = TextLine(displayObject);
	    	addChild(displayObject);
    		if ( textLine.y <= _height || _autoSize != TextFieldAutoSize.NONE )
		    	++_bottomScrollV;
    		else
    			displayObject.visible = false; // hide it
   			_numLines++;
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
    private function addedToStageHandler(event:Event):void
    {
    	// having renderHandler attached only while on the stage gives a performance improvement.
     	removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
	   	addEventListener(Event.RENDER, renderHandler);
    	addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
    	validateNow();
    }
    
    /**
     *  @private
     */
    private function removedFromStageHandler(event:Event):void
    {
    	removeEventListener(Event.RENDER, renderHandler);
    	removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
		addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
    }
    
    /**
     *  @private
     */
    private function renderHandler(event:Event):void
    {
    	validateNow();
    }
}

}
