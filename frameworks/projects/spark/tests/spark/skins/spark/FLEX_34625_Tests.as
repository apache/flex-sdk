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

package spark.skins.spark {
    import flash.events.Event;
    import flash.events.EventDispatcher;

    import mx.managers.FocusManager;
    import mx.managers.IFocusManagerContainer;

    import org.flexunit.asserts.assertTrue;
    import org.flexunit.async.Async;
    import org.fluint.uiImpersonation.UIImpersonator;

    import spark.components.TextInput;

    public class FLEX_34625_Tests {

        private static const NO_ENTER_FRAMES_TO_ALLOW:int = 4;
        private static const TIMEOUT_MS:int = 1000;
        private static const _finishNotifier:EventDispatcher = new EventDispatcher();
        private static var _textInput:TextInput;
        private var noEnterFramesRemaining:int = NaN;

        [Before]
        public function setUp():void
        {
            var _focusManager:FocusManager;
            if (UIImpersonator.testDisplay is IFocusManagerContainer)
                _focusManager = new FocusManager(UIImpersonator.testDisplay as IFocusManagerContainer);
            else
                _focusManager = UIImpersonator.testDisplay.parent["document"].focusManager;
            _focusManager.showFocusIndicator = true;

            _textInput = new TextInput();
            _textInput.width = 0;
            _textInput.height = 0;
            _textInput.focusManager = _focusManager;
        }

        [After]
        public function tearDown():void
        {
            _textInput = null;
        }

        [Test(async, timeout=1100)]
        public function test_focus_skin_with_zero_focus_thickness():void
        {
            //given
            UIImpersonator.addChild(_textInput);

            //when
            _textInput.setStyle("focusThickness", 0);
            _textInput.setFocus();

            //then wait for the focus skin to show
            noEnterFramesRemaining = NO_ENTER_FRAMES_TO_ALLOW;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, onTestComplete, TIMEOUT_MS);
        }

        [Test(async, timeout=1100)]
        public function test_focus_skin_with_NaN_focus_thickness():void
        {
            //given
            UIImpersonator.addChild(_textInput);

            //when
            _textInput.setStyle("focusThickness", NaN);
            _textInput.setFocus();

            //then wait for the focus skin to show
            noEnterFramesRemaining = NO_ENTER_FRAMES_TO_ALLOW;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, onTestComplete, TIMEOUT_MS);
        }

        private function onEnterFrame(event:Event):void
        {
            if(!--noEnterFramesRemaining)
            {
                UIImpersonator.testDisplay.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
                _finishNotifier.dispatchEvent(new Event(Event.COMPLETE));
            }
        }

        private static function onTestComplete(event:Event, passThroughData:Object):void
        {
            //if we get here it means no error has been thrown
            assertTrue(true);
        }
    }
}
