////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

package spark.layouts.supportClasses
{

[ExcludeClass]

/**
 *  @private
 *  The LayoutElementHelper class is for internal use only.
 *  TODO (egeorgie): move to a more general place, this is not specific to the LayoutElementHelper
 */
public class LayoutElementHelper
{
    include "../../core/Version.as";

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
        return result[0];
    }

    /**
     *  @private
     *  Parses a constraint expression, like left="col1:10" 
     *  so that an array is returned where the first value is
     *  the offset (ie: 10) and the second value is 
     *  the boundary (ie: "col1")
     */
    public static function parseConstraintExp(val:Object):Array
    {
        if (val is Number)
            return [Number(val), null];
        
        if (!val)
            return [NaN, null];
        // Replace colons with spaces
        var temp:String = String(val).replace(/:/g, " ");
        
        // Split the string into an array 
        var args:Array = temp.split(/\s+/);
        
        // If the val was a String object representing a single number (i.e. "100"),
        // then we'll hit this case:
        if (args.length == 1)
            return args;
        
        // Return [offset, boundary]
        return [args[1], args[0]];
    }
}

}
