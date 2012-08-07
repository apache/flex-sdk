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
	public class CVConstant
	{
		public static const CUST_ERROR:String = "It's a custom error string!!!";
		public static const CUST_ERROR_ZH:String = "这是个中文的错误文本!!!";
		
		public static const pauseTime:int = 100;

		public static const ERROT_TEXT:String = null;

		
		public static const localeUndefinedErrMsg:String = spark.globalization.LastOperationStatus.LOCALE_UNDEFINED_ERROR;
		public static const noErrorMsg:String = spark.globalization.LastOperationStatus.NO_ERROR;
		public static const parseErrorMsg:String = spark.globalization.LastOperationStatus.PARSE_ERROR;

		public static const illegalParamMsg:String = spark.globalization.LastOperationStatus.ILLEGAL_ARGUMENT_ERROR;
		

		public static const ERROR_1:String = "It's a custom error text!!!";
		
		public static const ERROR_2:String = "这是个中文的错误文本。";
		
		public static function testArgError(errObj:*,pptName:String,pptValue:*):String
		{
			var errorStr:String = "No Error";
			
			try
			{
				errObj[pptName] = pptValue;
			}
			catch(e:Error)
			{
				errorStr = e.toString();
				return errorStr;
			}
			
			return errorStr;
		}
		
		public static function hasArgError(errObj:*,pptName:String,pptValue:*):Boolean
		{
			if(testArgError(errObj,pptName,pptValue)=="No Error")
				return false;
			else
				return true;
		}
		
		public static const SURROGATE_STR1:String = String("\uD873\uDC00\uD874\uDC01");
		public static const SURROGATE_STR2:String = String("\uD875\uDC02\uD876\uDC03");
		public static const SURROGATE_STR3:String = String("\uD877\uDC04\uD878\uDC05");
		
		public static const SIMPLE_CHAR1:String = String("ABC");
		public static const SIMPLE_CHAR2:String = String("abcd");
		
		public static const SURROGATE_CHAR1:String = String("\uD875\uDC02");
		public static const SURROGATE_CHAR2:String = String("a\uD874\uDC04");
		public static const SURROGATE_CHAR3:String = String("ab\uD875\uDC05");
		public static const SURROGATE_CHAR4:String = String("\uD876\uDC04\uD875\uDC05");
		public static const SURROGATE_CHAR5:String = String("\uD877\uDC11\uD876\uDC04\uD875\uDC05");
		public static const SURROGATE_CHAR6:String = String("\uD878\uDC12\uD879\uDC13\uD87A\uDC14\uD87B\uDC15");
		public static const SURROGATE_CHAR7:String = String("中国人");
		public static const SURROGATE_CHAR8:String = String("中国人民");
		
		public static const MINUS_CHAR1:String = "\u2212";
		public static const MINUS_CHAR2:String = "\uFE63";
		public static const MINUS_CHAR3:String = "\uFF0D";
		
		public static const SPACE_CHAR1:String = "\u00A0";
		public static const SPACE_CHAR2:String = "\u202F";
		public static const SPACE_CHAR3:String = "\u3000";
		
		public static const PLUS_CHAR1:String = "\u002B";
		public static const PLUS_CHAR2:String = "\uFB29";
		public static const PLUS_CHAR3:String = "\uFE62";
		public static const PLUS_CHAR4:String = "\uFF0B";
		
		public function CVConstant()
		{
		}
	}
}