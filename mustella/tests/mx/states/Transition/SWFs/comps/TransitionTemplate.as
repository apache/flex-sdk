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
	import comps.modules.Monitor;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.events.EffectEvent;
	import mx.states.Transition;
	
	import spark.components.Group;
	
	public class TransitionTemplate extends Group
	{
		private var _monitor:Monitor;
		private var _valueFunction:Function;
		private var _initTransTime:Number;
		private var _returnTransTime:Number;
		private var _interruptTime:Number;
		private var _initTrans:Transition;
		private var _returnTrans:Transition;
		private var _autoreverse:Boolean = true;
		private var _endsPerPath:int = 1;
		private var numEnds:int = 0;
		
		private var interruptTimer:Timer;
		
		public function TransitionTemplate()
		{
			super();
		}

		[Bindable]
		public function get monitor():Monitor
		{
			return _monitor;
		}
		
		public function set monitor(value:Monitor):void
		{
			_monitor = value;
			_monitor.valueFunction = getValue;
			_monitor.target = this;
			dispatchEvent(new Event("monitorRegistered"));
		}

		public function interrupt(event:TimerEvent):void{
			currentState="One";
		}
		
		public function start():void {
			if(isNaN(initTransTime)){
				initTrans.effect.duration=1000;
			}else{
				initTrans.effect.duration=initTransTime;
			}
			initTrans.autoReverse = _autoreverse;
			
			this.transitions.push(initTrans);
			
			if(!isNaN(returnTransTime)){
				returnTrans.effect.duration=returnTransTime;
				returnTrans.autoReverse = _autoreverse;
				this.transitions.push(returnTrans);
			}
			currentState="Two";
		}
		
		public function effectStart(event:EffectEvent):void{
			_monitor.effectStart(event);
			if(isNaN(_interruptTime)) _interruptTime=1100;
			interruptTimer = new Timer(_interruptTime,1);
			interruptTimer.addEventListener(TimerEvent.TIMER,interrupt);
			interruptTimer.start();
			dispatchEvent(event);
		}
		
		public function effectStop(event:EffectEvent):void{
			_monitor.effectStop(event);
			dispatchEvent(event);
		}
		
		public function effectUpdate(event:EffectEvent):void{
			_monitor.effectUpdate(event);
			dispatchEvent(event);
		}
		
		public function effectEnd(event:EffectEvent):void{
			_monitor.effectEnd(event);
			numEnds++;
			if(numEnds == _endsPerPath) _monitor.isReturn = true;
			dispatchEvent(event);
		}
		
		public function effectRepeat(event:EffectEvent):void{
			_monitor.effectRepeat(event);
			dispatchEvent(event);
		}
		
		public function check():void{_monitor.check();}

		public function getValue():Number {
			return _valueFunction.call();
		}
		
		protected function get valueFunction():Function
		{
			return _valueFunction;
		}

		protected function set valueFunction(value:Function):void
		{
			_valueFunction = value;
		}

		[Bindable]
		public function get interruptTime():Number
		{
			return _interruptTime;
		}

		public function set interruptTime(value:Number):void
		{
			_interruptTime = value;
		}

		[Bindable]
		public function get initTransTime():Number
		{
			return _initTransTime;
		}

		public function set initTransTime(value:Number):void
		{
			_initTransTime = value;
		}

		[Bindable]
		public function get returnTransTime():Number
		{
			return _returnTransTime;
		}

		public function set returnTransTime(value:Number):void
		{
			_returnTransTime = value;
		}

		[Bindable]
		public function get initTrans():Transition
		{
			return _initTrans;
		}

		public function set initTrans(value:Transition):void
		{
			_initTrans = value;
		}

		[Bindable]
		public function get returnTrans():Transition
		{
			return _returnTrans;
		}

		public function set returnTrans(value:Transition):void
		{
			_returnTrans = value;
		}

		[Bindable]
		public function get autoreverse():Boolean
		{
			return _autoreverse;
		}

		public function set autoreverse(value:Boolean):void
		{
			_autoreverse = value;
		}

		public function get endsPerPath():int
		{
			return _endsPerPath;
		}

		public function set endsPerPath(value:int):void
		{
			_endsPerPath = value;
		}


	}
}