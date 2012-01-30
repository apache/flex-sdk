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
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
final public class CSSConditionKind
{
    /**
     *  A selector condition to match a component by styleName.
     *  Examples:
     *      Button.special { ... }
     *      .special { ... }
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const CLASS:String = "class";

    /**
     *  A selector condition to match a component by id.
     *  Examples:
     *      Button#special { ... }
     *      #special { ... }
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ID:String = "id";

    /**
     *  A selector condition to match a component by state (which may be
     *  dynamic and change over time).
     *  Examples:
     *      Button:special { ... }
     *      :special { ... }
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public static const PSEUDO:String = "pseudo";

    /**
     *  Constructor. Not used.
     *  @private
     */   
    public function CSSConditionKind()
    {
    }
}
}
