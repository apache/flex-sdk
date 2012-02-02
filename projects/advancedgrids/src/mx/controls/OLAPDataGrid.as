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
import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.ui.Keyboard;
import flash.utils.Dictionary;

import mx.collections.ArrayCollection;
import mx.collections.IList;
import mx.collections.errors.ItemPendingError;
import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
import mx.controls.advancedDataGridClasses.AdvancedDataGridColumnGroup;
import mx.controls.advancedDataGridClasses.AdvancedDataGridHeaderInfo;
import mx.controls.advancedDataGridClasses.AdvancedDataGridListData;
import mx.controls.listClasses.BaseListData;
import mx.controls.listClasses.IDropInListItemRenderer;
import mx.controls.listClasses.IListItemRenderer;
import mx.controls.olapDataGridClasses.OLAPDataGridGroupRenderer;
import mx.controls.olapDataGridClasses.OLAPDataGridHeaderRenderer;
import mx.controls.olapDataGridClasses.OLAPDataGridHeaderRendererProvider;
import mx.controls.olapDataGridClasses.OLAPDataGridItemRendererProvider;
import mx.controls.olapDataGridClasses.OLAPDataGridRendererProvider;
import mx.core.ClassFactory;
import mx.core.FlexShape;
import mx.core.IDataRenderer;
import mx.core.IFactory;
import mx.core.IFlexDisplayObject;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.formatters.Formatter;
import mx.olap.IOLAPAxisPosition;
import mx.olap.IOLAPCell;
import mx.olap.IOLAPHierarchy;
import mx.olap.IOLAPLevel;
import mx.olap.IOLAPMember;
import mx.olap.IOLAPResult;
import mx.styles.ISimpleStyleClient;
import mx.styles.IStyleClient;
use namespace mx_internal;

//--------------------------------------
//  Excluded APIs
//--------------------------------------

//--------------------------------------
//  public properties
//--------------------------------------

[Exclude(name="allowDragSelection", kind="property")]
[Exclude(name="columns", kind="property")]
[Exclude(name="columnWidth", kind="property")]
[Exclude(name="displayDisclosureIcon", kind="property")]
[Exclude(name="displayItemsExpanded", kind="property")]
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
[Exclude(name="hasRoot", kind="property")]
[Exclude(name="hierarchicalCollectionView", kind="property")]
[Exclude(name="itemEditorInstance", kind="property")]
[Exclude(name="itemIcons", kind="property")]
[Exclude(name="labelFunction", kind="property")]
[Exclude(name="lockedColumnCount", kind="property")]
[Exclude(name="lookAheadDuration", kind="property")]
[Exclude(name="openItems", kind="property")]
[Exclude(name="rendererProviders", kind="property")]
[Exclude(name="showHeaders", kind="property")]
[Exclude(name="showRoot", kind="property")]
[Exclude(name="sortableColumns", kind="property")]
[Exclude(name="sortExpertMode", kind="property")]
[Exclude(name="sortItemRenderer", kind="property")]

//--------------------------------------
//  protected properties
//--------------------------------------
[Exclude(name="_columns", kind="property")]
[Exclude(name="dragImage", kind="property")]
[Exclude(name="dragImageOffsets", kind="property")]
[Exclude(name="headerInfoInitialized", kind="property")]
[Exclude(name="lastDropIndex", kind="property")]
[Exclude(name="orderedHeadersList", kind="property")]
[Exclude(name="selectedHeaderInfo", kind="property")]

//--------------------------------------
//  public methods
//--------------------------------------

[Exclude(name="calculateDropIndex", kind="method")]
[Exclude(name="collapseAll", kind="method")]
[Exclude(name="createItemEditor", kind="method")]
[Exclude(name="destroyItemEditor", kind="method")]
[Exclude(name="expandAll", kind="method")]
[Exclude(name="expandChildrenOf", kind="method")]
[Exclude(name="expandItem", kind="method")]
[Exclude(name="getParentItem", kind="method")]
[Exclude(name="isItemOpen", kind="method")]
[Exclude(name="setItemIcon", kind="method")]
[Exclude(name="getFieldSortInfo", kind="method")]
[Exclude(name="hideDropFeedback", kind="method")]
[Exclude(name="showDropFeedback", kind="method")]
[Exclude(name="startDrag", kind="method")]
[Exclude(name="stopDrag", kind="method")]

//--------------------------------------
//  protected methods
//--------------------------------------
[Exclude(name="addDragData", kind="method")]
[Exclude(name="addSortField", kind="method")]
[Exclude(name="dragCompleteHandler", kind="method")]
[Exclude(name="dragDropHandler", kind="method")]
[Exclude(name="dragEnterHandler", kind="method")]
[Exclude(name="dragExitHandler", kind="method")]
[Exclude(name="dragOverHandler", kind="method")]
[Exclude(name="dragScroll", kind="method")]
[Exclude(name="dragStartHandler", kind="method")]
[Exclude(name="expandItemHandler", kind="method")]
[Exclude(name="findSortField", kind="method")]
[Exclude(name="headerReleaseHandler", kind="method")]
[Exclude(name="placeSortArrow", kind="method")]
[Exclude(name="removeSortField", kind="method")]
[Exclude(name="treeNavigationHandler", kind="method")]
[Exclude(name="updateHeaderSearchList", kind="method")]
[Exclude(name="updateVisibleHeaders", kind="method")]


//--------------------------------------
//  events
//--------------------------------------

[Exclude(name="dragComplete", kind="event")]
[Exclude(name="dragDrop", kind="event")]
[Exclude(name="dragEnter", kind="event")]
[Exclude(name="dragExit", kind="event")]
[Exclude(name="dragOver", kind="event")]
[Exclude(name="headerDragOutside", kind="event")]
[Exclude(name="headerDropOutside", kind="event")]
[Exclude(name="headerRelease", kind="event")]
[Exclude(name="headerShift", kind="event")]
[Exclude(name="itemClose", kind="event")]
[Exclude(name="itemEditBegin", kind="event")]
[Exclude(name="itemEditBeginning", kind="event")]
[Exclude(name="itemEditEnd", kind="event")]
[Exclude(name="itemOpen", kind="event")]
[Exclude(name="itemOpening", kind="event")]

//--------------------------------------
//  styles
//--------------------------------------

[Exclude(name="columnDropIndicatorSkin", kind="style")]
[Exclude(name="defaultLeafIcon", kind="style")]
[Exclude(name="depthColors", kind="style")]
[Exclude(name="folderClosedIcon", kind="style")]
[Exclude(name="folderOpenIcon", kind="style")]
[Exclude(name="headerSortSeparatorSkin", kind="style")]
[Exclude(name="headerStyleName", kind="style")]
[Exclude(name="openDuration", kind="style")]
[Exclude(name="openEasingFunction", kind="style")]
[Exclude(name="sortFontFamily", kind="style")]
[Exclude(name="sortFontSize", kind="style")]
[Exclude(name="sortFontStyle", kind="style")]
[Exclude(name="sortFontWeight", kind="style")]
[Exclude(name="headerDragProxyStyleName", kind="style")]


//--------------------------------------
//  Styles
//--------------------------------------

