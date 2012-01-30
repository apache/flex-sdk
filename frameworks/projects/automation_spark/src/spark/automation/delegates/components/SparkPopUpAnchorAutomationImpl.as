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
    import mx.automation.IAutomationObject;
    import mx.automation.IAutomationObjectHelper;
    import mx.automation.delegates.core.UIComponentAutomationImpl;
    import mx.core.UIComponent;
    import mx.core.mx_internal;
    
    import spark.components.PopUpAnchor;
    
    use namespace mx_internal;
    
    [Mixin]
    /**
     *  Defines methods and properties required to perform instrumentation for the 
     *  PopUpAnchor component.
     * 
     *  @see spark.components.PopUpAnchor
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public class SparkPopUpAnchorAutomationImpl extends UIComponentAutomationImpl
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
         *  @param root DisplayObject object representing the application root. 
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public static function init(root:DisplayObject):void
        {
            Automation.registerDelegateClass(PopUpAnchor, SparkPopUpAnchorAutomationImpl);
        }   
        
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Constructor.
         *
         *  @param obj PopUpAnchor object to be automated.     
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public function SparkPopUpAnchorAutomationImpl(obj:PopUpAnchor)
        {
            super(obj);
        }
        
        public function get popUpAnchor():PopUpAnchor
        {
            return uiComponent as PopUpAnchor;
        }
        
        /**
         *  @private
         */
        override public function createAutomationIDPart(child:IAutomationObject):Object
        {
            var help:IAutomationObjectHelper = Automation.automationObjectHelper;
            return help.helpCreateIDPart(popUpAnchor, child);
        }
        
        /**
         *  @private
         */
        override public function createAutomationIDPartWithRequiredProperties(child:IAutomationObject, properties:Array):Object
        {
            var help:IAutomationObjectHelper = Automation.automationObjectHelper;
            return help.helpCreateIDPartWithRequiredProperties(popUpAnchor, child,properties);
        }
        
        /**
         *  @private
         */
        override public function resolveAutomationIDPart(criteria:Object):Array
        {
            var help:IAutomationObjectHelper = Automation.automationObjectHelper;
            return help.helpResolveIDPart(popUpAnchor, criteria);
        }
        
        /**
         *  @private
         */
        override public function getAutomationChildren():Array
        {
            var childList:Array = new Array();
            childList.push(popUpAnchor.popUp as IAutomationObject);
            return childList;
        }
        
        /**
         *  @private
         */
        override public function get numAutomationChildren():int
        {
            return 1;
        }
        
        /**
         *  @private
         */
        override public function getAutomationChildAt(index:int):IAutomationObject
        {
            if(index == 0)
                return popUpAnchor.popUp as IAutomationObject;
            return null;
        }
    }
}