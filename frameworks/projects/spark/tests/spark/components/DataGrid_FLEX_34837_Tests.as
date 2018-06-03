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

package spark.components {
    import mx.collections.ArrayCollection;
    import mx.collections.ArrayList;
    import mx.collections.IList;
    import mx.collections.ListCollectionView;

    import org.flexunit.asserts.assertEquals;
    import org.flexunit.asserts.assertNotNull;
    import org.fluint.uiImpersonation.UIImpersonator;

    import spark.components.gridClasses.GridColumn;
    import spark.formatters.DateTimeFormatter;

    public class DataGrid_FLEX_34837_Tests {
        private var _sut:DataGrid;

        [Before]
        public function setUp():void
        {
            _sut = new DataGrid();
            _sut.width = 200;
            _sut.height = 200;
        }

        [After]
        public function tearDown():void
        {
            _sut = null;
        }

        [Test]
        public function test_removing_selected_item_on_complex_field_sorted_grid_after_renaming_it():void
        {
            //given
            var streetColumn:GridColumn = new GridColumn("address.street");
            _sut.columns = new ArrayCollection([streetColumn]);

            const tenObjects:IList = generateVOs(10);
            const firstObject:FLEX_34837_VO = tenObjects.getItemAt(0) as FLEX_34837_VO;
            const dataProvider:ListCollectionView = new ListCollectionView(tenObjects);

            //when
            UIImpersonator.addChild(_sut);
            assertNotNull("UIImpersonator doesn't work correctly!", _sut.grid);
            _sut.dataProvider = dataProvider;
            _sut.sortByColumns(new <int>[0]); //sort by address.street
            firstObject.address.street = "zzz"; //should move it at the end of the list

            //then
            assertEquals("The object should have moved to the end of the list!", dataProvider.length - 1, dataProvider.getItemIndex(firstObject));
            dataProvider.removeItemAt(dataProvider.getItemIndex(firstObject)); //make sure there's no RTE
            assertEquals("The item wasn't removed!", 9, dataProvider.length);
        }

        [Test]
        public function test_removing_selected_item_on_complex_field_sorted_grid_with_formatter_after_renaming_it():void
        {
            //given
            var dateColumn:GridColumn = new GridColumn("address.dateMovedIn");
            var dateTimeFormatter:DateTimeFormatter = new DateTimeFormatter();
            dateTimeFormatter.dateTimePattern = "MMMM"; //Full month name
            dateColumn.formatter = dateTimeFormatter;

            _sut.columns = new ArrayCollection([dateColumn]);

            const tenObjects:IList = generateVOs(10);
            const dataProvider:ListCollectionView = new ListCollectionView(tenObjects);

            //when
            UIImpersonator.addChild(_sut);
            assertNotNull("UIImpersonator doesn't work correctly!", _sut.grid);
            _sut.dataProvider = dataProvider;
            _sut.sortByColumns(new <int>[0]); //sort by address.dateMovedIn, in effect by month name

            //then
            const aprilObject:FLEX_34837_VO = tenObjects.getItemAt(3) as FLEX_34837_VO;
            assertEquals(0, dataProvider.getItemIndex(aprilObject));

            //when
            const septemberObject:FLEX_34837_VO = tenObjects.getItemAt(8) as FLEX_34837_VO;
            septemberObject.address.dateMovedIn = new Date(2000, 3, 2); //"April"; should move it at the start of the list

            const firstObject:FLEX_34837_VO = tenObjects.getItemAt(0) as FLEX_34837_VO;
            firstObject.address.dateMovedIn = new Date(2000, 8, 2); //"September"; should move it at the end of the list

            //then
            assertEquals("The object should have moved to the end of the list!", dataProvider.length - 1, dataProvider.getItemIndex(firstObject));
            dataProvider.removeItemAt(dataProvider.getItemIndex(firstObject)); //make sure there's no RTE
            assertEquals("The item wasn't removed!", 9, dataProvider.length);
        }

        [Test]
        public function test_removing_selected_item_on_multiple_field_sorted_grid_with_formatter_changed_after_first_sort_and_after_renaming():void
        {
            //given
            var dateColumn:GridColumn = new GridColumn("address.dateMovedIn");
            _sut.columns = new ArrayCollection([dateColumn]);

            const tenObjects:IList = generateVOs(10);
            const dataProvider:ListCollectionView = new ListCollectionView(tenObjects);

            //when
            UIImpersonator.addChild(_sut);
            assertNotNull("UIImpersonator doesn't work correctly!", _sut.grid);
            _sut.dataProvider = dataProvider;

            var dateTimeFormatter:DateTimeFormatter = new DateTimeFormatter();
            dateTimeFormatter.dateTimePattern = "MMMM"; //Full month name
            dateColumn.formatter = dateTimeFormatter; //this should re-sort the items in the grid according to the month

            _sut.sortByColumns(new <int>[0]); //sort by address.dateMovedIn

            //then
            const aprilObject:FLEX_34837_VO = tenObjects.getItemAt(3) as FLEX_34837_VO;
            assertEquals(0, dataProvider.getItemIndex(aprilObject));

            //when
            const septemberObject:FLEX_34837_VO = tenObjects.getItemAt(8) as FLEX_34837_VO;
            septemberObject.address.dateMovedIn = new Date(2000, 3, 2); //"April"; should move it at the start of the list

            const firstObject:FLEX_34837_VO = tenObjects.getItemAt(0) as FLEX_34837_VO;
            firstObject.address.dateMovedIn = new Date(2000, 8, 2); //"September"; should move it at the end of the list

            //then
            assertEquals("The object should have moved to the end of the list!", dataProvider.length - 1, dataProvider.getItemIndex(firstObject));
            dataProvider.removeItemAt(dataProvider.getItemIndex(firstObject)); //make sure there's no RTE
            assertEquals("The item wasn't removed!", 9, dataProvider.length);
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

        private static function generateOneObject(i:Number):FLEX_34837_VO
        {
            return new FLEX_34837_VO(i, "Object", "Street");
        }
    }
}

[Bindable]
class FLEX_34837_VO
{
    public var name:String;
    public var address:FLEX_34837_AddressVO;
    public var index:Number;

    public function FLEX_34837_VO(index:Number, namePrefix:String, streetPrefix:String)
    {
        this.index = index;
        this.name = namePrefix + index;
        this.address = new FLEX_34837_AddressVO(streetPrefix + index, Math.floor(index), new Date(2000 + Math.floor(index), Math.floor(index), 1, 0, 0, 0, 1));
    }
}

[Bindable]
class FLEX_34837_AddressVO
{
    public var street:String;
    public var houseNumber:int;
    public var dateMovedIn:Date;

    public function FLEX_34837_AddressVO(street:String, houseNumber:int, dateMovedIn:Date)
    {
        this.street = street;
        this.houseNumber = houseNumber;
        this.dateMovedIn = dateMovedIn;
    }
}