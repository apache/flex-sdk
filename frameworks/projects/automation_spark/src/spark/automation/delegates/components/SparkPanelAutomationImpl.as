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
	
	import mx.automation.Automation;
	import mx.automation.IAutomationObject;
	import mx.core.mx_internal;
	
	import spark.components.Panel;
	import spark.core.IViewport;
	
	use namespace mx_internal;
	
	
	
	[Mixin]
	/**
	 * 
	 *  Defines the methods and properties required to perform instrumentation for the 
	 *  Panel class. 
	 * 
	 *  @see spark.components.Panel
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 *  
	 */
	public class SparkPanelAutomationImpl extends SparkSkinnableContainerAutomationImpl
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
			Automation.registerDelegateClass(spark.components.Panel, SparkPanelAutomationImpl);
		}   
		
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 * @param obj Panel object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function SparkPanelAutomationImpl(obj:spark.components.Panel)
		{
			super(obj);
			recordClick = true;
		}
		
		
		/**
		 *  @private
		 *  storage for the owner component
		 */
		protected function get sparkPanel():spark.components.Panel
		{
			return uiComponent as spark.components.Panel;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  automationName
		//----------------------------------
		
		/**
		 *  @private
		 */
		override public function get automationName():String
		{
			return sparkPanel.title || super.automationName;
		}
		
		/**
		 *  @private
		 */
		override public function get automationValue():Array
		{
			return [ sparkPanel.title ];
		}
		
		/**
		 *  @private
		 */     
		override public function getAutomationChildAt(index:int):IAutomationObject
		{
			
			var controlBarChildren:Array = getControlBarChildren();
			if(index < controlBarChildren.length)
				return  controlBarChildren[index] as IAutomationObject;
			var numChildren:int = sparkPanel.contentGroup.numChildren;
			numChildren += controlBarChildren;
			if(index < numChildren )
				return   sparkPanel.contentGroup.getChildAt(index) as IAutomationObject;
			else
			{
				index = index - numChildren;
				var scrollBars:Array = getScrollBars(sparkPanel,sparkPanel.contentGroup);
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
			
			var childArray:Array = new Array();
			var n:int;
			var i:int;
			
			//Add the children in the Control Bar first
			var tempChildren:Array  = getControlBarChildren();
			if(tempChildren)
			{
				n = tempChildren.length;
				for ( i = 0; i < n ; i++)
				{
					childArray.push(tempChildren[i] as IAutomationObject);
				}
			}
			if(sparkPanel.contentGroup)
			{
				n = sparkPanel.contentGroup.numChildren;
				
				for (i = 0; i<n ; i++)
				{
					var obj:Object = sparkPanel.contentGroup.getChildAt(i);
					// here if are getting scrollers, we need to add the viewport's children as the actual children
					// instead of the scroller
					if(obj is spark.components.Scroller)
					{
						var scroller:spark.components.Scroller = obj as spark.components.Scroller; 
						var viewPort:IViewport =  scroller.viewport;
						if(viewPort is IAutomationObject)
							childArray.push(viewPort);
						if(scroller.horizontalScrollBar)
							childArray.push(scroller.horizontalScrollBar);
						if(scroller.verticalScrollBar)
							childArray.push(scroller.verticalScrollBar);
					}
					else
						childArray.push(obj as IAutomationObject);
				}
			}
			var scrollBars:Array = getScrollBars(null,sparkPanel.contentGroup);
			n = scrollBars? scrollBars.length : 0;
			
			for ( i=0; i<n ; i++)
			{
				childArray.push(scrollBars[i] as IAutomationObject);
			}
			
			
			return childArray;
		}
		
		/**
		 *  @private
		 */
		private function getControlBarChildren():Array
		{
			var childrenList:Array = new Array();
			if(sparkPanel.controlBarGroup != null)
			{
				var n:int = sparkPanel.controlBarGroup.numChildren;
				for (var i:int = 0; i < n ; i++)
				{
					var obj:Object = sparkPanel.controlBarGroup.getChildAt(i);
					childrenList.push(obj);
				}   
			}
			return childrenList;
		}
	}
	
}