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
 *  The IOLAPQuery interface represents an OLAP query that is executed on an IOLAPCube.
 *
 *  @see mx.olap.OLAPQuery
 *  @see mx.olap.IOLAPQueryAxis
 *  @see mx.olap.OLAPQueryAxis
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IOLAPQuery
{
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
    /**
     *  Gets an axis from the query. You typically call this method to 
     *  obtain an uninitialized IOLAPQueryAxis instance, then configure the 
     *  IOLAPQueryAxis instance for the query.
     *
     *  @param axisOrdinal Specify <code>OLAPQuery.COLUMN AXIS</code> for a column axis, 
     *  <code>OLAPQuery.ROW_AXIS</code> for a row axis, 
     *  and <code>OLAPQuery.SLICER_AXIS</code> for a slicer axis.
     *
     *  @return The IOLAPQueryAxis instance.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getAxis(axisOridnal:int):IOLAPQueryAxis;
    
    /**
     *  Sets an axis to the query.
     *
     *  @param axisOrdinal Specify <code>OLAPQuery.COLUMN AXIS</code> for a column axis, 
     *  <code>OLAPQuery.ROW_AXIS</code> for a row axis, 
     *  and <code>OLAPQuery.SLICER_AXIS</code> for a slicer axis.
     *
     *  @param axis The IOLAPQueryAxis instance.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function setAxis(axisOridnal:int, axis:IOLAPQueryAxis):void;
}
}