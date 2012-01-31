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
import flash.text.engine.FontPosture;
import flash.text.engine.FontWeight;
import flash.text.engine.Kerning;
import flash.utils.getQualifiedClassName;

import flex.graphics.IDisplayObjectElement;

import mx.core.mx_internal;
import mx.styles.CSSStyleDeclaration;
import mx.styles.ISimpleStyleClient;
import mx.styles.IStyleClient;
import mx.styles.StyleManager;

import text.formats.TextAlign;
import text.formats.VerticalAlign;

/**
 *  Documentation is not currently available.
 */
public class TextGraphicElement extends GraphicElement
	implements IDisplayObjectElement, ISimpleStyleClient, IStyleClient
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
			invalidateDisplayList();
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
			invalidateSize();
			invalidateDisplayList();
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
			invalidateSize();
			invalidateDisplayList();
		}
	}

	//----------------------------------
	//  fontStyle
	//----------------------------------

	/**
	 *  @private
	 */
	private var _fontStyle:String = FontPosture.NORMAL;

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
			invalidateSize();
			invalidateDisplayList();
		}
	}

	//----------------------------------
	//  fontWeight
	//----------------------------------

	/**
	 *  @private
	 */
	private var _fontWeight:String = FontWeight.NORMAL;

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
			invalidateSize();
			invalidateDisplayList();
		}
	}

	//----------------------------------
	//  kerning
	//----------------------------------

	/**
	 *  @private
	 */
	private var _kerning:String = Kerning.AUTO;

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
			invalidateSize();
			invalidateDisplayList();
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
			invalidateSize();
			invalidateDisplayList();
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
			invalidateSize();
			invalidateDisplayList();
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
			invalidateSize();
			invalidateDisplayList();
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
			invalidateSize();
			invalidateDisplayList();
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
			invalidateSize();
			invalidateDisplayList();
		}
	}
	
	//----------------------------------
	//  textAlign
	//----------------------------------

	/**
	 *  @private
	 */
	private var _textAlign:String = TextAlign.START;

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
			invalidateSize();
			invalidateDisplayList();
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
			invalidateDisplayList();
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
			invalidateSize();
			invalidateDisplayList();
		}
	}

	//----------------------------------
	//  verticalAlign
	//----------------------------------

	/**
	 *  @private
	 */
	private var _verticalAlign:String = VerticalAlign.TOP;

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
			invalidateDisplayList();
		}
	}

	//--------------------------------------------------------------------------
	//
	//  Properties: ISimpleStyleClient
	//
	//--------------------------------------------------------------------------

    //----------------------------------
    //  styleName
    //----------------------------------

    /**
     *  @private
     *  Storage for the styleName property.
     */
    private var _styleName:Object /* String, CSSStyleDeclaration, or UIComponent */;

    [Inspectable(category="General")]

    /**
	 *  Documentation is not currently available.
     */
    public function get styleName():Object /* String, CSSStyleDeclaration, or UIComponent */
    {
        return _styleName;
    }

    /**
     *  @private
     */
    public function set styleName(
        value:Object /* String, CSSStyleDeclaration, or UIComponent */):void
    {
        // to be implemented
    }

	//--------------------------------------------------------------------------
	//
	//  Properties: IStyleClient
	//
	//--------------------------------------------------------------------------

    //----------------------------------
    //  className
    //----------------------------------

    /**
	 *  Documentation is not currently available.
     */
    public function get className():String
    {
        var name:String = getQualifiedClassName(this);
        
        // If there is a package name, strip it off.
        var index:int = name.indexOf("::");
        if (index != -1)
            name = name.substr(index + 2);
                
        return name;
    }
    
    //----------------------------------
    //  inheritingStyles
    //----------------------------------

    /**
     *  @private
     *  Storage for the inheritingStyles property.
     */
    private var _inheritingStyles:Object =
        StyleManager.mx_internal::STYLE_UNINITIALIZED;
    
    [Inspectable(environment="none")]

    /**
	 *  Documentation is not currently available.
     */
    public function get inheritingStyles():Object
    {
        return _inheritingStyles;
    }
    
    /**
     *  @private
     */
    public function set inheritingStyles(value:Object):void
    {
        _inheritingStyles = value;
    }

    //----------------------------------
    //  nonInheritingStyles
    //----------------------------------

    /**
     *  @private
     *  Storage for the nonInheritingStyles property.
     */
    private var _nonInheritingStyles:Object =
        StyleManager.mx_internal::STYLE_UNINITIALIZED;

    [Inspectable(environment="none")]

    /**
	 *  Documentation is not currently available.
     */
    public function get nonInheritingStyles():Object
    {
        return _nonInheritingStyles;
    }

    /**
     *  @private
     */
    public function set nonInheritingStyles(value:Object):void
    {
        _nonInheritingStyles = value;
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
	 *  Documentation is not currently available.
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
			invalidateSize();
			invalidateDisplayList();
		}
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden methods: GraphicElement
	//
	//--------------------------------------------------------------------------

	/**
	 *  @inheritDoc
	 */
    override protected function updateDisplayList(unscaledWidth:Number, 
                                                  unscaledHeight:Number):void
	{
		/*
		var g:Graphics = Sprite(displayObject).graphics;
		
	    // TODO EGeorgie: clearing the graphics needs to be shared when
	    // the display objects are shared.
	    g.clear();

		g.lineStyle()
		g.beginFill(0xCCCCCC);
		g.drawRect(0, 0, unscaledWidth, unscaledHeight);
		g.endFill();
		*/
	}

	//--------------------------------------------------------------------------
	//
	//  Methods: ISimpleStyleClient
	//
	//--------------------------------------------------------------------------

    /**
     *  Documentation is not currently available.
     */
    public function styleChanged(styleProp:String):void
    {
        // to be implemented
    }

	//--------------------------------------------------------------------------
	//
	//  Methods: IStyleClient
	//
	//--------------------------------------------------------------------------

    /**
     *  Documentation is not currently available.
     */
    public function getStyle(styleProp:String):*
    {
        return StyleManager.isInheritingStyle(styleProp) ?
               _inheritingStyles[styleProp] :
               _nonInheritingStyles[styleProp];
    }

    /**
     *  Documentation is not currently available.
     */
    public function setStyle(styleProp:String, newValue:*):void
    {
        // to be implemented
    }

    /**
     *  Documentation is not currently available.
     */
    public function clearStyle(styleProp:String):void
    {
        setStyle(styleProp, undefined);
    }

    /**
     *  Documentation is not currently available.
     */
    public function getClassStyleDeclarations():Array
    {
        // to be implemented
        return null;
    }

    /**
     *  Documentation is not currently available.
     */
    public function notifyStyleChangeInChildren(
                        styleProp:String, recursive:Boolean):void
    {
        // to be implemented
    }

    /**
     *  Documentation is not currently available.
     */
    public function regenerateStyleCache(recursive:Boolean):void
    {
        // to be implemented
    }

	/**
	 *  Documentation is not currently available.
	 */
    public function registerEffects(effects:Array /* of String */):void
    {
        // to be implemented
    }

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

    /**
     *  Documentation is not currently available.
     */
    public function stylesInitialized():void
    {
    }

    /**
     *  @private
     *  Documentation is not currently available.
     */
    mx_internal function initProtoChain():void
    {
        // to be implemented
    }

	/**
	 *  Documentation is not currently available.
	 */
	protected function invalidateTextLines(cause:String):void
	{
	}
}

}
