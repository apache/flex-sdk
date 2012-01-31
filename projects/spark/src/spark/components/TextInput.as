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

import text.model.LineBreak;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispached after the <code>selectionAnchorIndex</code> and/or
 *  <code>selectionActiveIndex</code> properties have changed
 *  due to a user interaction.
 */
[Event(name="selectionChange", type="flash.events.Event")]

/**
 *  Dispatched before a user editing operation occurs.
 *  You can alter the operation, or cancel the event
 *  to prevent the operation from being processed.
 */
[Event(name="changing", type="flex.events.TextOperationEvent")]

/**
 *  Dispatched after a user editing operation is complete.
 */
[Event(name="change", type="flex.events.TextOperationEvent")]

/**
 *  Dispatched when the user presses the Enter key.
 */
[Event(name="enter", type="flash.events.Event")]

/**
 *  Documentation is not currently available.
 */
public class TextInput extends SkinnableComponent
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

    //--------------------------------------------------------------------------
    //
    //  Overridden properties: UIComponent
    //
    //--------------------------------------------------------------------------

	//----------------------------------
	//  enabled
    //----------------------------------

	/**
	 *  @private
	 */
	override public function set enabled(value:Boolean):void
	{
		if (value == enabled)
			return;
		
		super.enabled = value;
		
		invalidateSkinState();
	}

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

	//----------------------------------
	//  selectionActiveIndex
    //----------------------------------

	/**
	 *  @private
	 */
	private var _selectionActiveIndex:int = -1;

	/**
	 *  @private
	 */
	private var selectionActiveIndexChanged:Boolean = false;

	[Bindable("selectionChange")]
	
	/**
	 *  The active index of the selection.
	 *  The "active" point is the end of the selection
	 *  which is changed when the selection is extended.
	 *  The active index may be either the start
	 *  or the end of the selection. 
	 *
	 *  @default -1
	 */
	public function get selectionActiveIndex():int
	{
		return _selectionActiveIndex;
	}

	/**
	 *  @private
	 */
	public function set selectionActiveIndex(value:int):void
	{
		if (value == _selectionActiveIndex)
			return;
		
		_selectionActiveIndex = value;
		selectionActiveIndexChanged = true;

		invalidateProperties();
		
		dispatchEvent(new Event("selectionChange"));
	}

	//----------------------------------
	//  selectionAnchorIndex
    //----------------------------------

	/**
	 *  @private
	 */
	private var _selectionAnchorIndex:int = -1;

	/**
	 *  @private
	 */
	private var selectionAnchorIndexChanged:Boolean = false;

	[Bindable("selectionChange")]
	
	/**
	 *  The anchor index of the selection.
	 *  The "anchor" point is the stable end of the selection
	 *  when the selection is extended.
	 *  The anchor index may be either the start
	 *  or the end of the selection.
	 *
	 *  @default -1
	 */
	public function get selectionAnchorIndex():int
	{
		return _selectionAnchorIndex;
	}

	/**
	 *  @private
	 */
	public function set selectionAnchorIndex(value:int):void
	{
		if (value == _selectionAnchorIndex)
			return;
		
		_selectionAnchorIndex = value;
		selectionAnchorIndexChanged = true;

		invalidateProperties();

		dispatchEvent(new Event("selectionChange"));
	}

    //----------------------------------
	//  text
    //----------------------------------

	/**
	 *  @private
	 */
	private var _text:String = "";

	/**
	 *  @private
	 */
	private var textChanged:Boolean = false;

	[Bindable("change")]
	[Bindable("textChanged")]
	
	/**
	 *  The text String displayed by this TextInput.
	 */
	public function get text():String
	{
		return _text;
	}

	/**
	 *  @private
	 */
	public function set text(value:String):void
	{
		if (value == _text)
			return;

		_text = value;
		textChanged = true;

		invalidateProperties();
		
		dispatchEvent(new Event("textChanged"));
	}
    
    //----------------------------------
	//  textView
    //----------------------------------

    [SkinPart]

	/**
	 *  The TextView that must be present
	 *  in any skin assigned to this TextInput.
	 */
	public var textView:TextView;
    
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
		
		if (textChanged)
		{
			textView.text = _text;
			textChanged = false;
		}

		if (selectionAnchorIndexChanged)
		{
			textView.selectionAnchorIndex = _selectionAnchorIndex;
			selectionAnchorIndexChanged = false
		}

		if (selectionActiveIndexChanged)
		{
			textView.selectionActiveIndex = _selectionActiveIndex;
			selectionActiveIndexChanged = false
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
        
			// Start listening for various events from the TextView.
			textView.addEventListener("selectionChange",
									  textView_selectionChangeHandler);
			textView.addEventListener("changing", textView_changingHandler);
			textView.addEventListener("change", textView_changeHandler);
			textView.addEventListener("enter", textView_enterHandler);
		}
	}

	/**
	 *  @private
	 */
	override protected function partRemoved(partName:String, instance:*):void
	{
		super.partRemoved(partName, instance);

		if (instance == textView)
		{
			// Stop listening for various events from the TextView.
			textView.removeEventListener("selectionChange",
										 textView_selectionChangeHandler);
			textView.removeEventListener("changing", textView_changingHandler);
			textView.removeEventListener("change", textView_changeHandler);
			textView.removeEventListener("enter", textView_enterHandler);
		}
	}
    
	/**
	 *  @private
	 */
	override protected function getUpdatedSkinState():String
	{
		return enabled ? "enabled" : "disabled";
	}

	//--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Called when the TextView dispatches a 'selectionChange' event.
	 */
	private function textView_selectionChangeHandler(event:Event):void
	{
		// Update our storage variables for the selection indices.
		_selectionAnchorIndex = textView.selectionAnchorIndex;
		_selectionActiveIndex = textView.selectionActiveIndex;
		
		// Redispatch the event that came from the TextView.
		dispatchEvent(event);
	}

	/**
	 *  @private
	 *  Called when the TextView dispatches a 'change' event
	 *  after an editing operation.
	 */
	private function textView_changeHandler(event:TextOperationEvent):void
	{
		// Update our storage variable for the text string.
		_text = textView.text;

		// Redispatch the event that came from the TextView.
		dispatchEvent(event);
	}

	/**
	 *  @private
	 *  Called when the TextView dispatches a 'changing' event
	 *  before an editing operation.
	 */
	private function textView_changingHandler(event:TextOperationEvent):void
	{
		// Redispatch the event that came from the TextView.
		var newEvent:Event = event.clone();
		dispatchEvent(newEvent);
		
		// If the event dispatched from this TextInput is canceled,
		// cancel the one from the TextView, which will prevent
		// the editing operation from being processed.
		if (newEvent.isDefaultPrevented())
			event.preventDefault();
	}

	/**
	 *  @private
	 *  Called when the TextView dispatches an 'enter' event
	 *  in response to the Enter key.
	 */
	private function textView_enterHandler(event:Event):void
	{
		// Redispatch the event that came from the TextView.
		dispatchEvent(event);
	}
}

}

