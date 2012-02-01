package spark.layouts
{
import flash.utils.Dictionary;

import mx.containers.errors.ConstraintError;
import mx.containers.utilityClasses.ConstraintColumn;
import mx.containers.utilityClasses.ConstraintRow;
import mx.core.ILayoutElement;
import mx.core.mx_internal;
import mx.resources.ResourceManager;

import spark.components.supportClasses.GroupBase;
import spark.layouts.supportClasses.LayoutBase;
import spark.layouts.supportClasses.LayoutElementHelper;

use namespace mx_internal;

[ResourceBundle("layout")]

/**
 *  The ConstraintLayout class arranges the layout elements based on their individual
 *  settings and a set of constraint regions defined by constraint columns and
 *  constraint rows. Although you can use all of the properties and constraints from
 *  BasicLayout to position and size elements, ConstraintLayout gives you the ability
 *  to create sibling-relative layouts by constraining elements to the specified
 *  columns and rows. 
 *
 *  <p><b>Note: </b>The Spark list-based controls (the Spark List control and its subclasses
 *  such as ButtonBar, ComboBox, DropDownList, and TabBar) do not support the ConstraintLayout class. 
 *  Do not use ConstraintLayout with the Spark list-based controls.</p>
 *
 *  <p>Per-element supported constraints are <code>left</code>, <code>right</code>, 
 *  <code>top</code>, <code>bottom</code>, <code>baseline</code>,
 *  <code>percentWidth</code>, and <code>percentHeight</code>.
 *  Element's minimum and maximum sizes will always be respected.</p>
 * 
 *  <p>Columns and rows may have an explicit size or content size (no explicit size). 
 *  Explicit size regions will be fixed at their specified size, while content size
 *  regions will stretch to fit only the elements constrained to them. If multiple
 *  content size regions are spanned by an element, the space will be divided
 *  equally among the content size regions.</p>
 *
 *  <p>The measured size of the container is calculated from the elements, their
 *  constraints, their preferred sizes, and the sizes of the rows and columns.
 *  The size of each row and column is just big enough to hold all of the elements
 *  constrained to it at their preferred sizes with constraints satisfied. The measured
 *  size of the container is big enough to hold all of the columns and rows as well as
 *  any other elements left at their preferred sizes with constraints satisfied. </p>
 *
 *  <p>During a call to the <code>updateDisplayList()</code> method, 
 *  the element's size is determined according to
 *  the rules in the following order of precedence (the element's minimum and
 *  maximum sizes are always respected):</p>
 *  <ul>
 *    <li>If the element has <code>percentWidth</code> or <code>percentHeight</code> set, 
 *    then its size is calculated as a percentage of the available size, where the available
 *    size is the region or container size minus any <code>left</code>, <code>right</code>,
 *    <code>top</code>, or <code>bottom</code> constraints.</li>
 *
 *    <li>If the element has both left and right constraints, it's width is
 *    set to be the region's or container's width minus the <code>left</code> 
 *    and <code>right</code> constraints.</li>
 * 
 *    <li>If the element has both <code>top</code> and <code>bottom</code> constraints, 
 *    it's height is set to be the container's height minus the <code>top</code> 
 *    and <code>bottom</code> constraints.</li>
 *
 *    <li>The element is set to its preferred width and/or height.</li>
 *  </ul>
 * 
 *  <p>The element's position is determined according to the rules in the following
 *  order of precedence:</p>
 *  <ul>
 *    <li>If element's baseline is specified, then the element is positioned in
 *    the vertical direction such that its <code>baselinePosition</code> (usually the base line
 *    of its first line of text) is aligned with <code>baseline</code> constraint.</li>
 *
 *    <li>If element's <code>top</code> or <code>left</code> constraints 
 *    are specified, then the element is
 *    positioned such that the top-left corner of the element's layout bounds is
 *    offset from the top-left corner of the container by the specified values.</li>
 *
 *    <li>If element's <code>bottom</code> or <code>right</code> constraints are specified, 
 *    then the element is positioned such that the bottom-right corner 
 *    of the element's layout bounds is
 *    offset from the bottom-right corner of the container by the specified values.</li>
 * 
 *    <li>When no constraints determine the position in the horizontal or vertical
 *    direction, the element is positioned according to its x and y coordinates.</li>
 *  </ul>
 *
 *  <p>The content size of the container is calculated as the maximum of the
 *  coordinates of the bottom-right corner of all the layout elements and 
 *  constraint regions.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4.5
 */
public class ConstraintLayout extends LayoutBase
{
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     * 
     *  @return true if the constraints determine the element's width;
     */
    private static function constraintsDetermineWidth(elementInfo:ElementConstraintInfo):Boolean
    {
        return !isNaN(elementInfo.left) && !isNaN(elementInfo.right);
    }
    
    /**
     *  @private
     * 
     *  @return true if the constraints determine the element's height;
     */
    private static function constraintsDetermineHeight(elementInfo:ElementConstraintInfo):Boolean
    {
        return !isNaN(elementInfo.top) && !isNaN(elementInfo.bottom);
    }
    
    /**
     *  @private
     *  @return Returns the maximum value for an element's dimension so that the component doesn't
     *  spill out of the container size. Calculations are based on the layout rules.
     *  Pass in unscaledWidth, left, right, childX to get a maxWidth value.
     *  Pass in unscaledHeight, top, bottom, childY to get a maxHeight value.
     */
    static private function maxSizeToFitIn(totalSize:Number,
                                           lowConstraint:Number,
                                           highConstraint:Number,
                                           position:Number):Number
    {
        if (!isNaN(lowConstraint))
        {
            // childWidth + left <= totalSize
            return totalSize - lowConstraint;
        }
        else if (!isNaN(highConstraint))
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
     *  @productversion Flex 4.5
     */
    public function ConstraintLayout()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Vectors that keep track of children spanning
     *  content size columns or rows or whether the 
     *  elements don't use columns or rows at all.
     */
    private var colSpanElements:Vector.<ElementConstraintInfo> = null;
    private var rowSpanElements:Vector.<ElementConstraintInfo> = null;
    private var otherElements:Vector.<ElementConstraintInfo> = null;
    
    /**
     *  @private
     *  Vectors to store the baseline property of the rows, and
     *  the maximum ascent of the elements in each row.
     */
    private var rowBaselines:Vector.<Array> = null;
    private var rowMaxAscents:Vector.<Number> = null;
    
    private var constraintCache:Dictionary = null;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  constraintColumns
    //----------------------------------
    
    private var _constraintColumns:Vector.<ConstraintColumn> = new Vector.<ConstraintColumn>(0, true);
    // An associative array of column id --> column index
    private var columnsObject:Object = new Object();
    
    /**
     *  A Vector of ConstraintColumn instances that partition the target container.
     *  The ConstraintColumn instance at index 0 is the left-most column;
     *  indices increase from left to right. 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get constraintColumns():Vector.<ConstraintColumn>
    {
        // make defensive copy
        return _constraintColumns.slice();
    }
    
    /**
     *  @private
     */
    public function set constraintColumns(value:Vector.<ConstraintColumn>):void
    {   
        // clear constraintColumns
        if (value == null)
        {
            _constraintColumns = new Vector.<ConstraintColumn>(0, true);
            columnsObject = new Object();
            return;
        }
        
        var n:int = value.length;
        var col:ConstraintColumn;
        var temp:Vector.<ConstraintColumn> = value.slice();
        var obj:Object = new Object();
        
        for (var i:int = 0; i < n; i++)
        {
            col = temp[i];
            col.container = this.target;
            obj[col.id] = i;
            
            // TODO (klin): Allow percentWidth columns.
            if (!isNaN(col.percentWidth))
                throw new Error(ResourceManager.getInstance().getString("layout", "percentWidthColumn"));
        }
        
        _constraintColumns = temp;
        columnsObject = obj;
        
        if (target)
        {
            target.invalidateSize();
            target.invalidateDisplayList();
        }
    }
    
    //----------------------------------
    //  constraintRows
    //----------------------------------
    
    private var _constraintRows:Vector.<ConstraintRow> = new Vector.<ConstraintRow>(0, true);
    // An associative array of row id --> row index
    private var rowsObject:Object = new Object();
    
    /**
     *  A Vector of ConstraintRow instances that partition the target container.
     *  The ConstraintRow instance at index 0 is the top-most column;
     *  indices increase from top to bottom. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get constraintRows():Vector.<ConstraintRow> 
    {
        return _constraintRows.slice();
    }
    
    /**
     *  @private
     */
    public function set constraintRows(value:Vector.<ConstraintRow>):void
    {
        // clear constraintRows
        if (value == null)
        {
            _constraintRows = new Vector.<ConstraintRow>(0, true);
            rowsObject = new Object();
            return;
        }
        
        var n:int = value.length;
        var row:ConstraintRow;
        var temp:Vector.<ConstraintRow> = value.slice();
        var obj:Object = new Object();
        rowBaselines = new Vector.<Array>();
        
        for (var i:int = 0; i < n; i++)
        {
            row = temp[i];
            row.container = this.target;
            obj[row.id] = i;
            rowBaselines[i] = LayoutElementHelper.parseConstraintExp(row.baseline);
            
            var maxAscentStr:String = rowBaselines[i][1];
            if (maxAscentStr && maxAscentStr != "maxAscent")
                throw new Error(ResourceManager.getInstance().getString("layout", "invalidBaselineOnRow",
                                                                        [ row.id, row.baseline ]));
            
            if (!isNaN(row.percentHeight))
                throw new Error(ResourceManager.getInstance().getString("layout", "percentHeightRow"));
        }
        
        _constraintRows = temp;
        rowsObject = obj;
        
        if (target)
        {
            target.invalidateSize();
            target.invalidateDisplayList();
        }
    }
    
    /**
     *  @private
     *  Resets the target on the constraintColumns and constraintRows.
     */
    override public function set target(value:GroupBase):void
    {
        super.target = value;
        
        // setting a new target means we need to reset the targets of
        // our columns and rows
        var i:int;
        var n:int = _constraintColumns.length;

        for (i = 0; i < n; i++)
        {
            _constraintColumns[i].container = value;
        }
        
        n = _constraintRows.length;
        for (i = 0; i < n; i++)
        {
            _constraintRows[i].container = value;
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden Methods: LayoutBase
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     * 
     *  1) Parse each element constraint and populate the constraintCache
     *  2) Measure the columns and rows based on only the elements that use them
     *     and get the sum of the column widths and row heights.
     *  3) Measure the size of this container based on elements that don't use
     *     either columns or rows or both.
     *  4) Take the max of 2 and 3 to find the measuredWidth.
     */
    override public function measure():void
    {
        checkUseVirtualLayout();
        super.measure();
        
        var layoutTarget:GroupBase = target;
        if (!layoutTarget)
            return;

        var width:Number = 0;
        var height:Number = 0;
        var minWidth:Number = 0;
        var minHeight:Number = 0;
        
        parseConstraints();
        
        // TODO (klin): minimum will be different when percent size comes into play
        var colWidths:Vector.<Number> = measureColumns();
        var rowHeights:Vector.<Number> = measureRows();
        var n:Number;
        
        for each (n in colWidths)
        {
            width += n;
        }
        minWidth = width;
        for each (n in rowHeights)
        {
            height += n;
        }
        minHeight = height;
        
        if (otherElements)
        {
            var vec:Vector.<Number> = measureOtherContent();
            
            width = Math.max(width, vec[0]);
            height = Math.max(height, vec[1]);
            minWidth = Math.max(minWidth, vec[2]);
            minHeight = Math.max(minHeight, vec[3]);
        }

        layoutTarget.measuredWidth = Math.ceil(width);
        layoutTarget.measuredHeight = Math.ceil(height);
        layoutTarget.measuredMinWidth = Math.ceil(minWidth);
        layoutTarget.measuredMinHeight = Math.ceil(minHeight);
        
        // clear out cache
        colSpanElements = null;
        rowSpanElements = null;
        otherElements = null;
        rowMaxAscents = null;
        constraintCache = null;
    }
    
    /**
     *  @private
     * 
     *  1) Re-parse element constraints because they may have changed.
     *  2) Resize and reposition the columns and rows based on new constraints.
     *  3) Size and position the elements in the available space.
     */
    override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        checkUseVirtualLayout();
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        var layoutTarget:GroupBase = target;
        if (!layoutTarget)
            return;
        
        // Need to measure in case of explicit width and height on target.
        // Also need to reparse constraints in case of something changing.
        measureAndPositionColumnsAndRows();
        
        layoutContent(unscaledWidth, unscaledHeight);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods: Used by FormItemLayout
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Lays out the elements of the layoutTarget using the current
     *  widths and heights of the columns and rows. Used by FormItemLayout
     *  after setting new column widths to lay elements using those new widths.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */ 
    protected function layoutContent(unscaledWidth:Number, unscaledHeight:Number):void
    {
        var layoutTarget:GroupBase = target;
        if (!layoutTarget)
            return;
        
        var count:int = layoutTarget.numElements;
        var layoutElement:ILayoutElement;
        
        var maxX:Number = 0;
        var maxY:Number = 0;
        
        // update children
        for (var i:int = 0; i < count; i++)
        {
            layoutElement = layoutTarget.getElementAt(i);
            if (!layoutElement || !layoutElement.includeInLayout)
                continue;
            
            applyConstraintsToElement(unscaledWidth, unscaledHeight, layoutElement);
            
            // update content limits
            maxX = Math.max(maxX, layoutElement.getLayoutBoundsX() +
                            layoutElement.getLayoutBoundsWidth());
            maxY = Math.max(maxY, layoutElement.getLayoutBoundsY() +
                            layoutElement.getLayoutBoundsHeight());
        }
        
        // Make sure that if the content spans partially over a pixel to the right/bottom,
        // the content size includes the whole pixel.
        layoutTarget.setContentSize(Math.ceil(maxX), Math.ceil(maxY));
        
        // clear out cache
        colSpanElements = null;
        rowSpanElements = null;
        otherElements = null;
        rowMaxAscents = null;
        constraintCache = null;
    }
    
    /**
     *  Used by FormItemLayout to measure and set new column widths
     *  before laying out the elements.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    protected function measureAndPositionColumnsAndRows():void
    {
        parseConstraints();
        setColumnWidths(measureColumns());
        setRowHeights(measureRows());
    }
    
    /**
     *  Used to set new column widths before laying out the elements.
     *  Used by FormItemLayout to set column widths provided by the
     *  Form.
     */ 
    protected function setColumnWidths(value:Vector.<Number>):void
    {
        if (value == null)
            return;
        
        var constraintColumns:Vector.<ConstraintColumn> = this.constraintColumns;
        var numCols:int = constraintColumns.length;
        var totalWidth:Number = 0;
        
        for (var i:int = 0; i < numCols; i++)
        {
            constraintColumns[i].setActualWidth(value[i]);
            constraintColumns[i].x = totalWidth;
            totalWidth += value[i];
        }
    }
    
    /**
     *  Used to set new row heights before laying out the elements.
     */ 
    protected function setRowHeights(value:Vector.<Number>):void
    {
        if (value == null)
            return;
        
        var constraintRows:Vector.<ConstraintRow> = this.constraintRows;
        var numRows:int = constraintRows.length;
        var totalHeight:Number = 0;
        
        for (var i:int = 0; i < numRows; i++)
        {
            constraintRows[i].setActualHeight(value[i]);
            constraintRows[i].y = totalHeight;
            totalHeight += value[i];
        }
    }

    /**
     *  @private
     *  This function is mx_internal so that FormItemLayout can use it
     *  in its updateDisplayList.
     */
    mx_internal function checkUseVirtualLayout():void
    {
        if (useVirtualLayout)
            throw new Error(ResourceManager.getInstance().getString("layout", "constraintLayoutNotVirtualized"));
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Sizes and positions the element based on the given size of the container
     *  and the element's constraints.
     * 
     *  1) Retrieves element constraints from the constraint cache.
     *  2) Determines the x and y boundaries of each side.
     *  3) Sizes the element based on constraints and its preferred
     *     size. The precedence for sizing is as follows: percent, 
     *     top and bottom constraints, preferred size.
     *  4) Positions the element based on its constraints. The precedence
     *     for positioning is as follows: baseline, left and top, right and bottom,
     *     x and y.  
     */
    private function applyConstraintsToElement(unscaledWidth:Number,
                                               unscaledHeight:Number,
                                               layoutElement:ILayoutElement):void
    {
        var elementInfo:ElementConstraintInfo = constraintCache[layoutElement];
        
        var left:Number = elementInfo.left;
        var right:Number = elementInfo.right;
        var top:Number = elementInfo.top;
        var bottom:Number = elementInfo.bottom;
        var baseline:Number = elementInfo.baseline;
        
        var leftBoundary:String = elementInfo.leftBoundary;
        var rightBoundary:String = elementInfo.rightBoundary;
        var topBoundary:String = elementInfo.topBoundary;
        var bottomBoundary:String = elementInfo.bottomBoundary;
        var baselineBoundary:String = elementInfo.baselineBoundary;
        
        var percentWidth:Number = layoutElement.percentWidth;
        var percentHeight:Number = layoutElement.percentHeight;
        
        var availableWidth:Number;
        var availableHeight:Number;
        
        var elementWidth:Number = NaN;
        var elementHeight:Number = NaN;
        var elementMaxWidth:Number = NaN;
        var elementMaxHeight:Number = NaN;
        var elementX:Number = 0;
        var elementY:Number = 0;
        
        var leftHolder:Number = 0;
        var rightHolder:Number = unscaledWidth;
        var topHolder:Number = 0;
        var bottomHolder:Number = unscaledHeight;
        var baselineHolder:Number = 0;
        
        var i:Number;
        
        var col:ConstraintColumn;
        var row:ConstraintRow;
        
        if (leftBoundary)
        {
            col = _constraintColumns[elementInfo.colSpanLeftIndex];
            leftHolder = col.x;
        }
        
        if (rightBoundary)
        {
            col = _constraintColumns[elementInfo.colSpanRightIndex];
            rightHolder = col.x + col.width;
        }
        
        if (topBoundary)
        {
            row = _constraintRows[elementInfo.rowSpanTopIndex];
            topHolder = row.y;
        }
        
        if (bottomBoundary)
        {
            row = _constraintRows[elementInfo.rowSpanBottomIndex];
            bottomHolder = row.y + row.height;
        }
        
        if (baselineBoundary)
        {
            var baselineIndex:Number = elementInfo.baselineIndex;
            var rowBaseline:Array = rowBaselines[baselineIndex];
            row = _constraintRows[baselineIndex];
            
            // add baseline offset from row.
            baselineHolder = row.y + Number(rowBaseline[0]);
            
            // add maxAscent. maxAscent defaults to 0 if not specified.
            if (rowMaxAscents)
                baselineHolder += rowMaxAscents[baselineIndex];
            
            // If bottom doesn't exist, then the bottom should be restricted to the
            // baseline row.
            if (isNaN(bottom))
                bottomHolder = row.y + row.height;
        }
        
        // available width
        availableWidth = Math.round(rightHolder - leftHolder);
        
        // cases are baseline with top and bottom, 
        // baseline with top, baseline with bottom, no baseline
        if (!isNaN(baseline) && (isNaN(top) || isNaN(bottom)))
            availableHeight = Math.round(bottomHolder - baselineHolder);
        else
            availableHeight = Math.round(bottomHolder - topHolder);
        
        // set width
        if (!isNaN(percentWidth))
        {
            if (!isNaN(left))
                availableWidth -= left;
            if (!isNaN(right))
                availableWidth -= right;
            
            elementWidth = Math.round(availableWidth * Math.min(percentWidth * 0.01, 1));
            elementMaxWidth = Math.min(layoutElement.getMaxBoundsWidth(),
                maxSizeToFitIn(unscaledWidth, left, right, layoutElement.getLayoutBoundsX()));
        }
        else if (!isNaN(left) && !isNaN(right))
        {
            elementWidth = availableWidth - left - right;
        }
        
        // set height
        if (!isNaN(percentHeight))
        {
            if (!isNaN(top))
                availableHeight -= top;
            if (!isNaN(bottom))
                availableHeight -= bottom;    
            
            elementHeight = Math.round(availableHeight * Math.min(percentHeight * 0.01, 1));
            elementMaxHeight = Math.min(layoutElement.getMaxBoundsHeight(),
                maxSizeToFitIn(unscaledHeight, top, bottom, layoutElement.getLayoutBoundsY()));
        }
        else if (!isNaN(top) && !isNaN(bottom))
        {
            elementHeight = availableHeight - top - bottom;
        }
        
        // Apply min and max constraints, make sure min is applied last. In the cases
        // where elementWidth and elementHeight are NaN, setLayoutBoundsSize will use preferredSize
        // which is already constrained between min and max.
        if (!isNaN(elementWidth))
        {
            if (isNaN(elementMaxWidth))
                elementMaxWidth = layoutElement.getMaxBoundsWidth();
            elementWidth = Math.max(layoutElement.getMinBoundsWidth(), Math.min(elementMaxWidth, elementWidth));
        }
        
        if (!isNaN(elementHeight))
        {
            if (isNaN(elementMaxHeight))
                elementMaxHeight = layoutElement.getMaxBoundsHeight();
            elementHeight = Math.max(layoutElement.getMinBoundsHeight(), Math.min(elementMaxHeight, elementHeight));
        }
        
        layoutElement.setLayoutBoundsSize(elementWidth, elementHeight);
        // update temp variables
        elementWidth = layoutElement.getLayoutBoundsWidth();
        elementHeight = layoutElement.getLayoutBoundsHeight();
        
        // Horizontal Position
        if (!isNaN(left))
            elementX = leftHolder + left;
        else if (!isNaN(right))
            elementX = rightHolder - right - elementWidth;
        else
            elementX = layoutElement.getLayoutBoundsX();
        
        // Vertical Position
        if (!isNaN(baseline))
            elementY = baselineHolder + baseline - layoutElement.baselinePosition;
        else if (!isNaN(top))
            elementY = topHolder + top;
        else if (!isNaN(bottom))
            elementY = bottomHolder - bottom - elementHeight;
        else
            elementY = layoutElement.getLayoutBoundsY();
        
        layoutElement.setLayoutBoundsPosition(elementX, elementY);
    }
    
    /** 
     *  @private
     *  This function measures the ConstraintColumns partitioning
     *  the target and returns their new widths. The calculations
     *  are based on the current constraintCache. To update the
     *  constraintCache, one needs to call the parseConstraints()
     *  method.
     * 
     *  The algorithm works like this:
     *  1. Fixed columns honor their pixel values.
     * 
     *  2. Content sized columns whose children span
     *  only that column assume the width of the widest child. 
     * 
     *  3. (not implemented) Those Content sized columns that span multiple 
     *  columns do the following:
     *    a. Sort the children by order of how many columns they
     *    are spanning.
     *    b. For children spanning a single column, make each 
     *    column as wide as the preferred size of the child.
     *    c. For subsequent children, divide the remainder space
     *    equally between shared columns. 
     * 
     *  4. (not implemented) Remaining space is shared between the percentage size
     *  columns.
     * 
     *  5. x positions are set based on the column widths
     * 
     *  6. Sum the column widths to get the total measured width of the target.
     * 
     *  @return a vector of the new column widths.
     */
    private function measureColumns():Vector.<Number>
    {
        // TODO (klin): Parameterize this to work for both columns and rows.
        // This may mean we need to add some mx_internal properties to 
        // the columns for "major size", etc... Question is, what about
        // 1-D properties like baseline? What parts can we parameterize and
        // what parts aren't possible.
        
        if (_constraintColumns.length <= 0)
            return new Vector.<Number>();
        
        var measuredWidth:Number = 0;
        var i:Number;
        var numCols:Number = _constraintColumns.length;
        var col:ConstraintColumn;
        var hasContentSize:Boolean = false;
        var colWidths:Vector.<Number> = new Vector.<Number>();
        
        // Start column widths at the minWidth of each column or
        // its explicit width.
        for (i = 0; i < numCols; i++)
        {
            col = _constraintColumns[i];
            if (col.contentSize)
            {
                hasContentSize = true;
                
                if (!isNaN(col.minWidth))
                    colWidths[i] = Math.ceil(Math.max(col.minWidth, 0));
                else
                    colWidths[i] = 0;
            }
            else if (!isNaN(col.explicitWidth))
            {
                var w:Number = col.width;
                
                if (!isNaN(col.minWidth))
                    w = Math.max(w, col.minWidth);
                
                if (!isNaN(col.maxWidth))
                    w = Math.min(w, col.maxWidth);
                
                colWidths[i] = Math.ceil(w);
            }
        }
        
        // Assumption: elements in colSpanElements have one or more constraints touching a column.
        // This is enforced in parseElementConstraints().
        if (colSpanElements && hasContentSize)
        {
            var numColSpanElements:Number = colSpanElements.length;
            
            // Measure content size columns only single span for now.
            // If multiple span, do nothing yet.
            for (i = 0; i < numColSpanElements; i++)
            {
                var elementInfo:ElementConstraintInfo = colSpanElements[i];
                var layoutElement:ILayoutElement = elementInfo.layoutElement;
                var leftIndex:int = -1;
                var rightIndex:int = -1;
                var span:int;
                
                var extX:Number = 0;
                var preferredWidth:Number = layoutElement.getPreferredBoundsWidth();
                var maxExtent:Number;
                var availableWidth:Number;
                
                var j:int;
                var colWidth:Number = 0;
                
                // Determine how much space the element needs to satisfy its
                // constraints and be at its preferred width.
                if (!isNaN(elementInfo.left))
                {
                    extX += elementInfo.left;
                    if (elementInfo.leftBoundary)
                        leftIndex = elementInfo.colSpanLeftIndex;
                    else
                        leftIndex = 0; // constrained to parent
                }
                
                if (!isNaN(elementInfo.right))
                {
                    extX += elementInfo.right;
                    if (elementInfo.rightBoundary)
                        rightIndex = elementInfo.colSpanRightIndex;
                    else
                        rightIndex = numCols - 1; // constrained to parent
                }
                
                maxExtent = extX + preferredWidth;
                availableWidth = maxExtent;
                
                // If either the left or the right constraint doesn't exist,
                // we must find the span of the element. We do this by
                // determining the index of the last column that the element
                // occupies in the unconstrained direction.
                if (leftIndex < 0 || rightIndex < 0)
                {
                    var isLeft:Boolean = leftIndex < 0;
                    var startIndex:int = isLeft ? rightIndex : leftIndex;
                    var endIndex:int = isLeft ? -1 : numCols;
                    var increment:int = isLeft ? -1 : 1;
                    
                    // defaults to 0
                    if (isLeft)
                        leftIndex = 0;
                    else // defaults to numCols - 1
                        rightIndex = numCols - 1;
                    
                    for (j = startIndex; j != endIndex ; j += increment)
                    {
                        col = _constraintColumns[j];
                        
                        // subtract fixed columns
                        if (!isNaN(col.explicitWidth))
                            availableWidth -= col.explicitWidth;
                        
                        if (col.contentSize || availableWidth < 0)
                        {
                            if (isLeft)
                                leftIndex = j;
                            else
                                rightIndex = j;
                            break;
                        }
                    }
                }
                
                // always 1 or positive.
                span = rightIndex - leftIndex + 1;
                //trace(span);

                if (span == 1)
                {
                    col = _constraintColumns[leftIndex];
                    
                    // only measure with when dealing with content size
                    if (col.contentSize)
                    {   
                        colWidth = Math.max(colWidths[leftIndex], extX + preferredWidth);
                        
                        if (constraintsDetermineWidth(elementInfo))
                            colWidth = Math.max(colWidth, extX + layoutElement.getMinBoundsWidth());
                        
                        // bound with max width of column
                        if (!isNaN(col.maxWidth))
                            colWidth = Math.min(colWidth, col.maxWidth);
                        
                        colWidths[leftIndex] = Math.ceil(colWidth);
                    }
                }
                else
                {
                    // multiple spanning case. span >= 2.
                    // 1) start from leftIndex and subtract fixed columns
                    // 2) divide space evenly into content size columns.
                    var contentCols:Vector.<ConstraintColumn> = new Vector.<ConstraintColumn>();
                    var contentColsIndices:Vector.<int> = new Vector.<int>();
                    
                    availableWidth = maxExtent;
                    
                    for (j = leftIndex; j <= rightIndex; j++)
                    {
                        col = _constraintColumns[j];
                        
                        if (!isNaN(col.explicitWidth))
                        {
                            availableWidth -= col.width;
                            
                            if (availableWidth < 0)
                            {
                                availableWidth += col.width;
                                break;
                            }
                        }
                        else if (col.contentSize)
                        {
                            contentCols.push(col);
                            contentColsIndices.push(j);
                        }
                    }
                    
                    var numContentCols:Number = contentCols.length;
                    
                    if (numContentCols > 0)
                    {
                        var splitWidth:Number = availableWidth / numContentCols;
                        
                        for (j = 0; j < numContentCols; j++)
                        {
                            col = contentCols[j];
                            
                            colWidth = Math.max(colWidths[contentColsIndices[j]], splitWidth);
                            if (!isNaN(col.maxWidth))
                                colWidth = Math.min(colWidth, col.maxWidth);
                            
                            colWidths[contentColsIndices[j]] = Math.ceil(colWidth);
                        }
                    }
                }
            }
        }
        
        return colWidths;
    }
    
    /**
     *  @private
     *  Synonymous to measureColumns(), but with added baseline constraint.
     *  Baseline is only included in the measurement if at least one of the element's
     *  top or bottom constraint doesn't exist. The calculations are based on the
     *  current constraintCache. To update the constraintCache, one needs to call
     *  the parseConstraints() method.
     */
    private function measureRows():Vector.<Number>
    {
        if (_constraintRows.length <= 0)
            return new Vector.<Number>();
        
        var measuredHeight:Number = 0;
        var i:Number;
        var numRows:Number = _constraintRows.length;
        var row:ConstraintRow;
        var hasContentSize:Boolean = false;
        var rowHeights:Vector.<Number> = new Vector.<Number>();
        
        // Reset content size rows to 0.
        for (i = 0; i < numRows; i++)
        {
            row = _constraintRows[i];
            if (row.contentSize)
            {
                hasContentSize = true;
                
                if (!isNaN(row.minHeight))
                    rowHeights[i] = Math.ceil(Math.max(row.minHeight, 0));
                else
                    rowHeights[i] = 0;
            }
            else if (!isNaN(row.explicitHeight))
            {
                var h:Number = row.height;
                
                if (!isNaN(row.minHeight))
                    h = Math.max(h, row.minHeight);
                
                if (!isNaN(row.maxHeight))
                    h = Math.min(h, row.maxHeight);
                
                rowHeights[i] = Math.ceil(h);
            }
        }
        
        // Assumption: elements in rowSpanElements have one or more constraints touching a row.
        // This is enforced in parseElementConstraints().
        if (rowSpanElements && hasContentSize)
        {
            var numRowSpanElements:Number = rowSpanElements.length;
            
            // Measure content size rows only single span for now.
            // If multiple span, do nothing yet.
            for (i = 0; i < numRowSpanElements; i++)
            {
                var elementInfo:ElementConstraintInfo = rowSpanElements[i];
                var layoutElement:ILayoutElement = elementInfo.layoutElement;
                var topIndex:int = -1;
                var bottomIndex:int = -1;
                var span:int;
                
                var extY:Number = 0;
                var preferredHeight:Number = layoutElement.getPreferredBoundsHeight();
                var maxExtent:Number;
                var availableHeight:Number;
                
                var j:int;
                var rowHeight:Number = 0;
                
                // Determine how much space the element needs to satisfy its
                // constraints and be at its preferred height.
                if (!isNaN(elementInfo.top))
                {
                    extY += elementInfo.top;
                    if (elementInfo.topBoundary)
                        topIndex = elementInfo.rowSpanTopIndex;
                    else
                        topIndex = 0; // constrained to parent
                }
                
                if (!isNaN(elementInfo.bottom))
                {
                    extY += elementInfo.bottom;
                    if (elementInfo.bottomBoundary)
                        bottomIndex = elementInfo.rowSpanBottomIndex;
                    else
                        bottomIndex = numRows - 1; // constrained to parent
                }
                
                // Only include baseline if at least one of top or bottom don't
                // exist.
                if (!isNaN(elementInfo.baseline) && (topIndex < 0 || bottomIndex < 0))
                {
                    extY += elementInfo.baseline - layoutElement.baselinePosition;
                    
                    if (!isNaN(elementInfo.top))
                        extY -= elementInfo.top;
                    
                    if (elementInfo.baselineBoundary)
                    {
                        topIndex = elementInfo.baselineIndex;
                        
                        // add baseline offset.
                        extY += Number(rowBaselines[topIndex][0]); 
                            
                        // add maxAscent. maxAscent is 0 if not specified on the row.
                        if (rowMaxAscents)
                            extY += rowMaxAscents[topIndex];
                    }
                    else
                    {
                        topIndex = 0;
                    }
                }
                
                maxExtent = extY + preferredHeight;
                availableHeight = maxExtent
                
                // If either the top or the bottom constraint doesn't exist,
                // we must find the span of the element. We do this by
                // determining the index of the last column that the element
                // occupies in the unconstrained direction.
                if (topIndex < 0 || bottomIndex < 0)
                {
                    var isTop:Boolean = topIndex < 0;
                    var startIndex:int = isTop ? bottomIndex : topIndex;
                    var endIndex:int = isTop ? -1 : numRows;
                    var increment:int = isTop ? -1 : 1;
                    
                    // defaults to 0
                    if (isTop)
                        topIndex = 0;
                    else // defaults to numRows - 1
                        bottomIndex = numRows - 1;
                    
                    for (j = startIndex; j != endIndex ; j += increment)
                    {
                        row = _constraintRows[j];
                        
                        // subtract fixed rows
                        if (!isNaN(row.explicitHeight))
                            availableHeight -= row.explicitHeight;
                        
                        if (row.contentSize || availableHeight < 0)
                        {
                            if (isTop)
                                topIndex = j;
                            else
                                bottomIndex = j;
                            break;
                        }
                    }
                }
                
                // always 1 or positive.
                span = bottomIndex - topIndex + 1;
                //trace(span);
                
                if (span == 1)
                {
                    row = _constraintRows[topIndex];
                    
                    // only measure with when dealing with content size
                    if (row.contentSize)
                    {   
                        rowHeight = Math.max(rowHeights[topIndex], extY + preferredHeight);
                        
                        if (constraintsDetermineHeight(elementInfo))
                            rowHeight = Math.max(rowHeight, extY + layoutElement.getMinBoundsHeight());
                        
                        // bound with max height of row
                        if (!isNaN(row.maxHeight))
                            rowHeight = Math.min(rowHeight, row.maxHeight);
                        
                        rowHeights[topIndex] = Math.ceil(rowHeight);
                    }
                }
                else
                {
                    // multiple spanning case. span >= 2.
                    // 1) start from topIndex and subtract fixed rows
                    // 2) divide space evenly into content size rows.
                    var contentRows:Vector.<ConstraintRow> = new Vector.<ConstraintRow>();
                    var contentRowsIndices:Vector.<int> = new Vector.<int>();
                    
                    availableHeight = maxExtent;
                    
                    for (j = topIndex; j <= bottomIndex; j++)
                    {
                        row = _constraintRows[j];
                        
                        if (!isNaN(row.explicitHeight))
                        {
                            availableHeight -= row.height;
                            
                            if (availableHeight < 0)
                            {
                                availableHeight += row.height;
                                break;
                            }
                        }
                        else if (row.contentSize)
                        {
                            contentRows.push(row);
                            contentRowsIndices.push(j);
                        }
                    }
                    
                    var numContentRows:Number = contentRows.length;
                    
                    if (numContentRows > 0)
                    {
                        var splitHeight:Number = availableHeight / numContentRows;
                        
                        for (j = 0; j < numContentRows; j++)
                        {
                            row = contentRows[j];
                            
                            rowHeight = Math.max(rowHeights[contentRowsIndices[j]], splitHeight);
                            if (!isNaN(row.maxHeight))
                                rowHeight = Math.min(rowHeight, row.maxHeight);
                            
                            rowHeights[contentRowsIndices[j]] = Math.ceil(rowHeight);
                        }
                    }
                }
            }
        }
        
        return rowHeights;
    }
    
    /**
     *  @private
     *  Measures the size of target based on content not included in the columns and rows.
     *  Basically, applies BasicLayout to other content to determine measured size.
     *  Returns a vector with the measured [width, height, minWidth, minHeight].
     */
    private function measureOtherContent():Vector.<Number>
    {
        var width:Number = 0;
        var height:Number = 0;
        var minWidth:Number = 0;
        var minHeight:Number = 0;
        var count:int = otherElements.length;
        
        for (var i:int = 0; i < count; i++)
        {
            var elementInfo:ElementConstraintInfo = otherElements[i];
            var layoutElement:ILayoutElement = elementInfo.layoutElement;
            
            // Only measure width if not constrained to columns.
            if (!elementInfo.leftBoundary && !elementInfo.rightBoundary)
            {
                var left:Number = elementInfo.left;
                var right:Number = elementInfo.right;
                var extX:Number;
                
                if (!isNaN(left) && !isNaN(right))
                {
                    // If both left & right are set, then the extents is always
                    // left + right so that the element is resized to its preferred
                    // size (if it's the one that pushes out the default size of the container).
                    extX = left + right;                
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
                
                var preferredWidth:Number = layoutElement.getPreferredBoundsWidth();
                width = Math.max(width, extX + preferredWidth);
                
                // Find the minimum default extents, we take the minimum height only
                // when the element size is determined by the parent size
                var elementMinWidth:Number =
                    constraintsDetermineWidth(elementInfo) ? layoutElement.getMinBoundsWidth() :
                    preferredWidth;
                
                minWidth = Math.max(minWidth, extX + elementMinWidth);
            }
            
            // only measure height if not constrained to rows.
            var noVerticalBoundaries:Boolean = !elementInfo.topBoundary && !elementInfo.bottomBoundary;
            var noBaselineBoundary:Boolean = !elementInfo.baselineBoundary;
            
            if (noVerticalBoundaries || noBaselineBoundary)
            {
                var top:Number;
                var bottom:Number;
                var baseline:Number;
                var extY:Number;
                
                if (noVerticalBoundaries)
                {
                    top = elementInfo.top;
                    bottom = elementInfo.bottom;
                }
                
                if (noBaselineBoundary)
                    baseline = elementInfo.baseline;
                
                if (!isNaN(top) && !isNaN(bottom))
                {
                    // If both top & bottom are set, then the extents is always
                    // top + bottom so that the element is resized to its preferred
                    // size (if it's the one that pushes out the default size of the container).
                    extY = top + bottom;                
                }
                else if (!isNaN(baseline))
                {
                    extY = Math.round(baseline - layoutElement.baselinePosition);
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
                
                var preferredHeight:Number = layoutElement.getPreferredBoundsHeight();
                height = Math.max(height, extY + preferredHeight);
                
                // Find the minimum default extents, we take the minimum height only
                // when the element size is determined by the parent size
                var elementMinHeight:Number =
                    constraintsDetermineHeight(elementInfo) ? layoutElement.getMinBoundsHeight() : 
                    preferredHeight;
                
                minHeight = Math.max(minHeight, extY + elementMinHeight);
            }
        }
        
        var vec:Vector.<Number> = new Vector.<Number>(4, true);
        vec[0] = Math.max(width, minWidth);
        vec[1] = Math.max(height, minHeight);
        vec[2] = minWidth;
        vec[3] = minHeight;
        
        return vec;
    }
    
    /**
     *  @private
     *  Iterates over elements and calls parseElementConstraints on each.
     */
    private function parseConstraints():void
    {
        var layoutTarget:GroupBase = target;
        if (!layoutTarget)
            return;
        
        var count:Number = layoutTarget.numElements;
        var layoutElement:ILayoutElement;
        
        var cache:Dictionary = new Dictionary(true);
        var i:int;
        
        // Populate rowBaselines with baseline information from rows.
        var n:int = _constraintRows.length;
        var row:ConstraintRow;
        var obj:Object = new Object();
        if (rowBaselines == null)
            rowBaselines = new Vector.<Array>();
        else
            rowBaselines.length = 0;
        
        for (i = 0; i < n; i++)
        {
            row = _constraintRows[i];
            rowBaselines[i] = LayoutElementHelper.parseConstraintExp(row.baseline);
            
            var maxAscentStr:String = rowBaselines[i][1];
            if (maxAscentStr && maxAscentStr != "maxAscent")
                throw new Error(ResourceManager.getInstance().getString("layout", "invalidBaselineOnRow",
                    [ row.id, row.baseline ]));
        }
        
        for (i = 0; i < count; i++)
        {
            layoutElement = layoutTarget.getElementAt(i);
            if (!layoutElement || !layoutElement.includeInLayout)
                continue;
            
            parseElementConstraints(layoutElement, cache);
        }
        
        this.constraintCache = cache;
    }
    
    /**
     *  @private
     *  This function parses the constraints of a single element, creates an
     *  ElementConstraintInfo object for the element, and throws errors if the
     *  columns or rows are not found for each constraint.
     */
    private function parseElementConstraints(layoutElement:ILayoutElement, constraintCache:Dictionary):void
    {
        // Variables to track the offsets
        var left:Number;
        var right:Number;
        var top:Number;
        var bottom:Number;
        var baseline:Number;
        
        // Variables to track the boundaries from which
        // the offsets are calculated from. If null, the 
        // boundary is the parent container edge. 
        var leftBoundary:String;
        var rightBoundary:String;
        var topBoundary:String;
        var bottomBoundary:String;
        var baselineBoundary:String;
        
        var message:String;
        
        var temp:Array;
        temp = LayoutElementHelper.parseConstraintExp(layoutElement.left);
        left = temp[0];
        leftBoundary = temp[1];
        
        temp = LayoutElementHelper.parseConstraintExp(layoutElement.right);
        right = temp[0];
        rightBoundary = temp[1];
        
        temp = LayoutElementHelper.parseConstraintExp(layoutElement.top);
        top = temp[0];
        topBoundary = temp[1];
        
        temp = LayoutElementHelper.parseConstraintExp(layoutElement.bottom);
        bottom = temp[0];
        bottomBoundary = temp[1];
        
        temp = LayoutElementHelper.parseConstraintExp(layoutElement.baseline);
        baseline = temp[0];
        baselineBoundary = temp[1];
        
        // save values into a Dictionary based on element name.
        var elementInfo:ElementConstraintInfo = new ElementConstraintInfo(layoutElement,
            left, right, top, bottom, baseline,
            leftBoundary, rightBoundary,
            topBoundary, bottomBoundary, baselineBoundary);
        constraintCache[layoutElement] = elementInfo;
        
        // If some pair of boundaries don't exist, we will need to measure
        // the container size based on the element's other properties like
        // x, y, width, height.
        var i:Number;
        if ((!leftBoundary && !rightBoundary) ||
            (!topBoundary && !bottomBoundary) ||
            !baselineBoundary)
        {
            if (!otherElements)
                otherElements = new Vector.<ElementConstraintInfo>();
            
            otherElements.push(elementInfo);
        }
        
        // match columns
        if (leftBoundary || rightBoundary)
        {
            var numColumns:Number = _constraintColumns.length;
            var colIndex:Object;

            if (!colSpanElements)
                colSpanElements = new Vector.<ElementConstraintInfo>();
            
            colSpanElements.push(elementInfo);
            
            if (leftBoundary)
            {
                colIndex = columnsObject[leftBoundary];
                
                if (colIndex != null)
                    elementInfo.colSpanLeftIndex = int(colIndex);
                
                // throw error if no match.
                if (elementInfo.colSpanLeftIndex < 0)
                {
                    message = ResourceManager.getInstance().getString(
                        "layout", "columnNotFound", [ leftBoundary ]);
                    throw new ConstraintError(message);
                }
            }
            
            // can we assume rightIndex >= leftIndex?
            if (rightBoundary)
            {
                colIndex = columnsObject[rightBoundary];
                
                if (colIndex != null)
                    elementInfo.colSpanRightIndex = int(colIndex);
                
                // throw error if no match.
                if (elementInfo.colSpanRightIndex < 0)
                {
                    message = ResourceManager.getInstance().getString(
                        "layout", "columnNotFound", [ rightBoundary ]);
                    throw new ConstraintError(message);
                }
            }
        }
        
        // match rows.
        if (topBoundary || bottomBoundary || baselineBoundary)
        {
            var rowIndex:Object;
            
            if (!rowSpanElements)
                rowSpanElements = new Vector.<ElementConstraintInfo>();
            
            rowSpanElements.push(elementInfo);
            
            if (topBoundary)
            {
                rowIndex = rowsObject[topBoundary];
                
                if (rowIndex != null)
                    elementInfo.rowSpanTopIndex = int(rowIndex);
                
                // throw error if no match.
                if (elementInfo.rowSpanTopIndex < 0)
                {
                    message = ResourceManager.getInstance().getString(
                        "layout", "rowNotFound", [ topBoundary ]);
                    throw new ConstraintError(message);
                }
            }
            
            if (bottomBoundary)
            {
                rowIndex = rowsObject[bottomBoundary];
                
                if (rowIndex != null)
                    elementInfo.rowSpanBottomIndex = int(rowIndex);
                
                // throw error if no match.
                if (elementInfo.rowSpanBottomIndex < 0)
                {
                    message = ResourceManager.getInstance().getString(
                        "layout", "rowNotFound", [ bottomBoundary ]);
                    throw new ConstraintError(message);
                }
            }
            
            if (baselineBoundary)
            {
                rowIndex = rowsObject[baselineBoundary];
                
                if (rowIndex != null)
                    elementInfo.baselineIndex = int(rowIndex);
                
                // throw error if no match.
                if (elementInfo.baselineIndex < 0)
                {
                    message = ResourceManager.getInstance().getString(
                        "layout", "rowNotFound", [ baselineBoundary ]);
                    throw new ConstraintError(message);
                }
                
                // when using maxAscent, calculate maximum baselinePosition for this row.
                var bIndex:int = elementInfo.baselineIndex;
                var numRows:Number = _constraintRows.length;
                
                if (rowBaselines[bIndex][1])
                {
                    // maxAscents will all default to 0.
                    if (!rowMaxAscents)
                        rowMaxAscents = new Vector.<Number>(numRows, true);

                    rowMaxAscents[bIndex] = Math.max(rowMaxAscents[bIndex], layoutElement.baselinePosition);
                }
            }
        }
    }
}
}

