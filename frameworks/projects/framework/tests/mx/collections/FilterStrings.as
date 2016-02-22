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

    public class FilterStrings
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
		
		protected function addStrings():void
		{
			ac.addItem("A");
			ac.addItem("B");
			ac.addItem("D");
			ac.addItem("C");
		}
		
		protected function allIn(object:Object):Boolean
		{
			return true;
		}
		
		protected function allOut(object:Object):Boolean
		{
			return false;
		}
		
		protected function isA(object:Object):Boolean
		{
			return object == "A";
		}
		
		[Test]
		public function nullFilter():void
		{
			addStrings();
			ac.filterFunction = null;
			ac.refresh();
			
			assertEquals("Length is not four", ac.length, 4);
			assertEquals("First element not correct", ac[0], "A");
			assertEquals("Second element not correct", ac[1], "B");
			assertEquals("Third element not correct", ac[2], "D");
			assertEquals("Four element not correct", ac[3], "C");
		}	
		
		[Test]
		public function trueFilter():void
		{
			addStrings();
			ac.filterFunction = allIn; 
			ac.refresh();
			
			assertEquals("Length is not four", ac.length, 4);
			assertEquals("First element not correct", ac[0], "A");
			assertEquals("Second element not correct", ac[1], "B");
			assertEquals("Third element not correct", ac[2], "D");
			assertEquals("Four element not correct", ac[3], "C");
		}
		
		[Test]
		public function falseFilter():void
		{
			addStrings();
			ac.filterFunction = allOut; 
			ac.refresh();
			
			assertEquals("Length is not zero", ac.length, 0);
		}
		
		
		[Test]
		public function filterNoRefresh():void
		{
			addStrings();
			ac.filterFunction = allOut;
			
			// Filter should not take effect
			assertEquals("Length is not four", ac.length, 4);
			assertEquals("First element not correct", ac[0], "A");
			assertEquals("Second element not correct", ac[1], "B");
			assertEquals("Third element not correct", ac[2], "D");
			assertEquals("Four element not correct", ac[3], "C");
		}
		
		[Test]
		public function nullFilterNoRefresh():void
		{
			addStrings();
			ac.filterFunction = null;
			
			// Filter should not take effect
			assertEquals("Length is not four", ac.length, 4);
			assertEquals("First element not correct", ac[0], "A");
			assertEquals("Second element not correct", ac[1], "B");
			assertEquals("Third element not correct", ac[2], "D");
			assertEquals("Four element not correct", ac[3], "C");
		}
		
		[Test]
		public function filterDoubleRefresh():void
		{
			addStrings();
			ac.filterFunction = allOut;
			ac.refresh();
			
			assertEquals("Length is not zero", ac.length, 0);
			
			ac.filterFunction = null;
			ac.refresh();
			
			// Filter should not take effect
			assertEquals("Length is not four", ac.length, 4);
			assertEquals("First element not correct", ac[0], "A");
			assertEquals("Second element not correct", ac[1], "B");
			assertEquals("Third element not correct", ac[2], "D");
			assertEquals("Four element not correct", ac[3], "C");
		}
		
		// RTEs in Apache Flex 4.9.1
		[Test]
		public function filterAddAfterNullNoRefresh():void
		{
			addStrings();
			
			ac.filterFunction = allOut;
			ac.refresh();
			
			assertEquals("Length is not zero", ac.length, 0);
			
			ac.filterFunction = null;
			addStrings();
			
			// Filter should be in effect and first 2 items sorted
			// item added after are not filtered until refresh called
			assertEquals("Length is not four", ac.length, 4);
			assertEquals("First element not correct", ac[0], "A");
			assertEquals("Second element not correct", ac[1], "B");
			assertEquals("Third element not correct", ac[2], "D");
			assertEquals("Four element not correct", ac[3], "C");
			
			ac.refresh();
			assertEquals("Length is not eight", ac.length, 8);
			assertEquals("First element not correct", ac[0], "A");
			assertEquals("Second element not correct", ac[1], "B");
			assertEquals("Third element not correct", ac[2], "D");
			assertEquals("Four element not correct", ac[3], "C");
			assertEquals("First element not correct", ac[4], "A");
			assertEquals("Second element not correct", ac[5], "B");
			assertEquals("Third element not correct", ac[6], "D");
			assertEquals("Four element not correct", ac[7], "C");
		}
		
		[Test]
		public function filterRemoveAfterNullNoRefresh():void
		{
			addStrings();
			
			ac.filterFunction = allOut;
			ac.refresh();
			ac.filterFunction = null;
			
			assertEquals("Length is not zero", ac.length, 0);
			
			try {
				ac.removeItemAt(0);
			}
			catch (error:Error)
			{
				assertTrue("Error not range error", error is RangeError);
			}
			
			assertEquals("Length is not zero", ac.length, 0);
			
			ac.refresh();
			assertEquals("Length is not four", ac.length, 4);
		}
		
		[Test]
		public function filterIncludingDuplicates():void
		{
			addStrings();
			addStrings();
			
			ac.filterFunction = isA;
			ac.refresh();
			
			assertEquals("Length is not two", ac.length, 2);
			
			assertEquals("First element not correct", ac[0], "A");
			assertEquals("Second element not correct", ac[1], "A");	
		}
		
		// Fails in Apache Flex 4.9.1
		[Test]
		public function swapItemsTwoThenOne():void
		{
			//given
			addStrings();
			ac.filterFunction = allIn; 
			ac.refresh();
			
			var item1:String = ac.getItemAt(0) as String;
			var item2:String = ac.getItemAt(1) as String;

            //when
			ac.setItemAt(item2,0);
			ac.setItemAt(item1,1);

            //then
			assertEquals("Length is not four", ac.length, 4);
			assertEquals("First element not correct", "B", ac[0]);
			assertEquals("Second element not correct", "A", ac[1]);
			assertEquals("Third element not correct", "D", ac[2]);
			assertEquals("Four element not correct", "C", ac[3]);
		}
		
		[Test]
		public function swapItemsOneThenTwo():void
		{
			addStrings();
			ac.filterFunction = allIn; 
			ac.refresh();
			
			var item1:String = ac.getItemAt(0) as String;
			var item2:String = ac.getItemAt(1) as String;
			
			ac.setItemAt(item1,1);
			ac.setItemAt(item2,0);
			
			assertEquals("Length is not four", ac.length, 4);
			assertEquals("First element not correct", ac[0], "B");
			assertEquals("Second element not correct", ac[1], "A");
			assertEquals("Third element not correct", ac[2], "D");
			assertEquals("Four element not correct", ac[3], "C");
		}
		
		[Test]
		public function removeAllAfterFiltered():void
		{
			addStrings();
			ac.filterFunction = allOut; 
			ac.refresh();
			
			assertEquals("Length is not two", ac.length, 0);
			
			ac.removeAll();
			
			assertEquals("Length is not two", ac.length, 0);
			
			ac.filterFunction = null; 
			ac.refresh();
			
			assertEquals("Length is not four", ac.length, 4);
			assertEquals("First element not correct", ac[0], "A");
			assertEquals("Second element not correct", ac[1], "B");
			assertEquals("Third element not correct", ac[2], "D");
			assertEquals("Four element not correct", ac[3], "C");
		}
		
		[Test]
		public function removeFilteredItem():void
		{
			addStrings();
			ac.filterFunction = isA; 
			ac.refresh();
			
			assertEquals("Length is not one", ac.length, 1);
			
			ac.removeItemAt(ac.getItemIndex("A"));
			
			assertEquals("Length is not zero", ac.length, 0);
			
			ac.filterFunction = null; 
			ac.refresh();
			
			assertEquals("Length is not three", ac.length, 3);
			assertEquals("First element not correct", ac[0], "B");
		}
		
		[Test]
		public function removeNonFilteredItem():void
		{
			addStrings();
			ac.filterFunction = isA; 
			ac.refresh();
			
			assertEquals("Length is not one", ac.length, 1);
			
			try {
				// not removed as filter hids it - perhaps it should be removed?
				ac.removeItemAt(ac.getItemIndex("B"));	
			}
			catch (error:Error)
			{
				assertTrue("Error not range error", error is RangeError);
			}
			
			assertEquals("Length is not one", ac.length, 1);
			
			ac.filterFunction = null; 
			ac.refresh();
			
			assertEquals("Length is not four", ac.length, 4);
			assertEquals("First element not correct", ac[0], "A");
			assertEquals("Second element not correct", ac[1], "B");
			assertEquals("Third element not correct", ac[2], "D");
			assertEquals("Four element not correct", ac[3], "C");
		}
		
		
	}
}