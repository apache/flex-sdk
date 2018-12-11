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
package examples.renderers
{
import flash.events.MouseEvent;

import mx.styles.IStyleClient;

import spark.components.Alert;

import spark.components.Button;
import spark.components.itemRenderers.IMobileGridCellRenderer;

public class MyActionButtonPartRenderer extends Button implements IMobileGridCellRenderer
{

    private var _data:Object;

    public function MyActionButtonPartRenderer()
    {
        super();
        label = "Go";
        height=30;
        addEventListener( MouseEvent.CLICK, onClick);
    }

    public function set styleProvider(value:IStyleClient):void
    {
    }

    public function get canSetContentWidth():Boolean
    {
        return true;
    }

    public function get canSetContentHeight():Boolean
    {
        return false;
    }

    public function set cssStyleName(value:String):void
    {
    }

    public function get data():Object
    {
        return _data;
    }

    public function set data(value:Object):void
    {
        _data = value;
    }

    private function onClick(event:MouseEvent):void
    {
        Alert.show("Click on: " + data.Name, "Action");
    }

}
}
