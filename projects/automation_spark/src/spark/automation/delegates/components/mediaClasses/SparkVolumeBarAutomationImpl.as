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

package spark.automation.delegates.components.mediaClasses
{
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.ui.Keyboard;
    import flash.utils.getTimer;
    
    import mx.automation.Automation;
    import mx.automation.IAutomationObjectHelper;
    import mx.core.mx_internal;
    import mx.events.FlexEvent;
    
    import spark.automation.delegates.components.supportClasses.SparkSliderBaseAutomationImpl;
    import spark.components.mediaClasses.VolumeBar;
    import spark.events.DropDownEvent;
    
    use namespace mx_internal;
    
    [Mixin]
    /**
     * 
     *  Defines methods and properties required to perform instrumentation for the 
     *  VolumeBar control.
     * 
     *  @see spark.components.mediaClasses.VolumeBar
     *
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public class SparkVolumeBarAutomationImpl extends SparkSliderBaseAutomationImpl 
    {
        include "../../../../core/Version.as";
        
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
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public static function init(root:DisplayObject):void
        {
            Automation.registerDelegateClass(spark.components.mediaClasses.VolumeBar, SparkVolumeBarAutomationImpl);
        }   
        
        /**
         *  Constructor.
         * @param obj VolumeBar object to be automated.     
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function SparkVolumeBarAutomationImpl(obj:spark.components.mediaClasses.VolumeBar)
        {
            super(obj);
            
            obj.addEventListener(spark.events.DropDownEvent.CLOSE, openCloseHandler, false, 0, true);
            obj.addEventListener(spark.events.DropDownEvent.OPEN, openCloseHandler, false, 0, true);
            obj.addEventListener(mx.events.FlexEvent.MUTED_CHANGE, muteChangeHandler, false, 0, true);
        }
        
        /**
         *  @private
         *  storage for the owner component
         */
        protected function get sparkVolumeBar():spark.components.mediaClasses.VolumeBar
        {
            return uiComponent as spark.components.mediaClasses.VolumeBar;
            
        }
        
        //--------------------------------------------------------------------------
        //
        //  Event handlers
        //
        //--------------------------------------------------------------------------
        
        /**
         *  @private
         */
        private function openCloseHandler(event:spark.events.DropDownEvent):void
        {
            // if we have a drop down object, we need to listen to the record
            // events coming from the same in the open handler and remove the same
            // in the close handler.
            // ref: DropDownListBaseAutomationImpl
            
            if (event.type == DropDownEvent.OPEN)
            {
                recordAutomatableEvent(event);              
            }
        }
        
        /**
         *  @private
         */
        private function muteChangeHandler(event:mx.events.FlexEvent):void
        {
            recordAutomatableEvent(event);
        }
        
        override public function replayAutomatableEvent(event:Event):Boolean
        {
            var completeTime:Number;
            var help:IAutomationObjectHelper = Automation.automationObjectHelper;
            
            if (event is mx.events.FlexEvent)
            {
                // we need to replay the click on the muteButton
                if(event.type == FlexEvent.MUTED_CHANGE)
                {
                    help.replayClick(sparkVolumeBar.muteButton);
                }
            }
            else if (event is KeyboardEvent)
            {
                var keyEvent:KeyboardEvent = event as KeyboardEvent;
                
                // if volumeBar is closing due to either selection or escape we need to wait
                // and sync up
                if (keyEvent.keyCode == Keyboard.ENTER || keyEvent.keyCode == Keyboard.ESCAPE)
                {
                    completeTime = getTimer() + sparkVolumeBar.getStyle("closeDuration");
                    
                    help.addSynchronization(function():Boolean
                    {
                        return getTimer() >= completeTime;
                    });
                }
                return help.replayKeyboardEvent(uiComponent, KeyboardEvent(event));
                //}
            }
            else if (event is spark.events.DropDownEvent)
            {
                var cbdEvent:spark.events.DropDownEvent = spark.events.DropDownEvent(event);
                if (cbdEvent.triggerEvent is KeyboardEvent)
                {
                    var kbEvent:KeyboardEvent =
                        new KeyboardEvent(KeyboardEvent.KEY_DOWN);
                    kbEvent.keyCode =
                        (cbdEvent.type == spark.events.DropDownEvent.OPEN
                            ? Keyboard.DOWN
                            : Keyboard.UP);
                    kbEvent.ctrlKey = true;
                    help.replayKeyboardEvent(uiComponent, kbEvent);
                }
                else //triggerEvent is MouseEvent
                {
                    // Usually we dispatch mouseClick events. But as they are handled in a different way
                    // for this component, we are dispatching a roll_over and mouse_down events
                    help.replayMouseEvent(sparkVolumeBar.muteButton, new MouseEvent(MouseEvent.ROLL_OVER));
                    help.replayMouseEvent(sparkVolumeBar.muteButton, new MouseEvent(MouseEvent.MOUSE_DOWN));
                }
                
                completeTime = getTimer() +
                    sparkVolumeBar.getStyle(cbdEvent.type == spark.events.DropDownEvent.OPEN ?
                        "openDuration" :
                        "closeDuration");
                
                help.addSynchronization(function():Boolean
                {
                    return getTimer() >= completeTime;
                });
                
                return true;
            }
            
            return super.replayAutomatableEvent(event);         
        }       
    }
}
