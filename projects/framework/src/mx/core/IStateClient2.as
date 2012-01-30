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
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IStateClient2 extends IEventDispatcher, IStateClient 
{   
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  states
    //----------------------------------

    [ArrayElementType("mx.states.State")]

    /**
     *  The set of view state objects.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get transitions():Array;

    /**
     *  @private
     */
    function set transitions(value:Array):void;
    
    /**
     *  Determines whether the specified state has been defined on this
     *  UIComponent. 
     *
     *  @param stateName The name of the state being checked. 
     *
     *  @return Whether or not the specified state has been defined 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function hasState(stateName:String):Boolean
    
}

}