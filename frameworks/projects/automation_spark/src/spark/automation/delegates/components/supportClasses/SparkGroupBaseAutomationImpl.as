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
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    
    import mx.automation.Automation;
    import mx.automation.IAutomationObject;
    import mx.automation.IAutomationObjectHelper;
    import mx.automation.delegates.core.UIComponentAutomationImpl;
    import mx.automation.tabularData.ContainerTabularData;
    import mx.core.EventPriority;
    import mx.core.mx_internal;
    
    import spark.components.Scroller;
    import spark.components.supportClasses.GroupBase;
    import spark.core.IViewport;
    
    use namespace mx_internal;
    
    [Mixin]
    /**
     * 
     *  Defines methods and properties required to perform instrumentation for the 
     *  GroupBase control.
     * 
     *  @see spark.components.supportClasses.GroupBase
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     *
     */
    public class SparkGroupBaseAutomationImpl extends UIComponentAutomationImpl 
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
         *  @playerversion Flash 9
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public static function init(root:DisplayObject):void
        {
            Automation.registerDelegateClass(spark.components.supportClasses.GroupBase, SparkGroupBaseAutomationImpl);
        }   
        
        /**
         *  Constructor.
         * @param obj GroupBase object to be automated.     
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function SparkGroupBaseAutomationImpl(obj:spark.components.supportClasses.GroupBase)
        {
            super(obj);
            obj.$addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler,
                false, EventPriority.DEFAULT+1, true );
        }
		
		override protected function addMouseEvent(obj:DisplayObject, event:String, handler:Function , 
										 useCapture:Boolean = false , priority:int = 0, useWeekRef:Boolean = false):void
		{
			grpBase.$addEventListener(event, handler, useCapture,priority, useWeekRef);
				// special addevent listener on the container, which does not add the mouse shield.
			
		} 
        
        /**
         *  @private
         *  storage for the owner component
         */
        protected function get grpBase():GroupBase
        {
            return uiComponent as GroupBase;
        }
        
        
        
        //----------------------------------
        //  automationName
        //----------------------------------
        
        /**
         *  @private
         */
        override public function get automationName():String
        {
            return super.automationName;
        }
        
        //----------------------------------
        //  automationValue
        //----------------------------------
        
        /**
         *  @private
         */
        override public function get automationValue():Array
        {
            return  super.automationValue;
        }
        
        
        
        //--------------------------------------------------------------------------
        //
        //  Overridden methods
        //
        //--------------------------------------------------------------------------
        
        /**
         *  @private
         *  Replays click interactions on the button.
         *  If the interaction was from the mouse,
         *  dispatches MOUSE_DOWN, MOUSE_UP, and CLICK.
         *  If interaction was from the keyboard,
         *  dispatches KEY_DOWN, KEY_UP.
         *  Button's KEY_UP handler then dispatches CLICK.
         *
         *  @param event ReplayableClickEvent to replay.
         */
        override public function replayAutomatableEvent(event:Event):Boolean
        {
            var help:IAutomationObjectHelper = Automation.automationObjectHelper;
            
            if (event is MouseEvent && event.type == MouseEvent.CLICK)
                return help.replayClick(uiComponent, MouseEvent(event));
                
            else if (event is MouseEvent && event.type == MouseEvent.MOUSE_WHEEL)
                return help.replayMouseEvent(uiComponent, event as MouseEvent);
                
            else if (event is KeyboardEvent)
                return help.replayKeyboardEvent(uiComponent, KeyboardEvent(event));
                
            else
                return super.replayAutomatableEvent(event);
        }
        
        /**
         *  @private
         */
        override public function createAutomationIDPart(child:IAutomationObject):Object
        {
            var help:IAutomationObjectHelper = Automation.automationObjectHelper;
            return help.helpCreateIDPart(uiAutomationObject, child);
        }
        
        /**
         *  @private
         */
        override public function resolveAutomationIDPart(part:Object):Array
        {
            var help:IAutomationObjectHelper = Automation.automationObjectHelper;
            return help.helpResolveIDPart(uiAutomationObject, part);
        }
        
        /**
         *  @private
         */
        override public function createAutomationIDPartWithRequiredProperties(child:IAutomationObject, properties:Array):Object
        {
            var help:IAutomationObjectHelper = Automation.automationObjectHelper;
            return help.helpCreateIDPartWithRequiredProperties(uiAutomationObject, child,properties);
            
        }
        
        /**
         *  @private
         */
        override public function getAutomationChildren():Array
        {
            var n:int = grpBase.numChildren;
            var childArray:Array = new Array();
            
            for ( var i:int = 0; i<n ; i++)
            {
                var obj:Object = grpBase.getChildAt(i);
                
                // here if are getting scrollers, we need to add the viewport's children as the actual children
                // instead of the scroller
                if(obj is spark.components.Scroller)
                {
                    var scroller:spark.components.Scroller = obj as spark.components.Scroller; 
                    var viewPort:IViewport =  scroller.viewport;
                    if(viewPort is IAutomationObject)
                        childArray.push(viewPort);
                    if(scroller.horizontalScrollBar)
                        childArray.push(scroller.horizontalScrollBar);
                    if(scroller.verticalScrollBar)
                        childArray.push(scroller.verticalScrollBar);
                }
                else
                    childArray.push(obj as IAutomationObject);
            }
            return childArray;
        }
        
        /**
         *  @private
         */
        protected function getInternalScroller():spark.components.Scroller
        {
            var n:int = grpBase.numChildren;
            var childArray:Array = new Array();
            
            for ( var i:int = 0; i<n ; i++)
            {
                var obj:Object = grpBase.getChildAt(i);
                
                // here if are getting scrollers, we need to add the viewport's children as the actual children
                // instead of the scroller
                if(obj is spark.components.Scroller)
                    return obj as spark.components.Scroller;
            }
            
            return null;
        } 
        /**
         *  @private
         */
        override public function get automationTabularData():Object
        {
            return new ContainerTabularData(uiAutomationObject);
        }
        
        /**
         *  @private
         */
        private function mouseWheelHandler(event:MouseEvent):void
        {
            if(event.target == uiComponent)
            {   
                recordAutomatableEvent(event, true);
            }
        }
        
        /**
         *  @private
         */
        override protected function keyDownHandler(event:KeyboardEvent):void
        {
            
            if( event.target == getInternalScroller())
                recordAutomatableEvent(event);
        }
        
    }
    
}