////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
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
	import mx.automation.IAutomationObjectHelper;
	
	import spark.components.FormItem;
	
	
	[Mixin]
	/**
	 * 
	 *  Defines the methods and properties required to perform instrumentation for the 
	 *  FormItem class. 
	 * 
	 *  @see spark.components.FormItem
	 *  
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.5
	 *  @productversion Flex 4.5
	 */
	public class SparkFormItemAutomationImpl extends SparkSkinnableContainerAutomationImpl
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
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public static function init(root:DisplayObject):void
		{
			Automation.registerDelegateClass(spark.components.FormItem, SparkFormItemAutomationImpl);
		}   
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *  @param obj FormItem object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public function SparkFormItemAutomationImpl(obj:spark.components.FormItem)
		{
			super(obj);
		}
		
		/**
		 *  @private
		 *  storage for the formItem component
		 */
		protected function get formItem():spark.components.FormItem
		{
			return uiComponent as spark.components.FormItem;
		}
		
		
		//----------------------------------
		//  automationValue
		//----------------------------------
		
		/**
		 *  @private
		 */
		override public function get automationValue():Array
		{
			var labelObj:IAutomationObject = formItem.labelDisplay as IAutomationObject;
			var label:String = formItem.label;
			
			var sequenceLabelObj:IAutomationObject = formItem.sequenceLabelDisplay as IAutomationObject;
			var seqLabel:String = formItem.sequenceLabel;
			// Add values  of sequence label and label in that order if they exist
			var result:Array = [ seqLabel ? seqLabel : null ];
			result.push(label ? label : null);
			
			var childArray:Array = getAutomationChildren();
			if (childArray)
			{
				var n:int = childArray.length;
				for (var i:int = 0; i < n; i++)
				{
					var child:IAutomationObject = childArray[i] as IAutomationObject;
					if (child == labelObj || child == sequenceLabelObj)
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
			return formItem.numChildren + (formItem.labelDisplay != null ? 1 : 0) + (formItem.sequenceLabelDisplay != null ? 1 : 0)
				+ (formItem.errorTextDisplay != null ? 1 : 0) + (formItem.helpContentGroup != null ? 1 : 0);
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
			var labelObj:IAutomationObject = formItem.labelDisplay as IAutomationObject;
			var seqLabelObj:IAutomationObject = formItem.sequenceLabelDisplay as IAutomationObject;
			var errorLabelObj:IAutomationObject = formItem.errorTextDisplay as IAutomationObject;
			var helpObj:IAutomationObject = formItem.helpContentGroup as IAutomationObject;
			
			if(index >= formItem.numChildren)
			{
				index = index - formItem.numChildren;
				
				var nonContentChildren:Array = [];
				
				if(labelObj)
					nonContentChildren.push(labelObj);
				if(seqLabelObj)
					nonContentChildren.push(seqLabelObj);
				if(errorLabelObj)
					nonContentChildren.push(errorLabelObj);
				if(helpObj)
					nonContentChildren.push(helpObj);				
				
				return nonContentChildren[index];
			}
			
			return super.getAutomationChildAt(index);
		}
		
		/**
		 * @private
		 */
		override public function getAutomationChildren():Array
		{
			var childList:Array = new Array();
			var seqLabelObj:IAutomationObject = formItem.sequenceLabelDisplay as IAutomationObject;
			var labelObj:IAutomationObject = formItem.labelDisplay as IAutomationObject;
			var errorLabelObj:IAutomationObject = formItem.errorTextDisplay as IAutomationObject;
			var helpObj:IAutomationObject = formItem.helpContentGroup as IAutomationObject;
			// we need to add all label objects and the children of the form also
			
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
			if(seqLabelObj)
				childList.push(seqLabelObj);
			if(errorLabelObj)
				childList.push(errorLabelObj);
			if(helpObj)
				childList.push(helpObj);
			
			return childList;
		}
		
		/**
		 * @private
		 */
		private function getItemAutomationName(child:IAutomationObject):String
		{
			var seqLabelObj:IAutomationObject = formItem.sequenceLabelDisplay as IAutomationObject;
			var seqLabel:String = formItem.sequenceLabel;
			
			var labelObj:IAutomationObject = formItem.labelDisplay as IAutomationObject;
			var label:String = formItem.label;
			
			var result:String = null;
			result = (seqLabel && seqLabel.length != 0) ? seqLabel + ":" : "";	//add sequence label if exists
			result = (label && label.length != 0) ? result + label + ":" : result+""; // add label if exists
			if (child.automationName && child.automationName.length != 0)
			{
				result = result + child.automationName;
			}
			else
			{
				var childArray:Array = getAutomationChildren();
				if (childArray)
				{
					var n:int = childArray.length;
					for (var i:uint = 0; !result && i < n; i++)
					{
						if (childArray[i] == child)
						{
							result = (i == 0 && 
								n == ((labelObj && seqLabelObj) ? 3 : (labelObj ? 2 : (seqLabelObj ? 2 : 1))) 	// if both seqLabelObj and labelObj exist, 3																												
								? result : result + ":" + i);													// 2 if one of them exist, 1 otherwise
						}
					}
				}
			}
			return result;
		}
	}
}