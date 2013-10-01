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
import mx.core.mx_internal;

import spark.components.itemRenderers.IItemPartRendererBase;
import spark.utils.UIComponentUtils;

use namespace  mx_internal;

/** @private
 *    this class is responsible for laying out grid cells in a given MobileGrid row.
 *    It will make sure that cell content is aligned according to the column widths.
 */
public class ListMultiPartColumnLayout extends ListMultiPartLayoutBase
{

    public function ListMultiPartColumnLayout(target:ListMultiPartItemRendererBase)
    {
        super(target);
    }

    override public function measure():void
    {
        super.measure();
        var totalWidth:Number = 0;
        for each (var ld:PartRendererDescriptorBase in partRendererDescriptors)
        {
            totalWidth += ld.dpiScaledWidth;
        }
        target.measuredWidth = totalWidth;
        target.measuredMinWidth = 50;
    }

    /* vertical align middle
     * Layout algorithm:   give all columns the requested sizes, and the last column the remaining width  */
    override public function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
    {

        if (unscaledWidth == 0 && unscaledHeight == 0)
            return;   // not ready
        var cellPaddingLeft:Number = target.getStyle("paddingLeft");
        var cellPaddingRight:Number = target.getStyle("paddingRight");
        var paddingTop:Number = target.getStyle("paddingTop");
        var paddingBottom:Number = target.getStyle("paddingBottom");
        var cellHeight:Number = unscaledHeight - paddingTop - paddingBottom;

        var desc:PartRendererDescriptorBase;
        var dpr:IItemPartRendererBase;
        var remainingWidth:Number = unscaledWidth;
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
            colWidth = desc.dpiScaledWidth;
            if (dpr.canSetWidth)
            {
                // expand last column to fill width, unless it has explicity width
                partWidth = Math.max(0, ( i == count && !desc.hasExplicitWidth) ? remainingWidth : colWidth - cellPaddingLeft - cellPaddingRight);
            }
            else
            {
                partWidth = dpr.getPreferredBoundsHeight();
            }
            partHeight = dpr.canSetHeight ? cellHeight : dpr.getPreferredBoundsHeight();
            ;
            setElementSize(dpr, partWidth, partHeight);
            setElementPosition(dpr, curX, curY + UIComponentUtils.offsetForCenter(partHeight, cellHeight));
            curX += colWidth;
            remainingWidth -= colWidth;
        }
    }
}
}
