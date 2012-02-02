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
import flash.utils.Dictionary;

import mx.collections.IList;
import mx.core.mx_internal;

use namespace mx_internal;

/**
* @private
*/
public class QueryCubeBuilder
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    private var prevNodeAtLevel:Array; //of CubeNodes
    private var allNodeAtLevel:Array;  // of CubeNodes
    private var prevValueAtLevel:Array; // type depends on data (mostly string)
    
    // the level at which the new property is going to be placed
    private var currentLevel:int;
    private var prevLevel:int;
    private var nextLevel:int;

    //the nodes whose values are going to be aggregated as the above node
    //value has changed.
    private var closingNodesBelow:Array;
    private var closingValues:Array;
    
    //list of measures in the cube
    private var measureMembers:IList;

    // the maps holding nodes which are used to finalize the aggregation
    
    // simple aggregation map 
    private var computeEndMap:Dictionary = new Dictionary(false);
    
    //aggregation of aggregations map
    private var computeObjEndMap:Dictionary = new Dictionary(false);

    private var measureMap:Object = {};

    private var allLevelNames:Array;
    
    private var nodesToClose:Array = [];
    private var nodesToAggregate:Array;
    private var dataToAggregate:Array;
    private var measureToAggregate:Array;
    private var valueToAggregate:Array;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------   
    
    //----------------------------------
    // cube
    //----------------------------------
    
    private var _cube:OLAPCube;
    
    public function set cube(c:IOLAPCube):void
    {
        _cube = c as OLAPCube;
    }
    
    //----------------------------------
    // rootNode
    //----------------------------------
    
    /**
    *  Top most node which can be used to access the query cube.
    *  
    *  @langversion 3.0
    *  @playerversion Flash 9
    *  @playerversion AIR 1.1
    *  @productversion Flex 3
    */
    public var rootNode:CubeNode;
    
    //----------------------------------
    // allNodePropertyName
    //----------------------------------
    
    /**
    * The property name used to refer to the property
    * pointing at the aggregation of nodes below a CubeNode  
    *  
    *  @langversion 3.0
    *  @playerversion Flash 9
    *  @playerversion AIR 1.1
    *  @productversion Flex 3
    */
    public var allNodePropertyName:String ="(QAll)";
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    public function initNodeBuilding():void
    {
        prevNodeAtLevel = [];
        allNodeAtLevel = [];
        prevValueAtLevel = [];
        measureMap = {};
        
        //compute for all the measures
        measureMembers = _cube.findDimension("Measures").members;

        for each (var measure:OLAPMeasure in measureMembers)
        {
            computeEndMap[measure] = [];
            computeObjEndMap[measure] = [];
            measureMap[measure.name] = measure;
        }
        
        nodesToClose = [];
        
        nodesToAggregate = [];
        dataToAggregate = [];
        measureToAggregate = [];
        valueToAggregate = []; 
        
        
        //prepare a dictionary of all level names
        allLevelNames = [];
        
        for each (var d:OLAPDimension in _cube.dimensions)
        {
        	if (d.isMeasure)
        		continue;
            for each (var a:OLAPAttribute in d.attributes)
            {
                allLevelNames.push(a.findMember(a.allMemberName).uniqueName);
            }

            for each (var h:OLAPHierarchy in d.hierarchies)
            {
                allLevelNames.push(h.findMember(h.allMemberName).uniqueName);
            }
        }
    }
    
    public function moveToNextRound():void
    {
        currentLevel = 0;
        prevLevel = -1;
        nextLevel = 1;
    }
    
    private function sortCubeNodes(p1:CubeNode, p2:CubeNode):int
    {
        if (p1.level == p2.level)
            return 0;
        if (p1.level < p2.level)
            return 1;
        return -1;
    }
    
    /**
     *  @private
     *  Check whether the cubeNode has any entry for a (All) field
     *  from any level.
     */
    private function allPropertyPresent(node:CubeNode):Boolean
    {
        for (var p:String in node)
        {
            if (allLevelNames.indexOf(p) > -1)
            	return true;
        }
        return false;
    }
    
    public function completeNodeBuilding():void
    {
        //TODO initializing rootNode twice
        rootNode = prevNodeAtLevel[0];
        closingNodesBelow = prevNodeAtLevel.reverse();
        closingValues = prevValueAtLevel.reverse();
        
        var tempLevel:int = closingNodesBelow.length-1;
        var p:String;
        var n:int = closingNodesBelow.length;
        for (var i:int = 0; i < n; ++i)
        {
            if (tempLevel < 1)
                continue;
            var closingValue:Object = closingValues[i];
            //OLAPTrace.traceMsg("Closing value:" + closingValues[i], //OLAPTrace.TRACE_LEVEL_2);
            var closingNode:Object = closingNodesBelow[i];
            if (closingNode[closingValue] is CubeNode)
            {
                if (closingNode[allNodePropertyName] is CubeNode)
                {
                    var index:int = nodesToClose.indexOf(closingNode);
                    if (index == -1)
                        nodesToClose.push(closingNode);
                }
            }

            --tempLevel;
        }
        
        n = nodesToAggregate.length;
        for (i = 0; i < n; ++ i)
        {
            var prevNode:Object = nodesToAggregate[i];
            if (prevNode.numCells > 2 && allLevelNames.indexOf(valueToAggregate[i]) > -1)
                continue;
            var tempAllNode:Object;
            
			if (prevNode.numCells == 2)
        	{
        		if (prevNode.hasOwnProperty(allNodePropertyName))
	        	{
		        	for (p in prevNode)
			        {
			        	if (p == allNodePropertyName)
			        		continue;
			        	if (prevNode[allNodePropertyName] != prevNode[p])
			        		prevNode[allNodePropertyName] = prevNode[p];
			        	break;
			        }
			        continue;
			    }
		   }
            
            if (prevNode[allNodePropertyName] is CubeNode || prevNode[allNodePropertyName] is Number)
                tempAllNode = prevNode[allNodePropertyName] = new SummaryNode;
            else
                tempAllNode = prevNode[allNodePropertyName];
            aggregateAllValue(tempAllNode, dataToAggregate[i], measureToAggregate[i]);
        }
        
        // we sort the nodes in their order of level to do aggregation
        // bottom up to get correct results
        nodesToClose.sort(sortCubeNodes);
        
        // close all nodes pending
        for each (var node:CubeNode in nodesToClose)
        {
        	var allPropPresent:Boolean = allPropertyPresent(node);
            for (p in node)
            {
                if (p == allNodePropertyName)
                    continue;
                // if there are other paths leading to the nodes below
                // do not include the all property in aggregation because that would
                // lead to multiple aggregations of same values
                if (node.numCells > 2 && allLevelNames.indexOf(p) > -1)
                    continue;

            	// if we have only one extra entry in the node other than allNodeProperty
                // then we can optimize. 
                if (allPropPresent && node.numCells == 3)
            		node[allNodePropertyName] = node[p];
				else             		
                	accumValuesFromNode(node[allNodePropertyName], node[p]);
            }
        }
        
        for (p in rootNode)
        {
            if (p == allNodePropertyName || (rootNode.numCells > 2 && allLevelNames.indexOf(p) > -1))
                continue;
            // can we accumulate everything from the tree to the all tree here?
            accumValuesFromNode(rootNode[allNodePropertyName], rootNode[p]);
        }

        var temp:Array;
        var y:Object;
        var measure:OLAPMeasure;
        var aggregator:IOLAPCustomAggregator;
        for (var x:Object in computeEndMap)
        {
            measure = x as OLAPMeasure;
            aggregator = measure.aggregator as IOLAPCustomAggregator;
            temp = computeEndMap[x];
            for each (y in temp)
                y[measure.name] = aggregator.computeEnd(y[measure.name], measure.dataField);
        }

        for (x in computeObjEndMap)
        {
            measure = x as OLAPMeasure;
            aggregator = measure.aggregator as IOLAPCustomAggregator;
            temp = computeObjEndMap[x];
            for each (y in temp)
                y[measure.name] = aggregator.computeObjectEnd(y[measure.name], measure.dataField);
        }
    }
    
    public function addValueToNodeBuilder(value:Object, currentData:Object):void
    {
        // decide whether to create a new node or use the previous node
        var prevNode:CubeNode = prevNodeAtLevel[currentLevel];
        var prevValue:Object = prevValueAtLevel[currentLevel];
        var closingValue:Object;
        var closingNode:Object
        
        if (prevValue)
        {
            if (prevValue == value)
            {
                // continue to process the same value
                // update nodes
                //OLAPTrace.traceMsg("Continue with value:" + prevValue, OLAPTrace.TRACE_LEVEL_2);
            }
            else
            {
                // no more processing of this value.
                // time to compute update all nodes etc
                
                // close all nodes below this node
                closingNodesBelow = prevNodeAtLevel.splice(nextLevel).reverse();
                closingValues = prevValueAtLevel.splice(nextLevel).reverse();
                var tempLevel:int = currentLevel + closingNodesBelow.length;
                var n:int = closingNodesBelow.length;
                for (var i:int = 0; i < n; ++i)
                {
                    closingValue = closingValues[i];
                    //OLAPTrace.traceMsg("Closing value:" + closingValues[i], OLAPTrace.TRACE_LEVEL_2);
                    closingNode = closingNodesBelow[i];
                    if (closingNode[closingValue] is CubeNode)
                    {
                        if (tempLevel != 0)
                        {
                            if (closingNode[allNodePropertyName] is CubeNode)
                            {
                                if (nodesToClose.indexOf(closingNode) == -1)
                                    nodesToClose.push(closingNode);
                            }
                        }
                    }
                    
                    --tempLevel;
                }
                
                //OLAPTrace.traceMsg("Closing value:" + prevValue, //OLAPTrace.TRACE_LEVEL_2);
                closingValue = prevValue;
                closingNode = prevNode;
                if (closingNode[closingValue] is CubeNode)
                {
                    if (currentLevel != 0)
                    {
                        if (closingNode[allNodePropertyName] is CubeNode)
                        {
                            if (nodesToClose.indexOf(closingNode) == -1)
                                nodesToClose.push(closingNode);
                        }
                    }
                }
                
                //OLAPTrace.traceMsg("New value:" + value, //OLAPTrace.TRACE_LEVEL_2);
            }
        }
        
        var allNode:CubeNode = allNodeAtLevel[currentLevel];
        
        if (!prevNode)
        {   
            //OLAPTrace.traceMsg("Creating new node: " + value, //OLAPTrace.TRACE_LEVEL_2);
            // - create a new node, put the pointer to the ALL node, add new key to the ALL node
            var newNode:CubeNode = new CubeNode(currentLevel);
            
            // create a all node to summaries the cells of this node
            newNode[allNodePropertyName] = new CubeNode(currentLevel+1);
            ++newNode.numCells;  
            //TODO initializing rootNode twice
            if (currentLevel == 0 && prevNodeAtLevel.length == 0)
                rootNode = newNode;
            
            prevNodeAtLevel[currentLevel] = newNode;
            if (!allNode)
            {
                // for the top most level we would have only one node
                // which is also the all node
                // for other levels we have one node which is a all node
                // containing aggr value of all cells in the nodes at that level
                if (currentLevel > 0)
                {
                    allNodeAtLevel[currentLevel] = allNode = new CubeNode(currentLevel+1);
                    allNode[allNodePropertyName] = {};
                    allNodeAtLevel[prevLevel][allNodePropertyName] = allNode;
                    ++allNode.numCells;                    
                }
                else
                {   
                    // special case of zero level
                    allNodeAtLevel[currentLevel] = newNode;
                }
            }

            prevNode = newNode;                     
        }
        else
        {
            // add a new cell/property to the previous node if it doesn't exist
            if (!prevNode.hasOwnProperty(value))
            {   
                //prevNode[value] = 0;
                prevNodeAtLevel.splice(nextLevel);
                prevValueAtLevel.splice(nextLevel);
            }
            else
            {
                if (!prevNodeAtLevel[nextLevel])
                {
                    //assigning a summary node was causing a issue(1096) 
                    if (prevNode[value] is CubeNode)
                    {
                        // a node already seems to be present for this value
                        prevNodeAtLevel[nextLevel] = prevNode[value];                           
                        // we cannot set what the previous value for next level should be
                        // because we have already cleared it and lost it.
                    }
                }
            }
        }

        // make the node at previous level point to the node
        if (currentLevel > 0)
        {
            var prevLevelNode:Object = prevNodeAtLevel[prevLevel];
            if (!prevLevelNode.hasOwnProperty(prevValueAtLevel[prevLevel]))
            {   
                var prevLevelValue:Object = prevValueAtLevel[prevLevel];
                prevLevelNode[prevLevelValue] = newNode;
                ++prevLevelNode.numCells;
            }
        }

        prevValueAtLevel[currentLevel] = value;
        ++prevLevel;
        ++currentLevel;
        ++nextLevel;
        
    }
    
    public function addMeasureValueToNode(value:Object, currentData:Object, measureToUpdate:OLAPMeasure):void
    {
        var prevNode:CubeNode = prevNodeAtLevel[currentLevel-1];
        var prevValue:Object = prevValueAtLevel[currentLevel-1];

        if (!prevNode.hasOwnProperty(value))
        {
            prevNode[value] = new SummaryNode;
            ++prevNode.numCells;
        }
        
        aggregateAllValue(prevNode[value], currentData, measureToUpdate);
        
        nodesToAggregate.push(prevNode);
        dataToAggregate.push(currentData);
        measureToAggregate.push(measureToUpdate);
        valueToAggregate.push(value);
    }
    
    private function addValueToNode(node:Object, name:String, 
                        value:Object, measure:OLAPMeasure):void
    {
        var aggregator:IOLAPCustomAggregator;
        if (value is Number)
        {
            aggregator = measure.aggregator as IOLAPCustomAggregator;
            if (!node.hasOwnProperty(name))
            {
                node[name] = aggregator.computeBegin(name);
                computeEndMap[measure].push(node);
                //if (node is SummaryNode)
                //  node["measures"][name] = measure;
                aggregator.computeLoop(node[name], name, value);
            }
            else
            {
                aggregator.computeLoop(node[name], name, value);
            }
        }
        else
        {
            var temp:Object;
            if (!node.hasOwnProperty(name))
            {
                node[name] = temp = new SummaryNode;
                ++node.numCells;
                for (var p:String in value)
                {
                    if (value is SummaryNode)
                        measure = measureMap[p];
                    
                    if (measure)
                    {
                        aggregator = measure.aggregator as IOLAPCustomAggregator;
                        if (value[p] is Number)
                        {
                            temp[name] = aggregator.computeBegin(p);
                            computeEndMap[measure].push(temp);
                            aggregator.computeLoop(temp[name], p, value[p]);
                        }
                        else
                        {
                            if (temp.hasOwnProperty(p))
                            {
                                aggregator.computeObjectLoop(temp[p], value[p]);
                            }
                            else
                            {
                                temp[p] = aggregator.computeObjectBegin(value[p]);
                                computeObjEndMap[measure].push(temp);
                            }
                                
                        }
                    }
                }
            }
            else
            {
                if (value is SummaryNode && !(node[name] is SummaryNode))
                {
                	var incr:Boolean = false;
                	if (!node.hasOwnProperty(name))
	                	incr = true;
                    temp = node[name] = new SummaryNode;
                	if (incr)
                		++node.numCells;
                }
                else
                {
                    temp = node[name];
                }

                for (p in value)
                {
                    if (temp.hasOwnProperty(p))
                    {
                        measure = measureMap[p];
                        aggregator = measure.aggregator as IOLAPCustomAggregator;
                        aggregator.computeObjectLoop(temp[p], value[p]);
                    }
                    else
                    {   
                        if (temp is SummaryNode)
                            measure = measureMap[p];
                            
                        if (measure)
                        {
                            aggregator = measure.aggregator as IOLAPCustomAggregator;
                            if (value[p] is Number)
                            {
                                temp[p] = aggregator.computeBegin(p);
                                aggregator.computeLoop(temp[p], p, value[p]);
                            }
                            else
                            {
                                temp[p] = aggregator.computeObjectBegin(value[p]);
                                computeObjEndMap[measure].push(temp);
                            }
                        }
                    }
                }
            }
        }
    }
    
    private function accumValuesFromNode(target:Object, 
                                source:Object):void
    {
        for (var p:String in source)
        {
	    	if (p == allNodePropertyName)
				continue;

            // if there are other paths leading to the nodes below
            // do not include the all property in aggregation because that would
            // lead to multiple aggregations of same values
            if (source.numCells > 2 && allLevelNames.indexOf(p) > -1)
                continue;
            
            var value:Object = source[p];
            if (value is CubeNode)
            {
                var newNode:CubeNode;
                if (target[p] is CubeNode)
                {
                    newNode = target[p];
                }
                else
                {
                    target[p] = newNode = new CubeNode(value.level);
                	++target.numCells;
                }
                accumValuesFromNode(newNode, value);
            }
            else
            {
                addValueToNode(target, p, value, null);
            }  
        }

        if (target.numCells == 1)
        {
        	for (p in target)
	        {
	        	target[allNodePropertyName] = target[p];
	        	break;
	        }
	        ++target.numCells;
        }
        else if (target.numCells == 2 && target.hasOwnProperty(allNodePropertyName))
        {
        	for (p in target)
	        {
	        	if (p == allNodePropertyName)
	        		continue;
	        	if (target[allNodePropertyName] != target[p])
	        		target[allNodePropertyName] = target[p];
	        	break;
	        }
        }
        else
        {
        	var done:Boolean = false;
        	var otherProperty:String;
        	for (p in target)
	        {
	        	if (p == allNodePropertyName)
	        		continue;
	        	if (target[allNodePropertyName] == target[p])
	        	{
	        		value = target[p];
	        		if (value is CubeNode)
                	{
                		target[allNodePropertyName] = newNode = new CubeNode(value.level);
	        			accumValuesFromNode(newNode, value);
						for (otherProperty in target)
                		{
                			if (otherProperty == allNodePropertyName ||
                				otherProperty == p)
                				continue;
                			//now we have the other property.
			            	accumValuesFromNode(newNode, source[otherProperty]);
                		}
                		done = true;
                	}
                	else
                	{
                		target[allNodePropertyName] = null;
		            	addValueToNode(target, allNodePropertyName, value, null);
						for (otherProperty in target)
                		{
                			if (otherProperty == allNodePropertyName ||
                				otherProperty == p)
                				continue;
                			//now we have the other property.
			            	addValueToNode(target, allNodePropertyName, target[otherProperty], null);
                		}
                		done = true;
                	}
	        		break;
	        	}
	        }
	        
	        if (!done)
        	{
	        	p = allNodePropertyName;
	            value = source[p];
	        	if (value is CubeNode)
	        	{
	                if (target[p] is CubeNode)
	                {
	                    newNode = target[p];
	                }
	                else
	                {
	                	target[p] = newNode = new CubeNode(value.level);
	                	++target.numCells;
	                }    
	                accumValuesFromNode(newNode, value);
	            }
	            else
	            {
	            	addValueToNode(target, p, value, null);
	            }
	        } 
        }
    }
    
    public function aggregateAllValue(node:Object,/* name:String,*/ 
                        value:Object, measure:OLAPMeasure):void
    {
        var measureName:String = measure.name;
        var aggregator:IOLAPCustomAggregator = measure.aggregator as IOLAPCustomAggregator;
        var prop:String = "saved_" + measureName;
        var temp:Object;
        if (!node.hasOwnProperty(measureName))
        {
            temp = node;
            if (measure)
            {
                if (temp.hasOwnProperty(measureName))
                {
                    aggregator.computeObjectLoop(temp[measureName], value[prop]);
                }
                else
                {
                    temp[measureName] = aggregator.computeObjectBegin(value[prop]);
                    computeObjEndMap[measure].push(temp);
                }
            }
        }
        else
        {
            temp = node;
            if (temp.hasOwnProperty(measureName))
            {
                aggregator.computeObjectLoop(temp[measureName], value[prop]);
            }
            else
            {   
                if (value[prop] is Number)
                {
                    temp[prop] = aggregator.computeBegin(prop);
                    aggregator.computeLoop(temp[prop], prop, value[prop]);
                }
                else
                {
                    temp[measureName] = aggregator.computeObjectBegin(value[prop]);
                    computeObjEndMap[measure].push(temp);
                }
           }
       }
   }
}

}
