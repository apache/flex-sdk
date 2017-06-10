package mx.managers {
    import flash.events.Event;
    import flash.events.EventDispatcher;

    import mx.core.UIComponentGlobals;
    import mx.core.mx_internal;
    import mx.events.FlexEvent;

    import org.flexunit.asserts.assertEquals;
    import org.flexunit.asserts.assertNotNull;
    import org.flexunit.asserts.assertNull;
    import org.flexunit.async.Async;
    import org.fluint.uiImpersonation.UIImpersonator;

    use namespace mx_internal;

    public class LayoutManager_FLEX_35321_Tests
    {
        private static var noEnterFramesRemaining:int = NaN;
        private static const _finishNotifier:EventDispatcher = new EventDispatcher();

        private var _objectWhichIsRemovedOnSizeValidation:SomeComponent;
        private var _creationCompleteCalls:int;

        [Before]
        public function setUp():void
        {
            _creationCompleteCalls = 0;
            _objectWhichIsRemovedOnSizeValidation = new SomeComponent();
            _objectWhichIsRemovedOnSizeValidation.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
            UIImpersonator.addElement(_objectWhichIsRemovedOnSizeValidation);
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
            _objectWhichIsRemovedOnSizeValidation.removeFromStageOnValidateProperties = true;

            //when
            _objectWhichIsRemovedOnSizeValidation.validateNow();

            //then
            assertNull("The object was actually not removed from stage. Huh?", _objectWhichIsRemovedOnSizeValidation.parent);
            assertEquals("Yep, this is the bug. Why call initialized=true on an object that's not on stage?", 0, _creationCompleteCalls);
        }

        [Test(async, timeout=500)]
        public function test_object_removed_from_stage_via_user_action_is_not_initialized():void
        {
            //given
            UIComponentGlobals.mx_internal::layoutManager.usePhasedInstantiation = true;
            _objectWhichIsRemovedOnSizeValidation.removeFromStageOnValidateProperties = false;

            //when
            _objectWhichIsRemovedOnSizeValidation.invalidateDisplayList();
            _objectWhichIsRemovedOnSizeValidation.invalidateProperties();
            _objectWhichIsRemovedOnSizeValidation.invalidateSize();

            //then wait 1 frame
            noEnterFramesRemaining = 1;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, then_remove_from_stage_in_next_frame, 300);
        }

        private function then_remove_from_stage_in_next_frame(event:Event, passThroughData:Object):void
        {
            //when
            _objectWhichIsRemovedOnSizeValidation.pretendUserAskedForComponentRemovalInNextFrame();

            //then wait 2 frames
            noEnterFramesRemaining = 2;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, then_assert_not_initialized, 300);
        }

        private function then_assert_not_initialized(event:Event, passThroughData:Object):void
        {
            //then
            assertNull("The object was actually not removed from stage. Huh?", _objectWhichIsRemovedOnSizeValidation.parent);
            assertEquals("Yep, this is the bug. Why call initialized=true on an object that's not on stage?", 0, _creationCompleteCalls);
        }


        [Test(async, timeout=750)]
        public function test_object_removed_from_stage_then_readded_is_initialized_once():void
        {
            //given
            UIComponentGlobals.mx_internal::layoutManager.usePhasedInstantiation = true;
            _objectWhichIsRemovedOnSizeValidation.removeFromStageOnValidateProperties = false;

            //when
            _objectWhichIsRemovedOnSizeValidation.validateNow();
            _objectWhichIsRemovedOnSizeValidation.pretendUserAskedForComponentRemovalInNextFrame();

            //then wait 1 frame
            noEnterFramesRemaining = 1;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, then_readd_object, 200);
        }

        private function then_readd_object(event:Event, passThroughData:Object):void
        {
            //then
            assertNull("The object was actually not removed from stage. Huh?", _objectWhichIsRemovedOnSizeValidation.parent);

            //when
            UIImpersonator.addElement(_objectWhichIsRemovedOnSizeValidation);

            //then wait 4 frames, to make sure validation is done
            noEnterFramesRemaining = 4;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, then_assert_one_initialization_only, 400);
        }

        private function then_assert_one_initialization_only(event:Event, passThroughData:Object):void
        {
            //then
            assertNotNull("The object should be on stage...", _objectWhichIsRemovedOnSizeValidation.parent);
            assertEquals("When validation is interrupted half-way it should be complete once the object is re-added to stage", 1, _creationCompleteCalls);
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
            _creationCompleteCalls++;
        }
    }
}

import flash.events.TimerEvent;
import flash.utils.Timer;

import mx.core.IVisualElementContainer;
import mx.core.UIComponent;

class SomeComponent extends UIComponent
{
    private var _removeFromStageOnValidateProperties:Boolean = false;

    override public function validateProperties():void
    {
        super.validateProperties();
        if(_removeFromStageOnValidateProperties)
            removeFromStage();
    }

    override public function validateSize(recursive:Boolean = false):void
    {
        super.validateSize(recursive);
    }

    override public function validateDisplayList():void
    {
        super.validateDisplayList();
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

    public function pretendUserAskedForComponentRemovalInNextFrame():void
    {
        callLater(removeFromStage);
    }

    public function set removeFromStageOnValidateProperties(value:Boolean):void
    {
        _removeFromStageOnValidateProperties = value;
    }
}