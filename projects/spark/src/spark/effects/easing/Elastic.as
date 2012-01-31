////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.effects.easing
{
import mx.effects.easing.Elastic;

/**
 *  The Elastic class implements easing functionality where the target object
 *  movement is defined by an exponentially decaying sine wave. 
 *  The effect target decelerates toward the end value, and continues past the end value. 
 *  It then oscillates around the end value in smaller and smaller increments, 
 *  before reaching the end value. 
 *
 *  @includeExample examples/BounceElasticEffectExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class Elastic implements IEaser
{
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
    public function Elastic()
    {
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @inheritDoc
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function ease(fraction:Number):Number
    {
        return mx.effects.easing.Elastic.easeOut(fraction, 0, 1, 1);
    }
    
}
}