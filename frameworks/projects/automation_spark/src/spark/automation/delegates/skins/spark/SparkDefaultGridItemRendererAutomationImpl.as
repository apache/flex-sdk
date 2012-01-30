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
package spark.automation.delegates.skins.spark
{
    import flash.display.DisplayObject;
    
    import mx.automation.Automation;
    import mx.automation.delegates.core.UIComponentAutomationImpl;
    import mx.automation.delegates.core.UIFTETextFieldAutomationImpl;
    import mx.core.UIComponent;
    import mx.core.mx_internal;
    
    import spark.skins.spark.DefaultGridItemRenderer;
    
    use namespace mx_internal;
    
    [Mixin]
    /**
     * 
     *  Defines methods and properties required to perform instrumentation for the 
     *  ItemRenderer class for spark.
     * 
     *  @see spark.skins.spark.DefaultItemRenderer
     *
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.1
     *  @productversion Flex 4
     */
    public class SparkDefaultGridItemRendererAutomationImpl extends UIFTETextFieldAutomationImpl
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
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public static function init(root:DisplayObject):void
        {
            Automation.registerDelegateClass(spark.skins.spark.DefaultGridItemRenderer, SparkDefaultGridItemRendererAutomationImpl);
        }   
        
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Constructor.
         * @param obj DefaultGridItemRenderer object to be automated.     
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.1
         *  @productversion Flex 4
         */
        public function SparkDefaultGridItemRendererAutomationImpl(obj:DefaultGridItemRenderer)
        {
            super(obj);
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
        protected function get gridItem():spark.skins.spark.DefaultGridItemRenderer
        {
            return uiFTETextField as spark.skins.spark.DefaultGridItemRenderer;
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
            return gridItem.label|| super.automationName;
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
        
    }
}