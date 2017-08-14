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
        private static var parent0:Object = {label: "Folder 0", children: new ArrayCollection()};
        private static var parent1:Object = {label: "Folder 1", children: new ArrayCollection([child])};


        [Before]
        public function setUp():void
        {
            _sut = new Tree();
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


        //--------------------------------------------------------------------------
        //
        //  Test method
        //
        //--------------------------------------------------------------------------

        [Test(async, timeout=1000)]
        public function test_object_removed_from_stage_via_code_is_not_initialized():void
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
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, then_expand_second_folder, 200);
        }


        private function then_expand_second_folder(event:Event, passThroughData:Object):void
        {
            //when
            _sut.expandItem(parent1, true, true, true);

            //then wait a bit
            noEnterFramesToWait = 5;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, then_move_child_to_first_parent_and_expand_it, 500);
        }

        private function then_move_child_to_first_parent_and_expand_it(event:Event, passThroughData:Object):void
        {
            //then
            assertThat(_sut.isItemOpen(parent1));

            //when
            ArrayCollection(parent1.children).removeItemAt(0);
            _sut.expandItem(parent0, true, true, true);
            ArrayCollection(parent0.children).addItem(child);

            //then wait a bit
            noEnterFramesToWait = 1;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, then_contract_second_folder, 200);
        }

        private static function then_contract_second_folder(event:Event, passThroughData:Object):void
        {
            //when
            _sut.expandItem(parent1, false, true, true);

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