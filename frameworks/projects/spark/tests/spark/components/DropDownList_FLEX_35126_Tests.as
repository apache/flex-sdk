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

    import mx.events.FlexMouseEvent;

    import org.flexunit.assertThat;
    import org.flexunit.asserts.assertEquals;
    import org.flexunit.asserts.assertFalse;
    import org.flexunit.asserts.assertTrue;
    import org.flexunit.async.Async;
    import org.fluint.uiImpersonation.UIImpersonator;

    public class DropDownList_FLEX_35126_Tests
    {
        private static const NO_ENTER_FRAMES_TO_ALLOW:int = 2;
        private static var noEnterFramesRemaining:int = NaN;
        private static const _finishNotifier:EventDispatcher = new EventDispatcher();

        private static var _sut:DropDownListInspectable;
        private static var _dropDownListOnStage:DropDownList;
        private var _popUp:PopUpAnchor;

        [Before]
        public function setUp():void
        {
            _popUp = new PopUpAnchor();
            _popUp.displayPopUp = true;

            _sut = new DropDownListInspectable();
            _sut.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, onMouseDownOutsidePopup);

            _popUp.popUp = _sut;

            _dropDownListOnStage = new DropDownList();
        }

        private function onMouseDownOutsidePopup(event:FlexMouseEvent):void
        {
            _popUp.displayPopUp = false;
        }

        [After]
        public function tearDown():void
        {
            _sut = null;
            _popUp = null;
            _dropDownListOnStage = null;
        }

        [Test(async, timeout=1000)]
        public function test_dropdown_doesnt_close_when_item_selected_from_DropDownList():void
        {
            //given
            _popUp.width = _sut.width = 150;
            _dropDownListOnStage.x = 200;
            UIImpersonator.addChild(_popUp);
            UIImpersonator.addChild(_dropDownListOnStage);

            //then
            assertTrue(_popUp.displayPopUp);
            assertThat(isNaN(_sut.dropDownController_.rollOverOpenDelay));

            //when
            _sut.openButton.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OVER));
            _sut.openButton.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));

            //then - wait a frame
            noEnterFramesRemaining = NO_ENTER_FRAMES_TO_ALLOW;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, then_open_drop_down, 300);
        }

        private function then_open_drop_down(event:Event, passThroughData:Object):void
        {
            //when - MOUSE_UP to signify the lifting of the mouse button
            _sut.openButton.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));

            //then
            assertTrue(_sut.isDropDownOpen);

            //when - MOUSE_DOWN on the stage dropDownList
            _dropDownListOnStage.openButton.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OVER));
            _dropDownListOnStage.openButton.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));

            //then - wait a frame
            noEnterFramesRemaining = NO_ENTER_FRAMES_TO_ALLOW;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, then_select_item_in_drop_down, 300);
        }

        private function then_select_item_in_drop_down(event:Event, passThroughData:Object):void
        {
            //when - MOUSE_UP to signify the lifting of the mouse button
            _dropDownListOnStage.openButton.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));

            //then
            assertFalse("PopUpAnchor should be closed", _popUp.displayPopUp);
            assertTrue(_dropDownListOnStage.isDropDownOpen);

            //when - second click on stage dropdown
            _dropDownListOnStage.openButton.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OVER));
            _dropDownListOnStage.openButton.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));

            //then
            assertEquals("The DropDownController should have closed the DropDownList at the first click on the other DropDownList, and stopped listening to mouse events", 1, _sut.noReactionsToOutsideClick);
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

import flash.events.Event;

import mx.core.mx_internal;

import spark.components.DropDownList;
import spark.components.supportClasses.DropDownController;
import spark.skins.spark.DropDownListSkin;

use namespace mx_internal;

class DropDownListInspectable extends DropDownList
{
    public var noReactionsToOutsideClick:int = 0;

    public function DropDownListInspectable()
    {
        super();
        this.setStyle("skinClass", DropDownListSkin);
        this.dropDownController = new DropDownControllerInspectable();
        this.dropDownController.addEventListener(DropDownControllerInspectable.REACT_TO_MOUSE_DOWN, onControllerReactedToMouseDown);
    }

    private function onControllerReactedToMouseDown(event:Event):void
    {
        noReactionsToOutsideClick++;
    }

    public function get dropDownController_():DropDownController
    {
        return this.dropDownController;
    }
}

class DropDownControllerInspectable extends DropDownController
{
    public static const REACT_TO_MOUSE_DOWN:String = "justReactedToMouseDown";

    override mx_internal function systemManager_mouseDownHandler(event:Event):void
    {
        super.mx_internal::systemManager_mouseDownHandler(event);
        dispatchEvent(new Event(REACT_TO_MOUSE_DOWN));
    }
}