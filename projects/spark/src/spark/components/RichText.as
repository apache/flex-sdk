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

package spark.primitives
{

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Rectangle;
import flash.text.TextFormat;
import flash.text.engine.FontLookup;

import flashx.textLayout.compose.ITextLineCreator;
import flashx.textLayout.conversion.ITextImporter;
import flashx.textLayout.conversion.TextFilter;
import flashx.textLayout.elements.Configuration;
import flashx.textLayout.elements.FlowElement;
import flashx.textLayout.elements.ParagraphElement;
import flashx.textLayout.elements.SpanElement;
import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.events.DamageEvent;
import flashx.textLayout.factory.StringTextLineFactory;
import flashx.textLayout.factory.TextFlowTextLineFactory;
import flashx.textLayout.factory.TextLineFactoryBase;
import flashx.textLayout.factory.TruncationOptions;
import flashx.textLayout.formats.FormatValue;
import flashx.textLayout.formats.ITextLayoutFormat;
import flashx.textLayout.formats.TextLayoutFormat;

import mx.core.EmbeddedFont;
import mx.core.EmbeddedFontRegistry;
import mx.core.IEmbeddedFontRegistry;
import mx.core.IFlexModuleFactory;
import mx.core.IFontContextComponent;
import mx.core.IUIComponent;
import mx.core.Singleton;
import mx.core.mx_internal;
import mx.managers.ISystemManager;

import spark.core.CSSTextLayoutFormat;
import spark.primitives.supportClasses.TextGraphicElement;
import spark.utils.TextUtil;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

include "../styles/metadata/AdvancedTextLayoutFormatStyles.as"
include "../styles/metadata/BasicTextLayoutFormatStyles.as"
include "../styles/metadata/NonInheritingTextLayoutFormatStyles.as"

//--------------------------------------
//  Other metadata
//--------------------------------------

[DefaultProperty("content")]

[IconFile("RichText.png")]

/**
 *  Defines text in FXG.
 *  
 *  <p>This class can display richly-formatted text, with multiple character and paragraph formats. 
 *  However, it is non-interactive: it doesn't support scrolling, selection, or editing.</p>
 *  
 *  <p>A RichText element defines a text box, specified in the parent Group element's coordinate space, 
 *  to contain the provided text. The text box is specified using the x/y and width/height attributes on the RichText element.</p>
 *  
 *  <p>Text is rendered as a graphic element similar to paths and shapes, but with a restricted subset of rendering options. 
 *  RichText elements are always rendered using a solid fill color, modified by any opacity, blend mode, and color transformation 
 *  defined by parent elements, and clipped to any clipping content defined on its parent elements. RichText content is only filled, 
 *  not stroked.</p>
 *  
 *  <p>RichText does not support drawing a background or border; it only renders text and inline graphics. If you want a simpler text class, 
 *  use the SimpleText class. If you want a text control with more capabilities, use the RichEditableText class.</p>
 *  
 *  <p>The RichText element automatically clips the text rendering to the bounds of the text box.</p>
 *  
 *  <p>If you do not specify the value of the <code>width</code> or <code>height</code> properties, or if the specified value
 *  of these properties is 0, the width and height are calculated based on the text content.</p>
 *  
 *  @see mx.components.RichEditableText
 *  @see mx.graphics.SimpleText
 *  
 *  @includeExample examples/RichTextExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class RichText extends TextGraphicElement
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
        staticTextLayoutFormat = new TextLayoutFormat();
		staticTextLayoutFormat.lineBreak = FormatValue.INHERIT;
        staticTextLayoutFormat.paddingLeft = FormatValue.INHERIT;
        staticTextLayoutFormat.paddingRight = FormatValue.INHERIT;
        staticTextLayoutFormat.paddingTop = FormatValue.INHERIT;
        staticTextLayoutFormat.paddingBottom = FormatValue.INHERIT;
        staticTextLayoutFormat.verticalAlign = FormatValue.INHERIT;

        // Create a single Configuration used by all RichText instances.
        staticConfiguration = Configuration(
        	StringTextLineFactory.defaultConfiguration).clone();
        staticConfiguration.textFlowInitialFormat = staticTextLayoutFormat;            

        // Create the factory used to create TextLines from 'text'.
        staticStringFactory = new StringTextLineFactory(staticConfiguration);
        staticStringFactory.verticalScrollPolicy = "off";
        staticStringFactory.horizontalScrollPolicy = "off";           

        // Create the factory used to create TextLines from 'content'.
        staticTextFlowFactory = new TextFlowTextLineFactory();
        staticTextFlowFactory.verticalScrollPolicy = "off";
        staticTextFlowFactory.horizontalScrollPolicy = "off";
        
        staticTextFormat = new TextFormat();
     }
    
    initClass();
    
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Used for determining whitespace processing during import.
     */
    private static var staticTextLayoutFormat:TextLayoutFormat;
    
    /**
     *  @private
     *  Used for determining whitespace processing during import.
     */
    private static var staticConfiguration:Configuration;
    
    /**
     *  @private
     *  To compose text lines using a text string.
     */
    private static var staticStringFactory:StringTextLineFactory;

    /**
     *  @private
     *  To compose text lines using a text flow.
     */
    private static var staticTextFlowFactory:TextFlowTextLineFactory;
    
    /**
     *  @private
     *  Used in getEmbeddedFontContext().
     */
    private static var staticTextFormat:TextFormat;

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
    public function RichText()
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
     *  This object is determined by the CSS styles of the RichText
     *  and is updated by createTextFlow() when the hostFormatsInvalid flag
     *  is true.
     */
    private var hostFormat:ITextLayoutFormat;

    /**
     *  @private
     *  This flag indicates whether hostCharacterFormat, hostParagraphFormat,
     *  and hostContainerFormat need to be recalculated from the CSS styles
     *  of the RichText. It is set true by stylesInitialized() and also
     *  when styleChanged() is called with a null argument, indicating that
     *  multiple styles have changed.
     */
    private var hostFormatChanged:Boolean = true;

    /**
     *  @private
     */
    private var textFlow:TextFlow;

    /**
     *  @private
     */
    private var textChanged:Boolean = false;

    /**
     *  @private
     */
    private var contentChanged:Boolean = false;

    /**
     *  @private
     *  This flag is set to true if the 'text' needs to be extracted
     *  from the 'content'.
     */
    private var textInvalid:Boolean = false;

    /**
     *  @private
     *  Holds the last recorded value of the module factory
     *  used to create the font.
     */
    mx_internal var embeddedFontContext:IFlexModuleFactory;

    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  text
    //----------------------------------

    // Compiler will strip leading and trailing whitespace from text string.
    [CollapseWhiteSpace]
    
    /**
     *  @private
     */
    override public function get text():String
    {
        // Extracting the plaintext from a TextFlow is somewhat expensive,
        // as it involves iterating over the leaf FlowElements in the TextFlow.
        // Therefore we do this extraction only when necessary, namely when
        // you set the 'content' and then get the 'text'.
        if (textInvalid)
        {
            _text = TextUtil.extractText(textFlow);
            textInvalid = false;
        }

        return _text;
    }

    /**
     *  @private
     *  This will create a TextFlow with a single paragraph with a single span 
     *  with exactly the text specified.  If there is whitespace and line 
     *  breaks in the text, they will remain, regardless of the settings of
     *  the lineBreak and whiteSpaceCollapse styles.
     */
    override public function set text(value:String):void
    {
        // Setting 'text' temporarily causes 'content' to become null.
        // Later, after the 'text' has been committed into the TextFlow,
        // getting 'content' will return the TextFlow.
        _content = null;
        contentChanged = false;
        textInvalid = false;
        
        super.text = value;
    }
    
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
     *  @private
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
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  content
    //----------------------------------

    /**
     *  @private
     */
    protected var _content:Object;
    
    /**
     *  @private
     *  This metadata tells the MXML compiler to disable some of its default
     *  interpreation of the value specified for the 'content' property.
     *  Normally, for properties of type Object, it assumes that things
     *  looking like numbers are numbers and things looking like arrays
     *  are arrays. But <content>1</content> should generate code to set the
     *  content to  the String "1", not the int 1, and <content>[1]</content>
     *  should set it to the String "[1]", not the Array [ 1 ].
     *  However, {...} continues to be interpreted as a databinding
     *  expression, and @Resource(...), @Embed(...), etc.
     *  as compiler directives.
     *  Similar metadata on TLF classes causes the same rules to apply
     *  within <p>, <span>, etc.
     */
    [RichTextContent]
        
    /**
     *  The text contained in the RichText element.
     *  
     *  <p>The contents of this property can be a sequence of characters, &lt;p&gt;, &lt;br/&gt; or &lt;span&gt; elements. 
     *  The &lt;p&gt; and &lt;span&gt; elements can be implied, depending on how you use the style properties.</p>
     *  
     *  <p>If this property has text content and no explicit paragraph tag, a paragraph tag is automatically generated for the text.</p>
     *  
     *  <p>The following table describes the tags that can be used in the <code>content</code> property:
     *  
     *  <table>
     *    <tr>
     *      <td>&lt;p&gt;</td>
     *      <td>Starts a new paragraph. A &lt;p&gt; can be a child of a RichText. Children are character sequences, 
     *          &lt;br/&gt; elements, or &lt;span&gt; elements. Every &lt;p&gt; has at least one &lt;span&gt; that can be implied. 
     *          Character sequences that are direct children of &lt;p&gt; are in an implied &lt;span&gt;.</td>
     *    </tr>
     *    <tr>
     *      <td>&lt;span&gt;</td>
     *      <td>All character sequences are contained in one or more &lt;span&gt; elements. 
     *          Explicit &lt;span&gt; elements can be used for formatting runs of characters within a paragraph. 
     *          Every &lt;span&gt; element is a child of a &lt;p&gt; element. A &lt;span&gt; can contain character 
     *          sequences and/or &lt;br/&gt; elements. A &lt;span&gt; element can be empty. Unlike in XHTML, &lt;span&gt; elements
     *          must not be nested. The reason for this is the increased cost in number of objects required to represent the text.</td>
     *    </tr>
     *    <tr>
     *      <td>&lt;br/&gt;</td>
     *      <td>Behaves as a Unicode line separator character. It does not end the paragraph, it merely forces a line break at the 
     *          position where it appears. Always a child of &lt;span&gt; elements, though the 
     *          &lt;span&gt; element can be implied. The &lt;br/&gt; element must have no children (it must be an empty tag).</td>
     *    </tr>
     *  </table>
     *  </p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get content():Object 
    {
        // If there isn't any content and there is text, create a one paragraph 
        // text flow from the text.
        if (!_content && _text)
            _content = convertTextToContent();
                
        return _content;
    }
    
    /**
     *  @private
     *  Setting content uses the markup-importing process, so depending on
     *  the style settings, whitespace may get collapsed and newlines may be 
     *  treated as paragraph separators so that you end up with multiple 
     *  paragraphs.
     */
    public function set content(value:Object):void
    {
        if (value != _content)
        {
            // Setting 'content' temporarily causes 'text' to become null.
            // Later, after the 'content' has been committed into the TextFlow,
            // getting 'text' will extract the text from the TextFlow.
            _text = null;
            textChanged = false;
            
            _content = value;
            
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
     *  @private
     */
    override public function stylesInitialized():void
    {
        super.stylesInitialized();

        hostFormatChanged = true;
    }

    /**
     *  @private
     */
    override public function styleChanged(styleProp:String):void
    {
        super.styleChanged(styleProp);

        hostFormatChanged = true;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: TextGraphicElement
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override mx_internal function invalidateTextLines(cause:String):void
    {
        super.invalidateTextLines(cause);
        
        if (cause == "text")
            textChanged = true;
        else if (cause == "content")
            contentChanged = true;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
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
            	font, bold,	italic,
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
    private function createEmptyTextFlow():TextFlow
    {
        var textFlow:TextFlow = new TextFlow();
        var p:ParagraphElement = new ParagraphElement();
        var span:SpanElement = new SpanElement();
        textFlow.replaceChildren(0, 0, p);
        p.replaceChildren(0, 0, span);
        return textFlow;
    }

    /**
     *  @private
     *  Make 1 paragraph text flow.  We can not use the PLAIN_TEXT_FORMAT filter
     *  because each newline starts a new paragraph.
     */
    private function convertTextToContent():TextFlow
    {
        textFlow = new TextFlow();
        
        var p:ParagraphElement = new ParagraphElement();        
        textFlow.replaceChildren(0, 0, p);

        var span:SpanElement = new SpanElement();
        span.text = _text;
        p.replaceChildren(0, 0, span);
        
        // Set formats and textLineCreator.
        textFlow = createTextFlow();
        
        return textFlow;
    }

    /**
     *  @private
     */
    private function createTextFlowFromMarkup(markup:Object):TextFlow
    {
        if (markup is XML || markup is String)
        {
	        // We need to wrap the markup in a <TextFlow> tag
	        // unless it already has one.
	        // Note that we avoid trying to convert it to XML
	        // (in order to test whether the outer tag is <TextFlow>)
	        // unless it contains the substring "TextFlow".
            // And if we have to do the conversion, then
            // we use the markup in XML form rather than
            // having TLF reconvert it to XML.
	        var wrap:Boolean = true;
            if (markup is XML || markup.indexOf("TextFlow") != -1)
            {
                try
                {
                    var xmlMarkup:XML = XML(markup);
                    if (xmlMarkup.localName() == "TextFlow")
                    {
                        wrap = false;
                        markup = xmlMarkup;
                    }
                }
                catch(e:Error)
                {
                }
            }

	        if (wrap)
	        {
	            if (markup is String)
	            {
                    markup = 
                        '<TextFlow xmlns="http://ns.adobe.com/textLayout/2008">' +
                        markup +
                        '</TextFlow>';
                }
                else
                {
                    // It is XML.  Create a root element and add the markup
                    // as it's child.
                    var ns:Namespace = 
                        new Namespace("http://ns.adobe.com/textLayout/2008");
                                                 
                    xmlMarkup = <TextFlow />;
                    xmlMarkup.setNamespace(ns);            
                    xmlMarkup.setChildren(markup);  
                                        
                    // The namespace of the root node is not inherited by
                    // the children so it needs to be explicitly set on
                    // every element, at every level.  If this is not done
                    // the import will fail with an "Unexpected namespace"
                    // error.
                    for each (var element:XML in xmlMarkup..*::*)
                       element.setNamespace(ns);

                    markup = xmlMarkup;
                }
	        }
        }

        return importToFlow(markup, TextFilter.TEXT_LAYOUT_FORMAT);
    }
    
    /**
     *  @private
     */
    private function createTextFlowFromChildren(children:Array):TextFlow
    {
        var textFlow:TextFlow = new TextFlow();

        // The whiteSpaceCollapse format determines how whitespace
        // is processed when the children are set.
        staticTextLayoutFormat.whiteSpaceCollapse =
            getStyle("whiteSpaceCollapse");
        textFlow.hostFormat = staticTextLayoutFormat;

        textFlow.mxmlChildren = children;

        return textFlow;
    }

    /**
     *  @private
     *  Keep this method in sync with the same method in RichEditableText.
     */
    private function createTextFlow():TextFlow
    {
        if (contentChanged)
        {
            if (_content is TextFlow)
            {
                textFlow = TextFlow(_content);
            }
            else if (_content is Array)
            {
                textFlow = createTextFlowFromChildren(_content as Array);
            }
            else if (_content is FlowElement)
            {
                textFlow = createTextFlowFromChildren([ _content ]);
            }
	        else if (_content is String || _content is XML)
            {
                textFlow = createTextFlowFromMarkup(_content);
            }
            else if (_content == null)
            {
                textFlow = createEmptyTextFlow();
            }
            else
            {
                textFlow = createTextFlowFromMarkup(_content.toString());
            }
            textInvalid = true;
        }
        else if (textChanged)
        {
            if (textHasLineBreaks())
	            textFlow = createTextFlowFromText(_text);
            else
            	textFlow = null;
        }

        contentChanged = false;
        textChanged = false;

        var oldEmbeddedFontContext:IFlexModuleFactory = embeddedFontContext;
        
        // If the CSS styles for this component specify an embedded font,
        // embeddedFontContext will be set to the module factory that
        // should create TextLines (since they must be created in the
        // SWF where the embedded font is.)
        // Otherwise, this will be null.
        embeddedFontContext = getEmbeddedFontContext();
        
        if (embeddedFontContext != oldEmbeddedFontContext)
        {
            staticTextFlowFactory.textLineCreator =
                ITextLineCreator(embeddedFontContext)
            staticStringFactory.textLineCreator = 
                ITextLineCreator(embeddedFontContext)
        }
        
        if (hostFormatChanged)
        {
        	hostFormat = new CSSTextLayoutFormat(this);
        		// Note: CSSTextLayoutFormat has special processing
        		// for the fontLookup style. If it is "auto",
        		// the fontLookup format is set to either
        		// "device" or "embedded" depending on whether
        		// embeddedFontContext is null or non-null.
        	
        	hostFormatChanged = false;
        }

        if (textFlow)
        {
            textFlow.hostFormat = hostFormat;
            
            // There should always be a composer but be safe.
            if (textFlow.flowComposer)
            {
                textFlow.flowComposer.textLineCreator = 
                    staticTextFlowFactory.textLineCreator;
            }
        }

        return textFlow;
    }
    
    /**
     *  @private
     */
    private function textHasLineBreaks():Boolean
    {
    	return text.indexOf("\n") != -1 ||
    		   text.indexOf("\r") != -1;
    }
    
    /**
     *  @private
	 *  Splits 'text' into paragraphs on \n, etc.
     */
    private function createTextFlowFromText(text:String):TextFlow
    {
    	var importer:ITextImporter =
    		TextFilter.getImporter(TextFilter.PLAIN_TEXT_FORMAT);
    		
    	return importer.importToFlow(text);
    }

    /**
     *  @private
     *  This will throw on import error.
     */
    private function importToFlow(source:Object, format:String):TextFlow
    {        
        // The whiteSpaceCollapse format determines how whitespace
        // is processed when markup is imported.
        staticTextLayoutFormat.whiteSpaceCollapse =
            getStyle("whiteSpaceCollapse");
        
        var importer:ITextImporter = TextFilter.getImporter(format, 
                                                            staticConfiguration);
        
        // Throw import errors rather than return a null textFlow.
        // Alternatively, the error strings are in the Vector, importer.errors.
        importer.throwOnError = true;
        
        return importer.importToFlow(source);        
    }
    
    /**
     *  @private
     *  Returns true to indicate all lines were composed.
     */
    override mx_internal function composeTextLines(width:Number = NaN,
												   height:Number = NaN):Boolean
    {
        super.composeTextLines(width, height);

        // Don't want this handler firing when we're re-composing the text lines.
        if (textFlow)
        {
            textFlow.removeEventListener(DamageEvent.DAMAGE, 
                                         textFlow_damageHandler);
        }
        
        
        textFlow = createTextFlow();
        _content = textFlow;

		// Set the composition bounds to be used by createTextLines().
		// If the width or height is NaN, it will be computed by this method
		// by the time it returns.
		// The bounds are then used by the addTextLines() method
		// to determine the isOverset flag.
		// The composition bounds are also reported by the measure() method.
        bounds.x = 0;
        bounds.y = 0;
        bounds.width = isNaN(width) ? maxWidth : width;
        bounds.height = height;

        removeTextLines();
        releaseTextLines();
        
        createTextLines();
                    
        // If toFit and explicit width, adjust the bounds to match.
        // This will save a recompose and/or clip in updateDisplayList() if 
        // the bounds width matches the unscaled width.
        if (getStyle("lineBreak") == "toFit" && !isNaN(width) && 
            bounds.width < width)
        {
            bounds.width = width;
        }                                                           
        
        addTextLines(DisplayObjectContainer(drawnDisplayObject));
        
        // Figure out if the text overruns the available space for composition.
        isOverset = isTextOverset(width, height);
        
		// Just recomposed so reset.
        invalidateCompose = false;
        
        // Listen for "damage" events in case the textFlow is 
        // modified programatically.
        if (textFlow)
        {
            textFlow.addEventListener(DamageEvent.DAMAGE, 
                                      textFlow_damageHandler);
        }  
        
        // Created all lines.
        return true;      
    }
        
	/**
	 *  @private
	 *  Uses TextLineFactory to compose the textFlow
	 *  into as many TextLines as fit into the bounds.
	 */
	private function createTextLines():void
	{
		// Clear any previously generated TextLines from the textLines Array.
		textLines.length = 0;
		
		var factory:TextLineFactoryBase;
		if (textFlow)
            factory = staticTextFlowFactory;
		else
            factory = staticStringFactory;	

		// Note: Even if we have nothing to compose, we nevertheless
		// use the StringTextLineFactory to compose an empty string.
		// Since it appends the paragraph terminator "\u2029",
		// it actually creates and measures one TextLine.
		// Its width is 0 but its height is equal to the font's
		// ascent plus descent.
        
        factory.compositionBounds = bounds;   
        
        // Set up the truncation options.
        var truncationOptions:TruncationOptions;
        if (truncation != 0)
        {
            truncationOptions = new TruncationOptions();
            truncationOptions.lineCountLimit = truncation;
            truncationOptions.truncationIndicator =
                TextGraphicElement.truncationIndicatorResource;
        }        
		factory.truncationOptions = truncationOptions;
		
        if (textFlow)
        {
            staticTextFlowFactory.createTextLines(addTextLine, textFlow);
        }
        else
        {
            // We know text is non-null since it got this far.
            staticStringFactory.text = _text;
            staticStringFactory.textFlowFormat = hostFormat;
            staticStringFactory.createTextLines(addTextLine);
        }
        
        bounds = factory.contentBounds;
        isTextTruncated = factory.isTruncated;
    }

    /**
     *  @private
     *  Callback passed to createTextLines().
     */
    private function addTextLine(textLine:DisplayObject):void
    {
        textLines.push(textLine);
    }
  
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Called when the TextFlow dispatches a 'damage' event
     *  to indicate it has been modified.  This could mean the styles changed
     *  or the content changed, or both changed.
     */
    private function textFlow_damageHandler(
                            event:DamageEvent):void
    {
        //trace("damageHandler", "damageStart", event.damageStart, "damageLength", event.damageLength);
                
        // Invalidate text.
        textInvalid = true;
        
        // Force recompose since text and/or styles may have changed.
        invalidateCompose = true;

        // This is smart enough not to remeasure if the explicit width/height
        // were specified.
        invalidateSize();
        
        invalidateDisplayList();  
    }    
}

}
