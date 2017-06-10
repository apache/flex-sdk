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

        private var _objectWhichIsRemovedAtValidation:SomeComponent;
        private var _creationCompleteCalls:int;

        [Before]
        public function setUp():void
        {
            _creationCompleteCalls = 0;
            _objectWhichIsRemovedAtValidation = new SomeComponent();
            _objectWhichIsRemovedAtValidation.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
            UIImpersonator.addChild(_objectWhichIsRemovedAtValidation);
        }

        [After]
        public function tearDown():void
        {
            UIImpersonator.removeAllChildren();
            _objectWhichIsRemovedAtValidation = null;
        }


        //--------------------------------------------------------------------------
        //
        //  Test method
        //
        //--------------------------------------------------------------------------


        [Test]
        public function test_object_removed_from_stage_via_code_is_not_initialized():void
        {
            //given
            UIComponentGlobals.mx_internal::layoutManager.usePhasedInstantiation = false;
            _objectWhichIsRemovedAtValidation.removeFromStageOnValidateProperties = true;

            //when
            _objectWhichIsRemovedAtValidation.validateNow();

            //then
            then_assert_not_initialized();
        }



        //--------------------------------------------------------------------------
        //
        //  Test method
        //
        //--------------------------------------------------------------------------


        [Test(async, timeout=500)]
        public function test_object_removed_from_stage_via_user_action_is_not_initialized():void
        {
            //given
            UIComponentGlobals.mx_internal::layoutManager.usePhasedInstantiation = true;
            _objectWhichIsRemovedAtValidation.removeFromStageOnValidateProperties = false;

            //when
            _objectWhichIsRemovedAtValidation.invalidateDisplayList();
            _objectWhichIsRemovedAtValidation.invalidateProperties();
            _objectWhichIsRemovedAtValidation.invalidateSize();

            //then wait 1 frame
            noEnterFramesRemaining = 1;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, then_remove_from_stage_via_callLater, 300, then_assert_not_initialized);
        }




        //--------------------------------------------------------------------------
        //
        //  Test method
        //
        //--------------------------------------------------------------------------

        [Test(async, timeout=750)]
        public function test_object_removed_from_stage_then_readded_is_initialized_once():void
        {
            //given
            UIComponentGlobals.mx_internal::layoutManager.usePhasedInstantiation = true;
            _objectWhichIsRemovedAtValidation.removeFromStageOnValidateProperties = false;

            //when
            _objectWhichIsRemovedAtValidation.invalidateDisplayList();
            _objectWhichIsRemovedAtValidation.invalidateProperties();
            _objectWhichIsRemovedAtValidation.invalidateSize();

            //then wait 1 frame
            noEnterFramesRemaining = 1;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, then_remove_from_stage_via_callLater, 300, then_readd_object);
        }

        private function then_readd_object(event:Event, passThroughData:Object):void
        {
            //then
            assertNull("The object was actually not removed from stage. Huh?", _objectWhichIsRemovedAtValidation.parent);

            //when
            UIImpersonator.addElement(_objectWhichIsRemovedAtValidation);

            //then wait 4 frames, to make sure validation is done
            noEnterFramesRemaining = 4;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, then_assert_one_initialization_only, 400);
        }

        private function then_assert_one_initialization_only(event:Event, passThroughData:Object):void
        {
            //then
            assertNotNull("The object should be on stage...", _objectWhichIsRemovedAtValidation.parent);
            assertEquals("When validation is interrupted half-way it should be complete once the object is re-added to stage", 1, _creationCompleteCalls);
        }


        //--------------------------------------------------------------------------
        //
        //  Shared test methods
        //
        //--------------------------------------------------------------------------

        private function then_remove_from_stage_via_callLater(event:Event, passThroughData:Object):void
        {
            //then
            assertEquals("The first validation step should have completed by now", 1, _objectWhichIsRemovedAtValidation.numValidatePropertiesCalls);
            assertEquals("But not validateSize()", 0, _objectWhichIsRemovedAtValidation.numValidateSizeCalls);
            assertEquals("Nor validateDisplayList()", 0, _objectWhichIsRemovedAtValidation.numValidateDisplayListCalls);

            //given
            const whereToGoNext:Function = passThroughData as Function;

            //when
            _objectWhichIsRemovedAtValidation.pretendUserAskedForComponentRemovalInNextFrame();

            //then wait 2 frames
            noEnterFramesRemaining = 3;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, whereToGoNext, 300);
        }

        private function then_assert_not_initialized(event:Event = null, passThroughData:Object = null):void
        {
            //then
            assertNull("The object was actually not removed from stage. Huh?", _objectWhichIsRemovedAtValidation.parent);
            assertEquals("Yep, this is the bug. Why call initialized=true on an object that's not on stage?", 0, _creationCompleteCalls);
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

import mx.core.IVisualElementContainer;
import mx.core.UIComponent;

class SomeComponent extends UIComponent
{
    private var _removeFromStageOnValidateProperties:Boolean = false;
    private var _numValidatePropertiesCalls:int = 0;
    private var _numValidateSizeCalls:int = 0;
    private var _numValidateDisplayListCalls:int = 0;

    override public function validateProperties():void
    {
        super.validateProperties();
        _numValidatePropertiesCalls++;
        if(_removeFromStageOnValidateProperties)
            removeFromStage();
    }

    override public function validateSize(recursive:Boolean = false):void
    {
        super.validateSize(recursive);
        _numValidateSizeCalls++;
    }

    override public function validateDisplayList():void
    {
        super.validateDisplayList();
        _numValidateDisplayListCalls++;
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

    public function get numValidateDisplayListCalls():int
    {
        return _numValidateDisplayListCalls;
    }

    public function get numValidateSizeCalls():int
    {
        return _numValidateSizeCalls;
    }

    public function get numValidatePropertiesCalls():int
    {
        return _numValidatePropertiesCalls;
    }
}