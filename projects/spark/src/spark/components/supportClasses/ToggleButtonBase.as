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

use namespace mx_internal;

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

//--------------------------------------
//  Other metadata
//--------------------------------------

[AccessibilityClass(implementation="spark.accessibility.ToggleButtonAccImpl")]

/**
 *  The ToggleButtonBase component is the base class for the Spark button components
 *  that support the <code>selected</code> property.
 *  ToggleButton, CheckBox and RadioButton are subclasses of ToggleButtonBase.
 *
 *  @mxml
 *
 *  <p>The <code>&lt;s:ToggleButtonBase&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:ToggleButtonBase
 *    <strong>Properties</strong>
 *    selected="false"
 * 
 *    <strong>events</strong>
 *    change="<i>No default</i>"
 *  /&gt;
 *  </pre> 
 *
 *  @see spark.components.ToggleButton
 *  @see spark.components.CheckBox
 *  @see spark.components.RadioButton
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
    //  Class mixins
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Placeholder for mixin by ToggleButtonAccImpl.
     */
    mx_internal static var createAccessibilityImplementation:Function;
    
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
     *  Contains <code>true</code> if the button is in the down state, 
     *  and <code>false</code> if it is in the up state.
     *
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
    override protected function getCurrentSkinState():String
    {
        if (!selected)
            return super.getCurrentSkinState();
        else
            return super.getCurrentSkinState() + "AndSelected";
    }
    
    /**
     *  @private
     */ 
    override protected function buttonReleased():void
    {
        super.buttonReleased();
        
        selected = !selected;
        
        dispatchEvent(new Event(Event.CHANGE));
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function initializeAccessibility():void
    {
        if (ToggleButtonBase.createAccessibilityImplementation != null)
            ToggleButtonBase.createAccessibilityImplementation(this);
    }
}

}
