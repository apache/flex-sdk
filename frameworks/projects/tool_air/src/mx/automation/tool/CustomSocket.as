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
		
	import flash.errors.*;
	import flash.events.*;
	import flash.net.Socket;
	import mx.core.Application;
	
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	import mx.controls.Alert;
	

	[Event(name="socket_response", type="SocketResponseEvent")]
	
		
	public class CustomSocket extends Socket
	{
	
   		private var response:String;
  /*   		
   		private var isCurrentSentDetailsWasFromRecord:Boolean;
 		
   		public function isCurrentlyInRecordProcessing():Boolean
   		{
   			return isCurrentSentDetailsWasFromRecord;
   		}
   */
   
	
		
		 /**
		 *  @private
		 * 
		 **/						
	    public function CustomSocket(host:String = null, port:uint = 0) 
	    {
	    	//Security.loadPolicyFile("xmlsocket://localhost:2000");
	        super(host, port);
	        configureListeners();
	    }
	    
	    
		 /**
		 *  @private
		 * 
		 **/
	    private function configureListeners():void 
	    {
	        addEventListener(Event.CLOSE, closeHandler);
	        addEventListener(Event.CONNECT, connectHandler);
	        addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
	        addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
	        addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
	    }

	    /**
		 *  @private
		 * 
		 **/
	    private function writeln(str:String):void 
	    {
	        str += "\n";
	        try {
	            writeUTFBytes(str);
	        }
	        catch(e:IOError) {
	            trace("CustomSocket:writeln()-"+e);
	        }
	    }
		
		/**
		 *  @private
		 * 
		 **/
	    private function sendRequest():void 
	    {
	       // trace("sendRequest");
	        response = "";
	        writeln("GET /");
	        flush();
	    }
 
 		/**
		 *  @private
		 * 
		 **/   
       public function sendRequestString(str:String/*, isFromRecord:Boolean*/):void 
       {
       		//isCurrentSentDetailsWasFromRecord =  isFromRecord;
	        //trace("sendRequestString");
	        response = "";
	       	//trace ("data send " + str);
	       	writeln(str);
	        flush(); 
    	}

		/**
		 *  @private
		 * 
		 **/
	    public function readResponse():void 
	    {
	    	// read the data
	    	response = "";
        	response = readUTFBytes(bytesAvailable);
	        flush();
	        handleResponse();
        	         			
	    }
	   
   		/**
		 *  @private
		 * 
		 **/
 	    public function getResponse():String 
	    {
	    	// read the data
	    	response = "";
        	response = readUTFBytes(bytesAvailable);
	        flush();
	       	return response;
        	         			
	    }


		/**
		 *  @private
		 * 
		 **/
		private function handleResponse():void
		{
			if(response.indexOf("<cross-domain-policy>") != 0)
			{
				dispatchEvent(new SocketResponseEvent(response,/*isCurrentSentDetailsWasFromRecord,*/SocketResponseEvent.SOCKET_RESPONSE));
				response = "";
			}
			else
			{
				// we should never get this.
				// this should have been sent to the socket opened by the 
				// player
				trace ("CustomSocket:handleResponse()-we got the policy file.. this should not have happened");
			
			}
		}
	
		/**
		 *  @private
		 * 
		 **/
	    private function closeHandler(event:Event):void 
	    {
	        trace("CustomSocket:closeHandler()-" + event);
	    }
	    

		/**
		 *  @private
		 * 
		 **/
	    private function connectHandler(event:Event):void 
	    {
	 	    trace("CustomSocket:connectHandler()- Sending connect request" + event);
	 	   
		
			 var appTypeString:String;
             
             if(ToolAdapter.applicationType == ToolAdapter.ApplicationType_AIR)
           			appTypeString= ClientSocketHandler.appTypeAir;
           		else
           			appTypeString= ClientSocketHandler.appTypeFlex;
           				
			var dataToBeSent:String = ToolAdapter.applicationId
										+ ClientSocketHandler.separator + 
								  ClientSocketHandler.startRequestString 
										+ ClientSocketHandler.separator + 
								  appTypeString
										+ ClientSocketHandler.separator+
								  ClientSocketHandler.dataToAgentEndIndicator;
											
 	  
            // send the first message to the server socket.
	        sendRequestString(dataToBeSent);
	        
	    }

		private var connectionErrorShown:Boolean = false;
		/**
		 *  @private
		 * 
		 **/
	    private function ioErrorHandler(event:IOErrorEvent):void 
	    {
	    	ClientSocketHandler.enableApplication();
	    	/*
	    	Application.application.enabled = true;
	    	Application.application.alpha = ClientSocketHandler.appAlpha; */
	    	
	    	ToolAdapter.showioErrorMessage(event.toString());
	    	connectionErrorShown = true;
	    	
	    	
	        // trace("ioErrorHandler: " + event);
	        //trace("Coulld not establish connection to the QTP plugin server socket"); 
	        // trace("If you would like to use automation, please start QTP before starting the application");
	    }

		/**
		 *  @private
		 * 
		 **/
	    private function securityErrorHandler(event:SecurityErrorEvent):void 
	    {
	    	if(!connectionErrorShown)
	    	{
	    		ToolAdapter.showSecurityErrorMessage(event.toString());
	    	}
	    }

		/**
		 *  @private
		 * 
		 **/
	    private function socketDataHandler(event:ProgressEvent):void 
	    {
	        //trace("socketDataHandler: " + event);
	        //if(isCurrentSentDetailsWasFromRecord == false)
	        readResponse();
	    }
	}

}