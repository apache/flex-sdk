package spark.layouts
{
import flash.geom.Point;
import flash.utils.Dictionary;

import mx.containers.errors.ConstraintError;
import mx.containers.utilityClasses.ConstraintColumn;
import mx.containers.utilityClasses.ConstraintRow;
import mx.core.ILayoutElement;
import mx.core.mx_internal;
import mx.resources.IResourceManager;
import mx.resources.ResourceManager;

import spark.components.supportClasses.GroupBase;
import spark.layouts.supportClasses.LayoutBase;
import spark.layouts.supportClasses.LayoutElementHelper;

use namespace mx_internal;

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
    
    private static function constraintsDetermineHeight(elementInfo:ElementConstraintInfo):Boolean
    {
        return !isNaN(elementInfo.top) && !isNaN(elementInfo.bottom);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    public function ConstraintLayout()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    // for throwing errors
    private var resourceManager:IResourceManager =
        ResourceManager.getInstance();
    
    // Arrays that keep track of children spanning
    // content size columns or rows or whether the elements don't
    // use columns or rows at all
    private var colSpanElements:Vector.<ElementConstraintInfo> = null;
    private var rowSpanElements:Vector.<ElementConstraintInfo> = null;
    private var otherElements:Vector.<ElementConstraintInfo> = null;
    
    private var constraintCache:Dictionary = new Dictionary(true);
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  constraintColumns
    //----------------------------------
    
    private var _constraintColumns:Vector.<ConstraintColumn> = new Vector.<ConstraintColumn>(0, true);
    
    public function get constraintColumns():Vector.<ConstraintColumn>
    {
        // make defensive copy
        return Vector.<ConstraintColumn>(_constraintColumns);
    }
    
    public function set constraintColumns(value:Vector.<ConstraintColumn>):void
    {   
        // clear constraintColumns
        if (value == null)
        {
            _constraintColumns = new Vector.<ConstraintColumn>(0, true);
            return;
        }
        
        var n:int = value.length;
        var temp:Vector.<ConstraintColumn> = new Vector.<ConstraintColumn>(n, true);
        for (var i:int = 0; i < n; i++)
        {
            value[i].container = this.target;
            temp[i] = value[i];
        }
        
        _constraintColumns = temp;
        
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
    
    public function get constraintRows():Vector.<ConstraintRow> 
    {
        return Vector.<ConstraintRow>(_constraintRows);
    }
    
    public function set constraintRows(value:Vector.<ConstraintRow>):void
    {
        // clear constraintRows
        if (value == null)
        {
            _constraintRows = new Vector.<ConstraintRow>(0, true);
            return;
        }
        
        var n:int = value.length;
        var temp:Vector.<ConstraintRow> = new Vector.<ConstraintRow>(n, true);
        for (var i:int = 0; i < n; i++)
        {
            value[i].container = this.target;
            temp[i] = value[i];
        }
        
        _constraintRows = temp;
        
        if (target)
        {
            target.invalidateSize();
            target.invalidateDisplayList();
        }
    }
    
    /**
     *  @private
     * 
     *  resets the columns'/rows' targets.
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
            _constraintColumns[i].container = this.target;
        }
        
        n = _constraintRows.length;
        for (i = 0; i < n; i++)
        {
            _constraintRows[i].container = this.target
        }
    }

    mx_internal function checkUseVirtualLayout():void
    {
        if (useVirtualLayout)
            throw new Error(ResourceManager.getInstance().getString("layout", "basicLayoutNotVirtualized"));
    }

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
        
        parseConstraints();
        
        var width:Number = measureAndPositionColumns();
        var height:Number = measureAndPositionRows();
        
        if (otherElements)
        {
            var p:Point = measureOtherContent();
            
            width = Math.max(width, p.x);
            height = Math.max(height, p.y);
        }

        layoutTarget.measuredWidth = Math.ceil(width);
        layoutTarget.measuredHeight = Math.ceil(height);
        
        // FIXME (klin): measuredMinWidth/Height?
        
        colSpanElements = null;
        rowSpanElements = null;
        otherElements = null;
        constraintCache = null;
    }
    
    /**
     *  @private
     * 
     *  1) Reparse element constraints because they may have changed.
     *  2) Resize the columns and rows based on this information
     *  3) Size and position the elements based on the available space.
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
    
    /**
     *  Lays out the elements of the layoutTarget using the current
     *  widths and heights of the columns and rows. Used by FormItemLayout
     *  to set new column widths and then lay elements using those new widths.
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
            maxX = Math.max(maxX, layoutElement.getLayoutBoundsX() + layoutElement.getLayoutBoundsWidth());
            maxY = Math.max(maxY, layoutElement.getLayoutBoundsY() + layoutElement.getLayoutBoundsHeight());
        }
        
        // Make sure that if the content spans partially over a pixel to the right/bottom,
        // the content size includes the whole pixel.
        layoutTarget.setContentSize(Math.ceil(maxX), Math.ceil(maxY));
        
        // clear out cache
        colSpanElements = null;
        rowSpanElements = null;
        otherElements = null;
        constraintCache = null;
    }
    
    /**
     *  Used by FormItemLayout to measure and set new column widths
     *  before laying out the elements.
     */
    protected function measureAndPositionColumnsAndRows():void
    {
        parseConstraints();
        measureAndPositionColumns();
        measureAndPositionRows();
    }
    
    /**
     *  wrapper for parsing all the element constraints
     */
    private function parseConstraints():void
    {
        var layoutTarget:GroupBase = target;
        if (!layoutTarget)
            return;

        var count:Number = layoutTarget.numElements;
        var layoutElement:ILayoutElement;
        
        constraintCache = new Dictionary(true);
        
        for (var i:int = 0; i < count; i++)
        {
            layoutElement = layoutTarget.getElementAt(i);
            if (!layoutElement || !layoutElement.includeInLayout)
                continue;
            
            parseElementConstraints(layoutElement);
        }
    }

    /**
     *  @private
     *  This function parses the constraints of a single element, creates an
     *  ElementConstraintInfo object for the element, and throws errors if the
     *  columns or rows are not found.
     */
    private function parseElementConstraints(layoutElement:ILayoutElement):void
    {
        // parse constraint values
        //Variables to track the offsets
        var left:Number;
        var right:Number;
        var top:Number;
        var bottom:Number;
        
        //Variables to track the boundaries from which
        //the offsets are calculated from. If null, the 
        //boundary is the parent container edge. 
        var leftBoundary:String;
        var rightBoundary:String;
        var topBoundary:String;
        var bottomBoundary:String;
        
        var message:String;
        
        var temp:Array;
        temp = LayoutElementHelper.parseConstraintExp(layoutElement.left);
        if (!temp)
            left = NaN;
        else if (temp.length == 1)
            left = Number(temp[0]);
        else
        {
            leftBoundary = temp[0];
            left = temp[1];
        }
        
        temp = LayoutElementHelper.parseConstraintExp(layoutElement.right);
        if (!temp)
            right = NaN;
        else if (temp.length == 1)
            right = Number(temp[0]);
        else
        {
            rightBoundary = temp[0];
            right = temp[1];
        }
        
        temp = LayoutElementHelper.parseConstraintExp(layoutElement.top);
        if (!temp)
            top = NaN;
        else if (temp.length == 1)
            top = Number(temp[0]);
        else
        {
            topBoundary = temp[0];
            top = temp[1];
        }
        
        temp = LayoutElementHelper.parseConstraintExp(layoutElement.bottom);
        if (!temp)
            bottom = NaN;
        else if (temp.length == 1)
            bottom = Number(temp[0]);
        else
        {
            bottomBoundary = temp[0];
            bottom = temp[1];
        }
        
        // save values into a Dictionary based on element name.
        var elementInfo:ElementConstraintInfo = new ElementConstraintInfo(layoutElement, left, right, top, bottom,
            leftBoundary, rightBoundary,
            topBoundary, bottomBoundary);
        constraintCache[layoutElement] = elementInfo;
        
        // put into either column/row buckets or no column/row constraints buckets.
        var i:Number;
        if (!(leftBoundary || rightBoundary) || !(topBoundary || bottomBoundary))
        {
            if (!otherElements)
                otherElements = new Vector.<ElementConstraintInfo>();
            
            otherElements.push(elementInfo);
        }
            
        if (leftBoundary || rightBoundary)
        {
            var numColumns:Number = _constraintColumns.length;
            var colid:String;
            
            if (!colSpanElements)
                colSpanElements = new Vector.<ElementConstraintInfo>();
            
            colSpanElements.push(elementInfo);
            
            if (leftBoundary)
            {
                for (i = 0; i < numColumns; i++)
                {
                    colid = _constraintColumns[i].id;
                    
                    if (leftBoundary == colid)
                    {
                        elementInfo.colSpanLeftIndex = i;
                        break;
                    }
                }
                
                // throw error if no match.
                if (elementInfo.colSpanLeftIndex < 0)
                {
                    message = resourceManager.getString(
                        "containers", "columnNotFound", [ leftBoundary ]);
                    throw new ConstraintError(message);
                }
            }
            
            
            // can we assume rightIndex >= leftIndex?
            if (rightBoundary)
            {
                for (i = 0; i < numColumns; i++)
                {
                    colid = _constraintColumns[i].id;
                    
                    if (rightBoundary == colid)
                    {
                        elementInfo.colSpanRightIndex = i;
                        break;
                    }
                }
                
                // throw error if no match.
                if (elementInfo.colSpanRightIndex < 0)
                {
                    message = resourceManager.getString(
                        "containers", "columnNotFound", [ rightBoundary ]);
                    throw new ConstraintError(message);
                }
            }
        }
        
        if (topBoundary || bottomBoundary)
        {
            var numRows:Number = _constraintRows.length;
            var rowid:String;
            
            if (!rowSpanElements)
                rowSpanElements = new Vector.<ElementConstraintInfo>();
            
            rowSpanElements.push(elementInfo);
            
            if (topBoundary)
            {
                for (i = 0; i < numRows; i++)
                {
                    rowid = _constraintRows[i].id;
                    
                    if (topBoundary == rowid)
                    {
                        elementInfo.rowSpanTopIndex = i;
                        break;
                    }
                }
                
                // throw error if no match.
                if (elementInfo.rowSpanTopIndex < 0)
                {
                    message = resourceManager.getString(
                        "containers", "columnNotFound", [ topBoundary ]);
                    throw new ConstraintError(message);
                }
            }
            
            if (bottomBoundary)
            {
                for (i = 0; i < numRows; i++)
                {
                    rowid = _constraintRows[i].id;
                    
                    if (bottomBoundary == rowid)
                    {
                        elementInfo.rowSpanBottomIndex = i;
                        break;
                    }
                }
                
                // throw error if no match.
                if (elementInfo.rowSpanBottomIndex < 0)
                {
                    message = resourceManager.getString(
                        "containers", "columnNotFound", [ bottomBoundary ]);
                    throw new ConstraintError(message);
                }
            }
        }
    }
    
    /** 
     *  @private
     *  This function measures the ConstraintColumns and 
     *  and ConstraintRows partitioning the target and
     *  sets their x/y positions.
     * 
     *  The algorithm works like this (in the horizontal 
     *  direction):
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
     *  @return measuredWidth of the columns.
     */
    private function measureAndPositionColumns():Number
    {
        if (_constraintColumns.length <= 0)
            return 0;
        
        var measuredWidth:Number = 0;
        var i:Number;
        var numCols:Number = _constraintColumns.length;
        var col:ConstraintColumn;
        var hasContentSize:Boolean = false;
        
        // Reset content size columns to 0.
        for (i = 0; i < numCols; i++)
        {
            col = _constraintColumns[i];
            if (col.contentSize)
            {
                hasContentSize = true;
                
                if (!isNaN(col.minWidth))
                    col.setActualWidth(Math.ceil(Math.max(col.minWidth, 0)));
                else
                    col.setActualWidth(0);
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
                
                // if there is no left or no right constraint, there must be 
                // a corresponding column constraint on the other side. We
                // calculate the last column that this element touches to 
                // find the other column that the element spans to.
                if (leftIndex < 0)
                {   
                    leftIndex = 0; // defaults to first column
                    
                    // subtract fixed rows
                    for (j = rightIndex; j >= 0; j--)
                    {
                        col = _constraintColumns[j];
                        if (col.contentSize)
                        {
                            leftIndex = j;
                            break;
                        }
                        else if (!isNaN(col.explicitWidth))
                        {
                            maxExtent -= col.width;
                            if (maxExtent < 0)
                            {
                                leftIndex = j;
                                break;
                            }
                        }
                    }
                }
                else if (rightIndex < 0)
                {
                    rightIndex = numCols - 1; // defaults to last column
                    
                    // subtract fixed rows
                    for (j = leftIndex; j < numCols; j++)
                    {
                        col = _constraintColumns[j];
                        if (col.contentSize)
                        {
                            rightIndex = j;
                            break;
                        }
                        else if (!isNaN(col.explicitWidth))
                        {
                            maxExtent -= col.width;
                            if (maxExtent < 0)
                            {
                                rightIndex = j;
                                break;
                            }
                        }
                    }
                }
                
                // always 0 or positive.
                span = rightIndex - leftIndex;
                //trace(span);
                
                // span of 0 means the element spans one column
                if (span == 0)
                {
                    col = _constraintColumns[leftIndex];
                    
                    // only measure with when dealing with content size
                    if (col.contentSize)
                    {   
                        colWidth = Math.max(col.width, extX + preferredWidth);
                        
                        if (constraintsDetermineWidth(elementInfo))
                            colWidth = Math.max(colWidth, extX + layoutElement.getMinBoundsWidth());
                        
                        col.setActualWidth(Math.ceil(colWidth));
                    }
                }
                else
                {
                    // multiple spanning stuff.
                }
            }
        }

        // Position columns and add up widths.
        for (i = 0; i < numCols; i++)
        {
            col = _constraintColumns[i];
            col.x = measuredWidth;
            measuredWidth += col.width;
        }
        
        return measuredWidth;
    }
    
    /**
     *  @private
     *  synonymous to measureAndPositionColumns(), but with added baseline constraint.
     */
    private function measureAndPositionRows():Number
    {
        if (_constraintRows.length <= 0)
            return 0;
        
        var measuredHeight:Number = 0;
        var i:Number;
        var numRows:Number = _constraintRows.length;
        var row:ConstraintRow;
        var hasContentSize:Boolean = false;
        
        // Reset content size rows to 0.
        for (i = 0; i < numRows; i++)
        {
            row = _constraintRows[i];
            if (row.contentSize)
            {
                hasContentSize = true;
                
                if (!isNaN(row.minHeight))
                    row.setActualHeight(Math.ceil(Math.max(row.minHeight, 0)));
                else
                    row.setActualHeight(0);
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
                
                maxExtent = extY + preferredHeight;
                
                // if there is no top or no bottom constraint, there must be 
                // a corresponding row constraint on the other side. We
                // calculate the last row that this element touches to 
                // find the real span of the element.
                if (topIndex < 0)
                {   
                    topIndex = 0; // defaults to first row
                    
                    // subtract fixed rows
                    for (j = bottomIndex; j >= 0; j--)
                    {
                        row = _constraintRows[j];
                        if (row.contentSize)
                        {
                            topIndex = j;
                            break;
                        }
                        else if (!isNaN(row.explicitHeight))
                        {
                            maxExtent -= row.height;
                            if (maxExtent < 0)
                            {
                                topIndex = j;
                                break;
                            }
                        }
                    }
                }
                else if (bottomIndex < 0)
                {
                    bottomIndex = numRows - 1; // defaults to last row
                    
                    // subtract fixed rows
                    for (j = topIndex; j < numRows; j++)
                    {
                        row = _constraintRows[j];
                        if (row.contentSize)
                        {
                            bottomIndex = j;
                            break;
                        }
                        else if (!isNaN(row.explicitHeight))
                        {
                            maxExtent -= row.height;
                            if (maxExtent < 0)
                            {
                                bottomIndex = j;
                                break;
                            }
                        }
                    }
                }
                
                // always 0 or positive.
                span = bottomIndex - topIndex;
                //trace(span);
                
                // span of 0 means the element spans one row
                if (span == 0)
                {
                    row = _constraintRows[topIndex];
                    
                    // only measure with when dealing with content size
                    if (row.contentSize)
                    {   
                        rowHeight = Math.max(row.height, extY + preferredHeight);
                        
                        if (constraintsDetermineHeight(elementInfo))
                            rowHeight = Math.max(rowHeight, extY + layoutElement.getMinBoundsHeight());
                        
                        row.setActualHeight(Math.ceil(rowHeight));
                    }
                }
                else
                {
                    // multiple spanning stuff.
                }
            }
        }
        
        // Position rows and add up heights.
        for (i = 0; i < numRows; i++)
        {
            row = _constraintRows[i];
            row.y = measuredHeight;
            measuredHeight += row.height;
        }
        
        return measuredHeight;
    }
    
    /**
     *  Measures the size of target based on content not included in the columns and rows.
     *  Basically, applies BasicLayout to other content to determine measured size.
     */
    private function measureOtherContent():Point
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
            
            // Only measure if not constrained to columns
            if (!(elementInfo.leftBoundary || elementInfo.rightBoundary))
            {
                var left:Number      = elementInfo.left;
                var right:Number     = elementInfo.right;
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
            
            // only measure if not constrained to rows.
            if (!(elementInfo.topBoundary || elementInfo.bottomBoundary))
            {
                var top:Number       = elementInfo.top;
                var bottom:Number    = elementInfo.bottom;
                var extY:Number;
                
                if (!isNaN(top) && !isNaN(bottom))
                {
                    // If both top & bottom are set, then the extents is always
                    // top + bottom so that the element is resized to its preferred
                    // size (if it's the one that pushes out the default size of the container).
                    extY = top + bottom;                
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
        
        return new Point(Math.max(width, minWidth), Math.max(height, minHeight));
    }
    
    private function applyConstraintsToElement(unscaledWidth:Number, unscaledHeight:Number, layoutElement:ILayoutElement):void
    {
        //-------------------
        // Fixed Width
        //
        // To layout children:
        //        grab constraints from filled out cache
        //         Assuming constraints are good...
        //        Size the child based on constraints.
        //         Position the child based on left and top constraint
        //-------------------
        var elementInfo:ElementConstraintInfo = constraintCache[layoutElement];
        
        var left:Number = elementInfo.left;
        var right:Number = elementInfo.right;
        var top:Number = elementInfo.top;
        var bottom:Number = elementInfo.bottom;
        
        var leftBoundary:String = elementInfo.leftBoundary;
        var rightBoundary:String = elementInfo.rightBoundary;
        var topBoundary:String = elementInfo.topBoundary;
        var bottomBoundary:String = elementInfo.bottomBoundary;
        
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

        
        // available width
        availableWidth = Math.round(rightHolder - leftHolder);
        availableHeight = Math.round(bottomHolder - topHolder);
        
        // set width
        if (!isNaN(left) && !isNaN(right))
        {
            elementWidth = availableWidth - left - right;
        }
        // set height
        if (!isNaN(top) && !isNaN(bottom))
        {
            elementHeight = availableHeight - top - bottom;
        }
        
        // Apply min and max constraints, make sure min is applied last. In the cases
        // where elementWidth and elementHeight are NaN, setLayoutBoundsSize will use preferredSize
        // which is already constrained between min and max.
        if (!isNaN(elementWidth))
        {
            elementMaxWidth = layoutElement.getMaxBoundsWidth();
            elementWidth = Math.max(layoutElement.getMinBoundsWidth(), Math.min(elementMaxWidth, elementWidth));
        }
        if (!isNaN(elementHeight))
        {
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
        if (!isNaN(top))
            elementY = topHolder + top;
        else if (!isNaN(bottom))
            elementY = bottomHolder - bottom - elementHeight;
        else
            elementY = layoutElement.getLayoutBoundsY();
        
        layoutElement.setLayoutBoundsPosition(elementX, elementY);
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
        left:Number, right:Number, //hc:Number,
        top:Number, bottom:Number, //vc:Number,
        /*baseline:Number, */leftBoundary:String = null,
        rightBoundary:String = null, //hcBoundary:String = null,
        topBoundary:String = null, bottomBoundary:String = null,
        /*vcBoundary:String = null, baselineBoundary:String = null*/
        colSpanLeftIndex:int = -1, colSpanRightIndex:int = -1,
        rowSpanTopIndex:int = -1, rowSpanBottomIndex:int = -1):void
    {
        super();
        
        // pointer to element
        this.layoutElement = layoutElement;
        
        // offsets
        this.left = left;
        this.right = right;
/*        this.hc = hc;*/
        this.top = top;
        this.bottom = bottom;
/*        this.vc = vc;*/
/*        this.baseline = baseline;*/
        
        // boundaries (ie: parent, column or row edge)
        this.leftBoundary = leftBoundary;
        this.rightBoundary = rightBoundary;
/*        this.hcBoundary = hcBoundary;*/
        this.topBoundary = topBoundary;
        this.bottomBoundary = bottomBoundary;
/*        this.vcBoundary = vcBoundary;*/
/*        this.baselineBoundary = baselineBoundary;*/
        
        this.colSpanLeftIndex = colSpanLeftIndex;
        this.colSpanRightIndex = colSpanRightIndex;
        this.rowSpanTopIndex = rowSpanTopIndex;
        this.rowSpanBottomIndex = rowSpanBottomIndex;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    public var layoutElement:ILayoutElement;
    
    public var left:Number;
    public var right:Number;
/*    public var hc:Number;*/
    public var top:Number;
    public var bottom:Number;
/*    public var vc:Number;*/
    public var baseline:Number;
    public var leftBoundary:String;
    public var rightBoundary:String;
/*    public var hcBoundary:String;*/
    public var topBoundary:String;
    public var bottomBoundary:String;
/*    public var vcBoundary:String;*/
/*    public var baselineBoundary:String;*/
    
    public var colSpanLeftIndex:int;
    public var colSpanRightIndex:int;
    public var rowSpanTopIndex:int;
    public var rowSpanBottomIndex:int;
}