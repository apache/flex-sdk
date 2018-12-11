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
package spark.components.itemRenderers
{

import mx.core.mx_internal;
import mx.graphics.BitmapFillMode;
import mx.styles.IStyleClient;

import spark.primitives.BitmapImage;

use namespace mx_internal;

[Experimental]

/** Default lightweight  class for rendering embedded Bitmaps  or Multi-DPI Bitmaps in a MobileGrid cell .
 *You define the icon to be used in each cell by setting either iconField or iconFunction properties.
 *
 *  @langversion 3.0
 *  @playerversion AIR 3.8
 *  @productversion Flex 4.11
 *
 *  */
public class MobileGridBitmapCellRenderer extends BitmapImage implements IMobileGridCellRenderer
{

    private var _iconFunction:Function = null;
    private var _iconField:String = null;
    protected var _data:Object;

    public function MobileGridBitmapCellRenderer()
    {
        super();
        _fillMode = BitmapFillMode.REPEAT; // do not stretch
    }

    /**
     *  The name of the field or property in the DataGrid's dataProvider item that defines the icon to display for this renderer's column.
     *  <p> The field value must be either an embedded bitmap's class, or a MultiBitmapSource object.   </p>
     *   <p> If not set, then iconFunction will be used.  </p>
     *  @default null
     *
     *  @see #iconFunction
     *  @see  spark.utils.MultiDPIBitmapSource
     *
     */
    public function get iconField():String
    {
        return _iconField;
    }

    public function set iconField(value:String):void
    {
        _iconField = value;
    }

    /**
     *  An user-provided function that converts a data provider item into an icon to display in each cell for this renderer's column.
     *
     *  <p>if set, this property is used even if iconField is also set.</p>
     *  <p>The function specified to the <code>iconFunction</code> property
     *  must have the following signature:</p>
     *
     *  <pre>iconFunction(item:Object):Object</pre>
     *
     *  <p>The <code>item</code> parameter is the data provider item for an entire row.</p>
     *  <p> The function must return either an embedded bitmap's class, or a MultiBitmapSource object .</p>
     *
     *  @default null
     *
     *  @see #iconField
     *  @see  spark.utils.MultiDPIBitmapSource
     *
     */
    public function get iconFunction():Function
    {
        return _iconFunction;
    }

    public function set iconFunction(value:Function):void
    {
        _iconFunction = value;
    }

    /**
     *  @inheritDoc
     */
    public function set data(value:Object):void
    {
        _data = value;
        var iconSource:Object = _iconFunction != null ? _iconFunction(_data) : _data[_iconField];
        this.source = iconSource;
    }

    /**
     *  @inheritDoc
     */
    public function get data():Object
    {
        return _data;
    }

    /**
     *  @inheritDoc
     */
    public function set styleProvider(value:IStyleClient):void
    {
        // do nothing, this renderer does not manages styles for now.
    }

    /**
     *  @inheritDoc
     */
    public function set cssStyleName(value:String):void
    {

    }

    /**
     *  Returns false to avoid any density scaling artifacts.
     *   @inheritDoc
     *  */
    public function get canSetContentWidth():Boolean
    {
        return false;
    }

    /**
     *  Returns false to avoid any density scaling artifacts.
     *   @inheritDoc
     *  */
    public function get canSetContentHeight():Boolean
    {
        return false;
    }
}
}
