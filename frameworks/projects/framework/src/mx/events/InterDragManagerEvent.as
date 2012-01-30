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
 *  An event sent between DragManagers that are 
 *  in separate but trusted ApplicationDomains to
 *  handle the dispatching of DragEvents to the drag targets.
 *  One DragManager has a DragProxy that moves with 
 *  the mouse and looks for changes to the dropTarget.
 *  It cannot directly dispatch the DragEvent to a potential
 *  target in another ApplicationDomain because code
 *  in that ApplicationDomain would not type-match on DragEvent.
 *  Instead, the DragManager dispatches a InterDragManagerEvent
 *  that the other ApplicationDomain's DragManager listens
 *  for and it marshals the DragEvent and dispatches it to
 *  the potential dropTarget.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
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
	 *  to the target specified in the <code>dropTarget</code> property.
	 *
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
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
	 * 
	 *  @param type The event type; indicates the action that caused the event.
	 *
	 *  @param bubbles Specifies whether the event can bubble up the display list hierarchy.
	 *
	 *  @param cancelable Specifies whether the behavior associated with the event can be prevented.
	 *
	 *  @param localX The horizontal coordinate at which the event occurred relative to the containing sprite.
	 * 
	 *  @param localY The vertical coordinate at which the event occurred relative to the containing sprite.
	 *  
	 *  @param relatedObject A reference to a display list object that is related to the event.
	 *  
	 *  @param ctrlKey Indicates whether the <code>Ctrl</code> key was pressed.
	 *
	 *  @param altKey Indicates whether the <code>Alt</code> key was pressed.
	 *
	 *  @param shiftKey Indicates whether the <code>Shift</code> key was pressed.	 
	 *  
	 *  @param buttonDown Indicates whether the primary mouse button is pressed (true) or not (false).
	 *  
	 *  @param delta Indicates how many lines should be scrolled for each unit the user rotates the mouse wheel.
	 *  
	 *  @param dropTarget The potential drop target in the other application domain (which is why it is a DisplayObject and not some other class).
	 *  
	 *  @param dragEventType The event type for the DragEvent to be used by the receiving DragManager when creating the marshaled DragEvent.
	 *  
	 *  @param dragInitiator IUIComponent that specifies the component initiating
	 *  the drag.
	 *
	 *  @param dragSource A DragSource object containing the data being dragged.
	 *
	 *  @param action The specified drop action, such as <code>DragManager.MOVE</code>.
	 *
	 *  @param draggedItem An object representing the item that was dragged.
	 *  
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
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
	 *  The potential drop target in the other ApplicationDomain
     *  (which is why it is a DisplayObject and not some other class).
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var dropTarget:DisplayObject;

    //----------------------------------
    //  dragEventType
    //----------------------------------

	/**
	 *  The event type for the DragEvent to be used
	 *  by the receiving DragManager when creating the
	 *  marshaled DragEvent.
	 *  
	 *  @see mx.events.DragEvent
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var dragEventType:String;

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
		var cloneEvent:InterDragManagerEvent = new InterDragManagerEvent(type, bubbles, cancelable, 
                                                 localX, localY, relatedObject, ctrlKey, altKey, shiftKey,
												 buttonDown, delta, dropTarget, dragEventType, dragInitiator,
												 dragSource, action, draggedItem);

		return cloneEvent;
	}

}

}
