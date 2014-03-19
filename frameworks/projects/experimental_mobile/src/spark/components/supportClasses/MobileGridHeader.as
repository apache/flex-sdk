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

import mx.collections.ArrayList;
import mx.core.IVisualElement;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.styles.IStyleClient;

import spark.components.ButtonBar;
import spark.components.MobileGrid;
import spark.events.IndexChangeEvent;
import spark.events.MobileGridHeaderEvent;
import spark.utils.MultiDPIBitmapSource;

use namespace  mx_internal;

// for asdoc
[Experimental]

[Event(name="sortChange", type="spark.events.MobileGridHeaderEvent")]

/**  @private
 *    internal class used by MobileGrid to manage and display  the grid's column headers.
 *    It inherits from ButtonBar so that headers can display text and be clicked and forwards header clicks to the MobileGrid for managing sorting.
 *    the default skin for this class is : spark.skins.MobileGridHeaderButtonBarSkin
 *
 *    @see spark.skins.MobileGridHeaderButtonBarSkin
 */
public class MobileGridHeader extends ButtonBar
{

    [Embed(source="../../../../assets/images/mobile320/dg_header_asc.png")]
    private var ascIcon320Cls:Class;

    [Embed(source="../../../../assets/images/mobile320/dg_header_desc.png")]
    private var descIcon320Cls:Class;

    [Embed(source="../../../../assets/images/mobile160/dg_header_asc.png")]
    private var ascIcon160Cls:Class;

    [Embed(source="../../../../assets/images/mobile160/dg_header_desc.png")]
    private var descIcon160Cls:Class;

    protected var descIconCls:MultiDPIBitmapSource;
    protected var ascIconCls:MultiDPIBitmapSource;

    private var _dataGrid:MobileGrid;
    private var _columns:Array;
    private var _sortIndex:int = -1;

    public function MobileGridHeader()
    {
        this.labelField = "headerText";
        this.iconFunction = getIconForButton;
        this.setStyle("iconPlacement", "right");
        this.buttonMode = false;
        this.requireSelection = false;
        addEventListener(IndexChangeEvent.CHANGING, changingHandler);
        descIconCls = new MultiDPIBitmapSource();
        descIconCls.source160dpi = descIcon160Cls;
        descIconCls.source320dpi = descIcon320Cls;
        ascIconCls = new MultiDPIBitmapSource();
        ascIconCls.source160dpi = ascIcon160Cls;
        ascIconCls.source320dpi = ascIcon320Cls;
    }

    public function set columns(value:Array):void
    {
        _columns = value;
        if (_columns)
        {
            dataProvider = new ArrayList(_columns);
        }
        else
        {
            dataProvider = null;
        }
    }

    public function set dataGrid(value:MobileGrid):void
    {
        _dataGrid = value;
    }

    private function changingHandler(event:IndexChangeEvent):void
    {
        event.preventDefault();      // to clear selection
        var i:int = event.newIndex;
        var c:MobileGridColumn = _columns[i];
        if (_dataGrid.sortableColumns && c.sortable)
        {
            var headerEvent:MobileGridHeaderEvent = new MobileGridHeaderEvent(MobileGridHeaderEvent.SORT_CHANGE, c.colNum, false, true);
            // HEADER_RELEASE event is cancelable
            dispatchEvent(headerEvent);
        }
    }

    /* will be sent back by MobileGrid when sort is confirmed */
    mx_internal function setSort(newSortIndex:int, desc:Boolean):void
    {
        var prevSortIndex:int = _sortIndex;
        _sortIndex = newSortIndex;

        // update old and new
        if (prevSortIndex != -1)
            dataProvider.itemUpdated(_columns[prevSortIndex]);
        if (_sortIndex != -1)
            dataProvider.itemUpdated(_columns[_sortIndex]);
    }


    private function getIconForButton(col:MobileGridColumn):Object
    {
        if (col.colNum === _sortIndex)
        {
            return  col.sortDescending ? descIconCls : ascIconCls;
        }
        else
        {
            return null;
        }
    }

    /**
     *  @private
     *  Return the item renderer at the specified index, or null.
     */
    private function getItemRenderer(index:int):IVisualElement
    {
        if (!dataGroup || (index < 0) || (index >= dataGroup.numElements))
            return null;

        return dataGroup.getElementAt(index);
    }

    /**
     *  @private
     */
    override public function updateRenderer(renderer: IVisualElement, itemIndex: int, data: Object): void
    {
        super.updateRenderer(renderer, itemIndex, data);
        IStyleClient(renderer).styleName = MobileGridColumn(data).headerStyleName;
    }

    public function updateHeaderWidths():void
    {
        if (dataProvider.length != _columns.length)
            return; // not ready
        var header:UIComponent;
        for (var i:int = 0; i < _columns.length; i++)
        {
            header = UIComponent(this.getItemRenderer(i));
            header.explicitWidth = _columns[i].actualWidth;
        }
    }
}
}
