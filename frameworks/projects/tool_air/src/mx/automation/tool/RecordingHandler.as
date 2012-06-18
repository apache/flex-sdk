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
	import flash.utils.Timer;
	
	public class RecordingHandler
	{
		/*
		private static var requestsQueue:Array; // array of request data to be processed one after the other. 
		 // this is to ensure that data will be sent synchronously one after the other.
		 // please note that in such cases we should not expect request back from the client. (other than
		 // for the incomplete processing.
		 // if we expect so, we need to figure out some other methods. // like we can indicate proceed to next only
		 // after recieveing an x data request from app.
		 
		private static var currentDataFromAppToAgent:ApplicationDataToAgent;
		private static var responseRecieved:Boolean = false;
		private static var currentSocketEvent:SocketResponseEvent;
		private static var isInPartDataProcessing:Boolean = false;
		
		public function RecordingHandler()
		{
			
		}
			
		public static  function addToRecordRequestQueue1(requestObject:RequestData):int
		{
			// this is to handle the multiple requests which needs to be
			// processed for the record operation.
			if( !requestsQueue)
				requestsQueue = new Array();
			
			return requestsQueue.push(requestObject);
		}
		
	 
		public static function processQueuedRecordRequestsFromRecordHandler(socket:CustomSocket ,currentApplicationId:String,fromAgent:Boolean = false):Boolean
		{
			var processed:Boolean = false;
			
			// we will be getting this request only from the agent,].
			// we should only only process the current request and return the fucntion thread
			// back to the agent.
			// socket transfer is asynchronous.
			// by the logic here, we are trying to make it synchronous.
			if(requestsQueue)
			{
				while(requestsQueue.length)
				{
					// get the current request
					var currentRequest:RequestData = requestsQueue.shift(); 
					sendData(socket,currentApplicationId,currentRequest.requestID, currentRequest.requestData);
				}
			}
			

			return processed;
		}
		
		
		private static function sendRecordData(socket:CustomSocket,currentApplicationId:String, requestIdentifier:String,dataString:String):void
        {
        	
    		if(!dataString)
        		dataString = ClientSocketHandler.nullValueIndicator;
        		
        	  	
        	if(!currentDataFromAppToAgent)
        		currentDataFromAppToAgent = new ApplicationDataToAgent(currentApplicationId,requestIdentifier,dataString);
        	else
           		currentDataFromAppToAgent.init(currentApplicationId,requestIdentifier,dataString);
	           		
	    
        	do
        	{
	               	if(currentDataFromAppToAgent.willDataBePendingAfterNextSend())
	           		isInPartDataProcessing = true;
	           	else
	           		isInPartDataProcessing = false;
	           	
	          	
	           	var currentDataToBeSent:String = currentDataFromAppToAgent.getNextFormattedData(requestIdentifier, isInPartDataProcessing);
	           	
	           	socket.sendRequestString(currentDataToBeSent, true);
        		socket.flush();
        		var responseString:String = socket.getResponse();
	           	
	           	var tempTimer:Timer = new Timer(1000, 0);
					tempTimer.start();
					
				responseString = socket.getResponse();	
	           	
	           	// we will only send the data to the socket and wait for the feedback
				//responseRecieved = false;
				//while(responseRecieved == false)
				//{
				//	var tempTimer:Timer = new Timer(500, 0);
				//	tempTimer.start();
				//}
				
				
        	}while(isInPartDataProcessing)
           	
        }
        
       // public static function checkTimer
        
        public static function handleResponse(event:SocketResponseEvent):void
        {
        	// we need to process here only if the current response is from recording
           	if(event.isInRecordProcessing)
       		{
        		responseRecieved = true;
        		currentSocketEvent =SocketResponseEvent( event.clone());
       		}
        
        }
      */

	}
}