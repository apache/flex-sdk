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
 *  Represents a condition for a CSSSelector which is used to match a subset of
 *  components based on a particular property.
 * 
 *  @see mx.styles.CSSConditionKind
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class CSSCondition
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     * 
     *  @param kind The kind of condition. For valid values see the
     *  CSSConditionKind enumeration.
     *  @param value The condition value (without CSS syntax).
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function CSSCondition(kind:String, value:String)
    {
        _kind = kind;
        _value = value;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  kind
    //----------------------------------

    /**
     *  @private
     */ 
    private var _kind:String;


    /**
     *  The kind of condition this instance represents. Options are class,
     *  id and pseudo.
     * 
     *  @see mx.styles.CSSConditionKind
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function get kind():String
    {
        return _kind;
    }

    //----------------------------------
    //  specificity
    //----------------------------------

    /**
     *  Calculates the specificity of a conditional selector in a selector
     *  chain. The total specificity is used to determine the precedence when
     *  applying several matching style declarations. id conditions contribute
     *  100 points, pseudo and class conditions each contribute 10 points.
     *  Selectors with a higher specificity override selectors of lower
     *  specificity. If selectors have equal specificity, the declaration order
     *  determines the precedence (i.e. the last one wins).
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function get specificity():int
    {
        if (kind == CSSConditionKind.ID)
            return 100;
        else if (kind == CSSConditionKind.CLASS)
            return 10;
        else if (kind == CSSConditionKind.PSEUDO)
            return 10;
        else
            return 0;
    }

    //----------------------------------
    //  value
    //----------------------------------

    /**
     *  @private
     */ 
    private var _value:String;

    /**
     *  The value of this condition without any CSS syntax. To get a String
     *  representation that includes CSS syntax, call the <code>toString()</code> method.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function get value():String
    {
        return _value;
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Determines whether this condition matches the given component.
     * 
     *  @param object The component to which the condition may apply.
     *  @return true if component is a match, otherwise false. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function matchesStyleClient(object:IAdvancedStyleClient):Boolean
    {
        var match:Boolean = false;

        if (kind == CSSConditionKind.CLASS)
        {
            if (object.styleName != null && object.styleName is String)
            {
                // Look for a match in a potential list of styleNames 
                var styleNames:Array = object.styleName.split(/\s+/);
                for (var i:uint = 0; i < styleNames.length; i++)
                {
                    if (styleNames[i] == value)
                    {
                        match = true;
                        break;
                    }
                }
            }
        }
        else if (kind == CSSConditionKind.ID)
        {
            if (object.id == value)
                match = true;
        }
        else if (kind == CSSConditionKind.PSEUDO)
        {
            if (object.matchesCSSState(value))
                match = true;
        }

        return match;
    }

    /**
     * Returns a String representation of this condition.
     * 
     *  @return A String representation of this condition, including CSS syntax.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function toString():String
    {
        var s:String;

        if (kind == CSSConditionKind.CLASS)
            s = ("." + value);
        else if (kind == CSSConditionKind.ID)
            s = ("#" + value);
        else if (kind == CSSConditionKind.PSEUDO)
            s = (":" + value);
        else
            s = ""; 

        return s;
    }
}

}
