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

package mx.collections
{

/**
 *  The ISummaryCalculator interface defines the interface 
 *  implemented by custom summary calculator classes.
 *  An instance of a class that implements this interface can be passed
 *  to the <code>summaryOperation</code> property of the <code>SummaryField2</code> Class.
 *
 *  <p>Implement the methods of this interface in two groups. The first group consists of the
 *  <code>summaryCalculationBegin()</code>, <code>calculateSummary()</code>, and <code>returnSummary()</code> methods. 
 *  Use these methods to compute summary of the values.</p>
 *
 *  <p>The second group consists of the
 *  <code>summaryOfSummaryCalculationBegin()</code>, <code>calculateSummaryOfSummary()</code>, 
 *  and <code>returnSummaryOfSummary()</code> methods. 
 *  Use these methods to compute summary of summary values.</p>
 *
 *  @see mx.collections.SummaryField2
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public interface ISummaryCalculator
{
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Flex calls this method to start the computation of a summary value.
     *
     *  @param field The SummaryField2 for which the summary needs to calculated.
     *
     *  @return An Object initialized for the summary calculation. 
     *  Use this Object to hold any information necessary to perform the calculation.
     *  You pass this Object to subsequent calls to the <code>calculateSummary()</code> 
     *  and <code>returnSummary()</code> methods.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function summaryCalculationBegin(field:SummaryField2):Object;
    
    /**
     *  Flex calls this method when a new value needs to be added to the summary value.
     *
     *  @param data The Object returned by the call to the <code>summaryCalculationBegin()</code> method,
     *  or calculated by a previous call to the <code>calculateSummary()</code> method. 
     *  Use this Object to hold information necessary to perform the calculation.
     *  This method modifies this Object; it does not return a value.
     * 
     *  @param field The SummaryField2 for which the summary needs to calculated.
     *
     *  @param rowData The object representing the rows data that is being analyzed. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function calculateSummary(data:Object, field:SummaryField2, rowData:Object):void;
    
    /**
     *  Flex calls this method to end the computation of the summary value. 
     *
     *  @param data The Object returned by the call to the <code>calculateSummary()</code> method.
     *  Use this Object to hold information necessary to perform the calculation.
     * 
     *  @param field The SummaryField2 for which the summary needs to calculated.
     *
     *  @return The summary value.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function returnSummary(data:Object, field:SummaryField2):Number;
    
    /**
     *  Flex calls this method to start calculation of summary out of summary values. 
     *  Calculating the average value of a group of averages is an example of 
     *  an calculation of summary out of summary values.
     *
     *  @param value The Object returned by the call to the <code>calculateSummary()</code> method
     *  for a previous summary calculation. 
     *  Use this Object to hold the information necessary to perform the calculation.
     *  
     *  @param field The SummaryField2 for which the summary needs to calculated.
     *  
     *  @return An Object initialized for the summary calculation. 
     *  Use this Object to hold any information necessary to perform the calculation.
     *  You pass this Object to subsequent calls to the <code>calculateSummaryOfSummary()</code> 
     *  and <code>returnSummaryOfSummary()</code> methods.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function summaryOfSummaryCalculationBegin(value:Object, field:SummaryField2):Object;
    
    /**
     *  Flex calls this method when a new summary value needs to be added to the already computed summary.
     *
     *  @param value The Object returned by a call the <code>summaryOfSummaryCalculationBegin()</code> method,
     *  or calculated by a previous call to the <code>calculateSummaryOfSummary()</code> method.
     *  This method modifies this Object; it does not return a value.
     *
     *  @param newValue The Object returned by the call to the <code>returnSummary()</code> method
     *  for a previous aggregation.
     *  
     *  @param field The SummaryField2 for which the summary needs to calculated.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function calculateSummaryOfSummary(value:Object, newValue:Object, field:SummaryField2):void;
    
    /**
     *  Flex calls this method to end the summary calculation. 
     *
     *  @param value The Object returned by a call to the <code>calculateSummaryOfSummary()</code> method
     *  that is used to store the summary calculation results. 
     *  This method modifies this Object; it does not return a value.
     *
     *  @param field The SummaryField2 for which the summary needs to calculated.
     *
     *  @return The summary value.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function returnSummaryOfSummary(value:Object, field:SummaryField2):Number;
}
}