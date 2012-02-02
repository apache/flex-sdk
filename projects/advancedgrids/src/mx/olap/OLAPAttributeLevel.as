////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.olap
{

import mx.core.mx_internal;
import mx.collections.IList;

use namespace mx_internal;

/**
 * @private
 */ 
public class OLAPAttributeLevel extends OLAPLevel implements IOLAPAttributeLevel
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
	/**
	 * Constructor
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function OLAPAttributeLevel(name:String)
	{
		super(name);
	}

    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    // dataField
    //----------------------------------
    
	override public function get dataField():String
	{
		return OLAPAttribute(hierarchy).dataField;
	}

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
	
	//----------------------------------
    // userLevel
    //----------------------------------
    
	private var _userLevel:IOLAPLevel;
	
	/**
	 * Any OLAPLevel defined by the user and associated with this OLAPAttributeLevel.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	mx_internal function get userLevel():IOLAPLevel
	{
		return _userLevel;
	}
	
	/**
	 * @private
	 */
	mx_internal function set userLevel(value:IOLAPLevel):void
	{
		_userLevel = value;
	}
	
	//----------------------------------
    // children
    //----------------------------------

    /**
     * A OLAPAttributeLevel has no children.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	public function get children():IList
	{
		//trace("Children in AttributeLevel called. Returning null***");
		return null;
	}
	
}
}