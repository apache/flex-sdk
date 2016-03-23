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
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.MouseEvent;

    import mx.collections.ArrayCollection;
    import mx.collections.ArrayList;
    import mx.collections.IList;
    import mx.collections.ListCollectionView;

    import org.flexunit.asserts.assertEquals;
    import org.flexunit.asserts.assertNull;
    import org.flexunit.asserts.assertTrue;
    import org.flexunit.async.Async;
    import org.fluint.uiImpersonation.UIImpersonator;

    import spark.components.gridClasses.GridColumn;
    import spark.components.gridClasses.GridSelectionMode;
    import spark.events.GridEvent;

    public class DataGrid_FLEX_26808_Tests
    {
        private static const NO_ENTER_FRAMES_TO_ALLOW:int = 2;
        private static const _finishNotifier:EventDispatcher = new EventDispatcher();
        private static var noEnterFramesRemaining:int = NaN;
        private var _sut:DataGridInspectable;
        private var _firstObject:FLEX_26808_VO;

        [Before]
        public function setUp():void
        {
            _sut = new DataGridInspectable();

            _sut.dragEnabled = true;
            _sut.selectionMode = GridSelectionMode.MULTIPLE_ROWS;
            _sut.columns = new ArrayCollection([new GridColumn("name")]);
            _sut.width = 200;
            _sut.height = 200;

            const tenObjects:IList = generateVOs(10);
            _firstObject = tenObjects.getItemAt(0) as FLEX_26808_VO;
            const dataProvider:ListCollectionView = new ListCollectionView(tenObjects);
            _sut.dataProvider = dataProvider;
        }

        [After]
        public function tearDown():void
        {
            _sut = null;
            noEnterFramesRemaining = NaN;
        }

        [Test(async, timeout=1000)]
        public function test_ctrl_click_removes_selected_item():void
        {
            //when
            UIImpersonator.addElement(_sut);

            //then
            assertNull(_sut.selectedItem);

            noEnterFramesRemaining = NO_ENTER_FRAMES_TO_ALLOW;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, testSelectionAndDeselection, 800);
        }

        private function testSelectionAndDeselection(event:Event, passThroughData:Object):void
        {
            function onGridMouseDown(event:GridEvent):void
            {
                assertEquals(0, event.rowIndex);
                assertTrue(event.ctrlKey);
            }

            //when
            _sut.setSelectedIndex(0);

            //then
            assertEquals(_firstObject, _sut.selectedItem);

            //given
            const mouseDown:MouseEvent = new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, 5, 5, null, true, false, false);
            const mouseUp:MouseEvent = new MouseEvent(MouseEvent.MOUSE_UP, true, false, 5, 5, null, true, false, false);
            _sut.addEventListener(GridEvent.GRID_MOUSE_DOWN, onGridMouseDown);

            //when - Ctrl+Click on first item to deselect it
            _sut.grid.dispatchEvent(mouseDown);
            _sut.grid.dispatchEvent(mouseUp);

            //then
            assertEquals(1, _sut.commitInteractiveSelection_calls);
            assertNull("The selection should have been removed due to Ctrl+Click!", _sut.selectedItem);
            _sut.removeEventListener(GridEvent.GRID_MOUSE_DOWN, onGridMouseDown);
        }

        private static function onEnterFrame(event:Event):void
        {
            if(!--noEnterFramesRemaining)
            {
                UIImpersonator.testDisplay.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
                _finishNotifier.dispatchEvent(new Event(Event.COMPLETE));
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

        private static function generateOneObject(i:Number):FLEX_26808_VO
        {
            return new FLEX_26808_VO(i, "Object", "Street");
        }
    }
}

import spark.components.DataGrid;
import spark.skins.spark.DataGridSkin;

[Bindable]
class FLEX_26808_VO
{
    public var name:String;
    public var address:FLEX_26808_AddressVO;
    public var index:Number;

    public function FLEX_26808_VO(index:Number, namePrefix:String, streetPrefix:String)
    {
        this.index = index;
        this.name = namePrefix + index;
        this.address = new FLEX_26808_AddressVO(streetPrefix + index, Math.floor(index), new Date(2000 + Math.floor(index), Math.floor(index), 1, 0, 0, 0, 1));
    }
}

[Bindable]
class FLEX_26808_AddressVO
{
    public var street:String;
    public var houseNumber:int;
    public var dateMovedIn:Date;

    public function FLEX_26808_AddressVO(street:String, houseNumber:int, dateMovedIn:Date)
    {
        this.street = street;
        this.houseNumber = houseNumber;
        this.dateMovedIn = dateMovedIn;
    }
}

class DataGridInspectable extends DataGrid
{
    public function DataGridInspectable()
    {
        super();
        this.setStyle("skinClass", DataGridSkin);
    }

    public var commitInteractiveSelection_calls:int = 0;

    override protected function commitInteractiveSelection(selectionEventKind:String,
                                                           rowIndex:int,
                                                           columnIndex:int,
                                                           rowCount:int = 1,
                                                           columnCount:int = 1):Boolean

    {
        commitInteractiveSelection_calls++;
        return super.commitInteractiveSelection(selectionEventKind, rowIndex, columnIndex, rowCount, columnCount);
    }
}