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

    public class FilterNumbers
	{

        protected var ac:ArrayCollection;
		
		[Before]
		public function setUp():void
		{
			ac = new ArrayCollection();
		}
		
		[After]
		public function tearDown():void
		{
			ac = null;
		}
		
		protected function addNumbers():void
		{
			ac.addItem(1);
			ac.addItem(2);
		}
		
		protected function allIn(object:Object):Boolean
		{
			return true;
		}
		
		protected function allOut(object:Object):Boolean
		{
			return false;
		}
		
		protected function isOne(object:Object):Boolean
		{
			return object == 1;
		}
		
		[Test]
		public function nullFilter():void
		{
			addNumbers();
			ac.filterFunction = null;
			ac.refresh();
			
			assertEquals("Length is not two",  2, ac.length);
			assertEquals("First element not correct",  1, ac[0]);
			assertEquals("Second element not correct",  2, ac[1]);
		}	
		
		[Test]
		public function trueFilter():void
		{
			addNumbers();
			ac.filterFunction = allIn; 
			ac.refresh();
			
			assertEquals("Length is not two",  2, ac.length);
			assertEquals("First element not correct",  1, ac[0]);
			assertEquals("Second element not correct",  2, ac[1]);
		}
		
		[Test]
		public function falseFilter():void
		{
			addNumbers();
			ac.filterFunction = allOut; 
			ac.refresh();
			
			assertEquals("Length is not two",  0, ac.length);
		}
		
		
		[Test]
		public function filterNoRefresh():void
		{
			addNumbers();
			ac.filterFunction = allOut;
			
			// Filter should not take effect
			assertEquals("Length is not two",  2, ac.length);
			assertEquals("First element not correct",  1, ac[0]);
			assertEquals("Second element not correct",  2, ac[1]);
		}
		
		[Test]
		public function nullFilterNoRefresh():void
		{
			addNumbers();
			ac.filterFunction = null;
			
			// Filter should not take effect
			assertEquals("Length is not two",  2, ac.length);
			assertEquals("First element not correct",  1, ac[0]);
			assertEquals("Second element not correct",  2, ac[1]);
		}
		
		[Test]
		public function filterDoubleRefresh():void
		{
			addNumbers();
			ac.filterFunction = allOut;
			ac.refresh();
			
			assertEquals("Length is not zero",  0, ac.length);
			
			ac.filterFunction = null;
			ac.refresh();
			
			// Filter should not take effect
			assertEquals("Length is not two",  2, ac.length);
			assertEquals("First element not correct",  1, ac[0]);
			assertEquals("Second element not correct",  2, ac[1]);
		}
		
		// RTEs in Apache Flex 4.9.1
		[Test]
		public function filterAddAfterNullNoRefresh():void
		{
			addNumbers();
			
			ac.filterFunction = allOut;
			ac.refresh();
			
			assertEquals("Length is not zero",  0, ac.length);
			
			ac.filterFunction = null;
			addNumbers();
			
			// Filter should be in effect and first 2 items sorted
			// item added after are not filtered until refresh called
			assertEquals("Length is not two",  2, ac.length);
			assertEquals("First element not correct",  1, ac[0]);
			assertEquals("Second element not correct",  2, ac[1]);
			
			ac.refresh();
			assertEquals("Length is not four",  4, ac.length);
			assertEquals("First element not correct",  1, ac[0]);
			assertEquals("Second element not correct",  2, ac[1]);
			assertEquals("First element not correct",  1, ac[2]);
			assertEquals("Second element not correct",  2, ac[3]);
		}
		
		[Test]
		public function filterRemoveAfterNullNoRefresh():void
		{
			addNumbers();
			
			ac.filterFunction = allOut;
			ac.refresh();
			ac.filterFunction = null;
			
			assertEquals("Length is not zero",  0, ac.length);
			
			try {
				ac.removeItemAt(0);
			}
			catch (error:Error)
			{
				assertTrue("Error not range error", error is RangeError);
			}
			
			assertEquals("Length is not zero",  0, ac.length);
			
			ac.refresh();
			assertEquals("Length is not two",  2, ac.length);
		}
		
		[Test]
		public function filterIncludingDuplicates():void
		{
			addNumbers();
			addNumbers();
			
			ac.filterFunction = isOne;
			ac.refresh();
			
			assertEquals("Length is not two",  2, ac.length);
			
			assertEquals("First element not correct",  1, ac[0]);
			assertEquals("Second element not correct",  1, ac[1]);
		}
		
		// Fails in Apache Flex 4.9.1
		[Test]
		public function swapItemsTwoThenOne():void
		{
			//given
			addNumbers();
			ac.filterFunction = allIn;
			ac.refresh();
			
			var item1:Number = ac.getItemAt(0) as Number;
			var item2:Number = ac.getItemAt(1) as Number;

            //when
			ac.setItemAt(item2, 0);
			ac.setItemAt(item1, 1);

            //then
			assertEquals("Length is not two", 2, ac.length);
			assertEquals("First element not correct", 2, ac[0]);
			assertEquals("Second element not correct", 1, ac[1]);
		}
		
		[Test]
		public function swapItemsOneThenTwo():void
		{
			addNumbers();
			ac.filterFunction = allIn; 
			ac.refresh();
			
			var item1:Number = ac.getItemAt(0) as Number;
			var item2:Number = ac.getItemAt(1) as Number;
			
			ac.setItemAt(item1,1);
			ac.setItemAt(item2,0);
			
			assertEquals("Length is not two",  2, ac.length);
			assertEquals("First element not correct",  2, ac[0]);
			assertEquals("Second element not correct",  1, ac[1]);
		}
		
		[Test]
		public function removeAllAfterFiltered():void
		{
			addNumbers();
			ac.filterFunction = allOut; 
			ac.refresh();
			
			assertEquals("Length is not two",  0, ac.length);
			
			ac.removeAll();
			
			assertEquals("Length is not two",  0, ac.length);
			
			ac.filterFunction = null; 
			ac.refresh();
			
			assertEquals("Length is not two",  2, ac.length);
			assertEquals("First element not correct",  1, ac[0]);
			assertEquals("Second element not correct",  2, ac[1]);
		}
		
		[Test]
		public function removeFilteredItem():void
		{
			addNumbers();
			ac.filterFunction = isOne; 
			ac.refresh();
			
			assertEquals("Length is not one",  1, ac.length);
			
			ac.removeItemAt(ac.getItemIndex(1));
			
			assertEquals("Length is not zero",  0, ac.length);
			
			ac.filterFunction = null; 
			ac.refresh();
			
			assertEquals("Length is not two",  1, ac.length);
			assertEquals("First element not correct",  2, ac[0]);
		}
		
		[Test]
		public function removeNonFilteredItem():void
		{
			addNumbers();
			ac.filterFunction = isOne; 
			ac.refresh();
			
			assertEquals("Length is not one",  1, ac.length);
			
			try {
				// not removed as filter hids it - perhaps it should be removed?
				ac.removeItemAt(ac.getItemIndex(2));	
			}
			catch (error:Error)
			{
				assertTrue("Error not range error", error is RangeError);
			}
			
			assertEquals("Length is not one",  1, ac.length);
			
			ac.filterFunction = null; 
			ac.refresh();
			
			assertEquals("Length is not two",  2, ac.length);
			assertEquals("First element not correct",  1, ac[0]);
			assertEquals("First element not correct",  2, ac[1]);
		}
		
		
	}
}