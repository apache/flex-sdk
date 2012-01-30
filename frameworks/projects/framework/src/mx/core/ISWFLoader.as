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

import mx.sandbox.ISandboxBridgeProvider;

/**
 *  The IApplicationLoader interface defines an API with special properties
 *  and method required when loading compatible applications and untrusted applications.
 */ 
public interface IApplicationLoader extends ISandboxBridgeProvider
{
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  compatibleLoad
    //----------------------------------

    /**
     *  A flag that indictes whether content is loaded into a peer
     *  AppicationDomain. Loading into a peer ApplicationDomain 
     *  will allow the loaded application to interop with applications build with other verions of Flex.
     *  This flag is not respected if the content needs to be loaded into differnt
     *  SecurityDomain.
     *  If <code>true</code>, the content loads into a peer ApplicationDomain. 
     *  If <code>false</code>, the content loaded into a child ApplicationDomain.
     *
     *  @default false
     */
    function get compatibleLoad():Boolean;

    /**
     *  @private
     */
    function set compatibleLoad(value:Boolean):void;
        
    /**
     *  Get the bounds of the loaded application that are visible to the user
     *  on the screen.
     * 
     *  @param allApplications Control if the visible rect is calculated based only on the 
     *  display objects in this application or all parent applications as well.
     *  Including more parent applications may reduce the visible area returned.
     *  If <code>true</code> then all applications are used to find the visible
     *  area, otherwise only the display objects in this application are used.
     * 
     *  @return a <code>Rectangle</code> including the visible portion of the this 
     *  object. The rectangle is in global coordinates.
     */  
    function getVisibleApplicationRect(allApplications:Boolean=false):Rectangle;
    
}
}