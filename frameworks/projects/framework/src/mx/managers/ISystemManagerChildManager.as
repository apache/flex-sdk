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

import flash.display.DisplayObject;  

[ExcludeClass];

/**
 */
public interface ISystemManagerChildManager
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

   
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	function addingChild(child:DisplayObject):void;
	function childAdded(child:DisplayObject):void;

	function childRemoved(child:DisplayObject):void;
	function removingChild(child:DisplayObject):void;

	function initializeTopLevelWindow(width:Number, height:Number):void;
}

}
