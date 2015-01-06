package spark.skins.spark {
    import flash.events.Event;
    import flash.events.EventDispatcher;

    import mx.managers.FocusManager;
    import mx.managers.IFocusManagerContainer;

    import org.flexunit.asserts.assertTrue;
    import org.flexunit.async.Async;
    import org.fluint.uiImpersonation.UIImpersonator;

    import spark.components.TextInput;

    public class FLEX_34625_Test {

        private static const NO_ENTER_FRAMES_TO_ALLOW:int = 4;
        private var noEnterFramesRemaining:int = NaN;
        private var _finishNotifier:EventDispatcher;

        [Before]
        public function setUp():void
        {
            _finishNotifier = new EventDispatcher();
        }

        [After]
        public function tearDown():void
        {
            _finishNotifier = null;
        }

        [Test(async, timeout=500)]
        public function testFocusSkinWithZeroFocusThickness():void
        {
            //given
            const fm:FocusManager = new FocusManager(UIImpersonator.testDisplay as IFocusManagerContainer, false);
            fm.showFocusIndicator = true;

            const textInput:TextInput = new TextInput();
            textInput.focusManager = fm;
            UIImpersonator.addChild(textInput);

            //when
            textInput.setStyle("focusThickness", 0);
            textInput.setFocus();

            //then wait for the focus skin to show
            noEnterFramesRemaining = NO_ENTER_FRAMES_TO_ALLOW;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, onTestComplete);
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
