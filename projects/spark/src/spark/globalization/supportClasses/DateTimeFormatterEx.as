////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2011 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.globalization.supportClasses
{
import flash.errors.IllegalOperationError;
import flash.globalization.DateTimeStyle;
import flash.globalization.LocaleID;

import mx.core.mx_internal;
import mx.utils.ObjectUtil;
import mx.utils.StringUtil;

import spark.formatters.DateTimeFormatter;

use namespace mx_internal;

[ResourceBundle("core")]

[ExcludeClass]

/**
 *  DateTimeFormatterEx class provides a set of extended functionalities
 *  to deal with date formatting.
 *
 *  <p>For example, this class allows additional date style beyond the standard
 *  Spark DateTimeFormatter.
 *  Another feature is the date time pattern analysis which tells relative
 *  positions of each of formatting element.</p>
 *
 *  <p>There are maximum year and minimum year this class can handle.</p>
 *  <table>
 *  <tr><th>Item</th><th>Constant</th><th>Value</th></tr>
 *  <tr><td>Maximum year</td><td>MAX_YEAR</td><td>30827</td></tr>
 *  <tr><td>Minimum year</td><td>MIN_YEAR</td><td>1601</td></tr>
 *  </table>
 *  <p>This limitation is inherited from the underlying technology used by this
 *  class. (Spark DateTimeFormatter uses Flash DateTimeFormatter, which uses
 *  platform OS calls.) The limitation value is same across the platforms.</p>
 *
 *  @see spark.formatters.DateTimeFormatter
 *  @see flash.globalization.DateTimeFormatter
 *
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3
 *  @productversion Flex 4.6
 */
public class DateTimeFormatterEx extends DateTimeFormatter
{
    //--------------------------------------------------------------------------
    //
    //  Class Constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Extention of DateStyle constants: Year (y) and month (MMM).
     *
     *  <p><i>cf.</i> <a href="http://unicode.org/repos/cldr-tmp/trunk/diff/by_type/calendar-gregorian.pattern.html">
     *  http://unicode.org/repos/cldr-tmp/trunk/diff/by_type/calendar-gregorian.pattern.html</a></p>
     */
    public static const DATESTYLE_yMMM:String = "yMMM";
    public static const DATESTYLE_yMMMM:String = "yMMMM";
    public static const DATESTYLE_MMMEEEd:String = "MMMEEEd";
    
    /**
     *  Maximum year supported by DateTimeFormatterEx class.
     */
    public static const MAX_YEAR:uint = 30827;
    
    /**
     *  Minimum year supported by DateTimeFormatterEx class.
     */
    public static const MIN_YEAR:uint = 1601;
    
    // Number of milli seconds for a day
    private static const MILLISECONDS_PER_DAY:int = 1000 * 60 * 60 * 24;
    
    // Regular expressions for various date and time elements
    private static const REGEXP_YEAR:RegExp =
        /(^(?:[^'y]*(?:'[^']*')*[^y']*)*)(y+('年'|年|'년'|년)?)/;
    private static const REGEXP_MONTH:RegExp =
        /(^(?:[^'LM]*(?:'[^']*')*[^LM']*)*)([LM]+('月'|月|'월'|월)?)/;
    private static const REGEXP_DAYOFMONTH:RegExp =
        /(^(?:[^'d]*(?:'[^']*')*[^d']*)*)(d+('日'|日|'일'|일)?)/;
    private static const REGEXP_HOUR:RegExp =
        /(^(?:[^'hH]*(?:'[^']*')*[^hH']*)*)([hH]+('時'|時|'时'|时|'시'|시)?)/;
    private static const REGEXP_MINUTE:RegExp =
        /(^(?:[^'m]*(?:'[^']*')*[^m']*)*)(m+('分'|分|'분'|분)?)/;
    private static const REGEXP_SECOND:RegExp =
        /(^(?:[^'s]*(?:'[^']*')*[^s']*)*)(s+('秒'|秒|'초'|초)?)/;
    private static const REGEXP_AMPM:RegExp =  /^(.*)(a)(?:[^']*'[^']*')*[^']*$/;
    private static const REGEXP_DAYOFWEEK:RegExp =
        /(^(?:[^'E]*(?:'[^']*')*[^E']*)*)(E+)/;
    
    /*
    Regular expression for locale ID parsing
    [0] = full matching string
    [1] = language
    [2] = script
    [3] = region
    [4] = other attributes before the extention
    [5] = entire extension
    
    Example:
    sr_Latn_CS_xxx_yyy@collation=search;calendar=japanese
    [0] = sr_Latn_CS_xxx_yyy@collation=search;calendar=japanese
    [1] = sr
    [2] = Latn
    [3] = CS
    [4] = xxx_yyy
    [5] = collation=search;calendar=japanese
    */
    private static const REGEXP_LOCALEID:RegExp =
        /([a-z]+)?(?:[-_]([A-Z][a-z]+))?(?:[-_]([A-Z]+))?([a-zA-Z-]+)?(?:@(.*))?/;
    
    private static const REGEXP_L:RegExp = /(?:^[^'L]*(?:'[^']*')*[^L']*)(L+)/;
    
    private static const REGEXP_c:RegExp = /(?:^[^'c]*(?:'[^']*')*[^c']*)(c+)/;
    
    // Format pattern for yMMM
    private static const FORMATPATTERNLIST_yMMM:Vector.<FormatPattern> =
        new <FormatPattern> [
            new FormatPattern("LLL y", [
                "ca", "cs", "el", "fi", "ru", "sk", "uk"]),
            new FormatPattern("LLL y.", ["hr"]),
            new FormatPattern("MM/y", ["pt_PT"]),
            new FormatPattern("MMM 'de' y", ["pt", "seh"]),
            new FormatPattern("MMM 'di' y", ["kea"]),
            new FormatPattern("MMM y", [
                "af", "agq", "am", "ar", "asa", "bas", "be", "bem",
                "bez", "bm", "bn", "cgg", "chr", "cy", "da", "dav",
                "de", "dje", "dua", "dyo", "ebu", "ee", "en", "es",
                "et", "eu", "ewo", "fa", "ff", "fr", "fur", "gl",
                "gsw", "gu", "guz", "ha", "he", "hi", "id", "ig",
                "is", "it", "jmc", "kab", "kam", "kde", "khq", "ki",
                "kln", "kn", "ksb", "ksf", "lag", "lg", "ln",
                "lu", "luo", "luy", "mas", "mer", "mfe", "mg",
                "mgh", "mr", "ms", "mua", "naq", "nb", "nd",
                "nl", "nmg", "nn", "nus", "nyn", "pl", "rm",
                "rn", "ro", "rof", "rwk", "saq", "sbp", "ses",
                "sg", "shi", "shi_Tfng", "sl", "sn", "so", "sq", "sv",
                "sw", "swc", "ta", "te", "teo", "th", "to",
                "tr", "twq", "tzm", "vai_Latn", "vi", "vun", "wae",
                "xog", "yav", "yo", "zu"]),
            new FormatPattern("MMM y 'г'", ["bg"]),
            new FormatPattern("MMM y.", ["bs"]),
            new FormatPattern("MMM yyyy", ["ak", "brx", "vai"]),
            new FormatPattern("MMM, y", ["az", "az_Cyrl"]),
            new FormatPattern("MMM. y", ["sr"]),
            new FormatPattern("MMMی y", ["ku"]),
            new FormatPattern("y MMM", [
                "fil", "ksh", "mk", "ml", "my", "root", "sr_Latn", "trv"]),
            new FormatPattern("y. MMM", ["hu"]),
            new FormatPattern("yyyy. 'g'. MMM", ["lv"]),
            new FormatPattern("y년 MMM", ["ko"]),
            new FormatPattern("y年M月", ["ja", "zh", "zh_Hant"])
        ];
    
    // Format pattern for yMMMM
    private static const FORMATPATTERNLIST_yMMMM:Vector.<FormatPattern> =
        new <FormatPattern> [
            new FormatPattern("LLLL 'dal' y", [
                "fur"]),
            new FormatPattern("LLLL 'de' y", [
                "ca"]),
            new FormatPattern("LLLL y", [
                "pl", "sk", "uk"]),
            new FormatPattern("LLLL y.", [
                "hr"]),
            new FormatPattern("MMMM 'de' y", [
                "es", "seh"]),
            new FormatPattern("MMMM 'di' y", [
                "kea"]),
            new FormatPattern("MMMM y", [
                "af", "am", "ar", "asa", "be", "bem", "bez", "bm",
                "bn", "cgg", "chr", "dav", "ebu", "ee", "fa", "ff",
                "gl", "gsw", "guz", "ha", "he", "ig", "is", "jmc",
                "kab", "kam", "kde", "khq", "ki", "kln", "ksb", "ksh",
                "lag", "lg", "luo", "luy", "mas", "mer", "mfe", "mg",
                "naq", "nd", "nyn", "rm", "ro", "rof", "rwk",
                "saq", "ses", "sg", "shi", "shi_Tfng", "sn", "so", "sq",
                "sw", "teo", "th", "to", "tr", "tzm", "vi", "vun",
                "xog", "yo"]),
            new FormatPattern("MMMM yyyy", [
                "ak", "brx", "vai"]),
            new FormatPattern("y MMMM", [
                "fil", "mk", "ml", "my", "sr", "sr_Latn", "trv"]),
            new FormatPattern("y. 'g'. MMMM", [
                "lv"]),
        ];
    
    // Extra format pattern for yMMMM
    //
    // This pattern set is a tentative workaround for the Flex SDK Mega release.
    // It provides patterns for the "missing" locales.
    //
    // Method used:
    // (1) Locales listed for the yMMM pattern and the original yMMMM
    // were compared. The list of the locales that exist in yMMM but not
    // in yMMMM has been generated.
    // (There were no locales that exist in yMMMM but not in yMMM.)
    // (2) For each of the delta locales, the actual pattern was checked
    // using the ICU4J demo web page.
    // http://demo.icu-project.org/icu4jweb/flexTest.jsp
    // (3) The results from the above step were added below.
    private static const FORMATPATTERNLIST_yMMMM_extra:Vector.<FormatPattern> =
        new <FormatPattern> [
            new FormatPattern("MMMM y", [
                "agq", "az", "az_Cyrl", "bas", "cy", "da", "de", "dje",
                "dua", "dyo", "en", "et", "eu", "ewo", "fr", "gu",
                "hi", "id", "it", "kn", "ksf", "ku", "ln", "lu",
                "mgh", "mr", "ms", "mua", "nb", "nl", "nmg", "nn",
                "nus", "rn", "sbp", "sv", "swc", "ta", "te", "twq",
                "vai_Latn", "wae", "yav", "zu"]),
            new FormatPattern("y MMMM", [
                "root"]),
            new FormatPattern("MMMM y 'г'.", [
                "bg"]),
            new FormatPattern("y. MMMM", [
                "hu"]),
            new FormatPattern("y年M月", [
                "ja", "zh", "zh_Hant"]),
            new FormatPattern("y년 MMMM", [
                "ko"]),
            new FormatPattern("MMMM 'de' y", [
                "pt"]),
            new FormatPattern("MM/y", [
                "pt_PT"]),
            new FormatPattern("LLLL y", [
                "cs", "el", "fi", "ru"]),
        ];
    
    // Format patterns for MMMEEEd
    private static const FORMATPATTERNLIST_MMMEEEd:Vector.<FormatPattern> =
        new <FormatPattern> [
            new FormatPattern("EEE, d MMM", ["ro"]),
            new FormatPattern("ccc, d MMM", ["ru"]),
            new FormatPattern("d MMM, E", ["bg"]),
            new FormatPattern("d MMMM E", ["tr"]),
            new FormatPattern("E d LLL", ["fa"]),
            new FormatPattern("E d MMM", [
                "agq", "ar", "bas", "bm", "bn", "ca", "dje", "dua",
                "dyo", "en_GB", "en_IN", "es", "ewo", "ff", "fr",
                "fur", "gl", "id", "kab", "khq", "ksf", "ln", "lu",
                "mfe", "mg", "mua", "nl", "nmg", "nus", "rn", "ses",
                "sg", "shi", "shi_Tfng", "sq", "sv", "swc", "th", "to",
                "twq", "vi", "yav"]),
            new FormatPattern("E d. MMM", [
                "da", "fi", "gsw", "is", "nb", "nn", "rm", "sr",
                "sr_Latn"]),
            new FormatPattern("E dd MMM", ["en_ZA", "en_ZW"]),
            new FormatPattern("E MMM d", ["fil", "mk", /*"root",*/ "trv"]),
            new FormatPattern("E, d MMM", [
                "be", "el", "en_AU", "en_CA", "en_HK", "en_MT", "en_NZ", "en_SG",
                "gu", "hi", "kn", "mr", "pl", "ro", "ta", "te",
                "uk"]),
            new FormatPattern("E, d בMMM", ["he"]),
            new FormatPattern("E, d. MMM", [
                "cs", "de", "et", "hr", "lv", "sk", "sl", "wae"]),
            new FormatPattern("E, d/MM", ["pt_PT"]),
            new FormatPattern("E, dd. MMM", ["bs"]),
            new FormatPattern("E, MMM d", [
                "af", "ak", "am", "asa", "bem", "bez", "brx", "cgg",
                "dav", "ebu", "ee", "en", "es_US", "eu", "guz", "ha",
                "ig", "jmc", "kam", "kde", "ki", "kln", "ksb", "lag",
                "lg", "luo", "luy", "mas", "mer", "mgh", "naq", "nd",
                "nyn", "rof", "rwk", "saq", "sbp", "sn", "so", "sw",
                "teo", "tzm", "vai", "vai_Latn", "vun", "xog", "yo", "zu"]),
            new FormatPattern("E، dی MMM", ["ku"]),
            new FormatPattern("EEE d MMM", ["en_BE", "it"]),
            new FormatPattern("EEE dd MMM", ["en_BW", "en_BZ"]),
            new FormatPattern("EEE, d 'de' MMM", ["pt"]),
            new FormatPattern("EEE, d MMM", ["cy", "kea", "ms", "seh"]),
            new FormatPattern("EEE, d, MMM", ["az", "az_Cyrl"]),
            new FormatPattern("EEE, MMM d", ["my"]),
            new FormatPattern("MMM d E", ["si"]),
            new FormatPattern("MMM d, E", ["lt", "ml"]),
            new FormatPattern("MMM d., E", ["hu"]),
            new FormatPattern("MMM d일 (E)", ["ko"]),
            new FormatPattern("M月d日(E)", ["ja"]),
            new FormatPattern("M月d日E", ["zh", "zh_Hant"]),
        ];
    
    // Process for FORMATPATTERNLIST_yMMMM_extra repeated.
    // Locales list for MMMEEEd is compared with yMMM localelist and
    // the missing ones data is extracted.
    private static const
    FORMATPATTERNLIST_MMMEEEd_extra:Vector.<FormatPattern> =
        new <FormatPattern> [
            new FormatPattern("E MMM d", ["root"]),
            new FormatPattern("EEE MMM d", ["chr"]),
            new FormatPattern("EEE, MMM d", ["ksh"]),
        ];
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructs a new <code>DateTimeFormatterEx</code> object.
     *
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public function DateTimeFormatterEx()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Properties
    //
    //--------------------------------------------------------------------------
    
    override public function set dateStyle(value:String):void
    {
        if (value == dateStyle)
            return;
        
        invalidateSkeletonPattern();
        invalidatePatternAnalysis();
        {
            /*
            WORKAROUND FOR BUG SDK-30833
            
            This block of code is a workaround for the Spark
            DateTimeFormatter bug SDK-30833: Spark DateTimeFormatter ignores
            dateStyle/timeStyle assignments when it involves "custom" value
            
            If the Spark DateTimeFormatter gets fixed, remove this block.
            */
            if (super.dateStyle == "custom")
                super.dateStyle = (value == "none") ? "long" : "none";
        }
        super.dateStyle = value;
    }
    
    override public function set dateTimePattern(value:String):void
    {
        if (value == dateTimePattern)
            return;
        
        invalidateSkeletonPattern();
        invalidatePatternAnalysis();
        super.dateTimePattern = value;
    }
    
    override public function set timeStyle(value:String):void
    {
        if (value == timeStyle)
            return;
        
        invalidateSkeletonPattern();
        invalidatePatternAnalysis();
        
        /*
        WORKAROUND FOR BUG SDK-30833
        
        This block of code is a workaround for the Spark
        DateTimeFormatter bug SDK-30833: Spark DateTimeFormatter ignores
        dateStyle/timeStyle assignments when it involves "custom" value
        
        If the Spark DateTimeFormatter gets fixed, remove this block.
        */
        if (super.timeStyle == "custom")
            super.timeStyle = (value == "none") ? "long" : "none";

        super.timeStyle = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  dateTimeSkeletonPattern
    //----------------------------------
    
    /**
     *  @private
     *  Cached value for dateTimeSkeletonPattern.
     */
    private var _dateTimeSkeletonPattern:String;
    
    [Bindable("change")]
    
    /**
     *  Date time skeleton pattern.
     *
     *  <p>When a skeleton pattern is set, it is translated into a concreate
     *  pattern and dateTimePattern property gets the value.
     *  Only yMMM and yMMMM skeleton patterns are supported for the Mega
     *  release.
     *  In the future releases, we may be supporting more generic skeleton
     *  patterns.</p>
     *  <p>Between the <code>dateStyle</code>/<code>timeStyle</code>,
     *  <code>dateTimeSkeletonPattern</code> and <code>dateTimePattern</code>,
     *  the last one that has assigned gets the priority.
     *  For instance, if <code>dateStyle</code> is assinged the value
     *  <code>"short"</code> and <code>dateTimeSkeletonPattern</code> is
     *  assigned the value <code>"yMMMMM"</code> next,
     *  the <code>dateTimePattern</code> will have a concrete patter for
     *  the current locale (such as <code>"MMMM y"</code> for en_US).
     *  This is same concept with the Spark <code>DateTimeFormatter</code>
     *  in terms of the relation between the
     *  <code>dateStyle</code>/<code>timeStyle</code> and
     *  <code>dateTimePattern</code>.
     *  Here, the concept has been extended to include the
     *  <code>dateTimeSkeletonPattern</code>.</p>
     *  <p>See the CLDR web site for the details of the skeleton pattern at
     *  <a href="http://unicode.org/repos/cldr-tmp/trunk/diff/by_type/calendar-gregorian.pattern.html">http://unicode.org/repos/cldr-tmp/trunk/diff/by_type/calendar-gregorian.pattern.html</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public function get dateTimeSkeletonPattern():String
    {
        return _dateTimeSkeletonPattern;
    }
    
    public function set dateTimeSkeletonPattern(value:String):void
    {
        if (value == _dateTimeSkeletonPattern)
            return;
        
        _dateTimeSkeletonPattern = value;
        updatePattern();
        invalidatePatternAnalysis();
        update();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------
    
    public override function setStyle(styleProp:String, newValue:*):void
    {
        const oldValue:* = super.getStyle(styleProp);
        super.setStyle(styleProp, newValue);
        
        if ((styleProp != "locale") || (newValue == oldValue))
            return;
        
        updatePattern();
        invalidatePatternAnalysis();
        update();
    }
    
    override public function styleChanged(styleProp:String):void
    {
        super.styleChanged(styleProp);
        updatePattern();
        invalidatePatternAnalysis();
        update();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    [Bindable("change")]
    
    /**
     *  Formatting pattern for the am/pm.
     *
     *  See getYearPosition() method for details.
     */
    public function getAmPmPattern():String
    {
        const element:Object = elementPatternList["ampm"];
        return element ? element["pattern"] : null;
    }
    
    [Bindable("change")]
    
    /**
     *  Element position for the am/pm within the current
     *  date pattern.
     */
    public function getAmPmPosition():int
    {
        const element:Object = elementPatternList["ampm"];
        return element ? element["index"] : -1;
    }
    
    [Bindable("change")]
    
    /**
     *  Formatting pattern for the day.
     *
     *  See getYearPosition() method for details.
     */
    public function getDayOfMonthPattern():String
    {
        const element:Object = elementPatternList["dayOfMonth"];
        return element ? element["pattern"] : null;
    }
    
    [Bindable("change")]
    
    /**
     *  Element position for the day of the month within the current
     *  date pattern.
     */
    public function getDayOfMonthPosition():int
    {
        const element:Object = elementPatternList["dayOfMonth"];
        return element ? element["index"] : -1;
    }
    
    [Bindable("change")]
    
    /**
     *  Formatting pattern for the day of week.
     *
     *  See getYearPosition() method for details.
     */
    public function getDayOfWeekPattern():String
    {
        const element:Object = elementPatternList["dayOfWeek"];
        return element ? element["pattern"] : null;
    }
    
    [Bindable("change")]
    
    /**
     *  Element position for the day of the week within the current
     *  date pattern.
     */
    public function getDayOfWeekPosition():int
    {
        const element:Object = elementPatternList["dayOfWeek"];
        return element ? element["index"] : -1;
    }
    
    [Bindable("change")]
    
    /**
     *  Formatting pattern for the hour.
     *
     *  See getYearPosition() method for details.
     */
    public function getHourPattern():String
    {
        const element:Object = elementPatternList["hour"];
        return element ? element["pattern"] : null;
    }
    
    [Bindable("change")]
    
    /**
     *  Element position for the day of the hour within the current
     *  date pattern.
     */
    public function getHourPosition():int
    {
        const element:Object = elementPatternList["hour"];
        return element ? element["index"] : -1;
    }
    
    [Bindable("change")]
    
    /**
     *  Formatting pattern for the minute.
     *
     *  See getYearPosition() method for details.
     */
    public function getMinutePattern():String
    {
        const element:Object = elementPatternList["minute"];
        return element ? element["pattern"] : null;
    }
    
    [Bindable("change")]
    
    /**
     *  Element position for the minute within the current
     *  date pattern.
     */
    public function getMinutePosition():int
    {
        const element:Object = elementPatternList["minute"];
        return element ? element["index"] : -1;
    }
    
    [Bindable("change")]
    
    /**
     *  Formatting pattern for the month.
     *
     *  See getYearPosition() method for details.
     */
    public function getMonthPattern():String
    {
        const element:Object = elementPatternList["month"];
        return element ? element["pattern"] : null;
    }
    
    [Bindable("change")]
    
    /**
     *  Element position for the month within the current
     *  date pattern.
     */
    public function getMonthPosition():int
    {
        const element:Object = elementPatternList["month"];
        return element ? element["index"] : -1;
    }
    
    [Bindable("change")]
    
    /**
     *  Formatting pattern for the second.
     *
     *  See getYearPosition() method for details.
     */
    public function getSecondPattern():String
    {
        const element:Object = elementPatternList["second"];
        return element ? element["pattern"] : null;
    }
    
    [Bindable("change")]
    
    /**
     *  Element position for the second within the current
     *  date pattern.
     */
    public function getSecondPosition():int
    {
        const element:Object = elementPatternList["second"];
        return element ? element["index"] : -1;
    }
    
    [Bindable("change")]
    
    /**
     *  Finds if the current pattern is for 24-hour.
     *
     *  <p>This method checks the current pattern to see if 24-hour display
     *  is used. This method does this by checking if the pattern contains
     *  the letter "H" or "h". If the pattern does not exist or the pattern
     *  does not contain either "H" or "h", the use of 24- or 12-hour cannot
     *  be determined.</p>
     *
     *  @return <code>true</code> if 24-hour time is used.
     *          <code>false</code> if 12-hour time is used.
     *          <code>null</code> if it is unable to determine 24- or 12-hour
     *          because the current pattern does not contain either
     *          "H" or "h".
     */
    public function getUse24HourFlag():Object
    {
        const hourPattern:String = getHourPattern();
        
        if (!hourPattern)
            return null;
        
        const use24Hour:Boolean = hourPattern.indexOf("H") >= 0;
        const use12Hour:Boolean = hourPattern.indexOf("h") >= 0;
        if (use24Hour && !use12Hour)
            return true;
        else if (!use24Hour && use12Hour)
            return false;
        
        return null;
    }
    
    [Bindable("change")]
    
    /**
     *  Formatting pattern for the year.
     *
     *  See getYearPosition() method for details.
     */
    public function getYearPattern():String
    {
        const element:Object = elementPatternList["year"];
        return element ? element["pattern"] : null;
    }
    
    [Bindable("change")]
    
    /**
     *  Returns the element position for the year within the current
     *  date pattern.
     *
     *  <p>For example, assume the current date formatting pattern
     *  (<code>dateTimePattern</code> property) is
     *  <code>"MMMM d, yyyy"</code>.
     *  This method and other related methods return the values as
     *  follow:</p>
     *
     *  <table class="innertable">
     *      <tr><td>getYearPosition</td><td>2</td></tr>
     *      <tr><td>getYearPattern</td><td>"yyyy"</td></tr>
     *      <tr><td>getMonthPosition</td><td>0</td></tr>
     *      <tr><td>getMonthPattern</td><td>"MMMM"</td></tr>
     *      <tr><td>getDayOfMonthPosition</td><td>1</td></tr>
     *      <tr><td>getDayOfMonthPattern</td><td>"d"</td></tr>
     *  </table>
     *
     *  <p>If the current date time pattern does not contain an element,
     *  the corresponding position method returns -1 and the pattern
     *  method returns a <code>null</code> value.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public function getYearPosition():int
    {
        const element:Object = elementPatternList["year"];
        return element ? element["index"] : -1;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  elementPatternList
    //----------------------------------
    
    /**
     *  @private
     *  Pattern analysis result
     */
    private var _elementPatternList:Object;
    
    /**
     *  @private
     *  The set of element information as the analysis result of the current
     *  <code>dateTimePattern</code>.
     *
     *  <p>This is used by the <code>getYearPattern</code>,
     *  <code>getYearPosition</code> and other similar methods.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    private function get elementPatternList():Object
    {
        if (!_elementPatternList)
        {
            _elementPatternList =
                DateTimeFormatterEx.analysePattern(dateTimePattern,
                    patternMayContainDateElements,
                    patternMayContainTimeElements);
            addPrefixes(dateTimePattern, _elementPatternList);
        }
        
        return _elementPatternList;
    }
    
    private function set elementPatternList(value:Object):void
    {
        if (value)
            throw new ArgumentError("Invalid assignment.");
        _elementPatternList = null;
    }
    
    //----------------------------------
    //  patternMayContainDateElements
    //----------------------------------
    
    private function get patternMayContainDateElements():Boolean
    {
        switch (super.dateStyle)
        {
            case "none":
                return false;
            case "custom":
                break;
            default:    // "long", "medium" and "short"
                return true;
        }
        
        switch (_dateTimeSkeletonPattern)
        {
            case DATESTYLE_yMMM:
            case DATESTYLE_yMMMM:
            case DATESTYLE_MMMEEEd:
                return true;
        }
        
        /*
        The precise answer here is: it is unknown if the pattern contains
        any of date elements.
        Therefore, we return the value to say "it may contain some date
        elements".
        */
        return true;
    }
    
    //----------------------------------
    //  patternMayContainTimeElements
    //----------------------------------
    
    private function get patternMayContainTimeElements():Boolean
    {
        switch (super.timeStyle)
        {
            case "none":
                return false;
            case "custom":
                break;
            default:    // "long", "medium" and "short"
                return true;
        }
        
        switch (_dateTimeSkeletonPattern)
        {
            case DATESTYLE_yMMM:
            case DATESTYLE_yMMMM:
            case DATESTYLE_MMMEEEd:
                return false;
        }
        
        /*
        The precise answer here is: it is unknown if the pattern contains
        any of time elements.
        Therefore, we return the value to say "it may contain some time
        elements".
        */
        return true;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Special handling for locales that need prefix for pattern elements.
     *
     *  The regular expression becomes too complex to properly handle prefixed
     *  embeded strings. (Postfixes are ok, however.)
     *  This function adds the proper prefix to the elements.
     *  This is not the best solution for the long-run but it is a balancing
     *  solution for the Mega release.
     */
    private function addPrefixes(
        dateTimePattern:String, elementPatternList:Object):void
    {
        const locale:String = getStyle("locale");
        if (!locale || !elementPatternList)
            return;
        
        const language:String = locale.substr(0, 2);
        
        if ((language == "vi") && (dateTimePattern.indexOf("năm") != -1))
        {
            if (elementPatternList["year"])
            {
                elementPatternList["year"]["pattern"] = "'năm' " +
                    elementPatternList["year"]["pattern"];
            }
            if (elementPatternList["month"])
            {
                elementPatternList["month"]["pattern"] = "'tháng' " +
                    elementPatternList["month"]["pattern"];
            }
            if (elementPatternList["dayOfMonth"])
            {
                elementPatternList["dayOfMonth"]["pattern"] = "'Ngày' " +
                    elementPatternList["dayOfMonth"]["pattern"];
            }
        }
    }
    
    /**
     *  @private
     *  Find the best matching format pattern
     *  for a given locale and a given style.
     */
    private function findBestMatchingPattern(
        locale:String,
        style:String):String
    {
        var pattern:String;
        switch (style)
        {
            case DATESTYLE_yMMM:
                pattern = findBestMatchingPatternFromFormatPatternList(
                    locale, FORMATPATTERNLIST_yMMM);
                break;
            case DATESTYLE_yMMMM:
                pattern = findBestMatchingPatternFromFormatPatternList(
                    locale, FORMATPATTERNLIST_yMMMM);
                if (!pattern)
                {
                    pattern = findBestMatchingPatternFromFormatPatternList(
                        locale, FORMATPATTERNLIST_yMMMM_extra);
                }
                break;
            case DATESTYLE_MMMEEEd:
                pattern = findBestMatchingPatternFromFormatPatternList(
                    locale, FORMATPATTERNLIST_MMMEEEd);
                if (!pattern)
                {
                    pattern = findBestMatchingPatternFromFormatPatternList(
                        locale, FORMATPATTERNLIST_MMMEEEd_extra);
                }
                break;
        }
        
        if (pattern)
        {
            // 'L' is not supported by most systems so relace with 'M'
            pattern = pattern.replace(REGEXP_L, function(
                matchedSubstring:String,
                capturedMatch1:String, index:int, str:String):String
            {
                return replaceString(matchedSubstring,
                    capturedMatch1, index, str, "M");
            });
            
            // ru locale uses "c" as the symbol for the day name of the week
            // instead "E".
            pattern = pattern.replace(REGEXP_c, function(
                matchedSubstring:String,
                capturedMatch1:String, index:int, str:String):String
            {
                return replaceString(matchedSubstring,
                    capturedMatch1, index, str, "E");
            });
        }
        
        return pattern;
    }
    
    /**
     *  @private
     *  Find the best matching format pattern from the format pattern list
     *  for a given locale.
     */
    private function findBestMatchingPatternFromFormatPatternList(
        findLocale:String,
        formatPatternList:Vector.<FormatPattern>):String
    {
        if (!findLocale)
            findLocale = "root";
        
        const parsedLocale:Object = parseLocale(findLocale);
        const locale:String = parsedLocale["locale"];
        const language:String = parsedLocale["language"];
        const script:String = parsedLocale["script"];
        const region:String = parsedLocale["region"];
        const scoreList:Array = new Array();
        /*
        Score calculation method:
        Two of the languages are identical: Add 0x40
        One of the language is null: Add 0x20 (actually, not allowed)
        Two of the scripts are identical: Add 0x10
        One of the script is null: Add 0x08
        Two of the regions are indentical: Add 0x04
        One of the region is null: Add 0x02
        One from the table is "root": Add 0x01
        
        Notes:
        When both of them are null, it is considered they are identical.
        */
        var score:uint;
        
        for each (var formatPattern:FormatPattern in formatPatternList)
        {
            var qNameList:Array = ObjectUtil.getClassInfo(
                formatPattern.locales)["properties"];
            for each (var qName:QName in qNameList)
            {
                score = 0;
                var listedLocale:Object = parseLocale(qName.localName);
                if (language == listedLocale["language"])
                {
                    score += 0x40;
                    if (script == listedLocale["script"])
                        score += 0x10;
                    else if (!script || !listedLocale["script"])
                        score += 0x08;
                    
                    if (region == listedLocale["region"])
                        score += 0x04;
                    else if (!region || !listedLocale["region"])
                        score += 0x02;
                }
                if ((locale != "root") && (listedLocale["locale"] == "root"))
                    score++;
                if (score)
                {
                    scoreList.push({locale: qName.localName,
                        pattern: formatPattern.pattern, score: score});
                }
            }
        }
        
        if (!scoreList.length)
            return null;
        
        scoreList.sortOn("score", Array.NUMERIC | Array.DESCENDING);
        return scoreList[0]["pattern"];
    }
    
    private function invalidatePatternAnalysis():void
    {
        elementPatternList = null;
    }
    
    private function invalidateSkeletonPattern():void
    {
        _dateTimeSkeletonPattern = null;
    }
    
    /**
     *  @private
     *  Parse and normalize locale string
     */
    private function parseLocale(locale:String):Object
    {
        if (!locale)
        {
            return {
                locale: "",
                language: "",
                script: "",
                region: ""
            };
        }
        const regExpResult:Object = REGEXP_LOCALEID.exec(locale);
        const language:String = regExpResult[1] ? regExpResult[1] : "";
        const script:String = regExpResult[2] ? regExpResult[2] : "";
        const region:String = regExpResult[3] ? regExpResult[3] : "";
        
        const normalizedLocale:String = locale.replace("-", "_");
        
        return {
            locale: normalizedLocale,
            language: language,
            script: script,
            region: region
        };
    }
    
    private function replaceString(matchedSubstring:String,
                                   capturedMatch1:String, index:int, str:String,
                                   newChar:String):String
    {
        const len:int = capturedMatch1.length;
        const s:String = StringUtil.repeat(newChar, len);
        const n:String = matchedSubstring.substr(0,
            matchedSubstring.length - len) + s;
        return n;
    }
    
    private function updatePattern():void
    {
        if (!_dateTimeSkeletonPattern)
            return;
        
        super.dateTimePattern = findBestMatchingPattern(
            actualLocaleIDName, _dateTimeSkeletonPattern);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private Static Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  analysePattern() function.
     *
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    private static function analysePattern(pattern:String,
                                           analyseDateElements:Boolean,
                                           analyseTimeElements:Boolean):Object
    {
        const elementList:Array = new Array();
        
        if (analyseDateElements)
            DateTimeFormatterEx.extractDateElements(pattern, elementList);
        
        if (analyseTimeElements)
            DateTimeFormatterEx.extractTimeElements(pattern, elementList);
        
        elementList.sortOn("index", Array.NUMERIC);
        const processedElementList:Object = new Object();
        for (var i:int = 0; i < elementList.length; i++)
        {
            var element:Object = new Object();
            element["index"] = i;
            element["pattern"] = elementList[i]["pattern"];
            var name:String = elementList[i]["name"];
            processedElementList[name] = element;
        }
        
        return processedElementList;
    }
    
    /**
     *  @private
     *  extractDateElements() function.
     *
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    private static function extractDateElements(
        pattern:String, elementList:Array):void
    {
        var regExpOut:Object;
        for (var i:int = 0; i < 4; i++)
        {
            var element:Object = null;
            switch (i)
            {
                case 0:
                    regExpOut = REGEXP_YEAR.exec(pattern);
                    if (regExpOut)
                        element = { name: "year", pattern: regExpOut[2],
                            index: ((regExpOut["index"] as int)
                                + (regExpOut[1] as String).length) };
                    break;
                case 1:
                    regExpOut = REGEXP_MONTH.exec(pattern);
                    if (regExpOut)
                        element = { name: "month", pattern: regExpOut[2],
                            index: ((regExpOut["index"] as int)
                                + (regExpOut[1] as String).length) };
                    break;
                case 2:
                    regExpOut = REGEXP_DAYOFMONTH.exec(pattern);
                    if (regExpOut)
                        element = { name: "dayOfMonth", pattern: regExpOut[2],
                            index: ((regExpOut["index"] as int)
                                + (regExpOut[1] as String).length) };
                    break;
                case 3:
                    regExpOut = REGEXP_DAYOFWEEK.exec(pattern);
                    if (regExpOut)
                        element = { name: "dayOfWeek", pattern: regExpOut[2],
                            index: ((regExpOut["index"] as int)
                                + (regExpOut[1] as String).length) };
                    break;
            }
            if (element)
                elementList.push(element);
        }
    }
    
    /**
     *  @private
     *  extractTimeElements() function.
     *
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    private static function extractTimeElements(
        pattern:String, elementList:Array):void
    {
        var regExpOut:Object;
        for (var i:int = 0; i < 4; i++)
        {
            var element:Object = null;
            switch (i)
            {
                case 0:
                    regExpOut = REGEXP_HOUR.exec(pattern);
                    if (regExpOut)
                        element = { name: "hour", pattern: regExpOut[2],
                            index: ((regExpOut["index"] as int)
                                + (regExpOut[1] as String).length) };
                    break;
                case 1:
                    regExpOut = REGEXP_MINUTE.exec(pattern);
                    if (regExpOut)
                        element = { name: "minute", pattern: regExpOut[2],
                            index: ((regExpOut["index"] as int)
                                + (regExpOut[1] as String).length) };
                    break;
                case 2:
                    regExpOut = REGEXP_SECOND.exec(pattern);
                    if (regExpOut)
                        element = { name: "second", pattern: regExpOut[2],
                            index: ((regExpOut["index"] as int)
                                + (regExpOut[1] as String).length) };
                    break;
                case 3:
                    regExpOut = REGEXP_AMPM.exec(pattern);
                    if (regExpOut)
                        element = { name: "ampm", pattern: regExpOut[2],
                            index: ((regExpOut["index"] as int)
                                + (regExpOut[1] as String).length) };
                    break;
            }
            if (element)
                elementList.push(element);
        }
    }
}
}
