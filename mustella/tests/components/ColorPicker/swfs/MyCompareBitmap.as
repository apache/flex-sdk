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
package
{
	import flash.system.Capabilities;
	import flash.display.DisplayObject;
	public class MyCompareBitmap extends CompareBitmap
	{
		//add air_url property, when player type is Desktop, if the value air_url is set,
		//test assumes the image will be different than the one created in window, so 
		// the bitmap image will be read/created from air_url.
		
		public var air_url:String; 
		public var isURLConfigured:Boolean=false;
		
		public function configureURL():void
		{
			trace("###configureURL is called");
			var playerType:String=Capabilities.playerType.toLowerCase();
			if (playerType.indexOf("desktop")>-1 && air_url!="")
			{              
				url=air_url;
			}
			isURLConfigured=true;
		}
		override public function execute(root:DisplayObject, context:UnitTester,testCase:TestCase,
						testResult:TestResult):Boolean
		{
			if (air_url=="" || air_url==null) return super.execute(root,context,testCase,testResult);
			else{
				if (!isURLConfigured)
					configureURL();
				return super.execute(root,context,testCase,testResult);
			}
		}
	}
}