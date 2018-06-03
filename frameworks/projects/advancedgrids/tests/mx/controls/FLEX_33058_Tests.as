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

package mx.controls {
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.MouseEvent;

    import mx.collections.ArrayCollection;
    import mx.collections.Grouping;
    import mx.collections.GroupingCollection2;
    import mx.collections.GroupingField;
    import mx.collections.IHierarchicalCollectionView;
    import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
    import mx.controls.advancedDataGridClasses.AdvancedDataGridHeaderRenderer;
    import mx.events.FlexEvent;

    import org.flexunit.asserts.assertNotNull;
    import org.flexunit.asserts.assertTrue;
    import org.flexunit.async.Async;
    import org.fluint.uiImpersonation.UIImpersonator;

    public class FLEX_33058_Tests
    {
        private static const DEPARTMENT_SALES:String = "Sales";
        private static const DEPARTMENT_DEVELOPMENT:String = "Development";
        private static const NO_ITEMS_PER_GRID_HEIGHT:int = 5;
        private static const NO_ENTER_FRAMES_TO_ALLOW:int = 2;
        private static const _finishNotifier:EventDispatcher = new EventDispatcher();

        private static var _grid:AdvancedDataGrid;
        private static var _header:AdvancedDataGridHeaderRenderer;
        private static var _aSalesEmployee:EmployeeVO;
        private static var noEnterFramesRemaining:int = NaN;

        [Before]
        public function setUp():void
        {
            _grid = new AdvancedDataGrid();
            _grid.columns = [createNameColumn()];
            _grid.dataProvider = createGroupingCollection(createEmployees());

            _grid.addEventListener(Event.ADDED, onAdded);
        }

        [After]
        public function tearDown():void
        {
            _grid.removeEventListener(FlexEvent.ADD, onAdded);
            _grid = null;
            _header = null;
            _aSalesEmployee = null;
            noEnterFramesRemaining = NaN;
        }

        [Test(async, timeout=2500)]
        public function test_sorting_doesnt_throw_fatal():void
        {
            //given
            _grid.height = 50; //exact value is unimportant; can be anything that allows for vertical scroll bars

            //when
            UIImpersonator.addElement(_grid);

            //then wait a few frames
            noEnterFramesRemaining = NO_ENTER_FRAMES_TO_ALLOW;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, onGridAddedToStage, 800);
        }

        private function onGridAddedToStage(event:Event, passThroughData:Object):void
        {
            //when - expanding the two folders to enable scrolling
            _grid.expandAll();

            //then - wait a few more frames
            noEnterFramesRemaining = NO_ENTER_FRAMES_TO_ALLOW;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, onGridDrawn, 800);
        }

        private function onGridDrawn(event:Event, passThroughData:Object):void
        {
            //given
            assertTrue(_grid.maxVerticalScrollPosition > 0);

            //when - scrolling to the "Sales" folder
            _grid.firstVisibleItem = (_grid.dataProvider as IHierarchicalCollectionView).getParentItem(_aSalesEmployee);

            //then - wait a few more frames
            noEnterFramesRemaining = NO_ENTER_FRAMES_TO_ALLOW;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, onGridSetupComplete, 800);
        }

        private static function onGridSetupComplete(event:Event, passThroughData:Object):void
        {
            //given
            assertNotNull(_header);
            assertTrue(_grid.firstVisibleItem.hasOwnProperty("GroupLabel") && _grid.firstVisibleItem["GroupLabel"] == DEPARTMENT_SALES);

            //when - clicking on the column header to sort
            _header.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, 5, 5));
            _header.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, true, false, 5, 5));

            //then - if we get here it means no error has been thrown
            assertTrue(true);
        }

        private static function onEnterFrame(event:Event):void
        {
            if(!--noEnterFramesRemaining)
            {
                UIImpersonator.testDisplay.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
                _finishNotifier.dispatchEvent(new Event(Event.COMPLETE));
            }
        }

        private static function onAdded(event:Event):void
        {
            if(event.target is AdvancedDataGridHeaderRenderer)
                _header = AdvancedDataGridHeaderRenderer(event.target);
        }

        private static function createEmployees():ArrayCollection
        {
            var result:ArrayCollection = new ArrayCollection();
            for (var i:int = 0; i < NO_ITEMS_PER_GRID_HEIGHT - 1; i++)
            {
                result.addItem(createEmployee("Emp-" + DEPARTMENT_DEVELOPMENT + "-" + i, DEPARTMENT_DEVELOPMENT));
            }

            for (i = 0; i < NO_ITEMS_PER_GRID_HEIGHT - 1; i++)
            {
                result.addItem(createEmployee("Emp-" + DEPARTMENT_SALES + "-" + i, DEPARTMENT_SALES));
            }

            _aSalesEmployee = result.getItemAt(result.length - 1) as EmployeeVO;

            return result;
        }

        private static function createEmployee(name:String, department:String):EmployeeVO
        {
            return new EmployeeVO(name, department);
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

        private static function createNameColumn():AdvancedDataGridColumn
        {
            var nameColumn:AdvancedDataGridColumn = new AdvancedDataGridColumn("nameColumn");
            nameColumn.dataField = "name";
            return nameColumn;
        }
    }
}

class EmployeeVO
{
    public var name:String;
    public var department:String;

    public function EmployeeVO(name:String, department:String)
    {
        this.name = name;
        this.department = department;
    }
}