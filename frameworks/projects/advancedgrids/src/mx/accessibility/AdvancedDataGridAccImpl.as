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

package mx.accessibility
{

import flash.accessibility.Accessibility;
import flash.events.Event;

import mx.collections.CursorBookmark;
import mx.collections.ICollectionView;
import mx.collections.IHierarchicalCollectionView;
import mx.collections.IViewCursor;
import mx.controls.AdvancedDataGrid;
import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
import mx.controls.advancedDataGridClasses.AdvancedDataGridHeaderInfo;
import mx.controls.advancedDataGridClasses.SortInfo;
import mx.controls.listClasses.IListItemRenderer;
import mx.core.UIComponent;
import mx.events.AdvancedDataGridEvent;

import mx.core.mx_internal;

use namespace mx_internal;

/**
 *  The AdvancedDataGridAccImpl class is the accessibility class for AdvancedDataGrid.
 *
 *  @helpid 3009
 *  @tiptext This is the AdvancedDataGrid Accessibility Class.
 *  @review
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class AdvancedDataGridAccImpl extends ListBaseAccImpl
{
    include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class initialization
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Static variable triggering the hookAccessibility() method.
	 *  This is used for initializing AdvancedDataGridAccImpl class to hook its
	 *  createAccessibilityImplementation() method to AdvancedDataGrid class 
	 *  before it gets called from UIComponent.
	 */
	private static var accessibilityHooked:Boolean = hookAccessibility();
	
	/**
	 *  @private
	 *  Static method for swapping the createAccessibilityImplementation()
	 *  method of AdvancedDataGrid with the AdvancedDataGridAccImpl class.
	 */
	private static function hookAccessibility():Boolean
	{
		AdvancedDataGrid.createAccessibilityImplementation =
			createAccessibilityImplementation;

		return true;
	}

	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private static const ROLE_SYSTEM_LISTITEM:uint = 0x22;
	
	/**
	 *  @private
	 *  Role of treeItem.
	 */
	private static const ROLE_SYSTEM_OUTLINEITEM:uint = 0x24;

	/**
	 *  @private
	 */
	private static const STATE_SYSTEM_COLLAPSED:uint = 0x00000400;

	/**
	 *  @private
	 */
	private static const STATE_SYSTEM_EXPANDED:uint = 0x00000200;
	
	/**
	 *  @private
	 */
	private static const STATE_SYSTEM_FOCUSED:uint = 0x00000004;
	
	/**
	 *  @private
	 */
	private static const STATE_SYSTEM_INVISIBLE:uint = 0x00008000;
	
	/**
	 *  @private
	 */
	private static const STATE_SYSTEM_OFFSCREEN:uint = 0x00010000;
	
	/**
	 *  @private
	 */
	private static const STATE_SYSTEM_SELECTABLE:uint = 0x00200000;
	
	/**
	 *  @private
	 */
	private static const STATE_SYSTEM_SELECTED:uint = 0x00000002;
	
	/**
	 *  @private
	 *  Event emitted if 1 item is selected.
	 */
	private static const EVENT_OBJECT_FOCUS:uint = 0x8005; 
	
	/**
	 *  @private
	 *  Event emitted if 1 item is selected.
	 */
	private static const EVENT_OBJECT_SELECTION:uint = 0x8006;
	
	/**
	 *  @private
	 */
	private static const EVENT_OBJECT_STATECHANGE:uint = 0x800A;
	
	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Method for creating the Accessibility class.
	 *  This method is called from UIComponent.
	 *  @review
	 */
	mx_internal static function createAccessibilityImplementation(
								component:UIComponent):void
	{
		component.accessibilityImplementation =
			new AdvancedDataGridAccImpl(component);
	}

	/**
	 *  Method call for enabling accessibility for a component.
	 *  This method is required for the compiler to activate
	 *  the accessibility classes for a component.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static function enableAccessibility():void
	{
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 *
	 *  @param master The UIComponent instance that this AccImpl instance
	 *  is making accessible.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function AdvancedDataGridAccImpl(master:UIComponent)
	{
		super(master);
		
		var advancedDataGrid:AdvancedDataGrid = AdvancedDataGrid(master);
		
		role = getRole(advancedDataGrid);
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden properties: AccImpl
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  eventsToHandle
	//----------------------------------

	/**
	 *  @private
	 *	Array of events that we should listen for from the master component.
	 *  @review
	 */
	override protected function get eventsToHandle():Array
	{
		return super.eventsToHandle.concat([ "change", 
											AdvancedDataGridEvent.ITEM_OPEN,
											AdvancedDataGridEvent.ITEM_CLOSE, 
											AdvancedDataGridEvent.ITEM_FOCUS_IN ]);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden methods: AccessibilityImplementation
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Gets the role for the component.
	 *
	 *  @param childID Children of the component
	 */
	override public function get_accRole(childID:uint):uint
	{
		var advancedDataGrid:AdvancedDataGrid = AdvancedDataGrid(master);
		
		if (childID == 0)
		{
			role = getRole(advancedDataGrid);
			return role;
		}
		
		// if header is selected
		if (advancedDataGrid.headerIndex != -1)
			return 0x19; // ROLE_SYSTEM_COLUMNHEADER
		
		if (advancedDataGrid.selectionMode == "singleCell")
		{
			var coord:Object = advancedDataGrid.selectedCells[0];
			if (coord)
			{
				// if data is hierarchical and column is the first showing the tree view
				if (advancedDataGrid.dataProvider is IHierarchicalCollectionView && coord.columnIndex == advancedDataGrid.treeColumn.colNum)
					return ROLE_SYSTEM_OUTLINEITEM;
				
				return ROLE_SYSTEM_LISTITEM;
			}
		}
		
		if (advancedDataGrid.dataProvider is IHierarchicalCollectionView)
			return ROLE_SYSTEM_OUTLINEITEM;
					
		return ROLE_SYSTEM_LISTITEM;
	}

	/**
	 *  @private
	 *  IAccessible method for returning the value of the ListItem/AdvancedDataGrid
	 *  which is spoken out by the screen reader
	 *  The AdvancedDataGrid should return the name of the currently selected item
	 *  with m of n string (with level info if the data is hierarchical) as value 
	 *  when focus moves to AdvancedDataGrid.
	 *
	 *  @param childID uint
	 *
	 *  @return Name String
	 *  @review
	 */
	override public function get_accValue(childID:uint):String
	{
		var accValue:String = "";
		
		var item:Object;
		var i:int;
		var advancedDataGrid:AdvancedDataGrid = AdvancedDataGrid(master);
		var coord:Object;
		
		if (childID != 0 && advancedDataGrid.dataProvider is IHierarchicalCollectionView)
		{
			// Assuming childID is always ItemID + 1
			// because getChildIDArray is not always invoked.
			i = childID - 1;
			if (advancedDataGrid.selectionMode == "singleCell" || advancedDataGrid.editable.length != 0)
				i = Math.floor(i / advancedDataGrid.columns.length);
			
			item = getItemAt(i);
			if (item == null)
				return accValue;
			
			accValue = advancedDataGrid.getItemDepth(item, i - advancedDataGrid.verticalScrollPosition) + "";
		}
		
		return accValue;
	}

	/**
	 *  @private
	 *  IAccessible method for returning the state of the GridItem.
	 *  States are predefined for all the components in MSAA.
	 *  Values are assigned to each state.
	 *  Depending upon the GridItem being Selected, Selectable, Invisible,
	 *  Offscreen, a value is returned.
	 *
	 *  @param childID uint
	 *
	 *  @return State uint
	 */
	override public function get_accState(childID:uint):uint
	{
		var advancedDataGrid:AdvancedDataGrid = AdvancedDataGrid(master);

		var accState:uint = getState(childID);
		
		var row:int;
		var col:int;

		// 1 to columnCount * Rows -> ItemRenderers
		if (childID > 0)
		{
			if (advancedDataGrid.headerIndex != -1) // header selected
			{
				accState |= STATE_SYSTEM_SELECTABLE | STATE_SYSTEM_SELECTED | STATE_SYSTEM_FOCUSED;
				return accState;
			}
			
			var index:int = childID - 1;
			var coord:Object;
			var view:IHierarchicalCollectionView;
			var item:Object;
			
			if (advancedDataGrid.editable.length == 0 || advancedDataGrid.editedItemPosition == null)
			{
				row = index;
				if (advancedDataGrid.selectionMode == "singleCell")
				{
					coord = advancedDataGrid.selectedCells[0];
					if (coord)
					{
						row = coord.rowIndex;
					}
				}

				if (row < advancedDataGrid.verticalScrollPosition ||
					row >= advancedDataGrid.verticalScrollPosition 
						+ advancedDataGrid.rowCount)
				{
					accState |= (STATE_SYSTEM_OFFSCREEN | STATE_SYSTEM_INVISIBLE);
				}
				else
				{
					accState |= STATE_SYSTEM_SELECTABLE;

					var renderer:IListItemRenderer = advancedDataGrid.itemToItemRenderer(
						getItemAt(row));

					if (advancedDataGrid.dataProvider is IHierarchicalCollectionView)
					{
						view = IHierarchicalCollectionView(advancedDataGrid.dataProvider);
						//item = getItemAt(index);
						item = getItemAt(row);
	
						if (item && view.source.canHaveChildren(item))
						{
							if(advancedDataGrid.selectionMode != "singleCell" || (coord && coord.columnIndex == advancedDataGrid.treeColumn.colNum))
							{
								if (advancedDataGrid.isItemOpen(item))
									accState |= STATE_SYSTEM_EXPANDED;
								else
									accState |= STATE_SYSTEM_COLLAPSED;
							}
						}
					}
					
					if (advancedDataGrid.selectionMode == "singleCell")
					{
						row = Math.floor(index / advancedDataGrid.columns.length);
						col = index % advancedDataGrid.columns.length;
						
						if (coord &&
							coord.rowIndex == row &&
							coord.columnIndex == col)
						{
							accState |= STATE_SYSTEM_SELECTED | STATE_SYSTEM_FOCUSED;
						}
					}
					else if (renderer && advancedDataGrid.isItemSelected(renderer.data))
					{
						accState |= STATE_SYSTEM_SELECTED | STATE_SYSTEM_FOCUSED;
					}
				}
			}
			else
			{
				row = Math.floor(index / advancedDataGrid.columns.length);
				col = index % advancedDataGrid.columns.length;
				
				if (row < 0 || col < 0)
				{
					coord = advancedDataGrid.editedItemPosition;
					if (coord)
					{
						row = coord.rowIndex;
						col = coord.columnIndex;
					}
					else
					{
						row = 0;
						col = 0;
					}
				}
				
				if (advancedDataGrid.selectionMode == "singleCell")
					coord = advancedDataGrid.selectedCells[0];
				
				if (row < advancedDataGrid.verticalScrollPosition ||
					row >= advancedDataGrid.verticalScrollPosition 
						+ advancedDataGrid.rowCount)
				{
					accState |= (STATE_SYSTEM_OFFSCREEN | STATE_SYSTEM_INVISIBLE);
				}
				else if (advancedDataGrid.columns[col].editable)
				{
					accState |= STATE_SYSTEM_SELECTABLE;
					
					coord = advancedDataGrid.editedItemPosition;
					
					if (advancedDataGrid.dataProvider is IHierarchicalCollectionView)
					{
						view = IHierarchicalCollectionView(advancedDataGrid.dataProvider);
						item = getItemAt(index);
	
						if (item && view.source.canHaveChildren(item))
						{
							if(advancedDataGrid.selectionMode != "singleCell" || (coord && coord.columnIndex == 0))
							{
								if (advancedDataGrid.isItemOpen(item))
									accState |= STATE_SYSTEM_EXPANDED;
								else
									accState |= STATE_SYSTEM_COLLAPSED;
							}
						}
					}
					
					if (coord &&
						coord.rowIndex == row &&
						coord.columnIndex == col)
					{
						accState |= STATE_SYSTEM_SELECTED | STATE_SYSTEM_FOCUSED;
					}
				}
			}
		}

		return accState;
	}
	
	/**
	 *  @private
	 *  IAccessible method for returning the Default Action.
	 *
	 *  @param childID uint
	 *
	 *  @return name of default action.
	 */
	override public function get_accDefaultAction(childID:uint):String
	{
		var advancedDataGrid:AdvancedDataGrid = AdvancedDataGrid(master);
		
		var index:int = childID - 1;
		// index is the (0 based) index of the elements after the headers
	
		var row:int = index;
		var col:int = 0;
		
		if (advancedDataGrid.selectionMode == "singleCell")
		{
			row = Math.floor(index / advancedDataGrid.columns.length);
			col = index % advancedDataGrid.columns.length;
		}
		
		if (childID == 0)
			return null;
			
		if (advancedDataGrid.headerIndex != -1)
			return "Click";
		
		if (!(advancedDataGrid.dataProvider is IHierarchicalCollectionView) || col != advancedDataGrid.treeColumn.colNum)
			return super.get_accDefaultAction(childID);

		var item:Object = getItemAt(row);
		if (!item)
			return null;
			
		var view:IHierarchicalCollectionView = IHierarchicalCollectionView(advancedDataGrid.dataProvider);
		
		// for hierarchical data
		if (view.source.canHaveChildren(item))
			return advancedDataGrid.isItemOpen(item) ? "Collapse" : "Expand";
		else
			return "Double Click";
		
		return null;
	}

	/**
	 *  @private
	 *  IAccessible method for executing the Default Action.
	 *
	 *  @param childID uint
	 */
	override public function accDoDefaultAction(childID:uint):void
	{
		var advancedDataGrid:AdvancedDataGrid = AdvancedDataGrid(master);

		if (childID > 0) // see if this check needs to be given
		{
			// Assuming childID is always ItemID + 1
			// because getChildIDArray may not always be invoked.
			var index:int = childID - 1;
			// index is the (0 based) index of the elements after the headers
		
			var row:int = index;
			var col:int = 0;
			
			if (advancedDataGrid.selectionMode == "singleCell")
			{
				row = Math.floor(index / advancedDataGrid.columns.length);
				col = index % advancedDataGrid.columns.length;
			}
			
			// if header is selected, dispatch the sort event to trigger sorting
			if (advancedDataGrid.headerIndex != -1)
			{
				var advancedDataGridEvent:AdvancedDataGridEvent =
	                new AdvancedDataGridEvent(AdvancedDataGridEvent.SORT, false, true);
	
	            advancedDataGridEvent.columnIndex     = advancedDataGrid.headerIndex;
	            advancedDataGridEvent.dataField       = advancedDataGrid.columns[advancedDataGrid.headerIndex].dataField;
	            advancedDataGridEvent.multiColumnSort      = false;
	            advancedDataGridEvent.removeColumnFromSort = false;
	
	            advancedDataGrid.dispatchEvent(advancedDataGridEvent);
	            
	            return ;
   			}
			
			if (advancedDataGrid.dataProvider is IHierarchicalCollectionView && col == 0)
			{
				if (advancedDataGrid.selectionMode == "singleCell")
					index = row;
				var item:Object = getItemAt(index);
				if (item == null)
					return;
				
				var view:IHierarchicalCollectionView = IHierarchicalCollectionView(advancedDataGrid.dataProvider);
				
				if (view.source.canHaveChildren(item))
				{
					advancedDataGrid.expandItem(item, !advancedDataGrid.isItemOpen(item));
					return;
				}
			}
			
			if (advancedDataGrid.editable.length == 0)
			{
				if (advancedDataGrid.selectionMode == "singleCell")
				{
					advancedDataGrid.selectedCells = [{ rowIndex: row, columnIndex: col }];
				}
				else
				{
					// index is the row id
					advancedDataGrid.selectedIndex = index;
				}
			}
			else
			{
				advancedDataGrid.editedItemPosition = { rowIndex: row, columnIndex: col };
			}
		}
	}

	/**
	 *  @private
	 *  Method to return an array of childIDs.
	 *
	 *  @return Array
	 */
	override public function getChildIDArray():Array
	{
		var childIDs:Array = [];

		var advancedDataGrid:AdvancedDataGrid = AdvancedDataGrid(master);

		if (advancedDataGrid.dataProvider)
		{
			// 0 is AdvancedDataGrid, 1 to columnCount * Rows -> ItemRenderers
			var n:int = 0;
			if ((advancedDataGrid.editedItemPosition == null || advancedDataGrid.editable.length == 0) && 
					advancedDataGrid.selectionMode != "singleCell") // non editable case (itemRenderers)
				n = advancedDataGrid.dataProvider.length;
			else // editable case (rows) or selection mode is single cell
				n = advancedDataGrid.columns.length * advancedDataGrid.dataProvider.length;

			for (var i:int = 0; i < n; i++)
			{
				childIDs[i] = i + 1;
			}
		}
		return childIDs;
	}

	/**
	 *  @private
	 *  IAccessible method for returning the bounding box of the GridItem.
	 *
	 *  @param childID uint
	 *
	 *  @return Location Object
	 */
	override public function accLocation(childID:uint):*
	{
		var advancedDataGrid:AdvancedDataGrid = AdvancedDataGrid(master);

		var index:int = childID - 1;
		var row:int;
		var col:int;
		var coord:Object;
		
		// return the location of the header selected
		if (advancedDataGrid.headerIndex !=-1)
		{
			return advancedDataGrid.selectedHeaderInfo.headerItem;
		}
		
		if (advancedDataGrid.editable.length == 0 || advancedDataGrid.editedItemPosition == null)
		{
			if (advancedDataGrid.selectionMode == "singleCell" && advancedDataGrid.selectedCells.length > 0)
			{
				coord = advancedDataGrid.selectedCells[0];
				if (coord)
				{
					row = coord.rowIndex;
					col = coord.columnIndex;
				}
			}
			else
			{
				row = index;
				col = 0;
			}
			
			if (row < advancedDataGrid.verticalScrollPosition ||
				row >= advancedDataGrid.verticalScrollPosition + advancedDataGrid.rowCount)
			{
				return null;
			}

			return advancedDataGrid.indicesToItemRenderer(row - advancedDataGrid.verticalScrollPosition, col);
		}
		else
		{
			row = Math.floor(index / advancedDataGrid.columns.length);
			col = index % advancedDataGrid.columns.length;
			if (row < advancedDataGrid.verticalScrollPosition ||
				row >= advancedDataGrid.verticalScrollPosition + advancedDataGrid.rowCount)
			{
				return null;
			}
			
			return advancedDataGrid.indicesToItemRenderer(row - advancedDataGrid.verticalScrollPosition, col);
		}
	}
	
	/**
	 *  @private
	 *  IAccessible method for returning the child Selections in the List.
	 *
	 *  @param childID uint
	 *
	 *  @return focused childID.
	 */
	override public function get_accSelection():Array
	{
		var advancedDataGrid:AdvancedDataGrid = AdvancedDataGrid(master);
		var accSelection:Array = [];
		
		var n:int;
		var i:int;
		var coord:Object;
		if (advancedDataGrid.editable.length > 0 && advancedDataGrid.editedItemPosition != null)
		{
			coord = advancedDataGrid.editedItemPosition;
			if (!coord)
				return accSelection;

			accSelection[0] = advancedDataGrid.columns.length * coord.rowIndex + coord.columnIndex + 1;
		}
		else if (advancedDataGrid.selectionMode == "singleCell")
		{
			n = advancedDataGrid.selectedCells.length;
			for (i = 0; i < n; i++)
			{
				coord = advancedDataGrid.selectedCells[i];
				accSelection[i] = advancedDataGrid.columns.length * coord.rowIndex + coord.columnIndex + 1;
			}
		}
		else
		{
			var selectedIndices:Array = AdvancedDataGrid(master).selectedIndices;
			
			n = selectedIndices.length;
			for (i = 0; i < n; i++)
			{
				accSelection[i] = selectedIndices[i] + 1;
			}
		}
		
		return accSelection;
	}

	/**
	 *  @private
	 *  IAccessible method for returning the childFocus of the AdvancedDataGrid.
	 *
	 *  @param childID uint
	 *
	 *  @return focused childID.
	 */
	override public function get_accFocus():uint
	{
		var advancedDataGrid:AdvancedDataGrid = AdvancedDataGrid(master);
		
		var index:uint;
		if (advancedDataGrid.headerIndex != -1)
		{
			if (advancedDataGrid.selectionMode == "singleCell")
				index = advancedDataGrid.columns.length * advancedDataGrid.dataProvider.length
			 		+ advancedDataGrid.headerIndex + 1;
			 else
			 	index = advancedDataGrid.dataProvider.length
			 		+ advancedDataGrid.headerIndex + 1;
			 		
			return index;
		}
		
		var coord:Object;
		if (advancedDataGrid.editable.length == 0)
		{
			if (advancedDataGrid.selectionMode == "singleCell" && advancedDataGrid.selectedCells.length > 0)
			{
				coord = advancedDataGrid.selectedCells[0];
				if (coord)
				{
					index = advancedDataGrid.columns.length * coord.rowIndex + coord.columnIndex + 1;
				}
			}
			else
			{
				index = advancedDataGrid.selectedIndex;
			}
			
			return index >= 0 ? index + 1 : 0;
		}
		else
		{
			coord = advancedDataGrid.editedItemPosition;
			if (coord == null)
				return 0;

			var row:int = coord.rowIndex;
			var col:int = coord.columnIndex;

			return advancedDataGrid.columns.length * row + col + 1;
		}
	}
	
	/**
	 *  @private
	 *  IAccessible method for selecting an item.
	 *
	 *  @param childID uint
	 */
	override public function accSelect(selFlag:uint, childID:uint):void
	{
		var advancedDataGrid:AdvancedDataGrid = AdvancedDataGrid(master);

		var index:uint = childID - 1;
		
		if (index >= 0 && index < advancedDataGrid.dataProvider.length)
			advancedDataGrid.selectedIndex = index;
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods: AccImpl
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  @private
	 *  method for returning the name of the ListItem/AdvancedDataGrid
	 *  which is spoken out by the screen reader
	 *  The ListItem should return the label as the name with m of n string
	 * (with level info if the data is hierarchical) and
	 *  AdvancedDataGrid should return the name specified in the AccessibilityProperties.
	 *
	 *  @param childID uint
	 *
	 *  @return Name String
	 *  @review
	 */
	override protected function getName(childID:uint):String
	{
		var advancedDataGrid:AdvancedDataGrid = AdvancedDataGrid(master);
		// 0 -> AdvancedDataGrid
		
		if(childID != 0 && advancedDataGrid.headerIndex != -1)
		{
			name = getValueForHeader(advancedDataGrid);
			return name;
		}
		
		if (childID == 0 || childID > 100000)
			return "";
		
		var len:int = 0;
		
		// cases - 3 rows, 3 cols 
		// 1. row selection, len = 3
		// 2. cell selection, len = 9
		// 3. editable row/cell selection, len = 9
		// 4. un-editable row selection, len = 3
		// 5. un-editable cell selection, len = 9
		
		if (advancedDataGrid.editable.length == 0 || advancedDataGrid.editedItemPosition == null)
		{
			if (advancedDataGrid.selectionMode == "singleCell")
				len = advancedDataGrid.dataProvider.length * advancedDataGrid.columns.length;
			else
				len = advancedDataGrid.dataProvider.length;
		}
		else if (advancedDataGrid.editable.length != 0)
		{	
			len = advancedDataGrid.dataProvider.length * advancedDataGrid.columns.length;
		}
		
		if (childID > len)
			return "";
		
		var name:String;

		//1 to columnCount * Rows -> ItemRenderers
		if (childID > 0) // see if this check needs to be given
		{
			// assuming childID is always ItemID + 1
			// because getChildIDArray may not always be invoked.
			var index:int = childID - 1;
			
			// index is the (0 based) index of the elements after the headers
			var row:int;
			var col:int;
			var item:Object;
			var columns:Array;
			var n:int;
			var i:int;
			
			var firstColumn:Boolean = true;
			
			var rowStr:String;
			
			if (advancedDataGrid.editable.length == 0 || advancedDataGrid.editedItemPosition == null)
			{
				// index is the row id
				row = index;
				rowStr = ", Row " + (row + 1);
				item = getItemAt(index);
				if (item is String)
				{
					name = " " + item;
				}
				else
				{
					name = "";
					columns = advancedDataGrid.columns;
					
					if (advancedDataGrid.selectionMode == "singleCell")
					{
						row = Math.floor(index / advancedDataGrid.columns.length);
						col = index % advancedDataGrid.columns.length;
						
						if (row < 0 || col < 0)
						{
							var coord:Object = advancedDataGrid.selectedCells[0];
							if (coord)
							{
								row = coord.rowIndex;
								col = coord.columnIndex;
							}
							else
								return "";
						}
						rowStr = ", Row " + (row + 1);
						
						item = getItemAt(row);
						
						if (col != 0)
						{
							firstColumn = false;
							rowStr = "";
						}
						name += columns[col].headerText + ": " + columns[col].itemToLabel(item);
					}
					else
					{
						n = columns.length;
						for (i = 0; i < n; i++)
						{
							if (i > 0)
								name += ",";
							name += " " + columns[i].headerText + ": " + columns[i].itemToLabel(item);
						}
					}
				}
			}
			else
			{
				row = Math.floor(index / advancedDataGrid.columns.length);
				col = index % advancedDataGrid.columns.length;
				
				if (row < 0 || col < 0)
				{
					coord = advancedDataGrid.editedItemPosition;
					if (coord)
					{
						row = coord.rowIndex;
						col = coord.columnIndex;
					}
					else
					{
						return "";
					}
				}
				rowStr = ", Row " + (row + 1);
				
				if (col != 0)
				{
					firstColumn = false;
					rowStr = "";
				}
				
				item = getItemAt(row);
				
				// sometimes item may be an object.
				if (item is String)
				{
					name = " " + item;
				}
				else
				{
					columns = advancedDataGrid.columns;
					
					var itemName:String = columns[col].itemToLabel(item);
					
					var headerText:String = columns[col].headerText;
					
					name = "";

					//if (AdvancedDataGrid.selectable == true && AdvancedDataGrid.isItemSelected(row.data))
					{
						n = columns.length;
						for (i = 0; i < n; i++)
						{
							if (i > 0)
								name += ",";
							name += " " + columns[i].headerText + ": " + columns[i].itemToLabel(item);
						}
					}
					
					name += ", Editing " + headerText + ": " +
							itemName;
				}
			}
			
			if (advancedDataGrid.dataProvider is IHierarchicalCollectionView)
			{
				var view:IHierarchicalCollectionView = IHierarchicalCollectionView(advancedDataGrid.dataProvider);
				
				var str:String = "";
				var strMOfN:String = getMOfN(item);
				if (item && view.source.canHaveChildren(item))
				{
					if (firstColumn)
					{
						str = ". Press control shift right arrow to open, control shift left arrow to close";
						
						if (advancedDataGrid.editable.length == 0)
							name +=  strMOfN + str;
						else
							name += strMOfN ;
					}
					else
					{
						name = name + rowStr;
					}
				}
				else if(firstColumn)
				{
					name += strMOfN;
				}
					
			}
			else
			{
				name = name + rowStr;
			}
		}
		return name;
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden event handlers: AccImpl
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Override the generic event handler.
	 *  All AccImpl must implement this to listen
	 *  for events from its master component. 
	 */
	override protected function eventHandler(event:Event):void
	{
		// Let AccImpl class handle the events
		// that all accessible UIComponents understand.
		$eventHandler(event);
		
		var advancedDataGrid:AdvancedDataGrid = AdvancedDataGrid(master);
		
		var coord:Object;
		var index:int;
		
		var childID:uint;
		
		switch (event.type)
		{
			case "change":
			{
				var sendEvent:Boolean = false;
				if (advancedDataGrid.headerIndex != -1)
				{
					if (advancedDataGrid.selectionMode == "singleCell")
						childID = advancedDataGrid.columns.length * advancedDataGrid.dataProvider.length
					 		+ advancedDataGrid.headerIndex + 1;
					 else
					 	childID = advancedDataGrid.dataProvider.length
					 		+ advancedDataGrid.headerIndex + 1;
					 
					 sendEvent = true;
				}
				
				if (!sendEvent && (advancedDataGrid.editable.length == 0 || advancedDataGrid.editedItemPosition == null))
				{
					index = advancedDataGrid.selectedIndex;
					
					if (advancedDataGrid.selectionMode == "singleCell")
					{
						coord = advancedDataGrid.selectedCells[0];
						if (coord)
						{
							childID = advancedDataGrid.columns.length * coord.rowIndex + coord.columnIndex + 1;
							sendEvent = true;
						}
					}
					else if (index >= 0)
					{
						childID = index + 1;
						sendEvent = true;
					}
				}
				
				if (sendEvent)
				{
					Accessibility.sendEvent(advancedDataGrid, childID,
												EVENT_OBJECT_FOCUS);

					Accessibility.sendEvent(advancedDataGrid, childID,
												EVENT_OBJECT_SELECTION);
				}
				break;
			}
			
			case AdvancedDataGridEvent.ITEM_FOCUS_IN:
			{
				if (advancedDataGrid.editable.length != 0 && advancedDataGrid.editedItemPosition != null)
				{
					var row:int = AdvancedDataGridEvent(event).rowIndex;
					var col:int = AdvancedDataGridEvent(event).columnIndex;

					Accessibility.sendEvent(advancedDataGrid,
									advancedDataGrid.columns.length * row + col + 1,
									EVENT_OBJECT_FOCUS);

					Accessibility.sendEvent(advancedDataGrid,
									advancedDataGrid.columns.length * row + col + 1,
									EVENT_OBJECT_SELECTION);
				}
				break;
			}
			
			case AdvancedDataGridEvent.ITEM_OPEN:
			case AdvancedDataGridEvent.ITEM_CLOSE:
			{
				if (advancedDataGrid.selectionMode == "singleCell")
				{
					coord = advancedDataGrid.selectedCells[0];
					if (coord)
					{
						index = coord.rowIndex;
					}
				}
				else
				{
					index = advancedDataGrid.selectedIndex;
				}
				
				if (index >= 0)
				{
					Accessibility.sendEvent(master, index + 1,
											EVENT_OBJECT_STATECHANGE);
				}
				break;
			}
		}
	}

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private function getItemAt(index:int):Object
	{
		var iterator:IViewCursor = AdvancedDataGrid(master).collectionIterator;
		iterator.seek(CursorBookmark.FIRST, index);
		return iterator.current;
	}

	/**
	 *  @private
	 *  Local method to return m of n String.
	 *
	 *  @param item Object
	 *
	 *  @return string.
	 */
	private function getMOfN(item:Object):String
	{
		if (!item)
			return "";
		var advancedDataGrid:AdvancedDataGrid = AdvancedDataGrid(master);
		var i:int = 0;
		var n:int = 0;

		var view:IHierarchicalCollectionView = IHierarchicalCollectionView(advancedDataGrid.dataProvider);
		
		var parent:Object = advancedDataGrid.getParentItem(item);
		if (parent != null)
		{
			var childNodes:ICollectionView =
				view.getChildren(parent);
			 
			if (childNodes)
			{
				n = childNodes.length;
				for (i = 0; i < n; i++)
				{
					if (item == childNodes[i])
						break;
				}
			}
		}
		else
		{
			var cursor:IViewCursor = ICollectionView(advancedDataGrid.collectionIterator.view).createCursor();
			while (!cursor.afterLast)
			{
				if (item == cursor.current)
					i = n;
				n++;
				cursor.moveNext();
			}
		}
		
		if (i == n)
			i = 0;

		// Make it 1-based.
		if (n > 0)
			i++;

		return ", " + i + " of " + n;
	}
	
	/**
	 *  @private
	 *  Local method to return the header value.
	 *  Includes the sort information also.
	 *
	 *  @param advancedDataGrid AdvancedDataGrid
	 *
	 *  @return string.
	 */
	private function getValueForHeader(advancedDataGrid:AdvancedDataGrid):String
	{
		var accValue:String;
		var headerInfo:AdvancedDataGridHeaderInfo = advancedDataGrid.selectedHeaderInfo;
		var column:AdvancedDataGridColumn = headerInfo.column;
		
		// Whether the current column is sorted or not, and if so what info to
        // read
        var sortInfo:SortInfo = advancedDataGrid.getFieldSortInfo(column);
        
        var str:String;
        var str1:String = "ascending";
        var sortOrder:String;
        if (sortInfo)
        {
        	sortOrder = sortInfo.sequenceNumber == -1 ? null : (", sort order " + sortInfo.sequenceNumber);
        	if (sortInfo.descending)
        	{
        		str = "descending";
        	}
        	else
        	{
        		str = "ascending";
        		str1 = "descending";
        	}
        }
        
        var sortStr:String = (str ? (" sorted " + str) : "") + 
							(sortOrder ? sortOrder : "") + 
							" Press space to sort " + str1 +
							" on this field. " +
							" Press control space to add this field to sort";
			
		accValue = column.headerText + ": Column " + 
						(advancedDataGrid.headerIndex + 1);
		
		if (advancedDataGrid.columnGrouping)
		{
			var colGrpStr:String = "";
			if (headerInfo.children)
			{
				colGrpStr = ", spans " + headerInfo.columnSpan + " columns";
				accValue += colGrpStr;
			}
			else
			{
				accValue += sortStr;
			}
		}
		else
		{
			accValue += sortStr;
		}
		
		return accValue;
	}
	
	/**
	 *  @private
	 *  Local method to return the role of the
	 *  AdvancedDataGrid depending on its dataProvider.
	 *
	 *  @param advancedDataGrid AdvancedDataGrid
	 *
	 *  @return uint.
	 */
	private function getRole(advancedDataGrid:AdvancedDataGrid):uint
	{		
		if (advancedDataGrid.dataProvider is IHierarchicalCollectionView)
			return 0x23; // ROLE_SYSTEM_OUTLINE
		else
			return 0x21; // ROLE_SYSTEM_LIST
	}

}

}
