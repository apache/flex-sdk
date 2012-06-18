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
	public class ApplicationDataToAgent
	{
		private var m_oAppId:String;
		private var m_oCurrentResponseIdString:String;
		private var m_oCurrentResponseData:String;
		private var m_nRemianingDataLength:int;
		private var m_bFreshData:Boolean;
		
		public function get currentResponseIdString():String
		{
			return 	m_oCurrentResponseIdString;
		}
		
		public function get currentResponseData():String
		{
			return 	m_oCurrentResponseData;
		}
		
		public function ApplicationDataToAgent( p_oAppId:String,p_oResponseID:String ,p_oResponseData:String)
		{
			m_oAppId = p_oAppId;
			m_oCurrentResponseIdString = p_oResponseID;
			m_oCurrentResponseData = p_oResponseData;
			m_nRemianingDataLength =  m_oCurrentResponseData.length;
			m_bFreshData = true;
		}
		
		public function init( p_oAppId:String,p_oResponseID:String ,p_oResponseData:String):void
		{
			m_oAppId = p_oAppId;
			m_oCurrentResponseIdString = p_oResponseID;
			m_oCurrentResponseData = p_oResponseData;
			m_nRemianingDataLength =  m_oCurrentResponseData.length;
			m_bFreshData = true;
		}
		public function willDataBePendingAfterNextSend():Boolean
		{
			// this is the max data length which can be sent
			var a_nDataLength:int = getMaxDataLength();
			if(m_nRemianingDataLength > a_nDataLength)
				return true;
			else
				return false;
		}
		public function getNextSet(p_oResponseIdString:String):String
		{
			var a_oCurrentSet:String;
			
			// the remainining response will be processed only if the request came wit the same reponseID
			if(p_oResponseIdString == m_oCurrentResponseIdString)
			{
				// check whether the data remains to be sent
				if(m_nRemianingDataLength)
				{
					//check whether we need to split the data or we can send it in one shot.
					if(getRemainingTotalStringLengthToBeSent() > ClientSocketHandler.toAppDataMaxLength)
					{
						// get the next set data
						var a_nDataLength:int = getMaxDataLength();
						var a_oPartData:String = m_oCurrentResponseData.substr((m_oCurrentResponseData.length - m_nRemianingDataLength), a_nDataLength);
		
						// since we are sendnig a_nDataLength, re calculate the m_nRemianingDataLength
						m_nRemianingDataLength -= a_nDataLength;
						a_oCurrentSet = a_oPartData;
					}
					else
					{
			
						var a_oPartData1:String = m_oCurrentResponseData.substr((m_oCurrentResponseData.length - m_nRemianingDataLength), m_nRemianingDataLength);
		
						// send complete remaining data.
						m_nRemianingDataLength = 0;
						a_oCurrentSet = a_oPartData1;
					
					}
				}
				else if(m_bFreshData)
					a_oCurrentSet = "";
		
				m_bFreshData = false;
			}
		
			return a_oCurrentSet;
		}
		
		public function  sendNextSet(p_oResponseIdString:String):int
		{	
		
			// the remainining response will be processed only if the request came wit the same reponseID
			if(p_oResponseIdString == m_oCurrentResponseIdString)
			{
				// check whether the data remains to be sent
				if(m_nRemianingDataLength)
				{
					//check whether we need to split the data or we can send it in one shot.
					if(getRemainingTotalStringLengthToBeSent() > ClientSocketHandler.toAppDataMaxLength)
					{
						// get the next set data
						var a_nDataLength:int = getMaxDataLength();
						var a_oPartData:String = m_oCurrentResponseData.substr((m_oCurrentResponseData.length - m_nRemianingDataLength), a_nDataLength);
		
						// since we are sendnig a_nDataLength, re calculate the m_nRemianingDataLength
						m_nRemianingDataLength -= a_nDataLength;
						sendData(a_oPartData, 1);
					}
					else
					{
			
						var a_oPartData1:String = m_oCurrentResponseData.substr((m_oCurrentResponseData.length - m_nRemianingDataLength), m_nRemianingDataLength);
		
						// send complete remaining data.
						m_nRemianingDataLength = 0;
						sendData(a_oPartData1,0);
					}
				}
				else if(m_bFreshData)
					sendData("",0);
		
				m_bFreshData = false;
			}
		
			return m_nRemianingDataLength;

			
		}
		
		public function sendForcefulCompletion(p_oResponseIdString:String):int
		{
			sendData("", 0);
			return 0;
		}
		
		public function isDataRemaining():Boolean
		{
			if(m_nRemianingDataLength  > 0)
				return true;
			return false;
		}
		
		protected  function getRemainingTotalStringLengthToBeSent():int
		{
			// data will be sent in this format
			// AppId|ResponseId|ResponseData|End_Indicator or PartIndicator
		  // part indicator and end indicator is supposed to have the same length.
 		 	var a_nNextSendLength:int = m_oAppId.length + m_oCurrentResponseIdString.length + m_nRemianingDataLength+ 
			(ClientSocketHandler.separator.length)*3+ ClientSocketHandler.dataToAgentEndIndicator.length;

  			return a_nNextSendLength;
		}
		
		protected function getMaxDataLength():int
		{	
		 	 return ( ClientSocketHandler.toAppDataMaxLength - m_oAppId.length - m_oCurrentResponseIdString.length- 
					((ClientSocketHandler.separator.length)*3) - ClientSocketHandler.dataToAgentEndIndicator.length);
		}
		
		public function getNextFormattedData(p_oResponseIdString:String,p_bPartIndicator:Boolean):String
		{
			var rowData:String = getNextSet(p_oResponseIdString);
			var dataToBeSent:String = m_oAppId
											+ ClientSocketHandler.separator + 
									  m_oCurrentResponseIdString 
											+ ClientSocketHandler.separator + 
									  rowData
											+ ClientSocketHandler.separator;
			if(p_bPartIndicator == true) // it is part
					dataToBeSent = dataToBeSent+ClientSocketHandler.dataToAgentPartIndicator;
			else
					dataToBeSent = dataToBeSent+ClientSocketHandler.dataToAgentEndIndicator;
					
			return dataToBeSent;
		}
		
	
		protected function sendData(p_oDataString:String,  p_nPartIndicator:int):void
		{
			var dataToBeSent:String = m_oAppId
											+ ClientSocketHandler.separator + 
									  m_oCurrentResponseIdString 
											+ ClientSocketHandler.separator + 
									  p_oDataString
											+ ClientSocketHandler.separator;
			if(p_nPartIndicator == 1) // it is part
					dataToBeSent = dataToBeSent+ClientSocketHandler.dataToAgentPartIndicator;
			else
					dataToBeSent = dataToBeSent+ClientSocketHandler.dataToAgentEndIndicator;
		
		
			m_bFreshData = false;
			/*
			if(m_oCurrentResponseIdString == "Record")
			{
				var integ:int = 0;
				trace("Sending Record here"); 
				
			}
			*/
			
			//trace ("sending ... " + m_oCurrentResponseIdString + "  :   " + String(p_nPartIndicator) );
			ClientSocketHandler.sendDataWithoutFormatting(dataToBeSent);
			
			
		
		}



	}
}






		

