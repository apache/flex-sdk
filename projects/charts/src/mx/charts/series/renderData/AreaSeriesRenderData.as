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

package mx.charts.series.renderData
{

import mx.charts.chartClasses.RenderData;
import mx.charts.series.AreaSeries;

/**
 *  Represents all the information needed by the AreaSeries to render.  
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class AreaSeriesRenderData extends RenderData
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
     *  @param element The AreaSeries object that this structure is associated with.
     *  @param cache The list of AreaSeriesItem objects representing the items in the dataProvider.
     *  @param filteredCache The list of AreaSeriesItem objects representing the items in the dataProvider that remain after filtering.
     *  @param renderedBase The vertical position of the base of the area series, in pixels.
     *  @param radius The radius of the items of the AreaSeries.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function AreaSeriesRenderData(element:AreaSeries,
                                         cache:Array /* of AreaSeriesItem */ = null,
                                         filteredCache:Array /* of AreaSeriesItem */ = null,
                                         renderedBase:Number = 0,
                                         radius:Number = 0) 
    {
        super(cache,filteredCache);

        this.element = element;
        this.renderedBase = renderedBase;
        this.radius = radius;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  element
    //----------------------------------

    [Inspectable(environment="none")]

    /**
     *  The AreaSeries that this structure is associated with.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var element:AreaSeries;
    
    //----------------------------------
    //  radius
    //----------------------------------

    [Inspectable(environment="none")]

    /**
     *  The radius of the items of the AreaSeries.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var radius:Number;
    
    //----------------------------------
    //  renderedBase
    //----------------------------------

    [Inspectable(environment="none")]

    /**
     *  The vertical position of the base of the area series, in pixels.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var renderedBase:Number;
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override public function clone():RenderData
    {
        return new AreaSeriesRenderData(element, cache, filteredCache,
                                        renderedBase, radius);
    }
}

}
