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
package components
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	
	public class NamesVector implements IExternalizable
	{
		private var _names:Vector.<String>;
		
		public function NamesVector(v:Vector.<String>=null)
		{
			if (v)
			{
				_names = Vector.<String>(v);	
			} else {
				_names = new Vector.<String>();
			}
			
		}
		
		public function get names():Vector.<String>
		{
			return _names;
		}
		
		public function addName(aName:String):void
		{
			_names.push(aName);
		}
		
		public function writeExternal(output:IDataOutput):void
		{
			output.writeObject(_names);
		}
		
		public function readExternal(input:IDataInput):void
		{
			_names = Vector.<String> (input.readObject());
		}
	}
}