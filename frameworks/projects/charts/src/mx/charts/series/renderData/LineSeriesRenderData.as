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

/**
 *  Represents all the information needed by the LineSeries to render.  
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class LineSeriesRenderData extends RenderData
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
	 *	@param	cache	The list of LineSeriesItem objects representing the items in the dataProvider.
	 *	@param	filteredCache	The list of LineSeriesItem objects representing the items in the dataProvider that remain after filtering.
	 *	@param	validPoints	The number of points in the cache that are valid.
	 *	@param	segments	An Array of LineSeriesSegment objects representing each discontiguous segment of the LineSeries.
	 *	@param	radius	The radius of the individual items in the LineSeries.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function  LineSeriesRenderData(cache:Array /* of LineSeriesItem */ = null,
										  filteredCache:Array /* of LineSeriesItem */ = null,
										  validPoints:Number = 0,
										  segments:Array /* of LineSeriesSegment */ = null,
										  radius:Number = 0) 
	{
		super(cache, filteredCache);

		this.validPoints = validPoints;
		this.segments = segments;
		this.radius = radius;
	}

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
	//  radius
    //----------------------------------

	[Inspectable(environment="none")]

	/**
	 *  The radius of the individual items in the line series.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var radius:Number;
	
    //----------------------------------
	//  segments
    //----------------------------------

	[Inspectable(environment="none")]

	/**
	 *  An Array of LineSeriesSegment instances representing each discontiguous segment of the line series.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var segments:Array /* of LineSeriesSegment */;

    //----------------------------------
	//  validPoints
    //----------------------------------

	[Inspectable(environment="none")]

	/**
	 *  The number of points in the cache that were not filtered out by the axes.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var validPoints:Number;

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
		var newSegments:Array /* of LineSeriesSegment */ = [];
		
		var n:int = segments.length;
		for (var i:int = 0; i < n; i++)
		{
			newSegments[i] = segments[i].clone();
		}
		
		return new LineSeriesRenderData(cache, filteredCache, 
										validPoints, newSegments, radius);
	}
}

}