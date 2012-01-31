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

package flex.graphics.graphicsClasses
{

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Point;

import flex.graphics.IDisplayObjectElement;

/**
 *  Documentation is not currently available.
 */
public class TextGraphicElement extends GraphicElement
	implements IDisplayObjectElement
{
	include "../../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor. 
	 */
	public function TextGraphicElement()
	{
		super();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden properties: GraphicElement
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  displayObject
	//----------------------------------

	/**
	 *  @private
	 */
	private var _displayObject:DisplayObject = new Sprite();

	/**
	 *  @private
	 */
	override public function get displayObject():DisplayObject
	{
		return _displayObject;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties: Text Attributes
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  color
	//----------------------------------

	/**
	 *  @private
	 */
	private var _color:uint = 0x000000;

	/**
	 *  Documentation is not currently available.
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
		if (value != _color)
		{
			var oldValue:uint = _color;
			_color = value;
			dispatchPropertyChangeEvent("color", oldValue, value);			

			invalidateTextLines("style");
			notifyElementChanged();
		}
	}

	//----------------------------------
	//  fontFamily
	//----------------------------------

	/**
	 *  @private
	 */
	private var _fontFamily:String = "Times New Roman";

	/**
	 *  Documentation is not currently available.
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
		if (value != _fontFamily)
		{
			var oldValue:String = _fontFamily;
			_fontFamily = value;
			dispatchPropertyChangeEvent("fontFamily", oldValue, value);

			invalidateTextLines("style");
			notifyElementChanged();
		}
	}

	//----------------------------------
	//  fontSize
	//----------------------------------

	/**
	 *  @private
	 */
	private var _fontSize:Number = 12;

	/**
	 *  Documentation is not currently available.
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
		if (value != _fontSize)
		{
			var oldValue:Number = _fontSize;
			_fontSize = value;
			dispatchPropertyChangeEvent("fontSize", oldValue, value);

			invalidateTextLines("style");
			notifyElementChanged();
		}
	}

	//----------------------------------
	//  fontStyle
	//----------------------------------

	/**
	 *  @private
	 */
	private var _fontStyle:String = "normal";

	/**
	 *  Documentation is not currently available.
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
		if (value != _fontStyle)
		{
			var oldValue:String = _fontStyle;
			_fontStyle = value;
			dispatchPropertyChangeEvent("fontStyle", oldValue, value);

			invalidateTextLines("style");
			notifyElementChanged();
		}
	}

	//----------------------------------
	//  fontWeight
	//----------------------------------

	/**
	 *  @private
	 */
	private var _fontWeight:String = "normal";

	/**
	 *  Documentation is not currently available.
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
		if (value != _fontWeight)
		{
			var oldValue:String = _fontWeight;
			_fontWeight = value;
			dispatchPropertyChangeEvent("fontWeight", oldValue, value);

			invalidateTextLines("style");
			notifyElementChanged();
		}
	}

	//----------------------------------
	//  kerning
	//----------------------------------

	/**
	 *  @private
	 */
	private var _kerning:String = "auto";

	/**
	 *  Documentation is not currently available.
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
		if (value != _kerning)
		{
			var oldValue:String = _kerning;
			_kerning = value;
			dispatchPropertyChangeEvent("kerning", oldValue, value);

			invalidateTextLines("style");
			notifyElementChanged();
		}
	}

	//----------------------------------
	//  lineHeight
	//----------------------------------

	/**
	 *  @private
	 */
	private var _lineHeight:Object = "120%";

	/**
	 *  Documentation is not currently available.
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
		if (value != _lineHeight)
		{
			var oldValue:Object = _lineHeight;
			_lineHeight = value;
			dispatchPropertyChangeEvent("lineHeight", oldValue, value);

			invalidateTextLines("style");
			notifyElementChanged();
		}
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
		if (value != _paddingBottom)
		{
			var oldValue:Number = _paddingBottom;
			_paddingBottom = value;
			dispatchPropertyChangeEvent("paddingBottom", oldValue, value);

			invalidateTextLines("style");
			notifyElementChanged();
		}
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
		if (value != _paddingLeft)
		{
			var oldValue:Number = _paddingLeft;
			_paddingLeft = value;
			dispatchPropertyChangeEvent("paddingLeft", oldValue, value);

			invalidateTextLines("style");
			notifyElementChanged();
		}
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
		if (value != _paddingRight)
		{
			var oldValue:Number = _paddingRight;
			_paddingRight = value;
			dispatchPropertyChangeEvent("paddingRight", oldValue, value);

			invalidateTextLines("style");
			notifyElementChanged();
		}
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
		if (value != _paddingTop)
		{
			var oldValue:Number = _paddingTop;
			_paddingTop = value;
			dispatchPropertyChangeEvent("paddingTop", oldValue, value);

			invalidateTextLines("style");
			notifyElementChanged();
		}
	}
	
	//----------------------------------
	//  textAlign
	//----------------------------------

	/**
	 *  @private
	 */
	private var _textAlign:String = "left";

	/**
	 *  Documentation is not currently available.
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
		if (value != _textAlign)
		{
			var oldValue:String = _textAlign;
			_textAlign = value;
			dispatchPropertyChangeEvent("textAlign", oldValue, value);

			invalidateTextLines("style");
			notifyElementChanged();
		}
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
		if (value != _textAlpha)
		{
			var oldValue:Number = _textAlpha;
			_textAlpha = value;
			dispatchPropertyChangeEvent("textAlpha", oldValue, value);

			invalidateTextLines("style");
			notifyElementChanged();
		}
	}

	//----------------------------------
	//  tracking
	//----------------------------------

	/**
	 *  @private
	 */
	private var _tracking:Object = 0;

	/**
	 *  Documentation is not currently available.
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
		if (value != _tracking)
		{
			var oldValue:Object = _tracking;
			_tracking = value;
			dispatchPropertyChangeEvent("tracking", oldValue, value);

			invalidateTextLines("style");
			notifyElementChanged();
		}
	}

	//----------------------------------
	//  verticalAlign
	//----------------------------------

	/**
	 *  @private
	 */
	private var _verticalAlign:String = "top";

	/**
	 *  Documentation is not currently available.
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
		if (value != _verticalAlign)
		{
			var oldValue:String = _verticalAlign;
			_verticalAlign = value;
			dispatchPropertyChangeEvent("verticalAlign", oldValue, value);

			invalidateTextLines("style");
			notifyElementChanged();
		}
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  text
	//----------------------------------

	/**
	 *  @private
	 */
	private var _text:String = "";
		
	/**
	 *  Documentation is not currently available.
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
		if (value != _text)
		{
			var oldValue:String = _text;
			_text = value;
			dispatchPropertyChangeEvent("text", oldValue, value);

			invalidateTextLines("text");
			notifyElementChanged();
		}
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden methods: GraphicElement
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	override public function get actualSize():Point
	{
		return new Point(drawWidth, drawHeight);
	}

	/**
	 *  @private
	 */
	override public function draw(g:Graphics):void 
	{
		/*
		g.clear();
		g.lineStyle()
		g.beginFill(0xCCCCCC);
		g.drawRect(0, 0, drawWidth, drawHeight);
		g.endFill();
		*/
	}

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  Documentation is not currently available.
	 */
	protected function invalidateTextLines(cause:String):void
	{
	}
}

}
