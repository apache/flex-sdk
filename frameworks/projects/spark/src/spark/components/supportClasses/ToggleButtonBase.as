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

package spark.components.supportClasses
{

import flash.events.Event;
import flash.events.MouseEvent;

import mx.core.mx_internal;
import mx.events.FlexEvent;

/**
 *  Dispatched when the <code>selected</code> property 
 *  changes for the ToggleButtonBase control. 
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

// FIXME (egeorgie): figure out whether we need this?
[DefaultBindingProperty(source="selected", destination="label")]

/**
 *  The ToggleButtonBase component is the base class for the Spark button components
 *  that support the <code>selected</code> property.
 *  ToggleButton, CheckBox and RadioButton are subclasses of ToggleButtonBase.
 *
 *  @see mx.components.ToggleButton
 *  @see mx.components.CheckBox
 *  @see mx.components.RadioButton
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class ToggleButtonBase extends ButtonBase
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
    public function ToggleButtonBase()
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
     *  Storage for the selected property 
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
