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
import flash.events.FocusEvent;

import mx.components.TextView;
import mx.components.baseClasses.FxTextBase;
import mx.components.baseClasses.FxComponent;
import mx.events.TextOperationEvent;

import flashx.tcal.formats.LineBreak;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the user pressed the Enter key.
 */
[Event(name="enter", type="mx.events.FlexEvent")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[DefaultProperty("text")]

/**
 *  The built-in set of states for the TextInput component.
 */
[SkinStates("normal", "disabled")]

[IconFile("FxTextInput.png")]

/**
 *  Documentation is not currently available.
 */
public class FxTextInput extends FxTextBase
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
	public function FxTextInput()
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
	override protected function partAdded(partName:String, instance:Object):void
	{
		super.partAdded(partName, instance);

		if (instance == textView)
		{
			// Set the TextView to allow only one line of input.
            textView.heightInLines = 1;
			textView.multiline = false;
            textView.setStyle("lineBreak", "explicit");
		}
	}

	/**
	 *  @private
	 */
	override protected function getUpdatedSkinState():String
	{
		return enabled ? "normal" : "disabled";
	}
}

}

