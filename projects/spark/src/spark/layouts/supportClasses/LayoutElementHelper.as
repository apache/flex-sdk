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

package spark.layouts.supportClasses
{

[ExcludeClass]

/**
 *  @private
 *  The LayoutElementHelper class is for internal use only.
 */
public class LayoutElementHelper
{
    include "../../core/Version.as";

    // FIXME (egeorgie): move to a more general place, this is not specific to the LayoutElementHelper
    
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @return Returns <code>val</code> clamped to the range of
     *  <code>min</code> or <code>max</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static function pinBetween(val:Number, min:Number, max:Number):Number
    {
        return Math.min(max, Math.max(min, val));
    }

    /**
     *  @return returns the number for the passed in constraint value. Constraint value
     *  can be a Number, or a string in the format "col1:10".
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static function parseConstraintValue(value:Object):Number
    {
        if (value is Number)
            return Number(value);
        
        var str:String = value as String;
        if (!str)
            return NaN;
        
        var result:Array = parseConstraintExp(str);
        if (!result || result.length < 1)
            return NaN;

        return result[0];
    }

    // FIXME (egeorgie): Duplicated code! Share this code with the Flex3 Canvas:
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
