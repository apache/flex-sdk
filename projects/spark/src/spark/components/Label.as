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
import flash.display.Graphics;
import flash.display.Shape;
import flash.geom.Rectangle;
import flash.text.engine.EastAsianJustifier;
import flash.text.engine.ElementFormat;
import flash.text.engine.FontDescription;
import flash.text.engine.FontMetrics;
import flash.text.engine.Kerning;
import flash.text.engine.LineJustification;
import flash.text.engine.SpaceJustifier;
import flash.text.engine.TextBlock;
import flash.text.engine.TextElement;
import flash.text.engine.TextLine;
import flash.text.engine.TextLineValidity;

import mx.core.mx_internal;
import mx.graphics.baseClasses.TextGraphicElement;

[DefaultProperty("text")]

//--------------------------------------
//  Styles
//--------------------------------------

include "../styles/metadata/BasicTextLayoutFormatStyles.as"
include "../styles/metadata/NonInheritingTextLayoutFormatStyles.as"

[IconFile("TextBox.png")]

/**
 *  A box, specified in the parent Group element's coordinate space, that contains text.
 *  
 *  <p>The TextBox class is similar to the mx.controls.Label control, although it can display 
 *  multiple lines.</p>
 *  
 *  <p>TextBox does not support drawing a background or border; it only renders text. It supports only the basic formatting styles.
 *  If you want to use more advanced formatting styles, use the TextGraphic or TextView control.</p> 
 *  
 *  <p>The specified text is wrapped at the right edge of the component's bounds. If it extends below the bottom, it is clipped.
 *  The display cannot be scrolled.</p>
 *  
 *  @see mx.components.TextView
 *  @see mx.graphics.TextGraphic
 *  
 *  @includeExample examples/TextBoxExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class TextBox extends TextGraphicElement
{
    include "../core/Version.as";

	//--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------
	    
    // We can re-use single instances of a few FTE classes over and over,
    // since they just serve as a factory for the TextLines that we care about.
    
    /**
	 *  @private
	 */
	private static var staticTextBlock:TextBlock = new TextBlock();

	/**
	 *  @private
	 */
	private static var staticTextElement:TextElement = new TextElement();

    /**
     *  @private
     */
    private static var staticSpaceJustifier:SpaceJustifier =
        new SpaceJustifier();

    /**
     *  @private
     */
    private static var staticEastAsianJustifier:EastAsianJustifier =
        new EastAsianJustifier();

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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function TextBox()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Certain styles require the text to be recomposed when the height
     *  changes.
     */
    override protected function composeOnHeightChange():Boolean
    {
        var verticalAlign:String = getStyle("verticalAlign");
        var topAligned:Boolean = (verticalAlign == "top");

        return !topAligned;
    }

    /**
     *  @private
     *  Certain styles require the text to be recomposed when the width
     *  changes.
     */
    override protected function composeOnWidthChange():Boolean
    {
        var direction:String = getStyle("direction");
        var textAlign:String = getStyle("textAlign");

        var leftAligned:Boolean =
            textAlign == "left" ||
            textAlign == "start" && direction == "ltr" ||
            textAlign == "end" && direction == "rtl";

        return !leftAligned;   
    }
    
    /**
     *  @private
     */
    override protected function composeTextLines(width:Number = NaN,
												 height:Number = NaN):void
    {
        var elementFormat:ElementFormat = createElementFormat();
            
		// Set the composition bounds to be used by createTextLines().
		// If the width or height is NaN, it will be computed by this method
		// by the time it returns.
		// The bounds are then used by the addTextLines() method
		// to determine the isOverset flag.
		// The composition bounds are also reported by the measure() method.
		var bounds:Rectangle = mx_internal::bounds;
        bounds.x = 0;
        bounds.y = 0;
        bounds.width = width;
        bounds.height = height;

        mx_internal::removeTextLines();
		createTextLines(elementFormat);
        mx_internal::addTextLines(DisplayObjectContainer(displayObject));
        
        // Just recomposed so reset.
        mx_internal::stylesChanged = false;                
    }

	/**
	 *  @private
	 *  Creates an ElementFormat (and its FontDescription)
	 *  based on the TextBox's CSS styles.
	 *  These must be recreated each time because FTE
	 *  does not allow them to be reused.
	 */
	private function createElementFormat():ElementFormat
	{
		// When you databind to a text formatting style on a TextBox,
		// as in <TextBox fontFamily="{fontCombo.selectedItem}"/>
		// the databinding can cause the style to be set to null.
		// Setting null values for properties in an FTE FontDescription
		// or ElementFormat throw an error, so the following code does
		// null-checking on the problematic properties.
        
        var s:String;
        
        var fontDescription:FontDescription = new FontDescription();
        
        s = getStyle("cffHinting");
        if (s != null)
        	fontDescription.cffHinting = s;
        
        s = getStyle("fontLookup");
        if (s != null)
        	fontDescription.fontLookup = s;
        
        s = getStyle("fontFamily");
        if (s != null)
        	fontDescription.fontName = s;
        
        s = getStyle("fontStyle");
        if (s != null)
        	fontDescription.fontPosture = s;
        
        s = getStyle("fontWeight");
        if (s != null)
        	fontDescription.fontWeight = s;
        	
        s = getStyle("renderingMode");
        if (s != null)
        	fontDescription.renderingMode = s;
        
        var elementFormat:ElementFormat = new ElementFormat();
        
		s = getStyle("alignmentBaseline");
		if (s != null)
			elementFormat.alignmentBaseline = s;
			
        elementFormat.alpha = getStyle("textAlpha");
        	
        elementFormat.baselineShift = getStyle("baselineShift");
        	
        s = getStyle("breakOpportunity");
        if (s != null)
        	elementFormat.breakOpportunity = s;
        	
        elementFormat.color = getStyle("color");
        
        s = getStyle("digitCase");
        if (s != null)
        	elementFormat.digitCase = s;
        	
        s = getStyle("digitWidth");
        if (s != null)
        	elementFormat.digitWidth = s;
        	
        s = getStyle("dominantBaseline");
        if (s != null)
        	elementFormat.dominantBaseline = s;
        	
        elementFormat.fontDescription = fontDescription;
        
        elementFormat.fontSize = getStyle("fontSize");
        
        setKerning(elementFormat);
        
        s = getStyle("ligatureLevel");
        if (s != null)
        	elementFormat.ligatureLevel = s;
        
        s = getStyle("locale");
        if (s != null)
        	elementFormat.locale = s;
        
        s = getStyle("textRotation");
        if (s != null)
        	elementFormat.textRotation = s;
        
        setTracking(elementFormat);
        
        s = getStyle("typographicCase");
        if (s != null)
        	elementFormat.typographicCase = s;

		return elementFormat;
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
        
        var s:String = String(kerning);
        if (s != null)
           elementFormat.kerning = s;
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

	/**
	 *  @private
	 *  Stuffs the specified text and formatting info into a TextBlock
     *  and uses it to create as many TextLines as fit into the bounds.
	 */
	private function createTextLines(elementFormat:ElementFormat):void
	{
		// Get CSS styles that affect a TextBlock and its justifier.
		var direction:String = getStyle("direction");
        var justificationRule:String = getStyle("justificationRule");
        var justificationStyle:String = getStyle("justificationStyle");
        var textAlign:String = getStyle("textAlign");
        var textAlignLast:String = getStyle("textAlignLast");
        var textJustify:String = getStyle("textJustify");

		// Set the TextBlock's content.
        staticTextElement.text = text;
		staticTextElement.elementFormat = elementFormat;
		staticTextBlock.content = staticTextElement;

        // And its bidiLevel.
		staticTextBlock.bidiLevel = direction == "ltr" ? 0 : 1;

		// And its justifier.
		var lineJustification:String;
		if (textAlign == "justify")
		{
			lineJustification = textAlignLast == "justify" ?
				                LineJustification.ALL_INCLUDING_LAST :
				                LineJustification.ALL_BUT_LAST;
		}
		else
        {
			lineJustification = LineJustification.UNJUSTIFIED;
        }
		if (justificationRule == "space")
		{
            staticSpaceJustifier.lineJustification = lineJustification;
			staticSpaceJustifier.letterSpacing = textJustify == "distribute";
            staticTextBlock.textJustifier = staticSpaceJustifier;
		}
		else
		{
            staticEastAsianJustifier.lineJustification = lineJustification;
            staticEastAsianJustifier.justificationStyle = justificationStyle;
			
            staticTextBlock.textJustifier = staticEastAsianJustifier;
		}
                
		// Then create TextLines using this TextBlock.
		createTextLinesFromTextBlock(staticTextBlock);
	}

	/**
	 *  @private
	 */
	private function createTextLinesFromTextBlock(textBlock:TextBlock):void
	{
		// Clear any previously generated TextLines from the textLines Array.
		mx_internal::textLines.length = 0;
				
		// Get CSS styles for formats that we have to apply ourselves.
		var direction:String = getStyle("direction");
        var lineBreak:String = getStyle("lineBreak");
        var lineHeight:Object = getStyle("lineHeight");
        var lineThrough:Boolean = getStyle("lineThrough");
        var paddingBottom:Number = getStyle("paddingBottom");
        var paddingLeft:Number = getStyle("paddingLeft");
        var paddingRight:Number = getStyle("paddingRight");
        var paddingTop:Number = getStyle("paddingTop");
        var textAlign:String = getStyle("textAlign");
        var textAlignLast:String = getStyle("textAlignLast");
        var textDecoration:String = getStyle("textDecoration");
        var verticalAlign:String = getStyle("verticalAlign");

		var bounds:Rectangle = mx_internal::bounds;

		var innerWidth:Number = bounds.width - paddingLeft - paddingRight;
		var innerHeight:Number = bounds.height - paddingTop - paddingBottom;
		
		if (isNaN(innerWidth))
			innerWidth = TextLine.MAX_LINE_WIDTH;

        var maxLineWidth:Number = lineBreak == "explicit" ?
                                  TextLine.MAX_LINE_WIDTH :
                                  innerWidth;
		
		if (innerWidth < 0 || innerHeight < 0 || !textBlock)
		{
			bounds.width = 0;
			bounds.height = 0;
			return;
		}

		var fontSize:Number = staticTextElement.elementFormat.fontSize;
        var actualLineHeight:Number;
        if (lineHeight is Number)
        {
            actualLineHeight = Number(lineHeight);
        }
        else if (lineHeight is String)
        {
            var len:int = lineHeight.length;
            var percent:Number =
                Number(String(lineHeight).substring(0, len - 1));
            actualLineHeight = percent / 100 * fontSize;
        }
        if (isNaN(actualLineHeight))
            actualLineHeight = 1.2 * fontSize;
        
        var maxTextWidth:Number = 0;
		var totalTextHeight:Number = 0;
		
		var n:int = 0;
		var nextTextLine:TextLine;
		var nextY:Number = 0;
		var textLine:TextLine;
        var createdAllLines:Boolean = false;
		
		// Generate TextLines, stopping when we run out of text
		// or reach the bottom of the requested bounds.
		// In this loop the lines are positioned within the rectangle
		// (0, 0, innerWidth, innerHeight), with top-left alignment.
		while (true)
		{
			nextTextLine = textBlock.createTextLine(textLine, maxLineWidth);
			if (!nextTextLine)
            {
				createdAllLines = true;
                break;
            }
			
			// Determine the natural baseline position for this line.
			// Note: The y coordinate of a TextLine is the location
			// of its baseline, not of its top.
            nextY += (n == 0 ? nextTextLine.ascent : actualLineHeight);
			
			// If it is completely outside the rectangle, we're done.
			if (nextY - nextTextLine.ascent > innerHeight)
				break;

			// We'll keep this line. Put it into the textLines array.
			textLine = nextTextLine;
			mx_internal::textLines[n++] = textLine;
			
			// Assign its location based on left/top alignment.
			// Its x position is 0 by default.
			textLine.y = nextY;
			
			// Keep track of the maximum textWidth 
			// and the accumulated textHeight of the TextLines.
			maxTextWidth = Math.max(maxTextWidth, textLine.textWidth);
			totalTextHeight += textLine.textHeight;

            if (lineThrough || textDecoration == "underline")
            {
                // FTE doesn't render strikethroughs or underlines,
                // but it can tell us where to draw them.
                // You can't draw in a TextLine but it can have children,
                // so we create a child Shape to draw them in.
                
                var elementFormat:ElementFormat =
                    TextElement(textBlock.content).elementFormat;
                var fontMetrics:FontMetrics = elementFormat.getFontMetrics();
                
                var shape:Shape = new Shape();
                var g:Graphics = shape.graphics;
                if (lineThrough)
                {
                    g.lineStyle(fontMetrics.strikethroughThickness, 
                                elementFormat.color, elementFormat.alpha);
                    g.moveTo(0, fontMetrics.strikethroughOffset);
                    g.lineTo(textLine.textWidth, fontMetrics.strikethroughOffset);
                }
                if (textDecoration == "underline")
                {
                    g.lineStyle(fontMetrics.underlineThickness, 
                                elementFormat.color, elementFormat.alpha);
                    g.moveTo(0, fontMetrics.underlineOffset);
                    g.lineTo(textLine.textWidth, fontMetrics.underlineOffset);
                }
                
                textLine.addChild(shape);
            }
		}

		// At this point, n is the number of lines that fit
		// and textLine is the last line that fit.

		if (n == 0)
		{
			bounds.width = paddingLeft + paddingRight;
			bounds.height = paddingTop + paddingBottom;
			return;
		}
		
		if (isNaN(bounds.width))
            bounds.width = paddingLeft + maxTextWidth + paddingRight;
        if (isNaN(bounds.height))
            bounds.height = paddingTop + textLine.y +
							textLine.descent + paddingBottom;
		
		innerWidth = bounds.width - paddingLeft - paddingRight;
		innerHeight = bounds.height - paddingTop - paddingBottom;

        var leftAligned:Boolean = 
            textAlign == "start" && direction == "ltr" ||
            textAlign == "end" && direction == "rtl" ||
            textAlign == "left" ||
            textAlign == "justify";
        var centerAligned:Boolean = textAlign == "center";
        var rightAligned:Boolean =
            textAlign == "start" && direction == "rtl" ||
            textAlign == "end" && direction == "ltr" ||
            textAlign == "right"; 

		// Calculate loop constants for horizontal alignment.
		var leftOffset:Number = bounds.left + paddingLeft;
		var centerOffset:Number = leftOffset + innerWidth / 2;
		var rightOffset:Number =  leftOffset + innerWidth;
		
		// Calculate loop constants for vertical alignment.
		var topOffset:Number = bounds.top + paddingTop;
		var bottomOffset:Number = innerHeight - (textLine.y + textLine.descent);
		var middleOffset:Number = bottomOffset / 2;
		bottomOffset += topOffset;
		middleOffset += topOffset;
		var leading:Number = (innerHeight - totalTextHeight) / (n - 1);
		
		var previousTextLine:TextLine;
		var y:Number = 0;

        var lastLineIsSpecial:Boolean =
            textAlign == "justify" && createdAllLines;

		// Make each line static (which decouples it from the TextBlock
		// that created it and makes it consume less memory)
		// and reposition each line if necessary
		// based on the horizontal and vertical alignment.
		for (var i:int = 0; i < n; i++)
		{
			textLine = TextLine(mx_internal::textLines[i]);

			textLine.validity = TextLineValidity.STATIC;

			// If textAlign is "justify" and there is more than one line,
            // the last one (if we created it) gets horizontal aligned
            // according to textAlignLast.
            if (lastLineIsSpecial && i == n - 1)
            {
                leftAligned = 
                    textAlignLast == "start" && direction == "ltr" ||
                    textAlignLast == "end" && direction == "rtl" ||
                    textAlignLast == "left" ||
                    textAlignLast == "justify";
                centerAligned = textAlignLast == "center";
                rightAligned =
                    textAlignLast == "start" && direction == "rtl" ||
                    textAlignLast == "end" && direction == "ltr" ||
                    textAlignLast == "right";
            } 

            if (leftAligned)
				textLine.x = leftOffset;
			else if (centerAligned)
				textLine.x = centerOffset - textLine.textWidth / 2;
			else if (rightAligned)
				textLine.x = rightOffset - textLine.textWidth;

			if (verticalAlign == "top")
			{
				textLine.y += topOffset;
			}
			else if (verticalAlign == "middle")
			{
				textLine.y += middleOffset;
			}
			else if (verticalAlign == "bottom")
			{
				textLine.y += bottomOffset;
			}
			else if (verticalAlign == "justify")
			{
				// Determine the natural baseline position for this line.
				// Note: The y coordinate of a TextLine is the location
				// of its baseline, not of its top.
				y += i == 0 ?
					 topOffset + textLine.ascent :
					 previousTextLine.descent + leading + textLine.ascent;
			
				textLine.y = y;
				previousTextLine = textLine;
			}
		}
	}
}

}
