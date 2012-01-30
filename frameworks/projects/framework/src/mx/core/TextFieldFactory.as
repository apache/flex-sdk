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
import flash.utils.Dictionary;

use namespace mx_internal;

[ExcludeClass]

/**
 *  @private
 *  Singleton to create TextFields in the context of various ModuleFactories. 
 *  One module factory will have at most one TextField created for it.
 *  The text fields are only used for measurement;
 *  they are not on the display list.
 */
public class TextFieldFactory implements ITextFieldFactory
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------
    
	/**
	 *  @private
	 * 
	 *  This classes singleton.
	 */
	private static var instance:ITextFieldFactory;

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	public static function getInstance():ITextFieldFactory
	{
		if (!instance)
			instance = new TextFieldFactory();

		return instance;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  @private
	 *  Cache of TextFields. Limit of one per module factory.
	 *  In this Dictionary, each key is a weak reference
	 *  to an IFlexModuleFactory and each value is a Dictionary
	 *  with a single entry (a TextField as a weak key).
	 */
	private var textFields:Dictionary = new Dictionary(true);
			
	/**
	 *  @private
	 *  Cache of TLFTextFields. Limit of one per module factory.
	 *  In this Dictionary, each key is a weak reference
	 *  to an IFlexModuleFactory and each value is a Dictionary
	 *  with a single entry (a TLFTextField as a weak key).
	 */
	private var tlfTextFields:Dictionary = new Dictionary(true);
			
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  @private
	 *  Creates an instance of TextField
	 *  in the context of the specified IFlexModuleFactory.
	 *
	 *  @param moduleFactory The IFlexModuleFactory requesting the TextField.
	 *
	 *	@return A TLFTextField created in the context
	 *  of <code>moduleFactory</code>.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function createTextField(moduleFactory:IFlexModuleFactory):TextField
	{
		// Check to see if we already have a text field for this module factory.
		var textField:TextField = null;
		var textFieldDictionary:Dictionary = textFields[moduleFactory];

		if (textFieldDictionary)
		{
			for (var iter:Object in textFieldDictionary)
			{
				textField = TextField(iter);
				break;
			}
		}
		if (!textField)
		{
			if (moduleFactory)
				textField = TextField(moduleFactory.create("flash.text.TextField"));			
			else 
				textField = new TextField();	
			
			// The dictionary could be empty, but not null because entries in the dictionary
			// could be garbage collected.
			if (!textFieldDictionary)
				textFieldDictionary = new Dictionary(true);
			textFieldDictionary[textField] = 1;
			textFields[moduleFactory] = textFieldDictionary;
		}

		return textField;
	}

	/**
	 *  @private
	 *  Creates an instance of TLFTextField
	 *  in the context of the specified module factory.
	 * 
	 *  @param moduleFactory The IFlexModuleFactory requesting the TextField.
	 *  May not be <code>null</code>.
	 *
	 *	@return A TLFTextField created in the context
	 *  of <code>moduleFactory</code>.
	 *  The return value is loosely typed as Object
	 *  to avoid linking in TLFTextField (and therefore much of TLF).
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 4
	 */
	public function createTLFTextField(moduleFactory:IFlexModuleFactory):Object
	{
		// Check to see if we already have a text field for this module factory.
		var tlfTextField:Object = null;
		var tlfTextFieldDictionary:Dictionary = tlfTextFields[moduleFactory];

		if (tlfTextFieldDictionary)
		{
			for (var iter:Object in tlfTextFieldDictionary)
			{
				tlfTextField = iter;
				break;
			}
		}
		if (!tlfTextField)
		{
			if (moduleFactory)
			{
				tlfTextField = moduleFactory.create(
					"flashx.textLayout.controls.TLFTextField");
                tlfTextField.textLineCreator = moduleFactory;
			}			
			
			// The dictionary could be empty, but not null because entries in the dictionary
			// could be garbage collected.
			if (!tlfTextFieldDictionary)
				tlfTextFieldDictionary = new Dictionary(true);
			tlfTextFieldDictionary[tlfTextField] = 1;
			tlfTextFields[moduleFactory] = tlfTextFieldDictionary;
		}

		return tlfTextField;
	}
}

}
