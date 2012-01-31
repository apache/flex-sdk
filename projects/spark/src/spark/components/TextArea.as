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

package flex.component
{
	
import flash.events.Event;
import flash.events.FocusEvent;

import flex.component.TextView;
import flex.events.TextOperationEvent;

import mx.core.ScrollPolicy;

import flashx.tcal.formats.LineBreak;

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
public class TextArea extends TextBase
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
	public function TextArea()
	{
		super();
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
	public var horizontalScrollBar:ScrollBar;
    
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
	public var verticalScrollBar:ScrollBar;
    
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
    public function setSelection(anchorIndex:int = 0,
                                 activeIndex:int = int.MAX_VALUE):void
    {
        if (!textView)
            return;

        textView.setSelection(anchorIndex, activeIndex);
    }

	/**
	 *  Documentation is not currently available.
	 */
    public function insertText(text:String):void
    {
        if (!textView)
            return;

        textView.insertText(text);
    }

	/**
	 *  Documentation is not currently available.
	 */
    public function appendText(text:String):void
    {
        if (!textView)
            return;

        textView.appendText(text);
    }

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
}

}
