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

import flash.globalization.NationalDigitsType;

/**
 *  GlobalizationUtils is a class containing Unicode related functionality
 *  not supported directly in Flex or ActionScript.
 * 
 *  <p>This class contains the utility routines needed for all Validators. 
 *  Examples of typical routines are checking for unicode white space, 
 *  trimming all spaces in a string at the beginning and end.</p>
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
    private static const ASCII_ZERO:uint = 0x30;
    private static const NO_BREAK_SPACE:uint = 0xA0;
    private static const UNICODE_OGHAM_SPACE_MARK:uint = 0x1680;
    private static const UNICODE_MONGOLIAN_VOWEL_SEPARATOR:uint = 0x180E;
    private static const UNICODE_SPACE_START:uint = 0x2000;
    private static const UNICODE_SPACE_END:uint = 0x200B;
    private static const UNICODE_NARROW_NOBREAK_SPACE:uint = 0x202F;
    private static const UNICODE_MEDIUM_MATHEMATICAL_SPACE:uint = 0x205F;
    private static const UNICODE_IDEOGRAPHIC_SPACE:uint = 0x3000;
    private static const UNICODE_ZEROWIDTH_NOBREAK_SPACE:uint = 0xFEFF;
    private static const UNICODE_HIGH_SURROGATE_FRONT:uint = 0xd800;
    private static const UNICODE_HIGH_SURROGATE_BACK:uint = 0xdbff;
    private static const UNICODE_LOW_SURROGATE_FRONT:uint = 0xdc00;
    private static const UNICODE_LOW_SURROGATE_BACK:uint = 0xdfff;
    private static const UNICODE_DIGITS:Array = new Array(
                                 ASCII_ZERO, 
                                 NationalDigitsType.ARABIC_INDIC ,
                                 NationalDigitsType.BALINESE  , 
                                 NationalDigitsType.BENGALI ,
                                 NationalDigitsType.CHAM ,
                                 NationalDigitsType.DEVANAGARI ,
                                 NationalDigitsType.EUROPEAN ,
                                 NationalDigitsType.EXTENDED_ARABIC_INDIC ,
                                 NationalDigitsType.FULL_WIDTH ,
                                 NationalDigitsType.GUJARATI ,
                                 NationalDigitsType.GURMUKHI ,
                                 NationalDigitsType.KANNADA ,
                                 NationalDigitsType.KAYAH_LI ,
                                 NationalDigitsType.KHMER ,
                                 NationalDigitsType.LAO ,
                                 NationalDigitsType.LEPCHA ,
                                 NationalDigitsType.LIMBU ,
                                 NationalDigitsType.MALAYALAM ,
                                 NationalDigitsType.MONGOLIAN ,
                                 NationalDigitsType.MYANMAR ,
                                 NationalDigitsType.MYANMAR_SHAN ,
                                 NationalDigitsType.NEW_TAI_LUE ,
                                 NationalDigitsType.NKO ,
                                 NationalDigitsType.OL_CHIKI ,
                                 NationalDigitsType.ORIYA ,
                                 NationalDigitsType.OSMANYA ,
                                 NationalDigitsType.SAURASHTRA ,
                                 NationalDigitsType.SUNDANESE ,
                                 NationalDigitsType.TAMIL ,
                                 NationalDigitsType.TELUGU ,
                                 NationalDigitsType.THAI ,
                                 NationalDigitsType.TIBETAN ,
                                 NationalDigitsType.VAI
                               );

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    /**
     *  Return <code>true</code> if a codepoint is a numeric digit.
     *  Supported digits are listed in 
     *  <code>flash.globalization.NationalDigitsType</code>.
     *
     *  @param <code>int</code> input codepoint
     *  @returns <code>Boolean</code> <code>true</code> if a codepoint
     *  is a numeric digit, and <code>false</code> if not.
     *
     *  @return <code>true</code> if a codepoint is a numeric digit.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static function isDigit(ccode:uint):Boolean
    {
        for (var i:int = 0; i < UNICODE_DIGITS.length; i++)
        {
            if ((ccode >= UNICODE_DIGITS[i]) && (ccode <= (UNICODE_DIGITS[i] + 9)))
                return true;
        }
        return false;
    }

    /**
     *  Return <code>true</code> if a codepoint is a leading surrogate.
     *
     *  @param uint The input codepoint.
     * 
     *  @return <code>true</code> if a codepoint is a leading surrogate, 
     *  and <code>false</code> if not.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static function isLeadingSurrogate(ccode:uint):Boolean
    {
        return ((ccode >= UNICODE_HIGH_SURROGATE_FRONT) && 
            (ccode <= UNICODE_HIGH_SURROGATE_BACK));
    }

    /**
     *  Return <code>true</code> if a codepoint is a trailing surrogate.
     *
     *  @param uint The input codepoint.
     * 
     *  @return <code>true</code> if a codepoint is a trailing surrogate, 
     *  and <code>false</code> if not.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static function isTrailingSurrogate(ccode:uint):Boolean
    {
        return ((ccode >= UNICODE_LOW_SURROGATE_FRONT) && 
            (ccode <= UNICODE_LOW_SURROGATE_BACK));
    }

    /**
     *  Return <code>true</code> if a codepoint is a white space character.
     *  Supports all unicode white space characters. 
     *
     *  <p>The unicode supported white spaces are:
     *  <pre>
     *  ASCII_SPACE (0x20)
     *  NO_BREAK_SPACE (0xA0)
     *  UNICODE_OGHAM_SPACE_MARK (0x1680)
     *  Unicode spaces 0x2000 - 0x200B
     *  UNICODE_NARROW_NOBREAK_SPACE (0x202F)
     *  UNICODE_MEDIUM_MATHEMATICAL_SPACE (0x205F)
     *  UNICODE_IDEOGRAPHIC_SPACE (0x3000)
     *  UNICODE_ZEROWIDTH_NOBREAK_SPACE (0xFEFF)
     *  </pre>
     *  </p>
     *
     *  @param uint The input codepoint.
     * 
     *  @return <code>true</code> if a codepoint is a white space character, 
     *  and <code>false</code> if not.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static function isWhiteSpace(ccode:uint):Boolean
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
     *  Removes leading and trailing white space characters.
     *
     *  @param input Input string to process.
     * 
     *  @return String after removing leading and trailing 
     *  white space characters.
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

    /**
     *  Convert a surrogate pair to UTF32.
     *
     *  @param c0 High surrogate.
     * 
     *  @param c1 Low surrogate.
     * 
     *  @return The UTF32 equivalent.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public static function surrogateToUTF32(c0:uint, c1:uint):uint
    {
        var out:uint = 0;
    
        var tmp:int = c0 & 0xffff;
        if ((tmp < UNICODE_HIGH_SURROGATE_FRONT) || 
            (tmp > UNICODE_LOW_SURROGATE_BACK ))
        {
            out = tmp;
        }
        else 
        {
            out = (tmp - 0xd7C0) << 10;
            out += c1 & 0x03FF;
        }
        
        return out;
    }

}

}