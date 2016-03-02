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

    public class ArrayCollection_FilterNumbers_Tests
	{
        private var _sut:ArrayCollection;
		
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
		
		protected function addNumbers():void
		{
			_sut.addItem(1);
			_sut.addItem(2);
		}

		private static function allIn(object:Object):Boolean
		{
			return true;
		}

		private static function allOut(object:Object):Boolean
		{
			return false;
		}

		private static function isOne(object:Object):Boolean
		{
			return object == 1;
		}
		
		[Test]
		public function nullFilter():void
		{
			addNumbers();
			_sut.filterFunction = null;
			_sut.refresh();
			
			assertEquals("Length is not two",  2, _sut.length);
			assertEquals("First element not correct",  1, _sut[0]);
			assertEquals("Second element not correct",  2, _sut[1]);
		}	
		
		[Test]
		public function trueFilter():void
		{
			addNumbers();
			_sut.filterFunction = allIn;
			_sut.refresh();
			
			assertEquals("Length is not two",  2, _sut.length);
			assertEquals("First element not correct",  1, _sut[0]);
			assertEquals("Second element not correct",  2, _sut[1]);
		}
		
		[Test]
		public function falseFilter():void
		{
			addNumbers();
			_sut.filterFunction = allOut;
			_sut.refresh();
			
			assertEquals("Length is not two",  0, _sut.length);
		}
		
		
		[Test]
		public function filterNoRefresh():void
		{
			addNumbers();
			_sut.filterFunction = allOut;
			
			// Filter should not take effect
			assertEquals("Length is not two",  2, _sut.length);
			assertEquals("First element not correct",  1, _sut[0]);
			assertEquals("Second element not correct",  2, _sut[1]);
		}
		
		[Test]
		public function nullFilterNoRefresh():void
		{
			addNumbers();
			_sut.filterFunction = null;
			
			// Filter should not take effect
			assertEquals("Length is not two",  2, _sut.length);
			assertEquals("First element not correct",  1, _sut[0]);
			assertEquals("Second element not correct",  2, _sut[1]);
		}
		
		[Test]
		public function filterDoubleRefresh():void
		{
			addNumbers();
			_sut.filterFunction = allOut;
			_sut.refresh();
			
			assertEquals("Length is not zero",  0, _sut.length);
			
			_sut.filterFunction = null;
			_sut.refresh();
			
			// Filter should not take effect
			assertEquals("Length is not two",  2, _sut.length);
			assertEquals("First element not correct",  1, _sut[0]);
			assertEquals("Second element not correct",  2, _sut[1]);
		}
		
		// RTEs in Apache Flex 4.9.1
		[Test]
		public function filterAddAfterNullNoRefresh():void
		{
			addNumbers();
			
			_sut.filterFunction = allOut;
			_sut.refresh();
			
			assertEquals("Length is not zero",  0, _sut.length);
			
			_sut.filterFunction = null;
			addNumbers();
			
			// Filter should be in effect and first 2 items sorted
			// item added after are not filtered until refresh called
			assertEquals("Length is not two",  2, _sut.length);
			assertEquals("First element not correct",  1, _sut[0]);
			assertEquals("Second element not correct",  2, _sut[1]);
			
			_sut.refresh();
			assertEquals("Length is not four",  4, _sut.length);
			assertEquals("First element not correct",  1, _sut[0]);
			assertEquals("Second element not correct",  2, _sut[1]);
			assertEquals("First element not correct",  1, _sut[2]);
			assertEquals("Second element not correct",  2, _sut[3]);
		}
		
		[Test]
		public function filterRemoveAfterNullNoRefresh():void
		{
			addNumbers();
			
			_sut.filterFunction = allOut;
			_sut.refresh();
			_sut.filterFunction = null;
			
			assertEquals("Length is not zero",  0, _sut.length);
			
			try {
				_sut.removeItemAt(0);
			}
			catch (error:Error)
			{
				assertTrue("Error not range error", error is RangeError);
			}
			
			assertEquals("Length is not zero",  0, _sut.length);
			
			_sut.refresh();
			assertEquals("Length is not two",  2, _sut.length);
		}
		
		[Test]
		public function filterIncludingDuplicates():void
		{
			addNumbers();
			addNumbers();
			
			_sut.filterFunction = isOne;
			_sut.refresh();
			
			assertEquals("Length is not two",  2, _sut.length);
			
			assertEquals("First element not correct",  1, _sut[0]);
			assertEquals("Second element not correct",  1, _sut[1]);
		}

        [Ignore]
		[Test] //See FLEX-35039
		public function swapItemsTwoThenOne_reproduces_FLEX_35039():void
		{
			//given
			addNumbers();
			_sut.filterFunction = allIn;
			_sut.refresh();
			
			var item1:Number = _sut.getItemAt(0) as Number;
			var item2:Number = _sut.getItemAt(1) as Number;

            //when
			_sut.setItemAt(item2, 0);
			_sut.setItemAt(item1, 1);

            //then
			assertEquals("Length is not two", 2, _sut.length);
			assertEquals("First element not correct", 2, _sut[0]);
			assertEquals("Second element not correct", 1, _sut[1]);
		}
		
		[Test]
		public function swapItemsOneThenTwo():void
		{
			addNumbers();
			_sut.filterFunction = allIn;
			_sut.refresh();
			
			var item1:Number = _sut.getItemAt(0) as Number;
			var item2:Number = _sut.getItemAt(1) as Number;
			
			_sut.setItemAt(item1,1);
			_sut.setItemAt(item2,0);
			
			assertEquals("Length is not two",  2, _sut.length);
			assertEquals("First element not correct",  2, _sut[0]);
			assertEquals("Second element not correct",  1, _sut[1]);
		}
		
		[Test]
		public function removeAllAfterFiltered():void
		{
			addNumbers();
			_sut.filterFunction = allOut;
			_sut.refresh();
			
			assertEquals("Length is not two",  0, _sut.length);
			
			_sut.removeAll();
			
			assertEquals("Length is not two",  0, _sut.length);
			
			_sut.filterFunction = null;
			_sut.refresh();
			
			assertEquals("Length is not two",  2, _sut.length);
			assertEquals("First element not correct",  1, _sut[0]);
			assertEquals("Second element not correct",  2, _sut[1]);
		}
		
		[Test]
		public function removeFilteredItem():void
		{
			addNumbers();
			_sut.filterFunction = isOne;
			_sut.refresh();
			
			assertEquals("Length is not one",  1, _sut.length);
			
			_sut.removeItemAt(_sut.getItemIndex(1));
			
			assertEquals("Length is not zero",  0, _sut.length);
			
			_sut.filterFunction = null;
			_sut.refresh();
			
			assertEquals("Length is not two",  1, _sut.length);
			assertEquals("First element not correct",  2, _sut[0]);
		}
		
		[Test]
		public function removeNonFilteredItem():void
		{
			addNumbers();
			_sut.filterFunction = isOne;
			_sut.refresh();
			
			assertEquals("Length is not one",  1, _sut.length);
			
			try {
				// not removed as filter hids it - perhaps it should be removed?
				_sut.removeItemAt(_sut.getItemIndex(2));
			}
			catch (error:Error)
			{
				assertTrue("Error not range error", error is RangeError);
			}
			
			assertEquals("Length is not one",  1, _sut.length);
			
			_sut.filterFunction = null;
			_sut.refresh();
			
			assertEquals("Length is not two",  2, _sut.length);
			assertEquals("First element not correct",  1, _sut[0]);
			assertEquals("First element not correct",  2, _sut[1]);
		}
		
		
	}
}