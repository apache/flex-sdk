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
    import mx.collections.Sort;
    import mx.collections.SortField;
    import mx.utils.ObjectUtil;

    import org.flexunit.asserts.assertEquals;

    public class ListCollectionView_FLEX_34837_Tests {
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
        public function test_simple_ascending_sort_by_complex_fields():void
        {
            //given
            var from4To0:IList = generateVOs(5, true);
            _sut.addAll(from4To0); //values["address.street"]: Street4, Street3, Street2, Street1, Street0

            const sortByIndexAscending:Sort = new Sort();
            sortByIndexAscending.fields = [new SortField("address.street", false, false, false)];
            _sut.sort = sortByIndexAscending;

            //when
            _sut.refresh(); //should be: Street0, Street1, Street2, Street3, Street4

            //then
            assertIndexesAre([0, 1, 2, 3, 4]);
        }

        [Test]
        public function test_simple_sort_by_complex_fields_with_custom_compare_function_for_sort():void
        {
            function compareByStreet(a:ListCollectionView_FLEX_34837_VO, b:ListCollectionView_FLEX_34837_VO, fields:Array):int
            {
                var streetA:String = a.address ? a.address.street : null;
                var streetB:String = b.address ? b.address.street : null;

                return ObjectUtil.stringCompare(streetA, streetB, true);
            }

            //given
            var from4To0:IList = generateVOs(5, true);
            _sut.addAll(from4To0); //values["address.street"]: Street4, Street3, Street2, Street1, Street0

            const sortByStreetAscending:Sort = new Sort();
            sortByStreetAscending.fields = [new SortField("address.street", false, false, false)]; //should make no difference
            sortByStreetAscending.compareFunction = compareByStreet;
            _sut.sort = sortByStreetAscending;

            //when
            _sut.refresh(); //should be: Street0, Street1, Street2, Street3, Street4

            //then
            assertIndexesAre([0, 1, 2, 3, 4]);
        }

        [Test]
        public function test_simple_sort_by_complex_fields_with_custom_compare_function_for_sort_field():void
        {
            function compareByStreet(a:ListCollectionView_FLEX_34837_VO, b:ListCollectionView_FLEX_34837_VO):int
            {
                var streetA:String = a.address ? a.address.street : null;
                var streetB:String = b.address ? b.address.street : null;

                return ObjectUtil.stringCompare(streetA, streetB, true);
            }

            //given
            var from4To0:IList = generateVOs(5, true);
            _sut.addAll(from4To0); //values["address.street"]: Street4, Street3, Street2, Street1, Street0

            const sortByStreetAscending:Sort = new Sort();
            var sortField:SortField = new SortField("address.street", false, false, false);
            sortField.compareFunction = compareByStreet;
            sortByStreetAscending.fields = [sortField];
            _sut.sort = sortByStreetAscending;

            //when
            _sut.refresh(); //should be: Street0, Street1, Street2, Street3, Street4

            //then
            assertIndexesAre([0, 1, 2, 3, 4]);
        }

        [Test]
        public function test_changing_simple_sort_field_value_places_it_correctly_according_to_collection_sort():void
        {
            //given
            var from1To4:IList = generateVOs(5);
            from1To4.removeItemAt(0);
            _sut.addAll(from1To4);

            const sortByNameAscending:Sort = new Sort();
            sortByNameAscending.fields = [new SortField("name", false, false, false)];
            _sut.sort = sortByNameAscending;
            _sut.refresh(); //values: Object1, Object2, Object3, Object4

            //when
            const newItem:ListCollectionView_FLEX_34837_VO = generateOneObject(5);
            _sut.addItem(newItem); //values: Object1, Object2, Object3, Object4, Object5
            newItem.name = "Object0"; //this should immediately place the newItem at position 0

            //then
            const newItemIndex:int = _sut.getItemIndex(newItem);
            assertEquals("the new item should have been placed at the beginning of the list as soon as its name was changed", 0, newItemIndex);
        }

        [Test]
        public function test_changing_complex_sort_field_value_places_it_correctly_according_to_collection_sort():void
        {
            //given
            var from1To4:IList = generateVOs(5);
            from1To4.removeItemAt(0);
            _sut.addAll(from1To4);

            const sortByNameAscending:Sort = new Sort();
            sortByNameAscending.fields = [new SortField("address.street", false, false, false)];
            _sut.sort = sortByNameAscending;
            _sut.refresh(); //values: Object1, Object2, Object3, Object4

            //when
            const newItem:ListCollectionView_FLEX_34837_VO = generateOneObject(5);
            _sut.addItem(newItem); //values: Object1, Object2, Object3, Object4, Object5
            newItem.address.street = "Street0"; //this should immediately place the newItem at position 0

            //then
            const newItemIndex:int = _sut.getItemIndex(newItem);
            assertEquals("the new item should have been placed at the beginning of the list as soon as its address's street name was changed", 0, newItemIndex);
            _sut.removeItemAt(_sut.getItemIndex(newItem)); //if the bug is present, this will throw an RTE
        }

        private function assertIndexesAre(indexes:Array):void
        {
            assertEquals(indexes.length, _sut.length);

            for(var i:int = 0; i < _sut.length; i++)
            {
                assertEquals(ListCollectionView_FLEX_34837_VO(_sut.getItemAt(i)).index, indexes[i]);
            }
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

        private static function generateOneObject(index:Number):ListCollectionView_FLEX_34837_VO
        {
            return new ListCollectionView_FLEX_34837_VO(index, "Object", "Street");
        }
    }
}

class ListCollectionView_FLEX_34837_VO
{
    [Bindable]
    public var name:String;

    [Bindable]
    public var address:ListCollectionView_FLEX_34837_AddressVO;

    [Bindable]
    public var index:Number;

    public function ListCollectionView_FLEX_34837_VO(index:Number, namePrefix:String, streetPrefix:String)
    {
        this.index = index;
        this.name = namePrefix + index;
        this.address = new ListCollectionView_FLEX_34837_AddressVO(streetPrefix + index);
    }
}

class ListCollectionView_FLEX_34837_AddressVO
{
    [Bindable]
    public var street:String;

    public function ListCollectionView_FLEX_34837_AddressVO(street:String)
    {
        this.street = street;
    }
}