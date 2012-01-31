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

	//--------------------------------------------------------------------------
	//
	//  Overridden methods: GraphicElement
	//
	//--------------------------------------------------------------------------

	/**
	 *  @inheritDoc
	 */
    override protected function measure():void
    {
        var width:Number = !isNaN(explicitWidth) ? explicitWidth : Infinity;
        var height:Number = !isNaN(explicitHeight) ? explicitHeight : Infinity;
		compose(width, height);

		var r:Rectangle = textBlockComposer.actualBounds;
		measuredWidth = Math.ceil(r.width);
		measuredHeight = Math.ceil(r.height);
	}
		
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
