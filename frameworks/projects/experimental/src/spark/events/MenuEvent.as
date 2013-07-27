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
package spark.events {
    import flash.events.Event;

    import spark.components.List;
    import spark.components.Menu;

    /**
     * @author Bogdan Dinu (http://www.badu.ro)
     */
    public class MenuEvent extends IndexChangeEvent {
        public static const SELECTED:String = "selected";
        public static const CHECKED:String = "checked";

        public var menu:List;
        public var item:Object;

        public function MenuEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, owner:List = null, selectedItem:Object = null) {
            super(type, bubbles, cancelable);
            menu = owner;
            item = selectedItem;
        }

        override public function clone():Event {
            return new MenuEvent(type, bubbles, cancelable, menu, item);
        }

        public static function convert(event:IndexChangeEvent, menu:Menu, item:Object):Event {
            return new MenuEvent(event.type, event.bubbles, event.cancelable, menu, item);
        }
    }
}
