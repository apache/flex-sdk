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
	import spark.validators.CurrencyValidator;
	import spark.validators.supportClasses.NumberValidatorBase;
	
	[Exclude(name="currencyISOCode", kind="property")]
	[Exclude(name="currencySymbol", kind="property")]
	
	public class MyCurrencyValidator extends CurrencyValidator
	{
		public static const GOLD_SYMBOL:String = "@G@";
		public static const GOLD_ISO_CODE:String = "@GOLD@";
		
		public function MyCurrencyValidator()
		{
			super();
		}
		
		override protected function doValidation(value:Object):Array {
			currencySymbol = GOLD_SYMBOL;
			currencyISOCode = GOLD_ISO_CODE;
			
			var results:Array = super.doValidation(value);
			
			// Return if there are errors
			// or if the required property is set to <code>false</code> and 
			// length is 0.
			var val:String = value ? String(value) : "";
			if (results.length > 0 || ((val.length == 0) && !required))
				return results;
			else
				return validateCurrency(value, null);
			
		}
		
	}
}