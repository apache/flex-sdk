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

package mx.managers
{

import flash.desktop.Clipboard;
import flash.desktop.NativeDragManager;
import flash.desktop.NativeDragOptions;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.MouseEvent;
import flash.events.NativeDragEvent;
import flash.geom.Point;
import flash.system.Capabilities;

import mx.core.DragSource;
import mx.core.IFlexDisplayObject;
import mx.core.IFlexModuleFactory;
import mx.core.IUIComponent;
import mx.core.UIComponentGlobals;
import mx.core.mx_internal;
import mx.events.DragEvent;
import mx.events.FlexEvent;
import mx.events.InterDragManagerEvent;
import mx.events.InterManagerRequest;
import mx.managers.dragClasses.DragProxy;
import mx.styles.CSSStyleDeclaration;
import mx.styles.StyleManager;

use namespace mx_internal;

[ExcludeClass]

/**
 *  @private
 * 
 *  @playerversion AIR 1.1
 */
public class NativeDragManagerImpl implements IDragManager
{
 
	//--------------------------------------------------------------------------
	//
	//  Class variables
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private static var sm:ISystemManager;

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
			instance = new NativeDragManagerImpl();
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
	public function NativeDragManagerImpl()
	{
		super();

		if (instance)
			throw new Error("Instance already exists.");
			
		registerSystemManager(sm);
		sandboxRoot = sm.getSandboxRoot();
		sandboxRoot.addEventListener(InterDragManagerEvent.DISPATCH_DRAG_EVENT, marshalDispatchEventHandler, false, 0, true);

		// trace("creating DragManagerImpl", sm);
		sandboxRoot.addEventListener(InterManagerRequest.DRAG_MANAGER_REQUEST, marshalDragManagerHandler, false, 0, true);
		var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.DRAG_MANAGER_REQUEST);
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
	 *  Object being dragged around.
	 */
	public var dragProxy:DragProxy;

	/**
	 *  @private
	 */
	private var mouseIsDown:Boolean = false;

	private var _action:String;

	/**
	 *  @private
	 */
	private var _dragInitiator:IUIComponent;
	
	/**
	 *  @private
	 */
	private var _clipboard:Clipboard;
	
	/**
	 *  @private
	 */
	private var _dragImage:IFlexDisplayObject;
	
	private var _offset:Point;
	
	private var _allowedActions:NativeDragOptions;
	
	private var _allowMove:Boolean;
	
	private var _relatedObject:InteractiveObject;
	
	/**
	 *  @private
	 *  The highest place we can listen for events in our DOM
	 */
	private var sandboxRoot:IEventDispatcher;

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
		return flash.desktop.NativeDragManager.isDragging;// || bDoingDrag;
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
		if (isDragging)
			return; 
		
		// Can't do a drag if the mouse isn't down
		if (!(mouseEvent.type == MouseEvent.MOUSE_DOWN ||
			  mouseEvent.type == MouseEvent.CLICK ||
			  mouseIsDown ||
			  mouseEvent.buttonDown)) 
		{ 
			return;
		}
		
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

		_clipboard = new Clipboard();
		_dragInitiator = dragInitiator;
		_offset = new Point(xOffset, yOffset);
		_allowMove = allowMove;
		
		//adjust offsets for imagePlacement.
		_offset.y -= InteractiveObject(dragInitiator).mouseY;
		_offset.x -= InteractiveObject(dragInitiator).mouseX;
		
		// TODO!!! We need to pass in these values as a function parameter
		_allowedActions = new NativeDragOptions();
		_allowedActions.allowCopy = true;
		_allowedActions.allowLink = true;
		_allowedActions.allowMove = allowMove;
		
		// Transfer the dragSource into a Clipboard
		for (var i:int = 0; i < dragSource.formats.length; i++)
		{
			var format:String = dragSource.formats[i] as String;
			
			// Create an object to store a reference to the format and dragSource.
			// This delays copying over the drag data until it is needed
			var dataFetcher:DragDataFormatFetcher = new DragDataFormatFetcher();
			dataFetcher.dragSource = dragSource;
			dataFetcher.format = format;
						
			_clipboard.setDataHandler(format, dataFetcher.getDragSourceData, false);
		}	
		
		if (!dragImage)
		{
			// No drag image specified, use default
			var dragManagerStyleDeclaration:CSSStyleDeclaration =
				StyleManager.getStyleManager(sm as IFlexModuleFactory).getStyleDeclaration("DragManager");
			var dragImageClass:Class =
				dragManagerStyleDeclaration.getStyle("defaultDragImageSkin");
			dragImage = new dragImageClass();
			proxyWidth = dragInitiator ? dragInitiator.width : 0;
			proxyHeight = dragInitiator ? dragInitiator.height : 0;
			if (dragImage is IFlexDisplayObject)
				IFlexDisplayObject(dragImage).setActualSize(proxyWidth, proxyHeight);
		}
		else
		{
			proxyWidth = dragImage.width;
			proxyHeight = dragImage.height;
		}

		_dragImage = dragImage; 	
						
		if (dragImage is IUIComponent && dragImage is ILayoutManagerClient && 
			!ILayoutManagerClient(dragImage).initialized && dragInitiator)
		{
			dragImage.addEventListener(FlexEvent.UPDATE_COMPLETE,initiateDrag);
			dragInitiator.systemManager.popUpChildren.addChild(DisplayObject(dragImage));
						
			if (dragImage is ILayoutManagerClient )
			{
				UIComponentGlobals.layoutManager.validateClient(ILayoutManagerClient(dragImage), true);
			}
			
			if(dragImage is IUIComponent)
			{
				dragImage.setActualSize(proxyWidth, proxyHeight);
				proxyWidth = (dragImage as IUIComponent).getExplicitOrMeasuredWidth();
				proxyHeight = (dragImage as IUIComponent).getExplicitOrMeasuredHeight();
			}
			else
			{
				proxyWidth = dragImage.measuredWidth;
				proxyHeight = dragImage.measuredHeight;
			}
			
			if (dragImage is ILayoutManagerClient )
			{
				UIComponentGlobals.layoutManager.validateClient(ILayoutManagerClient(dragImage));
			}
		}
		else
		{ 
			initiateDrag(null, false);
			return;
		}
	}
	
	/**
	 *  Finish up the doDrag once the dragImage has been drawn
	 */ 
	private function initiateDrag(event:FlexEvent, removeImage:Boolean = true):void
	{
		if (removeImage)
			_dragImage.removeEventListener(FlexEvent.UPDATE_COMPLETE, initiateDrag);
		var dragBitmap:BitmapData 	
		if (_dragImage.width && _dragImage.height)
			dragBitmap = new BitmapData(_dragImage.width, _dragImage.height, true, 0x000000);
		else
			dragBitmap = new BitmapData(1, 1, true, 0x000000);
		dragBitmap.draw(_dragImage);
		
		if (removeImage && _dragImage is IUIComponent && _dragInitiator)		
		{
			_dragInitiator.systemManager.popUpChildren.removeChild(DisplayObject(_dragImage));
		}
		
		// TODO!!! include _dragActions as the last param
		flash.desktop.NativeDragManager.doDrag(InteractiveObject(_dragInitiator), _clipboard, dragBitmap, _offset, _allowedActions); 
		//NativeDragManager.dropAction = _allowMove ? DragManager.MOVE : DragManager.COPY;
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
		if (isDragging)
		{
			// trace("NativeDragMgr.acceptDragDrop targ",target);
			var dispObj:InteractiveObject = target as InteractiveObject;
			if (dispObj)
				flash.desktop.NativeDragManager.acceptDragDrop(dispObj);
		}
		else
		{
			var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.DRAG_MANAGER_REQUEST);
			me.name = "acceptDragDrop";
			me.value = target;
			// trace("-->dispatch acceptDragDrop for DragManagerImpl", sm, target);
			sandboxRoot.dispatchEvent(me);
			// trace("<--dispatch acceptDragDrop for DragManagerImpl", sm, target);
		}
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
		if (isDragging)
		{
			if (feedback == DragManager.MOVE && !_allowedActions.allowMove)
				return;
			else if (feedback == DragManager.COPY && !_allowedActions.allowCopy)
				return;
			else if (feedback == DragManager.LINK && !_allowedActions.allowLink)
				return;
			flash.desktop.NativeDragManager.dropAction = feedback;
		}
		else
		{
			var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.DRAG_MANAGER_REQUEST);
			me.name = "showFeedback";
			me.value = feedback;
			// trace("-->dispatch showFeedback for DragManagerImpl", sm, feedback);
			sandboxRoot.dispatchEvent(me);
			// trace("<--dispatch showFeedback for DragManagerImpl", sm, feedback);
		}
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
		if (!isDragging)
		{
			var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.DRAG_MANAGER_REQUEST);
			me.name = "getFeedback";
			// trace("-->dispatch getFeedback for DragManagerImpl", sm);
			sandboxRoot.dispatchEvent(me);
			// trace("<--dispatch getFeedback for DragManagerImpl", sm);
			return me.value as String;
		}

		return flash.desktop.NativeDragManager.dropAction;
	}
	
	/**
	 *  @Review
	 *  Not Supported by NativeDragManagerImpl
	 */
	public function endDrag():void
	{
		var me:InterManagerRequest;

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

	}
			
	/**
	 *  @private
	 *  register ISystemManagers that will listen for events 
	 *  (such as those for additional windows)
	 */
	mx_internal function registerSystemManager(sm:ISystemManager):void
	{
		if (sm.isTopLevel())
		{
			sm.addEventListener(MouseEvent.MOUSE_DOWN, sm_mouseDownHandler);
			sm.addEventListener(MouseEvent.MOUSE_UP, sm_mouseUpHandler);
		}

		sm.stage.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, nativeDragEventHandler, true);
		sm.stage.addEventListener(NativeDragEvent.NATIVE_DRAG_COMPLETE, nativeDragEventHandler, true);
		sm.stage.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, nativeDragEventHandler, true);
		sm.stage.addEventListener(NativeDragEvent.NATIVE_DRAG_EXIT, nativeDragEventHandler, true);
		sm.stage.addEventListener(NativeDragEvent.NATIVE_DRAG_OVER, nativeDragEventHandler, true);
		sm.stage.addEventListener(NativeDragEvent.NATIVE_DRAG_START, nativeDragEventHandler, true); 

	}
	
	/**
	 *  @private
	 *  unregister ISystemManagers that will listen for events 
	 *  (such as those for additional windows)
	 */
	mx_internal function unregisterSystemManager(sm:ISystemManager):void
	{
		if (sm.isTopLevel())
		{
			sm.removeEventListener(MouseEvent.MOUSE_DOWN, sm_mouseDownHandler);
			sm.removeEventListener(MouseEvent.MOUSE_UP, sm_mouseUpHandler);
		}

		sm.stage.removeEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, nativeDragEventHandler, true);
		sm.stage.removeEventListener(NativeDragEvent.NATIVE_DRAG_COMPLETE, nativeDragEventHandler, true);
		sm.stage.removeEventListener(NativeDragEvent.NATIVE_DRAG_DROP, nativeDragEventHandler, true);
		sm.stage.removeEventListener(NativeDragEvent.NATIVE_DRAG_EXIT, nativeDragEventHandler, true);
		sm.stage.removeEventListener(NativeDragEvent.NATIVE_DRAG_OVER, nativeDragEventHandler, true);
		sm.stage.removeEventListener(NativeDragEvent.NATIVE_DRAG_START, nativeDragEventHandler, true); 

	}
	
	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------
	private function sm_mouseDownHandler(event:MouseEvent):void
	{
		mouseIsDown = true;
	}

	private function sm_mouseUpHandler(event:MouseEvent):void
	{
		mouseIsDown = false;
	}
	
	/**
	 *  Listens for all NativeDragEvents and then redispatches them as DragEvents 
	 */
	private function nativeDragEventHandler(event:NativeDragEvent):void
	{
		var newType:String = event.type.charAt(6).toLowerCase() + event.type.substr(7);
		var dragSource:DragSource = new DragSource();
		var target:DisplayObject = event.target as DisplayObject;		
		var clipboard:Clipboard = event.clipboard;
		var origFormats:Array = clipboard.formats;
		var len:int = origFormats.length;
		var format:String;
		var data:Object;
		var me:InterManagerRequest;
		
		_allowedActions = event.allowedActions;
		
		//translate either commandKey or controlKey to old-style ctrlKey 
		var ctrlKey:Boolean = false;
		if (Capabilities.os.substring(0,3) == "Mac")
			ctrlKey = event.commandKey;
		else
			ctrlKey = event.controlKey;	
		//default to move if drag is from same app
	
                if (NativeDragManager.dragInitiator && event.type == NativeDragEvent.NATIVE_DRAG_START)
                {
                    flash.desktop.NativeDragManager.dropAction =  
                        (ctrlKey || !_allowMove) ? DragManager.COPY : DragManager.MOVE;
                }
	
		// Transfer clipboard data to dragSource	
		if (event.type != NativeDragEvent.NATIVE_DRAG_EXIT)
		{
			for (var i:int = 0; i < len; i++)
			{ 
				format = origFormats[i];
				if (clipboard.hasFormat(format))
				{
					// Create an object to store a reference to the format and clipboard.
					// This delays copying over the drag data until it is needed					
					var dataFetcher:DragDataFormatFetcher = new DragDataFormatFetcher();
					dataFetcher.clipboard = clipboard;
					dataFetcher.format = format;
						
					dragSource.addHandler(dataFetcher.getClipboardData, format);	
				}
			}
		} 
		if (event.type == NativeDragEvent.NATIVE_DRAG_DROP)
			_relatedObject = event.target as InteractiveObject;
		


		// Need a dragInitiator in NativeDragEvent
		var dragEvent:DragEvent 
			= new DragEvent(newType, false, event.cancelable, 
							NativeDragManager.dragInitiator as IUIComponent, 
							dragSource, event.dropAction, ctrlKey, 
							event.altKey, event.shiftKey);
		dragEvent.buttonDown = event.buttonDown;
		dragEvent.delta = event.delta;
		dragEvent.localX = event.localX;
		dragEvent.localY = event.localY;
		if (newType == DragEvent.DRAG_COMPLETE)
			dragEvent.relatedObject = _relatedObject;
		else
			dragEvent.relatedObject = event.relatedObject;
		// Resend the event as a DragEvent.
		_dispatchDragEvent(target, dragEvent);
			 	
		if (newType == DragEvent.DRAG_COMPLETE)
		{
		    if (sm == sandboxRoot)
		        endDrag();
		    else 
		    {
    			me = new InterManagerRequest(InterManagerRequest.DRAG_MANAGER_REQUEST);
    			me.name = "endDrag";
    			// trace("-->dispatch endDrag for DragManagerImpl", sm);
    			sandboxRoot.dispatchEvent(me);
    			// trace("<--dispatch endDrag for DragManagerImpl", sm);
    		}
		}
	}

    /**
     *  @private
     */
    private function _dispatchDragEvent(target:DisplayObject, event:DragEvent):void
    {
		// in trusted mode, the target could be in another application domain
		// in untrusted mode, the mouse events shouldn't work so we shouldn't be here

		// same domain
		if (isSameOrChildApplicationDomain(target))
			target.dispatchEvent(event);
		else
		{
			// wake up all the other DragManagers
			var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.INIT_MANAGER_REQUEST);
			me.name = "mx.managers.IDragManagerImpl";
			sandboxRoot.dispatchEvent(me);
			// bounce this message off the sandbox root and hope
			// another DragManager picks it up
			var mde:InterDragManagerEvent = new InterDragManagerEvent(InterDragManagerEvent.DISPATCH_DRAG_EVENT, false, false,
													event.localX,
													event.localY,
													event.relatedObject,
													event.ctrlKey,
													event.altKey,
													event.shiftKey,
													event.buttonDown,
													event.delta,
													target,
													event.type,
													event.dragInitiator,
													event.dragSource,
													event.action,
													event.draggedItem
													);
			sandboxRoot.dispatchEvent(mde);
		}
	}

	private function isSameOrChildApplicationDomain(target:Object):Boolean
	{
		var swfRoot:DisplayObject = SystemManager.getSWFRoot(target);
        if (swfRoot)
            return true;

        var me:InterManagerRequest = new InterManagerRequest(InterManagerRequest.SYSTEM_MANAGER_REQUEST);
        me.name = "hasSWFBridges";
        sandboxRoot.dispatchEvent(me);
        
        // if no bridges, it might be a private/internal class so return true and hope we're right
        if (!me.value) return true;

        return false;
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
			// bDoingDrag = marshalEvent.value; // not supported in AIR right now, we'd need more info
			break;
		case "acceptDragDrop":
			if (isDragging)
			{
				// trace("NativeDragMgr.acceptDragDrop targ",target);
				var dispObj:InteractiveObject = marshalEvent.value as InteractiveObject;
				if (dispObj)
					flash.desktop.NativeDragManager.acceptDragDrop(dispObj);
			}
			break;
		case "showFeedback":
			if (isDragging)	// it is our drag
			{
				// trace("--marshaled showFeedback for DragManagerImpl", sm, marshalEvent.value);
				showFeedback(marshalEvent.value);
			}
			break;
		case "getFeedback":
			if (isDragging)	// it is our drag
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
			if (isDragging)
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

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: DragDataFormatFetcher
//
////////////////////////////////////////////////////////////////////////////////

import flash.desktop.Clipboard;
import mx.core.DragSource;


/**
 *  @private
 *  Helper class used to provide a way to access the clipboard or dragSource data
 *  at a later time. 
 */
class DragDataFormatFetcher
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
	public function DragDataFormatFetcher()
	{
		super();
	}
	
	/**
     *  @private
     */
	public var clipboard:Clipboard;
	
	/**
     *  @private
     */
	public var dragSource:DragSource;
	
	/**
     *  @private
     */
	public var format:String;
	
	/**
     *  @private
     */
	public function getClipboardData():Object
	{
		if (clipboard)
			return clipboard.getData(format);
		else
			return null;
	}
	
	/**
     *  @private
     */
	public function getDragSourceData():Object
	{
		if (dragSource)
			return dragSource.dataForFormat(format);
		else
			return null;
	}
}

