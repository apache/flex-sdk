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
    
    import spark.automation.delegates.components.supportClasses.SparkButtonBarBaseAutomationImpl;
    import spark.components.TabBar;
    
    use namespace mx_internal;
    
    [Mixin]
    
    /**
     * 
     *  Defines the methods and properties required to perform instrumentation for the 
     *  TabBar class. 
     * 
     *  @see spark.components.TabBar
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     *  
     */
    
    public class SparkTabBarAutomationImpl extends SparkButtonBarBaseAutomationImpl
    {
        
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
            Automation.registerDelegateClass(spark.components.TabBar, SparkTabBarAutomationImpl);
        }  
        
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Constructor.
         * @param obj TabBar object to be automated.   
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function SparkTabBarAutomationImpl(obj:spark.components.TabBar)
        {
            super(obj);
        }
        
        /**
         *  @private
         *  storage for the owner component
         */
        protected function get sparkTabBar():spark.components.TabBar
        {
            return uiComponent as spark.components.TabBar;
        }   
    }
}