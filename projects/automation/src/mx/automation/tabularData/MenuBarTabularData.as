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
package mx.automation.tabularData
{
	
	import mx.automation.AutomationManager;
	import mx.automation.IAutomationObject;
	import mx.automation.IAutomationTabularData;
	import mx.controls.MenuBar;
	import mx.core.mx_internal;
	import mx.automation.Automation;
	
	use namespace mx_internal;
	
	/**
	 *  @private
	 */
	public class MenuBarTabularData
		implements IAutomationTabularData
	{
		
		private var menuBar:MenuBar;
		private var delegate:IAutomationObject;
		
		/**
		 *  @private
		 */
		public function MenuBarTabularData(delegate:IAutomationObject)
		{
			super();
			
			this.delegate = delegate;
			this.menuBar = delegate as MenuBar;
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get firstVisibleRow():int
		{
			return 0;
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get lastVisibleRow():int
		{
			return delegate.numAutomationChildren-1;
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get numRows():int
		{
			return delegate.numAutomationChildren;
		}
		
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get numColumns():int
		{
			return 1;
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get columnNames():Array
		{
			return ["MenuItems"];
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function getValues(start:uint = 0, end:uint = 0):Array
		{
			var _values:Array = [];
			var i:int;
			
			// code modified to avoid the usage of numAutomationChildren and 
			// getAutomationChildAt in a loop
			var childList:Array  = delegate.getAutomationChildren();
			if (childList)
			{
				end  = end > childList.length ? childList.length : end;
				
				for (i = start; i <= end; ++i)
				{
					//var values:Array = delegate.getAutomationChildAt(i).automationValue;
					var values:Array = childList[i]?childList[i].automationValue:null;
					if (values)
						_values.push([ values.join("|") ]);
				}
				
			}
			return _values;
		}
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function getAutomationValueForData(data:Object):Array
		{
			return [];
		}
	}
}
