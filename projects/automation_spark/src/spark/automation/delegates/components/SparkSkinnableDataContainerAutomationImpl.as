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

package spark.automation.delegates.components
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.automation.Automation;
	import mx.automation.IAutomationObject;
	import mx.automation.IAutomationObjectHelper;
	import mx.core.EventPriority;
	import mx.core.IVisualElement;
	import mx.core.mx_internal;
	
	import spark.automation.delegates.components.supportClasses.SparkSkinnableContainerBaseAutomationImpl;
	import spark.automation.tabularData.SkinnableContainerTabularData;
	import spark.automation.tabularData.SkinnableDataContainerTabularData;
	import spark.components.Scroller;
	import spark.components.SkinnableContainer;
	import spark.core.IViewport;
	
	use namespace mx_internal;
	
	
	
	[Mixin]
	/**
	 * 
	 *  Defines the methods and properties required to perform instrumentation for the 
	 *  SkinnableContainer class. 
	 * 
	 *  @see spark.components.SkinnableContainer
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 *  
	 */
	public class SparkSkinnableDataContainerAutomationImpl extends SparkSkinnableContainerBaseAutomationImpl
	{
		include "../../../core/Version.as";
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
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public static function init(root:DisplayObject):void
		{
			Automation.registerDelegateClass(spark.components.SkinnableDataContainer, SparkSkinnableDataContainerAutomationImpl);
			
		}   
		
		/**
		 *  Constructor.
		 * @param obj SkinnableContainer object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function SparkSkinnableDataContainerAutomationImpl(obj:spark.components.SkinnableDataContainer)
		{
			super(obj);    
		}
		
		
		/**
		 *  @private
		 */
		private function get container():spark.components.SkinnableDataContainer
		{
			return uiComponent as spark.components.SkinnableDataContainer;
		}
		
		
		
		
		//----------------------------------
		//  automationName
		//----------------------------------
		
		/**
		 *  @private
		 */
		override public function get automationName():String
		{
			return container.id || super.automationName;
		}
		
		//----------------------------------
		//  automationValue
		//----------------------------------
		
		/**
		 *  @private
		 */
		override public function get automationValue():Array
		{
			if (container.id && container.id.length != 0)
				return [ container.id ];
			
			var result:Array = [];
			var childList:Array = getAutomationChildren();
			var n:int = childList ? childList.length : 0;
			for (var i:int = 0; i < n; i++)
			{
				var child:IAutomationObject = childList[i];
				if(child != null) // we can have non automation elements like graphic elements also.
				{
					var x:Array = child.automationValue;
					if (x && x.length != 0)
						result.push(x);
				}
			}
			
			return result;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		
		/*override public function replayAutomatableEvent(event:Event):Boolean
		{
			if (event is MouseEvent && event.type == MouseEvent.MOUSE_WHEEL)
			{
				// the mouse wheel happens on the content group
				var help:IAutomationObjectHelper = Automation.automationObjectHelper;
				help.replayMouseEvent(container.contentGroup, event as MouseEvent);
				return true;
			}
			else if (event is KeyboardEvent)
			{
				// the key board events happens on the scroller.
				var scroller:spark.components.Scroller = getScroller(container,container.contentGroup);
				if(!scroller)
					scroller = getInternalScroller();
				
				if(scroller)
				{
					var helper:IAutomationObjectHelper = Automation.automationObjectHelper;
					if(helper)
						helper.replayKeyboardEvent(scroller,event as KeyboardEvent);
					
				}               
			}
			
			return super.replayAutomatableEvent(event);
		}*/
		
		
		/**
		 *  @private
		 */
		override public function createAutomationIDPart(child:IAutomationObject):Object
		{
			var help:IAutomationObjectHelper = Automation.automationObjectHelper;
			return help.helpCreateIDPart(uiAutomationObject, child);
		}
		
		/**
		 *  @private
		 */
		override public function resolveAutomationIDPart(part:Object):Array
		{
			var help:IAutomationObjectHelper = Automation.automationObjectHelper;
			return help.helpResolveIDPart(uiAutomationObject, part);
		}
		
		/**
		 *  @private
		 */
		override public function createAutomationIDPartWithRequiredProperties(child:IAutomationObject, properties:Array):Object
		{
			var help:IAutomationObjectHelper = Automation.automationObjectHelper;
			return help.helpCreateIDPartWithRequiredProperties(uiAutomationObject, child,properties);
			
		}
		
		
		
		/**
		 *  @private
		 */
		/*protected function getInternalScroller():spark.components.Scroller
		{
			var chilArray:Array = new Array();
			var n:int = container.contentGroup.numChildren;
			
			for (var i:int = 0; i<n ; i++)
			{
				var obj:Object = container.contentGroup.getChildAt(i);
				// here if are getting scrollers, we need to add the viewport's children as the actual children
				// instead of the scroller
				if(obj is spark.components.Scroller)
					return obj as spark.components.Scroller;
			}
			return null;
		}*/
		
		/**
		 *  @private
		 */
		
		override public function get numAutomationChildren():int
		{ 
			
			var objArray:Array = getAutomationChildren();
			return (objArray?objArray.length:0);
		}
		
		/**
		 *  @private
		 */
		
		override public function getAutomationChildAt(index:int):IAutomationObject
		{
			
			
			return null;
		}
		
		
		/**
		 *  @private
		 */
		override public function getAutomationChildren():Array
		{
			
			var childArray:Array = new Array();
			var i: int = 0;
			var n:int = container.dataGroup.numElements;
			for(i = 0; i < n; i++)
			{
				var obj:IVisualElement = container.dataGroup.getElementAt(i);
				if(obj is IAutomationObject)
					childArray.push(obj as IAutomationObject);
			}
			childArray = addScrollers(childArray);
			
			return childArray;
		}
		
		
		//----------------------------------
		//  automationTabularData
		//----------------------------------
		
		/**
		 *  @private
		 */
		
		override public function get automationTabularData():Object
		{
			return new SkinnableDataContainerTabularData(uiAutomationObject);
		}
		
		protected function addScrollers(chilArray:Array):Array
		{
			
			var count:int = container.numChildren;
			for (var i:int=0; i<count; i++)
			{
				var obj:Object = container.getChildAt(i);
				// here if are getting scrollers, we need to add the scrollbars. we dont need to
				// consider the view port contents as the data content is handled using the renderes.
				if(obj is spark.components.Scroller)
				{
					var scroller:spark.components.Scroller = obj as spark.components.Scroller; 
					if(scroller.horizontalScrollBar && scroller.horizontalScrollBar.visible)
						chilArray.push(scroller.horizontalScrollBar);
					if(scroller.verticalScrollBar && scroller.verticalScrollBar.visible)
						chilArray.push(scroller.verticalScrollBar);
				}
			}
			
			
			var scrollBars:Array = getScrollBars(container,null);
			var n:int = scrollBars? scrollBars.length : 0;
			
			for ( i=0; i<n ; i++)
			{
				chilArray.push(scrollBars[i]);
			}
			return chilArray;
		}
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		
		/**
		 *  @private
		 */
		
		private function mouseWheelHandler(event:MouseEvent):void
		{
			if( isEventTargetApplicabale(event)  )
				recordAutomatableEvent(event, true);
		}
		
		/**
		 *  @private
		 */
		private function isEventTargetApplicabale(event:Event):Boolean
		{
			// we decide to continue with the mouse events when they are 
			// on the same container group  
			
			//return (event.target == container.contentGroup);
			return false;
		}
		/**
		 *  @private
		 */
		protected function clickHandler(event:MouseEvent):void
		{
			if(isEventTargetApplicabale(event))
			{
				//var mouseEvent:MouseEvent = new MouseEvent(MouseEvent.CLICK);
				recordAutomatableEvent(event);
			}
		}
		
		/**
		 *  @private
		 */
		/*override protected function keyDownHandler(event:KeyboardEvent):void
		{
			
			if( event.target == getInternalScroller()||
				(event.target == getScroller(container,container.contentGroup)))
				recordAutomatableEvent(event);
		}*/
		
		/**
		 *  @private
		 */
		public function getContainerChildren():Array
		{
			var tempArray:Array = new Array();
			var n:int = container.numChildren;
			for(var i:int=0; i<n ; i++)
			{
				tempArray.push(container.getChildAt(i));
			}
			
			return tempArray;
		}
		
	}
	
}