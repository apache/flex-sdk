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
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	
	import mx.automation.Automation;
	import mx.automation.AutomationIDPart;
	import mx.automation.IAutomationObject;
	import mx.automation.IAutomationObjectHelper;
	import mx.automation.IAutomationTabularData;
	import mx.core.IVisualElement;
	import mx.core.mx_internal;
	import mx.utils.StringUtil;
	
	import spark.automation.delegates.components.supportClasses.SparkSkinnableContainerBaseAutomationImpl;
	import spark.automation.events.SparkDataGridItemSelectEvent;
	import spark.automation.tabularData.SparkDataGridTabularData;
	import spark.components.DataGrid;
	import spark.components.gridClasses.IGridItemRenderer;
	import spark.events.GridEvent;
	
	use namespace mx_internal;
	
	[Mixin]
	/**
	 * 
	 *  Defines methods and properties required to perform instrumentation for the 
	 *  DataGrid class.
	 * 
	 *  @see spark.components.DataGrid 
	 *
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.5
	 *  @productversion Flex 4.5
	 */
	public class SparkDataGridAutomationImpl extends SparkSkinnableContainerBaseAutomationImpl
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
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		public static function init(root:DisplayObject):void
		{
			Automation.registerDelegateClass(spark.components.DataGrid, SparkDataGridAutomationImpl);
		}
		
		//--------------------------------------------------------------------------
		// 
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/** 
		 *  Constructor.
		 *  @param obj DataGrid object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		
		public function SparkDataGridAutomationImpl(obj:spark.components.DataGrid)
		{
			super(obj);
			obj.addEventListener(Event.ADDED, childAddedHandler, false, 0, true);
			obj.addEventListener(GridEvent.GRID_DOUBLE_CLICK, recordAutomatableEvent, false, 0 , true);
			obj.addEventListener(GridEvent.SEPARATOR_MOUSE_UP, columnStretchHandler, false, 0, true);
			obj.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
			obj.addEventListener(FocusEvent.KEY_FOCUS_CHANGE,keyFocusChangeHandler, false, 1000, true);
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		protected var shiftKeyDown:Boolean = false;
		
		/**
		 *  @private
		 */
		protected var ctrlKeyDown:Boolean = false;      
		
		/**
		 * @private
		 */
		mx_internal var itemAutomationNameFunction:Function = getItemAutomationValue;
		
		private var itemUnderMouse:IGridItemRenderer;
		
		
		//--------------------------------------------------------------------------
		//
		//      Properties
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 *  storage for the owner component
		 */
		protected function get grid():spark.components.DataGrid
		{
			return uiComponent as spark.components.DataGrid;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//      Overridden Properties
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  A matrix of the automationValues of each item in the grid. The return value
		 *  is an array of rows, each of which is an array of item renderers (row-major).
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */
		override public function get automationTabularData():Object
		{
			return  new SparkDataGridTabularData(grid);
		}
		
		
		/**
		 *  @private
		 */
		override public function get numAutomationChildren():int
		{
			var listItems:Array = getCompleteRenderersArray();
			if (listItems.length == 0)
				return 0;
			
			var result:int = listItems.length * grid.columns.length;
			return result;
		}      
		
		override protected function componentInitialized():void
		{
			super.componentInitialized();
			updateItemRenderers();
			grid.grid.addEventListener(GridEvent.GRID_MOUSE_UP, gridMouseUpHandler, false, 1001, true);
			grid.columnHeaderGroup.addEventListener(GridEvent.GRID_CLICK, gridClickHandler, false, 0 , true);
		}
		
		//--------------------------------------------------------------------------
		//
		//      Methods
		//
		//--------------------------------------------------------------------------
		
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
		 * @private
		 */
		protected function updateItemRenderers():void
		{
			var items:Array = getCompleteRenderersArray();
			if (items.length == 0)
				return ;
			
			var rows:uint = items.length;
			var cols:uint = grid.columns.length;
			
			for (var i:int = 0; i < rows; ++i)
			{
				for (var j:int = 0; j < cols; ++j)
				{
					var item:IGridItemRenderer = items[i][j];
					if (item)
					{   
						item.owner = grid;
					}
				}   
			}
		}
		
		/**
		 * @private
		 */
		protected function recordDGItemSelectEvent(item:IGridItemRenderer,
												   trigger:Event, 
												   cacheable:Boolean=false):void
		{
			var selectionType:String = SparkDataGridItemSelectEvent.SELECT;
			var keyEvent:KeyboardEvent = trigger as KeyboardEvent;
			var mouseEvent:MouseEvent = trigger as MouseEvent;
			
			var indexSelection:Boolean = false;
			
			if (!Automation.automationManager || !Automation.automationManager.automationEnvironment 
				|| !Automation.automationManager.recording)
				return ;
			
			var event:SparkDataGridItemSelectEvent = new SparkDataGridItemSelectEvent(selectionType);
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
		 * @private
		 */
		protected function recordDGHeaderClickEvent(item:IGridItemRenderer,
													trigger:Event, 
													cacheable:Boolean=false):void
		{
			//recordAutomatableEvent(event, cacheable);
		}
		
		/**
		 * @private
		 * Plays back MouseEvent.CLICK on the item renderer.
		 */
		protected function replayMouseClickOnItem(item:IGridItemRenderer,
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
		
		/**
		 * @private
		 * Plays back MouseEvent.DOUBLE_CLICK on the item renderer.
		 */
		protected function replayMouseDoubleClickOnItem(item:IGridItemRenderer):Boolean
		{
			var me:MouseEvent = new MouseEvent(MouseEvent.DOUBLE_CLICK);
			var help:IAutomationObjectHelper = Automation.automationObjectHelper;
			return help.replayMouseEvent(item, me);
		}       
		
		/**
		 *  @private
		 */
		protected function getItemRendererForEvent(lise:SparkDataGridItemSelectEvent):IGridItemRenderer
		{
			var rowIndex:int = lise.itemIndex;
			//rowIndex = rowIndex < grid.lockedRowCount ? rowIndex : rowIndex - grid.verticalScrollPosition;
			
			return grid.grid.getItemRendererAt(rowIndex, 0) as IGridItemRenderer;
		}
		
		/**
		 *  @private
		 */
		protected function fillItemRendererIndex(item:IGridItemRenderer, event:SparkDataGridItemSelectEvent):void
		{
			var listItems:Array = getCompleteRenderersArray();
			
			var startRow:int = 0;
			//This portion is commented out as now the rowHeaders are separated
			/*
			if(grid.headerVisible)
			++startRow;
			*/
			
			var n:int = listItems.length;
			for (var i:int = startRow; i < n; i++)
			{
				var n1:int = listItems[i].length;
				for (var j:int = 0; j < n1; j++)
				{   
					if (listItems[i][j] == item)
					{
						event.itemIndex = i + grid.grid.verticalScrollPosition - 1;
					}
				}
			}
		}   
		
		/**
		 *  @private
		 */
		public function getVisibleRenderersArray():Array
		{
			const visibleRowIndices:Vector.<int> = grid.grid.getVisibleRowIndices();
			const visibleColumnIndices:Vector.<int> = grid.grid.getVisibleColumnIndices();
			const renderers:Array = new Array(visibleRowIndices.length);
			
			for each (var rowIndex:int in visibleRowIndices)
			{
				renderers[rowIndex] = new Array(visibleColumnIndices.length);
				for each (var columnIndex:int in visibleColumnIndices)
				renderers[rowIndex][columnIndex] = grid.grid.getItemRendererAt(rowIndex, columnIndex);
			}
			
			return renderers;               
		}
		
		/**
		 *  @private
		 */
		public function getCompleteRenderersArray():Array
		{
			var rowCount:int = 0;
			if(grid.dataProvider)
				rowCount = grid.dataProvider.length;
			var columnCount:int = 0;
			if(grid.columns)
				columnCount = grid.columns.length;
			const renderers:Array = new Array(rowCount+1);
			renderers[0] = new Array(columnCount);
			
			for (var col:int = 0; col < columnCount; col++)
			{
				renderers[0][col] = grid.columnHeaderGroup.getHeaderRendererAt(col);
			}
			for (var rowIndex:int = 0; rowIndex < rowCount; rowIndex++)
			{
				renderers[rowIndex+1] = new Array(columnCount);
				for (var columnIndex:int = 0; columnIndex < columnCount; columnIndex++)
					renderers[rowIndex+1][columnIndex] = grid.grid.getItemRendererAt(rowIndex, columnIndex);
			}
			
			return renderers;
			
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
		protected function findItemRenderer(selectEvent:SparkDataGridItemSelectEvent):Boolean
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
				var i:int;
				for (i = 0; i < n; i++)
				{
					var lString:String = labels[i];
					if (lString.charAt(0) == "*" && lString.charAt(lString.length-1) == "*")
						labels[i] = lString.substr(1, lString.length-2);
				}
				for (i = 0; i < length; i++)
				{
					if(compare(labels, values[i]))
					{
						grid.ensureCellIsVisible(i);
						var ao:IAutomationObject = Automation.automationManager.resolveIDPartToSingleObject(uiAutomationObject, part);
						
						if (ao)
						{
							selectEvent.itemRenderer = ao as IGridItemRenderer;
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
		public function getItemAutomationValue(item:IAutomationObject):String
		{
			return getItemAutomationNameOrValueHelper(item, false);
		}
		
		/**
		 *  @private
		 */
		public function getItemAutomationName(item:IAutomationObject):String
		{
			return getItemAutomationNameOrValueHelper(item, true);
		}
		
		/**
		 * @private
		 */
		public function getItemAutomationIndex(delegate:IAutomationObject):String
		{
			var item:Object = delegate;
			if (item == grid.itemEditorInstance && grid.editor && 
				(grid.editor.editorRowIndex >= 0) && (grid.editor.editorColumnIndex >= 0))
				item = grid.editor.editedItemRenderer;
			var row:int = item.rowIndex;
			if(row >= 0 && item.column)
			{
				return (item.column.dataField + ":" + row);
			}
			return getItemAutomationName(delegate);
		}
		
		
		/**
		 *  @private
		 */
		private function getItemAutomationNameOrValueHelper(delegate:IAutomationObject,
															useName:Boolean):String
		{
			var result:Array = [];
			var item:Object = delegate;
			
			if (item == grid.itemEditorInstance)
				item = grid.editor.editedItemRenderer;
			
			var row:int = item.rowIndex;
			var isHeader:Boolean = false;
			
			if (row == int.MIN_VALUE)
			{
				// return null;  -- this is commented after the header related 
				// changes in DG.
				
				// now for the headers also , it cmes as min_value
				// so we cannot make out header or invalid renderer
				//isHeader = grid.headerVisible;
			}
			
			
			/*row = row < grid.lockedRowCount ?
			row :
			row - grid.verticalScrollPosition; */           
			
			if (row >= 0)
			{
				row = row + 1;
			}
			else
			{
				row = 0;
			}
			
			var listItems:Array = getCompleteRenderersArray();
			//var listItems:Array = grid.rendererArray; .. changed as above to take care of the
			// locked row and locked column changed handling of DG
			
			// this varaible is added, since we are proceeding
			// even if the itemRendererToIndex is returning  int.MIN_VALUE
			// we are assuming that the user clicked the header in this case
			// But we need to find whether this is valid
			// this is found by checking whether we get the clicked item
			// in one of the column header renderer
			var validItemRendererFound:Boolean = false;
			var tabData:IAutomationTabularData = automationTabularData as IAutomationTabularData;
			var firstVisibleRowIndex:int = tabData.firstVisibleRow;
			
			for (var col:int = 0; col < listItems[row].length; col++)
			{
				var i:IVisualElement = listItems[row][col];
				if(i != null)   //can be null if column is not visible
				{
					if(i == grid.editor.editedItemRenderer)
						i = grid.itemEditorInstance;
					var itemDelegate:IAutomationObject = i as IAutomationObject;
					var s:String = (useName
						? itemDelegate.automationName
						: itemDelegate.automationValue.join(" | "));
					if ( i == item )
					{
						// we got a valid item renderer
						s= "*" + s + "*";
						validItemRendererFound= true;
					}               
					result.push(s);
				}
			}
			
			if(isHeader && (validItemRendererFound==false))
			{
				// we got the itemRendererToIndex(item) as int.MIN_VALUE
				// so we considered it as a header row
				// but no element on the header row match with the
				// current item renderer. Hence returning null
				return null;
			}
			return (isHeader
				? "[" + result.join("] | [") + "]"
				: result.join(" | "));
		}       
		
		/**
		 * private
		 */     
		protected function addScrollers(chilArray:Array):Array
		{
			
			var count:int = grid.numChildren;
			for (var i:int=0; i<count; i++)
			{
				var obj:Object = grid.getChildAt(i);
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
			
			
			var scrollBars:Array = getScrollBars(grid,null);
			var n:int = scrollBars? scrollBars.length : 0;
			
			for ( i=0; i<n ; i++)
			{
				chilArray.push(scrollBars[i]);
			}
			return chilArray;
		}
		
		//--------------------------------------------------------------------------------
		//
		//      Overridden Methods
		//
		//--------------------------------------------------------------------------------          
		
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
		 *  @private
		 */
		override public function replayAutomatableEvent(interaction:Event):Boolean
		{
			var help:IAutomationObjectHelper = Automation.automationObjectHelper;
			var mouseEvent:MouseEvent;
			switch (interaction.type)
			{
				case GridEvent.GRID_CLICK:
				{
					var colIndex:int = GridEvent(interaction).columnIndex;
					var rect:Rectangle = grid.columnHeaderGroup.getHeaderBounds(colIndex);
					MouseEvent(interaction).localX = rect.left + rect.width/2;
					MouseEvent(interaction).localY = rect.top + rect.height/2;
					return help.replayClick(grid.columnHeaderGroup, MouseEvent(interaction));
				}
				case GridEvent.GRID_DOUBLE_CLICK:
				{
					var clickEvent:GridEvent = GridEvent(interaction);
					return replayMouseDoubleClickOnItem(grid.grid.getItemRendererAt(clickEvent.rowIndex, clickEvent.columnIndex) as IGridItemRenderer);
				}    
				case KeyboardEvent.KEY_DOWN:
				{
					grid.setFocus();
					return help.replayKeyDownKeyUp(uiComponent, KeyboardEvent(interaction).keyCode, KeyboardEvent(interaction).ctrlKey, KeyboardEvent(interaction).shiftKey, KeyboardEvent(interaction).altKey);
				}
				case SparkDataGridItemSelectEvent.SELECT_INDEX:
				case SparkDataGridItemSelectEvent.SELECT:
				{
					var completeTime:Number = getTimer() + grid.getStyle("selectionDuration");
					
					help.addSynchronization(function():Boolean
					{
						return getTimer() >= completeTime;
					});
					
					var lise:SparkDataGridItemSelectEvent = SparkDataGridItemSelectEvent(interaction);
					
					if (interaction.type == SparkDataGridItemSelectEvent.SELECT_INDEX)
					{
						/*grid.grid.scrollToIndex(lise.itemIndex);
						lise.itemRenderer = getItemRendererForEvent(lise);*/
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
				case "editNext":
				{
					if(grid.itemEditorInstance)
					{
						var focusEvent:FocusEvent = new FocusEvent(FocusEvent.KEY_FOCUS_CHANGE);
						focusEvent.keyCode = Keyboard.TAB;
						grid.itemEditorInstance.dispatchEvent(focusEvent);
						grid.startItemEditorSession(grid.grid.caretRowIndex, grid.grid.caretColumnIndex);
						return true;
					}
					return false;
				}
					/*case "headerShift":
					{
					var icEvent:IndexChangedEvent = IndexChangedEvent(interaction);
					grid.shiftColumns(icEvent.oldIndex, icEvent.newIndex);
					return true;
					}
					
					case DataGridEvent.HEADER_RELEASE:
					{
					var listItems:Array = getCompleteRenderersArray();
					//var listItems:Array = grid.rendererArray; .. changed as above to take care of the
					// locked row and locked column changed handling of DG
					
					var c:IListItemRenderer = listItems[0][DataGridEvent(interaction).columnIndex];
					return help.replayClick(c);
					}*/
					
				case GridEvent.SEPARATOR_MOUSE_UP:
				{
					var s:IGridItemRenderer = grid.columnHeaderGroup.getHeaderRendererAt(GridEvent(interaction).columnIndex);
					
					//s.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, 0, 0));
					// localX needs to be passed in the constructor
					// to get stageX value computed.
					mouseEvent = new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, s.width, 10);
					help.replayMouseEvent(s, mouseEvent);
					
					
					mouseEvent = new MouseEvent(MouseEvent.MOUSE_MOVE, true, false, GridEvent(interaction).localX, 10);
					help.replayMouseEvent(grid, mouseEvent);
					
					mouseEvent = new MouseEvent(MouseEvent.MOUSE_UP,
						true, // bubble 
						false, // cancellable 
						GridEvent(interaction).localX, 
						10 // dummy value
					);
					help.replayMouseEvent(grid, mouseEvent);
					
					mouseEvent = new MouseEvent(MouseEvent.CLICK,
						true, // bubble 
						false, // cancellable 
						GridEvent(interaction).localX, 
						10 // dummy value
					);
					return help.replayMouseEvent(grid, mouseEvent);
					
				}
					
					/*case DataGridEvent.ITEM_EDIT_BEGIN:
					{
					var de:DataGridEvent = new DataGridEvent(DataGridEvent.ITEM_EDIT_BEGINNING);
					var input:DataGridEvent = interaction as DataGridEvent;
					de.itemRenderer = input.itemRenderer;
					de.rowIndex = input.rowIndex;
					de.columnIndex = input.columnIndex;
					uiComponent.dispatchEvent(de);
					}*/
				default:
				{
					return super.replayAutomatableEvent(interaction);
				}
			}
		}
		
		/**
		 * @private
		 */
		override public function getAutomationChildAt(index:int):IAutomationObject
		{
			var listItems:Array = getCompleteRenderersArray();
			//var listItems:Array = grid.rendererArray; .. changed as above to take care of the
			// locked row and locked column changed handling of DG
			
			var numCols:int = grid.columns.length;
			var row:uint = uint(numCols == 0 ? 0 : index / numCols);
			var col:uint = uint(numCols == 0 ? index : index % numCols);
			var item:IGridItemRenderer = listItems[row][col];
			
			if (grid.itemEditorInstance && grid.editor && 
				(grid.editor.editorRowIndex >= 0) && (grid.editor.editorColumnIndex >= 0) &&
				item == grid.editor.editedItemRenderer)
			{
				return grid.itemEditorInstance as IAutomationObject;
			}
			
			return  item as IAutomationObject;
		}
		
		/**
		 * @private
		 */
		override public function getAutomationChildren():Array
		{
			var childrenList:Array = new Array();
			var listItems:Array = getCompleteRenderersArray();
			
			// we get this as the 2 dim array of row and columns
			// we need to make this as single element array
			//while (!listItems[row][col] 
			var rowcount:int  = listItems?listItems.length:0;
			if (rowcount != 0)
			{
				var colCount:int = grid.columns.length;
				/*if ((listItems[0]) is Array)
				coulumcount = (listItems[0] as Array).length;*/
				
				for (var i:int = 0; i < rowcount ; i++)
				{
					for (var j:int = 0; j < colCount ; j++)
					{
						var item:IGridItemRenderer = listItems[i][j];
						if (item)
						{
							if (grid.itemEditorInstance && grid.editor && 
								(grid.editor.editorRowIndex >= 0) && (grid.editor.editorColumnIndex >= 0) &&
								item == grid.editor.editedItemRenderer)
								
								childrenList.push(grid.itemEditorInstance as IAutomationObject);
							else
								childrenList.push(item as IAutomationObject);
						}
					}
				}
			}
			childrenList = addScrollers(childrenList);
			return  childrenList;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		private function keyFocusChangeHandler(event:FocusEvent):void
		{
			if(grid.itemEditorInstance)
			{
				recordAutomatableEvent(new Event("editNext"));
			}
		}
		
		/**
		 *  @private
		 */
		protected function gridClickHandler(event:GridEvent):void
		{
			if (!Automation.automationManager || !Automation.automationManager.automationEnvironment 
				|| !Automation.automationManager.recording)
				return;
			
			var item:IGridItemRenderer = grid.columnHeaderGroup.getHeaderRendererAt(event.columnIndex);
			recordAutomatableEvent(event, true);
		}
		
		/**
		 *  @private
		 */
		protected function gridMouseUpHandler(event:GridEvent):void
		{
			if (!Automation.automationManager || !Automation.automationManager.automationEnvironment 
				|| !Automation.automationManager.recording)
				return;
			var gbPt:Point = event.target.localToGlobal(new Point(event.localX, event.localY));
			var locPt:Point = grid.grid.globalToLocal(gbPt);
			
			var item:IGridItemRenderer = grid.grid.getItemRendererAt(grid.grid.getRowIndexAt(locPt.x, locPt.y),
				grid.grid.getColumnIndexAt(locPt.x, locPt.y)) as IGridItemRenderer;
			if (item && item == itemUnderMouse)
			{
				// take the key modifiers from the mouseDown event because
				// they were used by List for making the selection
				if(event.itemRenderer != item || (grid.editor && item == grid.editor.editedItemRenderer))
					return;
				else
				{
					event.ctrlKey = ctrlKeyDown;
					event.shiftKey = shiftKeyDown;
					recordDGItemSelectEvent(item, event);
				}
			}
			
		}
		/**
		 *  @private
		 */
		public function childAddedHandler(event:Event):void
		{
			var child:Object = event.target;
			
			if (child is IGridItemRenderer && child.parent == grid.grid)
			{
				IGridItemRenderer(child).owner = grid;
			}
		}
		
		/**
		 *  @private
		 */
		protected function mouseDownHandler(event:MouseEvent):void
		{
			ctrlKeyDown = event.ctrlKey;
			shiftKeyDown = event.shiftKey;
			var gbPt:Point = event.target.localToGlobal(new Point(event.localX, event.localY));
			var locPt:Point = grid.grid.globalToLocal(gbPt);
			
			itemUnderMouse = grid.grid.getItemRendererAt(grid.grid.getRowIndexAt(locPt.x, locPt.y),
				grid.grid.getColumnIndexAt(locPt.x, locPt.y)) as IGridItemRenderer;
		}
		
		/**
		 *  @private
		 */
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			if (//grid.itemEditorInstance || 
				event.target != event.currentTarget)
				return;
			
			if (event.keyCode == Keyboard.SPACE)
			{
				var caretRowIndex:int = grid.grid.caretRowIndex;
				if (caretRowIndex != -1)
				{
					var caretColumnIndex:int = grid.grid.caretColumnIndex;
					if(caretColumnIndex == -1)
						caretColumnIndex = 0;
					var item:IGridItemRenderer = grid.grid.getItemRendererAt(caretRowIndex,caretColumnIndex) as IGridItemRenderer;
					recordDGItemSelectEvent(item, event);
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
		private function columnStretchHandler(event:GridEvent):void 
		{
			recordAutomatableEvent(event);
		}
		
		/**
		 *  @private
		 */
		/*private function headerReleaseHandler(event:DataGridEvent):void 
		{
		recordAutomatableEvent(event);
		}*/
		
		/**
		 *  @private
		 */
		/*private function headerShiftHandler(event:IndexChangedEvent):void 
		{
		if (event.triggerEvent)
		recordAutomatableEvent(event);
		}*/
		
		/**
		 *  @private
		 */
		/*private function itemEditHandler(event:DataGridEvent):void
		{
		recordAutomatableEvent(event, true);    
		}*/
		
		/**
		 *  @private
		 */
		/*protected function dragDropHandler(event:DragEvent):void
		{
		if(dragScrollEvent)
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
		//increment the index if headers are being shown
		if(grid.headerVisible)
		++index;
		
		if (index >= grid.lockedRowCount)
		index -= grid.verticalScrollPosition;
		
		var completeListitems:Array = getCompleteRenderersArray();
		
		//var rc:Number = grid.rendererArray.length;
		var rc:Number = completeListitems.length;
		
		if (index >= rc)
		index = rc - 1;
		
		if (index < 0)
		index = 0;
		
		//if(grid.rendererArray && grid.rendererArray[0] && grid.rendererArray[0].length)
		//index = index * grid.rendererArray[0].length;
		
		if(completeListitems && completeListitems[0] && completeListitems[0].length)
		index = index * completeListitems[0].length;
		
		drag.draggedItem = getAutomationChildAt(index);
		}
		
		preventDragDropRecording = false;
		am.recordAutomatableEvent(uiAutomationObject, drag);
		preventDragDropRecording = true;
		}*/
	}
}
