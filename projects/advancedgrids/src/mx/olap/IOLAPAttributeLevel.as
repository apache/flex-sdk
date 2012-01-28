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
import mx.collections.IList;

/**
 *  @private
 *  The IOLAPAttributeLevel interface represents the single level present 
 *  inside an attribute hierarchy of an OLAP schema.
 *.
 *  @see mx.olap.OLAPAttributeLevel
 */
public interface IOLAPAttributeLevel extends IOLAPLevel
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  children
	//----------------------------------
	
    /**
     *  Returns null.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get children():IList;      
}
}