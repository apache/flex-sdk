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
	import mx.controls.Alert;
	import mx.controls.TextInput;
	import mx.core.mx_internal;
	import mx.events.ValidationResultEvent;
	import mx.validators.ValidationResult;
	
	import spark.validators.supportClasses.GlobalizationValidatorBase;
	
	use namespace mx_internal;
	
	public class CustValidator extends spark.validators.supportClasses.GlobalizationValidatorBase
	{
		private var results:Array;
		
		public function CustValidator()
		{
			super();
		}

		override mx_internal function createWorkingInstance():void
		{
			
		}
		
/*		public override function validate(value:Object=null, suppressEvents:Boolean=false):ValidationResultEvent
		{
			if (value == null)
				value = getValueFromSource();
			
			var result:ValidationResultEvent;
			
			if(value.toString().length>3)
			{
				result = new ValidationResultEvent(ValidationResultEvent.VALID);

			}
			else
			{
				result = new ValidationResultEvent(ValidationResultEvent.INVALID);

			}
			
			dispatchEvent(result);
			return result;
				
		}*/
		
		override protected function doValidation(value:Object):Array
		{
			results = [];
			var inputValue:String=String(value);
			results = super.doValidation(value);
			
			if(results.length>0)
				return results;
			
			if(inputValue.length>3)
			{
				results.push(new ValidationResult(true,null,"length","the length is too long"));
				return results;
			}
			
			return results;
		}
	}
}