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
	import mx.collections.ArrayCollection;
	
	[Style(name="testextstyle_1_string_noinh", type="String", inherit="no")]	
	
	[Style(name="testextstyle_2_number_noinh", type="Number", inherit="no")]
	
	[Style(name="testextstyle_3_uint_inh", type="uint", inherit="yes")]
	
	[Style(name="testextstyle_4_boolean_inh", type="Boolean", inherit="yes")]
	
	public class ADVStyleTestExtendClass extends ADVStyleTestClass
	{
		public function ADVStyleTestExtendClass()
		{
			//TODO: implement function
			super();
		}
		
		/**
		 * a list that fill with all style's name defined in this ADVStyleTestClass class.
		 */
		public static const STYLE_NAME_LIST:ArrayCollection = new ArrayCollection([
			'testextstyle_1_string_noinh',
			'testextstyle_2_number_noinh',
			'testextstyle_3_uint_inh',
			'testextstyle_4_boolean_inh',
		]);
	}
}