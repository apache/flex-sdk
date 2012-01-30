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
     *  <code>interruptionBehavior</code> property of the Transition class.
     * 
     *  @see Transition#interruptionBehavior
     */
    public final class InterruptionBehavior
    {
        /**
         * Specifies that a transition that interrupts another running
         * transition will end that other transition before starting.
         */
        public static const END:String = "end";
        
        /**
         * Specifies that a transition that interrupts another running
         * transition will stop that other transition in place before starting.
         */
        public static const STOP:String = "stop";
    }
}