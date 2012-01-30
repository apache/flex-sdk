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

/**
 *  A class that contains variables that are global to all applications within
 *  the same ApplicationDomain.
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 *
 */
public class FlexGlobals
{
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------

    /**
     *  The first application run in an ApplicationDomain is the top-level application.
     *  This property is set to a reference to the top-level application in the top-level 
     *  application's constructor. Each ApplicationDomain will have its own 
     *  <code>topLevelApplication</code>.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
	public static var topLevelApplication:Object;
}

}
