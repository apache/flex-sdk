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

package mx.styles
{

/**
 *  This interface describes the advanced propeties that a component must
 *  implement to fully participate in the advanced style subsystem.
 */
public interface IAdvancedStyleClient extends IStyleClient
{
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  pseudoSelectorState
    //----------------------------------

    /**
     *  The current state of this component used to match CSS pseudo-selectors.
     *  If no state exists, returns null.
     * 
     *  Note Spark components use their skin state as the pseudo state, where
     *  as Halo components use their currentState property.
     */
    function get pseudoSelectorState():String;

    //----------------------------------
    //  id
    //----------------------------------

    /**
     *  The identity of the component.
     */ 
    function get id():String;

    //----------------------------------
    //  styleParent
    //----------------------------------

    /**
     *  The parent of this component.
     */ 
    function get styleParent():IAdvancedStyleClient;


    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Determines whether this instance is the same as - or is a subclass of -
     *  the given type.
     */ 
    function isAssignableToType(type:String):Boolean;

    /**
     *   Apply state specific styles.
     */
    function applyStateStyles(oldState:String, newState:String, recursive:Boolean):void;
}

}
