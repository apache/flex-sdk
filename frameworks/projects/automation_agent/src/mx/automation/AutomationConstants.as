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
	public class AutomationConstants
	{
		public static const invalidDelegateMethodCall:String = "This method should not be called on delegate.Should have been called on the component";
		public static const invalidMethodCall:String = "We should not have this method";
		public static const invalidInAIR:String = "In Air we are not allowed to do this on the Window object. We need to settle this with AIR team";
		public static const missingAIRClass:String = "In AIR we are supposed to have class 'mx.automation.air.AirFunctionsHelper'.";
	}
}