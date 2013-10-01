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
package spark.components.supportClasses
{
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import mx.core.ClassFactory;
import mx.core.DPIClassification;
import mx.core.IFactory;
import mx.core.mx_internal;

import spark.components.itemRenderers.IItemPartRendererBase;
import spark.components.itemRenderers.IItemTextPartRenderer;
import spark.components.itemRenderers.ItemTextPartRenderer;
import spark.utils.DensityUtil2;

/**  This is the base class for GridColumn
 *
 */
public class PartRendererDescriptorBase extends EventDispatcher implements IPartRendererDescriptor
{

    private var _colNum:int;
    private var _dataField:String;
    private var _width:Number;
    private var _scaledWidth:Number;
    private var _itemRenderer:IFactory;
    private var _labelFunction:Function;
    private var _styleName:String;
    private var _textAlign:String;

    public function PartRendererDescriptorBase(target:IEventDispatcher = null)
    {
        super(target);
        _labelFunction = null;
        width = 100; // default width;
        itemRenderer = null; // will set default ;
    }

    /* IDataGridColumn impl*/

    public function set dataField(value:String):void
    {
        _dataField = value;
    }

    public function get dataField():String
    {
        return _dataField;
    }

    public function get labelFunction():Function
    {
        return _labelFunction;
    }

    /**
     *  An idempotent function that converts a data provider item into a column-specific string
     *  that's used to initialize the item renderer's <code>label</code> property.
     *
     *  <p>You can use a label function to combine the values of several data provider items
     *  into a single string.
     *  If specified, this property is used by the
     *  <code>itemToLabel()</code> method, which computes the value of each item
     *  renderer's <code>label</code> property in this column.</p>
     *
     *  <p>The function specified to the <code>labelFunction</code> property
     *  must have the following signature:</p>
     *
     *  <pre>labelFunction(item:Object):String</pre>
     *
     *  <p>The <code>item</code> parameter is the data provider item for an entire row.
     *  The second parameter is this column object.</p>
     *
     *  <p>A typical label function could concatenate the firstName and
     *  lastName properties of the data provider item ,
     *  or do some custom formatting on a Date value property.</p>
     */
    public function set labelFunction(value:Function):void
    {
        _labelFunction = value;
    }

    public function set styleName(value:String):void
    {
        _styleName = value;
    }

    /** set the desired width of the column at the application's current DPI (or 160 if none)
     * default value is 100
     * the actual pixel width maybe higher if the runtimeDPI or application DPI  are different than 160
     *
     * @param value = desired width of the column at 160 DPI
     */
    public function set width(value:Number):void
    {
        _width = value;
        _scaledWidth = DensityUtil2.dpiScale(value, DPIClassification.DPI_160);
    }

    /** set the desired width of the column at the application's current DPI (or 160 if none)
     * default value is 100
     * the actual pixel width maybe higher if the runtimeDPI or application DPI  are different than 160
     *
     * @param value = desired width of the column at 160 DPI
     */
    public function set widthAt160DPI(value:Number):void
    {
        _width = value;
        _scaledWidth = DensityUtil2.dpiScale(value, DPIClassification.DPI_160);
    }

    public function get scaledWidth():Number
    {
        return  _scaledWidth;
    }

    mx_internal function get colNum():int
    {
        return _colNum;
    }

    mx_internal function set colNum(value:int):void
    {
        _colNum = value;
    }

    public function get itemRenderer():IFactory
    {
        return _itemRenderer;
    }

    public function set itemRenderer(value:IFactory):void
    {
        _itemRenderer = value ? value : new ClassFactory(ItemTextPartRenderer);
    }

    public function get styleName():String
    {
        return _styleName;
    }

    [Inspectable(enumeration="left,right,center,justify")]
    public function set textAlign(value:String):void
    {
        _textAlign = value;
    }

    public function createPartRenderer():IItemPartRendererBase
    {
        var pr:IItemPartRendererBase = _itemRenderer.newInstance() as IItemPartRendererBase;
        if (pr)
        {
            pr.cssStyleName = _styleName;
            if (pr is IItemTextPartRenderer)  {
                with( IItemTextPartRenderer(pr)){
                    labelField = _dataField;
                    labelFunction = _labelFunction;
                    textAlign = _textAlign;
                }
            }
        }
        return pr;
    }

}
}
