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
	import spark.validators.NumberValidator;
	import mx.validators.ValidationResult;
	import spark.validators.supportClasses.NumberValidatorBase;
	
	[Exclude(name="fractionalDigits", kind="property")]
	[Exclude(name="decimalSeparator", kind="property")]
	[Exclude(name="allowNegative", kind="property")]
	
	public class MyNumberValidator extends NumberValidator
	{
		public static const FRACTIONAL_DIGITS:int = 3;
		public static const DECIMAL_SEPARATOR:String = ".";
		
		public static const Default_NOT_MULTIPLES_FIVE_ERROR:String = "Number is not the multiples of five" ; 
		
		public function MyNumberValidator()
		{
			super();
			_isMultiplesOfFiveError = Default_NOT_MULTIPLES_FIVE_ERROR ;
		}
		
		override protected function doValidation(value:Object):Array {
			
			fractionalDigits = FRACTIONAL_DIGITS ;
			decimalSeparator = DECIMAL_SEPARATOR ;
			allowNegative = false ; 
			
			var results:Array = super.doValidation(value);
			
			// Return if there are errors
			// or if the required property is set to <code>false</code> and length
			// is 0.
			var val:String = value ? String(value) : "";
			if (results.length > 0 || ((val.length == 0) && !required))
				return results;
			else
				return validateMyNumber(value, null);
			
		}
		
		public function validateMyNumber(value:Object,
									   baseField:String):Array {
			var results:Array = [];
			
			const inputStr:String = String(value);
			
			if ( (Number(inputStr)%5 )  != 0) {
				results.push(new ValidationResult(
					true, baseField, "isMultipleOfFiveError",
					this.isMultiplesOfFiveError));
				
				return results;
			}
			
			return results;
		}
		
		private var _isMultiplesOfFiveError:String;
		
		[Inspectable(category="Errors", defaultValue="null")]
		/**
		 *  Error message when number is not the multiples of Five.
		 *
		 *  @default "Number is not the multiples of Five"
		 *  
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2
		 *  @langversion 3.0
		 *  @productversion Flex 4.5
		 */
		public function get isMultiplesOfFiveError():String
		{
			return _isMultiplesOfFiveError;
		}
		
		public function set isMultiplesOfFiveError(value:String):void
		{
			_isMultiplesOfFiveError = value ? value : "isMultipleOfFiveError";
		}
		
	}
}