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
package data {

    public class MenuDataASp  {
    
        public var myData:Object;
        public function MenuDataASp(): void
        {
            myData = [
						{label:"Toys", icon:"purplerect", icon2: "orangerect", children: [
						    { label:"Stuffed Animals", children: [
						        {label:"Stuffed Bears"},
							    {label:"Dinosaur", icon: "purplerect"}
						    ]},
						    {label:"Cars", children: [
						        {label:"RaceCar01"},
						    	{label:"RaceCar02"}
						    ]}
						]},
						{label:"Games", icon:"t1120", children:	[
						    { label:"Age 6 and up", children: [
						        {label:"Board Games"},
						        {label:"UpWords"},
						        {label:"WhiteSquares" }
						    ]},
						    {label:"Video Games", children:	[
						        {label:"ActionFigure"},
						        {label:"VideoGame"}
						    ]}
					    ]}
	 ];
        }
    }
}