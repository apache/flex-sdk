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

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.events.Event;
import mx.core.DragSource;
import mx.core.IUIComponent;
import mx.events.DragEvent;

/** 
 *  This is an event sent between DragManagers
 *  in separate ApplicationDomains that are trusted to
 *  handle the dispatching of DragEvents to the drag targets.
 *  One DragManager has a DragProxy that is moving with 
 *  the mouse and looking for changes to the dropTarget.
 *  It can't directly dispatch the DragEvent to a potential
 *  target in another ApplicationDomain because code
 *  in that ApplicationDomain would not type-match on DragEvent.
 *  Instead, the DragManager dispatches a InterDragManagerEvent
 *  that the other ApplicationDomain's DragManager is listening
 *  for and it marshals the DragEvent and dispatches it to
 *  the potential dropTarget
 */
public class InterDragManagerEvent extends DragEvent
{
	include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
		
	/**
	 *	Dispatch a DragEvent event to a target in another ApplicationDomain.
	 *  The receiving DragManager marshals the DragEvent and dispatches it
	 *  to the target specified in the dropTarget property
	 *
	 */
    public static const DISPATCH_DRAG_EVENT:String =
        "dispatchDragEvent";

	 
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

	/** 
	 *  Constructor.
	 */
	public function InterDragManagerEvent(type:String, bubbles:Boolean = false,
										cancelable:Boolean = false,
										localX:Number = NaN, 
										localY:Number = NaN, 
										relatedObject:InteractiveObject = null, 
										ctrlKey:Boolean = false, 
										altKey:Boolean = false, 
										shiftKey:Boolean = false, 
										buttonDown:Boolean = false, 
										delta:int = 0, 
										dropTarget:DisplayObject = null, 
										dragEventType:String = null,
									    dragInitiator:IUIComponent = null,
									    dragSource:DragSource = null,
									    action:String = null,
										draggedItem:Object = null)

	{
		super(type, false, false, dragInitiator, dragSource, action, ctrlKey, altKey, shiftKey);

		this.dropTarget = dropTarget;
		this.dragEventType = dragEventType;

		this.draggedItem = draggedItem;

		this.localX = localX;
		this.localY = localY;
		this.buttonDown = buttonDown;
		this.delta = delta;
		this.relatedObject = relatedObject;
	}

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------


    //----------------------------------
    //  dragTarget
    //----------------------------------

	/**
	 *  The potential drop target in the other application domain
     *  (which is why it is a DisplayObject and not some other class).
	 */
	public var dropTarget:DisplayObject;

    //----------------------------------
    //  dragEventType
    //----------------------------------

	/**
	 *  The event type for the DragEvent to be used
	 *  by the receiving DragManager when creating the
	 *  marshaled DragEvent.
	 *  @see mx.events.DragEvent
	 */
	public var dragEventType:String;

}

}
