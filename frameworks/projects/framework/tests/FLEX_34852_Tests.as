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
    import mx.collections.ComplexSortField;
    import mx.collections.IList;
    import mx.collections.ListCollectionView;
    import mx.collections.Sort;
    import mx.collections.SortFieldCompareTypes;

    import org.flexunit.asserts.assertEquals;
    import org.flexunit.asserts.assertTrue;

    public class FLEX_34852_Tests {
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
        public function test_ascending_sort_by_complex_string_fields():void
        {
            //given
            var from4To0:IList = generateVOs(5, true);
            _sut.addAll(from4To0); //values["address.street"]: Street4, Street3, Street2, Street1, Street0

            const sortByStreetAscending:Sort = new Sort();
            sortByStreetAscending.fields = [new ComplexSortField("address.street", false, false, false)];
            _sut.sort = sortByStreetAscending;

            //when
            _sut.refresh(); //should be: Street0, Street1, Street2, Street3, Street4

            //then
            assertIndexesAre([0, 1, 2, 3, 4]);
        }

        [Test]
        public function test_finding_items_works_after_ascending_sort_by_complex_string_fields():void
        {
            //given
            var from4To0:IList = generateVOs(5, true);
            _sut.addAll(from4To0); //values["address.street"]: Street4, Street3, Street2, Street1, Street0

            const sortByStreetAscending:Sort = new Sort();
            sortByStreetAscending.fields = [new ComplexSortField("address.street", false, false, false)];
            _sut.sort = sortByStreetAscending;

            //when
            _sut.refresh(); //should be: Street0, Street1, Street2, Street3, Street4

            //then
            for(var i:int = 0; i < from4To0.length; i++)
            {
                var vo:FLEX_34852_VO = from4To0.getItemAt(i) as FLEX_34852_VO;
                assertEquals(vo.index, _sut.getItemIndex(vo));
            }
        }

        [Test]
        public function test_simple_descending_sort_by_complex_string_fields():void
        {
            //given
            var from0To4:IList = generateVOs(5);
            _sut.addAll(from0To4); //values["address.street"]: Street0, Street1, Street2, Street3, Street4

            const sortByStreetDescending:Sort = new Sort();
            sortByStreetDescending.fields = [new ComplexSortField("address.street", false, true, false)];
            _sut.sort = sortByStreetDescending;

            //when
            _sut.refresh(); //should be: Street4, Street3, Street2, Street1, Street0

            //then
            assertIndexesAre([4, 3, 2, 1, 0]);
        }

        [Test]
        public function test_simple_ascending_sort_by_complex_string_fields_with_unique_field():void
        {
            //given
            var from4To0:IList = generateVOs(5, true);
            _sut.addAll(from4To0); //values["address.street"]: Street4, Street3, Street2, Street1, Street0

            const sortByStreetAscending:Sort = new Sort();
            sortByStreetAscending.fields = [new ComplexSortField("address.street", false, false, false)];
            sortByStreetAscending.unique = true;
            _sut.sort = sortByStreetAscending;

            //when
            _sut.refresh(); //should be: Street0, Street1, Street2, Street3, Street4

            //then
            assertIndexesAre([0, 1, 2, 3, 4]);
        }

        [Test(expects="Error")]
        public function test_simple_ascending_sort_by_complex_string_fields_with_unique_flag_and_duplicating_field_throws_error():void
        {
            //given
            var from4To0:IList = generateVOs(5, true);
            _sut.addAll(from4To0); //values["address.street"]: Street4, Street3, Street2, Street1, Street0
            FLEX_34852_VO(_sut.getItemAt(0)).address.street = "Street0"; //making sure there's a duplicate

            const sortByStreetAscending:Sort = new Sort();
            sortByStreetAscending.fields = [new ComplexSortField("address.street", false, false, false)];
            sortByStreetAscending.unique = true;
            _sut.sort = sortByStreetAscending;

            //when
            _sut.refresh(); //should throw an error about there being a duplicate value
        }

        [Test]
        public function test_simple_ascending_sort_by_complex_date_fields():void
        {
            //given
            var from2004To2000:IList = generateVOs(5, true);
            _sut.addAll(from2004To2000); //values["address.dateMovedIn"].getYear(): 2004, 2003, 2002, 2001, 2000

            const sortByDateMovedInAscending:Sort = new Sort();
            var complexSortField:ComplexSortField = new ComplexSortField("address.dateMovedIn", false, false, false);
            complexSortField.sortCompareType = SortFieldCompareTypes.DATE;
            sortByDateMovedInAscending.fields = [complexSortField];
            _sut.sort = sortByDateMovedInAscending;

            //when
            _sut.refresh(); //should be: 2000, 2001, 2002, 2003, 2004

            //then
            assertIndexesAre([0, 1, 2, 3, 4]);
        }

        [Test]
        public function test_simple_descending_sort_by_complex_date_fields():void
        {
            //given
            var from2000To2004:IList = generateVOs(5);
            _sut.addAll(from2000To2004); //values["address.dateMovedIn"].getYear(): 2000, 2001, 2002, 2003, 2004

            const sortByDateMovedInDescending:Sort = new Sort();
            var complexSortField:ComplexSortField = new ComplexSortField("address.dateMovedIn", false, true, false);
            complexSortField.sortCompareType = SortFieldCompareTypes.DATE;
            sortByDateMovedInDescending.fields = [complexSortField];
            _sut.sort = sortByDateMovedInDescending;

            //when
            _sut.refresh(); //should be: 2004, 2003, 2002, 2001, 2000

            //then
            assertIndexesAre([4, 3, 2, 1, 0]);
        }

        [Test]
        public function test_simple_ascending_sort_by_complex_number_fields():void
        {
            //given
            var from4To0:IList = generateVOs(5, true);
            _sut.addAll(from4To0); //values["address.houseNumber"]: 4, 3, 2, 1, 0

            const sortByHouseNumberAscending:Sort = new Sort();
            sortByHouseNumberAscending.fields = [new ComplexSortField("address.houseNumber", false, false, true)];
            _sut.sort = sortByHouseNumberAscending;

            //when
            _sut.refresh(); //should be: 0, 1, 2, 3, 4

            //then
            assertIndexesAre([0, 1, 2, 3, 4]);
        }

        [Test]
        public function test_simple_descending_sort_by_complex_number_fields():void
        {
            //given
            var from4To0:IList = generateVOs(5);
            _sut.addAll(from4To0); //values["address.houseNumber"]: 0, 1, 2, 3, 4

            const sortByHouseNumberDescending:Sort = new Sort();
            sortByHouseNumberDescending.fields = [new ComplexSortField("address.houseNumber", false, true, true)];
            _sut.sort = sortByHouseNumberDescending;

            //when
            _sut.refresh(); //should be: 4, 3, 2, 1, 0

            //then
            assertIndexesAre([4, 3, 2, 1, 0]);
        }

        [Test]
        public function test_simple_ascending_sort_with_empty_field_name_should_not_throw_error():void
        {
            //given
            var from4To0:IList = generateVOs(5, true);
            _sut.addAll(from4To0); //values["index"]: 4, 3, 2, 1, 0

            const sortByNothingAscending:Sort = new Sort();
            sortByNothingAscending.fields = [new ComplexSortField("", false, false)];
            _sut.sort = sortByNothingAscending;

            //when
            _sut.refresh(); //just make sure it doesn't throw an error.

            //then - we cannot guarantee the order of the items because SortField.nullCompare returns 0 in this
            // situation, so we just make sure there's no error
            assertTrue(true);
        }

        [Test]
        public function test_simple_ascending_sort_with_erroneous_field_name_should_not_throw_error():void
        {
            //given
            var from4To0:IList = generateVOs(5, true);
            _sut.addAll(from4To0); //values["index"]: 4, 3, 2, 1, 0

            const sortByNothingAscending:Sort = new Sort();
            sortByNothingAscending.fields = [new ComplexSortField("aFieldThatDoesntExist", false, false)];
            _sut.sort = sortByNothingAscending;

            //when
            _sut.refresh(); //just make sure it doesn't throw an error.

            //then - we cannot guarantee the order of the items because SortField.nullCompare returns 0 in this
            // situation, so we just make sure there's no error
            assertTrue(true);
        }




        private function assertIndexesAre(indexes:Array):void
        {
            assertEquals(indexes.length, _sut.length);

            for(var i:int = 0; i < _sut.length; i++)
            {
                assertEquals(FLEX_34852_VO(_sut.getItemAt(i)).index, indexes[i]);
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

        private static function generateOneObject(i:Number):FLEX_34852_VO
        {
            return new FLEX_34852_VO(i, "Object", "Street");
        }
    }
}

[Bindable]
class FLEX_34852_VO
{
    public var name:String;
    public var address:FLEX_34852_AddressVO;
    public var index:Number;

    public function FLEX_34852_VO(index:Number, namePrefix:String, streetPrefix:String)
    {
        this.index = index;
        this.name = namePrefix + index;
        this.address = new FLEX_34852_AddressVO(streetPrefix + index, Math.floor(index), new Date(2000 + Math.floor(index), 0, 0, 0, 0, 0, 1));
    }
}

[Bindable]
class FLEX_34852_AddressVO
{
    public var street:String;
    public var houseNumber:int;
    public var dateMovedIn:Date;

    public function FLEX_34852_AddressVO(street:String, houseNumber:int, dateMovedIn:Date)
    {
        this.street = street;
        this.houseNumber = houseNumber;
        this.dateMovedIn = dateMovedIn;
    }
}