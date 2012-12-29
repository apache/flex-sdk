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
		//add mac_url, linux_url property, also make sure they are set when
		//execute is called. when os is mac or linux, if the value mac_url, linux_url is set,
		//test assumes the image will be different than the one created in window, so 
		// the bitmap image will be read/created from mac_url or linux_url.
		
		public var mac_url:String; 
		public var linux_url:String; 
		public var isURLConfigured:Boolean=false;
		
		public function configureURL():void
		{
			trace("###configureURL is called");
			var current_os:String=Capabilities.os.toLowerCase();
			if (current_os.indexOf("window")>-1)
			{              
				trace("###url="+url);
			}else if (current_os.indexOf("mac")>-1 && mac_url!="")
			{
				url=mac_url;      
			}else if (current_os.indexOf("linux")>-1 && linux_url!="")
			{
				url=linux_url;
			}
			isURLConfigured=true;
		}
		override public function execute(root:DisplayObject, context:UnitTester,testCase:TestCase,
						testResult:TestResult):Boolean
		{
			if (!isURLConfigured)
				configureURL();
			return super.execute(root,context,testCase,testResult);
		}
	}
}