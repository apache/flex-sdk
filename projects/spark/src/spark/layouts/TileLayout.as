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

package spark.layout
{
import flash.geom.Rectangle;

import spark.components.supportClasses.GroupBase;
import mx.core.ILayoutElement;
import mx.events.PropertyChangeEvent;
import spark.layout.HorizontalAlign;
import spark.layout.supportClasses.LayoutBase;
import spark.layout.ColumnAlign;
import spark.layout.RowAlign;
import spark.layout.TileOrientation;
import spark.layout.VerticalAlign;

/**
 *  TileLayout arranges the layout elements in columns and rows
 *  of equally-sized cells.
 *
 *  There are a number of properties that control orientation,
 *  count, size, gap and justification of the columns and the rows
 *  as well as element alignment within the cells.
 *
 *  Per-element supported constraints are percentWidth, percentHeight.
 *  Element's minimum and maximum sizes will always be respected and
 *  where possible, an element's size will be limited to less then or equal
 *  of the cell size.
 *
 *  When not explicitly set, the columnWidth is calculated as the maximum
 *  preferred bounds width of all elements and the columnHeight is calculated
 *  as the maximum preferred bounds height of all elements.
 *
 *  When not explicitly set, the columnCount and rowCount are calculated from
 *  any explicit width/height settings for the layout target and columnWidth
 *  and columnHeight.  In case none is specified, the coulumnCount and rowCount
 *  values are picked so that the resulting pixel area is as square as possible.
 * 
 *  The measured size is calculated from the columnCount, rowCount, 
 *  columnWidth, rowHeight and the gap sizes.
 *
 *  The default measured size, when no properties were explicitly set, is
 *  as square as possible area and is enough to fit all elements.
 *
 *  In other cases the measured size may not be big enough to fit all elements -
 *  for example when both columnCount and rowCount are explicitly set to values
 *  such that columnCount * rowCount &lt; element count.
 *
 *  The minimum measured size is calculated the same way as the measured size but
 *  it's guaranteed to encompass enough rows/columns along the minor axis to fit
 *  all elements.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  @see #columnAlign
     *  @default 6
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  @see #rowAlign
     *  @default 6
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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

    private var _columnCount:int = -1;

    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
     *  This property will contain the actual column count after
     *  <code>updateDisplayList()</code>.
     *
     *  @see #rowCount
     *  @see #columnAlign
     *  @default -1
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get columnCount():int
    {
        return _columnCount;
    }

    //----------------------------------
    //  requestedColumnCount
    //----------------------------------

    /**
     *  @private
     *  Storage for the requestedColumnCount property.
     */
    private var _requestedColumnCount:int = -1;
    
    [Inspectable(category="General")]

    /**
     *  Number of columns to be displayed.
     *  Set to make sure the layout measures a specific number of columns.
     * 
     *  Set to -1 to remove explicit override and allow the TileLayout to determine
     *  the column count automatically.
     *
     *  Setting this property won't have any effect, if <code>orientation</code> is
     *  set to TileOrientation.ROWS, <code>rowCount</code> is explicitly set, and the
     *  container width is explicitly set.
     * 
     *  @see #columnCount
     *  @see #columnAlign
     *  @default -1
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
    private var _rowCount:int = -1;

    [Bindable("propertyChange")]
    [Inspectable(category="General")]

    /**
     *  This property will contain the actual row count after
     *  <code>updateDisplayList()</code>.
     *
     *  @see #requestedRowCount
     *  @see #columnCount
     *  @default -1
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get rowCount():int
    {
        return _rowCount;
    }

    //----------------------------------
    //  requestedRowCount
    //----------------------------------

    /**
     *  @private
     *  Storage for the requestedRowCount property.
     */
    private var _requestedRowCount:int = -1;
    
    [Inspectable(category="General")]

    /**
     *  Number of rows to be displayed.
     *  Set to make sure the layout measures a specific number of rows.
     * 
     *  Set to -1 to remove explicit override and allow the TileLayout to determine
     *  the row count automatically.
     *
     *  Setting this property won't have any effect, if <code>orientation</code> is
     *  set to TileOrientation.COLUMNS, <code>columnCount</code> is explicitly set, and the
     *  container height is explicitly set.
     * 
     *  @see #rowCount
     *  @see #rowAlign
     *  @default -1
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  If <code>columnAlign</code> is set to "justifyUsingWidth", the actual column width
     *  will grow to justify the fully-visible columns to the container width.
     *
     *  @see #rowHeight
     *  @see #columnAlign
     *  @default NaN
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  If <code>rowAlign</code> is set to "justifyUsingHeight", the actual row height
     *  will grow to justify the fully-visible rows to the container height.
     *
     *  @see #columnWidth
     *  @see #rowAlign
     *  @default NaN
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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

    private var _horizontalAlign:String = HorizontalAlign.JUSTIFY;

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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get horizontalAlign():String
    {
        return _horizontalAlign;
    }

    /**
     *  @private
     */
    public function set horizontalAlign(value:String):void
    {
        if (_horizontalAlign == value)
            return;

        _horizontalAlign = value;
        invalidateTargetSizeAndDisplayList();
    }

    //----------------------------------
    //  verticalAlign
    //----------------------------------

    private var _verticalAlign:String = VerticalAlign.JUSTIFY;

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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get verticalAlign():String
    {
        return _verticalAlign;
    }

    /**
     *  @private
     */
    public function set verticalAlign(value:String):void
    {
        if (_verticalAlign == value)
            return;

        _verticalAlign = value;
        invalidateTargetSizeAndDisplayList();
    }

    //----------------------------------
    //  columnAlign
    //----------------------------------

    private var _columnAlign:String = ColumnAlign.LEFT;

    [Inspectable(category="General", enumeration="left,justifyUsingGap,justifyUsingWidth", defaultValue="left")]

    /**
     *  Specifies how to justify the fully visible columns to the container width.
     *  ActionScript values can be <code>ColumnAlign.LEFT</code>, <code>ColumnAlign.JUSTIFY_USING_GAP</code>
     *  and <code>ColumnAlign.JUSTIFY_USING_WIDTH</code>.
     *  MXML values can be <code>"left"</code>, <code>"justifyUsingGap"</code> and <code>"justifyUsingWidth"</code>.
     *
     *  <p>When set to <code>ColumnAlign.LEFT</code> - turns column justification off, there may
     *  be partially visible columns or whitespace between the last column and
     *  the right edge of the container.  This is the default value.</p>
     *
     *  <p>When set to <code>ColumnAlign.JUSTIFY_USING_GAP</code> - the <code>horizontalGap</code>
     *  actual value will increase so that
     *  the last fully visible column right edge aligns with the container's right edge.
     *  In case there is only a single fully visible column, the <code>horizontalGap</code> actual value
     *  will increase so that it pushes any partially visible column just beyond the right edge
     *  of the container.  Note that explicitly setting the <code>horizontalGap</code> does not turn off
     *  justification, but just determines the initial gap value, and after thatn justification
     *  may increases it.</p>
     *
     *  <p>When set to <code>ColumnAlign.JUSTIFY_USING_WIDTH</code> - the <code>columnWidth</code>
     *  actual value will increase so that
     *  the last fully visible column right edge aligns with the container's right edge.  Note that
     *  explicitly setting the <code>columnWidth</code> does not turn off justification, but simply
     *  determines the initial column width value, and after that justification may increases it.</p>
     *
     *  @see #horizontalGap
     *  @see #columnWidth
     *  @see #rowAlign
     *  @default ColumnAlign.LEFT
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get columnAlign():String
    {
        return _columnAlign;
    }

    /**
     *  @private
     */
    public function set columnAlign(value:String):void
    {
        if (_columnAlign == value)
            return;

        _columnAlign = value;
        invalidateTargetSizeAndDisplayList();
    }

    //----------------------------------
    //  rowAlign
    //----------------------------------

    private var _rowAlign:String = RowAlign.TOP;

    [Inspectable(category="General", enumeration="top,justifyUsingGap,justifyUsingHeight", defaultValue="top")]

    /**
     *  Specifies how to justify the fully visible rows to the container height.
     *  ActionScript values can be <code>RowAlign.TOP</code>, <code>RowAlign.JUSTIFY_USING_GAP</code>
     *  and <code>RowAlign.JUSTIFY_USING_HEIGHT</code>.
     *  MXML values can be <code>"top"</code>, <code>"justifyUsingGap"</code> and <code>"justifyUsingHeight"</code>.
     *
     *  <p>When set to <code>RowAlign.TOP</code> - turns column justification off, there may
     *  be partially visible rows or whitespace between the last row and
     *  the bottom edge of the container.  This is the default value.</p>
     *
     *  <p>When set to <code>RowAlign.JUSTIFY_USING_GAP</code> - the <code>verticalGap</code>
     *  actual value will increase so that
     *  the last fully visible row bottom edge aligns with the container's bottom edge.
     *  In case there is only a single fully visible row, the <code>verticalGap</code> actual value
     *  will increase so that it pushes any partially visible row just beyond the bottom edge
     *  of the container.  Note that explicitly setting the <code>verticalGap</code> does not turn off
     *  justification, but just determines the initial gap value, and after that justification
     *  may increases it.</p>
     *
     *  <p>When set to <code>RowAlign.JUSTIFY_USING_HEIGHT</code> - the <code>rowHeight</code>
     *  actual value will increase so that
     *  the last fully visible row bottom edge aligns with the container's bottom edge.  Note that
     *  explicitly setting the <code>rowHeight</code> does not turn off justification, but simply
     *  determines the initial row height value, and after that justification may increases it.</p>
     *
     *  @see #verticalGap
     *  @see #rowHeight
     *  @see #columnAlign
     *  @default RowAlign.TOP
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get rowAlign():String
    {
        return _rowAlign;
    }

    /**
     *  @private
     */
    public function set rowAlign(value:String):void
    {
        if (_rowAlign == value)
            return;

        _rowAlign = value;
        invalidateTargetSizeAndDisplayList();
    }

    //----------------------------------
    //  orientation
    //----------------------------------

    private var _orientation:String = TileOrientation.ROWS;

    [Bindable("propertyChange")]
    [Inspectable(category="General", enumeration="rows,columns", defaultValue="rows")]

    /**
     *  Specifies whether elements are arranged row by row or
     *  column by column.
     *  ActionScript values can be <code>TileOrientation.ROWS</code> and 
     *  <code>TileOrientation.COLUMNS</code>.
     *  MXML values can be <code>"rows"</code> and <code>"columns"</code>.
     *
     *  @default TileOrientation.ROWS
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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

    // Cache storage to avoid repeating work from measure() in updateDisplayList().
    // These are set the first time the value is calculated and are reset at the end
    // of updateDisplayList().
    private var _tileWidthCached:Number = NaN;
    private var _tileHeightCached:Number = NaN;
    private var _numElementsCached:int = -1;
    
    /**
     *  @private
     *  The following variables are used by updateDisplayList() and set by
     *  calculateDisplayParameters().   If virtualLayout=true they're based 
     *  on the current scrollRect.
     */
    private var visibleStartIndex:int = -1;   // dataProvider/layout element index  
    private var visibleEndIndex:int = -1;     // ...
    private var visibleStartX:Number = 0;     // first tile/cell origin
    private var visibleStartY:Number = 0;     // ...

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Dispatches events if Actual values have changed since the last call.
     *  Checks columnWidth, rowHeight, columnCount, rowCount, horizontalGap, verticalGap.
     *  This method is called from within updateDisplayList()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    private function dispatchEventsForActualValueChanges():void
    {
        if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
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
        }

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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    private function updateActualValues(width:Number, height:Number):void
    {
        // First, figure the tile size
        calculateTileSize();

        // Second, figure out number of rows/columns
        var elementCount:int = calculateElementCount();
        calculateColumnAndRowCount(width, height, elementCount);

        // Third, adjust the gaps and column and row sizes based on justification settings
        _horizontalGap = explicitHorizontalGap;
        _verticalGap = explicitVerticalGap;

        // Justify
        switch (columnAlign)
        {
            case ColumnAlign.JUSTIFY_USING_GAP:
                _horizontalGap = justifyByGapSize(width, _columnWidth, _horizontalGap, _columnCount);
            break;
            case ColumnAlign.JUSTIFY_USING_WIDTH:
                _columnWidth = justifyByElementSize(width, _columnWidth, _horizontalGap, _columnCount);
            break;
        }

        switch (rowAlign)
        {
            case RowAlign.JUSTIFY_USING_GAP:
                _verticalGap = justifyByGapSize(height, _rowHeight, _verticalGap, _rowCount);
            break;
            case RowAlign.JUSTIFY_USING_HEIGHT:
                _rowHeight = justifyByElementSize(height, _rowHeight, _verticalGap, _rowCount);
            break;
        }

        // Last, if we have explicit overrides for both rowCount and columnCount, then
        // make sure that we can fit all the elements. If we need to, we will increase
        // the count along the minor axis based on the element count
        // and the count along the major axis.
        // Note that we do this *after* justification is taken into account as we want to
        // justify based on the explicit user settings.
        if (-1 != _requestedColumnCount && -1 != _requestedRowCount)
        {
            if (orientation == TileOrientation.ROWS)
                _rowCount = Math.max(_rowCount, Math.ceil(elementCount / Math.max(1, _requestedColumnCount)));
            else
                _columnCount = Math.max(_columnCount, Math.ceil(elementCount / Math.max(1, _requestedRowCount)));
        }
    }
    
    /**
     *  @private
     *  Returns true, if the dimensions (colCount1, rowCount1) are more square than (colCount2, rowCount2).
     *  Squareness is the difference between width and height of a tile layout
     *  with the specified number of columns and rows.
     */
    private function closerToSquare(colCount1:int, rowCount1:int, colCount2:int, rowCount2:int):Boolean
    {
        var difference1:Number = Math.abs(colCount1 * (_columnWidth + _horizontalGap) - _horizontalGap - 
                                          rowCount1 * (_rowHeight   +   _verticalGap) + _verticalGap);
        var difference2:Number = Math.abs(colCount2 * (_columnWidth + _horizontalGap) - _horizontalGap - 
                                          rowCount2 * (_rowHeight   +   _verticalGap) + _verticalGap);
        
        return difference1 < difference2 || (difference1 == difference2 && rowCount1 <= rowCount2);
    }

    /**
     *  @private
     *  Calculates _columnCount and _rowCount based on width, height,
     *  orientation, _requestedColumnCount, _requestedRowCount, _columnWidth, _rowHeight.
     *  _columnWidth and _rowHeight must be valid before calling.
     */
    private function calculateColumnAndRowCount(width:Number, height:Number, elementCount:int):void
    {
        _columnCount = _rowCount = -1;

        if (-1 != _requestedColumnCount || -1 != _requestedRowCount)
        {
            if (-1 != _requestedRowCount)
                _rowCount = Math.max(1, _requestedRowCount);

            if (-1 != _requestedColumnCount)
                _columnCount = Math.max(1, _requestedColumnCount);
        }
        // Figure out number of columns or rows based on the explicit size along one of the axes
        else if (!isNaN(width) && (orientation == TileOrientation.ROWS || isNaN(height)))
        {
            if (_columnWidth + explicitHorizontalGap > 0)
                _columnCount = Math.max(1, Math.floor((width + explicitHorizontalGap) / (_columnWidth + explicitHorizontalGap)));
            else
                _columnCount = 1;
        }
        else if (!isNaN(height) && (orientation == TileOrientation.COLUMNS || isNaN(width)))
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

            // To get integer count for the columns/rows we round up and down so
            // we get four possible solutions. Then we pick the best one.
            var row1:int = Math.max(1, Math.floor(rowCount));
            var col1:int = Math.max(1, Math.ceil(elementCount / row1));
            row1 = Math.max(1, Math.ceil(elementCount / col1));

            var row2:int = Math.max(1, Math.ceil(rowCount));
            var col2:int = Math.max(1, Math.ceil(elementCount / row2));
            row2 = Math.max(1, Math.ceil(elementCount / col2));

            var col3:int = Math.max(1, Math.floor(elementCount / rowCount));
            var row3:int = Math.max(1, Math.ceil(elementCount / col3));
            col3 = Math.max(1, Math.ceil(elementCount / row3));

            var col4:int = Math.max(1, Math.ceil(elementCount / rowCount));
            var row4:int = Math.max(1, Math.ceil(elementCount / col4));
            col4 = Math.max(1, Math.ceil(elementCount / row4));

            if (closerToSquare(col3, row3, col1, row1))
            {
                col1 = col3;
                row1 = row3;
            }

            if (closerToSquare(col4, row4, col2, row2))
            {
                col2 = col4;
                row2 = row4;
            }

            if (closerToSquare(col1, row1, col2, row2))
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
     *  Update _tileWidth,Height to be the maximum of their current
     *  value and the element's preferred bounds. 
     */
    private function updateVirtualTileSize(elt:ILayoutElement):void
    {
        if (!elt || !elt.includeInLayout)
            return;
        var w:Number = elt.getPreferredBoundsWidth();
        var h:Number = elt.getPreferredBoundsHeight();
        _tileWidthCached = isNaN(_tileWidthCached) ? w : Math.max(w, _tileWidthCached);
        _tileHeightCached = isNaN(_tileHeightCached) ? h : Math.max(h, _tileHeightCached);
    }
    
    /**
     *  @private
     */
    private function calculateVirtualTileSize():void
    {
        // If both dimensions are explicitly set, we're done
        _columnWidth = explicitColumnWidth;
        _rowHeight = explicitRowHeight;
        if (!isNaN(_columnWidth) && !isNaN(_rowHeight))
        {
            _tileWidthCached = _columnWidth;
            _tileHeightCached = _rowHeight;
            return;
        }
        
        // update _tileWidth,HeightCached based on the typicalElement     
        updateVirtualTileSize(typicalLayoutElement);
        
        // update _tileWidth,HeightCached based on visible elements    
        if ((visibleStartIndex != -1) && (visibleEndIndex != -1))
        {
            for(var index:int = visibleStartIndex; index <= visibleEndIndex; index++)
                updateVirtualTileSize(target.getVirtualElementAt(index));
        }
        
        if (isNaN(_columnWidth))
            _columnWidth = _tileWidthCached;
        if (isNaN(_rowHeight))
            _rowHeight = _tileHeightCached;        
    }

    /**
     *  @private
     *  Calculates _columnWidth and _rowHeight from maximum of
     *  elements preferred size and any explicit overrides.
     */
    private function calculateRealTileSize():void
    {
        _columnWidth = _tileWidthCached;
        _rowHeight = _tileHeightCached;
        if (!isNaN(_columnWidth) && !isNaN(_rowHeight))
            return;

        // Are both dimensions explicitly set?
        _columnWidth = _tileWidthCached = explicitColumnWidth;
        _rowHeight = _tileHeightCached = explicitRowHeight;
        if (!isNaN(_columnWidth) && !isNaN(_rowHeight))
            return;

        // Find the maxmimums of element's preferred sizes
        var columnWidth:Number = 0;
        var rowHeight:Number = 0;

        var layoutTarget:GroupBase = target;
        var count:int = layoutTarget.numElements;
        // Remember the number of includeInLayout elements
        _numElementsCached = count;
        for (var i:int = 0; i < count; i++)
        {
            var el:ILayoutElement = layoutTarget.getElementAt(i);
            if (!el || !el.includeInLayout)
            {
                _numElementsCached--;
                continue;
            }

            if (isNaN(_columnWidth))
                columnWidth = Math.max(columnWidth, el.getPreferredBoundsWidth());
            if (isNaN(_rowHeight))
                rowHeight = Math.max(rowHeight, el.getPreferredBoundsHeight());
        }

        if (isNaN(_columnWidth))
            _columnWidth = _tileWidthCached = columnWidth;
        if (isNaN(_rowHeight))
            _rowHeight = _tileHeightCached = rowHeight;
    }
    
    private function calculateTileSize():void    
    {
        if (useVirtualLayout)
            calculateVirtualTileSize();
        else 
            calculateRealTileSize();
    }    

    /**
     *  @private
     *  For normal layout return the number of non-null includeInLayout=true
     *  layout elements, for virtual layout just return the number of layout
     *  elements.
     */
    private function calculateElementCount():int
    {
        if (-1 != _numElementsCached)
            return _numElementsCached;
            
        var layoutTarget:GroupBase = target;
        var count:int = layoutTarget.numElements;
        _numElementsCached = count;

        if (useVirtualLayout)
            return _numElementsCached;
            
        for (var i:int = 0; i < count; i++)
        {
            var el:ILayoutElement = layoutTarget.getElementAt(i);
            if (!el || !el.includeInLayout)
                _numElementsCached--;
        }

        return _numElementsCached;
    }
    
    /**
     *  @private
     *  This method computes values for visibleStartX,Y, visibleStartIndex, and 
     *  visibleEndIndex based on the TileLayout geometry values, like _columnWidth
     *  and _rowHeight, computed by calculateActualValues().
     * 
     *  If useVirtualLayout=false, then visibleStartX,Y=0 and visibleStartIndex=0
     *  and visibleEndIndex=layoutTarget.numElements-1.
     * 
     *  If useVirtualLayout=true and orientation=ROWS then visibleStartIndex is the 
     *  layout element index of the item at first visible row relative to the scrollRect, 
     *  column 0.  Note that we're using column=0 instead of the first visible column
     *  to simplify the iteration logic in updateDisplayList().  This is optimal 
     *  for the common case where the entire row is visible.   Optimally handling 
     *  the case where orientation=ROWS and each row is only partially visible is 
     *  doable but adds some complexity to the main loop.
     * 
     *  The logic for useVirtualLayout=true and orientation=COLS is similar.
     */
    private function calculateDisplayParameters(unscaledWidth:int, unscaledHeight:int):void
    {
        updateActualValues(unscaledWidth, unscaledHeight);

        var layoutTarget:GroupBase = target;
        var eltCount:int = layoutTarget.numElements;
        visibleStartX = 0;   // initial values for xPos,yPos in updateDisplayList
        visibleStartY = 0;
        visibleStartIndex = 0;
        visibleEndIndex = eltCount - 1;

        if (useVirtualLayout)
        {
            var hsp:Number = layoutTarget.horizontalScrollPosition;
            var vsp:Number = layoutTarget.verticalScrollPosition;
            var cwg:Number = _columnWidth + _horizontalGap;
            var rwg:Number = _rowHeight + _verticalGap;
            
            var visibleCol0:int = Math.floor(hsp / cwg);
            var visibleRow0:int = Math.floor(vsp / rwg);
            var visibleCol1:int = Math.min(_columnCount - 1, Math.floor((hsp + unscaledWidth) / cwg));
            var visibleRow1:int = Math.min(_rowCount - 1, Math.floor((vsp + unscaledHeight) / rwg));

            if (orientation == TileOrientation.ROWS)
            {
                visibleStartIndex = (visibleRow0 * _columnCount);
                visibleEndIndex = Math.min(eltCount - 1, (visibleRow1 * _columnCount) + visibleCol1); 
                visibleStartY = visibleRow0 * rwg;                
            }
            else
            {
                visibleStartIndex = (visibleCol0 * _rowCount);
                visibleEndIndex = Math.min(eltCount - 1, (visibleCol1 * _rowCount) + visibleRow1);
                visibleStartX = visibleCol0 * cwg;                
            }
        }
    }
    
    /**
     *  @private
     *  This method is called by updateDisplayList() after initial values for 
     *  visibleStartIndex, visibleEndIndex have been calculated.  We 
     *  re-calculateDisplayParameters() to account for the possibility that
     *  larger cells may have been exposed.  Since tileWdth,Height can only
     *  increase, the new visibleStart,EndIndex values will be greater than or
     *  equal to the old ones. 
     */
     private function updateVirtualLayout(unscaledWidth:int, unscaledHeight:int):void
     {
        var oldVisibleStartIndex:int = visibleStartIndex;
        var oldVisibleEndIndex:int = visibleEndIndex;
        calculateDisplayParameters(unscaledWidth, unscaledHeight);
        
        // We're responsible for the laying *all* of the elements requested
        // with getVirtualElementAt(), even if they don't fall within the final
        // visible range.  Hide any extra ones.
        
        var layoutTarget:GroupBase = target;         
        for(var i:int = oldVisibleStartIndex; i <= oldVisibleEndIndex; i++)
        {
            if (i == visibleStartIndex)
            {
                i = visibleEndIndex;
                continue;
            } 
            var el:ILayoutElement = layoutTarget.getVirtualElementAt(i);
            if (!el)
                continue;
            el.setLayoutBoundsSize(0, 0);
        }
     }    

    /**
     *  Sets the size and the position of the specified layout element and cell bounds.
     *  @param element - the element to resize and position.
     *  @param cellX - the x coordinate of the cell.
     *  @param cellY - the y coordinate of the cell.
     *  @param cellWidth - the width of the cell.
     *  @param cellHeight - the height of the cell.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    private function sizeAndPositionElement(element:ILayoutElement,
                                              cellX:int,
                                              cellY:int,
                                              cellWidth:int,
                                              cellHeight:int):void
    {
        var childWidth:Number = NaN;
        var childHeight:Number = NaN;

        // Determine size of the element
        if (horizontalAlign == "justify")
            childWidth = cellWidth;
        else if (!isNaN(element.percentWidth))
            childWidth = Math.round(cellWidth * element.percentWidth * 0.01);
        else
            childWidth = element.getPreferredBoundsWidth();

        if (verticalAlign == "justify")
            childHeight = cellHeight;
        else if (!isNaN(element.percentHeight))
            childHeight = Math.round(cellHeight * element.percentHeight * 0.01);
        else
            childHeight = element.getPreferredBoundsHeight();

        // Enforce min and max limits
        var maxChildWidth:Number = Math.min(element.getMaxBoundsWidth(), cellWidth);
        var maxChildHeight:Number = Math.min(element.getMaxBoundsHeight(), cellHeight);
        // Make sure we enforce element's minimum last, since it has the highest priority
        childWidth = Math.max(element.getMinBoundsWidth(), Math.min(maxChildWidth, childWidth));
        childHeight = Math.max(element.getMinBoundsHeight(), Math.min(maxChildHeight, childHeight));

        // Size the element
        element.setLayoutBoundsSize(childWidth, childHeight);

        var x:Number = cellX;
        switch (horizontalAlign)
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
        switch (verticalAlign)
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

    /**
     *  @private
     *  @return Returns the x coordinate of the left edge for the specified column.
     */
    final private function leftEdge(columnIndex:int):Number
    {
        return Math.max(0, columnIndex * (_columnWidth + _horizontalGap));
    }

    /**
     *  @private
     *  @return Returns the x coordinate of the right edge for the specified column.
     */
    final private function rightEdge(columnIndex:int):Number
    {
        return Math.min(target.contentWidth, columnIndex * (_columnWidth + _horizontalGap) + _columnWidth);
    }

    /**
     *  @private
     *  @return Returns the y coordinate of the top edge for the specified row.
     */
    final private function topEdge(rowIndex:int):Number
    {
        return Math.max(0, rowIndex * (_rowHeight + _verticalGap));
    }

    /**
     *  @private
     *  @return Returns the y coordinate of the bottom edge for the specified row.
     */
    final private function bottomEdge(rowIndex:int):Number
    {
        return Math.min(target.contentHeight, rowIndex * (_rowHeight + _verticalGap) + _rowHeight);
    }
    
    /**
     *  @private 
     *  Convenience function for subclasses that invalidates the
     *  target's size and displayList so that both layout's <code>measure()</code>
     *  and <code>updateDisplayList</code> methods get called.
     * 
     *  <p>Typically a layout invalidates the target's size and display list so that
     *  it gets a chance to recalculate the target's default size and also size and
     *  position the target's elements. For example changing the <code>gap</code>
     *  property on a <code>VerticalLayout</code> will internally call this method
     *  to ensure that the elements are re-arranged with the new setting and the
     *  target's default size is recomputed.</p> 
     */
    private function invalidateTargetSizeAndDisplayList():void
    {
        var g:GroupBase = target;
        if (!g)
            return;

        g.invalidateSize();
        g.invalidateDisplayList();
    }

    //--------------------------------------------------------------------------
    //
    //  Overriden methods from LayoutBase
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function scrollPositionChanged():void
    {
        super.scrollPositionChanged();
        
        var layoutTarget:GroupBase = target;
        if (!layoutTarget)
            return;

        if (useVirtualLayout)
            layoutTarget.invalidateDisplayList();
    }


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
        var columnCount:int = _requestedColumnCount != -1 ? Math.max(1, _requestedColumnCount) : _columnCount;
        var rowCount:int = _requestedRowCount != -1 ? Math.max(1, _requestedRowCount) : _rowCount;

        layoutTarget.measuredWidth = Math.round(columnCount * (_columnWidth + _horizontalGap) - _horizontalGap);
        layoutTarget.measuredHeight = Math.round(rowCount * (_rowHeight + _verticalGap) - _verticalGap);

        // measured min size is guaranteed to have enough rows/columns to fit all elements
        layoutTarget.measuredMinWidth = Math.round(_columnCount * (_columnWidth + _horizontalGap) - _horizontalGap);
        layoutTarget.measuredMinHeight = Math.round(_rowCount * (_rowHeight + _verticalGap) - _verticalGap);
    }

    /**
     *  @private
     */
    override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        var layoutTarget:GroupBase = target;
        if (!layoutTarget)
            return;

        calculateDisplayParameters(unscaledWidth, unscaledHeight);
        if (useVirtualLayout)
            updateVirtualLayout(unscaledWidth, unscaledHeight);  // re-calculateDisplayParameters()
        
        // Upper right hand corner of first (visibleStartIndex) tile/cell
        var xPos:Number = visibleStartX;  // 0 if useVirtualLayout=false
        var yPos:Number = visibleStartY;  // ...
                
        // Use MajorDelta when moving along the major axis
        var xMajorDelta:Number;
        var yMajorDelta:Number;

        // Use MinorDelta when moving along the minor axis
        var xMinorDelta:Number;
        var yMinorDelta:Number;

        // Use counter and counterLimit to track when to move along the minor axis
        var counter:int = 0;
        var counterLimit:int;

        // Setup counterLimit and deltas based on orientation
        if (orientation == TileOrientation.ROWS)
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

        for(var index:int = visibleStartIndex; index <= visibleEndIndex; index++)
        {
            var el:ILayoutElement = (useVirtualLayout) ? layoutTarget.getVirtualElementAt(index) : layoutTarget.getElementAt(index);
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
                if (orientation == TileOrientation.ROWS)
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

        // Reset the cache
        if (!useVirtualLayout)
            _tileWidthCached = _tileHeightCached = NaN;
        _numElementsCached = -1;
        
        // No getVirtualElementAt() during measure, see calculateVirtualTileSize()
        if (useVirtualLayout)
            visibleStartIndex = visibleEndIndex = -1;        

        // If actual values have chnaged, notify listeners
        dispatchEventsForActualValueChanges();
    }

    /**
     *  @private
     */
    override protected function elementBoundsLeftOfScrollRect(scrollRect:Rectangle):Rectangle
    {
        var bounds:Rectangle = new Rectangle();
        // Find the column that spans or is to the left of the scrollRect left edge.
        var column:int = Math.floor((scrollRect.left - 1) / (_columnWidth + _horizontalGap));
        bounds.left = leftEdge(column);
        bounds.right = rightEdge(column);
        return bounds;
    }

    /**
     *  @private
     */
    override protected function elementBoundsRightOfScrollRect(scrollRect:Rectangle):Rectangle
    {
        var bounds:Rectangle = new Rectangle();
        // Find the column that spans or is to the right of the scrollRect right edge.
        var column:int = Math.floor((scrollRect.right + 1 + _horizontalGap) / (_columnWidth + _horizontalGap));
        bounds.left = leftEdge(column);
        bounds.right = rightEdge(column);
        return bounds;
    }

    /**
     *  @private
     */
    override protected function elementBoundsAboveScrollRect(scrollRect:Rectangle):Rectangle
    {
        var bounds:Rectangle = new Rectangle();
        // Find the row that spans or is above the scrollRect top edge
        var row:int = Math.floor((scrollRect.top - 1) / (_rowHeight + _verticalGap));
        bounds.top = topEdge(row);
        bounds.bottom = bottomEdge(row);
        return bounds;
    }

    /**
     *  @private
     */
    override protected function elementBoundsBelowScrollRect(scrollRect:Rectangle):Rectangle
    {
        var bounds:Rectangle = new Rectangle();
        // Find the row that spans or is below the scrollRect bottom edge
        var row:int = Math.floor((scrollRect.bottom + 1 + _verticalGap) / (_rowHeight + _verticalGap));
        bounds.top = topEdge(row);
        bounds.bottom = bottomEdge(row);
        return bounds;
    }
}
}
