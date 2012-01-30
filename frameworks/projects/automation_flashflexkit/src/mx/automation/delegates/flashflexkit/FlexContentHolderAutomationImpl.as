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


