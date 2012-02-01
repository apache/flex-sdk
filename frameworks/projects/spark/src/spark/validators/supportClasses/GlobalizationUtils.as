////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.validators.supportClasses
{
/**
 *  A utility class containing Unicode related functionality not supported in
 *  Flex or ActionScript.
 * 
 *  <p>This class contains the utility routines needed for all Validators. Examples
 *  of typical routines are checking for unicode white space, trimming all 
 *  spaces in a string at the beginning and end.</p>
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class GlobalizationUtils
{

    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class Constants
    //
    //--------------------------------------------------------------------------

    private static const ASCII_SPACE:uint = 0x20;
    private static const NO_BREAK_SPACE:uint = 0xA0;
    private static const UNICODE_OGHAM_SPACE_MARK:uint = 0x1680;
    private static const UNICODE_MONGOLIAN_VOWEL_SEPARATOR:uint = 0x180E;
    private static const UNICODE_SPACE_START:uint = 0x2000;
    private static const UNICODE_SPACE_END:uint = 0x200B;
    private static const UNICODE_NARROW_NOBREAK_SPACE:uint = 0x202F;
    private static const UNICODE_MEDIUM_MATHEMATICAL_SPACE:uint = 0x205F;
    private static const UNICODE_IDEOGRAPHIC_SPACE:uint = 0x3000;
    private static const UNICODE_ZEROWIDTH_NOBREAK_SPACE:uint = 0xFEFF;

    /**
     *  <p> Check if codepoint is a white space.
     *  Uses all unicode white space characters. See the list of public static
     *  constants in this class.</p>
     *
     *  @param <code>int</code> input codepoint
     *  @returns <code>Boolean</code> true or false.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static function isWhiteSpace(ccode:int):Boolean
    {
        if ((ccode == ASCII_SPACE) || (ccode == NO_BREAK_SPACE) ||
            (ccode == 0x9))
        {
            return true;
        }
        else if ((ccode >= UNICODE_SPACE_START) && (ccode <= UNICODE_SPACE_END))
        {
            return true;
        }
        else if ((ccode == UNICODE_NARROW_NOBREAK_SPACE) ||
                 (ccode == UNICODE_MEDIUM_MATHEMATICAL_SPACE))
        {
            return true;
        }
        else if ((ccode == UNICODE_IDEOGRAPHIC_SPACE) ||
                 (ccode == UNICODE_ZEROWIDTH_NOBREAK_SPACE))
        {
            return true;
        }
        else if ((ccode == UNICODE_OGHAM_SPACE_MARK) ||
                 (ccode == UNICODE_MONGOLIAN_VOWEL_SEPARATOR))
        {
            return true;
        }

        return false;
    }

    /**
     *  <p> Remove leading and trailing white space </p>
     *
     *  @param <code>String</code>  Input string to be processed
     *  @return <code>String</code> Output string after removing leading and
     *                              trailing space
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static function trim(input:String):String
    {
        if (!input)
            return null;

        const len:int = input.length;

        for (var i:int = 0; i < len; i++)
        {
            if (isWhiteSpace(input.charCodeAt(i)))
                continue;
            else
                break;
        }

        for (var j:int = len - 1; j >= 0; j--)
        {
            if (isWhiteSpace(input.charCodeAt(j)))
                continue;
            else
                break;
        }

        //substring() gets characters up to one index before.
        return input.substring(i, j+1);
    }
}

}