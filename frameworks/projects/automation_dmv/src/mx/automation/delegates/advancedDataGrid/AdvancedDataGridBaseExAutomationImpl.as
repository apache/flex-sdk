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
	use namespace mx_internal;
	/*
	import mx.automation.tabularData.DataGridTabularData;
	*/
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
	public class AdvancedDataGridBaseExAutomationImpl extends AdvancedListBaseAutomationImpl 
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
			Automation.registerDelegateClass(AdvancedDataGridBaseEx, AdvancedDataGridBaseExAutomationImpl);
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
		public function AdvancedDataGridBaseExAutomationImpl(obj:AdvancedDataGrid)
		{
			super(obj); 
			
			
			obj.addEventListener(IndexChangedEvent.HEADER_SHIFT, headerShiftHandler, false, 0, true);
			obj.addEventListener(AdvancedDataGridEvent.HEADER_RELEASE, headerReleaseHandler, false, 0, true);
			obj.addEventListener(AdvancedDataGridEvent.COLUMN_STRETCH, columnStretchHandler, false, 0, true);
			
		}
		
		/**
		 *  @private
		 *  storage for the owner component
		 */
		protected function get grid():AdvancedDataGrid
		{
			return uiComponent as AdvancedDataGrid;
		}
		/**
		 * @private
		 */
		override public function getAutomationChildren():Array
		{
			var childrenList:Array = new Array();
			var listItems:Array = grid.rendererArray;
			
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
							if (grid.itemEditorInstance &&
								grid.editedItemPosition &&
								item == grid.editedItemRenderer)
								childrenList.push(grid.itemEditorInstance as IAutomationObject);
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
			var listItems:Array = grid.rendererArray;
			var numCols:int = listItems[0].length;
			var row:uint = uint(numCols == 0 ? 0 : index / numCols);
			var col:uint = uint(numCols == 0 ? index : index % numCols);
			var item:IListItemRenderer = listItems[row][col];
			
			if (grid.itemEditorInstance &&
				grid.editedItemPosition &&
				item == grid.editedItemRenderer)
				return grid.itemEditorInstance as IAutomationObject;
			
			return  item as IAutomationObject;
		}
		
		/**
		 * @private
		 */
		override public function getItemAutomationIndex(delegate:IAutomationObject):String
		{
			var item:IListItemRenderer = delegate as IListItemRenderer;
			if (item == grid.itemEditorInstance && grid.editedItemPosition)
				item = grid.editedItemRenderer;
			var row:int = grid.itemRendererToIndex(item);
			return (row < 0
				? getItemAutomationName(delegate)
				: grid.gridColumnMap[item.name].dataField + ":" + row);
		}
		
		/**
		 *  @private
		 */
		override public function getItemAutomationValue(item:IAutomationObject):String
		{
			return getItemAutomationNameOrValueHelper(item, false);
		}
		
		/**
		 *  @private
		 */
		override public function getItemAutomationName(item:IAutomationObject):String
		{
			return getItemAutomationNameOrValueHelper(item, true);
		}
		
		/**
		 *  @private
		 */ 
		protected function getItemAutomationNameOrValueHelper(delegate:IAutomationObject,
															  useName:Boolean):String
		{ 
			var result:Array = [];
			var item:IListItemRenderer = delegate as IListItemRenderer;
			
			if (item == grid.itemEditorInstance)
				item = grid.editedItemRenderer;
			
			var row:int = grid.itemRendererToIndex(item);
			if ((row == int.MIN_VALUE)|| (row < 0 ))
				return null; 
			
			// get the complete information from the tabular date
			
			var tempTabData:AdvancedDataGridTabularData = new  AdvancedDataGridTabularData(grid);
			result = tempTabData.getValues(row,row);
			result = result[0];
			
			// get the selected cell Index among the visible cell index
			var selectedCellPos:Number = 0;
			
			row = row < grid.lockedRowCount ?
				row :
				row - grid.verticalScrollPosition;            
			
			
			
			var listItems:Array = grid.rendererArray;
			var selectedCellFound:Boolean = false;
			
			for (var col:int = 0; col < listItems[row].length; col++)
			{
				var i:IListItemRenderer = listItems[row][col];
				if (i == item)
				{
					selectedCellFound = true;
					break;
				}
				
			}
			
			if (selectedCellFound)
				selectedCellPos = col + grid.horizontalScrollPosition;
			
			//change the sring at the selected cellposition
			var tempString:String = result[selectedCellPos];
			tempString = "*" + tempString + "*";
			result[selectedCellPos]= tempString;
			
			
			return result.join(" | ");
			
			
		}
		
		
		
		/**
		 *  @private
		 */
		override public function replayAutomatableEvent(interaction:Event):Boolean
		{
			var help:IAutomationObjectHelper = Automation.automationObjectHelper;
			var mouseEvent:MouseEvent;
			switch (interaction.type)
			{
				case "headerShift":
				{
					
					if (interaction is IndexChangedEvent)
					{
						var icEvent:IndexChangedEvent = IndexChangedEvent(interaction);
						grid.shiftColumns(icEvent.oldIndex, icEvent.newIndex);
					}
					else if (interaction is AdvancedDataGridHeaderShiftEvent)
					{
						
						
						var event:AdvancedDataGridHeaderShiftEvent = AdvancedDataGridHeaderShiftEvent(interaction);
						grid.movingColumnIndex = event.movingColumnIndex;
						
						grid.shiftColumns(event.oldColumnIndex, event.newColumnIndex);
						
					}
					
					return true; 
				}
					
				case AdvancedDataGridItemSelectEvent.HEADER_RELEASE :
				{ 
					var adgAutomationEvent:AdvancedDataGridItemSelectEvent = interaction as AdvancedDataGridItemSelectEvent;
					if (adgAutomationEvent.columnIndex >= 0)
					{    
						// check whether we got this event from keyboard or mouse
						// if it is from the keyboard, we need to create a new keyboard event
						// and replay as the handling of the keyoard and mouse events are different on ADG.
						if (adgAutomationEvent.triggerEvent as KeyboardEvent)
						{
							var newKeyBoardEvent:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN);
							newKeyBoardEvent.keyCode = Keyboard.SPACE;
							if (adgAutomationEvent.ctrlKey || adgAutomationEvent.shiftKey)
							{
								newKeyBoardEvent.ctrlKey = adgAutomationEvent.ctrlKey;
								newKeyBoardEvent.shiftKey = adgAutomationEvent.shiftKey;
								newKeyBoardEvent.keyCode = Keyboard.SPACE;
							}
							help.replayKeyboardEvent(grid,newKeyBoardEvent);
						}
						else
						{       
							var de:AdvancedDataGridEvent = new AdvancedDataGridEvent(AdvancedDataGridEvent.HEADER_RELEASE);
							de.itemRenderer = adgAutomationEvent.itemRenderer;
							de.columnIndex = adgAutomationEvent.columnIndex;
							de.dataField=adgAutomationEvent.dataField;
							de.headerPart=adgAutomationEvent.headerPart;
							
							// create a new mouse event with the flexcontrol set
							var newMouseEvent:MouseEvent = new MouseEvent("click");
							if (adgAutomationEvent.ctrlKey || adgAutomationEvent.shiftKey)
							{
								newMouseEvent.ctrlKey = adgAutomationEvent.ctrlKey;
								newMouseEvent.shiftKey = adgAutomationEvent.shiftKey;
							}
							de.triggerEvent= newMouseEvent;
							uiComponent.dispatchEvent(de);
						}
						
					}
					return true ;
				}
				case AdvancedDataGridEvent.COLUMN_STRETCH:
				{
					// get the locked and unlocked separator
					var nonLockedSeparators:Array = grid.getSeparators() as Array;
					var lockedSeparators:Array =grid.getLockedSeparators() as Array;
					
					// we need to combine these two  arrays
					// however we have an extra separator in the combined one, which is
					// due to the boundary separation of these.
					// hence one needs to be removed.
					var combinedSeparators:Array = new Array();
					combinedSeparators = combinedSeparators.concat(lockedSeparators);
					if (combinedSeparators.length != 0)
						combinedSeparators.splice(combinedSeparators.length-1, 1);
					// remove the last elemenet
					
					// add the non locked separators
					combinedSeparators = combinedSeparators.concat(nonLockedSeparators);
					
					var s:IFlexDisplayObject = combinedSeparators[AdvancedDataGridEvent(interaction).columnIndex];
					s.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
					// localX needs to be passed in the constructor
					// to get stageX value computed.
					mouseEvent = new MouseEvent(MouseEvent.MOUSE_UP, 
						true, // bubble 
						false, // cancellable 
						AdvancedDataGridEvent(interaction).localX, 
						20, // dummy value 
						uiComponent as InteractiveObject );
					return help.replayMouseEvent(uiComponent, mouseEvent);
				}
					
				case AdvancedDataGridEvent.ITEM_EDIT_BEGIN:
				{
					var adgEvent:AdvancedDataGridEvent = new AdvancedDataGridEvent(AdvancedDataGridEvent.ITEM_EDIT_BEGINNING);
					var input:AdvancedDataGridEvent = interaction as AdvancedDataGridEvent;
					adgEvent.itemRenderer = input.itemRenderer;
					adgEvent.rowIndex = input.rowIndex;
					adgEvent.columnIndex = input.columnIndex;
					uiComponent.dispatchEvent(adgEvent);
				}
					
				case ListItemSelectEvent.DESELECT:
				case ListItemSelectEvent.MULTI_SELECT:
				case ListItemSelectEvent.SELECT:
				default:
				{
					return super.replayAutomatableEvent(interaction);
				}
			}
		}
		
		
		
		
		/**
		 * @private
		 */
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			return;
		}
		/**
		 *  @private
		 */
		protected function keyDownHandler1(event:KeyboardEvent):void
		{
			if (grid.itemEditorInstance || event.target != event.currentTarget)
				return;
			
			
			if (event.keyCode == Keyboard.SPACE) 
			{
				var listItems:Array = grid.rendererArray;
				var caretIndex:int = grid.getCaretIndex();
				if (caretIndex >= 0)
				{
					//var selectedCellColumnIndex:int = (grid.selectedCells[0]).columnIndex;
					
					//if( selectedCellColumnIndex < 0)
					//{
					//  selectedCellColumnIndex = 0;
					//}
					//var rendererIndex:int = caretIndex - listBase.verticalScrollPosition 
					//                      + listBase.lockedRowCount;
					//var item:IListItemRenderer = listItems[rendererIndex][selectedCellColumnIndex] as IListItemRenderer;
					//recordListItemSelectEvent(item, event);
					recordAutomatableEvent(event);
				}
				else
				{
					var column:AdvancedDataGridColumn = (grid.columns)[grid.headerIndex];
					if (column)
					{
						var dataFieldStrig:String = column.dataField;
						recordADGHeaderClickEvent(grid.headerIndex,dataFieldStrig,event,true);
					}
					else
					{
						// this case would have been user pressing the ctrl space
						recordAutomatableEvent(event);
					}
				}
				
				
			}
			else if (event.keyCode != Keyboard.SPACE &&
				event.keyCode != Keyboard.CONTROL &&
				event.keyCode != Keyboard.SHIFT &&
				event.keyCode != Keyboard.TAB)
				recordAutomatableEvent(event);
		}
		
		
		/**
		 *  @private
		 */
		private function columnStretchHandler(event:AdvancedDataGridEvent):void 
		{
			recordAutomatableEvent(event);
		} 
		
		/**
		 *  @private
		 */
		private function headerReleaseHandler(event:AdvancedDataGridEvent):void 
		{
			recordADGHeaderReleaseEvent(event);
		}
		
		/**
		 *  @private
		 */
		private function headerShiftHandler(event:IndexChangedEvent):void 
		{
			if (event.triggerEvent) 
			{ 
				if ((event.target as AdvancedDataGrid).columnGrouping)
				{
					// we need the movingcolumnIndex and the new and old index if the ADG
					// is with colum grouping
					var movingcolumnIndex:int = (event.target as AdvancedDataGrid).movingColumnIndex;
					
					// so created the special Automation event for the column grouping
					var autmationHeaderShiftEvent:AdvancedDataGridHeaderShiftEvent = new AdvancedDataGridHeaderShiftEvent(
						event.type,movingcolumnIndex,event.oldIndex,event.newIndex,event.bubbles,event.cancelable,event.triggerEvent);
					
					// recrod the special automation event  
					recordAutomatableEvent(autmationHeaderShiftEvent);  
				}
				else
				{
					// i.e current ADG does not use the column grouping
					recordAutomatableEvent(event);
				}
			}
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
		override protected function dragDropHandler(event:DragEvent):void
		{
			if (dragScrollEvent)
			{
				recordAutomatableEvent(dragScrollEvent);
				dragScrollEvent=null;
			}
			
			var am:IAutomationManager = Automation.automationManager;
			var index:int = grid.calculateDropIndex(event);
			var drag:AutomationDragEvent = new AutomationDragEvent(event.type);
			drag.action = event.action;
			
			if (grid.dataProvider && index != grid.dataProvider.length)
			{
				
				if (index >= grid.lockedRowCount)
					index -= grid.verticalScrollPosition;
				
				var rc:Number = grid.rendererArray.length;
				if (index >= rc)
					index = rc - 1;
				
				if (index < 0)
					index = 0;
				
				if (grid.rendererArray && grid.rendererArray[0] && grid.rendererArray[0].length)
					index = index * grid.rendererArray[0].length;
				
				drag.draggedItem = getAutomationChildAt(index);
			}
			
			preventDragDropRecording = false;
			am.recordAutomatableEvent(uiAutomationObject, drag);
			preventDragDropRecording = true;
		}
		
		/**
		 *  @private
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
		protected function recordADGHeaderReleaseEvent( adgEvent:AdvancedDataGridEvent, 
														cacheable:Boolean=true):void
		{
			var keyEvent:KeyboardEvent = adgEvent.triggerEvent as KeyboardEvent;
			var mouseEvent:MouseEvent = adgEvent.triggerEvent as MouseEvent;
			
			var event:AdvancedDataGridItemSelectEvent = new AdvancedDataGridItemSelectEvent(adgEvent.type);
			
			event.itemRenderer = adgEvent.itemRenderer;
			
			event.triggerEvent = adgEvent.triggerEvent;
			event.columnIndex = adgEvent.columnIndex;
			event.dataField = adgEvent.dataField;
			event.headerPart = adgEvent.headerPart;
			if (!adgEvent.dataField)
			{
				event.dataField ="groupHeader"; 
			}
			if (keyEvent)
			{
				event.ctrlKey = keyEvent.ctrlKey;
				event.shiftKey = keyEvent.shiftKey;
				event.altKey = keyEvent.altKey;
				recordAutomatableEvent(event, cacheable);
			}
			else if (mouseEvent)
			{
				event.ctrlKey = mouseEvent.ctrlKey;
				event.shiftKey = mouseEvent.shiftKey;
				event.altKey = mouseEvent.altKey;
				recordAutomatableEvent(event, cacheable);
			}
			else
			{
				recordAutomatableEvent(event);
			}
			
		}
		
		
		
		/**
		 * @private
		 */
		protected function recordADGHeaderClickEvent( columnIndex:Number,dataFieldStrig:String,adgEvent:KeyboardEvent, 
													  cacheable:Boolean=true):void
		{
			
			var keyEvent:KeyboardEvent = adgEvent as KeyboardEvent;
			
			var event:AdvancedDataGridItemSelectEvent = new AdvancedDataGridItemSelectEvent("headerRelease");
			event.triggerEvent = adgEvent;
			event.columnIndex = columnIndex;
			event.dataField = dataFieldStrig;
			if (keyEvent)
			{ 
				event.ctrlKey = keyEvent.ctrlKey;
				event.shiftKey = keyEvent.shiftKey;
				event.altKey = keyEvent.altKey;
				recordAutomatableEvent(event, cacheable);
			}
			else
			{
				recordAutomatableEvent(event);
			}
			
		}
		
		
		
		
	}
}
