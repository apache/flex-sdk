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
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.EventPhase;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.geom.Rectangle;
import flash.ui.Keyboard;

import mx.collections.ICollectionView;
import mx.collections.IList;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.core.IFactory;
import mx.core.IIMESupport;
import mx.core.ScrollPolicy;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.managers.CursorManager;
import mx.managers.CursorManagerPriority;
import mx.managers.IFocusManagerComponent;

import spark.components.gridClasses.CellPosition;
import spark.components.gridClasses.CellRegion;
import spark.components.gridClasses.DataGridEditor;
import spark.components.gridClasses.GridColumn;
import spark.components.gridClasses.GridDimensions;
import spark.components.gridClasses.GridLayout;
import spark.components.gridClasses.GridSelection;
import spark.components.gridClasses.GridSelectionMode;
import spark.components.gridClasses.IDataGridElement;
import spark.components.gridClasses.IGridItemEditor;
import spark.components.gridClasses.IGridItemRenderer;
import spark.components.gridClasses.IGridItemRendererOwner;
import spark.components.supportClasses.SkinnableContainerBase;
import spark.core.NavigationUnit;
import spark.events.GridCaretEvent;
import spark.events.GridEvent;
import spark.events.GridSelectionEvent;
import spark.events.GridSelectionEventKind;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

/**
 *  Used to initialize the DataGrid's rowBackground.   If defined, the alternatingRowColorsBackground
 *  skin part is used to render row backgrounds whose fill color is defined by successive entries
 *  in the array value of this style.
 * 
 *  @default undefined
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Style(name="alternatingRowColors", type="Array", arrayType="uint", format="Color", inherit="no", theme="spark")]

/**
 *  The alpha of the border for this component.
 *
 *  @default 1.0
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Style(name="borderAlpha", type="Number", inherit="no", theme="spark", minValue="0.0", maxValue="1.0")]

/**
 *  The color of the border for this component.
 *
 *  @default #696969
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Style(name="borderColor", type="uint", format="Color", inherit="no", theme="spark")]

/**
 *  Controls the visibility of the border for this component.
 *
 *  @default true
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Style(name="borderVisible", type="Boolean", inherit="no", theme="spark")]

/**
 *  The alpha of the content background for this component.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Style(name="contentBackgroundAlpha", type="Number", inherit="yes", theme="spark", minValue="0.0", maxValue="1.0")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:contentBackgroundColor
 *   
 *  @default 0xF9F9F9
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Style(name="contentBackgroundColor", type="uint", format="Color", inherit="yes", theme="spark")]

/**
 *  The class to use as the skin for the cursor that indicates that a column
 *  can be resized.
 *  The default value is the "cursorStretch" symbol from the Assets.swf file.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Style(name="stretchCursor", type="Class", inherit="no")]

include "../styles/metadata/BasicNonInheritingTextStyles.as"
include "../styles/metadata/BasicInheritingTextStyles.as"

/**
 *  Name of the class of the itemEditor to be used if one is not
 *  specified for a column.  This is a way to set
 *  an item editor for a group of DataGrids instead of having to
 *  set each one individually.  If you set the DataGridColumn's itemEditor
 *  property, it supercedes this value.
 *  @default null
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Style(name="defaultDataGridItemEditor", type="Class", inherit="no")]

/**
 *  Indicates under what conditions the horizontal scroll bar is displayed.
 * 
 *  <ul>
 *  <li>
 *  <code>ScrollPolicy.ON</code> ("on") - the scroll bar is always displayed.
 *  </li> 
 *  <li>
 *  <code>ScrollPolicy.OFF</code> ("off") - the scroll bar is never displayed.
 *  The viewport can still be scrolled programmatically, by setting its
 *  horizontalScrollPosition property.
 *  </li>
 *  <li>
 *  <code>ScrollPolicy.AUTO</code> ("auto") - the scroll bar is displayed when 
 *  the viewport's contentWidth is larger than its width.
 *  </li>
 *  </ul>
 * 
 *  <p>
 *  The scroll policy affects the measured size of the scroller skin part.  This style
 *  is simply a cover for the scroller skin part's horizontalScrollPolicy.  It is not an 
 *  inheriting style so, for example, it will not affect item renderers.
 *  </p>
 * 
 *  @default ScrollPolicy.AUTO
 *
 *  @see mx.core.ScrollPolicy
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="horizontalScrollPolicy", type="String", inherit="no", enumeration="off,on,auto")]

/**
 *  Indicates under what conditions the vertical scroll bar is displayed.
 * 
 *  <ul>
 *  <li>
 *  <code>ScrollPolicy.ON</code> ("on") - the scroll bar is always displayed.
 *  </li> 
 *  <li>
 *  <code>ScrollPolicy.OFF</code> ("off") - the scroll bar is never displayed.
 *  The viewport can still be scrolled programmatically, by setting its
 *  verticalScrollPosition property.
 *  </li>
 *  <li>
 *  <code>ScrollPolicy.AUTO</code> ("auto") - the scroll bar is displayed when 
 *  the viewport's contentHeight is larger than its height.
 *  </li>
 *  </ul>
 * 
 *  <p>
 *  The scroll policy affects the measured size of the scroller skin part.  This style
 *  is simply a cover for the scroller skin part's verticalScrollPolicy.  It is not an 
 *  inheriting style so, for example, it will not affect item renderers.
 *  </p>
 * 
 *  @default ScrollPolicy.AUTO
 *
 *  @see mx.core.ScrollPolicy
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="verticalScrollPolicy", type="String", inherit="no", enumeration="off,on,auto")]

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched by the grid skin part when the caret position, size, or
 *  visibility has changed due to user interaction or being programmatically set.
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
 *  Dispatched by the grid skin part when the mouse button is pressed over a Grid cell.
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
 *  Dispatched by the grid skin part after a GRID_MOUSE_DOWN event if the mouse moves before the button is released.
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
 *  Dispatched by the grid skin part after a GRID_MOUSE_DOWN event when the mouse button is released, even
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
 *  Dispatched by the grid skin part when the mouse enters a grid cell.
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
 *  Dispatched by the grid skin part when the mouse leaves a grid cell.
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
 *  Dispatched by the grid skin part when the mouse is clicked over a cell
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
 *  Dispatched by the grid skin part when the mouse is double-clicked over a cell
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
 *  Dispatched when the selection is going to change.
 *  Calling the <code>preventDefault()</code> method
 *  on the event prevents the selection from changing.
 *  
 *  <p>This event is dispatched when the user interacts with the control.
 *  When you change the selection programmatically, 
 *  the component does not dispatch the <code>selectionChanging</code> event. </p>
 *
 *  @eventType spark.events.GridSelectionChangeEvent.SELECTION_CHANGING
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="selectionChanging", type="spark.events.GridSelectionEvent")]

/**
 *  Dispatched when the selection has changed. 
 *  
 *  <p>This event is dispatched when the user interacts with the control.
 *  When you change the selection programmatically, 
 *  the component does not dispatch the <code>selectionChange</code> event. 
 *  It dispatches the <code>valueCommit</code> event instead.</p>
 *
 *  @eventType spark.events.GridSelectionChangeEvent.SELECTION_CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="selectionChange", type="spark.events.GridSelectionEvent")]

//--------------------------------------
//  Edit Events
//--------------------------------------

/**
 *  Dispatched when a new item editor session has been requested. A listener can
 *  dynamically determine if a cell is editable and cancel the edit (with 
 *  preventDefault()) if it is not. A listener may also dynamically 
 *  change the editor that will be used by assigning a different item editor to
 *  a column.
 * 
 *  <p>If this event is cancelled the item editor will not be created.</p>
 *
 *  @eventType spark.events.GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_STARTING
 *  
 *  @see spark.components.DataGrid.itemEditorInstance
 *  @see flash.events.Event
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="gridItemEditorSessionStarting", type="spark.events.GridItemEditorEvent")]

/**
 *  Dispatched immediately after an item editor has been opened. 
 *
 *  @eventType spark.events.GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_START
 *  
 *  @see spark.components.DataGrid.itemEditorInstance
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="gridItemEditorSessionStart", type="spark.events.GridItemEditorEvent")]

/**
 *  Dispatched after the data in item editor has been saved into the data provider
 *  and the editor has been closed.  
 *
 *  @eventType spark.events.GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_SAVE
 *  
 *  @see spark.components.DataGrid.itemEditorInstance
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="gridItemEditorSessionSave", type="spark.events.GridItemEditorEvent")]

/**
 *  Dispatched after the item editor has been closed without saving its data.  
 *
 *  @eventType spark.events.GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_CANCEL
 *  
 *  @see spark.components.DataGrid.itemEditorInstance
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="gridItemEditorSessionCancel", type="spark.events.GridItemEditorEvent")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[AccessibilityClass(implementation="spark.accessibility.DataGridAccImpl")]

[DefaultProperty("dataProvider")]

[DiscouragedForProfile("mobileDevice")]

[IconFile("DataGrid.png")]

/**
 *  TBD(hmuller)
 */  
