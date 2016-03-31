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
    import mx.events.CollectionEvent;
    import mx.events.CollectionEventKind;
    import mx.events.PropertyChangeEvent;
    import mx.events.PropertyChangeEventKind;
    import mx.utils.ObjectUtil;

    import org.flexunit.asserts.assertEquals;
    import org.flexunit.asserts.assertNull;
    import org.flexunit.asserts.assertTrue;

    public class ListCollectionView_PropertyChangeEvent_Tests
    {
        private static const NO_WORKOUTS:int = 10;

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
            _firstWorkout = null;

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

        [Test] //FLEX-35043 FLEX-34885
        public function test_when_collection_item_dispatches_PropertyChangeEvent_null_is_not_removed_from_list():void
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
            assertEquals(positionOfNull, _sut.getItemIndex(null));
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

        [Test] //FLEX-35043 FLEX-34885
        public function test_when_item_is_changed_bypassing_binding_and_collection_notified_of_itemUpdated_with_property_null_is_not_removed_from_list():void
        {
            //given
            _sut.addItem(null);
            _sut.filterFunction = allowAll;
            _sut.refresh();
            const positionOfNull:int = _sut.getItemIndex(null);
            const positionOfFirstWorkout:int = _sut.getItemIndex(_firstWorkout);

            //when
            _firstWorkout.setMuscleGroupsWithoutTriggeringBinding("biceps");
            _sut.itemUpdated(_firstWorkout, "muscleGroups", null, _firstWorkout.muscleGroups);

            //then
            assertTrue(positionOfNull != -1);
            assertEquals(positionOfNull, _sut.getItemIndex(null));
            assertEquals(positionOfFirstWorkout, _sut.getItemIndex(_firstWorkout));
        }

        [Test] //FLEX-35043 FLEX-34885
        public function test_when_item_is_changed_bypassing_binding_and_collection_notified_of_itemUpdated_without_property_null_is_not_removed_from_list():void
        {
            //given
            _sut.addItem(null);
            _sut.filterFunction = allowAll;
            _sut.refresh();
            const positionOfNull:int = _sut.getItemIndex(null);
            const positionOfFirstWorkout:int = _sut.getItemIndex(_firstWorkout);

            //when
            _firstWorkout.setMuscleGroupsWithoutTriggeringBinding("biceps");
            _firstWorkout.setMinAgeWithoutTriggeringBinding(14);
            _sut.itemUpdated(_firstWorkout);

            //then
            assertTrue(positionOfNull != -1);
            assertEquals(positionOfNull, _sut.getItemIndex(null));
            assertEquals(positionOfFirstWorkout, _sut.getItemIndex(_firstWorkout));
        }

        [Test] //FLEX-35043 FLEX-34885
        public function test_when_collection_item_dispatches_PropertyChangeEvent_with_UPDATE_null_is_not_removed_from_list():void
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
            assertEquals(positionOfNull, _sut.getItemIndex(null));
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

        [Test] //FLEX-35043 FLEX-34885
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
            assertEquals(-1, InspectableSort.itemsSearchedFor.indexOf(null));
            //and it's in the same position
            assertEquals(positionOfFirstWorkout, _sut.getItemIndex(_firstWorkout));
        }

        [Test] //FLEX-35043 FLEX-34885
        public function test_when_collection_item_dispatches_PropertyChangeEvent_sort_compare_function_not_called_with_null():void
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

            //then - no fatal because compareWorkouts was not called with null as an argument
            assertNull(_uncaughtError);
        }

        [Test] //FLEX-35043 FLEX-34885
        public function test_when_collection_notified_of_itemUpdated_without_property_or_oldValue_sort_compare_function_not_called_with_null_and_item_repositioned():void
        {
            function orderByDurationDescending(a:Object, b:Object, fields:Array = null):int
            {
                if(a.duration > b.duration)
                    return -1;
                if(a.duration < b.duration)
                    return 1;

                return 0;
            }

            //make sure the workout is on the first position
            assertEquals("Initial assumption wrong - position", 0, _sut.getItemIndex(_firstWorkout));
            assertEquals("Initial assumption wrong - duration", 0, _firstWorkout.duration);

            //given
            var sort:InspectableSort = new InspectableSort([], orderByDurationDescending);
            _sut.sort = sort;
            _sut.refresh();

            //then
            assertEquals("The first item should have the highest duration", NO_WORKOUTS - 1, WorkoutVO(_sut.getItemAt(0)).duration);
            assertEquals("The first workout should have been moved to the end of the list", _sut.length - 1, _sut.getItemIndex(_firstWorkout));

            //when
            _firstWorkout.setMuscleGroupsWithoutTriggeringBinding("chest");
            _firstWorkout.setMinAgeWithoutTriggeringBinding(20);
            _firstWorkout.setDurationWithoutTriggeringBinding(int.MAX_VALUE);
            _sut.itemUpdated(_firstWorkout);

            //then
            // 1. no fatal because compare function was not called with null
            assertNull(_uncaughtError);
            // 2. the workout was repositioned because its duration changed
            assertEquals("The workout should have been moved to the start of the list, as it has the highest duration", 0, _sut.getItemIndex(_firstWorkout));
        }

        [Test] //FLEX-35043 FLEX-34885
        public function test_when_collection_of_non_binding_objects_notified_of_itemUpdated_without_property_or_oldValue_item_is_repositioned():void
        {
            function onCollectionChange(event:CollectionEvent):void
            {
                moveDispatched = event.kind == CollectionEventKind.MOVE;
            }

            function orderByDurationAscending(a:Object, b:Object, fields:Array = null):int
            {
                if(a.duration > b.duration)
                    return 1;
                if(a.duration < b.duration)
                    return -1;

                return 0;
            }

            //given
            var moveDispatched:Boolean = false;

            var testWorkout:Object = {duration:10};
            _sut.removeAll();
            _sut.addAll(new ArrayList([testWorkout, {duration:20}, {duration:5}]));

            var sortField:SortField = new SortField("duration", false, false, null, SortFieldCompareTypes.NUMERIC);
            var sort:InspectableSort = new InspectableSort([sortField]);
            _sut.sort = sort;
            _sut.refresh();

            _sut.addEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChange);

            //then
            assertEquals("The ten minute workout should be in the second position", 1, _sut.getItemIndex(testWorkout));

            //when
            testWorkout.duration = int.MAX_VALUE;
            _sut.itemUpdated(testWorkout);

            //then
            // 1. no fatal because compare function was not called with null
            assertNull(_uncaughtError);
            // 2. the workout was repositioned because its duration changed
            assertTrue(moveDispatched);
            assertEquals("The workout should have been moved to the end of the list, as it now has the highest duration", _sut.length - 1, _sut.getItemIndex(testWorkout));
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
            for (var i:int = 0; i < NO_WORKOUTS; i++)
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
    public var name:String;
    private var _duration:int;
    private var _muscleGroups:String;
    private var _minAge:uint;

    public function WorkoutVO(name:String, duration:int)
    {
        this.name = name;
        this._duration = duration;
    }

    public function get muscleGroups():String
    {
        return _muscleGroups;
    }

    public function set muscleGroups(value:String):void
    {
        _muscleGroups = value;
    }

    public function setMuscleGroupsWithoutTriggeringBinding(groups:String):void
    {
        _muscleGroups = groups;
    }

    public function get minAge():uint
    {
        return _minAge;
    }

    public function set minAge(value:uint):void
    {
        _minAge = value;
    }

    public function setMinAgeWithoutTriggeringBinding(age:uint):void
    {
        _minAge = age;
    }

    public function setDurationWithoutTriggeringBinding(duration:int):void
    {
        _duration = duration;
    }

    public function get duration():int
    {
        return _duration;
    }

    public function set duration(value:int):void
    {
        _duration = value;
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