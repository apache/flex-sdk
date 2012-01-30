////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.automation.delegates.components
{
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    
    import mx.automation.Automation;
    import mx.automation.IAutomationObjectHelper;
    import mx.core.mx_internal;
    import mx.events.FlexEvent;
    
    import spark.automation.delegates.components.supportClasses.SparkRangeAutomationImpl;
    import spark.automation.events.SparkValueChangeAutomationEvent;
    import spark.components.Spinner;
    
    use namespace mx_internal;
    
    [Mixin]
    /**
     * 
     *  Defines methods and properties required to perform instrumentation for the 
     *  Spinner control.
     * 
     *  @see spark.components.Spinner 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     *
     */
    public class SparkSpinnerAutomationImpl extends SparkRangeAutomationImpl 
    {
        include "../../../core/Version.as";
        
        //--------------------------------------------------------------------------
        //
        //  Class methods
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Registers the delegate class for a component class with automation manager.
         *  
         *  @param root The SystemManger of the application.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public static function init(root:DisplayObject):void
        {
            Automation.registerDelegateClass(spark.components.Spinner, SparkSpinnerAutomationImpl);
        }   
        
        /**
         *  Constructor.
         * @param obj Spinner object to be automated.     
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function SparkSpinnerAutomationImpl(obj:spark.components.Spinner)
        {
            super(obj);
            obj.addEventListener(Event.CHANGE, nSpinnerChangeHandler, false, 0, true);
            obj.addEventListener(KeyboardEvent.KEY_DOWN,keyDownHandler1,true,50,true);
            
        }
        
        /**
         *  @private
         */
        protected function get nSpinner():spark.components.Spinner
        {
            return uiComponent as spark.components.Spinner;   
        }
        
        
        
        
        /**
         *  @private
         */
        protected var keyDownHappened:Boolean = false;
        protected function nSpinnerChangeHandler(event:Event):void
        {
            //We will get the change event for both mouse and keyboard interactions.
            // We will only record for the mouse interactions and let the keyDownHandler
            // to record the KeyBoard operations.
            if(!keyDownHappened)
            {
                // the event does not give the details of the value. So we need to provide this
                // so that replay can happen accordingly
                var nSpinnerEvent:SparkValueChangeAutomationEvent = 
                    new SparkValueChangeAutomationEvent(
                        SparkValueChangeAutomationEvent.CHANGE,false,false,nSpinner.value);
                recordAutomatableEvent(nSpinnerEvent);
            }
            else
            {
                // let the keyboard event hanlder in the appropriate component take care of the recording
                keyDownHappened = false;
            }
            
            
        }
        
        /**
         *  @private
         */
        protected function keyDownHandler1(event:KeyboardEvent):void
        {
            keyDownHappened = true;
        }
        
        /**
         *  @private
         */
        override public function replayAutomatableEvent(event:Event):Boolean
        {
            
            var help:IAutomationObjectHelper = Automation.automationObjectHelper;
            if (event is SparkValueChangeAutomationEvent)
            {
                var nsEvent:SparkValueChangeAutomationEvent = SparkValueChangeAutomationEvent(event);
                // here we need a Button Down event to be replayed, as the mouse down does not trigger
                // button down. However we are still replaying the mouse events also to make the
                //  handlers for those events to happen.
                var buttonDownEvent:FlexEvent = new FlexEvent(FlexEvent.BUTTON_DOWN);
                
                if(nsEvent.value > nSpinner.value)
                {
                    nSpinner.incrementButton.dispatchEvent(buttonDownEvent);
                    help.replayClick(nSpinner.incrementButton);
                }
                else if(nsEvent.value < nSpinner.value)
                {
                    nSpinner.decrementButton.dispatchEvent(buttonDownEvent);
                    help.replayClick(nSpinner.decrementButton);
                }
                // no event if the value was the same as before
            }
            else
            {
                return super.replayAutomatableEvent(event);
            }
            
            return true;
        }
        
        
    }
    
}