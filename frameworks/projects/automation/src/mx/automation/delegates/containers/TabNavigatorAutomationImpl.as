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

package mx.automation.delegates.containers 
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.automation.Automation; 
	import mx.automation.IAutomationObject;
	import mx.automation.IAutomationTabularData;
	import mx.automation.events.AutomationRecordEvent;
	import mx.containers.TabNavigator;
	import mx.core.mx_internal;
	
	use namespace mx_internal;
	
	[Mixin]
	/**
	 * 
	 *  Defines the methods and properties required to perform instrumentation for the 
	 *  TabNavigator class. 
	 * 
	 *  @see mx.containers.TabNavigator
	 *  
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class TabNavigatorAutomationImpl extends ViewStackAutomationImpl 
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
			Automation.registerDelegateClass(TabNavigator, TabNavigatorAutomationImpl);
		}   
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 * @param obj TabNavigator object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function TabNavigatorAutomationImpl(obj:TabNavigator)
		{
			super(obj);
		}
		
		/**
		 *  @private
		 *  storage for the owner component
		 */
		protected function get tabNavigator():TabNavigator
		{
			return uiComponent as TabNavigator;         
		}
		
		/**
		 *  @private
		 */
		override public function get automationTabularData():Object
		{
			var delegate:IAutomationObject 
			= tabNavigator.getTabBar() as IAutomationObject;
			
			return delegate.automationTabularData;
		}
		
		
		/**
		 *  Replays ItemClickEvents by dispatching a MouseEvent to the item that was
		 *  clicked.
		 *  
		 *  @param interaction The event to replay.
		 *  
		 *  @return <code>true</code> if the replay was successful. Otherwise, returns <code>false</code>.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		override public function replayAutomatableEvent(interaction:Event):Boolean
		{
			var replayer:IAutomationObject = 
				tabNavigator.getTabBar() as IAutomationObject ;
			return replayer.replayAutomatableEvent(interaction);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Method which gets called after the component has been initialized. 
		 *  This can be used to access any sub-components and act on the component.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		override protected function componentInitialized():void 
		{
			super.componentInitialized();
			tabNavigator.getTabBar().addEventListener(AutomationRecordEvent.RECORD,
				tabBar_recordHandler, false, 0, true);
		}
		
		/**
		 *  @private
		 */
		private function tabBar_recordHandler(event:AutomationRecordEvent):void
		{
			recordAutomatableEvent(event.replayableEvent);
		}
		
	}
}