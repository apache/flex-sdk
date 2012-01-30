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
	
	import mx.automation.Automation;
	import mx.automation.AutomationIDPart;
	import mx.automation.IAutomationObject;
	import mx.automation.IAutomationObjectHelper;
	import mx.automation.delegates.core.ContainerAutomationImpl;
	import mx.containers.FormItem;
	import mx.core.mx_internal;
	
	use namespace mx_internal;
	
	[Mixin]
	/**
	 * 
	 *  Defines the methods and properties required to perform instrumentation for the 
	 *  FormItem class. 
	 * 
	 *  @see mx.containers.FormItem
	 *  
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class FormItemAutomationImpl extends ContainerAutomationImpl 
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
			Automation.registerDelegateClass(FormItem, FormItemAutomationImpl);
		}   
		
		/**
		 *  @private
		 *  storage for the owner component
		 */
		protected function get formItem():FormItem
		{
			return uiComponent as FormItem;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *  
		 *  @param obj The FormItem object to be automated.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function FormItemAutomationImpl(obj:FormItem)
		{
			super(obj);
			
		}
		
		
		//----------------------------------
		//  automationValue
		//----------------------------------
		
		/**
		 *  @private
		 */
		override public function get automationValue():Array
		{
			var label:IAutomationObject = formItem.itemLabel as IAutomationObject;
			var result:Array = [ label ? label.automationName : null ];
			/*
			for (var i:int = 0; i < numAutomationChildren; i++)
			{
			var child:IAutomationObject = getAutomationChildAt(i);
			if (child == label)
			continue;
			var x:Array = child.automationValue;
			if (x && x.length != 0)
			result.push(x);
			}*/
			// changing the above code to avoid the usage of getAutomationChildAt.
			var childArray:Array = getAutomationChildren();
			if (childArray)
			{
				var n:int = childArray.length;
				for (var i:int = 0; i < n; i++)
				{
					var child:IAutomationObject = childArray[i] as IAutomationObject;
					if (child == label)
						continue;
					var x:Array = child.automationValue;
					if (x && x.length != 0)
						result.push(x);
				}
			}
			return result;
		}
		
		//----------------------------------
		//  numAutomationChildren
		//----------------------------------
		
		/**
		 *  @private
		 */
		override public function get numAutomationChildren():int
		{
			return formItem.numChildren + (formItem.itemLabel != null ? 1 : 0);
		}
		
		/**
		 *  @private
		 */
		override public function createAutomationIDPart(child:IAutomationObject):Object
		{ 
			var help:IAutomationObjectHelper = Automation.automationObjectHelper;
			return help.helpCreateIDPart(uiAutomationObject, child, getItemAutomationName);
		}
		
		override public function createAutomationIDPartWithRequiredProperties(child:IAutomationObject, properties:Array):Object
		{
			var help:IAutomationObjectHelper = Automation.automationObjectHelper;
			return help.helpCreateIDPartWithRequiredProperties(uiAutomationObject, child,properties, getItemAutomationName);
		}
		
		/**
		 *  @private
		 */
		override public function getAutomationChildAt(index:int):IAutomationObject
		{
			var labelObj:IAutomationObject = formItem.itemLabel as IAutomationObject;
			return (index == formItem.numChildren && labelObj != null 
				? (labelObj)
				: super.getAutomationChildAt(index));
		}
		
		/**
		 * @private
		 */
		override public function getAutomationChildren():Array
		{
			var childList:Array = new Array();
			var labelObj:IAutomationObject = formItem.itemLabel as IAutomationObject;
			// we need to add the label object and the children of the form also
			
			var tempArray1:Array = super.getAutomationChildren();
			if(tempArray1)
			{
				var n:int = tempArray1.length;
				for (var i:int = 0; i < n ; i++)
				{
					childList.push(tempArray1[i]);
				}
			}
			
			if(labelObj)
				childList.push(labelObj);
			
			return childList;
		}
		/**
		 * @private
		 */
		private function getItemAutomationName(child:IAutomationObject):String
		{
			var labelObj:IAutomationObject = formItem.itemLabel as IAutomationObject;
			var label:String = labelObj ? labelObj.automationName : "";
			var result:String = null;
			if (child.automationName && child.automationName.length != 0)
				result = (((label)&&(label.length != 0))
					? label + ":" + child.automationName 
					: child.automationName);
			else
			{
				/*
				for (var i:uint = 0; !result && i < numAutomationChildren; i++)
				{
				if (getAutomationChildAt(i) == child)
				{
				result = (i == 0 && 
				numAutomationChildren == (labelObj ? 2 : 1)
				? label
				: label + ":" + i);
				}
				}
				*/
				// changing the above code to avoid the usage of getAutomationChildAt.
				var childArray:Array = getAutomationChildren();
				if (childArray)
				{
					var n:int = childArray.length;
					for (var i:uint = 0; !result && i < n; i++)
					{
						if (childArray[i] == child)
						{
							result = (i == 0 && 
								n == (labelObj ? 2 : 1)
								? label
								: label + ":" + i);
						}
					}
				}
			}
			return result;
		}
		
		
		
	}
}
