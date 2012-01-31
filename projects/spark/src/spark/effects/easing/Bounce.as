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
import mx.effects.easing.Bounce;

/**
 *  The Bounce class implements easing functionality simulating gravity
 *  pulling on and bouncing the target object. 
 *  The movement of the effect target accelerates toward the end value, 
 *  and then bounces against the end value several times. 
 *
 *  @includeExample examples/BounceElasticEffectExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class Bounce implements IEaser
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
    public function Bounce()
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
        // We simply call the old Penner function for Bounce to let it
        // handle the calculation. This hard-codes the behavior to
        // be 3.5 bounces and ease-out, although these seem like
        // reasonable defaults.
        return mx.effects.easing.Bounce.easeOut(fraction, 0, 1, 1);
    }
    
}
}