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
package mx.effects.interpolation
{
	
import mx.resources.IResourceManager;
import mx.resources.ResourceManager;	

//--------------------------------------
//  Other metadata
//--------------------------------------

[ResourceBundle("sparkEffects")]
	
/**
 * ArrayInterpolator interpolates each element of start/end array
 * inputs separately, using another internal interpolator to do
 * the per-element interpolation. By default, the per-element
 * interpolation uses <code>NumberInterpolator</code>, but callers
 * can construct ArrayInterpolator with a different interpolator
 * instead.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class ArrayInterpolator implements IInterpolator
{
    
    /**
     * Constructor. An optional parameter provides a per-element
     * interpolator that will be used for every element of the arrays.
     * If no interpolator is supplied, <code>NumberInterpolator</code>
     * will be used by default.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function ArrayInterpolator(value:IInterpolator = null)
    {
        elementInterpolator = value;
    }

    /**
     *  @private
     *  Used for accessing localized Error messages.
     */
    private var resourceManager:IResourceManager =
                                    ResourceManager.getInstance();

    // The internal per-element interpolator
    private var _elementInterpolator:IInterpolator;
    /**
     * The internal interpolator that ArrayInterpolator uses for
     * each element of the input arrays
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get elementInterpolator():IInterpolator
    {
        return _elementInterpolator;
    }
    public function set elementInterpolator(value:IInterpolator):void
    {
        _elementInterpolator = value ? 
            value : (NumberInterpolator.getInstance());
    }

    /**
     * Returns the <code>Array</code> type, which is the type of
     * object interpolated by ArrayInterpolator
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get interpolatedType():Class
    {
        return Array;
    }

    /**
     * @inheritDoc
     * 
     * Interpolation for ArrayInterpolator consists of running a separate
     * interpolation on each element of the startValue and endValue
     * arrays, returning a new Array that holds those interpolated values.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function interpolate(fraction:Number, startValue:Object, 
        endValue:Object):Object
    {
        if (startValue.length != endValue.length)
            throw new Error(resourceManager.getString("sparkEffects", "arraysNotOfEqualLength"));
        var returnArray:Array = [];
        for (var i:int = 0; i < startValue.length; i++)
            returnArray[i] = _elementInterpolator.interpolate(fraction, 
                startValue[i], endValue[i]);

        return returnArray;
    }
    
    /**
     * @inheritDoc
     * 
     * Incrementing for ArrayInterpolator consists of running a separate
     * increment operation on each element of the <code>baseValue</code> array,
     * adding the same <code>incrementValue</code> to each one and
     * returning a new Array that holds those incremented values.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function increment(baseValue:Object, incrementValue:Object):Object
    {
        var returnArray:Array = [];
        for (var i:int = 0; i < baseValue.length; i++)
            returnArray[i] = _elementInterpolator.increment(
                baseValue[i], incrementValue);

        return returnArray;
    }
    
    /**
     * @inheritDoc
     * 
     * Decrementing for ArrayInterpolator consists of running a separate
     * decrement operation on each element of the <code>baseValue</code> array,
     * subtracting the same <code>incrementValue</code> from each one and
     * returning a new Array that holds those decremented values.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function decrement(baseValue:Object, decrementValue:Object):Object
    {
        var returnArray:Array = [];
        for (var i:int = 0; i < baseValue.length; i++)
            returnArray[i] = _elementInterpolator.decrement(
                baseValue[i], decrementValue);

        return returnArray;
    }
        
}
}