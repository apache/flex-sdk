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

package flex.graphics
{

import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.geom.Rectangle;

import flex.graphics.graphicsClasses.TextFlowComposer;
import flex.graphics.graphicsClasses.TextGraphicElement;

import text.importExport.TextFilter;
import text.model.FlowElement;
import text.model.Paragraph;
import text.model.Span;
import text.model.TextFlow;

[DefaultProperty("content")]

/**
 *  Documentation is not currently avilable.
 */
public class TextGraphic extends TextGraphicElement
	implements IDisplayObjectElement
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
	public function TextGraphic()
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
	private var textFlowComposer:TextFlowComposer = new TextFlowComposer();
		
	/**
	 *  @private
	 *  This flag is set to true by the text, width, and height setters,
	 *  to indicate that the TextLines must be regenerated.
	 *  The regeneration occurs when draw() is called or 'bounds' is read.
	 */
	private var invalid:Boolean = false;

	/**
	 *  @private
	 */
	private var textChanged:Boolean = false;

	/**
	 *  @private
	 */
	private var contentChanged:Boolean = false;

	//--------------------------------------------------------------------------
	//
	//  Overridden properties: GraphicElement
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  bounds
	//----------------------------------
	
	/**
	 *  @private
	 */
	private var _bounds:Rectangle = new Rectangle();

    /**
     *  @inheritDoc
     */
    override public function get bounds():Rectangle
	{
		if (invalid)
		{
			compose();
			invalid = false;
		}

		var w:Number;
		var h:Number;

		if (drawWidth != 0 && drawHeight != 0)
		{
			w = drawWidth;
			h = drawHeight;
		}
		else
		{
			var r:Rectangle = textFlowComposer.actualBounds;
			w = Math.ceil(r.width);
			h = Math.ceil(r.height);
		}

		_bounds.width = w;
		_bounds.height = h;
				
		return _bounds;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties: Text Attributes
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  blockProgression
	//----------------------------------

	/**
	 *  @private
	 */
	private var _blockProgression:String = "lr";

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
		if (value != _blockProgression)
		{
			var oldValue:String = _blockProgression;
			_blockProgression = value;
			dispatchPropertyChangeEvent("blockProgression", oldValue, value);

			invalidateTextLines("style");
			notifyElementChanged();
		}
	}

	//----------------------------------
	//  direction
	//----------------------------------

	/**
	 *  @private
	 */
	private var _direction:String = "ltr";

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
		if (value != _direction)
		{
			var oldValue:String = _direction;
			_direction = value;
			dispatchPropertyChangeEvent("direction", oldValue, value);

			invalidateTextLines("style");
			notifyElementChanged();
		}
	}

	//----------------------------------
	//  lineBreak
	//----------------------------------

	/**
	 *  @private
	 */
	private var _lineBreak:String = "toFit";

	/**
	 *  Documentation is not currently available.
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
		if (value != _lineBreak)
		{
			var oldValue:String = _lineBreak;
			_lineBreak = value;
			dispatchPropertyChangeEvent("lineBreak", oldValue, value);

			invalidateTextLines("style");
			notifyElementChanged();
		}
	}

	//----------------------------------
	//  lineThrough
	//----------------------------------

	/**
	 *  @private
	 */
	private var _lineThrough:Boolean = false;

	/**
	 *  Documentation is not currently available.
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
		if (value != _lineThrough)
		{
			var oldValue:Boolean = _lineThrough;
			_lineThrough = value;
			dispatchPropertyChangeEvent("lineThrough", oldValue, value);

			invalidateTextLines("style");
			notifyElementChanged();
		}
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
		if (value != _marginBottom)
		{
			var oldValue:Number = _marginBottom;
			_marginBottom = value;
			dispatchPropertyChangeEvent("marginBottom", oldValue, value);

			invalidateTextLines("style");
			notifyElementChanged();
		}
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
		if (value != _marginLeft)
		{
			var oldValue:Number = _marginLeft;
			_marginLeft = value;
			dispatchPropertyChangeEvent("marginLeft", oldValue, value);

			invalidateTextLines("style");
			notifyElementChanged();
		}
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
		if (value != _marginRight)
		{
			var oldValue:Number = _marginRight;
			_marginRight = value;
			dispatchPropertyChangeEvent("marginRight", oldValue, value);

			invalidateTextLines("style");
			notifyElementChanged();
		}
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
		if (value != _marginTop)
		{
			var oldValue:Number = _marginTop;
			_marginTop = value;
			dispatchPropertyChangeEvent("marginTop", oldValue, value);

			invalidateTextLines("style");
			notifyElementChanged();
		}
	}
	
	//----------------------------------
	//  textAlignLast
	//----------------------------------

	/**
	 *  @private
	 */
	private var _textAlignLast:String = "left";

	/**
	 *  Documentation is not currently available.
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
		if (value != _textAlignLast)
		{
			var oldValue:String = _textAlignLast;
			_textAlignLast = value;
			dispatchPropertyChangeEvent("textAlignLast", oldValue, value);

			invalidateTextLines("style");
			notifyElementChanged();
		}
	}

	//----------------------------------
	//  textDecoration
	//----------------------------------

	/**
	 *  @private
	 */
	private var _textDecoration:String = "none";

	/**
	 *  Documentation is not currently available.
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
		if (value != _textDecoration)
		{
			var oldValue:String = _textDecoration;
			_textDecoration = value;
			dispatchPropertyChangeEvent("textDecoration", oldValue, value);

			invalidateTextLines("style");
			notifyElementChanged();
		}
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
		if (value != _textIndent)
		{
			var oldValue:Number = _textIndent;
			_textIndent = value;
			dispatchPropertyChangeEvent("textIndent", oldValue, value);

			invalidateTextLines("style");
			notifyElementChanged();
		}
	}

	//----------------------------------
	//  whiteSpaceCollapse
	//----------------------------------

	/**
	 *  @private
	 */
	private var _whiteSpaceCollapse:String = "preserve";

	/**
	 *  Documentation is not currently available.
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
		if (value != _whiteSpaceCollapse)
		{
			var oldValue:String = _whiteSpaceCollapse;
			_whiteSpaceCollapse = value;
			dispatchPropertyChangeEvent("whiteSpaceCollapse", oldValue, value);

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
	//  content
	//----------------------------------

	/**
	 *  Documentation is not currently available.
	 */
	protected var _content:Object;
		
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
		if (value != _content)
		{
			var oldValue:Object = _content;
			_content = value;
			dispatchPropertyChangeEvent("content", oldValue, value);

			invalidateTextLines("content");
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
	override public function draw(g:Graphics):void 
	{
		super.draw(g);
		
		compose(drawWidth, drawHeight);
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods: TextGraphicElement
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	override protected function invalidateTextLines(cause:String):void
	{
		if (cause == "text")
			textChanged = true;
		else if (cause == "content")
			contentChanged = true;

		invalid = true;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private function createEmptyTextFlow():TextFlow
	{
		var textFlow:TextFlow = new TextFlow();
		var p:Paragraph = new Paragraph();
		var span:Span = new Span();
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
		
		return TextFilter.importFromString(markup, "fxg");
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
                textFlow.appendChildren = content as Array;
            }
            else if (content is FlowElement)
            {
                textFlow = createEmptyTextFlow();
                textFlow.appendChildren = [ content ];
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
				textFlow = TextFilter.importFromString(text, "text");
			}
			else
			{
				textFlow = createEmptyTextFlow();
			}
		}

 		contentChanged = false;
		textChanged = false;

        textFlow.blockProgression = blockProgression;
        textFlow.color = color;
        textFlow.direction = direction;
		textFlow.fontFamily = fontFamily;
		textFlow.fontSize = fontSize;
		textFlow.fontStyle = fontStyle;
		textFlow.fontWeight = fontWeight;
		textFlow.kerning = kerning;
		textFlow.lineHeight = lineHeight;
		textFlow.lineBreak = lineBreak;
		textFlow.lineThrough = lineThrough;
		textFlow.marginBottom = marginBottom;
		textFlow.marginLeft = marginLeft;
		textFlow.marginRight = marginRight;
		textFlow.marginTop = marginTop;
		textFlow.paddingBottom = paddingBottom;
		textFlow.paddingLeft = paddingLeft;
		textFlow.paddingRight = paddingRight;
		textFlow.paddingTop = paddingTop;
		textFlow.textAlign = textAlign;
		textFlow.textAlignLast = textAlignLast;
		textFlow.textAlpha = textAlpha;
		textFlow.textDecoration = textDecoration;
		textFlow.textIndent = textIndent;
		textFlow.trackingRight = tracking; // what about trackingLeft?
		textFlow.verticalAlign = verticalAlign;
		textFlow.whitespaceCollapse = whiteSpaceCollapse; // different case

		return textFlow;
	}

	/**
	 *  @private
	 */
	private function compose(width:Number = Infinity,
							 height:Number = Infinity):void
	{
		textFlow = createTextFlow();
		_content = textFlow;

		textFlowComposer.removeTextLines(DisplayObjectContainer(displayObject));
		
		var bounds:Rectangle = textFlowComposer.requestedBounds;
		bounds.x = 0;
		bounds.y = 0;
		bounds.width = width;
		bounds.height = height;

		textFlowComposer.composeTextFlow(textFlow);
		
		textFlowComposer.addTextLines(DisplayObjectContainer(displayObject));
	}
}

}