import mx.core.ILayoutElement;

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: ElementConstraintInfo
//
////////////////////////////////////////////////////////////////////////////////

class ElementConstraintInfo
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    public function ElementConstraintInfo(
        layoutElement:ILayoutElement,
        left:Number, right:Number,
        top:Number, bottom:Number,
        baseline:Number, leftBoundary:String = null,
        rightBoundary:String = null,
        topBoundary:String = null, bottomBoundary:String = null,
        baselineBoundary:String = null,
        colSpanLeftIndex:int = -1, colSpanRightIndex:int = -1,
        rowSpanTopIndex:int = -1, rowSpanBottomIndex:int = -1,
        baselineIndex:int = -1):void
    {
        super();
        
        // pointer to element
        this.layoutElement = layoutElement;
        
        // offsets
        this.left = left;
        this.right = right;
        this.top = top;
        this.bottom = bottom;
        this.baseline = baseline;
        
        // boundaries (ie: parent, column or row edge)
        this.leftBoundary = leftBoundary;
        this.rightBoundary = rightBoundary;
        this.topBoundary = topBoundary;
        this.bottomBoundary = bottomBoundary;
        this.baselineBoundary = baselineBoundary;
        
        this.colSpanLeftIndex = colSpanLeftIndex;
        this.colSpanRightIndex = colSpanRightIndex;
        this.rowSpanTopIndex = rowSpanTopIndex;
        this.rowSpanBottomIndex = rowSpanBottomIndex;
        this.baselineIndex = baselineIndex;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    public var layoutElement:ILayoutElement;
    
    public var left:Number;
    public var right:Number;
    public var top:Number;
    public var bottom:Number;
    public var baseline:Number;
    public var leftBoundary:String;
    public var rightBoundary:String;
    public var topBoundary:String;
    public var bottomBoundary:String;
    public var baselineBoundary:String;
    
    public var colSpanLeftIndex:int;
    public var colSpanRightIndex:int;
    public var rowSpanTopIndex:int;
    public var rowSpanBottomIndex:int;
    public var baselineIndex:int;
}