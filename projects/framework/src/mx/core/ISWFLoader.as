////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.core
{
import flash.geom.Rectangle;

import mx.core.ISWFBridgeProvider;

/**
 *  The ISWFLoader interface defines an API with special properties
 *  and method required when loading compatible applications and untrusted applications.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */ 
public interface ISWFLoader extends ISWFBridgeProvider
{
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  loadForCompatibility
    //----------------------------------

    /**
     *  A flag that indicates whether the content is loaded so that it can
     *  interoperate with applications that were built with a different verion of Flex.  
     *  Compatibility with other Flex Applications is accomplished by loading
     *  the application into a sibling (or peer) ApplicationDomain.
     *  This flag is ignored if the sub application is loaded into a different
     *  SecurityDomain than the main application.
     *  If <code>true</code>, the content loads into a sibling ApplicationDomain. 
     *  If <code>false</code>, the content loaded into a child ApplicationDomain.
     *
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get loadForCompatibility():Boolean;

    /**
     *  @private
     */
    function set loadForCompatibility(value:Boolean):void;
        
    /**
     *  Get the bounds of the loaded application that are visible to the user
     *  on the screen.
     * 
     *  @param allApplications Determine if the visible rectangle is calculated based only on the 
     *  display objects in this application or all parent applications as well.
     *  Including more parent applications might reduce the visible area returned.
     *  If <code>true</code>, then all applications are used to find the visible
     *  area, otherwise only the display objects in this application are used.
     * 
     *  @return A <code>Rectangle</code> that includes the visible portion of this 
     *  object. The rectangle uses global coordinates.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */  
    function getVisibleApplicationRect(allApplications:Boolean=false):Rectangle;
    
}
}