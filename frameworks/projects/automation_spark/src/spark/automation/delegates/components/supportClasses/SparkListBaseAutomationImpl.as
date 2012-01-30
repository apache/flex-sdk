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
    import flash.ui.Keyboard;
    import flash.utils.getTimer;
    
    import mx.automation.Automation;
    import mx.automation.AutomationIDPart;
    import mx.automation.IAutomationClass;
    import mx.automation.IAutomationObject;
    import mx.automation.IAutomationObjectHelper;
    import mx.automation.IAutomationTabularData;
    import mx.automation.delegates.DragManagerAutomationImpl;
    import mx.automation.events.AutomationDragEvent;
    import mx.core.IVisualElement;
    import mx.core.mx_internal;
    import mx.managers.DragManager;
    import mx.utils.StringUtil;
    
    import spark.automation.events.SparkListItemSelectEvent;
    import spark.automation.tabularData.SparkListBaseTabularData;
    import spark.components.IItemRenderer;
    import spark.components.supportClasses.ListBase;
    import spark.events.RendererExistenceEvent;
    import spark.layouts.HorizontalLayout;
    import spark.layouts.VerticalLayout;
    
    use namespace mx_internal;
    
    [Mixin]
    /**
     * 
     *  Defines methods and properties required to perform instrumentation for the 
     *  ListBase class.
     * 
     *  @see spark.components.supportClasses.ListBase 
     *
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public class SparkListBaseAutomationImpl extends SparkSkinnableContainerBaseAutomationImpl
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
            Automation.registerDelegateClass(spark.components.supportClasses.ListBase, SparkListBaseAutomationImpl);
        }   
        
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Constructor.
         * @param obj ListBase object to be automated.     
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function SparkListBaseAutomationImpl(obj:spark.components.supportClasses.ListBase)
        {
            super(obj);     
            
            obj.addEventListener(Event.ADDED, childAddedHandler, false, 0, true);           
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
        protected function get sparkListBase():spark.components.supportClasses.ListBase
        {
            return uiComponent as spark.components.supportClasses.ListBase;
        }
        
        /**
         *  @private
         */
        protected var preventDragDropRecording:Boolean = true;
        
        /**
         *  @private
         */
        protected var shiftKeyDown:Boolean = false;
        
        /**
         *  @private
         */
        protected var ctrlKeyDown:Boolean = false;
        
        //--------------------------------------------------------------------------
        //
        //  Methods
        //
        //--------------------------------------------------------------------------
        
        /**
         * @private
         */
        
        protected function recordListItemSelectEvent(item:IItemRenderer,
                                                     trigger:Event, 
                                                     cacheable:Boolean=true):void
        {
            var selected:Boolean = false;
            if(sparkListBase.selectedItem == item.data)
                selected = true;
            
            var selectionType:String = SparkListItemSelectEvent.SELECT;
            var keyEvent:KeyboardEvent = trigger as KeyboardEvent;
            var mouseEvent:MouseEvent = trigger as MouseEvent;
            
            var indexSelection:Boolean = false;
            
            if (!Automation.automationManager || !Automation.automationManager.automationEnvironment
			|| !Automation.automationManager.recording)
                return ;
            
            var automationClass:IAutomationClass = Automation.automationManager.automationEnvironment.getAutomationClassByInstance(sparkListBase);
            if (automationClass)
            {
                var propertyNameMap:Object = automationClass.propertyNameMap;
                if (propertyNameMap["enableIndexBasedSelection"])
                {
                    var message:String = "TBD - We should find the item renderer and convert it to index";
                    Automation.automationDebugTracer.traceMessage("SparkListBaseAutomationImpl","recordListItemSelectEvent()",message);
                    selectionType = SparkListItemSelectEvent.SELECT_INDEX;
                    indexSelection = true;
                }
            }
            
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
        
        
        //--------------------------------------------------------------------------
        //
        // Overridden methods
        //
        //--------------------------------------------------------------------------
        
        /**
         * @private
         */
        override protected function componentInitialized():void
        {
            // Sometimes List doesn't get initialized by the time constructor of 
            // this delegate is called. 
            // For ex: In TitleWindow - http://bugs.adobe.com/jira/browse/FLEXENT-1128
            // So instead of calling these code directly from the constructor, we call it
            // on component initialization.
            addMouseClickHandlerToExistingRenderers();
            
            if(sparkListBase.dataGroup)
            {
                sparkListBase.dataGroup.addEventListener(
                    RendererExistenceEvent.RENDERER_ADD, dataGroup_rendererAddHandler, false, 0, true);
                sparkListBase.dataGroup.addEventListener(
                    RendererExistenceEvent.RENDERER_REMOVE, dataGroup_rendererRemoveHandler, false, 0 , true);
            }
            super.componentInitialized();
        }
        
        
        //--------------------------------------------------------------------------
        //
        //  Properties
        //
        //--------------------------------------------------------------------------
        
        /**
         * @private
         */
        mx_internal var itemAutomationNameFunction:Function = getItemAutomationValue;
        
        /**
         * @private
         */
        public function getItemAutomationValue(item:IAutomationObject):String
        {
            // check for atleast one non-null item  
            var values:Array = item.automationValue;
            if (values)
            {
                var n:int = values.length;
                for (var i:int = 0; i < n; i++)
                {
                    if (values[i])
                        return values.join(" | ");
                    // found one non null item, so return
                }
            }
            
            return null;
        }
        
        /**
         * @private
         */
        public function getItemAutomationName(item:IAutomationObject):String
        {
            return item.automationName;
        }
        
        /**
         * @private
         */
        
        public function getItemAutomationIndex(item:IAutomationObject):String
        {
            return String("index:" + sparkListBase.dataGroup.getChildIndex(item as DisplayObject));
            
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
         * @private
         */
        override public function get automationValue():Array
        {
            var result:Array = [];
            return result;
        }
        
        /**
         *  @private
         */
        override public function createAutomationIDPart(child:IAutomationObject):Object
        {
            var help:IAutomationObjectHelper = Automation.automationObjectHelper;
            return (help
                ? help.helpCreateIDPart(uiAutomationObject, child, itemAutomationNameFunction,
                    getItemAutomationIndex)
                : null);
        }
        
        /**
         *  @private
         */
        override public function createAutomationIDPartWithRequiredProperties(child:IAutomationObject, properties:Array):Object
        {
            var help:IAutomationObjectHelper = Automation.automationObjectHelper;
            return (help
                ? help.helpCreateIDPartWithRequiredProperties(uiAutomationObject, child, properties,itemAutomationNameFunction,
                    getItemAutomationIndex)
                : null);
        }
        
        /**
         *  @private
         */
        override public function resolveAutomationIDPart(part:Object):Array
        {
            var help:IAutomationObjectHelper = Automation.automationObjectHelper;
            return help ? help.helpResolveIDPart(uiAutomationObject, part) : null;
        }
        
        
        /**
         * private
         */
        protected function getVisibleRowsRenderers():Array
        {
            var visibleRows:Array = new Array();
            
            var count:int = sparkListBase.dataGroup?sparkListBase.dataGroup.numElements:0;
            var startIndex:int = 0;
            if(sparkListBase.useVirtualLayout == false)
            {
                if(sparkListBase.layout is VerticalLayout)
                {
                    startIndex = ((sparkListBase.layout)as VerticalLayout).firstIndexInView;
                    count = ((sparkListBase.layout)as VerticalLayout).lastIndexInView+1;
                }
                else if (sparkListBase.layout is HorizontalLayout)
                {
                    startIndex = ((sparkListBase.layout)as HorizontalLayout).firstIndexInView;
                    count = ((sparkListBase.layout)as HorizontalLayout).lastIndexInView+1;
                }
                
            }
            
            for (var i:int = startIndex; i<count ; i++)
            {
                var currentObj:Object = sparkListBase.dataGroup.getElementAt(i);
                if( currentObj is IItemRenderer)
                {
                    visibleRows.push([currentObj]);
                }
            }
            return visibleRows;
        }
        
        
        /**
         *  @private
         */
        override public function get numAutomationChildren():int
        {
            
            var listItems:Array = getVisibleRowsRenderers();
            if (listItems.length == 0)
                return 0;
            
            //this code is for multi colum list also.
            // eventhough we have only one column spark list
            // we are maintaining the same as it does not cause any harm.
            var result:int = listItems.length * listItems[0].length;
            var row:uint = listItems.length - 1;
            var col:uint = listItems[0].length - 1;
            while (!listItems[row][col] && result > 0)
            {
                result--;
                if (col != 0)
                    col--;
                else if (row != 0)
                {
                    row--;
                    col = listItems[0].length - 1;
                }
            }
            return result;
        }
        
        /**
         *  @private
         */
        override public function getAutomationChildAt(index:int):IAutomationObject
        {
            
            var listItems:Array = getVisibleRowsRenderers();
            var numCols:int = listItems? listItems[0].length:0;
            var row:uint = uint(numCols == 0 ? 0 : index / numCols);
            var col:uint = uint(numCols == 0 ? index : index % numCols);
            var item:IAutomationObject = listItems[row][col];
            return item;
        }
        
        /**
         * @private
         */
        override public function getAutomationChildren():Array
        {
            
            var childrenList:Array = new Array();
            
            var listItems:Array = getVisibleRowsRenderers();
            
            // we get this as the 2 dim array of row and columns
            // we need to make this as single element array
            //while (!listItems[row][col] 
            var  rowcount:int  = listItems?listItems.length:0;
            if (rowcount != 0)
            {
                var coulumcount:int = 0;
                
                if ((listItems[0]) is Array)
                    coulumcount = (listItems[0] as Array).length;
                
                for (var i:int = 0; i < rowcount ; i++)
                {
                    for(var j:int = 0; j < coulumcount ; j++)
                    {
                        var item:IItemRenderer = listItems[i][j];
                        if(item)
                            childrenList.push(item as IAutomationObject);
                    }
                }
            }
            
            childrenList =  addScrollers(childrenList);
            return  childrenList;
        }
        
        /**
         * private
         */
        
        protected function addScrollers(chilArray:Array):Array
        {
            
            var count:int = sparkListBase.numChildren;
            for (var i:int=0; i<count; i++)
            {
                var obj:Object = sparkListBase.getChildAt(i);
                // here if are getting scrollers, we need to add the scrollbars. we dont need to
                // consider the view port contents as the data content is handled using the renderes.
                if(obj is spark.components.Scroller)
                {
                    var scroller:spark.components.Scroller = obj as spark.components.Scroller; 
                    if(scroller.horizontalScrollBar && scroller.horizontalScrollBar.visible)
                        chilArray.push(scroller.horizontalScrollBar);
                    if(scroller.verticalScrollBar && scroller.verticalScrollBar.visible)
                        chilArray.push(scroller.verticalScrollBar);
                }
            }
            
            
            var scrollBars:Array = getScrollBars(sparkListBase,null);
            var n:int = scrollBars? scrollBars.length : 0;
            
            for ( i=0; i<n ; i++)
            {
                chilArray.push(scrollBars[i]);
            }
            return chilArray;
        }
        
        
        /**
         *  A matrix of the automationValues of each item in the grid. The return value
         *  is an array of rows, each of which is an array of item renderers (row-major).
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        override public function get automationTabularData():Object
        {
            return new SparkListBaseTabularData(sparkListBase);
        }
        
        /**
         * @private
         */
        override public function replayAutomatableEvent(event:Event):Boolean
        {
            var help:IAutomationObjectHelper = Automation.automationObjectHelper;
            switch (event.type)
            {
                case MouseEvent.CLICK:
                {
                    return help.replayClick(uiComponent, MouseEvent(event));
                }
                    // There is no double click support on spark list as we do not have
                    // any event from spark list for double click
                /*  case ListEvent.ITEM_DOUBLE_CLICK:
                {
                    var clickEvent:ListEvent = ListEvent(event);
                    return replayMouseDoubleClickOnItem(clickEvent.itemRenderer);
                }  */  
                case KeyboardEvent.KEY_DOWN:
                {
                    sparkListBase.setFocus();
                    return help.replayKeyboardEvent(uiComponent, KeyboardEvent(event));
                }
                case SparkListItemSelectEvent.SELECT_INDEX:
                case SparkListItemSelectEvent.SELECT:
                {
                    var completeTime:Number = getTimer() + sparkListBase.getStyle("selectionDuration");
                    
                    help.addSynchronization(function():Boolean
                    {
                        return getTimer() >= completeTime;
                    });
                    
                    var lise:SparkListItemSelectEvent = SparkListItemSelectEvent(event);
                    
                    if (event.type == SparkListItemSelectEvent.SELECT_INDEX)
                    {
                        lise.itemRenderer = sparkListBase.dataGroup.getElementAt(lise.itemIndex) as IItemRenderer; 
                    }
                    else
                    {
                        if (!lise.itemRenderer)
                            findItemRenderer(lise);
                    }
                    
                    
                    // keyboard and mouse are currently treated the same
                    if (lise.triggerEvent is MouseEvent)
                    {
                        return replayMouseClickOnItem(lise.itemRenderer,
                            lise.ctrlKey,
                            lise.shiftKey,
                            lise.altKey);
                    }
                    else if (lise.triggerEvent is KeyboardEvent)
                    {
                        return help.replayKeyDownKeyUp(lise.itemRenderer,
                            Keyboard.SPACE,
                            lise.ctrlKey,
                            lise.shiftKey,
                            lise.altKey);
                    }
                    else
                    {
                        throw new Error();
                    }
                }
                    
                case AutomationDragEvent.DRAG_START:
                case AutomationDragEvent.DRAG_DROP:
                case AutomationDragEvent.DRAG_COMPLETE:
                {
                    return DragManagerAutomationImpl.replayAutomatableEvent(uiAutomationObject,
                        event);
                }
                    // fall thru if not dragging while scroll occurs
                default:
                {
                    return super.replayAutomatableEvent(event);
                }
            }
        }
        
        /**
         * @private
         * Plays back MouseEvent.CLICK on the item renderer.
         */
        protected function replayMouseClickOnItem(item:IItemRenderer,
                                                  ctrlKey:Boolean = false,
                                                  shiftKey:Boolean = false,
                                                  altKey:Boolean = false):Boolean
        {
            var me:MouseEvent = new MouseEvent(MouseEvent.CLICK);
            me.ctrlKey = ctrlKey;
            me.altKey = altKey;
            me.shiftKey = shiftKey;
            var help:IAutomationObjectHelper = Automation.automationObjectHelper;
            return help.replayClick(item, me);
        }
        
        //--------------------------------------------------------------------------
        //
        //  Event handlers
        //
        //--------------------------------------------------------------------------
        
        /**
         *  @private
         */
        
        public function childAddedHandler(event:Event):void
        {
            
        }
        
        
        /**
         *  @private
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
        
        protected function addMouseClickHandlerToExistingRenderers():void
        {
            
            var count:int = sparkListBase.dataGroup? sparkListBase.dataGroup.numElements:0;
            for (var i:int = 0; i<count ; i++)
            {
                var currentObj:Object = sparkListBase.dataGroup.getElementAt(i);
                if( currentObj is IItemRenderer)
                    (currentObj as IItemRenderer).addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler,false, -100,true);
                if(currentObj is IAutomationObject)
                    IAutomationObject(currentObj).showInAutomationHierarchy = true;
            }
            
        }
        /**
         *  @private
         */
        
        protected function mouseDownHandler(event:MouseEvent):void
        {
            if(event.currentTarget as IItemRenderer)
                recordListItemSelectEvent(event.currentTarget as IItemRenderer , event);
            
        }
        
        /**
         *  @private
         */
        
        override protected function keyDownHandler(event:KeyboardEvent):void
        {
            if (event.keyCode == Keyboard.SPACE)
            {
                
                var listItems:Array = getVisibleRowsRenderers();
                var caretIndex:int = sparkListBase.caretIndex;
                if (caretIndex != -1)
                {
                    // we may face this situation with two scenario.
                    // user pressed the space bar when the drop down list was open
                    // on when the dropDown list was closed.
                    // when it is closed, we dont have an itemrenderer nor the layout.
                    // so we wont be recording the select operation here
                    // http://bugs.adobe.com/jira/browse/FLEXENT-1103
                    if((sparkListBase.layout as VerticalLayout)&& listItems && (listItems.length))
                    {
                        var rendererIndex:int = caretIndex - (sparkListBase.layout as VerticalLayout).firstIndexInView; 
                        
                        var item:IItemRenderer = listItems[rendererIndex][0] as IItemRenderer;
                        recordListItemSelectEvent(item, event);
                    }
                }   
                
            }
            else if (event.keyCode != Keyboard.SPACE &&
                event.keyCode != Keyboard.CONTROL &&
                event.keyCode != Keyboard.SHIFT &&
                event.keyCode != Keyboard.TAB)
            {
                recordAutomatableEvent(event);
            }   
        }       
        
        /**
         *  @private
         */
        protected function trimArray(val:Array):void
        {
            var n:int = val.length;
            for (var i:int = 0; i <n; i++)
            {
                val[i] = StringUtil.trim(val[i]);
            }
        }
        
        /**
         *  @private
         */
        
        protected function findItemRenderer(selectEvent:SparkListItemSelectEvent):Boolean
        {
            if (selectEvent.itemAutomationValue && selectEvent.itemAutomationValue.length)
            {
                var itemLabel:String = selectEvent.itemAutomationValue;
                var tabularData:IAutomationTabularData = automationTabularData as IAutomationTabularData;
                var values:Array = tabularData.getValues(0, tabularData.numRows);
                var length:int = values.length;
                
                var part:AutomationIDPart = new AutomationIDPart();
                part.automationName = itemLabel;
                
                var labels:Array = itemLabel.split("|");
                
                trimArray(labels);
                
                var index:int = 0;
                for each (var a:Array in values)
                {
                    values[index] = [];
                    trimArray(a);
                    var colIndex:int = 0 ;
                    for each (var b:String in a)
                    {
                        var splitArray:Array = b.split("|");
                        for each ( var c:String in splitArray)
                        values[index].push(c);
                    }
                    trimArray(values[index]);
                    ++index;
                }
                
                var n:int = labels.length;
                for (var i:int = 0; i < n; i++)
                {
                    var lString:String = labels[i];
                    if (lString.charAt(0) == "*" && lString.charAt(lString.length-1) == "*")
                        labels[i] = lString.substr(1, lString.length-2);
                }
                
                for ( i = 0; i < length; i++)
                {
                    if(compare(labels, values[i]))
                    {
                        var ao:IAutomationObject = Automation.automationManager.resolveIDPartToSingleObject(uiAutomationObject, part);
                        
                        if (ao)
                        {
                            selectEvent.itemRenderer = ao as IItemRenderer;
                            return true;
                        }
                    }
                }
            }
            
            return false;
        }
        
        
        /**
         *  @private
         */
        protected function compare(labels:Array, values:Array):Boolean
        {
            if (labels.length != values.length)
                return false;
            var n:int = labels.length;
            for (var i:int = 0; i < n; i++)
            {
                if (labels[i] != values[i])
                    return false;
            }
            
            return true;
        }
        
        /**
         *  @private
         */
        
        protected function fillItemRendererIndex(item:IItemRenderer, event:SparkListItemSelectEvent):void
        {
            event.itemIndex = sparkListBase.dataGroup.getElementIndex(item as IVisualElement);
            
        }  
        
        
        /**
         *  @private
         */
        public function getItemsCount():int
        {
            if (sparkListBase.dataProvider)
                return sparkListBase.dataProvider.length;
            
            return 0;
        }
    }
}
