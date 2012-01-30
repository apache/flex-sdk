////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package spark.automation.delegates.skins.spark
{
    import flash.display.DisplayObject;
    
    import mx.automation.Automation;
    import mx.automation.IAutomationObject;
    import mx.core.UIComponent;
    import mx.core.mx_internal;
    
    import spark.automation.delegates.components.SparkGroupAutomationImpl;
    import spark.automation.delegates.components.gridClasses.SparkGridItemRendererAutomationImpl;
    import spark.skins.spark.DefaultGridHeaderRenderer;
    
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
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public class SparkDefaultGridHeaderRendererAutomationImpl extends SparkGridItemRendererAutomationImpl
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
            Automation.registerDelegateClass(spark.skins.spark.DefaultGridHeaderRenderer, SparkDefaultGridHeaderRendererAutomationImpl);
        }   
        
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Constructor.
         * @param obj DefaultGridHeaderRenderer object to be automated.     
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10.2
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public function SparkDefaultGridHeaderRendererAutomationImpl(obj:DefaultGridHeaderRenderer)
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
        protected function get gridItem():spark.skins.spark.DefaultGridHeaderRenderer
        {
            return uiComponent as spark.skins.spark.DefaultGridHeaderRenderer;
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
        
        override public function getAutomationChildAt(index:int):IAutomationObject
        {
            return null;
        }
        
        override public function get numAutomationChildren():int
        {
            return 0;
        }
        
        override public function getAutomationChildren():Array
        {
            return [];
        }
    }
}