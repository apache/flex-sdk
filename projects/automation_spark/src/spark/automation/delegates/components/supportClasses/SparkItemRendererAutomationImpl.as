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
    
    import mx.automation.Automation;
    import mx.automation.IAutomationObject;
    import mx.core.mx_internal;
    
    import spark.automation.delegates.components.SparkGroupAutomationImpl;
    import spark.components.supportClasses.ItemRenderer;
    
    use namespace mx_internal;
    
    [Mixin]
    /**
     * 
     *  Defines methods and properties required to perform instrumentation for the 
     *  ItemRenderer class for spark.
     * 
     *  @see spark.components.supportClasses.ItemRenderer
     *
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public class SparkItemRendererAutomationImpl extends SparkGroupAutomationImpl 
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
            Automation.registerDelegateClass(spark.components.supportClasses.ItemRenderer, SparkItemRendererAutomationImpl);
        }   
        
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Constructor.
         * @param obj ItemRenderer object to be automated.     
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function SparkItemRendererAutomationImpl(obj:ItemRenderer)
        {
            super(obj);
            recordClick = false;
        }
        
        //--------------------------------------------------------------------------
        //
        //  Variables
        //
        //--------------------------------------------------------------------------
        
        /**
         *  @private
         *  storage for the owner component
         */
        protected function get listItem():ItemRenderer
        {
            return uiComponent as ItemRenderer;
        }
        
        
        //--------------------------------------------------------------------------
        //
        //  Overridden properties
        //
        //--------------------------------------------------------------------------
        
        //----------------------------------
        //  automationName
        //----------------------------------
        
        /**
         *  @private
         */
        override public function get automationName():String
        {
            return listItem.label|| super.automationName;
        }
        
        //----------------------------------
        //  automationValue
        //----------------------------------
        
        /**
         *  @private
         */
        override public function get automationValue():Array
        {
            return [automationName];
        }
        
        // the defulat Item Rener is extending from Group which contains the label. But we wnat to treat this
        // a composite object. So override the following methods to make it a single object.
        /**
         *  @private
         */
        override public function getAutomationChildren():Array
        {
            return null;
        }
        
        // the defulat Item Rener is extending from Group which contains the label. But we wnat to treat this
        // a composite object. So override the following methods to make it a single object.
        /**
         *  @private
         */
        override public function  get numAutomationChildren():int
        {
            return 0;
        }
        
        
        // the defulat Item Rener is extending from Group which contains the label. But we wnat to treat this
        // a composite object. So override the following methods to make it a single object.
        /**
         *  @private
         */
        override public function getAutomationChildAt(index:int):IAutomationObject
        {
            return null;
        }
        
        
    }
}