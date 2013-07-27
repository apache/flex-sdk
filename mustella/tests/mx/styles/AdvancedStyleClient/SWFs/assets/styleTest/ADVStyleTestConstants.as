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
package assets.styleTest
{
	public class ADVStyleTestConstants
	{
		public static const pauseTime: int = 100;
			
		[Embed(source="../../../../../../../Assets/Images/next.jpg")]
		[Bindable]
		public static var defaultCls_heavy:Class;
		
		[Embed(source="../../../../../../../Assets/Images/next.jpg")]
		[Bindable]
		public static var defaultCls_medium:Class;
		
		[Embed(source="../../../../../../../Assets/Images/next.jpg")]
		[Bindable]
		public static var defaultCls_light:Class;
		
		[Embed(source="../../../../../../../Assets/Images/next.jpg")]
		[Bindable]
		public static var defaultCls:Class;
		
		[Embed(source="../../../../../../../Assets/Images/next.jpg")]
		[Bindable]
		public static var imgCls:Class;
		
		[Embed(source="../../../../../../../Assets/Images/down.jpg")]
		[Bindable]
		public static var img2Cls:Class;
		
		[Embed(source="../../../../../../../Assets/Images/up.jpg")]
		[Bindable]
		public static var img3Cls:Class;
		
		public static var defaultAdvVo:ADVStyleTestVo = new ADVStyleTestVo('defaultObjectVo_heavy');
			
		public static var testDate:Date = new Date(2000, 8, 16);
		public static var defaultDate:Date = new Date(2010, 5, 4);
			
	}
}