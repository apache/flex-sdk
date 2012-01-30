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

package mx.automation.delegates.controls 
{
	import flash.display.DisplayObject;
	import flash.events.Event; 
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	import mx.automation.Automation;
	import mx.automation.IAutomationObject;
	import mx.automation.delegates.DragManagerAutomationImpl;
	import mx.automation.events.AutomationDragEvent;
	import mx.automation.tabularData.TileBaseTabularData;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.controls.listClasses.TileBase;
	import mx.controls.listClasses.TileBaseDirection;
	import mx.core.mx_internal;
	
	use namespace mx_internal;
	
	[Mixin]
	/**
	 * 
	 *  Defines methods and properties required to perform instrumentation for the 
	 *  TileBase class, which is the parent of the TileList component.
	 * 
	 *  @see mx.controls.listClasses.TileBase
	 *  @see mx.controls.TileList 
	 *
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class TileBaseAutomationImpl extends ListBaseAutomationImpl 
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
			Automation.registerDelegateClass(TileBase, TileBaseAutomationImpl);
		}   
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 * @param obj TileBase object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function TileBaseAutomationImpl(obj:TileBase)
		{
			super(obj);
		}
		
		/**
		 *  @private
		 *  storage for the owner component
		 */
		protected function get  tileBase():TileBase
		{
			return uiComponent as TileBase;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden properties
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override public function get numAutomationChildren():int
		{
			if (tileBase.direction == TileBaseDirection.HORIZONTAL)
				return super.numAutomationChildren;
			
			var listItems:Array = tileBase.rendererArray;
			var result:int = listItems.length * listItems[0].length;
			var row:uint = listItems.length - 1;
			var col:uint = listItems[0].length - 1;
			while (!listItems[row][col] && result > 0)
			{
				result--;
				if (row != 0)
					row--;
				else if (col != 0)
				{
					col--;
					row = listItems.length - 1;
				}
			}
			return result;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override public function getAutomationChildAt(index:int):IAutomationObject
		{
			if (tileBase.direction == TileBaseDirection.HORIZONTAL)
				return super.getAutomationChildAt(index);
			
			var listItems:Array = tileBase.rendererArray;
			var numRows:int = listItems.length;
			var row:uint = index % numRows;
			var col:uint = index / numRows;
			return (listItems[row][col] as IAutomationObject);
		}
		
		/**
		 * @private
		 */
		override public function getAutomationChildren():Array
		{
			if (tileBase.direction == TileBaseDirection.HORIZONTAL)
				return super.getAutomationChildren();
			
			var childrenList:Array = new Array();
			var listItems:Array = tileBase.rendererArray;
			
			// we get this as the 2 dim array of row and columns
			// we need to make this as single element array
			//while (!listItems[row][col] 
			var  rowcount:int  = listItems?listItems.length:0;
			if (rowcount != 0)
			{
				var coulumcount:int = 0;
				
				if ((listItems[0]) is Array)
					coulumcount = (listItems[0] as Array).length;
				
				for (var i:int = 0; i<rowcount ; i++)
				{
					for (var j:int = 0; j<coulumcount ; j++)
					{
						var item:IListItemRenderer = listItems[i][j];
						if (item)
							childrenList.push(item as IAutomationObject);
					}
				}
			}
			return  childrenList;
		}
		/**
		 *  A matrix of the automationValues of each item in the grid. The return value
		 *  is an array of rows, each of which is an array of item renderers (row-major).
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		override public function get automationTabularData():Object
		{
			return new TileBaseTabularData(tileBase);
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
			if (event.keyCode == Keyboard.SPACE)
			{
				var listItems:Array = listBase.rendererArray;
				var caretIndex:int = listBase.getCaretIndex();
				if (caretIndex != -1)
				{
					var rowIndex:int = listBase.convertIndexToRow(caretIndex);
					var colIndex:int = listBase.convertIndexToColumn(caretIndex);
					var item:IListItemRenderer = listItems
						[rowIndex - listBase.verticalScrollPosition]
						[colIndex - listBase.horizontalScrollPosition]
						as IListItemRenderer;
					//Change made to adapt to the new sdk listbase which does not have listBase.lockedRowCount and lockedColumnCount
					
					/*
					var item:IListItemRenderer = listItems
					[rowIndex - listBase.verticalScrollPosition + listBase.lockedRowCount]
					[colIndex - listBase.horizontalScrollPosition + listBase.lockedColumnCount]
					as IListItemRenderer;
					
					
					*/
					recordListItemSelectEvent(item, event);
				}
				return;
			}
			
			super.keyDownHandler(event);
		}
		
		/**
		 *  @private
		 */
		private function getLastItemRenderer():DisplayObject
		{
			var item:DisplayObject;
			var listItems:Array = tileBase.rendererArray;
			var result:int = listItems.length * listItems[0].length;
			var row:uint = listItems.length - 1;
			var col:uint = listItems[0].length - 1;
			if (tileBase.direction == TileBaseDirection.HORIZONTAL)
			{
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
				if (result)
					item = listItems[row][col];
			}       
			else
			{
				while (!listItems[row][col] && result > 0)
				{
					result--;
					if (row != 0)
						row--;
					else if (col != 0)
					{
						col--;
						row = listItems.length - 1;
					}
				}
				if (result)
					item = listItems[row][col];
			}
			
			return item;
		}
		
		/**
		 *  @private
		 */
		private function getLastRendererMidPoint():Point
		{
			var maxX:int = 0;
			var maxY:int = 0;
			var item:DisplayObject = getLastItemRenderer();
			var adjusted:Boolean = false;
			if (!item)
				return null;
			if (tileBase.direction == TileBaseDirection.HORIZONTAL)
			{
				maxX = item.x + item.width ;
				maxY = item.y + item.height ;
				// are we at the right edge ?
				if (tileBase.width - maxX < item.width)
				{
					//yes. so move to next row
					maxX = item.width/2;
					maxY += item.height/2;
					adjusted = true;
				}
				
				//are we at the last row?
				if (!adjusted && tileBase.height - maxY < item.height)
				{
					//yes. so move to next item on right
					maxX += item.width/2;
					maxY -= item.height/2;
					adjusted = true;
				}
				
				if (!adjusted)
				{
					maxX += item.width/2;
					maxY -= item.height/2;
				}
			}
			else
			{
				maxX = item.x + item.width ;
				maxY = item.y + item.height ;
				// are we at the right edge ?
				if (tileBase.width - maxX < item.width)
				{
					//yes. so move to next row
					maxX -= item.width/2;
					maxY += item.height/2;
					adjusted = true;
				}
				
				//are we at the last row?
				if (!adjusted && tileBase.height - maxY < item.height)
				{
					//yes. so move to next item on right
					maxX += item.width/2;
					maxY = item.height/2;
					adjusted = true;
				}
				
				if (!adjusted)
				{
					maxX -= item.width/2;
					maxY += item.height/2;
				}
			}
			
			return new Point(maxX, maxY);
		}
		
		/**
		 *  @private
		 */
		override public function replayAutomatableEvent(event:Event):Boolean
		{
			if (event is AutomationDragEvent && event.type == AutomationDragEvent.DRAG_DROP)
			{
				var mouseEvent:MouseEvent = null;
				var dragEvent:AutomationDragEvent = AutomationDragEvent(event);
				
				var isTargetChild:Boolean = true;
				var delegate:IAutomationObject = (dragEvent.draggedItem as IAutomationObject);
				if (!delegate)
				{
					isTargetChild = false;
					delegate = uiAutomationObject;
				}   
				
				var realTarget:IEventDispatcher = IEventDispatcher(delegate);
				var container:DisplayObject = DisplayObject(realTarget);
				if (!isTargetChild)
				{
					var p:Point = getLastRendererMidPoint();
					if (p)
					{
						dragEvent.localX = p.x;
						dragEvent.localY = p.y;
					}
					else
					{
						dragEvent.localX = container.width/2;
						dragEvent.localY = container.height/2;
					}
				}
				else
				{
					dragEvent.localX = container.width/2;
					dragEvent.localY = container.height/2;
				}
				
				// maybe add a test to make sure that localX and localY actually
				// do point at the realTarget and aren't being obstructed by another automation
				// object?
				DragManagerAutomationImpl.replayDragDrop(realTarget,tileBase as IAutomationObject ,dragEvent,true);
				/*
				var help:IAutomationObjectHelper = Automation.automationObjectHelper;
				mouseEvent = DragManagerAutomationImpl.toMouseEvent(MouseEvent.MOUSE_MOVE, dragEvent);
				mouseEvent.buttonDown = true;
				help.replayMouseEvent(realTarget, mouseEvent);
				
				mouseEvent = DragManagerAutomationImpl.toMouseEvent(MouseEvent.MOUSE_UP, dragEvent);
				DragManager.dragProxy.action = dragEvent.action;
				help.replayMouseEvent(realTarget, mouseEvent);
				help.addSynchronization(function():Boolean
				{
				return !DragManager.isDragging;
				});
				*/
				
				return true;
			}       
			
			return super.replayAutomatableEvent(event);
		}
		
	}
}
