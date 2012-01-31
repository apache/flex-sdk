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

package spark.accessibility
{

import flash.accessibility.Accessibility;
import flash.events.Event;
import flash.events.FocusEvent;
import mx.accessibility.AccConst;
import mx.collections.IList;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.resources.ResourceManager;
import mx.resources.IResourceManager;
import spark.components.DataGrid;
import spark.components.Grid;
import spark.components.gridClasses.GridSelectionMode;
import spark.components.gridClasses.CellPosition;
import spark.events.GridEvent;
import spark.events.GridCaretEvent;
import spark.events.GridSelectionEvent;
import spark.events.GridSelectionEventKind;
import spark.events.GridItemEditorEvent;
import spark.skins.spark.DefaultGridItemRenderer;

use namespace mx_internal;

/**
 *  This is the accessibility implementation class for
 *  spark.components.DataGrid.
 *
 *  <p>When a Spark DataGrid is created, its <code>focusOwner</code> child
 *  object's <code>accessibilityImplementation</code> property is set to an
 *  instance of this class. The accessibility implementation is placed on
 *  this placeholder <code>focusOwner</code> object so that the DataGrid's
 *  accessibility implementation does not obscure the item editor's
 *  accessibility implementation.  The DataGrid component itself does not
 *  have an accessibility implementation.  This step is required as the
 *  current version of the Flash Player does not support multiple levels of
 *  MSAA objects.  Item editors can be any component and need to be full MSAA
 *  objects.  The item editor objects appear as sibling objects to the
 *  DataGrid in the MSAA tree structure.  The accessibility implementation
 *  for each item editor is thus handled by the accessibility implementation
 *  associated with that component, such as <code>CheckBoxAccImpl</code> for
 *  a CheckBox.  The item editor's accessibility implementation only exists
 *  when there is an item editor session, and there can only be one item
 *  editor active at one time; thus, there is one or zero instances of the
 *  item editor accessibility implementation active at any time.</p>
 *
 *  <p>Two methods are overwritten in the <code>DataGrid</code> class to
 *  properly handle focus among <code>DataGrid</code> and the
 *  <code>focusOwner</code> child of <code>DataGrid</code>.  The
 *  <code>GridItemRenderer</code> class turns accessibility off for item
 *  renderers, as by default these will be handled as simple objects under
 *  the DataGrid accessibility implementation.  While this limits how
 *  non-item editor components such as CheckBox, Panel, etc. can be used in
 *  DataGrids, it prevents these items from showing up as siblings to the
 *  DataGrid in the MSAA tree.  Allowing all grid item renderers to show up
 *  as siblings to the DataGrid in the MSAA tree would be very confusing to
 *  users of screen readers as there would be no context or relationship.
 *  Developers can of course override this default behavior if desired to
 *  display these renderers with accessibility enabled.</p>
 *
 *  <p>The Flash Player then uses this class to allow MSAA clients such as
 *  screen readers to see and manipulate the DataGrid. See the
 *  mx.accessibility.AccImpl and
 *  flash.accessibility.AccessibilityImplementation classes for background
 *  information about accessibility implementation classes and MSAA.</p>
 *
 *  <p>The <code>DataGridAccImpl</code> extends the
 *  <code>ListBaseAccImpl</code> (as the <code>DataGrid</code> extends the
 *  <code>DataGridBase</code> which extends the <code>ListBase</code> class).
 *  The Spark <code>DataGridAccImpl</code> is most similar to the MX
 *  <code>AdvancedDataGridAccImpl</code> as the AdvancedDataGrid also
 *  supports single cell and row selection which the MX DataGrid did not.</p>
 *
 *  <p><b>Children</b></p>
 *
 *  <p>The MSAA children of a DataGrid are, in this order</p>
 *  <ul>
 *  <li>One child for each visible header cell, starting from the left.
 *  "Visible" here means not hidden by the developer
 *  (<code>column.visible=false</code>).  The header for a column that is not
 *  marked invisible by the developer but which is scrolled off screen is
 *  considered "visible" here.</li>
 *  <li>In row selection mode, one child for each data row in the grid; OR</li>
 *  <li>In cell selection mode, one child for each cell in the grid,
 *  excluding cells in invisible (as just described) columns.</li>
 *  </ul>
 *
 *  <p>The number of children depends on the number of rows and columns in
 *  the <code>dataProvider</code>, not on the number of items currently
 *  displayed on screen.</p>
 *
 *  <p>Note that, unlike for <code>ListBase</code>, DataGrid child count does
 *  not reflect the number of data rows in the control.  Assistive technology
 *  should therefore avoid using <code>AccChildCount</code> as a means of
 *  reporting row count.</p>
 *
 *  <p>This property is not handled by the DataGrid accessibility
 *  implementation for item editors as item editors manage themselves.</p>
 *
 *  <p><b>Role</b></p>
 *
 *  <p>The MSAA Role of a DataGrid is <code>ROLE_SYSTEM_LIST</code>.</p>
 *
 *  <p>The Role of each data row or cell in the DataGrid is
 *  <code>ROLE_SYSTEM_LISTITEM</code>.</p>
 *
 *  <p>The Role of each header cell in the DataGrid is
 *  <code>ROLE_SYSTEM_COLUMNHEADER</code>.</p>
 *
 *  <p>This property is not handled by the DataGrid accessibility
 *  implementation for item editors as item editors manage themselves.</p>
 *
 *  <p><b>Name</b></p>
 *
 *  <p>The MSAA Name of a DataGrid is, by default, an empty string. When
 *  wrapped in a <code>FormItem</code> element, the Name is the FormItem's
 *  label. To override this behavior, set the DataGrids's
 *  <code>accessibilityName</code> property.  Setting the
 *  <code>accessibilityName</code> property will also apply the accessible
 *  name to the <code>focusOwner</code> child object of the DataGrid which
 *  represents the DataGrid.</p>
 *
 *  <p>The Name of each data row (when in row selection mode) is a string of
 *  the form "_column1Name_: _column1Value_, _column2Name_: _column2Value_,
 *  ..., _columnNName_: _columnNValue_, Row _m_ of _n_."  Columns are
 *  separated from each other by commas, and column names and values are
 *  separated from each other by colons.  Columns hidden by the developer are
 *  omitted entirely from the Name string.  Example Name string: "Contact
 *  Name: Doug, Contact Phone: 555-1212, Contact Zip: 12345, row 3 of 7."</p>
 *  <p>Note that "Row _m_ of _n_" is localized.</p>
 *
 *  <p>The Name of each data cell in column 1 (when in cell selection mode)
 *  is a string of the form "_columnName_: _columnValue_, Row _m_ of _n_."
 *  Example:  "Contact Phone: 555-1212, Row 2 of 5."  Subsequent columns use
 *  the same format but omit the "Row _m_ of _n_" portion.</p>
 *  <p>Note that "Row _m_ of _n_" is localized.</p>
 *
 *  <p>The Name string for a column header (in cell or row selection mode) is
 *  normally the text of the header.  Example:  "Contact Phone."  If the grid
 *  is sorted by the corresponding column however, the string "sorted" or
 *  "sorted descending" is appended to the column name, to indicate the sort
 *  and its direction.  Example:  "Contact Name sorted."  For a multicolumn
 *  sort, level strings are also appended indicating each column's level in
 *  the set of sorting columns.  For example, if a grid is sorted first by
 *  column 3 and then by column 2, and column 2 is sorted in descending
 *  order, column 3's name will end with "Sorted Level 1," and column 2's
 *  name will end with "Sorted descending level 2."  The strings for
 *  indicating ascending sort, descending sort, and sort level are
 *  localized.</p>
 *
 *  <p>When the Name of the DataGrid or one of its items changes, a DataGrid
 *  dispatches the MSAA event <code>EVENT_OBJECT_NAMECHANGE</code> with the
 *  proper childID for a row or cell or 0 for itself.</p>
 *
 *  <p>If an accessibility name is not set for an item editor, one is set
 *  based on the column header name for the cell.</p>
 *
 *  <p><b>Description</b></p>
 *
 *  <p>The MSAA Description of a DataGrid is, by default, an empty string,
 *  but you can set the DataGrid's <code>accessibilityDescription</code>
 *  property.</p>
 *
 *  <p>The Description of each row, cell, or header is the empty string and
 *  can not be set by an AccImpl.</p>
 *
 *  <p>This property is not handled by the DataGrid accessibility
 *  implementation for item editors as item editors manage themselves.</p>
 *
 *  <p><b>State</b></p>
 *
 *  <p>The MSAA State of a DataGrid is a combination of:</p>
 *  <ul>
 *  <li><code>STATE_SYSTEM_UNAVAILABLE</code> (when <code>enabled</code> is
 *  <code>false</code>)</li>
 *  <li><code>STATE_SYSTEM_FOCUSABLE</code> (when <code>enabled</code> is
 *  <code>true</code>)</li>
 *  <li><code>STATE_SYSTEM_FOCUSED</code> (when <code>enabled</code> is
 *  <code>true</code> and the DataGrid has focus)</li>
 *  <li><code>STATE_SYSTEM_MULTISELECTABLE</code> (when
 *  <code>allowMultipleSelection</code> is true)</li>
 *  </ul>
 *
 *  <p>The State of a data row or cell is a combination of:</p>
 *  <ul>
 *  <li><code>STATE_SYSTEM_FOCUSABLE</code></li>
 *  <li><code>STATE_SYSTEM_FOCUSED</code> (when focused)</li>
 *  <li><code>STATE_SYSTEM_OFFSCREEN</code> (when the row or cell has
 *  scrolled offscreen)</li>
 *  <li><code>STATE_SYSTEM_SELECTABLE</code></li>
 *  <li><code>STATE_SYSTEM_SELECTED</code> (when it is selected)</li>
 *  </ul>
 *
 *  <p>The State of a header cell is <code>STATE_SYSTEM_NORMAL</code>, since
 *  header cells may not receive focus or be selected.  As currently
 *  implemented, header cells may not report
 *  <code>STATE_SYSTEM_OFFSCREEN</code> even if the grid itself is moved such
 *  that its headers are offscreen.</p>
 *
 *  <p>When the State of the DataGrid or one of its items changes, a DataGrid
 *  dispatches the MSAA event <code>EVENT_OBJECT_STATECHANGE</code> with the
 *  proper childID for the row or cell or 0 for itself.</p>
 *
 *  <p>This property is not handled by the DataGrid accessibility
 *  implementation for item editors as item editors manage themselves.</p>
 *
 *  <p><b>Value</b></p>
 *
 *  <p>DataGrids and their children (rows, cells, and headers) do not have
 *  MSAA Values.</p>
 *
 *  <p><b>Location</b></p>
 *
 *  <p>The MSAA Location of a DataGrid or a row, data cell, or header cell
 *  within it is its bounding rectangle.  The Location of an item that is
 *  currently not displayed on screen is undefined.</p>
 *
 *  <p>This property is not handled by the DataGrid accessibility
 *  implementation for item editors as item editors manage themselves.</p>
 *
 *  <p><b>Default Action</b></p>
 *
 *  <p>A DataGrid does not have an MSAA DefaultAction. The MSAA DefaultAction
 *  for a row or cell is "Double Click" and for a header cell is "Click," and
 *  the corresponding localized string will be returned when the default
 *  action string is requested.</p>
 *
 *  <p>Performing the default action on a data row or cell will cause it to
 *  be focused and selected and may cause other behavior depending on
 *  cell/row type.  Performing the default action on a header will cause the
 *  grid to be sorted by that column.  Repeated default actions on the header
 *  will toggle the sort order between ascending and descending.  At this
 *  writing, there is no way via the AccImpl to arrange for a multilevel sort
 *  on several columns at once.</p>
 *
 *  <p>This property is not handled by the DataGrid accessibility
 *  implementation for item editors as item editors manage themselves.</p>
 *
 *  <p><b>Focus</b></p>
 *
 *  <p>When there is no specific item (row or cell depending on selection
 *  mode) in focus within the grid, Focus returns 0 indicating that the grid
 *  itself has focus.  This should only happen when the grid contains no
 *  data.</p>
 *
 *  <p>When a row (row selection mode) or cell (cell selection mode) has
 *  focus, Focus returns the childID of the focused item.</p>
 *
 *  <p>When a DataGrid receives focus, it dispatches the MSAA event
 *  <code>EVENT_OBJECT_FOCUS</code>.  This event is also dispatched when
 *  focus moves among rows or cells within the grid.</p>
 *
 *  <p>A focus change event is fired on the item editor when it
 *  starts/appears.  A focus change event is fired on the DataGrid when the
 *  item editor is saved or closed.</p>
 *
 *  <p><b>Selection</b></p>
 *
 *  <p>A DataGrid allows either a single row or cell or multiple rows or
 *  cells to be selected, depending on the
 *  <code>allowMultipleSelection</code> property.  Selection returns an array
 *  of the integer childIDs of the selected items.</p>
 *
 *  <p>When an item is selected exclusively, it dispatches MSAA event
 *  <code>EVENT_OBJECT_SELECTION</code>.  When a cell (cell selection mode)
 *  or row (row selection mode) is added to the current set of selections,
 *  the dispatched event is <code>EVENT_OBJECT_SELECTIONADD</code>.
 *  Similarly, if an item (cell or row) is removed from selection, the
 *  dispatched event is <code>EVENT_OBJECT_SELECTIONREMOVE</code>.  If all
 *  selections are cleared (regardless of how many items were selected) or a
 *  select-all or select-region action is performed, the dispatched event is
 *  <code>EVENT_OBJECT_SELECTIONWITHIN</code>.  Any selection operation not
 *  matching one of those listed above will dispatch
 *  <code>EVENT_OBJECT_SELECTION</code>.</p>
 *
 *  <p>This property is not handled by the DataGrid accessibility
 *  implementation for item editors as item editors manage themselves.</p>
 *
 *  <p><b>Select</b></p>
 *
 *  <p>The <code>accSelect</code> method implements requests made via MSAA
 *  for changes in selection and/or focus within the DataGrid.  The AccImpl
 *  for the DataGrid supports the setting of focus to a DataGrid itself or to
 *  a data item or set of items (row or cell depending on selection mode)
 *  within it.  Supported actions include setting focus, exclusively
 *  selecting one item, and adding and removing an item or set of items from
 *  selection, all as defined in the Microsoft Active Accessibility
 *  specification.  At this writing, attempting to use <code>accSelect</code>
 *  to extend an already-selected multi-cell region in cell multiselection
 *  mode to include more rows and columns at once may yield different results
 *  than doing the same action with a mouse.</p>
 *
 *  <p>This property is not handled by the DataGrid accessibility
 *  implementation for item editors as item editors manage themselves.</p>
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class DataGridAccImpl extends ListBaseAccImpl
{
    include "../core/Version.as";

    // See the DataGridAccImpl constructor for why this is not initialized here.
    private static var dgAccInfo:ItemAccInfo; // = new ItemAccInfo();

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Enables accessibility in the DataGrid class.
     *
     *  <p>This method is called by application startup code
     *  that is autogenerated by the MXML compiler.
     *  Afterwards, when instances of DataGrid are initialized,
     *  their <code>accessibilityImplementation</code> property
     *  will be set to an instance of this class.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static function enableAccessibility():void
    {
        DataGrid.createAccessibilityImplementation =
            createAccessibilityImplementation;
    }

    /**
     *  @private
     *  Creates a DataGrid's AccessibilityImplementation object.
     *  This method is called from UIComponent's
     *  initializeAccessibility() method.
     */
    mx_internal static function createAccessibilityImplementation(
                                component:UIComponent):void
    {
        // attach AccImpl to placeholder focusOwner component so that item editors
        // are exposed as sibling of the dataGrid allow for correct exposure in MSAA
        // and the ability for iSimpleTextSelection interface to work as it requires 
        // that the stage focused component be the same MSAA component 
        var accImpl:DataGridAccImpl = new DataGridAccImpl(component);
        DataGrid(component).focusOwner.accessibilityImplementation = accImpl;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *
     *  @param master The UIComponent instance that this AccImpl instance
     *  is making accessible.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function DataGridAccImpl(master:UIComponent)
    {
        super(master);
        // Normally this would not be done here, but at this writing,
        // initializing dgAccInfo from its declaration line causes an RTE,
        // apparently because the AS compiler does not yet detect a forward-ref
        // problem that results in an incorrect initialization at run time.
        // [DGL, 2010-09-07]
        if (!dgAccInfo)
            dgAccInfo = new ItemAccInfo();
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden properties: AccImpl
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  eventsToHandle
    //----------------------------------

    /**
     *  @private
     *  Array of events that we should listen for from the master component.
     */
    override protected function get eventsToHandle():Array
    {
        return super.eventsToHandle.concat([GridSelectionEvent.SELECTION_CHANGE, FocusEvent.FOCUS_IN, GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_START,
        GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_SAVE, GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_CANCEL]);
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: AccessibilityImplementation
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Gets the role for the component.
     *
     *  @param childID Children of the component
     */
    override public function get_accRole(childID:uint):uint
    {
        if (childID == 0)
            // Get this out of the way quick; it's often requested by AT.
            return role;
        dgAccInfo.setup(master, childID);
        if (dgAccInfo.isInvalid || !dgAccInfo.dataGrid.columns)
            return null;

        if (dgAccInfo.isColumnHeader)
            return AccConst.ROLE_SYSTEM_COLUMNHEADER;
        else
            // Same role for all childIDs regardless of mode (row or cell).
            // Valid and invalid childIDs return this;
            // this behavior is common to most list-based controls we've seen.
            // [DGL, 2010-08-10]
            return AccConst.ROLE_SYSTEM_LISTITEM;
    }

    /**
     *  @private
     *  IAccessible method for returning the state of the GridItem.
     *  States are predefined for all the components in MSAA.
     *  Values are assigned to each state.
     *  Depending upon the GridItem being Selected, Selectable, Invisible,
     *  Offscreen, a value is returned.
     *
     *  @param childID uint
     *
     *  @return State uint
     */
    override public function get_accState(childID:uint):uint
    {
        var accState:uint = getState(childID);
        if (childID == 0
        && DataGrid(master).focusOwner == UIComponent(master).getFocus())
            accState |= AccConst.STATE_SYSTEM_FOCUSED;
        if (int(childID) <= 0)
            return accState;

        dgAccInfo.setup(master, childID);
        if (!dgAccInfo.dataGrid.columns)
            return accState;
        if (dgAccInfo.isInvalid)
            // Child ID out of bounds most likely.
            return accState;
        if (dgAccInfo.isColumnHeader)
        {
            // isColumnHeader implies columnHeaderGroup.visible is true.
            if (dgAccInfo.dataGrid.columnHeaderGroup
            && !dgAccInfo.dataGrid.columnHeaderGroup.getHeaderRendererAt(dgAccInfo.columnIndex).visible)
                accState |= AccConst.STATE_SYSTEM_OFFSCREEN;
            // There are some states we don't allow for these.
            return accState & ~(
                AccConst.STATE_SYSTEM_FOCUSABLE
                | AccConst.STATE_SYSTEM_SELECTABLE
                | AccConst.STATE_SYSTEM_FOCUSED
                | AccConst.STATE_SYSTEM_SELECTED
            );
        }

        // We now have only rows and data cells to consider.

        // Determine if this item is focused.
        if (childID == get_accFocus())
            accState |= AccConst.STATE_SYSTEM_FOCUSED;

        // Must recalculate dgAccInfo here because get_accFocus() changed it.
        dgAccInfo.setup(master, childID);

        // Anything (row or cell) is selectable unless selection is not allowed at all.
        var mode:String = dgAccInfo.dataGrid.selectionMode;
        if (mode != GridSelectionMode.NONE)
        {
            accState |= AccConst.STATE_SYSTEM_SELECTABLE;
            if (dgAccInfo.isMultiSelect)
            {
                accState |= AccConst.STATE_SYSTEM_MULTISELECTABLE;
            }
        }

        // Figure out selectedness.
        var isSelected:Boolean;
        if (dgAccInfo.isCellMode)
            isSelected = dgAccInfo.dataGrid.selectionContainsCell(
                dgAccInfo.rowIndex,
                dgAccInfo.columnIndex
            );
        else
            isSelected = dgAccInfo.dataGrid.selectionContainsIndex(
                dgAccInfo.rowIndex
            );
        if (isSelected)
            accState |= AccConst.STATE_SYSTEM_SELECTED;

        // Figure out visibility and offscreenness.
        var rowIndex:int = dgAccInfo.rowIndex;
        var columnIndex:int = dgAccInfo.columnIndex;
        if (!dgAccInfo.isCellMode)
            columnIndex = -1;
        if (!dgAccInfo.dataGrid.grid.isCellVisible(rowIndex, columnIndex))
            accState |= AccConst.STATE_SYSTEM_OFFSCREEN

        return accState;
    }

    /**
     *  @private
     *  IAccessible method for returning the Default Action.
     *
     *  @param childID uint
     *
     *  @return DefaultAction String
     */
    override public function get_accDefaultAction(childID:uint):String
    {
        if (get_accRole(childID) == AccConst.ROLE_SYSTEM_COLUMNHEADER)
            return "Click";;
        return super.get_accDefaultAction(childID);
    }

    /**
     *  @private
     *  IAccessible method for executing the Default Action.
     *
     *  @param childID uint
     */
    override public function accDoDefaultAction(childID:uint):void
    {
        dgAccInfo.setup(master, childID);
        if (!dgAccInfo.dataGrid.columns || dgAccInfo.isInvalid)
            return;

        if (dgAccInfo.isColumnHeader)
        {
            if (dgAccInfo.dataGrid.sortableColumns
            && dgAccInfo.dataGrid.columns.getItemAt(dgAccInfo.columnIndex).sortable)
            {
                // TODO: This only allows sorting by one column at a time.
                var columnIndices:Vector.<int> = Vector.<int>([dgAccInfo.columnIndex]);
                dgAccInfo.dataGrid.sortByColumns(columnIndices);
                dgAccInfo.dataGrid.columnHeaderGroup.visibleSortIndicatorIndices = columnIndices;
            }
            return;
        }

        // TODO: Allow doDefaultAction to go into edit mode if editable
        accSelect(AccConst.SELFLAG_TAKESELECTION | AccConst.SELFLAG_TAKEFOCUS, childID);
    }

    /**
     *  @private
     *  Method to return an array of childIDs.
     *
     *  @return Array
     */
    override public function getChildIDArray():Array
    {
        dgAccInfo.setup(master, 0);
        if (!dgAccInfo.dataGrid.columns)
            return null;
        return createChildIDArray(dgAccInfo.maxChildID);
    }

    /**
     *  @private
     *  IAccessible method for returning the bounding box of the GridItem.
     *
     *  @param childID uint
     *
     *  @return Location Object
     */
    override public function accLocation(childID:uint):*
    {
        dgAccInfo.setup(master, childID);
        if (!dgAccInfo.dataGrid.columns)
            return null;
        if (dgAccInfo.isInvalid)
            return null;
        return dgAccInfo.boundingRect();
    }

    /**
     *  @private
     *  IAccessible method for returning the childFocus of the DataGrid.
     *
     *  @param childID uint
     *
     *  @return focused childID.
     */
    override public function get_accFocus():uint
    {
        dgAccInfo.setup(master, 0);
        if (!dgAccInfo.dataGrid.columns || !dgAccInfo.dataGrid.dataProvider)
            return null;

        return dgAccInfo.childIDFromRowAndColumn(
            dgAccInfo.dataGrid.grid.caretRowIndex,
            dgAccInfo.dataGrid.grid.caretColumnIndex
        );
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: AccImpl
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  method for returning the name of the ListItem/DataGrid
     *  which is spoken out by the screen reader
     *  The ListItem should return the label as the name with m of n string and
     *  DataGrid should return the name specified in the AccessibilityProperties.
     *
     *  @param childID uint
     *
     *  @return Name String
     */
    override protected function getName(childID:uint):String
    {
        if (int(childID) <= 0)
            return null;
        dgAccInfo.setup(master, childID);
        if (dgAccInfo.isInvalid || !dgAccInfo.dataGrid.columns)
            return null;
        var resourceManager:IResourceManager;
        if (dgAccInfo.isColumnHeader)
        {
            var column:Object = dgAccInfo.dataGrid.columns.getItemAt(dgAccInfo.columnIndex);
            var headerName:String = column.headerText;
            var sortColumnIndices:Vector.<int> = dgAccInfo.dataGrid.columnHeaderGroup.visibleSortIndicatorIndices;
            var sortIndex:int = sortColumnIndices.indexOf(dgAccInfo.columnIndex);
            if (sortIndex < 0)
                return headerName;
            resourceManager = ResourceManager.getInstance();
            var sortString:String;
            if (column.sortDescending)
                sortString = resourceManager.getString("components", "sortedDescending");
            else
                sortString = resourceManager.getString("components", "sortedAscending");
            if (sortColumnIndices.length > 1)
                sortString += resourceManager.getString("components", "sortLevel"
                ).replace("%1", String(sortIndex+1));
            headerName = headerName +" " +sortString;
            return headerName;
        }
        if (!dgAccInfo.dataGrid.dataProvider)
            return null;

        // We now have only rows and data cells to consider.

        // String representation of row position.
        var rowString:String = makeRowString(dgAccInfo);

        // Construct the name to return.
        var name:String = "";
        var rowObject:Object = dgAccInfo.dataGrid.dataProvider.getItemAt(dgAccInfo.rowIndex);
        var columns:IList = dgAccInfo.dataGrid.columns;
        if (dgAccInfo.isCellMode)
        {
            if (dgAccInfo.headerCount > 0)
                name = columns.getItemAt(dgAccInfo.columnIndex).headerText + ": "
            name += cellName(rowObject, dgAccInfo.columnIndex);
        }
        else if (rowObject)  // row mode
        {
            var idx:int = -1;
            for (var c:int = 0; c < dgAccInfo.reachableColumnCount; c++)
            {
                if (c > 0)
                    name += ", ";
                idx = dgAccInfo.dataGrid.grid.getNextVisibleColumnIndex(idx);
                if (dgAccInfo.headerCount > 0)
                    name += columns.getItemAt(idx).headerText + ": ";
                name += columns.getItemAt(idx).itemToLabel(rowObject);
            }
        }  // cell or row mode
        if (rowString)
            name += ", " +rowString;

        return name;
    }

    /**
     *  @private
     *  IAccessible method for focusing an item or altering selection.
     * This is a full implementation based on the Microsoft Active Accessibility
     * (MSAA) specification.
     *
     * @param selFlag:uint A combination of flags indicating what to do.
     * Flags may be combined as indicated below:
     * <dl>
     * <dt><code>SELFLAG_TAKEFOCUS</code>
     * <dd>Set focus to the childID given.
     * May be combined with the below flags.
     * <dt><code>SELFLAG_TAKESELECTION</code>
     * <dd>Select the given child and unselect any other selected ones.
     * Combining this with <code>SELFLAG_TAKEFOCUS</code>
     * emulates a single mouse click.
     * <dt><code>SELFLAG_ADDSELECTION</code>
     * <dd>Add the given child to those that are selected.
     * Combining this with <code>SELFLAG_TAKEFOCUS</code>
     * emulates a mouse click on an unselected item with the <kbd>Ctrl</kbd> key down.
     * <dt><code>SELFLAG_REMOVESELECTION</code>
     * <dd>Remove the given child from those that are selected.
     * Combining this with <code>SELFLAG_TAKEFOCUS</code>
     * emulates a mouse click on a selected item with the <kbd>Ctrl</kbd> key down.
     * <dt><code>SELFLAG_ADDSELECTION | SELFLAG_EXTENDSELECTION</code>
     * <dd>Select all children from the current focus to the given child.
     * <dt><code>SELFLAG_REMOVESELECTION | SELFLAG_EXTENDSELECTION</code>
     * <dd>Unselect all children from the current focus to the given child.
     * <dt><code>SELFLAG_EXTENDSELECTION</code>
     * <dd>Duplicate the selected/unselected state of the currently focused child,
     * for all children through the given child.
     * Combining this with <code>SELFLAG_TAKEFOCUS</code>
     * emulates a mouse click with the <kbd>Shift</kbd> key down.
     * </dl>
     *  @param childID uint The ID of the child to use.
     * For extending selection or unselection, this is the endpoint,
     * and current focus is the anchor.
     */
    override public function accSelect(selFlag:uint, childID:uint):void
    {
        dgAccInfo.setup(master, childID);
        if (dgAccInfo.isColumnHeader || dgAccInfo.isInvalid)
            return;

        // TODO: Adjust for there being no apparent way to just set focus
        // without altering selection:  For now, treate SELFLAG_TAKEFOCUS like
        // SELFLAG_TAKESELECTION, and remove the TAKEFOCUS bit from
        // all other requests, thus letting other selection calls also
        // handle focus changes.
        // Code for handling focus properly remains below in case a
        // way is found to make the code at the end of this function
        // actually set focus independent of selection.
        if (selFlag == AccConst.SELFLAG_TAKEFOCUS)
            selFlag = AccConst.SELFLAG_TAKESELECTION
        else if (selFlag & AccConst.SELFLAG_TAKEFOCUS)
            selFlag -= AccConst.SELFLAG_TAKEFOCUS

        var settingFocus:Boolean = Boolean(selFlag & AccConst.SELFLAG_TAKEFOCUS);
        if (settingFocus)
            selFlag -= AccConst.SELFLAG_TAKEFOCUS;

        var rowIndex:int = dgAccInfo.rowIndex;
        var columnIndex:int = dgAccInfo.columnIndex;
        if (!dgAccInfo.isCellMode)
            columnIndex = -1;
        var grid:DataGrid = dgAccInfo.dataGrid;
        grid.ensureCellIsVisible(rowIndex, columnIndex);

        // First selection, then focus if requested.
        // Caveat: Invalid selection flags will cause no changes to be made,
        // including a focus change if one was requested.

        if (selFlag == AccConst.SELFLAG_TAKESELECTION)
        {
            if (columnIndex == -1)
                grid.setSelectedIndex(rowIndex);
            else
                grid.setSelectedCell(rowIndex, columnIndex);
        }
        else if (selFlag == AccConst.SELFLAG_ADDSELECTION)
        {
            if (columnIndex == -1)
                grid.addSelectedIndex(rowIndex);
            else
                grid.addSelectedCell(rowIndex, columnIndex);
        }
        else if (selFlag == AccConst.SELFLAG_REMOVESELECTION)
        {
            if (columnIndex == -1)
                grid.removeSelectedIndex(rowIndex);
            else
                grid.removeSelectedCell(rowIndex, columnIndex);
        }
        else if (Boolean(selFlag & AccConst.SELFLAG_EXTENDSELECTION))
        {
            if (Boolean(selFlag & AccConst.SELFLAG_ADDSELECTION)
            && Boolean(selFlag & AccConst.SELFLAG_REMOVESELECTION))
                return;
            var focusedID:uint = get_accFocus();
            if (!focusedID)
            {
                // This could be assumed to be 1, but this is probably safer.
                return;
            }
            // We have to recalculate dgAccInfo for the anchor,
            // but we already have row/column indices for the requested item,
            // so we can do that without needing to reset it again afterward.
            dgAccInfo.setup(master, focusedID);
            if (dgAccInfo.isColumnHeader || dgAccInfo.isInvalid)
                return;
            var anchorRowIndex:int = dgAccInfo.rowIndex;
            var anchorColumnIndex:int = dgAccInfo.columnIndex;
            var adding:Boolean;
            if (Boolean(selFlag & AccConst.SELFLAG_ADDSELECTION))
                adding = true;
            else if (Boolean(selFlag & AccConst.SELFLAG_REMOVESELECTION))
                adding = false;
            else
            {
                // MSAA docs say use selection state of anchor here.
                // This method of figuring that out is a bit more
                // intensive than necessary (other states calculated also),
                // but selection extension without ADD/REMOVE being specified
                // should be a very infrequent occurrence, and this method
                // centralizes the logic for figuring out what is selected.
                adding = Boolean(get_accState(focusedID) & AccConst.STATE_SYSTEM_SELECTED);
            }
            if (columnIndex == -1)
                grid.selectIndices(
                    Math.min(anchorRowIndex, rowIndex),
                    Math.abs(rowIndex - anchorRowIndex) + 1
                );
            else
                grid.selectCellRegion(
                    Math.min(anchorRowIndex, rowIndex),
                    Math.min(anchorColumnIndex, columnIndex),
                    Math.abs(rowIndex - anchorRowIndex) + 1,
                    Math.abs(columnIndex - anchorColumnIndex) + 1
                );
        }

        // Now handle the focus change request if there was one
        // (and if invalid flags didn't cause a return above).
        // TODO:  This approach does not work properly, and to date,
        // no approach that does has been found.
        // Code at the top of this function effectively makes the
        // below "if" never true.
        if (settingFocus)
            grid.grid.caretRowIndex = rowIndex;
            grid.grid.caretColumnIndex = columnIndex;
    }

    /**
     *  @private
     *  IAccessible method for returning the child Selections in the List.
     *
     *  @param childID uint
     *
     *  @return focused childID.
     */
    override public function get_accSelection():Array
    {
        var accSelection:Array = [];
        dgAccInfo.setup(master, 0);
        if (!dgAccInfo.dataGrid.columns)
            return null;
        var i:int
        var n:int
        var items:Object;

        if (dgAccInfo.isCellMode)
        {
            items = dgAccInfo.dataGrid.selectedCells;
            n = items.length;
            for (i = 0; i < n; i++)
            {
                // The selected childID is effectively the 1-based cell index.
                // This is row*colCount + columnInRow +columnHeaderCount +1.
                accSelection[i] = items[i].rowIndex * dgAccInfo.reachableColumnCount
                + items[i].columnIndex
                + dgAccInfo.headerCount + 1;
            }
        }
        else // row mode
        {
            items = dgAccInfo.dataGrid.selectedIndices;
            n = items.length;
            for (i = 0; i < n; i++)
            {
                // This time we just need rowIndex (0-based) + headerCount + 1.
                accSelection[i] = items[i] + dgAccInfo.headerCount + 1;
            }

        }

        return accSelection;

    }

    //--------------------------------------------------------------------------
    //
    //  Overridden event handlers: AccImpl
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Override the generic event handler.
     *  All AccImpl must implement this to listen
     *  for events from its master component.
     */
    override protected function eventHandler(event:Event):void
    {
        // Let AccImpl class handle the events
        // that all accessible UIComponents understand.
        $eventHandler(event);

        dgAccInfo.setup(master, 0);
        if (!dgAccInfo.dataGrid.columns)
            return;

        var childID:uint;
        switch (event.type)
        {
            case GridCaretEvent.CARET_CHANGE:
            {
                childID = dgAccInfo.childIDFromRowAndColumn(
                    int(GridCaretEvent(event).newRowIndex),
                    int(GridCaretEvent(event).newColumnIndex)
                )
                if (int(childID) > 0)
                    if (!dgAccInfo.dataGrid.itemEditorInstance)
                        Accessibility.sendEvent(dgAccInfo.dataGrid.focusOwner, childID, AccConst.EVENT_OBJECT_FOCUS);
                    else
                        Accessibility.sendEvent(UIComponent(dgAccInfo.dataGrid.itemEditorInstance), 0, AccConst.EVENT_OBJECT_FOCUS);
                break;
            }
            case GridSelectionEvent.SELECTION_CHANGE:
            {
                var gridSelectionEvent:GridSelectionEvent = GridSelectionEvent(event);
                childID = dgAccInfo.childIDFromRowAndColumn(
                    gridSelectionEvent.selectionChange.rowIndex,
                    gridSelectionEvent.selectionChange.columnIndex
                );
                if (int(childID) <= 0)
                    return;

                var eventID:int = AccConst.EVENT_OBJECT_SELECTION;
                var kind:String = gridSelectionEvent.kind;
                if (kind == GridSelectionEventKind.ADD_CELL
                || kind == GridSelectionEventKind.ADD_ROW)
                    eventID = AccConst.EVENT_OBJECT_SELECTIONADD;
                else if (kind == GridSelectionEventKind.REMOVE_CELL
                || kind == GridSelectionEventKind.REMOVE_ROW)
                    eventID = AccConst.EVENT_OBJECT_SELECTIONREMOVE;
                else if (kind == GridSelectionEventKind.CLEAR_SELECTION
                || kind == GridSelectionEventKind.SELECT_ALL
                || kind == GridSelectionEventKind.SET_CELL_REGION
                || kind == GridSelectionEventKind.SET_ROWS)
                    eventID = AccConst.EVENT_OBJECT_SELECTIONWITHIN;

                Accessibility.sendEvent(dgAccInfo.dataGrid.focusOwner, childID, eventID);
                break;
            }
            case FocusEvent.FOCUS_IN:
            {
                // do not fire focus changes for list when a child editor is focused 
                // as this causes an extra event being fired
                if (event.target == DataGrid(master).focusOwner)
                    Accessibility.sendEvent(DataGrid(master).focusOwner, 0, AccConst.EVENT_OBJECT_FOCUS);
                break;
            }
            case GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_START:
            {
                dgAccInfo.setup(master, 0);
                
                childID = dgAccInfo.childIDFromRowAndColumn(
                    GridItemEditorEvent(event).rowIndex,
                    GridItemEditorEvent(event).columnIndex
                );
                var editor:Object = event.currentTarget.itemEditorInstance;
                var defaultGridItemEditorClass:Class = Class(getDefinition("spark.components.gridClasses.DefaultGridItemEditor", master.moduleFactory));
                if (editor is defaultGridItemEditorClass)
                {
                    // The specific part with focus.
                    try
                    {
                        editor = Object(editor).textArea;
                    }
                    catch(e:Error)
                    {
                    }
                }
                else
                {
                    // Try to find the specific part with focus,
                    // falling back to the itemEditorInstance if we don't know it.
                    var realEditor:UIComponent = null;
                    try
                    {
                        realEditor = UIComponent(editor.stage.focus);
                    }
                    catch(e:Error)
                    {
                    }
                    if (Boolean(realEditor) && editor != realEditor)
                    {
                        editor = realEditor;
                    }
                }
                // Name the editor with this cell's name.
                // This applies the same rules for row identification for both edit and non-edit cells.
                if (!editor.accessibilityName)
                {
                    var edName:String = "";
                    if (dgAccInfo.headerCount > 0)
                    {
                        var columns:IList = dgAccInfo.dataGrid.columns;
                        var columnIndex:int = GridItemEditorEvent(event).columnIndex;
                        edName += columns.getItemAt(columnIndex).headerText;
                    }
                    // For the row string, we need to indicate which cell to use.
                    dgAccInfo.setup(master, childID);
                    var rowString:String = makeRowString(dgAccInfo);
                    if (rowString)
                        edName += " " +rowString;
                    editor.accessibilityName = edName;
                    Accessibility.updateProperties();
                }
                Accessibility.sendEvent(UIComponent(editor), 0, AccConst.EVENT_OBJECT_FOCUS);
                break;
            }
            case GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_SAVE, GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_CANCEL:
            {
                dgAccInfo.setup(master, 0);
                
                childID = dgAccInfo.childIDFromRowAndColumn(
                GridItemEditorEvent(event).rowIndex, GridItemEditorEvent(event).columnIndex);

                Accessibility.sendEvent(DataGrid(master).focusOwner, childID, AccConst.EVENT_OBJECT_FOCUS);
            }
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private function makeRowString(dgAccInfo:ItemAccInfo):String
    {
        var rowString:String = "";
        if ((dgAccInfo.isCellMode && dgAccInfo.reachableColumnIndex == 0) || !dgAccInfo.isCellMode)
        {
            var resourceManager:IResourceManager = ResourceManager.getInstance();
            rowString = resourceManager.getString("components", "rowMofN");
            rowString = rowString.replace("%1", dgAccInfo.reachableRowIndex + 1).replace("%2", dgAccInfo.reachableRowCount);
        }
        return rowString;
    }

    /**
     *  @private
     */
    private function cellName(rowObject:Object, columnIndex:int):String
    {
        var item:Object = rowObject;
        var dataGrid:DataGrid = DataGrid(master);
        var columns:IList = dataGrid.columns;
        if (!columns)
            return null;
        var column:Object = columns.getItemAt(columnIndex);
        if (!column)
            return null;
        return column.itemToLabel(rowObject);
    }

}

}

/**
 *  @private
 *  ItemAccInfo is a support class used by DataGridAccImpl to determine various
 *  things about a DataGrid.  For performance reasons, this class is
 *  instantiated once by DataGridAccImpl and repopulated as needed from
 *  DataGridAccImpl code via calls to ItemAccInfo.setup().
 *
 *  <p>Terminology:  A "reachable" cell, row, or column refers to an item that
 *  the developer has allowed a user to view, whether or not it happens to be
 *  visible on screen at the moment.
 *  At this writing, the ability to hide rows from the user is not anticipated,
 *  but the hiding of columns will be possible.
 *  (When rows of data are hidden via DataProvider filtering, they simply don't
 *  appear in the DataGrid at all.)
 */
internal class ItemAccInfo
{
    import mx.core.UIComponent;
    import spark.components.DataGrid;
    import spark.components.Grid;
    import spark.components.gridClasses.GridSelectionMode;
    import spark.components.gridClasses.CellPosition;
    import flash.geom.Rectangle;
    import flash.geom.Point;

    /**
     *  Constructor.
     */
    public function ItemAccInfo()
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     *  Sets up for use with a particular DataGrid and item within it.
     *
     *  @param master The UIComponent instance that the calling AccImpl instance
     *  is making accessible.
     *  @param childID The childID of the DataGrid item of interest.
     *  This may refer to a header cell, a data cell, or a data row.
     */
    public function setup(master:UIComponent, childID:uint):void
    {
        this.master = master;
        this.childID = childID;
        dataGrid = DataGrid(master);
        reachableRowIndices = null;
        reachableColumnIndices = null;
        if (dataGrid.columns)
        {
            columnCount = dataGrid.columns.length;
            // For efficiency in the common case, assume all is visible,
            // and only build a vector of reachable indices if this is wrong.
            var somethingIsInvisible:Boolean = false;
            var column:Object;
            var i:int;
            for (i = 0; i < columnCount; i++)
            {
                column = dataGrid.columns.getItemAt(i);
                if (!column.visible)
                {
                    somethingIsInvisible = true;
    break;
                }
            }
            if (somethingIsInvisible)
            {
                reachableColumnIndices = new Vector.<int>();
                for (i = 0; i < columnCount; i++)
                {
                    column = dataGrid.columns.getItemAt(i);
                    if (column.visible)
                        reachableColumnIndices.push(column.columnIndex);
                }
            }
            reachableColumnCount = reachableColumnIndices == null ?
                columnCount : reachableColumnIndices.length;
        }
        else
        {
            columnCount = 0;
            reachableColumnCount = 0;
        }
        if (dataGrid.dataProvider)
        {
          rowCount = dataGrid.dataProvider.length;
            reachableRowCount = reachableRowIndices == null ?
                rowCount : reachableRowIndices.length;
        }
        else
        {
            rowCount = 0;
            reachableRowCount = 0;
        }
        headerCount = 0;
        reachableHeaderCount = 0;
        maxChildID = 0;
        isCellMode = false;
        isMultiSelect = false;
        isInvalid = false;
        isColumnHeader = false;
        rowIndex = 0;
        columnIndex = 0;
        reachableRowIndex = 0;
        reachableColumnIndex = 0;

        var itemIndex:int = childID - 1;
        if (dataGrid.columnHeaderGroup && dataGrid.columnHeaderGroup.visible)
        {
            // There are visible column headers, so their childIDs come first.
            itemIndex -= reachableColumnCount;
            headerCount = columnCount;
            reachableHeaderCount = reachableColumnCount;
        }
        else
        {
            // No header bar or it's invisible,
            // so we should not try to expose any data within it.
            headerCount = 0;
            reachableHeaderCount = 0;
        }
        var mode:String = dataGrid.selectionMode;
        isCellMode = (
            mode == GridSelectionMode.SINGLE_CELL
            || mode == GridSelectionMode.MULTIPLE_CELLS
        );
        isMultiSelect = (
            mode == GridSelectionMode.MULTIPLE_CELLS
            || mode == GridSelectionMode.MULTIPLE_ROWS
        );
        maxChildID = 0;
        // Account for reachable headers.
        maxChildID += reachableHeaderCount;
        // Then for reachable cells or rows as appropriate.
        if (isCellMode)
            maxChildID += reachableRowCount * reachableColumnCount;
        else
            maxChildID += reachableRowCount;
        isColumnHeader = false;
        isInvalid = false;
        if (childIDOutOfBounds(childID))
        {
            isInvalid = true;
            reachableColumnIndex = -1;
            reachableRowIndex = -1;
            itemIndex = -1;
        }
        else if (itemIndex < 0)
        {
            // This childID refers to a header, not a data row or cell.
            isColumnHeader = true;
            reachableColumnIndex = itemIndex + reachableColumnCount;
            reachableRowIndex = -1;
            itemIndex = -1;
        }
        else if (isCellMode)
        {
            reachableRowIndex = Math.floor(itemIndex / reachableColumnCount);
            reachableColumnIndex = itemIndex % reachableColumnCount;
        }
        else
        {
            reachableRowIndex = itemIndex;
            // Using 0 here so, for example, getItemRendererAt() calls still work for a row.
            reachableColumnIndex = 0;
        }
        rowIndex = reachableRowIndex;
        columnIndex = reachableColumnIndex;
        if (reachableRowIndex >= 0 && reachableRowIndices && reachableRowIndices.length)
            rowIndex = reachableRowIndices[reachableRowIndex];
        if (reachableColumnIndex >= 0 && reachableColumnIndices && reachableColumnIndices.length)
            columnIndex = reachableColumnIndices[reachableColumnIndex];
    }

    /**
     *  @private
     */
    // The master component reference for which this AccImpl is instantiated.
    public var master:UIComponent;
    // The childID within that component for which this accInfo is calculated.
    public var childID:uint;
    // The DataGrid reference for this instance.
    public var dataGrid:DataGrid;
    // Number of columns, headers, and rows overall.
    public var columnCount:int;
    public var headerCount:int;
    public var rowCount:int;
    // Number of columns, headers, and rows that are reachable.
    // ("Reachable" means not marked invisible by the developer.)
    public var reachableColumnCount:int;
    public var reachableHeaderCount:int;
    public var reachableRowCount:int;
    // Indices of reachable rows and columns.
    // These are null when nothing is filtered, for performance reasons.
    protected var reachableRowIndices:Vector.<int>;
    protected var reachableColumnIndices:Vector.<int>;
    // The highest valid childID.
    public var maxChildID:int;
    // True if we are in cell navigation mode (single or multiple selection).
    public var isCellMode:Boolean;
    // True if we are in a multiple selection mode (row or cell).
    public var isMultiSelect:Boolean;
    // True if the data in this object is invalid for some reason.
    // Usually this means an invalid childID was passed to setup().
    public var isInvalid:Boolean;
    // True if the given childID represents a column header cell.
    public var isColumnHeader:Boolean;
    // 0-based indices of row and column in the sets of reachable ones.
    public var reachableColumnIndex:int;
    public var reachableRowIndex:int;
    // 0-based indices of row and column in the set of all of each.
    public var columnIndex:int;
    public var rowIndex:int;

    /**
     *  @private
     *  Determine the childID corresponding to the given DataGrid row and column.
     *  The row and column indices taken here are from the set of reachable
     *  rows and colums; they are not absolute row/column indices.
     *  This method is used internally; see childIDFromRowAndColumn() for the
     *  external interface.
     *
     *  @param reachableRowIndex The 0-based index of the row among reachable rows.
     *  @param reachableColumnIndex The 0-based index of the column among reachable columns.
     *  Ignored if this grid is in a row navigation mode.
     *
     *  @return The childID corresponding to the row and column indices passed.
     */
    protected function childIDFromReachableRowAndColumn(reachableRowIndex:int, reachableColumnIndex:int):uint
    {
        var childID:int = reachableHeaderCount + 1;
        if (reachableRowIndex < 0)
            childID = 0;
        else if (isCellMode)
            if (reachableColumnIndex < 0)
                childID = 0;
            else
                childID += reachableRowIndex * reachableColumnCount + reachableColumnIndex;
        else
            childID += reachableRowIndex;
        return uint(childID);
    }

    /**
     *  @private
     *  Determine the childID corresponding to the given DataGrid row and column.
     *  The indices passed to this method are mapped onto the set of rows and
     *  columns that are or can be exposed to the user.
     *
     *  @param rowIndex The 0-based index of the row.
     *  @param columnIndex The 0-based index of the column.
     *  Ignored if this grid is in a row navigation mode.
     *
     *  @return The childID corresponding to the row and column indices passed.
     */
    public function childIDFromRowAndColumn(rowIndex:int, columnIndex:int):uint
    {
        return childIDFromReachableRowAndColumn(
            reachableRowIndices == null ? rowIndex : reachableRowIndices.indexOf(rowIndex),
            reachableColumnIndices == null ? columnIndex : reachableColumnIndices.indexOf(columnIndex)
        );
    }

    /**
     *  @private
     *  Internal method for checking if a childID is above or below those allowed.
     *
     *  @param childID The childID to check.
     *
     *  @return true if the childID is out of bounds and false if not.
     */
    private function childIDOutOfBounds(childID: int):Boolean
    {
        if (int(childID) <= 0)
            return true;
        if (!dataGrid.dataProvider || !dataGrid.columns)
            return true
        if (childID > maxChildID)
            return true;
        return false;
    }

    /**
     *  @private
     *  Return an object giving the bounds of this grid item (row or cell).
     *  The object returned is either an IVisualElement (renderer), in which
     *  case its coordinates are assumed to be stage-based, or a
     *  flash.geom.Rectangle, in which case its coordinates are relative to
     *  the top left corner of the DataGrid.  These are the requirements of
     *  the AccImpl::get_accLocation() method.
     *
     *  @return The Rectangle indicating the item's bounds.
     */
    public function boundingRect():Object
    {
        // First see if this item is on screen.
        // We could skip this, but we'd run the risk of having
        // assistive technology create huge numbers of itemRenderers below
        // by quickly scanning an entire grid.
        if (!isColumnHeader && (rowIndex < 0 || rowIndex >= rowCount))
            // Also covers rowCount == 0 effectively.
            return null;
        if (isCellMode && (columnIndex < 0 || columnIndex >= columnCount))
            return null;
        var vri:Vector.<int> = dataGrid.grid.getVisibleRowIndices();
        var vci:Vector.<int> = dataGrid.grid.getVisibleColumnIndices();
        if (isColumnHeader && vci.indexOf(columnIndex) < 0)
            return null;
        if ((!isColumnHeader && vri.indexOf(rowIndex) < 0)
        || (isCellMode && vci.indexOf(columnIndex) < 0))
            return null;

        var result:Object;
        if (isColumnHeader)
        {
            result = dataGrid.columnHeaderGroup.getHeaderRendererAt(columnIndex);
        }
        else if (isCellMode)
        {
            result = dataGrid.grid.getItemRendererAt(rowIndex, columnIndex);
        }
        else  // row mode
        {
            // Use the item renderers at both ends of this row
            // to calculate the width.
            // We assume here that top and bottom of all renderers for one row are equal.
            var r1:Object = dataGrid.grid.getItemRendererAt(rowIndex, vci[0]);
            var r2:Object = dataGrid.grid.getItemRendererAt(rowIndex, vci[vci.length-1]);
            var xy:Point = new Point(
                r1.getLayoutBoundsX(),
                r1.getLayoutBoundsY()
            );
            xy = dataGrid.grid.localToGlobal(xy);
            xy = dataGrid.globalToLocal(xy);
            result = new Rectangle(
                xy.x, xy.y,
                r2.getLayoutBoundsX() + r2.getLayoutBoundsWidth() - r1.getLayoutBoundsX(),
                r1.getLayoutBoundsHeight()
            );
        }
        return result;
    }

}
