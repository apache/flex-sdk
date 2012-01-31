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

package mx.components.baseClasses
{
    
import flash.events.Event;

import mx.components.baseClasses.FxComponent;

import mx.events.FlexEvent;

/**
 *  The FxRange class holds a value and a legal range for that 
 *  value, defined by a <code>minimum</code> and <code>maximum</code> property. 
 *  The <code>value</code> property 
 *  is always constrained to be between the current <code>minimum</code> and
 *  <code>maximum</code>, and the <code>minimum</code>,
 *  and <code>maximum</code> are always constrained
 *  to be in the proper numerical order such that, at any time,
 *  (minimum &lt;= value &lt;= maximum) is <code>true</code>. 
 *  The <code>value</code> is also constrained to be multiples of 
 *  <code>valueInterval</code> if <code>valueInterval</code> is not 0.
 * 
 *  <p>FxRange has a <code>stepSize</code> property to control 
 *  how much <code>value</code> will change based on small 
 *  stepping operations.</p>
 * 
 *  <p>FxRange is a base class for various controls that require range
 *  functionality, including FxTrackBase and FxSpinner.</p>
 * 
 *  @see mx.components.baseClasses.FxTrackBase
 *  @see mx.components.FxSpinner
 */  
public class FxRange extends FxComponent
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor. 
     */
    public function FxRange():void
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //---------------------------------
    // maximum
    //---------------------------------   
    
    private var _maximum:Number = 100;
    
    private var maxChanged:Boolean = false;
    
    /**
     *  Number which represents the maximum value possible for 
     *  <code>value</code>. If the values for either 
     *  <code>minimum</code> or <code>value</code> are greater
     *  than <code>maximum</code>, they will be changed to 
     *  reflect the new <code>maximum</code>
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
        maxChanged = true;

        invalidateProperties();
    }
    
    //---------------------------------
    // minimum
    //---------------------------------
    
    private var _minimum:Number = 0;
    
    private var minChanged:Boolean = false;
    
    /**
     *  Number which represents the minimum value possible for 
     *  <code>value</code>. If the values for either 
     *  <code>maximum</code> or <code>value</code> are less
     *  than <code>minimum</code>, they will be changed to 
     *  reflect the new <code>minimum</code>
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
        minChanged = true;
        
        invalidateProperties();
    }

    //---------------------------------
    // stepSize
    //---------------------------------    
    
    private var _stepSize:Number = 1;
    
    private var stepSizeChanged:Boolean = false;

    /**
     *  <code>stepSize</code> is the amount that the value 
     *  changes when <code>step()</code> is called. It must
     *  be a multiple of <code>valueInterval</code> unless 
     *  <code>valueInterval</code> is 0. If <code>stepSize</code>
     *  is not a multiple, it is rounded to the nearest multiple 
     *  &gt;= <code>valueInterval</code>.
     *
     *  @default 1
     */
    public function get stepSize():Number
    {
        return _stepSize;
    }

    public function set stepSize(value:Number):void
    {
        if (value == _stepSize)
            return;
            
        _stepSize = value;
        stepSizeChanged = true;
        
        invalidateProperties();       
    }

    //---------------------------------
    // value
    //---------------------------------   
     
    private var _value:Number = 0;

    private var valueChanged:Boolean = false;
    
    [Bindable(event="valueCommit")]

    /**
     *  Number which represents the current value for this range. 
     *  <code>value</code> will always be constrained to lie 
     *  within the current <code>minimum</code> and 
     *  <code>maximum</code> values. It also must be a multiple
     *  of <code>valueInterval</code>.
     * 
     *  @default 0
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
    
    //---------------------------------
    // valueInterval
    //---------------------------------   
     
    private var _valueInterval:Number = 1;

    private var valueIntervalChanged:Boolean = false;

    /**
     *  If greater than 0, <code>valueInterval</code> constrains
     *  <code>value</code> to multiples of itself. If it is 0, then 
     *  <code>value</code> can be any number between minimum and 
     *  maximum. Also, <code>value</code> may always be set to the 
     *  minimum and maximum.
     *  Changing <code>valueInterval</code> also may change 
     *  <code>stepSize</code> to be a multiple of 
     *  <code>valueInterval</code> and &gt;= <code>valueInterval</code>.
     * 
     *  @default 1
     */
    public function get valueInterval():Number
    {
        return _valueInterval;
    }

    public function set valueInterval(value:Number):void
    {
        if (value == _valueInterval)
            return;
        
        _valueInterval = value;
        valueIntervalChanged = true;
        
        stepSizeChanged = true;
        
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

        if (minimum > maximum)
        {
            // Check min <= max
            if (!maxChanged)
                _minimum = _maximum;
            else
                _maximum = _minimum;
        }

        if (valueChanged || maxChanged || minChanged || valueIntervalChanged)
        {
            var newValue:Number = nearestValidValue(_value, valueInterval);
            
            if (valueChanged || newValue != _value)
            {
                _value = newValue;
                dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
            }

            valueChanged = false;
            maxChanged = false;
            minChanged = false;
            valueIntervalChanged = false;
        }
        
        if (stepSizeChanged)
        {
            if (valueInterval != 0)
                _stepSize = nearestValidInterval(_stepSize, valueInterval);
            
            stepSizeChanged = false;
        }
    }

    /**
     *  Round a value (such as <code>stepSize</code>) 
     *  to the closets multiple of <code>interval</code>.
     *
     *  @param value The value to round.
     *
     *  @param interval The interval.
     *
     *  @return The closets multiple of interval. 
     *  The minimum value returned is <code>interval</code>.
     */
    protected function nearestValidInterval(value:Number, interval:Number):Number
    {
        var closest:Number = Math.round(value / interval)
                             * interval;
        
        if (Math.abs(closest) < interval)
            return interval;
        else
            return closest;
    }

    /**
     *  Rounds <code>value</code> to the closest multiple of  
     *  <code>interval</code>, and constrain the result to the range 
     *  defined by Range. 
     *  If <code>interval</code> is 0, then the <code>value</code> 
     *  is only bound to the range.
     * 
     *  @param value The value to round.
     * 
     *  @param interval The interval to round the value against.
     * 
     *  @return The rounded value, or 0 if <code>value</code> is NaN.
     */
    protected function nearestValidValue(value:Number, interval:Number):Number
    {
        var closest:Number = value;
        
        if (isNaN(closest))
            closest = 0;

        // Round value to closest multiple of valueInterval
        if (interval != 0)
            closest = Math.round(closest / interval) * interval;    
        
        if (closest >= maximum)
            return maximum;
        else if (closest <= minimum)
            return minimum;

        if (interval == 0)
            return closest;

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
     *  Directly sets <code>value</code> without going through the correction
     *  and invalidation processes. Subclasses may use this method if
     *  they wish to customize behavior.
     * 
     *  @param value The new value of <code>value</code>.
     */
    protected function setValue(value:Number):void
    {
        if (_value == value)
            return;
        
        _value = value;
        
        dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
    }
    
    /**
     *  Increase or decrease <code>value</code> by <code>stepSize</code>.
     *  The new value of <code>value</code> is a multiple of <code>stepSize</code>.
     *
     *  @param increase Whether the stepping action increases (<code>true</code>) or
     *  decreases (<code>false</code>) the <code>value</code>.
     */
    public function step(increase:Boolean = true):void
    {
        if (increase)
            setValue(nearestValidValue(value + stepSize, stepSize));
        else
            setValue(nearestValidValue(value - stepSize, stepSize));
    }
}

}