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

    public class SortStrings
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
		
		[Test]
		public function nullSort():void
		{
			addStrings();
			ac.sort = null;
			ac.refresh();
			
			assertEquals("Length is not four", ac.length, 4);
			assertEquals("First element not correct", ac[0], "A");
			assertEquals("Second element not correct", ac[1], "B");
			assertEquals("First element not correct", ac[2], "D");
			assertEquals("Second element not correct", ac[3], "C");
		}	
		
		[Test]
		public function emptySort():void
		{
			addStrings();
			ac.sort = new Sort();
			ac.refresh();
			
			assertEquals("Length is not four", ac.length, 4);
			assertEquals("First element not correct", ac[0], "A");
			assertEquals("Second element not correct", ac[1], "B");
			assertEquals("First element not correct", ac[2], "C");
			assertEquals("Second element not correct", ac[3], "D");
		}
		
		[Test]
		public function reverseSort():void
		{
			var sort:Sort = new Sort();			
			sort.fields = [new SortField(null, false, true)];
			addStrings();
			ac.sort = sort;
			ac.refresh();
			
			assertEquals("Length is not four", ac.length, 4);
			assertEquals("First element not correct", ac[0], "D");
			assertEquals("Second element not correct", ac[1], "C");
			assertEquals("First element not correct", ac[2], "B");
			assertEquals("Second element not correct", ac[3], "A");
		}
		
		[Test]
		public function forwardSort():void
		{
			var sort:Sort = new Sort();			
			sort.fields = [new SortField()];
			addStrings();
			ac.sort = sort;
			ac.refresh();
			
			assertEquals("Length is not four", ac.length, 4);
			assertEquals("First element not correct", ac[0], "A");
			assertEquals("Second element not correct", ac[1], "B");
			assertEquals("First element not correct", ac[2], "C");
			assertEquals("Second element not correct", ac[3], "D");
		}
		
		[Test]
		public function sortNoRefresh():void
		{
			var sort:Sort = new Sort();			
			sort.fields = [new SortField()];
			addStrings();
			ac.sort = sort;
			
			// Short should not take effect
			assertEquals("Length is not four", ac.length, 4);
			assertEquals("First element not correct", ac[0], "A");
			assertEquals("Second element not correct", ac[1], "B");
			assertEquals("First element not correct", ac[2], "D");
			assertEquals("Second element not correct", ac[3], "C");
		}
		
		[Test]
		public function nullSortNoRefresh():void
		{
			var sort:Sort = new Sort();			
			sort.fields = [new SortField()];
			addStrings();
			ac.sort = sort;
			ac.refresh();
			ac.sort = null;
			
			// Sort should be in effect
			assertEquals("Length is not four", ac.length, 4);
			assertEquals("First element not correct", ac[0], "A");
			assertEquals("Second element not correct", ac[1], "B");
			assertEquals("First element not correct", ac[2], "C");
			assertEquals("Second element not correct", ac[3], "D");
			
			ac.refresh();
			
			// and back to original
			assertEquals("Length is not four", ac.length, 4);
			assertEquals("First element not correct", ac[0], "A");
			assertEquals("Second element not correct", ac[1], "B");
			assertEquals("First element not correct", ac[2], "D");
			assertEquals("Second element not correct", ac[3], "C");
		}
		
		[Test]
		public function sortDoubleRefresh():void
		{
			var sort:Sort = new Sort();			
			sort.fields = [new SortField()];
			addStrings();
			ac.sort = sort;
			ac.refresh();
			ac.sort = null;
			ac.refresh();
			
			// Sort should not be in effect
			assertEquals("Length is not four", ac.length, 4);
			assertEquals("First element not correct", ac[0], "A");
			assertEquals("Second element not correct", ac[1], "B");
			assertEquals("First element not correct", ac[2], "D");
			assertEquals("Second element not correct", ac[3], "C");
		}
		
		// RTEs in APache flex 4.9.1
		[Test]
		public function sortAddAfterNullNoRefresh():void
		{
			addStrings();
			
			var sort:Sort = new Sort();			
			sort.fields = [new SortField()];
			ac.sort = sort;
			ac.refresh();
			ac.sort = null;
			addStrings();
			
			// Sort should be in effect and first 4 items sorted
			// item added after are not sorted
			assertEquals("Length is not eight", ac.length, 8);
			assertEquals("First element not correct", ac[0], "A");
			assertEquals("Second element not correct", ac[1], "B");
			assertEquals("First element not correct", ac[2], "C");
			assertEquals("Second element not correct", ac[3], "D");
			assertEquals("First element not correct", ac[4], "A");
			assertEquals("Second element not correct", ac[5], "B");
			assertEquals("First element not correct", ac[6], "D");
			assertEquals("Second element not correct", ac[7], "C");
			
			ac.refresh();
			
			// and back to being unsorted
			assertEquals("Length is not eight", ac.length, 8);
			assertEquals("First element not correct", ac[0], "A");
			assertEquals("Second element not correct", ac[1], "B");
			assertEquals("First element not correct", ac[2], "D");
			assertEquals("Second element not correct", ac[3], "C");
			assertEquals("First element not correct", ac[4], "A");
			assertEquals("Second element not correct", ac[5], "B");
			assertEquals("First element not correct", ac[6], "D");
			assertEquals("Second element not correct", ac[7], "C");
		}
		
		// RTEs in Apache Flex 4.9.1
		[Test]
		public function sortRemoveAfterNullNoRefresh():void
		{
			addStrings();
			
			var sort:Sort = new Sort();			
			sort.fields = [new SortField(null, false, true, true)];
			ac.sort = sort;
			ac.refresh();
			ac.sort = null;
			
			assertEquals("Length is not four", ac.length, 4);
			
			ac.removeItemAt(0); // still sorted so 2 is removed leaving 1
			assertEquals("Length is not three", ac.length, 3);
			assertEquals("First element not correct", ac[0], "B");
			
			ac.refresh();
			
			assertEquals("Length is not four", ac.length, 3);
			assertEquals("First element not correct", ac[0], "A");
		}
		
		[Test]
		public function sortIncludingDuplicates():void
		{
			addStrings();
			addStrings();
			
			var sort:Sort = new Sort();			
			sort.fields = [new SortField()];
			ac.sort = sort;
			ac.refresh();
			
			assertEquals("Length is not eight", ac.length, 8);
			assertEquals("First element not correct", ac[0], "A");
			assertEquals("Second element not correct", ac[1], "A");
			assertEquals("First element not correct", ac[2], "B");
			assertEquals("Second element not correct", ac[3], "B");	
			assertEquals("First element not correct", ac[4], "C");
			assertEquals("Second element not correct", ac[5], "C");
			assertEquals("First element not correct", ac[6], "D");
			assertEquals("Second element not correct", ac[7], "D");	
		}
		
	}
}