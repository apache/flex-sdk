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
﻿package data {
	   public class ListDataAS  {
    
        public var myData:Object;
		public function ListDataAS(): void
        {
			  myData = [
						{label:"Toys", quantity: 0, color: "Red"}, 
						{label:"Stuffed Animals", quantity: 0, color: "Red"}, 
						{label:"Grizzly Bears", quantity: 2, color: "Green"}, 
						{label:"Dinosaurs", quantity: 8, color: "Fuscia"}, 
						{label:"Cars", quantity: 9, color: "Yellow"}, 
						{label:"Games", quantity: 0, color: "Black"}, 
						{label:"Board Games", quantity: 0, color: "Black"}, 
						{label:"Checkers", quantity: 4, color: "White"}, 
						{label:"Action Figure", quantity: 0, color: "Rose"}, 
						{label:"Video Game", quantity: 8, color: "Periwinkle"}, 
					  ]; 
        }
	}
}