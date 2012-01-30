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

import mx.core.mx_internal;

use namespace mx_internal;

[ExcludeClass]

/**
 *  @private
 */
public class ArrayElementWatcher extends Watcher
{
    include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

    /**
	 *  @private
	 *  Constructor
	 */
    public function ArrayElementWatcher(document:Object,
                                        accessorFunc:Function,
                                        listeners:Array)
    {
		super(listeners);

        this.document = document;
        this.accessorFunc = accessorFunc;
    }

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

    /**
	 *  @private
	 */
	private var document:Object;
    
    /**
	 *  @private
	 */
	private var accessorFunc:Function;

    /**
	 *  @private
	 */
    public var arrayWatcher:Watcher;

	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

    /**
	 *  @private
	 */
    override public function updateParent(parent:Object):void
    {
        if (arrayWatcher.value != null)
        {
            wrapUpdate(function():void
			{
				value = arrayWatcher.value[accessorFunc.apply(document)];
				updateChildren();
			});
        }
    }

    /**
	 *  @private
	 */
    override protected function shallowClone():Watcher
    {
        return new ArrayElementWatcher(document, accessorFunc, listeners);
    }
}

}
