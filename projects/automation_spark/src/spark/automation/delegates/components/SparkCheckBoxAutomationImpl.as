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