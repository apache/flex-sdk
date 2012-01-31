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
 *  @eventType mx.events.Event
 */
[Event(name="change", type="mx.events.Event")]

/**
 *  A Spinner is used to select a value from an
 *  ordered set. It uses two buttons that increase or
 *  decrease the current value based on the current
 *  step size.
 *  
 *  <p>This control extends the Range class and
 *  is the base class for controls that select a value
 *  from an ordered set such as the NumericStepper control.</p>
 * 
 *  <p>A Spinner consists of two required buttons,
 *  one to increase the value and one to decrease the 
 *  value. </p>
 *
 *  <p>Spinner has the addition property of <code>valueWrap</code> 
 *  which enables value wrapping.</p>
 * 
 *  @see flex.component.Range
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
     *  <code>incrButton</code> is a SkinPart that defines a button that, when
     *  pressed, will cause the value to increment to the next value (based on 
     *  the step size).
     */
    public var incrButton:Button;
    
    [SkinPart]
    /**
     *  <code>decrButton</code> is a SkinPart that defines a button that, when
     *  pressed, will cause the value to decrement to the previous value (based
     *  on the step size).
     */
    public var decrButton:Button;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties: UIComponent
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  enabled
    //----------------------------------

    /**
     *  Enable/disable this component. This also enables/disables 
     *  any of the skin parts for this component.
     * 
     *  @default true
     */
    override public function set enabled(value:Boolean):void
    {
        super.enabled = value;
        enableSkinParts(value);
    }

    //----------------------------------
    //  stepSize
    //----------------------------------

    private var stepSizeChanged:Boolean = false;

    /**
     *  The stepSize property determines the allowed values of
     *  the Spinner. See nearestValidValue() for a complete
     *  description of the allowed values. Also, a stepSize of
     *  less than 0 is not supported.
     * 
     *  @default 1
     */
    override public function set stepSize(value:Number):void
    {
        if (stepSize == value)
            return;

        super.stepSize = value;
        stepSizeChanged = true;

        invalidateProperties()
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
     *  Internal storage for the valueWrap property.
     */
    private var _valueWrap:Boolean = false;
    
    /**
     *  Value wrapping determines the behavior of stepping beyond
     *  the maximum or minimum value. If the valueWrap property 
     *  is set when stepping beyond an extreme, it will set the value
     *  to the opposite extreme instead of not changing the value.
     * 
     *  @return Returns whether this Spinner allows value wrapping.
     *  @default false
     */
    public function get valueWrap():Boolean
    {
        return _valueWrap;
    }

    /**    
     *  Sets whether this Spinner allows value wrapping.
     */
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
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        // Changing the stepSize affects the value
        if (stepSizeChanged)
        {
            var temp:Number = value;
            setValue(nearestValidValue(value));
            
            if (value != temp)
                dispatchEvent(new Event(FlexEvent.VALUE_COMMIT));
            stepSizeChanged = false;
        }
    }

    /**
     *  Called when either button is added. It adds the button's
     *  event handlers and also enables the buttons using 
     *  enableSkinParts().
     */
    override protected function partAdded(partName:String, instance:*):void
    {
        // TODO: autoRepeat as a property?        
        if (instance == incrButton)
        {
            incrButton.addEventListener(FlexEvent.BUTTON_DOWN,
                                        incrButton_buttonDownHandler);
            incrButton.autoRepeat = true;
        }
        else if (instance == decrButton)
        {
            decrButton.addEventListener(FlexEvent.BUTTON_DOWN,
                                        decrButton_buttonDownHandler);
            decrButton.autoRepeat = true;
        }
        
        enableSkinParts(enabled);
    }

    /**
     *  Called when either button is removed. partRemoved 
     *  removes the event handlers.
     */
    override protected function partRemoved(partName:String, instance:*):void
    {
        if (instance == incrButton)
        {
            incrButton.removeEventListener(FlexEvent.BUTTON_DOWN, 
                                           incrButton_buttonDownHandler);
        }
        else if (instance == decrButton)
        {
            decrButton.removeEventListener(FlexEvent.BUTTON_DOWN, 
                                           decrButton_buttonDownHandler);
        }
    }
    
    /**
     *  Make the skins reflect the enabled state of the Spinner.
     */
    protected function enableSkinParts(value:Boolean):void
    {
        if (incrButton)
            incrButton.enabled = value;
        if (decrButton)
            decrButton.enabled = value;
    }
    
    /**
     *  Returns the nearest valid value. This is determined by
     *  stepSize. The allowed values are multiples of stepSize 
     *  away from 0 and restricted to between the maximum and
     *  minimum. However, maximum and minimum are included in the
     *  allowed values even if the distance between of the extremes
     *  and the next or previous allowed value is less
     *  than stepSize.
     */
    override protected function nearestValidValue(value:Number):Number
    {
        if (isNaN(value))
            value = 0;
        
        if (stepSize == 0)
            return value;
        
        // Find the closest multiple of stepSize
        var closest:Number = Math.round(value / stepSize) * stepSize;
        if (closest >= maximum)
            return maximum;
        else if (closest <= minimum)
            return minimum;

        // Round to the closest value (closest multiple, min, or max).
        var cdiff:Number = Math.abs(closest - value);
        var mindiff:Number = Math.abs(minimum - value);
        var maxdiff:Number = Math.abs(maximum - value);
        var min:Number = Math.min(cdiff, mindiff, maxdiff);
        
        // Return order maintains rounding up when in the middle.
        if (min == maxdiff)
            return maximum;
        else if (min == cdiff)
            return closest;
        else 
            return minimum;
    }
    
    /**
     *  Steps value up if <code>increase</code> is true 
     *  and down if false. <code>trigger</code> is passed to commitValue. 
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
                setValue(nearestValidValue(value + stepSize));
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
                setValue(nearestValidValue(value - stepSize));
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
     *  Handle a click on the incrButton. This should step to the next value.
     */
    protected function incrButton_buttonDownHandler(event:Event):void
    {
        var prevValue:Number = this.value;
        step(true);
        if (value != prevValue)
            dispatchEvent(new Event("change"));
    }
    
    /**
     *  Handle a click on the decrButton. This should step to the previous
     *  value.
     */
    protected function decrButton_buttonDownHandler(event:Event):void
    {
        var prevValue:Number = this.value;
        step(false);
        if (value != prevValue)
            dispatchEvent(new Event("change"));
    }   
    
    /**
     *  Handles keyboard input. Right and up arrows increment. Left and down
     *  arrows decrement. Home and end set the value to maximum and minimum
     *  respectively.
     */
    override protected function keyDownHandler(event:KeyboardEvent):void
    {
        var prevValue:Number = this.value;
        
        switch (event.keyCode)
        {
            case Keyboard.DOWN:
            case Keyboard.LEFT:
            {
                step(false);
                break;
            }

            case Keyboard.UP:
            case Keyboard.RIGHT:
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
    }

}

}
