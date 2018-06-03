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

package spark.layouts {
    import flash.events.Event;
    import flash.events.EventDispatcher;

    import mx.containers.utilityClasses.ConstraintColumn;
    import mx.containers.utilityClasses.ConstraintRow;
    import mx.effects.Resize;
    import mx.states.SetProperty;
    import mx.states.State;
    import mx.states.Transition;

    import org.flexunit.asserts.assertTrue;
    import org.flexunit.async.Async;
    import org.fluint.uiImpersonation.UIImpersonator;

    import spark.components.DropDownList;
    import spark.components.Group;
    import spark.events.DropDownEvent;

    public class ConstraintLayout_FLEX_33311_Tests {
        private static const NO_ENTER_FRAMES_TO_ALLOW:int = 3;
        private static var noEnterFramesRemaining:int = NaN;
        private static const _finishNotifier:EventDispatcher = new EventDispatcher();

        private var _sut:ConstraintLayout;
        private var _parentGroup:Group;
        private var _childGroup1:Group;
        private var _childGroup2:Group;
        private var _dropDown:DropDownList;

        [Before]
        public function setUp():void
        {
            _sut =  new ConstraintLayout();
            _sut.constraintColumns = new <ConstraintColumn>[new ConstraintColumn()];
            var row:ConstraintRow = new ConstraintRow();
            row.id = "row1";
            _sut.constraintRows = new <ConstraintRow>[row];


            _parentGroup = new Group();
            _childGroup1 = new Group();
            _childGroup2 = new Group();

            _dropDown = new DropDownList();
            _childGroup1.addElement(_dropDown);
            _parentGroup.addElement(_childGroup1);
            _parentGroup.addElement(_childGroup2);

            _parentGroup.states = [
                new State({name:"closed", overrides:[new SetProperty(_dropDown, "width", "200")]}),
                new State({name:"open", overrides:[new SetProperty(_dropDown, "width", "400")]})];
            _parentGroup.currentState = "closed";

            var _transition:Transition = new Transition();
            _transition.fromState = "*";
            _transition.toState = "*";
            _transition.effect = new Resize(_childGroup1);
            _parentGroup.transitions = [_transition];
        }

        [After]
        public function tearDown():void
        {
            _sut = null;
            _parentGroup = null;
            _childGroup1 = null;
            _childGroup2 = null;
            _dropDown = null;
        }

        [Test(async, timeout=1000)]
        public function reproduce_bug():void
        {
            function onDropDownOpen(event:DropDownEvent):void
            {
                _parentGroup.currentState = "open";
            }

            function onDropDownClose(event:DropDownEvent):void
            {
                _parentGroup.currentState = "closed";
            }

            //given
            _childGroup1.baseline = "row1:0";
            _childGroup2.baseline = "row1:0";
            _dropDown.addEventListener(DropDownEvent.CLOSE, onDropDownClose);
            _dropDown.addEventListener(DropDownEvent.OPEN, onDropDownOpen);

            //when
            _parentGroup.layout = _sut;
            UIImpersonator.addChild(_parentGroup);
            _dropDown.openDropDown();

            //then - wait a few frames
            noEnterFramesRemaining = NO_ENTER_FRAMES_TO_ALLOW;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, then_no_fatal_was_thrown, 800);
        }

        private static function then_no_fatal_was_thrown(event:Event, passThroughData:Object):void
        {
            assertTrue(true);
        }

        private function onEnterFrame(event:Event):void
        {
            if(!--noEnterFramesRemaining)
            {
                UIImpersonator.testDisplay.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
                _finishNotifier.dispatchEvent(new Event(Event.COMPLETE));
            }
            else if(NO_ENTER_FRAMES_TO_ALLOW - noEnterFramesRemaining == 2)
            {
                _dropDown.closeDropDown(true);
            }
        }
    }
}