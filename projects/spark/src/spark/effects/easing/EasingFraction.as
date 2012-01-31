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
package spark.effects.easing
{
/**
 *  The EasingFraction class defines constants for 
 *  the <code>easeInFraction</code> property of the EaseInOutBase class.
 * 
 *  @see EaseInOutBase
 *  @see EaseInOutBase#easeInFraction
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public final class EasingFraction
{
    /**
     *  Specifies that the easing instance
     *  spends the entire animation easing in. This is equivalent
     *  to setting the <code>easeInFraction</code> property to 1.0.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const IN:Number = 1;

    /**
     *  Specifies that the easing instance
     *  spends the entire animation easing out. This is equivalent
     *  to setting the <code>easeInFraction</code> property to 0.0.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const OUT:Number = 0;

    /**
     *  Specifies that an easing instance
     *  that eases in for the first half and eases out for the
     *  remainder. This is equivalent
     *  to setting the <code>easeInFraction</code> property to 0.5.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const IN_OUT:Number = 0.5;
}
}