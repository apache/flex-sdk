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
	import flash.events.MouseEvent;
	import mx.automation.Automation;
	import mx.automation.IAutomationObject;
	import mx.automation.tabularData.OLAPDataGridTabularData;
	
	
	import mx.controls.AdvancedDataGrid;
	import mx.controls.OLAPDataGrid;
	import mx.olap.IOLAPAxisPosition;
	import mx.olap.IOLAPResult;
	import mx.olap.IOLAPResultAxis;
	import mx.olap.OLAPQuery;
	
	import mx.controls.listClasses.IListItemRenderer;
	import mx.core.mx_internal;
	use namespace mx_internal;   
	
	
	// take the class place it in a Mixin array and the System manger calls init on this class.
	[Mixin] 
	/**
	 * 
	 *  Defines methods and properties required to perform instrumentation for the 
	 *  OLAPDataGrid control.
	 * 
	 *  @see mx.controls.OLAPDataGrid 
	 *
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class  OLAPDataGridAutomationImpl extends AdvancedDataGridAutomationImpl  
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
			Automation.registerDelegateClass(OLAPDataGrid, OLAPDataGridAutomationImpl);
		}  
		
		/** 
		 *  Constructor.
		 *
		 * @param obj OLAPDataGrid object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */              
		public function OLAPDataGridAutomationImpl(obj:OLAPDataGrid) 
		{
			super(obj);
		}
		
		/**
		 *  @private
		 *  get methods for internal use and the mouse Down Handler 
		 */
		protected   function get odg():OLAPDataGrid
		{
			return uiComponent as OLAPDataGrid;
		}
		
		
		/*  this method is overwritten for the following reason 
		In DG and ADG, we used to record the basic mouse click event
		when there is no item renderer at the click position
		in ODG, we get valid item renderer when the user clicks on the
		column Headers. But this does not result in a selection
		Hence we want to record click in this case too. */
		/**
		 * @private
		 */
		override protected function mouseClickHandler(event:MouseEvent):void
		{
			var item:IListItemRenderer = odg.getItemRendererForMouseEvent(event);
			
			if (!item) 
			{
				//DataGrid overrides displayObjectToItemRenderer to return
				//null if the item is the active item editor, so that's
				//not a reliable way of determining if the user clicked on a blank
				//row or now, so use mouseEventToItemRendererOrEditor instead
				if (odg.mouseEventToItemRendererOrEditor(event) == null)
					recordAutomatableEvent(event, true);
				
				return;
			}
			else 
			{
				
				// in case of ODG we get a valid item renderer when the user
				// clicks on the column headers. In this case, we are not
				// recording the select event, as no selection happens.
				// hence check whether the element is a column Hedaer element
				// in this case, record it as a mouse click event
				var row:int = odg.itemRendererToIndex(item);
				if(row == -1 )
				{
					recordAutomatableEvent(event, true)
				}
				else
				{
					// take the key modifiers from the mouseDown event because
					// they were used by List for making the selection
					event.ctrlKey = ctrlKeyDown;
					event.shiftKey = shiftKeyDown;
					recordListItemSelectEvent(item, event);
				}
				
			}
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
			return  new OLAPDataGridTabularData(odg);
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
			var result:Array = [];
			var item:IListItemRenderer = delegate as IListItemRenderer;
			
			if (item == odg.itemEditorInstance)
				item = odg.editedItemRenderer;
			
			var row:int = odg.itemRendererToIndex(item);
			if ((row == int.MIN_VALUE)|| (row < 0 ))
				return null; 
			
			// get the complete information from the tabular date
			
			var tempTabData:OLAPDataGridTabularData = new  OLAPDataGridTabularData(odg);
			result = tempTabData.getValues(row,row+1);
			result = result[0]; 
			
			// get the selected cell Index among the visible cell index
			var selectedCellPos:Number = 0;
			
			row = row < odg.lockedRowCount ?
				row :
				row - odg.verticalScrollPosition;     
			
			
			var listItems:Array = odg.rendererArray;
			var selectedCellFound:Boolean = false;
			
			var n:int = listItems[row].length;
			for (var col:int = 0; col < n; col++)
			{
				var i:IListItemRenderer = listItems[row][col];
				if (i == item)
				{
					selectedCellFound = true;
					break;
				}
			}
			
			if(selectedCellFound == true)
				selectedCellPos = col ;
			
			//change the sring at the selected cellposition
			var tempString:String = result[selectedCellPos];
			tempString = "*" + tempString + "*";
			result[selectedCellPos]= tempString;
			
			return result.join(" | ");
			
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
					for(var j:int = 0; j < coulumcount ; j++)
					{
						var item:IListItemRenderer = listItems[i][j];
						if (item)
						{
							if (grid1.itemEditorInstance &&
								grid1.editedItemPosition &&
								item == grid1.editedItemRenderer)
								childrenList.push(grid1.itemEditorInstance as IAutomationObject);
							
							childrenList.push(item as IAutomationObject);
						}
					}
					
				}
			}
			
			return  childrenList;
		}
		
	}
}

