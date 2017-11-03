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

    import mx.collections.ArrayCollection;
    import mx.core.mx_internal;

    import org.flexunit.assertThat;
    import org.flexunit.async.Async;
    import org.fluint.uiImpersonation.UIImpersonator;

    use namespace mx_internal;

    public class Tree_FLEX_18746_Tests
    {
        private static var noEnterFramesToWait:int = NaN;
        private static const _finishNotifier:EventDispatcher = new EventDispatcher();

        private static var _sut:Tree;
        private static var child:Object = {label: "Item"};
        private static var parent0:Object;
        private static var parent1:Object;


        [Before]
        public function setUp():void
        {
            _sut = new Tree();
            _sut.width = 200;
            _sut.height = 200;

            parent0 = {label: "Folder 0", children: new ArrayCollection()};
            parent1 = {label: "Folder 1", children: new ArrayCollection([child])};

            UIImpersonator.addChild(_sut);
        }

        [After]
        public function tearDown():void
        {
            UIImpersonator.removeAllChildren();
            _sut = null;
        }


        [Test(async, timeout=1000)]
        public function test_closing_previously_opened_folder_with_0_children_without_animation_does_not_throw_fatal():void
        {
            //given
            const dataProvider:ArrayCollection = new ArrayCollection();
            dataProvider.addItem(parent0);
            dataProvider.addItem(parent1);

            //when
            _sut.dataProvider = dataProvider;

            //then wait a few frames
            noEnterFramesToWait = 2;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, then_expand_second_folder, 300, {useAnimation:false});
        }

        [Test(async, timeout=1000)]
        public function test_closing_previously_opened_folder_with_0_children_using_animation_does_not_throw_fatal():void
        {
            //given
            const dataProvider:ArrayCollection = new ArrayCollection();
            dataProvider.addItem(parent0);
            dataProvider.addItem(parent1);

            //when
            _sut.dataProvider = dataProvider;

            //then wait a few frames
            noEnterFramesToWait = 2;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, then_expand_second_folder, 300, {useAnimation:true});
        }


        private function then_expand_second_folder(event:Event, passThroughData:Object):void
        {
            //when
            _sut.expandItem(parent1, true, passThroughData.useAnimation, true);

            //then wait a bit
            noEnterFramesToWait = 5;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, then_move_child_to_first_parent_and_expand_it, 500, passThroughData);
        }

        private function then_move_child_to_first_parent_and_expand_it(event:Event, passThroughData:Object):void
        {
            //then
            assertThat(_sut.isItemOpen(parent1));

            //when
            ArrayCollection(parent1.children).removeItemAt(0);
            _sut.expandItem(parent0, true, passThroughData.useAnimation, true);
            ArrayCollection(parent0.children).addItem(child);

            //then wait a bit
            noEnterFramesToWait = 1;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, then_contract_second_folder, 200, passThroughData);
        }

        private static function then_contract_second_folder(event:Event, passThroughData:Object):void
        {
            //when
            _sut.expandItem(parent1, false, passThroughData.useAnimation, true);

            //then no error was thrown
            assertThat(true);
        }


        private static function onEnterFrame(event:Event):void
        {
            if(!--noEnterFramesToWait)
            {
                UIImpersonator.testDisplay.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
                _finishNotifier.dispatchEvent(new Event(Event.COMPLETE));
            }
        }
    }
}