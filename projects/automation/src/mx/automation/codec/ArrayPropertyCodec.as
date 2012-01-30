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

package mx.automation.codec
{
	
	import mx.automation.Automation;
	import mx.automation.qtp.QTPPropertyDescriptor;
	import mx.automation.qtp.IQTPPropertyDescriptor;
	import mx.automation.IAutomationManager;
	import mx.automation.IAutomationObject;
	
	/**
	 * translates between internal Flex array and automation-friendly version
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class ArrayPropertyCodec extends DefaultPropertyCodec
	{
		private var arrayTypeCodec:IAutomationPropertyCodec;
		
		/**
		 * Constructor
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */ 
		
		public function ArrayPropertyCodec(arrayTypeCodec:IAutomationPropertyCodec)
		{
			super();
			
			this.arrayTypeCodec = arrayTypeCodec;
		}
		
		private function converIntVectorToArray(vectorObj:Vector.<int> ):Array
		{
			var arrayObj:Array = new Array();
			var count:int = vectorObj.length;
			
			for (var i:int = 0; i<count; i++)
			{
				arrayObj.push(vectorObj[i]);
			}
			return arrayObj;
		}
		
		private function converObjVectorToArray(vectorObj:Vector.<Object> ):Array
		{
			var arrayObj:Array = new Array();
			var count:int = vectorObj.length;
			
			for (var i:int = 0; i<count; i++)
			{
				arrayObj.push(vectorObj[i]);
			}
			return arrayObj;
		}
		
		override public function encode(automationManager:IAutomationManager,
										obj:Object, 
										pd:IQTPPropertyDescriptor,
										relativeParent:IAutomationObject):Object
		{
			var result:Array = [];
			var value:Object = getMemberFromObject(automationManager, obj, pd);
			
			
			if (value != null && (!(value is Array)))
			{
				if(value is Vector.<int>)
					value = converIntVectorToArray(value as  Vector.<int>) ;
				else if (value is Vector.<Object>)
					value = converObjVectorToArray(value as  Vector.<Object>);
			}
		
			
			if (value != null && value is Array)
			{
				var arrayObj:Array = value as Array;
				var n:int = arrayObj.length;
				
				for (var i:int = 0; i <n ; ++i)
				{
					var arrayPropertyDescriptor:QTPPropertyDescriptor= 
						new QTPPropertyDescriptor(String(i),
							pd.forDescription,
							pd.forVerification,
							"string",
							pd.codecName);
					var arrayItem:String = String(arrayTypeCodec.encode(automationManager, 
						arrayObj,
						arrayPropertyDescriptor,
						relativeParent));
					
					arrayItem = arrayItem.replace(/;/g, "&#x3B;");
					
					result.push(arrayItem);
				}
			}
			
			
			
			//Arrays are always returned as strings
			return result.join(";");
		}
		
		override public function decode(automationManager:IAutomationManager,
										obj:Object, 
										value:Object,
										pd:IQTPPropertyDescriptor,
										relativeParent:IAutomationObject):void
		{
			if (value != null && value.length != 0)
			{
				//since we override obj when calling the sub-codec
				//make sure relativeParent is set
				var delegate:IAutomationObject = obj as IAutomationObject;
				if (relativeParent == null)
					relativeParent = delegate;
				
				var arrayObj:Array = [];
				var arrayString:Array = String(value).split(";");
				
				//note if the array members have extra spaces this code
				//won't work, we would need to trim the members, but that could
				//be a bad thing if the spaces are significant, so if we need to
				//do this, then we should also entity encode spaces (which would be ugly)
				
				var n:int = arrayString.length;
				for (var i:int = 0; i < n; ++i)
				{
					arrayString[i] = arrayString[i].replace(/&#x3B;/g, ";");
					var arrayPropertyDescriptor:QTPPropertyDescriptor= 
						new QTPPropertyDescriptor(String(i),
							pd.forDescription,
							pd.forVerification,
							"string",
							pd.codecName);
					
					arrayTypeCodec.decode(automationManager, 
						arrayString,
						arrayString[i],
						arrayPropertyDescriptor,
						relativeParent);
					
					arrayObj.push(arrayString[i]);
				}
				
				obj[pd.name] = arrayObj;
				
			}
		}
	}
	
}
