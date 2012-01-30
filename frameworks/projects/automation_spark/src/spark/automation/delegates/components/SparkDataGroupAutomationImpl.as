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
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    
    import mx.automation.Automation;
    import mx.automation.IAutomationClass;
    import mx.automation.IAutomationObject;
    import mx.automation.IAutomationObjectHelper;
    import mx.core.EventPriority;
    import mx.core.IVisualElement;
    import mx.core.mx_internal;
    
    import spark.automation.delegates.components.supportClasses.SparkGroupBaseAutomationImpl;
    import spark.automation.events.SparkListItemSelectEvent;
    import spark.components.DataGroup;
    import spark.components.IItemRenderer;
    import spark.components.Scroller;
    import spark.events.RendererExistenceEvent;
    
    use namespace mx_internal;
    
    [Mixin]
    /**
     * 
     *  Defines methods and properties required to perform instrumentation for the 
     *  DataGroup control.
     * 
     *  @see spark.components.DataGroup
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public class SparkDataGroupAutomationImpl extends SparkGroupBaseAutomationImpl
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
            Automation.registerDelegateClass(spark.components.DataGroup, SparkDataGroupAutomationImpl);
        }   
        
        /**
         *  Constructor.
         *  
         *  @param obj DataGroup object to be automated.     
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function SparkDataGroupAutomationImpl(obj:spark.components.DataGroup)
        {
            super(obj);
        }
        
        /**
         *  The DataGroup object.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function get sparkDataGroup():spark.components.DataGroup
        {
            return uiComponent as spark.components.DataGroup;
        }
        
        //--------------------------------------------------------------------------
        //
        //  Overridden methods
        //
        //--------------------------------------------------------------------------
        
        /**
         *  @private
         *  Replays click interactions on the button.
         *  If the interaction was from the mouse,
         *  dispatches MOUSE_DOWN, MOUSE_UP, and CLICK.
         *  If interaction was from the keyboard,
         *  dispatches KEY_DOWN, KEY_UP.
         *  Button's KEY_UP handler then dispatches CLICK.
         *
         *  @param event ReplayableClickEvent to replay.
         */
        override public function replayAutomatableEvent(event:Event):Boolean
        {
            var help:IAutomationObjectHelper = Automation.automationObjectHelper;
            
            if (event is MouseEvent && event.type == MouseEvent.CLICK)
                return help.replayClick(uiComponent, MouseEvent(event));
            else if (event is KeyboardEvent)
            {
                // the key board events happens on the scroller.
                var scroller:spark.components.Scroller = getInternalScroller();
                if(scroller)
                {
                    var helper:IAutomationObjectHelper = Automation.automationObjectHelper;
                    if(helper)
                        helper.replayKeyboardEvent(scroller,event as KeyboardEvent);
                    
                }
                return true;
            }
            else
                return super.replayAutomatableEvent(event);
        }
        
        
        /**
         *  @private
         */
        override public function get numAutomationChildren():int
        {
            return sparkDataGroup.numChildren;
        }
        
        /**
         *  @private
         */
        override public function getAutomationChildAt(index:int):IAutomationObject
        {
            return sparkDataGroup.getChildAt(index) as IAutomationObject;
        }  
        
        /**
         * @private
         */
        override protected function componentInitialized():void
        {
            addMouseClickHandlerToExistingRenderers();
            
            if(sparkDataGroup)
            {
                sparkDataGroup.addEventListener(
                    RendererExistenceEvent.RENDERER_ADD, dataGroup_rendererAddHandler, false, 0, true);
                sparkDataGroup.addEventListener(
                    RendererExistenceEvent.RENDERER_REMOVE, dataGroup_rendererRemoveHandler, false, 0 , true);
            }
            super.componentInitialized();
        }
        
        /**
         * @private
         */
        protected function dataGroup_rendererAddHandler(event:RendererExistenceEvent):void
        {
            var renderer:IVisualElement = event.renderer;
            
            if (renderer)
                renderer.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler,false,-100,true);
            
            if(renderer is IAutomationObject)
                IAutomationObject(renderer).showInAutomationHierarchy = true;
        }
        
        
        /**
         *  @private
         */
        protected function dataGroup_rendererRemoveHandler(event:RendererExistenceEvent):void
        {
            var renderer:Object = event.renderer;
            
            if (renderer)
                renderer.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        }
        
        /**
         *  @private
         */
        
        protected function mouseDownHandler(event:MouseEvent):void
        {
            if(event.currentTarget as IItemRenderer)
                recordDataGroupItemClickEvent(event.currentTarget as IItemRenderer , event);
            
        }
        
        /**
         * @private
         */
        
        protected function recordDataGroupItemClickEvent(item:IItemRenderer,
                                                     trigger:Event, 
                                                     cacheable:Boolean=true):void
        {
            var selectionType:String = SparkListItemSelectEvent.SELECT;
            var keyEvent:KeyboardEvent = trigger as KeyboardEvent;
            var mouseEvent:MouseEvent = trigger as MouseEvent;
            
            var indexSelection:Boolean = false;
            
            if (!Automation.automationManager || !Automation.automationManager.automationEnvironment
			|| !Automation.automationManager.recording)
                return ;
            
            var automationClass:IAutomationClass = Automation.automationManager.automationEnvironment.getAutomationClassByInstance(sparkDataGroup);
            
            var event:SparkListItemSelectEvent = new SparkListItemSelectEvent(selectionType);
            if (indexSelection)
                fillItemRendererIndex(item, event);
            else
                event.itemRenderer = item;
            
            event.triggerEvent = trigger;
            if (keyEvent)
            {
                event.ctrlKey = keyEvent.ctrlKey;
                event.shiftKey = keyEvent.shiftKey;
                event.altKey = keyEvent.altKey;
            }
            else if (mouseEvent)
            {
                event.ctrlKey = mouseEvent.ctrlKey;
                event.shiftKey = mouseEvent.shiftKey;
                event.altKey = mouseEvent.altKey;
            }
            
            recordAutomatableEvent(event, cacheable);
        }
        
        /**
         *  @private
         */
        
        protected function fillItemRendererIndex(item:IItemRenderer, event:SparkListItemSelectEvent):void
        {
            event.itemIndex = sparkDataGroup.getElementIndex(item as IVisualElement);
            
        }  
        
        /**
         * @private
         */
        protected function addMouseClickHandlerToExistingRenderers():void
        {
            
            var count:int = sparkDataGroup? sparkDataGroup.numElements:0;
            for (var i:int = 0; i<count ; i++)
            {
                var currentObj:Object = sparkDataGroup.getElementAt(i);
                if( currentObj is IItemRenderer)
                    (currentObj as IItemRenderer).addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler,false, -100,true);
                if(currentObj is IAutomationObject)
                    IAutomationObject(currentObj).showInAutomationHierarchy = true;
            }
            
        }
    }
}