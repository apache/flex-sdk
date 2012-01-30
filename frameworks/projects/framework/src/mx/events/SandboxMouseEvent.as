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

package mx.events
{

import flash.events.Event;

/**
 *  This is an event sent between sandboxes to notify listeners
 *  about mouse activity in another sandbox.
 *
 *  For security reasons, some fields of a MouseEvent are not sent
 *  in a SandboxRootMouseEvent.
 */
public class SandboxRootMouseEvent extends Event
{
	include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
		
	/**
	 *  Mouse was clicked somewhere outside your sandbox.
	 */
    public static const CLICK_SOMEWHERE:String = "clickSomewhere";

	/**
	 *  Mouse was double-clicked somewhere outside your sandbox.
	 */
    public static const DOUBLE_CLICK_SOMEWHERE:String = "coubleClickSomewhere";

	/**
	 *  Mouse button was pressed down somewhere outside your sandbox.
	 */
    public static const MOUSE_DOWN_SOMEWHERE:String = "mouseDownSomewhere";

	/**
	 *  Mouse was moved somewhere outside your sandbox.
	 */
    public static const MOUSE_MOVE_SOMEWHERE:String = "mouseMoveSomewhere";

	/**
	 *  Mouse button was released somewhere outside your sandbox.
	 */
    public static const MOUSE_UP_SOMEWHERE:String = "mouseUpSomewhere";

	/**
	 *  Mouse wheel was spun somewhere outside your sandbox.
	 */
    public static const MOUSE_WHEEL_SOMEWHERE:String = "mouseWheelSomewhere";

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

	/**
     *  Documentation is not currently available.
     */
    public static function marshal(event:Event):SandboxRootMouseEvent
	{
		var eventObj:Object = event;

		return new SandboxRootMouseEvent(eventObj.type, eventObj.bubbles,
                                     eventObj.cancelable,
							         eventObj.ctrlKey, eventObj.altKey, 
							         eventObj.shiftKey, eventObj.buttonDown); 
	}

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
	 
	/** 
	 *  Constructor.
	 */
	public function SandboxRootMouseEvent(type:String, bubbles:Boolean = false,
                                      cancelable:Boolean = false,
									  ctrlKey:Boolean = false,
                                      altKey:Boolean = false,
                                      shiftKey:Boolean = false,
									  buttonDown:Boolean = false)
	{
		super(type, bubbles, cancelable);

		this.ctrlKey = ctrlKey;
		this.altKey = altKey;
		this.shiftKey = shiftKey;
		this.buttonDown = buttonDown;
	}

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  altKey
    //----------------------------------

	/**
	 *  @see flash.events.MouseEvent#altkey
	 */
	public var altKey:Boolean;

    //----------------------------------
    //  buttonDown
    //----------------------------------

	/**
	 *  @see flash.events.MouseEvent#buttonDown
	 */
	public var buttonDown:Boolean;

    //----------------------------------
    //  ctrlKey
    //----------------------------------

	/**
	 *  @see flash.events.MouseEvent#ctrlKey
	 */
	public var ctrlKey:Boolean;

    //----------------------------------
    //  shiftKey
    //----------------------------------

	/**
	 *  @see flash.events.MouseEvent#shiftKey
	 */
	public var shiftKey:Boolean;

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: Event
    //
    //--------------------------------------------------------------------------

	/**
     *  @private
     */
    override public function clone():Event
	{
		return new SandboxRootMouseEvent(type, bubbles, cancelable,
                                     ctrlKey, altKey, shiftKey, buttonDown);
	}
}

}
