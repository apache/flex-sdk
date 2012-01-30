
package mx.automation.codec
{
	
	import mx.automation.qtp.IQTPPropertyDescriptor; 
	import mx.automation.IAutomationManager;
	import mx.automation.IAutomationObject;
	
	/**
	 * Translates between internal Flex keyModifiers and automation-friendly ones.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class KeyModifierPropertyCodec extends DefaultPropertyCodec
	{
		/**
		 *  Constructor
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */ 
		public function KeyModifierPropertyCodec()
		{
			super();
		}
		
		/**
		 *  @private
		 */ 
		override public function encode(automationManager:IAutomationManager,
										obj:Object, 
										pd:IQTPPropertyDescriptor,
										relativeParent:IAutomationObject):Object
		{
			var val:int = 0;
			
			if ("ctrlKey" in obj && Boolean(obj["ctrlKey"]))
				val |= (1 << 0);
			
			if ("shiftKey" in obj && Boolean(obj["shiftKey"]))
				val |= (1 << 1);
			
			if ("altKey" in obj && Boolean(obj["altKey"]))
				val |= (1 << 2);
			
			return val;
		}
		
		/**
		 *  @private
		 */ 
		override public function decode(automationManager:IAutomationManager,
										obj:Object, 
										value:Object,
										pd:IQTPPropertyDescriptor,
										relativeParent:IAutomationObject):void
		{
			if ("ctrlKey" in obj)
				obj["ctrlKey"] = (uint(value) & (1 << 0)) != 0;
			
			if ("shiftKey" in obj)
				obj["shiftKey"] = (uint(value) & (1 << 1)) != 0;
			
			if ("altKey" in obj)
				obj["altKey"] = (uint(value) & (1 << 2)) != 0;
		}
	}
	
}
