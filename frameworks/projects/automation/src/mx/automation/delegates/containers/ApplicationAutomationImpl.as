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

package mx.automation.delegates.containers
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.system.ApplicationDomain;
	
	import mx.automation.Automation;
	import mx.automation.AutomationHelper;
	import mx.automation.AutomationManager;
	import mx.automation.IAutomationManager2;
	import mx.automation.IAutomationObject;
	import mx.automation.delegates.core.ContainerAutomationImpl;
	import mx.containers.ApplicationControlBar;
	import mx.core.Application;
	import mx.core.mx_internal;

	use namespace mx_internal;
	
	[Mixin]
	/**
	 * 
	 *  Defines the methods and properties required to perform instrumentation for the 
	 *  Application class. 
	 * 
	 *  @see mx.core.Application
	 *  
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class ApplicationAutomationImpl extends ContainerAutomationImpl
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
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public static function init(root:DisplayObject):void
		{
			Automation.registerDelegateClass(Application, ApplicationAutomationImpl);
		}   
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 * @param obj Application object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function ApplicationAutomationImpl(obj:Application)
		{
			super(obj);
			recordClick = true;
			var am:IAutomationManager2 = Automation.automationManager2;
			am.registerNewApplication(obj);
		}
		
		/**
		 *  @private
		 */
		protected function get application():Application
		{
			return uiComponent as Application;      
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
		private function getDockedControlBar(index:int):IAutomationObject
		{
			var dockedApplicationControlBarsFound:int = 0;
			
			// number of docked application control bars
			// get its row children and see how many docked application control 
			// bars are present
			var n:int = application.rawChildren.numChildren;
			for ( var childPos:int=0 ;childPos < n; childPos++)
			{
				var currentObject:ApplicationControlBar = 
					application.rawChildren.getChildAt(childPos) as ApplicationControlBar;
				if( currentObject)
				{
					if(currentObject.dock == true)
					{
						if(dockedApplicationControlBarsFound == index)
						{
							return currentObject as IAutomationObject;
						}
						else
						{
							dockedApplicationControlBarsFound++;
						}
					}
				}
			}
			return null;
		}
		
		/**
		 *  @private
		 */
		private function getDockedControlBarChildren():Array
		{
			var childrenList:Array = new Array();
			
			// number of docked application control bars
			// get its row children and see how many docked application control 
			// bars are present
			var n:int = application.rawChildren.numChildren;
			for (var i:int=0 ;i < n; i++)
			{
				var currentObject:ApplicationControlBar = 
					application.rawChildren.getChildAt(i) as ApplicationControlBar;
				if (currentObject)
				{
					if(currentObject.dock == true)
						childrenList.push(currentObject as IAutomationObject);
				}
			}
			return childrenList;
		}
		
		/**
		 *  @private
		 */
		//----------------------------------
		//  getDockedApplicationControlBarCount
		//----------------------------------
		/* this method is written to get the docked application control bars separately
		as they are not part of the numChildren and get childAt.
		but we need these objcts as part of them to get the event from these
		properly recorded
		*/
		private function getDockedApplicationControlBarCount():int
		{
			var dockedApplicationControlBars:int = 0;
			
			// number of docked application control bars
			// get its row children and see how many docked application control 
			// bars are present
			var n:int = application.rawChildren.numChildren;
			for (var i:int=0; i < n; i++)
			{
				var currentObject:ApplicationControlBar = 
					application.rawChildren.getChildAt(i) as ApplicationControlBar;
				if( currentObject)
				{
					if(currentObject.dock == true)
						dockedApplicationControlBars++;
				}
			}
			
			return dockedApplicationControlBars;
		}
		
		override public function get numAutomationChildren():int
		{
			
			var am:IAutomationManager2 = Automation.automationManager2;
			
			return application.numChildren + application.numRepeaters + 
				getDockedApplicationControlBarCount() +am.getPopUpChildrenCount();
		}
		
		override public function getAutomationChildren():Array
		{
			var am:IAutomationManager2 = Automation.automationManager2;
			var childList:Array = new Array();
			// get the 	 DockedApplicationBarControl details
			var tempChildren:Array  = getDockedControlBarChildren();
			if(tempChildren)
			{
				n = tempChildren.length;
				for ( i = 0; i < n ; i++)
				{
					childList.push(tempChildren[i]);
				}
			}
			
			
			n = application.numChildren;
			for (i = 0; i < n ; i++)
			{
				var obj:Object = application.getChildAt(i);
				// Here if we are getting spark scrollers, we need to add the viewport's children 
				// as the actual children instead of the scroller. Before that we need to check if
				// spark classes are present. We should not add spark dependency for this class because
				// this class is intended to be used in MX only work flows as well.
				if(AutomationHelper.isRequiredSparkClassPresent())
				{
					var sparkScroller:Class = Class(ApplicationDomain.currentDomain.getDefinition("spark.components.Scroller"));
					if(obj is sparkScroller)					
					{
						if(obj.viewport is IAutomationObject)
							childList.push(obj.viewport);
						if(obj.horizontalScrollBar)
							childList.push(obj.horizontalScrollBar);
						if(obj.verticalScrollBar)
							childList.push(obj.verticalScrollBar);
					}
					else
						childList.push(obj);
				}
				else
					childList.push(obj);
			}
			
			tempChildren  =   application.childRepeaters;
			if (tempChildren)
			{
				n = tempChildren.length;
				for (i = 0; i < n ; i++)
				{
					childList.push(tempChildren[i]);
				}
			}
			
			// we need to add popup children
			
			var tempChildren1:Array  = am.getPopUpChildren();
			var n:int = 0;
			var i:int = 0;	
			
			if(tempChildren1)
			{
				n = tempChildren1.length;
				for (i = 0; i < n ; i++)
					childList.push(tempChildren1[i]);
			}
			
			return childList;
		}
		
		override public function getAutomationChildAt(index:int):IAutomationObject
		{
			var am:IAutomationManager2 = Automation.automationManager2;
			// handle popup objects
			var popUpCount:int = am.getPopUpChildrenCount();
			if (index < popUpCount)
				return am.getPopUpChildObject(index) ;
			else
				index = index - popUpCount;
			
			// get the 	 DockedApplicationControl details
			var dockedApplicationBarNumbers:int = getDockedApplicationControlBarCount();
			if (index < dockedApplicationBarNumbers)
				return (getDockedControlBar(index) as IAutomationObject);
			else
				index = index - dockedApplicationBarNumbers ;
			
			
			if (index < application.numChildren)
			{
				var d:Object = application.getChildAt(index);
				return d as IAutomationObject;
			}   
			
			var r:Object = application.childRepeaters[index - application.numChildren];
			return r as IAutomationObject;
		}
		
	}
	
}