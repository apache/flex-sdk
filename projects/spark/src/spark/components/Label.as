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

package spark.components
{

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.Shape;
import flash.geom.Rectangle;
import flash.text.TextFormat;
import flash.text.engine.EastAsianJustifier;
import flash.text.engine.ElementFormat;
import flash.text.engine.FontDescription;
import flash.text.engine.FontLookup;
import flash.text.engine.FontMetrics;
import flash.text.engine.Kerning;
import flash.text.engine.LineJustification;
import flash.text.engine.SpaceJustifier;
import flash.text.engine.TextBaseline;
import flash.text.engine.TextBlock;
import flash.text.engine.TextElement;
import flash.text.engine.TextLine;

import flashx.textLayout.compose.ISWFContext;
import flashx.textLayout.compose.TextLineRecycler;

import mx.core.IEmbeddedFontRegistry;
import mx.core.IFlexModuleFactory;
import mx.core.IFontContextComponent;
import mx.core.IUIComponent;
import mx.core.Singleton;
import mx.core.mx_internal;
import mx.managers.ISystemManager;

import spark.components.supportClasses.TextBase;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

include "../styles/metadata/BasicInheritingTextStyles.as"
include "../styles/metadata/BasicNonInheritingTextStyles.as"

//--------------------------------------
//  Other metadata
//--------------------------------------

[DefaultProperty("text")]

[IconFile("Label.png")]

/**
 *  Label is a low-level UIComponent that can render
 *  one or more lines of uniformly-formatted text.
 *  The text to be displayed is determined by the
 *  <code>text</code> property inherited from TextBase.
 *  The formatting of the text is specified by the element's CSS styles,
 *  such as <code>fontFamily</code> and <code>fontSize</code>.
 *
 *  <p>Label, which is new with Flex 4, makes use of the new
 *  Flash Text Engine (FTE) in Flash Player 10 to provide high-quality
 *  international typography.
 *  Because Label is fast and lightweight, it is especially suitable
 *  for use cases that involve rendering many small pieces of non-interactive
 *  text, such as item renderers, labels in Button skins, etc.</p>
 *
 *  <p>The Spark architecture provides three text "primitives" -- 
 *  Label, RichText, and RichEditableText --
 *  as part of its pay-only-for-what-you-need philosophy.
 *  Label is the fastest and most lightweight,
 *  but is limited in its capabilities: no complex formatting,
 *  no scrolling, no selection, no editing, and no hyperlinks.
 *  RichText and RichEditableText are built on the Text Layout
 *  Framework (TLF) library, rather than on FTE.
 *  RichText adds the ability to render rich HTML-like text
 *  with complex formatting, but is still completely non-interactive.
 *  RichEditableText is the slowest and heaviest,
 *  but can do it all: it supports scrolling with virtualized TextLines,
 *  selection, editing, hyperlinks, images loaded from URLs, etc.
 *  You should use the fastest one that meets your needs.</p>
 *
 *  <p>spark.components.Label is similar to the older MX control mx.controls.Label.
 *  The most important differences to understand are
 *  <ul>
 *    <li>Spark Label uses FTE, the player's new text engine,
 *        while MX Label uses the obsolete TextField class.</li>
 *    <li>Spark Label offers better typography, and better support
 *        for international languages, than MX Label.</li>
 *    <li>Spark Label can display multiple lines, which MX Label cannot.</li>
 *    <li>MX Label can display a limited subset of HTML,
 *        while Spark Label can only display text with uniform formatting.</li>
 *    <li>MX Label can be made selectable, while Label cannot.</li>
 *  </ul></p>
 *
 *  <p>In Spark Label, three character sequences are recognized
 *  as explicit line breaks: CR (<code>"\r"</code>), LF (<code>"\n"</code>),
 *  and CR+LF (<code>"\r\n"</code>).</p>
 *
 *  <p>If you don't specify any kind of width for a Label,
 *  then the longest line, as determined by these explicit line breaks,
 *  will determine the width of the Label.</p>
 *
 *  <p>If you do specify some kind of width, then the specified text is
 *  word-wrapped at the right edge of the component's bounds, because the
 *  default value of the <code>lineBreak</code> style is <code>"toFit"</code>.
 *  If the text extends below the bottom of the component,
 *  it will be clipped.</p>
 *
 *  <p>To disable this automatic wrapping, set the <code>lineBreak</code>
 *  style to <code>"explicit"</code>. Then lines will be broken only where
 *  the <code>text</code> contains an explicit line break,
 *  and the ends of lines extending past the right edge will be clipped.</p>
 *
 *  <p>If you have more text than you have room to display it,
 *  Label can truncate the text for you.
 *  Truncating text means replacing excess text
 *  with a truncation indicator such as "...".
 *  See the inherited properties <code>maxDisplayedLines</code>
 *  and <code>isTruncated</code>.</p>
 *
 *  <p>You can control the line spacing with the <code>lineHeight</code> style.
 *  You can horizontally and vertically align the text within the element's
 *  bounds using the <code>textAlign</code>, <code>textAlignLast</code>,
 *  and <code>verticalAlign</code> styles.
 *  You can inset the text from the element's edges using the
 *  <code>paddingLeft</code>, <code>paddingTop</code>, 
 *  <code>paddingRight</code>, and <code>paddingBottom</code> styles.</p>
 *
 *  <p>By default a Label has no background,
 *  but you can draw one using the <code>backgroundColor</code>
 *  and <code>backgroundAlpha</code> styles.
 *  Borders are not supported.
 *  If you need a border, or a more complicated background, use a separate
 *  graphic element, such as a Rect, behind the Label.</p>
 *
 *  <p>Label supports displaying left-to-right (LTR) text such as French,
 *  right-to-left (RTL) text such as Arabic, and bidirectional text
 *  such as a French phrase inside of an Arabic paragraph.
 *  If the predominant text direction is right-to-left,
 *  set the <code>direction</code> style to <code>"rtl"</code>.
 *  The <code>textAlign</code> style defaults to <code>"start"</code>,
 *  which makes the text left-aligned when <code>direction</code>
 *  is <code>"ltr"</code> and right-aligned when <code>direction</code>
 *  is <code>"rtl"</code>.
 *  To get the opposite alignment,
 *  set <code>textAlign</code> to <code>"end"</code>.</p>
 *
 *  <p>Label uses the TextBlock class in the Flash Text Engine
 *  to create one or more TextLine objects to statically display
 *  its text String in the format determined by its CSS styles.
 *  For performance, its TextLines do not contain information
 *  about individual glyphs; for more info, see
 *  flash.text.engine.TextLineValidity.STATIC.</p>
 *
 *  @see spark.components.RichEditableText
 *  @see spark.components.RichText
 *  
 *  @includeExample examples/LabelExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class Label extends TextBase
	implements IFontContextComponent
{
    include "../core/Version.as";

	//--------------------------------------------------------------------------
    //
    //  Class initialization
    //
    //--------------------------------------------------------------------------
	
    /**
	 *  @private
	 */
	private static function initClass():void
	{
		staticTextBlock = new TextBlock();
		
		staticTextElement = new TextElement();
		
		staticSpaceJustifier = new SpaceJustifier();
		
		staticEastAsianJustifier = new EastAsianJustifier();
		
		staticTextFormat = new TextFormat();

		if ("recreateTextLine" in staticTextBlock)
			recreateTextLine = staticTextBlock["recreateTextLine"];
	}
	
	initClass();

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
	private static var staticTextBlock:TextBlock;

	/**
	 *  @private
	 */
	private static var staticTextElement:TextElement;

    /**
     *  @private
     */
    private static var staticSpaceJustifier:SpaceJustifier;

    /**
     *  @private
     */
    private static var staticEastAsianJustifier:EastAsianJustifier;
    
    /**
     *  @private
     *  Used in getEmbeddedFontContext().
     */
    private static var staticTextFormat:TextFormat;
        
    /**
     *  @private
     *  A reference to the recreateTextLine() method in staticTextBlock,
     *  if it exists. This method was added in player 10.1.
     *  It allows better performance by making it possible to reuse
     *  existing TextLines instead of having to create new ones.
     */
    private static var recreateTextLine:Function;

	//--------------------------------------------------------------------------
    //
    //  Class properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  embeddedFontRegistry
    //----------------------------------

    /**
     *  @private
     *  Storage for the _embeddedFontRegistry property.
     *  Note: This gets initialized on first access,
     *  not when this class is initialized, in order to ensure
     *  that the Singleton registry has already been initialized.
     */
    private static var _embeddedFontRegistry:IEmbeddedFontRegistry;

    /**
     *  @private
     *  A reference to the embedded font registry.
     *  Single registry in the system.
     *  Used to look up the moduleFactory of a font.
     */
    private static function get embeddedFontRegistry():IEmbeddedFontRegistry
    {
        if (!_embeddedFontRegistry)
        {
            _embeddedFontRegistry = IEmbeddedFontRegistry(
                Singleton.getInstance("mx.core::IEmbeddedFontRegistry"));
        }

        return _embeddedFontRegistry;
    }

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
    public function Label()
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
     *  Holds the last recorded value of the module factory
     *  used to create the font.
     */
    private var embeddedFontContext:IFlexModuleFactory;

    //--------------------------------------------------------------------------
    //
    //  Properties: IFontContextComponent
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  fontContext
    //----------------------------------
    
    /**
     *  @private
     */
    private var _fontContext:IFlexModuleFactory;

    /**
     *  @inheritDoc
     */
    public function get fontContext():IFlexModuleFactory
    {
        return _fontContext;
    }

    /**
     *  @private
     */
    public function set fontContext(value:IFlexModuleFactory):void
    {
        _fontContext = value;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: TextBase
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  This helper method is used by measure() and updateDisplayList().
     *  It composes TextLines to render the 'text' String,
     *  using the staticTextBlock as a factory,
     *  and using the 'width' and 'height' parameters to define the size
     *  of the composition rectangle, with NaN meaning "no limit".
     *  It stops composing when the composition rectangle has been filled.
     *  Returns true if all lines were composed, otherwise false.
     */
    override mx_internal function composeTextLines(width:Number = NaN,
												   height:Number = NaN):Boolean
    {
        super.composeTextLines(width, height);
        
        var elementFormat:ElementFormat = createElementFormat();
            
		// Set the composition bounds to be used by createTextLines().
		// If the width or height is NaN, it will be computed by this method
		// by the time it returns.
		// The bounds are then used by the addTextLines() method
		// to determine the isOverset flag.
		// The composition bounds are also reported by the measure() method.
        bounds.x = 0;
        bounds.y = 0;
        bounds.width = width;
        bounds.height = height;

        // Remove the TextLines from the container and then release them for
        // reuse, if supported by the player.
        removeTextLines();
        releaseTextLines();
        
		// Create the TextLines.
		var allLinesComposed:Boolean = createTextLines(elementFormat);
        
        // Need truncation if all the following are true
        // - truncation options exist (0=no trunc, -1=fill up bounds then trunc,
        //      n=n lines then trunc)
        // - compose width is specified
        // - explicit line breaking is not used
        // - content doesn't fit
        if (maxDisplayedLines && getStyle("lineBreak") == "toFit" &&
            !doesComposedTextFit(height, allLinesComposed, maxDisplayedLines))
        {
            truncateText(width, height);
        }
        
        // Detach the TextLines from the TextBlock that created them.
        releaseLinesFromTextBlock();
                                                       
        // Add the new text lines to the container.
        addTextLines();

        // Figure out if a scroll rect is needed.
        isOverset = isTextOverset(width, height);
        
        // Just recomposed so reset.
        invalidateCompose = false;     
        
        return allLinesComposed;           
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Creates an ElementFormat (and its FontDescription)
	 *  based on the Label's CSS styles.
	 *  These must be recreated each time because FTE
	 *  does not allow them to be reused.
	 *  As a side effect, this method also sets embeddedFontContext
	 *  so that we know which SWF should be used to create TextLines.
	 *  (TextLines using an embedded font must be created in the SWF
	 *  where the font is.)
	 */
	private function createElementFormat():ElementFormat
	{
		// When you databind to a text formatting style on a Label,
		// as in <Label fontFamily="{fontCombo.selectedItem}"/>
		// the databinding can cause the style to be set to null.
		// Setting null values for properties in an FTE FontDescription
		// or ElementFormat throw an error, so the following code does
		// null-checking on the problematic properties.

        var s:String;
        
        // If the CSS styles for this component specify an embedded font,
        // embeddedFontContext will be set to the module factory that
        // should create TextLines (since they must be created in the
        // SWF where the embedded font is.)
        // Otherwise, this will be null.
        embeddedFontContext = getEmbeddedFontContext();

        // Fill out a FontDescription based on the CSS styles.
        
        var fontDescription:FontDescription = new FontDescription();
        
        s = getStyle("cffHinting");
        if (s != null)
        	fontDescription.cffHinting = s;
        
        s = getStyle("fontLookup");
        if (s != null)
        {
        	// FTE understands only "device" and "embeddedCFF"
        	// for fontLookup. But Flex allows this style to be
        	// set to "auto", in which case we automatically
        	// determine it based on whether the CSS styles
        	// specify an embedded font.
        	if (s == "auto")
        	{
        		s = embeddedFontContext ?
        			FontLookup.EMBEDDED_CFF :
                	FontLookup.DEVICE;
        	}
	       	fontDescription.fontLookup = s;
        }
        
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
        
        // Fill our an ElementFormat based on the CSS styles.
        
        var elementFormat:ElementFormat = new ElementFormat();
        
		s = getStyle("alignmentBaseline");
		if (s != null)
			elementFormat.alignmentBaseline = s;
			
        elementFormat.alpha = getStyle("textAlpha");
        	
        elementFormat.baselineShift = -getStyle("baselineShift");
			// Note: The negative sign is because, as in TLF,
			// we want a positive number to shift the baseline up,
			// whereas FTE does it the opposite way.
			// In FTE, a positive baselineShift increases
			// the y coordinate of the baseline, which is
			// mathematically appropriate, but unintuitive.
        	
        // Note: Label doesn't support a breakOpportunity style,
		// so we leave elementFormat.breakOpportunity with its
		// default value of "auto".
        	
        elementFormat.color = getStyle("color");
        
        s = getStyle("digitCase");
        if (s != null)
        	elementFormat.digitCase = s;
        	
        s = getStyle("digitWidth");
        if (s != null)
        	elementFormat.digitWidth = s;
        	
        s = getStyle("dominantBaseline");
        if (s != null)
		{
        	// TLF adds the concept of a locale-based "auto" setting for
			// dominantBaseline, so we support that in Label as well
			// so that "auto" can be used in the global selector.
			// TLF's rule is that "auto" means "ideographicCenter"
			// for Japanese and Chinese locales and "roman" for other locales.
			// (See TLF's LocaleUtil, which we avoid linking in here.)
			if (s == "auto")
			{
				s = TextBaseline.ROMAN;
				var locale:String = getStyle("locale");
				if (locale != null)
				{
					var lowercaseLocale:String = locale.toLowerCase();
					if (lowercaseLocale.indexOf("ja") == 0 ||
						lowercaseLocale.indexOf("zh") == 0)
					{
						s = TextBaseline.IDEOGRAPHIC_CENTER;
					}
				}
			}
			elementFormat.dominantBaseline = s;
		}
        	
        elementFormat.fontDescription = fontDescription;
        
        elementFormat.fontSize = getStyle("fontSize");
        
        setKerning(elementFormat);
        
        s = getStyle("ligatureLevel");
        if (s != null)
        	elementFormat.ligatureLevel = s;
        
        s = getStyle("locale");
        if (s != null)
        	elementFormat.locale = s;
        
        setTracking(elementFormat);
        
        s = getStyle("typographicCase");
        if (s != null)
        	elementFormat.typographicCase = s;

		return elementFormat;
	}
	
	/**
	 *  @private
	 *  Uses the component's CSS styles to determine the module factory
	 *  that should creates its TextLines.
	 */
	private function getEmbeddedFontContext():IFlexModuleFactory
	{
		var moduleFactory:IFlexModuleFactory;
		
		var fontLookup:String = getStyle("fontLookup");
		if (fontLookup != FontLookup.DEVICE)
        {
			var font:String = getStyle("fontFamily");
			var bold:Boolean = getStyle("fontWeight") == "bold";
			var italic:Boolean = getStyle("fontStyle") == "italic";
			
            moduleFactory = embeddedFontRegistry.getAssociatedModuleFactory(
            	font, bold, italic,
                this, fontContext);

            // If we found the font, then it is embedded. 
            // But some fonts are not listed in info()
            // and are therefore not in the above registry.
            // So we call isFontFaceEmbedded() which gets the list
            // of embedded fonts from the player.
            if (!moduleFactory) 
            {
                var sm:ISystemManager;
                if (fontContext != null && fontContext is ISystemManager)
                	sm = ISystemManager(fontContext);
                else if (parent is IUIComponent)
                	sm = IUIComponent(parent).systemManager;

                staticTextFormat.font = font;
                staticTextFormat.bold = bold;
                staticTextFormat.italic = italic;
                
                if (sm != null && sm.isFontFaceEmbedded(staticTextFormat))
                    moduleFactory = sm;
            }
        }

        if (!moduleFactory && fontLookup == FontLookup.EMBEDDED_CFF)
        {
            // if we couldn't find the font and somebody insists it is
            // embedded, try the default fontContext
            moduleFactory = fontContext;
        }
        
        return moduleFactory;
	}

    /**
     *  @private
     */
    private function setKerning(elementFormat:ElementFormat):void
    {
        var kerning:Object = getStyle("kerning");
        
		// In Halo components based on TextField,
		// kerning is supposed to be true or false.
		// The default in TextField and Flex 3 is false
		// because kerning doesn't work for device fonts
		// and is slow for embedded fonts.
		// In Spark components based on TLF and FTE,
		// kerning is "auto", "on", or, "off".
		// The default in TLF and FTE is "auto"
		// (which means kern non-Asian characters)
		// because kerning works even on device fonts
		// and has miminal performance impact.
        // Since a CSS selector or parent container
		// can affect both Halo and Spark components,
		// we need to map true to "on" and false to "off"
		// here and in Label.
		// For Halo components, UITextField and UIFTETextField
		// do the opposite mapping
		// of "auto" and "on" to true and "off" to false.
		// We also support a value of "default"
		// (which we set in the global selector)
		// to mean "auto" for Spark and false for Halo
		// to get the recommended behavior in both sets of components.
        if (kerning === "default")
			kerning = Kerning.AUTO;
		else if (kerning === true)
            kerning = Kerning.ON;
        else if (kerning === false)
            kerning = Kerning.OFF;
        
        if (kerning != null)
           elementFormat.kerning = String(kerning);
    }

    /**
     *  @private
     */
    private function setTracking(elementFormat:ElementFormat):void
    {
        var trackingLeft:Object = getStyle("trackingLeft");
        var trackingRight:Object = getStyle("trackingRight");
        
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
     *  Returns true if all the text was composed into textLines.
	 */
	private function createTextLines(elementFormat:ElementFormat):Boolean
	{
		// Get CSS styles that affect a TextBlock and its justifier.
		var direction:String = getStyle("direction");
        var justificationRule:String = getStyle("justificationRule");
        var justificationStyle:String = getStyle("justificationStyle");
        var textAlign:String = getStyle("textAlign");
        var textAlignLast:String = getStyle("textAlignLast");
        var textJustify:String = getStyle("textJustify");

        // TLF adds the concept of a locale-based "auto" setting for
		// justificationRule and justificationStyle, so we support
		// that in Label as well so that "auto" can be used
		// in the global selector.
		// TLF's rule is that "auto" for justificationRule means "eastAsian"
		// for Japanese and Chinese locales and "space" for other locales,
		// and that "auto" for justificationStyle (which only affects
		// the EastAsianJustifier) always means "pushInKinsoku".
		// (See TLF's LocaleUtil, which we avoid linking in here.)
		if (justificationRule == "auto")
		{
			justificationRule = "space";
			var locale:String = getStyle("locale");
			if (locale != null)
			{
				var lowercaseLocale:String = locale.toLowerCase();
				if (lowercaseLocale.indexOf("ja") == 0 ||
					lowercaseLocale.indexOf("zh") == 0)
				{
					justificationRule = "eastAsian";
				}
			}
		}
		if (justificationStyle == "auto")
			justificationStyle = "pushInKinsoku";

		// Set the TextBlock's content.
		// Note: If there is no text, we do what TLF does and compose
		// a paragraph terminator character, so that a TextLine
		// gets created and we can measure it.
		// It will have a width of 0 but a height equal
		// to the font's ascent plus descent.
        staticTextElement.text = text != null && text.length > 0 ? text : "\u2029";
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
		return createTextLinesFromTextBlock(staticTextBlock, textLines, bounds);
	}

	/**
	 *  @private
	 *  Compose into textLines.  bounds on input is size of composition
	 *  area and on output is the size of the composed content.
	 *  The caller must call releaseLinesFromTextBlock() to release the
	 *  textLines from the TextBlock.  This must be done after truncation
	 *  so that the composed lines can be broken into atoms to figure out
	 *  where the truncation indicator should be placed.
	 * 
     *  Returns true if all the text was composed into textLines.
	 */
	private function createTextLinesFromTextBlock(textBlock:TextBlock,
                	                              textLines:Vector.<DisplayObject>,
                	                              bounds:Rectangle):Boolean
	{
		// Start with 0 text lines.
		releaseTextLines(textLines);
	       
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

		var innerWidth:Number = bounds.width - paddingLeft - paddingRight;
		var innerHeight:Number = bounds.height - paddingTop - paddingBottom;
		
        var measureWidth:Boolean = isNaN(innerWidth);
		if (measureWidth)
			innerWidth = maxWidth;

        var maxLineWidth:Number = lineBreak == "explicit" ?
                                  TextLine.MAX_LINE_WIDTH :
                                  innerWidth;
		
		if (innerWidth < 0 || innerHeight < 0 || !textBlock)
		{
			bounds.width = 0;
			bounds.height = 0;
			return false;
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
        
        var swfContext:ISWFContext = ISWFContext(embeddedFontContext);
        			
		// For truncation, need to know if all lines have been composed.
        var createdAllLines:Boolean = false;
        
		// Generate TextLines, stopping when we run out of text
		// or reach the bottom of the requested bounds.
		// In this loop the lines are positioned within the rectangle
		// (0, 0, innerWidth, innerHeight), with top-left alignment.
		while (true)
		{
            var recycleLine:TextLine = TextLineRecycler.getLineForReuse();
            if (recycleLine)
            {
                if (swfContext)
                {
                    nextTextLine = swfContext.callInContext(
						textBlock["recreateTextLine"], textBlock,
						[ recycleLine, textLine, maxLineWidth ]);		
                }        
                else
                {
                    nextTextLine = recreateTextLine(
                    	recycleLine, textLine, maxLineWidth);
                }  
		    }
		    else
		    {
                if (swfContext)
                {
                    nextTextLine = swfContext.callInContext(
						textBlock.createTextLine, textBlock,
						[ textLine, maxLineWidth ]);
                }
                else
                {
    			    nextTextLine = textBlock.createTextLine(
    			    	textLine, maxLineWidth);
                }
            }
            
			if (!nextTextLine)
            {
				createdAllLines = true;
                break;
            }
			
			// Determine the natural baseline position for this line.
			// Note: The y coordinate of a TextLine is the location
			// of its baseline, not of its top.
            nextY += (n == 0 ? nextTextLine.ascent : actualLineHeight);
			
			// If verticalAlign is top and the next line is completely outside 
			// the rectangle, we're done.  If verticalAlign is middle or bottom
			// then we need to compose all the lines so the alignment is done
			// correctly.
			if (verticalAlign == "top" && 
			    nextY - nextTextLine.ascent > innerHeight)
			{
				break;
			}

			// We'll keep this line. Put it into the textLines array.
			textLine = nextTextLine;
			textLines[n++] = textLine;

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
                var fontMetrics:FontMetrics;
                if (embeddedFontContext)
                    fontMetrics = embeddedFontContext.callInContext(elementFormat.getFontMetrics, elementFormat, null);
                else
                    fontMetrics = elementFormat.getFontMetrics();
                
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
			return createdAllLines;
		}
		
        // If not measuring the width, innerWidth remains the same since 
        // alignment is done over the innerWidth not over the width of the
        // text that was just composed.
        if (measureWidth)
            innerWidth = maxTextWidth;

        if (isNaN(bounds.height))
            innerHeight = textLine.y + textLine.descent;
		
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

        var minX:Number = innerWidth;
        var minY:Number = innerHeight;
        var maxX:Number = 0;
        
        var clipping:Boolean = (n) ? (textLines[n - 1].y + TextLine(textLines[n - 1]).descent > innerHeight) : false;

		// Reposition each line if necessary.
		// based on the horizontal and vertical alignment.
		for (var i:int = 0; i < n; i++)
		{
			textLine = TextLine(textLines[i]);

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

			if (verticalAlign == "top" || !createdAllLines || clipping)
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

            // Upper left corner of bounding box may not be 0,0 after
            // styles are applied or rounding error from minY calculation.
            // y is one decimal place and ascent isn't rounded so minY can be 
            // slightly less than zero. 
            minX = Math.min(minX, textLine.x);             
            minY = Math.min(minY, textLine.y - textLine.ascent);
            maxX = Math.max(maxX, textLine.x + textLine.textWidth); 
		}

        bounds.x = minX - paddingLeft;
        bounds.y = minY - paddingTop;
        bounds.right = maxX + paddingRight;
        bounds.bottom = textLine.y + textLine.descent + paddingBottom;
        
        return createdAllLines;
	}
	
    /**
	 *  @private
     *  Determines if the composed text fits in the given height and 
     *  line count limit. 
     */ 
    private function doesComposedTextFit(height:Number,
                                         createdAllLines:Boolean,
                                         lineCountLimit:int):Boolean
    {
        // Not all text composed because it didn't fit within bounds.
        if (!createdAllLines)
            return false;
                    
        // More text lines than allowed lines.                    
        if (lineCountLimit != -1 && textLines.length > lineCountLimit)
            return false;
        
        // No lines or no height restriction.
        if (!textLines.length || isNaN(height))
            return true;
                                             
        // Does the bottom of the last line fall within the bounds?                                                    
        var lastLine:TextLine = TextLine(textLines[textLines.length - 1]);        
        var lastLineExtent:Number = lastLine.y + lastLine.descent;
        
        return lastLineExtent <= height;
    }

    /**
     *  @private
     *  width and height are the ones used to do the compose, not the measured
     *  results resulting from the compose.
     * 
     *  Adapted from justification code in TLF's
     *  TextLineFactory.textLinesFromString().
     */
	private function truncateText(width:Number, height:Number):void
	{
	    var lineCountLimit:int = maxDisplayedLines;
        var somethingFit:Boolean = false;
        var truncLineIndex:int = 0;    

        // Compute the truncation line.
        truncLineIndex = computeLastAllowedLineIndex(height, lineCountLimit);
                                     
        if (truncLineIndex >= 0)
        {
            // Estimate the initial truncation position using the following 
            // steps. 
            
            // 1. Measure the space that the truncation indicator will take
            // by composing the truncation resource using the same bounds
            // and formats.  The measured indicator lines could be cached but
            // as well as being dependent on the indicator string, they are 
            // dependent on the given width.            
            staticTextElement.text = truncationIndicatorResource;
            var indicatorLines:Vector.<DisplayObject> =
            	new Vector.<DisplayObject>();
            var indicatorBounds:Rectangle = new Rectangle(0, 0, width, NaN);
    
            createTextLinesFromTextBlock(staticTextBlock, 
                                         indicatorLines, 
                                         indicatorBounds);
                                               
            releaseLinesFromTextBlock();
                                                                                                         
            // 2. Move target line for truncation higher by as many lines 
            // as the number of full lines taken by the truncation 
            // indicator.
            truncLineIndex -= (indicatorLines.length - 1);
            if (truncLineIndex >= 0)
            {
                // 3. Calculate allowed width (width left over from the 
                // last line of the truncation indicator).
                var measuredTextLine:TextLine = 
                    TextLine(indicatorLines[indicatorLines.length - 1]);      
                var allowedWidth:Number = 
                    measuredTextLine.specifiedWidth -
                    measuredTextLine.unjustifiedTextWidth;                          
                                        
                measuredTextLine = null;                                        
                releaseTextLines(indicatorLines);
                                                        
                // 4. Get the initial truncation position on the target 
                // line given this allowed width. 
                // FIXME (gosmith): What if textLines[truncLineIndex] is a backgroundColor
				// Shape instead of a TextLine?
                var truncateAtCharPosition:int = getTruncationPosition(
                	TextLine(textLines[truncLineIndex]), allowedWidth);

                // The following loop executes repeatedly composing text until 
                // it fits.  In each iteration, an atoms's worth of characters 
                // of original content is dropped
                do
                {
                    // Replace all content starting at the inital truncation 
                    // position with the truncation indicator.
                    var truncText:String = text.slice(0, truncateAtCharPosition) +
                    					   truncationIndicatorResource;

                    // (Re)-initialize bounds for next compose.
                    bounds.x = 0;
                    bounds.y = 0;
                    bounds.width = width;
                    bounds.height = height;
                                                                                    
                    staticTextElement.text = truncText;
                    
                    var createdAllLines:Boolean = createTextLinesFromTextBlock(
                    	staticTextBlock, textLines, bounds);
        
                    if (doesComposedTextFit(height, 
                                            createdAllLines, 
                                            lineCountLimit))
                    {
                        somethingFit = true;
                        break; 
                    }       
                    
                     // No original content left to make room for 
                     // truncation indicator.
                    if (truncateAtCharPosition == 0)
                        break;
                    
                    // Try again by truncating at the beginning of the 
                    // preceding atom.
                    truncateAtCharPosition = getNextTruncationPosition(
                    	truncLineIndex, truncateAtCharPosition);                         
                }
                while (true);
            }
        }

        // If nothing fit, return no lines and bounds that just contains
        // padding.
        if (!somethingFit)
        {
            releaseTextLines();

            var paddingBottom:Number = getStyle("paddingBottom");
            var paddingLeft:Number = getStyle("paddingLeft");
            var paddingRight:Number = getStyle("paddingRight");
            var paddingTop:Number = getStyle("paddingTop");
            
            bounds.x = 0;
            bounds.y = 0;
            bounds.width = paddingLeft + paddingRight;
            bounds.height = paddingTop + paddingBottom;
        }
        
        // The text was truncated.
        setIsTruncated(true);
    }
        
    /** 
	 *  @private
     *  Calculates the last line that fits in the given height and line count 
     *  limit.
     */
    private function computeLastAllowedLineIndex(height:Number,
                                                 lineCountLimit:int):int
    {           
        var truncationLineIndex:int = textLines.length - 1;
        
        if (!isNaN(height))
        {
            // Search in reverse order since truncation near the end is the 
            // more common use case.
            do
            {
                var textLine:TextLine = TextLine(textLines[truncationLineIndex]);
                if (textLine.y + textLine.descent <= height)
                    break;
                                
                truncationLineIndex--;
            }
            while (truncationLineIndex >= 0);
        }   
    
        // if line count limit is smaller, use that
        if (lineCountLimit != -1 && lineCountLimit <= truncationLineIndex)
            truncationLineIndex = lineCountLimit - 1;            
            
        return truncationLineIndex;            
    }

    /** 
	 *  @private
     *  Gets the truncation position on a line given the allowed width.
     *  - Must be at an atom boundary.
     *  - Must scan the line for atoms in logical order, not physical position 
     *    order.
     *  For example, given bi-di text ABאבCD
     *  atoms must be scanned in this order: 
     *  A, B, א
     *  ג, C, D  
     */
    private function getTruncationPosition(line:TextLine, 
                                           allowedWidth:Number):int
    {           
        var consumedWidth:Number = 0;
        var charPosition:int = line.textBlockBeginIndex;
        
        while (charPosition < line.textBlockBeginIndex + line.rawTextLength)
        {
            var atomIndex:int = line.getAtomIndexAtCharIndex(charPosition);
            var atomBounds:Rectangle = line.getAtomBounds(atomIndex); 
            consumedWidth += atomBounds.width;
            if (consumedWidth > allowedWidth)
                break;
                
            charPosition = line.getAtomTextBlockEndIndex(atomIndex);
        }
        
        line.flushAtomData();
        
        return charPosition;
    }
        
    /** 
	 *  @private
     *  Gets the next truncation position by shedding an atom's worth of 
     *  characters.
     */
    private function getNextTruncationPosition(truncationLineIndex:int,
                                               truncateAtCharPosition:int):int
    {
        // 1. Get the position of the last character of the preceding atom
        // truncateAtCharPosition-1, because truncateAtCharPosition is an 
        // atom boundary.
        truncateAtCharPosition--; 
        
        // 2. Find the new target line (i.e., the line that has the new 
        // truncation position).  If the last truncation position was at the 
        // beginning of the target line, the new position may have moved to a 
        // previous line.  It is also possible for this position to be found 
        // in the next line because the truncation indicator may have combined 
        // with original content to form a word that may not have afforded a 
        // suitable break opportunity.  In any case, the new truncation 
        // position lies in the vicinity of the previous target line, so a 
        // linear search suffices.
        var line:TextLine = TextLine(textLines[truncationLineIndex]);
        do
        {
            if (truncateAtCharPosition >= line.textBlockBeginIndex && 
                truncateAtCharPosition < line.textBlockBeginIndex + line.rawTextLength)
            {
                break;
            }
            
            if (truncateAtCharPosition < line.textBlockBeginIndex)
                truncationLineIndex--;
            else
                truncationLineIndex++;
                
            line = TextLine(textLines[truncationLineIndex]);
        }
        while (true);

        // 3. Get the line atom index at this position          
        var atomIndex:int = 
                        line.getAtomIndexAtCharIndex(truncateAtCharPosition);
        
        // 4. Get the char index for this atom index
        var nextTruncationPosition:int = 
                        line.getAtomTextBlockBeginIndex(atomIndex);
        
        line.flushAtomData();
        
        return nextTruncationPosition;
    }
    
    /**
	 *  @private
     *  Cleans up and sets the validity of the lines associated 
     *  with the TextBlock to TextLineValidity.INVALID.
     */
    private function releaseLinesFromTextBlock():void
    {
        var firstLine:TextLine = staticTextBlock.firstLine;
        var lastLine:TextLine = staticTextBlock.lastLine;
        
        if (firstLine)
            staticTextBlock.releaseLines(firstLine, lastLine);        
     }
}

}
