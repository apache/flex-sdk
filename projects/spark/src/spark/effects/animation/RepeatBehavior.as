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
package spark.effects.animation
{
/**
 *  The RepeatBehavior class defines constants for use with <code>repeatBehavior</code>
 *  property of the Animate and Animation classes.
 * 
 *  @see spark.effects.Animate#repeatBehavior
 *  @see Animation#repeatBehavior
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public final class RepeatBehavior
{
    /**
     * Specifies that a repeating animation should progress in a forward direction on
     * every iteration.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const LOOP:String = "loop";
    
    /**
     * Specifies that a repeating animation should reverse direction on
     * every iteration. For example, a reversing animation would play forward
     * on the even iterations and in reverse on the odd iterations.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const REVERSE:String = "reverse";
}
}