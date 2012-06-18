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

package mx.automation.tool
{

import flash.display.DisplayObject;

import mx.automation.AutomationHelper;
import mx.core.FlexGlobals;
import mx.events.FlexEvent;
import mx.managers.ISystemManager;

[Mixin]
public class ToolAgent
{

    include "../../core/Version.as";
	
	private static var _root:DisplayObject;
	
	private static var qtpAdapter:ToolAdapter;
	
	private static var  _clientSocketHandler:ClientSocketHandler;
	
	public static function get clientSocketHandler():ClientSocketHandler
	{
		return _clientSocketHandler;
	}
	
	
	
	public static function init(root:DisplayObject):void
    {
    	if(!qtpAdapter)
	    {
	    	_root = root;
	    	new ToolAgent(root);
    	}
	}
	
	public function ToolAgent(root:DisplayObject):void
	{
		super();

		root.addEventListener(FlexEvent.APPLICATION_COMPLETE, applicationCompleteHandler);
	}
	
	/*private function applicationCloseHandler(event:Event):void
	{
		var sm:ISystemManager = Application.application.systemManager;
		if(sm.isTopLevelRoot()){
			trace("getting application close event..informing server to close the socket");
			clientSocketHandler.sendData(ClientSocketHandler.closeRequestString);
		}
	}*/
	
	private function applicationCompleteHandler(event:FlexEvent):void
	{
		_root.removeEventListener(FlexEvent.APPLICATION_COMPLETE, applicationCompleteHandler);
		//Application.application.addEventListener(Event.CLOSING, applicationCloseHandler);
		
		var currentAppId:String;
		var applicationType:int = -1;
		
		
		// it was observed that when there are other applications loaded into the same domain
		// we get this event more than once. But for one application domain we need to create the details only once
		if(qtpAdapter)
			return;
			
		if(FlexGlobals.topLevelApplication.hasOwnProperty("applicationID"))// this should work for AIR app's
		{
			currentAppId = FlexGlobals.topLevelApplication.applicationID;
			applicationType = ToolAdapter.ApplicationType_AIR;
		}
		else if (FlexGlobals.topLevelApplication.hasOwnProperty("id"))
		{
			currentAppId = FlexGlobals.topLevelApplication.id; // this should work for flex apps
			applicationType = ToolAdapter.ApplicationType_Flex;
		}
		/*if(	applicationType != 	ToolAdapter.ApplicationType_AIR)
			return ;*/ // we support only AIR from this swc // we removed as we support Flex app from AIR for 
			// marshalling
		if(!currentAppId)
		{
			// we have not got the flex type id and we have not got the air type id
			// so here if it is the top level root applicaiton, we assume that it is air
			if(_root && (_root as ISystemManager) && (_root as ISystemManager).isTopLevelRoot())
			{
				try
				{
					currentAppId = FlexGlobals.topLevelApplication.stage.nativeWindow.title;
					applicationType = ToolAdapter.ApplicationType_AIR;
				}
				catch(e:Error)
				{
					// we could not access the air related properties.
					// so this looks to be an improper flex applicaiton which has not specified an ID
					trace ("ToolAgent:applicationCompleteHandler()-Flex Root Applicaiton which does not have an id found. Please verify");
					applicationType = ToolAdapter.ApplicationType_Flex; 
				}
			}
			else
				applicationType = ToolAdapter.ApplicationType_Flex; // this is the case of flex applicaiton which 
				// is loaded as the sub application.
		}
			
		
		ToolAdapter.applicationType = applicationType;
		ToolAdapter.applicationId = currentAppId;
		
		//var point:Point = ExternalInterfaceMethods_AS.getApplicationStartPointInScreenCoordinates(Application.application.id);
		qtpAdapter = new ToolAdapter();
		
		if(AutomationHelper.isRequiredAirClassPresent() == true)
		{
		
			if(FlexGlobals.topLevelApplication.systemManager.isTopLevelRoot())
			// start the socket here.
				_clientSocketHandler =  new ClientSocketHandler(qtpAdapter,currentAppId,applicationType);
		}
			
	}
}

}
