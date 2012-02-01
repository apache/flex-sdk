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
import flash.globalization.NumberFormatter;

import mx.core.mx_internal;
import mx.validators.NumberValidatorDomainType;
import mx.validators.ValidationResult;

import spark.formatters.CurrencyFormatter;
import spark.formatters.NumberFormatter;
import spark.globalization.LastOperationStatus;
import spark.globalization.supportClasses.GlobalizationBase;
import spark.validators.supportClasses.GlobalizationUtils;
import spark.validators.supportClasses.GlobalizationValidatorBase;

use namespace mx_internal;
/**
 *  The NumberValidatorBase class contains all the common functionality that is
 *  required by the <code>NumberValidator</code> and 
 *  <code>CurrencyValidator</code> classes.
 *  <p> This class is similar to the <code>NumberFormatterBase</code> class used
 *  by the spark <code>NumberFormatter</code> and <code>CurrencyFormatter</code>
 *  classes.</p>
 * 
 *  @see spark.formatters.NumberFormatterBase
 *
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */ 
public class NumberValidatorBase extends GlobalizationValidatorBase
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class Constants
    //
    //--------------------------------------------------------------------------

    private static const ALLOW_NEGATIVE:String = "allowNegative";
    private static const DECIMAL_SEPARATOR:String = "decimalSeparator";
    private static const FRACTIONAL_DIGITS:String = "fractionalDigits";
    private static const GROUPING_PATTERN:String = "groupingPattern";
    private static const GROUPING_SEPARATOR:String = "groupingSeparator";
    private static const NEGATIVE_SYMBOL:String = "negativeSymbol";

    // Used by inheritors.
    mx_internal static const NUMBER_VALIDATOR_TYPE:int = 1;
    mx_internal static const CURRENCY_VALIDATOR_TYPE:int = 2;

    // Follows flash.globalization limit.
    private static const PATTERN_LENGTH_LIMIT:int = 10;
    private static const DECIMAL_SEP_STD:String = ".";

    /**
     *  @private
     *  A String containing the decimal digits 0 through 9.
     *
     */
    mx_internal static const DECIMAL_DIGITS:String = "0123456789";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function NumberValidatorBase()
    {
        super();
        // Previously allowNegative was an object. If it was null, the default
        // value was loaded from resource manager in the setter. But now it
        // is a boolean. Hence load it explicitly.
        _allowNegative = allowNegativeOverride = resourceManager.getBoolean(
            "validators", "allowNegative");
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Underlying working instance of flash.globalizaiton.NumberFormatter or
     *  CurrencyFormatter class.
     *
     *  Because it can be either type and they don't have common base except
     *  Object, it is defined as Object.
     */
    protected var g11nWorkingInstance:Object = null;

    /**
    *  @private
    *  Basic properies of the actual underlying working instance.
    *
    *  It can be flash.globalization.NumberFormatter/CurrencyFormatter OR
    *  the fallback's propery set.
    */
    protected var properties:Object = null;

    //--------------------------------------------------------------------------
    //
    //  Overridden Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  lastOperationStatus
    //----------------------------------
    
    [Bindable("change")]
    
    /**
     *  @inheritDoc
     *
     *  @see spark.Globalization.LastOperationStatus
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override public function get lastOperationStatus():String
    {
        return g11nWorkingInstance ?
            g11nWorkingInstance.lastOperationStatus :
            fallbackLastOperationStatus;
    }
    
    //----------------------------------
    //  useFallback
    //----------------------------------
    
    [Bindable("change")]
    
    /**
     *  @private
     */
    override mx_internal function get useFallback():Boolean
    {
        return g11nWorkingInstance.useFallback;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  allowNegative
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the allowNegative property.
     */
    private var _allowNegative:Boolean;
    
    /**
     *  @private
     */
    protected var allowNegativeOverride:Boolean;
    
    [Inspectable(category="General", defaultValue="true")]
    [Bindable("change")]
    
    /**
     *  Specifies whether negative numbers are permitted.
     *  Valid values are <code>true</code> or <code>false</code>.
     *
     *  @default true
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get allowNegative():Boolean
    {
        return _allowNegative;
    }
    
    public function set allowNegative(value:Boolean):void
    {
        allowNegativeOverride = value;
        
        _allowNegative = value;
        update();
    }

    
    //----------------------------------
    //  decimalSeparator
    //----------------------------------

    [Bindable("change")]

    /**
     *  The decimal separator character used for validating numbers that have
     *  a decimal part.
     *
     *  <p>This property is initially set based on the locale that
     *  is selected when the validator object
     *  is constructed.</p>
     *
     *  @throws TypeError if this property is assigned a null value.
     *
     *  @default dependent on the locale and operating system.
     *
     *  @see #validate()
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get decimalSeparator():String
    {
        return getBasicProperty(properties, DECIMAL_SEPARATOR);
    }

    public function set decimalSeparator(value:String):void
    {
        setBasicProperty(properties, DECIMAL_SEPARATOR, value);
    }

    
    //----------------------------------
    //  domain
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the domain property.
     */
    private var _domain:String;
    
    /**
     *  @private
     */
    protected var domainOverride:String = "real";
    
    [Inspectable(category="General", enumeration="int,real",
                                     defaultValue="real")]
    [Bindable("change")]
    
    /**
     *  Type of number to be validated.
     *  Permitted values are <code>"real"</code> and <code>"int"</code>.
     *
     *  <p>In ActionScript, you can use the following constants to set this
     *  property:
     *  <code>NumberValidatorDomainType.REAL</code> or
     *  <code>NumberValidatorDomainType.INT</code>.</p>
     *
     *  @default "real"
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get domain():String
    {
        return _domain;
    }
    
    /**
     *  @private
     */
    public function set domain(value:String):void
    {
        domainOverride = value;
        
        if (!value)
        {
            _domain = resourceManager.getString(
                "validators", "numberValidatorDomain");
        }
        else if ((value != NumberValidatorDomainType.INT) && 
            (value != NumberValidatorDomainType.REAL))
        {
            throw new ArgumentError();
        }
        else
        {
            _domain = value; 
        }
        
        update();
    }

    //----------------------------------
    //  fractionalDigits
    //----------------------------------

    [Bindable("change")]
    [Inspectable(category="General", minValue="0")]

    /**
     *  The maximum number of digits that can appear after the decimal
     *  separator.
     *
     *  @default dependent on the locale and operating system.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get fractionalDigits():int
    {
        return getBasicProperty(properties, FRACTIONAL_DIGITS);
    }

    public function set fractionalDigits(value:int):void
    {
        setBasicProperty(properties, FRACTIONAL_DIGITS, value);
    }

    //----------------------------------
    //  groupingPattern
    //----------------------------------

    [Bindable("change")]

    /**
     *  Describes the placement of grouping separators within the
     *  validated number string.
     *
     *  <p>The grouping pattern is defined as a string containing
     *  numbers separated by semicolons and optionally may end
     *  with an asterisk. For example: <code>"3;2;&#42;"</code>.
     *  Each number in the string represents the number of digits
     *  in a group. The grouping separator is placed before each
     *  group of digits. An asterisk at the end of the string
     *  indicates that groups with that number of digits should be
     *  repeated for the rest of the formatted string.
     *  If there is no asterisk then there are no additional groups
     *  or separators for the rest of the formatted string. </p>
     *
     *  <p>The first number in the string corresponds to the first
     *  group of digits to the left of the decimal separator.
     *  Subsequent numbers define the number of digits in subsequent
     *  groups to the left. Thus the string "3;2;&#42;"
     *  indicates that a grouping separator is placed after the first
     *  group of 3 digits, followed by groups of 2 digits.
     *  For example: <code>98,76,54,321</code></p>
     *
     *  <p>The following table shows examples of formatting the
     *  number 123456789.12 with various grouping patterns.
     *  The grouping separator is a comma and the decimal separator
     *  is a period.
     *  </p>
     *    <table class="innertable" border="0">
     *          <tr>
     *                <td>Grouping Pattern</td>
     *                <td>Sample Format</td>
     *          </tr>
     *          <tr>
     *                <td><code>3;&#42;</code></td>
     *                <td>123,456,789.12</td>
     *          </tr>
     *          <tr>
     *                <td><code>3;2;&#42;</code></td>
     *                <td>12,34,56,789.12</td>
     *          </tr>
     *          <tr>
     *                <td><code>3</code></td>
     *                <td>123456,789.12</td>
     *          </tr>
     *    </table>
     *
     *  <p>Only a limited number of grouping sizes can be defined.
     *  On some operating systems, grouping patterns can only contain
     *  two numbers plus an asterisk. Other operating systems can
     *  support up to four numbers and an asterisk.
     *  For patterns without an asterisk, some operating systems
     *  only support one number while others support up to three numbers.
     *  If the maximum number of grouping pattern elements is exceeded,
     *  then additional elements
     *  are ignored and the <code>lastOperationStatus</code> property
     *  is set to indicate that a fall back value is
     *  being used.
     *  </p>
     *
     *  @throws TypeError if this property is assigned a null value.
     *
     *  @default dependent on the locale and operating system.
     *
     *  @see #groupingSeparator
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get groupingPattern():String
    {
        return getBasicProperty(properties, GROUPING_PATTERN);
    }

    public function set groupingPattern(value:String):void
    {
        setBasicProperty(properties, GROUPING_PATTERN, value);
        // donot override the default if grouping pattern is incorrect.
        if (!parseGroupingPattern(value))
            return;
    }

    //----------------------------------
    //  groupingSeparator
    //----------------------------------

    [Bindable("change")]

    /**
     *  The character or string used for the grouping separator.
     *
     *  <p>The value of this property is used as the grouping
     *  separator when validating numbers.  This
     *  property is initially set based on the locale that is selected
     *  when the validator object is constructed.</p>
     *
     *  @throws TypeError if this property is assigned a null value.
     *
     *  @default dependent on the locale and operating system.
     *
     *  @see #validate()
     *  @see #groupingPattern
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get groupingSeparator():String
    {
        return getBasicProperty(properties, GROUPING_SEPARATOR);
    }

    public function set groupingSeparator(value:String):void
    {
        setBasicProperty(properties, GROUPING_SEPARATOR, value);
    }

    //----------------------------------
    //  maxValue
    //----------------------------------

    /**
     *  @private
     *  Storage for the maxValue property.
     */
    private var _maxValue:Number;

    /**
     *  @private
     */
    protected var maxValueOverride:Number;

    [Inspectable(category="General", defaultValue="null")]
    [Bindable("change")]

    /**
     *  Maximum value for a valid number. A value of NaN means there is no
     *  maximum.
     *
     *  @default NaN
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get maxValue():Number
    {
        return _maxValue;
    }

    /**
     *  @private
     */
    public function set maxValue(value:Number):void
    {
        maxValueOverride = value;

        _maxValue = value;
        update();
    }

    //----------------------------------
    //  minValue
    //----------------------------------

    /**
     *  @private
     *  Storage for the minValue property.
     */
    private var _minValue:Number;

    /**
     *  @private
     */
    protected var minValueOverride:Number;

    [Inspectable(category="General", defaultValue="null")]
    [Bindable("change")]

    /**
     *  Minimum value for a valid number. A value of NaN means there is no
     *  minimum.
     *
     *  @default NaN
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get minValue():Number
    {
        return _minValue;
    }

    public function set minValue(value:Number):void
    {
        minValueOverride = value;

        _minValue = value;
        update();
    }

    //----------------------------------
    //  negativeSymbol
    //----------------------------------
    
    [Bindable("change")]
    
    /**
     *  The negative symbol to be used when validating negative values.
     *
     *  <p>This symbol is used when validating a negative number.
     *  This is read-only property as not all operating systems allow
     *  customizing of this property. </p>
     *
     *  <p> This property is set to a default value specified by the locale.</p>
     *
     *  @see #negativeNumberFormat
     *  @see #validate()
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get negativeSymbol():String
    {
        return getBasicProperty(properties, NEGATIVE_SYMBOL);
    }

    //--------------------------------------------------------------------------
    //
    //  Properties: Errors
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  decimalPointCountError
    //----------------------------------

    /**
     *  @private
     *  Storage for the decimalPointCountError property.
     */
    private var _decimalPointCountError:String;

    /**
     *  @private
     */
    protected var decimalPointCountErrorOverride:String;

    [Inspectable(category="Errors", defaultValue="null")]

    /**
     *  Error message when the decimal separator character occurs more than
     *  once.
     *
     *  @default "The decimal separator can occur only once."
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get decimalPointCountError():String
    {
        return _decimalPointCountError;
    }

    public function set decimalPointCountError(value:String):void
    {
        decimalPointCountErrorOverride = value;

        _decimalPointCountError = value ? value :
              resourceManager.getString("validators", "decimalPointCountError");
    }

    //----------------------------------
    //  fractionalDigitsError
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the fractionalDigitsError property.
     */
    private var _fractionalDigitsError:String;
    
    /**
     *  @private
     */
    protected var fractionalDigitsErrorOverride:String;
    
    [Inspectable(category="Errors", defaultValue="null")]
    
    /**
     *  Error message when fraction digits exceeds the value specified
     *  by the fractionalDigits property.
     *
     *  @default "The amount entered has too many digits beyond the decimal
     *  point."
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get fractionalDigitsError():String
    {
        return _fractionalDigitsError;
    }
    
    public function set fractionalDigitsError(value:String):void
    {
        fractionalDigitsErrorOverride = value;
        
        _fractionalDigitsError = value ? value :
            resourceManager.getString("validators", "fractionalDigitsError");
    }

    //----------------------------------
    //  greaterThanMaxError
    //----------------------------------

    /**
     *  @private
     *  Storage for the exceedsMaxError property.
     */
    private var _greaterThanMaxError:String;

    /**
     *  @private
     */
    protected var greaterThanMaxErrorOverride:String;

    [Inspectable(category="Errors", defaultValue="null")]

    /**
     *  Error message when the value exceeds the <code>maxValue</code> property.
     *
     *  @default "The number entered is too large."
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get greaterThanMaxError():String
    {
        return _greaterThanMaxError;
    }

    /**
     *  @private
     */
    public function set greaterThanMaxError(value:String):void
    {
        greaterThanMaxErrorOverride = value;

        _greaterThanMaxError = value ? value :
                   resourceManager.getString("validators", "exceedsMaxErrorNV");
    }

    //----------------------------------
    //  groupingSeparationError
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the groupingSeparationError property.
     */
    private var _groupingSeparationError:String;
    
    /**
     *  @private
     */
    protected var groupingSeparationErrorOverride:String;
    
    [Inspectable(category="Errors", defaultValue="null")]
    
    /**
     *  Error message when the grouping separator is in incorrect location.
     *
     *  @default "The number digits grouping is not following the grouping
     *  pattern."
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get groupingSeparationError():String
    {
        return _groupingSeparationError;
    }
    
    public function set groupingSeparationError(value:String):void
    {
        groupingSeparationErrorOverride = value;
        
        _groupingSeparationError = value ? value :
            resourceManager.getString("validators", "groupingSeparationError");
    }

    //----------------------------------
    //  invalidCharError
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the invalidCharError property.
     */
    private var _invalidCharError:String;
    
    /**
     *  @private
     */
    protected var invalidCharErrorOverride:String;
    
    [Inspectable(category="Errors", defaultValue="null")]
    
    /**
     *  Error message when the value contains invalid characters.
     *
     *  @default The input contains invalid characters."
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get invalidCharError():String
    {
        return _invalidCharError;
    }

    /**
     *  @private
     */
    public function set invalidCharError(value:String):void
    {
        invalidCharErrorOverride = value;
        
        _invalidCharError = value ? value :
            resourceManager.getString("validators", "invalidCharError");
    }
    
    //----------------------------------
    //  invalidFormatCharsError
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the invalidFormatCharsError property.
     */
    private var _invalidFormatCharsError:String;
    
    /**
     *  @private
     */
    protected var invalidFormatCharsErrorOverride:String;
    
    [Inspectable(category="Errors", defaultValue="null")]
    
    /**
     *  Error message when the value contains invalid format characters, which
     *  means that it contains a digit or minus sign (-) as a separator
     *  character, or it contains two or more consecutive separator characters.
     *
     *  @default "One of the formatting parameters is invalid."
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get invalidFormatCharsError():String
    {
        return _invalidFormatCharsError;
    }
    
    public function set invalidFormatCharsError(value:String):void
    {
        invalidFormatCharsErrorOverride = value;
        
        _invalidFormatCharsError = value ? value :
            resourceManager.getString("validators", "invalidFormatCharsError");
    }
    
    //----------------------------------
    //  lessThanMinError
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the lowerThanMinError property.
     */
    private var _lessThanMinError:String;
    
    /**
     *  @private
     */
    protected var lessThanMinErrorOverride:String;
    
    [Inspectable(category="Errors", defaultValue="null")]
    
    /**
     *  Error message when the value is less than the <code>minValue</code>.
     *
     *  @default "The amount entered is too small."
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get lessThanMinError():String
    {
        return _lessThanMinError;
    }
    
    public function set lessThanMinError(value:String):void
    {
        lessThanMinErrorOverride = value;
        
        _lessThanMinError = value ? value :
            resourceManager.getString("validators", "lowerThanMinError");
    }

    //----------------------------------
    //  localeUndefinedError
    //----------------------------------
    
    private var _localeUndefinedError:String;
    /**
     *  @private
     */
    protected var localeUndefinedErrorOverride:String;
    
    [Inspectable(category="Errors", defaultValue="null")]
    /**
     *  Error message when the locale is undefined or is not available.
     *
     *  @default "Locale is undefined."
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get localeUndefinedError():String
    {
        return _localeUndefinedError;
    }
    
    public function set localeUndefinedError(value:String):void
    {
        localeUndefinedErrorOverride = value;
        
        _localeUndefinedError = value ? value :
            resourceManager.getString("validators", "localeUndefinedError");
    }

    //----------------------------------
    //  negativeError
    //----------------------------------

    /**
     *  @private
     *  Storage for the negativeError property.
     */
    private var _negativeError:String;

    /**
     *  @private
     */
    protected var negativeErrorOverride:String;

    [Inspectable(category="Errors", defaultValue="null")]

    /**
     *  Error message when the value is negative and the
     *  <code>allowNegative</code> property is <code>false</code>.
     *
     *  @default "The amount may not be negative."
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get negativeError():String
    {
        return _negativeError;
    }

    public function set negativeError(value:String):void
    {
        negativeErrorOverride = value;

        _negativeError = value ? value :
                       resourceManager.getString("validators", "negativeError");
    }

    //----------------------------------
    //  negativeSymbolError
    //----------------------------------

    /**
     *  @private
     *  Storage for the negativeSymbolError property.
     */
    private var _negativeSymbolError:String;

    /**
     *  @private
     */
    protected var negativeSymbolErrorOverride:String;

    [Inspectable(category="Errors", defaultValue="null")]

    /**
     *  Error message when the negative symbol is repeated or is in wrong place.
     *
     *  @default "The negative symbol is repeated or not in right place."
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get negativeSymbolError():String
    {
        return _negativeSymbolError;
    }

    public function set negativeSymbolError(value:String):void
    {
        negativeSymbolErrorOverride = value;

        _negativeSymbolError = value ? value :
            resourceManager.getString("validators", "negativeSymbolError");
    }

    //----------------------------------
    //  notAnIntegerError
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the integerError property.
     */
    private var _notAnIntegerError:String;
    
    /**
     *  @private
     */
    protected var notAnIntegerErrorOverride:String;
    
    [Inspectable(category="Errors", defaultValue="null")]
    
    /**
     *  Error message when the number must be an integer, as defined
     *  by the <code>domain</code> property.
     *
     *  @default "The number must be an integer."
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get notAnIntegerError():String
    {
        return _notAnIntegerError;
    }
    
    public function set notAnIntegerError(value:String):void
    {
        notAnIntegerErrorOverride = value;
        
        _notAnIntegerError = value ? value :
            resourceManager.getString("validators", "integerError");
    }

    //----------------------------------
    //  parseError
    //----------------------------------

    private var _parseError:String;
    /**
     *  @private
     */
    protected var parseErrorOverride:String;

    [Inspectable(category="Errors", defaultValue="null")]
    /**
     *  Error message when number could not be parsed.
     *
     *  @default "The input string could not be parsed."
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get parseError():String
    {
        return _parseError;
    }

    /**
     *  @private
     */
    public function set parseError(value:String):void
    {
        parseErrorOverride = value;

        _parseError = value ? value :
            resourceManager.getString("validators", "parseError");
    }



    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Create underlying formatter object for currency or number validator.
     *  This method has the common code that is needed by both currency and
     *  number validator object's createWorkingInstance().
     *
     *  <p> Create locale specific formatter object using localeStyle property.
     *  If localeStyle is null, this method sets fallbackLastOperationStatus to
     *  LOCALE_UNDEFINED_ERROR and returns.
     *  If localeStyle is specified and fallback is enforced, then fallback
     *  formatter object is created using "en-US" locale. Otherwise creates
     *  the flash.globalization formatter. The formatter properties are updated
     *  with the user overriden values.</p>
     *
     *  @param validatorType An integer specifying currency or number validator.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     *
     */
    mx_internal function createWorkingInstanceCore(validatorType:int):void
    {
        // release this array as it contains symbols based on previous locale
        // grouping pattern.
        groupingPatternSymbols = null;
        
        if (validatorType == NUMBER_VALIDATOR_TYPE)
            g11nWorkingInstance
            = new spark.formatters.NumberFormatter();
        else if (validatorType == CURRENCY_VALIDATOR_TYPE)
            g11nWorkingInstance
            = new spark.formatters.CurrencyFormatter();
        
        if (!g11nWorkingInstance)
        {
            throw new Error("Internal failure: " +
                "spark formatter creation failure.");
        }
        g11nWorkingInstance.enforceFallback = enforceFallback;
        g11nWorkingInstance.setStyle("locale", localeStyle);
        
        if (g11nWorkingInstance.lastOperationStatus
            != LastOperationStatus.UNSUPPORTED_ERROR)
        {
            properties = g11nWorkingInstance
            propagateBasicProperties(g11nWorkingInstance);
            return;
        }
        
    }

    /**
     *  @private
     *  Return the actual locale id name.
     *
     *  <p> This method gets the actual locale id name from the internal
     *  formatter object. If the formatter object is not available, returns
     *  "en-US" as the ultimate fallback locale id name. </p>
     *
     *  @param validatorType  int having the validator type: currency or number
     *  @returns <code>String</code> Actual locale id name
     *
     */
    mx_internal function getActualLocaleIDName(validatorType:int):String
    {
        if (g11nWorkingInstance)
        {
            return (validatorType == NUMBER_VALIDATOR_TYPE)
            ? (g11nWorkingInstance
                as spark.formatters.NumberFormatter).actualLocaleIDName
                : (g11nWorkingInstance
                    as spark.formatters.CurrencyFormatter).actualLocaleIDName;
        }
            // Flex binding allows a situation of getting actual locale id name even
            // before createWorkingInstance() is called.
        else
        {
            fallbackLastOperationStatus = 
                LastOperationStatus.LOCALE_UNDEFINED_ERROR;
            return undefined;
        }
    }

    /**
     *  @private
     *  Load the error strings overrides.
     */
    mx_internal function loadChangedResources():void
    {
        allowNegative = allowNegativeOverride;
        domain = domainOverride;
        maxValue = maxValueOverride;
        minValue = minValueOverride;
        decimalPointCountError = decimalPointCountErrorOverride;
        greaterThanMaxError = greaterThanMaxErrorOverride;
        notAnIntegerError = notAnIntegerErrorOverride;
        invalidCharError = invalidCharErrorOverride;
        invalidFormatCharsError = invalidFormatCharsErrorOverride;
        lessThanMinError = lessThanMinErrorOverride;
        negativeError = negativeErrorOverride;
        negativeSymbolError = negativeSymbolErrorOverride;
        fractionalDigitsError = fractionalDigitsErrorOverride;
        groupingSeparationError = groupingSeparationErrorOverride;
        parseError = parseErrorOverride;
        localeUndefinedError = localeUndefinedError;
    }

    /**
     *  @private
     */
    mx_internal var groupingPatternSymbols:Array;

    /**
     *  @private
     *  Parse the grouping pattern and store the grouping information.
     *
     *  <p> Parse the grouping pattern and store the grouping information. The
     *  stored grouping information is used by the validateGrouping() method.
     *  </p>
     *
     *  @param  value  String specifying grouping pattern.
     *  @returns <code>Boolean</code> true or false.
     *
     */
    mx_internal function parseGroupingPattern(value:String):Boolean
    {
        var last_is_digit:int = 0;
        var p:String;

        if (!value)
            return false;

        var length:int = value.length;

        if ((length >= PATTERN_LENGTH_LIMIT) ||
           (value.charAt(length - 1) == ";"))
        {
            return false;
        }
        groupingPatternSymbols = new Array();
        var i:int = 0;
        while(length)
        {
            p = value.charAt(i);
            var pnum:Number = Number(p);

            if ((!last_is_digit) && ((pnum >= 1) && (pnum <= 9)))
            {
                ++i;
                length--;
                last_is_digit = 1;
                groupingPatternSymbols.push(p);
            }
            else if ((last_is_digit) && (p == ";"))
            {
                ++i;
                length--;
                last_is_digit = 0;
            }
            else if ((!last_is_digit) && ( p == "*" ))
            {
                ++i;
                length--;
                groupingPatternSymbols.push(p);
                if (length == 0)
                    return true;
                else
                {
                    groupingPatternSymbols.length = 0;
                    return false;
                }
            }
            else
            {
                groupingPatternSymbols.length = 0;
                return false;
            }
        }
        return true;
    }

    /**
     *  @private
     *  Validate the number string portion after the decimal point.
     *
     *  <p> Checks that there are no errors in the number string after the
     *  decimal. Example errors could be having a grouping separator or using an
     *  invalid character like non-numeral after the decimal. If
     *  there are any such errors, this method reports "invalidCharError" and
     *  returns <code>false</code>. Otherwise, returns <code>true</code>.</p>
     *
     *  @param      input        Input string to be checked.
     *  @param      baseField    The field name of the Object being validated.
     *  @param      results      Array holding the ValidationResult objects.
     *
     *  @return     <code>Boolean</code> true if no error otherwise false.
     *
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    mx_internal function validateDecimalString(input:String,
                                               baseField:String,
                                               results:Array):Boolean
    {
        if (!input)
            return true;
        
        const dindex:int = input.indexOf(decimalSeparator);
        var c:String;
        
        if (dindex == -1)
            return true;
        
        for (var i:int = input.length - 1; i > dindex; i--)
        {
            c = input.charAt(i);
            if (DECIMAL_DIGITS.indexOf(c) != -1)
                break;
        }
        
        var eindex:int = i;
        i = dindex + decimalSeparator.length;
        
        for (; i < eindex; i++)
        {
            c = input.charAt(i);
            if (DECIMAL_DIGITS.indexOf(c) != -1)
            {
                continue;
            }
            else
            {
                results.push(new ValidationResult(
                    true, baseField, "invalidChar", invalidCharError));
                return false;
            }
        }
        
        return true;
    }

    /**
     *  @private
     *  Check if a number has correct number of fraction digits.
     *
     *  <p> This method validates if a decimal number has correct number of
     *  fraction digits as specified by the <code>fractionalDigits</code>
     *  property. It also checks if a number is supposed to be integer, based
     *  on the <code>domain</code> property. For fraction digits error, it
     *  reports the "fractionalDigitsError" message as specified in the
     *  validator resources bundle. For integer error it reports the
     *  "integerError" message. If there is an error,
     *  this method returns <code>false</code>. Otherwise returns
     *  <code>true</code>. </p>
     *
     *  @param      input        Input Number string to be checked.
     *  @param      baseField    The field name of the Object being validated.
     *  @param      results      Array holding the ValidationResult objects.
     *
     *  @return     <code>Boolean</code> true if no error otherwise false.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    mx_internal function validateFractionPart(input:String,
                                              decimalSeparatorIndex:int,
                                              baseField:String,
                                              results:Array):Boolean
    {
        if (!input)
            return true;
        
        // Make sure that there aren't too many digits after the decimal point:
        // if domain is int there should be none,
        // otherwise there should be no more than specified by fractionalDigits.
        // The input string ALWAYS contains . as decimalseparator as, the caller
        // converts number obtained from NumberFormatter.parseNumber() to string
        // and then sends.
        
        const len:int = input.length;
        
        if (decimalSeparatorIndex != -1)
        {
            var numDigitsAfterDecimal:Number = 0;
            // we only have a '.'
            if (input == decimalSeparator)
            {
                results.push(new ValidationResult(
                    true, baseField, "invalidChar", invalidCharError));
                return false;
            }
            
            var i:int = decimalSeparatorIndex + decimalSeparator.length;
            
            // There may not be any digits after the decimal
            // if domain is int.
            if ((i < len) && (DECIMAL_DIGITS.indexOf(input.charAt(i)) != -1))
            {
                if (domain == NumberValidatorDomainType.INT)
                {
                    results.push(new ValidationResult(
                        true, baseField,"integer", notAnIntegerError));
                    return false;
                }
            }
            
            for (;i < len; i++)
            {
                ++numDigitsAfterDecimal;
                // break at ) or - or currency string when validatng fractions.
                if (DECIMAL_DIGITS.indexOf(input.charAt(i)) == -1)
                    break;
                
                // Make sure fractionalDigits is not exceeded.
                if (fractionalDigits != -1 &&
                    numDigitsAfterDecimal > fractionalDigits)
                {
                    results.push(new ValidationResult(
                        true, baseField, "fractionalDigits",
                        fractionalDigitsError));
                    return false;
                }
            }
        }
        return true;
    }
    /**
     *  @private
     *  Validate the grouping of digits in the number string.
     *
     *  <p>This method is called by both currency and number validator.
     *  The algorithm is to
     *  1. Start from the decimal end of the input string.
     *  2. Find the index 'grSepIndex' of all grouping separators in the input
     *     string.
     *  3. Compute the supposed grouping symbol index 'sepIndex' per grouping
     *     pattern.
     *  4. Make sure that these two are same. </p>
     *
     *  @param input String representing number being validated
     *  @param end   Index of last character in the input string.
     *  @returns <code>Boolean</code> true or false depending on grouping check.
     */
    mx_internal function validateGrouping(input:String, end:int):Boolean
    {
        if (!input)
            return true;

        // Be lenient on grouping separator. If grouping separator is not used,
        // treat it as correct. mx:Validators have same behaviour.
        if (input.indexOf(groupingSeparator) == -1)
            return true;
        if (groupingPatternSymbols == null)
            parseGroupingPattern(groupingPattern);
        const len:int = groupingPatternSymbols.length;

        var j:int = 0;
        var grPatNum:int = 0;
        var sepIndex:int = end;
        var i:int = 0;

        while (sepIndex > 0)
        {
            var grPat:String;
            // lastIndexOf() method searches upto including second parameter.
            // Hence decrement sepIndex for next iteration if a separator
            // symbol is found.
            var grSepIndex:int = input.lastIndexOf(groupingSeparator, sepIndex);

            if (j < len)
            {
                grPat = groupingPatternSymbols[j];
            }
            else if (grPat != "*")
            {
                grPat = "0";
                sepIndex = -1; // no more checking of grouping symbol
            }

            if (grPat != "*")
                grPatNum = Number(grPat);

            // grouping separator could be before the actual index. i.e. in case
            // of 3;3;* 123,3,45,678.56 grouping separator happens before the
            // exact position.
            var sepIndexCurrent:int = sepIndex - grPatNum -
                                      (groupingSeparator.length - 1);
            // special case: 1234^^^456^^^789, grouping pattern 3;*
            if ((sepIndexCurrent < 0) && (grSepIndex < 0) &&
                                               (sepIndex < grPatNum))
                return true;
            //enough digits, but no separator.
            if ((grSepIndex < 0) && (sepIndex >= grPatNum))
                return false;
            sepIndex = sepIndexCurrent;
            // case of 12,,345.56. grSepIndex is 2 and sepIndex = -1
            if (sepIndex != grSepIndex)
                return false;

            // increase j to get the next grouping pattern symbol in the array
            // decrement sepIndex to skip grouping separator already found.
            j++;
            sepIndex--;
        }
        return true;
    }

    /**
     *  @private
     *  Check if a number string contains invalid characters.
     *
     *  <p> This method validates if a number string has any characters other
     *  than the caller specified valid characters. Valid characters for numbers
     *  and currency comprise of digits, decimal separator, grouping separator,
     *  negative format characters, currency ISO code, currency symbol and white
     *  space. If any other character is found, then this method returns
     *  <code>false</code>. Otherwise returns <code>true</code>. </p>
     *
     *  @param      input     String representation of number to be validated.
     *  @param      len       int specifying the length of input
     *  @param      validChars String containing all valid characters.
     *
     *  @return     <code>Boolean</code> true if no error otherwise false.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    
    // detect if invalid characters are present in input. Caller supplies the
    // valid characters.
    mx_internal function validateInputCharacters(input:String,
                                                 len:int,
                                                 validChars:String):Boolean
    {
        if (!input)
            return true;
        
        for (var i:int = 0; i < len; i++)
        {
            const c:String = input.charAt(i);
            if (validChars.indexOf(c) == -1)
            {
                if (GlobalizationUtils.isWhiteSpace(c.charCodeAt(0)))
                    continue;
                return true;
            }
        }
        
        return false;
    }
    /**
     *  @private
     *  Check if input number string has any format or negative symbol errors.
     *
     *  <p> This method validates if an input number string has right format
     *  and does not have multiple negative symbols.
     *  If there is an error, this method returns <code>false</code>. Otherwise
     *  returns <code>true</code>. </p>
     *
     *  @param      input        Input Number string to be checked.
     *  @param      baseField    The field name of the Object being validated.
     *  @param      results      Array holding the ValidationResult objects.
     *
     *  @return     <code>Boolean</code> true if no error otherwise false.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */

    // check some common errors.
    mx_internal function validateNumberFormat(input:String,
                                         results:Array,
                                         baseField:String):Boolean
    {
        if (!input)
            return true;

        const len:int = input.length;
        var c:String;

        if (input.charAt(0) == "(")
        {
            // Make sure the last character is a closed parenthesis.
            if (input.charAt(len - 1) != ")")
            {
                results.push(new ValidationResult(
                    true, baseField, "invalidFormatChars",
                    invalidFormatCharsError));
                return false;
            }
        }
        else if (input.charAt(len - 1) == ")")
        {
            // Make sure the last character is a closed parenthesis.
            if (input.charAt(0) != "(")
            {
                results.push(new ValidationResult(
                    true, baseField, "invalidFormatCharsError",
                    invalidFormatCharsError));
                return false;
            }
        }

        if ((decimalSeparator == groupingSeparator) ||
            (negativeSymbol == groupingSeparator) ||
            (decimalSeparator == negativeSymbol))
        {
            results.push(new ValidationResult(
               true, baseField, "invalidFormatChars", invalidFormatCharsError));
            return false;
        }
        // handle "-." special case
        else if (input == (negativeSymbol + decimalSeparator))
        {
            results.push(new ValidationResult(
                true, baseField, "invalidChar", invalidCharError));
            return false;
        }
        // handle "(.)" special case
        else if (input == ("(" + decimalSeparator + ")"))
        {
            results.push(new ValidationResult(
                true, baseField, "invalidChar", invalidCharError));
            return false;
        }
        else if (input.indexOf(negativeSymbol) !=
                 input.lastIndexOf(negativeSymbol))
        {

            results.push(new ValidationResult(
                    true, baseField, "negativeSymbol", negativeSymbolError));
            return false;
        }
        return true;
    }

    /**
     *  @private
     *  Check if input number can be negative depending on allowNegative
     *  property.
     *
     *  <p> Checks if input number can be negative based on the
     *  <code>allowNegative</code> property. If <code>allowNegative</code> is
     *  false and number is negative, this method reports "negativeError" and
     *  returns <code>false</code>. Otherwise, returns <code>true</code>. </p>
     *
     *  @param      inputNum     Input Number string to be checked.
     *  @param      baseField    The field name of the Object being validated.
     *  @param      results      Array holding the ValidationResult objects.
     *
     *  @return     <code>Boolean</code> true if no error otherwise false.
     *
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    mx_internal function validateNumberNegativity(inputNum:Number,
                                                  baseField:String,
                                                  results:Array):Boolean
    {
        if (inputNum < 0)
        {
            // Check if negative input is allowed.
            if (!allowNegative)
            {
                results.push(new ValidationResult(
                    true, baseField, "negative", negativeError));
                return false;
            }
        }
        return true;
    }
    /**
     *  @private
     *  Check if a number is in a range specified by the user.
     *
     *  <p> This method validates if a number is in the range specified by the
     *  user. The minValue and maxValue properties define the range. If the
     *  number is not in the range, then this method reports either
     *  "lowerThanMinError" or "exceedsMaxError". If there is a range error,
     *  this returns <code>false</code>. Otherwise returns
     *  <code>true</code>.</p>
     *
     *  @param      num     Input Number string to be checked.
     *  @param      baseField    The field name of the Object being validated.
     *  @param      results      Array holding the ValidationResult objects.
     *
     *  @return     <code>Boolean</code> true if no error otherwise false.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    mx_internal function validateNumberRange(num:Number,
                                           baseField:String,
                                           results:Array):Boolean
    {
        const maxValue:Number = Number(maxValue);
        const minValue:Number = Number(minValue);
        if (!isNaN(minValue) || !isNaN(maxValue))
        {
            if (!isNaN(minValue) && (num < minValue))
            {
                results.push(new ValidationResult(
                    true, baseField, "lowerThanMin", lessThanMinError));
                return false;
            }

            if (!isNaN(maxValue) && (num > maxValue))
            {
                results.push(new ValidationResult(
                    true, baseField, "exceedsMax", greaterThanMaxError));
                return false;
            }
        }
        return true;
    }
}
}
