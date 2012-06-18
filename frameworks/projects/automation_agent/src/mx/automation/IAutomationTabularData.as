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

package mx.automation
{

/**
 *  The IAutomationTabularData interface is implemented by components 
 *  which can provide their content information in a tabular form.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IAutomationTabularData
{

    /**
     *  The index of the first visible child.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get firstVisibleRow():int;
    
    /**
     *  The index of the last visible child.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get lastVisibleRow():int;

    /**
     *  The total number of rows of data available.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get numRows():int;

    /**
     *  The total number of columns in the data available.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get numColumns():int;

    /**
     *  Names of all columns in the data.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get columnNames():Array;

    /**
     *  Returns a matrix containing the automation values of all parts of the components.
     *  Should be row-major (return value is an Array of rows, each of which is
     *  an Array of "items").
     *
     *  @param start The index of the starting child. 
     *
     *  @param end The index of the ending child.
     *
     *  @return A matrix containing the automation values of all parts of the components.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getValues(start:uint = 0, end:uint = 0):Array;
    
    /**
     *  Returns the values being displayed by the component for the given data.
     *  
     *  @param data The object representing the data.
     * 
     *  @return Array containing the values being displayed by the component.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getAutomationValueForData(data:Object):Array;
    
}

}
