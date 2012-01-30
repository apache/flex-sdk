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
	
	import flash.display.DisplayObject;
	
	import mx.automation.IAutomationObject;
	import mx.automation.IAutomationTabularData;
	import mx.automation.AutomationManager;
	import mx.core.mx_internal;
	import mx.core.Repeater;
	import mx.automation.Automation;
	
	use namespace mx_internal;
	
	/**
	 * @private
	 */
	public class ContainerTabularData
		implements IAutomationTabularData
	{
		/**
		 *  Constructor
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function ContainerTabularData(container:IAutomationObject)
		{
			super();
			
			this.containerDelegate = container;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private var containerDelegate:IAutomationObject;
		
		/**
		 *  @private
		 */
		private var _values:Array;
		
		/**
		 *  @private
		 */
		private var oldStart:uint;
		
		/**
		 *  @private
		 */
		private var oldEnd:int;
		
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		public function get firstVisibleRow():int
		{
			return 0;
		}
		
		/**
		 *  @private
		 */
		public function get lastVisibleRow():int
		{
			return Math.max(numRows - 1, 0);
		}
		
		/**
		 *  @private
		 */
		public function get numRows():int
		{
			var visibleChildren:int = 0; 
			// code modified to avoid the usage of numAutomationChildren and 
			// getAutomationChildAt in a loop
			var childList:Array  = containerDelegate.getAutomationChildren();
			
			var n:int = childList?childList.length:0;
			//for (var i:int = 0; i < containerDelegate.numAutomationChildren; ++i)
			for (var i:int = 0; i < n; ++i)
			{
				//var ao:IAutomationObject = containerDelegate.getAutomationChildAt(i);
				var ao:IAutomationObject = childList[i] as IAutomationObject;
				if (ao)
				{
					var disp:DisplayObject = ao as DisplayObject;
					if (disp.visible && !(disp is Repeater))
						++visibleChildren;
				}
			}
			return visibleChildren;
		}
		
		/**
		 *  @private
		 */
		public function get numColumns():int
		{
			var a:Array = _values || getValues(0, numRows);
			return a && a.length > 0 ? a[0].length : 0;
		}
		
		/**
		 *  @private
		 */
		public function get columnNames():Array
		{
			var result:Array = new Array(numColumns);
			var n:int = result.length;
			for (var i:int = 0; i < n; i++)
			{
				result[i] = "";
			}
			return result;
		}
		
		/**
		 *  @private
		 */
		public function getValues(start:uint = 0, end:uint = 0):Array
		{
			if (_values && oldStart == start && oldEnd == end)
				return _values;
			
			var longestRow:int = 1;
			_values = [ ];
			var k:int = 0; 
			// code modified to avoid the usage of numAutomationChildren and 
			// getAutomationChildAt in a loop
			var childList:Array  = containerDelegate.getAutomationChildren();
			
			var n:int = childList? childList.length:0;
			// for (var i:int = 0; 
			//      	i < containerDelegate.numAutomationChildren && k <= end; ++i)
			for (var i:int = 0; i < n && k <= end; i++)
			{
				//var ao:IAutomationObject = containerDelegate.getAutomationChildAt(i);
				var ao:IAutomationObject = childList[i];
				if (ao)
				{
					var disp:DisplayObject = ao  as DisplayObject;
					if (disp.visible && !(disp is Repeater))
					{
						if (k >=start && k <= end)
						{
							var av:Array = flattenArray(ao.automationValue);
							_values.push(av);
							longestRow = Math.max(longestRow, av.length);
						}
						++k;
					}
				}
			}
			
			n = _values.length;
			// normalize the grid so all rows have the same number of columns
			for (i = 0; i < n; i++)
			{
				for (var j:int = _values[i].length; j < longestRow; j++)
				{
					_values[i].push("");
				}
			}
			oldStart = start;
			oldEnd = end;
			return _values;
		}
		
		/**
		 *  @private
		 */
		private static function flattenArray(a:Array):Array
		{
			if (!a)
				return [];
			var n:int =  a.length;
			for (var i:int = 0; i < n; ++i)
			{
				if (a[i] is Array)
				{
					var tmp:Array = [];
					
					if (i > 0)
						tmp = a.slice(0, i);
					
					tmp = tmp.concat(a[i]);
					
					if (i < a.length - 1)
						tmp = tmp.concat(a.slice(i + 1));
					
					a = tmp;
					i = -1;
				}
			}
			return a;
		}
		
		/**
		 *  @private
		 */
		public function getAutomationValueForData(data:Object):Array
		{
			return [];
		}
	}
}
