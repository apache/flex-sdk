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

package mx.charts
{

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;

import mx.charts.chartClasses.ChartBase;
import mx.charts.events.LegendMouseEvent;
import mx.charts.styles.HaloDefaults;
import mx.collections.ArrayCollection;
import mx.collections.ICollectionView;
import mx.collections.IList;
import mx.collections.ListCollectionView;
import mx.containers.Tile;
import mx.core.EdgeMetrics;
import mx.core.IUIComponent;
import mx.core.ScrollPolicy;
import mx.core.mx_internal;
import mx.styles.CSSStyleDeclaration;
import mx.core.IFlexModuleFactory;

use namespace mx_internal;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the user clicks on a LegendItem in the Legend control.
 *
 *  @eventType mx.charts.events.LegendMouseEvent.ITEM_CLICK
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="itemClick", type="mx.charts.events.LegendMouseEvent")]

/**
 *  Dispatched when the user presses the mouse button
 *  while over a LegendItem in the Legend control.
 *
 *  @eventType mx.charts.events.LegendMouseEvent.ITEM_MOUSE_DOWN
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="itemMouseDown", type="mx.charts.events.LegendMouseEvent")]

/**
 *  Dispatched when the user moves the mouse off of a LegendItem in the Legend.
 *
 *  @eventType mx.charts.events.LegendMouseEvent.ITEM_MOUSE_OUT
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="itemMouseOut", type="mx.charts.events.LegendMouseEvent")]

/**
 *  Dispatched when the user moves the mouse over a LegendItem in the Legend control.
 *
 *  @eventType mx.charts.events.LegendMouseEvent.ITEM_MOUSE_OVER
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="itemMouseOver", type="mx.charts.events.LegendMouseEvent")]

/**
 *  Dispatched when the user releases the mouse button
 *  while over a LegendItem in the Legend.
 *
 *  @eventType mx.charts.events.LegendMouseEvent.ITEM_MOUSE_UP
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="itemMouseUp", type="mx.charts.events.LegendMouseEvent")]

//--------------------------------------
//  Styles
//--------------------------------------

include "../styles/metadata/GapStyles.as"
include "../styles/metadata/PaddingStyles.as"

/**
 *  Background color of the component.
 *  You can either have a <code>backgroundColor</code>
 *  or a <code>backgroundImage</code>, but not both.
 *  Note that some components, like a Button, do not have a background
 *  because they are completely filled with the button face or other graphics.
 *  The DataGrid control also ignores this style.
 *  The default value is <code>undefined</code>.
 *  If both this style and the backgroundImage style are undefined,
 *  the control has a transparent background.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="backgroundColor", type="uint", format="Color", inherit="no")]

/**
 *  Bounding box style.
 *  The possible values are <code>"none"</code>, <code>"solid"</code>,
 *  <code>"inset"</code> and <code>"outset"</code>.
 *
 *  <p>Note: The <code>borderStyle</code> style is not supported by the
 *  Button control or the Panel container.
 *  To make solid border Panels, set the <code>borderThickness</code>
 *  property, and set the <code>dropShadow</code> property to
 *  <code>false</code> if desired.</p>
 *  
 *  @default "inset"
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="borderStyle", type="String", enumeration="inset,outset,solid,none", inherit="no")]

/**
 *  Specifies the label placement of the legend element.
 *  Valid values are <code>"top"</code>, <code>"bottom"</code>,
 *  <code>"right"</code>, and <code>"left"</code>.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="labelPlacement", type="String", enumeration="top,bottom,right,left", inherit="yes")]

/**
 *  Specifies the height of the legend element.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="markerHeight", type="Number", format="Length", inherit="yes")]

/**
 *  Specifies the width of the legend element.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="markerWidth", type="Number", format="Length", inherit="yes")]

/**
 *  Specifies the line stroke for the legend element.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="stroke", type="Object", inherit="no")]

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="defaultButton", kind="property")]
[Exclude(name="horizontalScrollPolicy", kind="property")]
[Exclude(name="icon", kind="property")]
[Exclude(name="label", kind="property")]
[Exclude(name="tileHeight", kind="property")]
[Exclude(name="tileWidth", kind="property")]
[Exclude(name="verticalScrollPolicy", kind="property")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[DefaultBindingProperty(destination="dataProvider")]

[DefaultTriggerEvent("itemClick")]

[IconFile("Legend.png")]

/**
 *  The Legend control adds a legend to your charts,
 *  where the legend displays the label for each data series in the chart
 *  and a key showing the chart element for the series.
 *  
 *  <p>You can initialize a Legend control by binding a chart control
 *  identifier to the Legend control's <code>dataProvider</code> property,
 *  or you can define an Array of LegendItem objects.</p>
 *
 *  @mxml
 *  
 *  <p>The <code>&lt;mx:Legend&gt;</code> tag inherits all the propertie
 *  of its parent classes and adds the following properties:</p>
 *  
 *  <pre>
 *  &lt;mx:Legend
 *    <strong>Properties</strong>
 *    dataProvider="<i>No default</i>"
 *    legendItemClass="<i>No default</i>"
 * 
 *    <strong>Styles</strong>
 *    backgroundColor="<i>undefined</i>"
 *    borderStyle="inset|none|solid|outset"
 *    horizontalGap="<i>8</i>"
 *    labelPlacement="right|left|top|bottom"
 *    markerHeight="15"
 *    markerWidth="10"
 *    paddingLeft="<i>0</i>"
 *    paddingRight="<i>0</i>"
 *    stroke="<i>IStroke; no default</i>"
 *    verticalGap="<i>6</i>"
 * 
 *    <strong>Events</strong>
 *    itemClick="<i>Event; no default</i>"
 *    itemMouseDown="<i>Event; no default</i>"
 *    itemMouseOut="<i>Event; no default</i>"
 *    itemMouseOver="<i>Event; no default</i>"
 *    itemMouseUp="<i>Event; no default</i>"
 *  /&gt;
 *  </pre>
 *
 *  @see mx.charts.LegendItem
 *
 *  @includeExample examples/PlotChartExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class Legend extends Tile
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class initialization
    //
    //--------------------------------------------------------------------------
    

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
    public function Legend()
    {
        super();

        direction = "vertical";

        addEventListener(MouseEvent.CLICK, childMouseEventHandler);
        addEventListener(MouseEvent.MOUSE_OVER, childMouseEventHandler);
        addEventListener(MouseEvent.MOUSE_OUT, childMouseEventHandler);
        addEventListener(MouseEvent.MOUSE_UP, childMouseEventHandler);
        addEventListener(MouseEvent.MOUSE_DOWN, childMouseEventHandler);

        _dataProvider = new ArrayCollection();
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private var _moduleFactoryInitialized:Boolean = false;
	
    /**
     *  @private
     */
    private var _preferredMajorAxisLength:Number;
    
    /**
     *  @private
     */
    private var _actualMajorAxisLength:Number;
    
    /**
     *  @private
     */
    private var _childrenDirty:Boolean = false;

    /**
     *  @private
     */
    private var _unscaledWidth:Number;
    
    /**
     *  @private
     */
    private var _unscaledHeight:Number;

    /**
     *  @private
     */
    private static var legendItemLinkage:LegendItem = null;

    /**
     *  @private
     */
    private var _dataProviderChanged:Boolean = false;

    //--------------------------------------------------------------------------
    //
    //  Overridden properties: Container
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  horizontalScrollPolicy
    //----------------------------------

    /**
     *  @private
     */
    override public function get horizontalScrollPolicy():String
    {
        return ScrollPolicy.OFF;
    }

    /**
     *  @private
     */
    override public function set horizontalScrollPolicy(value:String):void
    {
    }

    //----------------------------------
    //  verticalScrollPolicy
    //----------------------------------

    /**
     *  @private
     */
    override public function get verticalScrollPolicy():String
    {
        return ScrollPolicy.OFF;
    }

    /**
     *  @private
     */
    override public function set verticalScrollPolicy(value:String):void
    {
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  dataProvider
    //----------------------------------

    /**
     *  @private
     *  Storage for the dataProvider property.
     */
    private var _dataProvider:Object;
    
    [Bindable("collectionChange")]
    [Inspectable(category="Data")]
    
    /**
     *  Set of data to be used in the Legend.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get dataProvider():Object
    {
        return _dataProvider;
    }

    /**
     *  @private
     */
    public function set dataProvider(
                            value:Object /* String, ViewStack or Array */):void
    {
        if (_dataProvider is ChartBase)
        {
            _dataProvider.removeEventListener("legendDataChanged",
                                              legendDataChangedHandler);
        }

        _dataProvider = value ? value : [];

        if (_dataProvider is ChartBase)
        {
            // weak listeners to collections and dataproviders
            _dataProvider.addEventListener("legendDataChanged",
                                           legendDataChangedHandler, false, 0, true);
        }
        else if (_dataProvider is ICollectionView)
        {
        }
        else if (_dataProvider is IList)
        {
            _dataProvider = new ListCollectionView(IList(_dataProvider));
        }
        else if (_dataProvider is Array)
        {
            _dataProvider = new ArrayCollection(_dataProvider as Array);
        }
        else if (_dataProvider != null)
        {
            _dataProvider = new ArrayCollection([_dataProvider]);
        }
        else
        {
            _dataProvider = new ArrayCollection();
        }

        invalidateProperties();
        invalidateSize();
        _childrenDirty = true;

        dispatchEvent(new Event("collectionChange"));
    }

    //----------------------------------
    //  legendItemClass
    //----------------------------------

    /**
     *  The class used to instantiate LegendItem objects.
     *  When a legend's content is derived from the chart or data,
     *  it instantiates one instance of <code>legendItemClass</code>
     *  for each item described by the <code>dataProvider</code>.
     *  If you want custom behavior in your legend items, 
     *  you can assign a subclass of LegendItem to this property
     *  to have the Legend create instances of their derived type instead.  
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var legendItemClass:Class = LegendItem;

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: UIComponent
    //
    //--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private function initStyles():Boolean
	{
		HaloDefaults.init(styleManager);
		
		var o:CSSStyleDeclaration = HaloDefaults.createSelector("mx.charts.Legend", styleManager);
		
		o.defaultFactory = function():void
		{
			this.borderStyle = "none";
			this.horizontalGap = 20;
			this.maintainAspectRatio = true;
			this.paddingBottom = 5;
			this.paddingLeft = 5;
			this.paddingRight = 5;
			this.paddingTop = 5;
			this.verticalGap = 7;
		}
		
		return true;
	}
	
	/**
	 *  @inheritDoc
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	override public function set moduleFactory(factory:IFlexModuleFactory):void
	{
		super.moduleFactory = factory;
		
		if (_moduleFactoryInitialized)
			return;
		
		_moduleFactoryInitialized = true;
		
		// our style settings
		initStyles();
	}
	
    /**
     *  Processes the properties set on the component.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override protected function commitProperties():void
    {
        super.commitProperties();

        if (_childrenDirty)
        {
            populateFromArray(_dataProvider);
            _childrenDirty = false;
        }
    }

    /**
     *  Calculates the preferred, minimum, and maximum sizes of the Legend.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override protected function measure():void
    {
        super.measure();

        var minWidth:Number;
        var minHeight:Number;
        var preferredWidth:Number;
        var preferredHeight:Number;
        var vm:EdgeMetrics;
        var colCount:int;
        var i:int;
        var n:int;

        // Determine the size of each tile cell
        findCellSize();

        // Min width and min height are large enough to display a single child
        minWidth = cellWidth;
        minHeight = cellHeight;

        // Determine the width and height necessary to display the tiles in an
        // N-by-N grid (with number of rows equal to number of columns).
        var numChildren:int = this.numChildren;
        if (numChildren > 0)
        {
            var horizontalGap:Number = getStyle("horizontalGap");
            var verticalGap:Number = getStyle("verticalGap");
            var columns:Array /* of Number */;
            vm = viewMetricsAndPadding;
            var rowCount:int;

            // If an explicit dimension or flex is set for the majorAxis,
            // set as many children as possible along the axis.
            if (direction == "vertical")
            {
                var bCalcColumns:Boolean = false;
                
                if (!isNaN(explicitHeight))
                {
                    preferredHeight = explicitHeight - vm.top - vm.bottom;
                    bCalcColumns = true;
                }
                else if (!isNaN(_actualMajorAxisLength))
                {
                    preferredHeight = _actualMajorAxisLength * cellHeight +
                        (_actualMajorAxisLength - 1) * verticalGap;
                    _actualMajorAxisLength = NaN;
                    bCalcColumns = true;
                }

                if (bCalcColumns)
                {
                    columns = calcColumnWidthsForHeight(preferredHeight);
                    preferredWidth = 0;
                    colCount = columns.length;
                    n = colCount;
                    for (i = 0; i < n; i++)
                    {
                        preferredWidth += columns[i];
                    }
                    preferredWidth += (colCount - 1) * horizontalGap;
                    
                    rowCount = Math.min(numChildren,
                        Math.max(1, Math.floor(
                        (preferredHeight + verticalGap) /
                        (cellHeight + verticalGap))));
                    preferredHeight = rowCount * cellHeight +
                                      (rowCount - 1) * verticalGap;
                    _preferredMajorAxisLength = rowCount;
                }
                else
                {
                    // If we have flex,
                    // our majorAxis can contain all our children
                    preferredHeight = numChildren * cellHeight +
                                      (numChildren - 1) * verticalGap;
                    preferredWidth = cellWidth;
                    _preferredMajorAxisLength = numChildren;
                }
            }
            else
            {
                if (!isNaN(explicitWidth))
                {
                    // If we have an explicit height set,
                    // see how many children can fit in the given height.
                    preferredWidth = explicitWidth - vm.left - vm.right;
                }
                else if (!isNaN(_actualMajorAxisLength))
                {
                    preferredWidth = _actualMajorAxisLength - vm.left - vm.right;
                    _actualMajorAxisLength = NaN;
                }
                else
                {
                    preferredWidth = screen.width - vm.left - vm.right;
                }
                
                columns = calcColumnWidthsForWidth(preferredWidth);
                preferredWidth = 0;
                colCount = columns.length;
				n = colCount;
                for (i = 0; i < n; i++)
                {
                    preferredWidth += columns[i];
                }
                
                preferredWidth += (colCount - 1) * horizontalGap;
                rowCount = Math.ceil(numChildren / colCount);
                preferredHeight = rowCount * cellHeight +
                                  (rowCount - 1) * verticalGap;
                _preferredMajorAxisLength = colCount;
            }

        }
        else
        {
            preferredWidth = minWidth;
            preferredHeight = minHeight;
        }

        // Add extra for borders and margins.
        vm = viewMetricsAndPadding;
        var hExtra:Number = vm.left + vm.right;
        var vExtra:Number = vm.top + vm.bottom;
        minWidth += hExtra;
        preferredWidth += hExtra;
        minHeight += vExtra;
        preferredHeight += vExtra;

        measuredMinWidth = minWidth;
        measuredMinHeight = minHeight;
        measuredWidth = preferredWidth;
        measuredHeight = preferredHeight;
    }

    /**
     *  Sets the size and position of each child of the Legend.
     *  This is an advanced method for use in subclassing.
     *  If you override this method, your implementation should call 
     *  the <code>super.updateDisplayList()</code> method.
     *
     *  @param unscaledWidth Specifies the width of the component, in pixels,
     *  in the component's coordinates, regardless of the value of the
     *  <code>scaleX</code> property of the component.
     *
     *  @param unscaledHeight Specifies the height of the component, in pixels,
     *  in the component's coordinates, regardless of the value of the
     *  <code>scaleY</code> property of the component.   
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        _unscaledWidth = unscaledWidth;
        _unscaledHeight = unscaledHeight;

        // The measure function isn't called if the width and height of
        // the Tile are hard-coded.  In that case, we compute the cellWidth
        // and cellHeight now.
        if (isNaN(cellWidth))
            findCellSize();

        if (direction == "vertical")
            layoutVertical();
        else
            layoutHorizontal();
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private function addLegendItem(legendData:Object):void
    {
        var c:Class = legendItemClass;
        var newItem:LegendItem = new c();

        newItem.marker = legendData.marker;

        if (legendData.label != "")
            newItem.label = legendData.label;

        if (legendData.element)
            newItem.element = legendData.element;
        
        if ("fill" in legendData)
            newItem.setStyle("fill",legendData["fill"]);

        newItem.markerAspectRatio = legendData.aspectRatio;
        newItem.legendData = legendData;
        newItem.percentWidth = 100;
        newItem.percentHeight = 100;

        addChild(newItem);

        newItem.setStyle("backgroundColor", 0xEEEEFF);
    }

    /**
     *  @private
     */
    private function populateFromArray(dp:Object):void
    {
        if (dp is ChartBase)
            dp = dp.legendData;

        removeAllChildren();

        var curItem:Object;
		var n:int = dp.length;
        for (var i:int = 0; i < n; i++)
        {
            var curList:Array /* of LegendData */ = (dp[i] as Array);
            if (!curList)
            {
                curItem = dp[i];
                addLegendItem(curItem);
            }
            else
            {
                var m:int = curList.length;
                for (var j:int = 0; j < m; j++)
                    {
                    curItem = curList[j];
                    addLegendItem(curItem);
                }
            }
        }

        _actualMajorAxisLength = NaN;
    }

    /**
     *  @private
     *  Returns a numeric value for the align setting.
     *  0 = left/top, 0.5 = center, 1 = right/bottom
     */
    private function findHorizontalAlignValue():Number
    {
        var horizontalAlign:String = getStyle("horizontalAlign");

        if (horizontalAlign == "center")
            return 0.5;
        
        else if (horizontalAlign == "right")
            return 1;

        // default = left
        return 0;
    }

    /**
     *  @private
     *  Returns a numeric value for the align setting.
     *  0 = left/top, 0.5 = center, 1 = right/bottom
     */
    private function findVerticalAlignValue():Number
    {
        var verticalAlign:String = getStyle("verticalAlign");

        if (verticalAlign == "middle")
            return 0.5;
        
        else if (verticalAlign == "bottom")
            return 1;

        // default = top
        return 0;
    }

    /**
     *  @private
     */
    private function widthPadding(numChildren:Number):Number
    {
        var vm:EdgeMetrics = viewMetricsAndPadding;
        var padding:Number = vm.left + vm.right;

        if (numChildren > 1 && direction == "horizontal")
            padding += getStyle("horizontalGap") * (numChildren - 1);

        return padding;
    }

    /**
     *  @private
     */
    private function heightPadding(numChildren:Number):Number
    {
        var vm:EdgeMetrics = viewMetricsAndPadding;
        var padding:Number = vm.top + vm.bottom;

        if (numChildren > 1 && direction == "vertical")
            padding += getStyle("verticalGap") * (numChildren - 1);

        return padding;
    }

    /**
     *  @private
     */
    private function calcColumnWidthsForHeight(h:Number):Array /* of Number */
    {
        var n:Number = numChildren;
        
        var verticalGap:Number = getStyle("verticalGap");
        if (isNaN(verticalGap))
            verticalGap = 0;

        var rowCount:int = Math.min(n, Math.max(
            1, Math.floor((h + verticalGap) / (cellHeight + verticalGap))));

        var nColumns:int = rowCount == 0 ? 0: Math.ceil(n / rowCount);

        var columnSizes:Array /* of Number */;
        if (nColumns <= 1)
        {
            columnSizes = [cellWidth];
        }
        else
        {
            columnSizes = [];
            for (var i:int = 0; i < nColumns; i++)
            {
                columnSizes[i] = 0;
            }

            for (i = 0; i < n; i++)
            {
                var child:IUIComponent = IUIComponent(getChildAt(i));
                var col:int = Math.floor(i / rowCount);
                columnSizes[col] = Math.max(columnSizes[col],
                                            child.getExplicitOrMeasuredWidth());
            }
        }

        return columnSizes;
    }

    /**
     *  @private
     *  Bound the layout in the vertical direction
     *  and let it grow horizontally.
     */
    private function layoutVertical():void
    {
        var n:Number = numChildren;
        
        var vm:EdgeMetrics = viewMetricsAndPadding;
        
        var horizontalGap:Number = getStyle("horizontalGap");
        var verticalGap:Number = getStyle("verticalGap");
        
        var horizontalAlign:String = getStyle("horizontalAlign");
        var verticalAlign:String = getStyle("verticalAlign");

        var xPos:Number = vm.left;
        var yPos:Number = vm.top;
        var yEnd:Number = unscaledHeight - vm.bottom;

        var rowCount:int = Math.min(n, Math.max(1, Math.floor(
            (yEnd - yPos + verticalGap) / (cellHeight + verticalGap))));

        var columnSizes:Array /* of Number */ = [];

        columnSizes = calcColumnWidthsForHeight(yEnd - yPos);
        var nColumns:int = columnSizes.length;

        for (var i:Number = 0; i < n; i++)
        {
            var child:IUIComponent = IUIComponent(getChildAt(i));
            
            var col:int = Math.floor(i / rowCount);
            var colWidth:Number = columnSizes[col];

            var childWidth:Number;
            var childHeight:Number;
            
            if (child.percentWidth > 0)
            {
                childWidth = Math.min(colWidth,
                                      colWidth * child.percentWidth / 100);
            }
            else
            {
                childWidth = child.getExplicitOrMeasuredWidth();
            }
            
            if (child.percentHeight > 0)
            {
                childHeight = Math.min(cellHeight,
                                       cellHeight * child.percentHeight / 100);
            }
            else
            {
                childHeight = child.getExplicitOrMeasuredHeight();
            }
            
            child.setActualSize(childWidth, childHeight);

            //  Align the child in the cell.
            var xOffset:Number =
                Math.floor(calcHorizontalOffset(child.width, horizontalAlign));
            var yOffset:Number =
                Math.floor(calcVerticalOffset(child.height, verticalAlign));
            child.move(xPos + xOffset, yPos + yOffset);

            if ((i % rowCount) == rowCount - 1)
            {
                yPos = vm.top;
                xPos += (colWidth + horizontalGap);
            }
            else
            {
                yPos += (cellHeight + verticalGap);
            }
        }

        if (rowCount != _preferredMajorAxisLength)
        {
            _actualMajorAxisLength = rowCount;
            invalidateSize();
        }
    }

    /**
     *  @private
     */
    private function calcColumnWidthsForWidth(w:Number):Array /* of Number */
    {
        var n:Number = numChildren;

        var horizontalGap:Number = getStyle("horizontalGap");

        var xPos:Number = 0;
        var xEnd:Number = w;

        // first determine the max number of columns we can have;
        var nColumns:int = 0;
        var columnSizes:Array /* of Number */;

        for (var i:Number = 0; i < n; i++)
        {
            var child:IUIComponent = IUIComponent(getChildAt(i));
            var childPreferredWidth:Number = child.getExplicitOrMeasuredWidth();

            // start a new row?
            if (xPos + childPreferredWidth > xEnd)
            {
                break;
            }
            xPos += (childPreferredWidth + horizontalGap);

            nColumns++;
        }

        var columnsTooWide:Boolean = true;

        while (nColumns > 1 && columnsTooWide)
        {
            columnSizes = [];
            for (i = 0; i < nColumns; i++)
            {
                columnSizes[i] = 0;
            }
            for (i = 0; i < n; i++)
            {
                var col:int = i % nColumns;
                columnSizes[col] = Math.max(columnSizes[col],
                    IUIComponent(getChildAt(i)).getExplicitOrMeasuredWidth());
            }
            xPos = 0;

            for (i = 0; i < nColumns; i++)
            {
                if (xPos + columnSizes[i] > xEnd)
                    break;
                xPos += columnSizes[i] + horizontalGap;
            }
            if (i == nColumns)
                columnsTooWide = false;
            else
                nColumns--;
        }

        if (nColumns <= 1)
        {
            nColumns = 1;
            columnSizes = [cellWidth];
        }

        return columnSizes;
    }

    /**
     *  @private
     */
    private function layoutHorizontal():void
    {
        var n:Number = numChildren;
        
        var vm:EdgeMetrics = viewMetricsAndPadding;
        
        var horizontalGap:Number = getStyle("horizontalGap");
        var verticalGap:Number = getStyle("verticalGap")
        
        var horizontalAlign:String = getStyle("horizontalAlign");
        var verticalAlign:String = getStyle("verticalAlign");

        var xPos:Number = vm.left;
        var xEnd:Number = _unscaledWidth - vm.right;
        var yPos:Number = vm.top;

        // First determine the max number of columns we can have.
        var nColumns:int = 0;
        var columnSizes:Array /* of Number */;

        columnSizes = calcColumnWidthsForWidth(xEnd - xPos);
        nColumns = columnSizes.length;

        for (var i:Number = 0; i < n; i++)
        {
            var child:IUIComponent = IUIComponent(getChildAt(i));
            
            var col:int = i % nColumns;
            var colWidth:Number = columnSizes[col];

            var childWidth:Number;
            var childHeight:Number;
            
            if (child.percentWidth > 0)
            {
                childWidth = Math.min(colWidth,
                                      colWidth * child.percentWidth / 100);
            }
            else
            {
                childWidth = child.getExplicitOrMeasuredWidth();
            }
            
            if (child.percentHeight > 0)
            {
                childHeight = Math.min(cellHeight,
                                       cellHeight * child.percentHeight / 100);
            }
            else
            {
                childHeight = child.getExplicitOrMeasuredHeight();
            }
            
            child.setActualSize(childWidth, childHeight);

            // Align the child in the cell.
            var xOffset:Number =
                Math.floor(calcHorizontalOffset(child.width, horizontalAlign));
            var yOffset:Number =
                Math.floor(calcVerticalOffset(child.height, verticalAlign));
            child.move(xPos + xOffset, yPos + yOffset);

            if (col == nColumns - 1)
            {
                xPos = vm.left;
                yPos += (cellHeight + verticalGap);
            }
            else
            {
                xPos += (columnSizes[col] + horizontalGap);
            }
        }

        if (nColumns != _preferredMajorAxisLength)
        {
            _actualMajorAxisLength = _unscaledWidth;
            invalidateSize();
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private function legendDataChangedHandler(event:Event = null):void
    {
        invalidateProperties();
        invalidateSize();
        _childrenDirty = true;;
    }

    /**
     *  @private
     */
    private function childMouseEventHandler(event:MouseEvent):void
    {
        var p:DisplayObject = DisplayObject(event.target);

        while (p != this && p.parent != this)
        {
            p = p.parent;
        }

        if (p is LegendItem)
            dispatchEvent(new LegendMouseEvent(event.type, event, LegendItem(p)));
    }
}

}
