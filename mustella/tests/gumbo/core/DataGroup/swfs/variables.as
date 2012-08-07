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
[Bindable]
[Embed(source="../../../../../Assets/Images/GridImages/1_r1_c1.png")]
public var graphic11:Class;

[Bindable]
[Embed(source="../../../../../Assets/Images/GridImages/1_r1_c2.png")]
public var graphic12:Class;

[Bindable]
[Embed(source="../../../../../Assets/Images/GridImages/1_r1_c3.png")]
public var graphic13:Class;

[Bindable]
[Embed(source="../../../../../Assets/Images/GridImages/1_r1_c4.png")]
public var graphic14:Class;

[Bindable]
public var graphicObject:Object={label:"1", data:graphic11};

[Bindable]
public var smallGraphicArray:Object=[{label:"1", data:graphic11},
			{label:"2", data:graphic12},
			{label:"3", data:graphic13},
			{label:"4", data:graphic14}];

[Bindable]
public var dataArray:Object=["10","20","30","40"];

[Bindable]
public var graphicArray:Object=[{label:"1", data:graphic11},
			{label:"2", data:graphic12},
			{label:"3", data:graphic13},
			{label:"4", data:graphic14}];
