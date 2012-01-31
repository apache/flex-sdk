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
package spark.effects.interpolation
{
    
import mx.resources.IResourceManager;
import mx.resources.ResourceManager;    

//--------------------------------------
//  Other metadata
//--------------------------------------

[ResourceBundle("sparkEffects")]
    
/**
 *  The ArrayInterpolator class interpolates each element of an Array
 *  of start and end elements separately, using another interpolator to do
 *  the interpolation for each element. 
 *  By default, the 
 *  interpolation for each element uses the NumberInterpolator class, but you 
 *  can construct an ArrayInterpolator instance with a different interpolator.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class ArrayInterpolator implements IInterpolator
{
    
    /**
     *  Constructor. 
     *
     *  @param elementInterpolator The interpolator for each element
     *  of the Array.
     *  If no interpolator is specified, use the NumberInterpolator class.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function ArrayInterpolator(elementInterpolator:IInterpolator = null)
    {
        if (elementInterpolator != null)
            this.elementInterpolator = elementInterpolator;
    }

    /**
     *  @private
     *  Used for accessing localized Error messages.
     */
    private var resourceManager:IResourceManager =
                                    ResourceManager.getInstance();

    // The internal per-element interpolator
    private var _elementInterpolator:IInterpolator = NumberInterpolator.getInstance();
    /**
     *  The interpolator for each element of the input Array. 
     *  A value of null specifies to use the NumberInterpolator class.
     *  
     *  @default NumberInterpolator
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
    /**
     *  @private
     */
    public function set elementInterpolator(value:IInterpolator):void
    {
        _elementInterpolator = value ? 
            value : (NumberInterpolator.getInstance());
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