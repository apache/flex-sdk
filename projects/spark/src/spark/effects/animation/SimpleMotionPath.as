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

package mx.effects
{
    
/**
 * This class is used to hold the name of a property and the values that
 * that property will assume over time for instances of the FxAnimate
 * effect, or subclasses of that effect.
 * 
 * @see FxAnimate
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class AnimationProperty
{
    /**
     * The name of the property to be animated. The property can
     * be either a property of the target object in the animation
     * or a style.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var property:String;
    
    private var _valueFrom:Object;
    /**
     * The value that the named property will animate from.
     * 
     * <p>Null or NaN (in the case of Numbers) element values indicate that a
     * value must be determined dynamically at runtime, either by
     * getting the value from the target property directly or calculating
     * it if the other value is valid and there is also a valid <code>valueBy</code>
     * value supplied.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get valueFrom():Object
    {
        return _valueFrom;
    }
    public function set valueFrom(value:Object):void
    {
        _valueFrom = value;
    }

    private var _valueTo:Object;
    /**
     * The value that the named property will animate to.
     * 
     * <p>Null or NaN (in the case of Numbers) element values indicate that a
     * value must be determined dynamically at runtime, either by
     * getting the value from the target property directly or calculating
     * it if the other value is valid and there is also a valid <code>valueBy</code>
     * value supplied.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get valueTo():Object
    {
        return _valueTo;
    }
    public function set valueTo(value:Object):void
    {
        _valueTo = value;
    }

    private var _valueBy:Object;
    /**
     * Optional property which specifies the delta used to calculate
     * either the <code>valueFrom</code> or <code>valueTo</code> value.
     * Providing this optional 'by' value gives a
     * mechanism to calculate necessary from/to values if either
     * are not provided or are to be determined dynamically when the Animation
     * begins.
     * <p>The way that the <code>valueBy</code> value is used depends on which of the
     * other values are set. If neither are set, then the <code>valueFrom</code> 
     * value is determined from the current value and the <code>valueTo</code> 
     * value is <code>valueFrom + valueBy</code>. 
     * If one or the other is set, but not both, then
     * the unset value is calulated by the other value plus or minus the
     * delta (<code>valueTo = valueFrom + valueBy</code>, 
     * <code>valueFrom = valueTo - valueBy</code>). If both are set, then the
     * <code>valueBy</code> property is ignored.</p>
     * <p>Note that <code>by</code> since <code>valueBy</code> is of type
     * Object, the system does not know how to calculate the other values
     * from it. It will call into the supplied <code>interpolator</code>
     * object to calculate the values through its increment() and decrement()
     * functions. If no interpolator is set, then it will use NumberInterpolator
     * by default.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get valueBy():Object
    {
        return _valueBy;
    }
    public function set valueBy(value:Object):void
    {
        _valueBy = value;
    }
    
    public function AnimationProperty(property:String = null, valueFrom:Object = null,
        valueTo:Object = null, valueBy:Object = null)
    {
        super();
        this.property = property;
        this.valueFrom = valueFrom;
        this.valueTo = valueTo;
        this.valueBy = valueBy;
    }
}
}