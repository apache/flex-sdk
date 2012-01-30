////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.layouts
{
import mx.core.IVisualElement;

import spark.components.supportClasses.GroupBase;
import spark.core.NavigationUnit;
import spark.layouts.supportClasses.LayoutBase;

public class ViewMenuLayout extends LayoutBase
{
    public function ViewMenuLayout()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    private var _horizontalGap:Number = 2;
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    
    /**
     *  Horizontal space between columns, in pixels.
     *
     *  @see #verticalGap
     *  @default 2
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get horizontalGap():Number
    {
        return _horizontalGap;
    }
    
    /**
     *  @private
     */
    public function set horizontalGap(value:Number):void
    {
        if (value == _horizontalGap)
            return;
        
        _horizontalGap = value;
        invalidateTargetSizeAndDisplayList();
    }
    
    private var _verticalGap:Number = 2;
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    
    /**
     *  Vertical space between rows, in pixels.
     *
     *  @see #horizontalGap
     *  @default 2
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get verticalGap():Number
    {
        return _verticalGap;
    }
    
    /**
     *  @private
     */
    public function set verticalGap(value:Number):void
    {
        if (value == _verticalGap)
            return;
        
        _verticalGap = value;
        invalidateTargetSizeAndDisplayList();
    }
    
    private var _requestedMaxColumnCount:int = 3;
    
    /**
     *  Maximumn number of columns to display per row. 
     *
     *  @default 3
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get requestedMaxColumnCount():int
    {
        return _requestedMaxColumnCount;
    }
    
    public function set requestedMaxColumnCount(value:int):void
    {
        if (_requestedMaxColumnCount == value)
            return;
        
        _requestedMaxColumnCount = value;
        target.invalidateSize();
        target.invalidateDisplayList();
    }
    
    private var rowHeight:Number = 0;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------
    
    // TODO (jszeto) Fix up logic to use brick algorithm. Might not have full number of columns
    override public function measure():void
    {
        super.measure();
        
        var layoutTarget:GroupBase = target;
        if (!layoutTarget)
            return;
        
        var numItems:int = layoutTarget.numElements;
        var numRows:int = Math.ceil(numItems / requestedMaxColumnCount);
        var numColumns:int = Math.ceil(numItems / numRows);
        
        var maxItemWidth:Number = 0;
        var maxItemHeight:Number = 0;
        
        for (var i:int = 0; i < numItems; i++)
        {
            var item:IVisualElement = layoutTarget.getElementAt(i);
            maxItemWidth = Math.max(maxItemWidth, item.getPreferredBoundsWidth());
            maxItemHeight = Math.max(maxItemHeight, item.getPreferredBoundsHeight());
        }
        
        layoutTarget.measuredWidth = Math.ceil(maxItemWidth * numColumns) + (numColumns - 1) * horizontalGap;
        layoutTarget.measuredHeight = Math.ceil(maxItemHeight * numRows) + (numRows - 1) * verticalGap;
        
        // Save the maxItemHeight and use in updateDisplayList as the height for all items
        rowHeight = maxItemHeight;
        
    }
    
    
    override public function updateDisplayList(width:Number, height:Number):void
    {
        super.updateDisplayList(width, height);
        
        var layoutTarget:GroupBase = target;
        if (!layoutTarget)
            return;
        
        var xPos:Number = 0;
        var yPos:Number = 0;
        var itemIndex:int = 0;
        var itemW:int = 0;
        var extraWidth:int = 0;
        
        var numItems:int = layoutTarget.numElements;
        var numRows:int = Math.ceil(numItems / requestedMaxColumnCount);
        var numColumns:int = Math.ceil(numItems / numRows);
        // Calculate the number of empty spots by getting the inverse of the column mod
        var emptySpots:int = (numItems % numColumns) > 0 ? numColumns - numItems % numColumns : 0;
        // Figure out whether the first row has more or fewer items. Default is fewer.
        var useMaxColumns:Boolean = (numRows % 2 == 1) ? Math.floor(numRows / 2) == emptySpots: false;        
        
        for (var rowIndex:int = 0; rowIndex < numRows; rowIndex++)
        {    
            var currentRowColumns:int = (emptySpots > 0) && !useMaxColumns ? numColumns - 1 : numColumns;
            var viewWidth:Number = width - (currentRowColumns - 1) * horizontalGap;
            var w:Number = itemW = Math.floor(viewWidth / currentRowColumns);
            // Keep track of the extra pixels since we round off the item widths
            extraWidth = Math.round(viewWidth - w * currentRowColumns);
            
            for (var colIndex:int = 0; colIndex < currentRowColumns; itemIndex++, colIndex++)
            {
                var item:IVisualElement = layoutTarget.getElementAt(itemIndex);
                
                // Add a pixel of extra width to the first item
                if (extraWidth > 0)
                {
                    itemW += 1;
                    extraWidth--;
                }
                
                item.setLayoutBoundsPosition(xPos, yPos);
                item.setLayoutBoundsSize(itemW, rowHeight);
                
                xPos += itemW + horizontalGap;
                itemW = w;
            }
            
            xPos = 0;
            yPos += rowHeight + verticalGap;   
            
            numItems -= currentRowColumns;
            useMaxColumns = !useMaxColumns;
            
            emptySpots = (numItems % numColumns) > 0 ? numColumns - numItems % numColumns : 0;
        }
    }
    
    override public function getNavigationDestinationIndex(currentIndex:int, navigationUnit:uint, arrowKeysWrapFocus:Boolean):int
    {
        // TODO (jszeto) Currently we just support LEFT/RIGHT. Need to add logic for UP/DOWN/PGUP/PGDN
        if (!target || target.numElements < 1)
            return -1; 
        
        var maxIndex:int = target.numElements - 1;
        var newIndex:int;
        
        if (currentIndex == -1)
        {
            if (navigationUnit == NavigationUnit.LEFT)
                return maxIndex;
            else if (navigationUnit == NavigationUnit.RIGHT)
                return 0;    
        }   
        
        if (navigationUnit == NavigationUnit.LEFT)
            newIndex = currentIndex - 1;
        else if (navigationUnit == NavigationUnit.RIGHT)
            newIndex = currentIndex + 1;
        else
            return currentIndex;
        
        if (newIndex > maxIndex)
            newIndex = 0;
        else if (newIndex < 0)
            newIndex = maxIndex;
        
        return newIndex;
    }
    
    // Helper function
    private function invalidateTargetSizeAndDisplayList():void
    {
        var g:GroupBase = target;
        if (!g)
            return;
        
        g.invalidateSize();
        g.invalidateDisplayList();
    }
}
    
    
}