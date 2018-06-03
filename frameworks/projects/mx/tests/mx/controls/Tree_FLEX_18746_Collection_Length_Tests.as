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

    import org.flexunit.asserts.assertEquals;
    import org.flexunit.async.Async;
    import org.fluint.uiImpersonation.UIImpersonator;

    use namespace mx_internal;

    public class Tree_FLEX_18746_Collection_Length_Tests
    {
        private static var noEnterFramesToWait:int = NaN;
        private static const _finishNotifier:EventDispatcher = new EventDispatcher();

        private static var _sut:Tree_;
        private static var Sam:TreeItem;
        private static var Ana:TreeItem;
        private static var Jenny:TreeItem;
        private static var Marc:TreeItem;
        private static var parentJill:TreeItem;
        private static var parentJohn:TreeItem;


        [Before]
        public function setUp():void
        {
            Sam = new TreeItem("Sam");
            Ana = new TreeItem("Ana");
            Jenny = new TreeItem("Jenny");
            Marc = new TreeItem("Marc");

            _sut = new Tree_();
            _sut.width = 200;
            _sut.height = 200;

            UIImpersonator.addChild(_sut);
        }

        [After]
        public function tearDown():void
        {
            UIImpersonator.removeAllChildren();
            _sut = null;
        }


        [Test(async, timeout=300)]
        public function test_opening_closing_with_both_parents_having_at_least_one_child():void
        {
            //given
            parentJill = new TreeItem("Jill", new ArrayCollection([Marc]));
            parentJohn = new TreeItem("John", new ArrayCollection([Sam]));

            const dataProvider:ArrayCollection = new ArrayCollection();
            dataProvider.addItem(parentJill);
            dataProvider.addItem(parentJohn);

            //when
            _sut.dataProvider = dataProvider;

            //then wait a few frames
            noEnterFramesToWait = 2;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, then_expand_and_contract, 250);
        }

        [Test(async, timeout=300)]
        public function test_opening_closing_with_Jill_having_no_children_to_begin_with():void
        {
            //given
            parentJill = new TreeItem("Jill", new ArrayCollection());
            parentJohn = new TreeItem("John", new ArrayCollection([Sam]));

            const dataProvider:ArrayCollection = new ArrayCollection();
            dataProvider.addItem(parentJill);
            dataProvider.addItem(parentJohn);

            //when
            _sut.dataProvider = dataProvider;

            //then wait a few frames
            noEnterFramesToWait = 2;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, then_expand_and_contract, 250);
        }

        private static function then_expand_and_contract(event:Event, passThroughData:Object):void
        {
            //given
            var currentLength:int = _sut.collectionLength_; //current length is correct

            //then
            assertEquals(2, currentLength);

            //when
            _sut.expandItem(parentJohn, true, false, true);
            currentLength += parentJohn.children.length;

            //then
            assertEquals(currentLength, _sut.collectionLength_);

            //when
            _sut.expandItem(parentJill, true, false, true);
            currentLength += parentJill.children.length;

            //then
            assertEquals(currentLength, _sut.collectionLength_);

            //when
            parentJohn.children.addItem(Jenny);
            currentLength += 1;

            //then
            assertEquals(currentLength, _sut.collectionLength_);

            //when
            _sut.expandItem(parentJohn, false, false, true);
            currentLength -= parentJohn.children.length;

            //then
            assertEquals(currentLength, _sut.collectionLength_);

            //when
            parentJill.children.addItem(Ana);
            currentLength += 1;

            //then
            assertEquals(currentLength, _sut.collectionLength_);
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

import mx.controls.Tree;
import mx.controls.treeClasses.HierarchicalCollectionView;

class Tree_ extends Tree
{
    public function getHierarchicalCollection():HierarchicalCollectionView
    {
        return super.collection as HierarchicalCollectionView;
    }

    public function get collectionLength_():int
    {
        return getHierarchicalCollection().length;
    }
}

import mx.collections.ArrayCollection;

class TreeItem {
    private var _label:String;
    private var _children:ArrayCollection;

    public function TreeItem(label:String, children:ArrayCollection = null)
    {
        this.label = label;
        this.children = children;
    }

    [Bindable]
    public function set label(label:String):void
    {
        _label = label;
    }

    public function get label():String
    {
        return _label;
    }

    [Bindable]
    public function set children(children:ArrayCollection):void
    {
        _children = children;
    }

    public function get children():ArrayCollection
    {
        return _children;
    }

    public function toString():String
    {
        return "TreeItem{_label=" + String(_label) + "}";
    }
}