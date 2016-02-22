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
package mx.collections {
    import org.flexunit.asserts.*;

    public class ArrayCollection_AddRemoveNumbers_Tests
	{	
		protected var _sut:ArrayCollection;
		
		[Before]
		public function setUp():void
		{
			_sut = new ArrayCollection();
		}
		
		[After]
		public function tearDown():void
		{
			_sut = null;
		}
		
		[Test]
		public function empty():void
		{
			//then
			assertEquals(_sut.length, 0);
		}
		
		[Test]
		public function addNumbers():void
		{
			_sut.addItem(1);
			assertEquals("Length is not one",  1, _sut.length);
			assertEquals("First element not correct",  1, _sut[0]);
			_sut.addItem(2);
			assertEquals("Length is not two",  2, _sut.length);
			assertEquals("Second element not correct",  2, _sut[1]);
		}
		
		[Test]
		public function addDuplicate():void
		{
			addNumbers();
			_sut.addItem(1);
			assertEquals("Length is not three",  3, _sut.length);
			assertEquals("First element not correct",  1, _sut[0]);
			assertEquals("Second element not correct",  2, _sut[1]);
			assertEquals("Second element not correct",  1, _sut[2]);
		}
		
		[Test]
		public function removeDuplicate():void
		{
			addNumbers();
			_sut.addItem(1);
			_sut.removeItemAt(0);
			assertEquals("Length is not two",  2, _sut.length);
			assertEquals("First element not correct",  2, _sut[0]);
			assertEquals("Second element not correct",  1, _sut[1]);
		}
		
		[Test]
		public function removeAllNumbers():void
		{
			addNumbers();
			_sut.removeAll();
			assertEquals("Length is not zero",  0, _sut.length);
		}
		
		[Test]
		public function removeFirstNumbers():void
		{
			addNumbers();
			_sut.removeItemAt(0);
			assertEquals("First element not correct",  2, _sut[0]);
			assertEquals("Length is not one",  1, _sut.length);
			_sut.removeItemAt(0);
			assertEquals("Length is not zero",  0, _sut.length);
		}
		
		[Test]
		public function removeLastNumbers():void
		{
			addNumbers();
			_sut.removeItemAt(1);
			assertEquals("First element not correct",  1, _sut[0]);
			assertEquals("Length is not one",  1, _sut.length);
			_sut.removeItemAt(0);
			assertEquals("Length is not zero",  0, _sut.length);
		}
		
		[Test]
		public function removeItemByIndex():void
		{
			addNumbers();
			_sut.removeItemAt(_sut.getItemIndex(1));
			assertEquals("First element not correct",  2, _sut[0]);
			assertEquals("Length is not one",  1, _sut.length);
			_sut.removeItemAt(_sut.getItemIndex(2));
			assertEquals("Length is not zero",  0, _sut.length);
		}
		
		[Test]
		public function outOfRange():void
		{
			addNumbers();
			try {
				_sut.removeItemAt(-1);
			}
			catch (error:Error)
			{
				assertTrue("Error not range error", error is RangeError);
			}
			assertEquals("Length is not two",  2, _sut.length);
			try {
				_sut.removeItemAt(10);
			}
			catch (error:Error)
			{
				assertTrue("Error not range error", error is RangeError);
			}
			assertEquals("Length is not two",  2, _sut.length);
		}
		
		[Test]
		public function swapItemsTwoThenOne():void
		{
			addNumbers();
			
			var item1:Number = _sut.getItemAt(0) as Number;
			var item2:Number = _sut.getItemAt(1) as Number;
			
			_sut.setItemAt(item2,0);
			_sut.setItemAt(item1,1);
			
			assertEquals("Length is not two",  2, _sut.length);
			assertEquals("First element not correct",  2, _sut[0]);
			assertEquals("Second element not correct",  1, _sut[1]);
		}
		
		[Test]
		public function swapItemsOneThenTwo():void
		{
			addNumbers();

			var item1:Number = _sut.getItemAt(0) as Number;
			var item2:Number = _sut.getItemAt(1) as Number;
			
			_sut.setItemAt(item1,1);
			_sut.setItemAt(item2,0);
			
			assertEquals("Length is not two",  2, _sut.length);
			assertEquals("First element not correct",  2, _sut[0]);
			assertEquals("Second element not correct",  1, _sut[1]);
		}
		
	}
}