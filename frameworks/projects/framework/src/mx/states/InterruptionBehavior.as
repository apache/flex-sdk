////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package mx.states
{
    /**
     *  The InterruptionBehavior class defines constants for use with the 
     *  <code>interruptionBehavior</code> property of the mx.states.Transition class.
     * 
     *  @see Transition#interruptionBehavior
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public final class InterruptionBehavior
    {
        /**
         *  Specifies that a transition that interrupts another running
         *  transition ends that other transition before starting.
         *  The transition ends by calling the <code>end()</code> method 
         *  on all effects in the transition.
         *  The <code>end()</code> method causes all effects 
         *  to snap to their end state.
         *
         *  @langversion 3.0
         *  @playerversion Flash 10.2
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public static const END:String = "end";
        
        /**
         *  Specifies that a transition that interrupts another running
         *  transition stops that other transition in place before starting.
         *  The transition stops by calling the <code>stop()</code> method 
         *  on all effects in the transition.
         *
         *  @langversion 3.0
         *  @playerversion Flash 10.2
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public static const STOP:String = "stop";
    }
}