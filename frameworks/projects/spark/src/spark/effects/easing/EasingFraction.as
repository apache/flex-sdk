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
 * Provides utility constants for use in subclasses of EaseInOutBase.
 * 
 * @see EaseInOutBase
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public final class EasingFraction
{
    /**
     * A utility constant which, when supplied as the 
     * <code>easeInFraction</code> to a subclass of EaseInOutBase, 
     * will create an easing instance
     * that spends the entire animation easing in. This is equivalent
     * to simply using the <code>easeInFraction = 1</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const IN:Number = 1;

    /**
     * A utility constant which, when supplied as the 
     * <code>easeInFraction</code> to a subclass of EaseInOutBase, 
     * will create an easing instance
     * that spends the entire animation easing out. This is equivalent
     * to simply using the <code>easeInFraction = 0</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const OUT:Number = 0;

    /**
     * A utility constant which, when supplied as the 
     * <code>easeInFraction</code> to a subclass of EaseInOutBase, 
     * will create an easing instance
     * that eases in for the first half and eases out for the
     * remainder. This is equivalent
     * to simply using the <code>easeInFraction = .5</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const IN_OUT:Number = .5;
}
}