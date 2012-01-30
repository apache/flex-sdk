////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

package spark.automation.tabularData
{ 
	
	import flash.display.DisplayObject;
	
	import mx.automation.IAutomationObject;
	import mx.automation.IAutomationTabularData;
	import mx.automation.AutomationManager;
	import mx.core.mx_internal;
	import mx.core.Repeater;
	import mx.automation.Automation;
	import spark.components.RichEditableText;
	
	use namespace mx_internal;
	
	/**
	 * @private
	 */
	public class RichEditableTextTabularData
		implements IAutomationTabularData
	{
		include "../../core/Version.as";
		
		/**
		 * Constructor. This class is modelled to get the text data of the
		 * rich editable text object and show them as separate rows. 
		 * QTP does not shows the text data of these objects, as these
		 * strings can have multiple lines 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		public function RichEditableTextTabularData(richEditableText:RichEditableText)
		{
			super();
			
			this.richEditatbleText = richEditableText;
			this.currentContent = this.richEditatbleText.text.split("\n");
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private var richEditatbleText:RichEditableText;
		
		private var currentContent:Array ;
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
			return currentContent?currentContent.length-1:0;
		}
		
		/**
		 *  @private
		 */
		public function get numRows():int
		{
			
			return currentContent?currentContent.length:0;
		}
		
		/**
		 *  @private
		 */
		public function get numColumns():int
		{
			// currently we are not considering number of columns. When we work on it
			// we need to calculate this properly.
			return 1;
		}
		
		/**
		 *  @private
		 */
		public function get columnNames():Array
		{
			return [ "" ];
		}
		
		/**
		 *  @private
		 */
		public function getValues(start:uint = 0, end:uint = 0):Array
		{
			if (_values && oldStart == start && oldEnd == end)
				return _values;
			
			
			_values = [ ];
			
			var n:int = currentContent.length;
			
			// normalize the grid so all rows have the same number of columns
			for (var i:int = start ; (i < end-start+1 && i < n); i++)
			{
				_values.push([currentContent[i]]);
			}
			oldStart = start;
			oldEnd = end;
			return _values;
		}
		
		
		/**
		 *  @private
		 */
		public function getAutomationValueForData(data:Object):Array
		{
			return [""];
		}
	}
}
