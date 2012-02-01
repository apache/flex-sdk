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
import flash.geom.Rectangle;	

import flex.core.Group;
import flex.intf.ILayout;
import flex.intf.ILayoutItem;

import mx.containers.utilityClasses.Flex;

/**
 *  Documentation is not currently available.
 */
public class HorizontalLayout implements ILayout
{
    include "../core/Version.as";

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
    
    private static function calculatePercentHeight( layoutItem:ILayoutItem, height:Number ):Number
    {
    	var percentHeight:Number = LayoutItemHelper.pinBetween( layoutItem.percentSize.y * height,
    	                                                       layoutItem.minSize.y,
    	                                                       layoutItem.maxSize.y );
    	return percentHeight < height ? percentHeight : height;
    }
        
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor. 
     */    
    public function HorizontalLayout():void
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
    
    //----------------------------------
    //  gap
    //----------------------------------

    /**
     *  @private
     */
    private var _gap:int = 6;
    
    /**
     *  @private
     */
    private var gapChanged:Boolean = false;

    [Inspectable(category="General")]

    /**
     *  Horizontal space between columns.
     * 
     *  @default 6
     */
    public function get gap():int
    {
        return _gap;
    }

    /**
     *  @private
     */
    public function set gap(value:int):void
    {
        if (_gap == value) return;
    
		_gap = value;
 	   	var layoutTarget:Group = target;
    	if (layoutTarget != null) 
    	{
			gapChanged = true;
        	layoutTarget.invalidateSize();
            layoutTarget.invalidateDisplayList();
    	}
    }
    
    //----------------------------------
    //  expliciColumnCount
    //----------------------------------

    /**
     *  The column count requested by explicitly setting
     *  <code>columnCount</code>.
     */
    protected var explicitColumnCount:int = -1;

    //----------------------------------
    //  columnCount
    //----------------------------------

    /**
     *  @private
     */
    private var _columnCount:int = -1;
    
    /**
     *  @private
     */
    private var columnCountChanged:Boolean = false;

    [Inspectable(category="General")]

    /**
     *  Number of columns to be displayed.
     *  If the width of the component has been explicitly set,
     *  this property might not have any effect.
     * 
     *  @default -1
     */
    public function get columnCount():int
    {
        return _columnCount;
    }

    /**
     *  @private
     */
    public function set columnCount(value:int):void
    {
        explicitColumnCount = value;

        if (_columnCount == value) return;

        setColumnCount(value);
 	   	var layoutTarget:Group = target;
    	if (layoutTarget != null) 
    	{
    		columnCountChanged = true;
        	layoutTarget.invalidateSize();
            layoutTarget.invalidateDisplayList();
    	}
    }

    /**
     *  Sets the <code>columnCount</code> property without causing
     *  invalidation or setting the <code>explicitColumnCount</code>
     *  property, which permanently locks in the number of columns.
     *
     *  @param v The row count.
     */
    protected function setColumnCount(v:int):void
    {
        _columnCount = v;
    }
    
    //----------------------------------
    //  explicitColumnWidth
    //----------------------------------

    /**
     *  The column width requested by explicitly setting
     *  <code>columnWidth</code>.
     */
    protected var explicitColumnWidth:Number;

    //----------------------------------
    //  columnWidth
    //----------------------------------
    
    /**
     *  @private
     */
    private var _columnWidth:Number = 20;
    
    /**
     *  @private
     */
    private var columnWidthChanged:Boolean = false;

    [Inspectable(category="General")]

    /**
     *  The width of the columns in pixels.
     *  Unless the <code>variableColumnWidth</code> property is
     *  <code>true</code>, all columns are the same width.  
     */
    public function get columnWidth():Number
    {
        return _columnWidth;
    }

    /**
     *  @private
     */
    public function set columnWidth(value:Number):void
    {
        explicitColumnWidth = value;

        if (_columnWidth != value)
        {
            setColumnWidth(value);
 		   	var layoutTarget:Group = target;
        	if (layoutTarget != null) 
        	{
        		columnWidthChanged = true;
            	layoutTarget.invalidateSize();
	            layoutTarget.invalidateDisplayList();
        	}
        }
    }

    /**
     *  Sets the <code>columnWidth</code> property without causing invalidation or 
     *  setting of <code>explicitColumnWidth</code> which
     *  permanently locks in the width of the columns.
     *
     *  @param value The column width, in pixels.
     */
    protected function setColumnWidth(value:Number):void
    {
        _columnWidth = value;
    }    