public class DataGrid extends SkinnableContainerBase implements IFocusManagerComponent, 
                              IGridItemRendererOwner, IIMESupport
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class mixins
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Placeholder for mixin by DataGridAccImpl.
     */
    mx_internal static var createAccessibilityImplementation:Function;
    
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
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function DataGrid()
    {
        super();
        
        addEventListener(Event.SELECT_ALL, selectAllHandler);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  True, when the hover indicator should be updated on a ROLL_OVER event.
     *  If the mouse button is depressed while outside of the grid, the hover 
     *  indicator is not enabled again until MOUSE_UP or ROLL_OUT. 
     */
    private var updateHoverOnRollOver:Boolean = true;
    
    //--------------------------------------------------------------------------
    //
    //  Skin Parts
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private 
     *  IFactory valued skin parts that require special handling, see findSkinParts().
     */
    private static const factorySkinPartNames:Array = [
        "alternatingRowColorsBackground",
        "caretIndicator",
        "columnSeparator",
        "headerColumnSeparator",        
        "hoverIndicator",
        "rowBackground",
        "rowSeparator",
        "selectionIndicator"];
        
    //----------------------------------
    //  alternatingRowColorsBackground
    //----------------------------------
    
    [Bindable]
    [SkinPart(required="false", type="mx.core.IFactory")]
    
    /**
     *  The IVisualElement class used to render the alternatingRowColors style
     */
    public var alternatingRowColorsBackground:IFactory;
    
    //----------------------------------
    //  caretIndicator
    //----------------------------------
    
    [Bindable]
    [SkinPart(required="false", type="mx.core.IFactory")]
    
    /**
     *  The IVisualElement class used to render the grid's caret indicator.
     */
    public var caretIndicator:IFactory;
    
    //----------------------------------
    //  columnHeaderGroup
    //----------------------------------
    
    [Bindable]
    [SkinPart(required="false", type="spark.components.GridColumnHeaderGroup")]
    
    /**
     *  A reference to the GridColumnHeaderGroup that displays the column headers.
     */
    public var columnHeaderGroup:GridColumnHeaderGroup;    
    
    //----------------------------------
    //  columnSeparator
    //----------------------------------
    
    [Bindable]
    [SkinPart(required="false", type="mx.core.IFactory")]
    
    /**
     *  The IVisualElement class used to render the vertical separator between columns. 
     */
    public var columnSeparator:IFactory;
    
    //----------------------------------
    //  editorIndicator
    //----------------------------------
    
    [Bindable]
    [SkinPart(required="false", type="mx.core.IFactory")]
    
    /**
     *  The IVisualElement class used to render a background behind
     *  item renderers that are being edited. Item renderers may only be edited
     *  when the data grid and the column are both editable and the
     *  column sets <code>rendererIsEditable</code> to true.
     */
    public var editorIndicator:IFactory;
    
    //----------------------------------
    //  grid
    //----------------------------------
    
    [Bindable]
    [SkinPart(required="false", type="spark.components.Grid")]
    
    /**
     *  A reference to the Grid that displays the dataProvider.
     */
    public var grid:spark.components.Grid;    

    //----------------------------------
    //  hoverIndicator
    //----------------------------------
    
    [Bindable]
    [SkinPart(required="false", type="mx.core.IFactory")]
    
    /**
     *  The IVisualElement class used to provide hover feedback.
     */
    public var hoverIndicator:IFactory;
    
    //----------------------------------
    //  rowBackground
    //----------------------------------
    
    [Bindable]
    [SkinPart(required="false", type="mx.core.IFactory")]
    
    /**
     *  The IVisualElement class used to render the background of each row.
     */
    public var rowBackground:IFactory;        
    
    //----------------------------------
    //  rowSeparator
    //----------------------------------
    
    [Bindable]
    [SkinPart(required="false", type="mx.core.IFactory")]
    
    /**
     *  The IVisualElement class used to render the horizontal separator between header rows. 
     */
    public var rowSeparator:IFactory;
    
    //----------------------------------
    //  scroller
    //----------------------------------
    
    [Bindable]
    [SkinPart(required="false", type="spark.components.Scroller")]
    
    /**
     *  A reference to the Scroller that scrolls the grid.
     */
    public var scroller:Scroller;    
    
    //----------------------------------
    //  selectionIndicator
    //----------------------------------
    
    [Bindable]
    [SkinPart(required="false", type="mx.core.IFactory")]
    
    /**
     *  The IVisualElement class used to render selected rows or cells.
     */
    public var selectionIndicator:IFactory;
    
    /**
     *  @private
     *  If the alternatingRowColors style is set AND the alternatingRowColorsBackground
     *  skin part has been added AND the grid skin part has been added, then set
     *  grid.rowBackground = alternatingRowColorsBackground here.
     * 
     *  TBD: if previous test fails but the grid and rowBackground skin parts have been
     *  added, then set grid.rowBackground = rowBackground.
     */
    private function initializeGridRowBackground():void
    {
        if (!grid)
            return;
        
        // FIXME (klin): what if alternatingRowColorsBackground is set to null?
        if ((getStyle("alternatingRowColors") as Array) && alternatingRowColorsBackground)
            grid.rowBackground = alternatingRowColorsBackground;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Skin Part Property Internals
    //
    //-------------------------------------------------------------------------- 
    
    /**
     *  @private
     *  A list of functions to be applied to the grid skin part at partAdded() time.
     *  This list is used to defer making grid selection updates per the set methods for
     *  the selectedIndex, selectedIndices, selectedItem, selectedItems, selectedCell
     *  and selectedCells properties.
     */
    private const deferredGridOperations:Vector.<Function> = new Vector.<Function>();
    
    /**
     *  @private
     *  Defines one bit for each skin part property that's covered by DataGrid.  Currently
     *  there are only grid properties.
     */
    private static const partPropertyBits:Object = {
        columns: uint(1 << 0),
        dataProvider: uint(1 << 1),
        itemRenderer: uint(1 << 2),
        requestedRowCount: uint(1 << 3),
        requestedColumnCount: uint(1 << 4),
        requestedMinRowCount: uint(1 << 5),
        requestedMinColumnCount: uint(1 << 6),
        rowHeight: uint(1 << 7),
        showDataTips: uint(1 << 8),
        typicalItem: uint(1 << 9),
        variableRowHeight: uint(1 << 10),
        dataTipField: uint(1 << 11),
        dataTipFunction: uint(1 << 12),
        resizableColumns: uint(1 << 13)
    };
    
    /**
     *  @private
     *  If the grid skin part hasn't been added, this var is an object whose properties
     *  temporarily record the values of DataGrid properties that just "cover" grid skin
     *  part properties. 
     * 
     *  If the grid skin part has been added (is non-null), then this var has 
     *  a single is a uint bitmask property called propertyBits that's used
     *  used to track which grid properties have been explicitly set.
     *  
     *  See getPartProperty(), setPartProperty().
     */
    private var gridProperties:Object = new Object();
    
    /**
     *  The default values of the grid skin part properties covered by DataGrid.
     */
    private static const gridPropertyDefaults:Object = {
        columns: null,
        dataProvider: null,
        itemRenderer: null,
        resizableColumns: true,
        requestedRowCount: int(10),
        requestedColumnCount: int(-1),
        requestedMinRowCount: int(-1),
        requestedMinColumnCount: int(-1),
        rowHeight: NaN,
        showDataTips: false,
        typicalItem: null,
        variableRowHeight: false,
        dataTipField: null,
        dataTipFunction: null
    };
    
    /** 
     *  @private
     *  A utility method for looking up a skin part property that accounts for the possibility that
     *  the skin part is null.  It's intended to be used in the definition of properties that just
     *  "cover" skin part properties.
     * 
     *  If part is non-null, then return part[propertyName].  Otherwise return the value
     *  of properties[propertyName], or defaults[propertyName] if the specified property's 
     *  value is undefined.
     */
    private static function getPartProperty(part:Object, properties:Object, propertyName:String, defaults:Object):*
    {
        if (part)
            return part[propertyName];
        
        const value:* = properties[propertyName];
        return (value === undefined) ? defaults[propertyName] : value;
    }
    
    /** 
     *  @private
     *  A utility method for setting a skin part property that accounts for the possibility that
     *  the skin part is null.  It's intended to be used in the definition of properties that just
     *  "cover" skin part properties.
     * 
     *  Return true if the property's value was changed.
     * 
     *  If part is non-null, then set part[propertyName], otherwise set properties[propertyName].  
     * 
     *  If part is non-null then we set the bit for this property on the properties.propertyBits, to record
     *  the fact that the DataGrid cover property was explicitly set.
     * 
     *  In either case we treat setting a property to its default value specially: the effect
     *  is as if the property was never set at all.
     */
    private static function setPartProperty(part:Object, properties:Object, propertyName:String, value:*, defaults:Object):Boolean
    {
        if (getPartProperty(part, properties, propertyName, defaults) === value)
            return false;
        
        const defaultValue:* = defaults[propertyName];
        
        if (part)
        {
            part[propertyName] = value;
            if (value === defaultValue)
                properties.propertyBits &= ~partPropertyBits[propertyName];
            else
                properties.propertyBits |= partPropertyBits[propertyName];
        }
        else
        {
            if (value === defaultValue)
                delete properties[propertyName];
            else
                properties[propertyName] = value;
        }
        
        return true;
    }
    
    /**
     *  @private
     *  Return the specified grid property.
     */
    private function getGridProperty(propertyName:String):*
    {
        return getPartProperty(grid, gridProperties, propertyName, gridPropertyDefaults);
    }
    
    /**
     *  @private
     *  Set the specified grid property and return true if the property actually changed.
     */
    private function setGridProperty(propertyName:String, value:*):Boolean
    {
        return setPartProperty(grid, gridProperties, propertyName, value, gridPropertyDefaults);
    }    
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /** 
     *  @private
     *  Maximum time in milliseconds between a click and a double click.
     *  
     */ 
    mx_internal var doubleClickTime:Number = 620;
    
    /** 
     *  @private
     * 
     *  Key used to start editting a cell.
     */ 
    mx_internal var editKey:uint = Keyboard.F2;
    
    /** 
     *  @private
     *  A cell editor is initiated by a single click on a selected cell. 
     *  If this variable is true then also open an editor when a cell is 
     *  double clicked, otherwise cancel the edit.
     */ 
    mx_internal var editOnDoubleClick:Boolean = false;
    
    /** 
     *  @private
     * 
     *  Provides all the logic to start and end item
     *  editor sessions.
     *
     *  Create your own editor by overriding the <code>createEditor()</code> 
     *  method. 
     */ 
    mx_internal var editor:DataGridEditor;

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
    
    // TBD(hmuller): baselinePosition override
    // TBD(hmuller): methods to enable scrolling
    
    
    //----------------------------------
    //  columns (delgates to grid.columns)
    //----------------------------------
    
    [Bindable("columnsChanged")]
    
    /**
     *  @copy spark.components.Grid#columns
     * 
     *  @default null
     */
    public function get columns():IList
    {
        return getGridProperty("columns");
    }
    
    /**
     *  @private
     */
    public function set columns(value:IList):void
    {
        if (setGridProperty("columns", value))
        {
            if (columnHeaderGroup)
            {
                columnHeaderGroup.layout.clearVirtualLayoutCache();
                columnHeaderGroup.invalidateSize();
                columnHeaderGroup.invalidateDisplayList();
            }
            
            dispatchChangeEvent("columnsChanged");
        }
    }
    
    private function getColumnsLength():uint
    {
        const columns:IList = columns;
        return (columns) ? columns.length : 0;
    }
    
    private function getColumnAt(columnIndex:int):GridColumn
    {
        const grid:Grid = grid;
        if (!grid || !grid.columns)
            return null;
        
        const columns:IList = grid.columns;
        return ((columnIndex >= 0) && (columnIndex < columns.length)) ? columns.getItemAt(columnIndex) as GridColumn : null;
    }
    
    //----------------------------------
    //  dataProvider (delgates to grid.dataProvider)
    //----------------------------------
    
    [Bindable("dataProviderChanged")]
    
    /**
     *  @copy spark.components.Grid#dataProvider
     * 
     *  @default nulll
     */
    public function get dataProvider():IList
    {
        return getGridProperty("dataProvider");
    }
    
    /**
     *  @private
     */
    public function set dataProvider(value:IList):void
    {
        if (setGridProperty("dataProvider", value))
            dispatchChangeEvent("dataProviderChanged");
    }
    
    /**
     *  @private
     */
    private function getDataProviderLength():uint
    {
        const dataProvider:IList = dataProvider;
        return (dataProvider) ? dataProvider.length : 0;
    }
    
    //----------------------------------
    //  dataTipField (delegates to grid.dataTipField)
    //----------------------------------    
    
    [Bindable("dataTipFieldChanged")]
    
    /**
     *  @copy spark.components.Grid#dataTipField
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get dataTipField():String
    {
        return getGridProperty("dataTipField");
    }
    
    /**
     *  @private
     */
    public function set dataTipField(value:String):void
    {
        if (setGridProperty("dataTipField", value))
            dispatchChangeEvent("dataTipFieldChanged");
    }        
        
    //----------------------------------
    //  dataTipFunction (delegates to grid.dataTipFunction)
    //----------------------------------    
    
    [Bindable("dataTipFunctionChanged")]
    
    /**
     *  @copy spark.components.Grid#dataTipFunction
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get dataTipFunction():Function
    {
        return getGridProperty("dataTipFunction");
    }
    
    /**
     *  @private
     */
    public function set dataTipFunction(value:Function):void
    {
        if (setGridProperty("dataTipFunction", value))
            dispatchChangeEvent("dataTipFunctionChanged");
    }        

    //----------------------------------
    //  editable
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the editable property.
     */
    private var _editable:Boolean = false;
    
    [Inspectable(category="General")]
    
    /**
     * The default value for the GridColumn editable property, which
     * indicates if a corresponding cell's dataProvider item can be edited.
     * If true, clicking on a selected cell opens an item editor, see
     * <code>startItemEditorSession</code>.  Developers can enable/disable
     * editing on a per cell (rather than per column) basis by handling 
     * the <code>startItemEditorSession</code> event.
     * 
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4.5
     */
    public function get editable():Boolean
    {
        return _editable;
    }
    
    /**
     *  @private
     */
    public function set editable(value:Boolean):void
    {
        _editable = value;
    }
    
    //----------------------------------
    //  editorColumnIndex
    //----------------------------------
    
    /**
     *  The zero-based column index of the cell that is being edited. The 
     *  value is -1 if no cell is being edited.
     * 
     *  @default -1
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4.5
     */
    public function get editorColumnIndex():int
    {
        if (editor)
            return editor.editorColumnIndex;
        
        return -1;
    }
    
    //----------------------------------
    //  editorRowIndex
    //----------------------------------
    
    /**
     *  The zero-based row index of the cell that is being edited. The 
     *  value is -1 if no cell is being edited.
     * 
     *  @default -1
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4.5
     */
    public function get editorRowIndex():int
    {
        if (editor)
            return editor.editorRowIndex;
        
        return -1;
    }
    
    //----------------------------------
    //  gridDimensions (private, read-only)
    //----------------------------------
    
    private var _gridDimensions:GridDimensions = null;
    
    /**
     *  @private
     */
    protected function get gridDimensions():GridDimensions
    {
        if (!_gridDimensions)
            _gridDimensions = new GridDimensions();  // TBD(hmuller):delegate to protected createGridDimensions()
        return _gridDimensions;
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
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4.5
     */
    public function get enableIME():Boolean
    {
        return false;
    }
    
    //----------------------------------
    //  gridSelection (private)
    //----------------------------------    
    
    private var _gridSelection:GridSelection = null;
    
    /**
     *  @private
     *  This object becomes the grid's gridSelection property after the grid skin part has been
     *  added.  It should only be referenced by this class when the grid skin part is null. 
     */
    protected function get gridSelection():GridSelection
    {
        if (!_gridSelection)
            _gridSelection = new GridSelection();  // TBD(hmuller):delegate to protected createGridSelection()
        return _gridSelection;
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
     *  The default value for the GridColumn imeMode property, which specifies
     *  specifies the IME (input method editor) mode.
     *  The IME enables users to enter text in Chinese, Japanese, and Korean.
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
     *  @productversion Flex 4.5
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
    //  itemEditor
    //----------------------------------
    
    [Bindable("itemEditorChanged")]
    
    private var _itemEditor:IFactory = null;
    
    /**
     *  The default value for the GridColumn itemEditor property, which specifies
     *  the IGridItemEditor class used to create item editor instances.
     * 
     *  @default null.
     *
     *  @see #dataField 
     *  @see GridItemRenderer
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5 
     */
    public function get itemEditor():IFactory
    {
        return _itemEditor;
    }
    
    /**
     *  @private
     */
    public function set itemEditor(value:IFactory):void
    {
        if (_itemEditor == value)
            return;
        
        _itemEditor = value;
        
        dispatchChangeEvent("itemEditorChanged");
    }    
        
    /**
     *  A reference to the currently active instance of the item editor, 
     *  if it exists.
     *
     *  <p>To access the item editor instance and the new item value when an 
     *  item is being edited, you use the <code>itemEditorInstance</code> 
     *  property. The <code>itemEditorInstance</code> property
     *  is not valid until the <code>itemEditorSessionStart</code> event is 
     *  dispatched.</p>
     *
     *  <p>The <code>DataGridColumn.itemEditor</code> property defines the
     *  class of the item editor and, therefore, the data type of the item
     *  editor instance.</p>
     *
     *  <p>You do not set this property in MXML.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4.5
     */
    public function get itemEditorInstance():IGridItemEditor
    {
        if (editor)
            return editor.itemEditorInstance;
        
        return null; 
    }
    
    //----------------------------------
    //  itemRenderer (delegates to grid.itemRenderer)
    //----------------------------------    
    
    [Bindable("itemRendererChanged")]
    
    /**
     *  @copy spark.components.Grid#itemRenderer
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get itemRenderer():IFactory
    {
        return getGridProperty("itemRenderer");
    }
    
    /**
     *  @private
     */
    public function set itemRenderer(value:IFactory):void
    {
        if (setGridProperty("itemRenderer", value))
            dispatchChangeEvent("itemRendererChanged");
    }    
    
    //----------------------------------
    //  preserveSelection (delegates to grid.preserveSelection)
    //----------------------------------
    
    /**
     *  @copy spark.components.Grid#preserveSelection
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get preserveSelection():Boolean
    {
        if (grid)
            return grid.preserveSelection;
        else
            return gridSelection.preserveSelection;
    }
    
    /**
     *  @private
     */    
    public function set preserveSelection(value:Boolean):void
    {
        if (grid)
            grid.preserveSelection = value;
        else
            gridSelection.preserveSelection = value;
    }
    
    //----------------------------------
    //  requireSelection (delegates to grid.requireSelection)
    //----------------------------------
    
    /**
     *  @copy spark.components.Grid#requireSelection
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get requireSelection():Boolean
    {
        if (grid)
            return grid.requireSelection;
        else
            return gridSelection.requireSelection;
    }
    
    /**
     *  @private
     */    
    public function set requireSelection(value:Boolean):void
    {
        if (grid)
            grid.requireSelection = value;
        else
            gridSelection.requireSelection = value;
    }
    
    //----------------------------------
    //  requestedRowCount(delegates to grid.requestedRowCount)
    //----------------------------------
    
    /**
     *  @copy spark.components.Grid#requestedRowCount
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get requestedRowCount():int
    {
        return getGridProperty("requestedRowCount");
    }
    
    /**
     *  @private
     */    
    public function set requestedRowCount(value:int):void
    {
        setGridProperty("requestedRowCount", value);
    }
    
    //----------------------------------
    //  requestedColumnCount(delegates to grid.requestedColumnCount)
    //----------------------------------
    
    /**
     *  @copy spark.components.Grid#requestedColumnCount
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get requestedColumnCount():int
    {
        return getGridProperty("requestedColumnCount");
    }
    
    /**
     *  @private
     */    
    public function set requestedColumnCount(value:int):void
    {
        setGridProperty("requestedColumnCount", value);
    }
    
    //----------------------------------
    //  requestedMinRowCount(delegates to grid.requestedMinRowCount)
    //----------------------------------
    
    /**
     *  @copy spark.components.Grid#requestedMinRowCount
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get requestedMinRowCount():int
    {
        return getGridProperty("requestedMinRowCount");
    }
    
    /**
     *  @private
     */    
    public function set requestedMinRowCount(value:int):void
    {
        setGridProperty("requestedMinRowCount", value);
    }
    
    //----------------------------------
    //  requestedMinColumnCount(delegates to grid.requestedMinColumnCount)
    //----------------------------------
    
    /**
     *  @copy spark.components.Grid#requestedMinColumnCount
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get requestedMinColumnCount():int
    {
        return getGridProperty("requestedMinColumnCount");
    }
    
    /**
     *  @private
     */    
    public function set requestedMinColumnCount(value:int):void
    {
        setGridProperty("requestedMinColumnCount", value);
    }
    
    //----------------------------------
    //  resizableColumns(delegates to grid.resizableColumns)
    //----------------------------------
    
    /**
     *  @copy spark.components.Grid#resizableColumns
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get resizableColumns():Boolean
    {
        return getGridProperty("resizableColumns");
    }
    
    /**
     *  @private
     */    
    public function set resizableColumns(value:Boolean):void
    {
        setGridProperty("resizableColumns", value);
    }        
    
    //----------------------------------
    //  rowHeight(delegates to grid.rowHeight)
    //----------------------------------
    
    [Bindable("rowHeightChanged")]
    
    /**
     *  @copy spark.components.Grid#rowHeight
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get rowHeight():Number
    {
        return getGridProperty("rowHeight");
    }
    
    /**
     *  @private
     */    
    public function set rowHeight(value:Number):void
    {
        if (setGridProperty("rowHeight", value))
            dispatchChangeEvent("rowHeightChanged");
    }    
    
    //----------------------------------
    //  selectionMode delegates to (delegates to grid.selectionMode)
    //----------------------------------    
    
    [Bindable("selectionModeChanged")]
    [Inspectable(category="General", enumeration="none,singleRow,multipleRows,singleCell,multipleCells", defaultValue="singleRow")]
    
    /**
     *  @copy spark.components.Grid#selectionMode
     *
     *  @see spark.components.gridClasses.GridSelectionMode
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get selectionMode():String
    {
        if (grid)
            return grid.selectionMode;
        else
            return gridSelection.selectionMode;
    }
    
    /**
     *  @private
     */
    public function  set selectionMode(value:String):void
    {
        if (selectionMode == value)
            return;
        
        if (grid)
            grid.selectionMode = value;
        else
            gridSelection.selectionMode = value;
        
        // Show the caret if we have focus and not in grid selection mode of "none".
        if (grid && grid.layout is GridLayout &&
            caretIndicator)
        {
            GridLayout(grid.layout).showCaret = (value != GridSelectionMode.NONE && 
                                                 this == getFocus());
        }
            
        dispatchChangeEvent("selectionModeChanged");
    }
    
    mx_internal function isRowSelectionMode():Boolean
    {
        const mode:String = selectionMode;
        return mode == GridSelectionMode.SINGLE_ROW || mode == GridSelectionMode.MULTIPLE_ROWS;
    }
    
    mx_internal function isCellSelectionMode():Boolean
    {
        const mode:String = selectionMode;        
        return mode == GridSelectionMode.SINGLE_CELL || mode == GridSelectionMode.MULTIPLE_CELLS;
    }
    
    //----------------------------------
    //  showDataTips
    //----------------------------------

    [Bindable("showDataTipsChanged")]
    [Inspectable(category="Data", defaultValue="false")]
    
    /**
     *  @copy spark.components.Grid#showDataTips
     * 
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get showDataTips():Boolean
    {
        return getGridProperty("showDataTips");
    }
    
    /**
     *  @private
     */
    public function set showDataTips(value:Boolean):void
    {
        if (setGridProperty("showDataTips", value))
            dispatchChangeEvent("showDataTipsChanged");
    }    
    
    //----------------------------------
    //  sortableColumns
    //----------------------------------
    
    private var _sortableColumns:Boolean = true;
    
    [Bindable("sortableColumnsChanged")]
    [Inspectable(category="General")]
    
    /**
     *  A flag that indicates whether the user can interactively sort columns.
     *  If <code>true</code>, the user can sort the dataProvider by the
     *  dataField of a column by clicking on the column's header.
     *  If <code>true</code>, individual columns must have their 
     *  <code>sortable</code> properties set to <code>false</code> to 
     *  prevent the user from sorting by a particular column.  
     * 
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get sortableColumns():Boolean
    {
        return _sortableColumns;
    }
    
    /**
     *  @private
     */    
    public function set sortableColumns(value:Boolean):void
    {
        if (_sortableColumns == value)
            return;
        
        _sortableColumns = value;
        dispatchChangeEvent("sortableColumnsChanged");
    }        
    
    //----------------------------------
    //  typicalItem delegates to (delegates to grid.typicalItem)
    //----------------------------------    
    
    [Bindable("typicalItemChanged")]
    
    /**
     *  @copy spark.components.Grid#typicalItem
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function get typicalItem():Object
    {
        return getGridProperty("typicalItem");
    }
    
    /**
     *  @private
     */
    public function set typicalItem(value:Object):void
    {
        if (setGridProperty("typicalItem", value))
            dispatchChangeEvent("typicalItemChanged");
    }

    /**
     *  @copy spark.components.Grid#invalidateTypicalItem
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function invalidateTypicalItem():void
    {
        if (grid)
            grid.invalidateTypicalItem();
    }
    
    //----------------------------------
    //  variableRowHeight(delegates to grid.variableRowHeight)
    //----------------------------------
    
    /**
     *  @copy spark.components.Grid#variableRowHeight
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get variableRowHeight():Boolean
    {
        return getGridProperty("variableRowHeight");
    }
    
    /**
     *  @private
     */    
    public function set variableRowHeight(value:Boolean):void
    {
        setGridProperty("variableRowHeight", value);
    }     
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function initializeAccessibility():void
    {
        if (DataGrid.createAccessibilityImplementation != null)
            DataGrid.createAccessibilityImplementation(this);
    }
    
    /**
     *  @private
     */ 
    override public function styleChanged(styleName:String):void
    {
        super.styleChanged(styleName);
        
        const allStyles:Boolean = (styleName == null || styleName == "styleName");
        
        if (grid)
        {
            if (allStyles || styleManager.isSizeInvalidatingStyle(styleName))
            {
                if (grid)
                {
                    grid.invalidateSize();
                    grid.clearGridLayoutCache(true);
                }
                if (columnHeaderGroup)
                {
                    columnHeaderGroup.layout.clearVirtualLayoutCache();
                    columnHeaderGroup.invalidateSize();
                }
            }
            
            if (allStyles || (styleName == "alternatingRowColors"))
            {
                initializeGridRowBackground();
                if (grid && grid.layout)
                    grid.layout.clearVirtualLayoutCache();               
            }
            
            if (grid)
                grid.invalidateDisplayList();
            
            if (columnHeaderGroup)
                columnHeaderGroup.invalidateDisplayList();
        }
        
        if (scroller)
        {
            // The scrollPolicy styles are initialized in framework/defaults.css
            // so there's no way to determine if been explicitly set here.  To avoid 
            // preempting explicitly set scroller scrollPolicy styles with the default
            // "auto" value, we only forward the style if it's not "auto".
            
            const vsp:String = getStyle("verticalScrollPolicy");
            if (styleName == "verticalScrollPolicy")
                scroller.setStyle("verticalScrollPolicy", vsp);
            else if (allStyles && vsp && (vsp !== ScrollPolicy.AUTO))
                scroller.setStyle("verticalScrollPolicy", vsp);
                
            const hsp:String = getStyle("horizontalScrollPolicy");
            if (styleName == "horizontalScrollPolicy")
                scroller.setStyle("horizontalScrollPolicy", hsp);
            else if (allStyles && hsp && (hsp !== ScrollPolicy.AUTO))
                scroller.setStyle("horizontalScrollPolicy", hsp);
        }
    }
    
    /**
     *  @private
     *  Build in basic keyboard navigation support in Grid. The focus is on
     *  the DataGrid which means the Scroller doesn't see the Keyboard events
     *  unless the event is dispatched to it.
     */
    override protected function keyDownHandler(event:KeyboardEvent):void
    {
        // If the key is passed down to the Scroller it will come back here when
        // it bubbles back up.  It may or may not have default prevented.
        if (event.eventPhase != EventPhase.AT_TARGET)
            return;
        
        if (!grid || event.isDefaultPrevented())
            return;

        // Ctrl-A only comes thru on Mac.  On Windows it is a SELECT_ALL
        // event.
        if (event.keyCode == Keyboard.A && event.ctrlKey)
        { 
            selectAllFromKeyboard();
            return;
        }

        // Row selection requires valid row caret, cell selection
        // requires both a valid row and a valid column caret.

        if (selectionMode == GridSelectionMode.NONE || 
            grid.caretRowIndex < 0 || 
            grid.caretRowIndex >= getDataProviderLength() ||
            (isCellSelectionMode() && 
                (grid.caretColumnIndex < 0 || 
                    grid.caretColumnIndex >= getColumnsLength())))
        {
            if (scroller)
                scroller.dispatchEvent(event);
            return;
        }
        
        var op:String;
        
        // Was the space bar hit? 
        if (event.keyCode == Keyboard.SPACE)
        {
            if (event.ctrlKey)
            {
                // Updates the selection.  The caret remains the same and the
                // anchor is updated.
                if (toggleSelection(grid.caretRowIndex, grid.caretColumnIndex))
                {
                    grid.anchorRowIndex = grid.caretRowIndex;
                    grid.anchorColumnIndex = grid.caretColumnIndex;
                    event.preventDefault();                
                }
            }
            else if (event.shiftKey)
            {
                // Extend the selection.  The caret remains the same.
                if (extendSelection(grid.caretRowIndex, grid.caretColumnIndex))
                    event.preventDefault();                
            }
            else
            {
                if (grid.caretRowIndex != -1)
                {
                    if (isRowSelectionMode())
                    {
                        op = selectionMode == GridSelectionMode.SINGLE_ROW ?
                            GridSelectionEventKind.SET_ROW :
                            GridSelectionEventKind.ADD_ROW;
                        
                        // Add the row and leave the caret position unchanged.
                        if (!commitInteractiveSelection(
                            op, grid.caretRowIndex, grid.caretColumnIndex))
                        {
                            return;
                        }
                        event.preventDefault();                
                    }
                    else if (isCellSelectionMode() && grid.caretColumnIndex != -1)
                    {
                        op = selectionMode == GridSelectionMode.SINGLE_CELL ?
                            GridSelectionEventKind.SET_CELL :
                            GridSelectionEventKind.ADD_CELL;
                        
                        // Add the cell and leave the caret position unchanged.
                        if (!commitInteractiveSelection(
                            op, grid.caretRowIndex, grid.caretColumnIndex))
                        {
                            return;
                        }
                        event.preventDefault();                
                    }
                }
            }
            return;
        }
        
        // Was some other navigation key hit?
        adjustSelectionUponNavigation(event);
    }
    
    /**
     *  @private
     *  New event in FP10 dispatched when the user activates the platform 
     *  specific accelerator key combination for a select all operation.
     *  On Windows this is ctrl-A and on Mac this is cmd-A.
     */
    protected function selectAllHandler(event:Event):void
    {
        if (!grid || event.isDefaultPrevented())
            return;

        selectAllFromKeyboard();
    }
    
    /**
     *  @private
     */
    private function selectAllFromKeyboard():void
    {
        // If there is a caret, leave it in its current position.
        if (selectionMode == GridSelectionMode.MULTIPLE_CELLS || 
            selectionMode == GridSelectionMode.MULTIPLE_ROWS)
        {
            commitInteractiveSelection(
                GridSelectionEventKind.SELECT_ALL,
                0, 0, dataProvider.length, columns.length);
            
            grid.anchorRowIndex = 0;
            grid.anchorColumnIndex = 0;
        }
    }
    
    /**
     *  @private
     *  Call partAdded() for IFactory type skin parts.   By default, partAdded() is not 
     *  called for IFactory type skin part variables, because they're assumed to be 
     *  "dynamic" skin parts, to be created with createDynamicPartInstance().  That's 
     *  not the case with the IFactory valued parts listed in factorySkinPartNames.
     */ 
    override protected function findSkinParts():void
    {
        super.findSkinParts();
        
        for each (var partName:String in factorySkinPartNames)
        {
            if ((partName in skin) && skin[partName])
                partAdded(partName, skin[partName]);
        }
    }
    
    /**
     *  @private
     */
    private function initializeDataGridElement(elt:IDataGridElement):void
    {
        if (!elt)
            return;
        
        elt.dataGrid = this;
        elt.nestLevel = grid.nestLevel + 1;
    }
    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == grid)
        {
            // Basic Initialization
            
            const layout:GridLayout = new GridLayout();
            grid.layout = layout;  // TBD(hmuller): delegate to protected createGridLayout()
            grid.gridDimensions = layout.gridDimensions = gridDimensions;
            gridSelection.grid = grid;
            grid.gridSelection = gridSelection;
            grid.dataGrid = this;

            // Grid cover Properties
            
            const modifiedGridProperties:Object = gridProperties;  // explicitly set properties
            gridProperties = {propertyBits:0};
            
            for (var propertyName:String in modifiedGridProperties)
            {
                if (propertyName == "propertyBits")
                    continue;
                setGridProperty(propertyName, modifiedGridProperties[propertyName]);
            }
            
            // IFactory valued skin parts => Grid visual element properties
            
            initializeGridRowBackground();
            grid.columnSeparator = columnSeparator;
            grid.rowSeparator = rowSeparator;
            grid.hoverIndicator = hoverIndicator;
            grid.caretIndicator = caretIndicator;
            grid.selectionIndicator = selectionIndicator;
            
            // Event Handlers
            
            grid.addEventListener(GridEvent.GRID_MOUSE_DOWN, grid_MouseDownHandler);
            grid.addEventListener(GridEvent.GRID_MOUSE_UP, grid_MouseUpHandler);
            grid.addEventListener(GridEvent.GRID_ROLL_OVER, grid_RollOverHandler);
            grid.addEventListener(GridEvent.GRID_ROLL_OUT, grid_RollOutHandler);
            grid.addEventListener(GridCaretEvent.CARET_CHANGE, grid_caretChangeHandler);            
            grid.addEventListener(FlexEvent.VALUE_COMMIT, grid_valueCommitHandler);
            grid.addEventListener("invalidateSize", grid_invalidateSizeHandler);            
            grid.addEventListener("invalidateDisplayList", grid_invalidateDisplayListHandler);
            
            // Deferred operations (grid selection updates)
            
            for each (var deferredGridOperation:Function in deferredGridOperations)
                deferredGridOperation(grid);
            deferredGridOperations.length = 0;
            
            // IDataGridElements: columnHeaderGroup...
            
            initializeDataGridElement(columnHeaderGroup);
            
            // Create the data grid editor
            
            editor = createEditor();
            editor.initialize();                               
        }
        
        if (instance == alternatingRowColorsBackground)
            initializeGridRowBackground();
        
        if (grid)
        {
            if (instance == columnSeparator) 
                grid.columnSeparator = columnSeparator;

            if (instance == rowSeparator) 
                grid.rowSeparator = rowSeparator;

            if (instance == hoverIndicator) 
                grid.hoverIndicator = hoverIndicator;

            if (instance == caretIndicator)
            {                
                grid.caretIndicator = caretIndicator;
                
                // Add a focus listener so we can turn the caret on and off
                // when we get and lose focus.
                addEventListener(FocusEvent.FOCUS_IN, dataGrid_focusHandler);
                addEventListener(FocusEvent.FOCUS_OUT, dataGrid_focusHandler);
                if (grid && grid.layout is GridLayout)
                    GridLayout(grid.layout).showCaret = false;
            }    
            
            if (instance == selectionIndicator) 
                grid.selectionIndicator = selectionIndicator;

        }
        
        if (instance == columnHeaderGroup)
        {
            if (grid)
                initializeDataGridElement(columnHeaderGroup);
            
            columnHeaderGroup.addEventListener(GridEvent.GRID_CLICK, columnHeaderGroup_clickHandler);
            columnHeaderGroup.addEventListener(GridEvent.SEPARATOR_ROLL_OVER, separator_rollOverHandler);
            columnHeaderGroup.addEventListener(GridEvent.SEPARATOR_ROLL_OUT, separator_rollOutHandler);
            columnHeaderGroup.addEventListener(GridEvent.SEPARATOR_MOUSE_DOWN, separator_mouseDownHandler);
            columnHeaderGroup.addEventListener(GridEvent.SEPARATOR_MOUSE_DRAG, separator_mouseDragHandler);
            columnHeaderGroup.addEventListener(GridEvent.SEPARATOR_MOUSE_UP, separator_mouseUpHandler);  
        }
        
        if (instance == scroller)
        {
            // The scrollPolicy styles are initialized in framework/defaults.css
            // so there's no way to determine if been explicitly set here.  To avoid 
            // preempting explicitly set scroller scrollPolicy styles with the default
            // "auto" value, we only forward the style if it's not "auto".
            
            const vsp:String = getStyle("verticalScrollPolicy");
            if (vsp && (vsp !== ScrollPolicy.AUTO))
                scroller.setStyle("verticalScrollPolicy", vsp);
            
            const hsp:String = getStyle("horizontalScrollPolicy");
            if (hsp && (hsp !== ScrollPolicy.AUTO))
                scroller.setStyle("horizontalScrollPolicy", hsp);            
        }
    }
    
    /**
     * @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);
        
        if (instance == grid)
        {
            // Basic Initialization
            
            const layout:GridLayout = GridLayout(grid.layout);
            grid.gridDimensions = layout.gridDimensions = null;
            grid.layout = null;
            gridSelection.grid = null;
            grid.gridSelection = null;
            grid.dataGrid = null;            
            
            // Event Handlers
            
            grid.removeEventListener("invalidateSize", grid_invalidateSizeHandler);            
            grid.removeEventListener("invalidateDisplayList", grid_invalidateDisplayListHandler);
            grid.removeEventListener(GridEvent.GRID_MOUSE_DOWN, grid_MouseDownHandler);
            grid.removeEventListener(GridEvent.GRID_MOUSE_UP, grid_MouseUpHandler);
            grid.removeEventListener(GridEvent.GRID_ROLL_OVER, grid_RollOverHandler);
            grid.removeEventListener(GridEvent.GRID_ROLL_OUT, grid_RollOutHandler);            
            grid.removeEventListener(GridCaretEvent.CARET_CHANGE, grid_caretChangeHandler);            
            grid.removeEventListener(FlexEvent.VALUE_COMMIT, grid_valueCommitHandler);
            
            // Cover Properties
            
            const gridPropertyBits:uint = gridProperties.propertyBits;
            gridProperties = new Object();
            
            for (var propertyName:String in gridPropertyDefaults)
            {
                var propertyBit:uint = partPropertyBits[propertyName];
                if ((propertyBit & gridPropertyBits) == propertyBit)
                    gridProperties[propertyName] = getGridProperty(propertyName);                
            }
            
            // Visual Elements
            
            grid.rowBackground = null;
            grid.columnSeparator = null;
            grid.rowSeparator = null;
            grid.hoverIndicator = null;
            grid.caretIndicator = null;
            grid.selectionIndicator = null;
            
            // IDataGridElements: grid, columnHeaderGroup
            
            if (columnHeaderGroup)
                columnHeaderGroup.dataGrid = null; 

            // Data grid editor
            if (editor)
            {
                editor.uninitialize();
                editor = null;
            }
        }
        
        if (grid)
        {
            if (instance == columnSeparator) 
                grid.columnSeparator = null;
            
            if (instance == rowSeparator) 
                grid.rowSeparator = null;
            
            if (instance == hoverIndicator) 
                grid.hoverIndicator = null;
            
            if (instance == caretIndicator)
            {
                grid.caretIndicator = null;
                
                removeEventListener(FocusEvent.FOCUS_IN, dataGrid_focusHandler);
                removeEventListener(FocusEvent.FOCUS_OUT, dataGrid_focusHandler);
            }
            
            if (instance == selectionIndicator) 
                grid.selectionIndicator = null;
        }

        if (instance == columnHeaderGroup)
        {
            columnHeaderGroup.dataGrid = null;
            columnHeaderGroup.removeEventListener(GridEvent.GRID_CLICK, columnHeaderGroup_clickHandler);
            columnHeaderGroup.removeEventListener(GridEvent.SEPARATOR_ROLL_OVER, separator_rollOverHandler);
            columnHeaderGroup.removeEventListener(GridEvent.SEPARATOR_ROLL_OUT, separator_rollOutHandler);
            columnHeaderGroup.removeEventListener(GridEvent.SEPARATOR_MOUSE_DOWN, separator_mouseDownHandler);
            columnHeaderGroup.removeEventListener(GridEvent.SEPARATOR_MOUSE_DRAG, separator_mouseDragHandler);
            columnHeaderGroup.removeEventListener(GridEvent.SEPARATOR_MOUSE_UP, separator_mouseUpHandler);             
        }
        
    }
    
    //----------------------------------
    //  selectedCell
    //----------------------------------
    
    [Bindable("selectionChange")]
    [Bindable("valueCommit")]
    
    /**
     *  @copy spark.components.Grid#selectedCell
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get selectedCell():CellPosition
    {
        if (grid)
            return grid.selectedCell;
        
        return selectedCells.length ? selectedCells[0] : null;
    }
    
    /**
     *  @private
     */
    public function set selectedCell(value:CellPosition):void
    {
        if (grid)
            grid.selectedCell = value;
        else
        {
            const valueCopy:CellPosition = (value) ? new CellPosition(value.rowIndex, value.columnIndex) : null;
            
            var f:Function = function(g:Grid):void
            {
                g.selectedCell = valueCopy;
            }
            deferredGridOperations.push(f);
        }
    }    
    
    //----------------------------------
    //  selectedCells
    //----------------------------------
    
    [Bindable("selectionChange")]
    [Bindable("valueCommit")]
    
    /**
     *  @copy spark.components.Grid#selectedCells
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get selectedCells():Vector.<CellPosition>
    {
        return grid ? grid.selectedCells : gridSelection.allCells();
    }
    
    /**
     *  @private
     */
    public function set selectedCells(value:Vector.<CellPosition>):void
    {
        if (grid)
            grid.selectedCells = value;
        else
        {
            const valueCopy:Vector.<CellPosition> = (value) ? value.concat() : null;
            var f:Function = function(g:Grid):void
            {
                g.selectedCells = valueCopy;
            }
            deferredGridOperations.push(f);
        }
    }       
    
    //----------------------------------
    //  selectedIndex
    //----------------------------------
    
    [Bindable("selectionChange")]
    [Bindable("valueCommit")]
    
    /**
     *  @copy spark.components.Grid#selectedIndex
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get selectedIndex():int
    {
        if (grid)
            return grid.selectedIndex;
        
        return (selectedIndices.length > 0) ? selectedIndices[0] : -1;
    }
    
    /**
     *  @private
     */
    public function set selectedIndex(value:int):void
    {
        if (grid)
            grid.selectedIndex = value;
        else
        {
            var f:Function = function(g:Grid):void
            {
                g.selectedIndex = value;
            }
            deferredGridOperations.push(f);
        }
    }
    
    //----------------------------------
    //  selectedIndices
    //----------------------------------
    
    [Bindable("selectionChange")]
    [Bindable("valueCommit")]
    
    /**
     *  @copy spark.components.Grid#selectedIndices
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get selectedIndices():Vector.<int>
    {
        return grid ? grid.selectedIndices : gridSelection.allRows();
    }
    
    /**
     *  @private
     */
    public function set selectedIndices(value:Vector.<int>):void
    {
        if (grid)
            grid.selectedIndices = value;
        else
        {
            const valueCopy:Vector.<int> = (value) ? value.concat() : null;
            var f:Function = function(g:Grid):void
            {
                g.selectedIndices = valueCopy;
            }
            deferredGridOperations.push(f);
        }
    }    
    
    //----------------------------------
    //  selectedItem
    //----------------------------------
    
    [Bindable("selectionChange")]
    [Bindable("valueCommit")]
    
    /**
     *  @copy spark.components.Grid#selectedItem
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get selectedItem():Object
    {
        if (grid)
            return grid.selectedItem;
        
        return (dataProvider && (selectedIndex > 0)) ? 
            dataProvider.getItemAt(selectedIndex) : undefined;
    }
    
    /**
     *  @private
     */
    public function set selectedItem(value:Object):void
    {
        if (grid)
            grid.selectedItem = value;
        else
        {
            var f:Function = function(g:Grid):void
            {
                g.selectedItem = value;
            }
            deferredGridOperations.push(f);
        }
    }    
    
    //----------------------------------
    //  selectedItems
    //----------------------------------
    
    [Bindable("selectionChange")]
    [Bindable("valueCommit")]
    
    /**
     *  @copy spark.components.Grid#selectedItems
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get selectedItems():Vector.<Object>
    {
        if (grid)
            return grid.selectedItems;
        
        var items:Vector.<Object> = new Vector.<Object>();
        
        for (var i:int = 0; i < selectedIndices.length; i++)
            items.push(selectedIndices[i]);
        
        return items;
    }
    
    /**
     *  @private
     */
    public function set selectedItems(value:Vector.<Object>):void
    {
        if (grid)
            grid.selectedItems = value;
        else
        {
            const valueCopy:Vector.<Object> = value.concat();
            var f:Function = function(g:Grid):void
            {
                g.selectedItems = valueCopy;
            }
            deferredGridOperations.push(f);
        }
    }      
    
    //----------------------------------
    //  selectionLength
    //----------------------------------
    
    [Bindable("selectionChange")]
    [Bindable("valueCommit")]
    
    /**
     *  @copy spark.components.Grid#selectionLength
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function get selectionLength():int
    {
        return grid ? grid.selectionLength : gridSelection.selectionLength;
    }    
    
    //--------------------------------------------------------------------------
    //
    //  Public Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @copy spark.components.Grid#selectAll()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function selectAll():Boolean
    {
        var selectionChanged:Boolean;
        
        if (grid)
        {
            selectionChanged = grid.selectAll();
        }
        else
        {
            selectionChanged = gridSelection.selectAll();
            if (selectionChanged)
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
        }
        
        return selectionChanged;
    }
    
    /**
     *  @copy spark.components.Grid#clearSelection()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function clearSelection():Boolean
    {
        var selectionChanged:Boolean;
        
        if (grid)
        {
            selectionChanged = grid.clearSelection();
        }
        else
        {
            selectionChanged = gridSelection.removeAll();
            if (selectionChanged)
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
        }
        
        return selectionChanged;
    }
    
    
    //----------------------------------
    //  selection for rows
    //----------------------------------    
    
    /**
     *  @copy spark.components.Grid#selectionContainsIndex
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function selectionContainsIndex(rowIndex:int):Boolean 
    {
        if (grid)
            return grid.selectionContainsIndex(rowIndex);
        else
            return gridSelection.containsRow(rowIndex);         
    }
    
    /**
     *  @copy spark.components.Grid#selectionContainsIndices
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function selectionContainsIndices(rowIndices:Vector.<int>):Boolean 
    {
        if (grid)
            return grid.selectionContainsIndices(rowIndices);
        else
            return gridSelection.containsRows(rowIndices);
    }
    
    /**
     *  @copy spark.components.Grid#setSelectedIndex
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function setSelectedIndex(rowIndex:int):Boolean
    {
        var selectionChanged:Boolean;
        
        if (grid)
        {
            selectionChanged = grid.setSelectedIndex(rowIndex);
        }
        else
        {
            selectionChanged = gridSelection.setRow(rowIndex);
            if (selectionChanged)
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
        }
        
        return selectionChanged;
    }
    
    /**
     *  @copy spark.components.Grid#addSelectedIndex
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function addSelectedIndex(rowIndex:int):Boolean
    {
        var selectionChanged:Boolean;
        
        if (grid)
        {
            selectionChanged = grid.addSelectedIndex(rowIndex);
        }
        else
        {
            selectionChanged = gridSelection.addRow(rowIndex);
            if (selectionChanged)
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
        }
        
        return selectionChanged;
    }
    
    /**
     *  @copy spark.components.Grid#removeSelectedIndex
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function removeSelectedIndex(rowIndex:int):Boolean
    {
        var selectionChanged:Boolean;
        
        if (grid)
        {
            selectionChanged = grid.removeSelectedIndex(rowIndex);
        }
        else
        {
            selectionChanged = gridSelection.removeRow(rowIndex);
            if (selectionChanged)
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
        }
        
        return selectionChanged;
    }
    
    /**
     *  @copy spark.components.Grid#setSelectedIndices
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function selectIndices(rowIndex:int, rowCount:int):Boolean
    {
        var selectionChanged:Boolean;
        
        if (grid)
        {
            selectionChanged = grid.selectIndices(rowIndex, rowCount);
        }
        else
        {
            selectionChanged = gridSelection.setRows(rowIndex, rowCount);
            if (selectionChanged)
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
        }
        
        return selectionChanged;
    }
    
    //----------------------------------
    //  selection for cells
    //----------------------------------    
    
    /**
     *  @copy spark.components.Grid#selectionContainsCell
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function selectionContainsCell(rowIndex:int, columnIndex:int):Boolean
    {
        if (grid)
            return grid.selectionContainsCell(rowIndex, columnIndex);
        else
            return gridSelection.containsCell(rowIndex, columnIndex);
    }
    
    /**
     *  @copy spark.components.Grid#selectionContainsCellRegion
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function selectionContainsCellRegion(rowIndex:int, columnIndex:int, 
                                                rowCount:int, columnCount:int):Boolean
    {
        if (grid)
        {
            return grid.selectionContainsCellRegion(
                rowIndex, columnIndex, rowCount, columnCount);
        }
        else
        {
            return gridSelection.containsCellRegion(
                rowIndex, columnIndex, rowCount, columnCount);
        }
    }
    
    /**
     *  @copy spark.components.Grid#setSelectedCell
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function setSelectedCell(rowIndex:int, columnIndex:int):Boolean
    {
        var selectionChanged:Boolean;
        
        if (grid)
        {
            selectionChanged = grid.setSelectedCell(rowIndex, columnIndex);
        }
        else
        {
            selectionChanged = gridSelection.setCell(rowIndex, columnIndex);
            if (selectionChanged)
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
        }
        
        return selectionChanged;
    }
    
    /**
     *  @copy spark.components.Grid#addSelectedCell
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function addSelectedCell(rowIndex:int, columnIndex:int):Boolean
    {
        var selectionChanged:Boolean;
        
        if (grid)
        {
            selectionChanged = grid.addSelectedCell(rowIndex, columnIndex);
        }
        else
        {
            selectionChanged = gridSelection.addCell(rowIndex, columnIndex);
            if (selectionChanged)
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
        }
        
        return selectionChanged;
    }
    
    /**
     *  @copy spark.components.Grid#removeSelectedCell
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function removeSelectedCell(rowIndex:int, columnIndex:int):Boolean
    {
        var selectionChanged:Boolean;
        
        if (grid)
        {
            selectionChanged = grid.removeSelectedCell(rowIndex, columnIndex);
        }
        else
        {
            selectionChanged = gridSelection.removeCell(rowIndex, columnIndex);
            if (selectionChanged)
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
        }
        
        return selectionChanged;
    }
    
    /**
     *  @copy spark.components.Grid#selectCellRegion
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function selectCellRegion(rowIndex:int, columnIndex:int, 
                                     rowCount:uint, columnCount:uint):Boolean
    {
        var selectionChanged:Boolean;
        
        if (grid)
        {
            selectionChanged = grid.selectCellRegion(
                rowIndex, columnIndex, rowCount, columnCount);
        }
        else
        {
            selectionChanged = gridSelection.setCellRegion(
                rowIndex, columnIndex, rowCount, columnCount);
            if (selectionChanged)
                dispatchFlexEvent(FlexEvent.VALUE_COMMIT);
        }
        
        return selectionChanged;
    }    
    
    /**
     *  In response to user input (mouse or keyboard) which changes the 
     *  selection, this dispatches the "selectionChanging" event, and if the 
     *  event is not cancelled, commits the selection change and then 
     *  dispatches the "selectionChange" event.  The caret is not udpated here.  
     *  To detect if the caret has changed use the "caretChanged" event.
     * 
     *  @param selectionEventKind The <code>GridSelectionEventKind</code> of
     *  selection that is being committed.  If not null, this will be used to 
     *  generate the <code>selectionChanging</code> event.
     * 
     *  @param rowIndex If <code>selectionEventKind</code> is for a row or a
     *  cell, the 0-based rowIndex of the selection in the 
     *  <code>dataProvider</code>. If <code>selectionEventKind</code> is 
     *  for multiple cells, the 0-based rowIndex of the origin of the
     *  cell region. The default is -1 to indicate this
     *  parameter is not being used.
     * 
     *  @param columnIndex If <code>selectionEventKind</code> is for a single row or 
     *  a single cell, the 0-based columnIndex of the selection in 
     *  <code>columns</code>. If <code>selectionEventKind</code> is for multiple 
     *  cells, the 0-based columnIndex of the origin of the
     *  cell region. The default is -1 to indicate this
     *  parameter is not being used.
     * 
     *  @param rowCount If <code>selectionEventKind</code> is for a cell region, 
     *  the number of rows in the cell region.  The default is -1 to indicate
     *  this parameter is not being used.
     * 
     *  @param columnCount If <code>selectionEventKind</code> is for a cell region, 
     *  the number  of columns in the cell region.  The default is -1 to 
     *  indicate this parameter is not being used.
     * 
     *  @param indices If <code>selectionEventKind</code> is for multiple rows,
     *  the 0-based row indicies of the rows in the selection.  The default is 
     *  null to indicate this parameter is not being used.
     * 
     *  @return True if the selection was committed, or false if the selection
     *  was cancelled or could not be committed due to an error, such as
     *  index out of range or the <code>selectionEventKind</code> is not compatible 
     *  s the <code>selectionMode</code>.
     * 
     *  @see spark.events.GridSelectionEvent#SELECTION_CHANGE
     *  @see spark.events.GridSelectionEvent#SELECTION_CHANGING
     *  @see spark.events.GridSelectionEventKind
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    protected function commitInteractiveSelection(
        selectionEventKind:String,                                         
        rowIndex:int,
        columnIndex:int, 
        rowCount:int = 1, 
        columnCount:int = 1):Boolean
        
    {
        if (!grid)
            return false;
        
        // Assumes selectionEventKind is valid for given selectionMode.  Assumes
        // indices are within range.
        
        var selectionChange:CellRegion = 
            new CellRegion(rowIndex, columnIndex, rowCount, columnCount);
        
        // Step 1: determine if the selection will change if the operation.
        // is committed.  
        if (!doesChangeCurrentSelection(selectionEventKind, selectionChange))
            return false;
        
        // Step 1: dispatch the "changing" event. If preventDefault() is called
        // on this event, the selection change will be cancelled.        
        if (hasEventListener(GridSelectionEvent.SELECTION_CHANGING))
        {
            const changingEvent:GridSelectionEvent = 
                new GridSelectionEvent(GridSelectionEvent.SELECTION_CHANGING, 
                    false, true, 
                    selectionEventKind, selectionChange); 
            
            // The event was cancelled so don't change the selection.
            if (!dispatchEvent(changingEvent))
                return false;
        }
        
        // Step 2: commit the selection change.  Call the gridSelection
        // methods directly so that the caret position is not altered and 
        // a VALUE_COMMIT event is not dispatched.
        
        var changed:Boolean;
        switch (selectionEventKind)
        {
            case GridSelectionEventKind.SET_ROW:
            {
                changed = grid.gridSelection.setRow(rowIndex);
                break;
            }
            case GridSelectionEventKind.ADD_ROW:
            {
                changed = grid.gridSelection.addRow(rowIndex);
                break;
            }
                
            case GridSelectionEventKind.REMOVE_ROW:
            {
                changed = grid.gridSelection.removeRow(rowIndex);
                break;
            }
                
            case GridSelectionEventKind.SET_ROWS:
            {
                changed = grid.gridSelection.setRows(rowIndex, rowCount);
                break;
            }
                
            case GridSelectionEventKind.SET_CELL:
            {
                changed = grid.gridSelection.setCell(rowIndex, columnIndex);
                break;
            }
                
            case GridSelectionEventKind.ADD_CELL:
            {
                changed = grid.gridSelection.addCell(rowIndex, columnIndex);
                break;
            }
                
            case GridSelectionEventKind.REMOVE_CELL:
            {
                changed = grid.gridSelection.removeCell(rowIndex, columnIndex);
                break;
            }
                
            case GridSelectionEventKind.SET_CELL_REGION:
            {
                changed = grid.gridSelection.setCellRegion(
                    rowIndex, columnIndex, 
                    rowCount, columnCount);
                break;
            }
                
            case GridSelectionEventKind.SELECT_ALL:
            {
                changed = grid.gridSelection.selectAll();
                break;
            }
        }
        
        // Selection change failed for some unforseen reason.
        if (!changed)
            return false;
        
        grid.invalidateDisplayList();
        
        // Step 3: dispatch the "change" event.
        if (hasEventListener(GridSelectionEvent.SELECTION_CHANGE))
        {
            const changeEvent:GridSelectionEvent = 
                new GridSelectionEvent(GridSelectionEvent.SELECTION_CHANGE, 
                    false, true, 
                    selectionEventKind, selectionChange); 
            dispatchEvent(changeEvent);
            // FIXME - to trigger bindings on grid selectedCell/Index/Item properties
            if (grid.hasEventListener(GridSelectionEvent.SELECTION_CHANGE))
                grid.dispatchEvent(changeEvent);
        }
        
        return true;
    }
    
    /**
     *  Updates the grid's caret position.  If the caret position changes
     *  a GridCaretEvent.CARET_CHANGE event will be dispatched by grid.
     *
     *  @param newCaretRowIndex The 0-based rowIndex of the new caret position.
     * 
     *  @param newCaretColumnIndex The 0-based columnIndex of the new caret 
     *  position.  If the selectionMode is row-based, this is -1.
     * 
     *  @see spark.events.GridCaretEvent#CARET_CHANGE
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    protected function commitCaretPosition(newCaretRowIndex:int, 
                                           newCaretColumnIndex:int):void
    {
        grid.caretRowIndex = newCaretRowIndex;
        grid.caretColumnIndex = newCaretColumnIndex;
    }
    
    //--------------------------------------------------------------------------
    //
    //  IGridItemRendererOwner Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    public function prepareItemRenderer(renderer:IGridItemRenderer, willBeRecycled:Boolean):void
    {            
        renderer.owner = this;
    }
    
    /**
     *  @private
     */
    public function discardItemRenderer(renderer:IGridItemRenderer, hasBeenRecycled:Boolean):void
    {
    }
    
    //--------------------------------------------------------------------------
    //
    //  Selection Utility Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    protected function selectionContainsOnlyIndex(index:int):Boolean 
    {
        if (grid)
            return grid.selectionContainsIndex(index) && grid.selectionLength == 1;
        else
            return gridSelection.containsRow(index) && gridSelection.selectionLength == 1;
    }
        
    /**
     *  @private
     *  Return true, if the current selection, only contains the rows in
     *  the selection change.
     */
    protected function selectionContainsOnlyIndices(selectionChange:CellRegion):Boolean 
    {
        var selectionLength:int = 
            grid ? grid.selectionLength : gridSelection.selectionLength;
        
        if (selectionChange.rowCount != selectionLength)
            return false;
        
        const bottom:int = 
            selectionChange.rowIndex + selectionChange.rowCount;
        
        for (var rowIndex:int = selectionChange.rowIndex; 
             rowIndex < bottom; 
             rowIndex++)
        {
            if (grid)
            {
                if (!grid.selectionContainsIndex(rowIndex)) 
                    return false;
            }
            else
            {
                if (!gridSelection.containsRow(rowIndex))
                    return false;
            }
        }
             
        return true;        
    }
    
    /**
     *  @private
     */
    private function selectionContainsOnlyCell(rowIndex:int, columnIndex:int):Boolean
    {
        if (grid)
            return grid.selectionContainsCell(rowIndex, columnIndex) && grid.selectionLength == 1;
        else
            return gridSelection.containsCell(rowIndex, columnIndex) && gridSelection.selectionLength == 1;
    }
    
    /**
     *  @private
     */
    private function selectionContainsOnlyCellRegion(rowIndex:int, 
                                                     columnIndex:int, 
                                                     rowCount:int, 
                                                     columnCount:int):Boolean
    {
        if (grid)
        {
            return grid.selectionContainsCellRegion(
                rowIndex, columnIndex, rowCount, columnCount) &&
                grid.selectionLength == rowCount * columnCount;
        }
        else
        {
            return gridSelection.containsCellRegion(
                rowIndex, columnIndex, rowCount, columnCount) &&
                gridSelection.selectionLength == rowCount * columnCount;
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Item Editor Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Starts an editor session on a selected cell in the data grid.
     * 
     *  A <code>startItemEditorSession</code> event is dispatched before
     *  an item editor is created. This allows a listener dynamically change 
     *  the item editor for a specified cell. 
     * 
     *  The event can also be cancelled with preventDefault(), to prevent the 
     *  editor session from being created.
     * 
     *  @param rowIndex The zero-based row index of the cell to edit.
     *  @param columnIndex The zero-based column index of the cell to edit.  
     * 
     *  @return true if the editor session was started. Returns false if
     *  the editor session was cancelled.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     *  
     */ 
    public function startItemEditorSession(rowIndex:int, columnIndex:int):Boolean
    {
        if (editor)
            return editor.startItemEditorSession(rowIndex, columnIndex);
        
        return false;
    }
    
    /**
     *  Closes the currently active editor and optionally saves the editor's value
     *  by calling the item editor's save() method.  If the cancel parameter is true,
     *  then the editor's cancel() method is called instead.
     * 
     *  @param cancel If false the data in the editor is saved. 
     *  Otherwise the data in the editor is discarded.
     *
     *  @return true if the editor session was saved, false if the save was
     *  cancelled.  
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */ 
    public function endItemEditorSession(cancel:Boolean = false):Boolean
    {
        if (editor)
            return editor.endItemEditorSession(cancel);
        
        return false;
    }
    
    /**
     *  Create the data grid editor. Overriding this function will
     *  allow the complete replacement of the data grid editor.
     */ 
    mx_internal function createEditor():DataGridEditor
    {
        return new DataGridEditor(this);    
    }
    
    //--------------------------------------------------------------------------
    //
    //  Sorting Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Sort the DataGrid by one or more columns and refresh the display.
     * 
     *  If the dataProvider is an ICollectionView, then it's sort property will be
     *  set to a value based on each column's dataField, sortCompareFunction,
     *  and sortDescending flag, and then the dataProvider's refresh() method will be called.
     * 
     *  If the dataProvider is not an ICollectionView, then this method has no effect.
     * 
     *  @param columnIndices The indices of the columns by which to sort the dataProvider.
     * 
     *  @return true if the dataProvider can be sorted with the provided column indices.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function sortByColumns(columnIndices:Vector.<int>):Boolean
    {
        const dataProvider:ICollectionView = this.dataProvider as ICollectionView;
        if (!dataProvider)
            return false;
        
        var sort:Sort = dataProvider.sort;
        if (sort)
            sort.compareFunction = null;
        else
            sort = new Sort();
        
        var sortFields:Array = createSortFields(columnIndices, sort.fields);
        if (!sortFields)
            return false;
        
        sort.fields = sortFields;
        
        dataProvider.sort = sort;
        dataProvider.refresh();
        return true;
    }

    /**
     *  @private
     *  This function builds an array of SortFields based on the column
     *  indices given. The direction is based on the current value of
     *  sortDescending from the column.
     */
    private function createSortFields(columnIndices:Vector.<int>, previousFields:Array):Array
    {
        if (columnIndices.length == 0)
            return null;
        
        var fields:Array = new Array();
        
        for each (var columnIndex:int in columnIndices)
        {
            var col:GridColumn = this.getColumnAt(columnIndex);
            
            // columns all must either have a dataField or a labelFunction
            if (!col || (col.dataField == null && col.labelFunction == null))
                return null;
            
            var sortField:SortField = null;
            var sortDescending:Boolean = col.sortDescending;
            var i:int;
            
            // Check if we just sorted this column.
            for (i = 0; i < fields.length; i++)
            {
                if (fields[i].name == col.dataField)
                {
                    // just sorted this column, so flip sortDescending.
                    sortDescending = !fields[i].descending;
                }
            }
            
            // If we haven't sorted by this column yet, check if
            // we've sorted by this column in the previous sort.
            if (!sortField && previousFields)
            {
                for (i = 0; i < previousFields.length; i++)
                {
                    if (previousFields[i].name == col.dataField)
                    {
                        // sortField exists in previous sort, so flip sortDescending.
                        sortField = previousFields[i];
                        sortDescending = !sortField.descending;
                        break;
                    }
                }
            }
            
            // Create a SortField from the column.
            if (!sortField)
                sortField = col.sortField;
            
            col.sortDescending = sortDescending;
            sortField.descending = sortDescending;
            
            fields.push(sortField);
        }
        
        return fields;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @return True if there is an anchor position set.
     */    
    private function isAnchorSet():Boolean
    {
        if (!grid)
            return false;
        
        if (isRowSelectionMode())
            return grid.anchorRowIndex != -1;
        else
            return grid.anchorRowIndex != -1 && grid.anchorRowIndex != -1;
    }
    
    /**
     *  @private
     *  Toggle the selection and set the caret to rowIndex/columnIndex.
     * 
     *  @return True if the selection has changed.
     */
    private function toggleSelection(rowIndex:int, columnIndex:int):Boolean
    {
        var kind:String;
        
        if (isRowSelectionMode())
        { 
            if (grid.selectionContainsIndex(rowIndex))
                kind = GridSelectionEventKind.REMOVE_ROW;
            else if (selectionMode == GridSelectionMode.MULTIPLE_ROWS)
                kind = GridSelectionEventKind.ADD_ROW;
            else
                kind = GridSelectionEventKind.SET_ROW;
            
        }
        else if (isCellSelectionMode())
        {
            if (grid.selectionContainsCell(rowIndex, columnIndex))
                kind = GridSelectionEventKind.REMOVE_CELL;
            else if (selectionMode == GridSelectionMode.MULTIPLE_CELLS)
                kind = GridSelectionEventKind.ADD_CELL;
            else
                kind = GridSelectionEventKind.SET_CELL;
        }
        
        var changed:Boolean = 
            commitInteractiveSelection(kind, rowIndex, columnIndex);
        
        // Update the caret even if the selection did not change.
        commitCaretPosition(rowIndex, columnIndex);
        
        return changed;
    }
    
    /**
     *  @private
     *  Extends the selection from the anchor position to the given 'caret'
     *  position and updates the caret position.
     */
    private function extendSelection(caretRowIndex:int, 
                                     caretColumnIndex:int):Boolean
    {
        if (!isAnchorSet())
            return false;
                    
        const startRowIndex:int = Math.min(grid.anchorRowIndex, caretRowIndex);
        const endRowIndex:int = Math.max(grid.anchorRowIndex, caretRowIndex);
        var changed:Boolean;
        
        if (selectionMode == GridSelectionMode.MULTIPLE_ROWS)
        {
            changed = commitInteractiveSelection(
                GridSelectionEventKind.SET_ROWS,
                startRowIndex, -1,
                endRowIndex - startRowIndex + 1, 0);
        }
        else if (selectionMode == GridSelectionMode.SINGLE_ROW)
        {
            // Can't extend the selection so move it to the caret position.
            changed = commitInteractiveSelection(
                GridSelectionEventKind.SET_ROW, caretRowIndex, -1, 1, 0);                
        }
        else if (selectionMode == GridSelectionMode.MULTIPLE_CELLS)
        {
            const rowCount:int = endRowIndex - startRowIndex + 1;
            const startColumnIndex:int = 
                Math.min(grid.anchorColumnIndex, caretColumnIndex);
            const endColumnIndex:int = 
                Math.max(grid.anchorColumnIndex, caretColumnIndex); 
            const columnCount:int = endColumnIndex - startColumnIndex + 1;
            
            changed = commitInteractiveSelection(
                GridSelectionEventKind.SET_CELL_REGION, 
                startRowIndex, startColumnIndex,
                rowCount, columnCount);
        }            
        else if (selectionMode == GridSelectionMode.SINGLE_CELL)
        {
            // Can't extend the selection so move it to the caret position.
            changed = commitInteractiveSelection(
                GridSelectionEventKind.SET_CELL, 
                caretRowIndex, caretColumnIndex, 1, 1);                
        }
        
        // Update the caret.
        commitCaretPosition(caretRowIndex, caretColumnIndex);
        
        return changed;
    }
    
    /**
     *  @private
     *  Sets the selection and updates the caret and anchor positions.
     */
    private function setSelectionAnchorCaret(rowIndex:int, columnIndex:int):Boolean
    {
        // click sets the selection and updates the caret and anchor 
        // positions.
        var changed:Boolean;
        if (isRowSelectionMode())
        {
            // Select the row.
            changed = commitInteractiveSelection(
                GridSelectionEventKind.SET_ROW, 
                rowIndex, columnIndex);
        }
        else if (isCellSelectionMode())
        {
            // Select the cell.
            changed = commitInteractiveSelection(
                GridSelectionEventKind.SET_CELL, 
                rowIndex, columnIndex);
        }
        
        // Update the caret and anchor positions even if the selection did not
        // change.
        commitCaretPosition(rowIndex, columnIndex);
        grid.anchorRowIndex = rowIndex;
        grid.anchorColumnIndex = columnIndex; 
        
        return changed;
    }
    
    /**
     *  @private
     *  Returns the new caret position based on the current caret position and 
     *  the navigationUnit as a Point, where x is the columnIndex and y is the 
     *  rowIndex.  Assures there is a valid caretPosition.
     */
    private function setCaretToNavigationDestination(navigationUnit:uint):CellPosition
    {
        var caretRowIndex:int = grid.caretRowIndex;
        var caretColumnIndex:int = grid.caretColumnIndex;
        
        const inRows:Boolean = isRowSelectionMode();
        
        const rowCount:int = getDataProviderLength();
        const columnCount:int = getColumnsLength();
        var visibleRows:Vector.<int>;
        var caretRowBounds:Rectangle;
        
        switch (navigationUnit)
        {
            case NavigationUnit.LEFT: 
            {
                if (isCellSelectionMode())
                {
                    if (grid.caretColumnIndex > 0)
                        caretColumnIndex = grid.getPreviousVisibleColumnIndex(caretColumnIndex);
                }
                break;
            }
                
            case NavigationUnit.RIGHT:
            {
                if (isCellSelectionMode())
                {
                    if (grid.caretColumnIndex + 1 < columnCount)
                        caretColumnIndex = grid.getNextVisibleColumnIndex(caretColumnIndex);
                }
                break;
            } 
                
            case NavigationUnit.UP:
            {
                if (grid.caretRowIndex > 0)
                    caretRowIndex--;
                break; 
            }
                
            case NavigationUnit.DOWN:
            {
                if (grid.caretRowIndex + 1 < rowCount)
                    caretRowIndex++;
                break; 
            }
                
            case NavigationUnit.PAGE_UP:
            {
                // Page up to first fully visible row on the page.  If there is
                // a partially visible row at the top of the page, the next
                // page up should include it in its entirety.
                visibleRows = grid.getVisibleRowIndices();
                if (visibleRows.length == 0)
                    break;
                
                // This row might be only partially visible.
                var firstVisibleRowIndex:int = visibleRows[0];                
                var firstVisibleRowBounds:Rectangle =
                    grid.getRowBounds(firstVisibleRowIndex);
                
                // Set to the first fully visible row.
                if (firstVisibleRowIndex < rowCount - 1 && 
                    firstVisibleRowBounds.top < grid.scrollRect.top)
                {
                    firstVisibleRowIndex = visibleRows[1];
                }
                
                if (caretRowIndex > firstVisibleRowIndex)
                {
                    caretRowIndex = firstVisibleRowIndex;
                }
                else
                {     
                    // If the caret is above the visible rows or the
                    // first visible row, scroll so that caret row is the last 
                    // visible row.
                    caretRowBounds = grid.getRowBounds(caretRowIndex);
                    const delta:Number = 
                        grid.scrollRect.bottom - caretRowBounds.bottom;
                    grid.verticalScrollPosition -= delta;
                    validateNow();
                    
                    // Visible rows have been updated so figure out which one
                    // is now the first fully visible row.
                    visibleRows = grid.getVisibleRowIndices();
                    firstVisibleRowIndex = visibleRows[0];
                    if (visibleRows.length > 0)
                    {
                        firstVisibleRowBounds = grid.getRowBounds(firstVisibleRowIndex);
                        if (firstVisibleRowIndex < rowCount - 1 && 
                            grid.scrollRect.top > firstVisibleRowBounds.top)
                        {
                            firstVisibleRowIndex = visibleRows[1];
                        }
                        caretRowIndex = firstVisibleRowIndex;
                    }
                }
                break; 
            }
            case NavigationUnit.PAGE_DOWN:
            {
                // Page down to last fully visible row on the page.  If there is
                // a partially visible row at the bottom of the page, the next
                // page down should include it in its entirety.
                visibleRows = grid.getVisibleRowIndices();
                if (visibleRows.length == 0)
                    break;
                
                // This row might be only partially visible.
                var lastVisibleRowIndex:int = 
                    visibleRows[visibleRows.length - 1];                
                var lastVisibleRowBounds:Rectangle =
                    grid.getRowBounds(lastVisibleRowIndex);
                
                // If there is more than one visible row, set to the last
                // fully visible row.
                if (lastVisibleRowIndex > 0 && 
                    grid.scrollRect.bottom < lastVisibleRowBounds.bottom)
                {
                    lastVisibleRowIndex = visibleRows[visibleRows.length - 2];
                }
                
                if (caretRowIndex < lastVisibleRowIndex)
                {
                    caretRowIndex = lastVisibleRowIndex;
                }
                else
                {                        
                    // Caret is last visible row or it is after the visible rows.
                    // Scroll, so the caret row is the first visible row.
                    caretRowBounds = grid.getRowBounds(caretRowIndex);
                    grid.verticalScrollPosition = caretRowBounds.y;
                    validateNow();
                    
                    // Visible rows have been updated so figure out which one
                    // is now the last fully visible row.
                    visibleRows = grid.getVisibleRowIndices();
                    lastVisibleRowIndex = visibleRows[visibleRows.length - 1];
                    if (visibleRows.length >= 0)
                    {
                        lastVisibleRowBounds = grid.getRowBounds(lastVisibleRowIndex);
                        if (lastVisibleRowIndex > 0 && 
                            grid.scrollRect.bottom < lastVisibleRowBounds.bottom)
                        {
                            lastVisibleRowIndex = visibleRows[visibleRows.length - 2];
                        }
                        caretRowIndex = lastVisibleRowIndex;
                    }
                }
                break; 
            }
                
            case NavigationUnit.HOME:
            {
                caretRowIndex = 0;
                caretColumnIndex = isCellSelectionMode() ? grid.getNextVisibleColumnIndex(-1) : -1; 
                break;
            }
                
            case NavigationUnit.END:
            {
                caretRowIndex = rowCount - 1;
                caretColumnIndex = isCellSelectionMode() ? grid.getPreviousVisibleColumnIndex(columnCount) : -1;
                
                // The heights of any rows that have not been rendered yet are
                // estimated.  Force them to draw so the heights are accurate.
                // TBD: is there a better way to do this?
                grid.verticalScrollPosition = grid.contentHeight;
                validateNow();
                if (grid.contentHeight != grid.verticalScrollPosition)
                {
                    grid.verticalScrollPosition = grid.contentHeight;
                    validateNow();
                }
                break;
            }
                
            default: 
            {
                return null;
            }
        }
        
        return new CellPosition(caretRowIndex, caretColumnIndex);
    }
    
    /**
     *  @copy spark.components.gridClasses.Grid#ensureCellIsVisible
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function ensureCellIsVisible(rowIndex:int, columnIndex:int = -1):void
    {
        if (grid)
            grid.ensureCellIsVisible(rowIndex, columnIndex);
    }
    
    /**
     *  @private
     * 
     *  Adjusts the caret and the selection based on what keystroke is used
     *  in combination with a ctrl/cmd key or a shift key.  Returns false
     *  if the selection was not changed.
     */
    protected function adjustSelectionUponNavigation(event:KeyboardEvent):Boolean
    {
        // Some unrecognized key stroke was entered, return. 
        if (!NavigationUnit.isNavigationUnit(event.keyCode))
            return false; 
        
        // If rtl layout, need to swap Keyboard.LEFT and Keyboard.RIGHT.
        var navigationUnit:uint = mapKeycodeForLayoutDirection(event);
        
        const newPosition:CellPosition = setCaretToNavigationDestination(navigationUnit);
        if (!newPosition)
            return false;
        
        // Cancel so another component doesn't handle this event.
        event.preventDefault(); 
        
        var selectionChanged:Boolean = false;
        
        if (event.shiftKey)
        {
            // The shift key-nav key combination extends the selection and 
            // updates the caret.
            selectionChanged = 
                extendSelection(newPosition.rowIndex, newPosition.columnIndex);
        }
        else if (event.ctrlKey)
        {
            // If its a ctrl/cmd key-nav key combination, there is nothing
            // more to do then set the caret.
            commitCaretPosition(newPosition.rowIndex, newPosition.columnIndex);
        }
        else
        {
            // Select the current row/cell.
            setSelectionAnchorCaret(newPosition.rowIndex, newPosition.columnIndex);
        }
        
        // Ensure this position is visible.
        ensureCellIsVisible(newPosition.rowIndex, newPosition.columnIndex);            
        
        return true;
    }
    
    /**
     *  @private
     * 
     *  Returns true if committing the given selection operation would change
     *  the current selection.
     */
    private function doesChangeCurrentSelection(
        selectionEventKind:String, 
        selectionChange:CellRegion):Boolean
    {
        var changesSelection:Boolean;
        
        const rowIndex:int = selectionChange.rowIndex;
        const columnIndex:int = selectionChange.columnIndex;
        const rowCount:int = selectionChange.rowCount;
        const columnCount:int = selectionChange.columnCount;
        
        switch (selectionEventKind)
        {
            case GridSelectionEventKind.SET_ROW:
            {
                changesSelection = 
                    !selectionContainsOnlyIndex(rowIndex);
                break;
            }
            case GridSelectionEventKind.ADD_ROW:
                
            {
                changesSelection = 
                    !grid.selectionContainsIndex(rowIndex);
                break;
            }
                
            case GridSelectionEventKind.REMOVE_ROW:
            {
                changesSelection = requireSelection ?
                    !selectionContainsOnlyIndex(rowIndex) :
                    grid.selectionContainsIndex(rowIndex);
                break;
            }
                
            case GridSelectionEventKind.SET_ROWS:
            {
                changesSelection = 
                    !selectionContainsOnlyIndices(selectionChange);
                break;
            }
                
            case GridSelectionEventKind.SET_CELL:
            {
                changesSelection = 
                    !selectionContainsOnlyCell(rowIndex, columnIndex);
                break;
            }
                
            case GridSelectionEventKind.ADD_CELL:
            {
                changesSelection = 
                    !grid.selectionContainsCell(rowIndex, columnIndex);
                break;
            }
                
            case GridSelectionEventKind.REMOVE_CELL:
            {
                changesSelection = requireSelection ?
                    !selectionContainsOnlyCell(rowIndex, columnIndex) :                  
                    grid.selectionContainsCell(rowIndex, columnIndex);
                break;
            }
                
            case GridSelectionEventKind.SET_CELL_REGION:
            {
                changesSelection = 
                    !selectionContainsOnlyCellRegion(
                        rowIndex, columnIndex, rowCount, columnCount);
                break;
            }
                
            case GridSelectionEventKind.SELECT_ALL:
            {
                changesSelection = !gridSelection.selectAllFlag;
                break;
            }
        }
        
        return changesSelection;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Grid event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Updating the hover is disabled if the mouse button was depressed
     *  while not over the grid.  The common case for this is while 
     *  scrolling.  While the scroll thumb is depressed don't want the 
     *  hover updated if the mouse drifts into the grid.
     */
    protected function grid_RollOverHandler(event:GridEvent):void
    {
        // The related object is the object that was previously under
        // the pointer.
        if (event.buttonDown && event.relatedObject != grid)
            updateHoverOnRollOver = false;
        
        grid.hoverRowIndex = updateHoverOnRollOver ? event.rowIndex : -1;
        grid.hoverColumnIndex = updateHoverOnRollOver ? event.columnIndex : -1;
    }
    
    /**
     *  @private
     *  If the mouse button is depressed while outside of the grid, the hover 
     *  indicator is not enabled again until GRID_MOUSE_UP or GRID_ROLL_OUT. 
     */
    protected function grid_RollOutHandler(event:GridEvent):void
    {
        grid.hoverRowIndex = -1;
        grid.hoverColumnIndex = -1;
        
        updateHoverOnRollOver = true;
    }
    
    /**
     *  @private
     *  If the mouse button is depressed while outside of the grid, the hover 
     *  indicator is not enabled again until GRID_MOUSE_UP or GRID_ROLL_OUT. 
     */
    protected function grid_MouseUpHandler(event:GridEvent):void
    {
        if (!updateHoverOnRollOver)
        {
            grid.hoverRowIndex = event.rowIndex;
            grid.hoverColumnIndex = event.columnIndex;
            updateHoverOnRollOver = true;
        }
    }
    
    /**
     *  @private
     */
    protected function grid_MouseDownHandler(event:GridEvent):void
    {
        const isCellSelection:Boolean = isCellSelectionMode();

        const rowIndex:int = event.rowIndex;
        const columnIndex:int = isCellSelection ? event.columnIndex : -1;
        
        // Clicked on empty place in grid.  Don't change selection or caret
        // position.
        if (rowIndex == -1 || isCellSelection && columnIndex == -1)
            return;
        
        if (event.ctrlKey)
        {
            // ctrl-click toggles the selection and updates caret and anchor.
            if (!toggleSelection(rowIndex, columnIndex))
                return;
            
            grid.anchorRowIndex = rowIndex;
            grid.anchorColumnIndex = columnIndex;
        }
        else if (event.shiftKey)
        {
            // shift-click extends the selection and updates the caret.
            if  (grid.selectionMode == GridSelectionMode.MULTIPLE_ROWS || 
                grid.selectionMode == GridSelectionMode.MULTIPLE_CELLS)
            {    
                if (!extendSelection(rowIndex, columnIndex))
                    return;
            }
        }
        else
        {
            // click sets the selection and updates the caret and anchor 
            // positions.
            setSelectionAnchorCaret(rowIndex, columnIndex);
        }
    }
    
    /**
     *  @private
     *  Redispatch the grid's "caretChange" event.
     */
    protected function grid_caretChangeHandler(event:GridCaretEvent):void
    {
        if (hasEventListener(GridCaretEvent.CARET_CHANGE))
            dispatchEvent(event);
    }
    
    /**
     *  @private
     *  Redispatch the grid's "valueCommit" event.
     */
    protected function grid_valueCommitHandler(event:FlexEvent):void
    {
        if (hasEventListener(FlexEvent.VALUE_COMMIT))
            dispatchEvent(event);
    }
    
    /**
     *  @private
     */
    private function grid_invalidateDisplayListHandler(event:Event):void
    {
        // invalidate all IDataGridElements
        if (columnHeaderGroup)
            columnHeaderGroup.invalidateDisplayList();
    }
    
    /**
     *  @private
     */
    private function grid_invalidateSizeHandler(event:Event):void
    {
        // invalidate all IDataGridElements
        if (columnHeaderGroup)
            columnHeaderGroup.invalidateSize();
    }     
    
    //--------------------------------------------------------------------------
    //
    //  Header event handlers
    //
    //--------------------------------------------------------------------------  
    
    private var stretchCursorID:int = CursorManager.NO_CURSOR;
    private var resizeColumn:GridColumn = null;
    private var resizeAnchorX:Number = NaN;
    private var resizeColumnWidth:Number = NaN;
    
    /**
     *  @private
     */
    protected function columnHeaderGroup_clickHandler(event:GridEvent):void
    {
        const column:GridColumn = event.column;
        if (!enabled || !sortableColumns || !column || !column.sortable)
            return;
    
        const columnIndices:Vector.<int> = Vector.<int>([column.columnIndex]);
        
        if (sortByColumns(columnIndices))
            columnHeaderGroup.visibleSortIndicatorIndices = columnIndices;
    }
    
    /**
     *  @private
     */
    protected function separator_mouseDownHandler(event:GridEvent):void
    {
        const column:GridColumn = event.column;
        if (!enabled || !grid.resizableColumns || !column || !column.resizable)
            return;
        
        resizeColumn = event.column;
        resizeAnchorX = event.localX;
        resizeColumnWidth = grid.getColumnWidth(resizeColumn.columnIndex);
        
        // Give all of the columns to the left of this one an explicit so that resizing
        // this column doesn't change their width and, consequently, this columns location.
        
        const resizeColumnIndex:int = resizeColumn.columnIndex;
        for (var columnIndex:int = 0; columnIndex < resizeColumnIndex; columnIndex++)
        {
            var gc:GridColumn = getColumnAt(columnIndex);
            if (gc.visible && isNaN(gc.width))
                gc.width = grid.getColumnWidth(columnIndex);
        }
    }    
    
    protected function separator_mouseDragHandler(event:GridEvent):void
    {
        if (!resizeColumn)
            return;
        
        const minWidth:Number = resizeColumn.minWidth;
        const maxWidth:Number = resizeColumn.maxWidth;
        var newWidth:Number = resizeColumnWidth + (event.localX - resizeAnchorX);
        
        if (!isNaN(minWidth))
            newWidth = Math.max(newWidth, minWidth);
        else 
            newWidth = Math.max(0, newWidth);
        
        if (!isNaN(maxWidth))
            newWidth = Math.min(newWidth, maxWidth);
        
        resizeColumn.width = newWidth;
    } 
    
    protected function separator_mouseUpHandler(event:GridEvent):void
    {
        if (!resizeColumn)
            return;
        
        resizeColumn = null;
    }     
    
    /**
     *  @private
     */
    protected function separator_rollOverHandler(event:GridEvent):void
    {
        const column:GridColumn = event.column;
        if (!enabled || !grid.resizableColumns || !column || !column.resizable)
            return;
        
        var stretchCursorClass:Class = getStyle("stretchCursor") as Class;
        if (stretchCursorClass)
            stretchCursorID = cursorManager.setCursor(stretchCursorClass, CursorManagerPriority.HIGH, 0, 0);
    }
    
    /**
     *  @private
     */
    protected function separator_rollOutHandler(event:GridEvent):void
    {
        if (!enabled)
            return;
        
        cursorManager.removeCursor(stretchCursorID);
    }     
    
    //--------------------------------------------------------------------------
    //
    //  DataGrid event handlers
    //
    //--------------------------------------------------------------------------  
    
    /**
     *  @private
     *  The UIComponent's focusInHandler and focusOutHandler draw the
     *  focus.  This handler exists only when there is a caretIndicator part.
     */
    protected function dataGrid_focusHandler(event:FocusEvent):void
    {
        if (!grid || !(grid.layout is GridLayout))
            return;

        if (isOurFocus(DisplayObject(event.target)))
        {
            GridLayout(grid.layout).showCaret = 
                event.type == FocusEvent.FOCUS_IN &&
                selectionMode != GridSelectionMode.NONE;
        }
    }
    
}
}
