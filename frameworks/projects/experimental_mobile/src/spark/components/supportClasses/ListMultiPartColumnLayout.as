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
import mx.core.IFlexDisplayObject;
import mx.core.ILayoutElement;
import mx.core.mx_internal;

import spark.components.itemRenderers.IMobileGridCellRenderer;
import spark.core.IGraphicElement;

use namespace  mx_internal;

// for asdoc
[Experimental]

/** @private
 *    this class is responsible for laying out grid cells in a given MobileGrid row.
 *    It will make sure that cell content is aligned according to the column widths.
 */
public class ListMultiPartColumnLayout extends Object
{
    public function ListMultiPartColumnLayout(target:MobileGridRowRenderer)
    {
        _target = target;
    }

    private var _target:MobileGridRowRenderer;

    public function get target():MobileGridRowRenderer
    {
        return _target;
    }

    protected function get partRendererDescriptors():Vector.<MobileGridColumn>
    {
        return target.columns;
    }

    protected function get graphicElementPartRenderers():Vector.<IGraphicElement>
    {
        return target.graphicElementPartRenderers;
    }

    protected function get partRenderers():Vector.<IMobileGridCellRenderer>
    {
        return target.partRenderers;
    }

    public function measure():void
    {

    }


    /* vertical align middle
     * Layout algorithm:   give all columns the requested sizes, and the last column the remaining width  */

    public function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
    {

        if (unscaledWidth == 0 && unscaledHeight == 0)
            return;   // not ready
        var cellPaddingLeft:Number = target.getStyle("paddingLeft");
        var cellPaddingRight:Number = target.getStyle("paddingRight");
        var paddingTop:Number = target.getStyle("paddingTop");
        var paddingBottom:Number = target.getStyle("paddingBottom");
        var cellHeight:Number = unscaledHeight - paddingTop - paddingBottom;

        var desc:MobileGridColumn;
        var dpr:IMobileGridCellRenderer;
        var curX:Number = cellPaddingLeft;
        var curY:Number = paddingTop;
        var colWidth:Number;
        var partWidth:Number;
        var partHeight:Number;
        var count:int = partRenderers.length - 1;
        for (var i:int = 0; i <= count; i++)
        {
            dpr = partRenderers[i];
            desc = partRendererDescriptors[i];
            colWidth = desc.actualWidth;
            if (dpr.canSetContentWidth)
            {
                // expand last column to fill width, unless it has explicity width
                partWidth = Math.max(0, colWidth - cellPaddingLeft - cellPaddingRight);
            }
            else
            {
                partWidth = dpr.getPreferredBoundsHeight();
            }
            partHeight = dpr.canSetContentHeight ? cellHeight : dpr.getPreferredBoundsHeight();
            setElementSize(dpr, partWidth, partHeight);
            setElementPosition(dpr, curX, curY + ( cellHeight - partHeight) / 2 );
            curX += colWidth;
        }
    }

    /* layout helper  methods */

    protected function setElementPosition(element:Object, x:Number, y:Number):void
    {
        if (element is ILayoutElement)
        {
            ILayoutElement(element).setLayoutBoundsPosition(x, y, false);
        }
        else if (element is IFlexDisplayObject)
        {
            IFlexDisplayObject(element).move(x, y);
        }
        else
        {
            element.x = x;
            element.y = y;
        }
    }

    protected function setElementSize(element:Object, width:Number, height:Number):void
    {
        if (element is ILayoutElement)
        {
            ILayoutElement(element).setLayoutBoundsSize(width, height, false);
        }
        else if (element is IFlexDisplayObject)
        {
            IFlexDisplayObject(element).setActualSize(width, height);
        }
        else
        {
            element.width = width;
            element.height = height;
        }
    }

    protected function getElementPreferredWidth(element:Object):Number
    {
        var result:Number;

        if (element is ILayoutElement)
        {
            result = ILayoutElement(element).getPreferredBoundsWidth();
        }
        else if (element is IFlexDisplayObject)
        {
            result = IFlexDisplayObject(element).measuredWidth;
        }
        else
        {
            result = element.width;
        }

        return Math.round(result);
    }

    protected function getElementPreferredHeight(element:Object):Number
    {
        var result:Number;

        if (element is ILayoutElement)
        {
            result = ILayoutElement(element).getPreferredBoundsHeight();
        }
        else if (element is IFlexDisplayObject)
        {
            result = IFlexDisplayObject(element).measuredHeight;
        }
        else
        {
            result = element.height;
        }

        return Math.ceil(result);
    }
}
}
