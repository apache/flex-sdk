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

package mx.controls
{

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.ui.Keyboard;
import flash.utils.Dictionary;
import flash.utils.describeType;
import flash.utils.getTimer;

import mx.collections.CursorBookmark;
import mx.collections.ICollectionView;
import mx.collections.ISort;
import mx.collections.ISortField;
import mx.collections.IViewCursor;
import mx.collections.ItemResponder;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.collections.errors.ItemPendingError;
import mx.controls.advancedDataGridClasses.AdvancedDataGridBase;
import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
import mx.controls.advancedDataGridClasses.AdvancedDataGridDragProxy;
import mx.controls.advancedDataGridClasses.AdvancedDataGridHeaderInfo;
import mx.controls.advancedDataGridClasses.AdvancedDataGridHeaderRenderer;
import mx.controls.advancedDataGridClasses.AdvancedDataGridItemRenderer;
import mx.controls.advancedDataGridClasses.AdvancedDataGridListData;
import mx.controls.advancedDataGridClasses.AdvancedDataGridSortItemRenderer;
import mx.controls.advancedDataGridClasses.SortInfo;
import mx.controls.listClasses.IDropInListItemRenderer;
import mx.controls.listClasses.IListItemRenderer;
import mx.controls.listClasses.ListBaseSeekPending;
import mx.controls.listClasses.ListBaseSelectionData;
import mx.controls.listClasses.ListRowInfo;
import mx.controls.scrollClasses.ScrollBar;
import mx.core.ClassFactory;
import mx.core.ContextualClassFactory;
import mx.core.EdgeMetrics;
import mx.core.EventPriority;
import mx.core.FlexShape;
import mx.core.FlexSprite;
import mx.core.IBorder;
import mx.core.IFactory;
import mx.core.IFlexDisplayObject;
import mx.core.IFlexModuleFactory;
import mx.core.IIMESupport;
import mx.core.IInvalidating;
import mx.core.IPropertyChangeNotifier;
import mx.core.IUIComponent;
import mx.core.LayoutDirection;
import mx.core.ScrollPolicy;
import mx.core.UIComponent;
import mx.core.UIComponentGlobals;
import mx.core.mx_internal;
import mx.events.AdvancedDataGridEvent;
import mx.events.AdvancedDataGridEventReason;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.DragEvent;
import mx.events.IndexChangedEvent;
import mx.events.ListEvent;
import mx.events.SandboxMouseEvent;
import mx.events.ScrollEvent;
import mx.events.ScrollEventDetail;
import mx.events.ScrollEventDirection;
import mx.managers.CursorManager;
import mx.managers.CursorManagerPriority;
import mx.managers.IFocusManager;
import mx.managers.IFocusManagerComponent;
import mx.skins.halo.DataGridColumnDropIndicator;
import mx.styles.ISimpleStyleClient;
import mx.utils.ObjectUtil;
import mx.utils.StringUtil;

use namespace mx_internal;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the user releases the mouse button while over an item 
 *  renderer, tabs to the AdvancedDataGrid control or within the AdvancedDataGrid control, 
 *  or in any other way attempts to edit an item.
 *
 *  @eventType mx.events.AdvancedDataGridEvent.ITEM_EDIT_BEGINNING
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="itemEditBeginning", type="mx.events.AdvancedDataGridEvent")]

/**
 *  Dispatched when the <code>editedItemPosition</code> property has been set
 *  and the item can be edited.
 *
 *  @eventType mx.events.AdvancedDataGridEvent.ITEM_EDIT_BEGIN
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="itemEditBegin", type="mx.events.AdvancedDataGridEvent")]

/**
 *  Dispatched when an item editing session ends for any reason.
 *
 *  @eventType mx.events.AdvancedDataGridEvent.ITEM_EDIT_END
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="itemEditEnd", type="mx.events.AdvancedDataGridEvent")]

/**
 *  Dispatched when an item renderer gets focus, which can occur if the user
 *  clicks on an item in the AdvancedDataGrid control or navigates to the item using
 *  a keyboard.  Only dispatched if the item is editable.
 *
 *  @eventType mx.events.AdvancedDataGridEvent.ITEM_FOCUS_IN
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="itemFocusIn", type="mx.events.AdvancedDataGridEvent")]

/**
 *  Dispatched when an item renderer loses focus, which can occur if the user
 *  clicks another item in the AdvancedDataGrid control or clicks outside the control,
 *  or uses the keyboard to navigate to another item in the AdvancedDataGrid control
 *  or outside the control.
 *  Only dispatched if the item is editable.
 *
 *  @eventType mx.events.AdvancedDataGridEvent.ITEM_FOCUS_OUT
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="itemFocusOut", type="mx.events.AdvancedDataGridEvent")]

/**
 *  Dispatched when a user changes the width of a column, indicating that the 
 *  amount of data displayed in that column may have changed.
 *  If <code>horizontalScrollPolicy</code> is <code>"none"</code>, other
 *  columns shrink or expand to compensate for the columns' resizing,
 *  and they also dispatch this event.
 *
 *  @eventType mx.events.AdvancedDataGridEvent.COLUMN_STRETCH
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="columnStretch", type="mx.events.AdvancedDataGridEvent")]

/**
 *  Dispatched when the user releases the mouse button on a column header
 *  to request the control to sort
 *  the grid contents based on the contents of the column.
 *  Only dispatched if the column is sortable and the data provider supports 
 *  sorting. The AdvancedDataGrid control has a default handler for this event that implements
 *  a single-column sort.  Multiple-column sort can be implemented by calling the 
 *  <code>preventDefault()</code> method to prevent the single column sort and setting 
 *  the <code>sort</code> property of the data provider.
 * <p>
 * <b>Note</b>: The sort arrows are defined by the default event handler for
 * the <code>headerRelease</code> event. If you call the <code>preventDefault()</code> method
 * in your event handler, the arrows are not drawn.
 * </p>
 *
 *  @eventType mx.events.AdvancedDataGridEvent.HEADER_RELEASE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="headerRelease", type="mx.events.AdvancedDataGridEvent")]

/**
 *  Dispatched when sorting is to be performed on the AdvancedDataGrid control.
 *
 *  @eventType mx.events.AdvancedDataGridEvent.SORT
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="sort", type="mx.events.AdvancedDataGridEvent")]

/**
 *  Dispatched when the user releases the mouse button on a column header after 
 *  having dragged the column to a new location resulting in shifting the column
 *  to a new index
 *
 *  @eventType mx.events.IndexChangedEvent.HEADER_SHIFT
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="headerShift", type="mx.events.IndexChangedEvent")]

//--------------------------------------
//  Styles
//--------------------------------------

include "../styles/metadata/IconColorStyles.as"

/**
 *  Name of the class of the itemEditor to be used if one is not
 *  specified for a column.  This is a way to set
 *  an item editor for a group of AdvancedDataGrids instead of having to
 *  set each one individually.  If you set the AdvancedDataGridColumn's itemEditor
 *  property, it supercedes this value.
 *  @default null
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="defaultDataGridItemEditor", type="Class", inherit="no")]

/**
 *  Name of the class of the itemRenderer to be used if one is not
 *  specified for a column.  This is a way to set
 *  an itemRenderer for a group of AdvancedDataGrids instead of having to
 *  set each one individually.  If you set the AdvancedDataGrid's itemRenderer
 *  property, it supercedes this value.
 *  @default null
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="defaultDataGridItemRenderer", type="Class", inherit="no")]

/**
 *  A flag that indicates whether to show vertical grid lines between
 *  the columns.
 *  If <code>true</code>, shows vertical grid lines.
 *  If <code>false</code>, hides vertical grid lines.
 *  @default true
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="verticalGridLines", type="Boolean", inherit="no")]

/**
 *  A flag that indicates whether to show horizontal grid lines between
 *  the rows.
 *  If <code>true</code>, shows horizontal grid lines.
 *  If <code>false</code>, hides horizontal grid lines.
 *  @default false
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="horizontalGridLines", type="Boolean", inherit="no")]

/**
 *  The color of the vertical grid lines.
 *  @default 0x666666
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="verticalGridLineColor", type="uint", format="Color", inherit="yes")]

/**
 *  The color of the horizontal grid lines.
  *  
  *  @langversion 3.0
  *  @playerversion Flash 9
  *  @playerversion AIR 1.1
  *  @productversion Flex 3
  */
[Style(name="horizontalGridLineColor", type="uint", format="Color", inherit="yes")]

