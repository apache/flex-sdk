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

package mx.controls.fileSystemClasses
{
	
import flash.filesystem.File;
import mx.controls.treeClasses.DefaultDataDescriptor;
import mx.collections.ArrayCollection;
import mx.collections.ICollectionView;
import mx.controls.fileSystemClasses.FileSystemControlHelper;
import mx.core.mx_internal;

use namespace mx_internal;

[ExcludeClass]

/**
 *  @private
 * 
 *  The FileSystemTreeDataDescriptor implements the
 *  <code>dataDescriptor</code> used by a FileSystemTree.
 *  This data descriptor enables it to display a hierarchical
 *  view of File instances representing directories and files
 *  despite the fact that a File instance doesn't have a property
 *  such as <code>children</code> that can be used to tie
 *  such instances together into a hierarchical data structure.
 * 
 *  <p>We could have chosen to create a subclass of File,
 *  or a wrapper class, which adds such a property;
 *  but every time a directory was enumerated
 *  we would have to turn the File instances
 *  we get into instances of this other class.
 *  Instead, each time a node in FileSystemTree is opened,
 *  we enumerate that subdirectory and
 *  store the resulting child collection in a map
 *  that maps parents to their immediate children.
 *  This descriptor class makes the resulting multiple
 *  linear ArrayCollections displaying by a tree control.
 */
public class FileSystemTreeDataDescriptor extends DefaultDataDescriptor
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function FileSystemTreeDataDescriptor()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

	/**
	 *  @private
	 * 
	 *  Maps nativePath (String) -> childItems (ArrayCollection).
	 */
	mx_internal var parentToChildrenMap:Object = {};
	
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

	/**
	 *  @private
	 */
    override public function getChildren(node:Object,
                                         model:Object = null):ICollectionView
    {
        return parentToChildrenMap[node.nativePath];
    }

	/**
	 *  @private
	 */
    override public function isBranch(node:Object, model:Object = null):Boolean
    {
        return File(node).isDirectory;
    }
    
	/**
	 *  @private
	 */
    override public function hasChildren(node:Object,
    									 model:Object = null):Boolean
    {
        var childCollection:ArrayCollection =
        	parentToChildrenMap[node.nativePath];
        	
        return childCollection != null && childCollection.length > 0;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    public function reset():void
    {
    	parentToChildrenMap = {};
    }
    
    /**
     *  @private
     */
    public function setChildren(node:Object, children:ArrayCollection):void
    {
    	parentToChildrenMap[node.nativePath] = children;
    }
}

}
