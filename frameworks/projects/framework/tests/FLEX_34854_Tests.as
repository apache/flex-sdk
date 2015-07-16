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
    import mx.collections.Sort;

    import org.flexunit.assertThat;

    import org.flexunit.asserts.assertEquals;

    public class FLEX_34854_Tests {
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
        public function test_changing_complex_sort_field_value_places_it_correctly_according_to_collection_sort():void
        {
            //given
            var from1To4:IList = generateVOs(5);
            from1To4.removeItemAt(0);
            _sut.addAll(from1To4);

            const sortByNameAscending:Sort = new Sort();
            sortByNameAscending.fields = [new ComplexSortField("address.street", false, false, false)];
            _sut.sort = sortByNameAscending;
            _sut.refresh(); //values: Object1, Object2, Object3, Object4

            _sut.complexFieldWatcher = new ComplexFieldChangeWatcher();

            //when
            const first:ListCollectionView_FLEX_34854_VO = _sut.getItemAt(0) as ListCollectionView_FLEX_34854_VO;
            first.address.street = "Street9"; //this should immediately place the newItem at the end

            //then
            const newItemIndex:int = _sut.getItemIndex(first);
            assertEquals("the new item should have been placed at the end of the list as soon as its address's street name was changed", _sut.length - 1, newItemIndex);
        }

        [Test]
        public function test_adding_and_changing_complex_sort_field_value_places_it_correctly_according_to_collection_sort():void
        {
            //given
            var from1To4:IList = generateVOs(5);
            from1To4.removeItemAt(0);
            _sut.addAll(from1To4);

            const sortByNameAscending:Sort = new Sort();
            sortByNameAscending.fields = [new ComplexSortField("address.street", false, false, false)];
            _sut.sort = sortByNameAscending;
            _sut.refresh(); //values: Object1, Object2, Object3, Object4

            _sut.complexFieldWatcher = new ComplexFieldChangeWatcher();

            //when
            const newItem:ListCollectionView_FLEX_34854_VO = generateOneObject(5);
            _sut.addItem(newItem); //values: Object1, Object2, Object3, Object4, Object5
            newItem.address.street = "Street0"; //this should immediately place the newItem at position 0

            //then
            const newItemIndex:int = _sut.getItemIndex(newItem);
            assertEquals("the new item should have been placed at the beginning of the list as soon as its address's street name was changed", 0, newItemIndex);
            _sut.removeItemAt(_sut.getItemIndex(newItem)); //if the bug is present, this will throw an RTE
        }

        [Test]
        public function test_removing_and_changing_complex_sort_field_value_keeps_it_away_from_collection():void
        {
            //given
            var from1To4:IList = generateVOs(5);
            from1To4.removeItemAt(0);
            _sut.addAll(from1To4);

            const sortByNameAscending:Sort = new Sort();
            sortByNameAscending.fields = [new ComplexSortField("address.street", false, false, false)];
            _sut.sort = sortByNameAscending;
            _sut.refresh(); //values: Object1, Object2, Object3, Object4

            _sut.complexFieldWatcher = new ComplexFieldChangeWatcher();

            //when
            const removedItem:ListCollectionView_FLEX_34854_VO = _sut.getItemAt(0) as ListCollectionView_FLEX_34854_VO;
            _sut.removeItemAt(0);
            removedItem.address.street = "Street22";

            //then
            const newItemIndex:int = _sut.getItemIndex(removedItem);
            assertEquals("the item should have been removed form the list", -1, newItemIndex);
            for(var i:int = 0; i < _sut.length; i++)
            {
                assertThat(_sut.getItemAt(i) != removedItem);
            }
        }

        [Test]
        public function test_replacing_and_changing_complex_sort_field_value_keeps_it_away_from_collection():void
        {
            //given
            var from1To4:IList = generateVOs(5);
            from1To4.removeItemAt(0);
            _sut.addAll(from1To4);

            const sortByNameAscending:Sort = new Sort();
            sortByNameAscending.fields = [new ComplexSortField("address.street", false, false, false)];
            _sut.sort = sortByNameAscending;
            _sut.refresh(); //values["address.street"]: Street1, Street2, Street3, Street4

            _sut.complexFieldWatcher = new ComplexFieldChangeWatcher();

            //when
            const replacedItem:ListCollectionView_FLEX_34854_VO = _sut.getItemAt(0) as ListCollectionView_FLEX_34854_VO;
            const newItem:ListCollectionView_FLEX_34854_VO = generateOneObject(9);
            _sut.setItemAt(newItem, 0);
            replacedItem.address.street = "Street9"; //should make no difference
            newItem.address.street = "Street5"; //should move it to the end of the list

            //then
            const indexOfRemovedItem:int = _sut.getItemIndex(replacedItem);
            assertEquals("the item should have been removed form the list", -1, indexOfRemovedItem);
            for(var i:int = 0; i < _sut.length; i++)
            {
                assertThat(_sut.getItemAt(i) != replacedItem);
            }
            assertEquals("the new item should have been moved to the end of the list", _sut.length - 1, _sut.getItemIndex(newItem));
        }

        [Test]
        public function test_replacing_list_and_changing_old_items_does_not_influence_current_list():void
        {
            //given
            var from0To4:IList = generateVOs(5);
            _sut.addAll(from0To4);

            _sut.complexFieldWatcher = new ComplexFieldChangeWatcher();

            const sortByNameAscending:Sort = new Sort();
            sortByNameAscending.fields = [new ComplexSortField("address.street", false, false, false)];
            _sut.sort = sortByNameAscending;
            _sut.refresh(); //values["address.street"]: Street0, Street1, Street2, Street3, Street4

            //when
            const firstItemFromOldList:ListCollectionView_FLEX_34854_VO = _sut.getItemAt(0) as ListCollectionView_FLEX_34854_VO;
            _sut.list = generateVOs(3); //values["address.street"]: Street0, Street1, Street2
            const firstItemFromNewList:ListCollectionView_FLEX_34854_VO = _sut.getItemAt(0) as ListCollectionView_FLEX_34854_VO;

            firstItemFromOldList.address.street = "Street9"; //should make no difference
            firstItemFromNewList.address.street = "Street9"; //should move it to the end of the list

            //then
            const indexOfRemovedItem:int = _sut.getItemIndex(firstItemFromOldList);
            assertEquals("the item should have been removed form the list", -1, indexOfRemovedItem);
            for(var i:int = 0; i < _sut.length; i++)
            {
                assertThat(_sut.getItemAt(i) != firstItemFromOldList);
            }
            assertEquals("the new item should have been moved to the end of the list", _sut.length - 1, _sut.getItemIndex(firstItemFromNewList));
        }

        [Test]
        public function test_marking_entire_item_as_updated_gets_the_old_object_out_of_the_list():void
        {
            //given
            var from0To4:IList = generateVOs(5, true); //values["address.street"]: Street4, Street3, Street2, Street1, Street0
            _sut.addAll(from0To4);

            _sut.complexFieldWatcher = new ComplexFieldChangeWatcher();

            const sortByNameAscending:Sort = new Sort();
            sortByNameAscending.fields = [new ComplexSortField("address.street", false, false, false)];
            _sut.sort = sortByNameAscending;
            _sut.refresh(); //values["name"]: Street0, Street1, Street2, Street3, Street4

            //when
            const removedItem:ListCollectionView_FLEX_34854_VO = (_sut.list as ArrayList).source[0] as ListCollectionView_FLEX_34854_VO;
            var newItem:ListCollectionView_FLEX_34854_VO = generateOneObject(-1);
            (_sut.list as ArrayList).source[0] = newItem;
            _sut.itemUpdated(newItem, null, removedItem, newItem);

            removedItem.address.street = "Street7"; //should make no difference
            newItem.address.street = "Street8"; //should place it at the end of the list

            //then
            const indexOfRemovedItem:int = _sut.getItemIndex(removedItem);
            assertEquals("the item should have been removed from the list", -1, indexOfRemovedItem);
            for(var i:int = 0; i < _sut.length; i++)
            {
                assertThat(_sut.getItemAt(i) != removedItem);
            }
            assertEquals("the new item should have been moved to the end of the list", _sut.length - 1, _sut.getItemIndex(newItem));
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

        private static function generateOneObject(i:Number):ListCollectionView_FLEX_34854_VO
        {
            return new ListCollectionView_FLEX_34854_VO(i, "Object", "Street");
        }
    }
}


[Bindable]
class ListCollectionView_FLEX_34854_VO
{
    public var name:String;
    public var address:ListCollectionView_FLEX_34854_AddressVO;
    public var index:Number;

    public function ListCollectionView_FLEX_34854_VO(index:Number, namePrefix:String, streetPrefix:String)
    {
        this.index = index;
        this.name = namePrefix + index;
        this.address = new ListCollectionView_FLEX_34854_AddressVO(streetPrefix + index);
    }
}

[Bindable]
class ListCollectionView_FLEX_34854_AddressVO
{
    public var street:String;

    public function ListCollectionView_FLEX_34854_AddressVO(street:String)
    {
        this.street = street;
    }
}