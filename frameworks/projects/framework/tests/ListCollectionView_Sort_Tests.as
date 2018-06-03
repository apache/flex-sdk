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
    import mx.collections.IList;
    import mx.collections.ListCollectionView;

    import org.flexunit.assertThat;

    import org.flexunit.asserts.assertEquals;

    import mx.collections.Sort;
    import mx.collections.SortField;

    public class ListCollectionView_Sort_Tests {
        private var _sut:ListCollectionView;

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
        public function test_numeric_descending_sort_on_simple_objects():void
        {
            //given
            var from0To4:IList = generateNumbers(5);
            _sut.addAll(from0To4); //values: 0, 1, 2, 3, 4

            const sortByIndexDescending:Sort = new Sort();
            sortByIndexDescending.fields = [new SortField(null, false, true, true)];
            _sut.sort = sortByIndexDescending;

            //when
            _sut.refresh(); //should be: 4, 3, 2, 1, 0

            //then
            assertItemsAre([4, 3, 2, 1, 0]);
            assertRemoveAll();
        }

        [Test]
        public function test_numeric_descending_sort_on_simple_objects_adds_new_object_in_right_place():void
        {
            //given
            var from0To4:IList = generateNumbers(5);
            _sut.addAll(from0To4); //values: 0, 1, 2, 3, 4

            const sortByIndexDescending:Sort = new Sort();
            sortByIndexDescending.fields = [new SortField(null, false, true, true)];
            _sut.sort = sortByIndexDescending;
            _sut.refresh(); //values: 4, 3, 2, 1, 0

            //when
            _sut.addItem(5); //should be: 5, 4, 3, 2, 1, 0

            //then
            assertItemsAre([5, 4, 3, 2, 1, 0]);
            assertRemoveAll();
        }

        [Test]
        public function test_numeric_descending_sort_on_simple_objects_removes_object_correctly():void
        {
            //given
            var from0To4:IList = generateNumbers(5);
            _sut.addAll(from0To4); //values: 0, 1, 2, 3, 4

            const sortByIndexDescending:Sort = new Sort();
            sortByIndexDescending.fields = [new SortField(null, false, true, true)];
            _sut.sort = sortByIndexDescending;
            _sut.refresh(); //values: 4, 3, 2, 1, 0

            //when
            _sut.removeItem(3); //should be: 4, 2, 1, 0

            //then
            assertItemsAre([4, 2, 1, 0]);
            assertRemoveAll();
        }

        [Test]
        public function test_numeric_descending_sort_on_simple_objects_removes_object_at_index_correctly():void
        {
            //given
            var from0To4:IList = generateNumbers(5);
            _sut.addAll(from0To4); //values: 0, 1, 2, 3, 4

            const sortByIndexDescending:Sort = new Sort();
            sortByIndexDescending.fields = [new SortField(null, false, true, true)];
            _sut.sort = sortByIndexDescending;
            _sut.refresh(); //values: 4, 3, 2, 1, 0

            //when
            _sut.removeItemAt(3); //should be: 4, 3, 2, 0

            //then
            assertItemsAre([4, 3, 2, 0]);
            assertRemoveAll();
        }

        [Test]
        public function test_numeric_descending_sort_on_simple_objects_moves_replaced_object_in_right_place():void
        {
            //given
            var from0To4:IList = generateNumbers(5);
            _sut.addAll(from0To4); //values: 0, 1, 2, 3, 4

            const sortByIndexDescending:Sort = new Sort();
            sortByIndexDescending.fields = [new SortField(null, false, true, true)];
            _sut.sort = sortByIndexDescending;
            _sut.refresh(); //values: 4, 3, 2, 1, 0

            //when
            _sut.setItemAt(100, 3); //before re-sort: 4, 3, 2, 100, 0

            //then
            assertItemsAre([100, 4, 3, 2, 0]);
            assertRemoveAll();
        }

        [Test]
        public function test_numeric_descending_sort_on_simple_objects_adds_new_identical_object_in_right_place():void
        {
            //given
            var from0To4:IList = generateNumbers(5);
            _sut.addAll(from0To4); //values: 0, 1, 2, 3, 4

            const sortByIndexDescending:Sort = new Sort();
            sortByIndexDescending.fields = [new SortField(null, false, true, true)];
            _sut.sort = sortByIndexDescending;
            _sut.refresh(); //values: 4, 3, 2, 1, 0

            //when
            _sut.addItem(3); //should be: 5, 4, 3, 2, 1, 0

            //then
            assertItemsAre([4, 3, 3, 2, 1, 0]);
            assertRemoveAll();
        }

        [Test]
        public function test_numeric_descending_sort_on_simple_objects_adds_new_identical_object_in_right_place_even_with_addItemAt():void
        {
            //given
            var from0To4:IList = generateNumbers(5);
            _sut.addAll(from0To4); //values: 0, 1, 2, 3, 4

            const sortByIndexDescending:Sort = new Sort();
            sortByIndexDescending.fields = [new SortField(null, false, true, true)];
            _sut.sort = sortByIndexDescending;
            _sut.refresh(); //values: 4, 3, 2, 1, 0

            //when
            _sut.addItemAt(3, 0); //should be: 5, 4, 3, 2, 1, 0

            //then
            assertItemsAre([4, 3, 3, 2, 1, 0]);
            assertRemoveAll();
        }


        [Test]
        public function test_numeric_descending_sort_on_complex_objects():void
        {
            //given
            var from0To4:IList = generateVOs(5);
            _sut.addAll(from0To4); //values["name"]: Object0, Object1, Object2, Object3, Object4

            const sortByIndexDescending:Sort = new Sort();
            sortByIndexDescending.fields = [new SortField("index", false, true, true)];
            _sut.sort = sortByIndexDescending;

            //when
            _sut.refresh(); //should be: Object4, Object3, Object2, Object1, Object0

            //then
            assertIndexesAre([4, 3, 2, 1, 0]);
            assertGetItemIndex(from0To4);
            assertRemoveAll();
        }

        [Test]
        public function test_multiple_sort_fields_on_complex_objects():void
        {
            //given
            var from0To4:IList = generateVOs(5);
            _sut.addAll(from0To4); //values["name"]: Object0, Object1, Object2, Object3, Object4
            const abc2:ListCollectionView_Sort_VO = generateOneObject(2, "ABC");
            _sut.addItem(abc2); //values["name"]: Object0, Object1, Object2, Object3, Object4, ABC2

            const sortByIndexDescending:Sort = new Sort();
            sortByIndexDescending.fields = [new SortField("index", false, true, true), new SortField("name", false, false, false)];
            _sut.sort = sortByIndexDescending;

            //when
            _sut.refresh(); //should be: Object0, Object1, ABC2, Object2, Object3, Object4

            //then
            assertIndexesAre([4, 3, 2, 2, 1, 0]);
            assertNamesAre(["Object4", "Object3", "ABC2", "Object2", "Object1", "Object0"]);

            const itemsInSUT:ListCollectionView = new ListCollectionView(new ArrayList());
            itemsInSUT.addAll(from0To4);
            itemsInSUT.addItem(abc2);
            assertGetItemIndex(itemsInSUT);

            assertRemoveAll();
        }

        [Test]
        public function test_numeric_descending_sort_on_complex_objects_adds_new_objects_in_right_place():void
        {
            //given
            var from0To4:IList = generateVOs(5);
            _sut.addAll(from0To4); //values["name"]: Object0, Object1, Object2, Object3, Object4

            const sortByIndexDescending:Sort = new Sort();
            sortByIndexDescending.fields = [new SortField("index", false, true, true)];
            _sut.sort = sortByIndexDescending;
            _sut.refresh(); //values["name"]: Object4, Object3, Object2, Object1, Object0

            //when
            const item6:ListCollectionView_Sort_VO = generateOneObject(6);
            _sut.addItem(item6);
            const item3_5:ListCollectionView_Sort_VO = generateOneObject(3.5);
            _sut.addItem(item3_5);

            //then
            assertIndexesAre([6, 4, 3.5, 3, 2, 1, 0]);

            const itemsInSUT:ListCollectionView = new ListCollectionView(new ArrayList());
            itemsInSUT.addAll(from0To4);
            itemsInSUT.addItem(item6);
            itemsInSUT.addItem(item3_5);
            assertGetItemIndex(itemsInSUT);

            assertRemoveAll();
        }

        [Test]
        public function test_numeric_descending_sort_on_complex_objects_moves_replaced_object_in_right_place():void
        {
            //given
            var from0To4:IList = generateVOs(5);
            _sut.addAll(from0To4); //values["name"]: Object0, Object1, Object2, Object3, Object4

            const sortByIndexDescending:Sort = new Sort();
            sortByIndexDescending.fields = [new SortField("index", false, true, true)];
            _sut.sort = sortByIndexDescending;
            _sut.refresh(); //values["name"]: Object4, Object3, Object2, Object1, Object0

            //when
            const addedItem:ListCollectionView_Sort_VO = generateOneObject(6);
            _sut.setItemAt(addedItem, 1);

            //then
            assertIndexesAre([6, 4, 2, 1, 0]);
            const itemsInSUT:ListCollectionView = new ListCollectionView(new ArrayList());
            itemsInSUT.addAll(from0To4);
            itemsInSUT.setItemAt(addedItem, 3);
            assertGetItemIndex(itemsInSUT);

            assertRemoveAll();
        }

        [Test]
        public function test_simple_numeric_ascending_sort_on_complex_objects():void
        {
            //given
            var from4To0:IList = generateVOs(5, true);
            _sut.addAll(from4To0); //values["name"]: Object4, Object3, Object2, Object1, Object0

            const sortByIndexAscending:Sort = new Sort();
            sortByIndexAscending.fields = [new SortField("index", false, false, true)];
            _sut.sort = sortByIndexAscending;

            //when
            _sut.refresh(); //should be: Object0, Object1, Object2, Object3, Object4

            //then
            assertIndexesAre([0, 1, 2, 3, 4]);
            assertGetItemIndex(from4To0);

            assertRemoveAll();
        }

        [Test]
        public function test_simple_numeric_ascending_sort_on_complex_objects_with_dot_in_property_name():void
        {
            //given
            var from4To0:IList = generateVOs(5, true);

            const fieldName:String = "property.with.dot";
            for(var i:int = 0; i < from4To0.length; i++)
            {
                var object:ListCollectionView_Sort_VO = from4To0.getItemAt(i) as ListCollectionView_Sort_VO;
                object[fieldName] = object.index;
            }
            _sut.addAll(from4To0); //values["name"]: Object4, Object3, Object2, Object1, Object0

            const sortByIndexAscending:Sort = new Sort();
            sortByIndexAscending.fields = [new SortField(fieldName, false, false, true)];
            _sut.sort = sortByIndexAscending;

            //when
            _sut.refresh(); //should be: Object0, Object1, Object2, Object3, Object4

            //then
            assertIndexesAre([0, 1, 2, 3, 4]);
            assertGetItemIndex(from4To0);
            assertRemoveAll();
        }


        [Test(description="Testing that changing the properties of the Sort doesn't impact the actual sort order")]
        public function test_sort_fields_on_complex_objects_dont_change_unless_sort_reapplied():void
        {
            //given
            var from4To0:IList = generateVOs(5, true);
            _sut.addAll(from4To0); //values["name"]: Object4, Object3, Object2, Object1, Object0

            const sortByIndexAscending:Sort = new Sort();
            var originalSortField:SortField = new SortField("index", false, false, true);
            sortByIndexAscending.fields = [originalSortField];
            _sut.sort = sortByIndexAscending;
            _sut.refresh(); //should be: Object0, Object1, Object2, Object3, Object4

            //when
            sortByIndexAscending.fields = [new SortField("name", false, true, false)]; //should have no effect

            //then
            assertIndexesAre([0, 1, 2, 3, 4]);
            sortByIndexAscending.fields = [originalSortField]; //TODO remove once FLEX-34853 is fixed
            assertGetItemIndex(from4To0);
            assertRemoveAll();
        }

        [Test]
        public function test_marking_entire_item_as_updated_gets_the_old_object_out_of_the_list():void
        {
            //given
            var from0To4:IList = generateVOs(5, true); //values["name"]: Object4, Object3, Object2, Object1, Object0
            _sut.addAll(from0To4);

            const sortByNameAscending:Sort = new Sort();
            sortByNameAscending.fields = [new SortField("name", false, false, false)];
            _sut.sort = sortByNameAscending;
            _sut.refresh(); //values["name"]: Object0, Object1, Object2, Object3, Object4

            //when
            const removedItem:ListCollectionView_Sort_VO = (_sut.list as ArrayList).source[0] as ListCollectionView_Sort_VO;
            const newItem:ListCollectionView_Sort_VO = generateOneObject(-1);
            (_sut.list as ArrayList).source[0] = newItem;
            _sut.itemUpdated(newItem, null, removedItem, newItem);

            removedItem.name = "Object7"; //should make no difference
            newItem.name = "Object9"; //should place it at the end of the list

            //then
            const indexOfRemovedItem:int = _sut.getItemIndex(removedItem);
            assertEquals("the item should have been removed from the list", -1, indexOfRemovedItem);
            for(var i:int = 0; i < _sut.length; i++)
            {
                assertThat(_sut.getItemAt(i) != removedItem);
            }
            assertEquals("the new item should have been moved to the end of the list", _sut.length - 1, _sut.getItemIndex(newItem));
        }

        private function assertIndexesAre(indexes:Array):void
        {
            assertFieldValuesAre("index", indexes);
        }

        private function assertNamesAre(names:Array):void
        {
            assertFieldValuesAre("name", names);
        }

        private function assertFieldValuesAre(field:String, values:Array):void
        {
            assertEquals(values.length, _sut.length);

            for(var i:int = 0; i < _sut.length; i++)
            {
                assertEquals(ListCollectionView_Sort_VO(_sut.getItemAt(i))[field], values[i]);
            }
        }

        private function assertItemsAre(indexes:Array):void
        {
            assertEquals(indexes.length, _sut.length);

            for(var i:int = 0; i < _sut.length; i++)
            {
                assertEquals(indexes[i], _sut.getItemAt(i));
            }
        }

        private function assertGetItemIndex(items:IList):void
        {
            for(var i:int = 0; i < items.length; i++)
            {
                var target:ListCollectionView_Sort_VO = items.getItemAt(i) as ListCollectionView_Sort_VO;
                assertThat("could not find " + target.name, _sut.getItemIndex(target) != -1); //in some bugs, an RTE is thrown here
            }
        }

        private function assertRemoveAll():void
        {
            _sut.removeAll(); //in some bugs, an RTE is thrown here
            assertEquals(0, _sut.length);
        }


        private static function generateVOs(no:int, reverse:Boolean = false):IList
        {
            return generateObjects(no, reverse, generateOneObject);
        }

        private static function generateNumbers(no:int, reverse:Boolean = false):IList
        {
            return generateObjects(no, reverse, generateOneNumber);
        }

        private static function generateObjects(no:int, reverse:Boolean = false, generator:Function = null):IList
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

        private static function generateOneObject(index:Number, name:String = "Object"):ListCollectionView_Sort_VO
        {
            return new ListCollectionView_Sort_VO(index, name, "Street");
        }

        private static function generateOneNumber(value:Number):Number
        {
            return value;
        }
    }
}

[Bindable]
dynamic class ListCollectionView_Sort_VO
{
    public var name:String;
    public var address:ListCollectionView_Sort_AddressVO;
    public var index:Number;

    public function ListCollectionView_Sort_VO(index:Number, namePrefix:String, streetPrefix:String)
    {
        this.index = index;
        this.name = namePrefix + index;
        this.address = new ListCollectionView_Sort_AddressVO(streetPrefix + index);
    }
}

[Bindable]
class ListCollectionView_Sort_AddressVO
{
    public var street:String;

    public function ListCollectionView_Sort_AddressVO(street:String)
    {
        this.street = street;
    }
}