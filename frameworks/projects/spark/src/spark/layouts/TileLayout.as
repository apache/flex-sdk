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

package mx.layout
{
import mx.components.baseClasses.GroupBase;
import mx.core.ILayoutElement;
import mx.events.PropertyChangeEvent;
import mx.layout.HorizontalAlign;
import mx.layout.LayoutBase;
import mx.layout.VerticalAlign;

/**
 *  Documentation is not currently available.
 */
public class TileLayout extends LayoutBase
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     */
    public function TileLayout():void
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  horizontalGap
    //----------------------------------

    private var explicitHorizontalGap:Number = 6;
    private var _horizontalGap:Number = 6;

    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
     *  Horizontal space between columns.
     *
     *  @see #verticalGap
     *  @see #justifyColumns
     *  @default 6
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
        explicitHorizontalGap = value;
        if (value == _horizontalGap)
            return;

        _horizontalGap = value;
        invalidateTargetSizeAndDisplayList();
    }

    //----------------------------------
    //  verticalGap
    //----------------------------------

    private var explicitVerticalGap:Number = 6;
    private var _verticalGap:Number = 6;

    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
     *  Vertical space between rows.
     *
     *  @see #horizontalGap
     *  @see #justifyRows
     *  @default 6
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
        explicitVerticalGap = value;
        if (value == _verticalGap)
            return;

        _verticalGap = value;
        invalidateTargetSizeAndDisplayList();
    }

    //----------------------------------
    //  columnCount
    //----------------------------------

    private var explicitColumnCount:int = -1;
    private var _columnCount:int = -1;

    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
     *  Number of columns to be displayed.
     *  This property will contain the actual column count after
     *  <code>updateDisplayList()</code>.
     *  Set to -1 to remove explicit override and allow the TileLayout to determine
     *  the column count automatically.
     *
     *  Setting this property won't have any effect, if <code>orientation</code> is
     *  set to "rows", <code>rowCount</code> is explicitly set, and the
     *  container width is explicitly set.
     *
     *  @see #rowCount
     *  @see #justifyColumns
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
        if (value == _columnCount)
            return;

        _columnCount = value;
        invalidateTargetSizeAndDisplayList();
    }

    //----------------------------------
    //  rowCount
    //----------------------------------

    /**
     *  @private
     *  Storage for the rowCount property.
     */
    private var explicitRowCount:int = -1;
    private var _rowCount:int = -1;

    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
     *  Number of rows to be displayed.
     *  This property will contain the actual row count after
     *  <code>updateDisplayList()</code>.
     *  Set to -1 to remove explicit override and allow the TileLayout to determine
     *  the row count automatically.
     *
     *  Setting this property won't have any effect, if <code>orientation</code> is
     *  set to "columns", <code>columnCount</code> is explicitly set, and the
     *  container height is explicitly set.
     *
     *  @see #columnCount
     *  @see #justifyRows
     *  @default -1
     */
    public function get rowCount():int
    {
        return _rowCount;
    }

    /**
     *  @private
     */
    public function set rowCount(value:int):void
    {
        explicitRowCount = value;
        if (value == _rowCount)
            return;

        _rowCount = value;
        invalidateTargetSizeAndDisplayList();
    }

    //----------------------------------
    //  columnWidth
    //----------------------------------

    private var explicitColumnWidth:Number = NaN;
    private var _columnWidth:Number = NaN;

    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
     *  Explicit override for the column width.
     *  This property will contain the actual column width after
     *  <code>updateDisplayList()</code>.
     *
     *  <p>If not explicitly set, the column width will be
     *  determined from the maximum of elements' width.
     *  Set to NaN to remove explicit override.</p>
     *
     *  If <code>justifyColumns</code> is set to "columnSize", the actual column width
     *  will grow to justify the fully-visible columns to the container width.
     *
     *  @see #rowHeight
     *  @see #justifyColumns
     *  @default NaN
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
        if (value == _columnWidth)
            return;

        _columnWidth = value;
        invalidateTargetSizeAndDisplayList();
    }

    //----------------------------------
    //  rowHeight
    //----------------------------------

    private var explicitRowHeight:Number = NaN;
    private var _rowHeight:Number = NaN;

    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
     *  Explicit override for the row height.
     *  This property will contain the actual row height after
     *  <code>updateDisplayList()</code>.
     *
     *  <p>If not explicitly set, the row height will be
     *  determined from the maximum of elements' height.
     *  Set to NaN to remove explicit override.</p>
     *
     *  If <code>justifyRows</code> is set to "rowSize", the actual row height
     *  will grow to justify the fully-visible rows to the container height.
     *
     *  @see #columnWidth
     *  @see #justifyRows
     *  @default NaN
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
        if (value == _rowHeight)
            return;

        _rowHeight = value;
        invalidateTargetSizeAndDisplayList();
    }

    //----------------------------------
    //  horizontalAlign
    //----------------------------------

    private var _elementHorizontalAlign:String = HorizontalAlign.JUSTIFY;

    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
     *  Specifies how to align the elements within the cells in the horizontal direction.
     *  Supported values are
     *  <code>HorizontalAlign.LEFT</code>,
     *  <code>HorizontalAlign.CENTER</code>,
     *  <code>HorizontalAlign.RIGHT</code>,
     *  <code>HorizontalAlign.JUSTIFY</code>.
     *
     *  <p>When set to <code>HorizontalAlign.JUSTIFY</code> the width of each
     *  element will be set to the <code>columnWidth</code></p>.
     *
     *  @default <code>HorizontalAlign.JUSTIFY</code>
     */
    public function get elementHorizontalAlign():String
    {
        return _elementHorizontalAlign;
    }

    /**
     *  @private
     */
    public function set elementHorizontalAlign(value:String):void
    {
        if (_elementHorizontalAlign == value)
            return;

        _elementHorizontalAlign = value;
        invalidateTargetSizeAndDisplayList();
    }

    //----------------------------------
    //  verticalAlign
    //----------------------------------

    private var _elementVerticalAlign:String = VerticalAlign.JUSTIFY;

    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
     *  Specifies how to align the elements within the cells in the vertical direction.
     *  Supported values are
     *  <code>VerticalAlign.TOP</code>,
     *  <code>VerticalAlign.MIDDLE</code>,
     *  <code>VerticalAlign.BOTTOM</code>,
     *  <code>VerticalAlign.JUSTIFY</code>.
     *
     *  <p>When set to <code>VerticalAlign.JUSTIFY</code>, the height of each
     *  element will be set to <code>rowHeight</code></p>.
     *
     *  @default <code>VerticalAlign.JUSTIFY</code>
     */
    public function get elementVerticalAlign():String
    {
        return _elementVerticalAlign;
    }

    /**
     *  @private
     */
    public function set elementVerticalAlign(value:String):void
    {
        if (_elementVerticalAlign == value)
            return;

        _elementVerticalAlign = value;
        invalidateTargetSizeAndDisplayList();
    }

    //----------------------------------
    //  justifyColumns
    //----------------------------------

    // TODO EGeorgie: add String enum
    private var _justifyColumns:String = "none";

    [Inspectable(category="General")]

    /**
     *  Specifies how to justify the fully visible columns to the container width.
     *  Supported values are "none", "gapSize", "columnSize".
     *
     *  <p>When set to "none" - turns column justification off, there may
     *  be partially visible columns or whitespace between the last column and
     *  the right edge of the container.  This is the default value.</p>
     *
     *  <p>When set to "gapSize" - the <code>horizontalGap</code> actual value will increase so that
     *  the last fully visible column right edge aligns with the container's right edge.
     *  In case there is only a single fully visible column, the <code>horizontalGap</code> actual value
     *  will increase so that it pushes any partially visible column just beyond the right edge
     *  of the container.  Note that explicitly setting the <code>horizontalGap</code> does not turn off
     *  justification, but just determines the initial gap value, and after thatn justification
     *  may increases it.</p>
     *
     *  <p>When set to "columnSize" - the <code>columnWidth</code> actual value will increase so that
     *  the last fully visible column right edge aligns with the container's right edge.  Note that
     *  explicitly setting the <code>columnWidth</code> does not turn off justification, but simply
     *  determines the initial column width value, and after that justification may increases it.</p>
     *
     *  @see #horizontalGap
     *  @see #columnWidth
     *  @see #justifyRows
     *  @default "none"
     */
    public function get justifyColumns():String
    {
        return _justifyColumns;
    }

    /**
     *  @private
     */
    public function set justifyColumns(value:String):void
    {
        if (_justifyColumns == value)
            return;

        _justifyColumns = value;
        invalidateTargetSizeAndDisplayList();
    }

    //----------------------------------
    //  justifyRows
    //----------------------------------

    private var _justifyRows:String = "none";

    [Inspectable(category="General")]

    /**
     *  Specifies how to justify the fully visible rows to the container height.
     *  Supported values are "none", "gapSize", "rowSize".
     *
     *  <p>When set to "none" - turns column justification off, there may
     *  be partially visible rows or whitespace between the last row and
     *  the bottom edge of the container.  This is the default value.</p>
     *
     *  <p>When set to "gapSize" - the <code>verticalGap</code> actual value will increase so that
     *  the last fully visible row bottom edge aligns with the container's bottom edge.
     *  In case there is only a single fully visible row, the <code>verticalGap</code> actual value
     *  will increase so that it pushes any partially visible row just beyond the bottom edge
     *  of the container.  Note that explicitly setting the <code>verticalGap</code> does not turn off
     *  justification, but just determines the initial gap value, and after that justification
     *  may increases it.</p>
     *
     *  <p>When set to "rowSize" - the <code>rowHeight</code> actual value will increase so that
     *  the last fully visible row bottom edge aligns with the container's bottom edge.  Note that
     *  explicitly setting the <code>rowHeight</code> does not turn off justification, but simply
     *  determines the initial row height value, and after that justification may increases it.</p>
     *
     *  @see #verticalGap
     *  @see #rowHeight
     *  @see #justifyColumns
     *  @default "none"
     */
    public function get justifyRows():String
    {
        return _justifyRows;
    }

    /**
     *  @private
     */
    public function set justifyRows(value:String):void
    {
        if (_justifyRows == value)
            return;

        _justifyRows = value;
        invalidateTargetSizeAndDisplayList();
    }

    //----------------------------------
    //  orientation
    //----------------------------------

    // TODO EGeorgie: add an enum instead of hardcoding
    private var _orientation:String = "rows";

    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
     *  Determines whether elements are arranged row by row or
     *  column by column.
     *  Supported values are "rows", "columns".
     *
     *  @default "rows"
     */
    public function get orientation():String
    {
        return _orientation;
    }

    /**
     *  @private
     */
    public function set orientation(value:String):void
    {
        if (_orientation == value)
            return;

        _orientation = value;
        invalidateTargetSizeAndDisplayList();
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  storage for old property values, in order to dispatch change events.
     */
    private var oldColumnWidth:Number = NaN;
    private var oldRowHeight:Number = NaN;
    private var oldColumnCount:int = -1;
    private var oldRowCount:int = -1;
    private var oldHorizontalGap:Number = NaN;
    private var oldVerticalGap:Number = NaN;

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Dispatches events if Actual values have changed since the last call.
     *  Checks columnWidth, rowHeight, columnCount, rowCount, horizontalGap, verticalGap.
     *  This method is called from within updateDisplayList()
     */
    protected function dispatchEventsForActualValueChanges():void
    {
        if (oldColumnWidth != _columnWidth)
            dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "columnWidth", oldColumnWidth, _columnWidth));
        if (oldRowHeight != _rowHeight)
            dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "rowHeight", oldRowHeight, _rowHeight));
        if (oldColumnCount != _columnCount)
            dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "columnCount", oldColumnCount, _columnCount));
        if (oldRowCount != _rowCount)
            dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "rowCount", oldRowCount, _rowCount));
        if (oldHorizontalGap != _horizontalGap)
            dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "horizontalGap", oldHorizontalGap, _horizontalGap));
        if (oldVerticalGap != _verticalGap)
            dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "verticalGap", oldVerticalGap, _verticalGap));

        oldColumnWidth   = _columnWidth;
        oldRowHeight     = _rowHeight;
        oldColumnCount   = _columnCount;
        oldRowCount      = _rowCount;
        oldHorizontalGap = _horizontalGap;
        oldVerticalGap   = _verticalGap;
    }

    /**
     *  This method is called from measure() and updateDisplayList() to calculate the
     *  actual values for columnWidth, rowHeight, columnCount, rowCount, horizontalGap and verticalGap.
     *
     *  @param width - the width during measure() is the layout target explicitWidth or NaN
     *  and during updateDisplayList() is the unscaledWidth.
     *  @param height - the height during measure() is the layout target explicitHeight or NaN
     *  and during updateDisplayList() is the unscaledHeight.
     */
    protected function updateActualValues(width:Number, height:Number):void
    {
        _columnWidth = _rowHeight = NaN;
        _horizontalGap = _verticalGap = NaN;
        _columnCount = _rowCount = -1;

        // First, figure the tile size
        calculateTileSize();

        // Second, figure out number of rows/columns
        var elementCount:int = calculateElementCount();
        calculateColumnAndRowCount(width, height, elementCount);

        // Third, adjust the gaps and column and row sizes based on justification settings
        _horizontalGap = explicitHorizontalGap;
        _verticalGap = explicitVerticalGap;

        // Justify
        switch(justifyColumns)
        {
            case "gapSize":
                _horizontalGap = justifyByGapSize(width, _columnWidth, _horizontalGap, _columnCount);
            break;
            case "columnSize":
                _columnWidth = justifyByElementSize(width, _columnWidth, _horizontalGap, _columnCount);
            break;
        }

        switch(justifyRows)
        {
            case "gapSize":
                _verticalGap = justifyByGapSize(height, _rowHeight, _verticalGap, _rowCount);
            break;
            case "rowSize":
                _rowHeight = justifyByElementSize(height, _rowHeight, _verticalGap, _rowCount);
            break;
        }

        // Last, if we have explicit overrides for both rowCount and columnCount, then
        // make sure that the count along the minor axis is deduced from the element count
        // and the count along the major axis.
        // Note that we do this *after* justification is taken into account as we want to
        // justify based on the explicit user settings.
        if (-1 != explicitColumnCount && -1 != explicitRowCount)
        {
            if (orientation == "rows")
                _rowCount = Math.max(_rowCount, Math.ceil(elementCount / Math.max(1, explicitColumnCount)));
            else
                _columnCount = Math.max(_columnCount, Math.ceil(elementCount / Math.max(1, explicitRowCount)));
        }
    }

    /**
     *  @private
     *  Calculates _columnCount and _rowCount based on width, height,
     *  orientation, explicitColumnCount, explicitRowCount, _columnWidth, _rowHeight.
     *  _columnWidth and _rowHeight must be valid before calling.
     */
    private function calculateColumnAndRowCount(width:Number, height:Number, elementCount:int):void
    {
        if (-1 != explicitColumnCount || -1 != explicitRowCount)
        {
            if (-1 != explicitRowCount)
                _rowCount = Math.max(1, explicitRowCount);

            if (-1 != explicitColumnCount)
                _columnCount = Math.max(1, explicitColumnCount);
        }
        // Figure out number of columns or rows based on the explicit size along one of the axes
        else if (!isNaN(width) && (orientation == "rows" || isNaN(height)))
        {
            if (_columnWidth + explicitHorizontalGap > 0)
                _columnCount = Math.max(1, Math.floor((width + explicitHorizontalGap) / (_columnWidth + explicitHorizontalGap)));
            else
                _columnCount = 1;
        }
        else if (!isNaN(height) && (orientation == "columns" || isNaN(width)))
        {
            if (_rowHeight + explicitVerticalGap > 0)
                _rowCount = Math.max(1, Math.floor((height + explicitVerticalGap) / (_rowHeight + explicitVerticalGap)));
            else
                _rowCount = 1;
        }
        else // Figure out the number of columns and rows so that pixels area occupied is as square as possible
        {
            // Calculate number of rows and columns so that
            // pixel area is as square as possible
            var hGap:Number = explicitHorizontalGap;
            var vGap:Number = explicitVerticalGap;

            // 1. columnCount * (columnWidth + hGap) - hGap == rowCount * (rowHeight + vGap) - vGap
            // 1. columnCount * (columnWidth + hGap) == rowCount * (rowHeight + vGap) + hGap - vGap
            // 1. columnCount == (rowCount * (rowHeight + vGap) + hGap - vGap) / (columnWidth + hGap)
            // 2. columnCount * rowCount == elementCount
            // substitute 1. in 2.
            // rowCount * rowCount + (hGap - vGap) * rowCount - elementCount * (columnWidth + hGap ) == 0

            var a:Number = Math.max(0, (rowHeight + vGap));
            var b:Number = (hGap - vGap);
            var c:Number = -elementCount * (_columnWidth + hGap);
            var d:Number = b * b - 4 * a * c; // Always guaranteed to be greater than zero, since c <= 0
            d = Math.sqrt(d);

            // We are guaranteed that we have only one positive root, since d >= b:
            var rowCount:Number = (a != 0) ? (b + d) / (2 * a) : elementCount;

            var row1:int = Math.max(1, Math.round(rowCount));
            var col1:int = Math.max(1, Math.ceil(elementCount / row1));

            // Now try to reduce the bigger dimension and see if we can come up with a better distribution
            var row2:int;
            var col2:int;
            if (col1 * (_columnWidth + hGap) - hGap > row1 * (_rowHeight + vGap) - vGap)
            {
                col2 = Math.max(1, col1 - 1);
                row2 = Math.max(1, Math.ceil(elementCount / col2));
            }
            else
            {
                row2 = Math.max(1, row2 - 1);
                col2 = Math.max(1, Math.ceil(elementCount / row2));
            }

            // Pick the better one of the two
            if (Math.abs(col1 * (_columnWidth + hGap) - hGap - row1 * (_rowHeight + vGap) + vGap) <=
                Math.abs(col2 * (_columnWidth + hGap) - hGap - row2 * (_rowHeight + vGap) + vGap))
            {
                _columnCount = col1;
                _rowCount = row1;
            }
            else
            {
                _columnCount = col2;
                _rowCount = row2;
            }
        }

        // In case we determined only columns or rows (from explicit overrides or explicit width/height)
        // calculate the other from the number of elements
        if (-1 == _rowCount)
            _rowCount = Math.max(1, Math.ceil(elementCount / _columnCount));
        if (-1 == _columnCount)
            _columnCount = Math.max(1, Math.ceil(elementCount / _rowCount));
    }

    /**
     *  @private
     *  Increases the gap so that elements are justified to exactly fit totalSize
     *  leaving no partially visible elements in view.
     *  @return Returs the new gap size.
     */
    private function justifyByGapSize(totalSize:Number, elementSize:Number,
                                      gap:Number, elementCount:int):Number
    {
        // If element + gap collapses to zero, then don't adjust the gap.
        if (elementSize + gap <= 0)
            return gap;

        // Find the number of fully visible elements
        var visibleCount:int =
            Math.min(elementCount, Math.floor((totalSize + gap) / (elementSize + gap)));

        // If there isn't even a singel fully visible element, don't adjust the gap
        if (visibleCount < 1)
            return gap;

        // Special case: if there's a singe fully visible element and a partially
        // visible element, then make the gap big enough to push out the partially
        // visible element out of view.
        if (visibleCount == 1)
            return elementCount > 1 ? Math.max(gap, totalSize - elementSize) : gap;

        // Now calculate the gap such that the fully visible elements and gaps
        // add up exactly to totalSize:
        // <==> totalSize == visibleCount * elementSize + (visibleCount - 1) * gap
        // <==> totalSize - visibleCount * elementSize == (visibleCount - 1) * gap
        // <==> (totalSize - visibleCount * elementSize) / (visibleCount - 1) == gap
        return (totalSize - visibleCount * elementSize) / (visibleCount - 1);
    }

    /**
     *  @private
     *  Increases the element size so that elements are justified to exactly fit
     *  totalSize leaving no partially visible elements in view.
     *  @return Returns the the new element size.
     */
    private function justifyByElementSize(totalSize:Number, elementSize:Number,
                                          gap:Number, elementCount:int):Number
    {
        var elementAndGapSize:Number = elementSize + gap;
        var visibleCount:int = 0;
        // Find the number of fully visible elements
        if (elementAndGapSize == 0)
            visibleCount = elementCount;
        else
            visibleCount = Math.min(elementCount, Math.floor((totalSize + gap) / elementAndGapSize));

        // If there isn't event a single fully visible element, don't adjust
        if (visibleCount < 1)
            return elementSize;

        // Now calculate the elementSize such that the fully visible elements and gaps
        // add up exactly to totalSize:
        // <==> totalSize == visibleCount * elementSize + (visibleCount - 1) * gap
        // <==> totalSize - (visibleCount - 1) * gap == visibleCount * elementSize
        // <==> (totalSize - (visibleCount - 1) * gap) / visibleCount == elementSize
        return (totalSize - (visibleCount - 1) * gap) / visibleCount;
    }

    /**
     *  @private
     *  Calculates _columnWidth and _rowHeight from maximum of
     *  elements preferred size and any explicit overrides.
     */
    private function calculateTileSize():void
    {
        _columnWidth = explicitColumnWidth;
        _rowHeight = explicitRowHeight;

        if (!isNaN(_columnWidth) && !isNaN(_rowHeight))
            return;

        // TODO EGeorgie: make sure we cache the values so that we don't calculate twice
        // on measure and updateDisplayList
        var columnWidth:Number = 0;
        var rowHeight:Number = 0;

        var layoutTarget:GroupBase = target;
        var count:int = layoutTarget.numLayoutElements;
        for (var i:int = 0; i < count; i++)
        {
            var el:ILayoutElement = layoutTarget.getLayoutElementAt(i);
            if (!el || !el.includeInLayout)
                continue;

            if (isNaN(_columnWidth))
                columnWidth = Math.max(columnWidth, el.getPreferredBoundsWidth());
            if (isNaN(_rowHeight))
                rowHeight = Math.max(rowHeight, el.getPreferredBoundsHeight());
        }

        if (isNaN(_columnWidth))
            _columnWidth = columnWidth;
        if (isNaN(_rowHeight))
            _rowHeight = rowHeight;
    }

    /**
     *  @private
     *  @return Returns the number of layout elements.
     */
    private function calculateElementCount():int
    {
        // TODO EGeorgie: make sure we cache the values so that we don't calculate twice
        // on measure and updateDisplayList.
        // TODO EGeorgie: subtract number of "includeInLayout==false" elements.
        return target.numLayoutElements;
    }

    /**
     *  Sets the size and the position of the specified layout element and cell bounds.
     *  @param element - the element to resize and position.
     *  @param cellX - the x coordinate of the cell.
     *  @param cellY - the y coordinate of the cell.
     *  @param cellWidth - the width of the cell.
     *  @param cellHeight - the height of the cell.
     */
    protected function sizeAndPositionElement(element:ILayoutElement,
                                              cellX:int,
                                              cellY:int,
                                              cellWidth:int,
                                              cellHeight:int):void
    {
        var childWidth:Number = NaN;
        var childHeight:Number = NaN;

        // Determine size of the element
        // TODO EGeorgie: Should we respect minimum element width?
        if (!isNaN(element.percentWidth))
            childWidth = Math.round(cellWidth * Math.min(100, element.percentWidth) / 100);

        // TODO EGeorgie: Should we respect minimum element height?
        if (!isNaN(element.percentHeight))
            childHeight = Math.round(cellHeight * Math.min(100, element.percentHeight) / 100);

        if (elementHorizontalAlign == "justify")
            childWidth = cellWidth;
        if (elementVerticalAlign == "justify")
            childHeight = cellHeight;

        // TODO EGeorgie: compare childWidth/childHeight against min/max.
        // The cell size should be a maximum for the element (in cases where the cell has explicit width/height).

        // Size the element
        element.setLayoutBoundsSize(childWidth, childHeight, true /*postTransform*/);

        var x:Number = cellX;
        switch (elementHorizontalAlign)
        {
            case "right":
                x += cellWidth - element.getLayoutBoundsWidth();
            break;
            case "center":
                // Make sure division result is integer - Math.floor() the result.
                x = cellX + Math.floor((cellWidth - element.getLayoutBoundsWidth()) / 2);
            break;
        }

        var y:Number = cellY;
        switch (elementVerticalAlign)
        {
            case "bottom":
                y += cellHeight - element.getLayoutBoundsHeight();
            break;
            case "middle":
                // Make sure division result is integer - Math.floor() the result.
                y += Math.floor((cellHeight - element.getLayoutBoundsHeight()) / 2);
            break;
        }

        // Position the element
        element.setLayoutBoundsPosition(x, y);
    }

    //--------------------------------------------------------------------------
    //
    //  Overriden methods from LayoutBase
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override public function measure():void
    {
        var layoutTarget:GroupBase = target;
        if (!layoutTarget)
            return;

        updateActualValues(layoutTarget.explicitWidth, layoutTarget.explicitHeight);

        // For measure, any explicit overrides for rowCount and columnCount take precedence
        var columnCount:int = explicitColumnCount != -1 ? explicitColumnCount : _columnCount;
        var rowCount:int = explicitRowCount != -1 ? explicitRowCount : _rowCount;

        layoutTarget.measuredWidth = Math.round(columnCount * (_columnWidth + _horizontalGap) - _horizontalGap);
        layoutTarget.measuredHeight = Math.round(rowCount * (_rowHeight + _verticalGap) - _verticalGap);

        // Minimum size is just enough to display a single cell
        layoutTarget.measuredMinWidth = Math.round(_columnWidth);
        layoutTarget.measuredMinHeight = Math.round(_rowHeight);
    }

    /**
     *  @private
     */
    override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        var layoutTarget:GroupBase = target;
        if (!layoutTarget)
            return;

        updateActualValues(unscaledWidth, unscaledHeight);

        var xPos:Number = 0;
        var yPos:Number = 0;

        // Use counter and counterLimit to track when to move along the minor axis
        var counter:int = 0;
        var counterLimit:int;

        // Use MajorDelta when moving along the major axis
        var xMajorDelta:Number;
        var yMajorDelta:Number;

        // Use MinorDelta when moving along the minor axis
        var xMinorDelta:Number;
        var yMinorDelta:Number;

        // Setup counterLimit and deltas based on orientation
        if (orientation == "rows")
        {
            counterLimit = _columnCount;
            xMajorDelta = _columnWidth + _horizontalGap;
            xMinorDelta = 0;
            yMajorDelta = 0;
            yMinorDelta = _rowHeight + _verticalGap;
        }
        else
        {
            counterLimit = _rowCount;
            xMajorDelta = 0;
            xMinorDelta = _columnWidth + _horizontalGap;
            yMajorDelta = _rowHeight + _verticalGap;
            yMinorDelta = 0;
        }

        var count:int = layoutTarget.numLayoutElements;
        for (var i:int = 0; i < count; i++)
        {
            var el:ILayoutElement = layoutTarget.getLayoutElementAt(i);
            if (!el || !el.includeInLayout)
                continue;

            // To calculate the cell extents as integers, first calculate
            // the extents and then use Math.round()
            var cellX:int = Math.round(xPos);
            var cellY:int = Math.round(yPos);
            var cellWidth:int = Math.round(xPos + _columnWidth) - cellX;
            var cellHeight:int = Math.round(yPos + _rowHeight) - cellY;

            sizeAndPositionElement(el, cellX, cellY, cellWidth, cellHeight);

            // Move along the major axis
            xPos += xMajorDelta;
            yPos += yMajorDelta;

            // Move along the minor axis
            if (++counter >= counterLimit)
            {
                counter = 0;
                if (orientation == "rows")
                {
                    xPos = 0;
                    yPos += yMinorDelta;
                }
                else
                {
                    xPos += xMinorDelta;
                    yPos = 0;
                }
            }
        }

        layoutTarget.setContentSize(Math.round(_columnCount * (_columnWidth + _horizontalGap) - _horizontalGap),
                                    Math.round(_rowCount * (_rowHeight + _verticalGap) - _verticalGap));

        // If actual values have chnaged, notify listeners
        dispatchEventsForActualValueChanges();
    }
}
}
