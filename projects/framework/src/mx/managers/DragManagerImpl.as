////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2006-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.managers
{

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.system.ApplicationDomain;

import mx.core.DragSource;
import mx.core.IFlexDisplayObject;
import mx.core.IUIComponent;
import mx.core.UIComponentGlobals;
import mx.core.mx_internal;
import mx.effects.EffectInstance;
import mx.effects.Move;
import mx.effects.Zoom;
import mx.events.DragEvent;
import mx.events.MarshalEvent;
import mx.events.MarshalDragEvent;
import mx.managers.ISystemManager2;
import mx.managers.dragClasses.DragProxy;
import mx.styles.CSSStyleDeclaration;
import mx.styles.StyleManager;

use namespace mx_internal;

[ExcludeClass]

/**
 *  @private
 */
public class DragManagerImpl implements IDragManager
{
    include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class variables
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private static var sm:ISystemManager2;

	/**
	 *  @private
	 */
	private static var instance:IDragManager;

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	public static function getInstance():IDragManager
	{
		if (!instance)
		{
			sm = SystemManagerGlobals.topLevelSystemManagers[0];
			instance = new DragManagerImpl();

		}

		return instance;
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	public function DragManagerImpl()
	{
		super();

		if (instance)
			throw new Error("Instance already exists.");
			
		var ed:IEventDispatcher;

		if (!sm.isTopLevelRoot())
		{
			sandboxRoot = sm.getSandboxRoot();
			sandboxRoot.addEventListener(MarshalDragEvent.DISPATCH_EVENT, marshalDispatchEventHandler, false, 0, true);
		}
		else
		{
			ed = sm;
			ed.addEventListener(MouseEvent.MOUSE_DOWN, sm_mouseDownHandler, false, 0, true);
			ed.addEventListener(MouseEvent.MOUSE_UP, sm_mouseUpHandler, false, 0, true);
			sandboxRoot = sm;
			sandboxRoot.addEventListener(MarshalDragEvent.DISPATCH_EVENT, marshalDispatchEventHandler, false, 0, true);
		}

		// trace("creating DragManagerImpl", sm);
		sandboxRoot.addEventListener(MarshalEvent.DRAG_MANAGER, marshalDragManagerHandler, false, 0, true);
		var me:MarshalEvent = new MarshalEvent(MarshalEvent.DRAG_MANAGER);
		me.name = "update";
		// trace("--->update request for DragManagerImpl", sm);
		sandboxRoot.dispatchEvent(me);
		// trace("<---update request for DragManagerImpl", sm);
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	

	/**
	 *  @private
	 *  The highest place we can listen for events in our DOM
	 */
	private var sandboxRoot:IEventDispatcher;

	/**
	 *  @private
	 *  Object that initiated the drag.
	 */
	private var dragInitiator:IUIComponent;

	/**
	 *  @private
	 *  Object being dragged around.
	 */
	public var dragProxy:DragProxy;

	/**
	 *  @private
	 */
	private var bDoingDrag:Boolean = false;

	/**
	 *  @private
	 */
	private var mouseIsDown:Boolean = false;

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  Read-only property that returns <code>true</code>
	 *  if a drag is in progress.
	 */
	public function get isDragging():Boolean
	{
		return bDoingDrag;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  Initiates a drag and drop operation.
	 *
	 *  @param dragInitiator IUIComponent that specifies the component initiating
	 *  the drag.
	 *
	 *  @param dragSource DragSource object that contains the data
	 *  being dragged.
	 *
	 *  @param mouseEvent The MouseEvent that contains the mouse information
	 *  for the start of the drag.
	 *
	 *  @param dragImage The image to drag. This argument is optional.
	 *  If omitted, a standard drag rectangle is used during the drag and
	 *  drop operation. If you specify an image, you must explicitly set a 
	 *  height and width of the image or else it will not appear.
	 *
	 *  @param xOffset Number that specifies the x offset, in pixels, for the
	 *  <code>dragImage</code>. This argument is optional. If omitted, the drag proxy
	 *  is shown at the upper-left corner of the drag initiator. The offset is expressed
	 *  in pixels from the left edge of the drag proxy to the left edge of the drag
	 *  initiator, and is usually a negative number.
	 *
	 *  @param yOffset Number that specifies the y offset, in pixels, for the
	 *  <code>dragImage</code>. This argument is optional. If omitted, the drag proxy
	 *  is shown at the upper-left corner of the drag initiator. The offset is expressed
	 *  in pixels from the top edge of the drag proxy to the top edge of the drag
	 *  initiator, and is usually a negative number.
	 *
	 *  @param imageAlpha Number that specifies the alpha value used for the
	 *  drag image. This argument is optional. If omitted, the default alpha
	 *  value is 0.5. A value of 0.0 indicates that the image is transparent;
	 *  a value of 1.0 indicates it is fully opaque. 
	 */
	public function doDrag(
			dragInitiator:IUIComponent, 
			dragSource:DragSource, 
			mouseEvent:MouseEvent,
			dragImage:IFlexDisplayObject = null, // instance of dragged item(s)
			xOffset:Number = 0,
			yOffset:Number = 0,
			imageAlpha:Number = 0.5,
			allowMove:Boolean = true):void
	{
		var proxyWidth:Number;
		var proxyHeight:Number;
		
		// Can't start a new drag if we're already in the middle of one...
		if (bDoingDrag)
			return;
		
		// Can't do a drag if the mouse isn't down
		if (!(mouseEvent.type == MouseEvent.MOUSE_DOWN ||
			  mouseEvent.type == MouseEvent.CLICK ||
			  mouseIsDown ||
			  mouseEvent.buttonDown))
		{
			return;
		}    
			
		bDoingDrag = true;
		var me:MarshalEvent = new MarshalEvent(MarshalEvent.DRAG_MANAGER);
		me.name = "isDragging";
		me.value = true;
		// trace("-->dispatch isDragging for DragManagerImpl", sm, true);
		sandboxRoot.dispatchEvent(me);
		// trace("<--dispatch isDragging for DragManagerImpl", sm, true);
		
		this.dragInitiator = dragInitiator;

		// The drag proxy is a UIComponent with a single child -
		// an instance of the dragImage.
		dragProxy = new DragProxy(dragInitiator, dragSource);
		sm.addChildToSandboxRoot("popUpChildren", dragProxy);	

		if (!dragImage)
		{
			// No drag image specified, use default
			var dragManagerStyleDeclaration:CSSStyleDeclaration =
				StyleManager.getStyleDeclaration("DragManager");
			var dragImageClass:Class =
				dragManagerStyleDeclaration.getStyle("defaultDragImageSkin");
			dragImage = new dragImageClass();
			dragProxy.addChild(DisplayObject(dragImage));
			proxyWidth = dragInitiator.width;
			proxyHeight = dragInitiator.height;
		}
		else
		{
			dragProxy.addChild(DisplayObject(dragImage));
			if (dragImage is ILayoutManagerClient )
				UIComponentGlobals.layoutManager.validateClient(ILayoutManagerClient (dragImage), true);
			if (dragImage is IUIComponent)
			{
				proxyWidth = (dragImage as IUIComponent).getExplicitOrMeasuredWidth();
				proxyHeight = (dragImage as IUIComponent).getExplicitOrMeasuredHeight();
			}
			else
			{
				proxyWidth = dragImage.measuredWidth;
				proxyHeight = dragImage.measuredHeight;
			}
		}

		dragImage.setActualSize(proxyWidth, proxyHeight);
		dragProxy.setActualSize(proxyWidth, proxyHeight);
		
		// Alpha
		dragProxy.alpha = imageAlpha;

		dragProxy.allowMove = allowMove;
		
		var nonNullTarget:Object = mouseEvent.target;
		if (nonNullTarget == null)
			nonNullTarget = dragInitiator;
		
		var point:Point = new Point(mouseEvent.localX, mouseEvent.localY);
		point = DisplayObject(nonNullTarget).localToGlobal(point);
		point = DisplayObject(sandboxRoot).globalToLocal(point);
		var mouseX:Number = point.x;
		var mouseY:Number = point.y;

		// Set dragProxy.offset to the mouse offset within the drag proxy.
		var proxyOrigin:Point = DisplayObject(nonNullTarget).localToGlobal(
						new Point(mouseEvent.localX, mouseEvent.localY));
		proxyOrigin = DisplayObject(dragInitiator).globalToLocal(proxyOrigin);
		dragProxy.xOffset = proxyOrigin.x + xOffset;
		dragProxy.yOffset = proxyOrigin.y + yOffset;
		
		// Call onMouseMove to setup initial position of drag proxy and cursor.
		dragProxy.x = mouseX - dragProxy.xOffset;
		dragProxy.y = mouseY - dragProxy.yOffset;
		
		// Remember the starting location of the drag proxy so it can be
		// "snapped" back if the drop was refused.
		dragProxy.startX = dragProxy.x;
		dragProxy.startY = dragProxy.y;

		// Turn on caching.
		if (dragImage is DisplayObject) 
			DisplayObject(dragImage).cacheAsBitmap = true;
			

		var delegate:Object = dragProxy.automationDelegate;
		if (delegate)
			delegate.recordAutomatableDragStart(dragInitiator, mouseEvent);
	}
	
	/**
	 *  Call this method from your <code>dragEnter</code> event handler if you accept
	 *  the drag/drop data.
	 *  For example: 
	 *
	 *  <pre>DragManager.acceptDragDrop(event.target);</pre>
	 *
	 *	@param target The drop target accepting the drag.
	 */
	public function acceptDragDrop(target:IUIComponent):void
	{
		// trace("-->acceptDragDrop for DragManagerImpl", sm, target);

		if (dragProxy)
			dragProxy.target = target as DisplayObject;
		else if (isDragging)
		{
			var me:MarshalEvent = new MarshalEvent(MarshalEvent.DRAG_MANAGER);
			me.name = "acceptDragDrop";
			me.value = target;
			// trace("-->dispatch acceptDragDrop for DragManagerImpl", sm, target);
			sandboxRoot.dispatchEvent(me);
			// trace("<--dispatch acceptDragDrop for DragManagerImpl", sm, target);
		}
		// trace("<--acceptDragDrop for DragManagerImpl", sm, target);
	}
	
	/**
	 *  Sets the feedback indicator for the drag and drop operation.
	 *  Possible values are <code>DragManager.COPY</code>, <code>DragManager.MOVE</code>,
	 *  <code>DragManager.LINK</code>, or <code>DragManager.NONE</code>.
	 *
	 *  @param feedback The type of feedback indicator to display.
	 */
	public function showFeedback(feedback:String):void
	{
		// trace("-->showFeedback for DragManagerImpl", sm, feedback);
		if (dragProxy)
		{
			if (feedback == DragManager.MOVE && !dragProxy.allowMove)
				feedback = DragManager.COPY;

			dragProxy.action = feedback;
		}
		else if (isDragging)
		{
			var me:MarshalEvent = new MarshalEvent(MarshalEvent.DRAG_MANAGER);
			me.name = "showFeedback";
			me.value = feedback;
			// trace("-->dispatch showFeedback for DragManagerImpl", sm, feedback);
			sandboxRoot.dispatchEvent(me);
			// trace("<--dispatch showFeedback for DragManagerImpl", sm, feedback);
		}
		// trace("<--showFeedback for DragManagerImpl", sm, feedback);
	}
	
	/**
	 *  Returns the current drag and drop feedback.
	 *
	 *  @return  Possible return values are <code>DragManager.COPY</code>, 
	 *  <code>DragManager.MOVE</code>,
	 *  <code>DragManager.LINK</code>, or <code>DragManager.NONE</code>.
	 */
	public function getFeedback():String
	{
		// trace("-->getFeedback for DragManagerImpl", sm);
		if (!dragProxy && isDragging)
		{
			var me:MarshalEvent = new MarshalEvent(MarshalEvent.DRAG_MANAGER);
			me.name = "getFeedback";
			// trace("-->dispatch getFeedback for DragManagerImpl", sm);
			sandboxRoot.dispatchEvent(me);
			// trace("<--dispatch getFeedback for DragManagerImpl", sm);
			return me.value as String;
		}
		// trace("<--getFeedback for DragManagerImpl", sm);
		return dragProxy ? dragProxy.action : DragManager.NONE;
	}
	
	/**
	 *  @private
	 */
	public function endDrag():void
	{
		var me:MarshalEvent;

		// trace("-->endDrag for DragManagerImpl", sm);
		if (dragProxy)
		{
			sm.removeChildFromSandboxRoot("popUpChildren", dragProxy);	
			
			dragProxy.removeChildAt(0);	// The drag image is the only child
			dragProxy = null;
		}
		else if (isDragging)
		{
			me = new MarshalEvent(MarshalEvent.DRAG_MANAGER);
			me.name = "endDrag";
			// trace("-->dispatch endDrag for DragManagerImpl", sm);
			sandboxRoot.dispatchEvent(me);
			// trace("<--dispatch endDrag for DragManagerImpl", sm);
		}
		
		dragInitiator = null;
		bDoingDrag = false;
		me = new MarshalEvent(MarshalEvent.DRAG_MANAGER);
		me.name = "isDragging";
		me.value = false;
		// trace("-->dispatch isDragging for DragManagerImpl", sm, false);
		sandboxRoot.dispatchEvent(me);
		// trace("<--dispatch isDragging for DragManagerImpl", sm, false);
		// trace("<--endDrag for DragManagerImpl", sm);
	}
			
	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private function sm_mouseDownHandler(event:MouseEvent):void
	{
		mouseIsDown = true;
	}
	
	/**
	 *  @private
	 */
	private function sm_mouseUpHandler(event:MouseEvent):void
	{
		mouseIsDown = false;
	}

	/**
	 *  Marshal dispatchEvents
	 */
	private function marshalDispatchEventHandler(event:Event):void
	{
		if (event is MarshalDragEvent)
			return;

		var marshalEvent:Object = event;

		if (marshalEvent.dragTarget.loaderInfo.applicationDomain != sm.loaderInfo.applicationDomain)
		{
			// see if we parent the application domain of the dragtarget
			var ad:ApplicationDomain = marshalEvent.dragTarget.loaderInfo.applicationDomain.parentDomain;
			var inOurAD:Boolean = false;
			while (ad)
			{
				if (ad == ApplicationDomain.currentDomain)
				{
					inOurAD = true;
					break;
				}
				ad = ad.parentDomain;
			}
			if (!inOurAD)
				return;
		}


		var dragEvent:DragEvent = new DragEvent(marshalEvent.eventType, marshalEvent.bubbles, marshalEvent.cancelable);
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
		if (!marshalEvent.dragTarget.dispatchEvent(dragEvent))
		{
			event.preventDefault();
		}
	}

	/**
	 *  Marshal dragManager
	 */
	private function marshalDragManagerHandler(event:Event):void
	{
		if (event is MarshalEvent)
			return;

		var marshalEvent:Object = event;
		switch (marshalEvent.name)
		{
		case "isDragging":
			// trace("--marshaled isDragging for DragManagerImpl", sm, marshalEvent.value);
			bDoingDrag = marshalEvent.value;
			break;
		case "acceptDragDrop":
			if (dragProxy)
			{
				// trace("--marshaled acceptDragDrop for DragManagerImpl", sm, marshalEvent.value);
				dragProxy.target = marshalEvent.value;
			}
			break;
		case "showFeedback":
			// trace("--marshaled showFeedback for DragManagerImpl", sm, marshalEvent.value);
			showFeedback(marshalEvent.value);
			break;
		case "getFeedback":
			if (dragProxy)	// it is our drag
			{
				marshalEvent.value = getFeedback();
				// trace("--marshaled getFeedback for DragManagerImpl", sm, marshalEvent.value);
			}
			break;
		case "endDrag":
			// trace("--marshaled endDrag for DragManagerImpl", sm, marshalEvent.value);
			endDrag();
			break;
		case "update":
			// if we own the drag, then redispatch to tell the new guy
			if (dragProxy && isDragging)
			{
				// trace("-->marshaled update for DragManagerImpl", sm);
				var me:MarshalEvent = new MarshalEvent(MarshalEvent.DRAG_MANAGER);
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

