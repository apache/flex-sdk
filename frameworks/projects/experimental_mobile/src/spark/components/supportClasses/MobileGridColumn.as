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
import mx.core.IFactory;
import mx.core.mx_internal;
import mx.utils.ObjectUtil;

import spark.collections.SortField;
import spark.components.itemRenderers.IMobileGridCellRenderer;
import spark.components.itemRenderers.IMobileGridTextCellRenderer;
import spark.components.itemRenderers.MobileGridTextCellRenderer;

[Experimental]

/**
 *  The MobileGridColumn class defines  a column to display in a MobileGrid control.
 * <p> The MobileGridColumn class specifies the characteristics of the column to display,
 * such as the field of the data provider item whose value is to be displayed in the column.
 * MobileGridColumn takes most of its properties  from its parent class and adds the following Grid-specific options:</p>
 * <ul>
 *     <li>headerText and headerStyleName: optional label and style to display in the header for this column.</li>
 *     <li>sortable, sortDescending and sortField: sorting options for this column.</li>
 *  </ul>
 *
 *  @see spark.components.MobileGrid
 *
 *  @langversion 3.0
 *  @playerversion AIR 3.8
 *  @productversion Flex 4.11
 */
public class MobileGridColumn extends EventDispatcher

{
    public function MobileGridColumn(target:IEventDispatcher = null)
    {
        super(target);
        _labelFunction = null;
        itemRenderer = null; // will set default ;
        labelFunction = null;
        itemRenderer = null; // will set default ;
    }

    private var _dataField:String;

    /**
     *  The name of the field or property in the data provider item associated
     *  with the column.
     *  Each GridColumn requires this property or
     *  the <code>labelFunction</code> property to be set
     *  to calculate the displayable text for the item renderer.
     *  If the <code>dataField</code>
     *  and <code>labelFunction</code> properties are set,
     *  the data is displayed using the <code>labelFunction</code> and sorted
     *  using the <code>dataField</code>.

     *  <p>If the column or its grid specifies a <code>labelFunction</code>,
     *  then the dataField is not used.</p>
     *
     *  @default null
     *
     *  @see #labelFunction
     *
     */
    public function get dataField():String
    {
        return _dataField;
    }

    public function set dataField(value:String):void
    {
        _dataField = value;
    }

    /* internal vars */

    private var _width:Number = NaN;


    /** Set the desired width for this column.
     * <p> Width value is expressed in current applicationDPI, or at 160 DPI  if applicationDPI is not set. </p>
     *
     *  <p>Note: You can specify a percentage value in the MXML
     *  <code>width</code> attribute, such as <code>width="50%"</code>,
     *  but you cannot use a percentage value in the <code>width</code>
     *  property in ActionScript.
     *  Use the <code>percentWidth</code> property instead.</p>
     *
     *  @see #percentWidth
     *
     * @default 100
     */
    public function get width():Number
    {
        return _width;
    }

    [PercentProxy("percentWidth")]
    public function set width(value:Number):void
    {
        _width = value;
    }

    private var _percentWidth:Number = NaN;

    /**
     *  Specifies the width of this column as a percentage of the grid's width. Allowed values are 0-100. The default value is NaN.
     *  If set, this property has precedence over the fixed width property.
     *
     *  <p> MobileGrid will compute the column widths as follows:
     *  <ul>
     *      <li> First, honor all columns with fixed widths.  Columns with no width or percentWidth receive a width of 100.</li>
     *      <li> Then distribute the remainder of width between all the columns with percentage widths.
     *      If the total of percentages is greater that 100%, it's will be normalized first..</li>
     *   </ul>
     *  </p>
     *
     * @default NaN
     */
    public function get percentWidth():Number
    {
        return _percentWidth;
    }

    public function set percentWidth(value:Number):void
    {
        _percentWidth = value;
    }

    private var _itemRenderer:IFactory;

    /**
     *  The class factory for the IMobileGridCellRenderer  class used to
     *  render individual grid cells.
     *
     *  <p>The default item renderer is the ItemTextPartRenderer class,
     *  which displays the data item as text, optimized for mobile.  </p>
     *  <p>You can use also ItemBitmapPartRenderer to display embedded bitmaps,
     *  in which case you need to define the iconField or iconFunction </p>
     *  <p>You can also  create custom item renderers by deriving any subclass of UIComponent (eg. s:Button)
     *  and implementing IMobileGridCellRenderer.</p>
     *  <p>For performance reasons  it's preferable that your renderer be written in ActionScript and be as light as possible.</p>
     *
     *  @see #dataField
     *  @see spark.components.itemRenderers.MobileGridTextCellRenderer
     *  @see spark.components.itemRenderers.MobileGridBitmapCellRenderer
     *  @see spark.components.itemRenderers.IMobileGridCellRenderer
     *
     */
    public function get itemRenderer():IFactory
    {
        return _itemRenderer;
    }

