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

package comps
{

import flash.utils.Dictionary;

import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.collections.ArrayCollection;
import mx.collections.HierarchicalData;
import mx.collections.HierarchicalCollectionView;
import mx.collections.HierarchicalCollectionViewCursor;
import mx.collections.ICollectionView;
import mx.collections.IViewCursor;
import mx.collections.XMLListCollection;
import mx.controls.treeClasses.ITreeDataDescriptor2;
import mx.controls.Tree;
import mx.core.mx_internal;
import mx.utils.UIDUtil;

/**
 *  The DefaultDataDescriptor class provides a default implementation for
 *  accessing and manipulating data for use in controls such as Tree and Menu.
 *
 *  This implementation handles e4x XML and object nodes in similar but different
 *  ways. See each method description for details on how the method
 *  accesses values in nodes of various types.
 *
 *  This class is the default value of the Tree, Menu, MenuBar, and
 *  PopUpMenuButton control <code>dataDescriptor</code> properties.
 *
 *  @see mx.controls.treeClasses.ITreeDataDescriptor
 *  @see mx.controls.menuClasses.IMenuDataDescriptor
 *  @see mx.controls.Menu
 *  @see mx.controls.Menu Bar
 *  @see mx.controls.PopUpMenuButton
 *  @see mx.controls.Tree
 */
public class DMVTreeDataDescriptor implements ITreeDataDescriptor2
{
    /**
     *  Constructor
     */
    public function DMVTreeDataDescriptor(tree:Tree, rootModel:ICollectionView)
    {
        super();
        this.tree = tree;
        hd = new TreeHierarchicalData(rootModel);
    }

    /**
     *  @private
     */
    private var tree:Tree;

    /**
     *  @private
     */
    private var rootModel:ICollectionView;

    /**
     *  @private
     */
    private var rootItem:*;

    /**
     *  @private
     */
    private var hd:HierarchicalData;

    /**
     *  @private
     */
    private var hcv:HierarchicalCollectionView;

    /**
     *  @private
     */
    private var openItems:Object;

    /**
     *  @private
     */
    private var uidFunction:Function;


    /**
     *  @private
     */
    private var ChildCollectionCache:Dictionary = new Dictionary(true);

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
    public function getChildren(node:Object, model:Object = null):ICollectionView
    {
        var children:*;
        var childrenCollection:ICollectionView;

        children = hd.getChildren(node);

        //no children exist for this node 
        if (children == undefined)
            return null;

        //then wrap children in ICollectionView if necessary
        if (children is ICollectionView)
        {
            childrenCollection = ICollectionView(children);
        }
        else if (children is Array)
        {
            var oldArrayCollection:ArrayCollection = ChildCollectionCache[node];
            if (!oldArrayCollection)
            {
                childrenCollection = new ArrayCollection(children);
                ChildCollectionCache[node] = childrenCollection;
            }
            else
            {
                childrenCollection = oldArrayCollection;
                ArrayCollection(childrenCollection).mx_internal::dispatchResetEvent = false;
                ArrayCollection(childrenCollection).source = children;
            }
            
        }
        else if (children is XMLList)
        {
            var oldXMLCollection:XMLListCollection = ChildCollectionCache[node];
            if (!oldXMLCollection)
            {
                // double check since XML as dictionary keys is inconsistent
                for (var p:* in ChildCollectionCache)
                {
                    if (p === node)
                    {
                        oldXMLCollection = ChildCollectionCache[p];
                        break;
                    }
                }
            }

            if (!oldXMLCollection)
            {
                childrenCollection =  new XMLListCollection(children);
                ChildCollectionCache[node] = childrenCollection;
            }
            else
            {
                childrenCollection = oldXMLCollection;
                
                //We don't want to send a RESET type of collectionChange event in this case. 
                XMLListCollection(childrenCollection).mx_internal::dispatchResetEvent = false; 
                XMLListCollection(childrenCollection).source = children;
            }
        }
        else
        {
            var childArray:Array = new Array(children);
            if (childArray != null)
            {
                childrenCollection =  new ArrayCollection(childArray);
            }
        }
        return childrenCollection;
    }
    
    /**
     *  Returns true if the node actually has children. 
     * 
     *  @param node The node object currently being evaluated.
     *  @param model The collection that contains the node; ignored by this class.
     *  @return boolean indicating if this node currently has children
     */
    public function hasChildren(node:Object, model:Object = null):Boolean
    {
        return hd.hasChildren(node);
    }

    /**
     *  Tests a node for termination.
     *  Branches are non-terminating but are not required to have any leaf nodes.
     *  If the node is XML, returns <code>true</code> if the node has children
     *  or a <code>true isBranch</code> attribute.
     *  If the node is an object, returns <code>true</code> if the node has a
     *  (possibly empty) <code>children</code> field.
     *
     *  @param node The node object currently being evaluated.
     *  @param model The collection that contains the node; ignored by this class.
     *  @return boolean indicating if this node is non-terminating
     */
    public function isBranch(node:Object, model:Object = null):Boolean
    {
        return hd.canHaveChildren(node);
    }

    /**
     *  Returns a node's data.
     *  Currently returns the entire node.
     *
     *  @param node The node object currently being evaluated.
     *  @param model The collection that contains the node; ignored by this class.
     *  @return The node.
     */
    public function getData(node:Object, model:Object = null):Object
    {
        return hd.getData(node);
    }

    /**
     *  Add a child node to a node at the specified index. 
     *  This implementation does the following:
     * 
     *  <ul>
     *      <li>If the <code>parent</code> parameter is null or undefined,
     *          inserts the <code>child</code> parameter at the 
     *          specified index in the collection specified by <code>model</code>
     *          parameter.
     *      </li>
     *      <li>If the <code>parent</code> parameter has a <code>children</code>
     *          field or property, the method adds the <code>child</code> parameter
     *          to it at the <code>index</code> parameter location.
     *          In this case, the <code>model</code> parameter is not required.
     *     </li>
     *     <li>If the <code>parent</code> parameter does not have a <code>children</code>
     *          field or property, the method adds the <code>children</code> 
     *          property to the <code>parent</code>. The method then adds the 
     *          <code>child</code> parameter to the parent at the 
     *          <code>index</code> parameter location. 
     *          In this case, the <code>model</code> parameter is not required.
     *     </li>
     *     <li>If the <code>index</code> value is greater than the collection 
     *         length or number of children in the parent, adds the object as
     *         the last child.
     *     </li>
     * </ul>
     *
     *  @param parent The node object that will parent the child
     *  @param newChild The node object that will be parented by the node
     *  @param index The 0-based index of where to put the child node relative to the parent
     *  @param model The entire collection that this node is a part of
     *  @return true if successful
     */
    public function addChildAt(parent:Object, newChild:Object, index:int, model:Object = null):Boolean
    {
		if (!hcv)
			tree.validateNow();

        return hcv.addChildAt(parent, newChild, index);
    }

    /**
     *  Removes the child node from a node at the specified index.
     *  If the <code>parent</code> parameter is null 
     *  or undefined, the method uses the <code>model</code> parameter to 
     *  access the child; otherwise, it uses the <code>parent</code> parameter
     *  and ignores the <code>model</code> parameter.
    *
     *  @param parent The node object that currently parents the child node
     *  @param child The node that is being removed
     *  @param index The 0-based index of  the child node to remove relative to the parent
     *  @param model The entire collection that this node is a part of
     *  @return true if successful
     */
    public function removeChildAt(parent:Object, child:Object, index:int, model:Object = null):Boolean
    {
		if (!hcv)
			tree.validateNow();

        return hcv.removeChildAt(parent, index);
    }

    /**
     *  Returns the type identifier of a node.
     *  This method is used by menu-based controls to determine if the
     *  node represents a separator, radio button,
     *  a check box, or normal item.
     *
     *  @param node The node object for which to get the type.
     *  @return  the value of the <code>type</code> attribute or field,
     *  or the empty string if there is no such field.
     */
    public function getType(node:Object):String
    {
        if (node is XML)
        {
            return String(node.@type);
        }
        else if (node is Object)
        {
            try
            {
                return String(node.type);
            }
            catch(e:Error)
            {
            }
        }
        return "";
    }

    /**
     *  Returns whether the node is enabled.
     *  This method is used by menu-based controls.
     *
     *  @param node The node for which to get the status.
     *  @return the value of the node's <code>enabled</code>
     *  attribute or field, or <code>true</code> if there is no such
     *  entry or the value is not false.
     */
    public function isEnabled(node:Object):Boolean
    {
        var enabled:*;
        if (node is XML)
        {
            enabled = node.@enabled;
            if (enabled[0] == false)
                return false;
        }
        else if (node is Object)
        {
            try
            {
                return !("false" == String(node.enabled))
            }
            catch(e:Error)
            {
            }
        }
        return true;
    }

    /**
     *  Sets the value of the field or attribute in the data provider
     *  that identifies whether the node is enabled.
     *  This method sets the value of the node's <code>enabled</code>
     *  attribute or field.
     *  This method is used by menu-based controls.
     *
     *  @param node The node for which to set the status.
     *  @param value Whether the node is enabled.
     */
    public function setEnabled(node:Object, value:Boolean):void
    {
        if (node is XML)
        {
            node.@enabled = value;
        }
        else if (node is Object)
        {
            try
            {
                node.enabled = value;
            }
            catch(e:Error)
            {
            }
        }
    }

    /**
     *  Returns whether the node is toggled.
     *  This method is used by menu-based controls.
     *
     *  @param node The node for which to get the status.
     *  @return The value of the node's <code>toggled</code>
     *  attribute or field, or <code>false</code> if there is no such
     *  entry.
     */
    public function isToggled(node:Object):Boolean
    {
        if (node is XML)
        {
            var toggled:* = node.@toggled;
            if (toggled[0] == true)
                return true;
        }
        else if (node is Object)
        {
            try
            {
                return Boolean(node.toggled);
            }
            catch(e:Error)
            {
            }
        }
        return false;
    }

    /**
     *  Sets the value of the field or attribute in the data provider
     *  that identifies whether the node is toggled.
     *  This method sets the value of the node's <code>toggled</code>
     *  attribute or field.
     *  This method is used by menu-based controls.
     *
     *  @param node The node for which to set the status.
     *  @param value Whether the node is toggled.
     */
    public function setToggled(node:Object, value:Boolean):void
    {
        if (node is XML)
        {
            node.@toggled = value;
        }
        else if (node is Object)
        {
            try
            {
                node.toggled = value;
            }
            catch(e:Error)
            {
            }
        }
    }

    /**
     *  Returns the name of the radio button group to which
     *  the node belongs, if any.
     *  This method is used by menu-based controls.
     *
     *  @param node The node for which to get the group name.
     *  @return The value of the node's <code>groupName</code>
     *  attribute or field, or an empty string if there is no such
     *  entry.
     */
    public function getGroupName(node:Object):String
    {
        if (node is XML)
        {
            return node.@groupName;
        }
        else if (node is Object)
        {
            try
            {
                return node.groupName;
            }
            catch(e:Error)
            {
            }
        }
        return "";
    }

    /**
     *  @see mx.controls.treeClasses.ITreeDataDescriptor#getHierarchicalCollectionAdaptor
     */
    public function getHierarchicalCollectionAdaptor(collection:ICollectionView, 
                                                uidFunction:Function, 
                                                openItems:Object,
                                                model:Object = null):ICollectionView
    {
        this.hcv = new HierarchicalCollectionView();
        hcv.showRoot = tree.showRoot;
        hcv.openNodes = openItems;
        hcv.source = hd;
        hcv.addEventListener(CollectionEvent.COLLECTION_CHANGE, expandHandler);
        this.openItems = openItems;
        this.uidFunction = uidFunction;
        return hcv;
    }

    /**
     *  @see mx.controls.treeClasses.ITreeDataDescriptor#getNodeDepth
     */
    public function getNodeDepth(node:Object, iterator:IViewCursor, model:Object = null):int
    {
        if (node == iterator.current)
        {
            var depth:int = hd.getNodeDepth(node);
            return depth;
        }
        return -1;
    }

    /**
     *  @see mx.controls.treeClasses.ITreeDataDescriptor#getParent
     */
    public function getParent(node:Object, collection:ICollectionView, model:Object = null):Object
    {
        return hd.getParent(node);
    }

    private function expandHandler(event:CollectionEvent):void
    {
        if (event.kind == CollectionEventKind.mx_internal::EXPAND)
        {
            var item:Object = event.items[0];
            var uid:String = uidFunction(item);
            if (openItems[uid] != null)
            {
                hcv.openNode(item);
            }
            else
                hcv.closeNode(item);
            event.stopImmediatePropagation();
        }
    }

    public function get hierarchicalData():HierarchicalData
    {
        return hd;
    }

    public function get hierarchicalCollectionView():HierarchicalCollectionView
    {
        return hcv;
    }
}

}
