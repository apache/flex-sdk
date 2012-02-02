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

import flash.utils.getTimer;

import mx.collections.ArrayCollection;
import mx.collections.CursorBookmark;
import mx.collections.IList;
import mx.collections.IViewCursor;
import mx.collections.ISort;
import mx.collections.ISortField;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.core.mx_internal;
import mx.events.CubeEvent;

use namespace mx_internal;

/**
 * @private
 */
public class DefaultCubeImpl implements IOLAPCubeImpl
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
	/**
	 * @private
	 * Arrays holding indices of valid rows and columns. 
	 * They are used to eliminate rows and columns which do not
	 * contain even a single valid value.  
	 */
    private var validRows:Array;
    private var validColumns:Array;
    
	/**
	 * @private
	 * Index of row currently being processed. 
	 */
    private var queryCubeRowIndex:int;
    
	/**
	 * @private
	 * Index of column currently being processed. 
	 */
    private var queryCubeColIndex:int;
    
	/**
	 * @private
	 * Indicates whether the query results cube has been built or not.
	 */
    private var queryCubeBuilt:Boolean;
    
	/**
	 * @private
	 * Indicates whether the tuples for the query has been built or not.
	 */
	private var queryTuplesBuilt:Boolean;
    
	/**
	 * @private
	 * progress and total values to be processed in the query 
	 */
	private var _queryProgress:int = 0;
	private var _queryTotal:int = 0;    

	/**
	 *  @private
	 *  A single query tuple.
	 */
	private var queryTuple:OLAPTuple;

	private var queryAxisPositions:Array;

    // the column positions on the result's column axis 
	private var colPositions:Array; // array of OLAPAxisPositions
	
    // the row positions on the result's row axis 
	private var rowPositions:Array; // array of OLAPAxisPositions
	
    // the slicer positions on the result's slicer axis 
	private var slicerPositions:Array;
	
	// the result object containing the query result 
	private var newResult:OLAPResult;
	
	// the column axis of the result
	private var colAxis:OLAPResultAxis;

	// the row axis of the result
	private var rowAxis:OLAPResultAxis;

	// the slicer axis of the result
	private var slicerAxis:OLAPResultAxis;
	
	// container for all the tuples in the query
	private var queryTuples:Array;

	//same as rowPositions/columnPositions/slierPositions
	private var colPos:IList;
	private var rowPos:IList;
	
	//the members on the slicer axis which need to be removed 
	//from the tuple to read aggregation result from the query cube
	private var removableSlicerMembers:IList;

	//if user has specified a measure on the slicer axis
	//this one would point to it
	private var measureInSlice:IOLAPMember;
	
    //private var tupleCubeMembers:Array = [];

	//array of all levels from all dimensions
    private var levels:Array; //of IOLAPLevels;
    
    //flag to indicate whether we are done with preparing
    //for building the cube
    private var prepared:Boolean = false;
    
    //the bookmark to keep track of the data row we are processing
    private var currentPosition:CursorBookmark = CursorBookmark.FIRST;
    
    //the dataProvider cursor
    private var iterator:IViewCursor = null;

	//saved sort value
    private var oldSort:ISort;
    
    //sort object used to gather members of dimensions 
    private var newSort:ISort;

	//Cube builder instance
    private var nodeBuilder:CubeNodeBuilder;
    
    //query cube builder instance
    private var queryCubeBuilder:QueryCubeBuilder;
	
	/**
	 *  @private
	 *  The function which should be invoked next, to build the query result.
	 *  Each action function has the following signature.
	 *      function action_fn_name(query:IOLAPQuery):Boolean
	 *  Each action function performs its work and after completion switches
	 *  the pointer to the next function that should be called.
	 *  The last function to get called should set the pointer back to the 
	 *  'prepareForNewQuery' function.
	 */
	private var actionFunction:Function = prepareForNewQuery;

	//flag indicates whether the query has a row axis or not
	private var validRowPositions:Boolean = true;
	
	//query row count can be zero when user has specified only column axis
	private var queryRowCount:int;
	
	//result row count is always > 0
	private var resultRowCount:int;
	
	//number of elements in the first query axis
	private var queryColCount:int;
	
	// a container to keep track of latest indices of query axis 
	// positions while tuples are being generated    
	private var tupleIndexObject:Object = {};
	
	//if true signals that we have finished generating
	//all the tuples.
	private var reachedEnd:Boolean = false;

	/*private var tempStartTime:int;
	private var tOnce:Boolean;
	private var cOnce:Boolean;
	private var rOnce:Boolean;
	
	private var totalRunCount:int = 0;
	private var totalTupleTime:Number = 0;
	private var totalCubeTime:Number = 0;
	private var totalResultTime:Number= 0;
	*/
	
	protected var queryProgressEventThreashold:int = 1000;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

	/**
	 * @private
	 * The cube on which the query is being run. 
	 */
    private var _cube:OLAPCube;
    
    public function set cube(c:IOLAPCube):void
    {
        _cube = c as OLAPCube;
    }

	/**
	 * Returns the number of query tuples which have been processed
	 * in the current iteration.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get queryProgress():int
	{
		return _queryProgress;
	}
	
	/**
	 * Returns the total number of query tuples being processed.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get queryTotal():int
	{
		return _queryTotal;
	}
	
	//--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
	 *  Populates the result object with axis and data values computed based
	 *  on the query. The computation happens in steps/stages. 
	 *  Returns true when the result is completely computed. A return value of
	 *  false indicates that the function needs to be called again to continue 
	 *  the operation.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */					   
    public function execute(query:IOLAPQuery, result:OLAPResult):Boolean
    {
        newResult = result;
        
        var startTime:int = getTimer();
        var actionResult:Boolean;
        var timeTaken:int;
        
        // if total time taken for a action is less than 10 ms 
        // call the action function again
        do
        {
            actionResult = actionFunction(query);
            timeTaken = getTimer() - startTime;
        } 
        while (!actionResult && timeTaken < 10);
        
        
        return actionResult;
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */ 
	public function cancelQuery(q:IOLAPQuery):void
	{
        actionFunction = prepareForNewQuery;
        
        //let us release all references
        queryCubeBuilder = null;
        validRows = validColumns = null;
        queryTuples = null;
	}
	
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */ 
	public function cancelRefresh():void
	{
        prepared = false;
        currentPosition = CursorBookmark.FIRST;
        iterator = null;
    
        if (newSort)            
        {
            _cube.dataProvider.sort = oldSort;
            _cube.dataProvider.refresh();
        }
	}
	
	public function refresh():void
    {
        //trace("Call buildCubeIteratively");
        //while (!buildCubeIteratively());
    }
    
    /**
	 *  @private
	 *  Updates the OLAP cube by processing one data row at a time.
	 *  Returns true when cube is completely built. A return value of false
	 *  indicates that this function needs to be called again to complete 
	 *  cube building.
	 */
    public function buildCubeIteratively():Boolean
    {
        if (!_cube.dataProvider)
            return true;
            
        var level:OLAPLevel;
        var attr:OLAPAttribute;
        
        if (!prepared)
        {
            levels = []; //of IOLAPLevels;

            // create as many levels as number of dimensions 
            for each (var dim:IOLAPDimension in _cube.dimensions)
            {
                //TODO should we skip this or just use this?
                if (dim.isMeasure)
                    continue;
                 
                for each (attr in dim.attributes)
                {
                	//include attributes which are not present in the hierarchy
                	if (!attr.userHierarchyLevel)
                        levels = levels.concat(attr.levels.toArray());
                }
                
                for each (var h:OLAPHierarchy in dim.hierarchies)
                {
                    levels = levels.concat(h.levels.toArray());
                }
            }
            
            // sort the data as it makes decision about completion of handling
            
            oldSort = _cube.dataProvider.sort; 
            
            //enable check to compare sort-cube performance
            //if (!oldSort)           
            {
                newSort = new Sort;
                var fields:Array = [];
                
                var field:ISortField ;
                for each (level in levels)
                {
                	if (level.attribute && level.attribute.userDataFunction)
                    {
                    	attr = level.attribute;
	                    field= new SortField(attr.dataField);
	                    field.compareFunction = attr.dataCompareFunction;
		                fields.push(field);
    	            }
                	else
                    {
	                    field= new SortField(level.dataField);
    	                fields.push(field);
    	            }
                }
                
                newSort.fields = fields;
                _cube.dataProvider.sort = newSort;
                _cube.dataProvider.refresh();
            }
            nodeBuilder = null;
            queryCubeBuilder = null;
            initNodeBuilder();
            prepared = true;

            iterator = _cube.dataProvider.createCursor();
            return false;
        }
        
        // go through each row of data
        iterator.seek(currentPosition);
        
        if (!iterator.afterLast && currentPosition != CursorBookmark.LAST)
        {
            var currentData:Object = iterator.current;
            // Signals the builder to prepare itself for a new data row.
            nodeBuilder.moveToNextRound();
            var values:Array = [];
            for each (level in levels)
            {
                // go through each dataField in the order of dimension (TODO or user specified order)
                var value:Object = level.dataFunction(currentData, level.dataField);
                values.push(value);
            }   
            nodeBuilder.addValueToNodeBuilder(values, currentData);
            
            iterator.moveNext();                
            currentPosition = iterator.bookmark;                
            return false;
        }
        else
        {
            if (!completeNodeBuilder())
            	return false;          
            prepared = false;
            currentPosition = CursorBookmark.FIRST;
            iterator = null;
        
            if (newSort)            
            {
                _cube.dataProvider.sort = oldSort;
                _cube.dataProvider.refresh();
            }
            return true;
    	}
    }
    
	/**
	 * @private
	 * Method to be invoked repeatedly to generate tuples
	 * for each combination of row and column query axis position
	 * intersection. reachedEnd flag should be set to false to start
	 * a fresh round of iteration. 
	 */
	private function getNextTuple():OLAPTuple
	{
		//if we have reached end returns null
		if (reachedEnd)
			return null;
			
    	var tempTuple:OLAPTuple = queryTuple;
       	
       	//add members from all query axes.
       	var axisIndex:int = 0;
       	for each (var pos:Array in queryAxisPositions)
       	{
          	tempTuple.addMembers(pos[ tupleIndexObject[axisIndex] ].members);
          	++axisIndex;
       	}
       	//adjust for the last increment
       	--axisIndex;
       	
       	//increment the axis index of the last query axis
       	//if the last element of the last query axis has been reached
       	//reset it to zero and increment the index of last-1 query axis
       	//do this till we reach the last element of the first query axis  
   		var lastIndex:int = ++tupleIndexObject[axisIndex];
       	if (lastIndex >= pos.length)
       	{
       		while(lastIndex >= pos.length)
       		{
	       		tupleIndexObject[axisIndex] = 0;
    	   		++tupleIndexObject[axisIndex-1];
    	   		lastIndex = tupleIndexObject[axisIndex-1];
    	   		--axisIndex;
    	   		//have we reached the last element of the first query axis?
    	   		if (axisIndex != -1)
    	   			pos = queryAxisPositions[axisIndex];
    	   		else
    	   		{
    	   			//done!
    	   			reachedEnd = true;
    	   			break;
    	   		}
    	   	}
       	}
	       	
		return tempTuple;
	} 
	
	/**
	 * @private
	 * Builds a array of tuples to build the query cube. 
	 */
    private function buildQueryTuples(query:IOLAPQuery):Boolean
    {
        var member:IOLAPMember;
       
        if (queryCubeColIndex < colPositions.length)
        {
            while (queryCubeRowIndex < queryRowCount || (!validRowPositions && queryCubeRowIndex == 0))
            {
                do
                {
                	//queryTuple would contain the resultant tuple
                	getNextTuple();

					if (isTupleValid(queryTuple))
					{
    				    validRows[queryCubeRowIndex] = 1;
				        validColumns[queryCubeColIndex] = 1;
	    	         	
                        if (!queryTuples[queryCubeRowIndex][queryCubeColIndex])
	        	     		queryTuples[queryCubeRowIndex][queryCubeColIndex] = [ queryTuple ];
	            	 	else
	             		{
	             			queryTuples[queryCubeRowIndex][queryCubeColIndex].push(queryTuple);
	             		}
	             		//allocate new tuple for next iteration
                    	queryTuple = new OLAPTuple();
	    			}
	    			else
	    			{
	    				//we didn't use the tuple so we can reuse it
	    				queryTuple.clear();
	    			}
                } while(!reachedEnd && queryCubeColIndex == tupleIndexObject[0] &&
                		queryCubeRowIndex == tupleIndexObject[1]);
               	
                ++queryCubeRowIndex;
                return false;
            }

       		queryCubeRowIndex = 0;
            ++queryCubeColIndex;
            return false;
        }
        
		//remove unused columns and rows.
		var n:int = validRows.length;
		for (var i:int = n - 1; i > -1; --i)
		{
			if (validRows[i] == undefined)
			{
				rowPositions.splice(i, 1);
				queryTuples.splice(i, 1);
			}
		}
		
		queryRowCount = rowPositions.length;
		
		n = validColumns.length;
		for (i = n - 1; i > -1; --i)
		{
			if (validColumns[i] == undefined)
			{
				colPositions.splice(i, 1);
	            for each (var a:Array in queryTuples)
	            {
	                a.splice(i, 1);
	            }
			}
		}
		
		_queryProgress = 0;
		queryCubeRowIndex = 0;
		queryCubeColIndex = 0;
		queryTuplesBuilt = true;
		validRows = validColumns = null;
		return true;
    }

	/**
	 *  @private
	 *  Builds the query cube step by step. Returns false
	 *  if the process is not complete and this function 
	 *  needs to be called again.
	 *  
	 */
    private function buildQueryCube(query:IOLAPQuery):Boolean
    {
        var member:IOLAPMember;
        var cubeToRead:CubeNode = rootNode;
        //build the sub cube with the query result values
        var tuple:OLAPTuple;// = new OLAPTuple;
        
		if (!queryCubeBuilder)
        {
			//prepare a new query result cube
        	initQueryNodeBuilder();
        
			validRows = new Array(queryRowCount);
			validColumns = new Array(colPositions.length);
			queryCubeRowIndex = 0;
       		queryCubeColIndex = 0;
        }
		
        if (queryCubeColIndex < colPositions.length)
        {
            var tupleMember:IOLAPMember;
            while (queryCubeRowIndex < queryRowCount || (!validRowPositions && queryCubeRowIndex == 0))
            {
            	var tArray:Array = queryTuples[queryCubeRowIndex][queryCubeColIndex]; 
                
                if (!tArray)
                {
                    ++queryCubeRowIndex;
                	continue;
                }
                
                for each (tuple in tArray) 
                {
					var generatedTupleMembers:Array = tuple.membersArray;
	                
	                var value:* = cubeToRead;
	                
	                //skip the last measure level;
	                var memCount:int = generatedTupleMembers.length -1;
	                var tupleIndex:int;
					var userMembers:Array = tuple.explicitMembers.toArray();
					validRows[queryCubeRowIndex] = 1;
					validColumns[queryCubeColIndex] = 1;
	
	                value = cubeToRead;
	                moveToNextRoundQuery();
	                
	                var prevMemberName:String;
					for (tupleIndex = 0; tupleIndex < memCount; ++tupleIndex)
	                {
	                    tupleMember = generatedTupleMembers[tupleIndex];
	                    //check for member existence 
	                    //Is this check redundant as the tuple has already been validated?
	                    if (value.hasOwnProperty(tupleMember.name))
	                    {
	                        value = value[tupleMember.name];
	                        prevMemberName = tupleMember.uniqueName;
	                        addValueToQueryNodeBuilder(tupleMember.uniqueName, value);
	                    }
	                    else
	                    {
	                        // remove the position from the axis
	                        value = undefined;
	                        break;
	                    }
	                }
	                
	                if (value != undefined)
	                {
	                    if (value is CubeNode)
	                        value = value[allNodePropertyName];
	
	                    var measure:OLAPMeasure = generatedTupleMembers[generatedTupleMembers.length-1] as OLAPMeasure;
	                   	addMeasureToQueryNodeBuilder(tupleMember.uniqueName, value, measure);
	                }
                }
                ++queryCubeRowIndex;
                return false;
            }

       		queryCubeRowIndex = 0;
            ++queryCubeColIndex;
            return false;
        }
        
        completeQueryNodeBuilding();

		//remove unused columns and rows.
		for (var temp:int = validRows.length-1; temp > -1; --temp)
		{
			if (validRows[temp] == undefined)
			{
				rowPositions.splice(temp, 1);
				queryTuples.splice(temp, 1);
			}
		}
		
		queryRowCount = rowPositions.length;
		
		for (temp = validColumns.length-1; temp > -1; --temp)
		{
			if (validColumns[temp] == undefined)
			{
				colPositions.splice(temp, 1);
	            for each (var a:Array in queryTuples)
	            {
	                a.splice(temp, 1);
	            }
			}
		}
		
		_queryProgress = 0;
		queryCubeRowIndex = 0;
		queryCubeColIndex = 0;
		queryCubeBuilt = true;
		return true;
    }
    
	/**
	 *  @private
	 *  Prepares the result object.
	 *  
	 */
	private function prepareResult(query:IOLAPQuery):void
	{
		queryCubeBuilt = false;
		queryTuplesBuilt = false;
    	colPositions = [];
    	rowPositions = [];
    	queryTuples = [];
    	queryTuple = new OLAPTuple(); 
    
    	queryAxisPositions = [];
    
        var member:IOLAPMember;
        var position:OLAPAxisPosition;
        var queryIndex:int = 0;
        var queryAxis:OLAPQueryAxis = query.getAxis(queryIndex) as OLAPQueryAxis;
        while (queryAxis) 
        {
	        var queryPositions:Array = [];
	        for each (var t:OLAPTuple in queryAxis.tuples)
	        {
	            position = new OLAPAxisPosition;
	            for each (member in t.explicitMembers)
	                position.addMember(member);
				queryPositions.push(position);
	        }
	        
	        if (queryPositions.length)
	        {
		        queryAxisPositions.push(queryPositions);
			
				//add a new result axis
				newResult.setAxis(queryIndex, new OLAPResultAxis());
				
				//initialize the index object map
				tupleIndexObject[queryIndex] = 0;
	        }

	        ++queryIndex;
	        queryAxis = query.getAxis(queryIndex) as OLAPQueryAxis;
	    }
        
        colPositions = queryAxisPositions[0];
        
        if (queryAxisPositions[1])
        	rowPositions = queryAxisPositions[1];
        
		colAxis = newResult.getAxis(0) as OLAPResultAxis;
		rowAxis = newResult.getAxis(1) as OLAPResultAxis;
		if (!rowAxis)
		{
			rowAxis = new OLAPResultAxis();
			newResult.setAxis(OLAPResult.ROW_AXIS, rowAxis);
		}

		slicerAxis = newResult.getAxis(2) as OLAPResultAxis;
   		slicerPositions = queryAxisPositions[2];

	}
	
	/**
	 *  @private
	 *  Dispatch the query progress event
	 *  
	 */
	private function dispatchCubeProgress(progress:int, total:int, message:String=null):void
	{
		var ev:CubeEvent = new CubeEvent(CubeEvent.QUERY_PROGRESS);
		ev.progress = progress;
		ev.total = total;
		if (!message)
			ev.message = "Processing cell : " + progress + " of " + total;
		ev.message = message;
		_cube.dispatchEvent(ev);
	}
	
	/**
	 *  @private
	 *  Insert a value into the object result.
	 *  
	 */
	private function insertResult():Boolean
	{
        var mainCubeTuple:OLAPTuple;//= new OLAPTuple;
        while (queryCubeColIndex < colPos.length)
        {
            while (queryCubeRowIndex < rowPos.length || (rowPos.length == 0 && queryCubeRowIndex ==0))
            {
            	var tArray:Array = queryTuples[queryCubeRowIndex][queryCubeColIndex];

	            if (!tArray)
            	{
	            	++queryCubeRowIndex;
	            	continue;
                }
            
            	// we use the first tuple in the tuples array to read the resultant
            	// aggregation value
                mainCubeTuple = tArray[0];
                 
                // we need to initialize it for each loop
                var value:* = undefined;
                
                //attempt a read from the query cube.
                if (queryRootNode)
	            {
                	// to read from the query cube we need to remove 
                	// the slicer members as we need to only read
                	// the aggregated value.
	            	if (removableSlicerMembers && removableSlicerMembers.length)
	                {	
		                mainCubeTuple.removeElementsAtEnd(removableSlicerMembers.length);
		                if (measureInSlice)
		                	mainCubeTuple.addMember(measureInSlice);
		            }
                    value = readCubeCell(queryRootNode, false, mainCubeTuple.membersArray);
                }
				//attempt a read from the main cube as we failed to read from the
				//query cube.
				else if (value == undefined)
                {
                	//OLAPTrace.traceMsg("Reading from the main cube.", OLAPTrace.TRACE_LEVEL_2);
                	value = readCubeCell(rootNode, true, mainCubeTuple.membersArray);
                }

                if (value != undefined)
                {
                    validRows[queryCubeRowIndex] = 1;
                    validColumns[queryCubeColIndex] = 1;
                    newResult.setCell(queryCubeRowIndex, queryCubeColIndex, Number(value));
	            }
                
                ++queryCubeRowIndex;
                return false;
            }
            queryCubeRowIndex = 0;
            ++queryCubeColIndex;
            return false;
        }
        
        return true;
	}
	
	/**
	 *  @private
	 *  Prepare for building the query tuples, query cube and query result.
	 *  
	 */
	private function prepareForNewQuery(query:IOLAPQuery):Boolean
	{
    	/*
    	++totalRunCount;
    	tempStartTime = getTimer();
    	tOnce = cOnce = rOnce = false;
    	*/
    	queryCubeBuilder = null;
    	prepareResult(query);
    	validRows = validColumns = null;
    	_queryProgress = 0;
    	
    	// Even if user has not specified a row axis 
    	// we will have one row in the result
        if (rowPositions.length)
        {
        	validRowPositions = true;
        	queryRowCount = resultRowCount = rowPositions.length;
        } 
        else
        {
        	validRowPositions = false;
        	// we will have minimum of one row
        	resultRowCount = 1;
        	queryRowCount = 0;
        }
        
    	_queryTotal = resultRowCount * colPositions.length;
		dispatchCubeProgress(_queryProgress, _queryTotal);
		newResult.query = query;
		actionFunction = buildQueryTuplesAction;
		

		validRows = new Array(resultRowCount);
		validColumns = new Array(colPositions.length);
		queryCubeRowIndex = 0;
   		queryCubeColIndex = 0;
   		queryTuples = new Array(resultRowCount);
   		for (var index:int = 0; index < resultRowCount; ++index)
   			queryTuples[index] = new Array(colPositions.length); 
        reachedEnd = false;
        return false;
	}
	
	/**
	 *  @private
	 *  The action function which in turn calls the buildQueryTyples function.
	 *  
	 */
	private function buildQueryTuplesAction(query:IOLAPQuery):Boolean
    {
        if (!buildQueryTuples(query))
        {
			if (_cube.hasEventListener(CubeEvent.QUERY_PROGRESS))
			{
				var newProgress:int = queryCubeColIndex * resultRowCount + queryCubeRowIndex;
				if (newProgress - _queryProgress > queryProgressEventThreashold) 
				{
					_queryProgress = newProgress; 
					dispatchCubeProgress(_queryProgress, _queryTotal, "First Pass - Processing cell : " + _queryProgress + " of " + _queryTotal);
				}
        	}
			return false;
        }

        /* code for performance measurement.
        if (!tOnce)
        {
        	totalTupleTime += (getTimer() - tempStartTime);  
        	trace("Time taken for building Query tuples:" + (totalTupleTime/totalRunCount));
        	tempStartTime = getTimer();
        	tOnce = true;
        }
        */
        
		actionFunction = buildQueryCubeAction;
		return false;    			
    }
   
    /**
	 *  @private
	 *  The action function which in turn calls the buildQueryCube function.
	 *  
	 */
    private function buildQueryCubeAction(query:IOLAPQuery):Boolean
    {
    	if (slicerAxis)
		{
			if (!buildQueryCube(query))
			{
				if (_cube.hasEventListener(CubeEvent.QUERY_PROGRESS))
				{
					var newProgress:int = queryCubeColIndex * resultRowCount + queryCubeRowIndex;
					if (newProgress - _queryProgress > queryProgressEventThreashold)
					{ 
						_queryProgress = newProgress;
						dispatchCubeProgress(_queryProgress, _queryTotal, "Second Pass - Processing cell : " + _queryProgress + " of " + _queryTotal);
					}
				}
				
				return false;
			}
		}
        /* code for performance measurement.
        if (!cOnce)
        {
        	totalCubeTime += getTimer() - tempStartTime; 
        	trace("Time taken for building Query tuples + queryCube:" + (totalCubeTime/totalRunCount));
        	tempStartTime = getTimer();
        	cOnce = true;
        }
        */
				
		actionFunction = buildQueryResultAction;
		
		prepareToGenerateResult();
		
		return false;
    }
    
    /**
	 *  @private
	 *  
	 */
    private function prepareToGenerateResult():void
    {
        var member:IOLAPMember;
		if (queryCubeRowIndex == 0 && queryCubeColIndex == 0)
		{
			dispatchCubeProgress(_queryTotal, _queryTotal);
			colAxis.positions = new ArrayCollection(colPositions);
			colPos = colAxis.positions;
	        validColumns = new Array(colPos.length);
			
			rowAxis.positions = new ArrayCollection(rowPositions);
			rowPos = rowAxis.positions;
            validRows = new Array(rowPos.length);
			
			_queryProgress = 0;
			_queryTotal = resultRowCount * colPositions.length;
		
            removableSlicerMembers = new ArrayCollection();
                    
			if (slicerAxis)
			{
				var slicerPos:IList = slicerAxis.positions = new ArrayCollection(slicerPositions);

                //gather members which need to be removed from tuples
				var mems:ArrayCollection = slicerPos[0].members;
				for (var mIndex:int = 0; mIndex < mems.length; ++mIndex)
				{
					member = mems.getItemAt(mIndex) as IOLAPMember;
					removableSlicerMembers.addItem(member);
					if (member.isMeasure)
						measureInSlice = member;
				}
			}
		}
    }
   
    /**
	 *  @private
	 *  The action function which in turn calls the insertResult function.
	 *  
	 */
    private function buildQueryResultAction(query:IOLAPQuery):Boolean
    {
		if (!insertResult())
		{
			if (_cube.hasEventListener(CubeEvent.QUERY_PROGRESS))
			{
				var newProgress:int = queryCubeColIndex * rowPos.length + queryCubeRowIndex;
				if (newProgress - _queryProgress > queryProgressEventThreashold) 
				{
					_queryProgress = newProgress; 
					dispatchCubeProgress(_queryProgress, _queryTotal, "Third Pass - Processing cell : " + _queryProgress + " of " + _queryTotal);
				}
			}
			
			return false;
		}
        
        /* code for performance measurement.
        if (!rOnce)
        {
        	totalResultTime += (getTimer() - tempStartTime); 
            trace("Time taken for building Query tuples + queryCube + result :" + (totalResultTime/totalRunCount));
        	tempStartTime = getTimer();
            rOnce = true;
        }
        */
		dispatchCubeProgress(_queryTotal, _queryTotal, "Third Pass - Processing cell : " + _queryTotal + " of " + _queryTotal);

        //remove unused columns and rows.
        for (var temp:int = validRows.length-1; temp > -1; --temp)
        {
            if (validRows[temp] == undefined)
            {
                rowPos.removeItemAt(temp);
                newResult.removeRowData(temp);
            }
        }

        for (temp = validColumns.length-1; temp > -1; --temp)
        {
            if (validColumns[temp] == undefined)
            {
                colPos.removeItemAt(temp);
                newResult.removeColumnData(temp);
            }
        }
        
        //we are done with this query
        actionFunction = prepareForNewQuery;
        
        //let us release all references
        queryCubeBuilder = null;
        validRows = validColumns = null;
        queryTuples = null;
                    
        return true;
    }
    
    /**
    *  @private
    *  Returns a value reading it from the cube based on the members array 
    *  describing the path to the cell that should be read.
    *  The mainCube flag indicates whether rootNode points to the main OLAP cube or 
    *  a query cube.
    */
    private function readCubeCell(rootNode:CubeNode, mainCube:Boolean, 
                            tupleCubeMembers:Array):*
    {
        var value:* = rootNode;
        for each (var index:IOLAPMember in tupleCubeMembers)
        {
			var memberName:String;
			if (index.isMeasure)
			{
				memberName = index.name;
			}
			else if (index.isAll)
			{
				memberName = mainCube ? allNodePropertyName : allQueryNodePropertyName;
				//if (!slicerAxis)
				//	memberName = index.uniqueName ;
			}
			else
			{
				memberName = mainCube ? index.name : index.uniqueName;
			}
				
			if (value.hasOwnProperty(memberName))
			{
                 value = value[memberName];
   			}
            else
            {
                 value = undefined;
                 break;
            }
         }
                
         if (value != undefined)
         {
            // user has stopped at this level
            // pick the agg all value from the levels below.
            if (value is CubeNode)
            {
                if (mainCube)
                    value = value[allNodePropertyName];
                else
                    value = value[allQueryNodePropertyName];
            }
                    
            if (index is OLAPMeasure)
            {
                //user has chosen measure on the axis 
                //we will use this
                //value = value[index.name];
                //if (!(value is Number))
                //    trace("Invalid assumption about having a value");
            }
            else
            {
                var measure:OLAPMeasure = _cube.findDimension("Measures").defaultMember as OLAPMeasure;
                value = value[measure.name];
            }
        }
        
        return value;
    }
    
    /*
    *  @private
    */
    mx_internal function sortData():void
    {
        for each (var dim:IOLAPDimension in _cube.dimensions)
        {
            for each (var hierarchy:OLAPHierarchy in dim.hierarchies)
            {
                levels = levels.concat(hierarchy.levels.toArray());
            }
        }
        
        // sort the data as it makes decision about completion of handling
        var newSort:ISort = new Sort;
        var fields:Array = [];
        
        for each (var level:OLAPLevel in levels)
        {
            var field:ISortField = new SortField(level.dataField);
            fields.push(field);
        }
        
        newSort.fields = fields;
        _cube.dataProvider.sort = newSort;
        _cube.dataProvider.refresh();
    }
    
    // cube builder API
    
    /**
    *  @private
    *  Signals the start of main OLAP cube building.
    *  
    */
    private function initNodeBuilder():void
    {
        if (!nodeBuilder)
        {
            nodeBuilder = new CubeNodeBuilder;
            nodeBuilder.cube = _cube;
            nodeBuilder.levelPreviousToMeasuresIndex = levels.length - 1;
        }
        nodeBuilder.initNodeBuilding(); 
    }
    
    /**
    *  @private
    *  Property Name used by the main cube in each node for a property, 
    *  which points to the aggregation node of nodes below. 
    *  
    */
    private function get allNodePropertyName():String
    {
        return nodeBuilder.allNodePropertyName;
    }
    
    /**
    *  Returns the root CubeNode of the main OLAP cube.
    *  
    *  @langversion 3.0
    *  @playerversion Flash 9
    *  @playerversion AIR 1.1
    *  @productversion Flex 3
    */
    mx_internal function get rootNode():CubeNode
    {
        return nodeBuilder.rootNode;
    }
    
    /**
    *  @private
    *  
    */
    private function addValueToNodeBuilder(value:Object, data:Object):void
    {
        nodeBuilder.addValueToNodeBuilder(value, data);
    }
    
    /**
    *  @private
    *  Signals end of input data processing. The node builder
    *  finalizes the cube by computing aggregates.
    *  
    */
    private function completeNodeBuilder():Boolean
    {
        return nodeBuilder.completeNodeBuilding();
    }
    
    /**
    *  @private
    *  QUERY cube builder API
    */ 
    private function initQueryNodeBuilder():void
    {
        if (!queryCubeBuilder)
        {
            queryCubeBuilder = new QueryCubeBuilder;
            queryCubeBuilder.cube = _cube;
        }
        queryCubeBuilder.initNodeBuilding();    
    }
    
    /**
    *  @private
    *  Property Name used by the query cube in each node for a property, 
    *  which points to the aggregation node of nodes below. 
    *  
    */
    private function get allQueryNodePropertyName():String
    {
        return queryCubeBuilder.allNodePropertyName;
    }
    
    /**
    *  @private
    *  Returns the root node for the query cube.
    *  
    */
    private function get queryRootNode():CubeNode
    {
        if (queryCubeBuilder)
            return queryCubeBuilder.rootNode;
        return null;
    }
    
    /**
    *  @private
    *  Adds a value to the query cube.
    *  
    */
    private function addValueToQueryNodeBuilder(value:Object, data:Object):void
    {
        queryCubeBuilder.addValueToNodeBuilder(value, data);
    }
    
    /**
    *  @private
    *  Adds a measure value to the query cube.
    *  
    */
    private function addMeasureToQueryNodeBuilder(value:Object, data:Object, measure:OLAPMeasure):void
    {
        queryCubeBuilder.addMeasureValueToNode(value, data, measure);
    }
    
    /**
    *  @private
    *  Signals the queryCube builder to finalize the cube so that
    *  results can be read from it.
    *  
    */
    private function completeQueryNodeBuilding():void
    {
        queryCubeBuilder.completeNodeBuilding();
    }
    
    /**
    *  @private
    *  Signals end of processing one tuple in the query.
    */
    private function moveToNextRoundQuery():void
    {
        queryCubeBuilder.moveToNextRound();
    }

	/**
	 *  A helper function which returns true if the Tuple addresses a valid
	 *  cell in the cube. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
    mx_internal function isTupleValid(tuple:OLAPTuple):Boolean
    {
        var generatedTupleMembers:Array = tuple.membersArray;
        
        var value:* = rootNode;
        
        //skip the last measure level;
        var memCount:int = generatedTupleMembers.length -1;
        var tupleMember:IOLAPMember;
        for (var tupleIndex:int = 0; tupleIndex < memCount; ++tupleIndex)
        {
            tupleMember = generatedTupleMembers[tupleIndex];
            if (tupleMember.isAll)
            {	
                value = value[allNodePropertyName];
            }
            else
            {
            	//move to the next level
            	value = value[tupleMember.name];
            	//absense of any value indicates a invalid tuple.
            	if (value === undefined)
            		return false;
            }
           
        }
        return true;
    }
}
}
