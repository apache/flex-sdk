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
	import flash.display.DisplayObjectContainer;
	
	import mx.automation.Automation;
	import mx.automation.IAutomationManager2;
	import mx.automation.IAutomationObject;
	import mx.core.mx_internal;
	
	import spark.components.Application;
	import spark.core.IViewport;
	
	use namespace mx_internal;
	
	[Mixin]
	/**
	 * 
	 *  Defines the methods and properties required to perform instrumentation for the 
	 *  Application class. 
	 * 
	 *  @see spark.components.Application
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public class SparkApplicationAutomationImpl extends SparkSkinnableContainerAutomationImpl
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
			Automation.registerDelegateClass(spark.components.Application, SparkApplicationAutomationImpl);
		}   
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *
		 * @param obj Application object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function SparkApplicationAutomationImpl(obj:spark.components.Application)
		{
			super(obj);
			recordClick = true; 
			var am:IAutomationManager2 = Automation.automationManager2;
			am.registerNewApplication(obj);
		}
		
		/**
		 *  @private
		 */
		override public function get automationName():String
		{
			var am:IAutomationManager2 = Automation.automationManager2;
			return am.getUniqueApplicationID();
		}
		
		/**
		 *  @private
		 */
		protected function get application():spark.components.Application
		{
			return uiComponent as spark.components.Application;      
		}
		
		/**
		 *  @private
		 */
		override protected function componentInitialized():void
		{
			super.componentInitialized();
			// Override for situations where an app is loaded into another
			// application. Find the Flex loader that contains us.
			var owner:IAutomationObject = application.owner as IAutomationObject;
			
			if ((!owner)  && application.systemManager.isTopLevel() == false)
			{
				try
				{
					var findAP:DisplayObject = application.parent;
					
					owner = findAP as IAutomationObject;
					while (findAP && !(owner))
					{
						findAP = findAP.parent;
						owner = findAP as IAutomationObject;
					}
					
					application.owner = owner as DisplayObjectContainer;
				}
				catch (e:Error)
				{
				}
			}
		}
		
		
		/**
		 *  @private
		 */
		override public function getAutomationChildren():Array
		{
			var childList:Array = new Array();
			
			var am:IAutomationManager2 = Automation.automationManager2;      
			
			// Add the children in Control Bar first 
			// For Halo application, control bar used to be an object of type
			// ApplicationControlBar which used to contain all the controls
			// that are intended to appear in control bar. It had a property to dock.
			// But in spark application, all the contents of control bar are added as
			// direct children of a group which inturn is a child of Application. 
			// Group doesn't have a property to dock. So we assume we need not handle
			// that case for spark applications. Also the controls in controlBarGroup
			// are added as direct children of application as in the case of the controls
			// in contentGroup
			var tempChildren:Array  = getControlBarChildren();
			if(tempChildren)
			{
				n = tempChildren.length;
				for ( i = 0; i < n ; i++)
				{
					childList.push(tempChildren[i] as IAutomationObject);
				}
			}
			if(application.contentGroup)
			{
				n = application.contentGroup.numChildren;
				for (i = 0; i < n ; i++)
				{
					var obj:Object = application.contentGroup.getChildAt(i);
					// here if are getting scrollers, we need to add the viewport's children as the actual children
					// instead of the scroller
					if(obj is spark.components.Scroller)
					{
						var scroller:spark.components.Scroller = obj as spark.components.Scroller; 
						var viewPort:IViewport =  scroller.viewport;
						if(viewPort is IAutomationObject)
							childList.push(viewPort);
						if(scroller.horizontalScrollBar)
							childList.push(scroller.horizontalScrollBar);
						if(scroller.verticalScrollBar)
							childList.push(scroller.verticalScrollBar);
					}
					else
						childList.push(obj as IAutomationObject);
				}
			}
			tempChildren =  application.repeaters;
			if (tempChildren)
			{
				n = tempChildren.length;
				for (i = 0; i < n ; i++)
				{
					childList.push(tempChildren[i] as IAutomationObject);
				}
			}
			
			var scrollBars:Array = getScrollBars(application, application.contentGroup);
			n = scrollBars ? scrollBars.length :0;
			
			for ( i=0; i<n ; i++)
			{
				childList.push(scrollBars[i]);
			}
			// we need to add popup children
			
			var tempChildren1:Array  = am.getPopUpChildren();
			var n:int = 0;
			var i:int = 0;  
			
			if(tempChildren1)
			{
				n = tempChildren1.length;
				for (i = 0; i < n ; i++)
					childList.push(tempChildren1[i] as IAutomationObject);
			} 
			return childList;
		}
		
		/**
		 *  @private
		 */
		private function getControlBarChildren():Array
		{
			var childrenList:Array = new Array();
			if(application.controlBarGroup != null)
			{
				var n:int = application.controlBarGroup.numChildren;
				for (var i:int = 0; i < n ; i++)
				{
					var obj:Object = application.controlBarGroup.getChildAt(i);
					childrenList.push(obj);
				}
			}
			return childrenList;
		}
		
		/**
		 *  @private
		 */
		override public function getAutomationChildAt(index:int):IAutomationObject
		{
			var controlBarChildren:Array = getControlBarChildren();
			if(index < controlBarChildren.length)
				return  controlBarChildren[index] as IAutomationObject;
			
			var numChildren:int = application.contentGroup.numChildren;
			numChildren += controlBarChildren;
			if(index < numChildren )
				return   application.contentGroup.getChildAt(index) as IAutomationObject;
			else
			{
				index = index - numChildren;
				var scrollBars:Array = getScrollBars(application,application.contentGroup);
				if(scrollBars && index < scrollBars.length)
					return scrollBars[index];
			}   
			return null;
		}
		
	}
	
}