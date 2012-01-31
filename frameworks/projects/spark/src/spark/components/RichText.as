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

import flashx.tcal.conversion.TextFilter;
import flashx.tcal.elements.FlowElement;
import flashx.tcal.elements.ParagraphElement;
import flashx.tcal.elements.SpanElement;
import flashx.tcal.elements.TextFlow;
import flashx.tcal.formats.ICharacterFormat;
import flashx.tcal.formats.IContainerFormat;
import flashx.tcal.formats.IParagraphFormat;

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
     *  This set keeps track of which text formats were specified
     *  on the graphic element's TextFlow as opposed to on the
     *  graphic element itself.
     *
     *  For example, if you have
     *
     *      <TextGraphic fontSize="10">
     *          <content>
     *              <TextFlow fontSize="20">
     *                  ...
     *              </TextFlow>
     *          </content>
     *      </TextGraphic>
     *
     *  then this set would be { fontSize: 20 }.
     */
    private var textFlowTextFormat:Object = {};

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
        var width:Number = !isNaN(explicitWidth) ? explicitWidth : NaN;
        var height:Number = !isNaN(explicitHeight) ? explicitHeight : NaN;
		compose(width, height);

		var r:Rectangle = textFlowComposer.bounds;
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
	private function importMarkup(markup:String):TextFlow
	{
		markup =
			'<TextGraphic xmlns="http://ns.adobe.com/fxg/2008">' +
			    '<content>' + markup + '</content>' +
			'</TextGraphic>';
		
		return TextFilter.importToFlow(markup, TextFilter.FXG_FORMAT);
	}

	/**
	 *  @private
     *  Keep this method in sync with the same method in TextView.
	 */
	private function createTextFlow():TextFlow
	{
        var p:String;

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

            // Build a textFlowTextFormat object which keeps track
            // of which text formats were specified on the TextFlow
            // as opposed to on the TextGraphic.
            // For example, if the 'content' were
            // <TextFlow fontSize="12">...</TextFlow>
            // then the textFlowTextFormat would be { fontSize: 12 }.
            
            var containerFormat:IContainerFormat =
                textFlow.containerFormat;
            var paragraphFormat:IParagraphFormat =
                textFlow.paragraphFormat;
            var characterFormat:ICharacterFormat =
                textFlow.characterFormat;
            
            for each (p in TextUtil.ALL_FORMAT_NAMES)
            {
                var kind:String = TextUtil.FORMAT_MAP[p];

                if (kind == TextUtil.CONTAINER &&
                    containerFormat != null &&
                    containerFormat[p] != null)
                {
                    textFlowTextFormat[p] = containerFormat[p];
                }
                else if (kind == TextUtil.PARAGRAPH &&
                         paragraphFormat != null &&
                         paragraphFormat[p] != null)
                {
                    textFlowTextFormat[p] = paragraphFormat[p];
                }
                else if (kind == TextUtil.CHARACTER &&
                         characterFormat != null &&
                         characterFormat[p] != null)
                {
                    textFlowTextFormat[p] = characterFormat[p];
                }
            }
        }

 		contentChanged = false;
		textChanged = false;

        // For each attribute whose value wasn't specified by the TextFlow,
        // apply the value from the TextGraphic.
        
        for each (p in TextUtil.ALL_FORMAT_NAMES)
        {
            if (!(p in textFlowTextFormat))
            {
            	var value:* = getStyle(p);
            	if (p == "tabStops" && value === undefined)
            		value = [];
            	textFlow[p] = value;
            }
         }
        
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
