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

package promises.cases
{

import flash.events.TimerEvent;
import flash.utils.Timer;
import flash.utils.setTimeout;

import flexunit.framework.Assert;

import org.apache.flex.promises.Promise;
import org.apache.flex.promises.interfaces.IThenable;
import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertNotNull;
import org.flexunit.asserts.assertTrue;
import org.flexunit.async.Async;

public class PromisesBasicTests
{

	//--------------------------------------------------------------------------
	//
	//    Variables
	//
	//--------------------------------------------------------------------------
	
	private var expected_:*;
	
	private var promise_:IThenable;
	
	private var got_:*;
	
	private var timer_:Timer;
	
	
	
	//--------------------------------------------------------------------------
	//
	//    Methods
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//    parseErrorGot_
	//----------------------------------
	
	private function parseErrorGot_(value:*):void {
		this.got_ = Error(value).message;
	}
	
	//----------------------------------
	//    parseGot_
	//----------------------------------
	
	private function parseGot_(value:*):void {
		this.got_ = value;
	}
	
	//----------------------------------
	//    setUp
	//----------------------------------
	
	[Before(async)]
	public function setUp():void
	{
		this.timer_ = new Timer(100, 1);
	}
	
	//----------------------------------
	//    tearDown
	//----------------------------------
	
	[After(async)]
	public function tearDown():void
	{
		this.promise_ = null;
		
		if (this.timer_)
		{
			this.timer_.stop();
			this.timer_ = null;
		}
	}
	
	//----------------------------------
	//    verifyGot_
	//----------------------------------
	
	private function verifyGot_(event:TimerEvent, result:*):void {
		assertEquals(this.expected_, this.got_);
	}
	

	
	//--------------------------------------------------------------------------
	//
	//    Tests
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//    test_Create
	//----------------------------------
	
	[Test]
	public function test_Create():void
	{
		promise_ = new Promise(null);
		
		Assert.assertNotUndefined(promise_);
		
		assertNotNull(promise_);
		
		assertTrue(promise_ is IThenable);
		assertTrue(promise_ is Promise);
	}
	
	//----------------------------------
	//    test_SimpleSyncThen_FulFill
	//----------------------------------
	
	[Test(async)]
	public function test_SimpleSyncThen_FulFill():void
	{
		Async.handleEvent(this, timer_, TimerEvent.TIMER_COMPLETE, verifyGot_);
		
		timer_.start();
		
		promise_ = new Promise(function (fulfill:Function = null, reject:Function = null):*
		{
			fulfill('Hello world');
		});
		
		expected_ = 'Hello world';
		promise_.then(parseGot_);
	}
	
	//----------------------------------
	//    test_SimpleSyncThen_Reject
	//----------------------------------
	
	[Test(async)]
	public function test_SimpleSyncThen_Reject():void
	{
		Async.handleEvent(this, timer_, TimerEvent.TIMER_COMPLETE, verifyGot_);
		
		timer_.start();
		
		promise_ = new Promise(function (fulfill:Function = null, reject:Function = null):*
		{
			reject(new Error('reject'));
		});
		
		expected_ = 'Error: reject';
		promise_.then(null, parseErrorGot_);
	}
	
	//----------------------------------
	//    test_SimpleASyncThen_FulFill
	//----------------------------------
	
	[Test(async)]
	public function test_SimpleASyncThen_FulFill():void
	{
		Async.handleEvent(this, timer_, TimerEvent.TIMER_COMPLETE, verifyGot_);
		
		timer_.start();
		
		this.promise_ = new Promise(function (fulfill:Function = null, 
											  reject:Function = null):*
		{
			setTimeout(function ():void { fulfill('Hello world'); }, 10);
		});
		
		expected_ = 'Hello world';
		promise_.then(parseGot_);
	}
	
	//----------------------------------
	//    test_SimpleASyncThen_Reject
	//----------------------------------
	
	[Test(async)]
	public function test_SimpleASyncThen_Reject():void
	{
		Async.handleEvent(this, timer_, TimerEvent.TIMER_COMPLETE, verifyGot_);
		
		timer_.start();
		
		this.promise_ = new Promise(function (fulfill:Function = null, 
											  reject:Function = null):*
		{
			setTimeout(function ():void { reject(new Error('reject')); }, 10);
		});
		
		expected_ = 'Error: reject';
		promise_.then(null, parseErrorGot_);
	}
	
	
	//----------------------------------
	//    test_MultipleASyncThen_FulFill
	//----------------------------------
	
	[Test(async)]
	public function test_MultipleASyncThen_FulFill():void
	{
		Async.handleEvent(this, timer_, TimerEvent.TIMER_COMPLETE, verifyGot_);
		
		timer_.start();
		
		var anotherStep:Function = function (value:*):IThenable
		{
			return new Promise(function (fulfill:Function = null, 
										 reject:Function = null):*
			{
				setTimeout(function ():void { 
					fulfill(value + ' ... again'); 
				}, 10);
			});
		}
		
		promise_ = new Promise(function (fulfill:Function = null, 
										 reject:Function = null):*
		{
			setTimeout(function ():void { 
				fulfill('Hello world'); 
			}, 10);
		});
		
		expected_ = 'Hello world ... again';
		promise_.then(anotherStep).then(parseGot_);
	}
	
	//----------------------------------
	//    test_MultipleASyncThen_RejectLast
	//----------------------------------
	
	[Test(async)]
	public function test_MultipleASyncThen_RejectLast():void
	{
		Async.handleEvent(this, timer_, TimerEvent.TIMER_COMPLETE, verifyGot_);
		
		timer_.start();
		
		var anotherStep:Function = function (value:*):IThenable
		{
			return new Promise(function (fulfill:Function = null, 
										 reject:Function = null):*
			{
				setTimeout(function ():void { 
					reject(new Error('reject')); 
				}, 10);
			});
		}
		
		promise_ = new Promise(function (fulfill:Function = null, 
										 reject:Function = null):*
		{
			setTimeout(function ():void { 
				fulfill('Hello world'); 
			}, 10);
		});
		
		expected_ = 'Error: reject';
		promise_.then(anotherStep).then(null, parseErrorGot_);
	}
	
	//----------------------------------
	//    test_MultipleASyncThen_RejectFirst
	//----------------------------------
	
	[Test(async)]
	public function test_MultipleASyncThen_Reject():void
	{
		Async.handleEvent(this, timer_, TimerEvent.TIMER_COMPLETE, verifyGot_);
		
		timer_.start();
		
		var anotherStep:Function = function (value:*):IThenable
		{
			return new Promise(function (fulfill:Function = null, 
										 reject:Function = null):*
			{
				setTimeout(function ():void { 
					fulfill(value + ' ... again'); 
				}, 10);
			});
		}
		
		promise_ = new Promise(function (fulfill:Function = null, 
										 reject:Function = null):*
		{
			setTimeout(function ():void { 
				reject(new Error('reject')); 
			}, 10);
		});
		
		expected_ = 'Error: reject';
		promise_.then(anotherStep).then(null, parseErrorGot_);
	}
	
}}