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


package mx.automation.delegates.flashflexkit
{ 
    import flash.display.DisplayObject;
    
    import mx.automation.Automation;
    import mx.automation.IAutomationObjectHelper;
    import mx.automation.IAutomationObject;
    import mx.core.mx_internal;
    import mx.flash.FlexContentHolder;
    use namespace mx_internal;
    
    [Mixin]
    /**
     *  
     *  Defines methods and properties required to perform instrumentation for the 
     *  FlexContentHolder control.
     *  The FlexContentHolder class is not for public use.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */ 
    public class  FlexContentHolderAutomationImpl  extends UIMovieClipAutomationImpl 
    {  
        include "../../../core/Version.as";
        
        //--------------------------------------------------------------------------
        //
        //  Class methods
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Registers the delegate class for a component class with automation manager.
         *  @param root DisplayObject object representing the application root. 
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion Flex 3
         */
        public static function init(root:DisplayObject):void
        {
            Automation.registerDelegateClass(FlexContentHolder, FlexContentHolderAutomationImpl);
        }   
        
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Constructor.
         * @param obj Panel object to be automated.     
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion Flex 3
         */
        public function FlexContentHolderAutomationImpl(obj:FlexContentHolder)
        {
            super(obj);
            recordClick = true;
        }
        
        
        /**
         *  @private
         *  storage for the owner component
         */
        protected function get flexContentHolder():FlexContentHolder
        {
            return movieClip as FlexContentHolder;
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
            return super.automationName;
        }
        
        /**
         *  @private
         */
        override public function get automationValue():Array
        {
            return [ automationName ];
        }
        
        //----------------------------------
        //  numAutomationChildren
        //----------------------------------
        
        /**
         *  @private
         */
        override public function get numAutomationChildren():int
        {
            //always the Flash container can have only one child
            // which inturn can be a Flex container to hold multiple objects
            
            return (1);
        }
        
        //--------------------------------------------------------------------------
        //
        //  Overridden methods
        //
        //--------------------------------------------------------------------------
        
        /**
         *  @private
         */
        override public function getAutomationChildAt(index:int):IAutomationObject
        {
            // only one flex component is allowed as the child
            
            if (index == 0)
                return flexContentHolder.content as IAutomationObject;
            
            return null;
        }
        
        override public function getAutomationChildren():Array
        {
            // only one flex component is allowed as the child
            return [flexContentHolder.content as IAutomationObject];
        }
        
        /**
         *  @private
         */
        override public function createAutomationIDPart(child:IAutomationObject):Object
        {
            var help:IAutomationObjectHelper = Automation.automationObjectHelper;
            return help.helpCreateIDPart(uiAutomationObject, child);
        }
        
        /**
         *  @private
         */
        override public function createAutomationIDPartWithRequiredProperties(child:IAutomationObject, properties:Array):Object
        {
            var help:IAutomationObjectHelper = Automation.automationObjectHelper;
            return help.helpCreateIDPartWithRequiredProperties(uiAutomationObject, child,properties);
        }
        
        /**
         *  @private
         */
        override public function resolveAutomationIDPart(part:Object):Array
        {
            var help:IAutomationObjectHelper = Automation.automationObjectHelper;
            return help.helpResolveIDPart(uiAutomationObject, part);
        }
        
    }
}


