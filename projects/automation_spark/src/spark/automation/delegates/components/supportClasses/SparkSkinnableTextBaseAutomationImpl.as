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
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    
    import mx.automation.Automation;
    import mx.automation.IAutomationObject;
    import mx.automation.IAutomationObjectHelper;
    import mx.automation.events.AutomationDragEvent;
    import mx.automation.events.AutomationRecordEvent;
    import mx.core.EventPriority;
    import mx.core.UIComponent;
    import mx.core.mx_internal;
    
    import spark.automation.delegates.SparkRichEditableTextAutomationHelper;
    import spark.automation.tabularData.RichEditableTextTabularData;
    import spark.components.RichEditableText;
    import spark.components.Scroller;
    import spark.components.supportClasses.SkinnableTextBase;
    
    use namespace mx_internal;
    
    [Mixin]
    /**
     * 
     *  Defines methods and properties required to perform instrumentation for the 
     *  SkinnableTextBase control.
     * 
     *  @see spark.components.supportClasses.SkinnableTextBase
     *
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public class SparkSkinnableTextBaseAutomationImpl extends SparkSkinnableComponentAutomationImpl 
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
            Automation.registerDelegateClass(spark.components.supportClasses.SkinnableTextBase, SparkSkinnableTextBaseAutomationImpl);
        }   
        
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Constructor.
         * @param obj SkinnableTextBase object to be automated.     
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function SparkSkinnableTextBaseAutomationImpl(obj:spark.components.supportClasses.SkinnableTextBase)
        {
            super(obj);
            obj.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler,
                false, EventPriority.DEFAULT+1, true );
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
        protected function get  skinnableTextBase():spark.components.supportClasses.SkinnableTextBase
        {
            return uiComponent as spark.components.supportClasses.SkinnableTextBase;
        }
        
        /**
         *  @private
         *  Generic record/replay logic for textfields.
         */
        private var automationHelper:SparkRichEditableTextAutomationHelper;
        
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
            return [ skinnableTextBase.text ];
        }
        
        
        //--------------------------------------------------------------------------
        //
        //  Overridden methods
        //
        //--------------------------------------------------------------------------
        
        /**
         *  @private
         */
        override public function replayAutomatableEvent(interaction:Event):Boolean
        {
            // For drag events, this needs to be handled by this object itself
            // instead of delegating it to its textDisplay
            // This is needed for AIR as we need to dispatch native drag events on 
            // current object to handle drag drop events in AIR
            // This is working in Flex even without this special handling because
            // drag events are automatically triggered by mouse events in Flex.
            // But this is not the case in AIR. Mouse events do not trigger those
            // native drag events and so we need to construct those events manually 
            // and dispatch them on the corresponding objects to replay them.
            if(interaction is AutomationDragEvent)
                return super.replayAutomatableEvent(interaction);
            
            // we have delegated the replay to the underlying the richEditabale Text.           
            if(skinnableTextBase.textDisplay is RichEditableText)
                return RichEditableText(skinnableTextBase.textDisplay).replayAutomatableEvent(interaction);
            else
                return super.replayAutomatableEvent(interaction);
        }
        
        //--------------------------------------------------------------------------
        //
        //  Event handlers
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Method which gets called after the component has been initialized. 
         *  This can be used to access any sub-components and act on the component.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        override protected function componentInitialized():void
        {
            super.componentInitialized();
            skinnableTextBase.addEventListener(AutomationRecordEvent.RECORD,
                inputField_recordHandler1, false, 0, true); 
        }
        
        
        private function inputField_recordHandler1(event1:AutomationRecordEvent):void
        {
            if(event1.automationObject == skinnableTextBase.textDisplay)
            {
                // let us record the evnet from the richEditableText as our event
                recordAutomatableEvent(event1.replayableEvent);
            }
        }
        
        /**
         *  @private
         *  Prevent duplicate ENTER key recordings. 
         */
        override protected function keyDownHandler(event:KeyboardEvent):void
        {
            ;
        }
        
        /**
         *  @private
         */
        
        override public function get automationTabularData():Object
        {
            return new RichEditableTextTabularData(skinnableTextBase.textDisplay as RichEditableText);
        }
        
        
        /**
         *  @private
         */
        
        override public function get numAutomationChildren():int
        { 
            var scrollBars:Array = getScrollBars(skinnableTextBase,skinnableTextBase.skin);
            return scrollBars?scrollBars.length:0;
        }
        
        override public function getAutomationChildAt(index:int):IAutomationObject
        {
            var scrollBars:Array = getScrollBars(skinnableTextBase,skinnableTextBase.skin);
            if(scrollBars && index < scrollBars.length)
                return scrollBars[index];
            return null;
        }
        
        /**
         *  @private
         */
        override public function getAutomationChildren():Array
        { 
            return getScrollBars(skinnableTextBase,skinnableTextBase.skin);
        }
        
        protected function getScrollBars(passedObj:Object, stopWithSkin:UIComponent):Array
        {
            var scroller:spark.components.Scroller = null;
            if(passedObj)
                scroller = getScroller(passedObj,null);
            else
                scroller = getScroller(skinnableTextBase,stopWithSkin);
            
            if(scroller)
            {
                var tempArray:Array = new Array();
                if(scroller.horizontalScrollBar)
                    tempArray.push(scroller.horizontalScrollBar);
                if(scroller.verticalScrollBar)
                    tempArray.push(scroller.verticalScrollBar);
                
            }
            return tempArray;
            
        }
        protected function getScroller(passedObj:Object, stopWithSkin:UIComponent):spark.components.Scroller
        {
            if(passedObj)
            {
                if( !(passedObj.hasOwnProperty("numChildren") && 
                    passedObj.hasOwnProperty("getChildAt")))
                    return null;
            }
            
            var requiredObject:Object = null;
            if(passedObj)
                requiredObject = passedObj;
            else
                // just to ensure that if no object is passed, we will consider it on the
                // current object.
                requiredObject = skinnableTextBase;
            
            var n:int = requiredObject.numChildren;
            
            var obj:Object;
            for (var i:int = 0; i<n ; i++)
            {
                obj  =  requiredObject.getChildAt(i);
                
                if(obj is spark.components.Scroller)
                    return obj as spark.components.Scroller;
                
                // check whether we need to proceed with the element to dig further
                // if it is a skin we need to proceed.
                // if the object corresponds to our contentGroup, we need not proceed further
                if(obj == stopWithSkin)
                    continue;
                do
                {
                    obj = getScroller(obj,stopWithSkin);
                }while(obj && !(obj is spark.components.Scroller))
                
                if(obj is spark.components.Scroller)
                    return obj as spark.components.Scroller;
            }
            return null;
        }
        
        
        /**
         *  @private
         */
        
        private function mouseWheelHandler(event:MouseEvent):void
        {
            if( isEventTargetApplicabale(event)  )
                recordAutomatableEvent(event, true);
        }
        
        private function isEventTargetApplicabale(event:Event):Boolean
        {       
            return (event.target == skinnableTextBase.textDisplay);
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
        override public function resolveAutomationIDPart(part:Object):Array
        {
            var help:IAutomationObjectHelper = Automation.automationObjectHelper;
            return help.helpResolveIDPart(uiAutomationObject, part);
        }
        
        /**
         *  @private
         */
        override public function createAutomationIDPartWithRequiredProperties(child:IAutomationObject, properties:Array):Object
        {
            var help:IAutomationObjectHelper = Automation.automationObjectHelper;
            return help.helpCreateIDPartWithRequiredProperties(uiAutomationObject, child,properties);
            
        }
        
    }
}