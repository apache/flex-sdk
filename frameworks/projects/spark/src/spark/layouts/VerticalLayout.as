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

import flex.core.Group;
import flex.intf.ILayout;
import flex.intf.ILayoutItem;

import mx.containers.utilityClasses.Flex;

/**
 *  Documentation is not currently available.
 */
public class VerticalLayout implements ILayout
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    /**
	 *  @private
	 */
	private static const GAP:int = 6;
    
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    private static function hasPercentWidth( layoutItem:ILayoutItem ):Boolean
    {
    	return !isNaN( layoutItem.percentSize.x );
    }
    
    private static function hasPercentHeight( layoutItem:ILayoutItem ):Boolean
    {
        return !isNaN( layoutItem.percentSize.y );
    }
    
    private static function calculatePercentWidth( layoutItem:ILayoutItem, width:Number ):Number
    {
    	var percentWidth:Number = LayoutItemHelper.pinBetween( layoutItem.percentSize.x * width,
    	                                                       layoutItem.minSize.x,
    	                                                       layoutItem.maxSize.x );
    	return percentWidth < width ? percentWidth : width;
    }
        
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor. 
     */    
    public function VerticalLayout():void
    {
		super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    private var _target:Group;
    
    public function get target():Group
    {
        return _target;
    }
    
    public function set target(value:Group):void
    {
        _target = value;
    }
    
    public function measure():void
    {
    	var layoutTarget:Group = target;
        if (!layoutTarget)
            return;
            
        var minWidth:Number = 0;
        var minHeight:Number = 0;
        var preferredWidth:Number = 0;
        var preferredHeight:Number = 0;
        
        var count:uint = layoutTarget.numLayoutItems;
        var totalCount:uint = count; // How many items will be laid out
        for (var i:int = 0; i < count; i++)
        {
            var layoutItem:ILayoutItem = layoutTarget.getLayoutItemAt(i);
            if (!layoutItem || !layoutItem.includeInLayout)
            {
            	totalCount--;
                continue;
            }            

            preferredWidth = Math.max(preferredWidth, layoutItem.preferredSize.x);
            preferredHeight += layoutItem.preferredSize.y; 

            var itemMinWidth:Number = hasPercentWidth(layoutItem) ? layoutItem.minSize.x : layoutItem.preferredSize.x;
            var itemMinHeight:Number = hasPercentHeight(layoutItem) ? layoutItem.minSize.y : layoutItem.preferredSize.y;
            minWidth = Math.max(minWidth, itemMinWidth);
            minHeight += itemMinHeight;
        }
        
        if (totalCount > 1)
        { 
            var gapSpace:Number = GAP * (totalCount - 1);
            minHeight += gapSpace;
            preferredHeight += gapSpace;
        }
        
        layoutTarget.measuredWidth = preferredWidth;
        layoutTarget.measuredHeight = preferredHeight;

        layoutTarget.measuredMinWidth = minWidth; 
        layoutTarget.measuredMinHeight = minHeight;
    }
    
    public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
    	var layoutTarget:Group = target; 
        if (!layoutTarget)
            return;
        
        // TODO EGeorgie: use vector
        var layoutItemArray:Array = new Array();
        var count:uint = layoutTarget.numLayoutItems;
        var totalCount:uint = count; // How many items will be laid out
        for (var i:int = 0; i < count; i++)
        {
            var layoutItem:ILayoutItem = layoutTarget.getLayoutItemAt(i);
            if (!layoutItem || !layoutItem.includeInLayout)
            {
            	totalCount--;
                continue;
            } 
            layoutItemArray.push(layoutItem);
        }

        var totalHeightToDistribute:Number = unscaledHeight;
        if (totalCount > 1)
            totalHeightToDistribute -= (totalCount - 1) * GAP;

        distributeHeight(layoutItemArray, unscaledWidth, totalHeightToDistribute); 
                            
        // TODO EGeorgie: horizontalAlign
        var hAlign:Number = 0;
        
        // Finally, position the objects        
        var y:Number = 0;
        for each (var lo:ILayoutItem in layoutItemArray)
        {
            var x:Number = (unscaledWidth - lo.actualSize.x) * hAlign;

            lo.setActualPosition(x, y);
            y += lo.actualSize.y;
            y += GAP;
        }
    }

    /**
     *  This function sets the height of each child
     *  so that the heights add up to <code>height</code>. 
     *  Each child is set to its preferred height
     *  if its percentHeight is zero.
     *  If its percentHeight is a positive number,
     *  the child grows (or shrinks) to consume its
     *  share of extra space.
     *  
     *  The return value is any extra space that's left over
     *  after growing all children to their maxHeight.
     */
    public function distributeHeight(layoutItemArray:Array,
                                     width:Number,
                                     height:Number):Number
    {
        var spaceToDistribute:Number = height;
        var totalPercentHeight:Number = 0;
        var childInfoArray:Array = [];
        var childInfo:LayoutItemFlexChildInfo;
        var newWidth:Number;
        
        // If the child is flexible, store information about it in the
        // childInfoArray. For non-flexible children, just set the child's
        // width and height immediately.
        for each (var layoutItem:ILayoutItem in layoutItemArray)
        {
            if (hasPercentHeight(layoutItem))
            {
                totalPercentHeight += layoutItem.percentSize.y;

                childInfo = new LayoutItemFlexChildInfo();
                childInfo.layoutItem = layoutItem;
                childInfo.percent    = layoutItem.percentSize.y * 100;
                childInfo.min        = layoutItem.minSize.y;
                childInfo.max        = layoutItem.maxSize.y;
                
                childInfoArray.push(childInfo);                
            }
            else
            {
                newWidth = NaN;
                if (hasPercentWidth(layoutItem))
                   newWidth = calculatePercentWidth(layoutItem, width);
                
                layoutItem.setActualSize(newWidth, NaN);
                spaceToDistribute -= layoutItem.actualSize.y;
            } 
        }

        // Distribute the extra space among the flexible children
        if (totalPercentHeight)
        {
            totalPercentHeight *= 100;
            spaceToDistribute = Flex.flexChildrenProportionally(height,
                                                                spaceToDistribute,
                                                                totalPercentHeight,
                                                                childInfoArray);
            for each (childInfo in childInfoArray)
            {
            	newWidth = NaN;
            	if (hasPercentWidth(childInfo.layoutItem))
            	   newWidth = calculatePercentWidth(childInfo.layoutItem, width);

                childInfo.layoutItem.setActualSize(newWidth, childInfo.size);
            }
        }
        return spaceToDistribute;
    }


    /*
    public function fill(unscaledWidth:Number, unscaledHeight:Number):void
    {
        var maxWidth:Number = 0;
        var maxHeight:Number = 0;
        var vTarget:VirtualizedContainer = _target as VirtualizedContainer;

        if (!vTarget)
            return;
            
        var index:Number = vTarget.firstVisibleChildIndex;
        
        while (maxHeight < unscaledHeight)
        {
            var child:DisplayObject = vTarget.getOrCreateChildSkin(index++);
            
            if (!child)
                break;
                
            var fdoChild:IFlexDisplayObject = child as IFlexDisplayObject;
            var uicChild:IUIComponent = child as IUIComponent;
            if((fdoChild as UIComponent == null) || UIComponent(fdoChild).includeInLayout)
            {
                if (child is UIComponent)
                    UIComponent(child).validateNow();
                    
                var childWidth:Number = uicChild ? uicChild.getExplicitOrMeasuredWidth() : fdoChild ? Math.max(fdoChild.measuredWidth, 0) : child.width;
                var childHeight:Number = uicChild ? uicChild.getExplicitOrMeasuredHeight() : fdoChild ? Math.max(fdoChild.measuredHeight, 0) : child.height;
                
                maxWidth = Math.max(maxWidth, childWidth);
                maxHeight += childHeight + GAP;
            }
        }
    }
    
    public function get maxHScrollPosition():Number
    {
        return 0;
    }
    
    public function get maxVScrollPosition():Number
    {
        var targetVirtualizedContainer:VirtualizedContainer = _target as VirtualizedContainer;
        
        if (targetVirtualizedContainer)
            return targetVirtualizedContainer.children.length - target.numChildren;
        else
            return target.numChildren;
    }
    
    public function get horizontalPageSize():Number
    {
        return 0;
    }
    
    public function get verticalPageSize():Number
    {
        // Should calculate this somehow....
        return 10;
    }
    
    public function scrollPositionToChildIndex(hScrollPosition:Number, vScrollPosition:Number):Number
    {
        // For vertical layout, vertical scroll position == child index
        return vScrollPosition;
    }
    */
}
}

[ExcludeClass]

import flex.intf.ILayoutItem;
import mx.containers.utilityClasses.FlexChildInfo;

class LayoutItemFlexChildInfo extends FlexChildInfo
{
    public var layoutItem:ILayoutItem;	
}
