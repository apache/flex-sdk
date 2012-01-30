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

package mx.binding
{

import mx.collections.CursorBookmark;
import mx.collections.ICollectionView;
import mx.collections.IViewCursor;
import mx.core.mx_internal;
import mx.events.CollectionEvent;

use namespace mx_internal;

[ExcludeClass]

/**
 *  @private
 */
public class RepeaterItemWatcher extends Watcher
{
    include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Constructor.
	 */
    public function RepeaterItemWatcher(dataProviderWatcher:PropertyWatcher)
    {
		super();

        this.dataProviderWatcher = dataProviderWatcher;
    }

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
    private var dataProviderWatcher:PropertyWatcher;

	/**
	 *  @private
	 */
    private var clones:Array;

	/**
	 *  @private
	 */
    private var original:Boolean = true;

	//--------------------------------------------------------------------------
	//
	//  Overridden methods: Watcher
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
    override public function updateParent(parent:Object):void
    {
        var dataProvider:ICollectionView;

        if (dataProviderWatcher)
        {
            dataProvider = ICollectionView(dataProviderWatcher.value);
            if (dataProvider != null)
            {
                dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, changedHandler, false);
            }
        }

        dataProviderWatcher = PropertyWatcher(parent);
        dataProvider = ICollectionView(dataProviderWatcher.value);

        if (dataProvider)
        {
            if (original)
            {
                dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, changedHandler, false, 0, true);
                updateClones(dataProvider);
            }
            else
            {
                wrapUpdate(function():void
                {
                    var iterator:IViewCursor = dataProvider.createCursor();
                    iterator.seek(CursorBookmark.FIRST, cloneIndex);
                    value = iterator.current;
                    updateChildren();
                });
            }
        }
    }

    /**
     *  @private
     *  Handles "Change" events sent by calls to Collection APIs
     *  on the Repeater's dataProvider.
     */
    private function changedHandler(collectionEvent:CollectionEvent):void
    {
        var dataProvider:ICollectionView = ICollectionView(dataProviderWatcher.value);

        if (dataProvider)
            updateClones(dataProvider);
    }

	/**
	 *  @private
	 */
    override protected function shallowClone():Watcher
    {
        return new RepeaterItemWatcher(dataProviderWatcher);
    }

	/**
	 *  @private
	 */
    private function updateClones(dataProvider:ICollectionView):void
    {
        if (clones)
            clones = clones.splice(0, dataProvider.length);
        else
            clones = [];

        for (var i:int = 0; i < dataProvider.length; i++)
        {
            var clone:RepeaterItemWatcher = RepeaterItemWatcher(clones[i]);
                
            if (!clone)
            {
                clone = RepeaterItemWatcher(deepClone(i));
                clone.original = false;
                clones[i] = clone;
            }

            clone.updateParent(dataProviderWatcher);
        }
    }
}

}
