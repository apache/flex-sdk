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

    public class ArrayCollection_SortNumbers_Tests
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
		
		[Test]
		public function nullSort():void
		{
			addNumbers();
			_sut.sort = null;
			_sut.refresh();
			
			assertEquals("Length is not two",  2, _sut.length);
			assertEquals("First element not correct",  1, _sut[0]);
			assertEquals("Second element not correct",  2, _sut[1]);
		}	
		
		[Test]
		public function emptySort():void
		{
			addNumbers();
			_sut.sort = new Sort();
			_sut.refresh();
			
			assertEquals("Length is not two",  2, _sut.length);
			assertEquals("First element not correct",  1, _sut[0]);
			assertEquals("Second element not correct",  2, _sut[1]);
		}
		
		[Test]
		public function reverseSort():void
		{
			var sort:Sort = new Sort();			
			sort.fields = [new SortField(null, false, true, true)];
			addNumbers();
			_sut.sort = sort;
			_sut.refresh();
			
			assertEquals("Length is not two",  2, _sut.length);
			assertEquals("First element not correct",  2, _sut[0]);
			assertEquals("Second element not correct",  1, _sut[1]);
		}
		
		[Test]
		public function sortNoRefresh():void
		{
			var sort:Sort = new Sort();			
			sort.fields = [new SortField(null, false, true, true)];
			addNumbers();
			_sut.sort = sort;
			
			// Short should not take effect
			assertEquals("Length is not two",  2, _sut.length);
			assertEquals("First element not correct",  1, _sut[0]);
			assertEquals("Second element not correct",  2, _sut[1]);
		}
		
		[Test]
		public function nullSortNoRefresh():void
		{
			var sort:Sort = new Sort();			
			sort.fields = [new SortField(null, false, true, true)];
			addNumbers();
			_sut.sort = sort;
			_sut.refresh();
			_sut.sort = null;
			
			// Sort should be in effect
			assertEquals("Length is not two",  2, _sut.length);
			assertEquals("First element not correct",  2, _sut[0]);
			assertEquals("Second element not correct",  1, _sut[1]);
			
			_sut.refresh();
			
			// and back to original
			assertEquals("Length is not two",  2, _sut.length);
			assertEquals("First element not correct",  1, _sut[0]);
			assertEquals("Second element not correct",  2, _sut[1]);
		}
		
		[Test]
		public function sortDoubleRefresh():void
		{
			var sort:Sort = new Sort();			
			sort.fields = [new SortField(null, false, true, true)];
			addNumbers();
			_sut.sort = sort;
			_sut.refresh();
			_sut.sort = null;
			_sut.refresh();
			
			// Sort should not be in effect
			assertEquals("Length is not two",  2, _sut.length);
			assertEquals("First element not correct",  1, _sut[0]);
			assertEquals("Second element not correct",  2, _sut[1]);
		}
		
		// RTEs in APache flex 4.9.1
		[Test]
		public function sortAddAfterNullNoRefresh():void
		{
			addNumbers();
			
			var sort:Sort = new Sort();			
			sort.fields = [new SortField(null, false, true, true)];
			_sut.sort = sort;
			_sut.refresh();
			_sut.sort = null;
			addNumbers();
			
			// Sort should be in effect and first 2 items sorted
			// item added after are not sorted
			assertEquals("Length is not four",  4, _sut.length);
			assertEquals("First element not correct",  2, _sut[0]);
			assertEquals("Second element not correct",  1, _sut[1]);
			assertEquals("Third element not correct",  1, _sut[2]);
			assertEquals("Fourth element not correct",  2, _sut[3]);
			
			_sut.refresh();
			
			// and back to being unsorted
			assertEquals("Length is not four",  4, _sut.length);
			assertEquals("First element not correct",  1, _sut[0]);
			assertEquals("Second element not correct",  2, _sut[1]);
			assertEquals("Third element not correct",  1, _sut[2]);
			assertEquals("Fourth element not correct",  2, _sut[3]);
		}
		
		// RTEs in Apache Flex 4.9.1
		[Test]
		public function sortRemoveAfterNullNoRefresh():void
		{
			addNumbers();
			
			var sort:Sort = new Sort();			
			sort.fields = [new SortField(null, false, true, true)];
			_sut.sort = sort;
			_sut.refresh();
			_sut.sort = null;
			
			assertEquals("Length is not two",  2, _sut.length);
			
			_sut.removeItemAt(0); // still sorted so 2 is removed leaving 1
			assertEquals("Length is not one",  1, _sut.length);
			assertEquals("First element not correct",  1, _sut[0]);
			
			_sut.refresh();
			
			// still the same
			assertEquals("Length is not one",  1, _sut.length);
			assertEquals("First element not correct",  1, _sut[0]);
		}
		
		[Test]
		public function sortIncludingDuplicates():void
		{
			addNumbers();
			addNumbers();
			
			var sort:Sort = new Sort();			
			sort.fields = [new SortField(null, false, true, true)];
			_sut.sort = sort;
			_sut.refresh();
			
			assertEquals("Length is not four",  4, _sut.length);
			
			assertEquals("First element not correct",  2, _sut[0]);
			assertEquals("Second element not correct",  2, _sut[1]);
			assertEquals("Third element not correct",  1, _sut[2]);
			assertEquals("Fourth element not correct",  1, _sut[3]);
		}
		
	}
}