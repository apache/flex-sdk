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
     *  A flag that indictes whether the content is loaded so it can
     *  interop with applications built with a different verion of Flex.  
     *  Compatibility with other Flex Applications is accomplished by loading
     *  the application into a sibling ApplicationDomain.
     *  This flag is not respected if the content needs to be loaded into differnt
     *  SecurityDomain.
     *  If <code>true</code>, the content loads into a sibling ApplicationDomain. 
     *  If <code>false</code>, the content loaded into a child ApplicationDomain.
     *
     *  @default false
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