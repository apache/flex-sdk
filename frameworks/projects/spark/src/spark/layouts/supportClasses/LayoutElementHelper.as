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

package mx.layout
{

import mx.layout.ILayoutItem;

import mx.core.IConstraintClient;

/**
 *  Documentation is not currently available.
 */
public class LayoutItemHelper
{
    include "../core/Version.as";

    // TODO EGeorgie: move to a more general place, this is not specific to the LayoutItemHelper
    
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @return Returns <code>val</code> clamped to the range of
     *  <code>min</code> or <code>max</code>.
     */
    public static function pinBetween(val:Number, min:Number, max:Number):Number
    {
        return Math.min(max, Math.max(min, val));
    }

    // TODO EGeorgie: this currently works only for constraints specified to
    // the parent. Add constraintRow and constraintColumn support.
    /**
     *  @param item The item whose constraint is returned.
     *  @param name The name of the constraint, i.e. "left", "right", "top",
     *  "bottom", "baseline", "horizontalCenter", "verticalCenter"
     *  @return returns the number for the specified constraint.
     */
    public static function getConstraint(item:ILayoutItem, name:String):Number
    {
        var constraintClient:IConstraintClient = item.target as IConstraintClient;
        if (!constraintClient)
            return NaN;

        var value:String = constraintClient.getConstraintValue(name);
        var result:Array = parseConstraintExp(value);
        if (!result || result.length != 1)
            return NaN;

        return result[0];
    }

    // TODO EGeorgie: Duplicated code! Share this code with the Flex3 Canvas:
    /**
     *  @private
     *  Parses a constraint expression, like left="col1:10" 
     *  so that an array is returned where the first value is
     *  the boundary (ie: "col1") and the second value is 
     *  the offset (ie: 10)
     */
    private static function parseConstraintExp(val:String):Array
    {
        if (!val)
            return null;
        // Replace colons with spaces
        var temp:String = val.replace(/:/g, " ");

        // Split the string into an array 
        var args:Array = temp.split(/\s+/);
        return args;
    }
}

}
