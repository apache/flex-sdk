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
	
/**
 *  Describes the current state of a chart.
 *  Series implementations can examine the Chart.state value
 *  to determine whether the chart is showing or hiding data,
 *	and how to render in response.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public final class ChartState 
{
	include "../../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------

	/**
	 *  No state. The chart is simply showing its data.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const NONE:uint = 0;
	
	/**
	 *  The display of data has changed in the chart,
	 *  and it is about to begin a transition to hide the current data.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const PREPARING_TO_HIDE_DATA:uint = 1;
	
	/**
	 *  The chart is currently running transitions to hide the old chart data.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const HIDING_DATA:uint = 2;
	
	/**
	 *  The chart has finished any transitions to hide the old data,
	 *  and is preparing to run transitions to display the new data
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const PREPARING_TO_SHOW_DATA:uint = 3;
	
	/**
	 *  The chart is currently running transitions to show the new chart data.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const SHOWING_DATA:uint = 4;
}

}
