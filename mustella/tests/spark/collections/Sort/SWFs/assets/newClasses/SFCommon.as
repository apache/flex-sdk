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
package assets.newClasses
{
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList ;
	import mx.collections.IList;
	import mx.collections.ISortField;
	import mx.utils.ObjectUtil;

	public class SFCommon
	{

		public static function getSorttedStringFromCollection( arrlist:mx.collections.IList, 
														fieldName1:String , fieldName2:String , 
														fieldName3:String,fieldName4:String):String {
			var sorttedStr:String =""; 
			var i:int = 0 ; 
			
			if ( arrlist == null )  return null ;
			
			if ( arrlist is ArrayList ) 
			{
				var arrl:ArrayList = arrlist as ArrayList ; 
				var arr:Array = arrl.source ; 
				for ( i = 0 ; i < arr.length ; i++ ) 
				{
					sorttedStr = sorttedStr + arr[i] + "*" ; 
				}
				return sorttedStr ;
			}
			
			for each (var item:Object in arrlist) {
				if ( fieldName1 == null || fieldName1.length == 0 ) 
				{
					sorttedStr = sorttedStr + item.toString() + "\n" ;
					continue ; 
				}else if ( fieldName2 == null && fieldName1 != null ) {
					if ( item.hasOwnProperty(fieldName1) ) 
						sorttedStr = sorttedStr + item[fieldName1] + "\n" ; 
					else 
						sorttedStr = sorttedStr + item.toString() + "\n" ;
					continue ;
				}else if ( fieldName3 == null && fieldName2 != null && fieldName1 != null ) {
					if ( item.hasOwnProperty(fieldName1) && item.hasOwnProperty(fieldName2)  )
					{
						sorttedStr = sorttedStr + fieldName1 + ": "+ item[fieldName1] + ", ";
						sorttedStr = sorttedStr + fieldName2 + ": "+ item[fieldName2] + "\n" ;
					}
					else 
						sorttedStr = sorttedStr + item.toString() + "\n" ;
					
					continue ;
					
				}else if ( fieldName4 == null && fieldName3 != null && fieldName2 != null ){
					if ( item.hasOwnProperty(fieldName1) && item.hasOwnProperty(fieldName2) && item.hasOwnProperty(fieldName3) )
					{
						sorttedStr = sorttedStr + fieldName1 + ": "+ item[fieldName1] + ", ";
						sorttedStr = sorttedStr + fieldName2 + ": "+ item[fieldName2] + ", ";
						sorttedStr = sorttedStr + fieldName3 + ": "+ item[fieldName3] + "\n" ;
					}
					else 
						sorttedStr = sorttedStr + item.toString() + "\n" ;
					
					continue ;
					
				}else if ( fieldName4 != null && fieldName3 != null ) {
					if ( item.hasOwnProperty(fieldName1) && item.hasOwnProperty(fieldName2) && item.hasOwnProperty(fieldName3) && item.hasOwnProperty(fieldName4))
					{
						sorttedStr = sorttedStr + fieldName1 + ": "+ item[fieldName1] + ", ";
						sorttedStr = sorttedStr + fieldName2 + ": "+ item[fieldName2] + ", ";
						sorttedStr = sorttedStr + fieldName3 + ": "+ item[fieldName3] + ", ";
						sorttedStr = sorttedStr + fieldName4 + ": "+ item[fieldName4] + "\n" ;
					}
					else 
						sorttedStr = sorttedStr + item.toString() + "\n" ;
					
					continue ; 
				}else {
					sorttedStr = sorttedStr + item.toString() + "\n" ;
				}
			} // end of for each 
			
			return sorttedStr ; 
		}
			
	}
}