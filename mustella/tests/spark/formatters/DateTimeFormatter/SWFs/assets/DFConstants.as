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
package assets
{
	
	import spark.globalization.LastOperationStatus;
	
	public class DFConstants
	{
		public static const pauseTime:int = 200;
		
		public static const ERROT_TEXT:String = null;
		
		public static const localeUndefinedErrMsg:String = spark.globalization.LastOperationStatus.LOCALE_UNDEFINED_ERROR;
		public static const noErrorMsg:String = spark.globalization.LastOperationStatus.NO_ERROR;
		public static const illegalParamMsg:String = spark.globalization.LastOperationStatus.ILLEGAL_ARGUMENT_ERROR;
		
		public static const ERROR_1:String = "It's a custom error text!!!";
		
		public static const ERROR_2:String = "这是个中文的错误文本。";
		
		public static const testDate:Date = new Date(2000, 4, 14);
		
	}
}