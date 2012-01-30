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

package spark.automation.delegates.components.supportClasses
{
    import flash.display.DisplayObject;
    import flash.events.MouseEvent;
    
    import mx.automation.Automation;
    import mx.automation.delegates.core.UIComponentAutomationImpl;
    import mx.core.EventPriority;
    import mx.core.mx_internal;
    
    import spark.components.supportClasses.TextBase;
    
    use namespace mx_internal;
    
    [Mixin]
    /**
     * 
     *  Defines methods and properties required to perform instrumentation for the 
     *  TextBase control.
     * 
     *  @see spark.components.supportClasses.TextBase 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     *
     */
    public class SparkTextBaseAutomationImpl extends UIComponentAutomationImpl 
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
         *  @playerversion Flash 9
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public static function init(root:DisplayObject):void
        {
            Automation.registerDelegateClass(spark.components.supportClasses.TextBase, SparkTextBaseAutomationImpl);
        }   
        
        /**
         *  Constructor.
         * @param obj TextBase object to be automated.     
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function SparkTextBaseAutomationImpl(obj:spark.components.supportClasses.TextBase)
        {
            super(obj);
            obj.addEventListener(MouseEvent.CLICK, clickHandler, false, EventPriority.DEFAULT+1, true);
        }
        
        /**
         *  @private
         *  storage for the owner component
         */
        protected function get textBase():spark.components.supportClasses.TextBase
        {
            return uiComponent as spark.components.supportClasses.TextBase;
        }
        
        
        
        //----------------------------------
        //  automationName
        //----------------------------------
        
        /**
         *  @private
         */
        override public function get automationName():String
        {
            return textBase.text || super.automationName;
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
        
        /**
         *  @private
         */
        protected function clickHandler(event:MouseEvent):void 
        {
            recordAutomatableEvent(event);
        }
        
        
        
    }
    
}