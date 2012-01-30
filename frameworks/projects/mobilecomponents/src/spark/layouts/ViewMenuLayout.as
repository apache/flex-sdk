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

/**
 *  The ViewMenuLayout class defines the layout of the ViewMenu container.
 *  The menu can have multiple rows depending on the number of menu items.
 *
 *  <p>The <code>requestedMaxColumnCount</code> property 
 *  defines the maximum number of menu items in a row. 
 *  By default, the property is set to three.</p>
 *
 *  <p>The ViewMenuLayout class define the layout as follows: </p>
 *  
 *  <ul>
 *    <li>If you define three or fewer menu items, 
 *       where the <code>requestedMaxColumnCount</code> property contains 
 *       the default value of three, the menu items are displayed in a single row. 
 *       Each menu item has the same size. 
 *       <p>If you define four or more menu items, meaning more menu items 
 *       than specified by the <code>requestedMaxColumnCount</code> property, 
 *       the ViewMenu container creates multiple rows.</p></li>
 *    <li>If the number of menu items is evenly divisible by 
 *       the <code>requestedMaxColumnCount</code> property, 
 *       each row contains the same number of menu items. 
 *       Each menu item is the same size.
 *       <p>For example the <code>requestedMaxColumnCount</code> property 
 *       is set to the default value of three and you define six menu items. 
 *       The menu displays two rows, each containing three menu items. </p></li>
 *    <li>If the number of menu items is not evenly divisible by 
 *       the <code>requestedMaxColumnCount</code> property, 
 *       rows can contain a different number of menu items. 
 *       The size of the menu items depends on the number of menu items 
 *       in the row. 
 *       <p>For example the <code>requestedMaxColumnCount</code> property 
 *       is set to the default value of three and you define eight menu items. 
 *       The menu displays three rows. 
 *       The first row contains two menu items. 
 *       The second and third rows each contains three items. </p></li>
 *  </ul>
 *  
 *  <p>You can create your own custom layout for the menu by creating 
 *  your own layout class.
 *  By default, the spark.skins.mobile.ViewMenuSkin class defines 
 *  the skin for the ViewMenu container. 
 *  To apply a customized ViewMenuLayout class to the ViewMenu container, 
 *  define a new skin class for the ViewMenu container. </p>
 *
 *  <p>The ViewMenuSkin class includes a definition for a Group 
 *  container named <code>contentGroup</code>, as shown below:</p>
 *
 *  <pre>
 *    &lt;s:Group id="contentGroup" left="0" right="0" top="3" bottom="2" 
 *        minWidth="0" minHeight="0"&gt; 
 *        &lt;s:layout&gt; 
 *            &lt;s:ViewMenuLayout horizontalGap="2" verticalGap="2" id="contentGroupLayout" 
 *                requestedMaxColumnCount="3" requestedMaxColumnCount.landscapeGroup="6"/&gt; 
 *        &lt;/s:layout&gt; 
 *    &lt;/s:Group&gt;</pre>
 * 
 *  <p>To apply your customized ViewMenuLayout class, your skin class 
 *  should define a container named <code>contentGroup</code>. 
 *  That container uses the <code>layout</code> property 
 *  to specify your customized layout class. </p>
 *  
 *  @mxml 
 *  <p>The <code>&lt;s:ViewMenuLayout&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:ViewMenuLayout 
 *    <strong>Properties</strong>
 *    horizontalGap="2"
 *    requestedMaxColumnCount="3"
 *    verticalGap="2"
 *  /&gt;
 *  </pre>
 *
 *  @see spark.components.ViewMenu
 *  @see spark.components.ViewMenuItem
 *  @see spark.skins.mobile.ViewMenuSkin
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */ 
public class ViewMenuLayout extends LayoutBase
{

