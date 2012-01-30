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
 *  Represents all the information needed by the HLOCSeries and CandlestickSeries objects to render.  
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class HLOCSeriesRenderData extends RenderData
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
	 *	@param	cache	The list of HLOCSeriesItem objects representing the items in the data provider.
	 *	@param	filteredCache	The list of HLOCSeriesItem objects representing the items in the data provider that remain after filtering.
	 *	@param	renderedHalfWidth	Half the width of an item, in pixels.
	 *	@param	renderedXOffset		The offset of each item from its x value, in pixels.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function  HLOCSeriesRenderData(cache:Array /* of HLOCSeriesItem */ = null,
										  filteredCache:Array /* of HLOCSeriesItem */ = null,
										  renderedHalfWidth:Number = 0,
										  renderedXOffset:Number = 0) 
	{
		super(cache, filteredCache);

		this.renderedHalfWidth = renderedHalfWidth;
		this.renderedXOffset = renderedXOffset;
	}

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
	//  renderedHalfWidth
    //----------------------------------

	[Inspectable(environment="none")]

	/**
	 *  Half the width of an item, in pixels.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var renderedHalfWidth:Number;

    //----------------------------------
	//  renderedXOffset
    //----------------------------------

	[Inspectable(environment="none")]

	/**
	 *  The offset of each item from its x value, in pixels.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var renderedXOffset:Number;

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
		return new HLOCSeriesRenderData(cache, filteredCache,
										renderedHalfWidth, renderedXOffset);
	}
}

}