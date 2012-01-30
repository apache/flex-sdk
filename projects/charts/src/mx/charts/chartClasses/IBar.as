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
 *  The IBar interface is implemented by any any series
 *  that can be clustered vertically, such as a BarSeries.
 *  The BarSet series type requires that any sub-series
 *  assigned to it implement this interface.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IBar
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

    //----------------------------------
	//  barWidthRatio
    //----------------------------------
	
	/**
	 *  Specifies how wide to render the items relative to the category.
	 *  A value of <code>1</code> uses the entire space, while a value
	 *  of <code>0.6</code> uses 60% of the category's available space. 
	 *  You typically do not set this property directly.
	 *  A governing BarSet or BarChart would implicitly assign this value.
	 *  The actual size used is the smaller of <code>barWidthRatio</code>
	 *  and the <code>maxbarWidth</code> property
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	function set barWidthRatio(value:Number):void;
	
    //----------------------------------
	//  maxBarWidth
    //----------------------------------

	/**
	 *  Specifies how wide to draw the items, in pixels.
	 *  The actual item width used is the smaller of this style
	 *  and the <code>barWidthRatio</code> property.
	 *  You typically do not set this property directly.
	 *  The BarSet or BarChart objects assign this value.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	function set maxBarWidth(value:Number):void;
	
    //----------------------------------
	//  offset
    //----------------------------------

	/**
	 *  Specifies how far to offset the center of the items
	 *  from the center of the available space, relative the category size. 
	 *  The range of values is a percentage in the range
	 *  <code>-100</code> to <code>100</code>. 
	 *  Set to <code>0</code> to center the items in the space.
	 *  Set to <code>-50</code> to center the item
	 *  at the beginning of the available space.
	 *  You typically do not set this property directly.
	 *  The BarSet or BarChart objects assign this value.
	 *
	 *  @default 0
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	function set offset(value:Number):void;
}

}
