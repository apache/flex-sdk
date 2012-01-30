////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.automation.delegates 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.*;
	
	import mx.automation.Automation;
	import mx.automation.AutomationHelper;
	import mx.automation.AutomationManager;
	import mx.automation.IAutomationManager;
	import mx.automation.IAutomationObject;
	import mx.automation.IAutomationObjectHelper;
	import mx.automation.delegates.core.UIComponentAutomationImpl;
	import mx.automation.events.AutomationDragEvent;
	import mx.automation.events.AutomationDragEventWithPositionInfo;
	import mx.automation.events.MarshalledAutomationEvent;
	import mx.core.DragSource;
	import mx.core.IUIComponent;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.events.DragEvent;
	import mx.events.InterManagerRequest;
	import mx.managers.DragManager;
	import mx.managers.IMarshalSystemManager;
	import mx.managers.ISystemManager;
	import mx.managers.dragClasses.DragProxy;
	
	// for air
	
	use namespace mx_internal;
	
	[Mixin]
	/**
	 * 
	 *  Defines the methods and properties required to perform instrumentation for the 
	 *  DragManager class. 
	 * 
	 *  @see mx.managers.DragManager
	 *  
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class DragManagerAutomationImpl extends UIComponentAutomationImpl
	{
		include "../../core/Version.as";
		
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private static var currentDragProxy:DisplayObject;
		
		private static var sm:ISystemManager;
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Registers the delegate class for a component class with automation manager.
		 *  
		 *  @param root The SystemManger of the application.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public static function init(root:DisplayObject):void
		{
			sm = root as ISystemManager;
			Automation.registerDelegateClass(DragProxy, DragManagerAutomationImpl);
		}
		
		/**
		 *  Constructor.
		 *  
		 *  @param proxy DragManager object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function DragManagerAutomationImpl(proxy:UIComponent)
		{
			super(proxy);
			//if(sm.getSandboxRoot() == sm) 
			/* This check is not needed because, though we store the proxy in the root, we can trigger 
			the storage from any sub application. But while retrieving, we should ask only the root app
			to give the proxy. http://bugs.adobe.com/jira/browse/FLEXENT-1244*/
			Automation.automationManager2.storeDragProxy(proxy);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private static var dragStarted:Boolean = false;
		
		/**
		 *  @private
		 */
		private static var dragOwner:IAutomationObject;
		
		/**
		 *  @private
		 */
		public static var callBackBeforeDrop:Function;
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		public static function setForcefulDragStart():void
		{
			// this will be used by the interapplicaiton drag drop, when the events 
			// are orginated fron the non list based controls. i.e if the events are handled by
			// DRAG_DROP_PERFORM_REQUEST_TO_ROOT_APP or DRAG_DROP_PERFORM_REQUEST_TO_SUB_APP of 
			// MarshalledAutomationEvent
			dragStarted = true;
		}
		/**
		 *  @private
		 */
		public static function toMouseEvent(type:String, dragEvent:AutomationDragEvent):MouseEvent
		{
			var result:MouseEvent = new MouseEvent(type);
			result.localX = dragEvent.localX;
			result.localY = dragEvent.localY;
			result.shiftKey = dragEvent.shiftKey;
			result.ctrlKey = dragEvent.ctrlKey;
			result.altKey = dragEvent.altKey;
			return result;
		}
		
		/**
		 *  @private
		 */
		public static function getChildAutomationObject(target:IUIComponent,
														mouseEvent:MouseEvent):IAutomationObject
		{
			var delegate:IAutomationObject = (target as IAutomationObject);
			//find the child of the target that is under the point
			if (!delegate || delegate.numAutomationChildren == 0)
				return null;
			
			//find the child of the target that is under the point
			//use local because stage will be empty if no target in the event
			var eventTarget:DisplayObject = (mouseEvent.target != null 
				? DisplayObject(mouseEvent.target) 
				: DisplayObject(target));
			var ptGlobal:Point = new Point(mouseEvent.localX, mouseEvent.localY);
			ptGlobal = eventTarget.localToGlobal(ptGlobal);
			
			//var numAChildren:int = delegate.numAutomationChildren;
			var highestChild:IAutomationObject = null;
			var highestChildIndex:int = -1;
			var childAO:IAutomationObject;
			var childDO:DisplayObject;
			var x:int;
			var y:int;
			var p:Point;
			
			// code modified to avoid the usage of getAutomationChildAt in a loop.
			var childList:Array = delegate.getAutomationChildren();
			var n:int = childList ? childList.length:0;
			for (var i:int = 0; i < n; ++i)
			{
				//childAO = delegate.getAutomationChildAt(i);
				childAO = childList[i];
				if(childAO)
				{
					childDO = DisplayObject(childAO);
					if(childDO)
					{
						x = childDO.x;
						y = childDO.y;
						p = new Point(x, y);
						p = childDO.parent.localToGlobal(p);
						p.x += childDO.width;
						p.y += childDO.height;
						
						if (childDO.visible 
							&& childDO.hitTestPoint(ptGlobal.x, ptGlobal.y))
						{
							var childIndex:int = childDO.parent.getChildIndex(childDO);
							if (highestChild == null || childIndex > highestChildIndex)
							{
								highestChild = childAO;
								highestChildIndex = childIndex;
							}
						}
					}
				}
			}
			
			if (!highestChild)
			{        
				for (i = 0; i < n; ++i)
				{
					//childAO = delegate.getAutomationChildAt(i);
					childAO = childList[i];
					childDO = DisplayObject(childAO);
					
					x = childDO.x;
					y = childDO.y;
					// adjust for scrollRect
					var ui:UIComponent = childDO as UIComponent;
					if (ui && ui.$parent.scrollRect)
					{
						x -= ui.$parent.scrollRect.left;
						y -= ui.$parent.scrollRect.top;
					}
					p = new Point(x, y);
					p = childDO.parent.localToGlobal(p);
					var p1:Point = new Point(p.x, p.y);
					p.x += childDO.width;
					p.y += childDO.height;
					
					if (childDO.visible 
						&& ptGlobal.x >= p1.x
						&& ptGlobal.y >= p1.y
						&& ptGlobal.x <= p.x
						&& ptGlobal.y <= p.y) 
					{
						highestChild = childAO;
						break;
					}
				}
			}
			
			return highestChild;
		}
		/**
		 *  @private
		 */
		public function recordAutomatableDragStart(dragInitiator:IUIComponent, 
												   mouseEvent:MouseEvent):void
		{
			// we need the static method for the native drarmanagerImpl to call the recording
			// so moved the implementation to that method and calling the same from here.
			recordAutomatableDragStart1(dragInitiator,mouseEvent);
		}
		
		/**
		 *  @private
		 */
		public static function recordAutomatableDragStart1(dragInitiator:IUIComponent, 
														   mouseEvent:MouseEvent):void
		{
			var delegate:IAutomationObject = (dragInitiator as IAutomationObject);
			if (!delegate)
				return;
			
			var am:IAutomationManager = Automation.automationManager;
			if (am && am.recording)
			{
				dragOwner = delegate;
				
				if (!delegate.automationDelegate.hasOwnProperty("isDragEventPositionBased") ||
					(delegate.automationDelegate).isDragEventPositionBased() == false)
				{
					var e:AutomationDragEvent = new AutomationDragEvent(AutomationDragEvent.DRAG_START);
					e.draggedItem = 
						getChildAutomationObject(dragInitiator, mouseEvent);
					
					if (!e.draggedItem)
					{
						e.draggedItem = dragInitiator as IAutomationObject;
						dragOwner = (Automation.automationManager as IAutomationManager).getParent(delegate);
					}
					
					am.recordAutomatableEvent(dragOwner, e, false);
				}
				else
				{
					var e1:AutomationDragEventWithPositionInfo = new AutomationDragEventWithPositionInfo(AutomationDragEvent.DRAG_START);
					e1.draggedItem = 
						getChildAutomationObject(dragInitiator, mouseEvent);
					
					if (!e1.draggedItem)
					{
						e1.draggedItem = dragInitiator as IAutomationObject;
						dragOwner = (Automation.automationManager as IAutomationManager).getParent(delegate);
					}
					
					var localPoint:Point;
					localPoint= (delegate.automationDelegate).getLocalPoint(new Point(mouseEvent.localX, mouseEvent.localY),e1.draggedItem);
					e1.localX = localPoint.x;
					e1.localY = localPoint.y;
					am.recordAutomatableEvent(dragOwner, e1, false);
				}
				
				dragStarted = true;
			}
		}
		
		/**
		 *  @private
		 */
		public static function recordAutomatableDragDrop1(target1:DisplayObject, 
														  dragEvent:DragEvent):void
		{
			if (!dragStarted)
				return;
			
			var target:IUIComponent = target1 as IUIComponent;
			if (!target)
			{
				if (target1 && (!target))
				{
					// it is quite possible that the target and the dragproxy belongs to different application
					// domain. since drag drop is allowed only in the same security domain we need to make the info to 
					// all applicaitons in this domain. So let us send to the parent. and parent let it tray to handle it
					// if it cannot it will send to all its children.
					var tempArr:Array = new Array();
					tempArr.push(target1);
					tempArr.push(dragEvent);
					if (sm.getSandboxRoot() == sm)
					{
						var eventObj:MarshalledAutomationEvent = new MarshalledAutomationEvent(
							MarshalledAutomationEvent.DRAG_DROP_PERFORM_REQUEST_TO_SUB_APP);
						eventObj.interAppDataToSubApp = tempArr;
						Automation.automationManager2.dispatchToAllChildren(eventObj);
					}
					else
					{
						dispatchEventOnSandBoxRoot(MarshalledAutomationEvent.DRAG_DROP_PERFORM_REQUEST_TO_ROOT_APP,tempArr);
					}
				}
				return;
			}
			
			var delegate:IAutomationObject = (target as IAutomationObject);
			if (!delegate)
				return;
			
			var am:IAutomationManager = Automation.automationManager;
			if (am && am.recording)
			{
				if (!delegate.automationDelegate.hasOwnProperty("isDragEventPositionBased") ||
					(delegate.automationDelegate).isDragEventPositionBased() == false)
				{
					var e:AutomationDragEvent = new AutomationDragEvent(dragEvent.type);
					e.draggedItem = getChildAutomationObject(target, dragEvent);
					
					am.recordAutomatableEvent(delegate, e, false);
					dragStarted = false;
				}
				else
				{
					var e1:AutomationDragEvent = new  AutomationDragEventWithPositionInfo(dragEvent.type);
					e1.draggedItem = getChildAutomationObject(target, dragEvent);
					e1.localX = dragEvent.localX;
					e1.localY = dragEvent.localY;
					am.recordAutomatableEvent(delegate, e1, false);
					dragStarted = false;
				}
			}
		}
		
		
		/**
		 *  @private
		 */
		public  function recordAutomatableDragDrop(target1:DisplayObject, 
												   dragEvent:DragEvent):void
		{
			// we need the static method for the native drarmanagerImpl to call the recording
			// so moved the implementation to that method and calling the same from here.
			
			recordAutomatableDragDrop1(target1,dragEvent);
		}
		
		/**
		 *  @private
		 */
		public function recordAutomatableDragCancel(target:IUIComponent, 
													dragEvent:DragEvent):void
		{
			// we need the static method for the native drarmanagerImpl to call the recording
			// so moved the implementation to that method and calling the same from here.
			
			recordAutomatableDragCancel1(target,dragEvent);
		}
		
		
		public static function recordAutomatableDragCancel1(target:IUIComponent, 
															dragEvent:DragEvent):void
		{
			if (!dragStarted)
				return;
			var delegate:IAutomationObject = (target as IAutomationObject);
			if (!delegate)
				return;
			
			var am:IAutomationManager = Automation.automationManager;
			if (am && am.recording)
			{
				var e:AutomationDragEvent = new AutomationDragEvent(dragEvent.type);
				e.action = dragEvent.action;
				am.recordAutomatableEvent(dragOwner, e, false);
				dragStarted = false;
			}
		}
		
		private static function replayDragStartInFlex(realTarget:IEventDispatcher,dragEvent:AutomationDragEvent,help:IAutomationObjectHelper ):void
		{
			var mouseEvent:MouseEvent  = null;
			
			mouseEvent = toMouseEvent(MouseEvent.MOUSE_DOWN, dragEvent);
			mouseEvent.buttonDown = true;
			help.replayMouseEvent(realTarget, mouseEvent);
			
			//note the 10 pixel offset hack is some arbitrary amount to
			//make the component think the cursor has moved
			dragEvent.localX = -10;
			dragEvent.localY = -10;
			
			mouseEvent = toMouseEvent(MouseEvent.MOUSE_MOVE, dragEvent);
			mouseEvent.buttonDown = true;
			help.replayMouseEvent(realTarget, mouseEvent);
			
			mouseEvent = toMouseEvent(MouseEvent.MOUSE_OUT, dragEvent);
			mouseEvent.buttonDown = true;
			help.replayMouseEvent(realTarget, mouseEvent);
			
		}
		private static function replayDragStartInAir(target:IAutomationObject,realTarget:IEventDispatcher,
													 dragEvent:AutomationDragEvent,help:IAutomationObjectHelper ):void
		{
			// we shall do the flex way. the replayAIRDragStartEvent, which is called down will check
			// whether we have got the dragStart. If not(due to the isDragging incorrect status we wont
			// get it if the components uses the same to decide whether to start a new drag), we will create
			// the native dragstart evnet and dispatch the same.
			replayDragStartInFlex( realTarget,dragEvent,help);
			
			// register listener for the DRAG_DROP_COMPLETE_REQUEST event
			sm.getSandboxRoot().addEventListener(MarshalledAutomationEvent.DRAG_DROP_COMPLETE_REQUEST,dragDropCompletionHandler);
			// get the drag handling class for AIR
			var dragHandlerClass:Class = AutomationHelper.getAirHelperClass("mx.automation.air.AirDragManagerAutomationHandler");
			if (dragHandlerClass)
			{
				//dragHandlerClass["replayAIRDragStartEvent"](realTarget,dragEvent);
				dragHandlerClass["replayAIRDragStartEvent"](target,dragEvent,realTarget);
			}
			
		}
		
		// this method is called by the  NativeDragManagerImpl during the doDrag. This passes
		// the current drag source which will be used during the drop operations.
		public static function storeAIRDragSourceDetails(dragSource:DragSource):void
		{
			var dragHandlerClass:Class = AutomationHelper.getAirHelperClass("mx.automation.air.AirDragManagerAutomationHandler");
			if (dragHandlerClass)
			{
				dragHandlerClass["storeAIRDragSourceDetails"](dragSource);
			}
		}
		
		// return value indicates whether the coordinate can be changed.
		private static function calculateDropPosition(target:IAutomationObject,realTarget:IEventDispatcher,
													  delegate:IAutomationObject,dragEvent:AutomationDragEvent):Boolean
		{
			
			var dontChangeCoords:Boolean = false;
			
			if (!target.automationDelegate.hasOwnProperty("isDragEventPositionBased") ||
				(target.automationDelegate).isDragEventPositionBased() == false)
			{
				// if the drag event is position based, it has the coordinate 
				// information. else calculate centre of the container and reproduce
				// the mouse move event
				var maxX:int = 0;
				var maxY:int = 0;
				// code modified below to avoid the usage of numAutomationChildren and
				// getAutomationChildAt in a loop
				var childList:Array = delegate.getAutomationChildren();
				var numAChildCount:int =  childList ? childList.length :0 ;
				
				// if (realTarget is DisplayObjectContainer &&delegate.numAutomationChildren != 0)
				if (realTarget is DisplayObjectContainer && numAChildCount != 0)
				{
					// we need to find a point where we'll hit the real target and not another
					// child that is obstructing it.  this algorithm makes a lot of assumptions,
					// namely that we're dropping at the end of a contiguous region and that that's
					// the point the user chose.  we could be more rigorous and try to find the 
					// largest visible region of the container and select a coordinate there, but
					// this is gonna be imperfect either way (imagine dropping into a tic tac toe
					// board) so might as well keep it simple and assume we're dropping at the
					// end of a horizontal or vertical list.
					var aObjContainer:IAutomationObject = delegate;
					var dObjContainer:DisplayObject =
						realTarget as DisplayObjectContainer;
					//for (var i:uint = 0; i < aObjContainer.numAutomationChildren; i++)
					for (var i:uint = 0; i <numAChildCount; i++)
					{
						//var child:IAutomationObject = aObjContainer.getAutomationChildAt(i);
						var child:IAutomationObject = childList[i];
						
						if (child && (child is DisplayObject))
						{
							var dObj:DisplayObject = child as DisplayObject;
							maxX = Math.max(maxX, dObj.x + dObj.width);
							maxY = Math.max(maxY, dObj.y + dObj.height);
						}
					}
					if ((maxX > (dObjContainer.x + dObjContainer.width)) && 
						(maxY > (dObjContainer.y + dObjContainer.height)))
						throw new Error();
				}
				var container:DisplayObject = DisplayObject(realTarget);
				if ( (container.width - maxX) > 5)
					dragEvent.localX = maxX + (container.width - maxX)/3;	// Dropping on exact mid point has different behavior in Halo and Spark List controls.
																			// Halo List drops it above the item and Spark List drops it below the item.
																			// So we are ensuring that we are dropping above the midpoint. So using /3 instead of /2
				else
					dragEvent.localX = container.width - maxX/2;
				if( (container.height - maxY) > 5)
					dragEvent.localY = maxY + (container.height - maxY)/3;	// Dropping on exact mid point has different behavior in Halo and Spark List controls.
																			// Halo List drops it above the item and Spark List drops it below the item.
																			// So we are ensuring that we are dropping above the midpoint. So using /3 instead of /2
				else
					dragEvent.localY = container.height - maxY/2;
				// maybe add a test to make sure that localX and localY actually
				// do point at the realTarget and aren't being obstructed by another automation
				// object?
				
			}
			else
			{
				dontChangeCoords = true;
				// get the cooridnate based on the dragged item
				var point:Point = (target.automationDelegate).getLocalPoint(new Point(dragEvent.localX, dragEvent.localY),dragEvent.draggedItem);
				dragEvent.localX= point.x;
				dragEvent.localY=point.y;
			}
			
			return dontChangeCoords;
			
		}
		
		private static function replayDragDropInAir():void
		{
			
		}
		//--------------------------------------------------------------------------
		//
		// Replay support
		//
		//--------------------------------------------------------------------------
		/**
		 *  @private
		 */
		public static function replayAutomatableEvent(target:IAutomationObject,
													  interaction:Event):Boolean
		{
			
			if (! (interaction is AutomationDragEvent))
				return false;
			
			var mouseEvent:MouseEvent = null;   
			var dragEvent:AutomationDragEvent = AutomationDragEvent(interaction);
			
			
			var delegate:IAutomationObject = (dragEvent.draggedItem as IAutomationObject);
			if (!delegate)
				delegate = (target as IAutomationObject);
			
			
			var realTarget:IEventDispatcher = 
				IEventDispatcher(delegate);
			
			var help:IAutomationObjectHelper = Automation.automationObjectHelper;
			
			if (dragEvent.type == AutomationDragEvent.DRAG_START)
			{
				// we need a special handling here to have the synchronization working
				// the add synchornisation added in the last application will not have been
				// cleared unless there was an operation on the object in the same applicaiton
				// other than drap grop. so we need to dispatch an event on the sandboxroot so
				// that all Automation Manger calls the synchornization methods to clear the 
				// already finished requirements regarding synchronisation
				// normally there is no other operation which has a split interaction between two different
				// applications.
				dispatchEventOnSandBoxRoot(MarshalledAutomationEvent.UPDATE_SYCHRONIZATION);
				
				if (AutomationHelper.isCurrentAppAir()) 
					replayDragStartInAir(target,realTarget,dragEvent,help);
				else
					replayDragStartInFlex(realTarget,dragEvent,help);
				
				// it is possible that the drag dop or cancel is happening in another application domain
				// so we need to wait on the appropriate event and ensure that the dragging is over
				// before we replay an action on any object in this application.
				addListenerToSandBoxRootForDragCompletionInAnotherApplication();
			}
			else if (dragEvent.type == DragEvent.DRAG_DROP)
			{
				var dontChangeCoords:Boolean  = calculateDropPosition(target,realTarget,delegate,dragEvent);
				
				replayDragDrop(realTarget,target,dragEvent,dontChangeCoords);
				
			}
			else if (dragEvent.type == DragEvent.DRAG_COMPLETE)
			{
				// we need air specific handling same here
				// so delegting this to the AutomationHelper
				if (AutomationHelper.isCurrentAppAir())
				{
					// remove the  listener for the DRAG_DROP_COMPLETE_REQUEST event
					sm.getSandboxRoot().removeEventListener(MarshalledAutomationEvent.DRAG_DROP_COMPLETE_REQUEST,dragDropCompletionHandler);
					
					// get the drag handling class for AIR
					var dragHandlerClass1:Class = AutomationHelper.getAirHelperClass("mx.automation.air.AirDragManagerAutomationHandler");
					if (dragHandlerClass1)
					{
						//dragHandlerClass["replayAIRDragStartEvent"](realTarget,dragEvent);
						dragHandlerClass1["replayAIRDragCancelEvent"](target,dragEvent);
					}
					return true;
				}
				
				mouseEvent = toMouseEvent(MouseEvent.MOUSE_UP, dragEvent);
				var proxy:DragProxy = getDragManagerProxy() as DragProxy;  // DragManager.dragProxy;
				if (!proxy)
					return false;
				
				// we got a proxy , we need to let the Main applicaiton automation manager store this.
				//sendDragProxyToMainApplication(proxy);
				
				var pt:Point = 
					proxy.globalToLocal(new Point(proxy.startX, proxy.startY));
				mouseEvent.localX = pt.x;
				mouseEvent.localY = pt.y;
				
				// help.replayMouseEvent(DragManager.dragProxy, mouseEvent);
				help.replayMouseEvent(proxy, mouseEvent);
				
				help.addSynchronization(function():Boolean
				{
					return !DragManager.isDragging;
				});
				
				
			}
			return true;
		}
		
		public static function replayDragDrop(realTarget:IEventDispatcher,target:IAutomationObject,
											  dragEvent:AutomationDragEvent ,dontChangeCoords:Boolean ):Boolean
			
		{
			
			var help:IAutomationObjectHelper = Automation.automationObjectHelper;
			var mouseEvent:MouseEvent = null;    
			var flexHandlingNedded:Boolean = false;
			var fromAir:Boolean = false;
			var proxy1:DisplayObject = getDragManagerProxy(); // DragManager.dragProxy; 
			if (AutomationHelper.isCurrentAppAir() )
			{
				
				fromAir = true;
				// remove the  listener for the DRAG_DROP_COMPLETE_REQUEST event
				sm.getSandboxRoot().removeEventListener(MarshalledAutomationEvent.DRAG_DROP_COMPLETE_REQUEST,dragDropCompletionHandler);
				
				
				// we need to decide whether the drag start happened in flex or AIR.
				// if the drag start happend in flex, we need to complete in flex way only. 
				// we can find this by the availability of drag Proxy.
				if (!proxy1)
				{
					// there is no drag proxy so , the drag start happened in AIR only.
					// we need air specific handling same here
					
					if (dragEvent.draggedItem) // this is not the dragged item. it is the drop position indicator object.
					{
						// we need to calculate the point so that the objects wll get dropped appropriately.
						// the point calculated is inside point of the renderer on which the click was replayed
						// for flex. But for AIR, we need the x and y with respect to the list.
						// hence, we need to convert the current point to the point local to the list. 
						
						// we record the object before the drop.
						if (!dontChangeCoords)
						{
							var droppedObject:DisplayObject = DisplayObject(realTarget);
							dragEvent.localX = dragEvent.localX + droppedObject.x;
							dragEvent.localY = dragEvent.localY + droppedObject.y;
						}
					}
					// get the drag handling class for AIR
					var dragHandlerClass:Class = AutomationHelper.getAirHelperClass("mx.automation.air.AirDragManagerAutomationHandler");
					if(dragHandlerClass)
					{
						//dragHandlerClass["replayAIRDragStartEvent"](realTarget,dragEvent);
						dragHandlerClass["replayAIRDragDropEvent"](target,dragEvent);
					}
					
					//(target.automationDelegate as IAutomationObject2).replayAutomatableAirDragEvent(target , dragEvent);
					return true;
				}
				else
				{
					// we are currently in air. But there is drag proxy, that means the drag start has happened in flex.
					// so we need to allow the flex way of completing the operation.
					flexHandlingNedded = true;
				}
			}
			else
				flexHandlingNedded = true;
			
			if(flexHandlingNedded)
			{
				// we are in flex, but if the drag start happened in air we may not have a drag proxy, in this case, we need not handle the 
				// drag drop here. And we should  dispatch an event with all the details.
				if (!proxy1)
				{
					if (dragEvent.draggedItem) // this is not the dragged item. it is the drop position indicator object.
					{
						// we need to calculate the point so that the objects wll get dropped appropriately.
						// the point calculated is inside point of the renderer on which the click was replayed
						// for flex. But for AIR, we need the x and y with respect to the list.
						// hence, we need to convert the current point to the point local to the list. 
						
						// we record the object before the drop.
						if (!dontChangeCoords)
						{
							var droppedObject1:DisplayObject = DisplayObject(realTarget);
							dragEvent.localX = dragEvent.localX + droppedObject1.x;
							dragEvent.localY = dragEvent.localY + droppedObject1.y;
						}
					}
					// we need the event to be dispatched to parent. Reson is as follows. we are in flex
					// and as per the current situation, drag start happened in  air. the AIR can be only the root
					// application, so we need only to dispatch to the parent which will be the sandbox root.
					var tempArr:Array = new Array();
					tempArr.push(target);
					tempArr.push(dragEvent);
					dispatchEventOnSandBoxRoot(MarshalledAutomationEvent.DRAG_DROP_COMPLETE_REQUEST,tempArr);
				}
				else
				{	
					
					mouseEvent = toMouseEvent(MouseEvent.MOUSE_MOVE, dragEvent);
					mouseEvent.buttonDown = true;
					help.replayMouseEvent(realTarget, mouseEvent);
					if (callBackBeforeDrop != null)
					{
						callBackBeforeDrop();
						callBackBeforeDrop = null;
					}
					
					mouseEvent = toMouseEvent(MouseEvent.MOUSE_UP, dragEvent);
					// replay of mouse up cause the mouseUp handler on the dragProxy also
					// which will complete the current drag operation.
					
					if (proxy1)
						proxy1["action"] = dragEvent.action;
					
					// if(fromAir)
					//	proxy1["target"] = realTarget;
					//DragManager.dragProxy.action = dragEvent.action;
					help.replayMouseEvent(realTarget, mouseEvent);
					
					if (!fromAir)
					{
						help.addSynchronization(function():Boolean
						{
							return !DragManager.isDragging;
						});
					}
				}
			}
			return true;
		}
		private static function dispatchEventOnSandBoxRoot(type:String, details:Array = null, dataToMain:Boolean = true):void
		{
			//var currentSm:SystemManager = Application.application.systemManager;
			if (sm)
			{
				var rootSm:IEventDispatcher =sm.getSandboxRoot() as IEventDispatcher;
				if (rootSm )
				{
					var event:MarshalledAutomationEvent = new MarshalledAutomationEvent(type );
					if (details)
					{
						if(dataToMain == true)
							event.interAppDataToMainApp =  details;
						else
							event.interAppDataToSubApp =  details;
					}
					
					rootSm.dispatchEvent(event);
				}
			}
		}
		
		private static function dragDropCompletionHandler(event:Event):void
		{
			if (event is MarshalledAutomationEvent)
				return; // marhshalled events are expected only from another application. hence if this happens it is an echo
			
			// get the target and the dragEvent details.
			var details:Array = event["interAppDataToMainApp"] as Array;
			if (details && details.length == 2)
			{
				var targetObj:Object = details[0];
				var eventDetails:Object = details[1];
				
				
				// get the drag handling class for AIR
				var dragHandlerClass:Class = AutomationHelper.getAirHelperClass("mx.automation.air.AirDragManagerAutomationHandler");
				if (dragHandlerClass)
					dragHandlerClass["replayAIRDragDropMarshalledEvent"](targetObj,eventDetails);
				//dragHandlerClass["replayAIRDragStartEvent"](realTarget,dragEvent);
				
			}
			
		}
		
		
		/*
		private static function sendDragProxyToMainApplication(currentProxy:DragProxy):void
		{
		var details:Array = new Array();
		details.push(currentProxy);
		dispatchEventOnSandBoxRoot(MarshalledAutomationEvent.DRAG_DROP_PROXY_STORE_REQUEST , details);
		}
		*/ 
		
		private static var _inDragProxyRequestProcessing:Boolean = false;
		public static function getDragManagerProxy():DisplayObject
		{
			// here we are not calling the dispatchEventOnSandBoxRoot, as we need to add listener also
			// to the same.
			if (!DragManager.dragProxy)
			{
				//var currentSm:SystemManager = Application.application.systemManager;
				if (sm)
				{
					var rootSm:IEventDispatcher =sm.getSandboxRoot() as IEventDispatcher;
					if (rootSm )
					{
						rootSm.addEventListener(MarshalledAutomationEvent.DRAG_DROP_PROXY_RETRIEVE_REPLY, proxyRetrieveReplyHandler);
						
						var dragProxyRetrievalRequestMarshalEvent:MarshalledAutomationEvent
						= new MarshalledAutomationEvent(MarshalledAutomationEvent.DRAG_DROP_PROXY_RETRIEVE_REQUEST);
						_inDragProxyRequestProcessing = true;		
						rootSm.dispatchEvent(dragProxyRetrievalRequestMarshalEvent);
					}
				}
				return currentDragProxy;
			}
			return DragManager.dragProxy
			
		} 
		
		private static function proxyRetrieveReplyHandler(event:Event):void
		{
			if (!_inDragProxyRequestProcessing)
				return;
			
			_inDragProxyRequestProcessing = false;
			
			currentDragProxy = event["interAppDataToSubApp"][0] as DisplayObject;
			//var currentSm:SystemManager = Application.application.systemManager;
			if (sm)
			{
				var rootSm:IEventDispatcher =sm.getSandboxRoot() as IEventDispatcher;
				if (sm )
					sm.removeEventListener(MarshalledAutomationEvent.DRAG_DROP_PROXY_RETRIEVE_REPLY,proxyRetrieveReplyHandler);
			}
		}
		private static function addListenerToSandBoxRootForDragCompletionInAnotherApplication():void
		{
			//var currentSm:SystemManager = Application.application.systemManager;
			if (sm)
			{
				var rootSm:IEventDispatcher =sm.getSandboxRoot() as IEventDispatcher;
				if (sm )
					sm.addEventListener(InterManagerRequest.DRAG_MANAGER_REQUEST,dragManagerRequestHandler);
			}
		}
		
		private static function dragManagerRequestHandler(event:Event):void
		{
			if (event is InterManagerRequest)
				return;
			
			if (AutomationHelper.isCurrentAppAir() == false) 
			{
				// in AIR during replay we dont get the isDragging status properly.
				// hence this check should not be added.
				// infact this check is not  needed at all for air as 
				// we are directly dispatching event and before we come out of the loop
				// we will have the process completed.
				if (event["name"] == "acceptDragDrop")
				{
					var help:IAutomationObjectHelper = Automation.automationObjectHelper;
					help.addSynchronization(function():Boolean
					{
						return !DragManager.isDragging;
					});
				}
			}
		}
		
	}
	
}
