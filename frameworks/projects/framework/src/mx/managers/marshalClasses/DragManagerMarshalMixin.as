////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.managers.marshalClasses
{

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.IEventDispatcher;

import mx.events.DragEvent;
import mx.events.InterDragManagerEvent;
import mx.events.InterManagerRequest;
import mx.events.Request;
import mx.managers.DragManagerImpl;
import mx.managers.IMarshalSystemManager;
import mx.managers.ISystemManager;
import mx.managers.SystemManager;
import mx.managers.SystemManagerGlobals;
import mx.core.DragSource;
import mx.core.IFlexModuleFactory;
import mx.core.mx_internal;

[ExcludeClass]

[Mixin]

/**
 *  @private
 *  A SystemManager has various types of children,
 *  such as the Application, popups, 
 *  tooltips, and custom cursors.
 *  You can access the just the custom cursors through
 *  the <code>cursors</code> property,
 *  the tooltips via <code>toolTips</code>, and
 *  the popups via <code>popUpChildren</code>.  Each one returns
 *  a SystemChildrenList which implements IChildList.  The SystemManager's
 *  IChildList methods return the set of children that aren't popups, tooltips
 *  or cursors.  To get the list of all children regardless of type, you
 *  use the rawChildrenList property which returns this SystemRawChildrenList.
 */
public class DragManagerMarshalMixin
{
    include "../../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class Method
	//
	//--------------------------------------------------------------------------
	
	public static function init(fbs:IFlexModuleFactory):void
	{
		if (!DragManagerImpl.mixins)
			DragManagerImpl.mixins = [];
        if (DragManagerImpl.mixins.indexOf(DragManagerMarshalMixin) == -1)
    		DragManagerImpl.mixins.push(DragManagerMarshalMixin);
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */
	public function DragManagerMarshalMixin(owner:DragManagerImpl = null)
	{
		super();

        if (!owner)
            return;

		this.dragManager = owner;
		dragManager.addEventListener("initialize", initializeHandler);
		dragManager.addEventListener("doDrag", doDragHandler);
		dragManager.addEventListener("popUpChildren", popUpChildrenHandler);
		dragManager.addEventListener("acceptDragDrop", acceptDragDropHandler);
		dragManager.addEventListener("showFeedback", showFeedbackHandler);
		dragManager.addEventListener("getFeedback", getFeedbackHandler);
		dragManager.addEventListener("endDrag", endDragHandler);

	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private var sm:ISystemManager;
	
	/**
	 *  @private
	 *  The highest place we can listen for events in our DOM
	 */
	private var sandboxRoot:IEventDispatcher;

	/**
	 *  @private
	 */
	private var dragManager:DragManagerImpl;


	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	public function initializeHandler(event:Event):void
	{
		var ed:IEventDispatcher;

		sm = SystemManagerGlobals.topLevelSystemManagers[0];
		if (!sm.isTopLevelRoot())
		{
			sandboxRoot = sm.getSandboxRoot();
			sandboxRoot.addEventListener(InterDragManagerEvent.DISPATCH_DRAG_EVENT, marshalDispatchEventHandler, false, 0, true);
		}
		else
		{
			ed = sm;
			sandboxRoot = sm;
			sandboxRoot.addEventListener(InterDragManagerEvent.DISPATCH_DRAG_EVENT, marshalDispatchEventHandler, false, 0, true);
		}

		// trace("creating DragManagerImpl", sm);
		sandboxRoot.addEventListener(InterManagerRequest.DRAG_MANAGER_REQUEST, marshalDragManagerHandler, false, 0, true);
		var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.DRAG_MANAGER_REQUEST);
		me.name = "update";
		// trace("--->update request for DragManagerImpl", sm);
		sandboxRoot.dispatchEvent(me);
		// trace("<---update request for DragManagerImpl", sm);
	}

	public function doDragHandler(event:Event):void
	{

		var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.DRAG_MANAGER_REQUEST);
		me.name = "isDragging";
		me.value = true;
		// trace("-->dispatch isDragging for DragManagerImpl", sm, true);
		sandboxRoot.dispatchEvent(me);
		// trace("<--dispatch isDragging for DragManagerImpl", sm, true);
		
		me = new InterManagerRequest(InterManagerRequest.DRAG_MANAGER_REQUEST);
		me.name = "mouseShield";
		me.value = true;
		// trace("-->dispatch add mouseShield.for DragManagerImpl", sm);
		sandboxRoot.dispatchEvent(me);

	}

	public function acceptDragDropHandler(event:Request):void
	{

		if (dragManager.isDragging)
		{
			var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.DRAG_MANAGER_REQUEST);
			me.name = "acceptDragDrop";
			me.value = event.value;
			// trace("-->dispatch acceptDragDrop for DragManagerImpl", sm, target);
			sandboxRoot.dispatchEvent(me);
			// trace("<--dispatch acceptDragDrop for DragManagerImpl", sm, target);
		}
		// trace("<--acceptDragDrop for DragManagerImpl", sm, target);

	}

	public function showFeedbackHandler(event:Request):void
	{
		if (dragManager.isDragging)
		{
			var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.DRAG_MANAGER_REQUEST);
			me.name = "showFeedback";
			me.value = event.value;
			// trace("-->dispatch showFeedback for DragManagerImpl", sm, feedback);
			sandboxRoot.dispatchEvent(me);
			// trace("<--dispatch showFeedback for DragManagerImpl", sm, feedback);
		}
		// trace("<--showFeedback for DragManagerImpl", sm, feedback);
	}


	public function getFeedbackHandler(event:Request):void
	{
		// trace("-->getFeedback for DragManagerImpl", sm);
		if (!dragManager.dragProxy && dragManager.isDragging)
		{
			var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.DRAG_MANAGER_REQUEST);
			me.name = "getFeedback";
			// trace("-->dispatch getFeedback for DragManagerImpl", sm);
			sandboxRoot.dispatchEvent(me);
			// trace("<--dispatch getFeedback for DragManagerImpl", sm);
			event.preventDefault();
			event.value = me.value;
		}
	}

	public function popUpChildrenHandler(event:Event):void
	{
		var mp:IMarshalSystemManager =
			IMarshalSystemManager(sm.getImplementation("mx.managers::IMarshalSystemManager"));

		mp.addChildToSandboxRoot("popUpChildren", dragManager.dragProxy);	
        event.preventDefault();
	}

	public function endDragHandler(event:Event):void
	{
		var me:InterManagerRequest;

		// trace("-->endDrag for DragManagerImpl", sm);
		if (dragManager.dragProxy)
		{
			var mp:IMarshalSystemManager =
				IMarshalSystemManager(sm.getImplementation("mx.managers::IMarshalSystemManager"));

			mp.removeChildFromSandboxRoot("popUpChildren", dragManager.dragProxy);	
			
			dragManager.dragProxy.removeChildAt(0);	// The drag image is the only child
			dragManager.dragProxy = null;
		}
		else if (dragManager.isDragging)
		{
			me = new InterManagerRequest(InterManagerRequest.DRAG_MANAGER_REQUEST);
			me.name = "endDrag";
			// trace("-->dispatch endDrag for DragManagerImpl", sm);
			sandboxRoot.dispatchEvent(me);
			// trace("<--dispatch endDrag for DragManagerImpl", sm);
		}
		me = new InterManagerRequest(InterManagerRequest.DRAG_MANAGER_REQUEST);
		me.name = "mouseShield";
		me.value = false;
		// trace("-->dispatch remove mouseShield.for DragManagerImpl", sm);
		sandboxRoot.dispatchEvent(me);
		
		me = new InterManagerRequest(InterManagerRequest.DRAG_MANAGER_REQUEST);
		me.name = "isDragging";
		me.value = false;
		// trace("-->dispatch isDragging for DragManagerImpl", sm, false);
		sandboxRoot.dispatchEvent(me);
		// trace("<--dispatch isDragging for DragManagerImpl", sm, false);
		// trace("<--endDrag for DragManagerImpl", sm);
        event.preventDefault();
	}

	/**
	 *  Marshal dispatchEvents
	 */
	private function marshalDispatchEventHandler(event:Event):void
	{
		if (event is InterDragManagerEvent)
			return;

		var marshalEvent:Object = event;

		var swfRoot:DisplayObject = SystemManager.getSWFRoot(marshalEvent.dropTarget);
		if (!swfRoot)
			return;	// doesn't belong to this appdomain

		var dragEvent:DragEvent = new DragEvent(marshalEvent.dragEventType, marshalEvent.bubbles, marshalEvent.cancelable);
		dragEvent.localX = marshalEvent.localX;
		dragEvent.localY = marshalEvent.localY;
		dragEvent.action = marshalEvent.action;
		dragEvent.ctrlKey = marshalEvent.ctrlKey;
		dragEvent.altKey = marshalEvent.altKey;
		dragEvent.shiftKey = marshalEvent.shiftKey;
		dragEvent.draggedItem = marshalEvent.draggedItem;
		dragEvent.dragSource = new DragSource();
		var formats:Array = marshalEvent.dragSource.formats;
		var n:int = formats.length;
		for (var i:int = 0; i < n; i++)
		{
			// this will call handlers right away, so deferred clipboard will be costly
			dragEvent.dragSource.addData(marshalEvent.dragSource.dataForFormat(formats[i]), formats[i]);
		}
		if (!marshalEvent.dropTarget.dispatchEvent(dragEvent))
		{
			event.preventDefault();
		}
	}

	/**
	 *  Marshal dragManager
	 */
	private function marshalDragManagerHandler(event:Event):void
	{
		if (event is InterManagerRequest)
			return;

		var marshalEvent:Object = event;
		switch (marshalEvent.name)
		{
		case "isDragging":
			// trace("--marshaled isDragging for DragManagerImpl", sm, marshalEvent.value);
			dragManager.bDoingDrag = marshalEvent.value;
			break;
		case "acceptDragDrop":
			if (dragManager.dragProxy)
			{
				// trace("--marshaled acceptDragDrop for DragManagerImpl", sm, marshalEvent.value);
				dragManager.dragProxy.target = marshalEvent.value;
			}
			break;
		case "showFeedback":
			if (dragManager.dragProxy)	// it is our drag
			{
				// trace("--marshaled showFeedback for DragManagerImpl", sm, marshalEvent.value);
				dragManager.showFeedback(marshalEvent.value);
			}
			break;
		case "getFeedback":
			if (dragManager.dragProxy)	// it is our drag
			{
				marshalEvent.value = dragManager.getFeedback();
				// trace("--marshaled getFeedback for DragManagerImpl", sm, marshalEvent.value);
			}
			break;
		case "endDrag":
			// trace("--marshaled endDrag for DragManagerImpl", sm, marshalEvent.value);
			dragManager.endDrag();
			break;
		case "update":
			// if we own the drag, then redispatch to tell the new guy
			if (dragManager.dragProxy && dragManager.isDragging)
			{
				// trace("-->marshaled update for DragManagerImpl", sm);
				var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.DRAG_MANAGER_REQUEST);
				me.name = "isDragging";
				me.value = true;
				// trace("-->dispatched isDragging for DragManagerImpl", sm, true);
				sandboxRoot.dispatchEvent(me);
				// trace("<--dispatched isDragging for DragManagerImpl", sm, true);
				// trace("<--marshaled update for DragManagerImpl", sm);
			}
		}
	}
}

}
