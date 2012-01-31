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
import text.model.ICharacterAttributes;
import text.model.IContainerAttributes;
import text.model.IParagraphAttributes;
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

		if (!isNaN(explicitWidth) && !isNaN(explicitHeight))
		{
			w = explicitWidth;
			h = explicitHeight;
		}
		else
		{
			var r:Rectangle = textFlowComposer.bounds;
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
			invalidateSize();
			invalidateDisplayList();
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
            invalidateSize();
			invalidateDisplayList();
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
            invalidateSize();
			invalidateDisplayList();
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
            invalidateSize();
			invalidateDisplayList();
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
            invalidateSize();
			invalidateDisplayList();
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
            invalidateSize();
			invalidateDisplayList();
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
            invalidateSize();
			invalidateDisplayList();
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
			invalidateSize();
			invalidateDisplayList();
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
			invalidateSize();
			invalidateDisplayList();
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
			invalidateSize();
			invalidateDisplayList();
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
			invalidateSize();
			invalidateDisplayList();
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
			invalidateSize();
			invalidateDisplayList();
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
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		
		compose(unscaledWidth, unscaledHeight);
		
		applyDisplayObjectProperties();
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
				textFlow = TextFilter.importFromString(text, TextFilter.PLAIN_TEXT_FORMAT);
			}
			else
			{
				textFlow = createEmptyTextFlow();
			}
		}

 		contentChanged = false;
		textChanged = false;

        var containerAttributes:IContainerAttributes =
            textFlow.containerAttributes;
        var paragraphAttributes:IParagraphAttributes =
            textFlow.paragraphAttributes;
        var characterAttributes:ICharacterAttributes =
            textFlow.characterAttributes;
        
        if (!containerAttributes || containerAttributes.blockProgression == null)
            textFlow.blockProgression = blockProgression;
        if (!characterAttributes || characterAttributes.color == null)
            textFlow.color = color;
        if (!paragraphAttributes || paragraphAttributes.direction == null)
            textFlow.direction = direction;
		if (!characterAttributes || characterAttributes.fontFamily == null)
            textFlow.fontFamily = fontFamily;
		if (!characterAttributes || characterAttributes.fontSize == null)
            textFlow.fontSize = fontSize;
		if (!characterAttributes || characterAttributes.fontStyle == null)
		    textFlow.fontStyle = fontStyle;
		if (!characterAttributes || characterAttributes.fontWeight == null)
		    textFlow.fontWeight = fontWeight;
		if (!characterAttributes || characterAttributes.kerning == null)
		    textFlow.kerning = kerning;
		if (!characterAttributes || characterAttributes.lineHeight == null)
		    textFlow.lineHeight = lineHeight;
		if (!containerAttributes || containerAttributes.lineBreak == null)
		    textFlow.lineBreak = lineBreak;
		if (!characterAttributes || characterAttributes.lineThrough == null)
		    textFlow.lineThrough = lineThrough;
        if (!paragraphAttributes || paragraphAttributes.marginBottom == null)
		    textFlow.marginBottom = marginBottom;
        if (!paragraphAttributes || paragraphAttributes.marginLeft == null)
		    textFlow.marginLeft = marginLeft;
        if (!paragraphAttributes || paragraphAttributes.marginRight == null)
		    textFlow.marginRight = marginRight;
        if (!paragraphAttributes || paragraphAttributes.marginTop == null)
		    textFlow.marginTop = marginTop;
        if (!containerAttributes || containerAttributes.paddingBottom == null)
		    textFlow.paddingBottom = paddingBottom;
        if (!containerAttributes || containerAttributes.paddingLeft == null)
		    textFlow.paddingLeft = paddingLeft;
        if (!containerAttributes || containerAttributes.paddingRight == null)
		    textFlow.paddingRight = paddingRight;
        if (!containerAttributes || containerAttributes.paddingTop == null)
		    textFlow.paddingTop = paddingTop;
        if (!paragraphAttributes || paragraphAttributes.textAlign == null)
		    textFlow.textAlign = textAlign;
        if (!paragraphAttributes || paragraphAttributes.textAlignLast == null)
		    textFlow.textAlignLast = textAlignLast;
		if (!characterAttributes || characterAttributes.textAlpha == null)
		    textFlow.textAlpha = textAlpha;
		if (!characterAttributes || characterAttributes.textDecoration == null)
		    textFlow.textDecoration = textDecoration;
        if (!paragraphAttributes || paragraphAttributes.textIndent == null)
		    textFlow.textIndent = textIndent;
		if (!characterAttributes || characterAttributes.trackingRight == null)
		    textFlow.trackingRight = tracking; // what about trackingLeft?
        if (!containerAttributes || containerAttributes.verticalAlign == null)
		    textFlow.verticalAlign = verticalAlign;
		if (!characterAttributes || characterAttributes.whitespaceCollapse == null)
		    textFlow.whitespaceCollapse = whiteSpaceCollapse; // different case

		return textFlow;
	}

	/**
	 *  @private
	 */
	private function compose(width:Number = NaN,
							 height:Number = NaN):void
	{
		textFlow = createTextFlow();
		_content = textFlow;

		textFlowComposer.removeTextLines(DisplayObjectContainer(displayObject));
		
		var bounds:Rectangle = textFlowComposer.bounds;
		bounds.x = 0;
		bounds.y = 0;
		bounds.width = width;
		bounds.height = height;

		textFlowComposer.composeTextFlow(textFlow);
		
		textFlowComposer.addTextLines(DisplayObjectContainer(displayObject));
	}
}

}
