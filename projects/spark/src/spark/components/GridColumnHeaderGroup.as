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

package spark.components
{ 
import flash.display.InteractiveObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.collections.IList;
import mx.core.ClassFactory;
import mx.core.IFactory;
import mx.core.IInvalidating;
import mx.core.IVisualElement;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.managers.CursorManager;
import mx.managers.CursorManagerPriority;
import mx.managers.IFocusManagerComponent;

import spark.components.supportClasses.ColumnHeaderBarLayout;
import spark.components.supportClasses.DefaultColumnHeaderRenderer;
import spark.components.supportClasses.GridColumn;
import spark.components.supportClasses.GridDimensions;
import spark.components.supportClasses.GridLayer;    
import spark.events.GridEvent;
import spark.events.RendererExistenceEvent;
import spark.utils.LabelUtil;
import spark.utils.MouseEventUtil;

use namespace mx_internal;
//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the mouse button is pressed over a column header.
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
 *  if the mouse is no longer within the ColumnHeaderBar.
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
 *  Dispatched when the mouse enters a column header.
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
 *  Dispatched when the mouse leaves a column header.
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
 *  Dispatched when the mouse is clicked over a column header.
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
 *  Dispatched when the mouse is double-clicked over a column header.
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
 *  Dispatched when the mouse button is pressed over a column header.
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
 *  Dispatched after a SEPARATOR_MOUSE_DOWN event if the mouse moves before 
 *  the button is released.
 *
 *  @eventType spark.events.GridEvent.SEPARATOR_MOUSE_DRAG
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="separatorMouseDrag", type="spark.events.GridEvent")]

