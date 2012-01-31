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

import mx.core.ISelectableRenderer;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.utils.BitFlagUtil;

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
public class FxToggleButton extends FxButton implements ISelectableRenderer
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

        flags = BitFlagUtil.update(flags, allowDeselectionFlag, true);
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
    protected static const showFocusIndicatorFlag:uint = FxButton.lastFlag << 2;

    /**
     *  @private
     */    
    protected static const allowDeselectionFlag:uint = FxButton.lastFlag << 4;

    /**
     *  @private
     */    
    protected static const lastFlag:uint = allowDeselectionFlag;
    
    /**
     *  <code>true</code> if the button can be set to
	 *  <code>selected = false</code>
     */    
    public function get allowDeselection():Boolean
    {
        return BitFlagUtil.isSet(flags, allowDeselectionFlag);
    }
    
    /**
     *  @private
     */    
    public function set allowDeselection(value:Boolean):void
    {
        if (BitFlagUtil.isSet(flags, allowDeselectionFlag) == value)
            return;
         
        flags = BitFlagUtil.update(flags, allowDeselectionFlag, value);
    }

    [Bindable]
    
    /**
     *  <code>true</code> if the button is in the down state, 
     *  and <code>false</code> if it is in the up state.
     */    
    public function get selected():Boolean
    {
        return BitFlagUtil.isSet(flags, selectedFlag);
    }
    
    /**
     *  @private
     */    
    public function set selected(value:Boolean):void
    {
        if (BitFlagUtil.isSet(flags, selectedFlag) == value)
            return;
         
        flags = BitFlagUtil.update(flags, selectedFlag, value);

        dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
        invalidateButtonState();
    }

    /**
     *  <code>true</code> if the button should display
     *  as if it has focus even if it doesn't.
     */    
    public function get showFocusIndicator():Boolean
    {
        return BitFlagUtil.isSet(flags, showFocusIndicatorFlag);
    }
    
    /**
     *  @private
     */    
    public function set showFocusIndicator(value:Boolean):void
    {
        if (BitFlagUtil.isSet(flags, showFocusIndicatorFlag) == value)
            return;
         
        flags = BitFlagUtil.update(flags, showFocusIndicatorFlag, value);

		mx_internal::drawFocusAnyway = true;
		drawFocus(value);
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

		if (selected && !allowDeselection)
			return;

        selected = !selected;
        dispatchEvent(new Event(Event.CHANGE));
        event.updateAfterEvent();
    }
}

}