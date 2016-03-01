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
    import flash.display.DisplayObject;
    import flash.events.UncaughtErrorEvent;

    import mx.core.FlexGlobals;
    import mx.events.PropertyChangeEvent;
    import mx.events.PropertyChangeEventKind;
    import mx.utils.ObjectUtil;

    import org.flexunit.asserts.assertEquals;
    import org.flexunit.asserts.assertTrue;

    public class ListCollectionView_PropertyChangeEvent_Tests
    {
        private static var _sut:ListCollectionView;
        private static var _firstWorkout:WorkoutVO;

        private static var PROPERTY_CHANGE_EVENT:PropertyChangeEvent;
        private static var PROPERTY_CHANGE_EVENT_UPDATE:PropertyChangeEvent;
        private static var PROPERTY_CHANGE_EVENT_UPDATE_CONVENIENCE:PropertyChangeEvent;
        private static var _noTimesFilterFunctionCalled:int;
        private static var _lastFilteredObject:Object;
        private static var _uncaughtError:Error;

        [BeforeClass]
        public static function setUpBeforeClass():void
        {
            if(FlexGlobals.topLevelApplication is DisplayObject)
                (FlexGlobals.topLevelApplication as DisplayObject).loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, handleUncaughtClientError);
        }

        [AfterClass]
        public static function tearDownAfterClass():void
        {
            if(FlexGlobals.topLevelApplication is DisplayObject)
                (FlexGlobals.topLevelApplication as DisplayObject).loaderInfo.uncaughtErrorEvents.removeEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, handleUncaughtClientError);
        }

        [Before]
        public function setUp():void
        {
            PROPERTY_CHANGE_EVENT = new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE);
            PROPERTY_CHANGE_EVENT_UPDATE = new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE, false, false, PropertyChangeEventKind.UPDATE);
            PROPERTY_CHANGE_EVENT_UPDATE_CONVENIENCE = PropertyChangeEvent.createUpdateEvent(null, null, null, null);

            _noTimesFilterFunctionCalled = 0;

            InspectableSort.setUp();

            _sut = new ListCollectionView(new ArrayList());
            _sut.addAll(createWorkouts());
        }

        [After]
        public function tearDown():void
        {
            _sut = null;
            _lastFilteredObject = null;

            PROPERTY_CHANGE_EVENT = null;
            PROPERTY_CHANGE_EVENT_UPDATE = null;
            PROPERTY_CHANGE_EVENT_UPDATE_CONVENIENCE = null;

            InspectableSort.tearDown();

            _uncaughtError = null;
        }

        [Test]
        public function test_PropertyChangeEvents_equivalent():void
        {
            //when
            var eventComparison:int = ObjectUtil.compare(PROPERTY_CHANGE_EVENT_UPDATE, PROPERTY_CHANGE_EVENT_UPDATE_CONVENIENCE);

            //then
            assertEquals(0, eventComparison);
        }

        [Test]
        public function test_when_collection_item_dispatches_PropertyChangeEvent_item_is_run_through_filter_and_there_is_no_fatal():void
        {
            //given
            _sut.filterFunction = allowAll;
            _sut.refresh();
            const positionOfFirstWorkout:int = _sut.getItemIndex(_firstWorkout);

            _noTimesFilterFunctionCalled = 0;
            _lastFilteredObject = null;

            //when
            _firstWorkout.dispatchEvent(PROPERTY_CHANGE_EVENT);

            //then - no fatal, and object has been filtered
            assertEquals(1, _noTimesFilterFunctionCalled);
            assertEquals(_firstWorkout, _lastFilteredObject);
            assertEquals(positionOfFirstWorkout, _sut.getItemIndex(_firstWorkout));
        }

        [Test]
        public function test_when_collection_item_changes_item_is_run_through_filter_and_there_is_no_fatal():void
        {
            //given
            _sut.filterFunction = allowAll;
            _sut.refresh();
            const positionOfFirstWorkout:int = _sut.getItemIndex(_firstWorkout);

            _noTimesFilterFunctionCalled = 0;
            _lastFilteredObject = null;

            //when
            _firstWorkout.duration += 10;

            //then - no fatal, and object has been filtered
            assertEquals(1, _noTimesFilterFunctionCalled);
            assertEquals(_firstWorkout, _lastFilteredObject);
            assertEquals(positionOfFirstWorkout, _sut.getItemIndex(_firstWorkout));
        }

        [Test]
        public function test_when_collection_item_dispatches_PropertyChangeEvent_null_is_removed_from_list():void
        {
            //given
            _sut.addItem(null);
            _sut.filterFunction = allowAll;
            _sut.refresh();
            var positionOfNull:int = _sut.getItemIndex(null);
            const positionOfFirstWorkout:int = _sut.getItemIndex(_firstWorkout);

            //when
            _firstWorkout.dispatchEvent(PROPERTY_CHANGE_EVENT);

            //then
            assertTrue(positionOfNull != -1);
            assertEquals(-1, _sut.getItemIndex(null));
            assertEquals(positionOfFirstWorkout, _sut.getItemIndex(_firstWorkout));
        }

        [Test]
        public function test_when_collection_item_is_changed_null_is_not_removed_from_list():void
        {
            //given
            _sut.addItem(null);
            _sut.filterFunction = allowAll;
            _sut.refresh();
            const positionOfNull:int = _sut.getItemIndex(null);
            const positionOfFirstWorkout:int = _sut.getItemIndex(_firstWorkout);

            //when
            _firstWorkout.duration += 10;

            //then
            assertTrue(positionOfNull != -1);
            assertEquals(positionOfNull, _sut.getItemIndex(null));
            assertEquals(positionOfFirstWorkout, _sut.getItemIndex(_firstWorkout));
        }

        [Test]
        public function test_when_collection_item_dispatches_PropertyChangeEvent_with_UPDATE_null_is_removed_from_list():void
        {
            //given
            _sut.addItem(null);
            _sut.filterFunction = allowAll;
            _sut.refresh();
            var positionOfNull:int = _sut.getItemIndex(null);
            const positionOfFirstWorkout:int = _sut.getItemIndex(_firstWorkout);

            //when
            _firstWorkout.dispatchEvent(PROPERTY_CHANGE_EVENT_UPDATE);

            //then
            assertTrue(positionOfNull != -1);
            assertEquals(-1, _sut.getItemIndex(null));
            assertEquals(positionOfFirstWorkout, _sut.getItemIndex(_firstWorkout));
        }

        [Test]
        public function test_when_collection_item_dispatches_PropertyChangeEvent_with_correct_property_and_oldValue_null_stays_in_list():void
        {
            //given
            _sut.addItem(null);
            var sort:InspectableSort = new InspectableSort([new SortField("name")]);
            _sut.sort = sort;
            _sut.refresh();
            const positionOfNull:int = _sut.getItemIndex(null);
            const positionOfFirstWorkout:int = _sut.getItemIndex(_firstWorkout);

            //when
            _firstWorkout.dispatchEvent(PropertyChangeEvent.createUpdateEvent(_firstWorkout, "name", _firstWorkout.name, "zzz"));

            //then
            assertTrue(positionOfNull != -1);
            assertEquals(positionOfNull, _sut.getItemIndex(null));
            assertEquals(positionOfFirstWorkout, _sut.getItemIndex(_firstWorkout));
        }

        [Test]
        public function test_when_collection_item_dispatches_PropertyChangeEvent_with_correct_property_and_null_oldValue_null_stays_in_list():void
        {
            //given
            _sut.addItem(null);
            var sort:InspectableSort = new InspectableSort([new SortField("name")]);
            _sut.sort = sort;
            _sut.refresh();
            const positionOfNull:int = _sut.getItemIndex(null);
            const positionOfFirstWorkout:int = _sut.getItemIndex(_firstWorkout);

            //when
            _firstWorkout.dispatchEvent(PropertyChangeEvent.createUpdateEvent(_firstWorkout, "name", null, null));

            //then
            assertTrue(positionOfNull != -1);
            assertEquals(positionOfNull, _sut.getItemIndex(null));
            assertEquals(positionOfFirstWorkout, _sut.getItemIndex(_firstWorkout));
        }

        [Test]
        public function test_when_collection_item_dispatches_PropertyChangeEvent_item_is_added_in_correct_place_based_on_sort_and_there_is_no_fatal():void
        {
            //given
            var sort:InspectableSort = new InspectableSort([new SortField("name")]);
            _sut.sort = sort;
            _sut.refresh();
            const positionOfFirstWorkout:int = _sut.getItemIndex(_firstWorkout);

            //when
            _firstWorkout.dispatchEvent(PROPERTY_CHANGE_EVENT);

            //then - no fatal, and:
            //object's correct position has been inspected with Sort
            assertEquals(_firstWorkout, InspectableSort.lastItemSearchedFor);
            //and null (PropertyChangeEvent.oldValue) has been sought for when trying to remove it
            assertTrue(InspectableSort.itemsSearchedFor.indexOf(null) != -1);
            //and it's in the same position
            assertEquals(positionOfFirstWorkout, _sut.getItemIndex(_firstWorkout));
        }

        [Test]
        public function test_when_collection_item_dispatches_PropertyChangeEvent_sort_compare_function_called_with_null_and_fatals_if_no_null_check():void
        {
            function compareWorkouts(a:Object, b:Object, fields:Array = null):int
            {
                if(a.duration > b.duration)
                    return 1;
                if(a.duration < b.duration)
                    return -1;

                return 0;
            }
            //given
            var sort:InspectableSort = new InspectableSort([], compareWorkouts);
            _sut.sort = sort;
            _sut.refresh();

            //when
            _firstWorkout.dispatchEvent(PROPERTY_CHANGE_EVENT);

            //then - fatal because compareWorkouts was called with null, which it didn't expect (but should have)
            assertTrue(_uncaughtError is TypeError);
        }

        private static function allowAll(object:Object):Boolean
        {
            _lastFilteredObject = object;
            _noTimesFilterFunctionCalled++;
            return true;
        }

        private static function createWorkouts():IList
        {
            var result:ArrayList = new ArrayList();
            for (var i:int = 0; i < 10; i++)
            {
                result.addItem(new WorkoutVO("Workout" + i, i));
            }

            _firstWorkout = result.getItemAt(0) as WorkoutVO;

            return result;
        }

        private static function handleUncaughtClientError(event:UncaughtErrorEvent):void
        {
            _uncaughtError = event.error;
            event.preventDefault();
            event.stopImmediatePropagation();
        }
    }
}

import spark.collections.Sort;

[Bindable]
class WorkoutVO
{
    public var duration:int;
    public var name:String;

    public function WorkoutVO(name:String, duration:int)
    {
        this.name = name;
        this.duration = duration;
    }
}

class InspectableSort extends Sort
{
    public static var lastItemSearchedFor:Object;
    public static var itemsSearchedFor:Array;

    public function InspectableSort(fields:Array = null, customCompareFunction:Function = null, unique:Boolean = false)
    {
        super(fields, customCompareFunction, unique);
    }

    override public function findItem(items:Array, values:Object, mode:String, returnInsertionIndex:Boolean = false, compareFunction:Function = null):int
    {
        lastItemSearchedFor = values;
        itemsSearchedFor.push(values);
        return super.findItem(items, values, mode, returnInsertionIndex, compareFunction);
    }

    public static function setUp():void
    {
        itemsSearchedFor = [];
    }

    public static function tearDown():void
    {
        lastItemSearchedFor = null;
        itemsSearchedFor = null;
    }
}