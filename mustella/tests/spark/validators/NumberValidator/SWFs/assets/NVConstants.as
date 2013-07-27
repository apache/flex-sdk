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

	public class NVConstants
	{
		public static const pauseTime:int = 100;
		
		public static const ERROT_TEXT:String = null;
		
		public static const localeUndefinedErrMsg:String = spark.globalization.LastOperationStatus.LOCALE_UNDEFINED_ERROR;
		public static const noErrorMsg:String = spark.globalization.LastOperationStatus.NO_ERROR;
		public static const illegalParamMsg:String = spark.globalization.LastOperationStatus.ILLEGAL_ARGUMENT_ERROR;
		public static const usingDefaultWarningMsg:String = spark.globalization.LastOperationStatus.USING_DEFAULT_WARNING ; 
		
		public static const NEGATIVE_ERROR:String = "You cannot input negative number here. zh-CN " ;
		public static const NEGATIVENUMBERFORMAT_ERROR:String = "The negative format is wrong el-GR " ;
								public static const DECIMALPOINTCOUNT_ERROR:String = "Decimal point count is not correct. ar-SA" ;
								public static const GREATER_THAN_MAX_ERROR:String = "Exceed max value hi-IN" ;
		public static const INTEGER_ERROR:String = "This should be an integer ja-JP" ; 
		public static const INVALIDCHAR_ERROR:String = "It contains invalid character de-DE: März" ;
		public static const INVALIDFORMATCHAR_ERROR:String = "The formatting parameter is invalid fr-FR:février " ;
		public static const LESS_THAN_MIN_ERROR:String = "The number is too small LATIN: utorak,sreda,četvrtak" ; 
		public static const NEGATIVE_SYMBOL_ERROR:String = "The negative symbol is wrong sr-Cyrl-ME" ; 
		public static const FRACTIONAL_DIGITS_ERROR:String = "Too many digits beyond the decimal point ru-RU" ; 
		public static const GROUPING_SEPARATOR_ERROR:String = "The number digits grouping is not following the group pattern hy-AM" ; 
								public static const PARSE_ERROR:String = "The input string cannot be parsed fa-IR" ; 
								public static const LOCALEUNDEFINED_ERROR:String = "Locale is undefined fa-IR" ; 
		//public static const NOT_A_NUMBER_ERROR:String = "This is not a number" ; 
		
		public static const NEGATIVE_ERROR_ZH:String = "你不能在这里输入负数。zh-CN: 测试测试" ;
		
		
		public static const decimalPointCountErrorDef:String = 'The decimal separator can occur only once.';
		public static const greaterThanMaxErrorDef:String = 'The number entered is too large.';
		public static const fractionalDigitsErrorDef:String = 'The amount entered has too many digits beyond the decimal point.';
		public static const groupingSeparationErrorDef:String = 'The number digits grouping is not following the grouping pattern.';
		public static const notAnIntegerErrorDef:String = 'The number must be an integer.';
		public static const invalidCharErrorDef:String = 'The input contains invalid characters.';
		public static const invalidFormatCharsErrorDef:String = 'One of the formatting parameters is invalid.';
		public static const lessThanMinErrorDef:String = 'The amount entered is too small.';
		public static const negativeErrorDef:String = 'The amount may not be negative.';
		public static const negativeSymbolErrorDef:String = 'The negative symbol is repeated or not in right place.';
		public static const negativeNumberFormatErrorDef:String = 'The negative format of the input number is incorrect.';
		public static const parseErrorDef:String = 'The input string could not be parsed.';
		public static const localeUndefinedErrorDef:String = 'Locale is undefined.';
		
		public static const ERROR_1:String = "It's a custom error text!!!";
		
		public static const ERROR_2:String = "这是个中文的错误文本。";
		
		public function NVConstants(){ }
		
		public static function testArgError(errObj:*,pptName:String,pptValue:*):String
		{
			var errorStr:String = "noError";
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
			
	}
}