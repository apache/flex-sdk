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

package mx.core
{

[ExcludeClass]

/**
 *  The ISystemCursorClient interface defines the interface a component may
 *  implement to notify the CursorManager whether or not the system cursor
 *  should be used in conjunction with a custom cursor. 
 *   
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public interface ISystemCursorClient
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  showSystemCursor
	//----------------------------------
	
	/**
	 *  True if the system cursor should always be shown when the mouse 
     *  moves over the component.  If false, the custom cursor will be shown.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function get showSystemCursor():Boolean;    
}

}
