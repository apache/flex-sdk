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

package mx.collections
{
    import mx.collections.*;
    import mx.utils.StringUtil;
	import mx.collections.ArrayCollection;
	import mx.collections.CursorBookmark;
	import mx.collections.HierarchicalCollectionView;
	import mx.collections.HierarchicalCollectionViewCursor;
	import mx.collections.HierarchicalData;
	import mx.collections.IViewCursor;
	import mx.utils.UIDUtil;

	public class HierarchicalCollectionViewTestUtils
	{
		//assumes the root is an ArrayCollection of DataNodes
		private var _allNodes:Object = {};
		
		public function clone(hcv:HierarchicalCollectionView):HierarchicalCollectionView
		{
			var oldRoot:ArrayCollection = ArrayCollection(getRoot(hcv));
			var newRoot:ArrayCollection = new ArrayCollection();
			
			for each(var rootNode:DataNode in oldRoot)
			{
				newRoot.addItem(rootNode.clone());
			}
			
			return generateHCV(newRoot);
		}
		
		public function createNodes(level:String, no:int):ArrayCollection
		{
			var nodes:ArrayCollection = new ArrayCollection();
			for(var i:int = 0; i < no; i++)
			{
				nodes.addItem(createSimpleNode(level));
			}
			
			return nodes;
		}
		
		public function generateOpenHierarchyFromRootList(root:ArrayCollection):HierarchicalCollectionView
		{
			var hcv:HierarchicalCollectionView = generateHCV(root, false);
			openAllNodes(hcv);
			return hcv;
		}

        public function generateOpenHierarchyFromRootListWithAllNodesMethod(root:ArrayCollection):HierarchicalCollectionView
        {
            var hcv:HierarchicalCollectionView = generateHCV(root, true);
            return hcv;
        }
		
		public function generateHCV(rootCollection:ArrayCollection, useAllNodes:Boolean = false):HierarchicalCollectionView
		{
			return new HierarchicalCollectionView(new HierarchicalData(rootCollection), useAllNodes ? _allNodes : null);
		}
		
		public function openAllNodes(hcv:HierarchicalCollectionView):void
		{
			var cursor:HierarchicalCollectionViewCursor = hcv.createCursor() as HierarchicalCollectionViewCursor;
			while(!cursor.afterLast)
			{
				hcv.openNode(cursor.current);
				cursor.moveNext();
			}
		}
		
		public function getRoot(hcv:HierarchicalCollectionView):Object
		{
			return hcv.source.getRoot();
		}
		
		public function printHCollectionView(hcv:HierarchicalCollectionView):void
		{
			trace("");
			var cursor:HierarchicalCollectionViewCursor = hcv.createCursor() as HierarchicalCollectionViewCursor;
			while(!cursor.afterLast)
			{
				trace(DataNode(cursor.current).label);
				cursor.moveNext();
			}
		}

        public function createSimpleNode(label:String):DataNode
		{
			var node:DataNode = new DataNode(label);
			_allNodes[UIDUtil.getUID(node)] = node;
            return node;
        }

        public function isAncestor(node:DataNode, forNode:DataNode, hcv:HierarchicalCollectionView):Boolean
        {
            do
            {
                forNode = hcv.getParentItem(forNode) as DataNode;
            } while(forNode && forNode != node)

            return forNode == node;
        }
		
		public function nodesHaveCommonAncestor(node:DataNode, withNode:DataNode, hcv:HierarchicalCollectionView):Boolean
		{
			var nodeAndAncestors:Array = [node].concat(getNodeAncestors(node, hcv));
			var otherNodeAndAncestors:Array = [withNode].concat(getNodeAncestors(withNode, hcv));
			for each(var ancestor:DataNode in nodeAndAncestors)
				if(otherNodeAndAncestors.indexOf(ancestor) != -1)
					return true;
				
			return false;
		}
		
		public function getNodeAncestors(node:DataNode, hcv:HierarchicalCollectionView):Array
		{
			var nodeParents:Array = [];
			
			// Make a list of parents of the node.
			var parent:Object = hcv.getParentItem(node);
			while (parent)
			{
				nodeParents.push(parent);
				parent = hcv.getParentItem(parent);
			}
			
			return nodeParents;
		}
		
		public function navigateToItem(cursor:IViewCursor, item:DataNode):IViewCursor
		{
			while(!cursor.afterLast && cursor.current != item)
			{
				cursor.moveNext();
			}
			
			return cursor;
		}
		
		public function generateHierarchySourceFromString(source:String):ArrayCollection
		{
			var rootCollection:ArrayCollection = new ArrayCollection();
			var alreadyCreatedNodes:Array = [];
			var node:DataNode;
			
			var lines:Array = source.split("\n");
			for each(var line:String in lines)
			{
				if(!line)
					continue;
				
				var currentLabel:String = "";
				var previousNode:DataNode = null;
				var nodesOnThisLine:Array = StringUtil.trim(line).split("->");
				for each(var nodeName:String in nodesOnThisLine)
				{
					if(!nodeName)
						continue;
					
					currentLabel += currentLabel ? "->" + nodeName : nodeName;
					
					var nodeAlreadyCreated:Boolean = alreadyCreatedNodes[currentLabel] != undefined;
					
					if(nodeAlreadyCreated)
						node = alreadyCreatedNodes[currentLabel];
					else {
						node = createSimpleNode(currentLabel);
						alreadyCreatedNodes[currentLabel] = node;
					}
					
					if(!nodeAlreadyCreated) {
						if (previousNode)
							previousNode.addChild(node);
						else
							rootCollection.addItem(node);
					}
					
					previousNode = node;
				}
			}
			
			return rootCollection;
		}
	}
}