    //----------------------------------
    //  variableColumnWidth
    //----------------------------------

    /**
     *  @private
     */
    private var _variableColumnWidth:Boolean = true;

    [Inspectable(category="General")]

    /**
     *  @default true
     */
    public function get variableColumnWidth():Boolean
    {
        return _variableColumnWidth;
    }

    /**
     *  @private
     */
    public function set variableColumnWidth(value:Boolean):void
    {
        if (value == _variableColumnWidth) return;
        
        _variableColumnWidth = value;
 		var layoutTarget:Group = target;
        if (layoutTarget != null) {
    		layoutTarget.invalidateSize();
        	layoutTarget.invalidateDisplayList();
        }
    }
    
    

    public function variableColumnWidthMeasure(layoutTarget:Group):void
    {
        var minWidth:Number = 0;
        var minHeight:Number = 0;
        var preferredWidth:Number = 0;
        var preferredHeight:Number = 0;
        var visibleWidth:Number = 0;
        var visibleColumns:uint = 0;
        var explicitColumnCount:int = explicitColumnCount;        
        
        
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

            preferredHeight = Math.max(preferredHeight, layoutItem.preferredSize.y);
            preferredWidth += layoutItem.preferredSize.x; 

            var itemMinWidth:Number = hasPercentWidth(layoutItem) ? layoutItem.minSize.x : layoutItem.preferredSize.x;
            var itemMinHeight:Number = hasPercentHeight(layoutItem) ? layoutItem.minSize.y : layoutItem.preferredSize.y;
            minHeight = Math.max(minHeight, itemMinHeight);
            minWidth += itemMinWidth;
            
            if ((explicitColumnCount != -1) && (visibleColumns < explicitColumnCount)) 
            {
            	visibleWidth = preferredWidth;
            	visibleColumns += 1;
            }
            
        }
        
        if (totalCount > 1)
        { 
            var gapSpace:Number = gap * (totalCount - 1);
            minWidth += gapSpace;
            preferredWidth += gapSpace;
            visibleWidth += (visibleColumns < 2) ? 0 : ((visibleColumns - 1) * gap); 
        }
        
        layoutTarget.measuredWidth = (explicitColumnCount == -1) ? preferredWidth : visibleWidth;
        layoutTarget.measuredHeight = preferredHeight;

        layoutTarget.contentWidth = preferredWidth;
        layoutTarget.contentHeight = preferredHeight;

