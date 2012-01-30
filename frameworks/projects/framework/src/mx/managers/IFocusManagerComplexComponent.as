////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.managers
{

/**
 *  The IFocusManagerComplexComponent interface defines the interface 
 *  that components that can have more than one internal focus target
 *  should implement in order to
 *  receive focus from the FocusManager.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IFocusManagerComplexComponent extends IFocusManagerComponent
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  hasFocusableContent
	//----------------------------------

	/**
	 *  A flag that indicates whether the component currently has internal
	 *  focusable targets
	 * 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	function get hasFocusableContent():Boolean;
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  Called by the FocusManager when the component receives focus.
	 *  The component may in turn set focus to an internal component.
	 *  The components setFocus() method will still be called when focused by
	 *  the mouse, but this method will be used when focus changes via the
	 *  keyboard
	 *
	 *  @param direction "bottom" if TAB used with SHIFT key, "top" otherwise
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	function assignFocus(direction:String):void;

}

}
