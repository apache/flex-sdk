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