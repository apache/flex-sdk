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

package mx.automation.delegates.core
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	
	import mx.automation.Automation;
	import mx.automation.AutomationConstants;
	import mx.automation.IAutomationObject;
	import mx.core.UIFTETextField;
	
	[Mixin]
	/**
	 * 
	 *  Defines the methods and properties required to perform instrumentation for the 
	 *  UIFTETextField class. 
	 * 
	 *  @ see mx.core.UIFTETextField
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	
	public class UIFTETextFieldAutomationImpl implements IAutomationObject
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
		 *  @productversion Flex 4
		 */
		public static function init(root:DisplayObject):void
		{
			Automation.registerDelegateClass(UIFTETextField, UIFTETextFieldAutomationImpl);
		}   
		
		/**
		 * Constructor.
		 * @param obj UIFTETextField object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */ 
		public function UIFTETextFieldAutomationImpl(obj:UIFTETextField)
		{
			super();
			uiFTETextField = obj;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */ 
		protected var uiFTETextField:UIFTETextField;
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		public function get automationDelegate():Object
		{
			Automation.automationDebugTracer.traceMessage("UIFTETextFieldAutomationImpl", "get automationDelegate()", AutomationConstants.invalidDelegateMethodCall);
			return this;
		}
		
		public function set automationDelegate(delegate:Object):void
		{
			Automation.automationDebugTracer.traceMessage("UIFTETextFieldAutomationImpl", "set automationDelegate()", AutomationConstants.invalidDelegateMethodCall);
		}
		
		public function get automationName():String
		{
			return uiFTETextField.text;
		}
		
		public function set automationName(name:String):void
		{
			if( uiFTETextField is IAutomationObject)
			{
				var tempObj:IAutomationObject = IAutomationObject(uiFTETextField);
				if(tempObj != null)
				{
					tempObj.automationName = name;
				}
			}
		}
		
		public function get automationValue():Array
		{
			return [ automationName ];
		}
		
		public function get automationOwner():DisplayObjectContainer
		{
			Automation.automationDebugTracer.traceMessage("UIFTETextFieldAutomationImpl", "get automationOwner()", AutomationConstants.invalidDelegateMethodCall);
			
			if(uiFTETextField)
				return uiFTETextField.owner;
			
			return null;
		}
		
		public function get automationParent():DisplayObjectContainer
		{
			Automation.automationDebugTracer.traceMessage("UIFTETextFieldAutomationImpl", "get automationParent()", AutomationConstants.invalidDelegateMethodCall);
			
			if(uiFTETextField)
				return uiFTETextField.parent;
			
			return null;
		}
		
		//---------------------------------
		//  automationEnabled
		//---------------------------------
		public function get automationEnabled():Boolean
		{
			Automation.automationDebugTracer.traceMessage("UIFTETextFieldAutomationImpl", "get automationEnabled()", AutomationConstants.invalidDelegateMethodCall);
			if(uiFTETextField)
				return uiFTETextField.enabled;
			
			return false;
		}
		
		public function get automationVisible():Boolean
		{
			Automation.automationDebugTracer.traceMessage("UIFTETextFieldAutomationImpl", "get automationVisible()", AutomationConstants.invalidDelegateMethodCall);
			if(uiFTETextField)
				return uiFTETextField.visible;
			
			return false;
		}
		
		public function createAutomationIDPart(child:IAutomationObject):Object
		{
			return null;
		}
		
		public function createAutomationIDPartWithRequiredProperties(child:IAutomationObject, properties:Array):Object
		{
			return null;
		}
		
		public function resolveAutomationIDPart(criteria:Object):Array
		{
			return [];
		}
		
		public function getAutomationChildren():Array
		{
			return null;
		}
		
		public function getAutomationChildAt(index:int):IAutomationObject
		{
			return null;
		}
		
		public function get numAutomationChildren():int
		{
			return 0;
		}
		
		public function get showInAutomationHierarchy():Boolean
		{
			Automation.automationDebugTracer.traceMessage("UIFTETextFieldAutomationImpl", "get showInAutomationHierarchy()", AutomationConstants.invalidDelegateMethodCall);
			return uiFTETextField.showInAutomationHierarchy;
		}
		
		public function set showInAutomationHierarchy(value:Boolean):void
		{
			Automation.automationDebugTracer.traceMessage("UIFTETextFieldAutomationImpl", "set showInAutomationHierarchy()", AutomationConstants.invalidDelegateMethodCall);
		}
		
		public function get automationTabularData():Object
		{
			return null;
		}
		
		public function replayAutomatableEvent(event:Event):Boolean
		{
			return false;
		}
	}
}