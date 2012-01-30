////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.binding
{

[ExcludeClass]

/**
 *  @private
 *  This interface is used internally by Flex 4 to enable data binding
 *  to static private variables and properties.
 *  Flex 3 used the IWatcherSetupUtil interface.
 */
public interface IWatcherSetupUtil2
{
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	function setup(target:Object, propertyGetter:Function,
                   staticPropertyGetter:Function,
				   bindings:Array, watchers:Array):void;
}

}
