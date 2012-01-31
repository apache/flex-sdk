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
import flash.text.TextFormat;
import flash.text.engine.FontLookup;

import flashx.textLayout.compose.ITextLineCreator;
import flashx.textLayout.conversion.ConversionType;
import flashx.textLayout.conversion.ITextExporter;
import flashx.textLayout.conversion.ITextImporter;
import flashx.textLayout.conversion.TextConverter;
import flashx.textLayout.elements.Configuration;
import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.events.DamageEvent;
import flashx.textLayout.factory.StringTextLineFactory;
import flashx.textLayout.factory.TextFlowTextLineFactory;
import flashx.textLayout.factory.TextLineFactoryBase;
import flashx.textLayout.factory.TruncationOptions;
import flashx.textLayout.formats.FormatValue;
import flashx.textLayout.formats.ITextLayoutFormat;
import flashx.textLayout.formats.TextLayoutFormat;

import mx.core.IEmbeddedFontRegistry;
import mx.core.IFlexModuleFactory;
import mx.core.IFontContextComponent;
import mx.core.IUIComponent;
import mx.core.Singleton;
import mx.core.mx_internal;
import mx.managers.ISystemManager;

import spark.core.CSSTextLayoutFormat;
import spark.primitives.supportClasses.TextGraphicElement;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

