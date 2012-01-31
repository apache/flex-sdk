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

import flash.events.Event;
import flash.events.MouseEvent;

/**
 *  The FxCheckBox component consists of an optional label and a small box
 *  that can contain a check mark or not. 
 *  You can place the optional text label to the left, right, top, or bottom
 *  of the CheckBox.
 *
 *  <p>When a user clicks a FxCheckBox component or its associated text,
 *  the FxCheckBox component sets its <code>selected</code> property
 *  to <code>true</code> for checked, and to <code>false</code> for unchecked.</p>
 */
public class FxCheckBox extends FxToggleButton
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
    public function FxCheckBox()
    {
        super();
    }
}

}
