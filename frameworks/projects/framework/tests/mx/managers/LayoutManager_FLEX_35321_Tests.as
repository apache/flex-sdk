package mx.managers {
    import flash.events.Event;
    import flash.events.EventDispatcher;

    import mx.core.UIComponentGlobals;
    import mx.core.mx_internal;
    import mx.events.FlexEvent;

    import org.flexunit.asserts.assertFalse;
    import org.flexunit.asserts.assertNull;
    import org.flexunit.async.Async;
    import org.fluint.uiImpersonation.UIImpersonator;

    use namespace mx_internal;

    public class LayoutManager_FLEX_35321_Tests
    {
        private static var noEnterFramesRemaining:int = NaN;
        private static const _finishNotifier:EventDispatcher = new EventDispatcher();

        private var _objectWhichIsRemovedOnSizeValidation:SomeComponent;
        private var _creationCompleteCalled:Boolean;

        [Before]
        public function setUp():void
        {
            _creationCompleteCalled = false;
            _objectWhichIsRemovedOnSizeValidation = new SomeComponent();
            UIImpersonator.addChild(_objectWhichIsRemovedOnSizeValidation);
        }

        [After]
        public function tearDown():void
        {
            UIImpersonator.removeAllChildren();
            _objectWhichIsRemovedOnSizeValidation = null;
        }

        [Test]
        public function test_object_removed_from_stage_via_code_is_not_initialized():void
        {
            //given
            UIComponentGlobals.mx_internal::layoutManager.usePhasedInstantiation = false;
            _objectWhichIsRemovedOnSizeValidation.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);

            //when
            _objectWhichIsRemovedOnSizeValidation.validateNow();

            //then
            assertNull("The object was actually not removed from stage. Huh?", _objectWhichIsRemovedOnSizeValidation.parent);
            assertFalse("Yep, this is the bug. Why call initialized=true on an object that's not on stage?", _creationCompleteCalled);
        }

        [Test(async, timeout=500)]
        public function test_object_removed_from_stage_via_user_action_is_not_initialized():void
        {
            //given
            UIComponentGlobals.mx_internal::layoutManager.usePhasedInstantiation = true;
            _objectWhichIsRemovedOnSizeValidation.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);

            //when
            _objectWhichIsRemovedOnSizeValidation.validateNow();
            _objectWhichIsRemovedOnSizeValidation.pretendUserAskedForComponentRemoval();

            //then wait 2 frames
            noEnterFramesRemaining = 2;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, then_assert, 300);
        }

        private function then_assert(event:Event, passThroughData:Object):void
        {
            //then
            assertNull("The object was actually not removed from stage. Huh?", _objectWhichIsRemovedOnSizeValidation.parent);
            assertFalse("Yep, this is the bug. Why call initialized=true on an object that's not on stage?", _creationCompleteCalled);
        }

        private static function onEnterFrame(event:Event):void
        {
            if(!--noEnterFramesRemaining)
            {
                UIImpersonator.testDisplay.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
                _finishNotifier.dispatchEvent(new Event(Event.COMPLETE));
            }
        }

        private function onCreationComplete(event:FlexEvent):void
        {
            _creationCompleteCalled = true;
        }
    }
}

import flash.events.TimerEvent;
import flash.utils.Timer;

import mx.core.IVisualElementContainer;
import mx.core.UIComponent;

class SomeComponent extends UIComponent
{
    private var _timer:Timer = new Timer(1, 1);

    override public function validateSize(recursive:Boolean = false):void
    {
        super.validateSize(recursive);
        removeFromStage();
    }

    private function removeFromStage():void
    {
        if(this.parent)
        {
            if(this.parent is IVisualElementContainer)
                IVisualElementContainer(this.parent).removeElement(this);
            else
                this.parent.removeChild(this);
        }
    }

    public function pretendUserAskedForComponentRemoval():void
    {
        callLater(removeFromStage);
    }
}