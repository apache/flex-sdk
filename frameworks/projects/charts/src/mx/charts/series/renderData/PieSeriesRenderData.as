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

import mx.charts.chartClasses.RenderData

/**
 *  Represents all the information needed by the PieSeries to render.  
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class PieSeriesRenderData extends RenderData
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
	 *	@param	cache	The list of PieSeriesItem objects representing the items in the dataProvider.
	 *	@param	filteredCache	The list of PieSeriesItem objects representing the items in the dataProvider that remain after filtering.
	 *	@param	labelScale The scale factor of the labels rendered by the PieSeries.
	 *	@param	labelData A structure of data associated with the layout of the labels rendered by the PieSeries.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function  PieSeriesRenderData(cache:Array /* of PieSeriesItem */ = null,
										 filteredCache:Array /* of PieSeriesItem */ = null,
										 labelScale:Number = 1,
										 labelData:Object = null) 
	{
		super(cache, filteredCache);

		this.labelScale = labelScale;
		this.labelData = labelData
	}

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
	
    /**
	 *  The total sum of the values represented in the pie series.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var itemSum:Number;

	//----------------------------------
	//  labelData
    //----------------------------------

	[Inspectable(environment="none")]

	/**
	 *  A structure of data associated with the layout of the labels rendered by the pie series.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var labelData:Object;

    //----------------------------------
	//  labelScale
    //----------------------------------

	[Inspectable(environment="none")]

	/**
	 *  The scale factor of the labels rendered by the pie series.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var labelScale:Number;
	
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
		return new PieSeriesRenderData(cache, filteredCache,
									   labelScale, labelData);
	}
}

}
