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

import text.formats.LineBreak;

[DefaultProperty("content")]

/**
 *  Documentation is not currently available.
 */
public class TextArea extends TextInput
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
	override protected function partAdded(partName:String, instance:*):void
	{
        super.partAdded(partName, instance);

		if (instance == textView)
		{
			// Set the TextView to allow multiple lines of input.
			textView.heightInLines = 10;
            textView.lineBreak = LineBreak.TO_FIT;
			textView.multiline = true;
        }
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
