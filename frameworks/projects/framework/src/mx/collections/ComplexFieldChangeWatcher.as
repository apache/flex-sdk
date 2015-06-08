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

package mx.collections {
    import flash.events.EventDispatcher;

    import mx.binding.utils.BindingUtils;
    import mx.binding.utils.ChangeWatcher;
    import mx.events.PropertyChangeEvent;

    public class ComplexFieldChangeWatcher extends EventDispatcher {

        private var _complexFieldWatchers:Vector.<ChangeWatcher> = new Vector.<ChangeWatcher>();
        private var _list:IList;

        public function stopWatchingForComplexFieldChanges():void
        {
            for each(var watcher:ChangeWatcher in _complexFieldWatchers)
            {
                watcher.unwatch();
            }

            _complexFieldWatchers.length = 0;
        }

        public function startWatchingForComplexFieldChanges(list:IList, fields:Array):void
        {
            _list = list;

            for(var i:int = 0; i < fields.length; i++)
            {
                var sortField:IComplexSortField = fields[i] as IComplexSortField;
                if(sortField && sortField.nameParts)
                {
                    for(var j:int = 0; j < _list.length; j++)
                    {
                        var item:Object = _list.getItemAt(j);
                        if(item)
                        {
                            var watcher:ChangeWatcher = BindingUtils.bindSetter(function(value:Object):void {}, item, sortField.nameParts);
                            if(watcher)
                            {
                                watcher.setHandler(new Closure(item, complexValueChanged).callFunctionOnObject);
                                _complexFieldWatchers.push(watcher);
                            }
                        }
                    }
                }
            }
        }

        private function complexValueChanged(item:Object):void
        {
            dispatchEvent(PropertyChangeEvent.createUpdateEvent(item, null, null, null));
        }
    }
}

import flash.events.Event;

class Closure
{
    private var _object:Object;
    private var _function:Function;

    public function Closure(cachedObject:Object, cachedFunction:Function)
    {
        _object = cachedObject;
        _function = cachedFunction;
    }

    public function callFunctionOnObject(event:Event):void
    {
        _function.apply(null, [_object]);
    }
}