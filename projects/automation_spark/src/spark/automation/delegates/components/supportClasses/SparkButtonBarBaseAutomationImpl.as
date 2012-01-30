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
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.ui.Keyboard;
    
    import mx.automation.Automation;
    import mx.automation.events.AutomationRecordEvent;
    import mx.core.EventPriority;
    import mx.core.mx_internal;
    
    import spark.components.supportClasses.ButtonBarBase;
    import spark.events.IndexChangeEvent;
    
    use namespace mx_internal;
    
    [Mixin]
    
    /**
     * 
     *  Defines methods and properties required to perform instrumentation for the 
     *  ButtonBarBase control.
     * 
     *  @see spark.components.supportClasses.ButtonBarBase
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     *
     */
    public class SparkButtonBarBaseAutomationImpl extends SparkListBaseAutomationImpl
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
            Automation.registerDelegateClass(spark.components.supportClasses.ButtonBarBase, SparkButtonBarBaseAutomationImpl);
        }  
        
        /**
         *  Constructor.
         * @param obj ButtonBarBase object to be automated.     
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function SparkButtonBarBaseAutomationImpl(obj:spark.components.supportClasses.ButtonBarBase)
        {
            super(obj);
            recordClick = false;
            
            obj.addEventListener(AutomationRecordEvent.RECORD, automationRecordHandler, false, EventPriority.DEFAULT+1, true);
            
            obj.addEventListener(spark.events.IndexChangeEvent.CHANGE, itemClickHandler, false, 0, true);
        }
        
        /**
         *  @private
         */
        private function automationRecordHandler(event:AutomationRecordEvent):void
        {
            if (event.replayableEvent.type == MouseEvent.CLICK)
                event.stopImmediatePropagation();
        }
        
        /**
         *  @private
         */
        protected function itemClickHandler(event:spark.events.IndexChangeEvent):void
        {
            
        }
        
        //--------------------------------------------------------------------------
        //
        //  Event handlers
        //
        //--------------------------------------------------------------------------
        
        /**
         *  @private
         */
        override protected function keyDownHandler(event:KeyboardEvent):void 
        {
            switch (event.keyCode)
            {
                case Keyboard.DOWN:
                case Keyboard.RIGHT:
                case Keyboard.UP:
                case Keyboard.LEFT:
                    recordAutomatableEvent(event);
                    break;  
            }
        }   
    }
}