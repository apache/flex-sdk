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

    import mx.binding.utils.ChangeWatcher;
    import mx.core.mx_internal;
    import mx.events.CollectionEvent;
    import mx.events.CollectionEventKind;
    import mx.events.PropertyChangeEvent;

    public class ComplexFieldChangeWatcher extends EventDispatcher {

        private var _complexFieldWatchers:Vector.<ChangeWatcher> = new Vector.<ChangeWatcher>();
        private var _list:IList;
        private var _listCollection:ICollectionView;

        public function stopWatchingForComplexFieldChanges():void
        {
            unwatchListForChanges();

            for each(var watcher:ChangeWatcher in _complexFieldWatchers)
            {
                watcher.unwatch();
            }

            _complexFieldWatchers.length = 0;
        }

        public function startWatchingForComplexFieldChanges():void
        {
            watchListForChanges();

            watchItems(list);
        }

        private function watchItems(items:IList):void
        {
            if(sortFields)
            {
                for(var i:int = 0; i < items.length; i++)
                {
                    watchItem(items.getItemAt(i), sortFields);
                }
            }
        }

        private function watchArrayOfItems(items:Array):void
        {
            if(sortFields)
            {
                for(var i:int = 0; i < items.length; i++)
                {
                    watchItem(items[i], sortFields);
                }
            }
        }

        private function watchItem(item:Object, sortFields:Array):void
        {
            if(item)
            {
                for(var i:int = 0; i < sortFields.length; i++)
                {
                    var sortField:IComplexSortField = sortFields[i] as IComplexSortField;
                    if(sortField && sortField.nameParts)
                    {
                        watchItemForField(item, sortField.nameParts);
                    }
                }
            }
        }

        private function watchItemForField(item:Object, chain:Array):void
        {
            var watcher:ChangeWatcher = ChangeWatcher.watch(item, chain, new Closure(item, onComplexValueChanged).callFunctionOnObject, false, true);
            if(watcher)
            {
                _complexFieldWatchers.push(watcher);
            }
        }

        private function onCollectionChanged(event:CollectionEvent):void
        {
            switch(event.kind)
            {
                case CollectionEventKind.ADD: {
                    watchArrayOfItems(event.items);
                    break;
                }
            }
        }

        private function onComplexValueChanged(item:Object):void
        {
            dispatchEvent(PropertyChangeEvent.createUpdateEvent(item, null, null, null));
        }

        private function get sortFields():Array
        {
            return _listCollection && _listCollection.sort ? _listCollection.sort.fields : null;
        }

        mx_internal function set list(value:IList):void
        {
            if(_list != value)
            {
                stopWatchingForComplexFieldChanges();

                _list = value;
                _listCollection = value as ICollectionView;
            }
        }

        protected function get list():IList
        {
            return _list;
        }

        private function watchListForChanges():void
        {
            if(list)
                list.addEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChanged, false, 0, true);
        }

        private function unwatchListForChanges():void
        {
            if(list)
                list.removeEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChanged);
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