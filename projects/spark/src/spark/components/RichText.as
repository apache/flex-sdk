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

import flashx.tcal.conversion.ITextImporter;
import flashx.tcal.conversion.TextFilter;
import flashx.tcal.elements.FlowElement;
import flashx.tcal.elements.ParagraphElement;
import flashx.tcal.elements.SpanElement;
import flashx.tcal.elements.TextFlow;
import flashx.tcal.formats.CharacterFormat;
import flashx.tcal.formats.ContainerFormat;
import flashx.tcal.formats.ICharacterFormat;
import flashx.tcal.formats.IContainerFormat;
import flashx.tcal.formats.IParagraphFormat;
import flashx.tcal.formats.ParagraphFormat;

import mx.core.mx_internal;
import mx.graphics.graphicsClasses.TextFlowComposer;
import mx.graphics.graphicsClasses.TextGraphicElement;
import mx.utils.TextUtil;

//--------------------------------------
//  Styles
//--------------------------------------

include "../styles/metadata/BasicContainerFormatTextStyles.as"
include "../styles/metadata/AdvancedContainerFormatTextStyles.as"
include "../styles/metadata/BasicParagraphFormatTextStyles.as"
include "../styles/metadata/AdvancedParagraphFormatTextStyles.as"
include "../styles/metadata/BasicCharacterFormatTextStyles.as"
include "../styles/metadata/AdvancedCharacterFormatTextStyles.as"

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
 */
public class TextGraphic extends TextGraphicElement
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
     *  This object is determined by the CSS styles of the TextGraphic
     *  and is updated by createTextFlow() when the hostFormatsInvalid flag
     *  is true.
     */
    private var hostCharacterFormat:CharacterFormat = new CharacterFormat();

    /**
     *  @private
     *  This object is determined by the CSS styles of the TextGraphic
     *  and is updated by createTextFlow() when the hostFormatsInvalid flag
     *  is true.
     */
    private var hostParagraphFormat:ParagraphFormat = new ParagraphFormat();

    /**
     *  @private
     *  This object is determined by the CSS styles of the TextGraphic
     *  and is updated by createTextFlow() when the hostFormatsInvalid flag
     *  is true.
     */
    private var hostContainerFormat:ContainerFormat = new ContainerFormat();

    /**
     *  @private
     *  This flag indicates whether hostCharacterFormat, hostParagraphFormat,
     *  and hostContainerFormat need to be recalculated from the CSS styles
     *  of the TextGraphic. It is set true by stylesInitialized() and also
     *  when styleChanged() is called with a null argument, indicating that
     *  multiple styles have changed.
     */
    private var hostFormatsInvalid:Boolean = false;

    /**
     *  @private
     */
    private var textFlowComposer:TextFlowComposer = new TextFlowComposer();
        
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
        
    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  text
    //----------------------------------

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
        _content = null;
        contentChanged = false;
        
        super.text = value;
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
    override protected function measure():void
    {
        compose(explicitWidth, explicitHeight);

        var bounds:Rectangle = textFlowComposer.bounds;
        measuredWidth = Math.ceil(bounds.width);
        measuredHeight = Math.ceil(bounds.height);
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

    /**
     *  @inheritDoc
     */
    override public function stylesInitialized():void
    {
        super.stylesInitialized();

        hostFormatsInvalid = true;
    }

    /**
     *  @inheritDoc
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
            hostFormatsInvalid = true;
        else
            setHostFormat(styleProp);
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
    private function setHostFormat(styleProp:String):void
    {
        var value:* = getStyle(styleProp);
        if (styleProp == "tabStops" && value === undefined)
            value = [];

        var kind:String = TextUtil.FORMAT_MAP[styleProp];

        if (kind == TextUtil.CONTAINER)
            hostContainerFormat[styleProp] = value;
        
        else if (kind == TextUtil.PARAGRAPH)
            hostParagraphFormat[styleProp] = value;
        
        else if (kind == TextUtil.CHARACTER)
            hostCharacterFormat[styleProp] = value;
    }

    /**
     *  @private
     */
    private function importStringMarkup(markup:String):TextFlow
    {
        markup = '<TextFlow xmlns="http://ns.adobe.com/tcal/2008">' +
                 markup +
                 '</TextFlow>';
        
        return TextFilter.importToFlow(markup, TextFilter.TCAL_FORMAT);
    }
    
    /**
     *  @private
     */
    private function importXMLMarkup(markup:XML):TextFlow
    {
        return TextFilter.importToFlow(markup, TextFilter.TCAL_FORMAT);
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
                textFlow = new TextFlow();
                textFlow.mxmlChildren = _content as Array;
            }
            else if (_content is FlowElement)
            {
                textFlow = new TextFlow();
                textFlow.mxmlChildren = [ _content ];
            }
	        else if (_content is XML)
            {
                textFlow = importXMLMarkup(XML(_content));
            }
            else if (_content is String)
            {
                textFlow = importStringMarkup(String(_content));
            }
            else if (_content == null)
            {
                textFlow = createEmptyTextFlow();
            }
            else
            {
                throw new Error("invalid content");
            }
            textInvalid = true;
        }
        else if (textChanged)
        {
            var t:String = mx_internal::_text;
            if (t != null && t != "")
            {
                textFlow = TextFilter.importToFlow(t, TextFilter.PLAIN_TEXT_FORMAT);
            }
            else
            {
                textFlow = createEmptyTextFlow();
            }
        }

        contentChanged = false;
        textChanged = false;

        if (hostFormatsInvalid)
        {
            for each (var p:String in TextUtil.ALL_FORMAT_NAMES)
            {
                setHostFormat(p);
            }
            hostFormatsInvalid = false;
        }

        textFlow.hostCharacterFormat = hostCharacterFormat;
        textFlow.hostParagraphFormat = hostParagraphFormat;
        textFlow.hostContainerFormat = hostContainerFormat;

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

        displayObject.scrollRect = textFlowComposer.isOverset ? bounds : null;
    }
}

}
