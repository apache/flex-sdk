////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.printing
{

import flash.events.KeyboardEvent;

import mx.collections.CursorBookmark;
import mx.controls.OLAPDataGrid;
import mx.core.EdgeMetrics;
import mx.core.ScrollPolicy;
import mx.core.mx_internal;
import mx.olap.IOLAPResult;
import mx.olap.IOLAPResultAxis;
import mx.olap.OLAPQuery;

use namespace mx_internal;

//--------------------------------------
//  Excluded APIs
//--------------------------------------

//--------------------------------------
//  public properties
//--------------------------------------

[Exclude(name="allowDragSelection", kind="property")]
[Exclude(name="allowMultipleSelection", kind="property")]
[Exclude(name="columns", kind="property")]
[Exclude(name="columnWidth", kind="property")]
[Exclude(name="displayDisclosureIcon", kind="property")]
[Exclude(name="displayItemsExpanded", kind="property")]
[Exclude(name="dataTipField", kind="property")]
[Exclude(name="dataTipFunction", kind="property")]
[Exclude(name="doubleClickEnabled", kind="property")]
[Exclude(name="dragEnabled", kind="property")]
[Exclude(name="draggableColumns", kind="property")]
[Exclude(name="dragMoveEnabled", kind="property")]
[Exclude(name="dropEnabled", kind="property")]
[Exclude(name="dropTarget", kind="property")]
[Exclude(name="editable", kind="property")]
[Exclude(name="editedItemPosition", kind="property")]
[Exclude(name="editedItemRenderer", kind="property")]
[Exclude(name="groupedColumns", kind="property")]
[Exclude(name="groupIconFunction", kind="property")]
[Exclude(name="groupLabelFunction", kind="property")]
[Exclude(name="hierarchicalCollectionView", kind="property")]
[Exclude(name="horizontalScrollBar", kind="property")]
[Exclude(name="horizontalScrollPolicy", kind="property")]
[Exclude(name="itemEditorInstance", kind="property")]
[Exclude(name="itemIcons", kind="property")]
[Exclude(name="labelFunction", kind="property")]
[Exclude(name="lockedColumnCount", kind="property")]
[Exclude(name="lookAheadDuration", kind="property")]
[Exclude(name="maxHorizontalScrollPosition", kind="property")]
[Exclude(name="maxVerticalScrollPosition", kind="property")]
[Exclude(name="rendererProviders", kind="property")]
[Exclude(name="showHeaders", kind="property")]
[Exclude(name="scrollTipFunction", kind="property")]
[Exclude(name="selectable", kind="property")]
[Exclude(name="selectedIndex", kind="property")]
[Exclude(name="selectedIndices", kind="property")]
[Exclude(name="selectedItem", kind="property")]
[Exclude(name="selectedItems", kind="property")]
[Exclude(name="showScrollTips", kind="property")]
[Exclude(name="sortableColumns", kind="property")]
[Exclude(name="sortExpertMode", kind="property")]
[Exclude(name="sortItemRenderer", kind="property")]
[Exclude(name="toolTip", kind="property")]
[Exclude(name="useHandCursor", kind="property")]
[Exclude(name="verticalScrollBar", kind="property")]
[Exclude(name="verticalScrollPolicy", kind="property")]

//--------------------------------------
//  protected properties
//--------------------------------------

[Exclude(name="anchorBookmark", kind="property")]
[Exclude(name="anchorIndex", kind="property")]
[Exclude(name="caretBookmark", kind="property")]
[Exclude(name="caretIndex", kind="property")]
[Exclude(name="caretIndicator", kind="property")]
[Exclude(name="caretItemRenderer", kind="property")]
[Exclude(name="caretUID", kind="property")]
[Exclude(name="dragImage", kind="property")]
[Exclude(name="dragImageOffsets", kind="property")]
[Exclude(name="highlightIndicator", kind="property")]
[Exclude(name="highlightUID", kind="property")]
[Exclude(name="keySelectionPending", kind="property")]
[Exclude(name="lastDropIndex", kind="property")]
[Exclude(name="selectionLayer", kind="property")]
[Exclude(name="selectionTweens", kind="property")]
[Exclude(name="showCaret", kind="property")]

//--------------------------------------
//  public methods
//--------------------------------------

[Exclude(name="calculateDropIndex", kind="method")]
[Exclude(name="createItemEditor", kind="method")]
[Exclude(name="destroyItemEditor", kind="method")]
[Exclude(name="effectFinished", kind="method")]
[Exclude(name="effectStarted", kind="method")]
[Exclude(name="endEffectStarted", kind="method")]
[Exclude(name="hideDropFeedback", kind="method")]
[Exclude(name="isItemHighlighted", kind="method")]
[Exclude(name="isItemSelected", kind="method")]
[Exclude(name="showDropFeedback", kind="method")]
[Exclude(name="startDrag", kind="method")]

//--------------------------------------
//  protected methods
//--------------------------------------

[Exclude(name="dragCompleteHandler", kind="method")]
[Exclude(name="dragDropHandler", kind="method")]
[Exclude(name="dragEnterHandler", kind="method")]
[Exclude(name="dragExitHandler", kind="method")]
[Exclude(name="dragOverHandler", kind="method")]
[Exclude(name="dragScroll", kind="method")]
[Exclude(name="drawCaretIndicator", kind="method")]
[Exclude(name="drawHighlightIndicator", kind="method")]
[Exclude(name="drawSelectionIndicator", kind="method")]
[Exclude(name="mouseClickHandler", kind="method")]
[Exclude(name="mouseDoubleClickHandler", kind="method")]
[Exclude(name="mouseDownHandler", kind="method")]
[Exclude(name="mouseEventToItemRenderer", kind="method")]
[Exclude(name="mouseMoveHandler", kind="method")]
[Exclude(name="mouseOutHandler", kind="method")]
[Exclude(name="mouseOverHandler", kind="method")]
[Exclude(name="mouseUpHandler", kind="method")]
[Exclude(name="mouseWheelHandler", kind="method")]
[Exclude(name="moveSelectionHorizontally", kind="method")]
[Exclude(name="moveSelectionVertically", kind="method")]
[Exclude(name="placeSortArrow", kind="method")]
[Exclude(name="removeIndicators", kind="method")]
[Exclude(name="selectItem", kind="method")]
[Exclude(name="setScrollBarProperties", kind="method")]
[Exclude(name="expandItemHandler", kind="method")]

//--------------------------------------
//  events
//--------------------------------------

[Exclude(name="click", kind="event")]
[Exclude(name="doubleClick", kind="event")]
[Exclude(name="dragComplete", kind="event")]
[Exclude(name="dragDrop", kind="event")]
[Exclude(name="dragEnter", kind="event")]
[Exclude(name="dragExit", kind="event")]
[Exclude(name="dragOver", kind="event")]
[Exclude(name="effectEnd", kind="event")]
[Exclude(name="effectStart", kind="event")]
[Exclude(name="headerRelease", kind="event")]
[Exclude(name="itemClick", kind="event")]
[Exclude(name="itemDoubleClick", kind="event")]
[Exclude(name="itemEditBegin", kind="event")]
[Exclude(name="itemEditBeginning", kind="event")]
[Exclude(name="itemEditEnd", kind="event")]
[Exclude(name="itemFocusIn", kind="event")]
[Exclude(name="itemFocusOut", kind="event")]
[Exclude(name="itemRollOut", kind="event")]
[Exclude(name="itemRollOver", kind="event")]
[Exclude(name="keyDown", kind="event")]
[Exclude(name="keyUp", kind="event")]
[Exclude(name="mouseDown", kind="event")]
[Exclude(name="mouseDownOutside", kind="event")]
[Exclude(name="mouseFocusChange", kind="event")]
[Exclude(name="mouseMove", kind="event")]
[Exclude(name="mouseOut", kind="event")]
[Exclude(name="mouseOver", kind="event")]
[Exclude(name="mouseUp", kind="event")]
[Exclude(name="mouseWheel", kind="event")]
[Exclude(name="mouseWheelOutside", kind="event")]
[Exclude(name="rollOut", kind="event")]
[Exclude(name="rollOver", kind="event")]
[Exclude(name="toolTipCreate", kind="event")]
[Exclude(name="toolTipEnd", kind="event")]
[Exclude(name="toolTipHide", kind="event")]
[Exclude(name="toolTipShow", kind="event")]
[Exclude(name="toolTipShown", kind="event")]
[Exclude(name="toolTipStart", kind="event")]

//--------------------------------------
//  styles
//--------------------------------------

[Exclude(name="columnDropIndicatorSkin", kind="style")]
[Exclude(name="columnResizeSkin", kind="style")]
[Exclude(name="dropIndicatorSkin", kind="style")]
[Exclude(name="headerDragProxyStyleName", kind="style")]
[Exclude(name="horizontalScrollBarStyleName", kind="style")]
[Exclude(name="rollOverColor", kind="style")]
[Exclude(name="selectionColor", kind="style")]
[Exclude(name="selectionDisabledColor", kind="style")]
[Exclude(name="selectionDuration", kind="style")]
[Exclude(name="selectionEasingFunction", kind="style")]
[Exclude(name="strechCursor", kind="style")]
[Exclude(name="textRollOverColor", kind="style")]
[Exclude(name="textSelectedColor", kind="style")]
[Exclude(name="useRollOver", kind="style")]
[Exclude(name="verticalScrollBarStyleName", kind="style")]

//--------------------------------------
//  effects
//--------------------------------------

[Exclude(name="addedEffect", kind="effect")]
[Exclude(name="creationCompleteEffect", kind="effect")]
[Exclude(name="focusInEffect", kind="effect")]
[Exclude(name="focusOutEffect", kind="effect")]
[Exclude(name="hideEffect", kind="effect")]
[Exclude(name="mouseDownEffect", kind="effect")]
[Exclude(name="mouseUpEffect", kind="effect")]

[Exclude(name="moveEffect", kind="effect")]
[Exclude(name="removedEffect", kind="effect")]
[Exclude(name="resizeEffect", kind="effect")]
[Exclude(name="rollOutEffect", kind="effect")]
[Exclude(name="rollOverEffect", kind="effect")]
[Exclude(name="showEffect", kind="effect")]

/**
 *  The PrintOLAPDataGrid control is an OLAPDataGrid subclass that is styled
 *  to show a table with line borders and is optimized for printing. 
 *  It can automatically size to properly fit its container, and removes 
 *  any partially displayed rows.
 *
 *  @mxml
 * 
 *  <p>The <code>&lt;mx:PrintOLAPDataGrid&gt;</code> tag inherits the tag attributes
 *  of its superclass; however, you do not use the properties, styles, events,
 *  and effects (or methods) associated with user interaction.
 *  The <code>&lt;mx:PrintOLAPDataGrid&gt;</code> tag adds the following tag attribute:
 *  </p>
 *  <pre>
 *  &lt;mx:PrintOLAPDataGrid
 *    <b>Properties</b>
 *    allowInteraction="true|false"
 *    sizeToPage="true|false"
 *    source="null"
 *  &gt; 
 *  ...
 *  &lt;/mx:PrintOLAPDataGrid&gt;
 *  </pre>
 * 
 *  @see mx.printing.FlexPrintJob
 *  @see mx.printing.PrintDataGrid
 *  @see mx.printing.PrintAdvancedDataGrid
 *  @see mx.controls.OLAPDataGrid
 * 
 *  @includeExample examples/OLAPPrintDataGridExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class PrintOLAPDataGrid extends OLAPDataGrid
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
     *  <p>Constructs a PrintOLAPDataGrid control with no scroll bars, user interactivity,
     *  column sorting, resizing, drag scrolling, selection, or keyboard
     *  interaction.
     *  The default height is 100% of the container height, or the height 
     *  required to display all the data provider rows, whichever is smaller.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function PrintOLAPDataGrid()
    {
        super();

        horizontalScrollPolicy = ScrollPolicy.OFF;
        verticalScrollPolicy = ScrollPolicy.OFF;
        sortableColumns = false;
        selectable = false;
        // to disable dragScrolling
        dragEnabled = true;
        resizableColumns = false;
        mouseChildren = false;
        super.percentHeight = 100;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Previous Page row count.
     */
    private var previousPageRowCount:int = 0;

    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  height
    //----------------------------------

    [Bindable("heightChanged")]
    [Inspectable(category="General")]
    [PercentProxy("percentHeight")]

    /**
     *  @private
     *  Getter needs to be overridden if setter is overridden.
     */
    override public function get height():Number
    {
        return super.height;
    }

    /**
     *  @private
     *  Height setter needs to be overridden to update _originalHeight.
     */
    override public function set height(value:Number):void
    {
        _originalHeight = value;
        if (!isNaN(percentHeight))
        {
            super.percentHeight = NaN;
            measure();
            value = measuredHeight;
        }
        
        super.height = value;
        
        invalidateDisplayList();

        if (sizeToPage && !isNaN(explicitHeight))
            explicitHeight = NaN;
    }

    //----------------------------------
    //  percentHeight
    //----------------------------------

    [Bindable("resize")]
    [Inspectable(category="Size", defaultValue="NaN")]
    /**
     *  @private
     *  Getter needs to be overridden if setter is overridden.
     */
    override public function get percentHeight():Number
    {
        return super.percentHeight;
    }

    /**
     *  @private
     *  percentHeight setter needs to be overridden to update _originalHeight.
     */
    override public function set percentHeight(value:Number):void
    {
        _originalHeight = NaN;
        super.percentHeight = value;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  allowInteraction
    //----------------------------------
    
    /**
     *  Storage for the allowInteraction property.
     *  @private
     */
    private var _allowInteraction:Boolean;
    
    /**
     *  If <code>true</code>, allows some interactions with the control, 
     *  such as column resizing.
     *
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get allowInteraction():Boolean
    {
        return _allowInteraction;
    }
    
    public function set allowInteraction(value:Boolean):void
    {
        _allowInteraction = value;
        if(value)
        {
            mouseChildren = true;
            resizableColumns = true;
        }
        else
        {
            mouseChildren = false;
            resizableColumns = false;
        }
    }
    
    //----------------------------------
    //  currentPageHeight
    //----------------------------------

    /**
     *  @private
     *  Storage for the currentPageHeight property.
     */
    private var _currentPageHeight:Number;

    /**
     *  The height that the PrintOLAPDataGrid would be if the <code>sizeToPage</code> 
     *  property is <code>true</code>, meaning that the PrintOLAPDataGrid displays only completely
     *  viewable rows and displays no partial rows. 
     *  If the <code>sizeToPage</code> property 
     *  is <code>false</code>, the value of this property equals 
     *  the <code>height</code> property.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get currentPageHeight():Number
    {
        return _currentPageHeight;
    }

    //----------------------------------
    //  originalHeight
    //----------------------------------

    /**
     *  Storage for the originalHeight property.
     *  @private
     */
    private var _originalHeight:Number;

    /**
     *  The height of the PrintOLAPDataGrid as set by the user.
     *  If the <code>sizeToPage</code> property is <code>false</code>,
     *  the value of this property equals the <code>height</code> property.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get originalHeight():Number
    {
        return _originalHeight;
    }

    //----------------------------------
    //  sizeToPage
    //----------------------------------

    /**
     *  If <code>true</code>, the PrintOLAPDataGrid readjusts its height to display
     *  only completely viewable rows.
     *
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var sizeToPage:Boolean = true;
    
    //----------------------------------
    //  source
    //----------------------------------
    
    /**
     *  @private
     *  Source ADG.
     */
    private var _source:OLAPDataGrid;
    
    /**
     *  Initializes the PrintOLAPDataGrid control and all of its properties 
     *  from the specified OLAPDataGrid control. 
     * 
     *  <p><b>Note:</b> The width and height of the PrintOLAPDataGrid control  
     *  are not taken from the source OLAPDataGrid control.
     *  Changes to the source OLAPDataGrid control are not automatically reflected 
     *  in the PrintOLAPDataGrid instance.
     *  Therefore, you must reset the <code>source</code> property after changing 
     *  the source OLAPDataGrid control.</p>
     *
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get source():OLAPDataGrid
    {
        return _source;
    }
    
    /**
     *  @private
     */
    public function set source(value:OLAPDataGrid):void
    {
        this.dataProvider = value.dataProvider; // set the dataProvider
        
        this.itemRenderer = value.itemRenderer; // set the itemRenderer
        this.headerRenderer = value.headerRenderer; // set the headerRenderer
        this.groupItemRenderer = value.groupItemRenderer; // set the groupItemRenderer
        
        this.lockedRowCount = value.lockedRowCount; // set lockedRowCount
        
        this.wordWrap = value.wordWrap; // set wordWrap
        this.variableRowHeight = value.variableRowHeight; // set variableRowHeight
        
        this.defaultCellString = value.defaultCellString; // set the defaultCellString
        this.headerRendererProviders = value.headerRendererProviders; // set the headerRendererProviders 
        this.itemRendererProviders = value.itemRendererProviders; // set the itemRendererProviders 
        
        this.setStyle("columnAxisHeaderStyleName",value.getStyle("columnAxisHeaderStyleName")); // style
        this.setStyle("rowAxisHeaderStyleName",value.getStyle("rowAxisHeaderStyleName")); // style
        
        itemsSizeChanged = true;
        
        // invalidate everything
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
        
    }

    //----------------------------------
    //  validNextPage
    //----------------------------------

    /**
     *  Indicates that the data provider contains additional data rows that follow 
     *  the rows that the PrintOLAPDataGrid control currently displays.
     *
     *  @return A Boolean value of <code>true</code> if a set of rows is 
     *  available else <code>false</false>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get validNextPage():Boolean
    {
        var vPos:int = verticalScrollPosition + rowCount ;
            
        return dataProvider && vPos < getLength() ? true : false;
    }
    
    //----------------------------------
    //  validPreviousPage
    //----------------------------------

    /**
     *  Indicates that the data provider contains data rows that precede 
     *  the rows that the PrintOLAPDataGrid control currently displays.
     *
     *  @return A Boolean value of <code>true</code> if a set of rows is 
     *  available else <code>false</false>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get validPreviousPage():Boolean
    {
        var vPos:int = verticalScrollPosition - previousPageRowCount ;
            
        return dataProvider && vPos >= 0 ? true : false;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: UIComponent
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Sets the default number of display rows to dataProvider.length.
     */
    override protected function measure():void
    {
        var oldRowCount:uint = rowCount;

        var count:uint;
        
        count = (dataProvider) ? getLength() : 0;
        
        // Headers should show even if there is no dataProvider
        if (count == 0 && headerVisible)
        	count++;

        if (count >= verticalScrollPosition)
            count -= verticalScrollPosition;
        else
            count = 0;

        setRowCount(count);

        // need to calculate rowCount before super()
        super.measure();
        measureHeight();

        if (isNaN(_originalHeight))
            _originalHeight = measuredHeight;
        _currentPageHeight = measuredHeight;

        if (!sizeToPage)
        {
            setRowCount(oldRowCount);
            super.measure();
        }
    }

    /**
     *  @private
     *  setActualSize() is overridden to update _originalHeight.
     */
    override public function setActualSize(w:Number, h:Number):void
    {
        if (!isNaN(percentHeight))
        {
            _originalHeight = h;
            super.percentHeight = NaN;
            measure();
            h = measuredHeight;
        }

        super.setActualSize(w, h);
        
        invalidateDisplayList();

        if (sizeToPage && !isNaN(explicitHeight))
            explicitHeight = NaN;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: ListBase
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Overridden configureScrollBars to disable autoScrollUp.
     */
    override protected function configureScrollBars():void
    {
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Puts the next set of data rows in view;
     *  that is, it sets the PrintOLAPDataGrid <code>verticalScrollPosition</code>
     *  property to equal <code>verticalScrollPosition</code> + (number of scrollable rows).
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function nextPage():void
    {
        previousPageRowCount = rowCount - lockedRowCount;
        
        if (verticalScrollPosition < getLength())
        {
            verticalScrollPosition += rowCount - lockedRowCount;
            // this can be avoided - look into it again
            itemsSizeChanged = true;
            invalidateSize();
            invalidateDisplayList();
        }
    }
    
    /**
     *  Puts the previous set of data rows in view;
     *  that is, it sets the PrintOLAPDataGrid <code>verticalScrollPosition</code>
     *  property to equal <code>verticalScrollPosition</code> - (number of rows in the previous page).
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function previousPage():void
    {
        if (verticalScrollPosition > 0)
        {
            verticalScrollPosition = Math.max(0, (verticalScrollPosition - previousPageRowCount));
            
            invalidateSize();
            invalidateDisplayList();
        }
    }

    /**
     *  @private
     *  ListBase.measure() does'nt calculate measuredHeight in required way
     *  so have to add the code here.
     */
    private function measureHeight():void
    {   
        if( dataProvider && getLength() > 0 
            && (verticalScrollPosition >= getLength()))
        {
            setRowCount(0);
            measuredHeight = 0;
            measuredMinHeight = 0;
            return;
        }

        var o:EdgeMetrics = viewMetrics;
        var rc:int = (explicitRowCount < 1) ? rowCount : explicitRowCount;

        var maxHeight:Number = isNaN(_originalHeight) ? -1 
                                : _originalHeight - o.top - o.bottom;

        measuredHeight = measureHeightOfItemsUptoMaxHeight(
            -1, rc, maxHeight) + o.top + o.bottom;

        measuredMinHeight = measureHeightOfItemsUptoMaxHeight(
            -1, Math.min(rc, 2), maxHeight) + o.top + o.bottom;
    }
    
    /**
     *  Moves to the first page of the PrintOLAPDataGrid control,
     *  which corresponds to the first set of visible rows. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function moveToFirstPage():void
    {
        // move the iterator to the first position
        // this is done because when nextPage() is called without
        // checking for validNextPage(), listItems becomes empty after the last page
        // and the iterator is not seeked to the desired position.
        iterator.seek(CursorBookmark.FIRST);
        verticalScrollPosition = 0;
        
        invalidateSize();
        invalidateDisplayList();
    }
    
    private function getLength():int
    {
    	var result:IOLAPResult = dataProvider as IOLAPResult;
    	var rowAxis:IOLAPResultAxis = result.getAxis(OLAPQuery.ROW_AXIS);
    	
    	return rowAxis.positions.length;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden event handlers: UIComponent
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Overridden keyDown to disable keyboard functionality.
     */
    override protected function keyDownHandler(event:KeyboardEvent):void
    {
    }
}

}