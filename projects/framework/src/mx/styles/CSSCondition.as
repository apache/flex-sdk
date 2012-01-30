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
     */ 
    public function CSSCondition(kind:uint, value:String)
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
    private var _kind:uint;


    /**
     *  The kind of condition this instance represents. Options are class,
     *  id and pseudo.
     * 
     *  @see mx.styles.CSSConditionKind
     */ 
    public function get kind():uint
    {
        return _kind;
    }

    //----------------------------------
    //  specificity
    //----------------------------------

    public function get specificity():uint
    {
        if (kind == CSSConditionKind.ID_CONDITION)
            return 100;
        else if (kind == CSSConditionKind.CLASS_CONDITION)
            return 10;
        else if (kind == CSSConditionKind.PSEUDO_CONDITION)
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
     *  representation that includes CSS syntax, call the toString() method.
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
     */
    public function isMatch(object:IAdvancedStyleClient):Boolean
    {
        var match:Boolean = false;

        if (kind == CSSConditionKind.CLASS_CONDITION)
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
        else if (kind == CSSConditionKind.ID_CONDITION)
        {
            if (object.id == value)
                match = true;
        }
        else if (kind == CSSConditionKind.PSEUDO_CONDITION)
        {
            if (object.currentState == value)
                match = true;
        }

        return match;
    }

    /**
     *  @return A String representation of this condition, including CSS syntax.
     */ 
    public function toString():String
    {
        var s:String;

        if (kind == CSSConditionKind.CLASS_CONDITION)
            s = ("." + value);
        else if (kind == CSSConditionKind.ID_CONDITION)
            s = ("#" + value);
        else if (kind == CSSConditionKind.PSEUDO_CONDITION)
            s = (":" + value);
        else
            s = ""; 

        return s;
    }
}

}