/**
 *  The name of a CSS style declaration for controlling aspects of
 *  the appearance of the row axis headers.
 *  The default value is <code>undefined</code>, which means it uses the value of the 
 *  <code>headerStyleName</code> style.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="rowAxisHeaderStyleName", type="String", inherit="no")]

/**
 *  The name of a CSS style declaration for controlling aspects of
 *  the appearance of the column axis headers.
 *  The default value is <code>undefined</code>, which means it uses the value of the 
 *  <code>headerStyleName</code> style.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="columnAxisHeaderStyleName", type="String", inherit="no")]

/**
 *  The OLAPDataGrid control expands on the functionality of the AdvancedDataGrid control 
 *  to add support for the display of the results of OLAP queries. 
 *  Like all Flex data grid controls, the OLAPDataGrid control is designed to display data 
 *  in a two-dimensional representation of rows and columns. 
 *
 *  <p>Because of the way you pass data to the OLAPDataGrid control, 
 *  it has several differences from the AdvancedDataGrid control:</p>
 *  <ul>
 *    <li>Column dragging is not allowed in the OLAPDataGrid control.</li>
 *    <li>You cannot edit cells in the OLAPDataGrid control because cell data 
 *      is a result of a query and does not correspond to a single data value in the OLAP cube.</li>
 *    <li>You cannot sort columns by clicking on header in the OLAPDataGrid control. 
 *      Sorting is supported at the dimension level so that you can change 
 *      the order of members of that dimension.</li>
 *  </ul>
 *
 *  <p>You populate an OLAPDataGrid control with data by setting its data provider 
 *  to an instance of the OLAPResult class, which contains the results of an OLAP query. </p>
 *
 *  @mxml
 *  <p>
 *  The <code>&lt;mx:OLAPDataGrid&gt;</code> tag inherits all of the tag attributes
 *  of its superclass, except for <code>labelField</code>, <code>iconField</code>,
 *  and <code>iconFunction</code>, and adds the following tag attributes:
 *  </p>
 *  <pre>
 *  &lt;mx:OLAPDataGrid 
 *    <b>Properties</b>
 *    defaultCellString="NaN"
 *    headerRendererProviders="[]"
 *    itemRendererProviders="[]"
 *     
 *    <b>Styles</b>
 *    columnAxisHeaderStyleName="undefined"
 *    rowAxisHeaderStyleName="undefined"
 *  /&gt;
 *   
 *  @see mx.controls.AdvancedDataGrid
 *  @see mx.olap.OLAPQuery
 *  @see mx.olap.OLAPResult
 *
 *  @includeExample examples/OLAPDataGridExample.mxml 
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class OLAPDataGrid extends AdvancedDataGrid 
{

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    /**
     *  A constant that corresponds to the column axis.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const COLUMN_AXIS:int = 0;
    /**
     *  A constant that corresponds to the row axis.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const ROW_AXIS:int = 1;
    /**
     *  A constant that corresponds to the slicer axis.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const SLICER_AXIS:int = 2;

    /**
     *  A constant that corresponds to a member of an axis.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const OLAP_MEMBER:int = 0;
    /**
     *  A constant that corresponds to a level of an axis.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const OLAP_LEVEL:int = 1;
    /**
     *  A constant that corresponds to a member of an axis.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const OLAP_HIERARCHY:int = 2;
    /**
     *  A constant that corresponds to a member of an axis.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const OLAP_DIMENSION:int = 3;
    
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
    public function OLAPDataGrid()
    {
        super();

        groupItemRenderer = new ClassFactory(OLAPDataGridGroupRenderer);

        olapElements = [];
        olapElements.push(OLAPDataGrid.OLAP_MEMBER);
        olapElements.push(OLAPDataGrid.OLAP_LEVEL);
        olapElements.push(OLAPDataGrid.OLAP_HIERARCHY);
        olapElements.push(OLAPDataGrid.OLAP_DIMENSION);
        olapElements = olapElements.sort();

        draggableColumns = false;
        sortableColumns = false;
        sortExpertMode = true;
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Reference to the IOLAPResultView
     */
    private var olapData:IOLAPResult;
    
    /**
     *  @private
     *  rowAxis of the olapData
     */
    private var rowAxis:IList;

    /**
     *  @private
     *  columnAxis of the olapData
     */
    private var columnAxis:IList;
    
    /**
     *  @private
     *  slicerAxis of the olapData
     */
    private var slicerAxis:IList;

    /**
     *  @private
     *  maintains a mapping of each column with the corresponding IOLAPMember
     */
    private var columnNames:Dictionary;

    /**
     *  @private
     *  number of columns which make up row headers area
     */
    private var numHeaderCols:int = 0;

    /**
     * @private
     * Special column which acts as a header of all column headers
     * 
     * Idea is to have a root column for column axis
     * which will wrap all the column axis headers in a UIComponent
     * and show them
     */
    private var hierarchiesHeaderColumn:AdvancedDataGridColumnGroup;

    /**
     *  @private
     */
    private var dataProviderChanged:Boolean = false;

    /**
     *  @private
     */
    private var isMeasuring:Boolean

    /**
     *  @private
     */
    private var currentRowLabels:Array /* of String */ ;

    /**
     *  @private
     *  Maintains information for each row header row, type OLAPRowHeaderInfo
     */
    private var rowHeadersMap:Dictionary;
    
    /**
     *  @private
     *  Array of dictionaries to hash the itemRendererProviders
     *  defined on the OLAPDataGrid, each dictionary in the array
     *  corresponds to one type viz member, level, hierarchy, dimension
     *
     */
    private var cellRenderersMap:Array/* of Dictionary */ ;

    /**
     *  @private
     *  Similar to cellRenderersMap, an  Array of dictionaries to 
     *  hash the hedaerRendererProviders
     *
     */
    private var headerRenderersMap:Array/* of Dictionary */ ;
    
    /**
     *  @private
     *  Array which keeps member, level, hierarchy, dimension (olap elements)
     *  in sorted order
     */
    private var olapElements:Array /* of int */ ;
    
    private var itemRendererProvidersChanged:Boolean = false;
	
	private var headerRendererProvidersChanged:Boolean = false;
	
	/**
     * Caches the indents seen in the first row of the data
     * thus, in case of full page scroll, indentation is decided
     * by comparing the depth of the current member with the depths stored here
     * @private
     */
    private var cachedMinRowIndents:Array/* of int */;
    
    /**
     *  @private
     *  Keep track of styles of the individual item renderers when custom
     *  row/column formatting i.e. grid and column styleFunctions are applied.
     */
    private var oldStyles:Dictionary;

    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  draggableColumns
    //----------------------------------

    /**
     *  @private
     *  Column Dragging is not allowed in OLAPDataGrid
     */
    override public function set draggableColumns(value:Boolean):void
    {
        super.draggableColumns = false;
    }
    
    //----------------------------------
    //  verticalScrollPosition
    //----------------------------------

    /**
     *  @private
     *  On vertical scroll rowHeaderHorizontalSeparators need to be drawn again
     *
     */
    override public function set verticalScrollPosition(value:Number):void
    {
        super.verticalScrollPosition = value;
        
        //Need to re-draw horizontal grid lines in case of vertical scroll
        if (getStyle("horizontalGridLines"))
            drawRowHeaderHorizontalSeparators();
    }

    //----------------------------------
    // dataProvider
    //----------------------------------
    
    /**
     *  @private
     */
    override public function get dataProvider():Object
    {
        return olapData;
    }
    
    /**
     *  An OLAPDataGrid accepts only an IOLAPResult as dataProvider
     *  other dataProviders are simply ignored.
     * 
     *  One can set dataProvider to null, to reset the control.
     * 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function set dataProvider(value:Object):void
    {
        if(!value || value != null && value is IOLAPResult)
        {
            olapData = IOLAPResult(value);
            dataProviderChanged = true;
            
            invalidateProperties();
        }
        
    }
    
    //----------------------------------
    // sortExpertMode
    //----------------------------------

    /**
     *  @private
     */
    override public function set sortExpertMode(value:Boolean):void
    {
        super.sortExpertMode = true;
    }
    
    //----------------------------------
    // styleFunction
    //----------------------------------

    /**
     *  A callback function called while rendering each cell in the cell data area.
     *
     *  The signature of the callback function is:
     *
     *   <pre>function myStyleFunction(row:IOLAPAxisPosition, column:IOLAPAxisPosition, value:Number):Object</pre>
     *
     *   <p>where 
     *   <code>row</code> is the IOLAPAxisPosition associated with this cell on row axis,
     *   <code>column</code> is the IOLAPAxisPosition associated with this cell on column axis
     *   and <code>value</code> is the cell value.</p>
     *
     *  <p>The return value should be a Object with styles as properties.
     *  For example: <code>{ color:0xFF0000, fontWeight:"bold" }</code>.</p>
     *  <p>In case when the value in the cell is NaN, the function is called with NaN as the last argument</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    
    override public function set styleFunction(value:Function):void
    {
        super.styleFunction = value;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  defaultCellString
    //----------------------------------

    /**
     *  String displayed in a cell when the data for that cell returned by 
     *  the IOLAPResult instance is null or NaN. 
     *
     *  @default "NaN"
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var defaultCellString:String = "NaN";

    //----------------------------------
    //  itemRendererProviders
    //----------------------------------

    /**
     *  @private
     */
    private var _itemRendererProviders:Array /* of OLAPDataGridItemRendererProvider */ = [];;
    private var _itemRendererProvidersUnSorted:Array /* of OLAPDataGridItemRendererProvider */ = [];

    /**
     *  Array of OLAPDataGridItemRendererProvider instances that specify a
     *  custom item renderer for the cells of the control. 
     *  You can use several renderer providers to specify custom item renderers used for 
     *  different locations in the control.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get itemRendererProviders():Array /* of OLAPDataGridItemRendererProvider */ 
    {
        return _itemRendererProvidersUnSorted;
    }

    /**
     *  @private
     */
    public function set itemRendererProviders(value:Array /* of OLAPDataGridItemRendererProvider */):void
    {
        //Sort them based on their priority, so that one with high proprity
        // is on the top and get picked up
        _itemRendererProviders = value.sort(compareFunction);

        cellRenderersMap = [];
        var n:int = olapElements.length;
        for (var i:int = 0; i < n; i++)
        {
            cellRenderersMap[olapElements[i]] = new Dictionary(true);
        }
        
        n = _itemRendererProviders.length;
        for (i = 0; i < n; i++)
        {
            if(value[i].renderer)
            {
                itemsSizeChanged = true;
                rendererChanged = true;
            }
            cellRenderersMap[value[i].type][value[i].uniqueName] = i;
        }

        _itemRendererProvidersUnSorted = value;
        itemRendererProvidersChanged = true;
        invalidateDisplayList();
    }
    
    //----------------------------------
    //  headerRendererProviders
    //----------------------------------

    /**
     *  @private
     */
    private var _headerRendererProviders:Array /* of OLAPDataGridHeaderRendererProvider */ = [];;

    private var _headerRendererProvidersUnSorted:Array /* of OLAPDataGridHeaderRendererProvider */ = [];;

    /**
     *  Array of OLAPDataGridHeaderRendererProvider instances that specify a
     *  custom header renderer for the columns of the control. 
     *  You can use several header renderer providers to specify custom header renderers for 
     *  different columns the control.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get headerRendererProviders():Array /* of OLAPDataGridHeaderRendererProvider */
    {
        return _headerRendererProvidersUnSorted;
    }

    /**
     *  @private
     */
    public function set headerRendererProviders(value:Array /* of OLAPDataGridHeaderRendererProvider */):void
    {
        //Sort them based on their priority, so that one with high priority
        // is on the top and get picked up
        _headerRendererProviders = value.sort(compareFunction);

        var n:int = olapElements.length;
        headerRenderersMap = [];
        for (var i:int = 0; i < n; i++)
        {
            headerRenderersMap[olapElements[i]] = new Dictionary(true);
        }
        
        n = _headerRendererProviders.length;
        for (i = 0; i < n; i++)
        {
            if(value[i].renderer)
            {
                itemsSizeChanged = true;
                rendererChanged = true;
            }
            headerRenderersMap[value[i].type][value[i].uniqueName] = i;
        }

        _headerRendererProvidersUnSorted = value;
        headerRendererProvidersChanged = true;
        invalidateDisplayList();
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function setupRenderer(itemData:Object, uid:String, insertItems:Boolean = false):void
    {
        super.setupRenderer(itemData, uid, insertItems);
        var currentData:IList = itemData.members;

        if (!rowHeadersMap[uid])
            rowHeadersMap[uid] = [];
        if (!rowHeadersMap[uid][0] || !rowHeadersMap[uid][0].initialized)
        {
            // Gets called only if this is the first call to makeRowsAndColumns 
            // or when we have scrolled down vertically
            var i:int;
            while (i < currentRowLabels.length && currentData.getItemAt(i).name == currentRowLabels[i].member.name)
            {
                
                if(!rowHeadersMap[uid][i])
                    rowHeadersMap[uid][i] = new OLAPRowHeaderInfo();
                rowHeadersMap[uid][i].visible = false;
                rowHeadersMap[uid][i].renderer = currentRowLabels[i].renderer;
                rowHeadersMap[uid][i].initialized = true;
                listItems[currentRowNum][i].visible = false;
                i++;
            }
            
            currentRowLabels.splice(i);
            
            while (i < currentData.length)
            {
                if (!rowHeadersMap[uid][i])
                    rowHeadersMap[uid][i] = new OLAPRowHeaderInfo();
                rowHeadersMap[uid][i].visible = true;
                rowHeadersMap[uid][i].renderer = listItems[currentRowNum][i];
                rowHeadersMap[uid][i].initialized = true;

                listItems[currentRowNum][i].visible = true;
                currentRowLabels.push({member:currentData.getItemAt(i), renderer:listItems[currentRowNum][i]});
                i++;
            }
        }
        else
        {
            //If we already know that about visibilty of items of these row
            //use the stored info only
            var n:int = currentData.length;
            for ( i = 0; i < n; i++)
            {
                listItems[currentRowNum][i].visible = rowHeadersMap[uid][i].visible;
            }
        }
    }

    /**
     *  @private
     */
    override protected function makeListData(data:Object, uid:String, 
                                    rowNum:int, columnNum:int, column:AdvancedDataGridColumn):BaseListData
    {
        var adgListData:AdvancedDataGridListData;
        var m:IOLAPMember;
        
        if (!(data is AdvancedDataGridColumn))
        { 
            var label:String;
            //case when row headers are getting created
            if (groupItemRenderer && column.colNum < numHeaderCols)
            {
                m = IOLAPMember(data.members.getItemAt(column.colNum));
                label = m ? m.displayName: " ";
                // Checking for a groupLabelFunction or a groupLabelField property to be present
                adgListData = new AdvancedDataGridListData(label, column.dataField, 
                                                                        columnNum, uid, this, rowNum);
                //Calculate indent only if we are not just measuring
                if(!isMeasuring)
                    adgListData.indent = getIndent(IOLAPAxisPosition(data), m, columnNum);
                return adgListData;
                
            }
            //Case when cell data renderers are getting created, cells 
            //get their value by making getCell request on the olapData object
            else if (column.colNum >= numHeaderCols)
            {
                var absoluteRowNum:int = rowNum;

                // rowNum here is the index of this row in the listItems or in other 
                // words index in the visible rows on the screen
                // To get the index of this row in the dataProvider, add
                // verticalScrollPosition to it
                if (rowNum >= lockedRowCount)
                    absoluteRowNum += Math.max(0,verticalScrollPosition);

                var absoluteColNum:int =  column.colNum - numHeaderCols;
                
                var cell:IOLAPCell = olapData.getCell(absoluteRowNum, absoluteColNum);
                label = cell && !isNaN(cell.value) ? String(cell.value) : defaultCellString;

                var colPosn:IOLAPAxisPosition = IOLAPAxisPosition(columnAxis.getItemAt(absoluteColNum));

                if (data is IOLAPAxisPosition)
                    label = getFormattedCellValue(label, IOLAPAxisPosition(data), colPosn);
                else
                    label = getFormattedCellValue(label, null, colPosn);
                    
                var listData:AdvancedDataGridListData = new AdvancedDataGridListData(label, column.dataField, 
                                                                                     columnNum, uid, this, rowNum);
                return listData;
            }
        }
        return super.makeListData(data, uid, rowNum, columnNum, column) as AdvancedDataGridListData;
    }

    /**
     *  @private
     */
    override mx_internal function setupRendererFromData(c:AdvancedDataGridColumn, item:IListItemRenderer, data:Object):void
    {
        isMeasuring = true;
        super.setupRendererFromData(c, item, data);
        isMeasuring = false;
    }

    /**
     *  @private
     */
    override mx_internal function columnItemRendererFactory(c:AdvancedDataGridColumn, forHeader:Boolean, itemData:Object):IFactory
    {
        //Use the groupItemRenderer, if it is a row header or column header
        var factory:IFactory;
        if (!forHeader && c.colNum < numHeaderCols)
        {
            if(c.itemRenderer)
                factory = c.itemRenderer;
            else
                factory = groupItemRenderer;
        }
        else if(forHeader)
        {
            if(c.headerRenderer)
            {
                factory = c.headerRenderer;
            }
            else
            {
                var headerInfo:AdvancedDataGridHeaderInfo = getHeaderInfo(c);
                if(headerInfo && headerInfo.actualColNum >= numHeaderCols)
                    factory = groupItemRenderer;
            }
        }
        if (!factory)
        {
            factory = super.columnItemRendererFactory(c, forHeader, itemData);
        }

        return factory;
    }
    
    /**
     *  @private
     */
    override protected function getHeaderRenderer(c:AdvancedDataGridColumn):IListItemRenderer
    {
        var r:IListItemRenderer = super.getHeaderRenderer(c);
        
        // If this is that top-level column group which wraps 
        // axis headers in the renderer
        if ( c == hierarchiesHeaderColumn && columnAxis.length > 0)
        {
            var firstColumn:IList = IOLAPAxisPosition(columnAxis.getItemAt(0)).members ;
            var numHeaderRows:int = firstColumn.length;
            var factories:Array /* of IFactory */ = [];
            var hierarchies:Array /* of IOLAPHierarchy */ = [];
            
            for (var i:int = 0; i < numHeaderRows; i++)
            {
                hierarchies.push(firstColumn.getItemAt(i).hierarchy);
                factories.push(headerRenderer);
            }
            OLAPDataGridHeaderRenderer(r).factories = factories;
            OLAPDataGridHeaderRenderer(r).dataProvider = hierarchies;
        }
        return r;
        
    }
    
    /**
     *  @private
     */
    override protected function itemRendererToIndices(item:IListItemRenderer):Point
    {
        if (item && !isHeaderItemRenderer(item) && isCellSelectionMode())
        {
            var pt:Point = super.itemRendererToIndices(item);
            var columnIndex:int = displayToAbsoluteColumnIndex(pt.x);
            if(columnIndex < numHeaderCols)
                return null;
        }
         
        return super.itemRendererToIndices(item);
    }

    /**
     *  @private
     */
    override protected function drawRowBackground(s:Sprite, rowIndex:int,
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
        background.x = getRowHeadersWidth();

        // Height is usually as tall is the items in the row, but not if
        // it would extend below the bottom of listContent
        var height:Number = Math.min(height,
                                     listContent.height -
                                     y);

        var g:Graphics = background.graphics;
        g.clear();
        g.beginFill(color, getStyle("backgroundAlpha"));
        g.drawRect(0, 0, unscaledWidth - viewMetrics.left - viewMetrics.right, height);
        g.endFill();
    }
    
    /**
     *  @private
     */
    override protected function applyUserStylesForItemRenderer(givenItemRenderer:IListItemRenderer):void
    {
        if (!givenItemRenderer)
            return;

        if (!
            (
                // It should support all the following interfaces/inheritances
                givenItemRenderer is IStyleClient
                && givenItemRenderer is IDataRenderer
                && givenItemRenderer is DisplayObject
                && givenItemRenderer is IDropInListItemRenderer
                )
            )
        {
            return;
        }
        
        var listData:BaseListData = IDropInListItemRenderer(givenItemRenderer).listData;
        
        if(listData.columnIndex < numHeaderCols)
            return;

        var itemRenderer:IStyleClient = givenItemRenderer as IStyleClient;

        //Cell value
        var label:String = listData.label;
        var cellValue:Number = Number(label);

        //Row axis position
        var absoluteRowNum:int = listData.rowIndex;
        if (absoluteRowNum >= lockedRowCount)
            absoluteRowNum += Math.max(0,verticalScrollPosition) + Math.max(0, lockedRowCount);

        var rowPosn:IOLAPAxisPosition;
        //Row posn is null in case of blank or non IOLAPAxisPosition rows
        if (absoluteRowNum < rowAxis.length && rowAxis.getItemAt(absoluteRowNum) is IOLAPAxisPosition)
            rowPosn = IOLAPAxisPosition(rowAxis.getItemAt(absoluteRowNum));
        else
            rowPosn = null;

        //Column axis position
        var absoluteColNum:int =  listData.columnIndex - numHeaderCols;

        var colPosn:IOLAPAxisPosition = IOLAPAxisPosition(columnAxis.getItemAt(absoluteColNum));

        // 0. Make sure we have a dictionary
        if (!oldStyles)
        {
            oldStyles = new Dictionary(true); // use weakKeys
        }

        // 1. Reset to the default i.e. "old" styles
        var styleName:String;
        if (oldStyles[itemRenderer])
        {
            for (styleName in oldStyles[itemRenderer])
            {
                itemRenderer.setStyle(styleName, oldStyles[itemRenderer][styleName]);
            }
            delete oldStyles[itemRenderer];
        }

        // 2. Call the grid's styleFunction
        var newStyles:Object;
        if (styleFunction != null)
        {
            newStyles = styleFunction(rowPosn, colPosn, cellValue);
            if (newStyles)
            {
                for (styleName in newStyles)
                {
                    if (!oldStyles[itemRenderer])
                    {
                        oldStyles[itemRenderer] = {};
                    }

                    oldStyles[itemRenderer][styleName] = itemRenderer.getStyle(styleName);
                    itemRenderer.setStyle(styleName, newStyles[styleName]);
                }
            }
        }
    }

    /**
     *  @private
     *  For restricting the cell selection to cell data area
     *  fake the call to viewDisplayableColumnAtOffset call so that
     *  when a LEFT is pressed at the left most cell in the cell data 
     *  area it finds that there is nothing left to it.
     */
    override protected function viewDisplayableColumnAtOffset(columnIndex:int,
                                                     offset:int,
                                                     rowIndex:int=-1,
                                                     scroll:Boolean=true)
                                                     :int
    {
        var displayColumnIndex:int = absoluteToDisplayColumnIndex(columnIndex);
        if(displayColumnIndex == numHeaderCols && offset < 0)
            return -1;
        else
            return super.viewDisplayableColumnAtOffset(columnIndex, offset, rowIndex, scroll)
    }

    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        if(dataProviderChanged)
        {
            dataProviderChanged = false;
            
            var hasRowAxis:Boolean = false;
            var hasColumnAxis:Boolean = false;

            if(olapData)
            {
                //Initialize each of the axis, saving pointers helps because they are needed at many places
                rowAxis = olapData.getAxis(OLAPDataGrid.ROW_AXIS).positions;
                columnAxis = olapData.getAxis(OLAPDataGrid.COLUMN_AXIS).positions;

                //Slicer axis may be empty too
                if(olapData.getAxis(OLAPDataGrid.SLICER_AXIS))
                    slicerAxis = olapData.getAxis(OLAPDataGrid.SLICER_AXIS).positions;
                
                hasRowAxis = rowAxis && rowAxis.length;
                hasColumnAxis = columnAxis && columnAxis.length;
            }

            //In case there was no column axis found, a reset grid is required
            if(!hasColumnAxis)
            {
                numHeaderCols = 0;
                groupedColumns = [];
                lockedColumnCount = 0;
                super.dataProvider = null;
            }
            else
            {
                var rowAxisHeaderCols:Array /* of AdvancedDataGridColumn */ = [];
                // Take the first row and create the columns corresponding
                // to row headers
                if(hasRowAxis)
                {
                    var firstRow:IList = IOLAPAxisPosition(rowAxis.getItemAt(0)).members;
                    numHeaderCols = firstRow.length;
                    cachedMinRowIndents = [];

                    for (var i:int = 0; i < firstRow.length; i++)
                    {
                        //Find the hierarchy getting used, and use it as headerText for rowAxis headers;
                        var hierarchy:IOLAPHierarchy = firstRow.getItemAt(i).hierarchy;

                        var c:AdvancedDataGridColumn = new AdvancedDataGridColumn(hierarchy.displayName);

                        c.public::setStyle("fontWeight", "bold");
                        c.public::setStyle("verticalAlign", "center");

                        rowAxisHeaderCols.push(c);
                        cachedMinRowIndents.push(firstRow.getItemAt(i).level.depth);
                    }
                    lockedColumnCount = numHeaderCols;
                }
                //In case no rowAxis was specified or the the rowAxis returned was empty
                else
                {
                    var dummyRow:Object = {};
                    numHeaderCols = 0;
                    lockedColumnCount = 0;
                    //An empty list of members
                    dummyRow.members = new ArrayCollection([]);
                    rowAxis = new ArrayCollection([dummyRow]);
                }
                
                var colAxisHeaderCols:Array /* of AdvancedDataGridColumn */ = [generateCols()];
                groupedColumns = rowAxisHeaderCols.concat(colAxisHeaderCols);

                //Initialize other structures
                currentRowLabels = [];
                rowHeadersMap = new Dictionary(true);

                //Force to re-apply the rendererProviders
                if(headerRendererProviders && headerRendererProviders.length > 0
                   || itemRendererProviders && itemRendererProviders.length > 0)
                {
                    headerRendererProvidersChanged = true;
                    itemRendererProvidersChanged = true;
                    invalidateDisplayList();
                }

                super.dataProvider = rowAxis;
            }
        }
        super.commitProperties();
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function styleChanged(styleProp:String):void
    {
        if (styleProp == "rowAxisHeaderStyleName")
            applyNewAxisStyles(OLAPDataGrid.ROW_AXIS);
        else if (styleProp == "columnAxisHeaderStyleName")
            applyNewAxisStyles(OLAPDataGrid.COLUMN_AXIS);

        super.styleChanged(styleProp);
    }
    /**
     *  @private
     */
    override protected function createHeaders(left:Number, top:Number):void
    {
        //If as rowAxisHeaderStyleName has been defined, this is where we assign it
        applyNewAxisStyles(OLAPDataGrid.ROW_AXIS);

        super.createHeaders(left, top);

        //If as columnAxisHeaderStyleName has been defined, this is where we assign it
        applyNewAxisStyles(OLAPDataGrid.COLUMN_AXIS);
    }
    
    /**
     *  @private
     */
    override mx_internal function getRenderer(c:AdvancedDataGridColumn, itemData:Object, forDragProxy:Boolean = false):IListItemRenderer
    {
        var r:IListItemRenderer;

        if (c.colNum < numHeaderCols)
        {
            var member:IOLAPMember = IOLAPMember(itemData.members.getItemAt(c.colNum));

            var info:OLAPDataGridHeaderRendererProvider = OLAPDataGridHeaderRendererProvider(getRendererInfo(member, true));
            
            if (info)
            {
                if (info.renderer)
                    r = info.renderer.newInstance();
                else 
                    r = super.getRenderer(c, itemData);
                
                if (info.styleName)
                    r.styleName = info.styleName;
                
                return r;
            }
        }
        else
        {
            var column:IOLAPAxisPosition = IOLAPAxisPosition(columnAxis.getItemAt(c.colNum-numHeaderCols));
            var row:IOLAPAxisPosition = itemData is IOLAPAxisPosition ?  IOLAPAxisPosition(itemData) : null
            var itemInfo:OLAPDataGridItemRendererProvider = getCellRendererInfo(row, column);

            if (itemInfo)
            {
                if (itemInfo.renderer)
                    r = itemInfo.renderer.newInstance();
                else 
                    r = super.getRenderer(c, itemData);
                
                if (itemInfo.styleName)
                    r.styleName = itemInfo.styleName;
                
                return r;
            }
        }

        r = super.getRenderer(c, itemData, forDragProxy);
        r.styleName = c;
        
        return r;
    }

    /**
     *  @private
     */
    override protected function drawSelectionIndicator(indicator:Sprite, x:Number, y:Number, width:Number, height:Number, color:uint, itemRenderer:IListItemRenderer):void
    {
        if (isRowSelectionMode())
        {
            var offset:Number = getRowHeadersWidth();

            width = unscaledWidth - viewMetrics.left - viewMetrics.right - offset;
            var g:Graphics = Sprite(indicator).graphics;
            g.clear();
            g.beginFill(color);
            g.drawRect(0, 0, width, height);
            g.endFill();
        
            indicator.x = offset;
            indicator.y = y;
        }
        else
        {
            super.drawSelectionIndicator(indicator, x, y, width, height, color, itemRenderer);
        }
    }

    /**
     *  @private
     */
    override protected function drawHighlightIndicator(indicator:Sprite, x:Number, y:Number, width:Number, height:Number, color:uint, itemRenderer:IListItemRenderer):void
    {
        if (isRowSelectionMode())
        {
            var offset:Number = getRowHeadersWidth();
            
            width = unscaledWidth - viewMetrics.left - viewMetrics.right - offset;
            var g:Graphics = Sprite(indicator).graphics;
            g.clear();
            g.beginFill(color);
            g.drawRect(0, 0, width, height);
            g.endFill();
        
            indicator.x = offset;
            indicator.y = y;
        }
        else
        {
            super.drawHighlightIndicator(indicator, x, y, width, height, color, itemRenderer);
        }
            
    }

    /**
     *  @private
     */
    override protected function drawCaretIndicator(indicator:Sprite, x:Number, y:Number, width:Number, height:Number, color:uint, itemRenderer:IListItemRenderer):void
    {
        if (isRowSelectionMode())
        {
            var offset:Number = getRowHeadersWidth();

            width = unscaledWidth - viewMetrics.left - viewMetrics.right - offset;

            var g:Graphics = Sprite(indicator).graphics;
            g.clear();
            g.lineStyle(1, color, 1);
            g.drawRect(0, 0, width - 1, height - 1);
            
            indicator.x = offset;
            indicator.y = y;
        }
        else
        {
            super.drawCaretIndicator(indicator, x, y, width, height, color, itemRenderer);
        }
    }
    
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void    
    {
        if (headerRendererProvidersChanged || itemRendererProvidersChanged)
        {
            applyRenderer();
            headerRendererProvidersChanged = false;
            itemRendererProvidersChanged = false;
        }

        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        var headerBG:UIComponent =
            UIComponent(listContent.getChildByName("rowHeaderBG"));

        if (!headerBG)
        {
            headerBG = new UIComponent();
            headerBG.name = "rowHeaderBG";

            listContent.addChildAt(DisplayObject(headerBG), listContent.getChildIndex(selectionLayer));

            var headerBGSkinClass:Class = getStyle("headerBackgroundSkin");
            var headerBGSkin:IFlexDisplayObject = new headerBGSkinClass();

            if (headerBGSkin is ISimpleStyleClient)
                ISimpleStyleClient(headerBGSkin).styleName = this;
            headerBG.addChild(DisplayObject(headerBGSkin)); 
        }

        headerBG.visible = true;
        drawRowHeaderBackground(headerBG);
    }

    /**
     *  @private
     */
    override protected function drawLinesAndColumnBackgrounds():void
    {
        super.drawLinesAndColumnBackgrounds();
        
        if (getStyle("horizontalGridLines"))
            drawRowHeaderHorizontalSeparators();
    }
    
    /**
     *  @private
     */
    override protected function drawHorizontalLine(s:Sprite, rowIndex:int, color:uint, y:Number):void
    {
        var g:Graphics = s.graphics;

        var offset:Number = 0;

        for ( var i:int = 0; i < numHeaderCols; i++)
        {
            offset += columns[i].width;
        }

        if (lockedRowCount > 0 && rowIndex == lockedRowCount-1)
            g.lineStyle(1, 0);
        else
            g.lineStyle(1, color);

        g.moveTo(offset, y);
        g.lineTo(unscaledWidth - viewMetrics.left - viewMetrics.right, y);
    }

    /**
     *  @private
     *  In case of OLAPDataGrid, the locked column boundary
     *  needn't be black to make it look like column headers
     *  
     */
    override protected function drawVerticalLine(s:Sprite, colIndex:int, color:uint, x:Number):void
    {
        //draw our vertical lines
        var g:Graphics = s.graphics;
        if (lockedColumnCount > 0 && colIndex == lockedColumnCount - 1)
            g.lineStyle(1, color, 100);
        else
            super.drawVerticalLine(s, colIndex, color, x);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  A small compare function to sort the renderProvider according to their priority(type)
     *  so that one with higher priority comes first at gets picked up
     */
    private function compareFunction(a:OLAPDataGridRendererProvider, b:OLAPDataGridRendererProvider):int
    {
        if(a.type > b.type)
            return -1;
        else if (a.type < b.type)
            return 1;
        else
            return 0;
        
    }
    
    /**
     *  @private
     */
    private function generateGroup(start:int, end:int=-1):Array /* of AdvancedDataGridColumn */
    {
        if(end == -1 || end > columnAxis.length)
            end = columnAxis.length;
        
        if(end < start)
            return [];
        
        //A dummy parent, to handle edge cases.
        var root:AdvancedDataGridColumnGroup = new AdvancedDataGridColumnGroup();
        
        var currentGroupObjects:Array /* of AdvancedDataGridColumn */ = [];
        var currentGroups:Array /* of AdvancedDataGridColumn */ = [];

        for (var i:int = start; i < end; i++)
        {
            var currentData:IList = IOLAPAxisPosition(columnAxis.getItemAt(i)).members ;
            
            var k:int = 0;

            //We need to compare by the member object and not their names (as opposed to what we do in groupingCollection)
            while (k < currentData.length 
                  && currentData[k] == currentGroupObjects[k])
                k++;
            
            //If all members are same, it means the OLAPPosition is repeated and we need to handle this one also
            if (k > 0 && k == currentData.length) 
                k--;

            currentGroupObjects.splice(k);
            currentGroups.splice(k);

            while (k < currentData.length)
            {
                var parent:AdvancedDataGridColumnGroup = (k > 0)? currentGroups[k-1] : root;
                var c:AdvancedDataGridColumn;

                if (k == currentData.length - 1)
                {
                    c = new AdvancedDataGridColumn(currentData.getItemAt(k).displayName);
                }
                else
                {
                    c = new AdvancedDataGridColumnGroup(currentData.getItemAt(k).displayName);
                    AdvancedDataGridColumnGroup(c).children = [];
                }

                columnNames[c] = currentData.getItemAt(k);
                currentGroups.push(c);
                currentGroupObjects.push(currentData[k]);
                parent.children.push(c);
                k++;
            }
        }
        return root.children;
    }
    
    /**
     *  @private
     */
    private function generateCols():AdvancedDataGridColumnGroup
    {
        columnNames = new Dictionary();

        var root:AdvancedDataGridColumnGroup = new AdvancedDataGridColumnGroup();

        root.children = generateGroup(0);
        
        hierarchiesHeaderColumn = root;

        // OLAPDataGridHeaderRenderer acts as a wrapper, which wraps all the hierarchies header 
        // in a UIComponent
        root.headerRenderer = new ClassFactory(OLAPDataGridHeaderRenderer);
        
        return root;
    }

    /**
     *  Applies the formatting associated with a particular cell to a String value.
     *  A cell falls at the intersection of a position on row as well as
     *  column axis. 
     *
     *  @param label The String value to be formatted.
     *
     *  @param row The position of the cell in a row axis with an associated formatter.
     *
     *  @param column The position of the cell in a column axis with an associated formatter.
     *
     *  @return The formatted value of <code>label</code>,
     *  or <code>label</code> if the cell does not exist or the cell does not have a formatter applied to it.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function getFormattedCellValue(label:String, row:IOLAPAxisPosition, col:IOLAPAxisPosition):String
    {
        var itemInfo:OLAPDataGridItemRendererProvider = getCellRendererInfo(row, col);
        
        if(itemInfo && itemInfo.formatter)
            return applyFormatting(label, itemInfo.formatter);
        
        return label;
    }
    

    /**
     *  Returns the indent, in pixels, of the label in a renderer.
     *
     *  @param position The position of the renderer on the axis.
     *
     *  @param m The member of the dimension to which the indent is requested.
     *
     *  @param mIndex The index of <code>m</code> in <code>position.members</code>.
     *
     *  @return The indent, in pixels, of the label in a renderer.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function getIndent(position:IOLAPAxisPosition, m:IOLAPMember, mIndex:int):int
    {
        var indent:int = 0;
        var uid:String = itemToUID(position);

        //Like visiblity info, if we know the indent then use that
        if(rowHeadersMap[uid] && rowHeadersMap[uid][mIndex])
        {
            indent = rowHeadersMap[uid][mIndex].indent;
        }
        else
        {
            var currentLevel:int;
            
            //Decide the indent otherwise
            if (currentRowNum > 0)
            {
                var last:Array /* of IDataRenderer */ = listItems[currentRowNum - 1];
                if (mIndex < last.length)
                {
                    var l:IOLAPLevel = last[mIndex].data.members.getItemAt(mIndex).level;
                    var lastLevel:int = l ? l.depth : 0;
                    currentLevel = m.level ?  m.level.depth : 0;

                    //if level of item on the top is same as of this item, use the same indent
                    if(currentLevel == lastLevel)
                    {
                        indent = last[mIndex].listData.indent;
                    }
                    //else if it was less, this need to be indented more than that
                    else if(currentLevel > lastLevel)
                    {
                        indent = last[mIndex].listData.indent + (currentLevel - lastLevel) * getStyle("indentation");
                    }
                    // or less
                    else if (lastLevel > currentLevel)
                    {
                        indent = last[mIndex].listData.indent + (currentLevel - lastLevel) * getStyle("indentation");
                        indent = indent >= 0 ? indent : last[mIndex].listData.indent;
                    }
                }
            }
            else
            {
                currentLevel = m.level ?  m.level.depth : 0;
                if(cachedMinRowIndents && mIndex < cachedMinRowIndents.length)
                    indent = Math.max(0, (currentLevel - cachedMinRowIndents[mIndex]) * getStyle("indentation"));
            }

            //Update the structures, so that while scrolling it doesn't have to calculate again
            if(!rowHeadersMap[uid])
                rowHeadersMap[uid] = [];
            if(!rowHeadersMap[uid][mIndex])
                rowHeadersMap[uid][mIndex] = new OLAPRowHeaderInfo();
            
            rowHeadersMap[uid][mIndex].indent = indent;
        }
        
        return indent;
    }
    
    /**
     * @private
     */
    mx_internal function columnToAxisPosition(c:AdvancedDataGridColumn):Object
    {
        var headerInfo:AdvancedDataGridHeaderInfo = getHeaderInfo(c);
        var position:IOLAPAxisPosition = IOLAPAxisPosition(seekColumn(headerInfo.actualColNum - numHeaderCols));
        var m:IOLAPMember = position.members[headerInfo.depth];
        return {member:m, position:position, positionIndex:headerInfo.actualColNum, memberIndex:headerInfo.depth};
    }

    /**
     * @private
     * Seek a particular column and return the IOLAPAxisPosition
     */
    private function seekColumn(seekPosition:int):Object
    {
        var value:Object = null;
        try
        {
            value = columnAxis.getItemAt(seekPosition);
        }
        catch (e:ItemPendingError)
        {
        }
        return value;
    }

    /**
     * @private
     *
     */
    private function applyRenderer():void
    {
        var n:int = orderedHeadersList ? orderedHeadersList.length : 0;
        var i:int;
        
        for (i = numHeaderCols + 1; i < n; i++)
        {
            var c:AdvancedDataGridColumn = orderedHeadersList[i].column;

            if (headerRendererProvidersChanged)
            {
                var info:OLAPDataGridHeaderRendererProvider = OLAPDataGridHeaderRendererProvider(getRendererInfo(IOLAPMember(columnNames[c]), true));
                
                if (info)
                {
                    if (info.renderer)
                        c.headerRenderer = info.renderer;
                    if (info.headerWordWrap)
                        c.headerWordWrap = info.headerWordWrap;
                    if (info.styleName)
                        c.public::setStyle("headerStyleName", info.styleName);
                }
            }
        }
    }

    /**
     *  @private
     *  Decide the word wrap for this row header
     *  Called by the renderer to decide by wordwrap has to be applied or not
     *
     */
    mx_internal function rowHeaderWordWrap(m:IOLAPMember):Boolean
    {
        var info:OLAPDataGridHeaderRendererProvider = OLAPDataGridHeaderRendererProvider(getRendererInfo(m, true));
        return info && info.headerWordWrap;
    }
    
    /**
     *  @private
     *
     */
    private function getRowHeadersWidth():Number
    {
        var offset:Number = 0;//getAdjustedXPos(0)* (-1);
        
        for (var i:int = 0; i < numHeaderCols; i++)
        {
            offset += columns[i].width;
        }

        return offset;
    }
    
    /**
     *  @private
     *
     */
    private function applyNewAxisStyles(axisNum:int):void
    {
        if (axisNum == OLAPDataGrid.COLUMN_AXIS)
        {
            var styleVal:* = getStyle("columnAxisHeaderStyleName");
            
            if (styleVal)
            {
                var r:IStyleClient = orderedHeadersList[numHeaderCols].headerItem as IStyleClient;
                if (r)
                {
                    var styleVal2:* = r.getStyle("axisHeaderStyleName");
                    
                    if (styleVal2!= styleVal)
                        r.setStyle("axisHeaderStyleName", styleVal);
                }
            }
        }
        else if (axisNum == OLAPDataGrid.ROW_AXIS)
        {
            var i:int;
            if (getStyle("rowAxisHeaderStyleName"))
            {
                var styleValue:* = getStyle("rowAxisHeaderStyleName");
                for (i = 0; i < numHeaderCols; i++)
                {
                    orderedHeadersList[i].column.public::setStyle("headerStyleName", styleValue);
                }
            }
        }
    }
    
    /**
     *  @private
     *
     */
    private function drawRowHeaderHorizontalSeparators():void
    {
        var lines:Sprite = Sprite(listContent.getChildByName("lockedContent"));
        if (!lines)
        {
            lines = new UIComponent();
            lines.name = "lockedContent";
            lines.cacheAsBitmap = true;
            lines.mouseEnabled = false;
            listSubContent.addChild(lines);
            listSubContent.setChildIndex(lines, listContent.numChildren - 1);
        }

        var linesBody:Sprite = Sprite(lines.getChildByName("horizontalRowHeaderLines"));

        if (!linesBody)
        {
            linesBody = new UIComponent();
            linesBody.name = "horizontalRowHeaderLines";
            lines.addChild(linesBody);
        }

        // clear the horizontal lines and draw them again
        linesBody.graphics.clear();

        // draw horizontalGridlines if needed.
        var lineCol:uint = getStyle("horizontalGridLineColor");
        
        var n:int = listItems.length;
        for (var i:int = 0; i < n; i++)
        {
            drawRowHeaderHorizontalLine(linesBody, i, lineCol,rowInfo[i].y + rowInfo[i].height);
        }
    }
    
    /**
     *  @private
     */
    protected function drawRowHeaderHorizontalLine(s:Sprite, rowIndex:int, color:uint, y:Number):void
    {
        var g:Graphics = s.graphics;

        g.lineStyle(0, color);
        
        var offset:Number = 0;

        var lastPixel:int = offset;
        var i:int;
        if (listItems[rowIndex+1] && !listItems[rowIndex+1][0])
        {
            for (i = 0; i < numHeaderCols; i++)
            {
                g.moveTo(lastPixel, y);
                lastPixel +=  columns[i].width;
                g.lineTo(lastPixel, y);
            }
        }
        else
        {
            for (i = 0; i < numHeaderCols; i++)
            {
                g.moveTo(lastPixel, y);
                lastPixel +=  columns[i].width;
                if (listItems[rowIndex+1] && listItems[rowIndex+1][i] && listItems[rowIndex+1][i].visible)
                    g.lineTo(lastPixel, y);
            }
        }

    }

    /**
     *  @private
     */
    protected function drawRowHeaderBackground(headerBG:UIComponent):void
    {
        var tot:Number = unscaledHeight - viewMetrics.top - viewMetrics.bottom;
        var hh:Number = 0;
        
        if (headerVisible)
        {
            hh = headerRowInfo.length ? headerRowInfo[0].height : headerHeight;
            tot -= hh;
        }

        var g:Graphics = headerBG.graphics;
        g.clear();
        var colors:Array /* of int */= getStyle("headerColors");
        styleManager.getColorNames(colors);

        colors = [ colors[0], colors[0], colors[1] ];
        var ratios:Array /* of int */ = [ 0, 60, 255 ];
        var alphas:Array  /* of Number */= [ 1.0, 1.0, 1.0 ];

        var ww:Number = 0;
        for (var i:int = 0; i < numHeaderCols; i++)
        {
            ww += columns[i].width;
        }

        var matrix:Matrix = new Matrix();
        matrix.createGradientBox(ww, tot + 1, 0, 0, 0);
        g.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
        g.lineStyle(0, 0x000000, 0);
        
        g.moveTo(0, hh-0.5);
        g.lineTo(0, tot+hh);
        g.lineTo(ww - 0.5, tot+hh);
        g.lineStyle(0, getStyle("borderColor"), 100);
        g.lineTo(ww-0.5, hh-0.5);

        g.endFill();
    }

    /**
     *  @private
     */
    private function applyFormatting(data:String, formatter:Formatter):String
    {
        if (formatter != null && data != null)
        {
            var label:String = formatter.format(data);

            // Silently ignore formatter errors. For example, errors occur when
            // the property corresponding to the dataField is not present in the
            // row object i.e. it'll be empty
            if (formatter.error)
                return null;

            return label;
        }
        else
        {
            return data;
        }
    }

    /**
     *  Decide which renderer to use for the particular cell.
     *  A cell falls at the intersection of a position on row as well as
     *  column axis, thus it can fall in rules defined by the
     *  <code>itemRendererProviders</code> property for both axis.
     *  This method gives row axis a priority and searches for the
     *  the right value of the <code>itemRendererProviders</code> property 
     *  to be used for the renderer.
     *
     *  @param row The position of the cell in a row axis.
     *
     *  @param column The position of the cell in a column axis.
     *
     *  @return The item renderer to use for the cell at the intersection 
     *  of the row and column axis.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function getCellRendererInfo(row:IOLAPAxisPosition, column:IOLAPAxisPosition):OLAPDataGridItemRendererProvider
    {
        var m:int = numHeaderCols - 1;
        var itemInfo:OLAPDataGridItemRendererProvider;
        var member:IOLAPMember;

        // We need to start from the right most row header column
        // from right to left to prioritize headers which are on right
        // For example, if there is a row (Flex, 2001) | 233 123 231 245
        // and rendererProviders has been as assigned for both of them
        // then we should pick one specified for 2001
        while (m >= 0)
        {
            member = IOLAPMember(row.members.getItemAt(m));
            itemInfo = OLAPDataGridItemRendererProvider(getRendererInfo(member, false));
            
            if (itemInfo)
                return itemInfo;
            m--;
        }
        
        // If there is no itemRendererProvider defined for this cell 
        // via row headers check if there is one from columns side
        m = 0;
        while (m < column.members.length)
        {
            member = IOLAPMember(column.members.getItemAt(m));
            itemInfo = OLAPDataGridItemRendererProvider(getRendererInfo(member, false));
            
            if (itemInfo)
                return itemInfo;
            m++;
        }
        return null;
    }

    /**
     *  @private
     */
    private function getRendererInfo(m:IOLAPMember, forHeader:Boolean):OLAPDataGridRendererProvider
    {
        var map:Array /* of Dictionary */;
        if (forHeader)
            map = headerRenderersMap;
        else
            map = cellRenderersMap;
        
        if(!map)
            return null;

        var index:int = -1;
        var prop:String;
        
        var n:int = olapElements.length;
        for (var i:int = 0; i < n; i++)
        {
            if (olapElements[i] == OLAPDataGrid.OLAP_MEMBER)
                prop = m.uniqueName;
            else if (olapElements[i] == OLAPDataGrid.OLAP_LEVEL)
                prop = m.level.uniqueName;
            else if (olapElements[i] == OLAPDataGrid.OLAP_HIERARCHY)
                prop = m.hierarchy.uniqueName;
            else if (olapElements[i] == OLAPDataGrid.OLAP_DIMENSION)
                prop = m.dimension.uniqueName;

            if(map[olapElements[i]][prop]!=null)
            {
                index = map[olapElements[i]][prop];
                if(forHeader)
                    return headerRendererProviders[index];
                else
                    return itemRendererProviders[index];
                break;
            }
        }
        return null;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function mouseOverHandler(event:MouseEvent):void
    {
        //Because columns are not sortable here, we need not show a sprite
        // on mouse over
        var hh:Number = headerRowInfo.length ? headerRowInfo[0].height : headerHeight;
        var pt:Point = new Point(event.stageX, event.stageY);
        pt = listContent.globalToLocal(pt);
        
        if(pt.y < hh)
            return;
        else
            super.mouseOverHandler(event);
    }

    /**
     *  @private
     */
    override protected function keyDownHandler(event:KeyboardEvent):void
    {
        if (!(headerVisible && selectedIndex == 0 && caretIndex == 0
                 && event.keyCode == Keyboard.UP
                 && !event.ctrlKey && !event.shiftKey
            ||
            event.keyCode == Keyboard.UP 
            && caretIndex == 0 
              && selectedIndex == -1))
            super.keyDownHandler(event);
    }    
}

}
import mx.olap.IOLAPMember;
import mx.controls.listClasses.IListItemRenderer;

/**
 * @private
 *
 */
class OLAPRowHeaderInfo
{
	//--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------   
    
    //----------------------------------
    // renderer
    //----------------------------------
    
    /**
     * @private
     * Needed for row spanning, first visible renderer in a row span
     *
     */
    public var renderer:IListItemRenderer;
    
    //----------------------------------
    // indent
    //----------------------------------
    
    /**
     * @private
     * indent used for this item
     *
     */
    public var indent:int;
    
    //----------------------------------
    // visible
    //----------------------------------

    /**
     * @private
     * item is made visible or not
     *
     */
    public var visible:Boolean
    
    //----------------------------------
    // initialized
    //----------------------------------
    
    /**
     * @private
     * set when a row corresponding
     * to this rowHeaderInfo is initialized
     *
     */
    public var initialized:Boolean;
}
