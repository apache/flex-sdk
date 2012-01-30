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

import mx.core.mx_internal;

/**
 *  Represents a selector node in a potential chain of selectors used to match
 *  CSS style declarations to components.
 * 
 *  @see mx.styles.CSSSelectorKind
 */
public class CSSSelector
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     * 
     *  @param kind  The kind of selector. For valid values see the
     *  CSSSelectorKind enumeration.
     *  @param value  The plain representation of this selector without
     *  conditions or ancestors.
     *  @param conditions  An optional Array of conditions used to match a
     *  subset of component instances. Currently only a single or a pair of
     *  @param ancestor An optional selector to match on a component that
     *  descends from an arbitrary ancestor.
     *  conditions are supported.
     */
    public function CSSSelector(kind:uint, value:String, conditions:Array=null,
            ancestor:CSSSelector=null)
    {
        _kind = kind;
        _value = value;
        _conditions = conditions;
        _ancestor = ancestor;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  ancestor
    //----------------------------------

    /**
     *  @private
     */ 
    private var _ancestor:CSSSelector;

    /**
     *  If this selector is part of a descendant selector it may have a further
     *  selector defined for an arbitrary ancestor.
     */ 
    public function get ancestor():CSSSelector
    {
        return _ancestor;
    }

    //----------------------------------
    //  conditions
    //----------------------------------

    /**
     *  @private
     */ 
    private var _conditions:Array; // of CSSCondition

    /**
     *  This selector may match a subset of components by specifying further
     *  conditions, i.e. the component may have a particular id, styleName
     *  (equivalent to a 'class' condition in CSS) or state (equivalent to a
     *  'pseudo' condition in CSS).
     * 
     *  @return Array of CSSCondition specified for this selector.
     */
    public function get conditions():Array
    {
        return _conditions;
    }

    //----------------------------------
    //  kind
    //----------------------------------

    /**
     *  @private
     */ 
    private var _kind:uint;

    /**
     *  The kind of selector this instance represents. Options are type,
     *  conditional or descendant.
     * 
     *  @see mx.styles.CSSSelectorKind
     */ 
    public function get kind():uint
    {
        return _kind;
    }

    //----------------------------------
    //  specificity
    //----------------------------------

    /**
     *  Calculates the specificity of a selector chain in order to determine
     *  the precedence when applying several matching style declarations. Note
     *  that id conditions contribute 100 points, pseudo and class conditions
     *  each contribute 10 points, types (including descendants in a chain of
     *  selectors) contribute 1 point. Global selectors (i.e. *) contribute
     *  nothing. The result is the sum of these contributions. Selectors with a
     *  higher specificity override selectors of lower specificity. If
     *  selectors have equival specificity, the declaration order determines
     *  the precedence (i.e. the last one wins).
     */
    public function get specificity():uint
    {
        var s:uint = 0;

        if ("*" != value && "global" != value && "" != value)
            s = 1;

        if (conditions != null)
        {
            for each (var condition:CSSCondition in conditions)
            {
                s += condition.specificity;
            }
        }

        if (ancestor != null)
            s += ancestor.specificity;

        return s;
    }

    //----------------------------------
    //  value
    //----------------------------------

    /**
     *  @private
     */ 
    private var _value:String;

    /**
     *  The value of this selector node (only). To get a String representation
     *  of all conditions and descendants of this selector call the toString()
     *  method.
     * 
     *  If this selector represents the root node of a potential chain of
     *  selectors, the value also represents the subject of the entire selector
     *  expression.
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
     *  Determines whether this selector matches the given component.
     * 
     *  @param object The component to which the selector may apply.
     *  @return true if component is a match, or false if not. 
     */ 
    public function isMatch(object:IAdvancedStyleClient):Boolean
    {
        var match:Boolean = false;
        var condition:CSSCondition = null;

        if (kind == CSSSelectorKind.TYPE_SELECTOR
            || kind == CSSSelectorKind.CONDITIONAL_SELECTOR)
        {
            if (value == "*" || value == "" || object.isAssignableToType(value))
            {
                match = true;
            }

            if (match && conditions != null)
            {
                for each (condition in conditions)
                {
                    match = condition.isMatch(object);
                    if (!match)
                        return false;
                }
            }
        }
        else if (kind == CSSSelectorKind.DESCENDANT_SELECTOR)
        {
            if (conditions != null)
            {
                // First, test if the conditions match
                for each (condition in conditions)
                {
                    match = condition.isMatch(object);
                    if (!match)
                        return false;
                }
            }

            if (ancestor != null)
            {
                // Then reset and test if ancestors match
                match = false;
                var parent:IAdvancedStyleClient = object.styleParent;
                while (parent != null)
                {
                    if (parent.isAssignableToType(ancestor.value)
                        || "*" == ancestor.value)
                    {
                        match = ancestor.isMatch(parent);
                        break;
                    }
                    parent = parent.styleParent;
                }
            }
        }

        return match;
    }

    /**
     *  @private
     */ 
    public function getPseudoSelector():String
    {
        var result:String = null;

        if ((kind == CSSSelectorKind.CONDITIONAL_SELECTOR
            || kind == CSSSelectorKind.DESCENDANT_SELECTOR) && conditions != null)
        {
            for each (var condition:CSSCondition in conditions)
            {
                if (condition.kind == CSSConditionKind.PSEUDO_CONDITION)
                {
                    result = condition.value;
                    break;
                }
            }
        }

        return result;
    }

    /**
     *  @return A String representation of this selector including all of its
     *  syntax, conditions and ancestors.
     */ 
    public function toString():String
    {
        var s:String;

        if (ancestor != null)
        {
            s = ancestor.toString() + " " + value;
        }
        else
        {
            s = value;
        }

        if (conditions != null)
        {
            for each (var condition:CSSCondition in conditions)
            {
                s += condition.toString();
            }
        }

        return s; 
    }
}

}
