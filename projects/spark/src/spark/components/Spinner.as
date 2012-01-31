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
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import mx.events.FlexEvent;
import mx.managers.IFocusManagerComponent;

/**
 *  Dispatched when the value of the Spinner control changes
 *  as a result of user interaction.
 *
 *  @eventType flash.events.Event
 */
[Event(name="change", type="flash.events.Event")]

/**
 *  A Spinner is used to select a value from an
 *  ordered set. It uses two buttons that increase or
 *  decrease the current value based on the current
 *  <code>stepSize</code>.
 *  
 *  <p>This control extends the Range class and
 *  is the base class for controls that select a value
 *  from an ordered set such as the NumericStepper control.</p>
 * 
 *  <p>A Spinner consists of two required buttons,
 *  one to increase the value and one to decrease the 
 *  value. </p>
 *
 *  <p>Spinner has the addition property of 
 *  <code>valueWrap</code> which enables value wrapping.</p>
 * 
 *  @see flex.component.Range
 *  @see flex.component.NumericStepper
 */
public class Spinner extends Range implements IFocusManagerComponent
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
    public function Spinner():void
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    // SkinParts
    //
    //--------------------------------------------------------------------------
    
    [SkinPart]
    
    /**
     *  <code>incrementButton</code> is a SkinPart that defines 
     *  a button that, when pressed, will cause <code>value</code>
     *  to increment by <code>stepSize</code>.
     */
    public var incrementButton:Button;
    
    [SkinPart]
    
    /**
     *  <code>decrementButton</code> is a SkinPart that defines
     *  a button that, when pressed, will cause <code>value</code>
     *  to decrement by <code>stepSize</code>.
     */
    public var decrementButton:Button;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties: UIComponent
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  enabled
    //----------------------------------

    /**
     *  Enable/disable this component. This also enables/disables any of the 
     *  skin parts for this component.
     */
    override public function set enabled(value:Boolean):void
    {
        super.enabled = value;
        enableSkinParts(value);
    }

    //--------------------------------------------------------------------------
    //
    // Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  valueWrap
    //----------------------------------
    
    /**
     *  @private
     */
    private var _valueWrap:Boolean = false;
    
    /**
     *  <code>valueWrap</code> determines the behavior of stepping 
     *  beyond the maximum or minimum value. If 
     *  <code>valueWrap</code> is true when stepping beyond an 
     *  extreme, it will set <code>value</code> to the opposite
     *  extreme.
     * 
     *  @default false
     */
    public function get valueWrap():Boolean
    {
        return _valueWrap;
    }

    public function set valueWrap(value:Boolean):void
    {
        _valueWrap = value;
    }
    
    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:*):void
    {
        // TODO: autoRepeat as a property on Spinner?        
        if (instance == incrementButton)
        {
            incrementButton.addEventListener(FlexEvent.BUTTON_DOWN,
                                        incrementButton_buttonDownHandler);
            incrementButton.autoRepeat = true;
        }
        else if (instance == decrementButton)
        {
            decrementButton.addEventListener(FlexEvent.BUTTON_DOWN,
                                        decrementButton_buttonDownHandler);
            decrementButton.autoRepeat = true;
        }
        
        enableSkinParts(enabled);
    }

    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:*):void
    {
        if (instance == incrementButton)
        {
            incrementButton.removeEventListener(FlexEvent.BUTTON_DOWN, 
                                           incrementButton_buttonDownHandler);
        }
        else if (instance == decrementButton)
        {
            decrementButton.removeEventListener(FlexEvent.BUTTON_DOWN, 
                                           decrementButton_buttonDownHandler);
        }
    }
    
    /**
     *  Make the skins reflect the enabled state of the Spinner.
     */
    protected function enableSkinParts(value:Boolean):void
    {
        if (incrementButton)
            incrementButton.enabled = value;
        if (decrementButton)
            decrementButton.enabled = value;
    }
    
    /**
     *  @private
     *  Adds complex behavior to step in order to adhere to
     *  multiples of stepSize (including maximum and minimum).
     */
    override public function step(increase:Boolean = true):void
    {
        if (stepSize == 0)
            return;

        if (increase)
        {
            if (value == maximum && valueWrap)
            {
                // Check for value wrapping
                setValue(minimum);
            }
            else if (value == minimum)
            {
                // Edge case when going up from the minimum.
                var steppedDown:Number = stepSize * Math.ceil(minimum / stepSize);
                if (steppedDown == minimum)
                    setValue(minimum + stepSize);
                else
                    setValue(steppedDown);
            }
            else
            {
                setValue(nearestValidValue(value + stepSize, stepSize));
            }
        }
        else
        {
            if (value == minimum && valueWrap)
            {
                // Check for value wrapping
                setValue(maximum);
            }
            else if (value == maximum)
            {
                // Edge case when coming down from the maximum
                var steppedUp:Number = stepSize * Math.floor(maximum / stepSize);
                if (steppedUp == maximum)
                    setValue(maximum - stepSize);
                else
                    setValue(steppedUp);
            }
            else
            {
                setValue(nearestValidValue(value - stepSize, stepSize));
            }
        }
    }
    
    //--------------------------------------------------------------------------
    // 
    // Event Handlers
    //
    //--------------------------------------------------------------------------
    
    //--------------------------------- 
    // Mouse handlers
    //---------------------------------
   
    /**
     *  Handle a click on the incrementButton. This should
     *  increment <code>value</code> by <code>stepSize</code>.
     */
    protected function incrementButton_buttonDownHandler(event:Event):void
    {
        var prevValue:Number = this.value;
        
        step(true);
        
        if (value != prevValue)
            dispatchEvent(new Event("change"));
    }
    
    /**
     *  Handle a click on the decrementButton. This should
     *  decrement <code>value</code> by <code>stepSize</code>.
     */
    protected function decrementButton_buttonDownHandler(event:Event):void
    {
        var prevValue:Number = this.value;
        
        step(false);
        
        if (value != prevValue)
            dispatchEvent(new Event("change"));
    }   
    
    /**
     *  Handles keyboard input. Up arrow increments. Down arrow
     *  decrements. Home and End keys set the value to maximum
     *  and minimum respectively.
     */
    override protected function keyDownHandler(event:KeyboardEvent):void
    {
        var prevValue:Number = this.value;
        
        switch (event.keyCode)
        {
            case Keyboard.DOWN:
            //case Keyboard.LEFT:
            {
                step(false);
                break;
            }

            case Keyboard.UP:
            //case Keyboard.RIGHT:
            {
                step(true);
                break;
            }

            case Keyboard.HOME:
            {
                value = minimum;
                break;
            }

            case Keyboard.END:
            {
                value = maximum;
                break;
            }
            
            default:
            {
                super.keyDownHandler(event);
                break;
            }
        }

        if (value != prevValue)
            dispatchEvent(new Event("change"));

        event.stopImmediatePropagation();
    }
}

}