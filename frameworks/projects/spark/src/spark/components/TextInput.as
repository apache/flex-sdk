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
import flex.core.SkinnableComponent;
import flex.events.TextOperationEvent;

import text.formats.LineBreak;

//--------------------------------------
//  Other metadata
//--------------------------------------

[DefaultProperty("text")]

/**
 *  The built-in set of states for the TextInput component.
 */
[SkinStates("enabled", "disabled")]

/**
 *  Documentation is not currently available.
 */
public class TextInput extends TextBase
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
	public function TextInput()
	{
		super();
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
	}

	/**
	 *  @private
	 */
	override protected function partAdded(partName:String, instance:*):void
	{
		super.partAdded(partName, instance);

		if (instance == textView)
		{
			// Set the TextView to allow only one line of input.
            textView.heightInLines = 1;
            textView.lineBreak = LineBreak.EXPLICIT;
			textView.multiline = false;
		}
	}

	/**
	 *  @private
	 */
	override protected function getUpdatedSkinState():String
	{
		return enabled ? "enabled" : "disabled";
	}
}

}

