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

import flex.core.Group;
import flex.intf.ILayout;
import flex.intf.ILayoutItem;

import mx.containers.utilityClasses.Flex;
import mx.events.PropertyChangeEvent;


/**
 *  Documentation is not currently available.
 */
public class HorizontalLayout extends EventDispatcher implements ILayout
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

    private function invalidateTargetSizeAndDisplayList():void
    {
        var layoutTarget:Group = target;
        if (layoutTarget != null) 
        {
            layoutTarget.invalidateSize();
            layoutTarget.invalidateDisplayList();
        }
    }    

    private var _gap:int = 6;

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
        if (_gap == value) 
            return;
    
		_gap = value;
 	    invalidateTargetSizeAndDisplayList();
    }
    
    //----------------------------------
    //  columnCount
    //----------------------------------

    private var _columnCount:int = -1;
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
     *  Specifies the number of items to display.
     * 
     *  If <code>columnCount</code> is -1, then all of them items are displayed.
     * 
     *  This value implies the layout's <code>measuredWidth</code>.
     * 
     *  If the width of the <code>target</code> has been explicitly set,
     *  then this property has no effect.
     * 
     *  @default -1
     */
    public function get columnCount():int
    {
        return _columnCount;
    }

    /**
     *  Sets the <code>columnCount</code> property without causing
     *  invalidation.  
     * 
     *  This method is intended to be used by subclass updateDisplayList() 
     *  methods to sync the columnCount property with the actual number
     *  of visible columns.
     *
     *  @param value The number of visible columns.
     */
    protected function setColumnCount(value:int):void
    {
        if (_columnCount == value)
            return;
        var oldValue:int = _columnCount;
        _columnCount = value;
        dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "columnCount", oldValue, value));
    }
        
    
    //----------------------------------
    //  requestedColumnCount
    //----------------------------------

    private var _requestedColumnCount:int = -1;
    
    [Inspectable(category="General")]

    /**
     *  Specifies the number of items to display.
     * 
     *  If <code>requestedColumnCount</code> is -1, then all of them items are displayed.
     * 
     *  This value implies the layout's <code>measuredWidth</code>.
     * 
     *  If the width of the <code>target</code> has been explicitly set,
     *  this property has no effect.
     * 
     *  @default -1
     */
    public function get requestedColumnCount():int
    {
        return _requestedColumnCount;
    }

    /**
     *  @private
     */
    public function set requestedColumnCount(value:int):void
    {
        if (_requestedColumnCount == value)
            return;
                               
        _requestedColumnCount = value;
        invalidateTargetSizeAndDisplayList();
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
    
    private var _columnWidth:Number = 20;

    [Inspectable(category="General")]

    /**
     *  Specifies the width of the columns if <code>variableColumnWidth</code>
     *  is false.
     *  
     *  @default 20
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
     *  If false, i.e. "fixed column width" is specified, the width of
     *  each item is set to the value of <code>columnWidth</code>.
     * 
     *  If the <code>columnWidth</code> property wasn't explicitly set,
     *  then it's initialized with the <code>measuredWidth</code> of
     *  the first item.
     * 
     *  The items' <code>includeInLayout</code>, 
     *  <code>measuredWidth</code>, <code>minWidth</code>,
     *  and <code>percentWidth</code> properties are ignored when 
     *  <code>variableColumnWidth</code> is false.
     * 
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
        var reqColumns:int = requestedColumnCount;        
        
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

            preferredHeight = Math.max(preferredHeight, li.preferredSize.y);
            preferredWidth += li.preferredSize.x; 
            
            var vcr:Boolean = (reqColumns != -1) && (visibleColumns < reqColumns);
            if (vcr || (reqColumns == -1))
            {
                var mw:Number =  hasPercentWidth(li) ? li.minSize.x : li.preferredSize.x;
                var mh:Number = hasPercentHeight(li) ? li.minSize.y : li.preferredSize.y;                   
                minWidth += mw;
                minHeight = Math.max(minHeight, mh);
            }
            if (vcr) 
            {
            	visibleWidth = preferredWidth;
            	visibleColumns += 1;
            }
        }
        
        if (totalCount > 1)
        { 
            preferredWidth += gap * (totalCount - 1);
            var vgap:Number = (visibleColumns > 1) ? ((visibleColumns - 1) * gap) : 0;
            visibleWidth +=  vgap;
            minWidth += vgap;
        }
        
        layoutTarget.measuredWidth = (reqColumns == -1) ? preferredWidth : visibleWidth;
        layoutTarget.measuredHeight = preferredHeight;

        layoutTarget.measuredMinWidth = minWidth; 
        layoutTarget.measuredMinHeight = minHeight;
        
        layoutTarget.setContentSize(preferredWidth, preferredHeight);
    }
    
    
    private function fixedColumnWidthMeasure(layoutTarget:Group):void
    {
        var cols:uint = layoutTarget.numLayoutItems;
        
		var columnWidth:Number = this.columnWidth;
        if (isNaN(explicitColumnWidth))
        {
            if (cols == 0)
            	columnWidth = 0;
            else 
      			columnWidth = layoutTarget.getLayoutItemAt(0).preferredSize.x;
        	setColumnWidth(columnWidth);
        }

        var reqColumns:int = requestedColumnCount;        
        var visibleCols:uint = (reqColumns == -1) ? cols : reqColumns;
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
        
        layoutTarget.measuredMinWidth = visibleWidth;
        layoutTarget.measuredMinHeight = minRowHeight;
        
        layoutTarget.setContentSize(contentWidth, rowHeight);
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
        var maxX:Number = 0;
        var maxY:Number = 0;        
        for each (var lo:ILayoutItem in layoutItemArray)
        {
            var y:Number = (unscaledHeight - lo.actualSize.y) * vAlign;
            lo.setActualPosition(x, y);
            var dy:Number = lo.actualSize.y;
            if (!variableColumnWidth)
            	lo.setActualSize(columnWidth, dy);
            var dx:Number = lo.actualSize.x;
            maxX = Math.max(maxX, x + dx);
            maxY = Math.max(maxY, y + dy);            
            if((x < maxVisibleX) && ((x + dx) > minVisibleX))
            	visibleColumns += 1;
            x += dx + gap;
        }
        setColumnCount(visibleColumns);  
        layoutTarget.setContentSize(maxX, maxY);        	      
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
