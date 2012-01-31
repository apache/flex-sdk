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

import mx.components.baseClasses.ToggleButtonBase;


[IconFile("FxToggleButton.png")]

/**
 *  The FxToggleButton component defines a toggle button. 
 *  Clicking the button toggles it between the up and an down states.
 *  If you click the button while it is in the up state, 
 *  it toggles to the down state. You must click the button again 
 *  to toggle it back to the up state.
 * 
 *  <p>You can get or set this state programmatically
 *  by using the <code>selected</code> property.</p>
 *
 *  @includeExample examples/FxToggleButtonExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class FxToggleButton extends ToggleButtonBase
{
    include "../core/Version.as";

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
    public function FxToggleButton()
    {
        super();
    }
}
}
