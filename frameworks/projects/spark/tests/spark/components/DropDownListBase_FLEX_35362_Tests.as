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
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;

    import org.flexunit.asserts.assertTrue;
    import org.flexunit.async.Async;
    import org.fluint.uiImpersonation.UIImpersonator;

    public class DropDownListBase_FLEX_35362_Tests {
        private var _sut:DropDownList;
        private static const NO_ENTER_FRAMES_TO_ALLOW:int = 2;
        private static var noEnterFramesRemaining:int = NaN;
        private static const _finishNotifier:EventDispatcher = new EventDispatcher();

        [Before]
        public function setUp():void
        {
            _sut = new DropDownList();
        }

        [After]
        public function tearDown():void
        {
            _sut = null;
            UIImpersonator.removeAllChildren();
        }

        [Test(async, timeout=1000)]
        public function test_pressing_END_right_after_opening_doesnt_trigger_fatal():void
        {
            //given
            UIImpersonator.addChild(_sut);

            noEnterFramesRemaining = NO_ENTER_FRAMES_TO_ALLOW;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, then_open_drop_down_and_press_key, 300);
        }

        private function then_open_drop_down_and_press_key(event:Event, passThroughData:Object):void
        {
            //when
            _sut.openDropDown();
            _sut.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 0, Keyboard.END, 0, true, false, false, true, false));

            //then - no fatal thrown
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
    }
}
