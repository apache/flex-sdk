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

package spark.effects
{
import spark.effects.interpolation.NumberArrayInterpolator;
    
    
/**
 * This class is used to hold the name of a property and the values that
 * that property will assume over time for instances of the Animate
 * effect, or subclasses of that effect. This class is a simple utility
 * subclass of MotionPath, setting up two keyframes to hold the 
 * <code>valueFrom</code>, <code>valueTo</code>, and
 * <code>valueBy</code> properties.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class AnimationProperty extends MotionPath
{
 
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     * Constructs an AnimationProperty object. The from/to/by values are used
     * to construct a simple one-keyframe MotionPath where the from value
     * is defined in the MotionPath object itself and the single keyframe.
     * 
     * @param property The name of the property being animated
     * @param valueFrom The value that the animation starts from
     * @param valueTo The value that the animation ends on
     * @param duration The time, in milliseconds, that the animation should take
     * @param valueBy An optional parameter that specifies the delta with
     * which to calculate either the from or to values.
     */    
    public function AnimationProperty(property:String = null, 
        valueFrom:Object = null, valueTo:Object = null, 
        duration:Number = NaN, valueBy:Object = null)
    {
        super();
        this.property = property;
        keyframes = [new KeyFrame(0, valueFrom), new KeyFrame(duration, valueTo, valueBy)];
        if (valueFrom is Array && valueTo is Array)
            interpolator = NumberArrayInterpolator.getInstance();
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    /**
     * The starting value for the property during the animation.
     * 
     * <p>Null or NaN (in the case of Numbers) element values indicate that a
     * value must be determined dynamically at runtime, either by
     * getting the value from the target property directly or calculating
     * it if the other value is valid and there is also a valid 
     * <code>valueBy</code> value supplied.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get valueFrom():Object
    {
        return keyframes[0].value;
    }
    public function set valueFrom(value:Object):void
    {
        keyframes[0].value = value;
    }

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
        return keyframes[keyframes.length -1].value;
    }
    public function set valueTo(value:Object):void
    {
        keyframes[keyframes.length - 1].value = value;
    }

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
        return keyframes[keyframes.length - 1].valueBy;
    }
    public function set valueBy(value:Object):void
    {
        keyframes[keyframes.length - 1].valueBy = value;
    }

}
}
