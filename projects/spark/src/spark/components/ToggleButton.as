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

package flex.component
{

import flash.events.Event;
import flash.events.MouseEvent;

import mx.events.FlexEvent;

/**
 *  Dispatched when the <code>selected</code> property 
 *  changes for the ToggleButton control. 
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

/**
 *  Documentation is not currently available.
 */
public class ToggleButton extends Button
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
    public function ToggleButton()
	{
		super();
		
		addEventListener(MouseEvent.CLICK, clickHandler);
	}
    
    // -----------------------------------------------------------------------
    //
    // Public properties defining the state of the ToggleButton.
    //
    // -----------------------------------------------------------------------

    protected static const selectedFlag:uint = Button.lastFlag << 1;
    
	protected static const lastFlag:uint = selectedFlag;
    
    [Bindable]
    
	public function get selected():Boolean
    {
        return flags.isSet(selectedFlag);
    }
    
	public function set selected(value:Boolean):void
    {
        if (!flags.update(selectedFlag, value))
            return;

        dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
        invalidateSkinState();
    }

    //--------------------------------------------------------------------------
    //
    //  States
    //
    //--------------------------------------------------------------------------

    /**
     *  <code>getUpdatedSkinState</code> returns a string representation of the component's
     *  state as a combination of some of its public properties.
     */ 
    protected override function getUpdatedSkinState():String
    {
        if( !selected )
            return super.getUpdatedSkinState();
        else
            return super.getUpdatedSkinState() + "AndSelected";
    }

    protected function clickHandler(event:MouseEvent):void
    {
        if (!isEnabled)
            return;
        selected = !selected;
        dispatchEvent(new Event(Event.CHANGE));
        event.updateAfterEvent();
    }
}

}