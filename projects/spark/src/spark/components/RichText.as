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

/**
 *  Documentation is not currently avilable.
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
     *  Since this static var gets initialized by calling a method
     *  in another class, we initialize it in the constructor to avoid
     *  any class-initialization-order problems.
	 */
    private static var textImporter:ITextImporter;

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

        if (!textImporter)
            textImporter = TextFilter.getImporter(TextFilter.TCAL_FORMAT);

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

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  content
	//----------------------------------

	/**
	 *  Documentation is not currently available.
	 */
	protected var _content:Object;
		
	/**
	 *  Documentation is not currently available.
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
	private function importMarkup(markup:String):TextFlow
	{
		markup = '<TextFlow xmlns="http://ns.adobe.com/tcal/2008">' +
                 markup +
                 '</TextFlow>';
		
		return textImporter.importToFlow(markup);
	}

	/**
	 *  @private
     *  Keep this method in sync with the same method in TextView.
	 */
	private function createTextFlow():TextFlow
	{
		if (contentChanged || textChanged)
        {
            if (contentChanged)
		    {
                if (content is TextFlow)
                {
                    textFlow = TextFlow(content);
                }
                else if (content is Array)
                {
                    textFlow = new TextFlow();
                    textFlow.mxmlChildren = content as Array;
                }
                else if (content is FlowElement)
                {
                    textFlow = new TextFlow();
                    textFlow.mxmlChildren = [ content ];
                }
			    else if (content is String)
			    {
				    textFlow = importMarkup(String(content));
			    }
			    else if (content == null)
			    {
				    textFlow = createEmptyTextFlow();
			    }
                else
                {
                    throw new Error("invalid content");
                }
		    }
		    else if (textChanged)
		    {
			    if (text != null && text != "")
			    {
				    textFlow = TextFilter.importToFlow(text, TextFilter.PLAIN_TEXT_FORMAT);
			    }
			    else
			    {
				    textFlow = createEmptyTextFlow();
			    }
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
