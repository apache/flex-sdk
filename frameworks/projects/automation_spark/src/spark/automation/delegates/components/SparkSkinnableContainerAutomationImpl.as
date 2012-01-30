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
	import mx.core.mx_internal;
	
	import spark.automation.delegates.components.supportClasses.SparkSkinnableContainerBaseAutomationImpl;
	import spark.automation.tabularData.SkinnableContainerTabularData;
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
	public class SparkSkinnableContainerAutomationImpl extends SparkSkinnableContainerBaseAutomationImpl
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
			Automation.registerDelegateClass(spark.components.SkinnableContainer, SparkSkinnableContainerAutomationImpl);
			
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
		public function SparkSkinnableContainerAutomationImpl(obj:spark.components.SkinnableContainer)
		{
			super(obj);
			
			obj.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler,
				false, EventPriority.DEFAULT+1, true );
			obj.addEventListener(MouseEvent.CLICK, clickHandler, false, EventPriority.DEFAULT+1, true);    
		}
		
		
		/**
		 *  @private
		 */
		private function get container():spark.components.SkinnableContainer
		{
			return uiComponent as spark.components.SkinnableContainer;
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
		
		override public function replayAutomatableEvent(event:Event):Boolean
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
		}
		
		
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
		protected function getInternalScroller():spark.components.Scroller
		{
			var chilArray:Array = new Array();
			if(container.contentGroup)
			{
				var n:int = container.contentGroup.numChildren;
				
				for (var i:int = 0; i<n ; i++)
				{
					var obj:Object = container.contentGroup.getChildAt(i);
					// here if are getting scrollers, we need to add the viewport's children as the actual children
					// instead of the scroller
					if(obj is spark.components.Scroller)
						return obj as spark.components.Scroller;
				}
			}
			return null;
		}
		
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
			var numChildren:int = container.contentGroup.numChildren;
			if(index < numChildren )
				return   container.contentGroup.getChildAt(index) as IAutomationObject;
			else
			{
				index = index - numChildren;
				var scrollBars:Array = getScrollBars(container,container.contentGroup);
				if(scrollBars && index < scrollBars.length)
					return scrollBars[index];
			}   
			
			
			return null;
		}
		
		
		/**
		 *  @private
		 */
		override public function getAutomationChildren():Array
		{
			
			var chilArray:Array = new Array();
			if(container.contentGroup)
			{
				var n:int = container.contentGroup.numChildren;
				
				for (var i:int = 0; i<n ; i++)
				{
					var obj:Object = container.contentGroup.getChildAt(i);
					// here if are getting scrollers, we need to add the viewport's children as the actual children
					// instead of the scroller
					if(obj is spark.components.Scroller)
					{
						var scroller:spark.components.Scroller = obj as spark.components.Scroller; 
						var viewPort:IViewport =  scroller.viewport;
						if(viewPort is IAutomationObject)
							chilArray.push(viewPort);
						if(scroller.horizontalScrollBar)
							chilArray.push(scroller.horizontalScrollBar);
						if(scroller.verticalScrollBar)
							chilArray.push(scroller.verticalScrollBar);
					}
					else
						chilArray.push(obj);
				}
			}
			var scrollBars:Array = getScrollBars(null,container.contentGroup);
			n = scrollBars? scrollBars.length : 0;
			
			for ( i=0; i<n ; i++)
			{
				chilArray.push(scrollBars[i]);
			}
			
			
			return chilArray;
		}
		
		
		//----------------------------------
		//  automationTabularData
		//----------------------------------
		
		/**
		 *  @private
		 */
		
		override public function get automationTabularData():Object
		{
			return new SkinnableContainerTabularData(uiAutomationObject);
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
			
			return (event.target == container.contentGroup);
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
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			
			if( event.target == getInternalScroller()||
				(event.target == getScroller(container,container.contentGroup)))
				recordAutomatableEvent(event);
		}
		
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