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

package mx.managers.systemClasses
{
import flash.events.IEventDispatcher;

[ExcludeClass]

/**
 * @private
 * Simple class to track placeholders for RemotePopups.
 */
public class PlaceholderData extends Object
{
    public function PlaceholderData(id:String, bridge:IEventDispatcher, data:Object)
    {
        this.id = id;
        this.bridge = bridge;
        this.data = data;
    }
    
    public var id:String;               // id of string at this node in the display list
    public var bridge:IEventDispatcher; // bridge to next child application
    public var data:Object;             // either a popup or a bridge to the next application 
}

}