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

package mx.utils
{
	import flash.display.DisplayObject;
	import flash.system.Capabilities;
	
	import mx.core.mx_internal;

	[Mixin]
	public class AndroidPlatformVersionOverride
	{
		public static function init(root:DisplayObject):void
		{
			var c:Class = Capabilities;
			//Set this override value on if we are 
			// a. on the AIR Simulator
			// b. simulating Android
			if(c.version.indexOf("AND") > -1 && c.manufacturer != "Android Linux")
			{
				Platform.mx_internal::androidVersionOverride =  "4.1.2";
			}
		}
	}
}