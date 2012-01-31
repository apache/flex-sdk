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

package mx.components
{	

/**
 *  The Skin class defines the base class for all skins used by skinnable components. 
 *  The SkinnableComponent class defines the base class for skinnable components.
 *
 *  <p>You typically write the skin classes in MXML, as the followiong example shows:</p>
 *
 *  <pre>  &lt;?xml version="1.0"?&gt;
 *  &lt;Skin xmlns="http://ns.adobe.com/mxml/2009"&gt;
 *  
 *  &lt;Metadata&gt;
 *          &lt;!-- Specify the component that uses this skin class. --&gt;
 *          [HostComponent("my.component.MyComponent")]
 *      &lt;/Metadata&gt; 
 *      
 *      &lt;states&gt;
 *          &lt;!-- Specify the states controlled by this skin. --&gt;
 *      &lt;/states&gt;
 *          
 *      &lt;!-- Define skin. --&gt;
 *  
 *  &lt;/Skin&gt;</pre>
 *
 *  @see mx.core.SkinnableComponent
 */
public class Skin extends Group
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
	
	private var _fxComponent:Object;
    [Bindable]
    /**
     *  A reference to the component that hosts this skin instance.
     */    
    public function get fxComponent():Object
    {
        return _fxComponent;
    }
    
    /**
     *  @private 
     */    
    public function set fxComponent(value:Object):void
    {
        _fxComponent = value;
    }
    
}

}
