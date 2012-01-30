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
    import flash.events.MouseEvent;
    
    import mx.automation.Automation;
    import mx.automation.IAutomationObjectHelper;
    import mx.core.mx_internal;
    import mx.events.ScrollEvent;
    import mx.managers.DragManager;
    
    import spark.automation.events.SparkValueChangeAutomationEvent;
    import spark.components.supportClasses.ScrollBarBase;
    import spark.events.TrackBaseEvent;
    
    use namespace mx_internal;
    
    [Mixin]
    /**
     * 
     *  Defines methods and properties required to perform instrumentation for the 
     *  ScrollBarBase class.
     * 
     *  @see spark.components.supportClasses.ScrollBarBase 
     *
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public class SparkScrollBarBaseAutomationImpl extends SparkTrackBaseAutomationImpl 
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
            Automation.registerDelegateClass(spark.components.supportClasses.ScrollBarBase, SparkScrollBarBaseAutomationImpl);
        }   
        
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Constructor.
         * @param obj ScrollBarBase object to be automated.     
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function SparkScrollBarBaseAutomationImpl(obj:spark.components.supportClasses.ScrollBarBase)
        {
            super(obj);
            
            obj.addEventListener(Event.CHANGE, scrollHandler, false, -1, true);
			obj.addEventListener(TrackBaseEvent.THUMB_PRESS, thumbPressHandler, false, -1, true);
			obj.addEventListener(TrackBaseEvent.THUMB_RELEASE, thumbReleaseHandler, false, -1, true);
        }
		
		private var thumbDown:Boolean = false;
        
        /**
         *  @private
         *  storage for the owner component
         */
        protected function get scroll():spark.components.supportClasses.ScrollBarBase
        {
            return uiComponent as spark.components.supportClasses.ScrollBarBase;
        }
        
        //----------------------------------
        //  automationValue
        //----------------------------------
        
        /**
         *  @private
         */
        override public function get automationValue():Array
        {
            return [ scroll.value.toString() ];
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
                var currentChange:int = event.value -  scroll.value;
                var target:IEventDispatcher = null;
                if(DragManager.isDragging)
                {
                    scroll.value = event.value;
                    scroll.validateNow();
                }
                else
                {
                    var mouseEvent:MouseEvent = new MouseEvent(MouseEvent.CLICK);
                    if(currentChange == scroll.stepSize)
                    {
                        if(currentChange  > 0)
                            target = scroll.incrementButton;
                        else
                            target = scroll.decrementButton;
                    }
                    else
                    {
                        target = scroll.thumb;
                        if(currentChange  > 0)
                        {
                            mouseEvent.localX = scroll.width;
                            mouseEvent.localY = scroll.height;
                        }
                        else
                        {
                            mouseEvent.localX = 0;
                            mouseEvent.localY = 0;
                        }
                        
                    }
                    
                    scroll.value = event.value;
                    if (target)
                    {
                        var help:IAutomationObjectHelper = Automation.automationObjectHelper;
                        help.replayClick(target, mouseEvent);
                    }
                }
                return true; 
            }
            else
            {
                return super.replayAutomatableEvent(interaction);
            }
        }
        
        //--------------------------------------------------------------------------
        //
        //  Event handlers
        //
        //--------------------------------------------------------------------------
        
        /**
         *  @private
         */
        private function scrollHandler(event:Event):void
        { 
			if(!thumbDown) // record only if it not dispatched when thumb is down
							//this records change events when user clicks on
							// increment or decrement buttons
			{
				// the event does not give the details of the value. So we need to provide this
				// so that replay can happen accordingly
				var valueChangeEvent:SparkValueChangeAutomationEvent = 
					new SparkValueChangeAutomationEvent(
						SparkValueChangeAutomationEvent.CHANGE,false,false,scroll.value);
				recordAutomatableEvent(valueChangeEvent);
			}
        }
		
		/**
		 *  @private
		 */
		private function thumbPressHandler(event:TrackBaseEvent):void
		{ 
			thumbDown = true;
		}
		
		/**
		 *  @private
		 */
		private function thumbReleaseHandler(event:TrackBaseEvent):void
		{ 
			thumbDown = false;
			// the event does not give the details of the value. So we need to provide this
			// so that replay can happen accordingly
			var valueChangeEvent:SparkValueChangeAutomationEvent = 
				new SparkValueChangeAutomationEvent(
					SparkValueChangeAutomationEvent.CHANGE,false,false,scroll.value);
			recordAutomatableEvent(valueChangeEvent);
		}
        
    }
}