////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

package
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.controls.Tree;
	import mx.core.mx_internal;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.DragEvent;
	import mx.events.TreeEvent;
	
    use namespace mx_internal;

	/**
	 * This class will expand a tree whenever the data provider changes. 
	 * The tree expansion performed in one of two ways. 
	 * 
	 * The first is by setting the nested levels. Setting the nested levels to 1 for example 
	 * will show the children of the root node.
	 * 
	 * Anothee approach is by setting the last parent class which indicates the class when encountered
	 * will stop the expansion of a branch. By setting expandLastParent to true, that node is also expanded.
	 * 
	 * In theory this should be separated into two classes once some neamingful names for the classes are found.
	*/
	public class TreeExpander
	{
		/**
		 * The last class to expand
		 */
		public var lastParent:Class;
		
		/**
		 * Whether or not the last parent should be expanded. Default is false.
		 */
		public var expandLastParent:Boolean = false;
		
		/**
		 * The number of tree levels to open, default is 100. Ignored if LastParent is set.
		 */
		public var nestedLevels:int = 100;
		
		/**
		 * Automatically expand the parent branches of an item when that item is selected.
		 * Default is true.
		 */ 
		public var expandSelectedItem:Boolean = true;
		
		private var selectedDomainObjects:Array;
		
		private var timerToExpand:Timer = new Timer(700, 1);
		
		private var nodeToExpand:Object;
				
		/** 
		 * The tree to perform the expansions.
		 */
		public function set tree(tree:Tree):void
		{
			_tree = tree;
			BindingUtils.bindSetter(expandFromRoot,  tree, "dataProvider");	
//			BindingUtils.bindSetter(expandAncestors, this, "selectedDomainObjects");
			
			tree.addEventListener(TreeEvent.ITEM_OPEN, 					nodeExpandedHandler);
			tree.addEventListener(DragEvent.DRAG_OVER, 					dragOverHandler);
			
			timerToExpand.addEventListener(TimerEvent.TIMER, 			timerToExpandHandler);
		}
		
		public function get tree():Tree
		{
			return _tree;
		}
		
		private var _tree:Tree;
		
		/**
		 * Expand the whole tree.
		 */
		public function expandFromRoot(object:Object=null):void
		{
			if (tree==null || tree.dataProvider==null || nestedLevels < 1)
				return;
				
			var rootNode:Object = getRootNode();
			if (rootNode != null)
			{
				expandNode(rootNode);
				
				if (tree.dataDescriptor.hasChildren(rootNode))
				{
					var children:ICollectionView = tree.dataDescriptor.getChildren(rootNode);
					children.addEventListener(CollectionEvent.COLLECTION_CHANGE, collectionChangeHandler);
				}
			}
		}
		
		/**
		 * Expand starting at a specific node
		 */
		private function expandNode(node:Object):void
		{
			if (lastParent)
				expandToLastParent(node);
			else
				expandToLevel(node);
		}

		/**
		 * Returns the root data provider node of the tree.
		 */
		private function getRootNode():Object
		{
			var rootNode:Object;
			
			if (tree.dataProvider is ArrayCollection)
			{
				var dataProviderArray:ArrayCollection = tree.dataProvider as ArrayCollection;
				if (dataProviderArray.length > 0)
				{
					rootNode = dataProviderArray.getItemAt(0);
				}
			}
			else
			{
				rootNode = tree.dataProvider;
			}
			return rootNode;
		}
		
		/**
		 * Expand until the nested level is reached 
		 */
		private function expandToLevel(node:Object, curLevel:int=0):void
		{
			if (curLevel<nestedLevels)
			{
				tree.expandItem(node, true);
				if (curLevel<nestedLevels && tree.dataDescriptor.hasChildren(node))
				{
					for each (var node:Object in tree.dataDescriptor.getChildren(node))
					{
						expandToLevel(node, curLevel+1);
					}
				}
			}
		}
		
		/**
		 * Expand until we have reached a node having a specific class
		 */
		private function expandToLastParent(node:Object):void
		{
			if (!isLastParent(node) || expandLastParent)
			{
				tree.expandItem(node, true);
				if (!isLastParent(node) && tree.dataDescriptor.hasChildren(node))
				{
					for each (var node:Object in tree.dataDescriptor.getChildren(node))
					{
						expandToLastParent(node);
					}
				}
			}
		}
		
		/**
		 * Returns true if the node is of class lastParent
		 */
		private function isLastParent(node:Object):Boolean
		{
			return lastParent ? node is lastParent : false;
		}		
		
		[Bindable]
		public function set selectedItems(items:Array):void
		{
			selectedDomainObjects = items;
			
			trace("1 --- Selected Items Length = " + items.length);
			
			if (items != null && items.length > 0)
			{
				expandAncestors(items[0]);
			}
			
			trace("2 --- Selected Items Length = " + items.length);
			try {
				tree.selectedItems = items;
			}
			catch(e:Error) {
				trace("ERROR" + e.message);
			}
			trace("3 --- Selected Items Length = " + items.length);
			
		}
		
		public function get selectedItems():Array
		{
			trace("TreeExpander " + tree.selectedItems.length);
			
			return tree.selectedItems;
		}
		
		/**
		 * Expand the ancestors of a node.
		 */
		private function expandAncestors(item:Object):void
		{
			if (tree.dataProvider!=null && expandSelectedItem && item!=null && !tree.isItemVisible(item))
			{
				var ancestors:Array = new Array();
				getAncestors(item, getRootNode(), ancestors);
				
				for each (var ancestor:Object in ancestors)
				{
					tree.expandItem(ancestor, true);
				}
			}
		}
		
		/**
		 * Recursively finds the ancestors of a node.
		 */
		private function getAncestors(item:Object, parent:Object, ancestors:Array):void
		{
			var children:ICollectionView = tree.dataDescriptor.getChildren(parent);
			
			for each (var child:Object in children)
			{
				if (child === item)
				{
					ancestors.push(parent);
					return;
				}
				else if (tree.dataDescriptor.hasChildren(child))
				{
					getAncestors(item, child, ancestors)
					if (ancestors.length > 0)
					{
						ancestors.push(parent);
						return;
					}
				}
			}
		}
		
		private function collectionChangeHandler(event:CollectionEvent):void
		{
			var items:Array = findAddedItems(event);
			 
			for each (var item:Object in items)
			{
				expandNode(item);
			}
		}
		
		private function findAddedItems(event:CollectionEvent):Array
		{
			var addedItems:Array;
			
			if (event.kind == CollectionEventKind.ADD)
			{
				addedItems = event.items;
			}
			else if (event.kind == CollectionEventKind.UPDATE)
			{
				addedItems = new Array();
				
				for each (var item:Object in event.items)
				{
					if (item.hasOwnProperty("origin") && item.origin is CollectionEvent)
					{
						var originalEvent:CollectionEvent = CollectionEvent(item.origin);
						
						if (originalEvent.kind == CollectionEventKind.ADD)
						{
							addedItems = addedItems.concat(originalEvent.items);
						}
					}
				}
			}
			return addedItems;
		}

		private function nodeExpandedHandler(event:TreeEvent):void
		{
			if (expandSelectedItem)
			{
				var firstItem:Object = selectedDomainObjects.length==0 ? null : selectedDomainObjects[0];
				
				if (firstItem != null && tree.isItemVisible(firstItem))
				{
					selectedItems = selectedDomainObjects;
				}
			}
		}	
		
		private function dragOverHandler(event:DragEvent):void
		{
			var collapsedBranch:Object = getCollapsedBranch();
			
			if (nodeToExpand != collapsedBranch)
			{
				timerToExpand.stop();
			}
			
			if (collapsedBranch != null)
			{
				nodeToExpand = collapsedBranch;
				timerToExpand.start();
			}
		}		
		
		private function getCollapsedBranch():Object
		{
			if (tree != null && tree._dropData != null)
			{
				if (tree._dropData.parent == null)
				{
					return getRootNode();
				}
				else
				{
					var children:ICollectionView = tree._dataDescriptor.getChildren(tree._dropData.parent);
					
					if (children is ArrayCollection && ArrayCollection(children).length>tree._dropData.index)
					{
						var child:Object = ArrayCollection(children).getItemAt(tree._dropData.index);
						if (tree._dataDescriptor.isBranch(child) && !tree.isItemOpen(child))
						{
							return child;
						}
					}
				}
			}
			return null;
		}	
		
		private function timerToExpandHandler(event:TimerEvent):void
		{
			if (nodeToExpand != null)
			{
				expandNode(nodeToExpand);
			}
		}
		
	}
}