/**
 *  An array of two colors used to draw the header background gradient.
 *  The first color is the top color.
 *  The second color is the bottom color.
 *  @default [0xFFFFFF, 0xE6E6E6]
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="headerColors", type="Array", arrayType="uint", format="Color", inherit="yes")]

/**
 *  The color of the row background when the user rolls over the row.
 *  @default 0xE3FFD6
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="rollOverColor", type="uint", format="Color", inherit="yes")]

/**
 *  The color of the background for the row when the user selects 
 *  an item renderer in the row.
 *  @default 0xCDFFC1
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="selectionColor", type="uint", format="Color", inherit="yes")]

/**
 *  The name of a CSS style declaration for controlling other aspects of
 *  the appearance of the column headers.
 *  @default "dataGridStyles"
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="headerStyleName", type="String", inherit="no")]

/**
 *  The class to use as the skin for a column that is being resized.
 * 
 *  @default mx.skins.halo.DataGridColumnResizeSkin (for both Halo and Spark themes)
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="columnResizeSkin", type="Class", inherit="no")]


/**
 *  The class to use as the skin that defines the appearance of the  
 *  background of the column headers in a AdvancedDataGrid control.
 * 
 *  <p>The default skin class is based on the theme. For example, with the Halo theme,
 *  the default skin class is <code>mx.skins.halo.DataGridHeaderBackgroundSkin</code>. For the Spark theme, the default skin
 *  class is <code>mx.skins.spark.DataGridHeaderBackgroundSkin</code>.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="headerBackgroundSkin", type="Class", inherit="no")]

/**
 *  The class to use as the skin that defines the appearance of the 
 *  separator between column headers in a AdvancedDataGrid control.
 *  
  *  <p>The default skin class is based on the theme. For example, with the Halo theme,
 *  the default skin class is <code>mx.skins.halo.DataGridHeaderSeparator</code>. For the Spark theme, the default skin
 *  class is <code>mx.skins.spark.DataGridHeaderSeparatorSkin</code>.</p>
*  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="headerSeparatorSkin", type="Class", inherit="no")]

/**
 *  The class to use as the skin that defines the appearance of the 
 *  separator between a column group and its children columns/column group headers
 *  in an AdvancedDataGrid control.
 *  @default mx.skins.halo.AdvancedDataGridHeaderHorizontalSeparator
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="headerHorizontalSeparatorSkin", type="Class", inherit="no")]

/**
 *  The class to use as the skin that defines the appearance of the 
 *  separator between rows in a AdvancedDataGrid control. 
 *  By default, the AdvancedDataGrid control uses the 
 *  <code>drawHorizontalLine()</code> and <code>drawVerticalLine()</code> methods
 *  to draw the separators.
 *
 *  @default undefined
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="horizontalSeparatorSkin", type="Class", inherit="no")]

/**
 *  The class to use as the skin that defines the appearance of the 
 *  separator between the locked and unlocked rows in a AdvancedDataGrid control.
 *  By default, the AdvancedDataGrid control uses the 
 *  <code>drawHorizontalLine()</code> and <code>drawVerticalLine()</code> methods
 *  to draw the separators.
 *
 *  @default undefined
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="horizontalLockedSeparatorSkin", type="Class", inherit="no")]

/**
 *  The class to use as the skin that defines the appearance of the 
 *  separators between columns in a AdvancedDataGrid control.
 *  By default, the AdvancedDataGrid control uses the 
 *  <code>drawHorizontalLine()</code> and <code>drawVerticalLine()</code> methods
 *  to draw the separators.
 *
 *  @default undefined
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="verticalSeparatorSkin", type="Class", inherit="no")]

/**
 *  The class to use as the skin that defines the appearance of the 
 *  separator between the locked and unlocked columns in a AdvancedDataGrid control.
 *  By default, the AdvancedDataGrid control uses the 
 *  <code>drawHorizontalLine()</code> and <code>drawVerticalLine()</code> methods
 *  to draw the separators.
 *
 *  @default undefined
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="verticalLockedSeparatorSkin", type="Class", inherit="no")]

/**
 *  The class to use as the skin for the cursor that indicates that a column
 *  can be resized.
 *  @default mx.skins.halo.DataGridStretchCursor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="stretchCursor", type="Class", inherit="no")]

/**
 *  The class to use as the skin that indicates that 
 *  a column can be dropped in the current location.
 *
 *  @default mx.skins.halo.DataGridColumnDropIndicator (for both Halo and Spark themes)
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="columnDropIndicatorSkin", type="Class", inherit="no")]

/**
 *  The name of a CSS style declaration for controlling aspects of the
 *  appearance of column when the user is dragging it to another location.
 *
 *  @default "headerDragProxyStyle"
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="headerDragProxyStyleName", type="String", inherit="no")]

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="columnCount", kind="property")]
[Exclude(name="labelField", kind="property")]
[Exclude(name="offscreenExtraRowsOrColumns", kind="property")]
[Exclude(name="offscreenExtraRows", kind="property")]
[Exclude(name="offscreenExtraRowsTop", kind="property")]
[Exclude(name="offscreenExtraRowsBottom", kind="property")]
[Exclude(name="offscreenExtraColumns", kind="property")]
[Exclude(name="offscreenExtraColumnsLeft", kind="property")]
[Exclude(name="offscreenExtraColumnsRight", kind="property")]
[Exclude(name="offscreenExtraRowsOrColumnsChanged", kind="property")]
[Exclude(name="maxHorizontalScrollPosition", kind="property")]
[Exclude(name="maxVerticalScrollPosition", kind="property")]
[Exclude(name="showDataTips", kind="property")]
[Exclude(name="cornerRadius", kind="style")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[DataBindingInfo("acceptedTypes", "{ dataProvider: &quot;String&quot; }")]

[DefaultBindingProperty(source="selectedItem", destination="dataProvider")]

[DefaultProperty("dataProvider")]

[DefaultTriggerEvent("change")]

[IconFile("AdvancedDataGrid.png")]

[RequiresDataBinding(true)]

/**
 * The AdvancedDataGridBaseEx class is a base class of the AdvancedDataGrid control. 
 * This class contains code that provides functionality similar to the DataGrid control.
 * 
 *  @mxml
 *  <p>
 *  The <code>&lt;mx:AdvancedDataGridBaseEx&gt;</code> tag inherits all of the tag attributes
 *  of its superclass, except for <code>labelField</code>, <code>iconField</code>,
 *  and <code>iconFunction</code>, and adds the following tag attributes:
 *  </p>
 *  <pre>
 *  &lt;mx:AdvancedDataGridBaseEx
 *    <b>Properties</b>
 *    columns="<i>From dataProvider</i>"
 *    draggableColumns="true|false"
 *    editable="item group summary"
 *    editedItemPosition="<code>null</code>"
 *    horizontalScrollPosition="null"
 *    imeMode="null"
 *    itemEditorInstance="null"
 *    lookAheadDuratio="400"
 *    minColumnWidth="<code>NaN</code>"
 *    resizableColumns="true|false"
 *    sortableColumns="true|false"
 *    sortExpertMode="false|true"
 *     
 *    <b>Styles</b>
 *    columnDropIndicatorSkin="DataGridColumnDropIndicator"
 *    columnResizeSkin="DataGridColumnResizeSkin"
 *    disabledIconColor="0x999999"
 *    headerBackgroundSkin="DataGridHeaderSeparator"
 *    headerColors="[#FFFFFF, #E6E6E6]"
 *    headerDragProxyStyleName="headerDragProxyStyle"
 *    headerHorizontalSeparatorSkin="AdvancedDataGridHeaderHorizontalSeparator"
 *    headerSeparatorSkin="DataGridHeaderSeparator"
 *    headerStyleName="<i>No default</i>"
 *    horizontalGridLineColor="<i>No default</i>"
 *    horizontalGridLines="false|true"
 *    horizontalLockedSeparatorSkin="undefined"
 *    horizontalSeparatorSkin="undefined"
 *    iconColor="0x111111"
 *    rollOverColor="#E3FFD6"
 *    selectionColor="#CDFFC1"
 *    stretchCursor="DataGridStretchCursor"
 *    verticalGridLineColor="#666666"
 *    verticalGridLines="false|true"
 *    verticalLockedSeparatorSkin="undefined"
 *    verticalSeparatorSkin="undefined"
 *     
 *    <b>Events</b>
 *    columnStretch="<i>No default</i>"
 *    headerRelease="<i>No default</i>"
 *    headerShift="<i>No default</i>"
 *    itemEditBegin="<i>No default</i>"
 *    itemEditBeginning="<i>No default</i>" 
 *    itemEditEnd="<i>No default</i>"
 *    itemFocusIn="<i>No default</i>"
 *    itemFocusOut="<i>No default</i>"
 *  /&gt;
 *   
 *  <i>The following AdvancedDataGrid code sample specifies the column order:</i>
 *  &lt;mx:AdvancedDataGrid&gt;
 *    &lt;mx:dataProvider&gt;
 *        &lt;mx:Object Artist="Pavement" Price="11.99"
 *          Album="Slanted and Enchanted"/&gt;
 *        &lt;mx:Object Artist="Pavement"
 *          Album="Brighten the Corners" Price="11.99"/&gt;
 *    &lt;/mx:dataProvider&gt;
 *    &lt;mx:columns&gt;
 *        &lt;mx:AdvancedDataGridColumn dataField="Album"/&gt;
 *        &lt;mx:AdvancedDataGridColumn dataField="Price"/&gt;
 *    &lt;/mx:columns&gt;
 *  &lt;/mx:AdvancedDataGrid&gt;
 *  </pre>
 *  </p>
 * 
 * @see mx.controls.AdvancedDataGrid
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class AdvancedDataGridBaseEx extends AdvancedDataGridBase implements IIMESupport
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  TODO!!! Replace with global versioning infrastructure
     */
    public static var useOldDGHeaderBGLogic:Boolean = false;
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function AdvancedDataGridBaseEx()
    {
        super();

        _columns = [];
        
        headerRenderer = new ClassFactory(AdvancedDataGridHeaderRenderer);
        sortItemRenderer = new ClassFactory(AdvancedDataGridSortItemRenderer);

        // pick a default row height
        setRowHeight(20);

        // Register default handlers for item editing and sorting events.

        addEventListener(AdvancedDataGridEvent.ITEM_EDIT_BEGINNING,
                         itemEditorItemEditBeginningHandler,
                         false, EventPriority.DEFAULT_HANDLER);

        addEventListener(AdvancedDataGridEvent.ITEM_EDIT_BEGIN,
                         itemEditorItemEditBeginHandler,
                         false, EventPriority.DEFAULT_HANDLER);

        addEventListener(AdvancedDataGridEvent.ITEM_EDIT_END,
                         itemEditorItemEditEndHandler,
                         false, EventPriority.DEFAULT_HANDLER);

        addEventListener(AdvancedDataGridEvent.HEADER_RELEASE,
                         headerReleaseHandler,
                         false, EventPriority.DEFAULT_HANDLER);

        addEventListener(AdvancedDataGridEvent.SORT,
                         sortHandler,
                         false, EventPriority.DEFAULT_HANDLER);

        addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);                         
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  true if we want to block editing on mouseUp
     */
    private var dontEdit:Boolean = false;

    /**
     *  @private
     *  true if we want to block editing on mouseUp
     */
    private var losingFocus:Boolean = false;
    
    /**
     *  @private
     */
    private var _focusPane:Sprite;

    /**
     *  @private
     *  true if we're in the endEdit call.  Used to handle
     *  some timing issues with collection updates
     */
    private var inEndEdit:Boolean = false;

    /**
     *  @private
     *  true if we've disabled updates in the collection
     */
    private var collectionUpdatesDisabled:Boolean = false;

    /**
     *  Specifies a graphic that shows the proposed column width as the user stretches it.
     *  
     *  @private
     */
    private var resizeGraphic:IFlexDisplayObject; //

    /**
     *  @private
     *  A tmp var to store the stretching col's X coord.
     */
    private var startX:Number;

    /**
     *  @private
     *  A tmp var to store the stretching col's min X coord for column's minWidth.
     */
    private var minX:Number;
    
    /**
     *  @private
     *  A tmp var to store the last point (in dataGrid coords) received while dragging.
     */
    private var lastPt:Point;

    /**
     *  @private
     *  List of header separators for column resizing.
     */
    private var separators:Array;

    /**
     *  @private
     *  List of header separators for column resizing in the locked column area.
     */
    protected var lockedSeparators:Array;

    /**
     *  @private
     *  The column that is being resized.
     */
    private var resizingColumn:AdvancedDataGridColumn;

    /**
     *  @private
     *  The index of the column being sorted.
     */
    private var sortIndex:int = -1;

    /**
     *  @private
     *  The column being sorted.
     */
    private var sortColumn:AdvancedDataGridColumn;

    /**
     *  @private
     *  The direction of the sort
     */
    private var sortDirection:String;

    /**
     *  @private
     *  The index of the last column being sorted on.
     */
    private var lastSortIndex:int = -1;

    /**
     *  @private
     */
    private var lastItemDown:IListItemRenderer;

    /**
     *  @private
     *  The column that is being moved.
     */
    protected var movingColumn:AdvancedDataGridColumn;

    /**
     *  @private
     *  Index of column before which to drop
     */
    protected var dropColumnIndex:int = -1;

    /**
     *  @private
     */
    mx_internal var columnDropIndicator:IFlexDisplayObject;

    /**
     *  @private
     */
    private var displayWidth:Number;

    /**
     *  @private
     *  Additional affordance given to header separators.
     */
    private var separatorAffordance:Number = 3;


    /**
     *  @private
     *  Columns with visible="true"
     */
    protected var displayableColumns:Array;
    /**
     *  @private
     *  Whether we have auto-generated the set of columns
     *  Defaults to true so we'll run the auto-generation at init time if needed
     */
    protected var generatedColumns:Boolean = true;

    /**
     *  @private
     *  A hash table of objects used to calculate sizes
     */
    protected var measuringObjects:Dictionary;

    /**
     *  @private
     */
    private var resizeCursorID:int = CursorManager.NO_CURSOR;

    // last known position of item editor instance
    private var actualRowIndex:int;
    private var actualColIndex:int;

    /**
     *  @private
     *  Flag to indicate whether sorting is manual or programmatic.  If it's
     *  not manual, we try to draw the sort arrow on the right column header.
     */
    private var manualSort:Boolean;

    /**
     *  An ordered list of AdvancedDataGridHeaderInfo instances that 
     *  correspond to the visible column headers.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected var orderedHeadersList:Array = [];

    /**
     * Contains <code>true</code> if the <code>headerInfos</code> property 
     * has been initialized with AdvancedDataGridHeaderInfo instances.
     *
     * @see mx.controls.advancedDataGridClasses.AdvancedDataGridHeaderInfo 
     *
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected var headerInfoInitialized:Boolean = false;

    /**
     *  Contains <code>true</code> if a key press is in progress.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected var isKeyPressed:Boolean = false;
    
    /**
     *  @private
     *  Stores the last typed character(s)
     *  for multiple characters type ahead lookup.
     */
    private var lookAheadCache:String = "";
    
    /**
     *  @private
     *  Stores the time of the last typed character
     *  for multiple characters type ahead lookup.
     */
    private var previousTime:uint;

    private var headerBGSkinChanged:Boolean = false;

    private var headerSepSkinChanged:Boolean = false;
    
    private var columnsChanged:Boolean = false;
    
    /**
     *  @private
     *  Set to true when the view is scrolled and
     *  optimumColumns != visibleColumns
     */
    private var subContentScrolled:Boolean = false;
    
    /**
     *  @private
     */
    private var minColumnWidthInvalid:Boolean = false;
    
    /**
     *  @private
     */
    private var bEditedItemPositionChanged:Boolean = false;

    /**
     *  @private
     *  undefined means we've processed it
     *  null means don't put up an editor
     *  {} is the coordinates for the editor
     */
    private var _proposedEditedItemPosition:*;

    /**
     *  @private
     *  the last editedItemPosition.  We restore editing
     *  to this point if we get focus from the TAB key
     */
    private var lastEditedItemPosition:*;
    
    private var _headerWordWrapPresent:Boolean = false;
    private var _originalExplicitHeaderHeight:Boolean = false;
    private var _originalHeaderHeight:Number = 0;
    
    /**
     *  @private
     *  true if based on mouse position, a dropIndex has been found
     */
    private var dropIndexFound:Boolean = false;
    
    /**
     *  @private
     *  true if header getting dragged is outside the permissible area
     */
    private var isHeaderDragOutside:Boolean = false;
    
    /**
     *  The AdvancedDataGridHeaderInfo instances that 
     *  correspond to the currently selected column header.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    mx_internal var selectedHeaderInfo:AdvancedDataGridHeaderInfo;

    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  itemRenderer
    //----------------------------------
    
    /**
    * @private
    * 
    * Defer creation of the class factory to give a chance for the moduleFactory to be set.
    */
    override public function get itemRenderer():IFactory
    {
        if (super.itemRenderer == null)
        {
            var fontName:String = StringUtil.trimArrayElements(getStyle("fontFamily"),",");
            var fontWeight:String = getStyle("fontWeight");
            var fontStyle:String = getStyle("fontStyle");
            var bold:Boolean = (fontWeight == "bold");
            var italic:Boolean = (fontStyle == "italic");
            var flexModuleFactory:IFlexModuleFactory = getFontContext(fontName, bold, italic);
            
            var c:Class = getStyle("defaultDataGridItemRenderer");
            if (!c)
                c = AdvancedDataGridItemRenderer;
            
            super.itemRenderer = new ContextualClassFactory(c, flexModuleFactory);
            
        }
        
        return super.itemRenderer;
    }
    
    //----------------------------------
    //  baselinePosition
    //----------------------------------

    /**
     *  @private
     */
    override public function get baselinePosition():Number
    {
        var top:Number = 0;

        if (border && border is IBorder)
            top = IBorder(border).borderMetrics.top;

        return top + measureText(" ").ascent;
    }

    /**
     *  @private
     *  Number of columns that can be displayed.
     *  Some may be offscreen depending on horizontalScrollPolicy
     *  and the width of the AdvancedDataGrid.
     */
    override  public function get columnCount():int
    {
        if (_columns)
            return _columns.length;
        else
            return 0;
    }

    //----------------------------------
    //  enabled
    //----------------------------------

    [Inspectable(category="General", enumeration="true,false", defaultValue="true")]

    /**
     *  @private
     */
    override public function set enabled(value:Boolean):void
    {
        super.enabled = value;

        if (itemEditorInstance)
            endEdit(AdvancedDataGridEventReason.OTHER);

        invalidateDisplayList();
    }

    //----------------------------------
    //  horizontalScrollPosition
    //----------------------------------

    /**
     *  The offset into the content from the left edge. 
     *  This can be a pixel offset in some subclasses or some other metric 
     *  like the number of columns in an AdvancedDataGrid control. 
     *
     *  The AdvancedDataGrid scrolls by columns so the value of the 
     *  <code>horizontalScrollPosition</code> property is always
     *  in the range of 0 to the index of the columns
     *  that will make the last column visible.  
     *  This is different from the List control, which scrolls by pixels.  
     *  The AdvancedDataGrid control always aligns the left edge
     *  of a column with the left edge of the AdvancedDataGrid control.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function set horizontalScrollPosition(value:Number):void
    {
        // if not init or no data;
        if (!initialized || listItems.length == 0)
        {
            super.horizontalScrollPosition = value;
            return;
        }

        var oldValue:int = super.horizontalScrollPosition;
        super.horizontalScrollPosition = value;

        columnsInvalid = true;
        calculateColumnSizes();

        // we are going to get a full repaint so don't repaint now
        if (itemsSizeChanged)
            return;

        if (oldValue != value)
        {
            removeClipMask();

            if (getOptimumColumns() == visibleColumns)
            {
                //clearIndicators();
                visibleData = {};

                // columns have variable width so we need to recalc scroll parms
                scrollAreaChanged = true;

                var bookmark:CursorBookmark;
                
                if (iterator)
                    bookmark = iterator.bookmark;
                
                //if we scrolled more than the number of scrollable columns
                makeRowsAndColumns(0, 0, listContent.width, listContent.height, 0, 0);
                
                if (iterator && bookmark)
                    iterator.seek(bookmark, 0);
                
            }
            else
            {
                // In case of column grouping and
                // column span we just move the scroll rect
                subContentScrolled = true;
            }

            updateSubContent();
            updateHeaderSearchList();

            addClipMask(false);

            //an invalidation is needed, to redraw the vertical lines and separators
            invalidateDisplayList();
        }
    }
    
    //----------------------------------
    //  verticalScrollPosition
    //----------------------------------
    
    /**
     *  @private
     *  Sets verticalScrollPosition and draw horizontal lines again
     *  variableRowHeight is true.
     */
    override public function set verticalScrollPosition(value:Number):void
    {
        super.verticalScrollPosition = value;
         
        // draw the horizontal lines afresh if variableRowHeight is true
        // i.e., row height may differ for each row
        if (variableRowHeight)
            drawHorizontalSeparators();
    }
    
    //----------------------------------
    //  focusPane
    //----------------------------------
    
    /**
     *  @private
     */
    override public function set focusPane(value:Sprite):void
    {
        super.focusPane = value;
        
        if (value)
            value.scrollRect = listSubContent ? listSubContent.scrollRect : null;
        
        if (!value && _focusPane)
            _focusPane.mask = null;
        _focusPane = value;
    }

    //----------------------------------
    //  horizontalScrollPolicy
    //----------------------------------

    /**
     *  @private
     *  Accomodates ScrollPolicy.AUTO.
     *  Makes sure column widths stay in synch.
     *
     *  @param policy on, off, or auto
     */
    override public function set horizontalScrollPolicy(value:String):void
    {
        super.horizontalScrollPolicy = value;
        columnsInvalid = true;
        itemsSizeChanged = true;
        invalidateDisplayList();
    }
    
    //----------------------------------
    //  lockedColumnCount
    //----------------------------------

    /**
     *  @private
     */
    override public function set lockedColumnCount(value:int):void
    {
        var i:int = 0;
        var j:int = 0;
        var m:int = 0;
        // remove the items from columnMap, so that they can be created again
        if (value > super.lockedColumnCount)
        {
            for (i = super.lockedColumnCount; i < value ;i++)
            {
                m = listItems.length;
                for(j = 0; j < m; j++)
                {
                    if (listItems[j] && listItems[j][i])
                        delete columnMap[listItems[j][i].name];
                }
            }
        }
        else if (value < super.lockedColumnCount)
        {
            for (i = value; i < super.lockedColumnCount ;i++)
            {
                m = listItems.length;
                for(j = 0; j < m; j++)
                {
                    if (listItems[j] && listItems[j][i])
                        delete columnMap[listItems[j][i].name];
                }
            }
        } 
        super.lockedColumnCount = value;
        
        //listSubContent scrollRectneed to be changed in case lockedColumnCount has changed
        // otherwise items in the scrollrect overlap with the items which have come
        // because of change in lockedColumnCount
        updateSubContent();
        
        itemsSizeChanged = true;

        columnsInvalid = true;

        // set the horizontalScrollPosition so that all the changes are reflected correctly
        horizontalScrollPosition = super.horizontalScrollPosition;
    }
    
    //----------------------------------
    //  dragImage
    //----------------------------------
    
    /**
     *  @private
     */
    override protected function get dragImage():IUIComponent
    {
        var image:AdvancedDataGridDragProxy = new AdvancedDataGridDragProxy();
        image.owner = this;
        image.moduleFactory = moduleFactory;
        return image;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  columns
    //----------------------------------

    /**
     *  @private
     */
    // Added to AdvancedDataGridBase
    //private var _columns:Array; // the array of our AdvancedDataGridColumns

    [Bindable("columnsChanged")]
    [Inspectable(category="General", arrayType="mx.controls.advancedDataGridClasses.AdvancedDataGridColumn")]

    /**
     *  An array of AdvancedDataGridColumn objects, one for each column that
     *  can be displayed. If not explicitly set, the AdvancedDataGrid control 
     *  attempts to examine the first data provider item to determine the
     *  set of properties and display those properties in alphabetic
     *  order.
     *
     *  <p>If you want to change the set of columns, you must get this Array,
     *  make modifications to the columns and order of columns in the Array,
     *  and then assign the new Array to the <code>columns</code> property.  This is because
     *  the AdvancedDataGrid control returns a copy of the Array of columns, 
     *  not a reference, and therefore cannot detect changes to the copy.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get columns():Array
    {
        return _columns.slice(0);
    }

    /**
     *  @private
     */
    public function set columns(value:Array):void
    {
        var n:int;
        var i:int;
        
        // remove the header items
        purgeHeaderRenderers();
        
        n = _columns.length;
        for (i = 0; i < n; i++)
        {
            columnRendererChanged(_columns[i]);
        }
        
        freeItemRenderersTable = new Dictionary(false);
        itemRendererToFactoryMap = new Dictionary(true);
        columnMap = {};

        _columns = value.slice(0);
        columnsInvalid = true;
        generatedColumns = false;

        n = value.length;
        for (i = 0; i < n; i++)
        {
            var column:AdvancedDataGridColumn = _columns[i];
            column.owner = this;
            column.colNum = i;
        }

        updateSortIndexAndDirection();
        itemsSizeChanged = true;
        columnsChanged = true;
        invalidateDisplayList();
        dispatchEvent(new Event("columnsChanged"));
    }
    
    //----------------------------------
    //  draggableColumns
    //----------------------------------

    /**
     *  @private
     *  Storage for the draggableColumns property.
     */
    private var _draggableColumns:Boolean = true;

    [Inspectable(defaultValue="true")]

    /**
     *  Indicates whether you are allowed to reorder columns.
     *  If <code>true</code>, you can reorder the columns
     *  of the AdvancedDataGrid control by dragging the header cells.
     *
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get draggableColumns():Boolean
    {
        return _draggableColumns;
    }

    /**
     *  @private
     */
    public function set draggableColumns(value:Boolean):void
    {
        _draggableColumns = value;
    }
    
    //----------------------------------
    //  enableIME
    //----------------------------------
    
    /**
     *  A flag that indicates whether the IME should
     *  be enabled when the component receives focus.
     *
     *  If the editor is up, it will set enableIME
     *  accordingly.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get enableIME():Boolean
    {
        return false;
    }
    
    //----------------------------------
    //  imeMode
    //----------------------------------

    /**
     *  @private
     */
    private var _imeMode:String = null;

    [Inspectable(environment="none")]

    /**
     *  Specifies the IME (input method editor) mode.
     *  The IME mode enables users to enter text in Chinese, Japanese, and Korean.
     *  Flex sets the specified IME mode when the control gets the focus,
     *  and sets it back to the previous value when the control loses the focus.
     *
     * <p>The flash.system.IMEConversionMode class defines constants for the
     *  valid values for this property.
     *  You can also specify <code>null</code> to specify no IME.</p>
     *
     *  @see flash.system.IMEConversionMode
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get imeMode():String
    {
        return _imeMode;
    }

    /**
     *  @private
     */
    public function set imeMode(value:String):void
    {
        _imeMode = value;
    }

    //----------------------------------
    //  minColumnWidth
    //----------------------------------

    /**
     *  @private
     */
    private var _minColumnWidth:Number;

    [Inspectable(defaultValue="NaN")]

    /**
     *  The minimum width of the columns, in pixels.  If not NaN,
     *  the AdvancedDataGrid control applies this value as the minimum width for
     *  all columns.  Otherwise, individual columns can have
     *  their own minimum widths.
     *  
     *  @default NaN
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get minColumnWidth():Number
    {
        return _minColumnWidth;
    }

    /**
     *  @private
     */
    public function set minColumnWidth(value:Number):void
    {
        _minColumnWidth = value;
        minColumnWidthInvalid = true;
        itemsSizeChanged = true;
        columnsInvalid = true;
        invalidateDisplayList();
    }
    
    //----------------------------------
    //  itemEditorInstance
    //----------------------------------
    
    [Inspectable(environment="none")]

    /**
     *  A reference to the currently active instance of the item editor, 
     *  if it exists.
     *
     *  <p>To access the item editor instance and the new item value when an 
     *  item is being edited, you use the <code>itemEditorInstance</code> 
     *  property. The <code>itemEditorInstance</code> property
     *  is not valid until after the event listener for
     *  the <code>itemEditBegin</code> event executes. Therefore, you typically
     *  only access the <code>itemEditorInstance</code> property from within 
     *  the event listener for the <code>itemEditEnd</code> event.</p>
     *
     *  <p>The <code>AdvancedDataGridColumn.itemEditor</code> property defines the
     *  class of the item editor,
     *  and therefore the data type of the item editor instance.</p>
     *
     *  <p>You do not set this property in MXML.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var itemEditorInstance:IListItemRenderer;
    
    //----------------------------------
    //  editedItemRenderer
    //----------------------------------
    
    /**
     *  A reference to the item renderer
     *  in the AdvancedDataGrid control whose item is currently being edited.
     *
     *  <p>From within an event listener for the <code>itemEditBegin</code>
     *  and <code>itemEditEnd</code> events,
     *  you can access the current value of the item being edited
     *  using the <code>editedItemRenderer.data</code> property.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get editedItemRenderer():IListItemRenderer
    {
        if (!itemEditorInstance) return null;

        return listItems[actualRowIndex][actualColIndex];
    }
    
    //----------------------------------
    //  headerIndex
    //----------------------------------
    
    /**
     *  @private
     *  Storage for headerIndex
     */
    private var _headerIndex:int = -1;
    
    /**
     *  If a header is selected via keyboard.
     *
     *  headerIndex is the absolute column number i.e. index of 'columns'.
     *
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    mx_internal function set headerIndex(value:int):void
    {
        _headerIndex = value;
        
        dispatchEvent(new ListEvent(ListEvent.CHANGE));
    }
    
    mx_internal function get headerIndex():int
    {
        return _headerIndex;
        
    }

    //----------------------------------
    //  editable
    //----------------------------------

    private var _editable:String = "";

    [Inspectable(category="General")]
    /**
     *  Indicates whether or not the user can edit items in the data provider.
     *
     *  <p>If <code>"item"</code>, the item renderers in the control are editable.
     *  The user can click on an item renderer to open an editor.</p>
     *
     *  <p>If <code>"item group"</code>, the item renderers and grouping headers can be edited.</p>
     *
     *  <p>If <code>"item summary"</code>, the item renderers and summary cells can be edited.</p>
     *
     *  <p>You can combine these values. For example, <code>editable = "item group summary"</code>.
     *  Note that item editing has to be enabled if enabling group or summary editing.</p>
     *
     *  <p>If you specify an empty String, no editing is allowed.</p>
     *
     *  <p>The values <code>"true"</code> and <code>"false"</code> correspond 
     *  to item editing and no editing.</p>
     *
     *  <p>A value of <code>"all"</code> means everything is editable.</p>
     *
     *  <p>You can turn off editing for individual columns of the
     *  AdvancedDataGrid control using the <code>AdvancedDataGridColumn.editable</code> property,
     *  or by handling the <code>itemEditBeginning</code> and
     *  <code>itemEditBegin</code> events.</p>
     *
     *  @default ""
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get editable():String
    {
        return _editable;
    }

    public function set editable(value:String):void
    {
        _editable = "";

        if (!value)
            return;

        var editableFlags:Array = value.split(" "); // space delimited
        var n:int = editableFlags.length;
        var keepProcessingFlags:Boolean = true;

        for (var i:int = 0; i < n && keepProcessingFlags; i++)
        {
            switch (editableFlags[i])
            {
                case "item":
                case "group":
                case "summary":
                    {
                        _editable += editableFlags[i] + " ";
                        break;
                    }

                case "true":
                    {
                        _editable = "item" + " ";
                        keepProcessingFlags = false;
                        break;
                    }

                case "false":
                    {
                        _editable = "" + " ";
                        keepProcessingFlags = false;
                        break;
                    }

                case "all":
                    {
                        _editable = "item group summary" + " ";
                        keepProcessingFlags = false;
                        break;
                    }
            }
        }
        _editable = _editable.slice(0, -1); // remove trailing space
    }

    //----------------------------------
    //  editedItemPosition
    //----------------------------------

    /**
     *  @private
     */
    private var _editedItemPosition:Object;

    [Bindable("itemFocusIn")]

    /**
     *  The column and row index of the item renderer for the
     *  data provider item being edited, if any.
     *
     *  <p>This Object has two fields, <code>columnIndex</code> and 
     *  <code>rowIndex</code>,
     *  the zero-based column and row indexes of the item.
     *  For example: {columnIndex:2, rowIndex:3}</p>
     *
     *  <p>Setting this property scrolls the item into view and
     *  dispatches the <code>itemEditBegin</code> event to
     *  open an item editor on the specified item renderer.</p>
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get editedItemPosition():Object
    {
        if (_editedItemPosition)
            return {rowIndex: _editedItemPosition.rowIndex,
                                  columnIndex: _editedItemPosition.columnIndex};
        else
            return _editedItemPosition;
    }

    /**
     *  @private
     */
    public function set editedItemPosition(value:Object):void
    {
        if (!value)
        {
            setEditedItemPosition(null);
            return;
        }

        var newValue:Object = {rowIndex: value.rowIndex,
                               columnIndex: value.columnIndex};

        setEditedItemPosition(newValue);
    }
    
    //----------------------------------
    //  lookAheadDuration
    //----------------------------------

    [Inspectable(defaultValue="400")]
    /**
     *  The type look-ahead duration, in milliseconds, for multi-character look ahead.
     *  Setting it to 0 will turn off multiple character type ahead lookup.
     *  
     *  @default 400
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var lookAheadDuration:Number = 400;

    //----------------------------------
    //  resizableColumns
    //----------------------------------

    [Inspectable(category="General")]

    /**
     *  A flag that indicates whether the user can change the size of the
     *  columns.
     *  If <code>true</code>, the user can stretch or shrink the columns of 
     *  the AdvancedDataGrid control by dragging the grid lines between the header cells.
     *  If <code>true</code>, individual columns must also have their 
     *  <code>resizeable</code> properties set to <code>false</code> to 
     *  prevent the user from resizing a particular column.  
     *
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var resizableColumns:Boolean = true;

    //----------------------------------
    //  sortableColumns
    //----------------------------------

    [Inspectable(category="General")]

    /**
     *  A flag that indicates whether the user can sort the data provider items
     *  by clicking on a column header cell.
     *  If <code>true</code>, the user can sort the data provider items by
     *  clicking on a column header cell. 
     *  The <code>AdvancedDataGridColumn.dataField</code> property of the column
     *  or the <code>AdvancedDataGridColumn.sortCompareFunction</code> property 
     *  of the column is used as the sort field.  
     *  If a column is clicked more than once, 
     *  the sort alternates between ascending and descending order.
     *  If <code>true</code>, individual columns can be made to not respond
     *  to a click on a header by setting the column's <code>sortable</code>
     *  property to <code>false</code>.
     *
     *  <p>When a user releases the mouse button over a header cell, the AdvancedDataGrid
     *  control dispatches a <code>headerRelease</code> event if both
     *  this property and the column's sortable property are <code>true</code>.  
     *  If no handler calls the <code>preventDefault()</code> method on the event, the 
     *  AdvancedDataGrid sorts using that column's <code>AdvancedDataGridColumn.dataField</code> or  
     *  <code>AdvancedDataGridColumn.sortCompareFunction</code> properties.</p>
     * 
     *  @default true
     *
     *  @see mx.controls.advancedDataGridClasses.AdvancedDataGridColumn#dataField
     *  @see mx.controls.advancedDataGridClasses.AdvancedDataGridColumn#sortCompareFunction
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var sortableColumns:Boolean = true;

    //----------------------------------
    //  sortExpertMode
    //----------------------------------

    // Type of sorting UI displayed
    private var _sortExpertMode:Boolean = false;

    /**
     *  By default, the <code>sortExpertMode</code> property is set to <code>false</code>, 
     *  which means you click in the header area of a column to sort the rows of 
     *  the AdvancedDataGrid control by that column. 
     *  You then click in the multiple-column sort area of the header to sort by additional columns. 
     *  If you set the <code>sortExpertMode</code> property to <code>true</code>, 
     *  you use the Control key to select every column after the first column to perform sort.
     *
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    [Inspectable(enumeration="true,false", defaultValue="false")]
    public function get sortExpertMode():Boolean
    {
        return _sortExpertMode;
    }

    /**
     *  @private
     */
    public function set sortExpertMode(value:Boolean):void
    {
        _sortExpertMode = value;

        invalidateHeaders();
        invalidateProperties();
        invalidateDisplayList();
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    [Inspectable(category="Data", defaultValue="undefined")]

    /**
     *  @private
     */
    override public function set dataProvider(value:Object):void
    {
        if (itemEditorInstance)
            endEdit(AdvancedDataGridEventReason.OTHER);

        lastEditedItemPosition = null;

        super.dataProvider = value;

        invalidateProperties();
    }
    
    /**
     *  @private
     *  Adds support for multiple characters type ahead lookup.
     */
    override protected function findKey(eventCode:int):Boolean
    {
        var tmpCode:int = eventCode;
        
        // get the timer value now
        var now:uint = getTimer();
        var str:String = String.fromCharCode(tmpCode);
        
        if (!(tmpCode >= 33 && tmpCode <= 126))
            return false;
        // store the value of the _selectedIndex
        var selIndex:Number = _selectedIndex;
        
        // compare the timer value with the previously stored
        // timer value and set up multiple character type ahead
        // lookup.
        if ((now - previousTime) < lookAheadDuration)
        {
            str = lookAheadCache + str;
            lookAheadCache = str;
            previousTime = now;
            // decrement the _selecteIndex
            // we want the lookup to start from the previous item
            if (_selectedIndex > 0)
            {
                selIndex = _selectedIndex;
                _selectedIndex--;
            }
        }
        else
        {
            previousTime = now;
            lookAheadCache = str;
        }
        
        var selectionChanged:Boolean = findString(str);
        
        // set the _selectedIndex back if we cant find the item
        if (!selectionChanged && _selectedIndex != selIndex)
            _selectedIndex = selIndex;
        
        return selectionChanged;
    }

    /**
     *  @private
     *  Measures the AdvancedDataGrid based on its contents,
     *  summing the total of the visible column widths.
     */
    override protected function measure():void
    {
        super.measure();

        var o:EdgeMetrics = viewMetrics;

        var n:int = columns.length;
        if (n == 0)
        {
            measuredWidth = DEFAULT_MEASURED_WIDTH;
            measuredMinWidth = DEFAULT_MEASURED_MIN_WIDTH;
            return;
        }

        var columnWidths:Number = 0;
        var columnMinWidths:Number = 0;
        for (var i:int = 0; i < n; i++)
        {
            if (columns[i].visible)
            {
                columnWidths += columns[i].preferredWidth;
                if (isNaN(_minColumnWidth))
                    columnMinWidths += columns[i].minWidth;
            }
        }

        if (!isNaN(_minColumnWidth))
            columnMinWidths = n * _minColumnWidth;

        measuredWidth = columnWidths + o.left + o.right;
        measuredMinWidth = columnMinWidths + o.left + o.right;

        // factor out scrollbars if policy == AUTO.  See Container.viewMetrics
        if (verticalScrollPolicy == ScrollPolicy.AUTO &&
            verticalScrollBar && verticalScrollBar.visible)
        {
            measuredWidth -= verticalScrollBar.minWidth;
            measuredMinWidth -= verticalScrollBar.minWidth;
        }
        if (horizontalScrollPolicy == ScrollPolicy.AUTO &&
            horizontalScrollBar && horizontalScrollBar.visible)
        {
            measuredHeight -= horizontalScrollBar.minHeight;
            measuredMinHeight -= horizontalScrollBar.minHeight;
        }

    }
    /**
     *  @private
     *  Sizes and positions the column headers, columns, and items based on the
     *  size of the AdvancedDataGrid.
     */
    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
    {
        // Note: We can't immediately call super.updateDisplayList()
        // because the visibleColumns array must be populated first.
        var updateContent:Boolean = false;
        if (displayWidth != unscaledWidth - viewMetrics.right - viewMetrics.left)
        {
            displayWidth = unscaledWidth - viewMetrics.right - viewMetrics.left;
            columnsInvalid = true;
            updateContent = true;
        }


        calculateColumnSizes();

        if (updateContent)
            updateSubContent();

        if (rendererChanged)
            purgeItemRenderers(); 

        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        // We need to explicitly call configureScrollBars
        // when horizontal scrolling is optimized. In this case
        // because scrollAreaChanged is false, super doesn't 
        // configure scrollbars.
        if (horizontalScrollPolicy != ScrollPolicy.OFF
            && getOptimumColumns() != visibleColumns
            && !itemsSizeChanged && !bSelectionChanged 
            && !scrollAreaChanged
            && subContentScrolled)
        {
            configureScrollBars();
            subContentScrolled = false;
        }

        if (collection && collection.length)
        {
            setRowCount(listItems.length);

            if (headerInfos && headerInfos.length)
                setColumnCount(headerInfos.length);
            else
                setColumnCount(0);
        }
        
        if (_horizontalScrollPolicy == ScrollPolicy.OFF)
        {
            // If we have a vScroll only and if we have room to fit the scrollbar below the header,
            // we want the scrollbar to be below

            var bm:EdgeMetrics = borderMetrics;
            var hh:Number = headerRowInfo.length ? headerRowInfo[0].height : headerHeight;

            if (verticalScrollBar != null && verticalScrollBar.visible && headerVisible 
                && roomForScrollBar(verticalScrollBar, 
                                    unscaledWidth-bm.left-bm.right, 
                                    unscaledHeight-hh-bm.top-bm.bottom))
            {
                verticalScrollBar.move(verticalScrollBar.x, viewMetrics.top + hh);
                verticalScrollBar.setActualSize(
                    verticalScrollBar.width,
                    unscaledHeight - viewMetrics.top - viewMetrics.bottom - hh);
                verticalScrollBar.visible =  (verticalScrollBar.height >= verticalScrollBar.minHeight);
            }
        }
        if (bEditedItemPositionChanged)
        {
            bEditedItemPositionChanged = false;
			// don't do this if mouse is down on an item
			// on mouse up, we'll let the edit session logic
			// request a new position
			if (!lastItemDown)
            	commitEditedItemPosition(_proposedEditedItemPosition);
            _proposedEditedItemPosition = undefined;
            itemsSizeChanged = false;
        }

        var headerBG:UIComponent =
            UIComponent(listContent.getChildByName("headerBG"));

        if (headerBGSkinChanged)
        {
            headerBGSkinChanged = false;
            if (headerBG)
                listContent.removeChild(headerBG);
            headerBG = null;
        }

        if (!headerBG)
        {
            headerBG = new UIComponent();
            headerBG.name = "headerBG";
            listContent.addChildAt(DisplayObject(headerBG), listContent.getChildIndex(selectionLayer));

            var headerBGSkinClass:Class = getStyle("headerBackgroundSkin");
            
            if (headerBGSkinClass != null)
            {
                var headerBGSkin:IFlexDisplayObject = new headerBGSkinClass();
    
                if (headerBGSkin is ISimpleStyleClient)
                    ISimpleStyleClient(headerBGSkin).styleName = this;
                headerBG.addChild(DisplayObject(headerBGSkin));
            }
        }

        if (headerVisible)
        {
            headerBG.visible = true;
            if (useOldDGHeaderBGLogic)
            {
                drawHeaderBackground(headerBG);
            }
            else
            {
                if (headerBG.numChildren > 0)
                    drawHeaderBackgroundSkin(IFlexDisplayObject(headerBG.getChildAt(0)));
            }
        }
        else
        {
            headerBG.visible = false;
        }

        drawRowBackgrounds();

        if (headerVisible)
            drawSeparators();
        else
            clearSeparators();

        drawLinesAndColumnBackgrounds();

        // trace("<<updateDisplayList");
    }

    /**
     *  @private
     */
    override protected function adjustListContent(unscaledWidth:Number = -1,
                                       unscaledHeight:Number = -1):void
    {
        super.adjustListContent(unscaledWidth, unscaledHeight);

        // listSubContent scrollRect needs to be updated whenever
        // listContent size is adjusted
        updateSubContent();
    }
    
    // horizontal page up, page down
    /**
     *  @private
     */    
    override protected function moveSelectionHorizontally(code:uint,
                                                          shiftKey:Boolean,
                                                          ctrlKey:Boolean):void
    {
        // The new calculated value of the horizontal scroll position
        var newHorizontalScrollPosition:Number;
        // Has the horizontal scroll position actually changed?
        var bUpdateHorizontalScrollPosition:Boolean = false;
        // Max horizontal position
        var maxPosition:int;

        if (shiftKey && code == Keyboard.PAGE_UP)
        {
            newHorizontalScrollPosition = Math.max(
                horizontalScrollPosition - (visibleColumns.length - lockedColumnCount)
                , 0);

            if (newHorizontalScrollPosition != horizontalScrollPosition)
                bUpdateHorizontalScrollPosition = true;
        }
        else if (shiftKey && code == Keyboard.PAGE_DOWN)
        {
            // We don't want to exceed the max scroll value or the last column's index
            maxPosition = Math.min(maxHorizontalScrollPosition, columns.length-1);
            newHorizontalScrollPosition = Math.min(
                horizontalScrollPosition + (visibleColumns.length - lockedColumnCount)
                , maxPosition);

            if (newHorizontalScrollPosition != horizontalScrollPosition)
                bUpdateHorizontalScrollPosition = true;
        }
        else
        {
            super.moveSelectionHorizontally(code, shiftKey, ctrlKey);
        }

        // Mark the event of the horizontal scroll position changing
        if (bUpdateHorizontalScrollPosition)
        {
            var scrollEvent:ScrollEvent = new ScrollEvent(ScrollEvent.SCROLL);
            scrollEvent.detail          = ScrollEventDetail.THUMB_POSITION;
            scrollEvent.direction       = ScrollEventDirection.HORIZONTAL;
            scrollEvent.delta           = newHorizontalScrollPosition - horizontalScrollPosition;
            scrollEvent.position        = newHorizontalScrollPosition;
            horizontalScrollPosition    = newHorizontalScrollPosition;
            dispatchEvent(scrollEvent);

            if (headerIndex != -1)
                unselectColumnHeader(headerIndex);
        }
    }

    /**
     *  @private
     */
    override protected function makeRowsAndColumns(left:Number, top:Number,
                                                   right:Number, bottom:Number,
                                                   firstCol:int, firstRow:int,
                                                   byCount:Boolean = false, rowsNeeded:uint = 0):Point
    {
        listContent.allowItemSizeChangeNotification = false;
        listSubContent.allowItemSizeChangeNotification = false;

        if (headerVisible && itemsSizeChanged)
            calculateHeaderHeight();

        var pt:Point = super.makeRowsAndColumns(left, top, right, bottom,
                                                firstCol, firstRow, byCount, rowsNeeded);
        var optimumColumns:Array = getOptimumColumns();
        if (itemEditorInstance)
        {
            itemEditorInstance.parent.setChildIndex(DisplayObject(itemEditorInstance),
                                                    itemEditorInstance.parent.numChildren - 1);
            var col:AdvancedDataGridColumn = optimumColumns[actualColIndex];
            var item:IListItemRenderer = listItems[actualRowIndex][actualColIndex];
            var rowData:ListRowInfo = rowInfo[actualRowIndex];
            if (item && !col.rendererIsEditor)
            {
                var dx:Number = col.editorXOffset;
                var dy:Number = col.editorYOffset;
                var dw:Number = col.editorWidthOffset;
                var dh:Number = col.editorHeightOffset;
                itemEditorInstance.move(item.x + dx, rowData.y + dy);
                itemEditorInstance.setActualSize(Math.min(col.width + dw, listContent.width - listContent.x - itemEditorInstance.x),
                                                 Math.min(rowData.height + dh, listContent.height - listContent.y - itemEditorInstance.y));
                // Commenting to show the item (with disclosure icon) behind the item editor
                //item.visible = false;

            }
        }

        var lines:Sprite = Sprite(listSubContent.getChildByName("lines"));
        if (lines)
            listSubContent.setChildIndex(lines, listSubContent.numChildren - 1);


        listContent.allowItemSizeChangeNotification = variableRowHeight;
        listSubContent.allowItemSizeChangeNotification = variableRowHeight;
        return pt;
    }

    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        if(columnsInvalid)
        {
            // initializeHeaderInfo need to be called only if columns array have been changed
            // no need to call it everytime columnsInvalid becomes true
            if(columnsChanged && !headerInfoInitialized)
            {
                headerInfoInitialized = true;
                headerInfos = initializeHeaderInfo(columns);
                headerInfoInitialized = false;
                columnsChanged = false;
            }

            columnsChanged = false;
            
            visibleHeaderInfos = updateVisibleHeaders();
            updateHeaderSearchList();
        
            createDisplayableColumns();
        }

        super.commitProperties();

        measureItems();
    }

    /**
     *  @private
     *  Instead of measuring the items, we measure the visible columns instead.
     */
    override public function measureWidthOfItems(index:int = -1, count:int = 0):Number
    {
        var w:Number = 0;

        var n:int = columns ? columns.length : 0;
        for (var i:int = 0; i < n; i++)
        {
            if (columns[i].visible)
                w += columns[i].width;
        }

        return w;
    }

    /**
     *  @private
     */
    override public function measureHeightOfItems(index:int = -1, count:int = 0):Number
    {
        return measureHeightOfItemsUptoMaxHeight(index, count);
    }

    /**
     *  @private
     */
    override protected function calculateRowHeight(data:Object, hh:Number, skipVisible:Boolean = false):Number
    {
        var item:IListItemRenderer;
        var c:AdvancedDataGridColumn;

        var n:int = columns.length;
        var i:int;
        var j:int = 0;

        if (skipVisible && visibleColumns.length == _columns.length)
            return hh;

        var paddingTop:Number = getStyle("paddingTop");
        var paddingBottom:Number = getStyle("paddingBottom");

        if (!measuringObjects)
            measuringObjects = new Dictionary(false);

        for (i = 0; i < n; i++)
        {
            // skip any columns that are visible
            if (skipVisible && j < visibleColumns.length && visibleColumns[j].colNum == columns[i].colNum)
            {
                j++;
                continue;
            }
            c = columns[i];

            if (!c.visible)
                continue;

            item = getMeasuringRenderer(c, false,data);
            setupRendererFromData(c, item, data);
            hh = Math.max(hh, item.getExplicitOrMeasuredHeight() + paddingBottom + paddingTop);
        }
        return hh;
    }

    /**
     *  @private
     */
    override protected function scrollHandler(event:Event):void
    {
        if (event.target == verticalScrollBar ||
            event.target == horizontalScrollBar)
        {
            // TextField.scroll bubbles so you might see it here
            if (event is ScrollEvent)
            {
                if (!liveScrolling &&
                    ScrollEvent(event).detail == ScrollEventDetail.THUMB_TRACK)
                {
                    return;
                }

                if (itemEditorInstance)
                    endEdit(AdvancedDataGridEventReason.OTHER);

                var scrollBar:ScrollBar = ScrollBar(event.target);
                var pos:Number = scrollBar.scrollPosition;

                if (scrollBar == verticalScrollBar)
                    verticalScrollPosition = pos;
                else if (scrollBar == horizontalScrollBar)
                    horizontalScrollPosition = pos;

                super.scrollHandler(event);
            }
        }
    }

    /**
     *  @private
     */
    override protected function configureScrollBars():void
    {
        var oldHorizontalScrollBar:Object = horizontalScrollBar;
        var oldVerticalScrollBar:Object = verticalScrollBar;

        var rowCount:int = listItems.length;
		// check whether the header items are present
		if (rowCount + getHeaderItemsLength() == 0)
        {
            // Get rid of any existing scrollbars.
            if (oldHorizontalScrollBar || oldVerticalScrollBar)
                setScrollBarProperties(0, 0, 0, 0);

            return;
        }

        var vScrollProperties:Array;
        var hScrollProperties:Array;

        // partial last rows don't count
        if (rowCount > 1 && rowInfo[rowCount - 1].y + rowInfo[rowCount - 1].height > listContent.height)
            rowCount--;

        // offset, when added to rowCount, is the index of the dataProvider
        // item for that row.  IOW, row 10 in listItems is showing dataProvider
        // item 10 + verticalScrollPosition - lockedRowCount;
        var offset:int = verticalScrollPosition - lockedRowCount;
        // don't count filler rows at the bottom either.
        var fillerRows:int = 0;
        while (rowCount && listItems[rowCount - 1].length == 0)
        {
            // as long as we're past the end of the collection, add up
            // fillerRows
            if (collection && rowCount + offset >= collection.length)
            {
                rowCount--;
                ++fillerRows;
            }
            else
            {
                break;
            }
        }

        // we have to scroll up.  We can't have filler rows unless the scrollPosition is 0
        if (verticalScrollPosition > 0 && fillerRows > 0)
        {
            if (adjustVerticalScrollPositionDownward(Math.max(rowCount, 1)))
                return;
        }

        vScrollProperties = [collection ? collection.length - lockedRowCount : 0,
                                        Math.max(rowCount - lockedRowCount, 1)];
         
        var colCount:int = visibleColumns.length;
        var lastHeaderInfo:AdvancedDataGridHeaderInfo = getHeaderInfo(visibleColumns[visibleColumns.length - 1]);
        var headerPosX:int =  lastHeaderInfo.headerItem.x;
        if(visibleColumns.length - 1  > lockedColumnCount)
            headerPosX = getAdjustedXPos(headerPosX);
        
        // if the last column is visible and partially offscreen (but it isn't the only
        // column) then adjust the column count so we can scroll to see it
        if (colCount > 1 && visibleColumns[colCount - 1] == displayableColumns[displayableColumns.length - 1]
            && headerPosX + visibleColumns[colCount - 1].width > displayWidth)
        {
            colCount--;
        }
        
        hScrollProperties = [displayableColumns.length - lockedColumnCount,
                             Math.max(colCount - lockedColumnCount, 1)];

        
        //Finally set both the scroll bar properties
        setScrollBarProperties(hScrollProperties[0], hScrollProperties[1],
                               vScrollProperties[0], vScrollProperties[1]);
        
        if ((!verticalScrollBar || !verticalScrollBar.visible) && collection &&
            collection.length - lockedRowCount > rowCount - lockedRowCount)
            maxVerticalScrollPosition = collection.length - lockedRowCount - (rowCount - lockedRowCount);
        
        if ((!horizontalScrollBar || !horizontalScrollBar.visible) && 
            displayableColumns.length - lockedColumnCount  > colCount - lockedColumnCount)
            maxHorizontalScrollPosition = displayableColumns.length - lockedColumnCount - (colCount - lockedColumnCount);
    }

    /**
     *  @private
     */
    override protected function scrollVertically(pos:int, deltaPos:int, scrollUp:Boolean):void
    {
        // temporarily shift the cursor index to first movable row.
        iterator.seek(CursorBookmark.CURRENT, lockedRowCount);

        super.scrollVertically(pos, deltaPos, scrollUp);

        // move the cursor back to actual first row.
        iterator.seek(CursorBookmark.CURRENT, - lockedRowCount);
    }

    /**
     *  @private
     */
    override public function calculateDropIndex(event:DragEvent = null):int
    {
        if (event)
        {
            var item:IListItemRenderer;
            var pt:Point = new Point(event.localX, event.localY);
            pt = DisplayObject(event.target).localToGlobal(pt);
            pt = listContent.globalToLocal(pt);
            
            var n:int = listItems.length;
            for (var i:int = 0; i < n; i++)
            {
                if (rowInfo[i].y <= pt.y && pt.y <= rowInfo[i].y + rowInfo[i].height)
                {
                    item = listItems[i][0];
                    break;
                }
            }

            if (item)
                lastDropIndex = itemRendererToIndex(item);
            else
                lastDropIndex = collection ? collection.length : 0;
        }

        return lastDropIndex;
    }

    /**
     *  @private
     */
    override protected function calculateDropIndicatorY(rowCount:Number, rowNum:int):Number
    {
        var i:int;
        // we need to take care of headerHeight
        var yy:Number = headerVisible ? headerHeight : 0;

        if (rowCount && listItems[rowNum].length && listItems[rowNum][0])
        {
           return listItems[rowNum][0].y - 1
        }

        for (i = 0; i < rowCount; i++)
        {
            if (listItems[i].length)
                yy += rowInfo[i].height;
            else
                break;
        }
        return yy;
    }

    /**
     *  @private
     */
    override protected function drawRowBackgrounds():void
    {
        var rowBGs:Sprite = Sprite(listContent.getChildByName("rowBGs"));
        if (!rowBGs)
        {
            rowBGs = new FlexSprite();
            rowBGs.mouseEnabled = false;
            rowBGs.name = "rowBGs";
            listContent.addChildAt(rowBGs, 0);
        }

        var colors:Array;
		var colorsStyle:Object = getStyle("alternatingItemColors");
		
		if (colorsStyle)
			colors = (colorsStyle is Array) ? (colorsStyle as Array) : [colorsStyle];
		
        if (!colors || colors.length == 0)
            return;

        styleManager.getColorNames(colors);

        var curRow:int = 0;

        var i:int = 0;
        var actualRow:int = verticalScrollPosition;
        var actualLockedRow:int = 0;
        var n:int = listItems.length;

        // for Locked rows
        while (curRow < lockedRowCount && curRow < n)
        {
            drawRowBackground(rowBGs, i++, rowInfo[curRow].y, rowInfo[curRow].height, colors[actualLockedRow % colors.length], actualLockedRow);
            curRow++;
            actualLockedRow++;
            actualRow++;
        }
        
        // for unlocked rows
        while (curRow < n)
        {
            drawRowBackground(rowBGs, i++, rowInfo[curRow].y, rowInfo[curRow].height, colors[actualRow % colors.length], actualRow);
            curRow++;
            actualRow++;
        }

        while (rowBGs.numChildren > i)
        {
            rowBGs.removeChildAt(rowBGs.numChildren - 1);
        }
    }

    /**
     *  @private
     */
    override protected function mouseEventToItemRenderer(event:MouseEvent):IListItemRenderer
    {
        var r:IListItemRenderer;

        if (event.target == highlightIndicator || event.target == listContent)
        {
            var pt:Point = new Point(event.stageX, event.stageY);
            pt = listContent.globalToLocal(pt);

            var ww:Number = 0;

            // For headerItems
            // headerItems are created even if showHeader is false
            // dont look for header renderers if headerVisible is false
            if (headerVisible)
                r = findHeaderRenderer(pt);

            // For listItems
            // if ADG is empty then length of rowInfo is 0
            if (!r && rowInfo.length !=0)
                r = findRenderer(pt,listItems,rowInfo,rowInfo[0].y);
        }

        if (!r)
            r = super.mouseEventToItemRenderer(event);

        return r == itemEditorInstance ? null : r;
    }

    /**
     *  @private
     */
    override public function styleChanged(styleProp:String):void
    {
        super.styleChanged(styleProp);

        var changed:Boolean = false;

        if (styleProp == "headerBackgroundSkin")
        {
            changed = true;
            headerBGSkinChanged = true;
        }
        else if (styleProp == "headerSortSeparatorSkin")
        {
            changed = true;
        }
        else if (styleProp == "headerSeparatorSkin")
        {
            headerSepSkinChanged = true;
            changed = true;
        }

        if (changed)
        {
            itemsSizeChanged = true;
        }
    }
    
    /**
     *  @private
     *  handle header selection
     */
    override protected function selectItem(item:IListItemRenderer,
                                  shiftKey:Boolean, ctrlKey:Boolean,
                                  transition:Boolean = true):Boolean
     {
        var val:Boolean = super.selectItem(item, shiftKey, ctrlKey, transition);
        
        // if item.data is AdvancedDataGridColumn, it means that a header is selected
        // selectedItem should be null
        if (item.data is AdvancedDataGridColumn)
            _selectedItem = null;
        
        return val;
     }
     
     /**
     *  @private
     *  handle header selection
     */
     override mx_internal function addSelectionData(uid:String, selectionData:ListBaseSelectionData):void
     {
        // if data is AdvancedDataGridColumn, it means that a header is selected
        // it should not be added into the list
        if (selectionData.data is AdvancedDataGridColumn)
            return ;
        super.addSelectionData(uid, selectionData);
     }
     
     /**
     *  @private
     *  used by ListBase.findString.  Shouldn't be used elsewhere
     *  because column's itemToLabel is preferred
     */
    override public function itemToLabel(data:Object):String
    {
        return displayableColumns[sortIndex == -1 ? 0 : sortIndex].itemToLabel(data);
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  When column width changes or horizontal scrolling happens
     *  we need to adjust the sub content area.
     */
    private function updateSubContent():void
    {
        if(!visibleColumns || getOptimumColumns() == visibleColumns)
        {
            listSubContent.scrollRect = null;
            listSubContent.x = 0;
            return ;
        }

        var lockedWidth:Number = 0;
        for(var i:int = 0; i < lockedColumnCount; ++i)
        {
            lockedWidth += displayableColumns[i].width;
        }

        var scrollWidth:Number = 0;
        if(visibleColumns.length > lockedColumnCount)
        {
            for(i = lockedColumnCount; i < lockedColumnCount+horizontalScrollPosition; ++i)
            {
                scrollWidth += displayableColumns[i].width;
            }
        }
        if (horizontalScrollPosition == 0)
        {
            //tmpMask.x = 0;
            listSubContent.scrollRect = null;
            listSubContent.x = 0;
        }
        else
        {
            if (lockedColumnCount > 0)
                listSubContent.x = lockedWidth;
            else
                listSubContent.x = 0;
            //tmpMask.x = lockedWidth;
            if (lockedWidth > 0)
                listSubContent.scrollRect = new Rectangle(lockedWidth+scrollWidth, 0, 
                                                          listContent.width - lockedWidth, listContent.height);
            else
                listSubContent.scrollRect = new Rectangle(scrollWidth, 0, 
                                                          listContent.width, listContent.height);
        }
    }

    /**
     *  @private
     */    
    protected function updateVisibleHeaders():Array
    {
        var visibleHeaderInfos:Array = [];

        var n:int = headerInfos ? headerInfos.length : 0;
        var i:int;
        var k:int= 0;;
        
        for ( i = 0; i < n; i++)
        {
            headerInfos[i].visible = headerInfos[i].column.visible;
            if(headerInfos[i].visible)
            {
                visibleHeaderInfos.push(headerInfos[i]);
                headerInfos[i].actualColNum = k++;
                headerInfos[i].columnSpan = 1;
            }
            else
            {
                headerInfos[i].actualColNum = NaN;
            }
        }
        return visibleHeaderInfos;
    }

    /**
     *  @private
     */    
    protected function updateHeaderSearchList():void
    {
        var n:int = visibleHeaderInfos? visibleHeaderInfos.length : 0;
        
        orderedHeadersList = [];
        for (var i:int = 0; i < n; i++)
        {
            orderedHeadersList.push(visibleHeaderInfos[i]);
        }
    }
    
    /**
     *  @private
     */
    protected function initializeHeaderInfo(a:Array):Array
    {
        var newArray:Array = [];
        var n:int = columns.length;
        for(var i:int = 0; i < n; i++)
        {
            var headerInfo:AdvancedDataGridHeaderInfo = new AdvancedDataGridHeaderInfo(columns[i],null,i, 0) ;
            newArray.push(headerInfo);
        }
        return newArray;
    }
	
	/**
	 * Get the length of the header items
	 * 
	 *  @private
	 */
	protected function getHeaderItemsLength():int
	{
		return headerItems.length;
	}
    
    /**
     *  @private
     */
    mx_internal function getMeasuringRenderer(c:AdvancedDataGridColumn, forHeader:Boolean, data:Object):IListItemRenderer
    {
        var factory:IFactory = columnItemRendererFactory(c,forHeader,data);
		
		if (!measuringObjects)
			measuringObjects = new Dictionary(false);
		
        var item:IListItemRenderer = measuringObjects[factory];
        if (!item)
        {
            item = columnItemRenderer(c, forHeader, data);
            item.visible = false;
            item.styleName = c;
            listContent.addChild(DisplayObject(item));
            measuringObjects[factory] = item;
        }

        return item;
    }

    mx_internal function setupRendererFromData(c:AdvancedDataGridColumn, item:IListItemRenderer, data:Object):void
    {
        var rowData:AdvancedDataGridListData =
            AdvancedDataGridListData(makeListData(data, itemToUID(data), 0, c.colNum, c));

        if (item is IDropInListItemRenderer)
        {
            if (data != null)
                IDropInListItemRenderer(item).listData = makeListData(data, itemToUID(data), 0 /* rowNum */, c.colNum, c);
            else
                IDropInListItemRenderer(item).listData = null;
        }

        item.data = data;

        if (item is IInvalidating)
            IInvalidating(item).invalidateSize();

        item.explicitWidth = getWidthOfItem(item, c, currentColNum);

        UIComponentGlobals.layoutManager.validateClient(item, true);
    }
    
    /**
     *  @private
     */
    mx_internal function measureHeightOfItemsUptoMaxHeight(index:int = -1, count:int = 0, maxHeight:Number = -1):Number
    {
        if (!columns.length)
            return rowHeight * count;

        var h:Number = 0;

        var item:IListItemRenderer;
        var c:AdvancedDataGridColumn;
        var ch:Number = 0;
        var n:int;
        var j:int;

        var paddingTop:Number = getStyle("paddingTop");
        var paddingBottom:Number = getStyle("paddingBottom");

        if (!measuringObjects)
            measuringObjects = new Dictionary(false);

        var lockedCount:int = lockedRowCount;

        if (headerVisible && count > 0 && index == -1)
        {
            h = calculateHeaderHeight();

            if (maxHeight != -1 && h > maxHeight)
            {
                setRowCount(0);
                return 0;
            }

            // trace(this + " header preferredHeight = " + h);
        }

        var bookmark:CursorBookmark = (iterator) ? iterator.bookmark : null;

        var bMore:Boolean = iterator != null;
        if (index != -1 && iterator)
        {
            try
            {
                iterator.seek(CursorBookmark.FIRST, index);
            }
            catch (e:ItemPendingError)
            {
                bMore = false;
            }
        }

        if (lockedCount > 0 && collectionIterator)
        {
            try
            {
                collectionIterator.seek(CursorBookmark.FIRST,0);
            }
            catch (e:ItemPendingError)
            {
                bMore = false;
            }
        }

        for (var i:int = 0; i < count; i++)
        {
            var data:Object;
            if (bMore)
            {
                data = (lockedCount > 0) ? collectionIterator.current : iterator.current;
                ch = 0;
                n = columns.length;
                for (j = 0; j < n; j++)
                {
                    c = columns[j];

                    if (!c.visible)
                        continue;

                    item = getMeasuringRenderer(c, false,data);
                    setupRendererFromData(c, item, data);
                    ch = Math.max(ch, variableRowHeight ? item.getExplicitOrMeasuredHeight() + paddingBottom + paddingTop : rowHeight);
                }
            }

            if (maxHeight != -1 && (h + ch > maxHeight || !bMore))
            {
                try
                {
                    if (iterator)
                        iterator.seek(bookmark, 0);
                }
                catch (e:ItemPendingError)
                {
                    // we don't recover here since we'd only get here if the first seek failed.
                }
                count = i;
                setRowCount(count);
                return h;
            }

            h += ch;
            if (iterator)
            {
                try
                {
                    bMore = iterator.moveNext();
                    if (lockedCount > 0)
                    {
                        collectionIterator.moveNext();
                        lockedCount--;
                    }
                }
                catch (e:ItemPendingError)
                {
                    // if we run out of data, assume all remaining rows are the size of the previous row
                    bMore = false;
                }
            }
        }

        if (iterator)
        {
            try
            {
                iterator.seek(bookmark, 0);
            }
            catch (e:ItemPendingError)
            {
                // we don't recover here since we'd only get here if the first seek failed.
            }
        }

        // trace("calcheight = " + h);
        return h;
    }

    /**
     *  @private
     */
    protected function calculateHeaderHeight():Number
    {
        if (!columns.length)
            return rowHeight;

        var item:IListItemRenderer;
        var c:AdvancedDataGridColumn;
        var rowData:AdvancedDataGridListData;
        var ch:Number = 0;
        var n:int;
        var j:int;

        var paddingTop:Number = getStyle("paddingTop");
        var paddingBottom:Number = getStyle("paddingBottom");

        if (!measuringObjects)
            measuringObjects = new Dictionary(false);

        if (headerVisible)
        {
            ch = 0;
            n = columns.length;

            if (_headerWordWrapPresent)
            {
                _headerHeight = _originalHeaderHeight;
                _explicitHeaderHeight = _originalExplicitHeaderHeight;
            }

            for (j = 0; j < n; j++)
            {
                c = columns[j];

                if (!c.visible)
                    continue;

                // passing data as null, as it is used for header renderer
                item = getMeasuringRenderer(c, true, null);
                rowData = AdvancedDataGridListData(makeListData(c, uid, 0, c.colNum, c));
                rowMap[item.name] = rowData;
                if (item is IDropInListItemRenderer)
                    IDropInListItemRenderer(item).listData = rowData;
                item.data = c;
                item.explicitWidth = c.width;
                UIComponentGlobals.layoutManager.validateClient(item, true);
                ch = Math.max(ch, _explicitHeaderHeight ? headerHeight : item.getExplicitOrMeasuredHeight() + paddingBottom + paddingTop);

                if (columnHeaderWordWrap(c))
                    _headerWordWrapPresent = true;
            }

            if (_headerWordWrapPresent)
            {
                // take backups
                _originalHeaderHeight = _headerHeight;
                _originalExplicitHeaderHeight = _explicitHeaderHeight;

                headerHeight = ch;
            }
        }
        return ch;
    }
    
    /**
     *  @private
     */
    protected function getAdjustedXPos(posx:int):int
    {
        if (listSubContent.scrollRect)
        {
            if (listSubContent.x == 0)
                posx -= listSubContent.scrollRect.x;
            else
                posx -= (listSubContent.scrollRect.x - listSubContent.x);
        }
        return posx;
    }

    /**
     *  @private
     */
    mx_internal function getHeaderInfo(col:AdvancedDataGridColumn):AdvancedDataGridHeaderInfo
    {
        return headerInfos[col.colNum];
    }

    /**
     *  @private
     */
    mx_internal function getHeaderInfoAt(colIndex:int):AdvancedDataGridHeaderInfo
    {
        if(headerInfos)
            return headerInfos[colIndex];
        return null;
    }

    /**
     *  @private
     */
    protected function getNumColumns():int
    {
        if(headerItems && headerItems[0])
            return headerItems[0].length;
        return -1;
    }
    
    /**
     *  @private
     *  Makes verticalScrollPosition smaller until it is 0 or there
     *  are no empty rows.  This is needed if we're scrolled to the
     *  bottom and something is deleted or the rows resize so more
     *  rows can be shown.
     */
    private function adjustVerticalScrollPositionDownward(rowCount:int):Boolean
    {
        var bookmark:CursorBookmark = iterator.bookmark;

        // add up how much space we're currently taking with valid items
        var h:Number = 0;

        var item:IListItemRenderer;
        var c:AdvancedDataGridColumn;
        var ch:Number = 0;
        var n:int;
        var j:int;

        var paddingTop:Number = getStyle("paddingTop");
        var paddingBottom:Number = getStyle("paddingBottom");

        h = rowInfo[rowCount - 1].y + rowInfo[rowCount - 1].height;
        h = listContent.height - h;

        // back up one
        var numRows:int = 0;
        try
        {
            if (iterator.afterLast)
                iterator.seek(CursorBookmark.LAST, 0)
            else
                var bMore:Boolean = iterator.movePrevious();
        }
        catch (e:ItemPendingError)
        {
            bMore = false;
        }
        if (!bMore)
        {
            // reset to 0;
            super.verticalScrollPosition = 0;
            try
            {
                iterator.seek(CursorBookmark.FIRST, 0);
                // sometimes, if the iterator is invalid we'll get lucky and succeed
                // here, then we have to make the iterator valid again
                if (!iteratorValid)
                {
                    iteratorValid = true;
                    lastSeekPending = null;
                }
            }
            catch (e:ItemPendingError)
            {
                lastSeekPending = new ListBaseSeekPending(CursorBookmark.FIRST, 0);
                e.addResponder(new ItemResponder(seekPendingResultHandler, seekPendingFailureHandler,
                                                 lastSeekPending));
                iteratorValid = false;
                invalidateList();
                return true;
            }
            updateList();
            return true;
        }

        // now work backwards to see how many more rows we need to create
        while (h > 0 && bMore)
        {
            var data:Object;
            if (bMore)
            {
                data = iterator.current;
                ch = 0;
                n = columns.length;
                for (j = 0; j < n; j++)
                {
                    c = columns[j];

                    if (!c.visible)
                        continue;

                    if (variableRowHeight)
                    {
                        item = getMeasuringRenderer(c, false,data);
                        setupRendererFromData(c, item, data);
                    }
                    ch = Math.max(ch, variableRowHeight ? item.getExplicitOrMeasuredHeight() + paddingBottom + paddingTop : rowHeight);
                }
            }
            h -= ch;
            try
            {
                bMore = iterator.movePrevious();
                numRows++;
            }
            catch (e:ItemPendingError)
            {
                // if we run out of data, assume all remaining rows are the size of the previous row
                bMore = false;
            }
        }
        // if we overrun, go back one.
        if (h < 0)
        {
            numRows--;
        }

        iterator.seek(bookmark, 0);
        verticalScrollPosition = Math.max(0, verticalScrollPosition - numRows);

        // make sure we get through configureScrollBars w/o coming in here.
        if (numRows > 0 && !variableRowHeight)
            configureScrollBars();

        return (numRows > 0);
    }
    
    /**
     *  @private
     *  Move a column to a new position in the columns array, shifting all
     *  other columns left or right and updating the sortIndex and
     *  lastSortIndex variables accordingly.
     */
    mx_internal function shiftColumns(oldIndex:int, newIndex:int,
                                      trigger:Event = null):void
    {
        var groupInfos:Array = headerInfos; //getPossibleDropPositions(movingColumn);
        if (newIndex >= 0 && oldIndex != newIndex)
        {
            var incr:int = oldIndex < newIndex ? 1 : -1;
            for (var i:int = oldIndex; i != newIndex; i += incr)
            {
                var j:int = i + incr;
                var c:AdvancedDataGridColumn = _columns[i];
                _columns[i] = _columns[j];
                _columns[j] = c;
                _columns[i].colNum = i;
                _columns[j].colNum = j;

                var cInfo:AdvancedDataGridHeaderInfo = groupInfos[i];
                groupInfos[i] = groupInfos[j];
                groupInfos[j] = cInfo;
                groupInfos[i].index -=incr;
                groupInfos[j].index += incr;
            }

            if (sortIndex == oldIndex)
                sortIndex += newIndex - oldIndex;
            else if ((oldIndex < sortIndex && sortIndex <= newIndex)
                     || (newIndex <= sortIndex && sortIndex < oldIndex))
                sortIndex -= incr;

            if (lastSortIndex == oldIndex)
                lastSortIndex += newIndex - oldIndex;
            else if ((oldIndex < lastSortIndex
                      && lastSortIndex <= newIndex)
                     || (newIndex <= lastSortIndex
                         && lastSortIndex < oldIndex))
                lastSortIndex -= incr;

            columnsInvalid = true;
            itemsSizeChanged = true;

            visibleHeaderInfos = updateVisibleHeaders();
            updateHeaderSearchList();
            createDisplayableColumns();

            invalidateDisplayList();
            var icEvent:IndexChangedEvent =
                new IndexChangedEvent(IndexChangedEvent.HEADER_SHIFT);
            icEvent.oldIndex = oldIndex;
            icEvent.newIndex = newIndex;
            icEvent.triggerEvent = trigger;
            dispatchEvent(icEvent);
        }
    }
    
    /**
     *  @private
     *  Searches the iterator to determine columns.
     */
    private function generateCols():void
    {
        if (collection.length > 0)
        {
            var col:AdvancedDataGridColumn;
            var newCols:Array = [];
            var cols:Array;
            if (dataProvider)
            {
                try
                {
                    iterator.seek(CursorBookmark.FIRST);
                }
                catch (e:ItemPendingError)
                {
                    lastSeekPending = new ListBaseSeekPending(CursorBookmark.FIRST, 0);
                    e.addResponder(new ItemResponder(generateColumnsPendingResultHandler, seekPendingFailureHandler,
                                                     lastSeekPending));
                    iteratorValid = false;
                    return;
                }
                var info:Object =
                    ObjectUtil.getClassInfo(iterator.current,
                                            ["uid", "mx_internal_uid"]);

                if(info)
                    cols = info.properties;
            }

            if (!cols)
            {
                // introspect the first item and use its fields
                var itmObj:Object = iterator.current;
                for (var p:String in itmObj)
                {
                    if (p != "uid")
                    {
                        col = new AdvancedDataGridColumn();
                        col.dataField = p;
                        newCols.push(col);
                    }
                }
            }
            else
            {
                // this is an old recordset - use its columns
                var n:int = cols.length;
                var colName:Object;
                for (var i:int = 0; i < n; i++)
                {
                    colName = cols[i];
                    if (colName is QName)
                        colName = QName(colName).localName;
                    col = new AdvancedDataGridColumn();
                    col.dataField = String(colName);
                    newCols.push(col);
                }
            }
            columns = newCols;
            generatedColumns = true;
        }
    }

    /**
     *  @private
     */
    private function generateColumnsPendingResultHandler(data:Object, info:ListBaseSeekPending):void
    {
        // generate cols if we haven't successfully generated them
        if (columns.length == 0)
            generateCols();
        seekPendingResultHandler(data, info);
    }

    /**
     *  @private
     */
    protected function createDisplayableColumns():void
    {
        var i:int;
        var n:int;
        
        displayableColumns = null;
        n = _columns.length;
        for (i = 0; i < n; i++)
        {
            if (displayableColumns && _columns[i].visible)
            {
                displayableColumns.push(_columns[i]);
            }
            else if (!displayableColumns && !_columns[i].visible)
            {
                displayableColumns = new Array(i);
                for (var j:int = 0; j < i; j++)
                {
                    displayableColumns[j] = _columns[j];
                }
            }
        }
        // If there are no hidden columns, displayableColumns points to
            // _columns (we don't need a duplicate copy of _columns).
        if (!displayableColumns)
            displayableColumns = _columns;
    }
    
    /**
     *  @private
     */
    private function calculateColumnSizes():void
    {
        var delta:Number;
        var n:int;
        var i:int;
        var totalWidth:Number = 0;
        var col:AdvancedDataGridColumn;
        var cw:Number;

        if (columns.length == 0)
        {
            visibleColumns = [];
            return;
        }

        // no columns are visible so figure out which ones
        // to make visible
        if (columnsInvalid)
        {
            columnsInvalid = false;
            visibleColumns = [];

            if (minColumnWidthInvalid)
            {
                n = columns.length;
                for (i = 0; i < n; i++)
                {
                    columns[i].minWidth = minColumnWidth;
                }
                minColumnWidthInvalid = false;
            }
            
            // if no hscroll, then pack columns in available space
            if (horizontalScrollPolicy == ScrollPolicy.OFF)
            {
                n = displayableColumns.length;
                for (i = 0; i < n; i++)
                {
                    visibleColumns.push(displayableColumns[i]);
                }
            }
            else
            {
                n = displayableColumns.length;
                for (i = 0; i < n; i++)
                {
                    if (i >= lockedColumnCount &&
                        i < lockedColumnCount + horizontalScrollPosition)
                    {
                        continue;
                    }

                    col = displayableColumns[i];
                    if (col.preferredWidth < col.minWidth)
                        col.preferredWidth = col.minWidth;

                    if (totalWidth < displayWidth)
                    {
                        visibleColumns.push(col);
                        totalWidth += isNaN(col.explicitWidth) ? col.preferredWidth : col.explicitWidth;
                        if (col.width != col.preferredWidth)
                            col.setWidth(col.preferredWidth);
                    }
                    else
                    {
                        if (visibleColumns.length == 0)
                            visibleColumns.push(displayableColumns[0]);
                        break;
                    }
                }
            }
        }

        var lastColumn:AdvancedDataGridColumn;
        var newSize:Number;

        // if no hscroll, then pack columns in available space
        if (horizontalScrollPolicy == ScrollPolicy.OFF)
        {
            var numResizable:int = 0;
            var fixedWidth:Number = 0;

            // trace("resizing columns");

            // count how many resizable columns and how wide they are
            n = visibleColumns.length;
            for (i = 0; i < n; i++)
            {
                // trace("column " + i + " width = " + visibleColumns[i].width);
                if (visibleColumns[i].resizable)
                {
                    // trace("    resizable");
                    if (!isNaN(visibleColumns[i].explicitWidth))
                    {
                        // trace("    explicit width " + visibleColumns[i].width);
                        fixedWidth += visibleColumns[i].width;
                    }
                    else
                    {
                        // trace("    implicitly resizable");
                        numResizable++;
                        fixedWidth += visibleColumns[i].minWidth;
                        // trace("    minWidth " + visibleColumns[i].minWidth);
                    }
                }
                else
                {
                    // trace("    not resizable");
                    fixedWidth += visibleColumns[i].width;
                }

                totalWidth += visibleColumns[i].width;
            }
            // trace("totalWidth = " + totalWidth);
            // trace("displayWidth = " + displayWidth);

            var ratio:Number;
            var newTotal:Number = displayWidth;
            var minWidth:Number;
            if (displayWidth > fixedWidth && numResizable)
            {
                // we have flexible columns and room to honor minwidths and non-resizable
                // trace("have enough room");

                // divide and distribute the excess among the resizable
                n = visibleColumns.length;
                for (i = 0; i < n; i++)
                {
                    if (visibleColumns[i].resizable && isNaN(visibleColumns[i].explicitWidth))
                    {
                        lastColumn = visibleColumns[i];
                        if (totalWidth > displayWidth)
                            ratio = (lastColumn.width - lastColumn.minWidth)/ (totalWidth - fixedWidth);
                        else
                            ratio = lastColumn.width / totalWidth;
                        newSize = lastColumn.width - (totalWidth - displayWidth) * ratio;
                        minWidth = visibleColumns[i].minWidth;
                        visibleColumns[i].setWidth(newSize > minWidth ? newSize : minWidth);
                        // trace("column " + i + " set to " + visibleColumns[i].width);
                    }
                    newTotal -= visibleColumns[i].width;
                }
                if (newTotal && lastColumn)
                {
                    // trace("excess = " + newTotal);
                    lastColumn.setWidth(lastColumn.width + newTotal);
                }
            }
            else // can't honor minwidth and non-resizables so just scale everybody
            {
                // trace("too small or too big");
                n = visibleColumns.length;
                for (i = 0; i < n; i++)
                {
                    lastColumn = visibleColumns[i];
                    ratio = lastColumn.width / totalWidth;
                    //totalWidth -= visibleColumns[i].width;
                    newSize = displayWidth * ratio;
                    lastColumn.setWidth(newSize);
                    lastColumn.explicitWidth = NaN;
                    // trace("column " + i + " set to " + visibleColumns[i].width);
                    newTotal -= newSize;
                }
                if (newTotal && lastColumn)
                {
                    // trace("excess = " + newTotal);
                    lastColumn.setWidth(lastColumn.width + newTotal);
                }
            }
        }
        else // we have or can have an horizontalScrollBar
        {
            totalWidth = 0;
            // drop any that completely overflow
            n = visibleColumns.length;
            for (i = 0; i < n; i++)
            {
                if (totalWidth > displayWidth)
                {
                    visibleColumns.splice(i);
                    break;
                }
                totalWidth += isNaN(visibleColumns[i].explicitWidth) ? visibleColumns[i].preferredWidth : visibleColumns[i].explicitWidth;
            }

            if (visibleColumns.length == 0)
                return;

            i = visibleColumns[visibleColumns.length - 1].colNum + 1;
            // add more if we have room
            if (totalWidth < displayWidth && i < displayableColumns.length)
            {
                n = displayableColumns.length;
                for (; i < n && totalWidth < displayWidth; i++)
                {
                    col = displayableColumns[i];

                    visibleColumns.push(col);
                    totalWidth += isNaN(col.explicitWidth) ? col.preferredWidth : col.explicitWidth;
                }
            }
            else if (totalWidth < displayWidth && horizontalScrollPosition > 0)
            {
                while (totalWidth < displayWidth && horizontalScrollPosition > 0)
                {
                    col = displayableColumns[lockedColumnCount + horizontalScrollPosition - 1];
                    cw = isNaN(col.explicitWidth) ? col.preferredWidth : col.explicitWidth;
                    if (cw < displayWidth - totalWidth)
                    {
                        visibleColumns.splice(lockedColumnCount, 0, col);
                        super.horizontalScrollPosition--;
                        totalWidth += cw;
                    }
                    else
                    {
                        break;
                    }
                }
            }

            lastColumn = visibleColumns[visibleColumns.length - 1];
            cw = isNaN(lastColumn.explicitWidth) ? lastColumn.preferredWidth : lastColumn.explicitWidth;
            newSize = cw + displayWidth - totalWidth;

            if (lastColumn == displayableColumns[displayableColumns.length - 1]
                && lastColumn.resizable 
                && newSize >= lastColumn.minWidth
                && newSize > cw)
            {
                lastColumn.setWidth(newSize);
                maxHorizontalScrollPosition =
                    displayableColumns.length - visibleColumns.length;
            }
            else
            {
                if (visibleColumns.length == displayableColumns.length)
                {
                    // set scrollPosition to zero
                    maxHorizontalScrollPosition = 0;
                    super.horizontalScrollPosition = 0;
                }
                else if(lockedColumnCount < visibleColumns.length)
                {
                    maxHorizontalScrollPosition =
                        displayableColumns.length - visibleColumns.length + 1;
                }
                else
                {
                    maxHorizontalScrollPosition =
                        Math.max(0, displayableColumns.length - lockedColumnCount + 1);
                    super.horizontalScrollPosition = Math.min(horizontalScrollPosition, maxHorizontalScrollPosition);
                }
            }
        }
    }

    /**
     *  @private
     *  If there is no horizontal scroll bar, changes the display width of other columns when
     *  one column's width is changed.
     *  @param col column whose width is changed
     *  @param w width of column
     */
    mx_internal function resizeColumn(col:int, w:Number):void
    {
        // there's a window of time before we calccolumnsizes
        // that someone can set width in AS
        if (!visibleColumns || visibleColumns.length == 0)
        {
            columns[col].setWidth(w);
            columns[col].preferredWidth = w;
            return;
        }

        if (w < columns[col].minWidth)
            w = columns[col].minWidth;

        // hScrollBar is present
        if (_horizontalScrollPolicy == ScrollPolicy.ON ||
            _horizontalScrollPolicy == ScrollPolicy.AUTO)
        {
            // adjust the column's width
            columns[col].setWidth(w);
            columns[col].explicitWidth = w;
            columns[col].preferredWidth = w;
            columnsInvalid = true;
        }
        else
        {
            // find the columns in the set of visible columns;
            var n:int = visibleColumns.length;
            var i:int;
            for (i = 0; i < n; i++)
            {
                if (col == visibleColumns[i].colNum)
                    break;
            }
            if (i >= visibleColumns.length)
                return;
            col = i;

            // we want all cols's new widths to the right of this to be in proportion
            // to what they were before the stretch.

            // get the original space to the right not taken up by the column
            var totalSpace:Number = 0;
            var lastColumn:AdvancedDataGridColumn;
            var newWidth:Number;
            //non-resizable columns don't count though
            var optimumColumns:Array = getOptimumColumns();
            for (i = col + 1; i < n; i++)
            {
                if (optimumColumns[i].resizable)
                    totalSpace += visibleColumns[i].width;
            }

            var newTotalSpace:Number = optimumColumns[col].width - w + totalSpace;
            if (totalSpace)
            {
                optimumColumns[col].setWidth(w);
                optimumColumns[col].explicitWidth = w;
            }

            var totX:Number = 0;
            // resize the columns to the right proportionally to what they were
            for (i = col + 1; i < n; i++)
            {
                if (optimumColumns[i].resizable)
                {
                    newWidth = Math.floor(visibleColumns[i].width
                                          * newTotalSpace / totalSpace);
                    if (newWidth < visibleColumns[i].minWidth)
                        newWidth = visibleColumns[i].minWidth;
                    optimumColumns[i].setWidth(newWidth);
                    totX += optimumColumns[i].width;
                    lastColumn = optimumColumns[i];
                }
            }

            if (totX > newTotalSpace)
            {
                // if excess then should be taken out only from changing column
                // cause others would have already gone to their minimum
                newWidth = optimumColumns[col].width - totX + newTotalSpace;
                if (newWidth < optimumColumns[col].minWidth)
                    newWidth = optimumColumns[col].minWidth;
                optimumColumns[col].setWidth(newWidth);
            }
            else if (lastColumn)
            {
                // if less then should be added in last column
                // dont need to check for minWidth as we are adding
                lastColumn.setWidth(lastColumn.width - totX + newTotalSpace);
            }
        }
        itemsSizeChanged = true;

        updateSubContent();

        invalidateDisplayList();
    }

    /**
     *  Draws the background of the headers into the given 
     *  UIComponent.  The graphics drawn can be scaled horizontally
     *  if the component's width changes, or this method will be
     *  called again to redraw at a different width and/or height
     *
     *  @param headerBG A UIComponent that will contain the header
     *  background graphics.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function drawHeaderBackground(headerBG:UIComponent):void
    {
        var tot:Number = displayWidth;

        // If we have vScroll only, extend the header over the scrollbar
        if (verticalScrollBar != null &&
            _horizontalScrollPolicy == ScrollPolicy.OFF &&
            headerVisible)
        {
            var bm:EdgeMetrics = borderMetrics;
            var adjustedWidth:Number = unscaledWidth - (bm.left + bm.right);
            tot = adjustedWidth;
            // Need to extend mask too.
            maskShape.width = adjustedWidth;
        }

        var hh:Number = headerRowInfo.length ? headerRowInfo[0].height : headerHeight;

        var g:Graphics = headerBG.graphics;
        g.clear();
        var colors:Array = getStyle("headerColors");
        styleManager.getColorNames(colors);

        var matrix:Matrix = new Matrix();
        matrix.createGradientBox(tot, hh + 1, Math.PI/2, 0, 0);

        colors = [ colors[0], colors[0], colors[1] ];
        var ratios:Array = [ 0, 60, 255 ];
        var alphas:Array = [ 1.0, 1.0, 1.0 ];

        g.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
        g.lineStyle(0, 0x000000, 0);
        g.moveTo(0, 0);
        g.lineTo(tot, 0);
        g.lineTo(tot, hh - 0.5);
        g.lineStyle(0, getStyle("borderColor"), 100);
        g.lineTo(0, hh - 0.5);
        g.lineStyle(0, 0x000000, 0);
        g.endFill();
    }

    private function drawHeaderBackgroundSkin(headerBGSkin:IFlexDisplayObject):void
    {
        var tot:Number = displayWidth;

        // If we have vScroll only, extend the header over the scrollbar
        if (verticalScrollBar != null &&
            _horizontalScrollPolicy == ScrollPolicy.OFF &&
            headerVisible)
        {
            var bm:EdgeMetrics = borderMetrics;
            var adjustedWidth:Number = unscaledWidth - (bm.left + bm.right);
            tot = adjustedWidth;
            // Need to extend mask too.
            maskShape.width = adjustedWidth;
        }

        var hh:Number = headerRowInfo.length ? headerRowInfo[0].height : headerHeight;
        headerBGSkin.setActualSize(tot,hh);     
    }

    /**
     *  Draws a row background 
     *  at the position and height specified using the
     *  color specified.  This implementation creates a Shape as a
     *  child of the input Sprite and fills it with the appropriate color.
     *  This method also uses the <code>backgroundAlpha</code> style property 
     *  setting to determine the transparency of the background color.
     * 
     *  @param s A Sprite that will contain a display object
     *  that contains the graphics for that row.
     *
     *  @param rowIndex The row's index in the set of displayed rows.  The
     *  header does not count, the top most visible row has a row index of 0.
     *  This is used to keep track of the objects used for drawing
     *  backgrounds so a particular row can re-use the same display object
     *  even though the index of the item that row is rendering has changed.
     *
     *  @param y The suggested y position for the background.
     * 
     *  @param height The suggested height for the indicator.
     * 
     *  @param color The suggested color for the indicator.
     * 
     *  @param dataIndex The index of the item for that row in the
     *  data provider.  This can be used to color the tenth item differently,
     *  for example.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function drawRowBackground(s:Sprite, rowIndex:int,
                                         y:Number, height:Number, color:uint, dataIndex:int):void
    {
        var background:Shape;
        if (rowIndex < s.numChildren)
        {
            background = Shape(s.getChildAt(rowIndex));
        }
        else
        {
            background = new FlexShape();
            background.name = "background";
            s.addChild(background);
        }

        background.y = y;

        // Height is usually as tall is the items in the row, but not if
        // it would extend below the bottom of listContent
        var height:Number = Math.min(height,
                                     listContent.height -
                                     y);

        var g:Graphics = background.graphics;
        g.clear();
        g.beginFill(color, getStyle("backgroundAlpha"));
        g.drawRect(0, 0, displayWidth, height);
        g.endFill();
    }

    /**
     *  Draws a column background for a column with the suggested color.
     *  This implementation creates a Shape as a
     *  child of the input Sprite and fills it with the appropriate color.
     *
     *  @param s A Sprite that will contain a display object
     *  that contains the graphics for that column.
     *
     *  @param columnIndex The column's index in the set of displayed columns.  
     *  The left-most visible column has a column index of 0.
     *  This is used to keep track of the objects used for drawing
     *  backgrounds, so a particular column can re-use the same display object
     *  even though the index of the AdvancedDataGridColumn for that column has changed.
     *
     *  @param color The suggested color for the indicator.
     * 
     *  @param column The column of the AdvancedDataGrid control that you are drawing the background for.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function drawColumnBackground(s:Sprite, columnIndex:int,
                                            color:uint, column:AdvancedDataGridColumn):void
    {
        var background:Shape;
        background = Shape(s.getChildByName(columnIndex.toString()));
        if (!background)
        {
            background = new FlexShape();
            s.addChild(background);
            background.name = columnIndex.toString();
        }

        var g:Graphics = background.graphics;
        g.clear();

        if(columnIndex >= lockedColumnCount && 
           columnIndex < lockedColumnCount + horizontalScrollPosition)
            return;

        g.beginFill(color);

        var lastRow:Object = rowInfo[listItems.length - 1];
        var headerInfo:AdvancedDataGridHeaderInfo = getHeaderInfo(getOptimumColumns()[columnIndex]);
        var xx:Number = headerInfo.headerItem.x;
        if(columnIndex >= lockedColumnCount)
            xx = getAdjustedXPos(xx);
        var yy:Number = headerRowInfo[0].y;

        if (headerVisible)
            yy += headerRowInfo[0].height;

        // Height is usually as tall is the items in the row, but not if
        // it would extend below the bottom of listContent
        var height:Number = Math.min(lastRow.y + lastRow.height,
                                     listContent.height - yy);

        g.drawRect(xx, yy, headerInfo.headerItem.width,
                   listContent.height - yy);
        g.endFill();
    }

    /**
     *  Creates and sizes the horizontalSeparator skins. If none have been specified, then draws the lines using
     *  drawHorizontalLine(). 
     *  
     *  @private
     */
    private function drawHorizontalSeparator(s:Sprite, rowIndex:int, color:uint, y:Number):void
    {
        var useLockedSeparator:Boolean = false;

        if (lockedRowCount > 0 && rowIndex == lockedRowCount - 1)
        {
            useLockedSeparator = true;
        }

        var hSepSkinName:String = "hSeparator" + rowIndex;
        var hLockedSepSkinName:String = "hLockedSeparator" + rowIndex;
        var createThisSkinName:String = useLockedSeparator ? hLockedSepSkinName : hSepSkinName;
        var createThisStyleName:String = useLockedSeparator ? "horizontalLockedSeparatorSkin" : "horizontalSeparatorSkin";

        var sepSkin:IFlexDisplayObject;
        var lockedSepSkin:IFlexDisplayObject;
        var deleteThisSkin:IFlexDisplayObject;
        var createThisSkin:IFlexDisplayObject;

        // Look for separator by name
        sepSkin = IFlexDisplayObject(s.getChildByName(hSepSkinName));
        lockedSepSkin = IFlexDisplayObject(s.getChildByName(hLockedSepSkinName));

        createThisSkin = useLockedSeparator ? lockedSepSkin : sepSkin;
        deleteThisSkin = useLockedSeparator ? sepSkin : lockedSepSkin;

        if (deleteThisSkin)
        {
            s.removeChild(DisplayObject(deleteThisSkin));
            //delete deleteThisSkin;
        }

        if (!createThisSkin)
        {
            var sepSkinClass:Class = Class(getStyle(createThisStyleName));

            if (sepSkinClass)
            {
                createThisSkin = IFlexDisplayObject(new sepSkinClass());
                createThisSkin.name = createThisSkinName;

                var styleableSkin:ISimpleStyleClient = createThisSkin as ISimpleStyleClient;
                if (styleableSkin)
                    styleableSkin.styleName = this;

                s.addChild(DisplayObject(createThisSkin));
            }
        }

        if (createThisSkin)
        {
            var mHeight:Number = !isNaN(createThisSkin.measuredHeight) ? createThisSkin.measuredHeight : 1;
            createThisSkin.setActualSize(displayWidth, mHeight); 
            createThisSkin.move(0, y);     
        }
        else // If we still don't have a sepSkin, then we have no skin style defined. Use the default function instead
        {
            drawHorizontalLine(s, rowIndex, color, y);
        }

    }

    /**
     *  Draws a line between rows.  This implementation draws a line
     *  directly into the given Sprite.  The Sprite has been cleared
     *  before lines are drawn into it.
     *
     *  @param s A Sprite that will contain a display object
     *  that contains the graphics for that row.
     *
     *  @param rowIndex The row's index in the set of displayed rows.  The
     *  header does not count; the top-most visible row has a row index of 0.
     *  This is used to keep track of the objects used for drawing
     *  backgrounds so a particular row can re-use the same display object
     *  even though the index of the item that row is rendering has changed.
     *
     *  @param color The suggested color for the indicator.
     * 
     *  @param y The suggested y position for the background.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function drawHorizontalLine(s:Sprite, rowIndex:int, color:uint, y:Number):void
    {
        var g:Graphics = s.graphics;

        if (lockedRowCount > 0 && rowIndex == lockedRowCount-1)
            g.lineStyle(1, 0);
        else
            g.lineStyle(1, color);
        
        g.moveTo(0, y);
        g.lineTo(displayWidth, y);
    }

    /**
     *  Creates and sizes the verticalSeparator skins. If none have been specified, then draws the lines using
     *  drawVerticalLine(). 
     *  
     *  @private
     */
    private function drawVerticalSeparator(s:Sprite, colIndex:int, color:uint, x:Number, y:Number):void
    {
        var useLockedSeparator:Boolean = false;

        if (lockedColumnCount > 0 && colIndex == lockedColumnCount-1)
        {
            useLockedSeparator = true;
        }

        var vSepSkinName:String = "vSeparator" + colIndex;
        var vLockedSepSkinName:String = "vLockedSeparator" + colIndex;
        var createThisSkinName:String = useLockedSeparator ? vLockedSepSkinName : vSepSkinName;
        var createThisStyleName:String = useLockedSeparator ? "verticalLockedSeparatorSkin" : "verticalSeparatorSkin";

        var sepSkin:IFlexDisplayObject;
        var lockedSepSkin:IFlexDisplayObject;
        var deleteThisSkin:IFlexDisplayObject;
        var createThisSkin:IFlexDisplayObject;

        // Look for separator by name
        sepSkin = IFlexDisplayObject(s.getChildByName(vSepSkinName));
        lockedSepSkin = IFlexDisplayObject(s.getChildByName(vLockedSepSkinName));

        createThisSkin = useLockedSeparator ? lockedSepSkin : sepSkin;
        deleteThisSkin = useLockedSeparator ? sepSkin : lockedSepSkin;

        if (deleteThisSkin)
        {
            s.removeChild(DisplayObject(deleteThisSkin));
            //delete deleteThisSkin;
        }

        if (!createThisSkin)
        {
            var sepSkinClass:Class = Class(getStyle(createThisStyleName));

            if (sepSkinClass)
            {
                createThisSkin = IFlexDisplayObject(new sepSkinClass());
                createThisSkin.name = createThisSkinName;

                var styleableSkin:ISimpleStyleClient = createThisSkin as ISimpleStyleClient;
                if (styleableSkin)
                    styleableSkin.styleName = this;

                s.addChild(DisplayObject(createThisSkin));
            }
        }

        if (createThisSkin)
        {
            var mWidth:Number = !isNaN(createThisSkin.measuredWidth) ? createThisSkin.measuredWidth : 1;
            createThisSkin.setActualSize(mWidth, listContent.height); 
            createThisSkin.move(x, y);     
        }
        else // If we still don't have a sepSkin, then we have no skin style defined. Use the default function instead
        {
            drawVerticalLine(s, colIndex, color, x);
        }

    }

    /**
     *  Draws lines between columns.  This implementation draws a line
     *  directly into the given Sprite.  The Sprite has been cleared
     *  before lines are drawn into it.
     *
     *  @param s A Sprite that will contain a display object
     *  that contains the graphics for that row.
     *
     *  @param columnIndex The column's index in the set of displayed columns.  
     *  The left most visible column has a column index of 0.
     *
     *  @param color The suggested color for the indicator.
     * 
     *  @param x The suggested x position for the background.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function drawVerticalLine(s:Sprite, colIndex:int, color:uint, x:Number):void
    {
        //draw our vertical lines
        var g:Graphics = s.graphics;
        if (lockedColumnCount > 0 && colIndex == lockedColumnCount - 1)
            g.lineStyle(1, 0, 100);
        else
            g.lineStyle(1, color, 100);
        
        var tempY:Number = 0;
        if(headerVisible)
        {
            //In case of lockedColumn line, we start it from the top, so that it comes
            //in the header area as well
            if(lockedColumnCount > 0 && colIndex == lockedColumnCount - 1)
            {
                g.moveTo(x, 1);
                g.lineTo(x, headerItems[0][colIndex].height);
            }
            else
                tempY = headerItems[0][colIndex].height;
                
        }

        // draw line from tempY to listContent's height
        g.moveTo(x, tempY);
        g.lineTo(x, listContent.height);
    }

    /**
     *  Draws lines between columns, and column backgrounds.
     *  This implementation calls the <code>drawHorizontalLine()</code>, 
     *  <code>drawVerticalLine()</code>,
     *  and <code>drawColumnBackground()</code> methods as needed.  
     *  It creates a
     *  Sprite that contains all of these graphics and adds it as a
     *  child of the <code>listContent</code> at the front of the z-order.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function drawLinesAndColumnBackgrounds():void
    {
        var lines:Sprite = getLines();
        lines.graphics.clear();

        var len:uint = getNumColumns();
        len = (len != -1)? len : visibleColumns.length;
        // defend against degenerate case when width == 0
        var optimumColumns:Array = getOptimumColumns();
        if (len > optimumColumns.length)
            len = optimumColumns.length;

        // draw horizontal lines
        drawHorizontalSeparators();

        // draw vertical lines
        drawVerticalSeparators();

        // draw column backgrounds
        if (headerInfos && hasHeaderItemsCreated(0) && hasHeaderItemsCreated(len-1))
        {
            var colBGs:Sprite = Sprite(listContent.getChildByName("colBGs"));
            // traverse the columns, set the sizes, draw the column backgrounds
            var lastChild:int = -1;
            for (var i:int = 0; i < len; i++)
            {
                var col:AdvancedDataGridColumn = optimumColumns[i];
                var bgCol:Object;
                if (enabled)
                    bgCol = col.getStyle("backgroundColor");
                else
                    bgCol = col.getStyle("backgroundDisabledColor");

                if (bgCol !== null && !isNaN(Number(bgCol)))
                {
                    if (!colBGs)
                    {
                        colBGs = new FlexSprite();
                        colBGs.mouseEnabled = false;
                        colBGs.name = "colBGs";
                        listContent.addChildAt(colBGs, listContent.getChildIndex(listContent.getChildByName("rowBGs")) + 1);
                    }
                    drawColumnBackground(colBGs, i, Number(bgCol), col);
                    lastChild = i;
                }
                else if (colBGs)
                {
                    var background:Shape = Shape(colBGs.getChildByName(i.toString()));
                    if (background)
                    {
                        var g:Graphics = background.graphics;
                        g.clear();
                        colBGs.removeChild(background);
                    }
                }
            }
            if (colBGs && colBGs.numChildren)
            {
                while (colBGs.numChildren)
                {
                    var bg:DisplayObject = colBGs.getChildAt(colBGs.numChildren - 1);
                    if (parseInt(bg.name) > lastChild)
                        colBGs.removeChild(bg);
                    else
                        break;
                }
            }
        }
    }

    /**
     *  @private
     * 
     *  Call drawHorizontalSeparator() to draw horizontal lines
     */
    protected function drawHorizontalSeparators():void
    {
        // draw horizontalGridlines if needed.
        var lineCol:uint = getStyle("horizontalGridLineColor");
        
        var lockedContent:Sprite = getLockedContent();

        // draw vertical lines in the locked column area        
        var lockedLinesBody:Sprite = Sprite(lockedContent.getChildByName("lockedHorizontalLines"));

        if (lockedLinesBody)
        {
            lockedLinesBody.graphics.clear();
        
            while (lockedLinesBody.numChildren)
            {
                lockedLinesBody.removeChildAt(0);
            }
        }

        //In case of horizontal lines we don't need to care
        //about column locking a line from 0-displayWidth will do
        if (getStyle("horizontalGridLines")
            || lockedRowCount > 0 && lockedRowCount < listItems.length)
        {
            if (!lockedLinesBody)
            {
                lockedLinesBody = new UIComponent();
                lockedLinesBody.name = "lockedHorizontalLines";
                lockedContent.addChild(lockedLinesBody);
            }
            
            if (getStyle("horizontalGridLines"))
            {
                var n:int = listItems.length;
                for (var i:int = 0; i < n; i++)
                {
                    drawHorizontalSeparator(lockedLinesBody, i, lineCol, rowInfo[i].y + rowInfo[i].height);
                }
            }
            else
            {
                drawHorizontalSeparator(lockedLinesBody, lockedRowCount - 1 , lineCol, rowInfo[lockedRowCount - 1].y + rowInfo[lockedRowCount - 1].height);
            }
        }
    }

    /**
     *  @private
     * 
     *  Call drawVerticalSeparator() to draw vertical lines
     */
    protected function drawVerticalSeparators():void
    {
        var lines:Sprite = getLines();

        var lockedContent:Sprite = getLockedContent();
        
        // draw vertical lines in the locked column area        
        var lockedLinesBody:Sprite = Sprite(lockedContent.getChildByName("lockedVerticalLines"));

        if (!lockedLinesBody)
        {
            lockedLinesBody = new UIComponent();
            lockedLinesBody.name = "lockedVerticalLines";
            lockedContent.addChild(lockedLinesBody);
        }
        
        // Make sure that the lockedLinesBody are on a higher index in the childList
        // of lockedContent as compared to resizing separators
        var child:UIComponent = UIComponent(lockedContent.getChildByName("lockedHeaderLines"));
        if(child)
        {
            var childIndex:int = lockedContent.getChildIndex(DisplayObject(child));
            if(childIndex > lockedContent.getChildIndex(DisplayObject(lockedLinesBody)))
                lockedContent.setChildIndex(lockedLinesBody, childIndex);
        }

        lockedLinesBody.graphics.clear();
        
        while (lockedLinesBody.numChildren)
        {
            lockedLinesBody.removeChildAt(0);
        }

        var yVal:Number = (headerVisible && headerRowInfo && headerRowInfo[0]) ? headerRowInfo[0].height : 0;
        var len:uint = Math.min((visibleColumns ? visibleColumns.length : 0), Math.max(0,lockedColumnCount));
        var vLines:Boolean = getStyle("verticalGridLines");
        var lineCol:uint = getStyle("verticalGridLineColor");
        if (vLines && len)
        {           
            for (var i:int = 0; i < len; i++)
            {
                drawVerticalSeparator(lockedLinesBody, i, lineCol, 
                                      getHeaderInfo(visibleColumns[i]).headerItem.x + visibleColumns[i].width, yVal);
            }
        }

        // draw vertical lines in the scrollable area
        var linesBody:Sprite = getLinesBody(lines, "verticalLines");

        // clear the vertical lines and draw them again
        linesBody.graphics.clear();
        
        while (linesBody.numChildren)
        {
            linesBody.removeChildAt(0);
        }

        len = visibleColumns.length;

        // defend against degenerate case when width == 0
        if (len > visibleColumns.length)
            len = visibleColumns.length;

        vLines = getStyle("verticalGridLines");
        lineCol = getStyle("verticalGridLineColor");

        if (vLines && headerInfos && hasHeaderItemsCreated(0) && hasHeaderItemsCreated(len - 1))
        {
            //Check against the negative case
            var lockedColCount:int = Math.max(0, lockedColumnCount);
            
            for (i = lockedColCount; i < len - 1; i++)
            {
                var headerInfo:AdvancedDataGridHeaderInfo = getHeaderInfo(visibleColumns[i]);
                
                drawVerticalSeparator(linesBody, absoluteToVisibleColumnIndex(visibleColumns[i].colNum), lineCol, 
                                      headerInfo.headerItem.x + visibleColumns[i].width, yVal);
            }
        }

        // is this drawing the vertical locked column indicator?
        if (!vLines && lockedColumnCount > 0 && lockedColumnCount < len)
            drawVerticalSeparator(linesBody, lockedColumnCount - 1, lineCol, 
                                  getHeaderInfo(visibleColumns[lockedColumnCount-1]).headerItem.x 
                                  + visibleColumns[lockedColumnCount - 1].width, 0);
    }

    /**
     *  @private
     * 
     *  Get the 'lockedContent' Sprite 
     */
    private function getLockedContent():Sprite
    {
        var locked:Sprite = Sprite(listContent.getChildByName("lockedContent"));
        if (!locked)
        {
            locked = new UIComponent();
            locked.name = "lockedContent";
            locked.cacheAsBitmap = true;
            locked.mouseEnabled = false;
            listContent.addChild(locked);
        }
        listContent.setChildIndex(locked, listContent.numChildren - 1);

        return locked;
    }

    /**
     *  @private
     * 
     *  Get the 'lines' Sprite 
     */
    private function getLines():Sprite
    {
        var lines:Sprite = Sprite(listSubContent.getChildByName("lines"));
        if (!lines)
        {
            lines = new UIComponent();
            lines.name = "lines";
            lines.cacheAsBitmap = true;
            lines.mouseEnabled = false;
            listSubContent.addChild(lines);
        }
        listSubContent.setChildIndex(lines, listSubContent.numChildren - 1);

        return lines;
    }

    /**
     *  @private
     * 
     *  Get the Sprite for horizontal/vertical lines
     */
    private function getLinesBody(lines:Sprite, linesBodyName:String):Sprite
    {
        var linesBody:Sprite = Sprite(lines.getChildByName(linesBodyName));

        if (!linesBody)
        {
            linesBody = new UIComponent();
            linesBody.name = linesBodyName;
            lines.addChild(linesBody);
        }

        return linesBody;
    }

    /**
     *  Removes column header separators that you normally use
     *  to resize columns.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function clearSeparators():void
    {
        if (!separators)
            return;

        var lines:Sprite = Sprite(listSubContent.getChildByName("lines"));
        var headerLines:Sprite = Sprite(lines.getChildByName("header"));
        if (headerLines)
        {
            while (headerLines.numChildren)
            {
                headerLines.removeChildAt(headerLines.numChildren - 1);
                separators.pop();
            }
        }

        var lockedContent:Sprite = getLockedContent();
        headerLines = Sprite(lockedContent.getChildByName("lockedHeaderLines"));
        if (headerLines)
        {
            while (headerLines.numChildren)
            {
                headerLines.removeChildAt(headerLines.numChildren - 1);
                lockedSeparators.pop();
            }
        }
    }

    /**
     *  Creates and displays the column header separators that the user 
     *  normally uses to resize columns.  This implementation uses
     *  the same Sprite as the lines and column backgrounds, adds
     *  instances of the <code>headerSeparatorSkin</code>, and attaches mouse
     *  listeners to them in order to know when the user wants
     *  to resize a column.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function drawSeparators():void
    {
        var lines:Sprite = getLines();
        lines.graphics.clear();
        
        var optimumColumns:Array = getOptimumColumns();

        if (headerSepSkinChanged)
        {
            headerSepSkinChanged = false;
            clearSeparators();
        }

        if (!separators)
        {
            separators = [];
            lockedSeparators = [];
        }

        lines = Sprite(listSubContent.getChildByName("lines"));

        var actualLocked:int = 0;
        var allColsLocked:Boolean = false;
        var numUnLockedSeparators:int = Math.max(0, optimumColumns.length - 1);
        
        var lockedContent:Sprite = getLockedContent();
        var lockedHeaderLines:UIComponent = UIComponent(lockedContent.getChildByName("lockedHeaderLines"));
        var headerLines:UIComponent = UIComponent(lines.getChildByName("header"));
        
        if(optimumColumns && optimumColumns.length > 0)
        {
            if (lockedColumnCount > 0)
            {
                actualLocked = Math.min(lockedColumnCount, optimumColumns.length); 
                allColsLocked = (actualLocked == optimumColumns.length);

                // -1 because we need one less separator, thus when all columns are 
                // locked, we dont draw separator after last column
                if(allColsLocked)
                    actualLocked--;

                //Number of separators left to be drawn in the scrollable area have reduced by actualLocked
                numUnLockedSeparators = numUnLockedSeparators - actualLocked;

                // Drawing a separator at lockedColumn boundary is required for resize cursor to appear
                // when mouse is coming from right
                if(!allColsLocked)
                    numUnLockedSeparators++;

                //Create only if needed i.e lockedColumnCount > 0
                if (!lockedHeaderLines)
                {
                    lockedHeaderLines = new UIComponent();
                    lockedHeaderLines.name = "lockedHeaderLines";
                    lockedContent.addChild(lockedHeaderLines);
                }
            }
            
            if(lockedHeaderLines)
                createHeaderSeparators(actualLocked, lockedSeparators, lockedHeaderLines);

            if (!headerLines)
            {
                headerLines = new UIComponent();
                headerLines.name = "header";
                lines.addChild(headerLines);    
            }

            // Create separators for columns which are not locked
            // -1 because we need one less separator
            createHeaderSeparators(numUnLockedSeparators, separators, headerLines);
        }
        
        // remove extra locked separators
        if(lockedHeaderLines)
            removeExtraSeparators(actualLocked, lockedSeparators, lockedHeaderLines);
        
        // remove extra unlocked separators
        if (headerLines)
            removeExtraSeparators(numUnLockedSeparators, separators, headerLines);
    }

    /**
     *  Returns the header separators between column headers, 
     *  and populates the <code>separators</code> Array with the separators returned.
     * 
     *  @param i The number of separators to return.
     *
     *  @param seperators Array to be populated with the header objects.
     *
     *  @param headerLines The parent component of the header separators. 
     *  Flex calls the <code>headerLines.getChild()</code> method internally to return the separators.
     *
     *  @return The header separators between column headers.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */        
    protected function getSeparator(i:int, seperators:Array, headerLines:UIComponent):UIComponent
    {
        var sep:UIComponent;
        var sepSkin:IFlexDisplayObject;

        if (i < headerLines.numChildren)
        {
            sep = UIComponent(headerLines.getChildAt(i));
            sepSkin = IFlexDisplayObject(sep.getChildAt(0));
        }
        else
        {
            var headerSeparatorClass:Class =
                getStyle("headerSeparatorSkin");
            sepSkin = new headerSeparatorClass();
            if (sepSkin is ISimpleStyleClient)
                ISimpleStyleClient(sepSkin).styleName = this;
            sep = new UIComponent();
            sep.addChild(DisplayObject(sepSkin));
            headerLines.addChild(sep);
            DisplayObject(sep).addEventListener(
                MouseEvent.MOUSE_OVER, columnResizeMouseOverHandler);
            DisplayObject(sep).addEventListener(
                MouseEvent.MOUSE_OUT, columnResizeMouseOutHandler);
            DisplayObject(sep).addEventListener(
                MouseEvent.MOUSE_DOWN, columnResizeMouseDownHandler);
            seperators.push(sep);
        }
        return sep;
    }
    
    
    /**
     *  Creates the header separators between column headers, 
     *  and populates the <code>separators</code> Array with the separators created.
     * 
     *  @param n The number of separators to create.
     *
     *  @param seperators Array to be populated with the header objects.
     *
     *  @param headerLines The parent component of the header separators to which the separators are added. 
     *  That is, Flex calls the <code>headerLines.addChild()</code> method internally to add the separators to the display.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */        
    protected function createHeaderSeparators(n:int, seperators:Array, headerLines:UIComponent):void
    {
        var optimumColumns:Array = getOptimumColumns();

        for (var i:int = 0; i < n; i++)
        {
            var headerItemIndex:int = (lockedColumnCount > 0 && seperators != lockedSeparators) ? i+lockedColumnCount - 1 : i;
            
            var sep:UIComponent = getSeparator(i, seperators, headerLines);
            var sepSkin:IFlexDisplayObject = IFlexDisplayObject(sep.getChildAt(0));
            if (!headerItems || !headerItems[0] || !headerItems[0][headerItemIndex])
            {
                sep.visible = false;
                continue;
            }

            sep.visible = true;
            sep.x = headerItems[0][headerItemIndex].x +
                optimumColumns[headerItemIndex].width - Math.round(sep.measuredWidth / 2 + 0.5);

            if (i > 0)
            {
                sep.x = Math.max(sep.x,
                                 seperators[i - 1].x + Math.round(sep.measuredWidth / 2 + 0.5));
            }
            sep.y = 0;

            sepSkin.setActualSize(sepSkin.measuredWidth,
                                  headerRowInfo.length ?
                                  headerRowInfo[0].height :
                                  headerHeight);

            // Draw invisible background for separator affordance
            sep.graphics.clear();
            sep.graphics.beginFill(0xFFFFFF, 0);
            sep.graphics.drawRect(-separatorAffordance, 0, sepSkin.measuredWidth + separatorAffordance , headerHeight);
            sep.graphics.endFill();
        }
    }
    
    /**
     *  @private
     *  removes the extra separators
     */
    private function removeExtraSeparators(n:int, seperators:Array, headerLines:UIComponent):void
    {
        while (headerLines.numChildren > n)
        {
            headerLines.removeChildAt(headerLines.numChildren - 1);
            seperators.pop();
        }
    }

    /**
     *  @private
     *  Update sortIndex and sortDirection based on sort info availabled in
     *  underlying data provider.
     */
    private function updateSortIndexAndDirection():void
    {
        // Don't show sort indicator if sortableColumns is false or if the
        // column sorted on has sortable="false"

        if (!sortableColumns)
        {
            lastSortIndex = sortIndex;
            sortIndex = -1;

            if (lastSortIndex != sortIndex)
                invalidateDisplayList();

            return;
        }

        if (!dataProvider)
            return;

        var view:ICollectionView = ICollectionView(dataProvider);
        var sort:ISort = view.sort;
        if (!sort)
        {
            sortIndex = lastSortIndex = -1;
            return;
        }

        var fields:Array = sort.fields;
        if (!fields)
            return;

        if (fields.length != 1)
        {
            lastSortIndex = sortIndex;
            sortIndex = -1;

            if (lastSortIndex != sortIndex)
                invalidateDisplayList();

            return;
        }

        // fields.length == 1, so the collection is sorted on a single field.
        var sortField:ISortField = fields[0];
        var n:int = _columns.length;
        for (var i:int = 0; i < n; i++)
        {
            if (_columns[i].dataField == sortField.name)
            {
                sortIndex = _columns[i].sortable ? i : -1;
                sortDirection = sortField.descending ? "DESC" : "ASC";
                return;
            }
        }
    }

    /**
     *  @private
     */
    private function setEditedItemPosition(coord:Object):void
    {
        bEditedItemPositionChanged = true;
        _proposedEditedItemPosition = coord;
        invalidateDisplayList();
    }

    /**
     *  @private
     *  focus an item renderer in the grid - harder than it looks
     */
    private function commitEditedItemPosition(coord:Object):void
    {
        if (!enabled || !editable.length)
            return;

        // just give focus back to the itemEditorInstance
        if (itemEditorInstance && coord &&
            itemEditorInstance is IFocusManagerComponent &&
            _editedItemPosition.rowIndex == coord.rowIndex &&
            _editedItemPosition.columnIndex == coord.columnIndex)
        {
            IFocusManagerComponent(itemEditorInstance).setFocus();
            return;
        }

        // dispose of any existing editor, saving away its data first
        if (itemEditorInstance)
        {
            var reason:String;
            if (!coord)
            {
                reason = AdvancedDataGridEventReason.OTHER;
            }
            else
            {
                reason = (!editedItemPosition || coord.rowIndex == editedItemPosition.rowIndex) ?
                    AdvancedDataGridEventReason.NEW_COLUMN :
                    AdvancedDataGridEventReason.NEW_ROW;
            }
            if (!endEdit(reason) && reason != AdvancedDataGridEventReason.OTHER)
                return;
        }

        // store the value
        _editedItemPosition = coord;

        // allow setting of undefined to dispose item editor instance
        if (!coord)
            return;

        if (dontEdit)
        {
            return;
        }

        var rowIndex:int = coord.rowIndex;
        var colIndex:int = coord.columnIndex;
        if (displayableColumns.length != _columns.length)
        {
            var n:int = displayableColumns.length;
            for (var i:int = 0; i < n; i++)
            {
                if (displayableColumns[i].colNum >= colIndex)
                {
                    colIndex = i;
                    break;
                }
            }
            if (i == displayableColumns.length)
                colIndex = 0;
        }

        // trace("commitEditedItemPosition ", coord.rowIndex, selectedIndex);

        var needChangeEvent:Boolean = false;
        if (selectedIndex != coord.rowIndex)
        {
            commitSelectedIndex(coord.rowIndex);
            needChangeEvent = true;
        }

        var actualLockedRows:int = lockedRowCount;
        var lastRowIndex:int = verticalScrollPosition + listItems.length - 1;
        var partialRow:int = (rowInfo[listItems.length - 1].y + rowInfo[listItems.length - 1].height > listContent.height) ? 1 : 0;

        // actual row/column is the offset into listItems
        if (rowIndex > actualLockedRows)
        {
            // not a locked editable row make sure it is on screen
            if (rowIndex < verticalScrollPosition + actualLockedRows)
                verticalScrollPosition = rowIndex - actualLockedRows;
            else
            {
                // variable row heights means that we can't know how far to scroll sometimes so we loop
                // until we get it right
                while (rowIndex > lastRowIndex ||
                       // we're the last row, and we're partially visible, but we're not
                       // the top scrollable row already
                       (rowIndex == lastRowIndex && rowIndex > verticalScrollPosition + actualLockedRows &&
                        partialRow))
                {
                    if (verticalScrollPosition == maxVerticalScrollPosition)
                        break;
                    verticalScrollPosition = Math.min(verticalScrollPosition + (rowIndex > lastRowIndex ? rowIndex - lastRowIndex : partialRow), maxVerticalScrollPosition);
                    lastRowIndex = verticalScrollPosition + listItems.length - 1;
                    partialRow = (rowInfo[listItems.length - 1].y + rowInfo[listItems.length - 1].height > listContent.height) ? 1 : 0;
                }
            }
            actualRowIndex = rowIndex - verticalScrollPosition;
        }
        else
        {
            if (rowIndex == actualLockedRows)
                verticalScrollPosition = 0;

            actualRowIndex = rowIndex;
        }

        var bm:EdgeMetrics = borderMetrics;

        var len:uint = /*(headerItems && headerItems[0]) ? headerItems[0].length :*/ visibleColumns.length;
        var lastColIndex:int = horizontalScrollPosition + len - 1;

        // TODO with locked columns this won't give correct results?
        var headerInfo:AdvancedDataGridHeaderInfo = getHeaderInfo(visibleColumns[visibleColumns.length-1]);
        var partialCol:int = (headerInfo.headerItem.x + headerInfo.column.width
                                > listContent.width) ? 1 : 0;

        if(colIndex > lockedColumnCount)
        {
            if (colIndex < horizontalScrollPosition + lockedColumnCount)
            {
                horizontalScrollPosition = colIndex - lockedColumnCount;
            }
            else
            {
                while (colIndex > lastColIndex ||
                       (colIndex == lastColIndex && colIndex > horizontalScrollPosition + lockedColumnCount &&
                        partialCol))
                {
                    if (horizontalScrollPosition == maxHorizontalScrollPosition)
                        break;
                    horizontalScrollPosition = Math.min(horizontalScrollPosition + (colIndex > lastColIndex ? colIndex - lastColIndex : partialCol), maxHorizontalScrollPosition);

                    lastColIndex = horizontalScrollPosition + visibleColumns.length - 1;
                    headerInfo = getHeaderInfo(visibleColumns[visibleColumns.length - 1]);
                    partialCol = (headerInfo.headerItem.x + headerInfo.headerItem.width > listContent.width) ? 1 : 0;
                }
            }
            // Need to get the index in visibleColumns
            actualColIndex = absoluteToVisibleColumnIndex(displayToAbsoluteColumnIndex(colIndex));
        }
        else
        {
            if (colIndex == lockedColumnCount)
                horizontalScrollPosition = 0;

            actualColIndex = colIndex;
        }

        // get the actual references for the column, row, and item
        var item:IListItemRenderer;
        if (listItems[actualRowIndex] && listItems[actualRowIndex][actualColIndex])
            item = listItems[actualRowIndex][actualColIndex];
        if (!item)
        {
            // assume that editing was cancelled
            commitEditedItemPosition(null);
            return;
        }

        if (needChangeEvent)
        {
            var evt:ListEvent = new ListEvent(ListEvent.CHANGE);
            evt.columnIndex = coord.columnIndex;
            evt.rowIndex = coord.rowIndex;;
            evt.itemRenderer = item;
            dispatchEvent(evt);
        }

        var event:AdvancedDataGridEvent =
            new AdvancedDataGridEvent(AdvancedDataGridEvent.ITEM_EDIT_BEGIN, false, true);
        // ITEM_EDIT events are cancelable
        event.columnIndex = displayableColumns[colIndex].colNum;
        event.rowIndex = _editedItemPosition.rowIndex;
        event.itemRenderer = item;
        dispatchEvent(event);

        lastEditedItemPosition = _editedItemPosition;

        // user may be trying to change the focused item renderer
        if (bEditedItemPositionChanged)
        {
            bEditedItemPositionChanged = false;
            commitEditedItemPosition(_proposedEditedItemPosition);
            _proposedEditedItemPosition = undefined;

        }

        if (!itemEditorInstance)
        {
            // assume that editing was cancelled
            commitEditedItemPosition(null);
        }
    }

    /**
     *  Creates the item editor for the item renderer at the
     *  <code>editedItemPosition</code> using the editor
     *  specified by the <code>itemEditor</code> property.
     *
     *  <p>This method sets the editor instance as the 
     *  <code>itemEditorInstance</code> property.</p>
     *
     *  <p>You may only call this method from within the event listener
     *  for the <code>itemEditBegin</code> event. 
     *  To create an editor at other times, set the
     *  <code>editedItemPosition</code> property to generate 
     *  the <code>itemEditBegin</code> event.</p>
     *
     *  @param colIndex The column index in the data provider of the item to be edited.
     *
     *  @param rowIndex The row index in the data provider of the item to be edited.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function createItemEditor(colIndex:int, rowIndex:int):void
    {
        if (displayableColumns.length != _columns.length)
        {
            var n:int = displayableColumns.length;
            for (var i:int = 0; i < n; i++)
            {
                if (displayableColumns[i].colNum >= colIndex)
                {
                    colIndex = i;
                    break;
                }
            }
            if (i == displayableColumns.length)
                colIndex = 0;
        }

        var col:AdvancedDataGridColumn = displayableColumns[colIndex];
        if (rowIndex > lockedRowCount)
            rowIndex -= verticalScrollPosition;

        if (colIndex > lockedColumnCount)
            colIndex -= horizontalScrollPosition;

        var item:IListItemRenderer;
        item = listItems[actualRowIndex][actualColIndex];
        
        var rowData:ListRowInfo = rowInfo[actualRowIndex];

        // Before the editor opens up, change the label to the original data
        // and not the label which is (possibly) formatted data.
        // See AdvancedDataGridColumn.itemToLabel() regarding formatter.
        if (item is IDropInListItemRenderer)
            IDropInListItemRenderer(item).listData.label = col.itemToLabel(item.data, false);

        if (!col.rendererIsEditor)
        {
            var dx:Number = 0;
            var dy:Number = -2;
            var dw:Number = 0;
            var dh:Number = 4;
            // if this isn't implemented, use an input control as editor
            if (!itemEditorInstance)
            {
                var itemEditor:IFactory = col.itemEditor;
                if (itemEditor == AdvancedDataGridColumn.defaultItemEditorFactory)
                {
                    // if it is the default factory, see if someone
                    // overrode it with this style
                    var c:Class = getStyle("defaultDataGridItemEditor");
                    if (c)
                    {
                        var fontName:String =
                            StringUtil.trimArrayElements(col.getStyle("fontFamily"), ",");
                        var fontWeight:String = col.getStyle("fontWeight");
                        var fontStyle:String = col.getStyle("fontStyle");
                        var bold:Boolean = (fontWeight == "bold");
                        var italic:Boolean = (fontStyle == "italic");
                        
                        var flexModuleFactory:IFlexModuleFactory =
                            getFontContext(fontName, bold, italic);
                        
                        itemEditor = col.itemEditor = new ContextualClassFactory(
                            c, flexModuleFactory);
                    }
                }
                
                dx = col.editorXOffset;
                dy = col.editorYOffset;
                dw = col.editorWidthOffset;
                dh = col.editorHeightOffset;
                itemEditorInstance = itemEditor.newInstance();
                itemEditorInstance.owner = this;
                itemEditorInstance.styleName = col;
                addRendererToContentArea(itemEditorInstance, col);
            }
            itemEditorInstance.parent.setChildIndex(DisplayObject(itemEditorInstance), 
                                                    itemEditorInstance.parent.numChildren - 1);
            // give it the right size, look and placement
            itemEditorInstance.visible = true;

            var itemXPos:Number = item.x + dx;
            
            itemEditorInstance.move(itemXPos, rowData.y + dy);

            // Original code:
            /*
              itemEditorInstance.setActualSize(Math.min(col.width + dw, 
              listContent.width - listContent.x - itemXPos),
              Math.min(rowData.height + dh, listContent.height - listContent.y - itemEditorInstance.y));
              DisplayObject(itemEditorInstance).addEventListener(FocusEvent.FOCUS_OUT, itemEditorFocusOutHandler);
              listContent.width - listContent.x - itemXPos),
              Math.min(rowData.height + dh, listContent.height - listContent.y - itemEditorInstance.y));
            */

            // To support column spanning:
            itemEditorInstance.setActualSize(editedItemRenderer.width + dw,
                                             Math.min(rowData.height + dh,
                                                      listContent.height - listContent.y - itemEditorInstance.y));

            DisplayObject(itemEditorInstance).addEventListener(FocusEvent.FOCUS_OUT, itemEditorFocusOutHandler);
            // Commenting to show the item (with disclosure icon) behind the item editor
            //item.visible = false;

            layoutItemEditor();
        }
        else
        {
            // if the item renderer is also the editor, we'll use it
            itemEditorInstance = item;
        }

        // listen for keyStrokes on the itemEditorInstance (which lets the grid supervise for ESC/ENTER)
        DisplayObject(itemEditorInstance).addEventListener(KeyboardEvent.KEY_DOWN, editorKeyDownHandler);
        // we disappear on any mouse down outside the editor
        systemManager.getSandboxRoot().
            addEventListener(MouseEvent.MOUSE_DOWN, editorMouseDownHandler, true, 0, true);
        systemManager.getSandboxRoot().
            addEventListener(SandboxMouseEvent.MOUSE_DOWN_SOMEWHERE, editorMouseDownHandler, false, 0, true);
        // we disappear if stage is resized
        systemManager.addEventListener(Event.RESIZE, editorStageResizeHandler, true, 0, true);
    }

    /**
     *  @private
     *  Determines the next item renderer to navigate to using the Tab key.
     *  If the item renderer to be focused falls out of range (the end or beginning
     *  of the grid) then move focus outside the grid.
     */
    private function findNextItemRenderer(shiftKey:Boolean):Boolean
    {
        if (!lastEditedItemPosition)
            return false;

        if (!editable.length)
        {
            loseFocus();
            return false;
        }

        // some other thing like a collection change has changed the
        // position, so bail and wait for commit to reset the editor.
        if (_proposedEditedItemPosition !== undefined)
            return false;

        _editedItemPosition = lastEditedItemPosition;

        var index:int = _editedItemPosition.rowIndex;
        var colIndex:int = _editedItemPosition.columnIndex;

        var found:Boolean = false;
        var incr:int = shiftKey ? -1 : 1;
        var maxIndex:int = collection.length - 1;
        var itemRenderer:IListItemRenderer;

        // cycle till we find something worth focusing, or the end of the grid
        while (!found)
        {
            // go to next column
            colIndex += incr;
            if (colIndex >= _columns.length || colIndex < 0)
            {
                // if we fall off the end of the columns, wrap around
                colIndex = (colIndex < 0) ? _columns.length - 1 : 0;
                // and increment/decrement the row index
                index += incr;
                if (index > maxIndex || index < 0)
                {
                    loseFocus();
                    return false;
                }
            }

            // We have to skip cells where the item renderer is invisible so
            // that we handle column spanning i.e. we should not open editors
            // where column spanning is applied and the column should not be
            // considered.
            // TODO here we are checking for
            // existence even before scrolling.
            var visibleCoords:Object = absoluteToVisibleIndices(index, colIndex);
            var visibleRowIndex:int = visibleCoords.rowIndex;
            var visibleColIndex:int = visibleCoords.columnIndex;

            if (visibleColIndex > -1) // column.visible=false
            {
                // Assumption that item renderer is never invisible in the
                // first column! i.e. When in last row, skip to the new last row's
                // first column directly without checking the item renderer's
                // visibility.
                if (visibleRowIndex == listItems.length) // last row last column -> tab
                    visibleRowIndex -= 1;
                else if (visibleRowIndex == -1) // first row first column -> shift-tab
                    visibleRowIndex = 0;
                itemRenderer = null;
                if (listItems[visibleRowIndex] && listItems[visibleRowIndex][visibleColIndex])
                    itemRenderer = listItems[visibleRowIndex][visibleColIndex];
                if (itemRenderer && !itemRenderer.visible) // handle column-spanning
                    continue;
            }

            var newData:Object = rowNumberToData(index);
            if (newData == null)
                return true;
            if (!isDataEditable(newData))
                continue;

            // if we find a visible and editable column, move to it
            // if the item is visible, then only create item editor for it
            if (_columns[colIndex].editable && _columns[colIndex].visible)
            {
                found = true;
                // kill the old edit session
                var reason:String;
                reason = index == _editedItemPosition.rowIndex ?
                    AdvancedDataGridEventReason.NEW_COLUMN :
                    AdvancedDataGridEventReason.NEW_ROW;
                if (!itemEditorInstance || endEdit(reason))
                {
                    // send event to create the new one
                    var advancedDataGridEvent:AdvancedDataGridEvent =
                        new AdvancedDataGridEvent(AdvancedDataGridEvent.ITEM_EDIT_BEGINNING, false, true);
                    // ITEM_EDIT events are cancelable
                    advancedDataGridEvent.columnIndex = colIndex;
                    advancedDataGridEvent.dataField = _columns[colIndex].dataField;
                    advancedDataGridEvent.rowIndex = index;
                    dispatchEvent(advancedDataGridEvent);
                }
            }
        }
        return found;
    }

    private function loseFocus():void
    {
        // if we've fallen off the rows, we need to leave the grid. get rid of the editor
        setEditedItemPosition(null);
        // set focus back to the grid so default handler will move it to the next component
        losingFocus = true;
        setFocus();
    }

    /**
     *  This method closes an item editor currently open on an item renderer. 
     *  You typically call this method only from within the event listener 
     *  for the <code>itemEditEnd</code> event, after
     *  you have already called the <code>preventDefault()</code> method to 
     *  prevent the default event listener from executing.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function destroyItemEditor():void
    {
        // trace("destroyItemEditor");
        if (itemEditorInstance)
        {
            DisplayObject(itemEditorInstance).removeEventListener(KeyboardEvent.KEY_DOWN, editorKeyDownHandler);
            systemManager.getSandboxRoot().
                removeEventListener(MouseEvent.MOUSE_DOWN, editorMouseDownHandler, true);
            systemManager.getSandboxRoot().
                removeEventListener(SandboxMouseEvent.MOUSE_DOWN_SOMEWHERE, editorMouseDownHandler);
            systemManager.removeEventListener(Event.RESIZE, editorStageResizeHandler, true);

            var event:AdvancedDataGridEvent =
                new AdvancedDataGridEvent(AdvancedDataGridEvent.ITEM_FOCUS_OUT);
            event.columnIndex = _editedItemPosition.columnIndex;
            event.rowIndex = _editedItemPosition.rowIndex;
            event.itemRenderer = itemEditorInstance;
            dispatchEvent(event);

            if (! _columns[_editedItemPosition.columnIndex].rendererIsEditor)
            {
                // FocusManager.removeHandler() does not find
                // itemEditors in focusableObjects[] array
                // and hence does not remove the focusRectangle
                if (itemEditorInstance && itemEditorInstance is UIComponent)
                    UIComponent(itemEditorInstance).drawFocus(false);

                // must call removeChild() so FocusManager.lastFocus becomes null
                itemEditorInstance.parent.removeChild(DisplayObject(itemEditorInstance));

                // we are not setting the item renderer's visibility to false while creating an editor,
                // then why set its visibility to true
                // setting it visible will display the invisible item renderer in case of Custom Rows
                //editedItemRenderer.visible = true;
            }
            itemEditorInstance = null;
            _editedItemPosition = null;
        }
    }

    /**
     *  @private
     *  When the user finished editing an item, this method is called.
     *  It dispatches the AdvancedDataGridEvent.ITEM_EDIT_END event to start the process
     *  of copying the edited data from
     *  the itemEditorInstance to the data provider and hiding the itemEditorInstance.
     *  returns true if nobody called preventDefault.
     */
    protected function endEdit(reason:String):Boolean
    {
        // this happens if the renderer is removed asynchronously ususally with FDS
        if (!editedItemRenderer)
            return true;

        inEndEdit = true;

        var advancedDataGridEvent:AdvancedDataGridEvent =
            new AdvancedDataGridEvent(AdvancedDataGridEvent.ITEM_EDIT_END, false, true);
        // ITEM_EDIT events are cancelable
        advancedDataGridEvent.columnIndex = editedItemPosition.columnIndex;
        advancedDataGridEvent.dataField = _columns[editedItemPosition.columnIndex].dataField;
        advancedDataGridEvent.rowIndex = editedItemPosition.rowIndex;
        advancedDataGridEvent.itemRenderer = editedItemRenderer;
        advancedDataGridEvent.reason = reason;
        dispatchEvent(advancedDataGridEvent);
        // set a flag to not open another edit session if the item editor is still up
        // this means somebody wants the old edit session to stay.
        dontEdit = itemEditorInstance != null;
        // trace("dontEdit", dontEdit);

        if (!dontEdit && reason == AdvancedDataGridEventReason.CANCELLED)
        {
            losingFocus = true;
            setFocus();
        }

        inEndEdit = false;

        return !(advancedDataGridEvent.isDefaultPrevented())
    }

    /**
     *  @private
     */
    mx_internal function columnRendererChanged(c:AdvancedDataGridColumn):void
    {
        var item:IListItemRenderer;

        var factory:IFactory = columnItemRendererFactory(c,true,null);
        if (measuringObjects)
        {
            item = measuringObjects[factory];
            if (item)
            {
                item.parent.removeChild(DisplayObject(item));
                measuringObjects[factory] = null;
            }
            // TODO - set valid item to be passed
            factory = columnItemRendererFactory(c,false,null);
            item = measuringObjects[factory];
            if (item)
            {
                item.parent.removeChild(DisplayObject(item));
                measuringObjects[factory] = null;
            }
        }
        if(freeItemRenderersTable[c])
        {
            // remove item renderers
            var freeRenderers:Array = freeItemRenderersTable[c][c.itemRenderer] as Array;
            if (freeRenderers)
            {
                while (freeRenderers.length)
                {
                    item = freeRenderers.pop();
                    item.parent.removeChild(DisplayObject(item));
                }
            }
            // remove header renderers
            freeRenderers = freeItemRenderersTable[c][c.headerRenderer ? c.headerRenderer : headerRenderer] as Array;
            if (freeRenderers)
            {
                while (freeRenderers.length)
                {
                    item = freeRenderers.pop();
                    item.parent.removeChild(DisplayObject(item));
                }
            }
        }
        rendererChanged = true;
        invalidateDisplayList();
    }

    /**
     *  @private
     */
    protected function getPossibleDropPositions(val:AdvancedDataGridColumn):Array
    {
        var n:int = visibleColumns ? visibleColumns.length : 0;

        var dropPositions:Array = [];
        for ( var i:int = 0; i < n; i++)
        {
            dropPositions.push(getHeaderInfo(visibleColumns[i]));
        }
        return dropPositions;
    }

    /**
     *  @private
     */
    protected function hasHeaderItemsCreated(index:int=-1):Boolean
    {
        if(index == -1)
            return (headerItems && headerItems[0] && headerItems[0][0]);
        return (headerItems && headerItems[0] && headerItems[0][index]);
    }

    /**
     *  @private
     */
    protected function columnDraggingMouseMoveHandler(event:MouseEvent):void
    {
        if (!event.buttonDown)
        {
            columnDraggingMouseUpHandler(event);
            return;
        }
        var item:IListItemRenderer;
        var c:AdvancedDataGridColumn = movingColumn;
        var s:Sprite;
        var i:int = 0;
        var n:int;
        if (isNaN(startX))
        {
            // If startX is not a number, dragging has just started.
            // Initialise and return without actually moving anything.

            startX = event.stageX;

            // Set this to null so sort doesn't happen.
            lastItemDown = null;

            // Create and position proxy.
            // passing data as null, as it is used for header renderer
            var proxy:IListItemRenderer = columnItemRenderer(c, true, null);
            proxy.name = "headerDragProxy";

            var rowData:AdvancedDataGridListData = AdvancedDataGridListData(makeListData(c, null, 0, c.colNum, c));
            if (proxy is IDropInListItemRenderer)
                IDropInListItemRenderer(proxy).listData = rowData;

            listContent.addChild(DisplayObject(proxy));

            n = orderedHeadersList.length;
            for (i = 0; i < n; i++)
            {
                item = orderedHeadersList[i].headerItem;
                if (item && item.data == movingColumn)
                    break;
            }

            var h:Number = item.height + cachedPaddingBottom + cachedPaddingTop;
            var w:Number = item.getExplicitOrMeasuredWidth();
            var x:Number = item.x;

            //In case we have scrolled the "selection" shown need to be shifted
            if(orderedHeadersList[i].actualColNum >= lockedColumnCount)
            {
                x = getAdjustedXPos(item.x);
                // In case of column grouping, it may be partially visible, so need to get the visible width as well as the
                //x pos from which it is visible
                if(horizontalScrollPosition > 0 && orderedHeadersList[i].actualColNum - horizontalScrollPosition < lockedColumnCount)
                {
                    var lockedWidth:Number = 0;
                    if(lockedColumnCount > 0)
                    {
                        var lastLockedInfo:AdvancedDataGridHeaderInfo = getHeaderInfo(columns[lockedColumnCount-1]);
                        lockedWidth = lastLockedInfo.headerItem.x + columns[lockedColumnCount - 1].width;
                    }
                    else
                        lockedWidth = 0;
                    
                    w -= (lockedWidth - x);
                    x = lockedWidth;
                }
            }

            proxy.data = c;
            proxy.styleName = getStyle("headerDragProxyStyleName");
            UIComponentGlobals.layoutManager.validateClient(proxy, true);
            proxy.setActualSize(w, _explicitHeaderHeight ?
                                headerHeight : proxy.getExplicitOrMeasuredHeight());

            proxy.move(x, item.y);

            // Create, position and draw column overlay.
            s = new FlexSprite();
            s.name = "columnDragOverlay";
            s.alpha = 0.6;
            listContent.addChildAt(s, listContent.getChildIndex(selectionLayer));

            var vm:EdgeMetrics = viewMetrics;

            s.x = x;
            s.y = item.y - cachedPaddingTop;;

            if (w > 0)
            {
                var g:Graphics = s.graphics;
                g.beginFill(getStyle("disabledColor"));
                g.drawRect(0, 0, w,
                           unscaledHeight - vm.bottom - s.y);
                g.endFill();
            }

            s = Sprite(selectionLayer.getChildByName("headerSelection"));
            if (s)
                s.width = w;//movingColumn.width;

            if (!listContent.mask)
            {
                // Clip the contents so the header drag proxy doesn't show
                // outside the list.
                var bm:EdgeMetrics = borderMetrics;
                listContent.scrollRect = new Rectangle(0, 0,
                                                       unscaledWidth - bm.left - bm.right,
                                                       unscaledHeight - bm.top - bm.bottom);
            }

            return;
        }

        // Global coordinates.
        var deltaX:Number = event.stageX - startX;

        // If the mouse pointer over the right (layoutDirection=”ltr”) or 
        // left (layoutDirection=”rtl”) half of the column, the drop indicator 
        // should be shown before the next column.
        var deltaXInLocalCoordinates:Number = 
            (layoutDirection == LayoutDirection.LTR ? +deltaX : -deltaX);
        
        // Move header selection.
        s = Sprite(selectionLayer.getChildByName("headerSelection"));
        if (s)
            s.x += deltaXInLocalCoordinates;

        // Move header proxy.
        item = IListItemRenderer(listContent.getChildByName("headerDragProxy"));
        if (item)
            item.move(item.x + deltaXInLocalCoordinates, item.y);

        startX += deltaX;

        var pt:Point = new Point(event.stageX, event.stageY);
        pt = listContent.globalToLocal(pt);
        lastPt = pt;

        var headerSearchArray:Array = getPossibleDropPositions(movingColumn);
        n = headerSearchArray.length;
        var headerInfo:AdvancedDataGridHeaderInfo;
        var columnXPos:Number = headerSearchArray[0].headerItem.x;      
        
        var ww:Number = columnXPos;
        var notLocked:Boolean = false;

        dropIndexFound = false;

        for (var k:int = 0; k < n; ++k)
        {
            headerInfo = headerSearchArray[k];
            
            //Is the column getting checked is locked or not?
            if(headerInfo.actualColNum >= lockedColumnCount)
                notLocked = true;

            ww += headerInfo.column.width;

            //We are not interested in columns hidden in the left because of scrolling
            // interested in visibleColumns only
            if(notLocked && headerInfo.actualColNum + headerInfo.columnSpan - horizontalScrollPosition <= lockedColumnCount)
            {
                columnXPos = ww;
                continue;
            }

            if(notLocked)
                columnXPos = getAdjustedXPos(columnXPos);

            if (pt.x >= columnXPos && pt.x < columnXPos + headerInfo.column.width)
            {
                dropIndexFound = true;
                isHeaderDragOutside = false;

                // If the mouse pointer over the right (ltr) or left (rtl) half
                // of the column, the drop indicator should be shown before the next column.
                if (pt.x > (columnXPos + headerInfo.column.width/2) || 
                    //Column groups which are partially visible should 
                    //show drag indicator at the right end only
                    notLocked && headerInfo.actualColNum - horizontalScrollPosition < lockedColumnCount)
                {
                    columnXPos += headerInfo.column.width;
                    ++k;
                }

                if (dropColumnIndex != k)
                {
                    dropColumnIndex = k;

                    if (!columnDropIndicator)
                    {
                        var dropIndicatorClass:Class
                            = getStyle("columnDropIndicatorSkin");
                        if (!dropIndicatorClass)
                            dropIndicatorClass = DataGridColumnDropIndicator;
                        columnDropIndicator = IFlexDisplayObject(
                            new dropIndicatorClass());

                        if (columnDropIndicator is ISimpleStyleClient)
                            ISimpleStyleClient(columnDropIndicator).styleName = this;

                        listContent.addChild(
                            DisplayObject(columnDropIndicator));
                    }

                    listContent.setChildIndex(
                        DisplayObject(columnDropIndicator),
                        listContent.numChildren - 1);
                    columnDropIndicator.x = columnXPos - 2;
                    columnDropIndicator.y = item.y;

                    columnDropIndicator.setActualSize(3, listContent.height - item.y);
                }

                columnDropIndicator.visible = true;

                break;
            }
            columnXPos = ww;
        }

        // dispatch a headerDragOutside event if we have moved out
        // Need not dispatch if we are already out
        if(!dropIndexFound && isHeaderDragOutside == false)
        {
            isHeaderDragOutside = true;

            var advancedDataGridEvent:AdvancedDataGridEvent = new AdvancedDataGridEvent(
                AdvancedDataGridEvent.HEADER_DRAG_OUTSIDE,
                false, true);
            
            var movingColumnInfo:AdvancedDataGridHeaderInfo = getHeaderInfo(movingColumn);

            advancedDataGridEvent.column = movingColumn;
            advancedDataGridEvent.columnIndex = -1;
            advancedDataGridEvent.itemRenderer = movingColumnInfo.headerItem;
            advancedDataGridEvent.triggerEvent = event;

            dispatchEvent(advancedDataGridEvent);
        }
    }

    /**
     *  @private
     */
    protected function columnDraggingMouseUpHandler(event:Event):void
    {
        if (!movingColumn)
            return;
        var origIndex:int = movingColumn.colNum;

        if (dropColumnIndex >= 0)
        {
            if (dropColumnIndex >= visibleColumns.length)
            {
                dropColumnIndex = visibleColumns.length - 1;
            }
            else
            {
                if (origIndex < visibleColumns[dropColumnIndex].colNum)
                    dropColumnIndex--;
            }
            
            // dropColumnIndex is actually the index into the visibleColumns
            // array.  Get the corresponding index into the _columns array.
            dropColumnIndex = visibleColumns[dropColumnIndex].colNum;
        }
        
        // Shift columns.
        shiftColumns(origIndex, dropColumnIndex, event as MouseEvent);
        unsetColumnDragParameters();
    }
    
    /**
     *  @private
     */
    protected function unsetColumnDragParameters():void
    {
        var sbRoot:DisplayObject = systemManager.getSandboxRoot();
        sbRoot.removeEventListener(MouseEvent.MOUSE_MOVE, columnDraggingMouseMoveHandler, true);
        sbRoot.removeEventListener(MouseEvent.MOUSE_UP, columnDraggingMouseUpHandler, true);
        sbRoot.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, columnDraggingMouseUpHandler);
        systemManager.deployMouseShields(false);

        var proxy:IListItemRenderer =
            IListItemRenderer(listContent.getChildByName("headerDragProxy"));
        if (proxy)
            listContent.removeChild(DisplayObject(proxy));

        var s:Sprite = Sprite(selectionLayer.getChildByName("headerSelection"));
        if (s)
            selectionLayer.removeChild(s);

        if (columnDropIndicator)
            columnDropIndicator.visible = false;

        s = Sprite(listContent.getChildByName("columnDragOverlay"));
        if (s)
            listContent.removeChild(s);

        listContent.scrollRect = null;

        // Add the mask which was present before column dragging
        addClipMask(false);

        startX = NaN;
        movingColumn = null;
        dropColumnIndex = -1;
    }

    /**
     *  Checks if dragging is allowed for a particular column or not.
     *
     *  @param draggedColumn The column being dragged.
     *
     *  @return <code>true</code> if dragging is allowed for the column.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function isDraggingAllowed(draggedColumn:AdvancedDataGridColumn):Boolean
    {
        return draggedColumn.draggable;
    }

    /**
     *  Returns a SortInfo instance containing sorting information for the column.
     *
     *  @param column The column index.
     *
     *  @return A SortInfo instance.
     * 
     *  @see mx.controls.advancedDataGridClasses.SortInfo 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function getFieldSortInfo(column:AdvancedDataGridColumn):SortInfo
    {
        if (column && collection && collection.sort)
        {
            var colUID:String;
            //In case there is no dataField we will use the unique column uid to identify if the column is sorted
            if (!column.dataField)
                colUID = itemToUID(column);
                
            var n:int = collection.sort.fields.length;

            for (var i:int = 0; i < n; i++)
            {
                if (column.dataField && collection.sort.fields[i].name == column.dataField
                    || colUID &&  collection.sort.fields[i].name == colUID)
                {
                    // return 1-based, not 0-based sequence number
                    return new SortInfo(i + 1, collection.sort.fields[i].descending);
                }
            }
        }
        
        return null;
    }

    /**
     *  Checks if editing is allowed for a group or summary row.
     *
     *  @param data Data provider Object for the row.
     *
     *  @return <code>true</code> if editing is allowed for the group or summary row.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function isDataEditable(data:Object):Boolean
    {
        return true;
    }

    /**
     * @private
     *
     * Invalidate everything (properties, size, displaylist) for an IListItemRenderer if it is
     * IInvalidating.
    */
    protected function invalidateRenderer(renderer:IListItemRenderer):void
    {
        var i:IInvalidating = renderer as IInvalidating;
        if (i)
        {
            i.invalidateProperties();
            i.invalidateSize();
            i.invalidateDisplayList();
        }
    }

    /**
     * @private
     *
     * Reset the headers.
     */
    protected function invalidateHeaders():void
    {
        // Refresh the headers so that the separator line is removed or added
        var n:int = orderedHeadersList.length;
        for (var i:int = 0; i < n; i++)
        {
            invalidateRenderer(orderedHeadersList[i].headerItem);
        }
    }
    
    /**
     * @private
     * Given a row number, get the corresponding data in the dataProvider.
     */
    protected function rowNumberToData(rowNumber:int):Object
    {
        var iterator:IViewCursor = collection.createCursor();
        iterator.seek(CursorBookmark.FIRST, rowNumber);
        if (iterator.afterLast)
            return null;
        return iterator.current;
    }

    /**
     *  @private
     *  find the next item renderer down from the currently edited item renderer, and focus it.
     */
    private function findNextEnterItemRenderer(event:KeyboardEvent):void
    {
        // some other thing like a collection change has changed the
        // position, so bail and wait for commit to reset the editor.
        if (_proposedEditedItemPosition !== undefined)
            return;

        _editedItemPosition = lastEditedItemPosition;

        var rowIndex:int = _editedItemPosition.rowIndex;
        var columnIndex:int = _editedItemPosition.columnIndex;
        var newIndex:int = rowIndex;

        do
        {
            // modify direction with SHIFT (up or down)
            newIndex += (event.shiftKey ? -1 : 1);
            // only move if we're within range
            if (newIndex < collection.length && newIndex >= 0)
            {
                rowIndex = newIndex;
            }
            else
            {
                setEditedItemPosition(null);
                return;
            }

            var newData:Object = rowNumberToData(newIndex);
            if (newData == null)
            {
                setEditedItemPosition(null);
                return;
            }

            if (isDataEditable(newData))
                break;

        } while (true);

        // send event to create the new one
        var advancedDataGridEvent:AdvancedDataGridEvent =
            new AdvancedDataGridEvent(AdvancedDataGridEvent.ITEM_EDIT_BEGINNING, false, true);
        // ITEM_EDIT events are cancelable
        advancedDataGridEvent.columnIndex = columnIndex;
        advancedDataGridEvent.dataField = _columns[columnIndex].dataField;
        advancedDataGridEvent.rowIndex = rowIndex;
        dispatchEvent(advancedDataGridEvent);
    }

    /**
     *  Returns the column index corresponding to the field name of a sortable field.
     *
     *  @param name The name of a sortable field of the data provider, as defined by 
     *  an instance of the SortField class.
     *
     *  @return The column index of the sortable field. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function findSortField(name:String):int
    {
        if (collection && collection.sort)
        {
            var n:int = collection.sort.fields.length;
            for (var i:int = 0; i < n; i++)
            {
                if (collection.sort.fields[i]["name"] == name)
                    return i;
            }
            
        }

        return -1;
    }
    
    /**
     *  Adds a data field to the list of sort fields. 
     *  Indicate the data field by specifying its column location.
     *
     *  @param columnName The name of the column that corresponds to the data field.
     *
     *  @param columnNumber The column index in the AdvancedDataGrid control.
     *
     *  @param collection The data collection that contains the data field.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function addSortField(columnName:String,
                                    columnNumber:int,
                                    collection:ICollectionView):void
    {
        var column:AdvancedDataGridColumn = columns[columnNumber];

        if (!column.sortable)
            return;

         var headerInfo:AdvancedDataGridHeaderInfo = getHeaderInfo(column);
         if(headerInfo && headerInfo.internalLabelFunction != null && column.sortCompareFunction == null)
             return;

         var desc:Boolean = column.sortDescending;
         
         var singleColumnSort:Boolean = false;
         if (!collection.sort || !collection.sort.fields)
         {
             singleColumnSort = true;
             var sort:ISort = new Sort();
             sort.fields = [];
             
             collection.sort = sort;
        }
        else if (collection.sort.fields.length == 0)
        {
            singleColumnSort = true;
        }

        if (singleColumnSort)
        {
            lastSortIndex = sortIndex;
            sortIndex     = columnNumber;
            sortColumn    = column;
            
            var dir:String = (desc) ? "DESC" : "ASC";
            sortDirection = dir;
        }
        else
        {
            lastSortIndex = -1;
            sortIndex = -1;
            sortColumn = null;
            sortDirection = null;
        }

        column.sortDescending = desc;
        var field:ISortField = new SortField(columnName); // name
        field.descending = desc;
        
//        field.name = column.dataField;
        if (column.sortCompareFunction != null)
            field.compareFunction = column.sortCompareFunction;
        collection.sort.fields.push(field);
    }

    /**
     *  Removes a data field from the list of sort fields. 
     *  Indicate the data field by specifying its column location.
     *
     *  @param columnName The name of the column that corresponds to the data field.
     *
     *  @param columnNumber The column index in the AdvancedDataGrid control.
     *
     *  @param collection The data collection that contains the data field.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function removeSortField(columnName:String,
                                    columnNumber:int,
                                    collection:ICollectionView):void
    {
        var column:AdvancedDataGridColumn = columns[columnNumber];

        if (!collection || !collection.sort || !collection.sort.fields
                || !collection.sort.fields.length)
            return;

        var columnNumberToRemove:int = -1;
        var n:int = collection.sort.fields.length;

        for (var i:int = 0; i < n; i++)
        {
            if (collection.sort.fields[i].name == column.dataField)
            {
                columnNumberToRemove = i;
                break;
            }
        }

        if (columnNumberToRemove != -1)
            collection.sort.fields.splice(columnNumberToRemove, 1);
    }

    /**
     *  Flip the order from ascending <-> descending for the given column name
     *  in the sort fields list
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    private function flipSortOrder(columnName:String, columnNumber:int, collection:ICollectionView):String
    {
        if (collection.sort)
        {
            var column:AdvancedDataGridColumn = columns[columnNumber];
            
            collection.sort.fields[findSortField(columnName)]["descending"]
                = ! collection.sort.fields[findSortField(columnName)]["descending"];

            if (collection.sort.fields[findSortField(columnName)]["descending"])
            {
                column.sortDescending = true;
                return "DESC";
            }
            else
            {
                column.sortDescending = false;
                return "ASC";
            }
        }

        return null;
    }
    
    /**
     *  A helper method to determine which item renderer is under the mouse.
     *  
     *  @private
     */    
    private function findRenderer(pt:Point,items:Array,info:Array,yy:Number = 0):IListItemRenderer
    {
        var r:IListItemRenderer;
        var ww:Number = 0;
        var m:int = 0;
        var n:int = items.length;
        var optimumColumns:Array = getOptimumColumns();
        for (var i:int = 0; i < n; i++)
        {
            if (items[i].length)
            {
                if (pt.y < yy + info[i].height)
                {
                    m = items[i].length;
                    if (m == 1)
                    {
                        r = items[i][0];
                        break;
                    }

                    ww = 0;
                    for (var j:int = 0; j < m; j++)
                    {
                        ww += optimumColumns[j].width;
                        if (pt.x < ww)
                        {
                            r = items[i][j];
                            break;
                        }

                    }
                    if (r)
                        break;
                }
            }
            yy += info[i].height;
        }

        return r;
    }

    /**
     *  A helper method to determine which item renderer is under the mouse.
     *  
     *  @private
     */    
    private function findHeaderRenderer(pt:Point):IListItemRenderer
    {
        var r:IListItemRenderer;
        var yy:Number = 0;
        var ww:Number = 0;
        var m:int = 0;
        var n:int = headerItems.length;
        var optimumColumns:Array = getOptimumColumns();
        for (var i:int = 0; i < n; i++)
        {
            if (headerItems[i].length)
            {
                if (pt.y < yy + headerRowInfo[i].height)
                {
                    m = headerItems[i].length;
                    if (m == 1)
                    {
                        r = headerItems[i][0];
                        break;
                    }

                    ww = 0;
                    for (var j:int = 0; j < lockedColumnCount; j++)
                    {
                        ww += optimumColumns[j].width;
                        if (pt.x < ww)
                        {
                            r = headerItems[i][j];
                            break;
                        }

                    }
                    if (r)
                        break;

                    for (j=lockedColumnCount + horizontalScrollPosition; j < m; j++)
                    {
                        ww += optimumColumns[j].width;
                        if (pt.x < ww)
                        {
                            r = headerItems[i][j];
                            break;
                        }

                    }

                }
            }
            yy += headerRowInfo[i].height;
        }

        return r;
    }
    
    /**
     *  @private
     */
    mx_internal function getSeparators():Array
    {
        return separators;
    }

    /**
     *  @private
     */
    mx_internal function getLockedSeparators():Array
    {
        return lockedSeparators;
    }
    
    /**
     *  @private
     */
    private function measureItems():void
    {
        if (itemsNeedMeasurement)
        {
            itemsNeedMeasurement = false;
            if (isNaN(explicitRowHeight))
            {
                if (iterator && columns.length > 0)
                {
                    if (!measuringObjects)
                        measuringObjects = new Dictionary(false);

                    //set AdvancedDataGridBase.visibleColumns to the set of 
                    //all columns
                    visibleColumns = columns;
                    columnsInvalid = true;

                    var paddingTop:Number = getStyle("paddingTop");
                    var paddingBottom:Number = getStyle("paddingBottom");

                    var data:Object = iterator.current;
                    var item:IListItemRenderer;
                    var c:AdvancedDataGridColumn;
                    var ch:Number = 0;
                    var n:int = columns.length;
                    for (var i:int = 0; i < n; i++)
                    {
                        c = columns[i];

                        if (!c.visible)
                            continue;

                        item = getMeasuringRenderer(c, false,data);
                        setupRendererFromData(c, item, data);
                        ch = Math.max(ch, item.getExplicitOrMeasuredHeight() + paddingBottom + paddingTop);
                    }

                    // unless specified otherwise, rowheight defaults to 20
                    setRowHeight(Math.max(ch, 20));
                }
                else
                    setRowHeight(20);
            }
        }
    }

    /**
     *  @private
     *  Set the itemEditor instance position according to the indentation of the item it is representing.
     */
    protected function layoutItemEditor():void
    {
    }

    /**
     *  Moves focus to the specified column header. 
     *
     *  @param columnIndex The index of the column to receive focus. 
     *  If you specify an invalid column index, the method returns without moving focus.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function moveFocusToHeader(columnIndex:int = -1):void
    {
        if (!headerVisible || headerIndex != -1)
            return;

        if (visibleColumns.length > 0)
        {
            if (columnIndex == -1)
                columnIndex = visibleColumns[0].colNum;

            selectedHeaderInfo = getHeaderInfo(columns[columnIndex]);
            headerIndex = columnIndex;
            selectColumnHeader(headerIndex);
        }
    }

    /**
     *  Selects the specified column header.
     *
     *  @param columnNumber The index of the column to receive focus. 
     *  If you specify an invalid column index, the method returns without moving focus.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function selectColumnHeader(columnNumber:int):void
    {
        var visibleColumnNumber:int = -1;
        var n:int = visibleColumns.length;
        for (var i:int = 0; i < n; i++)
        {
            if (visibleColumns[i].colNum == columnNumber)
            {
                visibleColumnNumber = i;
                break;
            }
        }

        // For example, if a column header is selected but we have horizontally
        // scrolled such that it is not visible, then we select the first visible header item
        if (visibleColumnNumber == -1)
        {
            visibleColumnNumber = 0;
            headerIndex = visibleColumns[0].colNum;
        }

        var s:Sprite = Sprite( selectionLayer.getChildByName("headerKeyboardSelection") );
        // Copied from function mouseOverHandler
        if (! s)
        {
            s = new FlexSprite();
            s.name = "headerKeyboardSelection";
            selectionLayer.addChild(s);
        }

        var r:IListItemRenderer = selectedHeaderInfo.headerItem;        
        if (r)
        {
            var g:Graphics = s.graphics;
            g.clear();
            g.beginFill( (isPressed || isKeyPressed) ? getStyle("selectionColor") : getStyle("rollOverColor") );
            g.drawRect(0, 0, visibleColumns[visibleColumnNumber].width, r.height+cachedPaddingTop+cachedPaddingBottom - 0.5);
            g.endFill();
    
            s.x = getAdjustedXPos(r.x);
            s.y = r.y - cachedPaddingTop;           
    
            // Make sure other selection is removed
            caretIndex = -1;
            isPressed = false;
            selectItem(selectedHeaderInfo.headerItem, false, false);
        }
    }

    /**
     *  Deselects the specified column header.
     *
     *  @param columnNumber The index of the column. 
     *  If you specify an invalid column index, the method does nothing.
     *
     *  @param completely If <code>true</code>, clear the <code>caretIndex</code> property
     *  and selects the first column header in the control. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function unselectColumnHeader(columnNumber:int, completely:Boolean=false):void
    {
        var s:Sprite = Sprite( selectionLayer.getChildByName("headerKeyboardSelection") );
        if (s)
            selectionLayer.removeChild(s);
        selectedHeaderInfo = null;
        if (completely)
        {
            caretIndex = 0;
            isPressed = false;
            selectItem(listItems[caretIndex][0], false, false);
        }
    }

    /**
     *  Helper function to figure out if the item renderer is renderering a
     *  header.
     *
     *  @private
     */
    protected function isHeaderItemRenderer(item:IListItemRenderer):Boolean
    {
        // data is set to AdvancedDataGridColumn for header items
        if (item != null && item.data is AdvancedDataGridColumn)
            return true;

        return false;
    }

    /**
     *  Converts an absolute column index to the corresponding index in the
     *  displayed columns. Because users can reorder columns, the 
     *  absolute column index may be different from the index of the
     *  displayed column.
     *
     *  @param columnIndex Absolute index of the column.
     *
     *  @return The index of the column as it is currently displayed, 
     *  or -1 if <code>columnIndex</code> is not found.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function absoluteToDisplayColumnIndex(columnIndex:int):int
    {
        var n:int = displayableColumns.length;
        for (var i:int = 0; i < n; i++)
        {
            if (displayableColumns[i].colNum == columnIndex)
                return i;
        }

        return -1;
    }

    /**
     *  Converts the current display column index of a column to 
     *  its corresponding absolute index. 
     *  Because users can reorder columns, the 
     *  absolute column index may be different from the index of the
     *  displayed column.
     *
     *  @param columnIndex Index of the column as it is currently displayed by the control.
     *
     *  @return The absolute index of the column.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function displayToAbsoluteColumnIndex(columnIndex:int):int
    {
        return displayableColumns[columnIndex].colNum;
    }

    /**
     *  Converts an absolute column index to the corresponding index in the
     *  visible columns. Because users can reorder columns, the 
     *  absolute column index may be different from the index of the
     *  visible column.
     *
     *  @param columnIndex Absolute index of the column.
     *
     *  @return The index of the column as it is currently visible, 
     *  or -1 if <code>columnIndex</code> is not currently visible.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function absoluteToVisibleColumnIndex(columnIndex:int):int
    {
        var optimumColumns:Array = getOptimumColumns();
        var n:int = optimumColumns.length;
        for (var i:int = 0; i < n; i++)
        {
            if (optimumColumns[i].colNum == columnIndex)
                return i;
        }
        return -1;
    }

    /**
     *  Converts the current visible column index of a column to 
     *  its corresponding absolute index. 
     *  Because users can reorder columns, the 
     *  absolute column index may be different from the index of the
     *  visible column.
     *
     *  @param columnIndex Index of a currently visible column in the control.
     *
     *  @return The absolute index of the column.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function visibleToAbsoluteColumnIndex(columnIndex:int):int
    {
        var optimumColumns:Array = getOptimumColumns();
        return optimumColumns[columnIndex].colNum;
    }

    /**
     *  Returns <code>true</code> if the specified row in a column is visible.
     *
     *  @param columnIndex The column index. 
     *
     *  @param rowIndex A row index in the column. If omitted, the method uses the 
     *  current value of the <code>verticalScrollPosition</code> property.
     *
     *  @return <code>true</code> if the specified row in the column is visible.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function isColumnFullyVisible(columnIndex:int, rowIndex:int = -1):Boolean
    {
        if (rowIndex == -1)
            rowIndex = verticalScrollPosition;

        var visibleCoords:Object = absoluteToVisibleIndices(rowIndex, columnIndex);
        var visibleRowIndex:int = visibleCoords.rowIndex;
        var visibleColIndex:int = visibleCoords.columnIndex;

        if (visibleRowIndex < 0)
            return false;

        // First, check for presence in visibleColumns
        var isFullyVisible:Boolean = (visibleColIndex != -1);

        if (isFullyVisible)
        {
            if (listItems.length >= 1 && visibleColumns.length >= 1)
            {
                var adjustedX:Number = listItems[visibleRowIndex][visibleColIndex].x;
                if(getOptimumColumns() == displayableColumns && visibleColIndex > lockedColumnCount)
                    adjustedX = getAdjustedXPos(adjustedX);

                // Second, check if it is fully visible
                // (a valid check if it is the last column)
                if (adjustedX + listItems[visibleRowIndex][visibleColIndex].width
                    > listContent.width)
                    isFullyVisible = false;
            }
        }

        return isFullyVisible;
    }

    /**
     *  Figure out which visible column is available at an offset from the
     *  current visible column.
     *
     *  Use with care, because it scrolls the new column into view.
     *
     *  @private
     */
    protected function viewDisplayableColumnAtOffset(columnIndex:int,
                                                     offset:int,
                                                     rowIndex:int=-1,
                                                     scroll:Boolean=true)
                                                     :int
    {
        var displayColumnIndex:int = absoluteToDisplayColumnIndex(columnIndex);
        if (displayColumnIndex == -1)
            return -1;

        var n:int = displayableColumns.length;

        for (var newDisplayColumnIndex:int = displayColumnIndex + offset;
             newDisplayColumnIndex >= 0 && newDisplayColumnIndex <= n-1;
             newDisplayColumnIndex += offset)
        {
            if (rowIndex > -1)
            {
                // If rowIndex is given and item renderer is present,
                // then it must be visible
                var visibleCoord:Object
                    = absoluteToVisibleIndices(rowIndex,
                                    displayToAbsoluteColumnIndex(newDisplayColumnIndex));
                var listItem:IListItemRenderer;
                if (listItems[visibleCoord.rowIndex])
                    listItem = listItems[visibleCoord.rowIndex][visibleCoord.columnIndex];
                if (listItem && !listItem.visible)
                    continue;
            }

            var newAbsoluteColumnIndex:int = displayToAbsoluteColumnIndex(newDisplayColumnIndex);
            if (newAbsoluteColumnIndex < 0 || newAbsoluteColumnIndex > columns.length-1)
                return -1;

            if (scroll)
            {
                if (!isColumnFullyVisible(newAbsoluteColumnIndex))
                    scrollToViewColumn(newAbsoluteColumnIndex, columnIndex);
            }

            return newAbsoluteColumnIndex;
        }

        return -1;
    }

    /**
     *  Changes the value of the <code>horizontalScrollPosition</code> property 
     *  to make the specified column visible.
     *  This method is useful when all columns of the control are not currently visible.
     *
     *  @param newColumnIndex The desired index of the column in the currently displayed columns.
     *
     *  @param columnIndex The index of the column to display.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function scrollToViewColumn(newColumnIndex:int, columnIndex:int):void
    {
        var i:int, n:int;
        if (newColumnIndex == columnIndex)
            return;

        var newDisplayColumnIndex:int = absoluteToDisplayColumnIndex(newColumnIndex);
        var displayColumnIndex:int    = absoluteToDisplayColumnIndex(columnIndex);

        var delta:int = newDisplayColumnIndex - displayColumnIndex;
        var newHorizontalScrollPosition:int = Math.max(0,horizontalScrollPosition + delta);

        // If moving from locked column area to unlocked column area, then
        // change horizontal scroll position to zero so that we can bring the
        // first unlocked column to view.
        if (lockedColumnCount > 0 && columnIndex == lockedColumnCount-1)
            newHorizontalScrollPosition = 0;

        var scrollEvent:ScrollEvent = new ScrollEvent(ScrollEvent.SCROLL);
        scrollEvent.detail          = ScrollEventDetail.THUMB_POSITION;
        scrollEvent.direction       = ScrollEventDirection.HORIZONTAL;
        scrollEvent.delta           = delta;
        scrollEvent.position        = newHorizontalScrollPosition;
        dispatchEvent(scrollEvent);

        horizontalScrollPosition    = newHorizontalScrollPosition;
    }

    /**
     *  Convert an absolute row index and column index into the corresponding 
     *  row index and column index of the item as it is currently displayed by the control.
     *
     *  @param rowIndex An absolute row index.
     *
     *  @param columnIndex An absolute column index.
     *
     *  @return An Object containing two fields, <code>rowIndex</code> and <code>columnIndex</code>, 
     *  that contain the row index and column index of the item as it is currently displayed by the control.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function absoluteToVisibleIndices(rowIndex:int, columnIndex:int):Object
    {
        var visibleRowIndex:int = -1;
        var visibleColIndex:int = -1;

        // Check row display
        if ( (rowIndex < lockedRowCount || rowIndex >= verticalScrollPosition)
                && rowIndex <= verticalScrollPosition
                    + (listItems.length ? listItems.length - 1 : 0))
        {
            if (rowIndex >= lockedRowCount && rowIndex >= verticalScrollPosition)
                visibleRowIndex = rowIndex - verticalScrollPosition;
            else
                visibleRowIndex = rowIndex;
        }

        // Check column display (optimization: calculate only if row is valid)
        if (visibleRowIndex > -1)
        {
            var columnsOnScreen:Array = visibleColumns;
            if (columnsOnScreen && columnsOnScreen.length > 0)
            {
                if (columnIndex >= columnsOnScreen[0].colNum
                        && columnIndex <= columnsOnScreen[columnsOnScreen.length-1].colNum)
                {
                    if (columnIndex >= lockedColumnCount)
                        visibleColIndex = absoluteToVisibleColumnIndex(columnIndex);
                    else
                        visibleColIndex = columnIndex;
                }
            }
        }

        return  {
                    rowIndex : visibleRowIndex,
                    columnIndex : visibleColIndex
                };
    }

    /**
     *  Returns the index of a column as it is currently displayed.
     *  This method is useful when all columns of the control are not currently visible.
     *
     *  @param colNum Absolute index of the column.
     *
     *  @return The index of the column as it is currently displayed, 
     *  or -1 if <code>colNum</code> is not found.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function colNumToIndex(colNum:int):int
    {
        if (getOptimumColumns() == visibleColumns)
            return absoluteToVisibleColumnIndex(colNum);
        else if (getOptimumColumns() == displayableColumns)
            return absoluteToDisplayColumnIndex(colNum);
        else
            return -1;
    }

    /**
     *  Returns the column number of a currently displayed column 
     *  as it is currently displayed. 
     *  This method is useful when all columns of the control are not currently visible.
     *
     *  @param columnIndex The index of the column as it is currently displayed.
     *
     *  @return The column number of the displayed column in the control, 
     *  or -1 if <code>columnIndex</code> is not found.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function indexToColNum(columnIndex:int):int
    {
        if (getOptimumColumns() == visibleColumns)
            return visibleToAbsoluteColumnIndex(columnIndex);
        else if (getOptimumColumns() == displayableColumns)
            return displayToAbsoluteColumnIndex(columnIndex);
        else
            return -1;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Catches any events from the model. Optimized for editing one item.
     *  Creates columns when there are none. Inherited from list.
     *  @param eventObj
     */
    override protected function collectionChangeHandler(event:Event):void
    {
        //if the iterator is null that indicates we havent been validated yet so we'll bail. 
        if (iterator == null)
            return;

        if (event is CollectionEvent)
        {
            var ceEvent:CollectionEvent = CollectionEvent(event)
            if (ceEvent.kind == CollectionEventKind.mx_internal::EXPAND)
            {
                //we ignore expand in list/tree
                event.stopPropagation();
            }
            if (ceEvent.kind == CollectionEventKind.UPDATE)
            {
                //this prevents listbase from invalidating the displaylist too early. 
                event.stopPropagation();
                //we only want to update the displaylist if an updated item was visible
                //but dont have a sufficient test for that yet
                itemsSizeChanged = true;
                invalidateDisplayList();
            }

            if (ceEvent.kind == CollectionEventKind.RESET)
            {
                if (generatedColumns)
                    generateCols();
                updateSortIndexAndDirection();
            }
            else if (ceEvent.kind == CollectionEventKind.REFRESH && !manualSort)
            {
                updateSortIndexAndDirection();
            }
            else
            {
                // if we get a remove while editing adjust the editPosition
                if (ceEvent.kind == CollectionEventKind.REMOVE)
                {
                    if (editedItemPosition)
                    {
                        if (collection.length == 0)
                        {
                            if (itemEditorInstance)
                                endEdit(AdvancedDataGridEventReason.CANCELLED);
                            setEditedItemPosition(null); // nothing left to edit
                        }
                        else if (ceEvent.location <= editedItemPosition.rowIndex)
                        {
                            var curEditedItemPosition:Object = editedItemPosition;

                            // if the editor is up on the item going away, cancel the session
                            if (ceEvent.location == editedItemPosition.rowIndex && itemEditorInstance)
                                endEdit(AdvancedDataGridEventReason.CANCELLED);

                            if (inEndEdit)
                                _editedItemPosition = { columnIndex : editedItemPosition.columnIndex, 
                                                        rowIndex : Math.max(0, editedItemPosition.rowIndex - ceEvent.items.length)};
                            else
                                setEditedItemPosition({ columnIndex : curEditedItemPosition.columnIndex, 
                                                            rowIndex : Math.max(0, curEditedItemPosition.rowIndex - ceEvent.items.length)});
                        }
                    }
                }
                else if (ceEvent.kind == CollectionEventKind.REPLACE)
                {
                    if (editedItemPosition)
                    {
                        // if the editor is up on the item going away, cancel the session
                        if (ceEvent.location == editedItemPosition.rowIndex && itemEditorInstance)
                            endEdit(AdvancedDataGridEventReason.CANCELLED);
                    }
                }
            }
        }

        super.collectionChangeHandler(event);

        if (event is CollectionEvent)
        {
            // trace("ListBase collectionEvent");
            var ce:CollectionEvent = CollectionEvent(event);
            if (ce.kind == CollectionEventKind.ADD)
            {
                // added first item, generate columns for it if needed
                if (collection.length == 1)
                    if (generatedColumns)
                        generateCols();
            }
        }

//      if (event.eventName != "sort" && bRowsChanged)
//          invInitHeaders = true;
    }

    /**
     *  @private
     */
    override protected function mouseOverHandler(event:MouseEvent):void
    {
        if (movingColumn)
            return;

        if (!enabled || !selectable)
            return;

        var r:IListItemRenderer;
        var n:int;
        if (enabled && headerVisible && getNumColumns() //headerItems.length
            && !isPressed)
        {
            r = mouseEventToItemRenderer(event);
            n = orderedHeadersList.length;

            var headerItem:IListItemRenderer;
            var headerInfo:AdvancedDataGridHeaderInfo;
            var i:int;
            for( i = 0; i < n && r; i++)
            {
                headerItem = orderedHeadersList[i].headerItem;
                if(headerItem == r)
                {
                    headerInfo = orderedHeadersList[i];
                    if(orderedHeadersList[i].column.sortable)
                    {
                        var s:Sprite = Sprite(
                            selectionLayer.getChildByName("headerSelection"));
                        if (!s)
                        {
                            s = new FlexSprite();
                            s.name = "headerSelection";
                            selectionLayer.addChild(s);
                        }

                        var h:Number = r.height + cachedPaddingBottom + cachedPaddingTop;
                        var w:Number = r.getExplicitOrMeasuredWidth();
                        var x:Number = r.x;
                        
                        //In case we have scrolled the "selection" shown need to be shifted
                        if(headerInfo.actualColNum >= lockedColumnCount)
                        {
                            x = getAdjustedXPos(r.x);
                            // In case of column grouping, it may be partially visible, so need to get the visible width as well as the
                            //x pos from which it is visible
                            if(horizontalScrollPosition > 0 && headerInfo.actualColNum - horizontalScrollPosition < lockedColumnCount)
                            {
                                var lockedWidth:Number = 0;
                                if(lockedColumnCount > 0)
                                {
                                    var lastLockedInfo:AdvancedDataGridHeaderInfo = getHeaderInfo(columns[lockedColumnCount-1]);
                                    lockedWidth = lastLockedInfo.headerItem.x + columns[lockedColumnCount - 1].width;
                                }
                                else
                                    lockedWidth = 0;

                                w -= (lockedWidth - x);
                                x = lockedWidth;
                            }
                        }
                        
                        var g:Graphics = s.graphics;
                        g.clear();
                        g.beginFill(getStyle("rollOverColor"));
                        g.drawRect(0, 0, w, h - 0.5);
                        g.endFill();

                        s.x = x;
                        s.y = r.y - cachedPaddingTop;
                    }
                    return;
                }
            }

        }

        if (event.buttonDown)
            lastItemDown = r;
        else
            lastItemDown = null;

        super.mouseOverHandler(event);
    }

    /**
     *  @private
     */
    override protected function mouseOutHandler(event:MouseEvent):void
    {
        if (movingColumn)
            return;

        var r:IListItemRenderer;
        var optimumColumns:Array = getOptimumColumns();
        var n:int;
        if (enabled && headerVisible && listItems.length)
        {
            r = mouseEventToItemRenderer(event);

            if(!r)
            {
                n = optimumColumns.length;
                for (var i:int = 0; i < n; i++)
                {
                    if(optimumColumns[i].colNum == sortIndex)
                        r = getHeaderInfo(optimumColumns[i]).headerItem;
                }
            }

            n = orderedHeadersList.length;
            var headerItem:IListItemRenderer;
            for( i = 0; i < n && r; i++)
            {
                headerItem = orderedHeadersList[i].headerItem;
                if(headerItem == r)
                {
                    if(orderedHeadersList[i].column.sortable)
                    {
                        var s:Sprite = Sprite(
                            selectionLayer.getChildByName("headerSelection"));
                        if (s)
                            selectionLayer.removeChild(s);
                    }
                    return;
                }
            }
        }
        if (event.buttonDown)
            lastItemDown = r;
        else
            lastItemDown = null;

        super.mouseOutHandler(event);
    }

    /**
     *  @private
     */
    override protected function mouseDownHandler(event:MouseEvent):void
    {
        // trace(">>mouseDownHandler");
        var r:IListItemRenderer;
        var s:Sprite;
        r = mouseEventToItemRenderer(event);

        var optimumColumns:Array = getOptimumColumns();
        // if headers are visible and clickable for sorting
        if (enabled && (sortableColumns || draggableColumns)
            && headerVisible && hasHeaderItemsCreated())
        {
            // find out if we clicked on a header
            var n:int = orderedHeadersList.length;
            var headerItem:IListItemRenderer;
            for( var i:int = 0; i < n && r; i++)
            {
                headerItem = orderedHeadersList[i].headerItem;
                // if we did click on a header
                if(headerItem == r)
                {
                    var headerInfo:AdvancedDataGridHeaderInfo = orderedHeadersList[i];
                    // dispose the editor
                    if (itemEditorInstance)
                        endEdit(AdvancedDataGridEventReason.OTHER);
                    var c:AdvancedDataGridColumn = orderedHeadersList[i].column;

                    if (sortableColumns && c.sortable)
                    {
                        lastItemDown = r;
                        s = Sprite(selectionLayer.getChildByName("headerSelection"));
                        if (!s)
                        {
                            s = new FlexSprite();
                            s.name = "headerSelection";
                            selectionLayer.addChild(s);
                        }

                        var h:Number = r.height + cachedPaddingBottom + cachedPaddingTop;
                        var w:Number = r.getExplicitOrMeasuredWidth();
                        var x:Number = r.x;

                        //In case we have scrolled the "selection" shown need to be shifted
                        if(headerInfo.actualColNum >= lockedColumnCount)
                        {
                            x = getAdjustedXPos(r.x);
                            // In case of column grouping, it may be partially visible, so need to get the visible width as well as the
                            //x pos from which it is visible
                            if(horizontalScrollPosition > 0 && headerInfo.actualColNum - horizontalScrollPosition < lockedColumnCount)
                            {
                                var lockedWidth:Number = 0;
                                if(lockedColumnCount > 0)
                                {
                                    var lastLockedInfo:AdvancedDataGridHeaderInfo = getHeaderInfo(columns[lockedColumnCount-1]);
                                    lockedWidth = lastLockedInfo.headerItem.x + columns[lockedColumnCount - 1].width;
                                }
                                else
                                {
                                    lockedWidth = 0;
                                }

                                w -= (lockedWidth - x);
                                x = lockedWidth;
                            }
                        }

                        var g:Graphics = s.graphics;
                        g.clear();
                        g.beginFill(getStyle("selectionColor"));
                        g.drawRect(0, 0, w, h - 0.5);
                        g.endFill();

                        s.x = x;
                        s.y = r.y - cachedPaddingTop;
                    }
                    isPressed = true;
                    // begin column dragging
                    if (draggableColumns && isDraggingAllowed(c))
                    {
                        startX = NaN;
                        var sbRoot:DisplayObject = systemManager.getSandboxRoot();
                        sbRoot.addEventListener(MouseEvent.MOUSE_MOVE, columnDraggingMouseMoveHandler, true);
                        sbRoot.addEventListener(MouseEvent.MOUSE_UP, columnDraggingMouseUpHandler, true);
                        sbRoot.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, columnDraggingMouseUpHandler);
                        systemManager.deployMouseShields(true);
                        movingColumn = c;
                    }

                    return;
                }
            }
        }
        lastItemDown = null;

        var isItemEditor:Boolean = itemRendererContains(itemEditorInstance, DisplayObject(event.target));

        // If it isn't an item renderer, or an item editor do default behavior
        if (!isItemEditor)
        {
            var pos:Point;
            if (r && r.data)
            {
                lastItemDown = r;

                pos = itemRendererToIndices(r);

                var bEndedEdit:Boolean = true;

                if (itemEditorInstance)
                {
                    //for header renderers pos would be null
                    if (pos == null || displayableColumns[pos.x].editable == false)
                        bEndedEdit = endEdit(AdvancedDataGridEventReason.OTHER);
                    else
                        bEndedEdit = endEdit(editedItemPosition.rowIndex == pos.y ?
                                             AdvancedDataGridEventReason.NEW_COLUMN :
                                             AdvancedDataGridEventReason.NEW_ROW);
                }

                // if we didn't end edit session, don't do default behavior (call super)
                if (!bEndedEdit)
                    return;
            }
            else
            {
                // trace("end edit?");
                if (itemEditorInstance)
                    endEdit(AdvancedDataGridEventReason.OTHER);
            }

            // Move focus out of header if mouse pressed on any list item
            if (headerIndex != -1)
            {
                var pt:Point = itemRendererToIndices(r);
                if (pt)
                {
                    unselectColumnHeader(headerIndex, true);
                    headerIndex = -1;
                    caretIndex = pt.y;
                }
            }

            super.mouseDownHandler(event);
            
            if (r)
            {
                if (pos && displayableColumns[pos.x].rendererIsEditor)
                    resetDragScrolling();
            }
        }
        else
            resetDragScrolling();
        // trace("<<mouseDownHandler");
    }

    /**
     *  @private
     */
    override protected function mouseUpHandler(event:MouseEvent):void
    {
        if (!collection || !collection.length)
            return;

        var advancedDataGridEvent:AdvancedDataGridEvent;
        var r:IListItemRenderer;
        var s:Sprite;
        var n:int;
        var i:int;
        var pos:Point;

        r = mouseEventToItemRenderer(event);

        if (enabled && (sortableColumns || draggableColumns)
            && collection && headerVisible && hasHeaderItemsCreated())
        {
            n = orderedHeadersList.length;
            for (i = 0; i < n; i++)
            {
                if (r == orderedHeadersList[i].headerItem && r)
                {
                    var c:AdvancedDataGridColumn = orderedHeadersList[i].column;
                    if (sortableColumns && c.sortable && lastItemDown == r)
                    {
                        lastItemDown = null;
                        advancedDataGridEvent= new AdvancedDataGridEvent(
                            AdvancedDataGridEvent.HEADER_RELEASE,
                            false, true);
                        // HEADER_RELEASE event is cancelable
                        if(c.colNum == -1 || isNaN(c.colNum))
                            advancedDataGridEvent.columnIndex = -1;
                        else
                            advancedDataGridEvent.columnIndex = c.colNum;
                        advancedDataGridEvent.dataField = c.dataField;
                        advancedDataGridEvent.itemRenderer = r;
                        advancedDataGridEvent.triggerEvent = event;
                        if (Object(r).hasOwnProperty("mouseEventToHeaderPart"))
                            advancedDataGridEvent.headerPart = Object(r).mouseEventToHeaderPart(event);
                        dispatchEvent(advancedDataGridEvent);
                    }
                    isPressed = false;
                    return;
                }
            }
        }

        if (movingColumn)
            return;

        super.mouseUpHandler(event);

        // if the item is visible, then only create item editor for it
        if (r && r.data && r != itemEditorInstance && lastItemDown == r && r.visible
                && isDataEditable(r.data))
        {
            pos = itemRendererToIndices(r);

            if (pos && pos.y >= 0 && !dontEdit)
            {
				if (displayableColumns[pos.x].editable)
				{
	                advancedDataGridEvent = new AdvancedDataGridEvent(AdvancedDataGridEvent.ITEM_EDIT_BEGINNING, false, true);
	                // ITEM_EDIT events are cancelable
	                advancedDataGridEvent.columnIndex = displayableColumns[pos.x].colNum;
	                advancedDataGridEvent.dataField = displayableColumns[pos.x].dataField;
	                advancedDataGridEvent.rowIndex = pos.y;
	                advancedDataGridEvent.itemRenderer = r;
	                dispatchEvent(advancedDataGridEvent);
				}
				else
				{
					// if the item is not editable, set lastPosition to it anyways
					// so future tabbing starts from there
					lastEditedItemPosition = { columnIndex: displayableColumns[pos.x].colNum, rowIndex: pos.y };
				}
            }
        }
        else if (lastItemDown && lastItemDown != itemEditorInstance)
        {
            pos = itemRendererToIndices(lastItemDown);

            if (pos && pos.y >= 0 && editable && !dontEdit)
            {
                if (displayableColumns[pos.x].editable)
                {
                    advancedDataGridEvent = new AdvancedDataGridEvent(AdvancedDataGridEvent.ITEM_EDIT_BEGINNING, false, true);
                    // ITEM_EDIT events are cancelable
                    advancedDataGridEvent.columnIndex = displayableColumns[pos.x].colNum;
                    advancedDataGridEvent.dataField = displayableColumns[pos.x].dataField;
                    advancedDataGridEvent.rowIndex = pos.y;
                    advancedDataGridEvent.itemRenderer = lastItemDown;
                    dispatchEvent(advancedDataGridEvent);
                }
                else
                {
                    // if the item is not editable, set lastPosition to it any
                    // so future tabbing starts from there
                    lastEditedItemPosition = { columnIndex: pos.x, rowIndex: pos.y };
                }
            }
        }

        lastItemDown = null;
    }

    /**
     *  @private
     *  when the grid gets focus, focus an item renderer
     */
    override protected function focusInHandler(event:FocusEvent):void
    {
        // trace(">>DGFocusIn ", selectedIndex);

        if (losingFocus)
        {
            losingFocus = false;
            // trace("losing focus via tab");
            // trace("<<DGFocusIn ");
            return;
        }

        if (editable.length)
        {
            addEventListener(FocusEvent.KEY_FOCUS_CHANGE, keyFocusChangeHandler);
            addEventListener(MouseEvent.MOUSE_DOWN, mouseFocusChangeHandler);
        }

        if (event.target != this)
        {
            // trace("subcomponent got focus ignoring");
            // trace("<<DGFocusIn ");
            return;
        }

        super.focusInHandler(event);

        if (editable.length && !isPressed) // don't do this if we're mouse focused
        {
            _editedItemPosition = lastEditedItemPosition;

            var foundOne:Boolean = false;

            // start somewhere
            if (!_editedItemPosition)
                _editedItemPosition = { rowIndex: 0, columnIndex: 0 };

            for (;
                 _editedItemPosition.columnIndex != _columns.length;
                 _editedItemPosition.columnIndex++)
	            {
	                // If the editedItemPosition is valid, focus it,
	                // otherwise find one.
	                if (_columns[_editedItemPosition.columnIndex].editable &&
	                    _columns[_editedItemPosition.columnIndex].visible)
	                {
                        foundOne = true;
                        break;
	                }
	            }

            if (foundOne)
            {
                // trace("setting focus", _editedItemPosition.columnIndex, _editedItemPosition.rowIndex);
                setEditedItemPosition(_editedItemPosition);
            }

        }

        // trace("<<DGFocusIn ");
    }

    /**
     *  @private
     *  when the grid loses focus, close the editor
     */
    override protected function focusOutHandler(event:FocusEvent):void
    {
        // trace(">>DGFocusOut " + itemEditorInstance + " " + event.relatedObject, event.target);
        if (event.target == this)
            super.focusOutHandler(event);

        // just leave if item editor is losing focus back to grid.  Usually happens
        // when someone clicks out of the editor onto a new item renderer.
        if (event.relatedObject == this && itemRendererContains(itemEditorInstance, DisplayObject(event.target)))
            return;

        // just leave if the cell renderer is losing focus to nothing while its editor exists. 
        // this happens when we make the cell renderer invisible as we put up the editor
        // if the renderer can have focus.
        if (event.relatedObject == null && itemRendererContains(editedItemRenderer, DisplayObject(event.target)))
            return;

        // just leave if item editor is losing focus to nothing.  Usually happens
        // when someone clicks out of the textfield
        if (event.relatedObject == null && itemRendererContains(itemEditorInstance, DisplayObject(event.target)))
            return;

        // however, if we're losing focus to anything other than the editor or the grid
        // hide the editor;
        if (itemEditorInstance && (!event.relatedObject || !itemRendererContains(itemEditorInstance, event.relatedObject)))
        {
            // trace("call endEdit from focus out");
            endEdit(AdvancedDataGridEventReason.OTHER);
            removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, keyFocusChangeHandler);
            removeEventListener(MouseEvent.MOUSE_DOWN, mouseFocusChangeHandler);
        }
        // trace("<<DGFocusOut " + itemEditorInstance + " " + event.relatedObject);
    }

    /**
     *  @private
     */
    override protected function keyDownHandler(event:KeyboardEvent):void
    {
        if (itemEditorInstance || event.target != event.currentTarget)
            return;

        if (headerIndex != -1) // header navigation via keyboard
        {
            headerNavigationHandler(event);
            return;
        }
        // hit esc to move focus back to the grid itself
        else if (event.keyCode == Keyboard.ESCAPE)
        {
            // no more editing
            setEditedItemPosition(null);
            // make sure there is nothing to jump back to
            lastEditedItemPosition = null;
            // lose focus
            endEdit(AdvancedDataGridEventReason.CANCELLED);
            return;
        }
        // Handle keyboard access to the header i.e. up key when in the first row
        else if (headerVisible && selectedIndex == 0 && caretIndex == 0
                 && event.keyCode == Keyboard.UP
                 && !event.ctrlKey && !event.shiftKey)
        {
            moveFocusToHeader();
        }
        else if (event.keyCode == Keyboard.UP && caretIndex == 0 && selectedIndex == -1)
        {
            // Bug 202639 Pressing up arrow after a shift-arrow row selection should move to header
            moveFocusToHeader();
        }
        else if ( event.shiftKey
                  && (event.keyCode == Keyboard.PAGE_UP || event.keyCode == Keyboard.PAGE_DOWN) )
        {
            moveSelectionHorizontally(event.keyCode, event.shiftKey, event.ctrlKey);
        }

        if (event.keyCode != Keyboard.SPACE)
        {
            super.keyDownHandler(event);
        }
        else if (caretIndex != -1)
        {
            moveSelectionVertically(event.keyCode, event.shiftKey, event.ctrlKey);
        }
    }

    /**
     *  @private
     */
    override protected function keyUpHandler(event:KeyboardEvent):void
    {
        if (isKeyPressed && headerIndex != -1)
        {
            isKeyPressed = false;
            selectedHeaderInfo = getHeaderInfo(columns[headerIndex]);
            selectColumnHeader(headerIndex);
        }
    }
    
    /**
     *  @private
     */
    override protected function mouseWheelHandler(event:MouseEvent):void
    {
        if (itemEditorInstance)
            endEdit(AdvancedDataGridEventReason.OTHER);

        super.mouseWheelHandler(event);
    }
    
    /**
     *  @private
     *  if some drags from the same row as an editor we can be left
     *  with updates disabled
     */
    override protected function dragStartHandler(event:DragEvent):void
    {
        if (collectionUpdatesDisabled)
        {
            collection.enableAutoUpdate();
            collectionUpdatesDisabled = false;
        }
        super.dragStartHandler(event);
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private function columnResizeMouseOverHandler(event:MouseEvent):void
    {
        if (!enabled || !resizableColumns)
            return;
        var target:DisplayObject = DisplayObject(event.target);
        var index:int = target.parent.getChildIndex(target);
        var optimumColumns:Array = getOptimumColumns();
        if (!optimumColumns[index].resizable)
            return;

        // hide the mouse, attach and show the cursor
        var stretchCursorClass:Class = getStyle("stretchCursor");
        resizeCursorID = cursorManager.setCursor(stretchCursorClass,
                                                 CursorManagerPriority.HIGH);
    }

    /**
     *  @private
     */
    private function columnResizeMouseOutHandler(event:MouseEvent):void
    {
        if (!enabled || !resizableColumns)
            return;

        var target:DisplayObject = DisplayObject(event.target);
        var index:int = target.parent.getChildIndex(target);
        var optimumColumns:Array = getOptimumColumns();
        if (!optimumColumns[index].resizable)
            return;
        cursorManager.removeCursor(resizeCursorID);
    }

    /**
     *  @private
     *  Indicates where the right side of a resized column appears.
     */
    private function columnResizeMouseDownHandler(event:MouseEvent):void
    {
        if (!enabled || !resizableColumns)
            return;

        var target:DisplayObject = DisplayObject(event.target);
        var index:int = target.parent.getChildIndex(target);
        
        //If the separator is not in locked region, column index need to be adjusted
        if(lockedColumnCount > 0 &&
           target.parent == UIComponent(getLines().getChildByName("header")))
            index += (lockedColumnCount - 1);

        var optimumColumns:Array = getOptimumColumns();
        if (!optimumColumns[index].resizable)
            return;

        if (itemEditorInstance)
            endEdit(AdvancedDataGridEventReason.OTHER);

        startX = DisplayObject(event.target).x;
        lastPt = new Point(event.stageX, event.stageY);
        lastPt = listContent.globalToLocal(lastPt);

        /*      var n:int = separators.length;
            for (var i:int = 0; i < n; i++)
            {
            if (separators[i] == event.target)
            {
            resizingColumn = optimumColumns[i];
            break;
            }
            }
        
            if (!resizingColumn)
            return;
        */

        resizingColumn = optimumColumns[index];
        var headerItem:IListItemRenderer = getHeaderInfo(optimumColumns[index]).headerItem;

        if (index > lockedColumnCount)
        {
            minX = getAdjustedXPos(headerItem.x);
            startX = getAdjustedXPos(startX);
        }
        else
        {
            minX = headerItem.x;
        }

        minX += resizingColumn.minWidth;
        isPressed = true;

        var sbRoot:DisplayObject = systemManager.getSandboxRoot();
        sbRoot.addEventListener(MouseEvent.MOUSE_MOVE, columnResizingHandler, true);
        sbRoot.addEventListener(MouseEvent.MOUSE_UP, columnResizeMouseUpHandler, true);
        sbRoot.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, columnResizeMouseUpHandler);
        systemManager.deployMouseShields(true);

        var resizeSkinClass:Class = getStyle("columnResizeSkin");
        resizeGraphic = new resizeSkinClass();
        listContent.addChild(DisplayObject(resizeGraphic));

        var pt:Point = new Point(event.stageX, event.stageY);
        pt = listContent.globalToLocal(pt);
        
        resizeGraphic.move(pt.x, target.y);
        resizeGraphic.setActualSize(resizeGraphic.measuredWidth,
                                    unscaledHeight-target.y);
    }

    /**
     *  @private
     */
    private function columnResizingHandler(event:MouseEvent):void
    {
        if (!MouseEvent(event).buttonDown)
        {
            columnResizeMouseUpHandler(event);
            // return from here, as the resizingColumn
            // set to null.
            return;
        }

        var vsw:int = verticalScrollBar ? verticalScrollBar.width : 0;

        var pt:Point = new Point(event.stageX, event.stageY);
        pt = listContent.globalToLocal(pt);
        lastPt = pt;
        
        var separatorWidth:Number = 0;
        if (lockedSeparators && lockedSeparators.length > 0)
            separatorWidth = lockedSeparators[0].width;
        else if (separators && separators.length > 0)
            separatorWidth = separators[0].width;
            
        // substract the separators width,
        // so that separator will be visible after column resizing
        // TODO - we should substract the resized column separatos's width 
        var maxWidth:Number = unscaledWidth - separatorWidth - vsw ;
        var index:int;
        if(getOptimumColumns() == visibleColumns)
            index = absoluteToVisibleColumnIndex(resizingColumn.colNum);
        else
            index = absoluteToDisplayColumnIndex(resizingColumn.colNum);

        resizeGraphic.move(Math.min(Math.max(minX, pt.x), maxWidth), resizeGraphic.y);
    }

    /**
     *  @private
     *  Determines how much to resize the column.
     */
    private function columnResizeMouseUpHandler(event:Event):void
    {
        if (!enabled || !resizableColumns)
            return;

        isPressed = false;
        
        var sbRoot:DisplayObject = systemManager.getSandboxRoot();
        sbRoot.removeEventListener(MouseEvent.MOUSE_MOVE, columnResizingHandler, true);
        sbRoot.removeEventListener(MouseEvent.MOUSE_UP, columnResizeMouseUpHandler, true);
        sbRoot.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, columnResizeMouseUpHandler);
        systemManager.deployMouseShields(false);

        listContent.removeChild(DisplayObject(resizeGraphic));

        cursorManager.removeCursor(resizeCursorID);

        var c:AdvancedDataGridColumn = resizingColumn;
        resizingColumn = null;

        // need to find the visible column index here.
