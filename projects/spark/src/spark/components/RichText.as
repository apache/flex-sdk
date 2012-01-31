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
import flash.text.engine.TextLine;

import flashx.textLayout.conversion.ITextImporter;
import flashx.textLayout.conversion.TextFilter;
import flashx.textLayout.elements.Configuration;
import flashx.textLayout.elements.FlowElement;
import flashx.textLayout.elements.ParagraphElement;
import flashx.textLayout.elements.SpanElement;
import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.events.DamageEvent;
import flashx.textLayout.factory.TextLineFactory;
import flashx.textLayout.factory.TruncationOptions;
import flashx.textLayout.formats.FormatValue;
import flashx.textLayout.formats.TextLayoutFormat;
import flashx.textLayout.tlf_internal;

import mx.core.mx_internal;
import mx.graphics.baseClasses.TextGraphicElement;
import mx.utils.TextUtil;

//--------------------------------------
//  Styles
//--------------------------------------

include "../styles/metadata/AdvancedTextLayoutFormatStyles.as"
include "../styles/metadata/BasicTextLayoutFormatStyles.as"

//--------------------------------------
//  Other metadata
//--------------------------------------

[DefaultProperty("content")]

[IconFile("TextGraphic.png")]

/**
 *  Defines text in FXG.
 *  
 *  <p>This class can display richly-formatted text, with multiple character and paragraph formats. 
 *  However, it is non-interactive: it doesn't support scrolling, selection, or editing.</p>
 *  
 *  <p>A TextGraphic element defines a text box, specified in the parent Group element's coordinate space, 
 *  to contain the provided text. The text box is specified using the x/y and width/height attributes on the TextGraphic element.</p>
 *  
 *  <p>Text is rendered as a graphic element similar to paths and shapes, but with a restricted subset of rendering options. 
 *  TextGraphic elements are always rendered using a solid fill color, modified by any opacity, blend mode, and color transformation 
 *  defined by parent elements, and clipped to any clipping content defined on its parent elements. TextGraphic content is only filled, 
 *  not stroked.</p>
 *  
 *  <p>TextGraphic does not support drawing a background or border; it only renders text and inline graphics. If you want a simpler text class, 
 *  use the TextBox class. If you want a text control with more capabilities, use the TextView class.</p>
 *  
 *  <p>The TextGraphic element automatically clips the text rendering to the bounds of the text box.</p>
 *  
 *  <p>If you do not specify the value of the <code>width</code> or <code>height</code> properties, or if the specified value
 *  of these properties is 0, the width and height are calculated based on the text content.</p>
 *  
 *  @see mx.components.TextView
 *  @see mx.graphics.TextBox
 *  
 *  @includeExample examples/TextGraphicExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class TextGraphic extends TextGraphicElement
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Used for determining whitespace processing during import.
     */
    private static var staticTextLayoutFormat:TextLayoutFormat =
        new TextLayoutFormat();
    
    /**
     *  @private
     *  Used for determining whitespace processing during import.
     */
    private static var staticConfiguration:Configuration =
        new Configuration();
    
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
     *  This object is determined by the CSS styles of the TextGraphic
     *  and is updated by createTextFlow() when the hostFormatsInvalid flag
     *  is true.
     */
    private var hostTextLayoutFormat:TextLayoutFormat = new TextLayoutFormat();

    /**
     *  @private
     *  This flag indicates whether hostCharacterFormat, hostParagraphFormat,
     *  and hostContainerFormat need to be recalculated from the CSS styles
     *  of the TextGraphic. It is set true by stylesInitialized() and also
     *  when styleChanged() is called with a null argument, indicating that
     *  multiple styles have changed.
     */
    private var hostTextLayoutFormatInvalid:Boolean = false;

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
     *  If content is explicitly set, it will take precedence over text, if it 
     *  is set as well.  Once content is set, it can be set to null and then text 
     *  can be set.
     */
    private var contentSet:Boolean = false;

    /**
     *  @private
     *  This flag is set to true if the 'text' needs to be extracted
     *  from the 'content'.
     */
    private var textInvalid:Boolean = false;
        
    /**
     *  @private
     */
    private var stylesChanged:Boolean = false;

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
            mx_internal::_text = TextUtil.extractText(textFlow);
            textInvalid = false;
        }

        return mx_internal::_text;
    }

    /**
     *  @private
     */
    override public function set text(value:String):void
    {
        // Setting 'text' temporarily causes 'content' to become null.
        // Later, after the 'text' has been committed into the TextFlow,
        // getting 'content' will return the TextFlow.
        if (!contentSet)
        {
            _content = null;
            contentChanged = false;
            
            super.text = value;
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
     *  @private
     */
    protected var _content:Object;
        
    /**
     *  The text contained in the TextGraphic element.
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
     *      <td>Starts a new paragraph. A &lt;p&gt; can be a child of a TextGraphic. Children are character sequences, 
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
        return _content;
    }
    
    /**
     *  @private
     */
    public function set content(value:Object):void
    {
        if (value != _content)
        {
            // Setting 'content' temporarily causes 'text' to become null.
            // Later, after the 'content' has been committed into the TextFlow,
            // getting 'text' will extract the text from the TextFlow.
            mx_internal::_text = null;
            textChanged = false;
            
            _content = value;
            
            // True, if content is non-null.  Once content is set, if then set 
            // to null, text can be set.
            contentSet = _content;
            
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
    override protected function updateDisplayList(unscaledWidth:Number, 
                                                  unscaledHeight:Number):void
    {
        //trace("updateDisplayList", unscaledWidth, unscaledHeight);
        
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        // The updateDisplayList() method of a GraphicElement can get called
        // when its style chain hasn't been initialized.
        // In that case, compose() must not be called.
        if (!mx_internal::styleChainInitialized)
            return;

        // Only compose if it's necessary:
        //   1) A style change.
        //   2) If both width/height are specified, measure isn't called
        //      and measuredWidth/Height will be 0 here.
        //   3) A layout change which leaves the measured values different
        //      than the unscaled values.
        //   4) measuredHeight/Width set by measure changed by super class
        //      to conform to explicit min/max values for width/height.
        if (stylesChanged || 
            measuredWidth != unscaledWidth || 
            measuredWidth != Math.ceil(mx_internal::bounds.width) ||
            measuredHeight != unscaledHeight ||
            measuredHeight != Math.ceil(mx_internal::bounds.height))
        {
			composeTextLines(unscaledWidth, unscaledHeight);
		}  
            
        mx_internal::clip(unscaledWidth, unscaledHeight);
    }
    
    /**
     *  @private
     */
    override public function stylesInitialized():void
    {
        super.stylesInitialized();

        hostTextLayoutFormatInvalid = true;
    }

    /**
     *  @private
     */
    override public function styleChanged(styleProp:String):void
    {
        super.styleChanged(styleProp);

        // If null or "styleName" is passed, indicating that
        // multiple styles may have changed, set a flag indicating
        // that hostContainerFormat, hostParagraphFormat,
        // and hostCharacterFormat need to be recalculated later.
        // But if a single style has changed, update the corresponding
        // property in either hostContainerFormat, hostParagraphFormat,
        // or hostCharacterFormat immediately.
        if (styleProp == null || styleProp == "styleName")
            hostTextLayoutFormatInvalid = true;
        else
            setHostTextLayoutFormat(styleProp);
            
        stylesChanged = true;
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
        var p:ParagraphElement = new ParagraphElement();
        var span:SpanElement = new SpanElement();
        textFlow.replaceChildren(0, 0, p);
        p.replaceChildren(0, 0, span);
        return textFlow;
    }

    /**
     *  @private
     */
    private function setHostTextLayoutFormat(styleProp:String):void
    {
        if (styleProp in hostTextLayoutFormat)
		{
			var value:* = getStyle(styleProp);
        
			if (styleProp == "tabStops" && value === undefined)
				value = [];

			hostTextLayoutFormat[styleProp] = value;
		}
    }

    /**
     *  @private
     */
    private function createTextFlowFromMarkup(markup:Object):TextFlow
    {
        // The whiteSpaceCollapse format determines how whitespace
        // is processed when markup is imported.
		staticTextLayoutFormat.lineBreak = FormatValue.INHERIT;
        staticTextLayoutFormat.paddingLeft = FormatValue.INHERIT;
        staticTextLayoutFormat.paddingRight = FormatValue.INHERIT;
        staticTextLayoutFormat.paddingTop = FormatValue.INHERIT;
        staticTextLayoutFormat.paddingBottom = FormatValue.INHERIT;
        staticTextLayoutFormat.verticalAlign = FormatValue.INHERIT;
		staticTextLayoutFormat.whiteSpaceCollapse =
            getStyle("whiteSpaceCollapse");
		staticConfiguration.textFlowInitialFormat =
            staticTextLayoutFormat;

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

        return importToFlow(markup, TextFilter.TEXT_LAYOUT_FORMAT,
                            staticConfiguration);
    }
    
    /**
     *  @private
     */
    private function createTextFlowFromChildren(children:Array):TextFlow
    {
        var textFlow:TextFlow = new TextFlow();

        // The whiteSpaceCollapse format determines how whitespace
        // is processed when the children are set.
		staticTextLayoutFormat.lineBreak = FormatValue.INHERIT;
        staticTextLayoutFormat.paddingLeft = FormatValue.INHERIT;
        staticTextLayoutFormat.paddingRight = FormatValue.INHERIT;
        staticTextLayoutFormat.paddingTop = FormatValue.INHERIT;
        staticTextLayoutFormat.paddingBottom = FormatValue.INHERIT;
        staticTextLayoutFormat.verticalAlign = FormatValue.INHERIT;
        staticTextLayoutFormat.whiteSpaceCollapse =
            getStyle("whiteSpaceCollapse");
        textFlow.hostTextLayoutFormat = staticTextLayoutFormat;

        textFlow.mxmlChildren = children;

        return textFlow;
    }

    /**
     *  @private
     *  Keep this method in sync with the same method in TextView.
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
            var t:String = mx_internal::_text;
            if (t != null && t != "")
            {
                textFlow = importToFlow(t, TextFilter.PLAIN_TEXT_FORMAT);
            }
            else
            {
                textFlow = createEmptyTextFlow();
            }
        }

        contentChanged = false;
        textChanged = false;

        if (hostTextLayoutFormatInvalid)
        {
            for (var p:String in TextLayoutFormat.tlf_internal::description)
            {
                setHostTextLayoutFormat(p);
            }
            hostTextLayoutFormatInvalid = false;
        }

        textFlow.hostTextLayoutFormat = new TextLayoutFormat(hostTextLayoutFormat);

        return textFlow;
    }

    /**
     *  @private
     * 
     *  This will throw on import error.
     */
    private function importToFlow(source:Object, format:String, 
                                  config:Configuration = null):TextFlow
    {
        var importer:ITextImporter = TextFilter.getImporter(format);
        
        // Throw import errors rather than return a null textFlow.
        // Alternatively, the error strings are in the Vector, importer.errors.
        importer.throwOnError = true;
        
        return importer.importToFlow(source);        
    }
    
    /**
     *  @private
     */
    override protected function composeTextLines(width:Number = NaN,
												 height:Number = NaN):void
    {
        // Don't want this handler firing when we're re-composing the text lines.
        textFlow.removeEventListener(DamageEvent.DAMAGE, textFlow_damageHandler);
        
        textFlow = createTextFlow();
        _content = textFlow;

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
        createTextLines();
        mx_internal::addTextLines(DisplayObjectContainer(displayObject));
        
		// Just recomposed so reset.
        stylesChanged = false;
        
        // Listen for "damage" events in case the textFlow is 
        // modified programatically.
        textFlow.addEventListener(DamageEvent.DAMAGE, textFlow_damageHandler);        
    }
    
	/**
	 *  @private
	 *  Uses TextLineFactory to compose the textFlow
	 *  into as many TextLines as fit into the bounds.
	 */
	private function createTextLines():void
	{
		// Clear any previously generated TextLines from the textLines Array.
		mx_internal::textLines.length = 0;
		
		var truncationOptions:TruncationOptions;
		if (truncation != 0)
		{
			truncationOptions = new TruncationOptions();
			truncationOptions.lineCountLimit = truncation;
			truncationOptions.truncationIndicator =
				TextGraphicElement.mx_internal::truncationIndicatorResource;
		}

        TextLineFactory.createTextLinesFromTextFlow(
			addTextLine, textFlow, mx_internal::bounds, truncationOptions);
    }

    /**
     *  @private
     *  Callback passed to createTextLines().
     */
    private function addTextLine(textLine:TextLine):void
    {
        mx_internal::textLines.push(textLine);
    }
		
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Called when the TextFlow dispatches a 'damage' event
     *  to indicate it has been modified.
     */
    private function textFlow_damageHandler(
                            event:DamageEvent):void
    {
        //trace("damageHandler", "damageStart", event.damageStart, "damageLength", event.damageLength);
                
        // The text flow changed.  It could have been either/or content or
        // styles within the text flow.  Invalidate text so that it will be 
        // regenerated from the text flow.
        textInvalid = true;
        
        // Make sure composition is done at least once.  It will update
        // _content with the potentially modified contents of the text flow.
        stylesChanged = true;

        // Unless both width/height were specified, need to recalc size.
        if (isNaN(explicitWidth) || isNaN(explicitHeight))
            invalidateSize();
        
        invalidateDisplayList();  
    }    
}

}
