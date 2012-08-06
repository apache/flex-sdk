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
package Assets
{
	import flash.text.TextField;
	
	import mx.controls.treeClasses.DefaultDataDescriptor;
	import flash.utils.Dictionary;
	import mx.collections.ArrayCollection;
	import mx.collections.CursorBookmark;
	import mx.collections.ICollectionView;
	import mx.collections.IList;
	import mx.collections.IViewCursor;
	import mx.collections.XMLListCollection;
	import mx.controls.menuClasses.IMenuDataDescriptor;
	import mx.utils.UIDUtil;

	public class CustomChildData extends DefaultDataDescriptor
	{
		public function CustomChildData()
		{
		}
	
		/**
		     *  Provides access to a node's children. Returns a collection
		     *  of children if they exist. If the node is an Object, the method
		     *  returns the contents of the object's <code>children</code> field as
		     *  an ArrayCollection.
		     *  If the node is XML, the method returns an XMLListCollection containing
		     *  the child elements.
		     *
		     *  @param node The node object currently being evaluated.
		     *  @param model The collection that contains the node; ignored by this class.
		     *  @return An object containing the children nodes.
		     */
		override public function getChildren(node:Object, model:Object = null):ICollectionView
		    {
		    	var childrenCollection:XMLListCollection;
		        
		        childrenCollection =  new XMLListCollection(node.mymenuette.*);
		        return childrenCollection;
		    }

		override public function isBranch(node:Object, model:Object = null):Boolean
		    {
		    	return hasChildren(node, model); 
  		    }
	}
}