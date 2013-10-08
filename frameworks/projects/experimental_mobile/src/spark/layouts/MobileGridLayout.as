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
package spark.layouts
{
import mx.core.mx_internal;

import spark.components.MobileGrid;
import spark.components.supportClasses.MobileGridColumn;
import spark.utils.MobileGridUtil;

use namespace  mx_internal;

[Experimental]

/**
 * Internal class used for laying out rows, columns and headers of a MobileGrid component.
 *
 *  @langversion 3.0
 *  @playerversion AIR 3.8
 *  @productversion Flex 4.11
 */
public class MobileGridLayout extends VerticalLayout
{
    public function MobileGridLayout(grid:MobileGrid)
    {
        super();
        _grid = grid;
    }

    private var prevUnscaledWidth:Number;
    private var _grid:MobileGrid;

    override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        if (prevUnscaledWidth != unscaledWidth)
        {
            prevUnscaledWidth = unscaledWidth;
            updateColumnWidths(unscaledWidth);
        }
    }

    /**   compute colum actual widths from colum width and percentWidth
     *     simple algorithm is following:
     *     first set all columns that have fixed width
     *     set distribute the remainder between the percentages, normalized to 100%
     *
     * @param unscaledWidth
     */
    protected function updateColumnWidths(unscaledWidth:Number):void
    {
        if (unscaledWidth == 0)
            return;   // not ready

        var colWidth:Number;
        var colActualWidth:Number;

        var totalFixedWidths:Number = 0;
        var totalPercentages:Number = 0;
        var cols:Array = _grid.columns;
        var col:MobileGridColumn;

        for (var i:int = 0; i < cols.length; i++)
        {
            col = cols[i];
            if (!isNaN(col.percentWidth))
            {
                totalPercentages += col.percentWidth;
            }
            else
            {
                colWidth = isNaN(col.width) ? 100 : col.width;
                colActualWidth = MobileGridUtil.dpiScale(colWidth);
                col.actualWidth = colActualWidth; // can immediately set actual width
                totalFixedWidths += colActualWidth;
            }
        }

        // distribute remainder to percent widths
        var remainingWidth:Number = Math.max(0, unscaledWidth - totalFixedWidths);
        var normalPercentWidth:Number;
        for (var j:int = 0; j < cols.length; j++)
        {
            col = cols[j];
            if (!isNaN(col.percentWidth))
            {
                normalPercentWidth = col.percentWidth / totalPercentages;
                /* 0 .. 1*/
                col.actualWidth = remainingWidth * normalPercentWidth;
            }
        }

        // update also datagrid header ;
        _grid.headerGroup.updateHeaderWidths();

    }

}
}
