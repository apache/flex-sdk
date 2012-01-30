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
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.utils.getTimer;
	
	import mx.automation.Automation;
	import mx.automation.AutomationIDPart;
	import mx.automation.IAutomationManager;
	import mx.automation.IAutomationManager2;
	import mx.automation.IAutomationObject;
	import mx.automation.IAutomationObjectHelper;
	import mx.automation.delegates.DragManagerAutomationImpl;
	import mx.automation.events.AutomationDragEvent;
	import mx.automation.events.ListItemSelectEvent;
	import mx.automation.tabularData.TreeTabularData;
	import mx.collections.CursorBookmark;
	import mx.collections.ICollectionView;
	import mx.collections.IViewCursor;
	import mx.controls.FileSystemTree;
	import mx.controls.Tree;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.controls.listClasses.ListBaseContentHolder;
	import mx.controls.treeClasses.TreeItemRenderer;
	import mx.core.IDataRenderer;
	import mx.core.UIComponentGlobals;
	import mx.core.mx_internal;
	import mx.events.DragEvent;
	import mx.events.FileEvent;
	
	use namespace mx_internal;
	
	[Mixin]
	
	[ResourceBundle("controls")]
	
	/**
	 * 
	 *  Defines methods and properties required to perform instrumentation for the 
	 *  Tree control.
	 * 
	 *  @see mx.controls.Tree 
	 *
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class FileSystemTreeAutomationImpl extends TreeAutomationImpl 
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
			Automation.registerDelegateClass(FileSystemTree, FileSystemTreeAutomationImpl);
		}   
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *
		 *  @param obj Tree object to be automated.     
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function FileSystemTreeAutomationImpl(obj:FileSystemTree)
		{
			super(obj);
			
			//obj.addEventListener(TreeEvent.ITEM_OPENING, recordAutomatableEvent, false, 0, true);
			//obj.addEventListener(TreeEvent.ITEM_CLOSE, recordAutomatableEvent, false, 0, true);
			
			obj.addEventListener(FileEvent.DIRECTORY_OPENING, recordAutomatableEvent, false, 0, true);
			obj.addEventListener(FileEvent.DIRECTORY_CLOSING, recordAutomatableEvent, false, 0, true);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  tree
		//----------------------------------
		
		/**
		 *  @private
		 *  storage for the owner component
		 */
		override protected function get tree():Tree
		{
			return uiComponent as Tree;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override public function getItemAutomationValue(delegate:IAutomationObject):String
		{
			var result:Array = [];
			
			var renderer:IListItemRenderer = delegate as IListItemRenderer;
			var curItem:Object = renderer.data;
			// while (curItem.getParent())   //
			while (curItem)
			{
				renderer = tree.getListVisibleData()[tree.getItemUID(curItem)];
				if (!renderer)
				{
					var contentHolder:ListBaseContentHolder = tree.getListContentHolder();
					renderer = IListItemRenderer(contentHolder.getChildByName("hiddenItem"));
					if (!renderer)
					{
						renderer = tree.itemRenderer.newInstance();
						//trace("[Tree] created new item");
						renderer.name = "hiddenItem";
						renderer.visible = false;
						renderer.styleName = contentHolder;
						contentHolder.addChild(DisplayObject(renderer));
					}
					var uid:String = tree.getItemUID(curItem);
					if (renderer is IDropInListItemRenderer)
						IDropInListItemRenderer(renderer).listData =
							tree.callMakeListData(curItem, uid, 0);
					renderer.data = curItem;
					UIComponentGlobals.layoutManager.validateClient(renderer, true);
				}
				
				if(renderer is IAutomationObject)
					result.unshift(IAutomationObject(renderer).automationValue);
				
				curItem = tree.getParentItem(curItem);
			}
			
			return result.join(">");
		}
		
		/**
		 *  @private
		 *  Replays NODE_OPEN, NODE_CLOSE, and CHANGE events. Replays NODE_OPEN /
		 *  NODE_CLOSE by replaying the right/left arrow key on the item, if input
		 *  type was keyboard, or delegating to the item renderer's replayAutomatableEvent
		 *  otherwise. Replays CHANGE by clicking on the item.
		 *
		 *  TODOtesting make sure item renderer components have correct IDs
		 *  TODOtesting clicking on a item's disclosure currently dispatches three CHANGEs and a NODE_OPEN. wtf?
		 */
		override public function replayAutomatableEvent(event:Event):Boolean
		{
			var completeTime:Number;
			var help:IAutomationObjectHelper = Automation.automationObjectHelper;
			if (event is FileEvent)
			{
				var t:FileEvent = FileEvent(event);
				var selectedFile:File  = t.file;
				
				var part:AutomationIDPart = new AutomationIDPart();
				var currentFileNameInTreeRendererForm:String = selectedFile.nativePath;
				while (currentFileNameInTreeRendererForm.indexOf(File.separator) != -1)
				{
					currentFileNameInTreeRendererForm = currentFileNameInTreeRendererForm.replace(File.separator , ">");
				}
				
				if (!currentFileNameInTreeRendererForm)
					return false;
				
				if (currentFileNameInTreeRendererForm.charAt(currentFileNameInTreeRendererForm.length-1)== ">")
					currentFileNameInTreeRendererForm = currentFileNameInTreeRendererForm.substr(0,currentFileNameInTreeRendererForm.length-1);
				// selectedFile.nativePath;
				part.automationName =currentFileNameInTreeRendererForm
				var automationManager:IAutomationManager2 = Automation.automationManager2 as IAutomationManager2;
				if (!automationManager)
					return false;
				
				var ao:Array = automationManager.resolveIDPart(tree as IAutomationObject, part);
				var delegate:IAutomationObject = (ao[0] as IAutomationObject);
				
				var renderer:IListItemRenderer = delegate as IListItemRenderer;
				var open:Boolean = tree.isItemOpen(renderer.data);
				
				if ((t.type == FileEvent.DIRECTORY_OPENING && open) ||
					(t.type == FileEvent.DIRECTORY_CLOSING && !open))
					return false;
				
				// we wait for the openDuration
				completeTime = getTimer() + tree.getStyle("openDuration");
				
				
				help.addSynchronization(function():Boolean
				{
					//we wait if the tree is opening
					// this is required because tree increases the tween duration based
					// on the number of items to open
					return (!tree.isOpening && getTimer() >= completeTime);
				});
				
				
				if (renderer is TreeItemRenderer)
					return help.replayClick(TreeItemRenderer(renderer).getDisclosureIcon());
				
				if (renderer is IAutomationObject)
					return IAutomationObject(renderer).replayAutomatableEvent(event);
				else
					throw new Error();
				
				
			}
			else if (event is ListItemSelectEvent)
			{
				completeTime = getTimer() + tree.getStyle("openDuration");
				help.addSynchronization(function():Boolean
				{
					//we wait if the tree is opening
					// this is required because tree increases the tween duration based
					// on the number of items to open
					return (!tree.isOpening && getTimer() >= completeTime);
				});
			}
			else if(event is AutomationDragEvent && event.type == AutomationDragEvent.DRAG_DROP)
			{
				var dragEvent:AutomationDragEvent = AutomationDragEvent(event);
				if (dragEvent.dropParent && !dragEvent.draggedItem)
				{
					var mouseEvent:MouseEvent = null;
					
					var index:int = tree.itemRendererToIndex(dragEvent.dropParent as IListItemRenderer) - tree.verticalScrollPosition;
					
					var view:ICollectionView = tree.getChildren(IDataRenderer(dragEvent.dropParent).data, tree.dataProvider);
					
					var targetItem:IListItemRenderer = tree.rendererArray[index+view.length+1][0];
					var localX:Number = targetItem.width/2 ;
					var localY:Number = tree.rowHeight/4;
					dragEvent.localX = localX;
					dragEvent.localY = localY;
					
					// we need to direct the air based replay so that the replays are taken care properly.
					DragManagerAutomationImpl.replayDragDrop(targetItem,tree as IAutomationObject,dragEvent,true);
					
					return true;
				}
			}       
			
			return super.replayAutomatableEvent(event);
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
			return new TreeTabularData(tree);
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
			
			var index:int = listBase.calculateDropIndex(event);
			
			var targetTree:Tree = Tree(event.target);
			var am:IAutomationManager = Automation.automationManager;
			index = targetTree._dropData.index;
			
			var drag:AutomationDragEvent = new AutomationDragEvent(event.type);
			var parent:IListItemRenderer = tree.itemToItemRenderer(targetTree._dropData.parent);
			
			if (targetTree._dropData.parent && !parent)
			{
				//try to create a itemRenderer for this
				parent = tree.itemRenderer.newInstance();
				tree.setupRendererFromData(parent, targetTree._dropData.parent);
				drag.dropParent = parent as IAutomationObject;
				parent.owner = tree;
			}
			
			var i:int = 0;
			var view:ICollectionView ;
			var listItems:Array = tree.rendererArray;
			if (parent)
			{
				drag.dropParent = parent as IAutomationObject;
				view = tree.getChildren(targetTree._dropData.parent, tree.dataProvider);
				if (index < view.length)
					drag.draggedItem = tree.itemToItemRenderer(view[index]) as IAutomationObject;
			}
			else
			{
				var cursor:IViewCursor = tree.dataProvider.createCursor();
				cursor.seek(CursorBookmark.FIRST, index);
				drag.draggedItem = tree.itemToItemRenderer(cursor.current) as IAutomationObject;
			}
			
			drag.action = event.action;
			preventDragDropRecording = false;
			am.recordAutomatableEvent(uiAutomationObject, drag);
			preventDragDropRecording = true;
		}
		
		/**
		 *  @private
		 */
		override public function getItemsCount():int
		{
			if (tree.dataProvider)
				return tree.collectionLength;
			
			return 0;
		}
		
	}
	
	
}
