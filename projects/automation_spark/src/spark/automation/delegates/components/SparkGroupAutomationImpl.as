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
    import flash.events.MouseEvent;
    
    import mx.automation.Automation;
    import mx.automation.IAutomationObject;
    import mx.automation.IAutomationObjectHelper;
    import mx.core.mx_internal;
    
    import spark.automation.delegates.components.supportClasses.SparkGroupBaseAutomationImpl;
    import spark.components.Group;
    
    use namespace mx_internal;
    
    [Mixin]
    /**
     * 
     *  Defines methods and properties required to perform instrumentation for the 
     *  Group control.
     * 
     *  @see spark.components.Group
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     *
     */
    public class SparkGroupAutomationImpl extends SparkGroupBaseAutomationImpl 
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
            Automation.registerDelegateClass(spark.components.Group, SparkGroupAutomationImpl);
        }   
        
        /**
         *  Constructor.
         * @param obj Group object to be automated.     
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function SparkGroupAutomationImpl(obj:spark.components.Group)
        {
            super(obj);
            recordClick = true;
        }
        
        /**
         *  @private
         *  storage for the owner component
         */
        protected function get group():spark.components.Group
        {
            return uiComponent as spark.components.Group;
        }
        
        //----------------------------------
        //  automationName
        //----------------------------------
        
        /**
         *  @private
         */
        override public function get automationName():String
        {
            return group.id || super.automationName;
        }
        
        //----------------------------------
        //  automationValue
        //----------------------------------
        
        /**
         *  @private
         */
        override public function get automationValue():Array
        {
            if (group.id && group.id.length != 0)
                return [ group.id ];
            
            var result:Array = [];
            var childList:Array = getAutomationChildren();
            var n:int = childList ? childList.length:0;
            for (var i:int = 0; i < n; i++)
            {
                var child:IAutomationObject = childList[i]; 
                if(child != null) // we can have non automation elements like graphic elements also.
                {
                    var x:Array = child.automationValue;
                    if (x && x.length != 0)
                        result.push(x.join(" | "));
                }
            }
            
            return  result;
            
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
            else if (event is KeyboardEvent)
            {
                // the key board events happens on the scroller.
                var scroller:spark.components.Scroller = getInternalScroller();
                if(scroller)
                {
                    var helper:IAutomationObjectHelper = Automation.automationObjectHelper;
                    if(helper)
                        helper.replayKeyboardEvent(scroller,event as KeyboardEvent);
                    
                }
                return true;
            }
            else
                return super.replayAutomatableEvent(event);
        }
        
        
        /**
         *  @private
         */
        override public function get numAutomationChildren():int
        {
            return group.numChildren;
        }
        
        /**
         *  @private
         */
        override public function getAutomationChildAt(index:int):IAutomationObject
        {
            return group.getChildAt(index) as IAutomationObject;
        }  
        
    }
    
}