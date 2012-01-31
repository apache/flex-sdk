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

package mx.components
{
	
import flash.events.Event;

import mx.components.baseClasses.FxScrollBar;
import mx.components.baseClasses.FxTextBase;
import mx.core.mx_internal;
import mx.core.ScrollPolicy;
import mx.events.TextOperationEvent;

//--------------------------------------
//  Other metadata
//--------------------------------------

[DefaultProperty("content")]

/**
 *  The built-in set of states for the TextArea component.
 */
[SkinStates("enabledNoScrollBars", "enabledHScrollBar", "enabledVScrollBar", "enabledBothScrollBars", "disabledNoScrollBars", "disabledHScrollBar", "disabledVScrollBar", "disabledBothScrollBars")]

/**
 *  Documentation is not currently available.
 */
public class FxTextArea extends FxTextBase
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
	public function FxTextArea()
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
        if (textInvalid)
        {
            mx_internal::_text = textView.text;
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
	private var _content:Object;

	/**
	 *  @private
	 */
	private var contentChanged:Boolean = false;

	[Bindable("change")]
	[Bindable("contentChanged")]
	[Bindable("textChanged")]
	
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
		if (value == _content)
			return;

        // Setting 'content' temporarily causes 'text' to become null.
        // Later, after the 'content' has been committed into the TextFlow,
        // getting 'text' will extract the text from the TextFlow.
        mx_internal::_text = null;
        mx_internal::textChanged = false;

		_content = value;
		contentChanged = true;

		invalidateProperties();
		
		dispatchEvent(new Event("contentChanged"));
	}
    
	//----------------------------------
	//  heightInLines
    //----------------------------------

	/**
	 *  @private
	 */
	private var _heightInLines:int = 10;

	/**
	 *  @private
	 */
	private var heightInLinesChanged:Boolean = false;
	
	/**
	 *  Documentation is not currently available.
	 */
	public function get heightInLines():int
	{
		return _heightInLines;
	}

	/**
	 *  @private
	 */
	public function set heightInLines(value:int):void
	{
		if (value == _heightInLines)
			return;

		_heightInLines = value;
		heightInLinesChanged = true;

		invalidateProperties();
	}
    
    //----------------------------------
	//  horizontalScrollBar
    //----------------------------------

    [SkinPart(required="false")]

	/**
	 *  The ScrollBar for horizontal scrolling that may be present
	 *  in skins assigned to this TextArea.
	 */
	public var horizontalScrollBar:FxScrollBar;
    
	//----------------------------------
	//  horizontalScrollPolicy
    //----------------------------------

	/**
	 *  @private
	 */
	private var _horizontalScrollPolicy:String = ScrollPolicy.OFF;
	
	/**
	 *  Documentation is not currently available.
	 */
	public function get horizontalScrollPolicy():String
	{
		return _horizontalScrollPolicy;
	}

	/**
	 *  @private
	 */
	public function set horizontalScrollPolicy(value:String):void
	{
		if (value == _horizontalScrollPolicy)
			return;

		_horizontalScrollPolicy = value;

		invalidateSkinState();
	}
    
    //----------------------------------
	//  verticalScrollBar
    //----------------------------------

    [SkinPart(required="false")]

	/**
	 *  The ScrollBar for vertical scrolling that may be present
	 *  in skins assigned to this TextArea.
	 */
	public var verticalScrollBar:FxScrollBar;
    
	//----------------------------------
	//  verticalScrollPolicy
    //----------------------------------

	/**
	 *  @private
	 */
	private var _verticalScrollPolicy:String = ScrollPolicy.ON;
	
	/**
	 *  Documentation is not currently available.
	 */
	public function get verticalScrollPolicy():String
	{
		return _verticalScrollPolicy;
	}

	/**
	 *  @private
	 */
	public function set verticalScrollPolicy(value:String):void
	{
		if (value == _verticalScrollPolicy)
			return;

		_verticalScrollPolicy = value;

		invalidateSkinState();
	}
    
	//----------------------------------
	//  widthInChars
    //----------------------------------

	/**
	 *  @private
	 */
	private var _widthInChars:int = 20;

	/**
	 *  @private
	 */
	private var widthInCharsChanged:Boolean = false;
	
	/**
	 *  The default width for the TextInput, measured in characters.
	 *  The width of the "0" character is used for the calculation,
	 *  since in most fonts the digits all have the same width.
	 *  So if you set this property to 5, it will be wide enough
	 *  to let the user enter 5 digits.
	 *
	 *  @default
	 */
	public function get widthInChars():int
	{
		return _widthInChars;
	}

	/**
	 *  @private
	 */
	public function set widthInChars(value:int):void
	{
		if (value == _widthInChars)
			return;

		_widthInChars = value;
		widthInCharsChanged = true;

		invalidateProperties();
	}
    
	//--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
        
	/**
	 *  @private
	 *  Pushes various TextInput properties down into the TextView. 
	 */
    override protected function commitProperties():void
	{
        super.commitProperties();
        
        if (widthInCharsChanged)
		{
			textView.widthInChars = _widthInChars;
			widthInCharsChanged = false;
		}

        if (heightInLinesChanged)
		{
			textView.heightInLines = _heightInLines;
			heightInLinesChanged = false;
		}

        if (contentChanged)
        {
            textView.content = _content;
            contentChanged = false;
        }
	}

	/**
	 *  @private
	 */
	override protected function partAdded(partName:String, instance:Object):void
	{
        super.partAdded(partName, instance);

		if (instance == textView)
		{
			// Set the TextView to allow multiple lines of input.
			textView.heightInLines = 10;
			textView.multiline = true;
            textView.setStyle("lineBreak", "toFit");

            textView.addEventListener("textInvalid",
									  textView_textInvalidHandler);

        }
	}

	/**
	 *  @private
	 */
	override protected function getUpdatedSkinState():String
	{
        var hOn:Boolean = horizontalScrollPolicy == ScrollPolicy.ON;
        var vOn:Boolean = verticalScrollPolicy == ScrollPolicy.ON;

        if (hOn && vOn)
            return enabled ? "enabledBothScrollBars" : "disabledBothScrollBars";

        if (hOn)
            return enabled ? "enabledHScrollBar" : "disabledHScrollBar";

        if (vOn)
            return enabled ? "enabledVScrollBar" : "disabledVScrollBar";

        return enabled ? "enabledNoScrollBars" : "disabledNoScrollBars";
	}

	//--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

	/**
	 *  Documentation is not currently available.
	 */
    public function export():XML
    {
        if (!textView)
            return null;

        return textView.export();
    }

	/**
	 *  Documentation is not currently available.
	 */
    public function getAttributes(names:Array = null):Object
    {
        if (!textView)
            return null;

        return textView.getAttributes(names);
    }

	/**
	 *  Documentation is not currently available.
	 */
    public function setAttributes(attributes:Object):void
    {
        if (!textView)
            return;

        textView.setAttributes(attributes);
    }

	//--------------------------------------------------------------------------
    //
    //  Overridden event handlers: FxTextBase
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function textView_changeHandler(
                                        event:TextOperationEvent):void
	{
		// Note: We don't call the superhandler here
        // because it immediately fetches textView.text
        // to extract the text from the TextFlow.
        // That's too expensive for an FxTextArea,
        // which might have a lot of leaf nodes.
        
        // Update our storage variable for the content.
		_content = textView.content;
        textInvalid = true;

		// Redispatch the event that came from the TextView.
		dispatchEvent(event);
	}

	//--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private function textView_textInvalidHandler(event:Event):void
    {
        textInvalid = true;
    }
}

}
