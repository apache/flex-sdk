////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.managers
{

import mx.managers.IFocusManagerContainer;

[ExcludeClass]

/**
 *  Interface for subsystem that manages which focus manager is active
 *  when there is more than one IFocusManagerContainer on screen.
 */
public interface IActiveWindowManager
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

    //----------------------------------
    //  numModalWindows
    //----------------------------------

	/**
	 *  The number of modal windows.  
	 *
	 *  <p>Modal windows don't allow
	 *  clicking in another windows which would normally 
	 *  activate the FocusManager in that window.  The PopUpManager
	 *  modifies this count as it creates and destroy modal windows.</p>
	 */
	function get numModalWindows():int;

	/**
	 *  @private
	 */
	function set numModalWindows(value:int):void;


	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  Registers a top-level window containing a FocusManager.
	 *  Called by the FocusManager, generally not called by application code.
	 *
	 *  @param f The top-level window in the application.
	 */
	function addFocusManager(f:IFocusManagerContainer):void;

	/**
	 *  Unregisters a top-level window containing a FocusManager.
	 *  Called by the FocusManager, generally not called by application code.
	 *
	 *  @param f The top-level window in the application.
	 */
	function removeFocusManager(f:IFocusManagerContainer):void;

	/**
	 *  Activates the FocusManager in an IFocusManagerContainer.
	 * 
	 *  @param f IFocusManagerContainer the top-level window
	 *  whose FocusManager should be activated.
	 */
	function activate(f:Object):void;
	
	/**
	 *  Deactivates the FocusManager in an IFocusManagerContainer, and activate
	 *  the FocusManager of the next highest window that is an IFocusManagerContainer.
	 * 
	 *  @param f IFocusManagerContainer the top-level window
	 *  whose FocusManager should be deactivated.
	 */
	function deactivate(f:Object):void;

}

}
