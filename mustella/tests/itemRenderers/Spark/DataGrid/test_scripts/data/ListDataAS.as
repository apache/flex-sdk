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

    public class ListDataAS  {
    
        public var myData:Object;
        public function ListDataAS(): void
        {
            var date1:Date = new Date(2007,4,20);
            var date2:Date = new Date(2007,0,15);
            var date3:Date = new Date(2007,9,24); 
            
            myData = [
                        {label:"Toys", available:false, quantity: 0, shipDate: date1, url: "../../../../../Assets/Images/redrect.jpg", color: "Red"}, 
                        {label:"Stuffed Animals", available:false, quantity: 0, shipDate: date1, url: "../../../../../Assets/Images/redrect.jpg", color: "Red"}, 
                        {label:"Some Bears", available:true, quantity: 2, shipDate: date2, url: "../../../../../Assets/Images/greenrect.jpg", color: "Green"}, 
                        {label:"Dinosaur", available:true, quantity: 8, shipDate: date1, url: "../../../../../Assets/Images/purplerect.jpg", color: "Fuscia"}, 
                        {label:"Cars", available:true, quantity: 9, shipDate: date1, url: "../../../../../Assets/Images/yellowrect.jpg", color: "Yellow"}, 
                        {label:"Games", available:false, quantity: 0, shipDate: date2, url: "../../../../../Assets/Images/bluerect.jpg", color: "Black"}, 
                        {label:"Board Games", available:false, quantity: 0, shipDate: date3, url: "../../../../../Assets/Images/bluerect.jpg", color: "Black"}, 
                        {label:"Dice Game", available:true, quantity: 4, shipDate: date3, url: "../../../../../Assets/Images/orangerect.jpg", color: "White"}, 
                        {label:"Movie", available:false, quantity: 0, shipDate: date1, url: "../../../../../Assets/Images/redrect.jpg", color: "Rose"}, 
                        {label:"Video Game",available:true, quantity: 8, shipDate: date3, url: "../../../../../Assets/Images/purplerect.jpg", color: "Periwinkle"}, 
                      ]; 
        }
    }
}