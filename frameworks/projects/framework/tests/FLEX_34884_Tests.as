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

package {
    import mx.collections.ArrayList;
    import mx.collections.ComplexFieldChangeWatcher;
    import mx.collections.ComplexSortField;
    import mx.collections.IList;
    import mx.collections.ListCollectionView;
    import spark.collections.Sort;
    import spark.collections.SortField;

    import org.flexunit.assertThat;

    import org.flexunit.asserts.assertEquals;

    public class FLEX_34884_Tests {
        private var _sut:ListCollectionView;

        private static const MILLISECONDS_IN_A_SECOND:Number = 1000;
        private static const MILLISECONDS_IN_A_MINUTE:Number = MILLISECONDS_IN_A_SECOND * 60;
        private static const MILLISECONDS_IN_AN_HOUR:Number = MILLISECONDS_IN_A_MINUTE * 60;
        private static const MILLISECONDS_IN_A_DAY:Number = MILLISECONDS_IN_AN_HOUR * 24;

        [Before]
        public function setUp():void
        {
            _sut = new ListCollectionView(new ArrayList());
        }

        [After]
        public function tearDown():void
        {
            _sut = null;
        }

        [Test]
        public function getItemIndex_finds_first_item_in_simple_sorted_non_filtered_list():void
        {
            //given
            var from0To4:IList = generateVOs(5);
            _sut.addAll(from0To4); //values: Object0, Object1, Object2, Object3, Object4

            const sortByIndexAscending:Sort = new Sort();
            sortByIndexAscending.fields = [new SortField("index", false, true)];
            _sut.sort = sortByIndexAscending;
            _sut.refresh(); //values (unchanged): Object0, Object1, Object2, Object3, Object4

            //when
            var item0:FLEX_34884_VO = from0To4.getItemAt(0) as FLEX_34884_VO;
            var item0Index:int = _sut.getItemIndex(item0);

            //then
            assertEquals(0, item0Index);
        }

        [Test]
        public function getItemIndex_finds_last_item_in_simple_descending_sorted_non_filtered_list():void
        {
            //given
            var from0To4:IList = generateVOs(5);
            _sut.addAll(from0To4); //values: Object0, Object1, Object2, Object3, Object4

            const sortByIndexDescending:Sort = new Sort();
            sortByIndexDescending.fields = [new SortField("index", true, true)];
            _sut.sort = sortByIndexDescending;
            _sut.refresh(); //values: Object4, Object3, Object2, Object1, Object0

            //when
            var item0:FLEX_34884_VO = from0To4.getItemAt(0) as FLEX_34884_VO;
            var item0Index:int = _sut.getItemIndex(item0);

            //then
            assertEquals(_sut.length - 1, item0Index);
        }

        [Test]
        public function getItemIndex_finds_second_to_last_item_in_simple_descending_sorted_non_filtered_list():void
        {
            //given
            var from0To4:IList = generateVOs(5);
            _sut.addAll(from0To4); //values: Object0, Object1, Object2, Object3, Object4

            const sortByIndexDescending:Sort = new Sort();
            sortByIndexDescending.fields = [new SortField("index", true, true)];
            _sut.sort = sortByIndexDescending;
            _sut.refresh(); //values: Object4, Object3, Object2, Object1, Object0

            //when
            var item1:FLEX_34884_VO = from0To4.getItemAt(1) as FLEX_34884_VO;
            var item1Index:int = _sut.getItemIndex(item1);

            //then
            assertEquals(_sut.length - 2, item1Index);
        }

        [Test]
        public function getItemIndex_finds_item_in_descending_two_sort_fields_sorted_list_after_changing_one_field():void
        {
            //given
            var from0To4:IList = generateVOs(5);
            _sut.addAll(from0To4); //index/name: 0/Object0, 1/Object1, 2/Object2, 3/Object3, 4/Object4

            const sortByIndexDescending:Sort = new Sort();
            sortByIndexDescending.fields = [new SortField("index", true, true), new SortField("name", false, false)];
            _sut.sort = sortByIndexDescending;
            _sut.refresh(); //index/name: 4/Object4, 3/Object3, 2/Object2, 1/Object1, 0/Object0

            //when
            var item1:FLEX_34884_VO = from0To4.getItemAt(1) as FLEX_34884_VO;
            item1.index = 0; //index/name: 4/Object4, 3/Object3, 2/Object2, 0/Object0, 0/Object1

            var item2:FLEX_34884_VO = from0To4.getItemAt(2) as FLEX_34884_VO;
            item2.index = 0; //index/name: 4/Object4, 3/Object3, 0/Object0, 0/Object1, 0/Object2

            //then
            assertEquals(_sut.length - 1, _sut.getItemIndex(item2));
            assertEquals(_sut.length - 2, _sut.getItemIndex(item1));
        }

        [Test]
        public function getItemIndex_finds_second_to_last_item_in_simple_no_fields_non_unique_sorted_list():void
        {
            //given
            var from0To4:IList = generateVOs(5);
            _sut.addAll(from0To4); //values: Object0, Object1, Object2, Object3, Object4

            const emptySort:Sort = new Sort(null, null, false);
            _sut.sort = emptySort;
            _sut.refresh(); //values should be unchanged

            //when
            var item1:FLEX_34884_VO = from0To4.getItemAt(1) as FLEX_34884_VO;

            //then
            var item1Index:int = _sut.getItemIndex(item1);
            assertEquals(1, item1Index);
        }

        [Test]
        public function getItemIndex_finds_second_to_last_item_in_simple_no_fields_unique_sorted_list():void
        {
            //given
            var from0To4:IList = generateVOs(5);
            _sut.addAll(from0To4); //values: Object0, Object1, Object2, Object3, Object4

            const emptySort:Sort = new Sort(null, null, true);
            _sut.sort = emptySort;
            _sut.refresh(); //values should be unchanged

            //when
            var item1:FLEX_34884_VO = from0To4.getItemAt(1) as FLEX_34884_VO;

            //then
            var item1Index:int = _sut.getItemIndex(item1);
            assertEquals(1, item1Index);
        }

        [Test]
        public function getItemIndex_finds_second_to_last_date_in_simple_no_fields_unique_sorted_list_of_dates():void
        {
            //given
            var yesterday:Date = new Date();
            yesterday.setTime(yesterday.getTime() - MILLISECONDS_IN_A_DAY);

            var today:Date = new Date();

            var tomorrow:Date = new Date();
            tomorrow.setTime(tomorrow.getTime() + MILLISECONDS_IN_A_DAY);

            _sut.addItem(tomorrow);
            _sut.addItem(today);
            _sut.addItem(yesterday);

            //when
            const emptySort:Sort = new Sort(null, null, true);
            _sut.sort = emptySort;
            _sut.refresh(); //values: yesterday, today, tomorrow

            //then
            assertEquals(0, _sut.getItemIndex(yesterday));
            assertEquals(1, _sut.getItemIndex(today));
            assertEquals(2, _sut.getItemIndex(tomorrow));
        }

        [Test]
        public function getItemIndex_finds_second_to_last_date_in_simple_no_fields_non_unique_sorted_list_of_dates():void
        {
            //given
            var yesterday:Date = new Date();
            yesterday.setTime(yesterday.getTime() - MILLISECONDS_IN_A_DAY);

            var today:Date = new Date();

            var tomorrow:Date = new Date();
            tomorrow.setTime(tomorrow.getTime() + MILLISECONDS_IN_A_DAY);

            _sut.addItem(tomorrow);
            _sut.addItem(today);
            _sut.addItem(yesterday);
            _sut.addItem(today);

            //when
            const emptySort:Sort = new Sort(null, null, true);
            _sut.sort = emptySort;
            _sut.refresh(); //values: yesterday, today, today, tomorrow

            //then
            assertEquals(0, _sut.getItemIndex(yesterday));
            var todayIndex:int = _sut.getItemIndex(today);
            assertThat(todayIndex == 1 || todayIndex == 2);
            assertEquals(3, _sut.getItemIndex(tomorrow));
        }

        [Test]
        public function getItemIndex_finds_first_item_in_complex_sorted_non_filtered_list():void
        {
            //given
            var from0To4:IList = generateVOs(5);
            _sut.addAll(from0To4); //values[address.street]: Street0, Street1, Street2, Street3, Street4

            const sortByIndexAscending:Sort = new Sort();
            sortByIndexAscending.fields = [new ComplexSortField("address.street", false, false)];
            _sut.sort = sortByIndexAscending;
            _sut.refresh(); //values[address.street] (unchanged): Street0, Street1, Street2, Street3, Street4

            //when
            var item0:FLEX_34884_VO = from0To4.getItemAt(0) as FLEX_34884_VO;
            var item0Index:int = _sut.getItemIndex(item0);

            //then
            assertEquals(0, item0Index);
        }

        [Test]
        public function getItemIndex_finds_last_item_in_complex_descending_sorted_non_filtered_list():void
        {
            //given
            var from0To4:IList = generateVOs(5);
            _sut.addAll(from0To4); //values[address.street]: Street0, Street1, Street2, Street3, Street4

            const sortByIndexDescending:Sort = new Sort();
            sortByIndexDescending.fields = [new ComplexSortField("address.street", false, true, false)];
            _sut.sort = sortByIndexDescending;
            _sut.refresh(); //values: Street4, Street3, Street2, Street1, Street0

            //when
            var item0:FLEX_34884_VO = from0To4.getItemAt(0) as FLEX_34884_VO;
            var item0Index:int = _sut.getItemIndex(item0);

            //then
            assertEquals(_sut.length - 1, item0Index);
        }

        [Test]
        public function getItemIndex_finds_item_in_complex_multi_field_sorted_non_filtered_list():void
        {
            //given
            var from0To4:IList = generateVOs(5);
            _sut.addAll(from0To4); //index / address.street: 0/Street0, 1/Street1, 2/Street2, 3/Street3, 4/Street4

            const sortByStreetAndIndex:Sort = new Sort();
            sortByStreetAndIndex.fields = [new ComplexSortField("address.street", false, true, false), new SortField("index", false, true)];
            _sut.sort = sortByStreetAndIndex;
            _sut.refresh(); //index / address.street: 4/Street4, 3/Street3, 2/Street2, 1/Street1, 0/Street0

            _sut.complexFieldWatcher = new ComplexFieldChangeWatcher();

            //when
            var item0:FLEX_34884_VO = from0To4.getItemAt(0) as FLEX_34884_VO;
            item0.address.street = "Street4"; //index / address.street: 0/Street4, 4/Street4, 3/Street3, 2/Street2, 1/Street1

            var item1:FLEX_34884_VO = from0To4.getItemAt(1) as FLEX_34884_VO;
            item1.address.street = "Street4"; //index / address.street: 0/Street4, 1/Street4, 4/Street4, 3/Street3, 2/Street2
            item1.index = 9; //index / address.street: 0/Street4, 4/Street4, 9/Street4, 3/Street3, 2/Street2

            //then
            assertEquals(0, _sut.getItemIndex(item0));
            assertEquals(2, _sut.getItemIndex(item1));
        }

        [Test]
        public function getItemIndex_finds_item_in_complex_multi_field_sorted_filtered_list():void
        {
            function excludeIndexesAbove4(item:Object):Boolean
            {
                return FLEX_34884_VO(item).index <= 4;
            }

            //given
            var from0To4:IList = generateVOs(5);
            _sut.addAll(from0To4); //index / address.street: 0/Street0, 1/Street1, 2/Street2, 3/Street3, 4/Street4

            const sortByStreetAndIndex:Sort = new Sort();
            sortByStreetAndIndex.fields = [new ComplexSortField("address.street", false, true, false), new SortField("index", false, true)];
            _sut.sort = sortByStreetAndIndex;

            _sut.refresh(); //index / address.street: 4/Street4, 3/Street3, 2/Street2, 1/Street1, 0/Street0

            _sut.complexFieldWatcher = new ComplexFieldChangeWatcher();

            //when
            var item0:FLEX_34884_VO = from0To4.getItemAt(0) as FLEX_34884_VO;
            item0.address.street = "Street4"; //index / address.street: 0/Street4, 4/Street4, 3/Street3, 2/Street2, 1/Street1

            var item1:FLEX_34884_VO = from0To4.getItemAt(1) as FLEX_34884_VO;
            item1.address.street = "Street4"; //index / address.street: 0/Street4, 1/Street4, 4/Street4, 3/Street3, 2/Street2
            item1.index = 9; //index / address.street: 0/Street4, 4/Street4, 9/Street4, 3/Street3, 2/Street2

            _sut.filterFunction = excludeIndexesAbove4;
            _sut.refresh(); //index / address.street: 0/Street4, 4/Street4, 3/Street3, 2/Street2

            //then
            assertEquals(0, _sut.getItemIndex(item0));
            assertEquals(-1, _sut.getItemIndex(item1));
            var item3:FLEX_34884_VO = from0To4.getItemAt(3) as FLEX_34884_VO;
            assertEquals(2, _sut.getItemIndex(item3));
        }

        [Test]
        public function getItemIndex_finds_item_in_complex_descending_sorted_list_after_its_repositioned_due_to_its_sort_field_changing():void
        {
            //given
            var from0To4:IList = generateVOs(5);
            _sut.addAll(from0To4); //values[address.street]: Street0, Street1, Street2, Street3, Street4

            const sortByIndexDescending:Sort = new Sort();
            sortByIndexDescending.fields = [new ComplexSortField("address.street", false, true, false)];
            _sut.sort = sortByIndexDescending;
            _sut.refresh(); //values: Street4, Street3, Street2, Street1, Street0

            _sut.complexFieldWatcher = new ComplexFieldChangeWatcher();

            //when
            var item0:FLEX_34884_VO = from0To4.getItemAt(0) as FLEX_34884_VO;
            var item999:FLEX_34884_VO = item0;
            item999.address.street = "Street999";

            //then
            var item999Index:int = _sut.getItemIndex(item0);
            assertEquals(0, item999Index);
        }

        [Test]
        public function getItemIndex_finds_item_in_complex_descending_sorted_list_after_its_repositioned_in_middle_due_to_its_sort_field_changing():void
        {
            //given
            var from0To4:IList = generateVOs(5);
            _sut.addAll(from0To4); //values[address.street]: Street0, Street1, Street2, Street3, Street4

            const sortByIndexDescending:Sort = new Sort();
            sortByIndexDescending.fields = [new ComplexSortField("address.street", false, true, false)];
            _sut.sort = sortByIndexDescending;
            _sut.refresh(); //values[address.street]: Street4, Street3, Street2, Street1, Street0

            _sut.complexFieldWatcher = new ComplexFieldChangeWatcher();

            //when
            var item2:FLEX_34884_VO = from0To4.getItemAt(2) as FLEX_34884_VO;
            item2.address.street = "Street9"; //values[address.street]: Street9, Street4, Street3, Street1, Street0

            var item0:FLEX_34884_VO = from0To4.getItemAt(0) as FLEX_34884_VO;
            item0.address.street = "Street2"; //values[address.street]: Street9, Street4, Street3, Street2, Street1

            //then
            var street2Index:int = _sut.getItemIndex(item0);
            assertEquals(3, street2Index);
        }

        [Test]
        public function getItemIndex_finds_newly_inserted_item_in_complex_descending_sorted_list():void
        {
            //given
            var from0To4:IList = generateVOs(5);
            _sut.addAll(from0To4); //values[address.street]: Street0, Street1, Street2, Street3, Street4

            const sortByStreetDescending:Sort = new Sort();
            sortByStreetDescending.fields = [new ComplexSortField("address.street", false, true, false)];
            _sut.sort = sortByStreetDescending;
            _sut.refresh(); //values[address.street]: Street4, Street3, Street2, Street1, Street0

            _sut.complexFieldWatcher = new ComplexFieldChangeWatcher();

            //when
            var newItem:FLEX_34884_VO = generateOneObject(9);
            _sut.addItemAt(newItem, _sut.length - 1); //values[address.street]: Street9, Street4, Street3, Street2, Street1, Street0

            //then
            assertEquals(0, _sut.getItemIndex(newItem));
        }

        [Test]
        public function getItemIndex_finds_newly_inserted_item_in_complex_multi_field_sorted_list():void
        {
            //given
            var from0To4:IList = generateVOs(5);
            _sut.addAll(from0To4); //values[address.street/index]: Street0/0, Street1/1, Street2/2, Street3/3, Street4/4

            const sortByStreetAndIndex:Sort = new Sort();
            sortByStreetAndIndex.fields = [new ComplexSortField("address.street", false, true, false), new SortField("index", false, true)];
            _sut.sort = sortByStreetAndIndex;
            _sut.refresh(); //values[address.street/index]: Street4/4, Street3/3, Street2/2, Street1/1, Street0/0

            _sut.complexFieldWatcher = new ComplexFieldChangeWatcher();

            //when
            var newItem:FLEX_34884_VO = generateOneObject(9);
            newItem.address.street = "Street4";
            _sut.addItemAt(newItem, _sut.length - 1); //values[address.street/index]: Street4/4, Street4/9, Street3/3, Street2/2, Street1/1, Street0/0

            //then
            assertEquals(1, _sut.getItemIndex(newItem));
        }

        [Test]
        public function getItemIndex_finds_newly_inserted_item_in_complex_descending_sorted_list_after_its_sort_field_changes():void
        {
            //given
            var from0To4:IList = generateVOs(5);
            _sut.addAll(from0To4); //values[address.street]: Street0, Street1, Street2, Street3, Street4

            const sortByIndexDescending:Sort = new Sort();
            sortByIndexDescending.fields = [new ComplexSortField("address.street", false, true, false)];
            _sut.sort = sortByIndexDescending;
            _sut.refresh(); //values[address.street]: Street4, Street3, Street2, Street1, Street0

            _sut.complexFieldWatcher = new ComplexFieldChangeWatcher();

            //when
            var newItem:FLEX_34884_VO = generateOneObject(1);
            _sut.addItemAt(newItem, _sut.length - 1); //values[address.street]: Street4, Street3, Street2, Street1, Street1, Street0

            newItem.address.street = "Street3"; //values[address.street]: Street4, Street3, Street3, Street2, Street1, Street1, Street0

            //then
            var newItemIndex:int = _sut.getItemIndex(newItem);
            assertThat(newItemIndex == 1 || newItemIndex == 2);
        }

        private static function generateVOs(no:int, reverse:Boolean = false):IList
        {
            return generateObjects(no, reverse, generateOneObject);
        }

        private static function generateObjects(no:int, reverse:Boolean, generator:Function):IList
        {
            var result:Array = [];
            for(var i:int = 0; i < no; i++)
            {
                result.push(generator(i));
            }

            if(reverse)
                result.reverse();

            return new ArrayList(result);
        }

        private static function generateOneObject(i:Number):FLEX_34884_VO
        {
            return new FLEX_34884_VO(i, "Object", "Street");
        }
    }
}

[Bindable]
class FLEX_34884_VO
{
    public var name:String;
    public var address:FLEX_34884_AddressVO;
    public var index:Number;

    public function FLEX_34884_VO(index:Number, namePrefix:String, streetPrefix:String)
    {
        this.index = index;
        this.name = namePrefix + index;
        this.address = new FLEX_34884_AddressVO(streetPrefix + index);
    }
}

[Bindable]
class FLEX_34884_AddressVO
{
    public var street:String;

    public function FLEX_34884_AddressVO(street:String)
    {
        this.street = street;
    }
}