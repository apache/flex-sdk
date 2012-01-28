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
 *  The OLAPCell class represents a cell in an OLAPResult instance.
 *
 *  @see mx.olap.OLAPResult
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class OLAPCell implements IOLAPCell
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor
     *
     *  @param value The raw value in the cell.
     *
     *  @param formattedValue The formatted value in the cell.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function OLAPCell(value:Number, formattedValue:String=null)
    {
        _value = value;
        _formattedValue = formattedValue;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    // formattedValue
    //----------------------------------
    
    /**
     * @private
     */
    protected var _formattedValue:String;
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get formattedValue():String
    {
        if (_formattedValue)
            return _formattedValue;
        return _value.toString();
    }
    
    //----------------------------------
    // value
    //----------------------------------
    
    private var _value:Number;
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get value():Number
    {
        return _value;
    }
    
}
}