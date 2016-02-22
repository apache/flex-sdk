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
			
			assertEquals("Length is not four",  4, ac.length);
			assertEquals("First element not correct",  "A", ac[0]);
			assertEquals("Second element not correct",  "B", ac[1]);
			assertEquals("First element not correct",  "D", ac[2]);
			assertEquals("Second element not correct",  "C", ac[3]);
		}	
		
		[Test]
		public function emptySort():void
		{
			addStrings();
			ac.sort = new Sort();
			ac.refresh();
			
			assertEquals("Length is not four",  4, ac.length);
			assertEquals("First element not correct",  "A", ac[0]);
			assertEquals("Second element not correct",  "B", ac[1]);
			assertEquals("First element not correct",  "C", ac[2]);
			assertEquals("Second element not correct",  "D", ac[3]);
		}
		
		[Test]
		public function reverseSort():void
		{
			var sort:Sort = new Sort();			
			sort.fields = [new SortField(null, false, true)];
			addStrings();
			ac.sort = sort;
			ac.refresh();
			
			assertEquals("Length is not four",  4, ac.length);
			assertEquals("First element not correct",  "D", ac[0]);
			assertEquals("Second element not correct",  "C", ac[1]);
			assertEquals("First element not correct",  "B", ac[2]);
			assertEquals("Second element not correct",  "A", ac[3]);
		}
		
		[Test]
		public function forwardSort():void
		{
			var sort:Sort = new Sort();			
			sort.fields = [new SortField()];
			addStrings();
			ac.sort = sort;
			ac.refresh();
			
			assertEquals("Length is not four",  4, ac.length);
			assertEquals("First element not correct",  "A", ac[0]);
			assertEquals("Second element not correct",  "B", ac[1]);
			assertEquals("First element not correct",  "C", ac[2]);
			assertEquals("Second element not correct",  "D", ac[3]);
		}
		
		[Test]
		public function sortNoRefresh():void
		{
			var sort:Sort = new Sort();			
			sort.fields = [new SortField()];
			addStrings();
			ac.sort = sort;
			
			// Short should not take effect
			assertEquals("Length is not four",  4, ac.length);
			assertEquals("First element not correct",  "A", ac[0]);
			assertEquals("Second element not correct",  "B", ac[1]);
			assertEquals("First element not correct",  "D", ac[2]);
			assertEquals("Second element not correct",  "C", ac[3]);
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
			assertEquals("Length is not four",  4, ac.length);
			assertEquals("First element not correct",  "A", ac[0]);
			assertEquals("Second element not correct",  "B", ac[1]);
			assertEquals("First element not correct",  "C", ac[2]);
			assertEquals("Second element not correct",  "D", ac[3]);
			
			ac.refresh();
			
			// and back to original
			assertEquals("Length is not four",  4, ac.length);
			assertEquals("First element not correct",  "A", ac[0]);
			assertEquals("Second element not correct",  "B", ac[1]);
			assertEquals("First element not correct",  "D", ac[2]);
			assertEquals("Second element not correct",  "C", ac[3]);
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
			assertEquals("Length is not four",  4, ac.length);
			assertEquals("First element not correct",  "A", ac[0]);
			assertEquals("Second element not correct",  "B", ac[1]);
			assertEquals("First element not correct",  "D", ac[2]);
			assertEquals("Second element not correct",  "C", ac[3]);
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
			assertEquals("Length is not eight",  8, ac.length);
			assertEquals("First element not correct",  "A", ac[0]);
			assertEquals("Second element not correct",  "B", ac[1]);
			assertEquals("First element not correct",  "C", ac[2]);
			assertEquals("Second element not correct",  "D", ac[3]);
			assertEquals("First element not correct",  "A", ac[4]);
			assertEquals("Second element not correct",  "B", ac[5]);
			assertEquals("First element not correct",  "D", ac[6]);
			assertEquals("Second element not correct",  "C", ac[7]);
			
			ac.refresh();
			
			// and back to being unsorted
			assertEquals("Length is not eight",  8, ac.length);
			assertEquals("First element not correct",  "A", ac[0]);
			assertEquals("Second element not correct",  "B", ac[1]);
			assertEquals("First element not correct",  "D", ac[2]);
			assertEquals("Second element not correct",  "C", ac[3]);
			assertEquals("First element not correct",  "A", ac[4]);
			assertEquals("Second element not correct",  "B", ac[5]);
			assertEquals("First element not correct",  "D", ac[6]);
			assertEquals("Second element not correct",  "C", ac[7]);
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
			
			assertEquals("Length is not four",  4, ac.length);
			
			ac.removeItemAt(0); // still sorted so 2 is removed leaving 1
			assertEquals("Length is not three",  3, ac.length);
			assertEquals("First element not correct",  "B", ac[0]);
			
			ac.refresh();
			
			assertEquals("Length is not four",  3, ac.length);
			assertEquals("First element not correct",  "A", ac[0]);
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
			
			assertEquals("Length is not eight",  8, ac.length);
			assertEquals("First element not correct",  "A", ac[0]);
			assertEquals("Second element not correct",  "A", ac[1]);
			assertEquals("First element not correct",  "B", ac[2]);
			assertEquals("Second element not correct",  "B", ac[3]);
			assertEquals("First element not correct",  "C", ac[4]);
			assertEquals("Second element not correct",  "C", ac[5]);
			assertEquals("First element not correct",  "D", ac[6]);
			assertEquals("Second element not correct",  "D", ac[7]);
		}
		
	}
}