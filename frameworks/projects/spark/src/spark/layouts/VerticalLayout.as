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
import flash.events.EventDispatcher;

import flex.core.GroupBase;
import flex.intf.ILayout;
import flex.intf.ILayoutItem;

import mx.containers.utilityClasses.Flex;
import mx.events.PropertyChangeEvent;


/**
 *  Documentation is not currently available.
 */
public class VerticalLayout extends EventDispatcher implements ILayout
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

    private var _target:GroupBase;
    
    public function get target():GroupBase
    {
        return _target;
    }
    
    public function set target(value:GroupBase):void
    {
        _target = value;
    }

    //----------------------------------
    //  gap
    //----------------------------------
    private function invalidateTargetSizeAndDisplayList():void
    {
        var layoutTarget:GroupBase = target;
        if (layoutTarget != null) 
        {
            layoutTarget.invalidateSize();
            layoutTarget.invalidateDisplayList();
        }
    }
    
    private var _gap:int = 6;
    
    [Inspectable(category="General")]

    /**
     *  Vertical space between rows.
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
        if (_gap == value) 
            return;

        _gap = value;
        invalidateTargetSizeAndDisplayList();
    }

    //----------------------------------
    //  rowCount
    //----------------------------------

    private var _rowCount:int = -1;

    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    
    /**
     *  Specifies the number of visible items..
     * 
     *  @default -1
     */
    public function get rowCount():int
    {
        return _rowCount;
    }
    
    /**
     *  Sets the <code>rowCount</code> property without causing
     *  invalidation.  
     * 
     *  This method is intended to be used by subclass updateDisplayList() 
     *  methods to sync the rowCount property with the actual number
     *  of visible rows.
     *
     *  @param value The number of visible rows.
     */
    protected function setRowCount(value:int):void
    {
        if (_rowCount == value)
            return;
        var oldValue:int = _rowCount;
        _rowCount = value;
        dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "rowCount", oldValue, value));
    }
    
    //----------------------------------
    //  requestedRowCount
    //----------------------------------

    private var _requestedRowCount:int = -1;
    
    [Inspectable(category="General")]

    /**
     *  Specifies the number of items to display.
     * 
     *  If <code>requestedRowCount</code> is -1, then all of the items are displayed.
     * 
     *  This value implies the layout's <code>measuredHeight</code>.
     * 
     *  If the height of the <code>target</code> has been explicitly set,
     *  this property has no effect.
     * 
     *  @default -1
     */
    public function get requestedRowCount():int
    {
        return _requestedRowCount;
    }

    /**
     *  @private
     */
    public function set requestedRowCount(value:int):void
    {
        if (_requestedRowCount == value)
            return;
                               
        _requestedRowCount = value;
        invalidateTargetSizeAndDisplayList();
    }    
    

    //----------------------------------
    //  explicitRowHeight
    //----------------------------------

    /**
     *  The row height requested by explicitly setting
     *  <code>rowHeight</code>.
     */
    protected var explicitRowHeight:Number;

    //----------------------------------
    //  rowHeight
    //----------------------------------
    
    private var _rowHeight:Number = 20;

    [Inspectable(category="General")]

    /**
     *  Specifies the height of the rows if <code>variableRowHeight</code>
     *  is false.
     *  
     *  @default 20
     */
    public function get rowHeight():Number
    {
        return _rowHeight;
    }

    /**
     *  @private
     */
    public function set rowHeight(value:Number):void
    {
        explicitRowHeight = value;

        if (_rowHeight != value)
        {
            setRowHeight(value);
            invalidateTargetSizeAndDisplayList();
        }
    }

    /**
     *  Sets the <code>rowHeight</code> property without causing invalidation or 
     *  setting of <code>explicitRowHeight</code> which
     *  permanently locks in the height of the rows.
     *
     *  @param value The row height, in pixels.
     */
    protected function setRowHeight(value:Number):void
    {
        _rowHeight = value;
    }    


    //----------------------------------
    //  variableRowHeight
    //----------------------------------

    /**
     *  @private
     */
    private var _variableRowHeight:Boolean = true;

    [Inspectable(category="General")]

    /**
     *  If false, i.e. "fixed row height" is specified, the height of
     *  each item is set to the value of <code>rowHeight</code>.
     * 
     *  If the <code>rowHeight</code> property wasn't explicitly set,
     *  then it's initialized with the <code>measuredHeight</code> of
     *  the first item.
     * 
     *  The items' <code>includeInLayout</code>, 
     *  <code>measuredHeight</code>, <code>minHeight</code>,
     *  and <code>percentHeight</code> properties are ignored when 
     *  <code>variableRowHeight</code> is false.
     * 
     *  @default true
     */
    public function get variableRowHeight():Boolean
    {
        return _variableRowHeight;
    }

    /**
     *  @private
     */
    public function set variableRowHeight(value:Boolean):void
    {
        if (value == _variableRowHeight) 
            return;
        
        _variableRowHeight = value;
        invalidateTargetSizeAndDisplayList();
    }


    private function variableRowHeightMeasure(layoutTarget:GroupBase):void
    {
        var minWidth:Number = 0;
        var minHeight:Number = 0;
        var preferredWidth:Number = 0;
        var preferredHeight:Number = 0;
        var visibleHeight:Number = 0;
        var visibleRows:uint = 0;
        var reqRows:int = requestedRowCount;
         
        var count:uint = layoutTarget.numLayoutItems;
        var totalCount:uint = count; // How many items will be laid out
        for (var i:int = 0; i < count; i++)
        {
            var li:ILayoutItem = layoutTarget.getLayoutItemAt(i);
            if (!li || !li.includeInLayout)
            {
            	totalCount--;
                continue;
            }            

            preferredWidth = Math.max(preferredWidth, li.preferredSize.x);
            preferredHeight += li.preferredSize.y; 
            
            var vrr:Boolean = (reqRows != -1) && (visibleRows < reqRows);

            if (vrr || (reqRows == -1))
            {
                var mw:Number =  hasPercentWidth(li) ? li.minSize.x : li.preferredSize.x;
                var mh:Number = hasPercentHeight(li) ? li.minSize.y : li.preferredSize.y;                   
                minWidth = Math.max(mw, minWidth);
                minHeight += mh;
            }

            if (vrr) 
            {
                visibleHeight = preferredHeight;
                visibleRows += 1;
            }            
        }
        
        if (totalCount > 1)
        { 
            preferredHeight += gap * (totalCount - 1);
            var vgap:Number = (visibleRows > 1) ? (gap * (visibleRows - 1)) : 0;
            visibleHeight += vgap;
            minHeight += vgap;
        }
        
        layoutTarget.measuredWidth = preferredWidth;
        layoutTarget.measuredHeight = (reqRows == -1) ? preferredHeight : visibleHeight;

        layoutTarget.measuredMinWidth = minWidth; 
        layoutTarget.measuredMinHeight = minHeight;

        layoutTarget.setContentSize(preferredWidth, preferredHeight);
    }
   
   
    private function fixedRowHeightMeasure(layoutTarget:GroupBase):void
    {
    	var rows:uint = layoutTarget.numLayoutItems;

		// If rowHeight wasn't set, then use the height of the first row
		var rowHeight:Number = this.rowHeight;
        if (isNaN(explicitRowHeight))
        {
            if (rows == 0)
            	rowHeight = 0;
            else 
      			rowHeight = layoutTarget.getLayoutItemAt(0).preferredSize.y;
        	setRowHeight(rowHeight);
        }

        var reqRows:int = requestedRowCount;
        var visibleRows:uint = (reqRows == -1) ? rows : reqRows;
        var contentHeight:Number = (rows * rowHeight) + ((rows > 1) ? (gap * (rows - 1)) : 0);
        var visibleHeight:Number = (visibleRows * rowHeight) + ((visibleRows > 1) ? (gap * (visibleRows - 1)) : 0);
        
        var columnWidth:Number = layoutTarget.explicitWidth;
        var minColumnWidth:Number = columnWidth;
        if (isNaN(columnWidth)) 
        {
			minColumnWidth = columnWidth = 0;
	        var count:uint = layoutTarget.numLayoutItems;
	        for (var i:int = 0; i < count; i++)
	        {
	            var layoutItem:ILayoutItem = layoutTarget.getLayoutItemAt(i);
	            if (!layoutItem || !layoutItem.includeInLayout) continue;
	            columnWidth = Math.max(columnWidth, layoutItem.preferredSize.x);
	            var itemMinWidth:Number = hasPercentWidth(layoutItem) ? layoutItem.minSize.x : layoutItem.preferredSize.x;
	            minColumnWidth = Math.max(minColumnWidth, itemMinWidth);
	        }
        }     
        
        layoutTarget.measuredWidth = columnWidth;
        layoutTarget.measuredHeight = visibleHeight;

        layoutTarget.measuredMinWidth = minColumnWidth;
        layoutTarget.measuredMinHeight = visibleHeight;
        
        layoutTarget.setContentSize(columnWidth, contentHeight);
    }
    
    
    public function measure():void
    {
    	var layoutTarget:GroupBase = target;
        if (!layoutTarget)
            return;
            
        if (variableRowHeight) 
            variableRowHeightMeasure(layoutTarget);
        else 
            fixedRowHeightMeasure(layoutTarget);

    }
    
    
    public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
    	var layoutTarget:GroupBase = target; 
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
            totalHeightToDistribute -= (totalCount - 1) * gap;

        distributeHeight(layoutItemArray, unscaledWidth, totalHeightToDistribute); 
                            
        // TODO EGeorgie: horizontalAlign
        var hAlign:Number = 0;
        
        // As the LayoutItems are positioned, we'll count how many rows 
        // fall within the layoutTarget's scrollRect
        var visibleRows:uint = 0;
        var minVisibleY:Number = layoutTarget.verticalScrollPosition;
        var maxVisibleY:Number = minVisibleY + unscaledHeight;
        
        // Finally, position the objects        
        var y:Number = 0;
        var maxX:Number = 0;
        var maxY:Number = 0;
        for each (var lo:ILayoutItem in layoutItemArray)
        {
            var x:Number = (unscaledWidth - lo.actualSize.x) * hAlign;
            lo.setActualPosition(x, y);
            var dx:Number = lo.actualSize.x;
            if (!variableRowHeight)
                lo.setActualSize(dx, rowHeight);
            var dy:Number = lo.actualSize.y;
            maxX = Math.max(maxX, x + dx);
            maxY = Math.max(maxY, y + dy);
            if ((y < maxVisibleY) && ((y + dy) > minVisibleY))
            	visibleRows += 1;
            y += dy + gap;
        }
        setRowCount(visibleRows);
        layoutTarget.setContentSize(maxX, maxY);
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
}
}

[ExcludeClass]

import flex.intf.ILayoutItem;
import mx.containers.utilityClasses.FlexChildInfo;

class LayoutItemFlexChildInfo extends FlexChildInfo
{
    public var layoutItem:ILayoutItem;	
}
