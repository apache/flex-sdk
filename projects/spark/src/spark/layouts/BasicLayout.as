////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package flex.layout
{

import flash.geom.Point;
import flash.geom.Rectangle;

import flex.core.GroupBase;
import flex.intf.ILayoutItem;


/**
 *  Documentation is not currently available.
 */
public class BasicLayout extends LayoutBase
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    private static function constraintsDetermineWidth(layoutItem:ILayoutItem):Boolean
    {
        return !isNaN(layoutItem.percentSize.x) ||
               !isNaN(LayoutItemHelper.getConstraint(layoutItem, "left")) &&
               !isNaN(LayoutItemHelper.getConstraint(layoutItem, "right"));
    }

    private static function constraintsDetermineHeight(layoutItem:ILayoutItem):Boolean
    {
        return !isNaN(layoutItem.percentSize.y) ||
               !isNaN(LayoutItemHelper.getConstraint(layoutItem, "top")) &&
               !isNaN(LayoutItemHelper.getConstraint(layoutItem, "bottom"));
    }

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     */
    public function BasicLayout():void
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    override public function measure():void
    {
        var layoutTarget:GroupBase = target;
        if (!layoutTarget)
            return;

        var width:Number = 0;
        var height:Number = 0;
        var minWidth:Number = 0;
        var minHeight:Number = 0;

        var count:int = layoutTarget.numLayoutItems;
        for (var i:int = 0; i < count; i++)
        {
            var layoutItem:ILayoutItem = layoutTarget.getLayoutItemAt(i);
            if (!layoutItem || !layoutItem.includeInLayout)
                continue;

            var left:Number      = LayoutItemHelper.getConstraint(layoutItem, "left");
            var right:Number     = LayoutItemHelper.getConstraint(layoutItem, "right");
            var top:Number       = LayoutItemHelper.getConstraint(layoutItem, "top");
            var bottom:Number    = LayoutItemHelper.getConstraint(layoutItem, "bottom");

            var extX:Number = 0;
            var extY:Number = 0;

            if (isNaN(left) && isNaN(right) &&
                isNaN(LayoutItemHelper.getConstraint(layoutItem, "horizontalCenter")))
            {
                extX += layoutItem.actualPosition.x;
            }
            else
            {
                extX += isNaN(left) ? 0 : left;
                extX += isNaN(right) ? 0 : right;
            }

            if (isNaN(top) && isNaN(bottom) &&
                isNaN(LayoutItemHelper.getConstraint(layoutItem, "verticalCenter")))
            {
                extY += layoutItem.actualPosition.y;
            }
            else
            {
                extY += isNaN(top) ? 0 : top;
                extY += isNaN(bottom) ? 0 : bottom;
            }

            width = Math.max(width, extX + layoutItem.preferredSize.x);
            height = Math.max(height, extY + layoutItem.preferredSize.y);

            var itemMinWidth:Number = constraintsDetermineWidth(layoutItem) ? layoutItem.minSize.x : layoutItem.preferredSize.x;
            var itemMinHeight:Number = constraintsDetermineHeight(layoutItem) ? layoutItem.minSize.y : layoutItem.preferredSize.y;

            minWidth = Math.max(minWidth, extX + itemMinWidth);
            minHeight = Math.max(minHeight, extY + itemMinHeight);
        }

        layoutTarget.measuredWidth = Math.max(width, minWidth);
        layoutTarget.measuredHeight = Math.max(height, minHeight);

        layoutTarget.measuredMinWidth = minWidth;
        layoutTarget.measuredMinHeight = minHeight;

        layoutTarget.setContentSize(layoutTarget.measuredWidth, layoutTarget.measuredHeight);
    }

    /**
     *  @return Returns the maximum value for an item's dimension so that the component doesn't
     *  spill out of the container size. Calculations are based on the layout rules.
     *  Pass in unscaledWidth, hCenter, left, right, childX to get a maxWidth value.
     *  Pass in unscaledHeight, vCenter, top, bottom, childY to get a maxHeight value.
     */
    static private function maxSizeToFitIn(totalSize:Number,
                                           center:Number,
                                           lowConstraint:Number,
                                           highConstraint:Number,
                                           position:Number):Number
    {
        if (!isNaN(center))
        {
            // (1) x == (totalSize - childWidth) / 2 + hCenter
            // (2) x + childWidth <= totalSize
            // (3) x >= 0
            //
            // Substitue x in (2):
            // (totalSize - childWidth) / 2 + hCenter + childWidth <= totalSize
            // totalSize - childWidth + 2 * hCenter + 2 * childWidth <= 2 * totalSize
            // 2 * hCenter + childWidth <= totalSize se we get:
            // (3) childWidth <= totalSize - 2 * hCenter
            //
            // Substitute x in (3):
            // (4) childWidth <= totalSize + 2 * hCenter
            //
            // From (3) & (4) above we get:
            // childWidth <= totalSize - 2 * abs(hCenter)

            return totalSize - 2 * Math.abs(center);
        }
        else if(!isNaN(lowConstraint))
        {
            // childWidth + left <= totalSize
            return totalSize - lowConstraint;
        }
        else if(!isNaN(highConstraint))
        {
            // childWidth + right <= totalSize
            return totalSize - highConstraint;
        }
        else
        {
            // childWidth + childX <= totalSize
            return totalSize - position;
        }
    }

    override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        var layoutTarget:GroupBase = target;
        if (!layoutTarget)
            return;

        var count:int = layoutTarget.numLayoutItems;
        var maxX:Number = 0;
        var maxY:Number = 0;
        for (var i:int = 0; i < count; i++)
        {
            var layoutItem:ILayoutItem = layoutTarget.getLayoutItemAt(i);
            if (!layoutItem || !layoutItem.includeInLayout)
                continue;

            var hCenter:Number = LayoutItemHelper.getConstraint(layoutItem, "horizontalCenter");
            var vCenter:Number = LayoutItemHelper.getConstraint(layoutItem, "verticalCenter");
            var left:Number    = LayoutItemHelper.getConstraint(layoutItem, "left");
            var right:Number   = LayoutItemHelper.getConstraint(layoutItem, "right");
            var top:Number     = LayoutItemHelper.getConstraint(layoutItem, "top");
            var bottom:Number  = LayoutItemHelper.getConstraint(layoutItem, "bottom");
            var itemMinSize:Point = layoutItem.minSize;
            var itemMaxSize:Point = layoutItem.maxSize.clone(); // Since we may update it below

            // Remember child position before setting actualSize, since changing the size may
            // change the position.
            var childX:Number = layoutItem.actualPosition.x;
            var childY:Number = layoutItem.actualPosition.y;

            // Calculate size
            var childWidth:Number = NaN;
            var childHeight:Number = NaN;

            if (!isNaN(left) && !isNaN(right))
            {
                childWidth = unscaledWidth - right - left;
            }
            else if (!isNaN(layoutItem.percentSize.x))
            {
                childWidth = unscaledWidth * Math.min(layoutItem.percentSize.x, 1);
                itemMaxSize.x = Math.min(itemMaxSize.x,
                    maxSizeToFitIn(unscaledWidth, hCenter, left, right, childX));
            }

            if (!isNaN(top) && !isNaN(bottom))
            {
                childHeight = unscaledHeight - bottom - top;
            }
            else if (!isNaN(layoutItem.percentSize.y))
            {
                childHeight = unscaledHeight * Math.min(layoutItem.percentSize.y, 1);
                itemMaxSize.y = Math.min(itemMaxSize.y,
                    maxSizeToFitIn(unscaledHeight, vCenter, top, bottom, childY));
            }

            // Apply min and max constraints, make sure min is applied last. In the cases
            // where childWidth and childHeight are NaN, setActualSize will use preferredSize
            // which is already constrained between min and max.
            if (!isNaN(childWidth))
                childWidth = Math.max(itemMinSize.x, Math.min(itemMaxSize.x, childWidth));
            if (!isNaN(childHeight))
                childHeight = Math.max(itemMinSize.y, Math.min(itemMaxSize.y, childHeight));

            // Set the size.
            var actualSize:Point = layoutItem.setActualSize(childWidth, childHeight);

            // Horizontal position
            if (!isNaN(hCenter))
                childX = Math.round((unscaledWidth - actualSize.x) / 2 + hCenter);
            else if (!isNaN(left))
                childX = left;
            else if (!isNaN(right))
                childX = unscaledWidth - actualSize.x - right;
            else // since setting actual size might have moved the actual position, we need to reset here            
            	childX = layoutItem.actualPosition.x;

            // Vertical position
            if (!isNaN(vCenter))
                childY = Math.round((unscaledHeight - actualSize.y) / 2 + vCenter);
            else if (!isNaN(top))
                childY = top;
            else if (!isNaN(bottom))
                childY = unscaledHeight - actualSize.y - bottom;
           	else  // since setting actual size might have moved the actual position, we need to reset here
           		childY = layoutItem.actualPosition.y;

            // Set position
            layoutItem.setActualPosition(childX, childY);

            // update content limits
            maxX = Math.max(maxX, childX + actualSize.x);
            maxY = Math.max(maxY, childY + actualSize.y);
        }

        layoutTarget.setContentSize(maxX, maxY);
        updateScrollRect(unscaledWidth, unscaledHeight);
    }
}

}
