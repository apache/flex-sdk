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

    public class ArrayCollection_FilerAndSortStrings_Tests
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
			_sut.addItem(6);
			_sut.addItem(2);
			_sut.addItem(3);
			_sut.addItem(1);
			_sut.addItem(5);
			_sut.addItem(4);
		}
		
		protected function even(object:Object):Boolean
		{
			return Number(object) % 2 == 0;
		}
		
		protected function odd(object:Object):Boolean
		{
			return Number(object) % 2 == 1;
		}
		
		[Test]
		public function filterAndSortCombinations():void
		{
			addNumbers();
			_sut.filterFunction = even;
			_sut.sort = new Sort();
			_sut.refresh();
			
			assertEquals("Length is not three",  3, _sut.length);
			assertEquals("First element not correct",  2, _sut[0]);
			assertEquals("Second element not correct",  4, _sut[1]);
			assertEquals("Third element not correct",  6, _sut[2]);
			
			_sut.filterFunction = odd;
			_sut.refresh();
			
			assertEquals("Length is not three",  3, _sut.length);
			assertEquals("First element not correct",  1, _sut[0]);
			assertEquals("Second element not correct",  3, _sut[1]);
			assertEquals("Third element not correct",  5, _sut[2]);
			
			_sut.sort = new Sort();
			_sut.sort.fields = [new SortField(null, false, true, true)];
			_sut.refresh();
			
			assertEquals("Length is not three",  3, _sut.length);
			assertEquals("First element not correct",  5, _sut[0]);
			assertEquals("Second element not correct",  3, _sut[1]);
			assertEquals("Third element not correct",  1, _sut[2]);
			
			_sut.filterFunction = null;
			_sut.refresh();
			
			assertEquals("Length is not six",  6, _sut.length);
			assertEquals("First element not correct",  6, _sut[0]);
			assertEquals("Second element not correct",  5, _sut[1]);
			assertEquals("Third element not correct",  4, _sut[2]);
			assertEquals("Fourth element not correct",  3, _sut[3]);
			assertEquals("Fith element not correct",  2, _sut[4]);
			assertEquals("Six element not correct",  1, _sut[5]);
			
			_sut.sort = null;
			_sut.refresh();
			
			assertEquals("Length is not six",  6, _sut.length);
			assertEquals("First element not correct",  6, _sut[0]);
			assertEquals("Second element not correct",  2, _sut[1]);
			assertEquals("Third element not correct",  3, _sut[2]);
			assertEquals("Fourth element not correct",  1, _sut[3]);
			assertEquals("Fith element not correct",  5, _sut[4]);
			assertEquals("Six element not correct",  4, _sut[5]);
		}	
		
		
	}
}