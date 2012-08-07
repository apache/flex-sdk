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


import mx.collections.HierarchicalData;
import mx.collections.HierarchicalCollectionView;
import mx.collections.HierarchicalCollectionViewCursor;
import mx.collections.XMLListCollection;

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
public class TreeHierarchicalData extends HierarchicalData
{
    /**
     *  Constructor
     */
    public function TreeHierarchicalData(value:Object = null)
    {
        super(value);
    }

    override public function hasChildren(node:Object):Boolean
    {
        if (node == null)
        {
            if (source is XMLList)
                node = source[0];
            else if (source is XMLListCollection)
                node = source.source[0];
        }
        return super.hasChildren(node);
    }

    override public function getChildren(node:Object):Object
    {
        if (node == null)
        {
            if (source is XMLList)
                node = source[0];
            else if (source is XMLListCollection)
                node = source.source[0];
        }
        return super.getChildren(node);
    }

	// tree expects top-level children to return null
    override public function getParent(node:Object):*
    {
		var top:Object;

        if (source is XMLList)
            top = source[0].parent();
        else if (source is XMLListCollection)
            top = source.source[0];

		var parent:Object = super.getParent(node);

		if (parent === top)
			return undefined;
		
		return parent;
    }

}

}
