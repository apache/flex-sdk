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
    
import mx.events.FlexEvent;

/**
 *  The Range class holds a value and an allowed range for that 
 *  value, defined by <code>minimum</code> and <code>maximum</code> properties. 
 *  The <code>value</code> property 
 *  is always constrained to be between the current <code>minimum</code> and
 *  <code>maximum</code>, and the <code>minimum</code>,
 *  and <code>maximum</code> are always constrained
 *  to be in the proper numerical order, such that
 *  <code>(minimum &lt;= value &lt;= maximum)</code> is <code>true</code>. 
 *  If the value of the <code>snapInterval</code> property is not 0, 
 *  then the <code>value</code> property is also constrained to be a multiple of 
 *  <code>snapInterval</code>.
 * 
 *  <p>Range is a base class for various controls that require range
 *  functionality, including TrackBase and Spinner.</p>
 *
 *  @mxml
 *
 *  <p>The <code>&lt;s:Range&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:Range
 *    <strong>Properties</strong>
 *    maximum="100"
 *    minimum="0"
 *    snapInterval="1"
 *    stepSize="1"
 *    value="0"
 *  /&gt;
 *  </pre> 
 * 
 *  @see spark.components.supportClasses.TrackBase
 *  @see spark.components.Spinner
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */  
public class Range extends SkinnableComponent
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
    public function Range():void
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
     *  The maximum valid <code>value</code>.
     * 
     *  <p>Changes to the value property are constrained
     *  by <code>commitProperties()</code> to be less than or equal to
     *  maximum with the <code>nearestValidValue()</code> method.</p> 
     *
     *  @default 100
     *  @see #nearestValidValue
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  The minimum valid <code>value</code>.
     * 
     *  <p>Changes to the value property are constrained
     *  by <code>commitProperties()</code> to be greater than or equal to
     *  minimum with the <code>nearestValidValue()</code> method.</p> 
     *
     *  @default 0
     *  @see #nearestValidValue
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
    
    [Inspectable(minValue="0.0")]

    /**
     *  The amount that the <code>value</code> property 
     *  changes when the <code>changeValueByStep()</code> method is called. It must
     *  be a multiple of <code>snapInterval</code>, unless 
     *  <code>snapInterval</code> is 0. 
     *  If <code>stepSize</code>
     *  is not a multiple, it is rounded to the nearest 
     *  multiple that is greater than or equal to <code>snapInterval</code>.
     *
     *  @default 1
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
    private var _changedValue:Number = 0;
    private var valueChanged:Boolean = false;
    
    [Bindable(event="valueCommit")]

    /**
     *  The current value for this range.
     *  
     *  <p>Changes to the value property are constrained
     *  by <code>commitProperties()</code> to be greater than or equal to
     *  the <code>minimum</code> property, less than or equal to the <code>maximum</code> property, and a
     *  multiple of <code>snapInterval</code> with the <code>nearestValidValue()</code>
     *  method.</p> 
     * 
     *  @default 0
     *  @see #setValue
     *  @see #nearestValidValue
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get value():Number
    {
        return (valueChanged) ? _changedValue : _value;
    }


    /**
     *  @private
     *  Implementation note: we temporarily store the new value in
     *  _changedValue and then update _value, by calling setValue()
     *  in commitProperties().  Only one "valueCommit" event is
     *  dispatched, even if this property has effectively changed
     *  twice per nearestValidValue().
     */    
    public function set value(newValue:Number):void
    {
        if (newValue == value)
            return;
        _changedValue = newValue;
        valueChanged = true;
        invalidateProperties();
    }
    
    //---------------------------------
    // snapInterval
    //---------------------------------   
     
    private var _snapInterval:Number = 1;

    private var snapIntervalChanged:Boolean = false;
    private var _explicitSnapInterval:Boolean = false;
    
    [Inspectable(minValue="0.0")]    

    /**
     *  If nonzero, valid values are the sum of the minimum with integer multiples
     *  of this property and less than or equal to the maximum.
     *  
     *  <p>If the value of this property is zero, then valid values are only constrained
     *  to be between minimum and maximum inclusive.</p>
     * 
     *  <p>This property also constrains valid values for the <code>stepSize</code> property when set.
     *  If this property is not explicitly set and <code>stepSize</code> is set, 
     *  then <code>snapInterval</code> defaults to <code>stepSize</code>.</p>
     *  
     *  @default 1
     *  @see #nearestValidValue
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get snapInterval():Number
    {
        return _snapInterval;
    }

    public function set snapInterval(value:Number):void
    {
        // snapInterval defaults to stepSize if snapInterval is not
        // explicitly set.
        _explicitSnapInterval = true;
        
        if (value == _snapInterval)
            return;

        // NaN effectively clears the snapInterval and resets it to 1.
        if (isNaN(value))
        {
            _snapInterval = 1;
            _explicitSnapInterval = false;
        }
        else
        {
            _snapInterval = value;
        }
        
        snapIntervalChanged = true;
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

        if (valueChanged || maxChanged || minChanged || snapIntervalChanged)
        {
            var currentValue:Number = (valueChanged) ? _changedValue : _value;
            valueChanged = false;
            maxChanged = false;
            minChanged = false;
            snapIntervalChanged = false;
            setValue(nearestValidValue(currentValue, snapInterval));
        }
        
        if (stepSizeChanged)
        {
            // Only modify stepSize if snapInterval was explicitly set.
            // Otherwise, snapInterval defaults to stepSize and we set
            // the value to respect the new snapInterval.
            if (_explicitSnapInterval)
            {
                _stepSize = nearestValidSize(_stepSize);
            }
            else
            {
                _snapInterval = _stepSize;
                setValue(nearestValidValue(_value, snapInterval));
            }
            
            stepSizeChanged = false;
        }
    }

    /**
     *  @private
     *  Returns the integer multiple of snapInterval that's closest to size.
     * 
     *  <p>If snapInterval is 0, which means that values are only constrained
     *  by the minimum and maximum properties, then size is returned unchanged.</p>
     * 
     *  <p>This method is used by commitProperties() to validate the 
     *  stepSize.</p>
     * 
     *  @param size The input size.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    private function nearestValidSize(size:Number):Number
    {
        var interval:Number = snapInterval;
        if (interval == 0)
            return size;
        
        var validSize:Number = Math.round(size / interval) * interval
        return (Math.abs(validSize) < interval) ? interval : validSize;
    }
    
    /**
     *  Returns the sum of the minimum with an integer multiple of <code>interval</code> that's 
     *  closest to <code>value</code>, unless <code>value</code> is closer to the maximum limit,
     *  in which case the maximum is returned.
     * 
     *  <p>If <code>interval</code> is equal to 0, the value is clipped to the minimum and maximum 
     *  limits.</p>
     * 
     *  <p>The valid values for a range are defined by the sum of the <code>minimum</code> property
     *  with multiples of the <code>interval</code> and also defined to be less than or equal to the
     *  <code>maximum</code> property.
     * 
     *  The maximum need not be a multiple of <code>snapInterval</code>.</p>
     * 
     *  <p>For example, if <code>minimum</code> is equal to 1, <code>maximum</code> is equal to 6,
     *  and <code>snapInterval</code> is equal to 2, the valid
     *  values for the Range are 1, 3, 5, 6.
     * 
     *  Similarly, if <code>minimum</code> is equal to 2, <code>maximum</code> is equal to 9,
     *  and <code>snapInterval</code> is equal to 1.5, the valid
     *  values for the Range are 2, 3.5, 5, 6.5, 8, and 9.</p>
     * 
     *  @param value The input value.
     *  @param interval The value of snapInterval or an integer multiple of snapInterval.
     *  @return The valid value that's closest to the input.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function nearestValidValue(value:Number, interval:Number):Number
    { 
        if (interval == 0)
            return Math.max(minimum, Math.min(maximum, value));
        
        var maxValue:Number = maximum - minimum;
        var scale:Number = 1;
        
        value -= minimum;
        
        // If interval isn't an integer, there's a possibility that the floating point 
        // approximation of value or value/interval will be slightly larger or smaller 
        // than the real value.  This can lead to errors in calculations like 
        // floor(value/interval)*interval, which one might expect to just equal value, 
        // when value is an exact multiple of interval.  Not so if value=0.58 and 
        // interval=0.01, in that case the calculation yields 0.57!  To avoid problems, 
        // we scale by the implicit precision of the interval and then round.  For 
        // example if interval=0.01, then we scale by 100.    
        
        if (interval != Math.round(interval)) 
        { 
            const parts:Array = (new String(1 + interval)).split("."); 
            scale = Math.pow(10, parts[1].length);
            maxValue *= scale;
            value = Math.round(value * scale);
            interval = Math.round(interval * scale);
        }   
        
        var lower:Number = Math.max(0, Math.floor(value / interval) * interval);
        var upper:Number = Math.min(maxValue, Math.floor((value + interval) / interval) * interval);
        var validValue:Number = ((value - lower) >= ((upper - lower) / 2)) ? upper : lower;
        
        return (validValue / scale) + minimum;
    }
        
    /**
     *  Sets the backing store for the <code>value</code> property and 
     *  dispatches a <code>valueCommit</code> event if the property changes.  
     * 
     *  <p>All updates to the <code>value</code> property cause a call to this method.</p>
     * 
     *  <p>This method assumes that the caller has already used the <code>nearestValidValue()</code> method
     *  to constrain the value parameter</p>
     * 
     *  @param value The new value of the <code>value</code> property.
     *  @see #nearestValidValue
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function setValue(value:Number):void
    {
        if (_value == value)
            return;
        if (!isNaN(maximum) && !isNaN(minimum) && (maximum > minimum))
            _value = Math.min(maximum, Math.max(minimum, value));
        else
            _value = value;
        dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
    }
    
    /**
     *  Increases or decreases <code>value</code> by <code>stepSize</code>.
     *
     *  @param increase If true, adds <code>stepSize</code> to <code>value</code>, otherwise, subtracts it.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function changeValueByStep(increase:Boolean = true):void
    {
        if (stepSize == 0)
            return;

        var newValue:Number = (increase) ? value + stepSize : value - stepSize;
        setValue(nearestValidValue(newValue, snapInterval));
    }
}

}