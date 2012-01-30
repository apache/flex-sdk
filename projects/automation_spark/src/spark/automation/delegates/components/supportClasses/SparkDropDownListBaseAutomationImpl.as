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

package spark.automation.delegates.components.supportClasses
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	
	import mx.automation.Automation;
	import mx.automation.AutomationConstants;
	import mx.automation.IAutomationObject;
	import mx.automation.IAutomationObjectHelper;
	import mx.automation.events.AutomationRecordEvent;
	import mx.automation.events.ListItemSelectEvent;
	import mx.core.IUIComponent;
	import mx.core.mx_internal;
	
	import spark.automation.delegates.components.SparkListAutomationImpl;
	import spark.components.List;
	import spark.components.supportClasses.DropDownListBase;
	import spark.events.DropDownEvent;
	import spark.events.RendererExistenceEvent;
	
	use namespace mx_internal;
	
	[Mixin]
	
	/**
	 * 
	 *  Defines methods and properties required to perform instrumentation for the 
	 *  DropDownListBase control.
	 * 
	 *  @see spark.components.supportClasses.DropDownListBase 
	 *
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	
	public class SparkDropDownListBaseAutomationImpl extends SparkListAutomationImpl
	{
		include "../../../../core/Version.as";
		
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
		 *  @productversion Flex 4
		 */
		public static function init(root:DisplayObject):void
		{
			Automation.registerDelegateClass(spark.components.supportClasses.DropDownListBase, SparkDropDownListBaseAutomationImpl);
		} 
		
		/**
		 *  Constructor.
		 * @param obj DropDownListBase object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */		
		public function SparkDropDownListBaseAutomationImpl(obj:spark.components.supportClasses.DropDownListBase)
		{
			super(obj);
			
			obj.addEventListener(spark.events.DropDownEvent.CLOSE, openCloseHandler, false, 0, true);
			obj.addEventListener(spark.events.DropDownEvent.OPEN, openCloseHandler, false, 0, true);
		}
		
		/**
		 *  @private
		 *  storage for the owner component
		 */
		protected function get sparkDropDownListBase():spark.components.supportClasses.DropDownListBase
		{
			return uiComponent as spark.components.supportClasses.DropDownListBase;
			
		}	
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		// variable added to track the opening
		private var isOpen:Boolean = false;
		protected var isKeyTypeEvent:Boolean = false;
		/**
		 *  @private
		 */
		private function openCloseHandler(event:spark.events.DropDownEvent):void
		{
			if (event.type == DropDownEvent.OPEN)
			{
				isOpen = true;
				addMouseClickHandlerToExistingRenderers();
				if(sparkDropDownListBase.dataGroup)
				{
					sparkDropDownListBase.dataGroup.addEventListener(
						RendererExistenceEvent.RENDERER_ADD, dataGroup_rendererAddHandler, false, 0, true);
					sparkDropDownListBase.dataGroup.addEventListener(
						RendererExistenceEvent.RENDERER_REMOVE, dataGroup_rendererRemoveHandler, false, 0 , true);
				}
				// Record the open event only if it is not triggered by typing a character 
				// This value is set to true by ComboBox when a key that types a value 
				// (basically when non-navigational key) is pressed.
				if(!isKeyTypeEvent)
					recordAutomatableEvent(event);
				
				if(sparkDropDownListBase.dropDown)
				{
					sparkDropDownListBase.dropDown.addEventListener(AutomationRecordEvent.RECORD, 
						dropdown_recordHandler, false, 0, true);
					
					// DropDownListBase's dropDown is a pop up. So its parent is SystemManager.
					// So scrollbars are recorded as children of Group.
					// Setting its owner to DropDownListBase so that scrollbars get recorded as 
					// children of DropDownListBase.
					// Ref: http://bugs.adobe.com/jira/browse/FLEXENT-1154
					if(sparkDropDownListBase.dropDown is IUIComponent)
						(sparkDropDownListBase.dropDown as IUIComponent).owner = sparkDropDownListBase;
					
				}
				
				
				
			}
			else
			{
				// Reset the isKeyTypeEvent on closing the dropDown.
				isKeyTypeEvent = false;
				if (sparkDropDownListBase.dropDown)
					sparkDropDownListBase.dropDown.removeEventListener(AutomationRecordEvent.RECORD, dropdown_recordHandler);
			}   
		}
		
		/**
		 *  @private
		 */
		private function dropdown_recordHandler(event:AutomationRecordEvent):void
		{
			var re:Event = event.replayableEvent;
			if ((re is ListItemSelectEvent ) 
				&& event.target is List )
				recordAutomatableEvent(event.replayableEvent, event.cacheable);
		}
		
		override public function getAutomationChildren():Array
		{
			var childList:Array = new Array();
			var n:int;
			var i:int;
			if(sparkDropDownListBase.dropDown)
			{
				var scrollBars:Array = getScrollBars(sparkDropDownListBase.dropDown,null);
				n = scrollBars? scrollBars.length : 0;
				
				for (i = 0; i < n; i++)
				{ 
					childList.push(scrollBars[i]);
				}
			}
			var tempChildren:Array = super.getAutomationChildren();
			n = tempChildren ? tempChildren.length : 0;
			
			for (i = 0; i < n; i++)
			{ 
				childList.push(tempChildren[i]);
			}
			return childList;
		}

		/**
		 * @private
		 */
		
		override public function getAutomationChildAt(index:int):IAutomationObject
		{
			Automation.automationDebugTracer.traceMessage("SparkDropDownListBaseAutomationImpl", "getAutomationChildAt()", AutomationConstants.invalidMethodCall);
			var scrollBarCount:int = 0;
			if(sparkDropDownListBase.dropDown)
			{
				var scrollBars:Array = getScrollBars(sparkDropDownListBase.dropDown,null);
				scrollBarCount = scrollBars? scrollBars.length : 0;
				
				if(index < scrollBarCount)
					return scrollBars[index] as IAutomationObject;
			}
			return super.getAutomationChildAt(index + scrollBarCount) as IAutomationObject;
			
		}
		
		override public function replayAutomatableEvent(event:Event):Boolean
		{
			var completeTime:Number;
			var help:IAutomationObjectHelper = Automation.automationObjectHelper;
			
			if (event is ListItemSelectEvent)
			{
				var result:Boolean=  sparkDropDownListBase.replayAutomatableEvent(event);
				
				// selection closes the comboBox. 
				// We need to wait for the dropDown to close.
				
				if (result)
				{
					completeTime = getTimer() + sparkDropDownListBase.getStyle("closeDuration");
					
					help.addSynchronization(function():Boolean
					{
						return getTimer() >= completeTime;
					});
				}
				
				
			}
			else if (event is KeyboardEvent)
			{
				var keyEvent:KeyboardEvent = event as KeyboardEvent;
				// if comboBox is closing due to either selection or escape we need to wait
				// and sync up
				if (keyEvent.keyCode == Keyboard.ENTER || keyEvent.keyCode == Keyboard.ESCAPE)
				{
					completeTime = getTimer() + sparkDropDownListBase.getStyle("closeDuration");
					
					help.addSynchronization(function():Boolean
					{
						return getTimer() >= completeTime;
					});
				}
				return help.replayKeyboardEvent(uiComponent, KeyboardEvent(event));
			}
			else if (event is spark.events.DropDownEvent)
			{
				var cbdEvent:spark.events.DropDownEvent = spark.events.DropDownEvent(event);
				if (cbdEvent.triggerEvent is KeyboardEvent)
				{
					var kbEvent:KeyboardEvent =
						new KeyboardEvent(KeyboardEvent.KEY_DOWN);
					kbEvent.keyCode =
						(cbdEvent.type == spark.events.DropDownEvent.OPEN
							? Keyboard.DOWN
							: Keyboard.UP);
					kbEvent.ctrlKey = true;
					help.replayKeyboardEvent(uiComponent, kbEvent);
				}
				else //triggerEvent is MouseEvent
				{
					// Usually we dispatch mouseClick events. But as they are handled in a different way
					// for this component, we are dispatching a roll_over and mouse_down events
					isOpen = false;
					if(sparkDropDownListBase.dropDown && event.type == DropDownEvent.OPEN)
					{
						// Don't replay open event if combo box is already open. Otherwise it closes it.
						return true;
					}
					else
					{						
						help.replayMouseEvent(sparkDropDownListBase.openButton, new MouseEvent(MouseEvent.ROLL_OVER));
						help.replayMouseEvent(sparkDropDownListBase.openButton, new MouseEvent(MouseEvent.MOUSE_DOWN));
					}
					
				}
				
				// the open duration and closeDuration is not found as the styles on the dropDownlsit and combobox
				// hence adding the synchornisation using the isOPen variable.
				/*
				completeTime = getTimer() +
					sparkDropDownListBase.getStyle(cbdEvent.type == spark.events.DropDownEvent.OPEN ?
						"openDuration" :
						"closeDuration");
				
				help.addSynchronization(function():Boolean
				{
					return getTimer() >= completeTime;
				});
				
				*/
				help.addSynchronization(function():Boolean
				{
					return isOpen;
				});
				return true;
			}
			
			return super.replayAutomatableEvent(event);
		}
	}
}