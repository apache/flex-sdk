package {
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
        private var _textInput:TextInput;

        [Before]
        public function setUp():void
        {
            var focusManager:FocusManager = new FocusManager(UIImpersonator.testDisplay as IFocusManagerContainer);
            focusManager.showFocusIndicator = true;

            _textInput = new TextInput();
            _textInput.focusManager = focusManager;

            _finishNotifier = new EventDispatcher();
        }

        [After]
        public function tearDown():void
        {
            _textInput = null;
            _finishNotifier = null;
        }

        [Test(async, timeout=500)]
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
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, onTestComplete);
        }

        [Test(async, timeout=500)]
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
