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
