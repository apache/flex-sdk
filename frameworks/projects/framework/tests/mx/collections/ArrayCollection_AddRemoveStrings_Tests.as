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

    public class ArrayCollection_AddRemoveStrings_Tests
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
			assertEquals(0, _sut.length);
		}
		
		[Test]
		public function addStrings():void
		{
			_sut.addItem("A");
			assertEquals("Length is not one", 1, _sut.length);
			assertEquals("First element not correct", "A", _sut[0]);

			_sut.addItem("B");
			assertEquals("Length is not two", 2, _sut.length);
			assertEquals("Second element not correct", "B", _sut[1]);

			_sut.addItem("D");
			assertEquals("Length is not three", 3, _sut.length);
			assertEquals("Second element not correct", "D", _sut[2]);

			_sut.addItem("C");
			assertEquals("Length is not four", 4, _sut.length);
			assertEquals("Second element not correct", "C", _sut[3]);
		}
		
		[Test]
		public function addDuplicate():void
		{
            //given
			addStrings();

            //when
			_sut.addItem("B");

            //then
			assertEquals("Length is not five", 5, _sut.length);
			assertEquals("First element not correct", "A", _sut[0]);
			assertEquals("Second element not correct", "B", _sut[1]);
			assertEquals("Second element not correct", "D", _sut[2]);
			assertEquals("Second element not correct", "C", _sut[3]);
			assertEquals("Second element not correct", "B", _sut[4]);
		}
		
		[Test]
		public function removeDuplicate():void
		{
            //given
			addStrings();

            //when
			_sut.addItem("B");
			_sut.removeItemAt(1);

            //then
			assertEquals("Length is not four", 4, _sut.length);
			assertEquals("First element not correct",  "A", _sut[0]);
			assertEquals("Second element not correct",  "D", _sut[1]);
			assertEquals("Second element not correct",  "C", _sut[2]);
			assertEquals("Second element not correct",  "B", _sut[3]);
		}
		
		[Test]
		public function removeAllStrings():void
		{
			addStrings();
			_sut.removeAll();
			assertEquals("Length is not zero",  0, _sut.length);
		}
		
		[Test]
		public function removeFirstStrings():void
		{
			addStrings();
			_sut.removeItemAt(0);
			assertEquals("First element not correct",  "B", _sut[0]);
			assertEquals("Length is not three",  3, _sut.length);
			_sut.removeItemAt(0);
			assertEquals("Length is not two",  2, _sut.length);
		}
		
		[Test]
		public function removeLastStrings():void
		{
			addStrings();
			_sut.removeItemAt(1);
			assertEquals("First element not correct",  "A", _sut[0]);
			assertEquals("Length is not three",  3, _sut.length);
			_sut.removeItemAt(0);
			assertEquals("Length is not two",  2, _sut.length);
		}
		
		[Test]
		public function removeItemByIndex():void
		{
			addStrings();
			_sut.removeItemAt(_sut.getItemIndex("B"));
			assertEquals("First element not correct",  "A", _sut[0]);
			assertEquals("Length is not three",  3, _sut.length);
			_sut.removeItemAt(_sut.getItemIndex("D"));
			assertEquals("Length is not two",  2, _sut.length);
		}
		
		[Test]
		public function outOfRange():void
		{
			addStrings();
			try {
				_sut.removeItemAt(-1);
			}
			catch (error:Error)
			{
				assertTrue("Error not range error", error is RangeError);
			}
			assertEquals("Length is not four", 4, _sut.length);
			try {
				_sut.removeItemAt(10);
			}
			catch (error:Error)
			{
				assertTrue("Error not range error", error is RangeError);
			}
			assertEquals("Length is not two", 4, _sut.length);
		}
		
		[Test]
		public function swapItemsTwoThenOne():void
		{
            //given
			addStrings();
			var item1:String = _sut.getItemAt(0) as String;
			var item2:String = _sut.getItemAt(1) as String;

            //when
			_sut.setItemAt(item2, 0);
			_sut.setItemAt(item1, 1);

            //then
			assertEquals("Length is not four",  4, _sut.length);
			assertEquals("First element not correct",  "B", _sut[0]);
			assertEquals("Second element not correct",  "A", _sut[1]);
		}
		
		[Test]
		public function swapItemsOneThenTwo():void
		{
            //given
			addStrings();
			var item1:String = _sut.getItemAt(0) as String;
			var item2:String = _sut.getItemAt(1) as String;

			//when
			_sut.setItemAt(item1, 1);
			_sut.setItemAt(item2, 0);

            //then
			assertEquals("Length is not four", 4, _sut.length);
			assertEquals("First element not correct",  "B", _sut[0]);
			assertEquals("Second element not correct",  "A", _sut[1]);
		}
		
	}
}