include "../styles/metadata/BasicInheritingTextStyles.as"
include "../styles/metadata/BasicNonInheritingTextStyles.as"
include "../styles/metadata/AdvancedInheritingTextStyles.as"
include "../styles/metadata/AdvancedNonInheritingTextStyles.as"

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
    //  Class variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private static var classInitialized:Boolean = false;
    
	/**
	 *  @private
	 *  This TLF object composes TextLines from a text String.
	 *  We use it when the 'text' property is set to a String
	 *  that doesn't contain linebreaks.
	 */
	private static var staticStringFactory:StringTextLineFactory;
	
	/**
	 *  @private
	 *  This TLF object composes TextLines from a TextFlow.
	 *  We use it when the 'textFlow' or 'content' property is set,
	 *  and when the 'text' property is set to a String
	 *  that contains linebreaks (and therefore is interpreted
	 *  as multiple paragraphs).
	 */
	private static var staticTextFlowFactory:TextFlowTextLineFactory;
	
	/**
	 *  @private
	 *  This TLF object is used to import a 'text' String
	 *  containing linebreaks to create a multiparagraph TextFlow.
	 */
	private static var staticPlainTextImporter:ITextImporter;
	
	/**
	 *  @private
	 *  This TLF object is used to export a TextFlow as plain 'text',
	 *  by walking the leaf FlowElements in the TextFlow.
	 */
	private static var staticPlainTextExporter:ITextExporter;
	
	/**
     *  @private
     *  Used for determining whitespace processing when setting 'content'.
     */
    private static var staticTextLayoutFormat:TextLayoutFormat;
    
    /**
     *  @private
     *  Used for determining whitespace processing when setting 'content'.
     */
    private static var staticConfiguration:Configuration;
    
    /**
     *  @private
     *  Used to call isFontFaceEmbedded() in getEmbeddedFontContext().
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
	//  Class methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  @private
	 *  This method initializes the static vars of this class.
	 *  Rather than calling it at static initialization time,
	 *  we call it in the constructor to do the class initialization
	 *  when the first instance is created.
	 *  (It does an immediate return if it has already run.)
	 *  By doing so, we avoid any static initialization issues
	 *  related to whether this class or the TLF classes
	 *  that it uses are initialized first.
	 */
	private static function initClass():void
	{
		if (classInitialized)
			return;
			
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
		
		staticStringFactory = new StringTextLineFactory(staticConfiguration);
		
		staticTextFlowFactory = new TextFlowTextLineFactory();
		
		staticTextFormat = new TextFormat();
		
		staticPlainTextImporter =
			TextConverter.getImporter(TextConverter.PLAIN_TEXT_FORMAT);
		
		staticPlainTextExporter =
			TextConverter.getExporter(TextConverter.PLAIN_TEXT_FORMAT);
			
		classInitialized = true;
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
        
        initClass();
        
        text = "";
    }
     
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  This object determines the default text formatting used
     *  by this component, based on its CSS styles.
     *  It is set to null by stylesInitialized() and styleChanged(),
     *  and recreated whenever necessary in commitProperties().
     */
    private var hostFormat:ITextLayoutFormat;

	/**
     *  @private
     *  Holds the last recorded value of the module factory
     *  used to create the font.
     */
    mx_internal var embeddedFontContext:IFlexModuleFactory;
    
	/**
	 *  @private
	 *  Specifies whether the StringTextLineFactory
	 *  or the TextFlowTextLineFactory is used to create the TextLines.
	 *  A StringTextLineFactory is more efficient; it is used
	 *  by default to render the default text ""
	 *  and when 'text' is set to a string without linebreaks;
	 *  otherwise, a TextFlowTextLineFactory is used.
	 */
	private var factory:TextLineFactoryBase;

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
    
    // The _text storage var is mx_internal in TextGraphicElement.
    
	/**
	 *  @private
	 */
	private var textChanged:Boolean = false;
	
	/**
     *  @private
     */
    override public function get text():String
    {
        // Extracting the plaintext from a TextFlow is somewhat expensive,
        // as it involves iterating over the leaf FlowElements in the TextFlow.
        // Therefore we do this extraction only when necessary, namely when
        // you first set the 'content' or the 'textFlow'
        // (or mutate the TextFlow), and then get the 'text'.
        if (_text == null)
        {
        	// If 'content' was last set,
        	// we have to first turn that into a TextFlow.
        	if (_content != null)
	        	_textFlow = createTextFlowFromContent(_content);
	        		
            // Once we have a TextFlow, we can export its plain text.
            _text = staticPlainTextExporter.export(
            	_textFlow, ConversionType.STRING_TYPE) as String;
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
    	// Treat setting the 'text' to null
    	// as if it were set to the empty String
    	// (which is the default state).
    	if (value == null)
    		value = "";
    	
    	// Don't return early if value is the same as _text,
    	// because _text might have been produced from setting
    	// 'textFlow' or 'content'.
    	// For example, if you set a TextFlow corresponding to
    	// "Hello <span color="OxFF0000">World</span>"
    	// and then get the 'text', it will be the String "Hello World"
    	// But if you then set the 'text' to "Hello World"
    	// this represents a change: the "World" should no longer be red.
    	
    	_text = value;
    	textChanged = true;
    	
    	// If more than one of 'text', 'textFlow', and 'content' is set,
    	// the last one set wins.
    	textFlowChanged = false;
    	contentChanged = false;
    	
		// The other two are now invalid and must be recalculated when needed.
		_textFlow = null;
    	_content = null;
    	
    	factory = staticStringFactory;
    	
		invalidateTextLines();
		invalidateProperties();
		invalidateSize();
		invalidateDisplayList();
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
     *  Storage for the content property.
     */
    protected var _content:Object;
    
	/**
	 *  @private
	 */
	private var contentChanged:Boolean = false;
	
    /**
     *  @private
     *  This metadata tells the MXML compiler to disable some of its default
     *  interpretation of the value specified for the 'content' property.
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
     *  This write-only property is for internal use by the MXML compiler.
     *  Please use the <code>textFlow</code> property to set
     *  rich text content.
     */
    public function set content(value:Object):void
    {
    	// Treat setting the 'content' to null
    	// as if 'text' were being set to the empty String
    	// (which is the default state).
    	if (value == null)
    	{
    		text = "";
    		return;
    	}
    	
    	if (value == _content)
    		return;
    	
        _content = value;
        contentChanged = true;
        
		// If more than one of 'text', 'textFlow', and 'content' is set,
		// the last one set wins.
		textChanged = false;
        textFlowChanged = false;
        
		// The other two are now invalid and must be recalculated when needed.
		_text = null;
		_textFlow = null;
		        
		factory = staticTextFlowFactory;
		
		invalidateTextLines();
		invalidateProperties();
		invalidateSize();
		invalidateDisplayList();
    }
    
	//----------------------------------
	//  textFlow
	//----------------------------------
	
	/**
	 *  @private
	 *  Storage for the textFlow property.
	 */
	private var _textFlow:TextFlow;
	
	/**
	 *  @private
	 */
	private var textFlowChanged:Boolean = false;
	
	/**
	 *  The TextFlow displayed by this component.
	 * 
	 *  <p>A TextFlow is the most important class
	 *  in the Text Layout Framework.
	 *  It is the root of a tree of FlowElements
	 *  representing rich text content.</p>
	 * 
	 *  @default
	 */
	public function get textFlow():TextFlow
	{
		// We might not have a valid _textFlow for two reasons:
		// either because the 'text' was set (which is the state
		// after construction) or because the 'content' was set.
		if (!_textFlow)
		{
			if (_content != null)
				_textFlow = createTextFlowFromContent(_content);
			else
				_textFlow = staticPlainTextImporter.importToFlow(_text);
		}
		
		return _textFlow;
	}
	
	/**
	 *  @private
	 */
	public function set textFlow(value:TextFlow):void
	{
		// Treat setting the 'textFlow' to null
		// as if 'text' were being set to the empty String
		// (which is the default state).
		if (value == null)
		{
			text = "";
			return;
		}
		
		if (value == _textFlow)
			return;
			
		_textFlow = value;
		textFlowChanged = true;
		
		// If more than one of 'text', 'textFlow', and 'content' is set,
		// the last one set wins.
		textChanged = false;
		contentChanged = false;
		
		// The other two are now invalid and must be recalculated when needed.
		_text = null
		_content = null;
		
		factory = staticTextFlowFactory;

		invalidateTextLines();
		invalidateProperties();
		invalidateSize();
		invalidateDisplayList();
	}
	
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: GraphicElement
    //
    //--------------------------------------------------------------------------
    
	/**
	 *  @private
	 */
	override protected function commitProperties():void
    {
    	super.commitProperties();
    	
    	// Only one of textChanged, textFlowChanged, and contentChanged
    	// will be true; the other two will be false because each setter
    	// guarantees this.
    	if (textChanged)
    	{
			// If the text has linebreaks (CR, LF, or CF+LF)
			// create a multi-paragraph TextFlow from it
			// and use the TextFlowTextLineFactory to render it.
			// Otherwise the StringTextLineFactory will put
			// all of the lines into a single paragraph
			// and FTE performance will degrade on a large paragraph.
			if (_text.indexOf("\n") != -1 || _text.indexOf("\r") != -1)
			{
				_textFlow = staticPlainTextImporter.importToFlow(_text);
				factory = staticTextFlowFactory;
			}
			textChanged = false;
    	}
    	else if (textFlowChanged)
    	{
    		// Nothing to do at commitProperties() time.
    		textFlowChanged = false;
    	}
    	else if (contentChanged)
    	{
			_textFlow = createTextFlowFromContent(_content);
			contentChanged = false;
    	}
    	
    	// At this point we know which TextLineFactory we're going to use
    	// and we know the _text or _textFlow that it will compose.

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
				
		// If the styles have changed, hostFormat will have
		// been set to null to indicate that it is invalid.
		// In that case, create a new one.
		if (!hostFormat)
		{
			hostFormat = new CSSTextLayoutFormat(this);
			// Note: CSSTextLayoutFormat has special processing
			// for the fontLookup style. If it is "auto",
			// the fontLookup format is set to either
			// "device" or "embedded" depending on whether
			// embeddedFontContext is null or non-null.
		}
		
		if (_textFlow)
		{
			// We might have a new TextFlow, or a new hostFormat,
			// so attach the latter to the former.
			_textFlow.hostFormat = hostFormat;
		
			if (_textFlow.flowComposer)
			{
				_textFlow.flowComposer.textLineCreator = 
					staticTextFlowFactory.textLineCreator;
			}
		}
	}
    
    /**
     *  @private
     */
    override public function stylesInitialized():void
    {
        super.stylesInitialized();

		// The old hostFormat is invalid
		// and a new one must be created.
		hostFormat = null;
    }

    /**
     *  @private
     */
    override public function styleChanged(styleProp:String):void
    {
        super.styleChanged(styleProp);

        // The old hostFormat is invalid
        // and a new one must be created.
        hostFormat = null;
        
		invalidateTextLines();
		invalidateProperties();
		invalidateSize();
		invalidateDisplayList();
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods: TextGraphicElement
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  @private
	 *  Returns true to indicate all lines were composed.
	 */
	override mx_internal function composeTextLines(width:Number = NaN,
												   height:Number = NaN):Boolean
	{
		super.composeTextLines(width, height);
		
		// Don't want this handler firing when we're re-composing the text lines.
		if (factory is TextFlowTextLineFactory && _textFlow != null)
		{
			_textFlow.removeEventListener(DamageEvent.DAMAGE,
										  textFlow_damageHandler);
		}
		
		
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
		
		addTextLines(DisplayObjectContainer(drawnDisplayObject));
		
		// Figure out if the text overruns the available space for composition.
		isOverset = isTextOverset(width, height);
		
		// Just recomposed so reset.
		invalidateCompose = false;
		
		// Listen for "damage" events in case the textFlow is 
		// modified programatically.
		if (factory is TextFlowTextLineFactory && _textFlow != null)
		{
			_textFlow.addEventListener(DamageEvent.DAMAGE, 
									   textFlow_damageHandler);
		}  
		
		// Created all lines.
		return true;      
	}
	
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private function createTextFlowFromContent(content:Object):TextFlow
    {
		var textFlow:TextFlow ;
		
		// The whiteSpaceCollapse format determines how whitespace
		// is processed when the children are set.
		staticTextLayoutFormat.whiteSpaceCollapse =
			getStyle("whiteSpaceCollapse");
		
		if (content is TextFlow)
		{
			textFlow = content as TextFlow;
			textFlow.hostFormat = staticTextLayoutFormat;
		}
		else if (content is Array)
		{
			textFlow = new TextFlow();
			textFlow.hostFormat = staticTextLayoutFormat;
			textFlow.mxmlChildren = content as Array;
		}
		else
		{
			textFlow = new TextFlow();
			textFlow.hostFormat = staticTextLayoutFormat;
			textFlow.mxmlChildren = [ content ];
		}
		
		return textFlow;
	}

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
	 *  Uses TextLineFactory to compose the textFlow
	 *  into as many TextLines as fit into the bounds.
	 */
	private function createTextLines():void
	{
		// Clear any previously generated TextLines from the textLines Array.
		textLines.length = 0;
		
		// Note: Even if we have nothing to compose, we nevertheless
		// use the StringTextLineFactory to compose an empty string.
		// Since it appends the paragraph terminator "\u2029",
		// it actually creates and measures one TextLine.
		// Its width is 0 but its height is equal to the font's
		// ascent plus descent.
        
        factory.compositionBounds = bounds;   
        
        // Set up the truncation options.
        var truncationOptions:TruncationOptions;
        if (maxDisplayedLines != 0)
        {
            truncationOptions = new TruncationOptions();
            truncationOptions.lineCountLimit = maxDisplayedLines;
            truncationOptions.truncationIndicator =
                TextGraphicElement.truncationIndicatorResource;
        }        
		factory.truncationOptions = truncationOptions;
		
        if (factory is StringTextLineFactory)
        {
			// We know text is non-null since it got this far.
			staticStringFactory.text = _text;
			staticStringFactory.textFlowFormat = hostFormat;
			staticStringFactory.createTextLines(addTextLine);
		}
        else if (factory is TextFlowTextLineFactory)
        {
            staticTextFlowFactory.createTextLines(addTextLine, _textFlow);
        }
        
        bounds = factory.getContentBounds();
        _isTruncated = factory.isTruncated;
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
    private function textFlow_damageHandler(event:DamageEvent):void
    {
        //trace("damageHandler", "damageStart", event.damageStart, "damageLength", event.damageLength);
                
        // Invalidate _text and _content.
        _text = null;
        _content = null;
        
        // After the TextFlow has been mutated,
        // we must render it, not the 'text' String.
        factory = staticTextFlowFactory;
        
        // Force recompose since text and/or styles may have changed.
        invalidateTextLines();
        
        // We don't need to call invalidateProperties()
        // because the hostFormat and the _textFlow are still valid.

        // This is smart enough not to remeasure if the explicit width/height
        // were specified.
        invalidateSize();
        
        invalidateDisplayList();  
    }    
}

}
