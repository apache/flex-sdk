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

package mx.olap
{

/**
 *  The IOLAPCustomAggregator interface defines the interface 
 *  implemented by custom aggregator classes.
 *  An instance of a class that implements this interface can be passed to an OLAPMeasure
 *  object to define the aggregation type of the measure. 
 *
 *  <p>You use the methods of this interface in two groups. The first group consists of the
 *  <code>computeBegin()</code>, <code>computeLoop()</code>, and <code>computeEnd()</code> methods. 
 *  Use these methods to compute an aggregation of the values of a measure.</p>
 *
 *  <p>The second group consists of the
 *  <code>computeObjectBegin()</code>, <code>computeObjectLoop()</code>, 
 *  and <code>computeObjectEnd()</code> methods. 
 *  Use these methods to compute an aggregation of aggregated values.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IOLAPCustomAggregator
{
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
    /**
     *  Flex calls this method to start the computation of an aggregation value.
     *
     *  @param dataField The name of the <code>OLAPMeasure.dataField</code> property
     *  for the measure to be aggregated.
     *
     *  @return An Object initialized for the aggregation. 
     *  Use this Object to hold any information necessary to perform the aggregation.
     *  You pass this Object to subsequent calls to the <code>computeLoop()</code> 
     *  and <code>computeEnd()</code> methods.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function computeBegin(dataField:String):Object;
    
    /**
     *  Flex calls this method when a new value needs to be added to the aggregation.
     *
     *  @param data The Object returned by the call to the <code>computeBegin()</code> method,
     *  or calculated by a previous call to the <code>computeLoop()</code> method. 
     *  Use this Object to hold information necessary to perform the aggregation.
     *  This method modifies this Object; it does not return a value.
     * 
     *  @param dataField The name of the <code>OLAPMeasure.dataField</code> property
     *  for the measure to be aggregated.
     *
     *  @param value The object representing the rows data that is being analyzed. 
     *
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function computeLoop(data:Object, dataField:String, value:Object):void;
    
    /**
     *  Flex calls this method to end the computation of the aggregation value. 
     *
     *
     *  @param data The Object returned by the call to the <code>computeLoop()</code> method.
     *  Use this Object to hold information necessary to perform the aggregation.
     * 
     *  @param dataField The name of the <code>OLAPMeasure.dataField</code> property
     *  for the measure to be aggregated.
     *
     *  @return The aggregated value.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function computeEnd(data:Object, dataField:String):Number;
    
    /**
     *  Flex calls this method to start aggregation of aggregated values. 
     *  Calculating the average value of a group of averages is an example of 
     *  an aggregation of aggregated values.
     *
     *  @param value The Object returned by the call to the <code>computeEnd()</code> method
     *  for a previous aggregation. 
     *  Use this Object to hold the information necessary to perform the aggregation.
     *
     *  @return An Object initialized for the aggregation. 
     *  Use this Object to hold any information necessary to perform the aggregation.
     *  You pass this Object to subsequent calls to the <code>computeObjectLoop()</code> 
     *  and <code>computeObjectEnd()</code> methods.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function computeObjectBegin(value:Object):Object;
    
    /**
     *  Flex calls this method when a new aggregated value needs to be added to the aggregation.
     *
     *  @param value The Object returned by a call the <code>computeObjectBegin()</code> method,
     *  or calculated by a previous call to the <code>computeObjectLoop()</code> method.
     *  This method modifies this Object; it does not return a value.
     *
     *  @param newValue The Object returned by the call to the <code>computeEnd()</code> method
     *  for a previous aggregation. 
     *
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function computeObjectLoop(value:Object, newValue:Object):void;
    
    /**
     *  Flex calls this method to end the computation. 
     *
     *  @param value The Object returned by a call to the <code>computeObjectLoop()</code> method
     *  that is used to store the aggregation results. 
     *  This method modifies this Object; it does not return a value.
     *
     *  @param dataField The name of the <code>OLAPMeasure.dataField</code> property
     *  for the measure to be aggregated.
     *
     *  @return The aggregated value.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function computeObjectEnd(value:Object, dataField:String):Number;
}

}