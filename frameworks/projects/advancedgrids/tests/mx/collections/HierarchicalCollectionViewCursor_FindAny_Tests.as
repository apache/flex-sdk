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
    import org.flexunit.asserts.assertEquals;
    import org.flexunit.asserts.assertTrue;

    public class HierarchicalCollectionViewCursor_FindAny_Tests
    {
        private static const DEPARTMENT_SALES:String = "Sales";
        private static const DEPARTMENT_DEVELOPMENT:String = "Development";
        private static const NO_ITEMS_PER_GRID_HEIGHT:int = 5;
        private static const _utils:HierarchicalCollectionViewTestUtils = new HierarchicalCollectionViewTestUtils();
        private static var _collectionView:HierarchicalCollectionView;
        private static var _sut:HierarchicalCollectionViewCursor;
        private static var _level0:ArrayCollection;

        [Before]
        public function setUp():void
        {
            _collectionView = createHierarchicalCollectionView(createGroupingCollection(createEmployees()));
            _level0 = _utils.getRoot(_collectionView) as ArrayCollection;
            _sut = _collectionView.createCursor() as HierarchicalCollectionViewCursor;
        }

        [After]
        public function tearDown():void
        {
            _collectionView = null;
            _sut = null;
        }

        [Test]
        public function test_seeking_first_lands_on_development():void
        {
            //given
            _utils.openAllNodes(_collectionView);

            //when
            _sut.seek(new CursorBookmark(CursorBookmark.FIRST));

            //then
            var developmentGroup:Object = _level0.getItemAt(0);
            assertTrue(developmentGroup.hasOwnProperty("GroupLabel"));
            assertEquals(DEPARTMENT_DEVELOPMENT, developmentGroup["GroupLabel"]);
            assertEquals(developmentGroup, _sut.current);
        }

        [Test]
        public function test_searching_for_sales_using_anonymous_object_lands_on_sales_group():void
        {
            //given
            var salesIdentifier:Object = {GroupLabel:DEPARTMENT_SALES};

            //when
            var found:Boolean = _sut.findAny(salesIdentifier);

            //then
            assertTrue(found);

            var current:Object = _sut.current;
            assertTrue(current.hasOwnProperty("GroupLabel"));
            assertEquals(DEPARTMENT_SALES, current["GroupLabel"]);
        }

        [Test]
        public function test_searching_for_sales_via_findLast_using_anonymous_object_lands_on_sales_group():void
        {
            //given
            var salesIdentifier:Object = {GroupLabel:DEPARTMENT_SALES};

            //when
            var found:Boolean = _sut.findLast(salesIdentifier);

            //then
            assertTrue(found);

            var current:Object = _sut.current;
            assertTrue(current.hasOwnProperty("GroupLabel"));
            assertEquals(DEPARTMENT_SALES, current["GroupLabel"]);
        }

        [Test]
        public function test_finding_current_leaves_first_unchanged():void
        {
            //given
            _utils.openAllNodes(_collectionView);
            _sut.seek(new CursorBookmark(CursorBookmark.FIRST));

            //when
            var found:Boolean = _sut.findAny(_sut.current);

            //then
            assertTrue(found);
            assertEquals(_level0.getItemAt(0), _sut.current);
        }

        [Test] //FLEX-35031
        public function test_FLEX_35031_finding_sealed_class_instance():void
        {
            //given
            _utils.openAllNodes(_collectionView);
            _sut.seek(new CursorBookmark(CursorBookmark.FIRST));
            _sut.moveNext(); //an EmployeeVO instance from the "Development" department

            //when
            var found:Boolean = _sut.findAny(_sut.current);

            //then
            assertTrue(found);
            assertTrue(_sut.current is EmployeeVO);
            assertEquals(DEPARTMENT_DEVELOPMENT, EmployeeVO(_sut.current).department);
        }

        [Test] //FLEX-35031
        public function test_FLEX_35031_finding_sealed_class_instance_with_findLast():void
        {
            //given
            _utils.openAllNodes(_collectionView);
            _sut.seek(new CursorBookmark(CursorBookmark.FIRST));
            _sut.moveNext(); //an EmployeeVO instance from the "Development" department

            //when
            var found:Boolean = _sut.findLast(_sut.current);

            //then
            assertTrue(found);
            assertTrue(_sut.current is EmployeeVO);
            assertEquals(DEPARTMENT_DEVELOPMENT, EmployeeVO(_sut.current).department);
        }

        private static function createHierarchicalCollectionView(groupingCollection:GroupingCollection2):HierarchicalCollectionView
        {
            return new HierarchicalCollectionView(groupingCollection);
        }

        private static function createEmployees():ArrayCollection
        {
            var result:ArrayCollection = new ArrayCollection();
            for (var i:int = 0; i < NO_ITEMS_PER_GRID_HEIGHT - 1; i++)
            {
                result.addItem(createEmployee("Emp-" + DEPARTMENT_DEVELOPMENT + "-" + i, DEPARTMENT_DEVELOPMENT, i));
            }

            for (i = 0; i < NO_ITEMS_PER_GRID_HEIGHT - 1; i++)
            {
                result.addItem(createEmployee("Emp-" + DEPARTMENT_SALES + "-" + i, DEPARTMENT_SALES, i));
            }

            return result;
        }

        private static function createEmployee(name:String, department:String, idInDepartment:int):EmployeeVO
        {
            return new EmployeeVO(name, department, idInDepartment);
        }

        private static function createGroupingCollection(source:ArrayCollection):GroupingCollection2
        {
            var collection:GroupingCollection2 = new GroupingCollection2();
            var grouping:Grouping = new Grouping();
            grouping.fields = [new GroupingField("department")];
            collection.grouping = grouping;

            collection.source = source;
            collection.refresh();

            return collection;
        }
    }
}

class EmployeeVO
{
    public var name:String;
    public var department:String;
    public var idInDepartment:int;

    public function EmployeeVO(name:String, department:String, idInDepartment:int)
    {
        this.name = name;
        this.department = department;
        this.idInDepartment = idInDepartment;
    }
}