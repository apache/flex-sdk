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

package spark.layouts
{

import mx.core.ILayoutElement;
import mx.core.IVisualElement;

import spark.components.supportClasses.GroupBase;
import spark.layouts.supportClasses.LayoutBase;
import spark.layouts.supportClasses.LayoutElementHelper;

/**
 *  BasicLayout arranges the layout elements according to their settings,
 *  independent of each-other.
 *
 *  Per-element supported constraints are left, right, top, bottom, horizontalCenter,
 *  verticalCenter, baseline, percentWidth, percentHeight.
 *  Element's minimum and maximum sizes will always be respected.
 *
 *  The measured size of the container is calculated from the elements, their
 *  constraints and their preferred sizes.
 *
 *  During updateDisplayList() the element's size is determined according to
 *  the rules in the following order of precedence (the element's minimum and
 *  maximum sizes are always respected):
 *  <ul>
 *    <li>If the element has percentWidth or percentHeight set, then its size
 *    is calculated as a percentage of the container size, minus any left, right,
 *    top, bottom constraints.</li>
 *
 *    <li>If the element has both left and right constraints, it's width is
 *    set to be the container's width minus the left and right constraints.</li>
 * 
 *    <li>If the element has both top and bottom constraints, it's height is
 *    set to be the container's height minus the top and bottom constraints.</li>
 *
 *    <li>The element is set to its preferred width and/or height.</li>
 *  </ul>
 * 
 *  The element's position is determined according to the rules in the following
 *  order of precedence:
 *  <ul>
 *    <li>If element's horizontalCenter/verticalCenter is specified, then the
 *    element is positioned such that the distance between the element's center
 *    and the container's center is equal to the horizontalCenter/verticalCenter.
 *    Set horizontalCenter/verticalCenter to zero to cetner the element within
 *    the container in the horizontal/vertical direction.</li>
 * 
 *    <li>If element's baseline is specified, then the element is positioned in
 *    the vertical direction such that its baselinePosition (usually the baseline
 *    of its first line of text) is aligned with baseline constraint.</li>
 *
 *    <li>If element's top/left constraints are specified, then the element is
 *    positioned such that the top-left corner of the element's layout bounds is
 *    offset from the top-left corner of the container by the specified values.</li>
 *
 *    <li>If element's bottom/right constraints are specified, then the element is
 *    positioned such that the bottom-right corner of the element's layout bounds is
 *    offset from the bottom-right corner of the container by the specified values.</li>
 * 
 *    <li>When no constraints determine the position in the horizontal/vertical
 *    direction, the element is positioned according to its x/y coordinates.</li>
 *  </ul>
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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

    /**
     *  @private 
     */
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

            var hCenter:Number   = LayoutElementHelper.parseConstraintValue(layoutElement.horizontalCenter);
            var vCenter:Number   = LayoutElementHelper.parseConstraintValue(layoutElement.verticalCenter);
            var baseline:Number  = LayoutElementHelper.parseConstraintValue(layoutElement.baseline);
            var left:Number      = LayoutElementHelper.parseConstraintValue(layoutElement.left);
            var right:Number     = LayoutElementHelper.parseConstraintValue(layoutElement.right);
            var top:Number       = LayoutElementHelper.parseConstraintValue(layoutElement.top);
            var bottom:Number    = LayoutElementHelper.parseConstraintValue(layoutElement.bottom);

            // Extents of the element - how much additional space (besides its own width/height)
            // the element needs based on its constraints.
            var extX:Number;
            var extY:Number;

            if (!isNaN(left) && !isNaN(right))
            {
                // If both left & right are set, then the extents is always
                // left + right so that the element is resized to its preferred
                // size (if it's the one that pushes out the default size of the container).
                extX = left + right;                
            }
            else if (!isNaN(hCenter))
            {
                // If we have horizontalCenter, then we want to have at least enough space
                // so that the element is within the parent container.
                // If the element is aligned to the left/right edge of the container and the
                // distance between the centers is hCenter, then the container width will be
                // parentWidth = 2 * (abs(hCenter) + elementWidth / 2)
                // <=> parentWidth = 2 * abs(hCenter) + elementWidth
                // Since the extents is the additional space that the element needs
                // extX = parentWidth - elementWidth = 2 * abs(hCenter)
                extX = Math.abs(hCenter) * 2;
            }
            else if (!isNaN(left) || !isNaN(right))
            {
                extX = isNaN(left) ? 0 : left;
                extX += isNaN(right) ? 0 : right;
            }
            else
            {
                extX = layoutElement.getBoundsXAtSize(NaN, NaN);
            }
            
            if (!isNaN(top) && !isNaN(bottom))
            {
                // If both top & bottom are set, then the extents is always
                // top + bottom so that the element is resized to its preferred
                // size (if it's the one that pushes out the default size of the container).
                extY = top + bottom;                
            }
            else if (!isNaN(vCenter))
            {
                // If we have verticalCenter, then we want to have at least enough space
                // so that the element is within the parent container.
                // If the element is aligned to the top/bottom edge of the container and the
                // distance between the centers is vCenter, then the container height will be
                // parentHeight = 2 * (abs(vCenter) + elementHeight / 2)
                // <=> parentHeight = 2 * abs(vCenter) + elementHeight
                // Since the extents is the additional space that the element needs
                // extY = parentHeight - elementHeight = 2 * abs(vCenter)
                extY = Math.abs(vCenter) * 2;
            }
            else if (!isNaN(baseline))
            {
                extY = baseline - layoutElement.baselinePosition;
            }
            else if (!isNaN(top) || !isNaN(bottom))
            {
                extY = isNaN(top) ? 0 : top;
                extY += isNaN(bottom) ? 0 : bottom;
            }
            else
            {
                extY = layoutElement.getBoundsYAtSize(NaN, NaN);
            }

            var preferredWidth:Number = layoutElement.getPreferredBoundsWidth();
            var preferredHeight:Number = layoutElement.getPreferredBoundsHeight();

            width = Math.max(width, extX + preferredWidth);
            height = Math.max(height, extY + preferredHeight);

            // Find the minimum default extents, we take the minimum width/height only
            // when the element size is determined by the parent size
            var elementMinWidth:Number =
                constraintsDetermineWidth(layoutElement) ? layoutElement.getMinBoundsWidth() :
                                                           preferredWidth;
            var elementMinHeight:Number =
                constraintsDetermineHeight(layoutElement) ? layoutElement.getMinBoundsHeight() : 
                                                            preferredHeight;

            minWidth = Math.max(minWidth, extX + elementMinWidth);
            minHeight = Math.max(minHeight, extY + elementMinHeight);
        }

        layoutTarget.measuredWidth = Math.max(width, minWidth);
        layoutTarget.measuredHeight = Math.max(height, minHeight);

        layoutTarget.measuredMinWidth = minWidth;
        layoutTarget.measuredMinHeight = minHeight;
    }

    /**
     *  @return Returns the maximum value for an element's dimension so that the component doesn't
     *  spill out of the container size. Calculations are based on the layout rules.
     *  Pass in unscaledWidth, hCenter, left, right, childX to get a maxWidth value.
     *  Pass in unscaledHeight, vCenter, top, bottom, childY to get a maxHeight value.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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

    /**
     *  @private 
     */
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
            var baseline:Number      = LayoutElementHelper.parseConstraintValue(layoutElement.baseline);
            var left:Number    = LayoutElementHelper.parseConstraintValue(layoutElement.left);
            var right:Number   = LayoutElementHelper.parseConstraintValue(layoutElement.right);
            var top:Number     = LayoutElementHelper.parseConstraintValue(layoutElement.top);
            var bottom:Number  = LayoutElementHelper.parseConstraintValue(layoutElement.bottom);
            var percentWidth:Number  = layoutElement.percentWidth;
            var percentHeight:Number = layoutElement.percentHeight;
            
            var elementMaxWidth:Number = layoutElement.getMaxBoundsWidth();
            var elementMaxHeight:Number = layoutElement.getMaxBoundsHeight();

            // Calculate size
            var childWidth:Number = NaN;
            var childHeight:Number = NaN;

            if (!isNaN(percentWidth))
            {
                var availableWidth:Number = unscaledWidth;
                if (!isNaN(left))
                    availableWidth -= left;
                if (!isNaN(right))
                     availableWidth -= right;

                childWidth = availableWidth * Math.min(percentWidth * 0.01, 1);
                elementMaxWidth = Math.min(elementMaxWidth,
                    maxSizeToFitIn(unscaledWidth, hCenter, left, right, layoutElement.getLayoutBoundsX()));
            }
            else if (!isNaN(left) && !isNaN(right))
            {
                childWidth = unscaledWidth - right - left;
            }

            if (!isNaN(percentHeight))
            {
                var availableHeight:Number = unscaledHeight;
                if (!isNaN(top))
                    availableHeight -= top;
                if (!isNaN(bottom))
                    availableHeight -= bottom;    
                    
                childHeight = availableHeight * Math.min(percentHeight * 0.01, 1);
                elementMaxHeight = Math.min(elementMaxHeight,
                    maxSizeToFitIn(unscaledHeight, vCenter, top, bottom, layoutElement.getLayoutBoundsY()));
            }
            else if (!isNaN(top) && !isNaN(bottom))
            {
                childHeight = unscaledHeight - bottom - top;
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

            var childX:Number = NaN;
            var childY:Number = NaN;
            
            // Horizontal position
            if (!isNaN(hCenter))
                childX = Math.round((unscaledWidth - elementWidth) / 2 + hCenter);
            else if (!isNaN(left))
                childX = left;
            else if (!isNaN(right))
                childX = unscaledWidth - elementWidth - right;
            else
            	childX = layoutElement.getLayoutBoundsX();

            // Vertical position
            if (!isNaN(vCenter))
                childY = Math.round((unscaledHeight - elementHeight) / 2 + vCenter);
            else if (!isNaN(baseline))
                childY = baseline - IVisualElement(layoutElement).baselinePosition;
            else if (!isNaN(top))
                childY = top;
            else if (!isNaN(bottom))
                childY = unscaledHeight - elementHeight - bottom;
            else
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
