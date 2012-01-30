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
    
    import mx.automation.Automation;
    
    import spark.automation.delegates.components.supportClasses.SparkToggleButtonBaseAutomationImpl;
    import spark.components.CheckBox;
    
    [Mixin]
    /**
     * 
     *  Defines methods and properties required to perform instrumentation for the 
     *  CheckBox control.
     * 
     *  @see spark.components.CheckBox 
     *
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public class SparkCheckBoxAutomationImpl extends SparkToggleButtonBaseAutomationImpl
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
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public static function init(root:DisplayObject):void
        {
            Automation.registerDelegateClass(spark.components.CheckBox, SparkCheckBoxAutomationImpl);
        }   
        
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Constructor.
         * @param obj CheckBox object to be automated.     
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        private var _checkBox:CheckBox;
        public function SparkCheckBoxAutomationImpl(obj:spark.components.CheckBox)
        {
            super(obj);
            _checkBox = obj;
        }
        
        /**
         *  @private
         *  storage for the owner component
         */
        protected function get chk():spark.components.CheckBox
        {
            return _checkBox as spark.components.CheckBox;
        }
        
        //--------------------------------------------------------------------------
        //
        //  Overridden properties
        //
        //--------------------------------------------------------------------------
        
        //----------------------------------
        //  automationValue
        //----------------------------------
        
        /**
         *  @private
         */
        override public function get automationValue():Array
        {
            var result:String = chk.selected ? "[X]" : "[ ]";
            if (chk.label || chk.toolTip)
                result += " " + (chk.label || chk.toolTip);
            return [ result ];
        }
        
    }
}