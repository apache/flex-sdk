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

import flex.core.Group;
import flex.intf.ILayout;
import flex.intf.ILayoutItem;

/**
 *  Documentation is not currently available.
 */
public class BasicLayout implements ILayout
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------
        
    private static function constraintsDetermineWidth(layoutItem:ILayoutItem):Boolean
    {
        return !isNaN(LayoutItemHelper.getConstraint(layoutItem, "left")) &&
               !isNaN(LayoutItemHelper.getConstraint(layoutItem, "right"));
    }

    private static function constraintsDetermineHeight(layoutItem:ILayoutItem):Boolean
    {
        return !isNaN(LayoutItemHelper.getConstraint(layoutItem, "top")) &&
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
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    // target
    //----------------------------------

    private var _target:Group;

    public function get target():Group
    {
        return _target;
    }

    public function set target(value:Group):void
    {
        _target = value;
    }


    //--------------------------------------------------------------------------
    //
    //  Methods: ILayout
    //
    //--------------------------------------------------------------------------

    public function measure():void
    {
        var layoutTarget:Group = target; 
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

    public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        var layoutTarget:Group = target; 
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
            var itemMaxSize:Point = layoutItem.maxSize;

            // Calculate size
            var childWidth:Number = NaN;
            var childHeight:Number = NaN;
            
            if (!isNaN(left) && !isNaN(right))
                childWidth = unscaledWidth - right - left;
            else
                childWidth = Math.max(itemMinSize.x, Math.min(itemMaxSize.x, childWidth));
            
            if (!isNaN(top) && !isNaN(bottom))
                childHeight = unscaledHeight - bottom - top;
            else
                childHeight = Math.max(itemMinSize.y, Math.min(itemMaxSize.y, childHeight));
            
            // Set size, no need to clip to min/max
            // TODO!!! incorporate min/maxSize
            var actualSize:Point = layoutItem.setActualSize(childWidth, childHeight);

            // Calculate the position            
            var childX:Number;
            var childY:Number;

            // Horizontal
            if (!isNaN(hCenter))
                childX = Math.round((unscaledWidth - actualSize.x) / 2 + hCenter);
            else if (!isNaN(left))
                childX = left;
            else if (!isNaN(right))
                childX = unscaledWidth - actualSize.x - right;
            else
                childX = layoutItem.actualPosition.x;
            
            // Vertical
            if (!isNaN(vCenter))
                childY = Math.round((unscaledHeight - actualSize.y) / 2 + vCenter);
            else if (!isNaN(top))
                childY = top;
            else if (!isNaN(bottom))
                childY = unscaledHeight - actualSize.y - bottom;
            else
                childY = layoutItem.actualPosition.y

            // Set position
            layoutItem.setActualPosition(childX, childY);
            
            // update content limits
            maxX = Math.max(maxX, childX + actualSize.x);
            maxY = Math.max(maxY, childY + actualSize.y);
        }

        layoutTarget.setContentSize(maxX, maxY);
    }
}

}