        layoutTarget.measuredMinWidth = minWidth; 
        layoutTarget.measuredMinHeight = minHeight;
    }
    
    
    private function fixedColumnWidthMeasure(layoutTarget:Group):void
    {
        // TBD init columnWidth if explicitColumnWidth isNaN
        var cols:uint = layoutTarget.numLayoutItems;
        var visibleCols:uint = (explicitColumnCount == -1) ? cols : explicitColumnCount;
        var contentWidth:Number = (cols * columnWidth) + ((cols > 1) ? (gap * (cols - 1)) : 0);
        var visibleWidth:Number = (visibleCols * columnWidth) + ((visibleCols > 1) ? (gap * (visibleCols - 1)) : 0);
        
        var rowHeight:Number = layoutTarget.explicitHeight;
        var minRowHeight:Number = rowHeight;
        if (isNaN(rowHeight)) 
        {
			minRowHeight = rowHeight = 0;
	        var count:uint = layoutTarget.numLayoutItems;
	        for (var i:int = 0; i < count; i++)
	        {
	            var layoutItem:ILayoutItem = layoutTarget.getLayoutItemAt(i);
	            if (!layoutItem || !layoutItem.includeInLayout) continue;
	            rowHeight = Math.max(rowHeight, layoutItem.preferredSize.y);
	            var itemMinHeight:Number = hasPercentHeight(layoutItem) ? layoutItem.minSize.y : layoutItem.preferredSize.y;
	            minRowHeight = Math.max(minRowHeight, itemMinHeight);
	        }
        }     
        
        layoutTarget.measuredWidth = visibleWidth;
        layoutTarget.measuredHeight = rowHeight;
        
        layoutTarget.contentWidth = contentWidth; 
        layoutTarget.contentHeight = rowHeight;

        layoutTarget.measuredMinWidth = columnWidth;
        layoutTarget.measuredMinHeight = minRowHeight;
    }
    

    public function measure():void
    {
    	var layoutTarget:Group = target;
        if (!layoutTarget)
            return;
            
        if (variableColumnWidth) 
        	variableColumnWidthMeasure(layoutTarget);
        else 
        	fixedColumnWidthMeasure(layoutTarget);
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

        var totalWidthToDistribute:Number = unscaledWidth;
        if (totalCount > 1)
            totalWidthToDistribute -= (totalCount - 1) * gap;

        distributeWidth(layoutItemArray, totalWidthToDistribute, unscaledHeight); 
                            
        // TODO EGeorgie: verticalAlign
        var vAlign:Number = 0;
        
        
        // If columnCount wasn't set, then as the LayoutItems are positioned
        // we'll count how many columns fall within the layoutTarget's scrollRect
        var visibleColumns:uint = 0;
        var minVisibleX:Number = layoutTarget.horizontalScrollPosition;
        var maxVisibleX:Number = minVisibleX + unscaledWidth
            
        // Finally, position the objects        
        var x:Number = 0;
        for each (var lo:ILayoutItem in layoutItemArray)
        {
            var y:Number = (unscaledHeight - lo.actualSize.y) * vAlign;
            lo.setActualPosition(x, y);
            if (!variableColumnWidth)
            	lo.setActualSize(columnWidth, lo.actualSize.y);
            var dx:Number = lo.actualSize.x;
            if((explicitColumnCount == -1) && (x < maxVisibleX) && ((x + dx) > minVisibleX))
            	visibleColumns += 1;
            x += dx + gap;
        }
        if (explicitColumnCount == -1) 
        	setColumnCount(visibleColumns);        

        var r:Rectangle = layoutTarget.scrollRect;
        if (r != null) 
        {
            r.width = unscaledWidth;
            r.height = unscaledHeight;
            layoutTarget.scrollRect = r;
        }
        else 
        {
        	var rx:Number = layoutTarget.horizontalScrollPosition;
        	var ry:Number = layoutTarget.verticalScrollPosition;
        	layoutTarget.scrollRect = new Rectangle(rx, ry, unscaledWidth, unscaledHeight);
        }
    }


    /**
     *  This function sets the width of each child
     *  so that the widths add up to <code>width</code>. 
     *  Each child is set to its preferred width
     *  if its percentWidth is zero.
     *  If its percentWidth is a positive number,
     *  the child grows (or shrinks) to consume its
     *  share of extra space.
     *  
     *  The return value is any extra space that's left over
     *  after growing all children to their maxWidth.
     */
    public function distributeWidth(layoutItemArray:Array,
                                     width:Number,
                                     height:Number):Number
    {
        var spaceToDistribute:Number = width;
        var totalPercentWidth:Number = 0;
        var childInfoArray:Array = [];
        var childInfo:HLayoutItemFlexChildInfo;
        var newHeight:Number;
        
        // If the child is flexible, store information about it in the
        // childInfoArray. For non-flexible children, just set the child's
        // width and height immediately.
        for each (var layoutItem:ILayoutItem in layoutItemArray)
        {
            if (hasPercentWidth(layoutItem))
            {
                totalPercentWidth += layoutItem.percentSize.x;

                childInfo = new HLayoutItemFlexChildInfo();
                childInfo.layoutItem = layoutItem;
                childInfo.percent    = layoutItem.percentSize.x * 100;
                childInfo.min        = layoutItem.minSize.x;
                childInfo.max        = layoutItem.maxSize.x;
                
                childInfoArray.push(childInfo);                
            }
            else
            {
                newHeight = NaN;
                if (hasPercentHeight(layoutItem))
                   newHeight = calculatePercentHeight(layoutItem, height);
                
                layoutItem.setActualSize(NaN, newHeight);
                spaceToDistribute -= layoutItem.actualSize.x;
            } 
        }

        // Distribute the extra space among the flexible children
        if (totalPercentWidth)
        {
            totalPercentWidth *= 100;
            spaceToDistribute = Flex.flexChildrenProportionally(width,
                                                                spaceToDistribute,
                                                                totalPercentWidth,
                                                                childInfoArray);
            for each (childInfo in childInfoArray)
            {
            	newHeight = NaN;
            	if (hasPercentHeight(childInfo.layoutItem))
            	   newHeight = calculatePercentHeight(childInfo.layoutItem, height);

                childInfo.layoutItem.setActualSize(childInfo.size, newHeight);
            }
        }
        return spaceToDistribute;
    }

}
}

[ExcludeClass]

import flex.intf.ILayoutItem;
import mx.containers.utilityClasses.FlexChildInfo;

class HLayoutItemFlexChildInfo extends FlexChildInfo
{
    public var layoutItem:ILayoutItem;	
}
