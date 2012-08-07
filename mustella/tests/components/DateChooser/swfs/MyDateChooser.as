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
package {

    import mx.controls.DateChooser;
    
    public class MyDateChooser extends DateChooser
    {
        private static var myNextMonthStyleFilters:Object = 
	   	{
	   	   	 "highlightAlphas" : "highlightAlphas",
	   	   	 "nextMonthUpSkin" : "nextMonthUpSkin",
	   	   	 "nextMonthOverSkin" : "nextMonthOverSkin",
	   	   	 "nextMonthDownSkin" : "nextMonthDownSkin",
	   	   	 "nextMonthDisabledSkin" : "nextMonthDisabledSkin",
	   	   	 "nextMonthSkin" : "nextMonthSkin",
	   	   	 "repeatDelay" : "repeatDelay",
	   	   	 "repeatInterval" : "repeatInterval",
	   	   	 "fillColors" : "fillColors"
	    } 
        
       override protected function get nextMonthStyleFilters():Object
	   {
	       	return myNextMonthStyleFilters;
	   }
	       
       private static var myPrevMonthStyleFilters:Object = 
	   	   {
	   	   		"highlightAlphas" : "highlightAlphas",
	   	       	"prevMonthUpSkin" : "prevMonthUpSkin",
	   	       	"prevMonthOverSkin" : "prevMonthOverSkin",
	   	       	"prevMonthDownSkin" : "prevMonthDownSkin",
	   	       	"prevMonthDisabledSkin" : "prevMonthDisabledSkin",
	   	       	"prevMonthSkin" : "prevMonthSkin",
	   	       	"repeatDelay" : "repeatDelay",
	   	   		"repeatInterval" : "repeatInterval",
	   	   		"cornerRadius" : "cornerRadius"
	           } 
	           
	           override protected function get prevMonthStyleFilters():Object
	   	    {
	   	       	return myPrevMonthStyleFilters;
	   	    }
	       
    }
}