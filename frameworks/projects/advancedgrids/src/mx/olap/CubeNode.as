////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

package mx.olap
{

/**
* @private
*/
dynamic public class CubeNode
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
    * Constructor. 
    *  
    *  @langversion 3.0
    *  @playerversion Flash 9
    *  @playerversion AIR 1.1
    *  @productversion Flex 3
    */
    public function CubeNode(l:int=-1):void
    {
        _level = l;
        //++nodeCount;
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------   
    
    /**
     * A instance counter to measure/tune performance
     */
    //public static var nodeCount:uint = 0;
    
    //----------------------------------
    // numCells
    //----------------------------------
    
    /**
    *  @private
    *  A count of number of dynamic values in this node.
    *  This is used to optimize the aggregation when we have only a single
    *  value in the node.
    *  
    */
    
    private var _numCells:int = 0;
    
    public function set numCells(value:int):void
    {
    	_numCells = value;
    	//var count:int = 0;
    	//for(var p:String in this)
    	//{
    	//	++count;
    	//}
    	//if (count != value)
    	//	trace("Error in numCells");
    }
    
    public function get numCells():int
    {
    	return _numCells;
    }
    
    //----------------------------------
    // level
    //----------------------------------
    
    private var _level:int;
    
    /**
    * The level at which the node is positioned in the cube.
    *  
    *  @langversion 3.0
    *  @playerversion Flash 9
    *  @playerversion AIR 1.1
    *  @productversion Flex 3
    */
    public function get level():int
    {
        return _level;
    }
}

}