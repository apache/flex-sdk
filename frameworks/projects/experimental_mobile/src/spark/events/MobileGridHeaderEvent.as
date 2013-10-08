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
package spark.events
{
import flash.events.Event;

[Experimental]

/**
 *  The MobileGridHeaderEvent class represents events that are dispatched when
 the user clicks  on the header of a column in the DataGrid to sort it.
 *
 *  @see spark.components.MobileGrid
 *
 *  @langversion 3.0
 *  @playerversion AIR 3.8
 *  @productversion Flex 4.11
 */

//   Note: we didn't use neither mx:DataGridEvent because it's in not available for mobile not GridSortEvent because it handles multiple sorting
public class MobileGridHeaderEvent extends Event
{

    public static const SORT_CHANGE:String = "sortChange";

    private var _columnIndex:int;

    public function MobileGridHeaderEvent(type:String, pindex:int, bubbles:Boolean = false, cancelable:Boolean = false)
    {
        super(type, bubbles, cancelable);
        this._columnIndex = pindex;
    }

    public function get columnIndex():int
    {
        return _columnIndex;
    }

    override public function clone():Event
    {
        return new MobileGridHeaderEvent(type, columnIndex, bubbles, cancelable);
    }
}
}
