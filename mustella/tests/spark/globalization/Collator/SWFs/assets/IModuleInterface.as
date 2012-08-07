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
package 
{
	import flash.events.IEventDispatcher;
	
	public interface IModuleInterface extends IEventDispatcher
	{
		function get actualLocaleIDName():String
		function get actualLocaleIDNameStyle():String;
		function set locale(newValue:*):void;
		function get ignoreCase():Boolean;
		function set ignoreCase(value:Boolean):void;
		function get ignoreCharacterWidth():Boolean;
		function set ignoreCharacterWidth(value:Boolean):void;
		function get ignoreDiacritics():Boolean;
		function set ignoreDiacritics(value:Boolean):void;
		function get ignoreKanaType():Boolean;
		function set ignoreKanaType(value:Boolean):void;
		function get ignoreSymbols():Boolean;
		function set ignoreSymbols(value:Boolean):void;
		function set numericComparison(value:Boolean):void;
		function get numericComparison():Boolean;
/*		function set initialMode(value:String):void;
		function get initialMode():String;*/
		function get lastOperationStatus():String;
		function compare(str1:String,str2:String):int;
		function equals(str1:String,str2:String):Boolean;
	}
}