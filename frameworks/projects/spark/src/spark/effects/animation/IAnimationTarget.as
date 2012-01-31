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
 *  The IAnimationTarget interface is implemented by classes that support 
 *  the events for an Animation instance.
 *  It is more typical to use the event listening mechanism on the Animation class,
 *  but an IAnimationTarget implementation approach can provide a lower
 *  overhead and higher performance in some situations for handling update events. 
 *
 *  @see spark.effects.animation.Animation
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public interface IAnimationTarget
{
    /**
     *  Called when an Animation instance starts. If there
     *  is a <code>startDelay</code> on the Animation, this function is called
     *  after that delay.
     *
     *  @param animation The Animation object.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function animationStart(animation:Animation):void;

    /**
     *  Called when an Animation instance ends.
     *
     *  @param animation The Animation object.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function animationEnd(animation:Animation):void;

    /**
     *  Called when an Animation instance repeats. 
     *  The Animation instance must have a <code>repeatCount</code> equal to 0 
     *  (infinitely repeating) or a value greater than 1.
     *
     *  @param animation The Animation object.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function animationRepeat(animation:Animation):void;

    /**
     *  Called during every update of an Animation instance.
     *  If an implementation class is listening to an Animation specifically to
     *  be able to do something after the Animation values are calculated for
     *  a given time, this is the function in which those values should be used.
     *  The other functions in this interface are more informational, just to tell
     *  the listeners when the Animation is starting, stopping, or repeating.
     *  This function is called when values have been calculated and something can be
     *  done with them. 
     *
     *  @param animation The Animation object.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function animationUpdate(animation:Animation):void;
    
}
}