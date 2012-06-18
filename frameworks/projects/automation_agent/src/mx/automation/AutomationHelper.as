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

package mx.automation
{
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.managers.ISystemManager;
	
	/**
	 *  Helper class used to call appropriate methods based on whether the 
	 *  current app is an AIR app or a Flex app.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */     
	public class AutomationHelper
	{
		/**
		 *  @private
		 *  system manager which will be used to get the definition of the requried class
		 */
		private static var sm:ISystemManager;
		private static var appType:int  = -1;
		
		/**
		 *  @private
		 *  Dictionary of already found classes
		 */
		private static var requiredClasses:Dictionary = new Dictionary(true);   
		
		
		/**
		 *  Constructor
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */     
		public function AutomationHelper()
		{
		}
		
		/**
		 *  Sets the system manager using which the root application is determined.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */     
		public static function registerSystemManager(sm1:ISystemManager):void
		{
			sm = sm1;
		}
		
		/**
		 *  Returns the top level application.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */     
		public static function getMainApplication():Object
		{
			//return FlexGlobals.topLevelApplication as Application;
			// change to support the Spark application
			// http://bugs.adobe.com/jira/browse/FLEXENT-1047
			return FlexGlobals.topLevelApplication;
		}
		
		/**
		 *  Returns true if the current application is an AIR app, false otherwise.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */     
		public static function isCurrentAppAir():Boolean
		{
			// appType -1  - type not set
			// appType 1  - air
			// appType 2  - flex
			
			if(appType == -1)
				//appType =  Application.application.hasOwnProperty("applicationID")?1:2
				appType =  getMainApplication().hasOwnProperty("applicationID")?1:2
			
			if(appType == 2)
			{
				// we are not having applicaitonID, not let us check if we have id. 
				// if id is null and if the to level applicaiton. Top level flex applicaiton
				// should have the id.  So if it is top level and if it does not have id, 
				// this is the case of air applications which does not have an applicationId
				// so we will still consier it as an AIR app.
				if(!getMainApplication().id)
				{
					if(sm.isTopLevelRoot())
						appType = 1;    
				}
			}
			
			return (appType==1)?true:false;
		}
		
		
		
		/**
		 *  Returns the title in case of AIR app, empty string otherwise.
		 *   
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */     
		public static function getAppTitle():String
		{
			var appTitle:String="";
			var allPropFound:Boolean= false;
			var am:IAutomationDebugTracer = Automation.automationDebugTracer;
			
			// get the type of the application.
			
			//if(Application.application.hasOwnProperty("applicationID"))   //air app
			if(isCurrentAppAir())// air app
			{
				var airFunctionHandler:Class = null;
				try
				{
					airFunctionHandler = getAirHelperClass("mx.automation.air.AirFunctionsHelper");
					if(airFunctionHandler)
					{
						var obj:Object = new airFunctionHandler(null);
						
						if(obj.hasOwnProperty("appTitle"))
						{
							appTitle = obj["appTitle"];
							allPropFound = true;
						}
						
					}
					
				}
				catch(e:Error)
				{
					throw e;
					
				}
				if(allPropFound == false)
				{
					am.traceMessage("AutomationHelper", "getAppTitle()","In AIR we are supposed to have class 'mx.automation.air.AirFunctionsHelper' with appTitle property.");
					// TBD. Converting this as user message and adding this in the locales.
				}
			}
			else // we are in flex app
			{
				// get the application start coordinate  from the browsers
				//appTitle = ExternalInterfaceMethods_AS.getBrowserTitle();
			}
			return appTitle;
		}
		
		
		/**
		 *  Returns the current active window in case of AIR app, 
		 *  top level application otherwise.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */     
		public static function getActiveWindow(windowId:String):Object
		{
			var activeWindow:Object = FlexGlobals.topLevelApplication;
			var allPropFound:Boolean= false;
			
			// get the type of the application.
			
			//if(Application.application.hasOwnProperty("applicationID"))   //air app
			if(isCurrentAppAir())// air app
			{
				var airFunctionHandler:Class = null;
				try
				{
					airFunctionHandler = getAirHelperClass("mx.automation.air.AirFunctionsHelper");
					if(airFunctionHandler)
					{
						var obj:Object = new airFunctionHandler(windowId);
						
						if(obj.hasOwnProperty("activeWindow"))
						{
							activeWindow = obj["activeWindow"];
							allPropFound = true;
						}				
					}
					
				}
				catch(e:Error)
				{
					throw e;
					
				}
				if(allPropFound == false)
				{
					Automation.automationDebugTracer.traceMessage("AutomationHelper", "getActiveWindow()","In AIR we are supposed to have class 'mx.automation.air.AirFunctionsHelper' with activeWindow property.");
					// TBD. Converting this as user message and adding this in the locales.
				}
			}
			else // we are in flex app
			{
				
			}
			return activeWindow;
		}
		
		/**
		 *  Returns the start point in screen coordinates.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */     
		public static function getStageStartPointInScreenCoords(windowId:String ):Point
		{
			
			var allPropFound:Boolean= false;
			var stageStartPointInScreenCoordinates:Point;
			// get the application start cooridnate in screen points
			//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
			
			
			// get the type of the application.
			//if(getMainApplication().hasOwnProperty("applicationID"))  //air app
			if(isCurrentAppAir())
			{
				var airFunctionHandler:Class = null;
				try
				{
					airFunctionHandler = getAirHelperClass("mx.automation.air.AirFunctionsHelper");
					if(airFunctionHandler)
					{
						var obj:Object = new airFunctionHandler(windowId);
						
						if(obj.hasOwnProperty("stageStartCoordinates"))
						{
							stageStartPointInScreenCoordinates = obj["stageStartCoordinates"];
							allPropFound = true;
						}                    
					}
					
				}
				catch(e:Error)
				{                   
					throw(e);
				}
				if(allPropFound == false)
				{
					Automation.automationDebugTracer.traceMessage("AutomationHelper", "getStageStartPointInScreenCoords()","In AIR we are supposed to have class 'mx.automation.air.AirFunctionsHelper' with stageStartCoordinates property.");
					// TBD. Converting this as user message and adding this in the locales.
				}
			}
			else // we are in flex app
			{
				stageStartPointInScreenCoordinates = Automation.automationManager2.getStartPointInScreenCoordinates(windowId);
				//var point:Point = Application.application.localToGlobal(new Point(Application.application.x, Application.application.y));
				var appObj:Object = getMainApplication();
				var point:Point = appObj.localToGlobal(new Point(appObj.x, appObj.y));
				stageStartPointInScreenCoordinates.x = stageStartPointInScreenCoordinates.x + point.x;
				stageStartPointInScreenCoordinates.y = stageStartPointInScreenCoordinates.y + point.y;
			}
			//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
			
			return stageStartPointInScreenCoordinates;
		} 
		
		
		private static var classLoadingFailed:Boolean = false;
		
		/**
		 *  Returns false if AIR helper class (AirFunctionsHelper) is not loaded.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */     
		public static function isAirClassLoaded():Boolean
		{
			return  !classLoadingFailed;
		}
		
		/**
		 *  Returns the helper class used for AIR automation (AirFunctionsHelper).
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */     
		public static function getAirHelperClass(className:String):Class
		{
			try
			{
				var requiredClass:Class = requiredClasses[className];
				if(requiredClass == null)
				{
					if(sm)
						requiredClass = Class(sm.getDefinitionByName(className));
					else
						requiredClass =  Class(getDefinitionByName((className)));
					
					if(requiredClass)
						// add to the dictionary so that any further request we dont need to get again.
						requiredClasses[className] = requiredClass;
				}
				return requiredClass;
			}
			catch (e:Error)
			{
				classLoadingFailed = true;
			}
			return null;            
		}
		
		/**
		 *  Returns false if AIR helper class (mx.automation.air.AirFunctionsHelper) is not found.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */     
		public static function isRequiredAirClassPresent():Boolean
		{
			try
			{
				if (getAirHelperClass("mx.automation.air.AirFunctionsHelper") != null)
					return true;
			}
			catch(e:Error)
			{
				Automation.automationDebugTracer.traceMessage("AutomationHelper", "isRequiredAirClassPresent()", e.message);
			}
			Automation.automationDebugTracer.traceMessage("AutomationHelper", "isRequiredAirClassPresent()", AutomationConstants.missingAIRClass);
			return false;
		}		
		
		public static function isRequiredSparkClassPresent():Boolean
		{
			try
			{
				if (getDefinitionByName("spark.components.Application") != null)
					return true;
			}
			catch(e:Error)
			{
				Automation.automationDebugTracer.traceMessage("AutomationHelper", "isRequiredSparkClassPresent()", e.message);
			}
			Automation.automationDebugTracer.traceMessage("AutomationHelper", "isRequiredSparkClassPresent()", "spark.components.Application class is not found.");
			return false;
		}
	}
}