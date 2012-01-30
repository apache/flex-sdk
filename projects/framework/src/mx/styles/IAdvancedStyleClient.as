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
 *  This interface describes the advanced properties that a component must
 *  implement to fully participate in the advanced style subsystem.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
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
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    function get id():String;

    //----------------------------------
    //  styleParent
    //----------------------------------

    /**
     *  The parent of this component.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  Returns <code>true</code> if <code>cssState</code> matches <code>currentCSSState</code>.
     *  Typically, you do not call this method directly. 
     *  It is called by the <code>mx.styles.CSSCondition.matchesStyleClient()</code> method.
     *
     *  <p>Note Spark components use their skin state as the pseudo state.
     *  Halo components use the <code>currentState</code> property.</p>
     *
     *  @param cssState A possible value of <code>CSSCondition.value</code>.
     *  It represents the current state of this component used to match CSS pseudo-selectors.
     *
     *  @return <code>true</code> if <code>cssState</code> matches <code>currentCSSState</code>. 
     *  By default, <code>currentCSSState</code> is the same as <code>currentState</code>.
     *  If no state exists, return null.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    function matchesCSSState(cssState:String):Boolean;

    /**
     *  Determines whether this instance is the same as, or is a subclass of,
     *  the given type.
     *  Typically, you do not call this method directly. 
     *  It is called by the <code>mx.styles.CSSCondition.matchesStyleClient()</code> method.
     *
     *  @param cssType A CSSSelector object.
     *
     *  @return <code>true</code> if <code>cssType</code> is in the hierarchy of qualified type selectors.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    function matchesCSSType(cssType:String):Boolean;
}

}
