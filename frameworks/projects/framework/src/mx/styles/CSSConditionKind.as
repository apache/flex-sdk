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
 *  An enumeration of the kinds of CSSCondition.
 * 
 *  @see mx.styles.CSSCondition
 *  @see mx.styles.CSSSelector
 */
public class CSSConditionKind
{
    /**
     *  A selector condition to match a component by styleName.
     *  Examples:
     *      Button.special { ... }
     *      .special { ... }
     */
    public static const CLASS_CONDITION:uint = 1;

    /**
     *  A selector condition to match a component by id.
     *  Examples:
     *      Button#special { ... }
     *      #special { ... }
     */
    public static const ID_CONDITION:uint = 2;

    /**
     *  A selector condition to match a component by state (which may be
     *  dynamic and change over time).
     *  Examples:
     *      Button:special { ... }
     *      :special { ... }
     */ 
    public static const PSEUDO_CONDITION:uint = 3;

    /**
     *  Constructor. Not used.
     *  
     *  @private
     */   
    public function CSSConditionKind()
    {
    }
}
}
