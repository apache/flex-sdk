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
    import mx.core.mx_internal;
    
    import spark.automation.delegates.components.supportClasses.SparkTextBaseAutomationImpl;
    import spark.components.Label;
    
    use namespace mx_internal;
    
    [Mixin]
    /**
     * 
     *  Defines methods and properties required to perform instrumentation for the 
     *  Label control.
     * 
     *  @see spark.components.Label 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     *
     */
    public class SparkLabelAutomationImpl extends SparkTextBaseAutomationImpl
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
            Automation.registerDelegateClass(spark.components.Label, SparkLabelAutomationImpl);
        }   
        
        /**
         *  Constructor.
         * @param obj Label object to be automated.     
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function SparkLabelAutomationImpl(obj:spark.components.Label)
        {
            super(obj);
            
        }
        
        /**
         *  @private
         *  storage for the owner component
         */
        protected function get label():spark.components.Label
        {
            return uiComponent as spark.components.Label;
        }
        
        /**
         *  @private
         */
        override public function get automationName():String
        {
            return label.id||label.text || super.automationName;
        }
        
        //----------------------------------
        //  automationValue
        //----------------------------------
        
        /**
         *  @private
         */
        override public function get automationValue():Array
        {
            return [ automationName ];
        }
        
        
    }
    
}