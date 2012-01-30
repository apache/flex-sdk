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
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IAdvancedStyleClient extends IStyleClient
{
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  id
    //----------------------------------

    /**
     *  The identity of the component.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */ 
    function get id():String;

    //----------------------------------
    //  styleParent
    //----------------------------------

    /**
     *  The parent of this component.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */ 
    function get styleParent():IAdvancedStyleClient;

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
	/**
	 *  Flex calls the <code>stylesInitialized()</code> method when
	 *  the styles for a component are first initialized.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	function stylesInitialized():void
		
    /**
     *  The current state of this component used to match CSS pseudo-selectors.
     *  If no state exists, returns null.
     * 
     *  Note Spark components use their skin state as the pseudo state, where
     *  as Halo components use their currentState property.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function matchesCSSState(cssState:String):Boolean;

    /**
     *  Determines whether this instance is the same as - or is a subclass of -
     *  the given type.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */ 
    function matchesCSSType(cssType:String):Boolean;
}

}
