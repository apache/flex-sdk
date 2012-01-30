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

package mx.automation.delegates.controls 
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest; 
	
	import mx.automation.Automation;
	import mx.automation.IAutomationObject;
	import mx.automation.IAutomationObjectHelper;
	import mx.automation.delegates.core.UIComponentAutomationImpl;
	import mx.controls.Image;
	import mx.controls.SWFLoader;
	import mx.core.ISWFBridgeProvider;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	import mx.managers.ISystemManager;
	import mx.utils.SecurityUtil;
	
	use namespace mx_internal;
	
	[Mixin]
	/**
	 * 
	 *  Defines methods and properties required to perform instrumentation for the 
	 *  SWFLoader control.
	 * 
	 *  @see mx.controls.SWFLoader 
	 *
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class SWFLoaderAutomationImpl extends UIComponentAutomationImpl 
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
			Automation.registerDelegateClass(SWFLoader, SWFLoaderAutomationImpl);
		}   
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 * @param obj SWFLoader object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function SWFLoaderAutomationImpl(obj:SWFLoader)
		{
			super(obj);
			// we use this class for both Image and SWFLoder. we dont need the 
			// recordClick and it causes some issue with Marshalling. hence let us add
			// it only for image. On long term let us better have another delegate for the
			// image. till then
			if (obj is Image)
				recordClick = true;
			
			obj.addEventListener(Event.OPEN, openEventHandler, false, 0, true);
		}
		
		/**
		 *  @private
		 */
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			// we dont want to record keydown operations on SWFLoader
			return;
		}
		
		/**
		 *  @private
		 *  storage for the owner component
		 */
		protected function get loader():SWFLoader
		{
			return uiComponent as SWFLoader;
		}
		
		private var loadingComplete:Boolean = true;
		
		//----------------------------------
		//  automationName
		//----------------------------------
		
		/**
		 *  @private
		 */
		override public function get automationName():String
		{
			//        if (toolTip)
			//            return toolTip;
			
			if (loader.source is String)
				return String(loader.source);
			if (loader.source is URLRequest)
				return URLRequest(loader.source).url;
			
			return super.automationName;
		}
		
		//----------------------------------
		//  automationValue
		//----------------------------------
		
		/**
		 *  @private
		 */
		override public function get automationValue():Array
		{
			//        if (toolTip)
			//            return [ toolTip ];
			
			if (loader.source is String)
				return [ String(loader.source) ];
			
			if (loader.source is URLRequest)
				return [ URLRequest(loader.source).url ];
			
			return super.automationValue;
		}
		
		//----------------------------------
		//  automationChild
		//----------------------------------
		
		/**
		 *  @private
		 */
		private function get automationChild():IAutomationObject
		{
			try
			{
				if( loader.content && loader.content is ISystemManager )
				{
					return ((ISystemManager(loader.content)).document)  as IAutomationObject;
				}
				return null;
			}
			catch (e:Error)
			{
				//most likely a security error
				Automation.automationDebugTracer.traceMessage("SWFLoaderAutomationImpl", "get automationChild()", "get content failed: " + e.message);
			}
			return null;
		}
		
		/**
		 *  @private
		 */
		override public function createAutomationIDPart(
			child:IAutomationObject):Object
		{
			var help:IAutomationObjectHelper = Automation.automationObjectHelper;
			if (!help)
				return null;
			
			var that:IAutomationObject = uiAutomationObject;
			
			return help.helpCreateIDPart(uiAutomationObject, child,
				function(item:IAutomationObject):String
				{
					var ao:IAutomationObject = loader.owner as IAutomationObject;
					return ao.createAutomationIDPart(that).automationName;
				});
		}
		
		/**
		 *  @private
		 */
		override public function createAutomationIDPartWithRequiredProperties(child:IAutomationObject, properties:Array):Object
		{
			var help:IAutomationObjectHelper = Automation.automationObjectHelper;
			if (!help)
				return null;
			
			var that:IAutomationObject = uiAutomationObject;
			
			return help.helpCreateIDPartWithRequiredProperties(uiAutomationObject, child,properties,
				function(item:IAutomationObject):String
				{
					var ao:IAutomationObject = loader.owner as IAutomationObject;
					return ao.createAutomationIDPart(that).automationName;
				});
		}
		
		/**
		 *  @private
		 */
		override public function resolveAutomationIDPart(part:Object):Array
		{
			var help:IAutomationObjectHelper = Automation.automationObjectHelper;
			return help ? help.helpResolveIDPart(uiAutomationObject, part) : null;
		}
		
		/**
		 *  @private
		 */
		override public function getAutomationChildAt(index:int):IAutomationObject
		{
			// SWFLoader can have only child
			return automationChild;
		}
		
		
		
		/**
		 * @private
		 */
		override public function getAutomationChildren():Array
		{ 
			// SWFLoader can have only child
			return [automationChild];
			
		}
		
		//----------------------------------
		//  numAutomationChildren
		//----------------------------------
		
		/**
		 *  @private
		 */
		override public function get numAutomationChildren():int
		{
			return automationChild != null ? 1 : 0;
		}
		
		/**
		 *  @private
		 */
		private function openEventHandler(event:Event):void
		{
			loadingComplete = false;
			
			loader.addEventListener(Event.COMPLETE, completeEventHandler, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorEventHandler, false, 0, true);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorEventHandler, false, 0, true);
			
			var help:IAutomationObjectHelper = Automation.automationObjectHelper;
			help.addSynchronization(function():Boolean
			{
				return loadingComplete;
			});
			
		}
		
		/**
		 *  @private
		 */
		private function removeListeners():void
		{
			loader.removeEventListener(Event.COMPLETE, completeEventHandler);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, errorEventHandler);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorEventHandler);
		}
		
		/**
		 *  @private
		 */
		private function errorEventHandler(event:Event):void
		{
			loadingComplete = true ;
			removeListeners();
		}
		
		/**
		 *  @private
		 */
		private function completeEventHandler(event:Event):void
		{
			//if the parent and child are not in mutually trusted domain
			//loader.content cannot be accessed. So we simply load the
			//swf in that case
			if (!SecurityUtil.hasMutualTrustBetweenParentAndChild(loader as ISWFBridgeProvider))
			{
				// we are done loading the swf
				loadingComplete = true ;
				removeListeners();
				return;
			}
			// if the loaded content is an app wait for application complete
			// event to get fired.
			if (loader && loader.content && loader.content is ISystemManager)
			{
				var sm:ISystemManager = loader.content as ISystemManager;
				sm.addEventListener(FlexEvent.APPLICATION_COMPLETE, appCompleteHandler);
			}
			else            
			{
				// we are done loading the swf
				loadingComplete = true ;
			}
			removeListeners();
		}
		
		/**
		 *  @private
		 */
		private function appCompleteHandler(event:Event):void
		{
			//application is initialized
			loadingComplete = true ;
			
			var sm:ISystemManager = loader.content as ISystemManager;
			sm.removeEventListener(FlexEvent.APPLICATION_COMPLETE, appCompleteHandler);
		}
		
	}
}