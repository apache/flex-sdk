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
import flash.text.engine.ElementFormat;
import flash.text.engine.FontDescription;

import flex.graphics.graphicsClasses.TextBlockComposer;
import flex.graphics.graphicsClasses.TextGraphicElement;

[DefaultProperty("text")]

/**
 *  Documentation is not currently available.
 */
public class TextBox extends TextGraphicElement
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
	public function TextBox()
	{
		super();
	}
	
	//--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
	
	/**
	 *  @private
	 */
	private var textBlockComposer:TextBlockComposer = new TextBlockComposer();

	/**
	 *  @private
	 *  This flag is set to true by the text, width, and height setters,
	 *  to indicate that the TextLines must be regenerated.
	 *  The regeneration occurs when draw() is called or 'bounds' is read.
	 */
	private var invalid:Boolean = false;
	
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
			var r:Rectangle = textBlockComposer.actualBounds;
			w = Math.ceil(r.width);
			h = Math.ceil(r.height);
		}

		_bounds.width = w;
		_bounds.height = h;
				
		return _bounds;
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
	private function compose(width:Number = Infinity,
							 height:Number = Infinity):void
	{
		var fontDescription:FontDescription = new FontDescription();
		fontDescription.fontName = fontFamily;
		fontDescription.fontPosture = fontStyle;
		fontDescription.fontWeight = fontWeight;
		
		var elementFormat:ElementFormat = new ElementFormat();
		elementFormat.alpha = textAlpha;
        elementFormat.color = color;
		elementFormat.fontDescription = fontDescription;
		elementFormat.fontSize = fontSize;
		elementFormat.kerning = kerning;
        if (tracking is Number)
        {
            elementFormat.trackingRight = Number(tracking);
        }
        else if (tracking is String) 
        {
            var len:int = String(tracking).length;
            if (tracking.charAt(len - 1) == "%")
            {
                var percent:Number = Number(tracking.substring(0, len - 1));
                elementFormat.trackingRight = percent / 100 * fontSize;
            }
        }

		textBlockComposer.removeTextLines(DisplayObjectContainer(displayObject));
		
		var bounds:Rectangle = textBlockComposer.requestedBounds;
		bounds.x = 0;
		bounds.y = 0;
		bounds.width = width;
		bounds.height = height;

		textBlockComposer.lineHeight = lineHeight;
		textBlockComposer.paddingLeft = paddingLeft;
		textBlockComposer.paddingTop = paddingTop;
		textBlockComposer.paddingRight = paddingRight;
		textBlockComposer.paddingBottom = paddingBottom;
		textBlockComposer.textAlign = textAlign;
		textBlockComposer.verticalAlign = verticalAlign;

		textBlockComposer.composeText(text, elementFormat);
				
		textBlockComposer.addTextLines(DisplayObjectContainer(displayObject));
	}
}

}
