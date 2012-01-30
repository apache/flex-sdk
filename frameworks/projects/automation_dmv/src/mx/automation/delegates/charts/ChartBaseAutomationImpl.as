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

package mx.automation.delegates.charts 
{
	
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	import mx.automation.Automation;
	import mx.automation.IAutomationManager;
	import mx.automation.IAutomationObject;
	import mx.automation.IAutomationObjectHelper;
	import mx.automation.delegates.DragManagerAutomationImpl;
	import mx.automation.delegates.core.UIComponentAutomationImpl;
	import mx.automation.events.AutomationDragEvent;
	import mx.automation.events.ChartSelectionChangeEvent;
	import mx.automation.tabularData.ChartBaseTabularData;
	import mx.charts.ChartItem;
	import mx.charts.HitData;
	import mx.charts.chartClasses.ChartBase;
	import mx.charts.chartClasses.Series;
	import mx.charts.events.ChartItemEvent;
	import mx.charts.events.ChartEvent;
	import mx.core.EventPriority;
	
	[Mixin]
	/**
	 * 
	 *  Defines the methods and properties required to perform instrumentation for the 
	 *  ChartBase base class. 
	 * 
	 *  @see mx.charts.chartClasses.ChartBase
	 *  
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class ChartBaseAutomationImpl extends UIComponentAutomationImpl 
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
		 *  @productversion Flex 3
		 */
		public static function init(root:DisplayObject):void
		{
			Automation.registerDelegateClass(ChartBase, ChartBaseAutomationImpl);
		}   
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/** 
		 *  Constructor.
		 *  @param obj ChartBase object to be automated. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function ChartBaseAutomationImpl(obj:ChartBase)
		{
			super(obj);
			
			chartBase = obj;
			obj.addEventListener(ChartItemEvent.ITEM_CLICK, chartItemClickHandler, false, 0, true);
			obj.addEventListener(ChartItemEvent.ITEM_DOUBLE_CLICK, chartItemDoubleClickHandler, false, 0, true);
			obj.addEventListener(ChartItemEvent.CHANGE, chartItemChangeHandler, false, 0, true);
			obj.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler1, false, EventPriority.DEFAULT-10, true);
			
			// we are not listening to mouse events as we have special events from chart
			// the special events are needed to take care of the snesitiviy based triggering of the events
			// on the item and on the chart. i.e even if the mouse is on the chart, the event will be the 
			// item click if htis point is within the sensitivity range of that datapoint.
			// it is not possible to differentiate this from outside. Hence charts gave a new event as chartClick
			// which will be triggered only if the hitdata set is empty. 
			obj.addEventListener(ChartEvent.CHART_CLICK, chartClickHandler, false, 0, true);
			
			
			
			// we are not getting the double click event at all
			// hence this portion is commented
			//obj.addEventListener(ChartEvent.CHART_DOUBLE_CLICK, chartClickHandler, false, 0, true);
			
			// we are not listening to mouse events refer the comments of ChartEvent.CHART_CLICK for details
			//obj.addEventListener(MouseEvent.CLICK, mouseClickHandler, false, 0, true);
			//obj.addEventListener(MouseEvent.DOUBLE_CLICK, mouseClickHandler, false, 0, true);
			
			
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  chartBase
		//----------------------------------
		
		/**
		 *  @private
		 *  storage for the owner component
		 */
		private var chartBase:ChartBase;
		
		
		/**
		 *  @private
		 */
		override public function createAutomationIDPart(child:IAutomationObject):Object
		{
			var help:IAutomationObjectHelper = Automation.automationObjectHelper;
			return help.helpCreateIDPart(uiAutomationObject, child);
		}
		
		override public function createAutomationIDPartWithRequiredProperties(child:IAutomationObject, properties:Array):Object
		{
			var help:IAutomationObjectHelper = Automation.automationObjectHelper;
			return (help
				? help.helpCreateIDPartWithRequiredProperties(uiAutomationObject, child,properties): null);
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
		override public function getAutomationChildAt(index:int):IAutomationObject
		{
			return chartBase.series[index] ;    
		}
		
		/**
		 *  @private
		 */
		override public function getAutomationChildren():Array
		{
			var childList:Array = new Array();
			
			var tempArray1:Array = chartBase.series;
			if (tempArray1)
			{
				var n:int = tempArray1.length;
				for(var i:int = 0; i < n ; i++)
				{
					childList.push(tempArray1[i]);
				}
			}
			return  childList;    
		}
		
		/**
		 *  @private
		 */
		override public function get numAutomationChildren():int
		{
			return chartBase.series.length;
		}
		
		/**
		 *  @private
		 */
		override public function get automationTabularData():Object
		{
			return new ChartBaseTabularData(uiAutomationObject);
		}
		
		
		/**
		 *  @private
		 */
		override public function getLocalPoint(inPoint:Point, targetObj:DisplayObject):Point
		{
			// in the mousedown handler of the event dispatches the coordinates
			// on the series. Replaying of event has actual dragged item which is the same 
			// series as target. So we need not convert this point. We can return the same 
			// point.
			
			return inPoint;
		}
		
		/**
		 *  @private
		 */
		override public function isDragEventPositionBased():Boolean
		{
			// for almost all components it is not.
			// however for compoents like chart it is coordinate based
			return true;
		}
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		
		/**
		 *  @private
		 */
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			// as of now this will be called only if it is the enter key
			// dont record this event
			return;
			
		}
		
		
		/**
		 * @private
		 */ 
		private function chartClickHandler(event:ChartEvent):void
		{
			
			// check whether the event is coming from the chart base
			if(event.target is ChartBase)
			{ 
				var am:IAutomationManager = Automation.automationManager;
				var ao:IAutomationObject = event.target as IAutomationObject;
				if (ao)
				{
					var newMouseEvent:MouseEvent = null;
					
					if (event.type==  ChartEvent.CHART_CLICK)
						newMouseEvent = new MouseEvent(MouseEvent.CLICK);
					
					newMouseEvent.shiftKey=event.shiftKey;
					newMouseEvent.altKey=event.altKey;
					newMouseEvent.ctrlKey=event.ctrlKey;
					am.recordAutomatableEvent(ao, newMouseEvent,true);
					
				}
			}
		}
		/**
		 *  @private
		 */
		protected function keyDownHandler1(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.ENTER)
				return;
			// as of now this will be called only if it is the enter key
			// dont record this event
			
		}
		
		
		/**
		 * @private
		 */
		private function chartItemClickHandler(event:ChartItemEvent):void
		{
			var am:IAutomationManager = Automation.automationManager;
			var itemCount:int = event.hitSet.length;
			
			event.localX = int(event.localX);
			event.localY = int(event.localY);
			
			for (var i:int = 0; i < itemCount; ++i)
			{       
				var data:HitData = event.hitSet[i];
				var ao:IAutomationObject = data.element as IAutomationObject;
				if (ao)
					am.recordAutomatableEvent(ao, event,true);
			}
		}
		
		/**
		 * @private
		 */
		private function chartItemDoubleClickHandler(event:ChartItemEvent):void
		{
			var am:IAutomationManager = Automation.automationManager;
			var itemCount:int = event.hitSet.length;
			
			for (var i:int = 0; i < itemCount; ++i)
			{       
				var data:HitData = event.hitSet[i];
				var ao:IAutomationObject = data.element as IAutomationObject;
				if (ao)
					am.recordAutomatableEvent(ao, event,true);
			}
		}
		
		
		
		/**
		 *  @private
		 */
		private function chartItemChangeHandler(event:ChartItemEvent):void
		{ 
			
			var am:IAutomationManager = Automation.automationManager;
			
			var selectedIndices:Array =((event.currentTarget)as ChartBase).selectedChartItems;
			var selectionDetails:Array = new Array;
			// var chartItemIndices:Array = new Array;
			var n:int = selectedIndices.length;
			for (var index:int=0; index < n ; index ++)
			{
				// get the item index - the selected item has the index datamember
				var chartItemIndex:int = (((((event.currentTarget)as ChartBase).selectedChartItems)[index]) as ChartItem).index; 
				var chartSeries:Array = ((event.currentTarget)as ChartBase).series;
				var selecteditems:Array = ((event.currentTarget)as ChartBase).selectedChartItems;
				var seriesIndex:int = chartSeries.indexOf((selecteditems[index]).element);
				var autoName:String = (chartSeries[seriesIndex] as Series).automationName;
				
				if (autoName != null )
					autoName = autoName.replace(";",",");
				else
					autoName = "  ";
				
				var selection:String = ("[" + autoName + " - " );
				selection = selection.concat( String (chartItemIndex) + ":" + String (seriesIndex) + " ] ");
				
				selectionDetails= selectionDetails.concat(selection);
			}
			if (selectedIndices.length == 0)
			{
				// this case happens if there were previus selections and then the user
				//clicks on an empty area.
				// in this case, we need to clear the current selection
				selection= "clear";
				selectionDetails= selectionDetails.concat(selection);
			}
			
			var chartEvent:ChartSelectionChangeEvent = new ChartSelectionChangeEvent(event.type,selectionDetails );
			
			
			//var data:ChartItem = ((event.currentTarget)as ChartBase).selectedChartItems[0];
			//var ao:IAutomationObject = data.element as IAutomationObject;
			var data:ChartBase = ((event.currentTarget)as ChartBase);
			var ao:IAutomationObject = data as IAutomationObject;
			if (ao)
				am.recordAutomatableEvent(ao, chartEvent);
		}
		
		
		
		/**
		 *  @private
		 */
		override public function replayAutomatableEvent(event:Event):Boolean
		{
			var help:IAutomationObjectHelper = Automation.automationObjectHelper;
			
			if (event is ChartSelectionChangeEvent) 
			{
				var selectEvent:ChartSelectionChangeEvent = event as ChartSelectionChangeEvent;   
				var selectionInfoDetails:Array = selectEvent.selectionInfo;
				
				// clear all the series selected Items
				var seriesCount:Number= chartBase.series.length;
				var emptyArray:Array = [];
				chartBase.clearSelection();
				
				if (( selectionInfoDetails.length == 1) && (selectionInfoDetails[0]=="clear"))
					return true;
				// the selection needs to be cleared.
				// since this is already done, it is not necessary to do this again, hence 
				
				var prevSeriesIndex:int = -1;
				var n:int = selectionInfoDetails.length;
				for (var index:int=0; index < n ; index++)
				{
					
					var currentSelection:String = selectionInfoDetails[index];
					// split the string to get the itemIndex and seriedIndex
					// each element will look like [Country,Silver - 1:0 ]
					var tempArray:Array= currentSelection.split("-");
					if( tempArray.length > 1)
					{
						var data:String = tempArray[1];
						// data is now 1:0 ]
						data = data.replace("]","");
						tempArray = data.split(":");
						
						if (tempArray.length > 1)
						{
							//series.selectedIndices += itemIndex;
							var seriesIndex:Number = Number(tempArray[1]);
							var itemIndex:Number = Number(tempArray[0]);
							if (prevSeriesIndex != seriesIndex)
							{
								if (prevSeriesIndex != -1)
									(chartBase.series[prevSeriesIndex]).selectedIndices = selectedItems;
								
								prevSeriesIndex = seriesIndex;
								var selectedItems:Array = [];
							}
							// get the series with the current series item
							selectedItems.push(itemIndex);
						}
						
						// the last series assignment
						(chartBase.series[seriesIndex]).selectedIndices = selectedItems;
					}
				}
				
				return true;
			}
			if (event is AutomationDragEvent)
			{
				var prevSlectionMode:String= chartBase.selectionMode;
				chartBase.selectionMode="none";
				
				DragManagerAutomationImpl.replayAutomatableEvent(uiAutomationObject,
					event);
				chartBase.selectionMode=prevSlectionMode;  
				return true;                                            
			}
			
			return super.replayAutomatableEvent(event);
		}
		
		
		
	}
}
