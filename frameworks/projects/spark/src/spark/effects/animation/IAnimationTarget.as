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
package spark.effects.animation
{
/**
 * This interface is implemented by classes that want to be called
 * with the various events happening in an Animation instance.
 * It is more typical to use th event listening mechanism on Animation,
 * but an IAnimationTarget implementation approach can provide a lower
 * overhead and higher performance means of getting update events 
 * in some situations.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public interface IAnimationTarget
{
    /**
     * This function is called when an Animation instance starts. If there
     * is a <code>startDelay</code> on the Animation, this function is called
     * after that delay, when the animation actually begins playing.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function animationStart(animation:Animation):void;

    /**
     * This function is called when an Animation instance ends.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function animationEnd(animation:Animation):void;

    /**
     * This function is called when an Animation instance repeats. The
     * Animation in question must have a repeatCount equal to 0 (infinitely
     * repeating) or greater than 1.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function animationRepeat(animation:Animation):void;

    /**
     * This function is called during every update of an Animation instance.
     * If an implementation class is listening to an Animation specifically to
     * be able to do something after the Animation values are calculated for
     * a given time, this is the function in which those values should be used.
     * The other functions in this interface are more informational, just to tell
     * the listeners when the Animation is starting, stopping, or repeating; this
     * function is called when values have been calculated and something can be
     * done with them. 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function animationUpdate(animation:Animation):void;
    
}
}