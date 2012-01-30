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

package mx.core
{
    
import flash.events.IEventDispatcher;

/**
 *  The IStateClient2 interface defines the interface that 
 *  components must implement to support Flex 4 view state
 *  semantics.
 */
public interface IStateClient2 extends IEventDispatcher
{   
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------


    //----------------------------------
    //  currentState
    //----------------------------------

    /**
     *  The current view state.
     */
    function get currentState():String;
    
    /**
     *  @private
     */
    function set currentState(value:String):void;
    
    
    //----------------------------------
    //  states
    //----------------------------------

    [ArrayElementType("mx.states.State")]

    /**
     *  The set of view state objects.
     */
    function get states():Array;

    /**
     *  @private
     */
    function set states(value:Array):void;
    
    
    //----------------------------------
    //  transitions
    //----------------------------------
    
    [ArrayElementType("mx.states.Transition")]
    
    /**
     *  The set of view state transitions.
     */
    function get transitions():Array;

    /**
     *  @private
     */
    function set transitions(value:Array):void;
}

}