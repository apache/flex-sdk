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

package mx.events
{

/**
 *  The FocusDirection class defines the constant values for the direction
 *  focus may be moved in. The value is used with the SWFBridgeRequest.MOVE_FOCUS_REQUEST
 *  request and with the FocusManager <code>moveFocus()</code> method.
 *  
 *  @see SWFBridgeRequest
 */
public final class FocusRequestDirection
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    /**
     *  Move the focus forward to the next control in the tab loop as if the
	 *  TAB key were pressed.
     */
    public static const FORWARD:String = "forward";
    
    /**
     *  Move the focus backward to the previous control in the tab loop as if
	 *  the SHIFT+TAB keys were pressed.
     */
    public static const BACKWARD:String = "backward";
    
    /**
     *  Move the focus to the top/first control in the tab loop as if the
	 *  TAB key were pressed when no object had focus in the tab loop
     */ 
    public static const TOP:String = "top";
    
    /**
     *  Move the focus to the bottom/last control in the tab loop as if the
	 *  SHIFT+TAB key were pressed when no object had focus in the tab loop
     */ 
    public static const BOTTOM:String = "bottom";


}

}
