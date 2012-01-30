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

package spark.automation.delegates.components.supportClasses
{
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.IEventDispatcher;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.ui.Keyboard;
    import flash.utils.getTimer;
    
    import mx.automation.Automation;
    import mx.automation.IAutomationObjectHelper;
    import mx.core.mx_internal;
    
    import spark.automation.events.SparkValueChangeAutomationEvent;
    import spark.components.HSlider;
    import spark.components.VSlider;
    import spark.components.supportClasses.SliderBase;
    
    use namespace mx_internal;
    
    [Mixin]
    /**
     * 
     *  Defines methods and properties required to perform instrumentation for the 
     *  SliderBarBase class.
     * 
     *  @see spark.components.supportClasses.SliderBarBase 
     *
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public class SparkSliderBaseAutomationImpl extends SparkTrackBaseAutomationImpl 
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
            Automation.registerDelegateClass(spark.components.supportClasses.SliderBase, SparkSliderBaseAutomationImpl);
        }   
        
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Constructor.
         * @param obj SliderBarBase object to be automated.     
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function SparkSliderBaseAutomationImpl(obj:spark.components.supportClasses.SliderBase)
        {
            super(obj);
            
            obj.addEventListener(Event.CHANGE, scrollHandler, false, -1, true);
        }
        
        /**
         *  @private
         *  storage for the owner component
         */
        protected function get slider():spark.components.supportClasses.SliderBase
        {
            return uiComponent as spark.components.supportClasses.SliderBase;
        }
        
        
        
        //----------------------------------
        //  automationValue
        //----------------------------------
        
        /**
         *  @private
         */
        override public function get automationValue():Array
        {
            //return [ slider.value.toString() ];
            return super.automationValue;
        }
        
        /**
         *  @private
         *  Replays ScrollEvents.
         *  ScrollEvents are replayed by simply setting the
         *  <code>verticalScrollPosition</code> or
         *  <code>horizontalScrollPosition</code> properties of the instance.
         */
        override public function replayAutomatableEvent(interaction:Event):Boolean
        {
            if ( interaction is SparkValueChangeAutomationEvent)
            {
                var event:SparkValueChangeAutomationEvent = SparkValueChangeAutomationEvent(interaction);
                var target:IEventDispatcher = null;
                var mouseEvent:MouseEvent = new MouseEvent(MouseEvent.MOUSE_DOWN);  
                
                var mousePoint:Point = new Point(0,0);
                
                var thumbW:Number = (slider.thumb) ? slider.thumb.width : 0;
                var thumbH:Number = (slider.thumb) ? slider.thumb.height : 0;
                
                if(slider is  spark.components.HSlider)
                    mousePoint = hSliderValueToPoint(event.value);
                    
                else if (slider is spark.components.VSlider)
                    mousePoint = vSliderValueToPoint(event.value);
                
                mouseEvent.localX = mousePoint.x;
                mouseEvent.localY = mousePoint.y;
                target = slider.track;
                if (target)
                {
                    var help:IAutomationObjectHelper = Automation.automationObjectHelper;
                    help.replayClick(target, mouseEvent);
                }
                
                var completeTime:Number = getTimer() + slider.getStyle("slideDuration");
                
                help.addSynchronization(function():Boolean
                {
                    return getTimer() >= completeTime;
                });
                return true; 
            }   
            else if (interaction is KeyboardEvent)
            {
                var help1:IAutomationObjectHelper = Automation.automationObjectHelper;
                help1.replayKeyboardEvent(slider, interaction as KeyboardEvent);
            }
            else
            {
                return super.replayAutomatableEvent(interaction);
            }
            
            return true;
        }
        
        private function  vSliderValueToPoint(value:Number):Point
        {
            // we are doing the reverse conversion od the pointToValue  in the VSlider
            // we even consider the modiifcation done in the mouseDownHanlder for the track in the slider
            var thumbRange:Number = slider.track.getLayoutBoundsHeight() - slider.thumb.getLayoutBoundsHeight();
            var range:Number = slider.maximum - slider.minimum;
            var localY:Number = thumbRange - ( (Number(value -slider.minimum) /  range)*  thumbRange)
            
            var thumbW:Number = (slider.thumb) ? slider.thumb.width : 0;
            var thumbH:Number = (slider.thumb) ? slider.thumb.height : 0;
            
            
            var adjustedY:Number = localY + (thumbH / 2);
            var adjustedX:Number = thumbW/2;
            
            return new Point(adjustedX,adjustedY);
        }
        
        
        private function  hSliderValueToPoint(value:Number):Point
        {
            // we are doing the reverse conversion od the pointToValue  in the VSlider
            // we even consider the modiifcation done in the mouseDownHanlder for the track in the slider
            var thumbRange:Number = slider.track.getLayoutBoundsWidth() - slider.thumb.getLayoutBoundsWidth();
            var range:Number = slider.maximum - slider.minimum;
            var localX:Number = ((value - slider.minimum)/ range)* thumbRange; 
            
            
            var thumbW:Number = (slider.thumb) ? slider.thumb.width : 0;
            var thumbH:Number = (slider.thumb) ? slider.thumb.height : 0;
            
            
            var adjustedX:Number = localX + (thumbW / 2);
            var adjustedY:Number = thumbH/2;
            
            return new Point(adjustedX,adjustedY);
        }
        
        
        //--------------------------------------------------------------------------
        //
        //  Event handlers
        //
        //--------------------------------------------------------------------------
        
        /**
         *  @private
         */
        protected var keyDownHappened:Boolean = false;
        private function scrollHandler(event:Event):void
        { 
            if(!keyDownHappened)
            {
                // the event does not give the details of the value. So we need to provide this
                // so that replay can happen accordingly
                if(!(isNaN(slider.value)))
                {
                    var valueChangeEvent:SparkValueChangeAutomationEvent = 
                        new SparkValueChangeAutomationEvent(
                            SparkValueChangeAutomationEvent.CHANGE,false,false,slider.value);
                    recordAutomatableEvent(valueChangeEvent);
                }
            }
            else
            {
                // let the keyboard event hanlder in the appropriate component take care of the recording
                keyDownHappened = false;
            }
            
            
        }
        
        
        
        override protected function keyDownHandler(event:KeyboardEvent) : void
        {
            
            // we need to inform that when keydown happens the change handler should not be
            // called and instead we want to record it as the key operation
            keyDownHappened = true;
            
            if (event.keyCode == Keyboard.HOME ||
                event.keyCode == Keyboard.END ||
                event.keyCode == Keyboard.UP ||
                event.keyCode == Keyboard.DOWN||
                event.keyCode == Keyboard.LEFT||
                event.keyCode == Keyboard.RIGHT)
            {
                recordAutomatableEvent(event);
            }
            
        }
        
        
    }
}