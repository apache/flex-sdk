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

    import org.flexunit.asserts.assertEquals;

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
            return new FLEX_34852_VO(i, "Object"+i, "Street"+i);
        }
    }
}

class FLEX_34852_VO
{
    [Bindable]
    public var name:String;

    [Bindable]
    public var address:FLEX_34852_AddressVO;

    [Bindable]
    public var index:Number;

    public function FLEX_34852_VO(index:Number, namePrefix:String, streetPrefix:String)
    {
        this.index = index;
        this.name = namePrefix + index;
        this.address = new FLEX_34852_AddressVO(streetPrefix + index);
    }
}

class FLEX_34852_AddressVO
{
    [Bindable]
    public var street:String;

    public function FLEX_34852_AddressVO(street:String)
    {
        this.street = street;
    }
}