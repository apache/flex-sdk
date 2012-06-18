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
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Timer;
	
	import mx.automation.AutomationHelper;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	
	public class ClientSocketHandler extends Sprite 
	{
		
		private  static var socket:CustomSocket;
		private  static var currentToolAdapter:ToolAdapter;
		
		private   var currentDataFromAppToAgent:ApplicationDataToAgent;
		private   var isInPartDataProcessing:Boolean;
		
		private var recordRequestsQueue:Array; // array of request data to be processed one after the other. 
		// this is to ensure that data will be sent synchronously one after the other.
		// please note that in such cases we should not expect request back from the client. (other than
		// for the incomplete processing.
		// if we expect so, we need to figure out some other methods. // like we can indicate proceed to next only
		// after recieveing an x data request from app.
		
		
		private  var count:int = 0;		 private var currentApplicationId:String;
		private var applicationType:int;
		
		private var requestsSent:Array = new Array(); // for debugging...
		// later may be we can remove this.
		
		private var responsesRecieved:Array = new Array(); // for debugging...
		// later may be we can remove this.
		
		
		// receiving data from Agent
		private var currentDataFromAgent:Array = new Array();
		private static var insideIncompleteLoop:Boolean = false;
		private var isInRecording:Boolean = false;
		private var isToolInRecordingStatus:Boolean = false;
		private var isToolInRunningStatus:Boolean = false;
		
		
		
		public static const separator:String = "|";
		private static const portNo:int = 2000;
		
		public static const dataEndIndicator:String = "__DATA_FROM_TOOL_AGENT__END__";
		public static const dataPartIndicator:String ="__DATA_FROM_TOOL_AGENT_PART__";
		
		public static const dataToAgentEndIndicator:String = "__DATA_TO_TOOL_AGENT__END__";
		public static const dataToAgentPartIndicator:String ="__DATA_TO_TOOL_AGENT_PART__";
		
		public static const dataStatusIndicatorLen:int = dataEndIndicator.length;
		public static const requestToCompletePrev:String= "-CompletePrevious";
		
		// both the end and the part string length should be the same
		
		// to agent strings
		public static const startRequestString:String = "Start";
		public static const closeRequestString:String = "CloseSocket";
		public static const envRequestString:String = "ReqEnv";
		public static const recordRequestString:String = "Record";
		public static const activeScreenDataStoreRequestString:String = "StoreActiveScreen";
		public static const acceptApplicationBoundaryInScreenCoordinates:String = "AcceptAppBoundaryInScreenCoords";
		
		// from agent strings
		public static const nullValueIndicator:String= "__MX_NULL__";
		public static const emptyStringIndicator:String= "__MX_EMPTY_STRING__";
		
		public static const socketStarted:String = "SocketStarted";
		public static const socketAccepted:String = "SocketAccepted";
		
		public static const beginRecordInstructionString:String = "BeginRecording";
		public static const endRecordInstructionString:String = "EndRecording";
		
		
		public static const startRunInstructionString:String = "StartRunning";
		public static const endRunInstructionString:String = "EndRunning";
		
		public static const setEnvInstructionString:String = "SetEnv";
		public static const sendRecordDetails:String = "SendRecordDetails";
		public static const finishedRecordIndicator:String = "FinishedRecordIndicator";
		public static const captureHandle:String = "CaptureWindowHandle";
		public static const captureHandleForNewWindow:String = "CaptureWindowHandleForNewWindow";
		public static const handleForNewWindowCaptured:String = "HandleForNewWindowCaptured";
		public static const getNewWindowDetails:String = "GetNewWindowDetails";
		public static const noNewWindow:String = "NoNewWindowCreatedDuringLastRun";
		
		public static const isPointInside:String = "IsPointInside";
		public static const getElementFromPoint:String = "GetElementFromPoint";
		public static const getObjectType:String = "GetObjectType";
		public static const getParent:String = "GetParent";
		public static const getChildren:String = "GetChildren";
		public static const childrenSeparator:String = ":|:";
		public static const learnChildren:String = "LearnChildren";
		public static const leanrnChildrenIdXMLSeparator:String = "__ID_XML_SEP__";
		public static const leanrnChildrenIdsSeparator:String = "__IDS_SEP__";
		
		public static const getDisplayName:String = "GetDisplayName";
		public static const getProperties:String = "GetProperties";
		public static const getProperties_ValueSeparator:String = "__MX_ARG_SEP__";
		public static const eventArgsSeparator:String = "__MX_EVNET_ARG_SEP__";
		public static const typeValueSeparator:String = "__MX_TYPE_VAL_SEP__";
		public static const recordInfoSeparator:String = "__MX_RECORD_INFO_SEP__";
		public static const recordNoArgIndicator:String = "FOR_TOOL_NO_ARGS_FROM_APP";
		public static const buildDescription:String = "BuildDescription";
		
		public static const getTabularData:String = "GetTabularData"; 
		public static const getTabularDataArgSeparator:String = "__TABULAR_DATA_ARGS_SEP__";
		public static const getTabularData_Title_Table_Separator:String = "__TITLE_TABLE_DATA_SEP__";
		public static const getTabularData_Title_Data_Separator:String = "__TITLE_DATA_SEP__";
		public static const getTabularData_Table_Data_Separator:String = "__TABLE_DATA_SEP__";
		public static const getTabularAttributes:String = "GetTabularAttributes"; 
		
		
		public static const findObjectId:String = "FindObjectId"; 
		public static const findObjectId2:String = "FindObjectId2"; 
		public static const compareObjectIds:String = "CompareObjectIds"; 
		public static const objectIdSeparators:String = ":|:"; 
		
		
		public static const getRectangle:String = "GetRectangle";
		public static const rectangeInfoSeparator:String = ",";
		
		public static const run:String = "Run";
		public static const runParamSeparator:String = "__RUN_PARAM_SEP__";
		public static const getLastError:String="GetLastError";
		
		
		
		public static const falseString:String = "Ret_False";
		public static const trueString:String = "Ret_True";
		
		public static const idNamesSeparator:String = "__MX_ID_NAME_SEP__";
		public static const idFilterSeparator:String = "__MX_ID_FILT_SEP__";
		
		public static const toAppDataMaxLength:int = 2500;
		
		
		public static const appTypeAir:String = "Air";
		public static const appTypeFlex:String = "Flex";
		
		private var  tempCount:int = 0;
		
		private static var appAlpha:int = -1;
		private var isInRunning :Boolean = false;
		
		public function ClientSocketHandler(adapter:ToolAdapter, currentAppId:String, appType:int ) 
		{
			// create the client socket and request for connection.
			
			//store the application ID. we need this to be sent with every message.
			currentApplicationId = currentAppId;
			currentToolAdapter = adapter;
			applicationType = appType;
			
			disableApplication();
			
			ToolAdapter.showConnectionAttemptMessage();
			
			// create a new socket and the port 
			socket = new CustomSocket("localhost", ClientSocketHandler.portNo);
			socket.addEventListener(SocketResponseEvent.SOCKET_RESPONSE,responseHandler);
			//socket.addEventListener(SocketResponseEvent.SOCKET_RESPONSE,RecordingHandler.handleResponse);
			
			var tempTimer:Timer = new Timer(5000,3);
			tempTimer.addEventListener("timer", checkForConnection);
			tempTimer.start();
			
			
			
		}
		
		private static var _isDisabled:Boolean = false;
		
		public static function disableApplication():void
		{
			var appObj:UIComponent = FlexGlobals.topLevelApplication as UIComponent;
			if(appObj)
			{
				// we need to handle all window disabling 
				appAlpha = appObj.alpha;
				appObj.alpha= .4;
				appObj.enabled = false;
				_isDisabled = true;
			}
		}
		
		public static function enableApplication():void
		{
			if(_isDisabled)
			{
				var appObj:UIComponent = FlexGlobals.topLevelApplication as UIComponent;
				if(appObj)
				{
					appObj.alpha= appAlpha;
					appObj.enabled = true;
					_isDisabled = false;
				}
			}
		}
		
		public function addToRecordRequestQueue(requestObject:Object):int	//Object of type RequestData
			//Change for marshalling
		{
			
			// this is to handle the multiple requests which needs to be
			// processed for the record operation.
			if( !recordRequestsQueue)
				recordRequestsQueue = new Array();
			
			return recordRequestsQueue.push(requestObject);
			
		}
		
		public function processQueuedRecordRequests(fromAgent:Boolean = false):Boolean
		{
			
			var processed:Boolean = false;
			if(fromAgent == true)
			{
				// process only if we are fresh in the list
				// i.e only if we are not in the record processing
				if((isInRecording == true)||(isInPartDataProcessing == true))
				{
					//trace (" not processing the request from agent");
					return false;
				}
				
			}
			// this will send the stored erquest in order 
			// this will be called first from the recordHandler of the qtp and
			// then once we get the record request back from the agent.
			
			
			// it is quite possible that another record information got added to the queue
			// when we were processing with the previous one.
			// but we should not process this
			// instead let the record processing mechanism to handle this
			if(isInPartDataProcessing == false)
			{
				/*
				if(fromAgent == true)
				trace ("processing request from agent");
				else
				trace ("processing request from end record info");*/
				
				
				if((recordRequestsQueue) && (recordRequestsQueue.length))
				{
					isInRecording = true;
					// we need to remove the elements in the order they were added.
					//currentRequest is of type RequestData. Changed to Object to support Marshalling
					var currentRequest:Object = recordRequestsQueue.shift(); 
					sendData(currentRequest.requestID, currentRequest.requestData);
					
					processed = true;
				}
			}
			
			return processed;
		}
		
		private  function getResponseDetails(responseString:String):Array
		{
			var details:Array = new Array();
			
			// every response will have the following format
			// id of the application|responseIdentifier|Response.
			// get the application identifier.
			// we need not blindly use split as there may be the same devider in the 
			// data part also. Hence read the tokens separately as we are interested only in the
			// first two tokens.
			var index:int = responseString.indexOf(ClientSocketHandler.separator);
			var applicationId:String;
			if(index > -1)
			{
				// get the applicationid
				applicationId = responseString.substring(0,index);
			}
			
			// proceed only if the current application id matches.
			// this is just to ensure that we dont process the response sent to other application
			// by mistake. (eventhough care will be taken from the server to send to the correct applicaiton)
			if((applicationId) && (applicationId == currentApplicationId))
			{
				
				details.push(applicationId);
				// get the response identifier
				var index1:int = responseString.indexOf(ClientSocketHandler.separator,index+1);
				if(index1 > -1)
				{
					// get the applicationid
					var responseIdentifier:String = responseString.substring(index+1,index1);
					details.push(responseIdentifier);
					
					// get the data
					var index2:int = responseString.lastIndexOf(ClientSocketHandler.separator);
					if(index2 > -1)
					{
						// get the data
						var responseData:String = responseString.substring(index1+1,index2);
						details.push(responseData);
						
						// get the response status indicator
						var statusIndicator:String = responseString.substr(index2+1, responseString.length- (index2+1));
						details.push(statusIndicator);
						
					}
					
				}
			}
			
			return details;
			
		}
		
		
		
		
		private function combineCurrentData(currentData:Array):void
		{
			//if the current is not empty, then assign new
			// else check all fields, and combine the data string - 3rd entry in the array
			if(currentDataFromAgent && currentDataFromAgent.length==4 )
			{
				// check whether all the data matches
				// TBD validity check
				var dataString:String = currentDataFromAgent[2];
				dataString = dataString + currentData[2];
				
				currentDataFromAgent[2] = dataString ;
				//trace (currentData[2]);
			}
			else
			{
				currentDataFromAgent = new Array();
				
				currentDataFromAgent = currentData;
			}
			
			
		}
		
		private function clearCurrentData():void
		{
			currentDataFromAgent  = new Array();
		}
		
		private var socketAccepted:Boolean = false;
		private var connectionTrialCount:int = 0;
		
		private function checkForConnection(event:Event):void
		{
			connectionTrialCount ++;
			if(connectionTrialCount == 3)
			{
				if (!socketAccepted)
				{
					ToolAdapter.showConnectionFailureMessage();
				}
			}
		}
		
		public  function responseHandler(event:SocketResponseEvent):void
		{
			// dont process the request unless the air libraries are loaded 
			// properly
			if(!AutomationHelper.isAirClassLoaded())
				return;
			
			// we need to process here only if the current response is not
			// from recording
			/*
			if(event.isInRecordProcessing)
			return ;*/
			
			//dispatchEvent(new SocketResponseEvent(event.response,event.type));
			//trace ("from event"+ event.response);
			// [0] - appID , [1] - Indentifier , [2] - Data
			
			if(event.response.length == 0)
			{
				
				// we got the empty response.
				// this happens after sending data and we dont get any response back from the applicaiton
				// but this can be used to trigger the queded requests.
				
				if(isInPartDataProcessing == false)
				{
					// if we have some queued request process that.
					//processQueuedRequests();
				}
			}
			else
			{
				
				var responseDetails:Array = getResponseDetails(event.response);
				
				var responseString:String;
				var processCurrentData:Boolean = false;
				
				if((responseDetails) && (responseDetails.length > 1))
					responseString = responseDetails[1];
				
				if(responseString)
				{
					// check whether it is request for the part data completion
					if(responseString.indexOf(ClientSocketHandler.requestToCompletePrev) != -1)
					{
						// this indicates that we are in the part processing
						if(isInPartDataProcessing == false)
						{
							// this indicates programming or synchronisation error.
							// ignore this
							var a_nFalseExecution:int  = 1;
							trace ("ClientSocketHandler:responseHandler()-"+event.response);
							trace ("ClientSocketHandler:responseHandler()-We should not have come here .... " + responseString);
						}
						else
						{
							// separate the actual string
							responseString = responseString.substr(0,responseString.length-ClientSocketHandler.requestToCompletePrev.length);
							sendCurrentPartData(responseString);
						}
					}
					else
					{
						
						if(isInPartDataProcessing == true)
						{
							trace ("ClientSocketHandler:responseHandler()-"+event.response);
							trace ("ClientSocketHandler:responseHandler()- We should not have come here 2.... " + responseString);
						}
						// we have not recieved to send the previous incomplete information continuation.
						// i.e the data recieved is for us to use and handle
						// now check whether this data is complete or part
						// check the status of the message
						if(responseDetails.length > 3)
						{
							var statusIndicator:String = responseDetails[3];
							
							// combine the current data with the existing
							combineCurrentData(responseDetails);
							
							if(statusIndicator == dataEndIndicator)
							{
								insideIncompleteLoop = false;
								processCurrentData = true;
							}
							else
							{
								insideIncompleteLoop = true;
								processCurrentData = false;
							}
						}
						
						if(insideIncompleteLoop)
						{
							tempCount++;
							// current dat is incomplete
							// send request for the next set
							sendData(currentDataFromAgent[1]+ClientSocketHandler.requestToCompletePrev);
						}
						else if(responseString && processCurrentData)
						{
							tempCount = 0;
							
							if(responseString == ClientSocketHandler.socketStarted)
							{
								// request the env details
								sendData(ClientSocketHandler.startRequestString);
								//tempTimer.
								
							}
								// process the current data
							else if(responseString == ClientSocketHandler.socketAccepted)
							{
								socketAccepted = true;
								// request the env details
								sendData(ClientSocketHandler.envRequestString);
								
							}
							else if (responseString == ClientSocketHandler.handleForNewWindowCaptured)
							{
								ClientSocketHandler.isNewWindowRegistrationOver = true;
								sendData(ClientSocketHandler.handleForNewWindowCaptured,"");
							}
								
							else if(responseString == ClientSocketHandler.beginRecordInstructionString)
							{
								// start recording.
								currentToolAdapter.beginRecording();
								isToolInRecordingStatus = true;
								
								
							}
							else if(responseString == ClientSocketHandler.endRecordInstructionString)
							{
								//end recording
								currentToolAdapter.endRecording();
								isToolInRecordingStatus = false;
								
							}
							else if(responseString == ClientSocketHandler.startRunInstructionString)
							{
								//end recording
								isToolInRunningStatus = true;
							}
							else if(responseString == ClientSocketHandler.endRunInstructionString)
							{
								//end recording
								isToolInRunningStatus = false;
							}
							else  if(responseString == ClientSocketHandler.setEnvInstructionString)
							{
								if(responseDetails[2])
									currentToolAdapter.setTestingEnvironment(currentDataFromAgent[2]);
								
								// get the App Title
								var appTitle:String = currentToolAdapter.getAppTitle();
								//trace ("App Title " + appTitle);
								// send the request to capture the window handle
								
								enableApplication();
								ToolAdapter.showConnectionSuccessMessage();
								sendData(ClientSocketHandler.captureHandle, appTitle);	
								
							}
							else  if(responseString == ClientSocketHandler.sendRecordDetails)
							{
								//trace ("calling processQueuedRecordRequests sendRecordDetails");
								// request to send the stored record information
								processQueuedRecordRequests();								
							}
							else if(responseString == ClientSocketHandler.finishedRecordIndicator)
							{
								//trace ("calling processQueuedRecordRequests finishedRecordIndicator");
								
								// if there are fresh record requests in the queue 
								// this will process that
								// request to send the stored record information if any
								if(recordRequestsQueue.length	 == 0)	
								{
									isInRecording = false;
									// during recording if the previos operation has
									// resulted in a new window creation we need to process
									// the same after the current recording is over.
									processNewWindowRequestToTool();
								}
								else
									processQueuedRecordRequests();		
							}
								/*  .. is pointinside is not called from plugin
								plugin does a diff way of finding whehter the point belongs to the application
								else if(responseString == ClientSocketHandler.isPointInside)
								{
								var dataToBeSent:String = ClientSocketHandler.falseString;
								
								if(currentDataFromAgent[2])
								{
								var pointArray:Array = (currentDataFromAgent[2] as String).split(",");
								var windowId:String;
								if(pointArray.length == 3)
								windowId = pointArray[2];
								if(pointArray.length >= 2)
								{
								var checkPoint:Point = new Point(pointArray[0], pointArray[1]);
								var status:Boolean = currentToolAdapter.isScreenPointWithinStageBoundary(checkPoint,windowId);
								if(status)
								dataToBeSent = ClientSocketHandler.trueString;
								}
								
								}
								sendData(ClientSocketHandler.isPointInside, dataToBeSent);
								
								}
								*/
							else if(responseString == ClientSocketHandler.getElementFromPoint)
							{
								
								var dataToBeSent1:String = "";
								if(currentDataFromAgent[2])
								{
									var pointArray1:Array = (currentDataFromAgent[2] as String).split(",");
									var object:Object = null;
									if(pointArray1.length == 2)
										object = currentToolAdapter.getElementFromPoint(pointArray1[0], pointArray1[1], "");
									else if(pointArray1.length == 3)
										object = currentToolAdapter.getElementFromPoint(pointArray1[0], pointArray1[1],pointArray1[2] );
									
									dataToBeSent1 = object["result"];
									
								}
								sendData(ClientSocketHandler.getElementFromPoint,dataToBeSent1 );
							}
							else if(responseString == ClientSocketHandler.getObjectType)
							{	
								var dataToBeSent2:String = "";
								var objectId:String = currentDataFromAgent[2];
								if(objectId)
								{
									var object2:Object = currentToolAdapter.getElementType(objectId);
									dataToBeSent2 = object2["result"];
								}
								sendData(ClientSocketHandler.getObjectType,dataToBeSent2 );
							}
							else if(responseString == ClientSocketHandler.getParent)
							{	
								var dataToBeSent3:String = "";
								var objectId2:String = currentDataFromAgent[2];
								if(objectId2)
								{
									var object3:Object = currentToolAdapter.getParent(objectId2);
									dataToBeSent3 = object3["result"];
								}
								sendData(ClientSocketHandler.getParent,dataToBeSent3 );
							}
							else if(responseString == ClientSocketHandler.getDisplayName)
							{	
								var dataToBeSent4:String = "";
								var objectId3:String = currentDataFromAgent[2];
								if(objectId3)
								{
									var object4:Object = currentToolAdapter.getDisplayName(objectId3);
									dataToBeSent4 = object4["result"];
								}
								sendData(ClientSocketHandler.getDisplayName,dataToBeSent4 );
							}
							else if(responseString == ClientSocketHandler.getProperties)
							{	
								var dataToBeSent5:String = "";
								var idAndNames:String = currentDataFromAgent[2];
								if(idAndNames)
								{
									// separate the idAndNames
									var idAndNamesArray:Array = idAndNames.split(ClientSocketHandler.idNamesSeparator);
									if(idAndNamesArray.length == 2)
									{
										var objectID5:String = idAndNamesArray[0];
										var names:String = idAndNamesArray[1];
										//trace("Properties requested for " + names);
										
										var object5:Object = currentToolAdapter.getProperties(objectID5,names);
										var dataObjectArray:Array = object5["result"] as Array;
										if(dataObjectArray)
											dataToBeSent5 = dataObjectArray.join(ClientSocketHandler.getProperties_ValueSeparator);
										
									}
								}
								sendData(ClientSocketHandler.getProperties,dataToBeSent5 );
							}
							else if(responseString == ClientSocketHandler.getRectangle)
							{	
								var dataToBeSent6:String = "";
								var objectID6:String = currentDataFromAgent[2];
								if(objectID6)
								{
									var arr1:Array = currentToolAdapter.getRectangleInScreenCoordinates(objectID6);
									dataToBeSent6 = arr1.join(ClientSocketHandler.rectangeInfoSeparator);
								}
								sendData(ClientSocketHandler.getRectangle,dataToBeSent6 );
							}
								
							else if(responseString == ClientSocketHandler.buildDescription)
							{	
								var dataToBeSent7String:String = "";
								var objectID7:String = currentDataFromAgent[2];
								if(objectID7)
								{
									var object7:Object = currentToolAdapter.buildDescription(objectID7);
									dataToBeSent7String = object7["result"];
									
								}
								sendData(ClientSocketHandler.buildDescription,dataToBeSent7String );
							}
							else if(responseString == ClientSocketHandler.getChildren)
							{	
								var dataToBeSent8:String = "";
								var objectID_And_Filter:String = currentDataFromAgent[2];
								if(objectID_And_Filter)
								{
									// separate the idAndNames
									var objectID_And_FilterArray:Array = objectID_And_Filter.split(ClientSocketHandler.idFilterSeparator);
									if(objectID_And_FilterArray.length == 2)
									{
										var objectID8:String = objectID_And_FilterArray[0];
										var filter:String = objectID_And_FilterArray[1];
										
										var object8:Object = currentToolAdapter.getChildren(objectID8,filter); 
										var dataToBeSentArray8:Array = (object8["result"] as Array);
										dataToBeSent8 = dataToBeSentArray8.join(ClientSocketHandler.childrenSeparator);
									}
								}
								sendData(ClientSocketHandler.getChildren,dataToBeSent8 );
							}
							else if(responseString == ClientSocketHandler.learnChildren)
							{
								var dataToBeSent9:String = "";
								var objectID_And_Filter1:String = currentDataFromAgent[2];
								if(objectID_And_Filter1)
								{
									// separate the idAndNames
									var objectID_And_FilterArray1:Array = objectID_And_Filter1.split(ClientSocketHandler.idFilterSeparator);
									if(objectID_And_FilterArray1.length == 2)
									{
										var objectID9:String = objectID_And_FilterArray1[0];
										var filter1:String = objectID_And_FilterArray1[1];
										
										var object9:Object = currentToolAdapter.learnChildObjects(objectID9,filter1); 
										var dataobject9:Object = (object9["result"]);
										
										var dataToBeSentArray9:Array = new Array();
										dataToBeSentArray9.push(dataobject9["learnChildrenXML"]);
										var childIDs:Array		 = (dataobject9["childrenIDs"] as Array)
										dataToBeSentArray9.push( childIDs.join(ClientSocketHandler.leanrnChildrenIdsSeparator));
										dataToBeSent9 = dataToBeSentArray9.join(ClientSocketHandler.leanrnChildrenIdXMLSeparator);
									}
								}
								sendData(ClientSocketHandler.learnChildren,dataToBeSent9);
							}
								
							else if(responseString == ClientSocketHandler.run)
							{
								
								isInRunning = true;
								var dataToBeSent10:String = "";
								var objectID_Method_Arg_String:String = currentDataFromAgent[2];
								
								if(objectID_Method_Arg_String)
								{
									// separate the idAndNames
									var objectID_Method_Arg_Array:Array = objectID_Method_Arg_String.split(ClientSocketHandler.runParamSeparator);
									if(objectID_Method_Arg_Array.length == 3)
									{ 
										
										var objectID10:String = objectID_Method_Arg_Array[0];
										//trace (objectID10);
										var method:String = objectID_Method_Arg_Array[1];
										var args:String = objectID_Method_Arg_Array[2];
										
										var object10:Object = currentToolAdapter.run(objectID10,method,args);
										
										dataToBeSent10 = "";
										if(object10)
										{
											var resultObj10:Object =(object10["result"]);  
											if(resultObj10)
												dataToBeSent10 = resultObj10["type"] + ClientSocketHandler.runParamSeparator+(resultObj10["value"]);
										}
									}
								}
								sendData(ClientSocketHandler.run,dataToBeSent10);
								// we need to  set it false only after we sending the
								// new window processing 
								//isInRunning = false;
								//processNewWindowRequestToTool();
							}
							else if(responseString == ClientSocketHandler.getLastError)
							{
								var dataToBeSent11:String = "";
								
								var object11:Object = currentToolAdapter.getLastError(); 
								dataToBeSent11 = (object11["result"]);
								sendData(ClientSocketHandler.getLastError,dataToBeSent11);
							}
								
							else if(responseString == ClientSocketHandler.getTabularData)
							{
								var dataToBeSent12:String = "";
								
								var tabularDataArgs:String = currentDataFromAgent[2];
								if(tabularDataArgs)
								{
									// separate the idAndNames
									var tabularDataArgsArray:Array = tabularDataArgs.split(ClientSocketHandler.getTabularDataArgSeparator);
									if(tabularDataArgsArray.length == 3)
									{
										var objectID12:String = tabularDataArgsArray[0];
										var min:Number = Number(tabularDataArgsArray[1]);
										var max:Number =  Number(tabularDataArgsArray[2]);
										
										var object12:Object = currentToolAdapter.getTabularData(objectID12,min,max); 
										var dataobject12:Object = (object12["result"]);
										
										var dataToBeSentArray12:Array = new Array();
										
										// Creating a dummy object to handle error in unusual cases like 
										// object being visible only at the time of inserting checkpoint
										// but not being available before that.
										// Ex: Volume bar in Spark Mutebutton control.
										// It will not be visible before we click on insert checkpoint
										// It can be made visible later by clicking on Ctrl.
										// If it is visible before we click on insert checkpoint
										// it will not be available in the child list of the application
										// by the time we come back to the application.
										// http://bugs.adobe.com/jira/browse/FLEXENT-1113
										if(!dataobject12)
										{
											dataobject12 = new Object();
											dataobject12["columnTitles"] = new Array();
											dataobject12["tableData"] = new Array();
										}
										
										var columnNamesString:String = (dataobject12["columnTitles"] as Array).join(ClientSocketHandler.getTabularData_Title_Data_Separator);
										if(columnNamesString=="")
										{
											if((dataobject12["columnTitles"] as Array).length == 0)
												columnNamesString = ClientSocketHandler.nullValueIndicator;
											else
												columnNamesString = ClientSocketHandler.emptyStringIndicator;
										}
										dataToBeSentArray12.push(columnNamesString);
										var tableDataString:String = openArrayOfArrays(dataobject12["tableData"] as Array, ClientSocketHandler.getTabularData_Table_Data_Separator)
										//var tableDataString:String = (dataobject12["tableData"] as Array).join(ClientSocketHandler.getTabularData_Table_Data_Separator);
										if(tableDataString=="")
										{
											if((dataobject12["tableData"] as Array).length == 0)
												tableDataString = ClientSocketHandler.nullValueIndicator;
											else
												tableDataString = ClientSocketHandler.emptyStringIndicator;
										}
										
										dataToBeSentArray12.push(tableDataString);
										dataToBeSent12 = dataToBeSentArray12.join(ClientSocketHandler.getTabularData_Title_Table_Separator);
									}
								}
								sendData(ClientSocketHandler.getTabularData,dataToBeSent12);
							}
							else if(responseString == ClientSocketHandler.getTabularAttributes)
							{
								var dataToBeSent13:String = "";
								
								var objectID13:String = currentDataFromAgent[2];
								if(objectID13)
								{
									// separate the idAndNames
									var object13:Object = currentToolAdapter.getTabularAttributes(objectID13); 
									var dataobject13:Object = (object13["result"]);
									
									var dataToBeSentArray13:Array = new Array();
									if(dataobject13)
									{
										dataToBeSentArray13.push(dataobject13["fullSize"]);
										dataToBeSentArray13.push(dataobject13["minVisibleRow"]);
										dataToBeSentArray13.push(dataobject13["maxVisibleRow"]);
									}
									else
									{
										// Creating a dummy array to handle error in unusual cases like 
										// object being visible only at the time of inserting checkpoint
										// but not being available before that.
										// Ex: Volume bar in Spark Mutebutton control.
										// It will not be visible before we click on insert checkpoint
										// It can be made visible later by clicking on Ctrl.
										// If it is visible before we click on insert checkpoint
										// it will not be available in the child list of the application
										// by the time we come back to the application.
										// http://bugs.adobe.com/jira/browse/FLEXENT-1113
										dataToBeSentArray13.push(0);
										dataToBeSentArray13.push(0);
										dataToBeSentArray13.push(0);
									}
									dataToBeSent13 = dataToBeSentArray13.toString(); // we are using the normal array sep
								}
								sendData(ClientSocketHandler.getTabularAttributes,dataToBeSent13);
							}
							else if(responseString == ClientSocketHandler.findObjectId2)
							{
								var dataToBeSent14:String = "";
								
								var descriptionXml14:String = currentDataFromAgent[2]; 
								if(descriptionXml14)
								{
									// separate the idAndNames
									var object14:Object = currentToolAdapter.findObjectIDs(descriptionXml14); 
									var dataobject14:Array = (object14["result"] as Array);
									
									if(dataobject14)
										dataToBeSent14 = dataobject14.join(ClientSocketHandler.objectIdSeparators); 
									
								}
								sendData(ClientSocketHandler.findObjectId2,dataToBeSent14);
							}
							else if(responseString == ClientSocketHandler.getNewWindowDetails)
							{
								processNewWindowRequestToTool(null,ClientSocketHandler.getNewWindowDetails,true);
								// WE would have got this request as a part of a run
								// refer the plugin run handling code.
								// so only after we processing this request we need to set the flag to false.
								if(isInRunning)
									isInRunning = false;
							}
							//getLastError
							clearCurrentData();
						}
					}
				}
				else
				{
					trace  ("event response is not normal" + event.response);
				}
			}
		}
		
		private function openArrayOfArrays(passedArray:Array , delimiter:String):String
		{
			if(passedArray )
			{
				var tempArr:Array = new Array();
				var index:int = 0;
				var count:int =  passedArray.length;
				while(index < count)
				{
					var currentArray:Array = passedArray[index] as Array;
					if(currentArray)
						tempArr.push(currentArray.join(delimiter));
					else
						tempArr.push(passedArray[index]);
					index++;
				}
				return tempArr.join(delimiter);
			}
			else
				return "";
		}
		
		private function processNewWindowRequestToTool(event:Event = null, newResposeIdString:String = null,
													   sendDataEvenOnNoNewWindow:Boolean = false):void
		{
			if(recordRequestsQueue && recordRequestsQueue.length)
				return;
			
			var responseIdString:String ;
			var dataString:String;
			var toBeSent:Boolean = false;
			if(newResposeIdString != null)
				responseIdString = newResposeIdString;
			
			if(queuedNewWindowRequestsToSendToTool && queuedNewWindowRequestsToSendToTool.length)
			{
				var appData:ApplicationDataToAgent = queuedNewWindowRequestsToSendToTool.shift() as ApplicationDataToAgent;
				dataString = appData.currentResponseData;
				if(!responseIdString)
					responseIdString = appData.currentResponseIdString;
			}
			else if (sendDataEvenOnNoNewWindow)
				dataString = ClientSocketHandler.noNewWindow;
			
			if(dataString && responseIdString)
				sendData(responseIdString,dataString);
		}
		
		private var queuedNewWindowRequestsToSendToTool:Array = new Array();
		
		public  function sendData(requestIdentifier:String,dataString:String=""):void
		{
			// TBD handle when we get if we were already in part processing we should
			// queue this request
			
			if(!dataString)
				dataString = ClientSocketHandler.nullValueIndicator;
			
			// here we assume that we got the request from the new data sending.
			requestsSent.push(requestIdentifier);   
			
			if(!currentDataFromAppToAgent)
				currentDataFromAppToAgent = new ApplicationDataToAgent(currentApplicationId,requestIdentifier,dataString);
			else
				currentDataFromAppToAgent.init(currentApplicationId,requestIdentifier,dataString);
			
			
			
			if(currentDataFromAppToAgent.willDataBePendingAfterNextSend())
				isInPartDataProcessing = true;
			
			if(currentDataFromAppToAgent.sendNextSet(requestIdentifier) > 0)
				isInPartDataProcessing = true;
				// means current data could not be completely sent
			else
				isInPartDataProcessing = false;
			
			
			
		}
		
		
		private function sendCurrentPartData( responseIdentifier:String):void
		{
			if(currentDataFromAppToAgent.isDataRemaining() == false)
			{
				
				trace("ClientSocketHandler:sendCurrentPartData()-This should not have happened. Last time data is not there and we received a part request.");
				// send a forceful completion 
				currentDataFromAppToAgent.sendForcefulCompletion(responseIdentifier);
				
			}
			else
			{	
				if(currentDataFromAppToAgent.willDataBePendingAfterNextSend())
					isInPartDataProcessing = true;
				
				if(currentDataFromAppToAgent.sendNextSet(responseIdentifier) > 0)
					isInPartDataProcessing = true;
				else
					isInPartDataProcessing = false;
			}
			
			
		}
		
		
		public static function sendDataWithoutFormatting(dataString:String):void
		{   
			// if the required air libraries could not be loaded, 
			// we should not proceed communicating to QTP.
			// without certian information using the library (e.g applicationTitle)
			// qtp will hang.
			if(!AutomationHelper.isAirClassLoaded())
				return;
			
			//trace ("sending " + dataString);
			
			
			//str = str.concat(String(count));
			if(socket.connected)
			{
				socket.sendRequestString(dataString);
				socket.flush();
				socket.readResponse();
			}
		}
		
		public function processNewWindowInformation(windowId:String):void
		{
			ClientSocketHandler.isNewWindowRegistrationOver = false;
			
			if(isToolInRecordingStatus && (AutomationHelper.isAirClassLoaded()) )
				disableApplication();
			
			
			if(isToolInRunningStatus || isToolInRecordingStatus)
			{
				// if we are getting this in the middle of recording or replaying
				// let us add to the queued request and once the 
				// recording or replaying is over let us handle it.
				var newDataFromAppToAgent:ApplicationDataToAgent = new ApplicationDataToAgent(currentApplicationId,ClientSocketHandler.captureHandleForNewWindow,windowId);
				queuedNewWindowRequestsToSendToTool.push(newDataFromAppToAgent);
			}
			else
				sendData(ClientSocketHandler.captureHandleForNewWindow, windowId);	
			
		}
		
		private static var _isNewWindowRegistrationOver:Boolean = false;
		public static function get isNewWindowRegistrationOver():Boolean
		{
			return _isNewWindowRegistrationOver;
		}
		
		public static function set isNewWindowRegistrationOver(inputData:Boolean):void
		{
			_isNewWindowRegistrationOver = inputData;
			if(_isNewWindowRegistrationOver)
				enableApplication();
		}
	}
}
