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

package mx.automation.air
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import mx.automation.Automation;
	import mx.automation.IAutomationManager2;
	import mx.core.FlexGlobals;
	[Mixin] 
	
	/**
	 *  Helper class that provides methods required for automation of AIR applications
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2
	 *  @productversion Flex 4.1
	 */
	public class AirFunctionsHelper
	{
		private var _stageStartCoordinates:Point;
		//private var _stageWidth:int;
		//private var _stageHeight:int;
		
		//private var _applicationStartCoordinates:Point;
		//private var _applicationWidth:int;
		//private var _applicationHeight:int;
		
		
		//private var _chromeHeight:int;    
		//private var _chromeWidth:int;
		
		private var _appTitle:String;
		private var _appWindow:DisplayObject; 
		
		/**
		 *  Constructor
		 *  @param windowId
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2
		 *  @productversion Flex 4.1
		 */
		public function AirFunctionsHelper(windowId:String)
		{
			if (!windowId)
				//_appWindow =   Application.application as DisplayObject;
				_appWindow =   FlexGlobals.topLevelApplication as DisplayObject;
			else
			{
				var automationManager:IAutomationManager2 = Automation.automationManager2;
				if(automationManager)
					_appWindow = automationManager.getAIRWindow(windowId);
			}
		}
		
		/**
		 *  @private
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2
		 *  @productversion Flex 4.1
		 */
		public static function init(root:DisplayObject):void
		{
			
		}
		
		// native window 's bound will give the totla and stage gives inner (statge width and stage heigjt
		
		/**
		 *  Returns the start point of the stage in screen coordinates
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2
		 *  @productversion Flex 4.1
		 */
		public  function get stageStartCoordinates():Point
		{
			// every time when the user asks this, we need to recalcuate and send the same
			
			var stageStartScreenCoordinates:Point;
			
			var startPoint:Point = new Point(0,0);
			if (_appWindow)
			{
				var startGloabalPoint:Point = _appWindow.localToGlobal(startPoint);
				//stageStartScreenCoordinates = Application.application.stage.nativeWindow.globalToScreen(startGloabalPoint);
				stageStartScreenCoordinates = _appWindow.stage.nativeWindow.globalToScreen(startGloabalPoint);
			}
			
			_stageStartCoordinates = stageStartScreenCoordinates;
			return _stageStartCoordinates;
			
		}
		
		/**
		 *  Returns current window that is active
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2
		 *  @productversion Flex 4.1
		 */
		public function get activeWindow():DisplayObject
		{
			if(_appWindow != null)
				return _appWindow;
			else
				return FlexGlobals.topLevelApplication as DisplayObject;
		}
		
		/**
		 *  Returns the title of window of top level application
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2
		 *  @productversion Flex 4.1
		 */
		public  function get appTitle():String
		{
			_appTitle=   FlexGlobals.topLevelApplication.stage.nativeWindow.title;
			return _appTitle;
		}
	}
}