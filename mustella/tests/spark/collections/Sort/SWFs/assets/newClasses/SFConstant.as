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
	import mx.collections.IList;
	import mx.collections.ISortField;
	import mx.collections.XMLListCollection;
	import mx.utils.ObjectUtil;
	
	import spark.collections.SortField;

	public class SFConstant
	{
		public static const pauseTime:int = 100;
		
		public function SFConstant(){}
		
		public static var emptyFunc:Function;
		
		public static var notInstSF:SortField;
		
		public static function errorCompFunc(a:Object):String {
			return 'test';
		}
		
		public static function testArgError(errObj:*,pptName:String,pptValue:*):String
			
		{
			var errorStr:String = "noError";
			try
			{
				errObj[pptName] = pptValue;
			}
			catch(e:Error)
			{
				errorStr = e.toString();
				return errorStr;
			}
			return errorStr;
		}
		
		public static function getArrayOfField(fieldName:String, arrList:IList):Array {
			var arr:Array = null;
			
			if (arrList != null) {
				arr = new Array();
				
				for each (var dataItem:Object in arrList) {
					if (fieldName == null || fieldName.length == 0) {
						arr.push(dataItem);
					} else {
						if (dataItem.hasOwnProperty(fieldName)) {
							arr.push(dataItem[fieldName]);
						} else {
							arr.push(dataItem);
						}
					}
				}
				
				return arr;
			}
			
			return null;
		}
		
		public static function deepCloneAC(orgList:ArrayCollection):ArrayCollection {
			var newList:ArrayCollection = null;
			
			if (orgList != null) {
				newList = new ArrayCollection();
				
				for each (var item:Object in orgList) {
					var newItem:Object = null;
					if (item is ArrayCollection) {
						newItem = deepCloneAC(item as ArrayCollection);
					} else if (item is String) {
						newItem = item;
					} else {
						newItem = ObjectUtil.clone(item);
					}
					
					newList.addItem(newItem);
				}
			}
			
			return newList;
		}
		
		public static function deepCloneXmlC(orgList:XMLListCollection):XMLListCollection {
			var newList:XMLListCollection = null;
			
			if (orgList != null) {
				newList = new XMLListCollection();
				
				for each (var item:Object in orgList) {
					var newItem:Object = null;
					if (item is XMLListCollection) {
						newItem = deepCloneXmlC(item as XMLListCollection);
					} else if (item is String) {
						newItem = item;
					} else {
						newItem = ObjectUtil.clone(item);
					}
					
					newList.addItem(newItem);
				}
			}
			
			return newList;
		}
		
		public static function myUmbraSpecialComp(a:Object, b:Object, arr:Array = null):int {
			if (a != null && b != null) {
				var aStr:String = null;
				var bStr:String = null;
				
				if (arr != null && arr.length == 1) {
					var obj:Object = arr[0];
					
					var fieldStr:String = null;
					
					if (obj is ISortField) {
						var fieldSF:ISortField = obj as ISortField;
						
						fieldStr = fieldSF.name;
					} else {
						fieldStr = obj as String;
					}
					
					aStr = a[fieldStr];
					bStr = b[fieldStr];
				} else {
					aStr = a.toString();
					bStr = b.toString();
				}
				
				if (aStr != null && bStr != null) {
					if (aStr == bStr) {
						return 0;
					}
					
					if (aStr == 'Umbra') {
						return -1;
					} else if (bStr == 'Umbra') {
						return 1;
					} else {
						
						if (aStr < bStr) {
							return -1;
						} else {
							return 1;
						}
					}
				}
			}
			
			return 0;
		}
			
		public static function myMollySpecialComp(a:Object, b:Object, arr:Array = null):int {
			if (a != null && b != null) {
				var aStr:String = null;
				var bStr:String = null;
				
				if (arr != null && arr.length == 1) {
					var obj:Object = arr[0];
					
					var fieldStr:String = null;
					
					if (obj is ISortField) {
						var fieldSF:ISortField = obj as ISortField;
						
						fieldStr = fieldSF.name;
					} else {
						fieldStr = obj as String;
					}
					
					aStr = a[fieldStr];
					bStr = b[fieldStr];
				} else {
					aStr = a.toString();
					bStr = b.toString();
				}
				
				if (aStr != null && bStr != null) {
					if (aStr == bStr) {
						return 0;
					}
					
					if (aStr == 'Molly') {
						return -1;
					} else if (bStr == 'Molly') {
						return 1;
					} else {
						
						if (aStr < bStr) {
							return -1;
						} else {
							return 1;
						}
					}
				}
			}
			
			return 0;
		}
		
		public static function myNumSpecialComp(a:Object, b:Object, arr:Array = null):int {
			if (a != null && b != null) {
				var aStr:String = null;
				var bStr:String = null;
				
				if (arr != null && arr.length == 1) {
					var obj:Object = arr[0];
					
					var fieldStr:String = null;
					
					if (obj is ISortField) {
						var fieldSF:ISortField = obj as ISortField;
						
						fieldStr = fieldSF.name;
					} else {
						fieldStr = obj as String;
					}
					
					aStr = a[fieldStr];
					bStr = b[fieldStr];
				} else {
					aStr = a.toString();
					bStr = b.toString();
				}
				
				if (aStr != null && bStr != null) {
					if (aStr == bStr) {
						return 0;
					}
					
					if (aStr == '20') {
						return -1;
					} else if (bStr == '20') {
						return 1;
					} else {
						
						if (aStr < bStr) {
							return -1;
						} else {
							return 1;
						}
					}
				}
			}
			
			return 0;
		}
		
		public static function myUmbraSpecialCompField(a:Object, b:Object):int {
			if (a != null && b != null) {
				var aStr:String = a['name'];
				var bStr:String = b['name'];
				
				if (aStr != null && bStr != null) {
					if (aStr == bStr) {
						return 0;
					}
					
					if (aStr == 'Umbra') {
						return -1;
					} else if (bStr == 'Umbra') {
						return 1;
					} else {
						
						if (aStr < bStr) {
							return -1;
						} else {
							return 1;
						}
					}
				}
			}
			
			return 0;
		}
		
		public static function myMollySpecialCompField(a:Object, b:Object):int {
			if (a != null && b != null) {
				var aStr:String = a['name'];
				var bStr:String = b['name'];
				
				if (aStr != null && bStr != null) {
					if (aStr == bStr) {
						return 0;
					}
					
					if (aStr == 'Molly') {
						return -1;
					} else if (bStr == 'Molly') {
						return 1;
					} else {
						
						if (aStr < bStr) {
							return -1;
						} else {
							return 1;
						}
					}
				}
			}
			
			return 0;
		}
		
		public static function myNumSpecialCompField(a:Object, b:Object):int {
			if (a != null && b != null) {
				var aStr:String = a['age'];
				var bStr:String = b['age'];
				
				if (aStr != null && bStr != null) {
					if (aStr == bStr) {
						return 0;
					}
					
					if (aStr == '20') {
						return -1;
					} else if (bStr == '20') {
						return 1;
					} else {
						
						if (aStr < bStr) {
							return -1;
						} else {
							return 1;
						}
					}
				}
			}
			
			return 0;
		}
		
		public static function getOption(option:int, expectedOpt:int):int {
			return option & expectedOpt;
		}
			
	}
}