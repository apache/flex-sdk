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
 *  Interface to create instances of TextField and FTETextField.
 *  These are re-used so that there are no more than one of each
 *  per module factory.
 */
public interface ITextFieldFactory
{
	/**
	 *  Creates an instance of TextField
	 *  in the context of the specified IFlexModuleFactory.
	 *
	 *  @param moduleFactory The IFlexModuleFactory requesting the TextField.
	 *
	 *	@return A FTETextField created in the context
	 *  of <code>moduleFactory</code>.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	function createTextField(moduleFactory:IFlexModuleFactory):TextField;
	
	/**
	 *  Creates an instance of FTETextField
	 *  in the context of the specified module factory.
	 * 
	 *  @param moduleFactory The IFlexModuleFactory requesting the TextField.
	 *  May not be <code>null</code>.
	 *
	 *	@return A FTETextField created in the context
	 *  of <code>moduleFactory</code>.
	 *  The return value is loosely typed as Object
	 *  to avoid linking in FTETextField (and therefore much of TLF).
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	function createFTETextField(moduleFactory:IFlexModuleFactory):Object;
}

}
