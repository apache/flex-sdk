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

package mx.layout
{

import flash.geom.Point;
import flash.geom.Rectangle;

import mx.components.baseClasses.GroupBase;
import mx.core.ILayoutElement;
import mx.layout.LayoutBase;

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

    private static function constraintsDetermineWidth(layoutElement:ILayoutElement):Boolean
    {
        return !isNaN(layoutElement.percentWidth) ||
               !isNaN(LayoutElementHelper.parseConstraintValue(layoutElement.left)) &&
               !isNaN(LayoutElementHelper.parseConstraintValue(layoutElement.right));
    }

    private static function constraintsDetermineHeight(layoutElement:ILayoutElement):Boolean
    {
        return !isNaN(layoutElement.percentHeight) ||
               !isNaN(LayoutElementHelper.parseConstraintValue(layoutElement.top)) &&
               !isNaN(LayoutElementHelper.parseConstraintValue(layoutElement.bottom));
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
        super.measure();
        
        var layoutTarget:GroupBase = target;
        if (!layoutTarget)
            return;

        var width:Number = 0;
        var height:Number = 0;
        var minWidth:Number = 0;
        var minHeight:Number = 0;

        var count:int = layoutTarget.numElements;
        for (var i:int = 0; i < count; i++)
        {
            var layoutElement:ILayoutElement = layoutTarget.getElementAt(i);
            if (!layoutElement || !layoutElement.includeInLayout)
                continue;

            var left:Number      = LayoutElementHelper.parseConstraintValue(layoutElement.left);
            var right:Number     = LayoutElementHelper.parseConstraintValue(layoutElement.right);
            var top:Number       = LayoutElementHelper.parseConstraintValue(layoutElement.top);
            var bottom:Number    = LayoutElementHelper.parseConstraintValue(layoutElement.bottom);

            var extX:Number = 0;
            var extY:Number = 0;

            if (isNaN(left) && isNaN(right) &&
                isNaN(LayoutElementHelper.parseConstraintValue(layoutElement.horizontalCenter)))
            {
                extX += layoutElement.getLayoutBoundsX();
            }
            else
            {
                extX += isNaN(left) ? 0 : left;
                extX += isNaN(right) ? 0 : right;
            }

            if (isNaN(top) && isNaN(bottom) &&
                isNaN(LayoutElementHelper.parseConstraintValue(layoutElement.verticalCenter)))
            {
                extY += layoutElement.getLayoutBoundsY();
            }
            else
            {
                extY += isNaN(top) ? 0 : top;
                extY += isNaN(bottom) ? 0 : bottom;
            }

            width = Math.max(width, extX + layoutElement.getPreferredBoundsWidth());
            height = Math.max(height, extY + layoutElement.getPreferredBoundsHeight());

            var elementMinWidth:Number = constraintsDetermineWidth(layoutElement) ? layoutElement.getMinBoundsWidth() : layoutElement.getPreferredBoundsWidth();
            var elementMinHeight:Number = constraintsDetermineHeight(layoutElement) ? layoutElement.getMinBoundsHeight() : layoutElement.getPreferredBoundsHeight();

            minWidth = Math.max(minWidth, extX + elementMinWidth);
            minHeight = Math.max(minHeight, extY + elementMinHeight);
        }

        layoutTarget.measuredWidth = Math.max(width, minWidth);
        layoutTarget.measuredHeight = Math.max(height, minHeight);

        layoutTarget.measuredMinWidth = minWidth;
        layoutTarget.measuredMinHeight = minHeight;

        layoutTarget.setContentSize(layoutTarget.measuredWidth, layoutTarget.measuredHeight);
    }

    /**
     *  @return Returns the maximum value for an element's dimension so that the component doesn't
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
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        var layoutTarget:GroupBase = target;
        if (!layoutTarget)
            return;

        var count:int = layoutTarget.numElements;
        var maxX:Number = 0;
        var maxY:Number = 0;
        for (var i:int = 0; i < count; i++)
        {
            var layoutElement:ILayoutElement = layoutTarget.getElementAt(i);
            if (!layoutElement || !layoutElement.includeInLayout)
                continue;

            var hCenter:Number = LayoutElementHelper.parseConstraintValue(layoutElement.horizontalCenter);
            var vCenter:Number = LayoutElementHelper.parseConstraintValue(layoutElement.verticalCenter);
            var left:Number    = LayoutElementHelper.parseConstraintValue(layoutElement.left);
            var right:Number   = LayoutElementHelper.parseConstraintValue(layoutElement.right);
            var top:Number     = LayoutElementHelper.parseConstraintValue(layoutElement.top);
            var bottom:Number  = LayoutElementHelper.parseConstraintValue(layoutElement.bottom);
            var elementMaxWidth:Number = layoutElement.getMaxBoundsWidth();
            var elementMaxHeight:Number = layoutElement.getMaxBoundsHeight();

            // Remember child position before setting layoutSize, since changing the size may
            // change the position.
            var childX:Number = layoutElement.getLayoutBoundsX();
            var childY:Number = layoutElement.getLayoutBoundsY();

            // Calculate size
            var childWidth:Number = NaN;
            var childHeight:Number = NaN;

            if (!isNaN(left) && !isNaN(right))
            {
                childWidth = unscaledWidth - right - left;
            }
            else if (!isNaN(layoutElement.percentWidth))
            {
                childWidth = unscaledWidth * Math.min(layoutElement.percentWidth * 0.01, 1);
                elementMaxWidth = Math.min(elementMaxWidth,
                    maxSizeToFitIn(unscaledWidth, hCenter, left, right, childX));
            }

            if (!isNaN(top) && !isNaN(bottom))
            {
                childHeight = unscaledHeight - bottom - top;
            }
            else if (!isNaN(layoutElement.percentHeight))
            {
                childHeight = unscaledHeight * Math.min(layoutElement.percentHeight * 0.01, 1);
                elementMaxHeight = Math.min(elementMaxHeight,
                    maxSizeToFitIn(unscaledHeight, vCenter, top, bottom, childY));
            }

            // Apply min and max constraints, make sure min is applied last. In the cases
            // where childWidth and childHeight are NaN, setLayoutBoundsSize will use preferredSize
            // which is already constrained between min and max.
            if (!isNaN(childWidth))
                childWidth = Math.max(layoutElement.getMinBoundsWidth(), Math.min(elementMaxWidth, childWidth));
            if (!isNaN(childHeight))
                childHeight = Math.max(layoutElement.getMinBoundsHeight(), Math.min(elementMaxHeight, childHeight));

            // Set the size.
            layoutElement.setLayoutBoundsSize(childWidth, childHeight);
            var elementWidth:Number = layoutElement.getLayoutBoundsWidth();
            var elementHeight:Number = layoutElement.getLayoutBoundsHeight();

            // Horizontal position
            if (!isNaN(hCenter))
                childX = Math.round((unscaledWidth - elementWidth) / 2 + hCenter);
            else if (!isNaN(left))
                childX = left;
            else if (!isNaN(right))
                childX = unscaledWidth - elementWidth - right;
            else // since setting actual size might have moved the actual position, we need to reset here            
            	childX = layoutElement.getLayoutBoundsX();

            // Vertical position
            if (!isNaN(vCenter))
                childY = Math.round((unscaledHeight - elementHeight) / 2 + vCenter);
            else if (!isNaN(top))
                childY = top;
            else if (!isNaN(bottom))
                childY = unscaledHeight - elementHeight - bottom;
           	else  // since setting actual size might have moved the actual position, we need to reset here
           		childY = layoutElement.getLayoutBoundsY();

            // Set position
            layoutElement.setLayoutBoundsPosition(childX, childY);

            // update content limits
            maxX = Math.max(maxX, childX + elementWidth);
            maxY = Math.max(maxY, childY + elementHeight);
        }

        layoutTarget.setContentSize(maxX, maxY);
    }
}

}
