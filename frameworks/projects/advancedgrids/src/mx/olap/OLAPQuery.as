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

//--------------------------------------
//  metadata
//--------------------------------------

[DefaultProperty("axes")]

/**
 *  The OLAPQuery interface represents an OLAP query that is executed on an IOLAPCube.
 *
 *  @mxml
 *  <p>
 *  The <code>&lt;mx:OLAPQuery&gt;</code> tag inherits all of the tag attributes
 *  of its superclass, and adds the following tag attributes:
 *  </p>
 *  <pre>
 *  &lt;mx:OLAPQuery
 *    <b>Properties</b>
 *       axis=""
 *  /&gt;
 *
 *  @see mx.olap.IOLAPQuery
 *  @see mx.olap.IOLAPQueryAxis
 *  @see mx.olap.OLAPQueryAxis
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class OLAPQuery implements IOLAPQuery
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Specifies a column axis.
     *  Use this property as a value of the <code>axisOrdinal</code> argument
     *  to the <code>getAxis()</code> method.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static var COLUMN_AXIS:int = 0;
    
    /**
     *  Specifies a row axis.
     *  Use this property as a value of the <code>axisOrdinal</code> argument
     *  to the <code>getAxis()</code> method.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static var ROW_AXIS:int = 1;
    
    /**
     *  Specifies a slicer axis.
     *  Use this property as a value of the <code>axisOrdinal</code> argument
     *  to the <code>getAxis()</code> method.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static var SLICER_AXIS:int = 2;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    // axes
    //----------------------------------
    
    private var _axes:Array = [new OLAPQueryAxis(0),  // col axis
                                new OLAPQueryAxis(1),  // row axis
                                new OLAPQueryAxis(2)]; // slicer axis
    
    /**
     *  The axis of the Query as an Array of OLAPQueryAxis instances. 
     *  A query can have three axes: column, row, and slicer.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function set axes(value:Array):void
    {
        _axes = value;
    }
    
    /**
     *  @private
     */
    public function get axes():Array
    {
        return _axes;
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function getAxis(axisOrdinal:int):IOLAPQueryAxis
    {
        switch(axisOrdinal)
        {
            case COLUMN_AXIS:
            case ROW_AXIS:
            case SLICER_AXIS:
                return axes[axisOrdinal];
        }
        return null;    
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function setAxis(axisOrdinal:int, axis:IOLAPQueryAxis):void
    {
        switch(axisOrdinal)
        {
            case COLUMN_AXIS:
            case ROW_AXIS:
            case SLICER_AXIS:
                axes[axisOrdinal] = axis;
                break;
        }
    }

}

}