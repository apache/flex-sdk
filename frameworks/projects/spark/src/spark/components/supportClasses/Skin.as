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

package flex.core
{
import mx.core.IDataRenderer;	

/**
 *  Documentation is not currently available.
 */
public class Skin extends Group implements IDataRenderer
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor. 
     */    
	public function Skin()
	{
		super();
	}
	
	//--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
	
	private var _data:Object;
    [Bindable]
    public function get data():Object
    {
        return _data;
    }
    
    public function set data(value:Object):void
    {
        _data = value;
    }
    
}

}