    /**
     *  Constructor. 
     *
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    public function ViewMenuLayout()
    {
        super();
    }
    
    private var numColsInRow:Array;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    private var _horizontalGap:Number = 2;
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    
    /**
     *  The horizontal space between columns, in pixels.
     *
     *  @see #verticalGap
     *  @default 2
     *  
     *  @langversion 3.0
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
     *  The vertical space between rows, in pixels.
     *
     *  @see #horizontalGap
     *  @default 2
     *  
     *  @langversion 3.0
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
     *  The maximum number of columns to display in a row. 
     *
     *  @default 3
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get requestedMaxColumnCount():int
    {
        return _requestedMaxColumnCount;
    }
    
    /**
     *  @private
     */
    public function set requestedMaxColumnCount(value:int):void
    {
        if (_requestedMaxColumnCount == value)
            return;
        
        _requestedMaxColumnCount = value;
        
        invalidateTargetSizeAndDisplayList();
    }
    
    private var rowHeight:Number = 0;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------
    
    // TODO (jszeto) Fix up logic to use brick algorithm. Might not have full number of columns
    /**
     *  @private
     */
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
    
    
    /**
     *  @private
     */
    override public function updateDisplayList(width:Number, height:Number):void
    {
        super.updateDisplayList(width, height);
        
        var layoutTarget:GroupBase = target;
        if (!layoutTarget)
            return;
        
        numColsInRow = [];
        
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
        
        for (var rowIndex:int = 0; rowIndex < numRows; rowIndex++)
        {    
            var currentRowColumns:int = (emptySpots > 0) ? numColumns - 1 : numColumns;
            var viewWidth:Number = width - (currentRowColumns - 1) * horizontalGap;
            var w:Number = itemW = Math.floor(viewWidth / currentRowColumns);
            
            numColsInRow.push(currentRowColumns);
            
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
            
            emptySpots = (numItems % numColumns) > 0 ? numColumns - numItems % numColumns : 0;
        }
    }
    
    /**
     *  @private
     */
    override public function getNavigationDestinationIndex(currentIndex:int, navigationUnit:uint, arrowKeysWrapFocus:Boolean):int
    {
        if (!target || target.numElements < 1)
            return -1; 
        
        var maxIndex:int = target.numElements - 1;
        var newIndex:int = 0;
        var numRows:int = Math.ceil(target.numElements / requestedMaxColumnCount);
        
        if (currentIndex == -1)
        {
            if (navigationUnit == NavigationUnit.RIGHT || navigationUnit == NavigationUnit.DOWN)
                return 0;    
            else
                return -1;
        }  
        
        var currentRow:int = getRowForIndex(currentIndex);
        var currentColCount:int;
        var newColCount:int;
                
        if (navigationUnit == NavigationUnit.LEFT ||
            navigationUnit == NavigationUnit.RIGHT)
            
        {
            newIndex = currentIndex + (navigationUnit == NavigationUnit.LEFT ? -1 : 1);
            
            // We don't support wrapping, so if the old and new index are 
            // on different rows, then don't change the index. 
            if (getRowForIndex(newIndex) != currentRow)
                newIndex = currentIndex;        
        }
        else if (navigationUnit == NavigationUnit.UP)
        {
            if (currentRow == 0)
                return currentIndex;
            
            currentColCount = numColsInRow[currentRow];
            newColCount = numColsInRow[currentRow - 1];
            
            newIndex = currentIndex - newColCount;
            
            // If the newIndex isn't on the previous row, then we need to shift
            // it back one more spot. This situation only occurs when the 
            // number of columns in the two rows are different
            if ((getRowForIndex(newIndex) != currentRow - 1) && (currentColCount != newColCount))
            {
                newIndex--;
            }
        }
        else if (navigationUnit == NavigationUnit.DOWN)
        {
            if (currentRow == numRows - 1)
                return currentIndex;
            
            // Assumes that the smaller column rows are always above the larger column rows
            newIndex = currentIndex + numColsInRow[currentRow];
        }
        
        if (newIndex > maxIndex)
            newIndex = maxIndex;
        else if (newIndex < 0)
            newIndex = 0;
        
        return newIndex;
    }
    
    // Helper function that figures out the row of a particular index
    private function getRowForIndex(index:int):int
    {
        var currentRow:int = 0;
        
        while (currentRow < numColsInRow.length)
        {  
            index -= numColsInRow[currentRow];

            if (index >= 0)
                currentRow++;
            else
                break;
        }
        
        return currentRow;
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