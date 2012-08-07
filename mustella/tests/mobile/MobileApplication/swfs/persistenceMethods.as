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
			import mx.events.FlexEvent;
			import components.NamesVector;
			import vo.TestValueObject;
						
			[Bindable]
			public var tvo:TestValueObject = new TestValueObject();
			
			protected function initializeHandler(event:FlexEvent):void
			{
				registerClassAlias("namesVector", components.NamesVector);
			}
			
			//Tests persistenceManager's setProperty by passing different
			//data types to the method
			public function saveData():void
			{
				persistenceManager.setProperty("stringKey", "string value");
				persistenceManager.setProperty("intKey", 999);
				persistenceManager.setProperty("boolKey", true);
				persistenceManager.setProperty("arrayKey", ["apple","orange", "banana"]);
				
				var vector:Vector.<String> = Vector.<String>(["mike","john"]);
				var nv:NamesVector = new NamesVector(vector);
				persistenceManager.setProperty("namesVectorKey", nv);
			}
			
			public function getData():void
			{
				tvo.myString = persistenceManager.getProperty("stringKey") as String;
				tvo.myInt = persistenceManager.getProperty("intKey") as int;
				tvo.myBool = persistenceManager.getProperty("boolKey") as Boolean;
				tvo.myArray = persistenceManager.getProperty("arrayKey") as Array;
				
				tvo.appVersion = persistenceManager.getProperty("versionNumber") as String;
				tvo.ts = persistenceManager.getProperty("timestamp") as Number;
				
				var obj:Object = persistenceManager.getProperty("namesVectorKey");
				tvo.myVector = (obj == null) ? null : NamesVector(obj).names;
			}
			
			public function clearData():void
			{
				persistenceManager.clear();
			}
