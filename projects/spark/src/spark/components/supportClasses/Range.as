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
import flex.core.SkinnableComponent;
import mx.events.FlexEvent;

/**
 *  The Range class holds a value and a legal range for that value, defined by a
 *  minimum and maximum. The value is always constrained to be within the
 *  current minimum and maximum, and the minimum and maximum are always
 *  constrained to be in the proper numerical order such that, at any
 *  time, (minimum &lt;= value &lt;= maximum) is true.
 * 
 *  <p>Range has the <code>stepSize</code> and <code>pageSize</code> properties
 *  to control how much <code>value</code> will change based on small (step) and
 *  large (page) stepping operations.</p>
 * 
 *  <p>Range is a base class for various controls that require Range
 *  functionality, including ScrollBar and its subclasses.</p>
 * 
 *  @see flex.component.ScrollBar
 *  @see flex.component.HScrollBar
 *  @see flex.component.VScrollBar
 */  
public class Range extends SkinnableComponent
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
    public function Range():void
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    private var rangeChanged:Boolean = false;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //////////////////////////////////
    // maximum
    //////////////////////////////////    
    
    private var _maximum:Number = 100;
    
    /**
     *  Number which represents the maximum value possible for 
     *  <code>value</code>. If the values for either <code>minimum</code> or
     *  <code>value</code> are greater than <code>maximum</code>, they will
     *  be changed to reflect the new max value.
     *
     *  @default 100
     */
    public function get maximum():Number
    {
        return _maximum;
    }

    public function set maximum(value:Number):void
    {
        if (value == _maximum)
            return;
        _maximum = value;
        
        rangeChanged = true;
        invalidateProperties();
    }
    
    //////////////////////////////////
    // minimum
    //////////////////////////////////    
    
    private var _minimum:Number = 0;
    
    /**
     *  Number which represents the minimum value possible for 
     *  <code>value</code>. If the values for either <code>maximum</code> or
     *  <code>value</code> are less than <code>minimum</code>, they will
     *  be changed to reflect the new min value.
     *
     *  @default 0
     */
    public function get minimum():Number
    {
        return _minimum;
    }
    
    public function set minimum(value:Number):void
    {
        if (value == _minimum)
            return;
        _minimum = value;
        
        rangeChanged = true;
        invalidateProperties();
    }
        
    //////////////////////////////////
    // pageSize
    //////////////////////////////////

    private var _pageSize:Number = 20;

    /**
     *  Amount of change in <code>value</code> when
     *  the range is paged.
     *
     *  @default 20
     */
    public function get pageSize():Number
    {
        return _pageSize;
    }

    public function set pageSize(value:Number):void
    {
        _pageSize = value;
    }   

    //////////////////////////////////
    // stepSize
    //////////////////////////////////    
    
    private var _stepSize:Number = 1;

    /**
     *  Amount of change in <code>value</code> when
     *  the range is stepped.
     *
     *  @default 1
     */
    public function get stepSize():Number
    {
        return _stepSize;
    }

    public function set stepSize(value:Number):void
    {
        _stepSize = value;
    }

    //////////////////////////////////
    // value
    //////////////////////////////////   
     
    private var _value:Number = 0;

    /**
     *  @private
     *  Flag that is set whenever the value changes. This flag is cleared
     *  in commitProperties().
     */
    private var valueChanged:Boolean = false;
    
    [Bindable(event="valueCommit")]

    /**
     *  Number which represents the current value for this range. 
     *  <code>value</code> will always be constrained to lie within the 
     *  current <code>minimum</code> and <code>maximum</code> values.
     */
    public function get value():Number
    {
        return _value;
    }

    public function set value(newValue:Number):void
    {
        if (newValue == _value)
            return;
        
        _value = newValue;
        valueChanged = true;
        
        invalidateProperties();
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();

        if (valueChanged || rangeChanged)
        {
            var newValue:Number = nearestValidValue(_value);
            if (valueChanged || newValue != _value)
            {
            	_value = newValue;
                dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
            }
           
            valueChanged = false;
            rangeChanged = false;            
        }
    }

    /**
     *  Returns the nearest valid value. The value must be between the
     *  maximum and minimum.
     * 
     *  @param value The value to be bounded.
     *  @return The bounded value or 0 if value was NaN.
     */
    protected function nearestValidValue(value:Number):Number
    {
        // NaN returns 0
        if (isNaN(value))
            value = 0;

        // Bound the value.
        if (value > maximum)
            return maximum;
        else if (value < minimum)
            return minimum;
        
        return value;
    }
    
    /**
     *  Directly sets the value without going through the correction
     *  and invalidation processes. Subclasses may use this method if
     *  they wish to customize behavior.
     * 
     *  @param value The value to set Range's value to.
     */
    protected function setValue(value:Number):void
    {
        if (_value == value)
            return;
        
        _value = value;
        dispatchEvent(new Event(FlexEvent.VALUE_COMMIT));
    }
    
    /**
     *  Steps the range value up or down
     *
     *  @param increase Whether the stepping action increases or
     *  decreases <code>value</code>.
     */
    public function step(increase:Boolean = true):void
    {
        value += (increase ? stepSize : -stepSize);
    }
    
    /**
     *  Pages the range value up or down
     *
     *  @param increase Whether the paging action increases or
     *  decreases <code>value</code>.
     */
    public function page(increase:Boolean = true):void
    {
        value += (increase ? pageSize : -pageSize);
    }
}

}
