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

package spark.components.supportClasses {
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.MouseEvent;

    import mx.collections.ArrayCollection;

    import org.flexunit.asserts.assertFalse;
    import org.flexunit.asserts.assertTrue;
    import org.flexunit.async.Async;
    import org.fluint.uiImpersonation.UIImpersonator;

    import spark.components.CalloutButton;
    import spark.components.DropDownList;

    public class CalloutButton_FLEX_34088_Tests
    {
        private static const NO_ENTER_FRAMES_TO_ALLOW:int = 1;
        private static var noEnterFramesRemaining:int = NaN;
        private static const _finishNotifier:EventDispatcher = new EventDispatcher();

        private static var _sut:CalloutButton;
        private static var _dropDownList:DropDownListInspectable;

        [Before]
        public function setUp():void
        {
            _sut = new CalloutButton();

            _dropDownList = new DropDownListInspectable();
            _dropDownList.dataProvider = new ArrayCollection([{label:"Hello"}, {label:"World"}]);
            _sut.calloutContent = [_dropDownList];
        }

        [After]
        public function tearDown():void
        {
            _sut = null;
        }

        [Test(async, timeout=1000)]
        public function test_dropdown_doesnt_close_when_item_selected_from_DropDownList():void
        {
            //given
            UIImpersonator.addChild(_sut);

            //when
            _sut.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OVER));
            _sut.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));

            //then - wait a frame
            noEnterFramesRemaining = NO_ENTER_FRAMES_TO_ALLOW;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, then_open_drop_down, 300);
        }

        private function then_open_drop_down(event:Event, passThroughData:Object):void
        {
            //then
            assertTrue(_sut.isDropDownOpen);

            //when
            _dropDownList.openButton.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OVER));
            _dropDownList.openButton.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));

            //then - wait a frame
            noEnterFramesRemaining = NO_ENTER_FRAMES_TO_ALLOW;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, then_select_item_in_drop_down, 300);
        }

        private function then_select_item_in_drop_down(event:Event, passThroughData:Object):void
        {
            //then
            assertTrue("DropDownList should be open", _dropDownList.isDropDownOpen);
            assertTrue("DropDownList should be open", _dropDownList.owns(DisplayObject(_dropDownList.lastRenderer)));

            //when
            _dropDownList.lastRenderer.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));

            //then - wait a frame
            noEnterFramesRemaining = NO_ENTER_FRAMES_TO_ALLOW;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, then_assert_callout_still_open, 300);
        }

        private function then_assert_callout_still_open(event:Event, passThroughData:Object):void
        {
            //then
            assertFalse(_dropDownList.isDropDownOpen);
            assertTrue("Callout should still be open", _sut.isDropDownOpen);
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

import mx.core.IVisualElement;

import spark.components.DropDownList;
import spark.events.RendererExistenceEvent;
import spark.skins.spark.DropDownListSkin;

class DropDownListInspectable extends DropDownList
{
    public var lastRenderer:IVisualElement;

    public function DropDownListInspectable()
    {
        super();
        this.setStyle("skinClass", DropDownListSkin);
    }

    override protected function dataGroup_rendererAddHandler(event:RendererExistenceEvent):void
    {
        lastRenderer = event.renderer;
        super.dataGroup_rendererAddHandler(event);
    }
}