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
 *  The DataDescription structure is used by ChartElements to describe
 *  the characteristics of the data they represent to Axis objects
 *  that auto-generate values from the data represented in the chart.
 *	ChartElements displaying data should construct and return DataDescriptions
 *  from their <code>describeData()</code> method when invoked.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class DataDescription
{
    include "../../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------

	/**
	 *  A bitflag passed by the axis to an element's <code>describeData()</code> method.
	 *  If this flag is set, the element sets the 
	 *  <code>boundedValues</code> property.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const REQUIRED_BOUNDED_VALUES:uint = 0x2;
	
	/**
	 *  A bitflag passed by the axis to an element's <code>describeData()</code> method.
	 *  If this flag is set, the element sets the
	 *  <code>minInterval</code> property.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const REQUIRED_MIN_INTERVAL:uint = 0x1;
	
	/**
	 *  A bitflag passed by the axis to an element's <code>describeData()</code> method.
	 *  If this flag is set, the element sets the
	 *  <code>DescribeData.min</code> and <code>DescribeData.max</code> properties.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const REQUIRED_MIN_MAX:uint = 0x4;

	/**
	 *  A bitflag passed by the axis to an element's <code>describeData()</code> method.
	 *  If this flag is set, the element sets the
	 *  <code>DescribeData.padding</code> property.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const REQUIRED_PADDING:uint = 0x8;

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
	public function DataDescription()
	{
		super();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  boundedValues
	//----------------------------------
	
	[Inspectable(environment="none")]

	/** 
	 *  An Array of BoundedValue objects describing the data in the element.
	 *  BoundedValues are data points that have extra space reserved
	 *  around the datapoint in the chart's data area. 
	 *  If requested, a chart element fills this property
	 *  with whatever BoundedValues are necessary
	 *  to ensure enough space is visible in the chart data area.
	 *  For example, a ColumnSeries that needs 20 pixels
	 *  above each column to display a data label.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var boundedValues:Array /* of BoundedValue */;
	
	//----------------------------------
	//  max
	//----------------------------------

	[Inspectable(environment="none")]

	/**
	 *  The maximum data value displayed by the element.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var max:Number;
	
	//----------------------------------
	//  min
	//----------------------------------

	[Inspectable(environment="none")]

	/**
	 *  The minimum data value displayed by the element.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var min:Number;
	
	//----------------------------------
	//  minInterval
	//----------------------------------

	[Inspectable(environment="none")]

	/**
	 *  The minimum interval, in data units,
	 *  between any two values displayed by the element.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var minInterval:Number;
	
	//----------------------------------
	//  padding
	//----------------------------------

	[Inspectable(environment="none")]

	/**
	 *  The amount of padding, in data units, that the element requires
	 *  beyond its min/max values to display its full values correctly .
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var padding:Number;
}

}
