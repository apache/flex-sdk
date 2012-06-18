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

package spark.automation.codec
{
	
	import mx.automation.AutomationError;
	import mx.automation.IAutomationManager;
	import mx.automation.IAutomationObject;
	import mx.automation.IAutomationTabularData;
	import mx.automation.codec.DefaultPropertyCodec;
	import mx.automation.tool.IToolPropertyDescriptor;
	import mx.core.mx_internal;
	
	import spark.components.DropDownList;
	import spark.components.supportClasses.DropDownListBase;
	import spark.utils.LabelUtil;
	
	use namespace mx_internal;
	
	[ResourceBundle("automation_agent")]
	
	/**
	 * Translates between internal Flex List item and automation-friendly version
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	public class SparkDropDownListBaseSelectedItemCodec extends DefaultPropertyCodec
	{
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		public function SparkDropDownListBaseSelectedItemCodec()
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
			// get the selected item
			var val:Object = getMemberFromObject(automationManager, obj, propertyDescriptor);
			
			// we need the dropDownListBase
			var ddlst:spark.components.supportClasses.DropDownListBase = obj as spark.components.supportClasses.DropDownListBase;
			if(val && ddlst)
				val = LabelUtil.itemToLabel(val, ddlst.labelField, ddlst.labelFunction);
			
			//Returning null corrupts memory sometimes
			// Ref: http://bugs.adobe.com/jira/browse/FLEXENT-1155
			if(!val)
				val = "";
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
			// we expect this codec to be used for getting the property details.
			// hence decoding is not expected to be used and not supported.
			var message:String = resourceManager.getString(
				"automation_agent", "notSupported");
			throw new AutomationError(message, AutomationError.ILLEGAL_OPERATION);
		}
	}
	
}
