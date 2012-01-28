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
import mx.collections.ICollectionView;
import mx.collections.IList;
import mx.rpc.AsyncToken;

/**
 *  The IOLAPCube interface represents an OLAP cube that holds 
 *  an N-dimensional representation of a flat data set.
 *  You use an OLAP schema to define how the cube represents the 
 *  input flat data set.
 *
 *  <p>An OLAP cube is analogous to a table in a relational database. 
 *  Where a table in a relational database has two dimensions, 
 *  an OLAP cube can have any number of dimensions.
 *  In its simplest form, the dimensions of an OLAP cube correspond 
 *  to a field of the flat data set.</p>
 *
 *  <p>After setting the schema of the OLAP cube, you must call 
 *  the <code>IOLAPCube.refresh()</code> method to build the cube.
 *  Upon completion of cube initialization, the OLAP cube dispatches 
 *  the <code>complete</code> event to signal that the cube is ready to query.</p>
 *.
 *  @see mx.olap.OLAPCube
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IOLAPCube 
{
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  dimensions
    //----------------------------------
    
    /**
     *  All dimensions in the cube, as a list of IOLAPDimension instances.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get dimensions():IList; //of IOLAPDimensions
    
    //----------------------------------
    //  name
    //----------------------------------
    
    /**
     *  The name of the OLAP cube.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */     
    function get name():String;
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Aborts a query that has been submitted for execution.
     *
     *  @param query The query to abort.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function cancelQuery(query:IOLAPQuery):void;

    /**
     *  Aborts the current cube refresh, if one is executing.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function cancelRefresh():void;

    /**
     *  Queues an OLAP query for execution.
     *  After you call the <code>refresh()</code> method to update the cube, 
     *  you must wait for a <code>complete</code> event 
     *  before you call the <code>execute()</code> method.
     *
     *  <p>OLAP cubes can be complex, so you do not want your application 
     *  to pause while Flex calculates the results of your OLAP query. 
     *  The <code>execute()</code> method returns an instance of the AsyncToken class, 
     *  which lets you set up handlers for asynchronous operations so that 
     *  your application can continue to execute during query processing.</p>
     *
     *  <p>When using the AsyncToken class, you set up two functions to handle the query results. 
     *  In this example, the showResult() function handles the query results when the query succeeds, 
     *  and the showFault() function handles any errors detected during query execution: </p>
     *
     *  <pre>
     *  &lt;mx:Script&gt;
     *          
     *          // Function to execute a query.
     *          private function runQuery(cube:IOLAPCube):void {
     *              // Create a query instance.
     *              var query:IOLAPQuery = getQuery(cube);
     *              // Execute the query.
     *              var token:AsyncToken = cube.execute(query);
     *              // Set up handlers for the query results.
     *              token.addResponder(new AsyncResponder(showResult, showFault));
     *          }
     *          
     *          // Handle a query fault.
     *          private function showFault(result:FaultEvent, token:Object):void {
     *              Alert.show("Error in query.");
     *          }
     *  
     *          // Handle a query success.
     *          private function showResult(result:Object, token:Object):void {
     *              if (!result) {
     *                  Alert.show("No results from query.");
     *                  return;
     *              }
     *  
     *              myOLAPDG.dataProvider= result as OLAPResult;            
     *          }        
     *  &lt;/mx:Script&gt;
     *  
     *  &lt;mx:OLAPDataGrid id="myOLAPDG" width="100%" height="100%" /&gt;
     *  </pre> 
     *
     *  @param query The query to execute, represented by an IOLAPQuery instance.
     *
     *  @return An AsyncToken instance.
     *
     *  @see mx.rpc.AsyncToken
     *  @see mx.rpc.AsyncResponder
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function execute(query:IOLAPQuery):AsyncToken;
    
    /**
     *  Returns the dimension with the given name within the OLAP cube. 
     *
     *  @param name The name of the dimension.
     *
     *  @return An IOLAPDimension instance representing the dimension, 
     *  or null if a dimension is not found.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function findDimension(name:String):IOLAPDimension;

    /**
     *  Refreshes the cube from the data provider. 
     *  After setting the cube's schema, you must call this method to build the cube.
     *
     *  <p>This method dispatches a <code>progress</code> event to indicate progress,
     *  and dispatches a <code>complete</code> event when the cube is complete
     *  and ready to execute queries.
     *  You must wait for a <code>complete</code> event 
     *  before you call the <code>execute()</code> method to run a query.</p>
     *
     *  @see mx.events.CubeEvent
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function refresh():void;    
}
}