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
    import org.flexunit.asserts.assertFalse;
    import org.flexunit.asserts.assertNotNull;
    import org.flexunit.asserts.assertNull;
    import org.flexunit.asserts.assertTrue;

    public class HierarchicalCollectionViewCursor_FindAny_Tests
    {
        private static const DEPARTMENT_SALES:String = "Sales";
        private static const DEPARTMENT_DEVELOPMENT:String = "Development";
        private static const NO_EMPLOYEES_PER_DEPARTMENT:int = 5;
        private static const NO_DEPARTMENTS:int = 2;
        private static const NO_EMPLOYEES:int = NO_EMPLOYEES_PER_DEPARTMENT * NO_DEPARTMENTS;
        private static const _utils:HierarchicalCollectionViewTestUtils = new HierarchicalCollectionViewTestUtils();
        private static var _collectionView:HierarchicalCollectionView;
        private static var _sut:HierarchicalCollectionViewCursor;
        private static var _level0:ArrayCollection;
        private static var _employeesByID:Array = [];

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
        public function test_FLEX_35031_finding_current_sealed_class_instance_with_findAny():void
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
        public function test_FLEX_35031_finding_different_sealed_class_instance_with_findAny():void
        {
            //given
            _utils.openAllNodes(_collectionView);
            var salesGroup:Object = _level0.getItemAt(1);
            var salesEmployee:EmployeeVO = salesGroup.children.getItemAt(0) as EmployeeVO;
            assertEquals(DEPARTMENT_SALES, salesEmployee.department);

            //when
            var found:Boolean = _sut.findAny(salesEmployee);

            //then
            assertTrue(found);
            assertEquals(salesEmployee, _sut.current);
        }

        [Test] //FLEX-35031
        public function test_FLEX_35031_finding_different_sealed_class_instance_with_findLast():void
        {
            //given
            _utils.openAllNodes(_collectionView);
            var developmentGroup:Object = _level0.getItemAt(0);
            var developmentEmployee:EmployeeVO = developmentGroup.children.getItemAt(0) as EmployeeVO;
            assertEquals(DEPARTMENT_DEVELOPMENT, developmentEmployee.department);

            //when
            var found:Boolean = _sut.findLast(developmentEmployee);

            //then
            assertTrue(found);
            assertEquals(developmentEmployee, _sut.current);
        }

        [Test] //FLEX-35031
        public function test_FLEX_35031_finding_sealed_class_instance_from_current_with_findLast():void
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

        [Test] //FLEX-33058
        public function test_FLEX_33058_when_not_found_via_findAny_using_anonymous_object_current_is_null():void
        {
            //given
            _utils.openAllNodes(_collectionView);

            //when
            var found:Boolean = _sut.findAny({someProperty:"someValue"});

            //then
            assertFalse(found);
            assertEquals(null, _sut.current);
        }

        [Test] //FLEX-33058
        public function test_FLEX_33058_when_not_found_via_findLast_using_anonymous_object_current_is_null():void
        {
            //given
            _utils.openAllNodes(_collectionView);

            //when
            var found:Boolean = _sut.findLast({someProperty:"someValue"});

            //then
            assertFalse(found);
            assertEquals(null, _sut.current);
        }

        [Test] //FLEX-35031
        public function test_FLEX_35031_findAny_does_not_fatal_when_trying_to_find_null_and_doesnt_find_it():void
        {
            //given
            _utils.openAllNodes(_collectionView);

            //when
            var found:Boolean = _sut.findAny(null);

            //then
            assertFalse(found);
            assertEquals(null, _sut.current);
        }

        [Test] //FLEX-35031
        public function test_FLEX_35031_findLast_does_not_fatal_when_trying_to_find_null_and_doesnt_find_it():void
        {
            //given
            _utils.openAllNodes(_collectionView);

            //when
            var found:Boolean = _sut.findLast(null);

            //then
            assertFalse(found);
            assertEquals(null, _sut.current);
        }

        [Test]
        public function test_findAny_finds_the_first_item_when_its_argument_is_an_empty_anonymous_object():void
        {
            //given
            _utils.openAllNodes(_collectionView);

            //when
            var found:Boolean = _sut.findAny({});

            //then
            assertTrue(found);
            assertEquals(_level0.getItemAt(0), _sut.current);
        }

        [Test]
        public function test_findLast_finds_the_last_item_when_its_argument_is_an_empty_anonymous_object():void
        {
            //given
            _utils.openAllNodes(_collectionView);

            //when
            var found:Boolean = _sut.findLast({});

            //then
            assertTrue(found);
            assertEquals(_employeesByID[_employeesByID.length - 1], _sut.current);
        }

        [Test]
        public function test_findAny_finds_sealed_class_instance_via_anonymous_object_with_subset_of_properties():void
        {
            //given
            const ID_TO_FIND:int = NO_EMPLOYEES_PER_DEPARTMENT;
            _utils.openAllNodes(_collectionView);

            //when
            var found:Boolean = _sut.findAny({department:DEPARTMENT_SALES, uniqueID:ID_TO_FIND});

            //then
            assertTrue(found);
            var currentEmployee:EmployeeVO = _sut.current as EmployeeVO;
            assertNotNull(currentEmployee);
            assertEquals(DEPARTMENT_SALES, currentEmployee.department);
            assertEquals(ID_TO_FIND, currentEmployee.uniqueID);
        }

        [Test]
        public function test_findAny_finds_sealed_class_instance_via_anonymous_object_with_subset_of_properties_and_string_values_instead_of_int():void
        {
            //given
            const ID_TO_FIND:int = NO_EMPLOYEES_PER_DEPARTMENT;
            _utils.openAllNodes(_collectionView);

            //when
            var found:Boolean = _sut.findAny({department:DEPARTMENT_SALES, uniqueID:ID_TO_FIND.toString()});

            //then
            assertTrue(found);
            var currentEmployee:EmployeeVO = _sut.current as EmployeeVO;
            assertNotNull(currentEmployee);
            assertEquals(DEPARTMENT_SALES, currentEmployee.department);
            assertEquals(ID_TO_FIND, currentEmployee.uniqueID);
        }

        [Test]
        public function test_findLast_finds_sealed_class_instance_via_anonymous_object_with_subset_of_properties():void
        {
            //given
            const ID_TO_FIND:int = 0;
            _utils.openAllNodes(_collectionView);

            //when
            var found:Boolean = _sut.findLast({department:DEPARTMENT_DEVELOPMENT, uniqueID:ID_TO_FIND});

            //then
            assertTrue(found);
            var currentEmployee:EmployeeVO = _sut.current as EmployeeVO;
            assertNotNull(currentEmployee);
            assertEquals(DEPARTMENT_DEVELOPMENT, currentEmployee.department);
            assertEquals(ID_TO_FIND, currentEmployee.uniqueID);
        }

        [Test]
        public function test_findLast_finds_sealed_class_instance_via_anonymous_object_with_subset_of_properties_and_string_values_instead_of_int():void
        {
            //given
            const ID_TO_FIND:int = 0;
            _utils.openAllNodes(_collectionView);

            //when
            var found:Boolean = _sut.findLast({department:DEPARTMENT_DEVELOPMENT, uniqueID:ID_TO_FIND.toString()});

            //then
            assertTrue(found);
            var currentEmployee:EmployeeVO = _sut.current as EmployeeVO;
            assertNotNull(currentEmployee);
            assertEquals(DEPARTMENT_DEVELOPMENT, currentEmployee.department);
            assertEquals(ID_TO_FIND, currentEmployee.uniqueID);
        }

        [Test]
        public function test_findAny_finds_sealed_class_instance_via_dynamic_class_instance_with_subset_of_properties():void
        {
            //given
            _utils.openAllNodes(_collectionView);
            var lastEmployee:EmployeeVO = _employeesByID[_employeesByID.length - 1];

            //when
            var found:Boolean = _sut.findLast(new DynamicVO(lastEmployee.name));

            //then
            assertTrue(found);
            assertEquals(lastEmployee, _sut.current);
        }

        [Test]
        public function test_findLast_finds_sealed_class_instance_via_dynamic_class_instance_with_subset_of_properties():void
        {
            //given
            _utils.openAllNodes(_collectionView);
            var firstEmployee:EmployeeVO = _employeesByID[0];

            //when
            var found:Boolean = _sut.findLast(new DynamicVO(firstEmployee.name));

            //then
            assertTrue(found);
            assertEquals(firstEmployee, _sut.current);
        }

        /**
         * Note that in a perfect world this would work. However, to accomplish this task
         * we'd need to use <code>flash.utils.describeType()</code> (or
         * <code>DescribeTypeCache.describeType()</code> or <code>ObjectUtil.getClassInfo()</code>).
         * But since no usage of findAny(), findFirst() and findLast() in the framework requires
         * this feature (as they are all about finding items that already exist in the collection),
         * there's no business case for implementing it.
         */
        [Test]
        public function test_findAny_does_NOT_find_sealed_class_instance_via_other_sealed_class_instance_with_subset_of_properties():void
        {
            //given
            _utils.openAllNodes(_collectionView);
            var lastEmployee:EmployeeVO = _employeesByID[_employeesByID.length - 1];

            //when
            var found:Boolean = _sut.findAny(new NamedVO(lastEmployee.name));

            //then
            assertFalse(found);
            assertNull(_sut.current);
        }

        //see the comment for the function above
        [Test]
        public function test_findLast_does_NOT_find_sealed_class_instance_via_other_sealed_class_instance_with_subset_of_properties():void
        {
            //given
            _utils.openAllNodes(_collectionView);
            var firstEmployee:EmployeeVO = _employeesByID[0];

            //when
            var found:Boolean = _sut.findLast(new NamedVO(firstEmployee.name));

            //then
            assertFalse(found);
            assertNull(_sut.current);
        }

        [Test]
        public function test_findLast_finds_different_object_to_findFirst_via_anonymous_object_with_subset_of_properties():void
        {
            //given
            _utils.openAllNodes(_collectionView);

            var secondEmployee:EmployeeVO = _employeesByID[1] as EmployeeVO;
            var secondToLastEmployee:EmployeeVO = _employeesByID[NO_EMPLOYEES - 2] as EmployeeVO;

            const sameName:String = "John";

            //when
            secondEmployee.name = sameName;
            secondToLastEmployee.name = sameName;

            var foundFromBeginning:Boolean = _sut.findAny({name:sameName});

            //then
            assertTrue(foundFromBeginning);
            assertEquals(secondEmployee, _sut.current);

            //when
            var foundFromEnd:Boolean = _sut.findLast({name:sameName});

            //then
            assertTrue(foundFromEnd);
            assertEquals(secondToLastEmployee, _sut.current);
        }

        private static function createHierarchicalCollectionView(groupingCollection:GroupingCollection2):HierarchicalCollectionView
        {
            return new HierarchicalCollectionView(groupingCollection);
        }

        private static function createEmployees():ArrayCollection
        {
            var result:ArrayCollection = new ArrayCollection();
            for (var i:int = 0; i < NO_EMPLOYEES_PER_DEPARTMENT * 2; i++)
            {
                result.addItem(createEmployee("Emp-" + i, (i < NO_EMPLOYEES_PER_DEPARTMENT ? DEPARTMENT_DEVELOPMENT : DEPARTMENT_SALES), i));
            }

            return result;
        }

        private static function createEmployee(name:String, department:String, uniqueID:int):EmployeeVO
        {
            var employeeVO:EmployeeVO = new EmployeeVO(name, department, uniqueID);
            _employeesByID[employeeVO.uniqueID] = employeeVO;
            return employeeVO;
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
    public var uniqueID:int;

    public function EmployeeVO(name:String, department:String, uniqueID:int)
    {
        this.name = name;
        this.department = department;
        this.uniqueID = uniqueID;
    }
}

class NamedVO
{
    public var name:String;

    public function NamedVO(name:String)
    {
        this.name = name;
    }
}

dynamic class DynamicVO
{
    public function DynamicVO(name:String)
    {
        this.name = name;
    }
}