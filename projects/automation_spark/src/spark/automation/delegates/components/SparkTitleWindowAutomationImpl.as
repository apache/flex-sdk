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
    import mx.automation.IAutomationObject;
    import mx.core.mx_internal;
    
    import spark.components.TitleWindow;
    
    use namespace mx_internal;
    
    [Mixin]
    /**
     * 
     *  Defines the methods and properties required to perform instrumentation for the 
     *  TitleWindow class. 
     * 
     *  @see spark.components.TitleWindow
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     *  
     */ 
    public class SparkTitleWindowAutomationImpl extends SparkPanelAutomationImpl
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
            Automation.registerDelegateClass(spark.components.TitleWindow, SparkTitleWindowAutomationImpl);
        }   
        
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Constructor.
         * @param obj TitleWindow object to be automated.     
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function SparkTitleWindowAutomationImpl(obj:spark.components.TitleWindow)
        {
            super(obj);
            recordClick = true;
        }
        
        /**
         *  @private
         *  storage for the owner component
         */
        protected function get sparkTitleWindow():spark.components.TitleWindow
        {
            return uiComponent as spark.components.TitleWindow;
        }
        
        //--------------------------------------------------------------------------
        //
        //  Overridden properties
        //
        //--------------------------------------------------------------------------
        
        /**
         *  @private
         */        
        override public function getAutomationChildAt(index:int):IAutomationObject
        {
            if(sparkTitleWindow.closeButton != null)
                if(index == 0)
                    return sparkTitleWindow.closeButton as  IAutomationObject;
                else index -= 1;
            
            return super.getAutomationChildAt(index);
        }
        
        
        /**
         *  @private
         */
        override public function getAutomationChildren():Array
        {           
            var childArray:Array = new Array();
            
            if(sparkTitleWindow.closeButton != null)
                childArray.push(sparkTitleWindow.closeButton as IAutomationObject);
            
            var tempChildren:Array  = super.getAutomationChildren();
            if(tempChildren)
            {
                var n:int = tempChildren.length;
                for ( var i:int = 0; i < n ; i++)
                {
                    childArray.push(tempChildren[i] as IAutomationObject);
                }
            }           
            return childArray;
        }
    }
}