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

// AdobePatentID="B976"

package spark.components.supportClasses


{	
    
import mx.core.UIComponent;

import spark.components.Group;

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
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class Skin extends Group
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */    
	public function Skin()
	{
		super();
	}
    
    /**
     *  @private
     */
    override protected function canSkipMeasurement():Boolean
    {
        var uiOwner:UIComponent = owner as UIComponent;
        
        // We can skip measure if our owning component has explicit sizes
        if (uiOwner && !isNaN(uiOwner.explicitWidth) && !isNaN(uiOwner.explicitHeight))
            return true;
        
        return super.canSkipMeasurement();
    }
}

}
