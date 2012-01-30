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

package mx.automation.delegates.advancedDataGrid
{ 
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	
	import mx.automation.Automation;
	import mx.automation.IAutomationManager;
	import mx.automation.IAutomationObject;
	import mx.automation.IAutomationObjectHelper;
	import mx.automation.events.AdvancedDataGridHeaderShiftEvent;
	import mx.automation.events.AdvancedDataGridItemSelectEvent;
	import mx.automation.events.AutomationDragEvent;
	import mx.automation.events.ListItemSelectEvent;
	import mx.automation.tabularData.AdvancedDataGridTabularData;
	import mx.controls.AdvancedDataGrid;
	import mx.controls.AdvancedDataGridBaseEx;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.core.IFlexDisplayObject;
	import mx.core.mx_internal;
	import mx.events.AdvancedDataGridEvent;
	import mx.events.DragEvent;
	import mx.events.IndexChangedEvent;
	import mx.collections.IHierarchicalCollectionView;
	import mx.collections.IHierarchicalData;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridGroupItemRenderer;
	
	use namespace mx_internal;   
	
	// take the class place it in a Mixin array and the System manger calls init on this class.
	[Mixin] 
	/**
	 * 
	 *  Defines methods and properties required to perform instrumentation for the 
	 *  AdvancedDataGrid control.
	 * 
	 *  @see mx.controls.AdvancedDataGrid 
	 *
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class AdvancedDataGridAutomationImpl extends AdvancedDataGridBaseExAutomationImpl  
	{    
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
			Automation.registerDelegateClass(AdvancedDataGrid, AdvancedDataGridAutomationImpl);
		}  
		
		
		/**
		 *  Constructor.
		 * @param obj AdvancedDataGrid object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */  
		public function AdvancedDataGridAutomationImpl(obj:AdvancedDataGrid) 
		{
			super(obj);
			obj.addEventListener(AdvancedDataGridEvent.ITEM_OPEN, recordAutomatableEvent, false, 0, true);
			obj.addEventListener(AdvancedDataGridEvent.ITEM_CLOSE, itemCloseHandler, false, 0, true);
			obj.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler1, false, -1, false);
		}
		
		/**
		 * @private
		 */
		protected  function get grid1():AdvancedDataGrid
		{
			return uiComponent as AdvancedDataGrid;
		}
		
		/**
		 * @private
		 */
		override protected function mouseDownHandler(event:MouseEvent):void
		{
			super.mouseDownHandler(event);
		}
		
		
		/**
		 * @private
		 */
		override protected function mouseClickHandler(event:MouseEvent):void
		{
			super.mouseClickHandler(event);
		}
		
		
		/**
		 * @private
		 */
		override public function getAutomationChildren():Array
		{
			var childrenList:Array = new Array();
			var listItems:Array = grid1.rendererArray;
			
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
					for (var j:int = 0; j < coulumcount ; j++)
					{
						var item:IListItemRenderer = listItems[i][j];
						if (item)
						{
							if (grid1.itemEditorInstance &&
								grid1.editedItemPosition &&
								item == grid1.editedItemRenderer)
								childrenList.push(grid1.itemEditorInstance as IAutomationObject);
							else
								childrenList.push(item as IAutomationObject);
						}
					}
				}
			}
			
			return  childrenList;
		}
		
		
		/**
		 * @private
		 */
		override public function getAutomationChildAt(index:int):IAutomationObject
		{
			var listItems:Array = grid1.rendererArray;
			
			var numCols:int = listItems[0].length;
			var row:uint = uint(numCols == 0 ? 0 : index / numCols);
			var col:uint = uint(numCols == 0 ? index : index % numCols);
			var item:IListItemRenderer = listItems[row][col];
			
			if (grid1.itemEditorInstance &&
				grid1.editedItemPosition &&
				item == grid1.editedItemRenderer)
				return grid1.itemEditorInstance as IAutomationObject;
			
			return  item as IAutomationObject;
		}
		
		
		/**
		 * @private
		 */
		override public function getItemAutomationIndex(delegate:IAutomationObject):String
		{
			var item:IListItemRenderer = delegate as IListItemRenderer;
			if (item == grid1.itemEditorInstance && grid1.editedItemPosition)
				item = grid1.editedItemRenderer;
			var row:int = grid1.itemRendererToIndex(item);
			return (row < 0
				? getItemAutomationName(delegate)
				: grid1.gridColumnMap[item.name].dataField + ":" + row);
		}
		
		/**
		 * @private
		 */
		override public function getItemAutomationValue(item:IAutomationObject):String
		{
			return getItemAutomationNameOrValueHelper(item, false);
		}
		
		
		/**
		 * @private
		 */
		override public function getItemAutomationName(item:IAutomationObject):String
		{
			return getItemAutomationNameOrValueHelper(item, true);
		}
		
		
		/**
		 *  @private
		 */
		
		
		/**
		 *  @private
		 */ 
		override protected function getItemAutomationNameOrValueHelper(delegate:IAutomationObject,
																	   useName:Boolean):String
		{   
			return super.getItemAutomationNameOrValueHelper(delegate,useName);
		}
		
		
		
		
		/**
		 * @private
		 */
		override public function replayAutomatableEvent(event:Event):Boolean
		{
			var completeTime:Number;
			var help:IAutomationObjectHelper = Automation.automationObjectHelper;
			if (event is AdvancedDataGridEvent)
			{
				var t:AdvancedDataGridEvent = AdvancedDataGridEvent(event);
				if ((event.type == IndexChangedEvent.HEADER_SHIFT)||
					((event.type == AdvancedDataGridEvent.HEADER_RELEASE)) ||
					((event.type == AdvancedDataGridEvent.COLUMN_STRETCH)))
				{
					return super.replayAutomatableEvent(event);
				}
				else
				{
					
					var renderer:IListItemRenderer = t.itemRenderer;
					var open:Boolean = grid1.isItemOpen(renderer.data);
					
					if ((t.type == AdvancedDataGridEvent.ITEM_OPEN && open) ||
						(t.type == AdvancedDataGridEvent.ITEM_CLOSE && !open))
						return false;
					
					// we wait for the openDuration
					completeTime = getTimer() + grid1.getStyle("openDuration");
					
					
					help.addSynchronization(function():Boolean
					{
						//we wait if the grid1. is opening
						// this is required because tree increases the tween duration based
						// on the number of items to open
						return (!grid1.isOpening && getTimer() >= completeTime);
					});
				}
				if (t.triggerEvent is KeyboardEvent)
				{
					// if its an open and we're closed, or a close and we're open
					grid1.getFocus();
					
					// to replay the keyboard open and close the key combination needed is
					// ctrl+shift+right for open and ctrl+shift+left for close.
					return help.replayKeyDownKeyUp(uiComponent,
						(t.type == AdvancedDataGridEvent.ITEM_OPEN
							? Keyboard.RIGHT
							: Keyboard.LEFT),true,true);
				}
				else if (t.triggerEvent is MouseEvent)
				{
					if (renderer is AdvancedDataGridGroupItemRenderer)
						return help.replayClick(AdvancedDataGridGroupItemRenderer(renderer).getDisclosureIcon());
					
					if (renderer is IAutomationObject)
						return IAutomationObject(renderer).replayAutomatableEvent(event);
					else
						throw new Error();
				}
				else
				{
					var message:String = resourceManager.getString(
						"controls", "unknownInput", [t.triggerEvent.type]);
					throw new Error(message);
				}
			}
				
			else if (event is ListItemSelectEvent)
			{
				completeTime = getTimer() + grid1.getStyle("openDuration");
				help.addSynchronization(function():Boolean
				{
					//we wait if the tree is opening
					// this is required because tree increases the tween duration based
					// on the number of items to open
					return (!grid1.isOpening && getTimer() >= completeTime);
				});
			}
			
			return super.replayAutomatableEvent(event);
		}
		
		
		
		
		
		/**
		 *  A matrix of the automationValues of each item in the grid1. The return value
		 *  is an array of rows, each of which is an array of item renderers (row-major).
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */ 
		override public function get automationTabularData():Object
		{
			return  new AdvancedDataGridTabularData(grid1);
		}
		
		/**
		 *  @private
		 */
		
		override protected function keyDownHandler1(event:KeyboardEvent):void
		{
			if (grid1.itemEditorInstance || event.target != event.currentTarget)
				return;
			
			super.keyDownHandler1(event);
		}
		
		
		
		
		/**
		 *  @private
		 */
		private function itemEditHandler(event:AdvancedDataGridEvent):void
		{
			recordAutomatableEvent(event, true);    
		}
		
		/**
		 *  @private
		 */
		private function itemCloseHandler(event:AdvancedDataGridEvent):void
		{
			recordAutomatableEvent(event, true);    
		}
		
		
		
		/**
		 * @private
		 * method to check whehter the specified index correpsonds to a groped item
		 */
		public function isGroupeditem(rowIndex:int, restorePrevView:Boolean=true):Boolean
		{
			var isGrouped:Boolean = false;
			
			// check wehter the dataprovider was of IHierarchicalCollectionView
			// if the ADG is not of the tree structure and if the user calls this method
			// else it will throw error.
			
			var view:IHierarchicalCollectionView = (grid1.dataProvider) as IHierarchicalCollectionView;
			if (!view)
				return isGrouped;
			
			var origScrollPos:int = grid1.verticalScrollPosition;
			var  posChanged:Boolean = false;
			var currentScrollpos:int = origScrollPos;  
			// check whether the requried row is visible
			// i.e whether the required row is withing the current Vertical scrollpos+ numberof row range
			if (grid1.scrollToIndex(rowIndex))
			{
				posChanged = true;
			}
			
			//calculate the visible row index
			currentScrollpos = grid1.verticalScrollPosition;
			var newRowIndex: int= rowIndex-currentScrollpos;
			
			// check whether the requried row Index is visible
			var listItems:Array = grid1.rendererArray;
			var item:IListItemRenderer = listItems[newRowIndex][0];
			
			
			if (newRowIndex >= view.length)
			{
				var message:String = "Invalid Row Index : " + String(rowIndex) + " - Total Row Count : " 
					+ String (grid1.maxVerticalScrollPosition + view.length);
				Automation.automationDebugTracer.traceMessage("AdvancedDataGridAutomationImpl","isGroupeditem()",message);
			}
			else
			{
				var data:IHierarchicalData = view.source;
				
				if (data.canHaveChildren(item.data))
					isGrouped = true;
			}
			
			if (posChanged && restorePrevView)
			{
				//  position chaneged and  it is required to set the original scroll pos
				// hence setting the original pos
				grid1.verticalScrollPosition = origScrollPos;
			}
			
			return isGrouped;
		}
		
		
		
		/**
		 * @private
		 * method to get the number of children for a group item
		 */
		public function getGroupedItemChildrenCount(rowIndex:int, restorePrevView:Boolean=true):Number
		{
			
			var numChildren:Number = 0;
			// check wehter the dataprovider was of IHierarchicalCollectionView
			// if the ADG is not of the tree structure and if the user calls this method
			// else it will throw error.
			
			var view:IHierarchicalCollectionView = (grid1.dataProvider) as IHierarchicalCollectionView;
			if (!view)
				return numChildren;
			
			
			var origScrollPos:int = grid1.verticalScrollPosition;
			var  posChanged:Boolean = false;
			var currentScrollpos:int = origScrollPos;  
			// check whether the requried row is visible
			// i.e whether the required row is withing the current Vertical scrollpos+ numberof row range
			if (grid1.scrollToIndex(rowIndex))
			{
				posChanged = true;
			}
			
			//calculate the visible row index
			currentScrollpos = grid1.verticalScrollPosition;
			var newRowIndex: int= rowIndex-currentScrollpos;
			
			// check whether the requried row Index is visible
			var listItems:Array = grid1.rendererArray;
			var item:IListItemRenderer = listItems[newRowIndex][0];
			
			
			if (newRowIndex >= view.length)
			{
				var message:String = "Invalid Row Index : " + String(rowIndex) + " - Total Row Count : " 
					+ String (grid1.maxVerticalScrollPosition + view.length);
				Automation.automationDebugTracer.traceMessage("AdvancedDataGridAutomationImpl","getGroupedItemChildrenCount()",message);
			}
			else
			{
				
				var data:IHierarchicalData = view.source;
				
				if (data.canHaveChildren(item.data))
					// the current row represents a grouped row
					numChildren = (data.getChildren(item.data)).length;
			}
			
			if (posChanged && restorePrevView)
				grid1.verticalScrollPosition = origScrollPos;
			//  position chaneged and  it is required to set the original scroll pos
			// hence setting the original pos
			
			return numChildren;
		}
		
		
		
		/**
		 * @private
		 * method to get the data corresponding to a speciifed row and column index
		 */
		public function getCellData(rowIndex:int, columIndex:int, restorePrevView:Boolean=true):String
		{
			var val:String = "";
			// check the validitity of the columnIndex
			if (columIndex >= grid1.columnCount)
			{
				val= "Invalid Column Index : " + String(columIndex) + " - Total Column Count : " + String( grid1.columnCount);
			}
			else
			{
				// this fucntion gets the cell data correspeonding to the cell mentioned by the row Index 
				// and the column Index.
				var origVScrollPos:int = grid1.verticalScrollPosition;
				var origHScrollPos:int = grid1.horizontalScrollPosition;						
				
				var  posChanged:Boolean = false;
				var currentScrollpos:int = origVScrollPos; 
				
				
				
				// check whether the requried row is visible
				// i.e whether the required row is withing the current Vertical scrollpos+ numberof row range
				if (grid1.scrollToIndex(rowIndex))
				{
					posChanged = true;
				}
				
				//calculate the visible row index
				currentScrollpos = grid1.verticalScrollPosition;
				var newRowIndex: int= rowIndex-currentScrollpos;
				
				// check whether the requried row Index is visible
				if (newRowIndex >= grid1.rowCount)
				{
					val= "Invalid Row Index : " + String(rowIndex) + " - Total Row Count : " 
						+ String (grid1.maxVerticalScrollPosition + grid1.rowCount);
				}
				else
				{
					// inedx is valid
					var listItems:Array = grid1.rendererArray;
					var item:IListItemRenderer;
					var itemDelegate:IAutomationObject;
					if ((listItems[newRowIndex] as Array).length > columIndex)
					{
						item = listItems[newRowIndex][columIndex];
						itemDelegate = item as IAutomationObject;
						val= (itemDelegate.automationName);
					}
					else
					{
						grid1.horizontalScrollPosition = columIndex;
						posChanged = true;
						var currentHScrollpos:Number = grid1.horizontalScrollPosition;
						var newColIndex:int = columIndex-currentHScrollpos;
						listItems = grid1.rendererArray;
						if ((listItems[newRowIndex] as Array).length > newColIndex)
						{
							item = listItems[newRowIndex][newColIndex];
							itemDelegate = item as IAutomationObject;
							val= (itemDelegate.automationName);
						}
					}
				}
				if (posChanged && restorePrevView)
				{
					grid1.verticalScrollPosition = origVScrollPos;
					grid1.horizontalScrollPosition = origHScrollPos;
				}
				//  position chaneged and  it is required to set the original scroll pos
				// hence setting the original pos
				
			}// end of valid column index if loop
			
			return val;
		}
		
		
		/**
		 * @private
		 * method to get the data corresponding to a speciifed row 
		 */
		public function getRowData(rowIndex:int, restorePrevView:Boolean=true):Array
		{
			var valArr:Array = new Array();
			// check the validitity of the columnIndex
			
			
			// this fucntion gets the cell data correspeonding to the cell mentioned by the row Index 
			// and the column Index.
			var origScrollPos:int = grid1.verticalScrollPosition;
			var  posChanged:Boolean = false;
			var currentScrollpos:int = origScrollPos; 
			
			
			
			// check whether the requried row is visible
			// i.e whether the required row is withing the current Vertical scrollpos+ numberof row range
			if (grid1.scrollToIndex(rowIndex))
				posChanged = true;
			
			//calculate the visible row index
			currentScrollpos = grid1.verticalScrollPosition;
			var newRowIndex: int= rowIndex-currentScrollpos;
			
			// check whether the requried row Index is visible
			if (newRowIndex >= grid1.rowCount)
			{
				var message:String = "Invalid Row Index : " + String(rowIndex) + " - Total Row Count : " 
					+ String (grid1.maxVerticalScrollPosition + grid1.rowCount);
				Automation.automationDebugTracer.traceMessage("AdvancedDataGridAutomationImpl","getRowData()",message);
				
			}
			else
			{
				var listItems:Array = grid1.rendererArray;
				var item:IListItemRenderer;
				
				// it will only get the contents corresponding to the visible elements
				// hence calculating the columnIndex
				
				var tempArray:Array = listItems[newRowIndex] as Array;
				var visibleColumnCount:Number = tempArray.length;
				
				// get the value of each cell and give back
				for (var columIndex:int = 0; columIndex < visibleColumnCount ; columIndex++)
				{
					item = listItems[newRowIndex][columIndex];
					var itemDelegate:IAutomationObject = item as IAutomationObject;
					if(itemDelegate.automationName != null)
						valArr.push(String(itemDelegate.automationName));
					else 
						valArr.push(String(""));
				}
			}
			if (posChanged && restorePrevView)
				grid1.verticalScrollPosition = origScrollPos;
			
			return valArr;
		}
		
		
		/**
		 * @private
		 * method to get the total number of data rows
		 */
		override public function getItemsCount():int
		{
			if (grid1.dataProvider)
				return grid1.dataProvider.length;
			
			return 0;
		}
		
		
		
	}
}

