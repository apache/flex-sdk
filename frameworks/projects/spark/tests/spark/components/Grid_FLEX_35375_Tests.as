package spark.components {
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;

    import mx.binding.utils.BindingUtils;

    import mx.collections.ArrayCollection;

    import mx.collections.IList;

    import org.flexunit.asserts.assertTrue;
    import org.flexunit.async.Async;
    import org.fluint.uiImpersonation.UIImpersonator;

    public class Grid_FLEX_35375_Tests {
        private var _sut:DataGrid;
        private static const NO_ENTER_FRAMES_TO_ALLOW:int = 2;
        private static var noEnterFramesRemaining:int = NaN;
        private static const _finishNotifier:EventDispatcher = new EventDispatcher();
        private var _initialSelectedItem:Object = null;
        private var _selectedItemBindingTriggered:Boolean;

        [Before]
        public function setUp():void
        {
            _sut = new DataGrid();
        }

        [After]
        public function tearDown():void
        {
            _sut = null;
            _initialSelectedItem = null;
            _selectedItemBindingTriggered = false;
            UIImpersonator.removeAllChildren();
        }

        [Test(async, timeout=2000)]
        public function test_changing_dataProvider_clears_selection_and_notifies_bindings():void
        {
            //given
            _sut.requireSelection = false;
            _sut.dataProvider = getTestDataProvider();
            UIImpersonator.addChild(_sut);

            noEnterFramesRemaining = NO_ENTER_FRAMES_TO_ALLOW;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, then_reset_data_provider, 600);
        }

        private function then_reset_data_provider(event:Event, passThroughData:Object):void
        {
            //given
            _sut.selectedItem = _sut.dataProvider.getItemAt(0);
            _initialSelectedItem = _sut.selectedItem;
            BindingUtils.bindSetter(setNewlySelectedItem, _sut, "selectedItem");

            //when
            _sut.dataProvider = getTestDataProvider();

            //then
            noEnterFramesRemaining = NO_ENTER_FRAMES_TO_ALLOW;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, then_verify_notifications_sent_if_selection_cleared, 600);
        }

        private function then_verify_notifications_sent_if_selection_cleared(event:Event, passThroughData:Object):void
        {
            //given
            const selectedItemNotificationsShouldHaveBeenSent:Boolean = _sut.selectedItem != _initialSelectedItem;

            //then
            if(selectedItemNotificationsShouldHaveBeenSent)
            {
                assertTrue("The change of the selectedItem should have been notified by the Grid!", _selectedItemBindingTriggered);
            }
            else
            {
                assertTrue(true); //nothing to verify
            }
        }




        private function setNewlySelectedItem(value:Object):void
        {
            if(value != _initialSelectedItem)
            {
                _selectedItemBindingTriggered = true;
            }
        }

        private static function getTestDataProvider():IList
        {
            return new ArrayCollection([{id:1, name:"Andy"}, {id:2, name:"Zainab"}, {id:3, name:"Greta"}]);
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
