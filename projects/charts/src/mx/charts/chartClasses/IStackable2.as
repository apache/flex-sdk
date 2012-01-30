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
	
import flash.utils.Dictionary;
	
/**
 *  The IStackable2 interface is implemented by any series that can be stacked.
 *  Stacking sets (ColumnSet, BarSet, AreaSet) require that any sub-series
 *  assigned to it when stacking implement this interface if they should show
 *  negative values also while stacking.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IStackable2 extends IStackable
{	
	
//--------------------------------------------------------------------------
//
//  Methods
//
//--------------------------------------------------------------------------
/**
 *  Stacks the series. Normally, a series implements the <code>updateData()</code> method
 *  to load its data out of the data provider. But a stacking series performs special 
 *  operations because its values are not necessarily stored in its data provider. 
 *  Its values are whatever is stored in its data provider, summed with the values 
 *  that are loaded by the object it stacks on top of.
 *  <p>A custom stacking series should implement the <code>stack()</code> method by loading its 
 *  data out of its data provider, adding it to the base values stored in the dictionary
 *  to get the real values it should render with, and replacing the values in the dictionary 
 *  with its new, summed values.</p>
 *  
 *  @param stackedPosXValueDictionary Contains the base values that the series should stack 
 *  on top of. The keys in the dictionary are the x values, and the values are the positive
 *  x values.
 * 
 *  @param stackedNegXValueDictionary Contains the base values that the series should stack 
 *  on top of. The keys in the dictionary are the x values, and the values are the negative
 *  y values.
 *  
 *  @param previousElement The previous element in the stack. If, for example, the element
 *  is of the same type, you can use access to this property to avoid duplicate effort when
 *  rendering.
 *  
 *  @return An object representing the maximum and minimum values in the newly stacked series.	 
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
	function stackAll(stackedPosXValueDictionary:Dictionary,
				stackedNegXValueDictionary:Dictionary,
				previousElement:IStackable2):Object;
}

}