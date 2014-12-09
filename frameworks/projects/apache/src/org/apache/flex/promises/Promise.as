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

package org.apache.flex.promises
{

import flash.events.TimerEvent;
import flash.utils.Timer;

import org.apache.flex.promises.enums.PromiseState;
import org.apache.flex.promises.interfaces.IPromise;
import org.apache.flex.promises.vo.Handler;

public class Promise implements IPromise
{


	//--------------------------------------------------------------------------
	//
	//    Constructor
	//
	//--------------------------------------------------------------------------
	
	public function Promise(resolver:Function) {
		this.handlers_ = new Vector.<Handler>();
		
		this.state_ = PromiseState.PENDING;
		
		this.doResolve_(resolver, this.resolve_, this.reject_);
	}



	//--------------------------------------------------------------------------
	//
	//    Variables
	//
	//--------------------------------------------------------------------------
	
	private var handlers_:Vector.<Handler>;
	
	private var state_:PromiseState;
	
	private var value_:*;
	
	
	
	//--------------------------------------------------------------------------
	//
	//    Methods
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//    done
	//----------------------------------
	
	public function done(onFulfilled:Function = null, onRejected:Function = null):void
	{
		//var self:Promise = this;
		
		//var timer:Timer = new Timer(0, 1);
		//timer.addEventListener(TimerEvent.TIMER, function ():void {
			this.handle_(new Handler(onFulfilled, onRejected));
		//});
		//timer.start();
	}
	
	//----------------------------------
	//    doResolve_
	//----------------------------------
	
	private function doResolve_(fn:Function, onFulfilled:Function, onRejected:Function):void
	{
		var done:Boolean = false;
		
		try
		{
			fn(function (value:*):void {
				if (done)
				{
					return;
				}
				
				done = true;
				
				onFulfilled(value);
			}, function (reason:*):void {
				if (done)
				{
					return;
				}
				
				done = true;
				
				onRejected(reason);
			});
		}
		catch (e:Error)
		{
			if (done)
			{
				return;
			}
			
			done = true;
			
			onRejected(e);
		}
	}
	
	//----------------------------------
	//    getThen_
	//----------------------------------
	
	private function getThen_(value:*):Function
	{
		var type:String = typeof value;
		
		if (value && (value === 'object' || value === 'function'))
		{
			var then:* = value.then;
			
			if (then is Function)
			{
				return then;
			}
		}
		
		return null;
	}
	
	//----------------------------------
	//    fulfill_
	//----------------------------------
	
	private function fulfill_(result:*):void
	{
		this.state_ = PromiseState.FULFILLED;
		
		this.value_ = result;
		
		this.handlers_.forEach(this.handle_);
		
		this.handlers_ = null;
	}
	
	//----------------------------------
	//    handle_
	//----------------------------------
	
	private function handle_(handler:Object, ...rest):void
	{
		if (this.state_ === PromiseState.PENDING)
		{
			trace(this.state_);
			this.handlers_.push(handler);
		}
		else
		{
			if (this.state_ === PromiseState.FULFILLED && handler.onFulfilled != null)
			{
				handler.onFulfilled(this.value_);
			}
			
			if (this.state_ === PromiseState.REJECTED && handler.onRejected != null)
			{
				handler.onRejected(this.value_);
			}
		}
	}
	
	//----------------------------------
	//    reject_
	//----------------------------------
	
	private function reject_(error:*):void
	{
		this.state_ = PromiseState.REJECTED;
		
		this.value_ = error;
		
		this.handlers_.forEach(this.handle_);
		
		this.handlers_ = null;
	}
	
	//----------------------------------
	//    resolve_
	//----------------------------------
	
	private function resolve_(result:*):void
	{
		try 
		{
			var then:Function = this.getThen_(result);
			
			if (then != null) {
				this.doResolve_(then, this.resolve_, this.reject_);
				
				return;
			}
			
			this.fulfill_(result);
		}
		catch (e:Error)
		{
			this.reject_(e);
		}
	}

	//----------------------------------
	//    then
	//----------------------------------

	public function then(onFulfilled:Function = null, 
						 onRejected:Function = null):IPromise
	{
		var self:IPromise = this;
		
		var resolver:Function = function (resolve:Function, reject:Function):* {
			return self.done(function (result:*):* {
				if (onFulfilled is Function)
				{
					try
					{
						return resolve(onFulfilled(result));
					}
					catch (e:Error)
					{
						return reject(e);
					}
				}
				else
				{
					return resolve(result);
				}
			}, function (error:*):* {
				if (onRejected is Function)
				{
					try
					{
						return resolve(onRejected(error));
					}
					catch (e:Error)
					{
						return reject(e);
					}
				}
				else
				{
					return reject(error);
				}
			});
		};
		
		return new Promise(resolver);
	}

}
}