    public function set itemRenderer(value:IFactory):void
    {
        _itemRenderer = value ? value : new ClassFactory(MobileGridTextCellRenderer);
    }

    private var _labelFunction:Function;


    /**
     *  An user-defined function that converts a data provider item into a column-specific string
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
     *  <p>The <code>item</code> parameter is the data provider item for an entire row.</p>
     *
     *  <p>A typical label function could concatenate the firstName and
     *  lastName properties of the data provider item ,
     *  or do some custom formatting on a Date value property.</p>
     */
    public function set labelFunction(value:Function):void
    {
        _labelFunction = value;
    }

    public function get labelFunction():Function
    {
        return _labelFunction;
    }

    private var _styleName:String;

    /** The css style name to apply to the renderer.
     * <p>The style items in the css entry will depend on the renderer. For example, text renderers will accept fontSize, color, fontWeight, etc.  </p>
     */
    public function get styleName():String
    {
        return _styleName;
    }

    public function set styleName(value:String):void
    {
        _styleName = value;
    }

    /** Sets the alignment of text renderers.
     * This property is ignored for non-text renderers.
     */
    [Inspectable(enumeration="left,right,center,justify")]
    public function set textAlign(value:String):void
    {
        _textAlign = value;
    }

    private var _textAlign:String;

    private var _headerText:String = null;

    /** Defines the text to be displayed in the column's header.
     * <p>If this property is not set, the header label will use the value  of dataField property instead.</p>
     * @see #dataField
     */
    public function get headerText():String
    {
        return _headerText != null ? _headerText : dataField;
    }

    public function set headerText(value:String):void
    {
        _headerText = value;
    }

    private var _headerStyleName:String;

    /** Defines the css style name to be used for displaying this column's header label.
     * <p>Use this property to display the header in a different color or font, or with a different text alignment.</p>
     */
    [Bindable]
    public function get headerStyleName():String
    {
        return _headerStyleName;
    }

    public function set headerStyleName(value:String):void
    {
        _headerStyleName = value;     // Bindable so will update MobileGridHeader corresponding renderer, magic of ArrayList
    }

    private var _sortDescending:Boolean;

    public function get sortDescending():Boolean
    {
        return _sortDescending;
    }

    public function set sortDescending(value:Boolean):void
    {
        _sortDescending = value;
    }

    private var _sortable:Boolean = true;

    /** Flag indicating whether a column can be sorted by clicking on its header.
     *  <p>This flag is effective only if the MobileGrid sortableColumn is not set or set to true.</p>
     */
    public function get sortable():Boolean
    {
        return _sortable;
    }

    public function set sortable(value:Boolean):void
    {
        _sortable = value;
    }

    /**
     *  Returns a SortField that can be used to sort a collection by this
     *  column's <code>dataField</code>.
     *
     *
     *  <p>If the <code>dataField</code> properties are not defined, but the
     *  <code>labelFunction</code> property is defined, then it assigns the
     *  <code>compareFunction</code> to a closure that does a basic string compare
     *  on the <code>labelFunction</code> applied to the data objects.</p>

     */
    public function get sortField():SortField
    {
        const column:MobileGridColumn = this;

        var sortField:SortField = new SortField(dataField);

        var cF:Function = null;
        if (dataField == null && labelFunction != null)
        {
            // use basic string compare on the labelFunction results
            cF = function (a:Object, b:Object):int
            {
                return ObjectUtil.stringCompare(labelFunction(a), labelFunction(b));
            };
            sortField.compareFunction = cF;
        }
        sortField.descending = column.sortDescending;
        return sortField;
    }

    mx_internal function createPartRenderer():IMobileGridCellRenderer
    {
        var pr:IMobileGridCellRenderer = _itemRenderer.newInstance() as IMobileGridCellRenderer;
        if (pr)
        {
            pr.cssStyleName = _styleName;
            if (pr is IMobileGridTextCellRenderer)
            {
                with (IMobileGridTextCellRenderer(pr))
                {
                    labelField = _dataField;
                    labelFunction = _labelFunction;
                    textAlign = _textAlign;
                }
            }
        }
        return pr;
    }

    mx_internal var colNum:int;
    mx_internal var actualWidth:Number;

}
}