/**
 *  Dispatched after a SEPARATOR_MOUSE_DOWN event when the mouse button is 
 *  released, even if the mouse is no longer within the separator affordance.
 *
 *  @eventType spark.events.GridEvent.SEPARATOR_MOUSE_UP
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="separatorMouseUp", type="spark.events.GridEvent")]

/**
 *  Dispatched when the mouse is over a column header separator.
 *
 *  @eventType spark.events.GridEvent.SEPARATOR_ROLL_OVER
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="separatorRollOver", type="spark.events.GridEvent")]

/**
 *  Dispatched when the mouse leaves a column header separator.
 *
 *  @eventType spark.events.GridEvent.SEPARATOR_ROLL_OUT
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="separatorRollOut", type="spark.events.GridEvent")]
    
/**
 *  Dispatched when the mouse is clicked over a column header separator.
 *
 *  @eventType spark.events.GridEvent.SEPARATOR_CLICK
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
//[Event(name="separatorClick", type="spark.events.GridEvent")]

/**
 *  Dispatched when the mouse is double-clicked over a column 
 *  header separator.
 *
 *  @eventType spark.events.GridEvent.SEPARATOR_DOUBLE_CLICK
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
//[Event(name="separatorDoubleClick", type="spark.events.GridEvent")]
  
//--------------------------------------
//  Other metadata
//--------------------------------------

[IconFile("ColumnHeaderBar.png")]

/**
 *  The ColumnHeaderBar control defines
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
public class ColumnHeaderBar extends SkinnableDataContainer 
    implements IFocusManagerComponent 
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
    public function ColumnHeaderBar()
    {
        super();
                
        layout = new ColumnHeaderBarLayout();
        layout.useVirtualLayout = true;
        layout.clipAndEnableScrolling = true;

        itemRendererFunction = defaultColumnHeaderBarItemRendererFunction;
        
        MouseEventUtil.addDownDragUpListeners(this, 
            chb_mouseDownDragUpHandler, 
            chb_mouseDownDragUpHandler, 
            chb_mouseDownDragUpHandler);
        
        addEventListener(MouseEvent.MOUSE_MOVE, chb_mouseMoveHandler);
        addEventListener(MouseEvent.ROLL_OUT, chb_mouseRollOutHandler);
        addEventListener(MouseEvent.CLICK, chb_clickHandler);
        addEventListener(MouseEvent.DOUBLE_CLICK, chb_doubleClickHandler); 
        
        addEventListener(GridEvent.GRID_MOUSE_DOWN, header_mouseDownHandler);
        addEventListener(GridEvent.GRID_ROLL_OVER, header_rollOverHandler);
        addEventListener(GridEvent.GRID_ROLL_OUT, header_rollOutHandler);
        
        addEventListener(GridEvent.SEPARATOR_MOUSE_DOWN, sep_mouseDownHandler);
        addEventListener(GridEvent.SEPARATOR_MOUSE_UP, sep_mouseUpHandler);
        addEventListener(GridEvent.SEPARATOR_ROLL_OVER, sep_rollOverHandler);
        addEventListener(GridEvent.SEPARATOR_ROLL_OUT, sep_rollOutHandler);
    }

    //--------------------------------------------------------------------------
    //
    //  Skin Parts
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  columnResizeIndicator
    //----------------------------------
    
    [SkinPart(required="false", type="flash.display.DisplayObject")]
    
    /**
     *  A skin part that defines the appearance of the column resize indicator. 
     *  The column resize indicator is resized and positioned by the layout 
     *  to ... TBD
     *
     *  <p>By default, the column resize indicator for a is a solid line that
     *  spans the height of the control.
     *  Create a custom column resize indicator by creating a custom skin class for the drop target.
     *  In your skin class, create a skin part named <code>columnResizeIndicator</code>,
     *  in the &lt;fx:Declarations&gt; area of the skin class</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4
     */
    public var columnResizeIndicator:IFactory; 
    
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    public var overlayLayer:GridLayer;
    
    /**
     *  @private
     */
    private var resizeCursorID:int = CursorManager.NO_CURSOR;
    
    /**
     *  @private
     *  Additional affordance given to header separators.
     *  TBD: should this be configurable?
     */
    private var separatorAffordance:Number = 3;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  firstItemRenderer
    //----------------------------------
    
    private var _firstItemRenderer:IFactory = null;
    
    [Bindable("firstItemRendererChanged")]
    
    /**
     *  A factory for IItemRenderers used to render the header for the first
     *  grid columns.  If not specified, the column header bar's 
     *  <code>headerItemRenderer</code> is return.
     *  
     *  @default The value of the firstItemRenderer, or the headerItemRenderer,
     *  if this has not been set.
     *
     *  @see #dataField 
     *  @see GridItemRenderer
     */
    public function get firstItemRenderer():IFactory
    {
        return (_firstItemRenderer) ? _firstItemRenderer : itemRenderer;
    }
    
    /**
     *  @private
     */
    public function set firstItemRenderer(value:IFactory):void
    {
        if (_firstItemRenderer == value)
            return;
        
        _firstItemRenderer = value;
        
        // Force the itemRenderers to be recreated.
        super.itemRenderer = super.itemRenderer;

        dispatchChangeEvent("firstItemRendererChanged");
    }
                
    //----------------------------------
    //  headerSeparator
    //----------------------------------
    
    [Bindable("headerSeparatorChanged")]
    
    private var _headerSeparator:IFactory = null;
    
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
    public function get headerSeparator():IFactory
    {
        return _headerSeparator;
    }
    
    /**
     *  @private
     */
    public function set headerSeparator(value:IFactory):void
    {
        if (_headerSeparator == value)
            return;
        
        _headerSeparator = value;
        
        invalidateDisplayList();
        
        dispatchChangeEvent("headerSeparatorChanged");
    }    
    
    //----------------------------------
    //  horizontalScrollPosition
    //----------------------------------

    private var _horizontalScrollPosition:int;

    public function get horizontalScrollPosition():Number 
    {
        return dataGroup ? 
               dataGroup.horizontalScrollPosition : _horizontalScrollPosition;
    }
    
    /**
     *  @private
     */
    public function set horizontalScrollPosition(value:Number):void 
    {
        // If there is no layout, dataGroup caches this.
        if (dataGroup)
            dataGroup.horizontalScrollPosition = value;
        else
            _horizontalScrollPosition = value;
    }
    
    //----------------------------------
    //  labelField
    //----------------------------------
    
    /**
     *  @private
     */
    private var _labelField:String = "headerText";
    
    /**
     *  @private
     */
    private var labelFieldOrFunctionChanged:Boolean; 
    
    /**
     *  The name of the field in the data provider items to display 
     *  as the header label. 
     *  The <code>labelFunction</code> property overrides this property.
     *
     *  @default "headerText" 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2
     *  @productversion Flex 4.5
     */
    public function get labelField():String
    {
        return _labelField;
    }
    
    /**
     *  @private
     */
    public function set labelField(value:String):void
    {
        if (value == _labelField)
            return 
            
        _labelField = value;
        labelFieldOrFunctionChanged = true;
        invalidateProperties();
    }
    
    //----------------------------------
    //  labelFunction
    //----------------------------------
    
    /**
     *  @private
     */
    private var _labelFunction:Function; 
    
    /**
     *  A user-supplied function to run on each item to determine its label.  
     *  The <code>labelFunction</code> property overrides 
     *  the <code>labelField</code> property.
     *
     *  <p>You can supply a <code>labelFunction</code> that finds the 
     *  appropriate fields and returns a displayable string. The 
     *  <code>labelFunction</code> is also good for handling formatting and 
     *  localization. </p>
     *
     *  <p>The label function takes a single argument which is the item in 
     *  the data provider and returns a String.</p>
     *  <pre>
     *  myLabelFunction(item:Object):String</pre>
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2
     *  @productversion Flex 4.5
     */
    public function get labelFunction():Function
    {
        return _labelFunction;
    }
    
    /**
     *  @private
     */
    public function set labelFunction(value:Function):void
    {
        if (value == _labelFunction)
            return 
            
            _labelFunction = value;
        labelFieldOrFunctionChanged = true;
        invalidateProperties(); 
    }
    
    //----------------------------------
    //  lastItemRenderer
    //----------------------------------
    
    private var _lastItemRenderer:IFactory = null;
    
    [Bindable("lastItemRendererChanged")]
    
    /**
     *  A factory for IItemRenderers used to render the header for the last
     *  grid columns.  If not specified, the column header bar's 
     *  <code>itemRenderer</code> is return.
     *  
     *  @default The value of the lastItemRenderer, or the itemRenderer,
     *  if this has not been set.
     *
     *  @see #dataField 
     *  @see GridItemRenderer
     */
    public function get lastItemRenderer():IFactory
    {
        return (_lastItemRenderer) ? _lastItemRenderer : itemRenderer;
    }
    
    /**
     *  @private
     */
    public function set lastItemRenderer(value:IFactory):void
    {
        if (_lastItemRenderer == value)
            return;
        
        _lastItemRenderer = value;
        
        // Force the itemRenderers to be recreated.
        super.itemRenderer = super.itemRenderer;
        
        dispatchChangeEvent("lastItemRendererChanged");
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Properties
    //
    //--------------------------------------------------------------------------
            
    //----------------------------------
    //  itemRenderer
    //----------------------------------
            
    [Bindable("itemRendererChanged")]
    
    /**
     *  A factory for IItemRenderers used to render the header for the
     *  grid columns.  If not specified, the 
     *  <code>DefaultColumnHeaderRenderer</code> is returned.
     * 
     *  <p>The default item renderer just displays the value of its 
     *  <code>label</code> property, which is based on the dataProvider item for 
     *  the column, and on the column's headerText property.  Custom item 
     *  renderers that derive more values from the column item and include 
     *  more complex visuals are easily created by subclassing 
     *  <code>ItemRenderer</code>.</p>
     * 
     *  @default The value of the headerItemRenderer.
     *
     *  @see DefaultColumnHeaderRenderer
     */
    override public function get itemRenderer():IFactory
    {
        if (!super.itemRenderer)
            itemRenderer = new ClassFactory(DefaultColumnHeaderRenderer);
        
        return super.itemRenderer;
    }
    
    /**
     *  @private
     */
    override public function set itemRenderer(value:IFactory):void
    {
        if (super.itemRenderer == value)
            return;
        
        super.itemRenderer = value;
        
        dispatchChangeEvent("itemRendererChanged");
    }
            
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == dataGroup)
        { 
            overlayLayer = new GridLayer();
            dataGroup.overlay.addDisplayObject(overlayLayer.root);        
                                    
            dataGroup.horizontalScrollPosition = _horizontalScrollPosition;
            dataGroup.addEventListener(RendererExistenceEvent.RENDERER_ADD, dataGroup_rendererAddHandler);
            dataGroup.addEventListener(RendererExistenceEvent.RENDERER_REMOVE, dataGroup_rendererRemoveHandler);
        }
    }
    
    /**
     * @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        if (instance == dataGroup)
        {
            dataGroup.removeEventListener(RendererExistenceEvent.RENDERER_ADD, dataGroup_rendererAddHandler);
            dataGroup.removeEventListener(RendererExistenceEvent.RENDERER_REMOVE, dataGroup_rendererRemoveHandler);
            horizontalScrollPosition = 0;
            
            overlayLayer = null;
        }

        super.partRemoved(partName, instance);
    }
            
    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        if (labelFieldOrFunctionChanged)
        {
            // Cycle through all instantiated renderers to push the correct text 
            // in to the renderer by setting its label property
            if (dataGroup)
            {
                var itemIndex:int;
                
                // if virtual layout, only loop through the indices in view
                // otherwise, loop through all of the item renderers
                if (layout && layout.useVirtualLayout)
                {
                    for each (itemIndex in dataGroup.getItemIndicesInView())
                    {
                        updateRendererLabelProperty(itemIndex);
                    }
                }
                else
                {
                    var n:int = dataGroup.numElements;
                    for (itemIndex = 0; itemIndex < n; itemIndex++)
                    {
                        updateRendererLabelProperty(itemIndex);
                    }
                }
            }
            
            labelFieldOrFunctionChanged = false; 
        }
    }
    
    /**
     *  @private
     */
    override public function updateRenderer(renderer:IVisualElement, itemIndex:int, data:Object):void
    {
        // If the CHB has a height set on it, force all the headers to be
        // that height.
        if (!isNaN(explicitHeight))
            renderer.height = explicitHeight;
        
        super.updateRenderer(renderer, itemIndex, data);
    }
    
    /**
     *  Given a data item, return the correct text a renderer
     *  should display while taking the <code>labelField</code> 
     *  and <code>labelFunction</code> properties into account. 
     *
     *  @param item A data item 
     *  
     *  @return String representing the text to display for the 
     *  data item in the  renderer. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function itemToLabel(item:Object):String
    {
    return GridColumn.itemToString(item, [labelField], labelFunction);
    }

    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private function get dataGrid():DataGrid
    {
        return owner as DataGrid;
    }
    
    /**
     *  @private
     */
    private function get grid():Grid
    {
        return dataGrid ? dataGrid.grid : null;
    }

    /**
     *  @private
     */
    private function getDataProviderItem(columnIndex:int):Object
    {
        const dataProvider:IList = dataProvider;
        if ((dataProvider == null) || (columnIndex < 0 || columnIndex >= dataProvider.length))
            return null;
        
        return dataProvider.getItemAt(columnIndex);
    }

    private function dispatchChangeEvent(type:String):void
    {
        if (hasEventListener(type))
            dispatchEvent(new Event(type));
    }
    
    /**
     *  @private
     */
    private function updateRendererLabelProperty(itemIndex:int):void
    {
        // grab the renderer at that index and re-compute it's label property
        var renderer:IItemRenderer = dataGroup.getElementAt(itemIndex) as IItemRenderer; 
        if (renderer)
            renderer.label = itemToLabel(renderer.data); 
    }
    
    /**
     *  @private
     *  If the first column use the firstItemRenderer, if the last column use 
     *  the lastItemRenderer, otherwise use the itemRenderer.
     */
    private function defaultColumnHeaderBarItemRendererFunction(data:Object):IFactory
    {
        var column:GridColumn = GridColumn(data);
        
        var columnIndex:int = column.columnIndex;
        
        if (columnIndex == 0)
            return firstItemRenderer;
        
        if (columnIndex == dataProvider.length - 1)
            return lastItemRenderer;

        return itemRenderer;
    }
    
    // TBD: refactor the version of this in GridLayout so it doesn't
    // have to be duplicated.
    
    /**
     *  @private
     *  Size and position the visual element.
     */
    private function layoutGridElement(elt:IVisualElement, 
                                       x:Number, y:Number, 
                                       width:Number, height:Number):void
    {
        const validatingElt:IInvalidating = elt as IInvalidating;
        
        if (!isNaN(width) || !isNaN(height))
        {
            if (validatingElt)
                validatingElt.validateNow();
            elt.setLayoutBoundsSize(width, height);
        }
        if (validatingElt)        
            validatingElt.validateNow();
        elt.setLayoutBoundsPosition(x, y);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //--------------------------------------------------------------------------
            
    /**
     *  @private
     */
    private function dataGroup_rendererAddHandler(event:RendererExistenceEvent):void
    {
        /*
        const renderer:IItemRenderer = event.renderer as IItemRenderer; 
        if (renderer)
        {
            renderer.addEventListener(MouseEvent.CLICK, item_clickHandler);

            // ToDo: deal with focus issues
            //if (renderer is IFocusManagerComponent)
            //    IFocusManagerComponent(renderer).focusEnabled = false;
        }
        */
    }
    
    /**
     *  @private
     */
    private function dataGroup_rendererRemoveHandler(event:RendererExistenceEvent):void
    {      
        /*
        const renderer:IVisualElement = event.renderer;
        if (renderer)
            renderer.removeEventListener(MouseEvent.CLICK, item_clickHandler);
        */
    }
    
    /**
     *  @private
     *  If the mouse is over the headerSeparator +/- the separatorAffordance,
     *  return the index of the column to the left of the separator.
     *  Otherwise return -1.
     */
    private function getHeaderSeparatorIndex(localPt:Point, columnIndex:int):int
    {   
        // FIXME: For now assume header separator is 1 pixel wide and 
        // the columnGap is 0.
        const bounds:Rectangle = grid.getColumnBounds(columnIndex);
        if (bounds == null)
            return -1;
        
        if (localPt.x <= bounds.left + separatorAffordance)
        {
            if (columnIndex == 0)
                return -1;
            
            return columnIndex - 1;
        }
        else if (localPt.x >= bounds.right - separatorAffordance)
        {
            return columnIndex;
        }
        
        return -1;
    }
    
    /**
     *  @private
     */
    private function header_mouseDownHandler(event:GridEvent):void
    {
        if (!enabled)
            return;           
     }

    /**
     *  @private
     */
    private function header_rollOverHandler(event:GridEvent):void
    {
        if (!enabled)
            return;
                               
        //column:GridColumn = event.column;
        //const columnIndex:int = event.columnIndex;            
    }
    
    /**
     *  @private
     */
    private function header_rollOutHandler(event:GridEvent):void
    {
        if (!enabled)
            return;
    }    
 
    /**
     *  @private
     */
    private function sep_mouseDownHandler(event:GridEvent):void
    {
        if (!enabled || !grid.resizableColumns)
            return;
        
        var column:GridColumn = event.column;            
        if (!column.resizable)
            return;
        
        const bounds:Rectangle = grid.getColumnBounds(event.columnIndex);
        
        // FIXME: handle columnResizeIndictor = null
        var resizeGraphic:IVisualElement = 
            columnResizeIndicator.newInstance() as IVisualElement;
        
        // TBD: size resize graphic and put in initial position
     }

    /**
     *  @private
     */
    private function sep_mouseUpHandler(event:GridEvent):void
    {
        if (!enabled || !grid.resizableColumns)
            return;
    }

    /**
     *  @private
     */
    private function sep_rollOverHandler(event:GridEvent):void
    {
        if (!enabled || !grid.resizableColumns)
            return;
        
        var column:GridColumn = event.column;
        
        if (!column.resizable)
            return;
        
        // Uncomment when resize is implemented.

        // Hide the mouse, attach and show the cursor            
        /*
        var stretchCursorClass:Class = getStyle("stretchCursor");
        resizeCursorID = cursorManager.setCursor(
                                stretchCursorClass, 
                                CursorManagerPriority.HIGH, 0, 0);
        */
    }
    
    /**
     *  @private
     */
    private function sep_rollOutHandler(event:GridEvent):void
    {
        if (!enabled)
            return;
        
        // Uncomment when resize is implemented.
        //cursorManager.removeCursor(resizeCursorID);
    }    

    //--------------------------------------------------------------------------
    //
    //  GridEvents
    //
    //--------------------------------------------------------------------------  
    
    private var rollColumnIndex:int = -1;
    private var mouseDownColumnIndex:int = -1;
    private var resizeColumnIndex:int = -1;
    private var dragSeparator:Boolean;
    
    /**
     *  This method is called when a MOUSE_DOWN event occurs within the column header bar and 
     *  for all subsequent MOUSE_MOVE events until the button is released (even if the 
     *  mouse leaves the column header bar).  The last event in such a "down drag up" gesture is 
     *  always a MOUSE_UP.  By default this method dispatches GRID_MOUSE_DOWN, 
     *  GRID_MOUSE_DRAG, or a GRID_MOUSE_UP event in response to the the corresponding
     *  mouse event on a column header or SEPARATOR_MOUSE_DOWN, SEPARATOR_MOUSE_DRAG, 
     *  or a SEPARATOR_MOUSE_UP event in response to the the corresponding
     *  mouse event on a column header separator.
     * 
     * .The GridEvent's columnIndex, column, item, and itemRenderer 
     *  properties correspond to the grid cell under the mouse.  
     * 
     *  @param event A MOUSE_DOWN, MOUSE_MOVE, or MOUSE_UP MouseEvent from a 
     *  down/move/up gesture initiated within the column header bar.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */    
    protected function chb_mouseDownDragUpHandler(event:MouseEvent):void
    {
        const eventStageXY:Point = new Point(event.stageX, event.stageY);
        const eventHeaderBarXY:Point = globalToLocal(eventStageXY);

        const eventColumnIndex:int = 
            grid.getColumnIndexAt(eventHeaderBarXY.x, 0);
        
        var gridEventType:String;
        switch(event.type)
        {
            case MouseEvent.MOUSE_MOVE: 
                if (dragSeparator)
                    gridEventType = GridEvent.SEPARATOR_MOUSE_DRAG;
                else
                    gridEventType = GridEvent.GRID_MOUSE_DRAG;
                break;
            case MouseEvent.MOUSE_UP:  
                if (dragSeparator)
                    gridEventType = GridEvent.SEPARATOR_MOUSE_UP;
                else
                    gridEventType = GridEvent.GRID_MOUSE_UP;
                break;
            case MouseEvent.MOUSE_DOWN: 
                // Is the mouseDown on a separator or a header?
                const headerIndex:int =
                    getHeaderSeparatorIndex(eventHeaderBarXY, eventColumnIndex);
                dragSeparator = headerIndex != -1;                   
                if (dragSeparator)
                {
                    gridEventType = GridEvent.SEPARATOR_MOUSE_DOWN;
                    mouseDownColumnIndex = headerIndex;
                }
                else
                {
                    gridEventType = GridEvent.GRID_MOUSE_DOWN;
                    mouseDownColumnIndex = eventColumnIndex;
                }
                break;
        }
                
        dispatchGridEvent(event, gridEventType, eventHeaderBarXY, eventColumnIndex);
    }
      
    /**
     *  This method is called whenever a MOUSE_MOVE occurs on either a
     *  header in the column header bar or on one of the column header bar 
     *  separators without the button pressed.  
     *  
     *  By default it dispatches a GRID_ROLL_OVER for the first
     *  MOUSE_MOVE GridEvent whose location is within a column header, and a 
     *  GRID_ROLL_OUT GridEvent when the mouse leaves the column_header and
     *  it dispatches a SEPARATOR_ROLL_OVER for the first MOUSE_MOVE 
     *  GridEvent whose location is over a column header separator +/- the
     *  column header separator affordance, and a SEPARATOR_ROLL_OUT 
     *  GridEvent when the mouse leaves the separator affordance.  
     *  Listeners are guaranteed to receive a GRID_ROLL_OUT event for every 
     *  GRID_ROLL_OVER event and to receive a SEPARATOR_ROLL_OUT event for
     *  every SEPARATOR_ROLL_OVER event.
     * 
     *  @param event A MOUSE_MOVE MouseEvent within the column header bar, 
     *  without the button pressed.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */    
    protected function chb_mouseMoveHandler(event:MouseEvent):void
    {
        const eventStageXY:Point = new Point(event.stageX, event.stageY);
        const eventHeaderBarXY:Point = globalToLocal(eventStageXY);
        const eventColumnIndex:int = grid.getColumnIndexAt(eventHeaderBarXY.x, 0);
        
        var headerIndex:int = 
            getHeaderSeparatorIndex(eventHeaderBarXY, eventColumnIndex);
        
        // Figure out if this roll over is over one of the header separators
        // or over the header itself.  The ends of the header that are 
        // within the separatorAffordance are considered part of the
        // seperator, not part of the header.
                    
        if (headerIndex != -1)
        {
            if (rollColumnIndex != -1)
            {
                dispatchGridEvent(event, GridEvent.GRID_ROLL_OUT, eventHeaderBarXY, rollColumnIndex);  
                rollColumnIndex = -1;
            }
            if (headerIndex != resizeColumnIndex)
            {
                if (resizeColumnIndex != -1 && headerIndex != resizeColumnIndex)
                    dispatchGridEvent(event, GridEvent.SEPARATOR_ROLL_OUT, eventHeaderBarXY, resizeColumnIndex);               
                if (eventColumnIndex != resizeColumnIndex)
                    dispatchGridEvent(event, GridEvent.SEPARATOR_ROLL_OVER, eventHeaderBarXY, headerIndex);               
                resizeColumnIndex = headerIndex;
            }
        }
        else
        {
            if (resizeColumnIndex != -1)
            {
                dispatchGridEvent(event, GridEvent.SEPARATOR_ROLL_OUT, eventHeaderBarXY, resizeColumnIndex);
                resizeColumnIndex = -1;
            }
            if (eventColumnIndex != rollColumnIndex)
            {
                if (rollColumnIndex != -1)
                    dispatchGridEvent(event, GridEvent.GRID_ROLL_OUT, eventHeaderBarXY, rollColumnIndex);
                if (eventColumnIndex != -1)
                    dispatchGridEvent(event, GridEvent.GRID_ROLL_OVER, eventHeaderBarXY, eventColumnIndex);
                rollColumnIndex = eventColumnIndex;
            }
        }
     }
            
    /**
     *  This method is called whenever a ROLL_OUT occurs on either a
     *  header in the column header bar or on one of the column header bar 
     *  separators.
     * 
     *  By default it dispatches either a GRID_ROLL_OUT or a
     *  SEPARATOR_ROLL_OUT event.
     * 
     *  @param event A ROLL_OUT MouseEvent from the column header bar.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */       
    protected function chb_mouseRollOutHandler(event:MouseEvent):void
    {
        const eventStageXY:Point = new Point(event.stageX, event.stageY);
        const eventHeaderBarXY:Point = globalToLocal(eventStageXY);
        
        // Is the rollout for a column seperator or is it for the column?
        
        if (resizeColumnIndex != -1)
        {
            dispatchGridEvent(event, GridEvent.SEPARATOR_ROLL_OUT, eventHeaderBarXY, resizeColumnIndex);
            resizeColumnIndex = -1;
        }
        else if (rollColumnIndex != -1)
        {
            dispatchGridEvent(event, GridEvent.GRID_ROLL_OUT, eventHeaderBarXY, rollColumnIndex);
            rollColumnIndex = -1;
        }
    }
    
    /**
     *  This method is called whenever a CLICK MouseEvent occurs on the 
     *  column header bar if both the corresponding down and up events occur 
     *  within the same column header cell. By default it dispatches a 
     *  GRID_CLICK event.
     * 
     *  @param event A CLICK MouseEvent from the column header bar.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */       
    protected function chb_clickHandler(event:MouseEvent):void 
    {
        const eventStageXY:Point = new Point(event.stageX, event.stageY);
        const eventHeaderBarXY:Point = globalToLocal(eventStageXY);
        const eventColumnIndex:int = grid.getColumnIndexAt(eventHeaderBarXY.x, 0);
        
        var headerIndex:int = 
            getHeaderSeparatorIndex(eventHeaderBarXY, eventColumnIndex);
        
        if (headerIndex != -1)
        {
            // Should be able to go down on one side of the separator and
            // up on the other side even though this spans columns.
            if (headerIndex == resizeColumnIndex) 
                dispatchGridEvent(event, GridEvent.SEPARATOR_CLICK, eventHeaderBarXY, headerIndex);
        }
        else
        {
            if (eventColumnIndex == mouseDownColumnIndex) 
                dispatchGridEvent(event, GridEvent.GRID_CLICK, eventHeaderBarXY, eventColumnIndex);
        }
    }
    
    /**
     *  This method is called whenever a DOUBLE_CLICK MouseEvent occurs on 
     *  the column header bar if the corresponding sequence of down and up 
     *  events occur within the same column header cell.
     *  By default it dispatches a GRID_DOUBLE_CLICK event.
     * 
     *  @param event A DOUBLE_CLICK MouseEvent from the column header bar.
     * 
     *  @see flash.display.InteractiveObject#doubleClickEnabled    
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */       
    protected function chb_doubleClickHandler(event:MouseEvent):void 
    {
        const eventStageXY:Point = new Point(event.stageX, event.stageY);
        const eventHeaderBarXY:Point = globalToLocal(eventStageXY);
        const gridDimensions:GridDimensions = dataGrid.grid.gridDimensions;
        const eventColumnIndex:int = grid.getColumnIndexAt(eventHeaderBarXY.x, 0);
        
        // This isn't stricly adequate, since the mouse might have been on a different cell for 
        // the first click.  It's not clear that the extra checking would be worthwhile.
        
        // TBD: separator double click
        
        if (eventColumnIndex == mouseDownColumnIndex) 
            dispatchGridEvent(event, GridEvent.GRID_DOUBLE_CLICK, eventHeaderBarXY, eventColumnIndex);            
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
    private function dispatchGridEvent(mouseEvent:MouseEvent, type:String, gridXY:Point, columnIndex:int):void
    {
        //trace("dispatchGridEvent", mouseEvent.type, type, gridXY, columnIndex);
        
        // ToDo: what is this?  what about the separators?  are they excluded?
        if (isEventTargetExcluded(mouseEvent))
            return;
        
        const column:GridColumn = getDataProviderItem(columnIndex) as GridColumn;
        const item:Object = null;
        const itemRenderer:IVisualElement = dataGroup.getElementAt(columnIndex);
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
            gridXY.x, gridXY.y, -1, columnIndex, column, item, itemRenderer, 
            relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta);
        dispatchEvent(event);
    }     
}
}
