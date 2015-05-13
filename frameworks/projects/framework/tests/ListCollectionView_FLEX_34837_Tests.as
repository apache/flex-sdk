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

    import org.flexunit.asserts.assertEquals;

    import spark.collections.Sort;
    import spark.collections.SortField;

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
        public function test_changing_sort_field_value_places_it_correctly_according_to_collection_sort():void
        {
            //given
            var from1To4:IList = generateObjects(5);
            from1To4.removeItemAt(0);
            _sut.addAll(from1To4);

            const sortByNameAscending:Sort = new Sort();
            sortByNameAscending.fields = [new SortField("name", false, false)];
            _sut.sort = sortByNameAscending;
            _sut.refresh(); //values: Object1, Object2, Object3, Object4

            //when
            const newItem:ListCollectionViewTestVO = generateOneObject(5);
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
            var from1To4:IList = generateObjects(5);
            from1To4.removeItemAt(0);
            _sut.addAll(from1To4);

            const sortByNameAscending:Sort = new Sort();
            sortByNameAscending.fields = [new SortField("address.street", false, false)];
            _sut.sort = sortByNameAscending;
            _sut.refresh(); //values: Object1, Object2, Object3, Object4

            //when
            const newItem:ListCollectionViewTestVO = generateOneObject(5);
            _sut.addItem(newItem); //values: Object1, Object2, Object3, Object4, Object5
            newItem.address.street = "Street0"; //this should immediately place the newItem at position 0

            //then
            const newItemIndex:int = _sut.getItemIndex(newItem);
            assertEquals("the new item should have been placed at the beginning of the list as soon as its name was changed", 0, newItemIndex);
            _sut.removeItemAt(_sut.getItemIndex(newItem)); //if the bug is present, this will throw an RTE
        }

        private function generateObjects(no:int):IList
        {
            var result:ArrayList = new ArrayList();
            for(var i:int = 0; i < no; i++)
            {
                result.addItem(generateOneObject(i));
            }

            return result;
        }

        private static function generateOneObject(i:int):ListCollectionViewTestVO
        {
            return new ListCollectionViewTestVO("Object"+i, "Street"+i);
        }
    }
}

class ListCollectionViewTestVO
{
    [Bindable]
    public var name:String;

    [Bindable]
    public var address:ListCollectionViewTestAddressVO;

    public function ListCollectionViewTestVO(name:String, street:String)
    {
        this.name = name;
        this.address = new ListCollectionViewTestAddressVO(street);
    }
}

class ListCollectionViewTestAddressVO
{
    [Bindable]
    public var street:String;

    public function ListCollectionViewTestAddressVO(street:String)
    {
        this.street = street;
    }
}