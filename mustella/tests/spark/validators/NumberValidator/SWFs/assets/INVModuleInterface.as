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
	import flash.events.IEventDispatcher;
	import flash.globalization.NumberParseResult;
	
	public interface INVModuleInterface extends IEventDispatcher
	{
		function get actualLocaleIDName():String
		function set locale(value:String):void
		function get allowNegative():Boolean
		function set allowNegative(value:Boolean):void
		function get decimalSeparator():String
		function set decimalSeparator(value:String):void
		function get domain():String
		function set domain(value:String):void
		function get fractionalDigits():int
		function set fractionalDigits(value:int):void
		function get digitsType():uint
		function set digitsType(value:uint):void
		function get groupingSeparator():String
		function set groupingSeparator(value:String):void
		function get maxValue():Number
		function set maxValue(value:Number):void
		function get minValue():Number
		function set minValue(value:Number):void
		function get negativeNumberFormat():uint
		function set negativeNumberFormat(value:uint):void
		function get negativeSymbol():String
		function get decimalPointCountError():String
		function set decimalPointCountError(value:String):void
		function get greaterThanMaxError():String
		function set greaterThanMaxError(value:String):void
		function get fractionalDigitsError():String
		function set fractionalDigitsError(value:String):void
		function get notAnIntegerError():String
		function set notAnIntegerError(value:String):void
		function get invalidCharError():String
		function set invalidCharError(value:String):void
		function get invalidFormatCharsError():String
		function set invalidFormatCharsError(value:String):void
		function get lessThanMinError():String
		function set lessThanMinError(value:String):void
		function get negativeError():String
		function set negativeError(value:String):void
		function get negativeSymbolError():String
		function set negativeSymbolError(value:String):void
		function get negativeNumberFormatError():String
		function set negativeNumberFormatError(value:String):void
		function get parseError():String
		function set parseError(value:String):void
		function get localeUndefinedError():String
		function set localeUndefinedError(value:String):void
		function get lastOperationStatus():String
		function set source(value:Object):void
		function set property(value:String):void
		function set trigger(value:IEventDispatcher):void
		function set triggerEvent(value:String):void
	}
}