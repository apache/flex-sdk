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

package mx.core
{

import flash.text.TextField;

[ExcludeClass]

/**
 *  @private
 *  Interface to create text fields.
 *  Text fields are re-used so there are no more than one per module factory.
 */
public interface ITextFieldFactory
{
	/**
	 *  Creates a TextField object in the context
	 *  of a specified module factory.
	 * 
	 *  @param moduleFactory May not be null.
	 *
	 *  @return A TextField created in the context of the module factory.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	function createTextField(moduleFactory:IFlexModuleFactory):TextField;
}

}
