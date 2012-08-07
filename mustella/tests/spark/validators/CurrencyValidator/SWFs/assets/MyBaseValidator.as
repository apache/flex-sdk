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
	
	import mx.core.mx_internal;
	import mx.validators.ValidationResult;
	
	import spark.validators.supportClasses.GlobalizationValidatorBase;
	
	use namespace mx_internal;
	
	public class MyBaseValidator extends GlobalizationValidatorBase
	{
		public function MyBaseValidator()
		{
			//TODO: implement function
			super();
		}
		
		public static const APACHE_NAME:String = 'apache';
		
		override mx_internal function createWorkingInstance():void {
			isIncludeApacheNameError = 'default error message.';
		}
		
		override protected function doValidation(value:Object):Array {
			var results:Array = super.doValidation(value);
			
			// Return if there are errors
			// or if the required property is set to <code>false</code> and 
			// length is 0.
			var val:String = value ? String(value) : "";
			if (results.length > 0 || ((val.length == 0) && !required)) {
				return results;
			} else {
				return validateAdbStr(value, null);	
			}
		}
		
		public function validateAdbStr(value:Object,
									   baseField:String):Array {
			var results:Array = [];
			
			const inputStr:String = String(value);
			
			if (inputStr.indexOf(APACHE_NAME) >= 0) {
				results.push(new ValidationResult(
					true, baseField, "isIncludeApacheNameError",
					this.isIncludeApacheNameError));
				
				return results;
			}
			
			return results;
		}
		
		private var _isIncludeApacheNameError:String;
		
		[Inspectable(category="Errors", defaultValue="null")]
		/**
		 *  Error message when the locale is undefined or is not available.
		 *
		 *  @default "Locale is undefined."
		 *  
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 2
		 *  @langversion 3.0
		 *  @productversion Flex 4.5
		 */
		public function get isIncludeApacheNameError():String
		{
			return _isIncludeApacheNameError;
		}
		
		public function set isIncludeApacheNameError(value:String):void
		{
			_isIncludeApacheNameError = value ? value :
				resourceManager.getString("myValidators", "isIncludeApacheNameError");
		}
	}
}