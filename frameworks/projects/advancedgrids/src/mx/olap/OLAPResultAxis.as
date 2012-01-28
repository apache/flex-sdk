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

import mx.collections.IList;
import mx.collections.ArrayCollection;

/**
 *  The OLAPResultAxis class represents an axis of the result of an OLAP query.
 *
 *  @see mx.olap.OLAPQuery
 *  @see mx.olap.OLAPQueryAxis
 *  @see mx.olap.IOLAPResultAxis
 *  @see mx.olap.IOLAPResult
 *  @see mx.olap.OLAPResult
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class OLAPResultAxis implements IOLAPResultAxis
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    // positions
    //----------------------------------
    
    private var _positions:IList = new ArrayCollection; //of IOLAPAxisPositions
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get positions():IList
    {
        return _positions;
    }
    
    /**
     *  @private
     */
    public function set positions(value:IList):void
    {
        _positions = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Adds a position to the axis of the query result.
     *
     *  @param p The IOLAPAxisPosition instance that represents the position.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function addPosition(p:IOLAPAxisPosition):void
    {
        _positions.addItem(p);
    }
    
    /**
     *  Removes a position from the axis of the query result.
     *
     *  @param p The IOLAPAxisPosition instance that represents the position.
     *
     *  @return <code>true</code> if the position is removed from the axis, 
     *  and <code>false</code> if not. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function removePosition(p:IOLAPAxisPosition):Boolean
    {
        var index:int = _positions.getItemIndex(p);
        if (index != -1)
        {
            _positions.removeItemAt(index);
            return true;
        }
        return false;
    }
    
}
}