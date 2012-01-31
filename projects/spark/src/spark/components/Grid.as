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

package spark.components
{
    import flash.display.InteractiveObject;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import mx.collections.ArrayList;
    import mx.collections.IList;
    import mx.core.IFactory;
    import mx.core.IVisualElement;
    import mx.core.UIComponent;
    import mx.core.mx_internal;
    import mx.events.CollectionEvent;
    import mx.events.CollectionEventKind;
    import mx.events.FlexEvent;
    import mx.utils.ObjectUtil;
    
    import spark.components.supportClasses.CellPosition;
    import spark.components.supportClasses.GridColumn;
    import spark.components.supportClasses.GridDimensions;
    import spark.components.supportClasses.GridLayout;
    import spark.components.supportClasses.GridSelection;
    import spark.components.supportClasses.GridSelectionMode;
    import spark.events.GridCaretEvent;
    import spark.events.GridEvent;
    import spark.utils.MouseEventUtil;
    
    use namespace mx_internal;
    
    //--------------------------------------
    //  Events
    //--------------------------------------
    
    /**
     *  Dispatched when the mouse button is pressed over a Grid cell.
     *
     *  @eventType spark.events.GridEvent.GRID_MOUSE_DOWN
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    [Event(name="gridMouseDown", type="spark.events.GridEvent")]
    
    
    /**
     *  Dispatched after a GRID_MOUSE_DOWN event if the mouse moves before the button is released.
     *
     *  @eventType spark.events.GridEvent.GRID_MOUSE_DRAG
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    [Event(name="gridMouseDrag", type="spark.events.GridEvent")]
    
    /**
     *  Dispatched after a GRID_MOUSE_DOWN event when the mouse button is released, even
     *  if the mouse is no longer within the Grid.
     *
     *  @eventType spark.events.GridEvent.GRID_MOUSE_UP
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    [Event(name="gridMouseUp", type="spark.events.GridEvent")]
    
    /**
     *  Dispatched when the mouse enters a grid cell.
     *
     *  @eventType spark.events.GridEvent.GRID_ROLL_OVER
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    [Event(name="gridRollOver", type="spark.events.GridEvent")]
    
    /**
     *  Dispatched when the mouse leaves a grid cell.
     *
     *  @eventType spark.events.GridEvent.GRID_ROLL_OUT
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    [Event(name="gridRollOut", type="spark.events.GridEvent")]
    
    /**
     *  Dispatched when the mouse is clicked over a cell
     *
     *  @eventType spark.events.GridEvent.GRID_CLICK
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    [Event(name="gridClick", type="spark.events.GridEvent")]
    
    /**
     *  Dispatched when the mouse is double-clicked over a cell
     *
     *  @eventType spark.events.GridEvent.GRID_DOUBLE_CLICK
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    [Event(name="gridDoubleClick", type="spark.events.GridEvent")]
    
    /**
     *  Dispatched after the caret has changed.  
     *
     *  @eventType spark.events.GridCaretEvent.CARET_CHANGE
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    [Event(name="caretChange", type="spark.events.GridCaretEvent")]
    
    /**
     *  Grid is a Spark component that displays a list of data items called
     *  its <i>dataProvider</i> in a scrollable table or "grid", one item per
     *  row.  Each of the grid's columns, defined by a <code>GridColumn</code>
     *  object, displays a value based on the item for the corresponding row.
     *  The grid's dataProvider is mutable, dataProvider items can be added or
     *  removed, or changed.  Similarly the Grid's list of columns is mutable.
     * 
     *  <p>The Grid component is intended to be used as a DataGrid skin part, or
     *  as an element of other custom composite components.  As such it is not
     *  skinnable, it does not include a scroller or scrollbars, and it does
     *  not provide default mouse or keyboard event handling.  Its role is
     *  similar to DataGroup, the workhorse skin part for the Spark List.</p>
     * 
     *  <p>Each visible Grid <i>cell</i> is displayed by a <code>GridItemRenderer</code>
     *  instance created using the <code>itemRenderer</code> factory.  One
     *  item renderer (factory) is specified for each column and, before it's
     *  displayed, each item renderer instance is configured with the value of
     *  the dataProvider item for that row, and its row and column indices.
     *  Item renderers are created as needed and then, to keep creation
     *  overhead to a minimum, pooled and "recycled".</p>
     * 
     *  <p>Grids support selection, according the <code>selectionMode</code>
     *  property.  The set of selected row or cell indices can be modified or
     *  queried programatically using the selection methods like
     *  <code>setSelectedIndex</code> or <code>selectionContainsIndex()</code>.</p>
     * 
     *  <p>Grids display hover, caret, and selection <i>indicators</i> per the
     *  selectionMode and the corresponding row,columnIndex properties like
     *  <code>hoverRowIndex</code> and <code>columnRowIndex</code>.  An
     *  indicator can be any visual element.  Indicators that implement IGridElement
     *  can configure themselves according to the row and column they're
     *  displayed on.</p>
     * 
     *  <p>Grids support smooth scrolling.  Their vertical and horizontal
     *  scroll positions define the pixel origin of the visible part of the
     *  grid and the grid's layout only displays as many cell item renderers
     *  as are needed to fill the available space.  Grids support variable
     *  height rows that automatically compute their height based on the item
     *  renderers' contents.  This support is called grid "virtualization"
     *  because the mapping from (pixel) scroll positions to row and column indices
     *  is typically based on incomplete information about the preferred sizes 
     *  for grid cells.  The Grid caches the computed heights of rows that have been
     *  scrolled into view and estimates the rest based on a single 
     *  <code>typicalItem</code>.</p>
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public class Grid extends Group
    {
        include "../core/Version.as";
        
        public var backgroundGroup:Group;
        public var selectionGroup:Group;    
        public var itemRendererGroup:Group;
        public var overlayGroup:Group;
        
        private var inUpdateDisplayList:Boolean = false;
        
        public function Grid()
        {
            super();
            layout = new GridLayout();
            
            backgroundGroup = new Group();
            backgroundGroup.layout = new NullLayout();
            addElement(backgroundGroup);
            
            selectionGroup = new Group();
            selectionGroup.layout = new NullLayout();
            addElement(selectionGroup);
            
            itemRendererGroup = this;  
            
            overlayGroup = new Group();
            overlayGroup.layout = new NullLayout();
            addElement(overlayGroup);        
            
            MouseEventUtil.addDownDragUpListeners(this, 
                grid_mouseDownDragUpHandler, 
                grid_mouseDownDragUpHandler, 
                grid_mouseDownDragUpHandler);
            addEventListener(MouseEvent.MOUSE_MOVE, grid_mouseMoveHandler);
            addEventListener(MouseEvent.ROLL_OUT, grid_mouseRollOutHandler);
            addEventListener(MouseEvent.CLICK, grid_clickHandler);
            addEventListener(MouseEvent.DOUBLE_CLICK, grid_doubleClickHandler);        
        }
        
        private function get gridLayout():GridLayout
        {
            return layout as GridLayout;
        }
        
        //--------------------------------------------------------------------------
        //
        //  Properties
        //
        //--------------------------------------------------------------------------
        
        /**
         *  @private
         */
        private function dispatchChangeEvent(type:String):void
        {
            if (hasEventListener(type))
                dispatchEvent(new Event(type));
        }
        
        /**
         *  @private
         */
        private function dispatchFlexEvent(type:String):void
        {
            if (hasEventListener(type))
                dispatchEvent(new FlexEvent(type));
        }
        
        //----------------------------------
        //  anchorColumnIndex
        //----------------------------------
        
        [Bindable("anchorColumnIndexChanged")]
        
        private var _anchorColumnIndex:int = 0;
        
        /**
         *  The column index of the "anchor" for the next shift selection.
         *  Grid event handlers should use this property to record the
         *  location of the most recent unshifted mouse down or keyboard
         *  event that defines one end of the next potential shift
         *  selection.  The caret index defines the other end.
         * 
         *  @default 0
         * 
         *  @see spark.components.Grid#caretRowIndex
         *  @see spark.components.Grid#caretColumnIndex
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5 
         */
        public function get anchorColumnIndex():int
        {
            return _anchorColumnIndex;
        }
        
        /**
         *  @private
         */
        public function set anchorColumnIndex(value:int):void
        {
            if (_anchorColumnIndex == value || 
                selectionMode == GridSelectionMode.SINGLE_ROW || 
                selectionMode == GridSelectionMode.MULTIPLE_ROWS)
            {
                return;
            }
            
            _anchorColumnIndex = value;
            dispatchChangeEvent("anchorColumnIndexChanged");
        }
        
        
        //----------------------------------
        //  anchorRowIndex
        //----------------------------------
        
        [Bindable("anchorRowIndexChanged")]
        
        private var _anchorRowIndex:int = 0; 
        
        /**
         *  The row index of the "anchor" for the next shift selection.
         *  Grid event handlers should use this property to record the
         *  location of the most recent unshifted mouse down or keyboard
         *  event that defines one end of the next potential shift
         *  selection.  The caret index defines the other end.
         * 
         *  @default 0
         *
         *  @see spark.components.Grid#caretRowIndex
         *  @see spark.components.Grid#caretColumnIndex
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5 
         */
        public function get anchorRowIndex():int
        {
            return _anchorRowIndex;
        }
        
        /**
         *  @private
         */
        public function set anchorRowIndex(value:int):void
        {
            if (_anchorRowIndex == value)
                return;
            
            _anchorRowIndex = value;
            dispatchChangeEvent("anchorRowIndexChanged");
        }
        
        //----------------------------------
        //  caretIndicator
        //----------------------------------
        
        [Bindable("caretIndicatorChanged")]
        
        private var _caretIndicator:IFactory = null;
        
        /**
         *  A single visual element that's displayed for the caret row, if
         *  selectionMode is <code>GridSelectionMode.SINGLE_ROW</code> or
         *  <code>GridSelectionMode.MULTIPLE_ROWS</code>, or for the caret
         *  cell, if selectionMode is
         *  <code>GridSelectionMode.SINGLE_CELL</code> or
         *  <code>GridSelectionMode.MULTIPLE_CELLS</code>.
         *  
         *  @default null
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4.5
         */
        public function get caretIndicator():IFactory
        {
            return _caretIndicator;
        }
        
        /**
         *  @private
         */
        public function set caretIndicator(value:IFactory):void
        {
            if (_caretIndicator == value)
                return;
            
            _caretIndicator = value;
            dispatchChangeEvent("caretIndicatorChanged");
        }    
        
        //----------------------------------
        //  caretColumnIndex
        //----------------------------------
        
        [Bindable("caretColumnIndexChanged")]
        
        private var _caretColumnIndex:int = -1;
        private var _oldCaretColumnIndex:int = -1;
        
        private var caretChanged:Boolean = false;
        
        /**
         *  The column index of the caretIndicator visualElement if
         *  <code>showCaretIndicator</code> is true.  If selectionMode is
         *  <code>GridSelectionMode.SINGLE_ROW</code> or
         *  <code>GridSelectionMode.MULTIPLE_ROWS</code> then the indicator
         *  occupies the entire row and caretColumnIndex is ignored.  If
         *  selectionMode is <code>GridSelectionMode.SINGLE_CELL</code> or
         *  <code>GridSelectionMode.MULTIPLE_CELLS</code> then the caretIndicator
         *  occupies the specified cell.
         * 
         *  <p>Setting caretColumnIndex to -1 means that the column index is undefined and 
         *  a cell caret will not be shown.</p>
         * 
         *  @default -1
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5 
         */
        public function get caretColumnIndex():int
        {
            return _caretColumnIndex;
        }
        
        /**
         *  @private
         */
        public function set caretColumnIndex(value:int):void
        {
            _oldCaretColumnIndex = _caretColumnIndex;

            if (caretColumnIndex == value)
                return;
            
            // ToDo: why isn't there any validation being done on value?
            
            _caretColumnIndex = value;
            
            caretChanged = true;
            invalidateProperties();
            
            if (caretIndicator)
                invalidateDisplayList();         
            dispatchChangeEvent("caretColumnIndexChanged");
        }
        
        
        //----------------------------------
        //  caretRowIndex
        //----------------------------------
        
        [Bindable("caretRowIndexChanged")]
        
        private var _caretRowIndex:int = -1;
        private var _oldCaretRowIndex:int = -1;
        
        /**
         *  The row index of the caretIndicator visualElement if
         *  <code>showCaretIndicator</code> is true.  If selectionMode is
         *  <code>GridSelectionMode.SINGLE_ROW</code> or
         *  <code>GridSelectionMode.MULTIPLE_ROWS</code> then the indicator
         *  occupies the entire row and caretColumnIndex is ignored.  If
         *  selectionMode is <code>GridSelectionMode.SINGLE_CELL</code> or
         *  <code>GridSelectionMode.MULTIPLE_CELLS</code> then the caretIndicator
         *  occupies the specified cell.
         * 
         *  <p>Setting caretRowIndex to -1 means that the row index is undefined and 
         *  the caret will not be shown.</p>
         * 
         *  @default -1
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5 
         */
        public function get caretRowIndex():int
        {
            return _caretRowIndex;
        }
        
        /**
         *  @private
         */
        public function set caretRowIndex(value:int):void
        {
            _oldCaretRowIndex = _caretRowIndex;

            if (_caretRowIndex == value)
                return;
            
            // ToDo: why isn't there any validation being done on value?

            _caretRowIndex = value;
            
            caretChanged = true;
            invalidateProperties();
            
            if (caretIndicator)
                invalidateDisplayList();         
            dispatchChangeEvent("caretRowIndexChanged");
        }
        
        //----------------------------------
        //  hoverIndicator
        //----------------------------------
        
        [Bindable("hoverIndicatorChanged")]
        
        private var _hoverIndicator:IFactory = null;
        
        /**
         *  A single visual element that's displayed for the row under the
         *  mouse, if selectionMode is
         *  <code>GridSelectionMode.SINGLE_ROW</code>, or
         *  <code>GridSelectionMode.MULTIPLE_ROWS</code>, or for the caret
         *  cell, if selectionMode is
         *  <code>GridSelectionMode.SINGLE_CELL</code> or
         *  <code>GridSelectionMode.MULTIPLE_CELLS</code>.
         * 
         *  @default null
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4.5
         */
        public function get hoverIndicator():IFactory
        {
            return _hoverIndicator;
        }
        
        /**
         *  @private
         */
        public function set hoverIndicator(value:IFactory):void
        {
            if (_hoverIndicator == value)
                return;
            
            _hoverIndicator = value;
            dispatchChangeEvent("hoverIndicatorChanged");
        }    
        
        //----------------------------------
        //  hoverColumnIndex 
        //----------------------------------
        
        [Bindable("hoverColumnIndexChanged")]
        
        private var _hoverColumnIndex:int = -1;
        
        /**
         *  Specifies column index of the hoverIndicator visualElement if
         *  <code>showHoverIndicator</code> is true.  If selectionMode is
         *  <code>GridSelectionMode.SINGLE_ROW</code> or
         *  <code>GridSelectionMode.MULTIPLE_ROWS</code> then the indicator
         *  occupies the entire row and hoverColumnIndex is ignored.  If
         *  selectionMode is <code>GridSelectionMode.SINGLE_CELL</code> or
         *  <code>GridSelectionMode.MULTIPLE_CELLS</code> then the hoverIndicator
         *  occupies the specified cell.
         *  
         *  <p>Setting hoverColumnIndex to -1 (the default) means that the column index
         *  is undefined and a cell hover indicator will not be displayed.</p>
         * 
         *  @default -1
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5 
         */
        public function get hoverColumnIndex():int
        {
            return _hoverColumnIndex;
        }
        
        /**
         *  @private
         */
        public function set hoverColumnIndex(value:int):void
        {
            if (_hoverColumnIndex == value)
                return;
            
            _hoverColumnIndex = value;
            if (hoverIndicator)
                invalidateDisplayList();         
            dispatchChangeEvent("hoverColumnIndexChanged");
        }
        
        
        //----------------------------------
        //  hoverRowIndex
        //----------------------------------
        
        [Bindable("hoverRowIndexChanged")]
        
        private var _hoverRowIndex:int = -1;
        
        /**
         *  Specifies column index of the hoverIndicator visualElement if
         *  <code>showHoverIndicator</code> is true.  If selectionMode is
         *  <code>GridSelectionMode.SINGLE_ROW</code> or
         *  <code>GridSelectionMode.MULTIPLE_ROWS</code> then the indicator
         *  occupies the entire row and hoverColumnIndex is ignored.  If
         *  selectionMode is <code>GridSelectionMode.SINGLE_CELL</code> or
         *  <code>GridSelectionMode.MULTIPLE_CELLS</code> then the hoverIndicator
         *  occupies the specified cell.
         * 
         *  <p>Setting hoverRowIndex to -1 (the default) means that the row index
         *  is undefined and a hover indicator will not be displayed.</p>
         * 
         *  @default -1
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5 
         */
        public function get hoverRowIndex():int
        {
            return _hoverRowIndex;
        }
        
        /**
         *  @private
         */
        public function set hoverRowIndex(value:int):void
        {
            if (_hoverRowIndex == value)
                return;
            
            _hoverRowIndex = value;
            if (hoverIndicator)
                invalidateDisplayList();           
            dispatchChangeEvent("hoverRowIndexChanged");
        }
        
        //----------------------------------
        //  columns
        //----------------------------------    
        
        private var _columns:IList = null; // list of GridColumns
        private var columnsChanged:Boolean = false;
        
        [Bindable("columnsChanged")]
        
        /**
         *  The list of GridColumns displayed by this grid.  Each column
         *  selects different dataProvider item properties to display in grid <i>cells</i>.
         *  
         *  <p>GridColumn objects can only appear in one columns list.</p> 
         *  
         *  @default null
         * 
         *  @see spark.components.Grid#dataProvider
         */
        public function get columns():IList
        {
            return _columns;
        }
        
        /**
         *  @private
         */
        public function set columns(value:IList):void
        {
            if (_columns == value)
                return;
            
            // Remove the old column listener, and set each column's grid=null, columnIndex=-1.
            
            const oldColumns:IList = _columns;
            if (oldColumns)
            {
                oldColumns.removeEventListener(CollectionEvent.COLLECTION_CHANGE, columns_collectionChangeHandler);
                for (var index:int = 0; index < oldColumns.length; index++)
                {
                    var oldColumn:GridColumn = GridColumn(oldColumns.getItemAt(index));
                    oldColumn.setGrid(null);
                    oldColumn.setColumnIndex(-1);
                }
            }
            
            _columns = value; 
            
            // Add the new columns listener, and set their grid,columnIndex properties.
            // The listener is a local method, so creating a weak reference to it (last 
            // addEventListener parameter) is safe, since the listener's lifetime is the 
            // same as this object.        
            
            const newColumns:IList = _columns;
            if (newColumns)
            {
                newColumns.addEventListener(CollectionEvent.COLLECTION_CHANGE, columns_collectionChangeHandler, false, 0, true);            
                for (index = 0; index < newColumns.length; index++)
                {
                    var newColumn:GridColumn = GridColumn(newColumns.getItemAt(index));
                    newColumn.setGrid(this);
                    newColumn.setColumnIndex(index);
                }
            }
            
            // Reset the cursor here so that if it is set before commitProperties
            // is run the change isn't wiped out.
            caretRowIndex = caretColumnIndex = -1;
            
            columnsChanged = true;
            invalidateProperties();
            invalidateSize();
            invalidateDisplayList();
            
            dispatchChangeEvent("columnsChanged");             
        }
        
        /**
         *  @private
         */
        private function getColumnsLength():uint
        {
            const columns:IList = columns;
            return (columns) ? columns.length : 0;
        }
        
        /**
         *  @private
         */
        private function generateColumns():IList
        {
            var item:Object = typicalItem;
            if (!item && dataProvider && (dataProvider.length > 0))
                item = dataProvider.getItemAt(0);
            
            var itemColumns:IList = null;
            if (item)
            {
                itemColumns = new ArrayList();
                const classInfo:Object = ObjectUtil.getClassInfo(item);
                if (classInfo)
                {
                    for each (var property:QName in classInfo.properties)
                    {
                        var column:GridColumn = new GridColumn();
                        column.dataField = property.localName;
                        itemColumns.addItem(column);                        
                    }
                }
            }
            
            return itemColumns;
        }
       
        
        //----------------------------------
        //  dataProvider
        //----------------------------------
        
        private var _dataProvider:IList = null;
        private var dataProviderChanged:Boolean;
        
        [Bindable("dataProviderChanged")]
        
        /**
         *  A list of <i>items</i> that correspond to the rows in the grid.   The grid's <i>columns</i>
         *  select different item properties to display in grid <i>cells</i>.
         * 
         *  @default null
         * 
         *  @see spark.components.Grid#columns
         */
        public function get dataProvider():IList
        {
            return _dataProvider;
        }
        
        /**
         *  @private
         */
        public function set dataProvider(value:IList):void
        {
            if (_dataProvider == value)
                return;
            
            const oldDataProvider:IList = dataProvider;
            if (oldDataProvider)
                oldDataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, dataProvider_collectionChangeHandler);
            
            _dataProvider = value;
            
            // The listener is a local method, so creating a weak reference to it (last addEventListener 
            // parameter) is safe, since the listener's lifetime is the same as this object.
            
            const newDataProvider:IList = dataProvider;
            if (newDataProvider)
                newDataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, dataProvider_collectionChangeHandler, false, 0, true);        
            
            // Reset the cursor here so that if it is set before commitProperties
            // is run the change isn't wiped out.
            caretRowIndex = caretColumnIndex = -1;
            
            dataProviderChanged = true;
            invalidateProperties();
            invalidateSize();
            invalidateDisplayList();
            
            dispatchChangeEvent("dataProviderChanged");        
        }
        
        //----------------------------------
        //  itemRenderer
        //----------------------------------
        
        [Bindable("itemRendererChanged")]
        
        private var _itemRenderer:IFactory = null;
        
        /**
         *  The item renderer that's used for columns that do not specify one.
         * 
         *  @default null
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4.5 
         */
        public function get itemRenderer():IFactory
        {
            return _itemRenderer;
        }
        
        /**
         *  @private
         */
        public function set itemRenderer(value:IFactory):void
        {
            if (_itemRenderer == value)
                return;
            
            _itemRenderer = value;
            
            invalidateSize();
            invalidateDisplayList();
            dispatchChangeEvent("itemRendererChanged");
        }    
        
        //----------------------------------
        //  columnSeparator
        //----------------------------------
        
        [Bindable("columnSeparatorChanged")]
        
        private var _columnSeparator:IFactory = null;
        
        /**
         *  A visual element that's displayed in between each column.
         * 
         *  @default null
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4.5
         */
        public function get columnSeparator():IFactory
        {
            return _columnSeparator;
        }
        
        /**
         *  @private
         */
        public function set columnSeparator(value:IFactory):void
        {
            if (_columnSeparator == value)
                return;
            
            _columnSeparator = value;
            dispatchChangeEvent("columnSeparatorChanged");
        }    
        
        //----------------------------------
        //  gridSelection (mx_internal)
        //----------------------------------
        
        private var _gridSelection:GridSelection;
        
        /**
         *  @private
         */
        mx_internal function get gridSelection():GridSelection
        {
            return _gridSelection;
        }
        
        /**
         *  @private
         *  This value is created by DataGrid/partAdded() and then set here.   It is only
         *  set once, unless that "grid" part is removed, at which point it's set to null.
         */
        mx_internal function set gridSelection(value:GridSelection):void
        {
            _gridSelection = value;
        }
        
        
        //----------------------------------
        //  gridDimensions (mx_internal)
        //----------------------------------
        
        private var _gridDimensions:GridDimensions;
        
        /**
         *  @private
         */
        mx_internal function get gridDimensions():GridDimensions
        {
            return _gridDimensions;
        }
        
        /**
         *  @private
         *  This value is created by DataGrid/partAdded() and then set here.   It is only
         *  set once, unless that "grid" part is removed, at which point it's set to null.
         */
        mx_internal function set gridDimensions(value:GridDimensions):void
        {
            _gridDimensions = value;
        }
        
        //----------------------------------
        //  owner
        //----------------------------------
        
        private var _gridOwner:IGridItemRendererOwner;
        
        /**
         *  @private
         *  TODO (jszeto) Should we just use owner instead of creating a new property?
         */
        public function get gridOwner():IGridItemRendererOwner
        {
            return _gridOwner;
        }
        
        /**
         *  @private
         */
        public function set gridOwner(value:IGridItemRendererOwner):void
        {
            _gridOwner = value;
        }
        
        
        //----------------------------------
        //  preserveSelection (delegates to gridSelection.preserveSelection)
        //----------------------------------
        
        /**
         *  @copy spark.components.supportClasses.GridSelection#preserveSelection
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */
        public function get preserveSelection():Boolean
        {
            return gridSelection.preserveSelection;
        }
        
        /**
         *  @private
         */    
        public function set preserveSelection(value:Boolean):void
        {
            gridSelection.preserveSelection = value;
        }
        
        
        //----------------------------------
        //  requestedMinRowCount
        //----------------------------------
        
        private var _requestedMinRowCount:int = -1;
        
        [Inspectable(category="General", minValue="-1")]
        
        /**
         *  The measured height of this grid will be large enough to display 
         *  at least <code>requestedMinRowCount</code> rows.
         * 
         *  <p>If <code>requestedRowCount</code> is set, then
         *  this property has no effect.</p>
         *
         *  <p>If the actual size of the grid has been explicitly set,
         *  then this property has no effect.</p>
         *
         *  @default -1
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4.5
         */
        public function get requestedMinRowCount():int
        {
            return _requestedMinRowCount;
        }
        
        /**
         *  @private
         */
        public function set requestedMinRowCount(value:int):void
        {
            if (_requestedMinRowCount == value)
                return;
            
            _requestedMinRowCount = value;
            invalidateSize();
        }    
        
        //----------------------------------
        //  requestedRowCount
        //----------------------------------
        
        private var _requestedRowCount:int = -1;
        
        [Inspectable(category="General", minValue="-1")]
        
        /**
         *  The measured height of this grid will be large enough to display 
         *  the first <code>requestedRowCount</code> rows. 
         * 
         *  <p>If <code>requestedRowCount</code> is -1, then the measured
         *  size will be big enough for all of the layout elements.</p>
         * 
         *  <p>If the actual size of the grid has been explicitly set,
         *  then this property has no effect.</p>
         * 
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
            invalidateSize();
        }
        
        
        //----------------------------------
        //  requestedMinColumnCount
        //----------------------------------
        
        private var _requestedMinColumnCount:int = -1;
        
        [Inspectable(category="General", minValue="-1")]
        
        /**
         *  The measured width of this grid will be large enough to display 
         *  at least <code>requestedMinColumnCount</code> columns.
         * 
         *  <p>If <code>requestedColumnCount</code> is set, then
         *  this property has no effect.</p>
         *
         *  <p>If the actual size of the grid has been explicitly set,
         *  then this property has no effect.</p>
         * 
         *  @default -1
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4.5
         */
        public function get requestedMinColumnCount():int
        {
            return _requestedMinColumnCount;
        }
        
        /**
         *  @private
         */
        public function set requestedMinColumnCount(value:int):void
        {
            if (_requestedMinColumnCount == value)
                return;
            
            _requestedMinColumnCount = value;
            invalidateSize();
        }   
        
        //----------------------------------
        //  requestedColumnCount
        //----------------------------------
        
        private var _requestedColumnCount:int = -1;
        
        [Inspectable(category="General", minValue="-1")]
        
        /**
         *  The measured width of this grid will be large enough to display 
         *  the first <code>requestedColumnCount</code> columns. 
         *  If <code>requestedColumnCount</code> is -1, then the measured
         *  width will be big enough for all of the columns.
         * 
         *  <p>If the actual size of the grid has been explicitly set,
         *  then this property has no effect.</p>
         * 
         *  @default -1
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4.5
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
            invalidateSize();
        }    
        
        //----------------------------------
        //  requireSelection
        //----------------------------------
        
        /**
         *  If <code>true</code> and the <code>selectionMode</code> is not 
         *  <code>GridSelectionMode.NONE</code>, an item must always be selected 
         *  in the grid.
         *
         *  @default false
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */
        public function get requireSelection():Boolean
        {
            return gridSelection.requireSelection;
        }
        
        /**
         *  @private
         */    
        public function set requireSelection(value:Boolean):void
        {
            gridSelection.requireSelection = value;
            
            if (value)
                invalidateDisplayList();
        }
 
        //----------------------------------
        //  resizableColumns
        //----------------------------------
        
        /**
         *  A flag that indicates whether the user can change the size of the
         *  columns.
         *  If <code>true</code>, the user can stretch or shrink the columns of 
         *  the DataGrid control by dragging the grid lines between the header cells.
         *  If <code>true</code>, individual columns must also have their 
         *  <code>resizable</code> properties set to <code>false</code> to 
         *  prevent the user from resizing a particular column.  
         *
         *  @default true
         *    
         *  @see spark.components.supportClasses.GridColumn
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public var resizableColumns:Boolean = true;
                        
        //----------------------------------
        //  rowBackground
        //----------------------------------
        
        [Bindable("rowBackgroundChanged")]
        
        private var _rowBackground:IFactory = null;
        
        /**
         *  A visual element that's displayed for each row.  
         * 
         *  @default null
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4.5
         */
        public function get rowBackground():IFactory
        {
            return _rowBackground;
        }
        
        /**
         *  @private
         */
        public function set rowBackground(value:IFactory):void
        {
            if (_rowBackground == value)
                return;
            
            _rowBackground = value;
            dispatchChangeEvent("rowBackgroundChanged");
        }
        
        //----------------------------------
        //  rowHeight
        //----------------------------------
        
        [Inspectable(category="General", minValue="0.0")]        
        
        [Bindable("rowBackgroundChanged")]
        
        private var _rowHeight:Number = NaN;      
        
        /**
         *  If <code>variableRowHeight</code> is <code>false</code>, then 
         *  this property specifies the actual height of each row, in pixels.
         * 
         *  <p>If <code>variableRowHeight</code> is <code>true</code>, 
         *  the default, then this property has no effect.</p>
         * 
         *  <p>If <code>variableRowHeight</code> is <code>false</code>, 
         *  the default value of this property is the maximum preferred height
         *  of the per-column renderers created for the typicalItem.</p>
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4.5
         */
        public function get rowHeight():Number
        {
            return (variableRowHeight) ? gridDimensions.defaultRowHeight : gridDimensions.fixedRowHeight;
        }
        
        /**
         *  @private
         */
        public function set rowHeight(value:Number):void
        {
            if (_rowHeight == value)
                return;
            
            _rowHeight = value;
            if (variableRowHeight)
                gridDimensions.defaultRowHeight = value;
            else
                gridDimensions.fixedRowHeight = value;
            
            invalidateSize();
            invalidateDisplayList();
            dispatchChangeEvent("rowHeightChanged");            
        }
        
        
        //----------------------------------
        //  rowSeparator
        //----------------------------------
        
        [Bindable("rowSeparatorChanged")]
        
        private var _rowSeparator:IFactory = null;
        
        /**
         *  A visual element that's displayed in between each row.
         * 
         *  @default null
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4.5
         */
        public function get rowSeparator():IFactory
        {
            return _rowSeparator;
        }
        
        /**
         *  @private
         */
        public function set rowSeparator(value:IFactory):void
        {
            if (_rowSeparator == value)
                return;
            
            _rowSeparator = value;
            dispatchChangeEvent("rowSeparatorChanged");
        }    
        
        //----------------------------------
        //  selectedCell
        //----------------------------------
        
        [Bindable("selectionChange")]
        [Bindable("valueCommit")]

        /**
         *  If <code>selectionMode</code> is <code>GridSelectionMode.SINGLE_CELL</code> 
         *  or <code>GridSelectionMode.MULTIPLE_CELLS</code>, returns the first
         *  selected cell starting at row 0 column 0 and progressing thru each
         *  column in a row before moving to the next row.
         * 
         *  <p>When the user changes the selection by interacting with the 
         *  control, the control dispatches the <code>selectionChange</code> 
         *  event. When the user changes the selection programmatically, the 
         *  control dispatches the <code>valueCommit</code> event.</p>
         *
         *  @default null
         * 
         *  @return CellPosition of the first selected cell or null if there is
         *  no cell selection.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */
        public function get selectedCell():CellPosition
        {
            var selectedCells:Vector.<CellPosition> = gridSelection.allCells();
            return selectedCells.length ? selectedCells[0] : null;
        }
                       
        //----------------------------------
        //  selectedCells
        //----------------------------------
        
        [Bindable("selectionChange")]
        [Bindable("valueCommit")]

        /**
         *  If <code>selectionMode</code> is <code>GridSelectionMode.SINGLE_CELL</code> 
         *  or <code>GridSelectionMode.MULTIPLE_CELLS</code>, returns a Vector
         *  of CellPosition objects representing the positions of the selected
         *  cells in the grid.
         * 
         *  <p>When the user changes the selection by interacting with the 
         *  control, the control dispatches the <code>selectionChange</code> 
         *  event. When the user changes the selection programmatically, the 
         *  control dispatches the <code>valueCommit</code> event.</p>
         * 
         *  @default []
         * 
         *  @return Vector of CellPosition objects where each element represents
         *  a selected cell.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */
        public function get selectedCells():Vector.<CellPosition>
        {
            return gridSelection.allCells();
        }

        //----------------------------------
        //  selectedIndex
        //----------------------------------
        
        [Bindable("selectionChange")]
        [Bindable("valueCommit")]

        /**
         *  If <code>selectionMode</code> is <code>GridSelectionMode.SINGLE_ROW</code> 
         *  or <code>GridSelectionMode.MULTIPLE_ROWS</code>, returns the
         *  rowIndex of the first selected row. 
         * 
         *  <p>When the user changes the selection by interacting with the 
         *  control, the control dispatches the <code>selectionChange</code> 
         *  event. When the user changes the selection programmatically, the 
         *  control dispatches the <code>valueCommit</code> event.</p>
         *
         *  @default -1
         * 
         *  @return rowIndex of first selected row or -1 if there are no
         *  selected rows.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */
        public function get selectedIndex():int
        {
            var selectedRows:Vector.<int> = gridSelection.allRows();
            return selectedRows.length ? selectedRows[0] : -1;
        }
        
        //----------------------------------
        //  selectedIndices
        //----------------------------------
        
        [Bindable("selectionChange")]
        [Bindable("valueCommit")]

        /**
         *  If <code>selectionMode</code> is <code>GridSelectionMode.SINGLE_ROW</code> 
         *  or <code>GridSelectionMode.MULTIPLE_ROWS</code>, returns a Vector of 
         *  the selected rows indices.  For all other selection modes, this 
         *  method has no effect.
         * 
         *  <p>When the user changes the selection by interacting with the 
         *  control, the control dispatches the <code>selectionChange</code> 
         *  event. When the user changes the selection programmatically, the 
         *  control dispatches the <code>valueCommit</code> event.</p>
         *
         *  @default []
         * 
         *  @return Vector of ints where each element is the index in 
         *  <code>dataProvider</code> of the selected row.
         *  
         *  @see spark.components.Grid#dataProvider
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */
        public function get selectedIndices():Vector.<int>
        {
            return gridSelection.allRows();
        }
        
        //----------------------------------
        //  selectedItem
        //----------------------------------
        
        [Bindable("selectionChange")]
        [Bindable("valueCommit")]
        
        /**
         *  If <code>selectionMode</code> is <code>GridSelectionMode.SINGLE_ROW</code> 
         *  or <code>GridSelectionMode.MULTIPLE_ROWS</code>, returns the 
         *  item in the <code>dataProvider</code> that is currently selected or
         *  <code>undefined</code> if no rows are selected.  
         * 
         *  <p>When the user changes the selection by interacting with the 
         *  control, the control dispatches the <code>selectionChange</code> 
         *  event. When the user changes the selection programmatically, the 
         *  control dispatches the <code>valueCommit</code> event.</p>
         *  @default undefined
         * 
         *  @return Vector of <code>dataProvider</code> items.
         *  
         *  @see spark.components.Grid#dataProvider
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */
        public function get selectedItem():Object
        {
            var rowIndex:int = selectedIndex;
            if (rowIndex == -1)
                return undefined;
            
            return getDataProviderItem(rowIndex);           
        }
        
        //----------------------------------
        //  selectedItems
        //----------------------------------
        
        [Bindable("selectionChange")]
        [Bindable("valueCommit")]

        /**
         *  If <code>selectionMode</code> is <code>GridSelectionMode.SINGLE_ROW</code> 
         *  or <code>GridSelectionMode.MULTIPLE_ROWS</code>, returns a Vector of 
         *  the dataProvider items that are currently selected.
         * 
         *  <p>When the user changes the selection by interacting with the 
         *  control, the control dispatches the <code>selectionChange</code> 
         *  event. When the user changes the selection programmatically, the 
         *  control dispatches the <code>valueCommit</code> event.</p>
         *  @default []
         * 
         *  @return Vector of <code>dataProvider</code> items.
         *  
         *  @see spark.components.Grid#dataProvider
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */
        public function get selectedItems():Vector.<Object>
        {
            var rowIndices:Vector.<int> = selectedIndices;
            if (rowIndices.length == 0)
                return undefined;
            
            var items:Vector.<Object> = new Vector.<Object>();
            
            for each (var rowIndex:int in rowIndices)        
                items.push(dataProvider.getItemAt(rowIndex));
           
            return items;
        }
        
        //----------------------------------
        //  selectionIndicator
        //----------------------------------
        
        [Bindable("selectionIndicatorChanged")]
        
        private var _selectionIndicator:IFactory = null;
        
        /**
         *  A visual element that's displayed for each selected row, if
         *  selectionMode is <code>GridSelectionMode.SINGLE_ROW</code> or
         *  <code>GridSelectionMode.MULTIPLE_ROWS</code>, or for each
         *  selected cell, if selectionMode is
         *  <code>GridSelectionMode.SINGLE_CELL</code> or
         *  <code>GridSelectionMode.MULTIPLE_CELLS</code>.
         *  
         *  @default null
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4.5
         */
        public function get selectionIndicator():IFactory
        {
            return _selectionIndicator;
        }
        
        /**
         *  @private
         */
        public function set selectionIndicator(value:IFactory):void
        {
            if (_selectionIndicator == value)
                return;
            
            _selectionIndicator = value;
            dispatchChangeEvent("selectionIndicatorChanged");
        }    
        
        //----------------------------------
        //  selectionLength (delegates to gridSelection.selectionLength)
        //----------------------------------
        
        [Bindable("selectionChange")]
        [Bindable("valueCommit")]
        
        /**
         *  If <code>selectionMode</code> is <code>GridSelectionMode.SINGLE_ROW</code>
         *  or <code>GridSelectionMode.MULTIPLE_ROWS</code>, returns the
         *  number of selected rows, and if <code>selectionMode</code> is 
         *  <code>GridSelectionMode.SINGLE_CELLS</code>
         *  or <code>GridSelectionMode.MULTIPLE_CELLS</code>, returns the
         *  number of selected cells.
         * 
         *  @default 0
         * 
         *  @return Number of selected rows or cells.
         *    
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */
        public function get selectionLength():int
        {
            return gridSelection.selectionLength;   
        }
        
        //----------------------------------
        //  selectionMode (delegates to gridSelection.selectionMode)
        //----------------------------------
        
        [Bindable("selectionModeChanged")]
        [Inspectable(category="General", enumeration="none,singleRow,multipleRows,singleCell,multipleCells", defaultValue="singleRow")]
        
        /**
         *  The selection mode of the control.  Possible values are:
         *  <code>GridSelectionMode.MULTIPLE_CELLS</code>, 
         *  <code>GridSelectionMode.MULTIPLE_ROWS</code>, 
         *  <code>GridSelectionMode.NONE</code>, 
         *  <code>GridSelectionMode.SINGLE_CELL</code>, and 
         *  <code>GridSelectionMode.SINGLE_ROW</code>.
         * 
         *  <p>Changing the selectionMode causes the current selection to be 
         *  cleared and the caretRowIndex and caretColumnIndex to be set to -1.</p>
         *
         *  @default GridSelectionMode.SINGLE_ROW
         * 
         *  @see spark.components.supportClasses.GridSelectionMode
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */
        public function get selectionMode():String
        {
            return gridSelection.selectionMode;
        }
        
        /**
         *  @private
         */
        public function set selectionMode(value:String):void
        {
            if (selectionMode == value)
                return;
            
            gridSelection.selectionMode = value;
            if (selectionMode != value) // value wasn't a valid GridSelectionMode constant
                return;
            
            anchorRowIndex = 0;
            anchorColumnIndex = 0;
            if (!requireSelection)
            {
                caretRowIndex = -1;
                caretColumnIndex = -1;
            }
            
            invalidateDisplayList();
            
            dispatchChangeEvent("selectionModeChanged");
        }
        
        //----------------------------------
        //  typicalItem
        //----------------------------------
        
        private var _typicalItem:Object = null;
        
        [Bindable("typicalItemChanged")]
        
        /**
         *  The grid's layout ensures that columns whose width is not specified will be wide
         *  enough to display an item renderer for this default dataProvider item.  If a typical
         *  item is not specified, then the first dataProvider item is used.
         * 
         *  <p>Restriction: if the <code>typicalItem</code> is an IVisualItem, it must not 
         *  also be a member of the data Provider.</p>
         * 
         *  @default null
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4.5
         */
        public function get typicalItem():Object
        {
            return _typicalItem;
        }
        
        /**
         *  @private
         */
        public function set typicalItem(value:Object):void
        {
            if (_typicalItem == value)
                return;
            
            _typicalItem = value;
            gridDimensions.clearTypicalCellWidthsAndHeights();
            
            invalidateSize();
            invalidateDisplayList();
			dispatchChangeEvent("typicalItemChanged");
        }
        
        //----------------------------------
        //  variableRowHeight
        //----------------------------------
        
        [Bindable("variableRowHeightChanged")]        
        
        /**
         *  If true, each row's height is the maximum of preferred heights of the cells displayed so far.
         * 
         *  <p>If <code>false</code>, the height of each row is just the value of <code>rowHeight</code>.</p>
         * 
         *  @default true
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4.5
         */
        public function get variableRowHeight():Boolean
        {
            return isNaN(gridDimensions.fixedRowHeight);
        }
        
        /**
         *  @private
         */        
        public function set variableRowHeight(value:Boolean):void
        {
            if (value == variableRowHeight)
                return;
            
            gridDimensions.fixedRowHeight = (value) ? NaN : rowHeight;
            
            invalidateSize();
            invalidateDisplayList();
            dispatchChangeEvent("variableRowHeightChanged");            
        }
        
        
        //--------------------------------------------------------------------------
        //
        //  GridSelection Cover Methods
        //
        //--------------------------------------------------------------------------
        
        /**
         *  If <code>selectionMode</code> is 
         *  <code>GridSelectionMode.MULTIPLE_ROWS</code>, selects all rows and
         *  removes the caret or if <code>selectionMode</code> is 
         *  <code>GridSelectionMode.MULTIPLE_CELLS</code> selects all cells  
         *  and removes the caret.  For all other selection modes, this method 
         *  has no effect.
         *
         *  <p>If items are added to the <code>dataProvider</code> or 
         *  <code>columns</code> are added after this method is called, the
         *  new rows or cells in the new column will be selected.</p>
         * 
         *  <p>This implicit "selectAll" mode ends when any of the following occur:
         *  <ul>
         *    <li>selection is cleared using <code>clearSelection</code></li>
         *    <li>selection reset using one of <code>setSelectedCell</code>, 
         *    <code>setSelectedCells</code>, <code>setSelectedIndex</code>, 
         *    <code>selectIndices</code></li>
         *    <li><code>dataProvider</code> is refreshed and <code>preserveSelection</code> is false</li>
         *    <li><code>dataProvider</code> is reset</li>
         *    <li><code>columns</code> is refreshed, 
         *    <code>preserveSelection</code> is <code>false</code> and 
         *    <code>selectionMode</code> is 
         *    <code>GridSelectionMode.MULTIPLE_CELLS</code></li>
         *    <li><code>columns</code> is reset and <code>selectionMode</code> is 
         *    <code>GridSelectionMode.MULTIPLE_CELLS</code></li> 
         *  </ul></p>
         * 
         *  @return True if the selection changed.
         *    
         *  @see spark.components.Grid#clearSelection
         *  @see spark.components.Grid#selectIndices
         *  @see spark.components.Grid#setSelectedCell
         *  @see spark.components.Grid#setSelectedCells
         *  @see spark.components.Grid#setSelectedIndex
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */
        public function selectAll():Boolean
        {           
            const selectionChanged:Boolean = gridSelection.selectAll();
            if (selectionChanged)
            {               
                // Remove the caret.
                caretRowIndex = -1;
                caretColumnIndex = -1;
                
                invalidateDisplayList()
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
            }
 
            return selectionChanged;
        }
        
        /**
         *  Removes all of the selected rows and cells, if <code>selectionMode</code>  
         *  is not <code>GridSelectionMode.NONE</code>.  Removes the caret and
         *  sets the anchor to the initial item.
         *
         *  @return True if the selection changed or false if there was nothing
         *  previously selected.
         *    
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */
        public function clearSelection():Boolean
        {
            const selectionChanged:Boolean = gridSelection.removeAll();
            if (selectionChanged)
            {
                invalidateDisplayList()
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
            }
            
            // Remove caret and reset the anchor.
            caretRowIndex = -1;
            caretColumnIndex = -1;
            anchorRowIndex = 0;
            anchorColumnIndex = 0;
            
            return selectionChanged;
        }
        
        //----------------------------------
        //  selection for rows
        //----------------------------------    
        
        /**
         *  If <code>selectionMode</code> is <code>GridSelectionMode.SINGLE_ROW</code>
         *  or <code>GridSelectionMode.MULTIPLE_ROWS</code>, returns true if the row 
         *  at <code>index></code> is in the current selection.
         * 
         *  <p>The <code>rowIndex</code> is the index in <code>dataProvider</code> 
         *  of the item containing the selected cell.</p>
         *
         *  @param rowIndex The 0-based row index of the row.
         * 
         *  @return True if the selection contains the row.
         *    
         *  @see spark.components.Grid#dataProvider
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */
        public function selectionContainsIndex(rowIndex:int):Boolean 
        {
            return gridSelection.containsRow(rowIndex);
        }
        
        /**
         *  If <code>selectionMode</code> is 
         *  <code>GridSelectionMode.MULTIPLE_ROWS</code>, returns true if the rows 
         *  in <code>indices</code> are in the current selection.
         * 
         *  @param rowIndices Vector of 0-based row indices to include in selection. 
         * 
         *  @return True if the current selection contains these rows.
         *    
         *  @see spark.components.Grid#dataProvider
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */
        public function selectionContainsIndices(rowIndices:Vector.<int>):Boolean 
        {
            return gridSelection.containsRows(rowIndices);
        }
        
        /**
         *  If <code>selectionMode</code>
         *  is <code>GridSelectionMode.SINGLE_ROW</code> or 
         *  <code>GridSelectionMode.MULTIPLE_ROWS</code>, sets the selection and 
         *  the caret position to this row.
         *  For all other selection modes, this method has no effect.
         * 
         *  <p>The <code>rowIndex</code> is the index in <code>dataProvider</code> 
         *  of the item containing the selected cell.</p>
         *
         *  @param rowIndex The 0-based row index of the cell.
         *
         *  @return True if no errors, or false if <code>index</code> is invalid or
         *  the <code>selectionMode</code> is invalid. 
         *    
         *  @see spark.components.Grid#caretColumnIndex
         *  @see spark.components.Grid#caretRowIndex
         *  @see spark.components.Grid#dataProvider
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */
        public function setSelectedIndex(rowIndex:int):Boolean
        {
            const selectionChanged:Boolean = gridSelection.setRow(rowIndex);
            if (selectionChanged)
            {
                caretRowIndex = rowIndex;
                caretColumnIndex = -1;
                
                invalidateDisplayList()
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
            }
            
            return selectionChanged;
        }
        
        /**
         *  If <code>selectionMode</code>
         *  is <code>GridSelectionMode.MULTIPLE_ROWS</code>, adds this row to
         *  the selection and sets the caret position to this row.
         *  For all other selection modes, this method has no effect.
         * 
         *  <p>The <code>rowIndex</code> is the index in <code>dataProvider</code> 
         *  of the item containing the selected cell.</p>
         *
         *  @param rowIndex The 0-based row index of the cell.
         *
         *  @return True if no errors, or false if <code>index</code> is invalid or
         *  the <code>selectionMode</code> is invalid. 
         *    
         *  @see spark.components.Grid#caretColumnIndex
         *  @see spark.components.Grid#caretRowIndex
         *  @see spark.components.Grid#dataProvider
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */
        public function addSelectedIndex(rowIndex:int):Boolean
        {
            const selectionChanged:Boolean = gridSelection.addRow(rowIndex);
            if (selectionChanged)
            {
                caretRowIndex = rowIndex;
                caretColumnIndex = -1;                

                invalidateDisplayList()
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
            }
            
            return selectionChanged;
        }
        
        /**
         *  If <code>selectionMode</code>
         *  is <code>GridSelectionMode.SINGLE_ROW</code> or 
         *  <code>GridSelectionMode.MULTIPLE_ROWS</code>, removes this row
         *  from the selection and sets the caret position to this row.
         *  For all other selection modes, this method has no effect.
         * 
         *  <p>The <code>rowIndex</code> is the index in <code>dataProvider</code> 
         *  of the item containing the selected cell.</p>
         *
         *  @param rowIndex The 0-based row index of the cell.
         *
         *  @return True if no errors, or false if <code>index</code> is invalid or
         *  the <code>selectionMode</code> is invalid. 
         *       
         *  @see spark.components.Grid#caretColumnIndex
         *  @see spark.components.Grid#caretRowIndex
         *  @see spark.components.Grid#dataProvider
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */
        public function removeSelectedIndex(rowIndex:int):Boolean
        {
            const selectionChanged:Boolean = gridSelection.removeRow(rowIndex);
            if (selectionChanged)
            {
                caretRowIndex = rowIndex;
                caretColumnIndex = -1;
                
                invalidateDisplayList()
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
            }
            
            return selectionChanged;
        }
        
        /**
         *  If <code>selectionMode</code> is <code>GridSelectionMode.MULTIPLE_ROWS</code>,
         *  sets the selection to the specfied rows and the caret position to
         *  <code>endRowIndex</code>.
         *  For all other selection modes, this method has no effect.
         * 
         *  <p>Each index represents an item in <code>dataProvider</code> 
         *  to include in the selection.</p>
         *
         *  @param rowIndex 0-based row index of the first row in the selection.
         *  @param rowCount Number of rows in the selection.
         * 
         *  @return True if no errors, or false if any of the indices are invalid
         *  or <code>startRowIndex</code> is not less than or equal to 
         *  <code>endRowIndex</code> or the <code>selectionMode</code> is invalid. 
         *    
         *  @see spark.components.Grid#dataProvider
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */
        public function selectIndices(rowIndex:int, rowCount:int):Boolean
        {
            const selectionChanged:Boolean = 
                gridSelection.setRows(rowIndex, rowCount);
            if (selectionChanged)
            {
                caretRowIndex = rowIndex + rowCount - 1;
                caretColumnIndex = -1;
                
                invalidateDisplayList()
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
            }
            
            return selectionChanged;
        }

        //----------------------------------
        //  selection for cells
        //----------------------------------    
        
        /**
         *  If <code>selectionMode</code> is <code>GridSelectionMode.SINGLE_CELL</code>
         *  or <code>GridSelectionMode.MULTIPLE_CELLS</code>, returns true if the cell 
         *  is in the current selection.
         * 
         *  <p>The <code>rowIndex</code> must be between 0 and the
         *  length of <code>dataProvider</code>.  The <code>columnIndex</code>
         *  must be between 0 and the length of <code>columns</code>. </p>
         *
         *  @param rowIndex The 0-based row index of the cell.
         *
         *  @param columnIndex The 0-based column index of the cell.
         *  
         *  @return True if the current selection contains the cell.
         * 
         *  @see spark.components.Grid#columns
         *  @see spark.components.Grid#dataProvider
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */
        public function selectionContainsCell(rowIndex:int, columnIndex:int):Boolean
        {
            return gridSelection.containsCell(rowIndex, columnIndex);
        }
        
        /**
         *  If <code>selectionMode</code> is 
         *  <code>GridSelectionMode.MULTIPLE_CELLS</code>, returns true if the cells 
         *  in the cell region are in the current selection.
         * 
         *  <p>The <code>rowIndex</code> must be between 0 and the
         *  length of <code>dataProvider</code>.  The <code>columnIndex</code>
         *  must be between 0 and the length of <code>columns</code>. </p>
         *
         *  @param rowIndex The 0-based row index of the cell.
         *
         *  @param columnIndex The 0-based column index of the cell.
         *  
         *  @param rowCount Number of rows, starting at <code>rowIndex</code> to 
         *  include in the cell region.
         *
         *  @param columnCount Number of columns, starting at 
         *  <code>columnIndex</code> to include in the cell region.
         * 
         *  @return True if the current selection contains all the cells in the cell
         *  region.
         * 
         *  @see spark.components.Grid#columns
         *  @see spark.components.Grid#dataProvider
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */
        public function selectionContainsCellRegion(rowIndex:int, columnIndex:int, 
                                                    rowCount:int, columnCount:int):Boolean
        {
            return gridSelection.containsCellRegion(rowIndex, columnIndex, 
                rowCount, columnCount);
        }
        
        /**
         *  If <code>selectionMode</code>
         *  is <code>GridSelectionMode.SINGLE_CELL</code> or 
         *  <code>GridSelectionMode.MULTIPLE_CELLS</code>, sets the selection
         *  and the caret position to this cell.
         *  For all other selection modes, this method has no effect.
         * 
         *  <p>The <code>rowIndex</code> is the index in <code>dataProvider</code> 
         *  of the item containing the selected cell.  The <code>columnIndex</code>
         *  is the index in <code>columns</code> of the column containing the
         *  selected cell.</p>
         *
         *  @param rowIndex The 0-based row index of the cell.
         *
         *  @param columnIndex The 0-based column index of the cell.
         * 
         *  @return True if no errors, or false if <code>rowIndex</code> 
         *  or <code>columnIndex</code> is invalid or the <code>selectionMode</code> 
         *  is invalid.     
         *  
         *  @see spark.components.Grid#caretColumnIndex
         *  @see spark.components.Grid#caretRowIndex
         *  @see spark.components.Grid#columns
         *  @see spark.components.Grid#dataProvider
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */
        public function setSelectedCell(rowIndex:int, columnIndex:int):Boolean
        {
            const selectionChanged:Boolean = gridSelection.setCell(rowIndex, columnIndex);
            if (selectionChanged)
            {
                caretRowIndex = rowIndex;
                caretColumnIndex = columnIndex;
                
                invalidateDisplayList()
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
            }
            
            return selectionChanged;
        }
        
        /**
         *  If <code>selectionMode</code>
         *  is <code>GridSelectionMode.SINGLE_CELL</code> or
         *  <code>GridSelectionMode.MULTIPLE_CELLS</code>, adds the cell to
         *  the selection and sets the caret position to the cell.
         *  For all other selection modes, this method has no effect.
         * 
         *  <p>The <code>rowIndex</code> is the index in <code>dataProvider</code> 
         *  of the item containing the selected cell.  The <code>columnIndex</code>
         *  is the index in <code>columns</code> of the column containing the
         *  selected cell.</p>
         *
         *  @param rowIndex The 0-based row index of the cell.
         *
         *  @param columnIndex The 0-based column index of the cell.
         * 
         *  @return True if no errors, or false if <code>rowIndex</code> 
         *  or <code>columnIndex</code> is invalid or the <code>selectionMode</code> 
         *  is invalid.     
         *  
         *  @see spark.components.Grid#caretColumnIndex
         *  @see spark.components.Grid#caretRowIndex
         *  @see spark.components.Grid#columns
         *  @see spark.components.Grid#dataProvider
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */
        public function addSelectedCell(rowIndex:int, columnIndex:int):Boolean
        {
            const selectionChanged:Boolean = gridSelection.addCell(rowIndex, columnIndex);
            if (selectionChanged)
            {
                caretRowIndex = rowIndex;
                caretColumnIndex = columnIndex;
                
                invalidateDisplayList()
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
            }
            
            return selectionChanged;
        }
        
        /**
         *  If <code>selectionMode</code>
         *  is <code>GridSelectionMode.SINGLE_CELL</code> or
         *  <code>GridSelectionMode.MULTIPLE_CELLS</code>, removes the cell
         *  from the selection and sets the caret position to the cell.
         *  For all other selection modes, this method has no effect.
         * 
         *  <p>The <code>rowIndex</code> is the index in <code>dataProvider</code> 
         *  of the item containing the selected cell.  The <code>columnIndex</code>
         *  is the index in <code>columns</code> of the column containing the
         *  selected cell.</p>
         *
         *  @param rowIndex The 0-based row index of the cell.
         *
         *  @param columnIndex The 0-based column index of the cell.
         * 
         *  @return True if no errors, or false if <code>rowIndex</code> 
         *  or <code>columnIndex</code> is invalid or the <code>selectionMode</code> 
         *  is invalid.     
         *  
         *  @see spark.components.Grid#caretColumnIndex
         *  @see spark.components.Grid#caretRowIndex
         *  @see spark.components.Grid#columns
         *  @see spark.components.Grid#dataProvider
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */
        public function removeSelectedCell(rowIndex:int, columnIndex:int):Boolean
        {
            const selectionChanged:Boolean = gridSelection.removeCell(rowIndex, columnIndex);
            if (selectionChanged)
            {
                caretRowIndex = rowIndex;
                caretColumnIndex = columnIndex;
                
                invalidateDisplayList()
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
            }
            
            return selectionChanged;
        }
        
        /** 
         *  If <code>selectionMode</code> is <code>GridSelectionMode.MULTIPLE_CELLS</code>,
         *  sets the selection to all the cells in the cell region and the
         *  caret position to the last cell in the cell region.
         *  For all other selection modes, this method has no effect.
         * 
         *  <p>The <code>rowIndex</code> is the index in <code>dataProvider</code> 
         *  of the item containing the origin of the cell region.  
         *  The <code>columnIndex</code>
         *  is the index in <code>columns</code> of the column containing the
         *  origin of the cell region.</p>
         *
         *  <p>This method has no effect if the cell region is not wholly
         *  contained within the grid.</p>
         * 
         *  @param rowIndex The 0-based row index of the origin of the cell region.
         *
         *  @param columnIndex The 0-based column index of the origin of the cell 
         *  region.
         *  
         *  @param rowCount Number of rows, starting at <code>rowIndex</code> to 
         *  include in the cell region.
         *
         *  @param columnCount Number of columns, starting at 
         *  <code>columnIndex</code> to include in the cell region.
         * 
         *  @return True if no errors, or false if the cell region is invalid or 
         *  the <code>selectionMode</code> is invalid.     
         *  
         *  @see spark.components.Grid#caretColumnIndex
         *  @see spark.components.Grid#caretRowIndex
         *  @see spark.components.Grid#columns
         *  @see spark.components.Grid#dataProvider
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */
        public function selectCellRegion(rowIndex:int, columnIndex:int, 
                                         rowCount:uint, columnCount:uint):Boolean
        {
            const selectionChanged:Boolean = gridSelection.setCellRegion(
                rowIndex, columnIndex, 
                rowCount, columnCount);
            if (selectionChanged)
            {
                caretRowIndex = rowIndex + rowCount - 1;
                caretColumnIndex = columnIndex + columnCount - 1;
                    
                invalidateDisplayList()
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
            }
            
            return selectionChanged;
        }
               
        //--------------------------------------------------------------------------
        //
        //  GridLayout Cover Methods, Properties
        //
        //--------------------------------------------------------------------------   
        
        /**
         *  If necessary, set the verticalScrollPosition and horizontalScrollPosition 
         *  properties so that the specified cell is completely visible.  If columnIndex
         *  is -1, then just adjust the verticalScrollPosition so that the specified
         *  row is visible.
         * 
         *  @param rowIndex The 0-based row index of the item renderer's cell.
         *  @param columnIndex The 0-based column index of the item renderer's cell, or -1 to specify a row.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */
        public function ensureCellIsVisible(rowIndex:int, columnIndex:int = -1):void
        {
            // be safe
            if (rowIndex < 0)
                return;
            
            // A cell's index as defined by LayoutBase it's just its position
            // in the row-major linear ordering of the grid's cells.
            
            const index:int = (rowIndex * dataProvider.length) + ((columnIndex < 0) ? 0 : columnIndex);
            var spDelta:Point = gridLayout.getScrollPositionDeltaToElement(index);
            if (spDelta)
            {
                if (columnIndex >= 0)
                    horizontalScrollPosition += spDelta.x;
                verticalScrollPosition += spDelta.y;
            }
        }        
        
        /**
         *  @copy spark.components.supportClasses.GridLayout#getVisibleRowIndices()
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */ 
        public function getVisibleRowIndices():Vector.<int>
        {
            return gridLayout.getVisibleRowIndices();
        }
        
        /**
         *  @copy spark.components.supportClasses.GridLayout#getVisibleColumnIndices()
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */ 
        public function getVisibleColumnIndices():Vector.<int>
        {
            return gridLayout.getVisibleColumnIndices();
        }
        
        /**
         *  @copy spark.components.supportClasses.GridLayout#getCellBounds()
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */ 
        public function getCellBounds(rowIndex:int, columnIndex:int):Rectangle
        {
            return gridLayout.getCellBounds(rowIndex, columnIndex);
        }
        
        /**
         *  @copy spark.components.supportClasses.GridLayout#getRowBounds()
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */
        public function getRowBounds(rowIndex:int):Rectangle
        {
            return gridLayout.getRowBounds(rowIndex);      
        }
        
        /**
         *  @copy spark.components.supportClasses.GridLayout#getColumnBounds()
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */
        public function getColumnBounds(columnIndex:int):Rectangle
        {
            return gridLayout.getColumnBounds(columnIndex);
        }
        
        /**
         *  @copy spark.components.supportClasses.GridLayout#getRowIndexAt()
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */
        public function getRowIndexAt(x:Number, y:Number):int
        {
            return gridLayout.getRowIndexAt(x, y);
        }
        
        /**
         *  @copy spark.components.supportClasses.GridLayout#getColumnIndexAt()
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */
        public function getColumnIndexAt(x:Number, y:Number):int
        {
            return gridLayout.getColumnIndexAt(x, y); 
        }

        /**
         *  @copy spark.components.supportClasses.GridLayout#getCellAt()
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */
        public function getCellAt(x:Number, y:Number):Object
        {
            return gridLayout.getCellAt(x, y);
        }
        
        /**
         *  @copy spark.components.supportClasses.GridLayout#getCellsAt()
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */
        public function getCellsAt(x:Number, y:Number, w:Number, h:Number):Vector.<CellPosition>
        { 
            return gridLayout.getCellsAt(x, y, w, h);
        }
        
        
        /**
         *  @copy spark.components.supportClasses.GridLayout#getItemRendererAt()
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */
        public function getItemRendererAt(rowIndex:int, columnIndex:int):IVisualElement
        {
            return gridLayout.getItemRendererAt(rowIndex, columnIndex);
        }
        
        /**
         *  @copy spark.components.supportClasses.GridLayout#isCellVisible()
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */        
        public function isCellVisible(rowIndex:int, columnIndex:int = -1):Boolean
        {
            return gridLayout.isCellVisible(rowIndex, columnIndex);
        }
        
        //--------------------------------------------------------------------------
        //
        //  Method Overrides
        //
        //--------------------------------------------------------------------------    
        
        /**
         *  @private
         *  During virtual layout updateDisplayList() eagerly validates lazily
         *  created (or recycled) IRs.   We don't want changes to those IRs to
         *  invalidate the size of the grid.
         */
        override public function invalidateSize():void
        {
            if (!inUpdateDisplayList)
                super.invalidateSize();
        }
        
        /**
         *  @private
         *  During virtual layout updateDisplayList() eagerly validates lazily
         *  created (or recycled) IRs.  Calls to invalidateDisplayList() eventually
         *  short-circuit but doing so early saves a few percent.
         */
        override public function invalidateDisplayList():void
        {
            if (!inUpdateDisplayList)
                super.invalidateDisplayList();
        }

        /**
         *  @private
         */
        override protected function commitProperties():void
        {
            if (!columns && dataProvider && (dataProvider.length > 0))
                columns = generateColumns();
            
            // If the dataProvider or columns change, reset the selection and 
            // the grid dimensions.  This has to be done here rather than in the 
            // setters because the gridSelection and gridDimensions might not 
            // be set yet, depending on the order they are initialized when the 
            // grid skin part is added to the data grid.
            
            if (dataProviderChanged || columnsChanged)
            {
                // Remove the current selection and, if requireSelection, make
                // sure the selection is reset to row 0 or cell 0,0.
                if (gridSelection)
                {
                    var savedRequireSelection:Boolean = gridSelection.requireSelection;
                    gridSelection.requireSelection = false;
                    gridSelection.removeAll();
                    gridSelection.requireSelection = savedRequireSelection;
                }
                
                gridLayout.clearVirtualLayoutCache();
                
                if (gridDimensions)
                {
                    gridDimensions.clear();
                    // clearing the gridDimensions resets rowCount
                    if (_dataProvider)
                        gridDimensions.rowCount = _dataProvider.length;
                    if (columnsChanged && _columns)
                        gridDimensions.columnCount = _columns.length;
                }
                                
                dataProviderChanged = false;
                columnsChanged = false;
            }
            
            // Only want one event if both caretRowIndex and caretColumnIndex
            // changed.
            if (caretChanged)
            {
                dispatchCaretChangeEvent();
                caretChanged = false;
            }            
        }
        
        /**
         *  @private
         */
        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            inUpdateDisplayList = true;
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            inUpdateDisplayList = false;
        }
        
        //--------------------------------------------------------------------------
        //
        //  Internal Grid Access
        //
        //--------------------------------------------------------------------------      
        
        /**
         *  @private
         */
        private function getGridColumn(columnIndex:int):GridColumn
        {
            const columns:IList = columns;
            if ((columns == null) || (columnIndex < 0) || (columnIndex >= columns.length))
                return null;
            
            return columns.getItemAt(columnIndex) as GridColumn;
        }
        
        /**
         *  @private
         */
        mx_internal function getDataProviderItem(rowIndex:int):Object
        {
            const dataProvider:IList = dataProvider;
            if ((dataProvider == null) || (rowIndex >= dataProvider.length))
                return null;
            
            return dataProvider.getItemAt(rowIndex);
        }
        
        /**
         *  @private
         */
        mx_internal function getDataProviderItemIndex(item:Object):int
        {
            const dataProvider:IList = dataProvider;
            if ((dataProvider == null))
                return -1;
            
            return dataProvider.getItemIndex(item);
        }
        
       /**
         *  @private
         */
        private function getVisibleItemRenderer(rowIndex:int, columnIndex:int):IVisualElement
        {
            const layout:GridLayout = layout as GridLayout;
            if (!layout)
                return null;
            
            return layout.getVisibleItemRenderer(rowIndex, columnIndex);
        }
        
        //--------------------------------------------------------------------------
        //
        //  GridEvents
        //
        //--------------------------------------------------------------------------  
        
        private var rollRowIndex:int = -1;
        private var rollColumnIndex:int = -1;
        private var mouseDownRowIndex:int = -1;
        private var mouseDownColumnIndex:int = -1;
        
        /**
         *  This method is called when a MOUSE_DOWN event occurs within the grid and 
         *  for all subsequent MOUSE_MOVE events until the button is released (even if the 
         *  mouse leaves the grid).  The last event in such a "down drag up" gesture is 
         *  always a MOUSE_UP.  By default this method dispatches GRID_MOUSE_DOWN, 
         *  GRID_MOUSE_DRAG, or a GRID_MOUSE_UP event in response to the the corresponding
         *  mouse event.  The GridEvent's rowIndex, columnIndex, column, item, and itemRenderer 
         *  properties correspond to the grid cell under the mouse.  
         * 
         *  @param event A MOUSE_DOWN, MOUSE_MOVE, or MOUSE_UP MouseEvent from a down/move/up gesture initiated within the grid.
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */    
        protected function grid_mouseDownDragUpHandler(event:MouseEvent):void
        {
            const eventStageXY:Point = new Point(event.stageX, event.stageY);
            const eventGridXY:Point = globalToLocal(eventStageXY);
            const gridDimensions:GridDimensions = GridLayout(layout).gridDimensions;
            const eventRowIndex:int = gridDimensions.getRowIndexAt(eventGridXY.x, eventGridXY.y);
            const eventColumnIndex:int = gridDimensions.getColumnIndexAt(eventGridXY.x, eventGridXY.y);
            
            var gridEventType:String;
            switch(event.type)
            {
                case MouseEvent.MOUSE_MOVE: gridEventType = GridEvent.GRID_MOUSE_DRAG; break;
                case MouseEvent.MOUSE_UP:   gridEventType = GridEvent.GRID_MOUSE_UP; break;
                case MouseEvent.MOUSE_DOWN: 
                    gridEventType = GridEvent.GRID_MOUSE_DOWN;
                    mouseDownRowIndex = eventRowIndex;
                    mouseDownColumnIndex = eventColumnIndex;
                    break;
            }
            
            dispatchGridEvent(event, gridEventType, eventGridXY, eventRowIndex, eventColumnIndex);        
        }
        
        /**
         *  This method is called whenever a MOUSE_MOVE event occurs within the grid
         *  without the button pressed.  By default it dispatches a GRID_ROLL_OVER for the
         *  first MOUSE_MOVE GridEvent whose location is within a grid cell, and a 
         *  GRID_ROLL_OUT GridEvent when the mouse leaves a cell.  Listeners are guaranteed
         *  to receive a GRID_ROLL_OUT event for every GRID_ROLL_OVER event.
         * 
         *  @param event A MOUSE_MOVE MouseEvent within the grid, without the button pressed.
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */    
        protected function grid_mouseMoveHandler(event:MouseEvent):void
        {
            const eventStageXY:Point = new Point(event.stageX, event.stageY);
            const eventGridXY:Point = globalToLocal(eventStageXY);
            const gridDimensions:GridDimensions = GridLayout(layout).gridDimensions;
            const eventRowIndex:int = gridDimensions.getRowIndexAt(eventGridXY.x, eventGridXY.y);
            const eventColumnIndex:int = gridDimensions.getColumnIndexAt(eventGridXY.x, eventGridXY.y);
                        
            if ((eventRowIndex != rollRowIndex) || (eventColumnIndex != rollColumnIndex))
            {
                if ((rollRowIndex != -1) || (rollColumnIndex != -1))
                    dispatchGridEvent(event, GridEvent.GRID_ROLL_OUT, eventGridXY, rollRowIndex, rollColumnIndex);
                if ((eventRowIndex != -1) && (eventColumnIndex != -1))
                    dispatchGridEvent(event, GridEvent.GRID_ROLL_OVER, eventGridXY, eventRowIndex, eventColumnIndex);
                rollRowIndex = eventRowIndex;
                rollColumnIndex = eventColumnIndex;
            }
        }
        
        /**
         *  This method is called whenever a ROLL_OUT occurs on the grid.
         *  By default it dispatches a GRID_ROLL_OUT event.
         * 
         *  @param event A ROLL_OUT MouseEvent from the grid.
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */       
        protected function grid_mouseRollOutHandler(event:MouseEvent):void
        {
            if ((rollRowIndex != -1) || (rollColumnIndex != -1))
            {
                const eventStageXY:Point = new Point(event.stageX, event.stageY);
                const eventGridXY:Point = globalToLocal(eventStageXY);            
                dispatchGridEvent(event, GridEvent.GRID_ROLL_OUT, eventGridXY, rollRowIndex, rollColumnIndex);
                rollRowIndex = -1;
                rollColumnIndex = -1;
            }
        }
        
        /**
         *  This method is called whenever a CLICK MouseEvent occurs on the grid if both
         *  the corresponding down and up events occur within the same grid cell.
         *  By default it dispatches a GRID_CLICK event.
         * 
         *  @param event A CLICK MouseEvent from the grid.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */       
        protected function grid_clickHandler(event:MouseEvent):void 
        {
            const eventStageXY:Point = new Point(event.stageX, event.stageY);
            const eventGridXY:Point = globalToLocal(eventStageXY);
            const gridDimensions:GridDimensions = GridLayout(layout).gridDimensions;
            const eventRowIndex:int = gridDimensions.getRowIndexAt(eventGridXY.x, eventGridXY.y);
            const eventColumnIndex:int = gridDimensions.getColumnIndexAt(eventGridXY.x, eventGridXY.y);
            
            if ((eventRowIndex == mouseDownRowIndex) && (eventColumnIndex == mouseDownColumnIndex)) 
                dispatchGridEvent(event, GridEvent.GRID_CLICK, eventGridXY, eventRowIndex, eventColumnIndex);
        }
        
        /**
         *  This method is called whenever a DOUBLE_CLICK MouseEvent occurs on the grid
         *  if the corresponding sequence of down and up events occur within the same grid cell.
         *  By default it dispatches a GRID_DOUBLE_CLICK event.
         * 
         *  @param event A DOUBLE_CLICK MouseEvent from the grid.
         * 
         *  @see flash.display.InteractiveObject#doubleClickEnabled    
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.5
         */       
        protected function grid_doubleClickHandler(event:MouseEvent):void 
        {
            const eventStageXY:Point = new Point(event.stageX, event.stageY);
            const eventGridXY:Point = globalToLocal(eventStageXY);
            const gridDimensions:GridDimensions = GridLayout(layout).gridDimensions;
            const eventRowIndex:int = gridDimensions.getRowIndexAt(eventGridXY.x, eventGridXY.y);
            const eventColumnIndex:int = gridDimensions.getColumnIndexAt(eventGridXY.x, eventGridXY.y);
            
            // This isn't stricly adequate, since the mouse might have been on a different cell for 
            // the first click.  It's not clear that the extra checking would be worthwhile.
            
            if ((eventRowIndex == mouseDownRowIndex) && (eventColumnIndex == mouseDownColumnIndex)) 
                dispatchGridEvent(event, GridEvent.GRID_DOUBLE_CLICK, eventGridXY, eventRowIndex, eventColumnIndex);            
        }    
        
        /**
         *  @private  
         *  Return itemRenderer["excludedEventTargets"] contains event.target.id,
         *  where itemRenderer is the item renderer ancestor of event.target.
         */ 
        private function isEventTargetExcluded(event:Event):Boolean
        {
            const eventTarget:UIComponent = event.target as UIComponent;
            const eventTargetID:String = (eventTarget) ? eventTarget.id : null;
            if (!eventTargetID)
                return false;
            
            // Find the eventTarget's ancestor whose parent is the Grid.  That's the
            // item renderer.  If it has an excludedEventTargets array that contains
            // event.target.id, then this event is to be excluded.
            
            for (var elt:IVisualElement = eventTarget; elt && (elt != this); elt = elt.parent as IVisualElement)
                if (elt.parent == this)  // then elt is an item renderer
                {
                    if ("excludedGridEventTargets" in Object(elt))
                    {
                        const excludedTargets:Array = Object(elt)["excludedGridEventTargets"] as Array;
                        return excludedTargets.indexOf(eventTargetID) != -1;
                    }
                    return false;
                }
            
            return false;
        }
        
        /**
         *  @private
         */
        private function dispatchGridEvent(mouseEvent:MouseEvent, type:String, gridXY:Point, rowIndex:int, columnIndex:int):void
        {
            if (isEventTargetExcluded(mouseEvent))
                return;
            
            const column:GridColumn = columnIndex >= 0 ? getGridColumn(columnIndex) : null;
            const item:Object = rowIndex >= 0 ? getDataProviderItem(rowIndex) : null;
            const itemRenderer:IVisualElement = getVisibleItemRenderer(rowIndex, columnIndex);
            const bubbles:Boolean = mouseEvent.bubbles;
            const cancelable:Boolean = mouseEvent.cancelable;
            const relatedObject:InteractiveObject = mouseEvent.relatedObject;
            const ctrlKey:Boolean = mouseEvent.ctrlKey;
            const altKey:Boolean = mouseEvent.altKey;
            const shiftKey:Boolean = mouseEvent.shiftKey;
            const buttonDown:Boolean = mouseEvent.buttonDown;
            const delta:int = mouseEvent.delta;        
            
            const event:GridEvent = new GridEvent(
                type, bubbles, cancelable, 
                gridXY.x, gridXY.y, rowIndex, columnIndex, column, item, itemRenderer, 
                relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta);
            dispatchEvent(event);
        }
                
        //--------------------------------------------------------------------------
        //
        //  IList listeners: columns, dataProvider
        //
        //--------------------------------------------------------------------------  

        /**
         *  @private
         *  Update caretRowIndex if necessary.  This method should only be called when 
         *  caretRowIndex is valid, i.e. != -1.
         */
        private function updateCaretForDataProviderChange(event:CollectionEvent):void
        {
            const oldCaretRowIndex:int = caretRowIndex;
            const location:int = event.location;
            var itemsLength:int;

            switch (event.kind)
            {
                case CollectionEventKind.ADD:
                    if (oldCaretRowIndex >= location)
                        caretRowIndex += event.items.length;
                    break;
               
                case CollectionEventKind.REMOVE:
                    if (oldCaretRowIndex >= location)
                    {
                        itemsLength = event.items.length;
                        if (oldCaretRowIndex < (location + itemsLength))
                            caretRowIndex = -1;
                        else
                            caretRowIndex -= itemsLength;    
                    }
                    
                    break;
                
                case CollectionEventKind.MOVE:
                    {
                        const oldLocation:int = event.oldLocation;
                        itemsLength = event.items.length;
                        if ((oldCaretRowIndex >= oldLocation) && (oldCaretRowIndex < (oldLocation + itemsLength)))
                            caretRowIndex += location - oldLocation;
                    }
                    break;                        
                    
                case CollectionEventKind.REPLACE:
                case CollectionEventKind.UPDATE:
                    break;
                
                case CollectionEventKind.REFRESH:
                case CollectionEventKind.RESET:
                    caretRowIndex = -1;
                    caretColumnIndex = -1;
                    horizontalScrollPosition = 0;
                    verticalScrollPosition = 0;
                    break;
            }            
        }
        
        /**
         *  @private
         *  Update hoverRowIndex if necessary.  This method should only be called when 
         *  hoverRowIndex is valid, i.e. != -1.
         */
        private function updateHoverForDataProviderChange(event:CollectionEvent):void
        {
            const oldHoverRowIndex:int = hoverRowIndex;
            const location:int = event.location;
            
            switch (event.kind)
            {
                case CollectionEventKind.ADD:
                case CollectionEventKind.REMOVE:
                case CollectionEventKind.REPLACE:
                case CollectionEventKind.UPDATE:
                case CollectionEventKind.MOVE:
                    if (oldHoverRowIndex >= location)
                        hoverRowIndex = gridDimensions.getRowIndexAt(mouseX, mouseY);
                    break;
                
                
                case CollectionEventKind.REFRESH:
                case CollectionEventKind.RESET:
                    hoverRowIndex = gridDimensions.getRowIndexAt(mouseX, mouseY);
                    break;
            }
                        
        }
        
        /**
         *  @private
         */
        private function dataProvider_collectionChangeHandler(event:CollectionEvent):void
        {
            if (gridDimensions)
                gridDimensions.dataProviderCollectionChanged(event);
            
            if (gridLayout)
                gridLayout.dataProviderCollectionChanged(event);
            
            if (gridSelection)
                gridSelection.dataProviderCollectionChanged(event);
                
            // ToDo:  do we need to do any scrolling to keep either the hover
            // indicator or the caret indicator visible?
            
            if (caretRowIndex != -1)
                updateCaretForDataProviderChange(event);
            
            if (gridDimensions && hoverRowIndex != -1)
		        updateHoverForDataProviderChange(event);	

            invalidateSize();
            invalidateDisplayList();
        }
        
        /**
         *  @private
         */
        private function columns_collectionChangeHandler(event:CollectionEvent):void
        {
            // TBD - need to double-check all of these and perhaps move it elsewhere
            
            var column:GridColumn;
            var index:int = event.location;
            
            switch (event.kind)
            {
                case CollectionEventKind.ADD: 
                {
                    // Note: multiple columns may be added.
                    while (index < columns.length)
                    {
                        column = GridColumn(columns.getItemAt(index));
                        column.setGrid(this);
                        column.setColumnIndex(index);
                        index++;
                    }                  
                    break;
                }
                    
                case CollectionEventKind.MOVE:
                {
                    // All columns between the old and new locations need to 
                    // have their index updated.
                    index = Math.min(event.oldLocation, event.location);
                    var maxIndex:int = Math.max(event.oldLocation, event.location);
                    while (index <= maxIndex)
                    {
                        column = GridColumn(columns.getItemAt(index));
                        column.setColumnIndex(index);
                        index++;
                    }                
                    break;
                }
                    
                case CollectionEventKind.REPLACE:
                case CollectionEventKind.UPDATE:
                {
                    column = GridColumn(columns.getItemAt(index));
                    column.setGrid(this);
                    column.setColumnIndex(index);
                    break;
                }
                    
                case CollectionEventKind.REFRESH:
                {
                    for (index = 0; index < columns.length; index++)
                    {
                        column = GridColumn(columns.getItemAt(index));
                        column.setColumnIndex(index);
                    }                
                    break;
                }
                    
                case CollectionEventKind.REMOVE:
                {
                    // Note: multiple columns may be removed.
                    var count:int = event.items.length;
                    
                    for (var i:int = 0; i < count; i++)
                    {
                        column = GridColumn(event.items[i]);
                        column.setGrid(null);
                        column.setColumnIndex(-1);
                    }
                    
                    // Renumber the columns which follow the removed columns.
                    while (index < columns.length)
                    {
                        column = GridColumn(columns.getItemAt(index));
                        column.setColumnIndex(index);
                        index++;
                    }                  
                    
                    break;
                }
                    
                case CollectionEventKind.RESET:
                {
                    for (index = 0; index < columns.length; index++)
                    {
                        column = GridColumn(columns.getItemAt(index));
                        column.setGrid(this);
                        column.setColumnIndex(index);
                    }                     
                    break;
                }                                
            }
            
            gridDimensions.columnCount = _columns.length;
            
            if (gridSelection)
                gridSelection.columnsCollectionChanged(event);
            
            // TBD: hover and caretIndex
            
            invalidateSize();
            invalidateDisplayList();        
        } 
        
        //--------------------------------------------------------------------------
        //
        //  Methods
        //
        //--------------------------------------------------------------------------  
        
        /**
         *  @private
         *  The caret change has already been comitted.  Dispatch the "caretChange"
         *  event.
         */
        private function dispatchCaretChangeEvent():void
        {
            if (hasEventListener(GridCaretEvent.CARET_CHANGE))
            {
                const caretChangeEvent:GridCaretEvent = 
                    new GridCaretEvent(GridCaretEvent.CARET_CHANGE);
                caretChangeEvent.oldRowIndex = _oldCaretRowIndex;
                caretChangeEvent.oldColumnIndex = _oldCaretColumnIndex;
                caretChangeEvent.newRowIndex = _caretRowIndex;
                caretChangeEvent.newColumnIndex = _caretColumnIndex;
                dispatchEvent(caretChangeEvent);
            }
        }
    }
}

import spark.layouts.supportClasses.LayoutBase;

class NullLayout extends LayoutBase
{
    public function NullLayout()
    {
        super();
    }
}