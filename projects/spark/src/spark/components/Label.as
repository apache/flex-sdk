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

package mx.graphics
{

import flash.display.DisplayObjectContainer;
import flash.geom.Rectangle;
import flash.text.engine.ElementFormat;
import flash.text.engine.FontDescription;
import flash.text.engine.Kerning;

import mx.graphics.graphicsClasses.TextBlockComposer;
import mx.graphics.graphicsClasses.TextGraphicElement;

[DefaultProperty("text")]

//--------------------------------------
//  Styles
//--------------------------------------

include "../styles/metadata/BasicContainerFormatTextStyles.as"
include "../styles/metadata/BasicParagraphFormatTextStyles.as"
include "../styles/metadata/BasicCharacterFormatTextStyles.as"

/**
 *  Documentation is not currently available.
 */
public class TextBox extends TextGraphicElement
{
	include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private static function getNumberOrPercentOf(value:Object,
                                                 n:Number):Number
    {
        // If 'value' is a Number like 10.5, return it.
        if (value is Number)
            return Number(value);

        // If 'value' is a percentage String like "10.5%",
        // return that percentage of 'n'.
        if (value is String)
        {
            var len:int = String(value).length;
            if (len >= 1 && value.charAt(len - 1) == "%")
            {
                var percent:Number = Number(value.substring(0, len - 1));
                return percent / 100 * n;
            }
        }

        // Otherwise, return NaN.
        return NaN;
    }

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
        super.measure();

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
		fontDescription.cffHinting = getStyle("cffHinting");
		fontDescription.fontLookup = getStyle("fontLookup");
		fontDescription.fontName = getStyle("fontFamily");
		fontDescription.fontPosture = getStyle("fontStyle");
		fontDescription.fontWeight = getStyle("fontWeight");
		fontDescription.renderingMode = getStyle("renderingMode");
		
		var elementFormat:ElementFormat = new ElementFormat();
		elementFormat.alignmentBaseline = getStyle("alignmentBaseline");
		elementFormat.alpha = getStyle("textAlpha");
        elementFormat.baselineShift = getStyle("baselineShift");
        elementFormat.color = getStyle("color");
        elementFormat.digitCase = getStyle("digitCase");
        elementFormat.digitWidth = getStyle("digitWidth");
        elementFormat.dominantBaseline = getStyle("dominantBaseline");
		elementFormat.fontDescription = fontDescription;
		elementFormat.fontSize = getStyle("fontSize");
        setKerning(elementFormat);
		elementFormat.ligatureLevel = getStyle("ligatureLevel");
		elementFormat.locale = getStyle("locale");
		elementFormat.textRotation = getStyle("textRotation");
        setTracking(elementFormat);
		elementFormat.typographicCase = getStyle("typographicCase");
        
		textBlockComposer.removeTextLines(
            DisplayObjectContainer(displayObject));
		
		var bounds:Rectangle = textBlockComposer.requestedBounds;
		bounds.x = 0;
		bounds.y = 0;
		bounds.width = width;
		bounds.height = height;

		textBlockComposer.lineHeight = getStyle("lineHeight");
		textBlockComposer.paddingBottom = getStyle("paddingBottom");
		textBlockComposer.paddingLeft = getStyle("paddingLeft");
		textBlockComposer.paddingRight = getStyle("paddingRight");
		textBlockComposer.paddingTop = getStyle("paddingTop");
		textBlockComposer.textAlign = getStyle("textAlign");
		textBlockComposer.verticalAlign = getStyle("verticalAlign");

		textBlockComposer.composeText(text, elementFormat);
				
		textBlockComposer.addTextLines(DisplayObjectContainer(displayObject));
	}

	/**
	 *  @private
	 */
    private function setKerning(elementFormat:ElementFormat):void
    {
        var kerning:Object = getStyle("kerning");
        
        if (kerning === true)
            kerning = Kerning.ON;
        else if (kerning === false)
            kerning = Kerning.OFF;
        
        elementFormat.kerning = String(kerning);
    }

	/**
	 *  @private
	 */
    private function setTracking(elementFormat:ElementFormat):void
    {
        var trackingLeft:Object = getStyle("trackingLeft");
        var trackingRight:Object = getStyle("trackingRight");
        
        if (trackingRight == null)
            trackingRight = getStyle("tracking");

        var value:Number;
        var fontSize:Number = elementFormat.fontSize;
       
        value = getNumberOrPercentOf(trackingLeft, fontSize);
        if (!isNaN(value))
            elementFormat.trackingLeft = value;

        value = getNumberOrPercentOf(trackingRight, fontSize);
        if (!isNaN(value))
            elementFormat.trackingRight = value;
    }
}

}
