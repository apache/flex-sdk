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
import flash.net.URLRequest;
import flash.utils.Timer;

import org.apache.flex.promises.Promise;
import org.apache.flex.promises.interfaces.IThenable;
import org.flexunit.asserts.assertEquals;
import org.flexunit.async.Async;

public class PromisesJIRATests
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
	//    verifyGotType_
	//----------------------------------
	
	private function verifyGotType_(event:TimerEvent, result:*):void {
		assertEquals(this.expected_, this.got_.toString());
	}
	

	
	//--------------------------------------------------------------------------
	//
	//    Tests
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//    test_FLEX34753
	//----------------------------------
	
	[Test(async)]
	public function test_FLEX34753():void
	{
		Async.handleEvent(this, timer_, TimerEvent.TIMER_COMPLETE, verifyGotType_);
		
		timer_.start();
		
		promise_ = new Promise(function (fulfill:Function = null, reject:Function = null):*
		{
			var urlRequest:URLRequest = new URLRequest('http://flex.apache.org');
			
			fulfill(urlRequest);
		});
		
		expected_ = '[object URLRequest]';
		
		promise_.then(parseGot_);
	}
	
}}