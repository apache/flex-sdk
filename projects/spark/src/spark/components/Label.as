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
import flash.text.engine.TabStop;

import mx.core.mx_internal;
import mx.graphics.graphicsClasses.TextBlockComposer;
import mx.graphics.graphicsClasses.TextGraphicElement;

[DefaultProperty("text")]

//--------------------------------------
//  Styles
//--------------------------------------

include "../styles/metadata/BasicContainerFormatTextStyles.as"
include "../styles/metadata/BasicParagraphFormatTextStyles.as"
include "../styles/metadata/BasicCharacterFormatTextStyles.as"

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
    //  Overridden properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  baselinePosition
    //----------------------------------

    [Inspectable(category="General")]

    /**
     *  @private
     */
    override public function get baselinePosition():Number
    {
        mx_internal::validateBaselinePosition();
        
        // Return the baseline of the first line of composed text.
        return (textBlockComposer.textLines.length > 0) ? 
            textBlockComposer.textLines[0].y : 0;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: GraphicElement
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function measure():void
    {
        super.measure();

        // The measure() method of a GraphicElement can get called
        // when its style chain hasn't been initialized.
        // In that case, compose() must not be called.
        if (!mx_internal::styleChainInitialized)
            return;

        compose(explicitWidth, explicitHeight);

        var r:Rectangle = textBlockComposer.bounds;
        measuredWidth = Math.ceil(r.width);
        measuredHeight = Math.ceil(r.height);
    }
        
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, 
                                                  unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        // The updateDisplayList() method of a GraphicElement can get called
        // when its style chain hasn't been initialized.
        // In that case, compose() must not be called.
        if (!mx_internal::styleChainInitialized)
            return;

        var overset:Boolean = compose(unscaledWidth, unscaledHeight);

        mx_internal::clip(overset, unscaledWidth, unscaledHeight);
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private function compose(width:Number = NaN, height:Number = NaN):Boolean
    {
        var container:DisplayObjectContainer = 
            DisplayObjectContainer(displayObject);
            
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
        
        textBlockComposer.removeTextLines(container);
        
        var bounds:Rectangle = textBlockComposer.bounds;
        bounds.x = 0;
        bounds.y = 0;
        bounds.width = width;
        bounds.height = height;

        textBlockComposer.direction = getStyle("direction");
        textBlockComposer.justificationRule = getStyle("justificationRule");
        textBlockComposer.justificationStyle = getStyle("justificationStyle");
        textBlockComposer.lineBreak = getStyle("lineBreak");
        textBlockComposer.lineHeight = getStyle("lineHeight");
        textBlockComposer.lineThrough = getStyle("lineThrough");
        textBlockComposer.paddingBottom = getStyle("paddingBottom");
        textBlockComposer.paddingLeft = getStyle("paddingLeft");
        textBlockComposer.paddingRight = getStyle("paddingRight");
        textBlockComposer.paddingTop = getStyle("paddingTop");
        setTabStops(textBlockComposer);
        textBlockComposer.textAlign = getStyle("textAlign");
        textBlockComposer.textAlignLast = getStyle("textAlignLast");
        textBlockComposer.textDecoration = getStyle("textDecoration");
        textBlockComposer.textJustify = getStyle("textJustify");
        textBlockComposer.verticalAlign = getStyle("verticalAlign");

        textBlockComposer.composeText(text, elementFormat);
                
        textBlockComposer.addTextLines(container);

        return textBlockComposer.isOverset;
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
     */
    private function setTabStops(textBlockComposer:TextBlockComposer):void
    {
        var value:* = getStyle("tabStops");
        var tabStops:Vector.<TabStop>;
        
        if (value is Vector.<TabStop>)
        {
            tabStops = value;
        }
        else if (value is Array)
        {
            var n:int = value.length;
            tabStops = new Vector.<TabStop>(n);
            for (var i:int = 0; i < n; i++)
            {
                tabStops[i] = value[i];
            }
        }
        else
        {
            tabStops = new Vector.<TabStop>();
        }   

        textBlockComposer.tabStops = tabStops;
    }
}

}
