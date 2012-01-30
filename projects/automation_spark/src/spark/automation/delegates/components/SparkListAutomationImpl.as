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
	import flash.events.MouseEvent;
	
	import mx.automation.Automation;
	import mx.automation.AutomationHelper;
	import mx.automation.AutomationIDPart;
	import mx.automation.IAutomationManager;
	import mx.automation.IAutomationObject;
	import mx.automation.IAutomationTabularData;
	import mx.automation.delegates.DragManagerAutomationImpl;
	import mx.automation.events.AutomationDragEvent;
	import mx.automation.events.AutomationRecordEvent;
	import mx.core.EventPriority;
	import mx.core.IVisualElement;
	import mx.core.mx_internal;
	import mx.events.DragEvent;
	import mx.managers.DragManager;
	
	import spark.automation.delegates.components.supportClasses.SparkListBaseAutomationImpl;
	import spark.automation.events.SparkListItemSelectEvent;
	import spark.automation.events.SparkValueChangeAutomationEvent;
	import spark.components.IItemRenderer;
	import spark.components.List;
	import spark.components.Scroller;
	import spark.components.supportClasses.ScrollBarBase;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.VerticalLayout;
	
	use namespace mx_internal;
	
	[Mixin]
	/**
	 * 
	 *  Defines methods and properties required to perform instrumentation for the 
	 *  List class.
	 * 
	 *  @see spark.components.List 
	 *
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	public class SparkListAutomationImpl extends SparkListBaseAutomationImpl
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
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		public static function init(root:DisplayObject):void
		{
			Automation.registerDelegateClass(spark.components.List, SparkListAutomationImpl);
		}   
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 * @param obj List object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 4
		 */
		public function SparkListAutomationImpl(obj:spark.components.List)
		{
			super(obj);
			obj.addEventListener(DragEvent.DRAG_START, dragStartHandler, false, 0 , true);
			obj.addEventListener(DragEvent.DRAG_DROP, dragDropHandler, false, EventPriority.DEFAULT+1, true);
			obj.addEventListener(DragEvent.DRAG_COMPLETE, dragCompleteHandler, false, 0 , true);
			obj.addEventListener(DragEvent.DRAG_ENTER, dragEnterHandler, false, 0 , true);
			obj.addEventListener(AutomationRecordEvent.RECORD, recordHandler, false, 0 , true);
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
		protected function get sparkList():spark.components.List
		{
			return uiComponent as spark.components.List;
		}
		
		/**
		 * @private
		 */
		private var dragEnterVScrollPos:Number;
		
		/**
		 * @private
		 */
		private var dragEnterHScrollPos:Number;
		
		/**
		 * @private
		 */
		private var itemUnderMouse:IAutomationObject;
		
		/**
		 * @private
		 */
		public function get firstVisibleRow():int
		{
			if(sparkList.layout is VerticalLayout)
				return (sparkList.layout as VerticalLayout).firstIndexInView;
			else if(sparkList.layout is HorizontalLayout)
				return (sparkList.layout as HorizontalLayout).firstIndexInView;
			return 0;
			
		}
		
		/**
		 * @private
		 */
		public function get lastVisibleRow():int
		{
			if(sparkList.layout is VerticalLayout)
				return (sparkList.layout as VerticalLayout).lastIndexInView;
			else if(sparkList.layout is HorizontalLayout)
				return (sparkList.layout as HorizontalLayout).lastIndexInView;
			return 0;
			
		}		
		
		/**
		 * @private
		 */
		override public function get automationValue():Array
		{
			var result:Array = [];
			// this gets the value of the item renderers in the 
			// selected indices.
			// currently we are handling only the single column details here.
			
			var selectedItemsAboveView:Boolean = false;
			var selectedItemsBelowView:Boolean = false;
			
			var selItems:Vector.<int> = sparkList.selectedIndices;
			var n:int = selItems? selItems.length :0;
			
			var listLength:int = (sparkList && sparkList.dataGroup)?sparkList.dataGroup.numElements:0 ;
			var firstVisibleIndex:int  = firstVisibleRow;
			var lastVisibleIndex:int  = lastVisibleRow;     
			
			for (var i:int = 0; i < n; i++)
			{
				
				var selectedIndex:int  =  selItems[i];
				
				if (selectedIndex < firstVisibleIndex)
				{
					selectedItemsAboveView = true;
				}
				else if (selectedIndex > lastVisibleIndex)
				{
					selectedItemsBelowView = true;
				}
				else
				{
					var item:IVisualElement = sparkList.dataGroup.getElementAt(selectedIndex);
					if(item is IAutomationObject)
						result.push(IAutomationObject(item).automationValue);
				}
			}
			
			if (selectedItemsAboveView)
				result.unshift("...");
			
			if (selectedItemsBelowView)
				result.push("...");
			
			return result;
		}		
		
		/**
		 *  @private
		 */
		protected function dragStartHandler(event:DragEvent):void
		{
			var shouldEventBeDispatched:Boolean = true;
			
			// we need a different handling if the event is happening in air.
			// first we need to check whether the env is air or not.
			// for automation we have a special class to handle the 
			if (AutomationHelper.isCurrentAppAir())
			{
				// for air we need to send the event only if the dragSource is present.
				// drag start happens from the list base  (mouse  down  + mouse move)
				// and from the listener of the native drag start.
				// we need the details from the native event, hence handle it only
				// if it is from the native drag event.
				if (!event.dragSource)
					shouldEventBeDispatched = false;
			}
			
			if (shouldEventBeDispatched)
			{  
				var drag:AutomationDragEvent = new AutomationDragEvent(event.type);
				drag.draggedItem = itemUnderMouse;
				drag.ctrlKey = ctrlKeyDown;
				drag.shiftKey = shiftKeyDown;
				
				var re:AutomationRecordEvent = new AutomationRecordEvent(AutomationRecordEvent.RECORD, false);
				re.automationObject = uiAutomationObject;
				re.cacheable = false;
				re.replayableEvent = drag;
				
				var am:IAutomationManager = Automation.automationManager;				
				preventDragDropRecording = false;
				am.recordAutomatableEvent(uiAutomationObject, re);
				preventDragDropRecording = true;
			}
		}
		
		/**
		 *  @private
		 */
		protected function dragDropHandler(event:DragEvent):void
		{
			
			var dragDropVScrollPos:Number = -1;
			var dragDropHScrollPos:Number = -1;
			if(sparkList.layout != null)
			{
				dragDropVScrollPos = sparkList.layout.verticalScrollPosition;
				dragDropHScrollPos = sparkList.layout.horizontalScrollPosition;
			}
			var am:IAutomationManager = Automation.automationManager;
			
			// Scrolling on the list while dragging is not dispatching any event. 
			// It dispatches a SCROLL event in Halo List controls but that is not the case in Spark List controls.
			// So we are recording a value change event here if we find that the scroll positions
			// at the time of drag drop are different from those at the time of drag enter. 
			if((dragDropVScrollPos != dragEnterVScrollPos) ||  (dragDropHScrollPos != dragEnterHScrollPos))
			{
				var vScrollBar:ScrollBarBase;
				var hScrollBar:ScrollBarBase;
				var scroller:Scroller = getScroller(sparkList, sparkList.dataGroup);
				if(scroller)
				{
					if(scroller.horizontalScrollBar && scroller.horizontalScrollBar.visible)
						hScrollBar = scroller.horizontalScrollBar;
					if(scroller.verticalScrollBar && scroller.verticalScrollBar.visible)
						vScrollBar = scroller.verticalScrollBar;					
				}
				
				if(dragDropVScrollPos != dragEnterVScrollPos)
				{
					var valueChangeEvent:SparkValueChangeAutomationEvent = 
						new SparkValueChangeAutomationEvent(
							SparkValueChangeAutomationEvent.CHANGE,false,false,dragDropVScrollPos);
					if (am && am.recording)
						am.recordAutomatableEvent(vScrollBar as IAutomationObject, valueChangeEvent);
				}
				
				if(dragDropHScrollPos != dragEnterHScrollPos)
				{
					var valueChangeEvent1:SparkValueChangeAutomationEvent = 
						new SparkValueChangeAutomationEvent(
							SparkValueChangeAutomationEvent.CHANGE,false,false,dragDropHScrollPos);
					if (am && am.recording)
						am.recordAutomatableEvent(hScrollBar as IAutomationObject, valueChangeEvent1);
				}
			}
			
			var drag:AutomationDragEvent = new AutomationDragEvent(event.type);
			drag.action = event.action;
			var index:int = sparkList.layout.calculateDropLocation(event).dropIndex;
			
			drag.draggedItem = sparkList.dataGroup.getElementAt(index) as IAutomationObject;
			preventDragDropRecording = false;
			am.recordAutomatableEvent(uiAutomationObject, drag);
			preventDragDropRecording = true;
		}
		
		/**
		 *  @private
		 */
		protected function dragEnterHandler(event:DragEvent):void
		{
			// Scrolling on the list while dragging is not dispatching any event.
			// It dispatches a SCROLL event in Halo List controls but that is not the case in Spark List controls.
			// So we are storing the scroll positions at the time of drag enter
			// so that we can record a value change event if we find that the scroll positions
			// at the time of drag drop are different from those at the time of drag enter.
			if(sparkList.layout != null)
			{
				dragEnterVScrollPos = sparkList.layout.verticalScrollPosition;
				dragEnterHScrollPos = sparkList.layout.horizontalScrollPosition;
			}
			else
			{
				dragEnterVScrollPos = -1;
				dragEnterHScrollPos = -1;
			}
		}
		
		/**
		 *  @private
		 */
		protected function dragCompleteHandler(event:DragEvent):void
		{
			if (event.action == DragManager.NONE)
			{
				var drag:AutomationDragEvent = new AutomationDragEvent(event.type);
				drag.action = event.action;
				
				var am:IAutomationManager = Automation.automationManager;
				preventDragDropRecording = false;
				am.recordAutomatableEvent(uiAutomationObject, drag);
				preventDragDropRecording = true;
			}
		}	
		
		
		/**
		 *  @private
		 */
		
		override protected function findItemRenderer(selectEvent:SparkListItemSelectEvent):Boolean
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
						sparkList.ensureIndexIsVisible(i);
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
		
		
		private function recordHandler(ev:AutomationRecordEvent):void
		{
			// list based controls handle drag-drop on their own
			if (preventDragDropRecording && ev.replayableEvent is AutomationDragEvent)
				ev.preventDefault();    
		}
		
		override protected function mouseDownHandler(event:MouseEvent):void
		{
			//This mouseDownHandler is on the renderer.
			ctrlKeyDown = event.ctrlKey;
			shiftKeyDown = event.shiftKey;
			itemUnderMouse = DragManagerAutomationImpl.getChildAutomationObject(sparkList, event);
			super.mouseDownHandler(event);
		}		
	}
}
