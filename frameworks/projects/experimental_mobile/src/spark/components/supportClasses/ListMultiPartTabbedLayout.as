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
import spark.components.itemRenderers.IItemPartRendererBase;
import spark.utils.UIComponentUtils;

/** @private
 *    this class is reponsible for laying out grid cells in a given MobileGrid row.
 *    It will make sure that cell content is aligned according to the column widths.
 */
public class ListMultiPartTabbedLayout extends ListMultiPartLayoutBase
{

    public function ListMultiPartTabbedLayout(target:ListMultiPartItemRendererBase)
    {
        super(target);
    }

    override public function measure():void
    {
        super.measure();
        var totalWidth:Number = 0;
        for each (var ld:IPartRendererDescriptor in partRendererDescriptors)
        {
            totalWidth += ld.scaledWidth;
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

        var desc:IPartRendererDescriptor;
        var dpr:IItemPartRendererBase;
        var remainingWidth:Number = unscaledWidth;
        var curX:Number = cellPaddingLeft;
        var curY:Number = paddingTop;
        var partWidth:Number;
        var partHeight:Number;
        var count:int = partRenderers.length - 1;
        for (var i:int = 0; i <= count; i++)
        {
            dpr = partRenderers[i];
            desc = partRendererDescriptors[i];
            partHeight = dpr.getPreferredBoundsHeight();
            partWidth = Math.max(0, i == count ? remainingWidth : desc.scaledWidth - cellPaddingLeft - cellPaddingRight);
            setElementSize(dpr, partWidth, partHeight);
            setElementPosition(dpr, curX, curY + UIComponentUtils.offsetForCenter(partHeight, cellHeight));
            curX += partWidth + cellPaddingRight + cellPaddingLeft;
            remainingWidth -= desc.scaledWidth;
        }
    }
}
}