//        var n:int = displayableColumns.length;
//        var i:int;
//        for (i = 0; i < n; i++)
//        {
//            if (c == displayableColumns[i])
//                break;
//        }
//        if (i >= displayableColumns.length)
//            return;

        var vsw:int = verticalScrollBar ? verticalScrollBar.width : 0;
        
        var mouseEvent:MouseEvent = event as MouseEvent;

        var pt:Point;
        
        if (mouseEvent)
        {
            pt = new Point(mouseEvent.stageX, mouseEvent.stageY);
            pt = listContent.globalToLocal(pt);
        }
        else
        {
            pt = lastPt;
        }

        var separatorWidth:Number = 0;
        if (lockedSeparators && lockedSeparators.length > 0)
            separatorWidth = lockedSeparators[0].width;
        else if (separators && separators.length > 0)
            separatorWidth = separators[0].width;
        
        // substract the separators width,
        // so that separator will be visible after column resizing
        // TODO - we should substract the resized column separatos's width  
        var maxWidth:Number = unscaledWidth - separatorWidth - vsw ;

        // resize the column
        var widthChange:Number = Math.min(Math.max(minX, pt.x), maxWidth) - startX;
        resizeColumn(c.colNum, Math.floor(c.width + widthChange));

        // event
        var advancedDataGridEvent:AdvancedDataGridEvent =
            new AdvancedDataGridEvent(AdvancedDataGridEvent.COLUMN_STRETCH);
        advancedDataGridEvent.columnIndex = c.colNum;
        advancedDataGridEvent.dataField = c.dataField;
        advancedDataGridEvent.localX = pt.x;
        dispatchEvent(advancedDataGridEvent);
    }

    /**
     *  @private
     */
    private function editorMouseDownHandler(event:Event):void
    {
        if(event is MouseEvent && owns(DisplayObject(event.target)))
            return;
            
        endEdit(AdvancedDataGridEventReason.OTHER);
    }

    /**
     *  @private
     */
    protected function editorKeyDownHandler(event:KeyboardEvent):void
    {
        // ESC just kills the editor, no new data
        if (event.keyCode == Keyboard.ESCAPE)
        {
            endEdit(AdvancedDataGridEventReason.CANCELLED);
        }
        else if (event.ctrlKey && event.charCode == 46)
        {   // Check for Ctrl-.
            endEdit(AdvancedDataGridEventReason.CANCELLED);
        }
        else if (event.charCode == Keyboard.ENTER && event.keyCode != 229)
        {
            // multiline editors can take the enter key.
            if (columns[_editedItemPosition.columnIndex].editorUsesEnterKey)
                return;

            // Enter edits the item, moves down a row
            // The 229 keyCode is for IME compatability. When entering an IME expression,
            // the enter key is down, but the keyCode is 229 instead of the enter key code.
            // Thanks to Yukari for this little trick...
            if (endEdit(AdvancedDataGridEventReason.NEW_ROW) && !dontEdit)
                findNextEnterItemRenderer(event);
        }
    }

    /**
     *  @private
     */
    private function editorStageResizeHandler(event:Event):void
    {
        if (event.target is DisplayObjectContainer &&
            DisplayObjectContainer(event.target).contains(this))
            endEdit(AdvancedDataGridEventReason.OTHER);
    }

    /**
     *  @private
     *  This gets called when the tab key is hit.
     */
    private function mouseFocusChangeHandler(event:MouseEvent):void
    {
        // trace("mouseFocus handled by " + this);

        if (itemEditorInstance &&
            !event.isDefaultPrevented() &&
            itemRendererContains(itemEditorInstance, DisplayObject(event.target)))
        {
            event.preventDefault();
        }
    }

    /**
     *  @private
     *  This gets called when the tab key is hit.
     */
    private function keyFocusChangeHandler(event:FocusEvent):void
    {
        // trace("tabHandled by " + this);

        if (event.keyCode == Keyboard.TAB &&
            ! event.isDefaultPrevented() &&
            findNextItemRenderer(event.shiftKey))
        {
            event.preventDefault();
        }
    }

    /**
     *  @private
     *  Hides the itemEditorInstance.
     */
    private function itemEditorFocusOutHandler(event:FocusEvent):void
    {
        // trace("itemEditorFocusOut " + event.relatedObject);
        if (event.relatedObject && contains(event.relatedObject))
            return;

        // ignore textfields losing focus on mousedowns
        if (!event.relatedObject)
            return;

        // trace("endEdit from itemEditorFocusOut");
        if (itemEditorInstance)
            endEdit(AdvancedDataGridEventReason.OTHER);
    }

    /**
     *  @private
     */
    private function itemEditorItemEditBeginningHandler(event:AdvancedDataGridEvent):void
    {
        // trace("itemEditorItemEditBeginningHandler");
        if (!event.isDefaultPrevented())
            setEditedItemPosition({columnIndex: event.columnIndex, rowIndex: event.rowIndex});
        else if (!itemEditorInstance)
        {
            _editedItemPosition = null;
            setFocus();
        }
    }

    /**
     *  @private
     *  focus an item renderer in the grid - harder than it looks
     */
    private function itemEditorItemEditBeginHandler(event:AdvancedDataGridEvent):void
    {
        // weak reference for deactivation
        if (root)
            systemManager.addEventListener(Event.DEACTIVATE, deactivateHandler, false, 0, true);

        // if not prevented and if data is not null (might be from dataservices)
        if (!event.isDefaultPrevented() && listItems[actualRowIndex][actualColIndex].data != null)
        {
            createItemEditor(event.columnIndex, event.rowIndex);

            if (editedItemRenderer is IDropInListItemRenderer && itemEditorInstance is IDropInListItemRenderer)
                IDropInListItemRenderer(itemEditorInstance).listData = IDropInListItemRenderer(editedItemRenderer).listData;
            // if rendererIsEditor, don't apply the data as the data may have already changed in some way.
            // This can happen if clicking on a checkbox rendererIsEditor as the checkbox will try to change
            // its value as we try to stuff in an old value here.
            if (!columns[event.columnIndex].rendererIsEditor)
                itemEditorInstance.data = editedItemRenderer.data;

            if (itemEditorInstance is IInvalidating)
                IInvalidating(itemEditorInstance).validateNow();

            if (itemEditorInstance is IIMESupport)
                IIMESupport(itemEditorInstance).imeMode =
                    (columns[event.columnIndex].imeMode == null) ? _imeMode : columns[event.columnIndex].imeMode;

            var fm:IFocusManager = focusManager;
            // trace("setting focus to item editor");
            if (itemEditorInstance is IFocusManagerComponent)
                fm.setFocus(IFocusManagerComponent(itemEditorInstance));
            fm.defaultButtonEnabled = false;

            var event:AdvancedDataGridEvent =
                new AdvancedDataGridEvent(AdvancedDataGridEvent.ITEM_FOCUS_IN);
            event.columnIndex = _editedItemPosition.columnIndex;
            event.rowIndex = _editedItemPosition.rowIndex;
            event.itemRenderer = itemEditorInstance;
            dispatchEvent(event);
        }
    }

    /**
     *  @private
     */
    private function itemEditorItemEditEndHandler(event:AdvancedDataGridEvent):void
    {
        if (!event.isDefaultPrevented())
        {
            var bChanged:Boolean = false;

            if (event.reason == AdvancedDataGridEventReason.NEW_COLUMN)
            {
                if (!collectionUpdatesDisabled)
                {
                    collection.disableAutoUpdate();
                    collectionUpdatesDisabled = true;
                }
            }
            else
            {
                if (collectionUpdatesDisabled)
                {
                    collection.enableAutoUpdate();
                    collectionUpdatesDisabled = false;
                }
            }

            if (itemEditorInstance && event.reason != AdvancedDataGridEventReason.CANCELLED)
            {
                var newData:Object = itemEditorInstance[_columns[event.columnIndex].editorDataField];
                var property:String = _columns[event.columnIndex].dataField;
                var data:Object = event.itemRenderer.data;
                var typeInfo:String = "";
                for each(var variable:XML in describeType(data).variable)
                {
                    if (property == variable.@name.toString())
                    {
                        typeInfo = variable.@type.toString();
                        break;
                    }
                }

                if (typeInfo == "String")
                {
                    if (!(newData is String))
                        newData = newData.toString();
                }
                else if (typeInfo == "uint")
                {
                    if (!(newData is uint))
                        newData = uint(newData);
                }
                else if (typeInfo == "int")
                {
                    if (!(newData is int))
                        newData = int(newData);
                }
                else if (typeInfo == "Number")
                {
                    if (!(newData is int))
                        newData = Number(newData);
                }
                if (data[property] != newData)
                {
                    bChanged = true;
                    data[property] = newData;
                }
                if (bChanged && !(data is IPropertyChangeNotifier))
                {
                    collection.itemUpdated(data, property);
                }
                if (event.itemRenderer is IDropInListItemRenderer)
                {
                    var listData:AdvancedDataGridListData = AdvancedDataGridListData(IDropInListItemRenderer(event.itemRenderer).listData);
                    listData.label = _columns[event.columnIndex].itemToLabel(data);
                    IDropInListItemRenderer(event.itemRenderer).listData = listData;
                }
                event.itemRenderer.data = data;
            }
        }
        else
        {
            if (event.reason != AdvancedDataGridEventReason.OTHER)
            {
                if (itemEditorInstance && _editedItemPosition)
                {
                    // edit session is continued so restore focus and selection
                    if (selectedIndex != _editedItemPosition.rowIndex)
                        selectedIndex = _editedItemPosition.rowIndex;
                    var fm:IFocusManager = focusManager;
                    // trace("setting focus to itemEditorInstance", selectedIndex);
                    if (itemEditorInstance is IFocusManagerComponent)
                        fm.setFocus(IFocusManagerComponent(itemEditorInstance));
                }
            }
        }

        if (event.reason == AdvancedDataGridEventReason.OTHER || !event.isDefaultPrevented())
        {
            destroyItemEditor();
        }
    }

    /**
     *  @private
     */
    protected function headerReleaseHandler(event:AdvancedDataGridEvent):void
    {
        if (! event.isDefaultPrevented())
        {
            if (itemEditorInstance)
                endEdit(AdvancedDataGridEventReason.OTHER);

            var advancedDataGridEvent:AdvancedDataGridEvent =
                new AdvancedDataGridEvent(AdvancedDataGridEvent.SORT, false, true);

            advancedDataGridEvent.columnIndex     = event.columnIndex;
            advancedDataGridEvent.dataField       = event.dataField;
            advancedDataGridEvent.triggerEvent    = event.triggerEvent;
            if (event.triggerEvent)
            {
                var mouseEvent:MouseEvent = event.triggerEvent as MouseEvent;
                if (mouseEvent)
                {
                    advancedDataGridEvent.multiColumnSort      = mouseEvent.ctrlKey;
                    advancedDataGridEvent.removeColumnFromSort = mouseEvent.shiftKey;
                }
            }

            dispatchEvent(advancedDataGridEvent);
        }
    }

    /**
     *  @private
     */
    protected function sortHandler(event:AdvancedDataGridEvent):void
    {
        var columnName:String = event.dataField;
        var columnNumber:int  = event.columnIndex;
        var sortFields:Array;
        var sort:ISort;

        if (!sortableColumns || !columns[columnNumber].sortable)
            return;

        //In case there is no dataField we will use the unique column uid to identify if the column is sorted
        if (columnName == null)
            columnName = itemToUID(columns[columnNumber]);

        // If normal click for single column sort
        // or
        // If ctrl+click when there is no previous sorting
        if (!event.multiColumnSort)
        {
            if (collection.sort && collection.sort.fields.length == 1 
                && (columnName && findSortField(columnName) > -1))
            {
                    // 1. Flipping order of single column sort
                    //
                    // Not allowed in default UI. You can't flip the sort order of a single
                    // column sort using the header text part (i.e. multiColumnSort==false).
                    // You can only flip by clicking on the icon part
                    // (i.e. multiColumnSort==true), see below.
                    if (sortExpertMode == true)
                        sortDirection = flipSortOrder(columnName, columnNumber, collection);
            }
            else
            {
                // 2. Single column sort
                collection.sort = null;
                addSortField(columnName, columnNumber, collection);
            }
        }
        else
        {
            if (event.removeColumnFromSort)
            {
                removeSortField(columnName, columnNumber, collection);
            }
            // Ctrl+click without any previous sort is same as single column sort
            // Or New column added to multi column sort
            else if (findSortField(columnName) == -1)
            {
                addSortField(columnName, columnNumber, collection);
            }
            else if (findSortField(columnName) > -1) // Flipping order in multi column sort
            {
                if (collection.sort.fields.length == 1)
                {
                    // 4. Flipping the order of a column in single column sort
                    sortDirection = flipSortOrder(columnName, columnNumber, collection);
                }
                else
                {
                    // 5. Flipping the order of a column in multi column sort
                    // descending <-> ascending
                    flipSortOrder(columnName, columnNumber, collection);
                    sortDirection = null;
                }
            }
        }

        collection.refresh();

        // If navigating header via keyboard, and you mouse click on some
        // other header to sort it, then move the keyboard navigation focus
        // to that column header.
        if (headerIndex != -1)
        {
            selectedHeaderInfo = getHeaderInfo(columns[event.columnIndex]);
            headerIndex = event.columnIndex;
            selectColumnHeader(headerIndex);
        }

        invalidateHeaders();
    }
    
    /**
     *  @private
     */
    private function deactivateHandler(event:Event):void
    {
        // if stage losing activation, set focus to DG so when we get it back
        // we popup an editor again
        if (itemEditorInstance)
        {
            endEdit(AdvancedDataGridEventReason.OTHER);
            losingFocus = true;
            setFocus();
        }
    }

    /**
     *  @private
     */
    protected function headerNavigationHandler(event:KeyboardEvent):void
    {
        if (headerIndex == -1)
            return;

        // If rtl layout, need to swap LEFT and RIGHT so correct action
        // is done.
        var keyCode:uint = mapKeycodeForLayoutDirection(event);
        
        var newColumnIndex:int;

        if (keyCode == Keyboard.DOWN)
        {
            unselectColumnHeader(headerIndex, true);
            headerIndex = -1;
        }
        else if (keyCode == Keyboard.LEFT)
        {
            newColumnIndex = viewDisplayableColumnAtOffset(headerIndex, -1);
            if (newColumnIndex != -1)
            {
                unselectColumnHeader(headerIndex);
                
                selectedHeaderInfo = getHeaderInfo(columns[newColumnIndex]);
                headerIndex = newColumnIndex;
                selectColumnHeader(headerIndex);
            }
        }
        else if (keyCode == Keyboard.RIGHT)
        {
            newColumnIndex = viewDisplayableColumnAtOffset(headerIndex, +1);
            if (newColumnIndex != -1)
            {
                unselectColumnHeader(headerIndex);
                selectedHeaderInfo = getHeaderInfo(columns[newColumnIndex]);
                headerIndex = newColumnIndex;
                selectColumnHeader(headerIndex);
            }
        }
        else if (keyCode == Keyboard.SPACE)
        {
            if (sortableColumns && columns[headerIndex].sortable)
            {
                isKeyPressed = true;
                selectedHeaderInfo = getHeaderInfo(columns[headerIndex]);
                selectColumnHeader(headerIndex);
    
                var advancedDataGridEvent:AdvancedDataGridEvent =
                    new AdvancedDataGridEvent(AdvancedDataGridEvent.SORT, false, true);
    
                advancedDataGridEvent.columnIndex     = headerIndex;
                advancedDataGridEvent.dataField       = columns[headerIndex].dataField;
                advancedDataGridEvent.multiColumnSort      = event.ctrlKey;
                advancedDataGridEvent.removeColumnFromSort = event.shiftKey;
    
                dispatchEvent(advancedDataGridEvent);
            }
        }
        // horizontal scrolling when focus is on header
        else if ( event.shiftKey
                  && (keyCode == Keyboard.PAGE_UP
                      || keyCode == Keyboard.PAGE_DOWN) )
        {
            moveSelectionHorizontally(keyCode, event.shiftKey, event.ctrlKey);
        }

        event.stopPropagation();
    }
}

}