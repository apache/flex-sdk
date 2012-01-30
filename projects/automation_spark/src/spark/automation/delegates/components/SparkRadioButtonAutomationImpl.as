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
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;
    
    import mx.automation.Automation;
    import mx.core.mx_internal;
    
    import spark.automation.delegates.components.supportClasses.SparkButtonBaseAutomationImpl;
    import spark.components.RadioButton;
    
    use namespace mx_internal;
    
    [Mixin]
    /**
     * 
     *  Defines methods and properties required to perform instrumentation for the 
     *  RadioButton control.
     * 
     *  @see spark.components.RadioButton
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     *
     */
    public class SparkRadioButtonAutomationImpl extends SparkButtonBaseAutomationImpl 
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
            Automation.registerDelegateClass(spark.components.RadioButton, SparkRadioButtonAutomationImpl);
        }   
        
        /**
         *  Constructor.
         * @param obj RadioButton object to be automated.     
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function SparkRadioButtonAutomationImpl(obj:spark.components.RadioButton)
        {
            super(obj);
            
        }
        
        /**
         *  @private
         *  Support the use of keyboard within the group.
         */
        override protected function keyDownHandler(event:KeyboardEvent):void
        {
            switch (event.keyCode)
            {
                case Keyboard.DOWN:
                case Keyboard.UP:
                case Keyboard.LEFT:
                case Keyboard.RIGHT:
                    //for form defaults:
                case Keyboard.ENTER:
                    recordAutomatableEvent(event);
                    break;
            }
        }
        
        
    }
    
}