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
 * The NumberInterpolator class provides interpolation between
 * start and end values represented as Number instances.
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class NumberInterpolator implements IInterpolator
{
    private static var theInstance:NumberInterpolator;

    /**
     *  Constructor.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function NumberInterpolator()
    {
        super();
    }

    /**
     *  @private
     *  Used for accessing localized Error messages.
     */
    private var resourceManager:IResourceManager =
                                    ResourceManager.getInstance();

    /**
     *  Returns the singleton of this class.
     *  Since all NumberInterpolators
     *  have the same behavior, there is no need for more than one instance.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static function getInstance():NumberInterpolator
    {
        if (!theInstance)
            theInstance = new NumberInterpolator();
        return theInstance;
    }

    /**
     *  Interpolation for NumberInterpolator consists of a simple
     *  parametric calculation between <code>startValue</code> and
     *  <code>endValue</code>, using <code>fraction</code> as the
     *  fraction of the elapsed time from start to end:
     *
     *  <pre>return startValue + fraction * (endValue - startValue);</pre>
     *
     *  @param fraction The fraction elapsed of the
     *  animation, between 0.0 and 1.0.
     *
     *  @param startValue The start value of the interpolation.
     *
     *  @param endValue The end value of the interpolation.
     *
     *  @return The interpolated value.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function interpolate(fraction:Number, startValue:Object,
        endValue:Object):Object
    {
        // Quick test for 0 or 1 to avoid round-off error on either end
        if (fraction == 0)
            return startValue;
        else if (fraction == 1)
            return endValue;
        if ((startValue is Number && isNaN(Number(startValue))) ||
            (endValue is Number && isNaN(Number(endValue))))
            throw new Error(resourceManager.getString("sparkEffects", "cannotCalculateValue", [startValue, endValue]));
        return Number(startValue) + (fraction * (Number(endValue) - Number(startValue)));
    }

    /**
     *  @inheritDoc
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function increment(baseValue:Object, incrementValue:Object):Object
    {
        return Number(baseValue) + Number(incrementValue);
    }

    /**
     *  @inheritDoc
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
   public function decrement(baseValue:Object, decrementValue:Object):Object
   {
        return Number(baseValue) - Number(decrementValue);
   }
}
}
