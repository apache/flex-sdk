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

package mx.charts.chartClasses
{

import mx.core.IFlexDisplayObject;

/**
 *  The LegendData structure is used by charts to describe the items
 *  that should be displayed in an auto-generated legend.
 *  A chart's <code>legendData</code> property contains an Array
 *  of LegendData objects, one for each item in the Legend. 
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class LegendData
{
    include "../../core/Version.as";

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
	public function LegendData()
	{
		super();
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  aspectRatio
	//----------------------------------

	[Inspectable]

	/**
	 *  Determines
	 *  the size and placement of the legend marker.
	 *  If set, the LegendItem ensures that the marker's
	 *  width and height match this value.
	 *  If unset (<code>NaN</code>), the legend item chooses an appropriate
	 *  default width and height.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var aspectRatio:Number;
	
	//----------------------------------
	//  element
	//----------------------------------

	[Inspectable(environment="none")]

	/**
	 *  The chart item that generated this legend item.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var element:IChartElement;
	
	//----------------------------------
	//  label
	//----------------------------------

	[Inspectable]

	/**
	 *  The text identifying the series or item displayed in the legend item.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var label:String = "";
	
	//----------------------------------
	//  marker
	//----------------------------------

	[Inspectable]

	/**
	 *  A visual indicator associating the legend item
	 *  with the series or item being represented. 
	 *  This DisplayObject is added as a child to the LegendItem. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var marker:IFlexDisplayObject;
}

}
