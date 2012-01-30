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

import flash.events.Event;
import mx.core.mx_internal;

use namespace mx_internal;

[ExcludeClass]

/**
 *  @private
 */
public class RepeaterComponentWatcher extends PropertyWatcher
{
    include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
     *
     *  Create a RepeaterComponentWatcher
     *
     *  @param prop The name of the property to watch.
     *  @param event The event type that indicates the property has changed.
     *  @param listeners The binding objects that are listening to this Watcher.
     *  @param propertyGetter A helper function used to access non-public variables.
	 */
    public function RepeaterComponentWatcher(propertyName:String,
                                             events:Object,
                                             listeners:Array,
                                             propertyGetter:Function = null)
    {
		super(propertyName, events, listeners, propertyGetter);
    }

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

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
    override public function updateChildren():void
    {
        if (original)
        {
            updateClones();
        }
        else
        {
            super.updateChildren();
        }
    }

	/**
	 *  @private
	 */
    override protected function shallowClone():Watcher
    {
        return new RepeaterComponentWatcher(propertyName, events, listeners, propertyGetter);
    }

	/**
	 *  @private
	 */
    private function updateClones():void
    {
        var components:Array = value as Array;

        if (components)
        {
            if (clones)
                clones = clones.splice(0, components.length);
            else
                clones = [];

            for (var i:int = 0; i < components.length; i++)
            {
                var clone:RepeaterComponentWatcher = RepeaterComponentWatcher(clones[i]);
                
                if (!clone)
                {
                    clone = RepeaterComponentWatcher(deepClone(i));
                    clone.original = false;
                    clones[i] = clone;
                }

                clone.value = components[i];
                clone.updateChildren();
            }
        }
    }

	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------

    /**
     *  Invokes super's notifyListeners() on each of the clones.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function notifyListeners(commitEvent:Boolean):void
    {
        if (original)
        {
            if (clones)
            {
                for (var i:int = 0; i < clones.length; i++)
                {
                    RepeaterComponentWatcher(clones[i]).notifyListeners(commitEvent);
                }
            }
        }

        super.notifyListeners(commitEvent);
    }
}

}
