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