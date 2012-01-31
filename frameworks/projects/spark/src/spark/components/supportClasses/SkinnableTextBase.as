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

package mx.components.baseClasses
{
	
import flash.events.Event;
import flash.events.FocusEvent;

import mx.components.TextView;
import mx.components.baseClasses.FxComponent;
import mx.events.TextOperationEvent;

import mx.events.FlexEvent;

import flashx.tcal.events.SelectionEvent;
import flashx.tcal.formats.LineBreak;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispached after the <code>selectionAnchorPosition</code> and/or
 *  <code>selectionActivePosition</code> properties have changed
 *  due to a user interaction.
 */
[Event(name="selectionChange", type="mx.events.AnimationEvent")]

/**
 *  Dispatched before a user editing operation occurs.
 *  You can alter the operation, or cancel the event
 *  to prevent the operation from being processed.
 */
[Event(name="changing", type="mx.events.TextOperationEvent")]

/**
 *  Dispatched after a user editing operation is complete.
 */
[Event(name="change", type="mx.events.TextOperationEvent")]

/**
 *  Documentation is not currently available.
 */
public class FxTextBase extends FxComponent
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor. 
     */    
	public function FxTextBase()
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
	//  selectionActivePosition
    //----------------------------------

	/**
	 *  @private
	 */
	private var _selectionActivePosition:int = -1;

	/**
	 *  @private
	 */
	private var selectionActivePositionChanged:Boolean = false;

	[Bindable("selectionChange")]
	
	/**
	 *  The active position of the selection.
	 *  The "active" point is the end of the selection
	 *  which is changed when the selection is extended.
	 *  The active position may be either the start
	 *  or the end of the selection. 
	 *
	 *  @default -1
	 */
	public function get selectionActivePosition():int
	{
		return _selectionActivePosition;
	}

	/**
	 *  @private
	 */
	public function set selectionActivePosition(value:int):void
	{
		if (value == _selectionActivePosition)
			return;
		
		_selectionActivePosition = value;
		selectionActivePositionChanged = true;

		invalidateProperties();
		
		dispatchEvent(new FlexEvent(FlexEvent.SELECTION_CHANGE));
	}

	//----------------------------------
	//  selectionAnchorPosition
    //----------------------------------

	/**
	 *  @private
	 */
	private var _selectionAnchorPosition:int = -1;

	/**
	 *  @private
	 */
	private var selectionAnchorPositionChanged:Boolean = false;

	[Bindable("selectionChange")]
	
	/**
	 *  The anchor position of the selection.
	 *  The "anchor" point is the stable end of the selection
	 *  when the selection is extended.
	 *  The anchor position may be either the start
	 *  or the end of the selection.
	 *
	 *  @default -1
	 */
	public function get selectionAnchorPosition():int
	{
		return _selectionAnchorPosition;
	}

	/**
	 *  @private
	 */
	public function set selectionAnchorPosition(value:int):void
	{
		if (value == _selectionAnchorPosition)
			return;
		
		_selectionAnchorPosition = value;
		selectionAnchorPositionChanged = true;

		invalidateProperties();

		dispatchEvent(new FlexEvent(FlexEvent.SELECTION_CHANGE));
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

		if (textChanged)
		{
			textView.text = _text;
			textChanged = false;
		}

		if (selectionAnchorPositionChanged)
		{
			textView.selectionAnchorPosition = _selectionAnchorPosition;
			selectionAnchorPositionChanged = false
		}

		if (selectionActivePositionChanged)
		{
			textView.selectionActivePosition = _selectionActivePosition;
			selectionActivePositionChanged = false
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
			// Start listening for various events from the TextView.

			textView.addEventListener(SelectionEvent.SELECTION_CHANGE,
									  textView_selectionChangeHandler);

			textView.addEventListener("changing",
                                      textView_changingHandler);

			textView.addEventListener("change",
                                      textView_changeHandler);
			
            textView.addEventListener(FlexEvent.ENTER,
                                      textView_enterHandler);
                                      
            // Set the initial text value
            textView.text = _text;
		}
	}

	/**
	 *  @private
	 */
	override protected function partRemoved(partName:String, instance:Object):void
	{
		super.partRemoved(partName, instance);

		if (instance == textView)
		{
			// Stop listening for various events from the TextView.

			textView.removeEventListener(SelectionEvent.SELECTION_CHANGE,
										 textView_selectionChangeHandler);

			textView.removeEventListener("changing",
                                         textView_changingHandler);

			textView.removeEventListener("change",
                                          textView_changeHandler);

			textView.removeEventListener(FlexEvent.ENTER,
                                         textView_enterHandler);
		}
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
		_selectionAnchorPosition = textView.selectionAnchorPosition;
		_selectionActivePosition = textView.selectionActivePosition;
		
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
