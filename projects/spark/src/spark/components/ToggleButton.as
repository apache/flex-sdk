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

/**
 *  Dispatched when the <code>selected</code> property 
 *  changes for the FxToggleButton control. 
 * 
 *  This event is dispatched only when the 
 *  user interacts with the control by using the mouse.
 *
 *  @eventType flash.events.Event.CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="change", type="flash.events.Event")]

/**
 *  Up State of the Button when it's selected
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("upAndSelected")]

/**
 *  Over State of the Button when it's selected
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("overAndSelected")]

/**
 *  Down State of the Button when it's selected
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("downAndSelected")]

/**
 *  Disabled State of the Button when it's selected
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("disabledAndSelected")]

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
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
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
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  selected
    //----------------------------------

    /**
     *  @private
     *  Storage for the allowDeselection property 
     */
    private var _selected:Boolean;

    [Bindable]
    
    /**
     *  <code>true</code> if the button is in the down state, 
     *  and <code>false</code> if it is in the up state.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */    
    public function get selected():Boolean
    {
        return _selected;
    }
    
    /**
     *  @private
     */    
    public function set selected(value:Boolean):void
    {
        if (value == _selected)
            return;

        _selected = value;            
        dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
        invalidateSkinState();
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

    //--------------------------------------------------------------------------
    //
    //  Event handling
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */ 
    override protected function clickHandler(event:MouseEvent):void
    {
        super.clickHandler(event);
        selected = !selected;
        dispatchEvent(new Event(Event.CHANGE));
        event.updateAfterEvent();
    }
}

}
