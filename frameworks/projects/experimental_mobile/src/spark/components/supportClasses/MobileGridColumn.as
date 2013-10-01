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

import flash.events.IEventDispatcher;

import mx.utils.ObjectUtil;

import spark.collections.SortField;

/**
 *  The MobileGridColumn class defines  a column to display in a MobileGrid control.
 * <p> The MobileGridColumn class specifies the characteristics of the column to display,
 * such as the field of the data provider item whose value is to be displayed in the column.
 * MobileGridColumn takes most of its properties  from its parent class and adds the following Grid-specific options:</p>
 * <ul>
 *     <li>headerText and headerStyleName: optional label and style to display in the header for this column </li>
 *     <li>sortable, sortDescending and sortField: sorting options for this column </li>
 *  </ul>
 *
 *  @see spark.components.MobileGrid
 *  @see spark.components.supportClasses.PartRendererDescriptorBase
 *
 *  @langversion 3.0
 *  @playerversion AIR 3.8
 *  @productversion Flex 4.11
 */
public class MobileGridColumn extends PartRendererDescriptorBase
{

    private var _headerText:String = null;
    private var _headerStyleName:String;
    private var _sortDescending:Boolean;
    private var _sortable:Boolean = true;

    public function MobileGridColumn(target:IEventDispatcher = null)
    {
        super(target);
        labelFunction = null;
        setWidth(100); // default width;
        itemRenderer = null; // will set default ;
    }

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

    /** Defines the css style name to be used for displaying this column's header label.
     * <p>Use this property to display the header in a different color or font, or with a different text alignment.</p>
     */
    public function get headerStyleName():String
    {
        return _headerStyleName;
    }

    public function set headerStyleName(value:String):void
    {
        _headerStyleName = value;
    }

    /** Flag indicating whether a column can be sorted by clicking on its header.
     *  <p>This flag is effective only if the MobileGrid </p>
     */
    public function get sortable():Boolean
    {
        return _sortable;
    }

    public function set sortable(value:Boolean):void
    {
        _sortable = value;
    }

    public function get sortDescending():Boolean
    {
        return _sortDescending;
    }

    public function set sortDescending(value:Boolean):void
    {
        _sortDescending = value;
    }

    //----------------------------------
    //  sortField
    //----------------------------------

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


}
}
