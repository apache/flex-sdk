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

package mx.automation.codec
{ 
	
	import mx.automation.AutomationError;
	import mx.automation.tool.IToolPropertyDescriptor;
	import mx.automation.IAutomationManager;
	import mx.automation.IAutomationObject;
	import mx.automation.IAutomationTabularData;
	import mx.core.mx_internal;
	import mx.controls.AdvancedDataGrid;
	import mx.automation.delegates.advancedDataGrid.AdvancedDataGridAutomationImpl;
	
	use namespace mx_internal;
	
	[ResourceBundle("automation_agent")]
	
	/**
	 * Translates between internal Flex List item and automation-friendly version
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class AdvancedDataGridSelectedCellCodec extends DefaultPropertyCodec
	{
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		public function AdvancedDataGridSelectedCellCodec()
		{
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */ 
		override public function encode(automationManager:IAutomationManager,
										obj:Object,  
										propertyDescriptor:IToolPropertyDescriptor,
										relativeParent:IAutomationObject):Object
		{
			var val:Object = getMemberFromObject(automationManager, obj, propertyDescriptor);
			
			if (val != null)
			{ 
				//val = relativeParent.automationTabularData.getAutomationValueForFiedData(val).join(" | ");
				var adg:AdvancedDataGrid = relativeParent as AdvancedDataGrid;
				var objdel:AdvancedDataGridAutomationImpl = (adg.automationDelegate) as AdvancedDataGridAutomationImpl;
				var ret:Array = [];
				
				if((val.columnIndex == -1)&& (val.rowIndex != -1))
					return objdel.getRowData(val.rowIndex,true);
				
				if((val.rowIndex != -1) &&(val.columnIndex != -1))
					ret.push(objdel.getCellData(val.rowIndex,val.columnIndex,true)); 
				
				val= ret;
				
			}
			
			return val;
		}
		
		/**
		 *  @private
		 */ 
		override public function decode(automationManager:IAutomationManager,
										obj:Object, 
										value:Object,
										propertyDescriptor:IToolPropertyDescriptor,
										relativeParent:IAutomationObject):void
		{
			var message:String = resourceManager.getString(
				"automation_agent", "notSupported");
			throw new AutomationError(message, AutomationError.ILLEGAL_OPERATION);
		}
	}
	
}
