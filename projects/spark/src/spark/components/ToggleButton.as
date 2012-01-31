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

import mx.events.FlexEvent;

/**
 *  Dispatched when the <code>selected</code> property 
 *  changes for the FxToggleButton control. 
 * 
 *  This event is dispatched only when the 
 *  user interacts with the control by using the mouse.
 *
 *  @eventType flash.events.Event.CHANGE
 */
[Event(name="change", type="flash.events.Event")]

/**
 *  The built-in set of states for the ToggleButton component.
 */
[SkinStates("up", "over", "down", "disabled", "upAndSelected", "overAndSelected", "downAndSelected", "disabledAndSelected")]

// TODO EGeorgie: figure out whether we need this?
[DefaultBindingProperty(source="selected", destination="label")]

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
 */
public class FxToggleButton extends FxButton
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
    public function FxToggleButton()
    {
        super();
    }
    
    // -----------------------------------------------------------------------
    //
    // Public properties defining the state of the ToggleButton.
    //
    // -----------------------------------------------------------------------

    /**
     *  @private
     */    
    protected static const selectedFlag:uint = FxButton.lastFlag << 1;
    
    /**
     *  @private
     */    
    protected static const lastFlag:uint = selectedFlag;
    
    [Bindable]
    
    /**
     *  <code>true</code> if the button is in the down state, 
     *  and <code>false</code> if it is in the up state.
     */    
    public function get selected():Boolean
    {
        return flags.isSet(selectedFlag);
    }
    
    /**
     *  @private
     */    
    public function set selected(value:Boolean):void
    {
        if (!flags.update(selectedFlag, value))
            return;

        dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
        invalidateButtonState();
    }

    //--------------------------------------------------------------------------
    //
    //  States
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */ 
    protected override function getCurrentSkinState():String
    {
        if( !selected )
            return super.getCurrentSkinState();
        else
            return super.getCurrentSkinState() + "AndSelected";
    }

    /**
     *  @private
     */ 
    override protected function onClick(event:MouseEvent):void
    {
        super.onClick(event);

        selected = !selected;
        dispatchEvent(new Event(Event.CHANGE));
        event.updateAfterEvent();
    }
}

}