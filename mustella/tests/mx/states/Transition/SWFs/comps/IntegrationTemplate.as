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
package comps
{
	import flash.events.Event;
	
	import mx.events.EffectEvent;
	import mx.states.Transition;
	
	import spark.components.Group;
	
	public class IntegrationTemplate extends Group
	{
		
		private var _valueFunction:Function;
		private var _fromValue:Number;
		private var _toValue:Number;
		
		[Bindable]
		public var passed:Boolean = true;
		[Bindable]
		public var error:String = null;
		
		protected var ignoreNext:Boolean = false;
		protected var strict:Boolean = true;
		
		private var _enableCheck:Boolean = false;
		private var checkValue:Number;
		
		public function IntegrationTemplate()
		{
			super();
		}
		
		public function start():void {
			currentState="Two";
		}
		
		public function effectStart(event:EffectEvent):void{
			if(_enableCheck){
				if(!ignoreNext){
					if(strict){
						var next:Number = Math.round(valueFunction.call() as Number);
						
						if(next != _fromValue){
							error = "--->Point is not at start! " + next + " vs. " + _fromValue + ".";
							trace(error);
							passed = false;
						}
					}
				}else{
					ignoreNext = false;
				}
			}
			dispatchEvent(event);
		}
		
		public function effectStop(event:EffectEvent):void{
			dispatchEvent(event);
		}
		
		public function effectUpdate(event:EffectEvent):void{
			if(_enableCheck){
				var next:Number = valueFunction.call() as Number;
				
				//If this value isn't closer to the end than the previous value fail.
				if(Math.abs(_toValue - next) > Math.abs(_toValue - checkValue)){
					error = "--->Point is not closer to end! " + next + " vs. " + checkValue + " (previous).";
					trace(error);
					passed = false;
				}else if(Math.abs(_fromValue - next) < Math.abs(_fromValue - checkValue)){
					error = "--->Point is not further from start! " + next + " vs. " + checkValue + " (previous).";
					trace(error);
					passed = false;
				}
			}
			dispatchEvent(event);
		}
		
		public function effectEnd(event:EffectEvent):void{
			if(_enableCheck){
				if(!ignoreNext){
					var next:Number = Math.round(valueFunction.call() as Number);
					
					if(next != toValue){
						error = "--->Point is not at end! " + next + " vs. " + _toValue + ".";
						trace(error);
						passed = false;
					}
				}else{
					ignoreNext = false;
				}
			}
			dispatchEvent(event);
		}
		
		public function effectRepeat(event:EffectEvent):void{
			dispatchEvent(event);
		}
		
		public function enableCheck():void {
			_enableCheck = true
		}
		
		[Bindable]
		public function get toValue():Number {
			return _toValue;
		}
		
		public function set toValue(value:Number):void {
			_toValue = value;
		}
		
		[Bindable]
		public function get fromValue():Number {
			return _fromValue;
		}
		
		public function set fromValue(value:Number):void {
			_fromValue = value;
		}
		
		protected function get valueFunction():Function
		{
			return _valueFunction;
		}
		
		protected function set valueFunction(value:Function):void
		{
			_valueFunction = value;
		}
	}
}