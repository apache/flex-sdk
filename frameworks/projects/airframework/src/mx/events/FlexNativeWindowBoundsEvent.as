////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.events
{

import flash.geom.Rectangle;
import flash.events.Event;
import flash.events.NativeWindowBoundsEvent;

public class FlexNativeWindowBoundsEvent extends NativeWindowBoundsEvent
{
	
	/**
	 *  dispatched when the underlying NativeWindow resizes
	 *
	 *  @eventType windowResize
	 */
	public static const WINDOW_RESIZE:String = "windowResize";
	
	/**
	 *  dispatched when the underlying NativeWindow changes
	 *
	 *  @eventType windowMove
	 */
	public static const WINDOW_MOVE:String = "windowMove";
	
	//--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *
     *  @param type The event type; indicates the action that caused the event.
     *
     *  @param bubbles Specifies whether the event can bubble up
     *  the display list hierarchy.
     *
     *  @param cancelable Specifies whether the behavior
     *  associated with the event can be prevented.
     * 
     *  @param beforeBounds The bounds of the window before the resize.
     * 
     *  @param afterBounds The bounds of the window before the resize.
     */
	public function FlexNativeWindowBoundsEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, 
					beforeBounds:Rectangle = null, afterBounds:Rectangle = null)
	{
		super(type, bubbles, cancelable, beforeBounds, afterBounds);
	}
		
	
	
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
        return new FlexNativeWindowBoundsEvent(type, bubbles, cancelable, beforeBounds, afterBounds);
    }
}
}