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

package mx.resources
{

[ExcludeClass]

/**
 *  @private
 *  When the MXML compiler compiles a resource module, the class
 *  that it autogenerates to represent the module implements this interface.
 */
public interface IResourceModule
{
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  An Array of ResourceBundle instances, containing one for each
	 *  of the resource bundle classes in this resource module.
	 *  
	 *  <p>The order of ResourceBundle instances in this Array
	 *  is not specified.</p>
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	function get resourceBundles():Array /* of ResourceBundle */;
}

}
