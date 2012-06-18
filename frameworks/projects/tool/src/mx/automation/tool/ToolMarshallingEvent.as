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
	import mx.automation.IAutomationObject;
	import mx.events.SWFBridgeEvent;
	import flash.events.Event;
	 
	/**
	 *  The MarshalledAutomationEvents class represents event objects that are dispatched 
	 *  by the AutomationManager.This represents the marshalling related events.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	public class ToolMarshallingEvent extends SWFBridgeEvent
	{
 	   include "../../core/Version.as";
		

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
  /* 
    public static const BEGIN_RECORDING:String = "BeginRecording";
     public static const END_RECORDING:String = "EndRecording";
     
    public static const ENV_DETAILS:String = "SetEnvironment";
    public static const RECORDING_STATUS_REQUEST:String ="GetRecordingStatus";
    public static const RECORDING_STATUS_REPLY:String ="RecordingStatusReply";
  */
    
    public static const RECORD:String = "Record";
    
    public static const FIND_OBJECTIDS:String = "FindObjectIDs";
    public static const FIND_OBJECTIDS_REPLY:String = "FindObjectIDsReply";
    
    public static const RUN:String = "Run";
    public static const RUN_REPLY:String = "RunReply";
    
    public static const GET_ACTIVESCREEN:String = "GetActiveScreen";
    public static const GET_ACTIVESCREEN_REPLY:String = "GetActiveScreenReply";    
    
    public static const GET_RECTANGLE:String = "GetRectangle";
    public static const GET_RECTANGLE_REPLY:String = "GetRectangleReply";  
    
    public static const GET_PARENT:String = "GetParent";
    public static const GET_PARENT_REPLY:String = "GetParentReply"; 
    
    public static const GET_ELEMENT_FROM_POINT:String = "GetElementFromPoint";
    public static const GET_ELEMENT_FROM_POINT_REPLY:String = "GetElementFromPointReply";
    
    public static const GET_ELEMENT_TYPE:String = "GetElementType";
    public static const GET_ELEMENT_TYPE_REPLY:String = "GetElementTypeReply";
    
    
    public static const GET_DISPLAY_NAME:String = "GetDisplayName";
    public static const GET_DISPLAY_NAME_REPLY:String = "GetDisplayNameReply";
    
    
    public static const GET_PROPERTIES:String = "GetProperties";
    public static const GET_PROPERTIES_REPLY:String = "GetPropertiesReply"; 
    
    
    public static const GET_TABULAR_DATA:String = "GetTabularData";
    public static const GET_TABULAR_DATA_REPLY:String = "GetTabularDataReply";
    
    
    public static const GET_TABULAR_ATTRIBUTES:String = "GetTabularAttributes";
    public static const GET_TABULAR_ATTRIBUTES_REPLY:String = "GetTabularAttributesReply";
    
    
    
    public static const BUILD_DESCRIPTION:String = "BuilddDescription";
    public static const BUILD_DESCRIPTION_REPLY:String = "BuilddDescriptionReply";
    
    
    public static const GET_CHILDREN:String = "GetChildren";
    public static const GET_CHILDREN_REPLY:String = "GetChildrenReply";
    
    
    public static const LEARN_CHILD_OBJECTS:String = "LearnChildObjects";
    public static const LEARN_CHILD_OBJECTS_REPLY:String = "LearnChildObjectsReply";
    
    
    public static const GET_LAST_ERROR:String = "GetLastError";
    public static const GET_LAST_ERROR_REPLY:String = "GetLastErrorReply";
    
    
    public static const SET_LAST_ERROR:String = "SetLastError";
    // no reply for the setLastError
    
    
    public static function marshal(event:Event):ToolMarshallingEvent
    {
        var eventObj:Object = event;
        return new ToolMarshallingEvent(eventObj.type,
                                        eventObj.bubbles,
                                        eventObj.cancelable,/*
                                        eventObj.automationObject,
                                        eventObj.replayableEvent,
                                        eventObj.args,
                                        eventObj.name,
                                        eventObj.cacheable, */
                                        eventObj.applicationName,
                                        eventObj.interAppDataToSubApp ,
                                        eventObj.interAppDataToMainApp);
                                        
     }
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

   	public function ToolMarshallingEvent(type:String, 
   	                                      bubbles:Boolean = true,
                                          cancelable:Boolean = true,/*
                                          automationObject:IAutomationObject = null, 
                                          replayableEvent:Event = null,
                                          args:Array = null,
                                          name:String = null,
                                          cacheable:Boolean = false,*/
                                          applicationName:String = null , 
                                          interAppDataToSubApp :Array =null,
                                          interAppDataToMainApp:Array = null)
	{	
        super(type, bubbles, cancelable);
       // this.automationObject = automationObject;
        //this.replayableEvent = replayableEvent;
        //this.args = args;
        //this.name = name;
        //this.cacheable = cacheable;
        this.applicationName = applicationName;
        this.interAppDataToSubApp = interAppDataToSubApp;
        this.interAppDataToMainApp = interAppDataToMainApp;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------


	
	/**
     *  Contains <code>string</code> which represents the application Name  for the application.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4
     */
	public var applicationName:String;
	
	
	/**
     *  Contains <code>array</code> which represents the data from the parent to sub applications.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4
     */
	public var interAppDataToSubApp:Array;
	
	/**
     *  Contains <code>array</code> which represents the data from the sub applications to parent.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4
     */
	public var interAppDataToMainApp:Array;
	
	
	
	
	
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: Event
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override public function clone():Event
    {
        return new ToolMarshallingEvent(type, bubbles, cancelable,/*
                                         automationObject,
                                         replayableEvent,
                                         args,
                                         name,
                                         cacheable,*/
                                         applicationName, interAppDataToSubApp,interAppDataToMainApp);
    }    
 }
}