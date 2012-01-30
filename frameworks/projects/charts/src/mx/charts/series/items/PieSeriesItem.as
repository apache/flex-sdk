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

package mx.charts.series.items
{

import flash.geom.Point;
import mx.charts.ChartItem;
import mx.charts.series.PieSeries;
import mx.core.IUITextField;
import mx.core.mx_internal;
import mx.graphics.IFill;

use namespace mx_internal;

/**
 *  Represents the information required
 *  to render a single wedge as part of a PieSeries.
 *  The PieSeries class passes these items to its itemRenderer when rendering.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class PieSeriesItem extends ChartItem
{
    include "../../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *
     *  @param element The owning series.
     *
     *  @param data The item from the dataProvider that this ChartItem represents .
     *
     *  @param index The index of the item from the series's dataProvider.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function PieSeriesItem(element:PieSeries = null,
                                  data:Object = null, index:uint = 0)
    {
        super(element, data, index);
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    mx_internal var labelText:String;
    
    /**
     *  @private
     */
    mx_internal var labelCos:Number;
    
    /**
     *  @private
     */
    mx_internal var labelSin:Number;
    
    /**
     *  @private
     */
    mx_internal var label:IUITextField;

    /**
     *  @private
     */
    mx_internal var labelX:Number;
    
    /**
     *  @private
     */
    mx_internal var labelY:Number;
    
    /**
     *  @private
     */
    mx_internal var labelWidth:Number;
    
    /**
     *  @private
     */
    mx_internal var labelHeight:Number;
    
    /**
     *  @private
     */
    mx_internal var next:PieSeriesItem;

    /**
     *  @private
     */
    mx_internal var prev:PieSeriesItem;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  angle
    //----------------------------------

    [Inspectable(environment="none")]

    /**
     *  The angle, in radians, that this wedge subtends.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var angle:Number;

    //----------------------------------
    //  fill
    //----------------------------------

    [Inspectable(environment="none")]

    /**
     *  The fill value associated with this wedge of the PieChart control.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var fill:IFill;

    //----------------------------------
    //  innerRadius
    //----------------------------------

    [Inspectable(environment="none")]

    /**
     *  The distance of the inner edge of this wedge from its origin, measured in pixels. If 0, the wedge should come to a point at the origin.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var innerRadius:Number;

    //----------------------------------
    //  labelAngle
    //----------------------------------

    [Inspectable(environment="none")]

    /**
     *  The angle of the label, in radians, for this wedge.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var labelAngle:Number;
    
    //----------------------------------
    //  number
    //----------------------------------

    [Inspectable(environment="none")]

    /**
     *  The value this wedge represents converted into screen coordinates.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var number:Number;

    //----------------------------------
    //  origin
    //----------------------------------

    [Inspectable(environment="none")]

    /**
     *  The origin, relative to the PieSeries's coordinate system, of this wedge.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var origin:Point;

    //----------------------------------
    //  outerRadius
    //----------------------------------

    [Inspectable(environment="none")]

    /**
     *  The distance of the outer edge of this wedge from its origin, measured in pixels.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var outerRadius:Number;

    //----------------------------------
    //  percentValue
    //----------------------------------

    [Inspectable(environment="none")]

    /**
     *  The percentage this value represents of the total pie.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var percentValue:Number;

    //----------------------------------
    //  startAngle
    //----------------------------------

    [Inspectable(environment="none")]

    /**
     *  The start angle, in radians, of this wedge.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var startAngle:Number;

    //----------------------------------
    //  value
    //----------------------------------

    [Inspectable(environment="none")]

    /**
     *  The value this wedge represents from the PieSeries' dataProvider.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var value:Object;

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Returns a copy of this ChartItem.
     */
    override public function clone():ChartItem
    {       
        var result:PieSeriesItem = new PieSeriesItem(PieSeries(element),item,index);
        result.itemRenderer = itemRenderer;
        return result;
    }
}

}
