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
import mx.collections.ArrayCollection;
import mx.collections.IList;

//--------------------------------------
//  metadata
//--------------------------------------

[DefaultProperty("cubeArray")]

/**
 *  The OLAPSchema class represents an OLAP cube or cubes.
 *
 *  @mxml
 *  <p>
 *  The <code>&lt;mx:OLAPSchema&gt;</code> tag inherits all of the tag attributes
 *  of its superclass, and adds the following tag attributes:
 *  </p>
 *  <pre>
 *  &lt;mx:OLAPSchema
 *    <b>Properties</b>
 *       cubeArray=""
 *  /&gt;
 *
 *  @see mx.olap.IOLAPSchema 
 *  @see mx.olap.OLAPCube
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class OLAPSchema implements IOLAPSchema
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    // cubes
    //----------------------------------
    
    private var _cubes:Dictionary = new Dictionary;

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get cubes():IList
    {
        var temp:Array = [];
        for each (var i:Object in _cubes)
            temp.push(i);
        return new ArrayCollection(temp);
    }
    
    /**
     *  @private
     */
    public function set cubes(value:IList):void
    {
        var n:int = value.length;
        for (var i:int = 0; i < n; ++i)
        {
            var cube:IOLAPCube = value.getItemAt(i) as IOLAPCube;
            _cubes[cube.name] = cube;
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    public function addCube(cube:IOLAPCube):Boolean
    {
        if (_cubes[cube.name])
            return false;

        _cubes[cube.name] = cube;
        
        return true;
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function createCube(name:String):IOLAPCube
    {
        var c:IOLAPCube;
        if (!_cubes[name])
        {
            c = new OLAPCube(name);
            _cubes[name] = c;
        }
        
        return _cubes[name];
    }
    
    /**
     *  Lets you set the cubes of a schema by passing an Array of IOLAPCube instances.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function set cubeArray(value:Array):void
    {
        var tempCubes:ArrayCollection = new ArrayCollection(value);
        cubes = tempCubes;
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function getCube(name:String):IOLAPCube
    {
        return _cubes[name];
    }
    
}

}