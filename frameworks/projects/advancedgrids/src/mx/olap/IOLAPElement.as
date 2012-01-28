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
*  The IOLAPElement interface defines a base interface that provides 
*  common properties for all OLAP elements.
*.
*  @see mx.olap.OLAPElement
*  
*  @langversion 3.0
*  @playerversion Flash 9
*  @playerversion AIR 1.1
*  @productversion Flex 3
*/
public interface IOLAPElement
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  dimension
	//----------------------------------
	
    /**
     *  The dimension to which this element belongs.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get dimension():IOLAPDimension;
    
    //----------------------------------
	//  displayName
	//----------------------------------
	
    /**
     *  The name of the OLAP element, as a String, which can be used for display.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get displayName():String;
    
    //----------------------------------
	//  name
	//----------------------------------
	
    /**
     *  The name of the OLAP element that includes the OLAP schema hierarchy of the element.
     *  For example, "Time_Year" is the name of the OLAP element, 
     *  where "Year" is a level of the "Time" dimension in an OLAP schema.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get name():String;
    
    //----------------------------------
	//  uniqueName
	//----------------------------------
	
    /**
     *  The unique name of the OLAP element in the cube.
     *  For example, "[Time][Year][2007]" is a unique name, 
     *  where 2007 is the element name belonging to the "Year" level of the "Time" dimension.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get uniqueName():String;
}
}
