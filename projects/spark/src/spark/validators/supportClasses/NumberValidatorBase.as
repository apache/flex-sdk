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
 *  The <code>NumberValidatorBase</code> class contains all the common functionality that is
 *  required by the <code>NumberValidator</code> and 
 *  <code>CurrencyValidator</code> classes.
 *
 *  @mxml
 *
 *  <p>The <code>&lt;s:NumberValidator&gt;</code> tag
 *  inherits all of the tag attributes of its superclass,
 *  and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:NumberValidatorBase
 *    <strong>Properties</strong>
 *    allowNegative="true"
 *    decimalPointCountError="The decimal separator can only occur once."
 *    decimalSeparator="<i>locale specified string or customized by user</i>."
 *    digitsType="<i>locale specified string or customized by user</i>."
 *    domain="real"
 *    fractionalDigits="<i>locale specified string or customized by user</i>."
 *    fractionalDigitsError="The amount entered has too many digits beyond the decimal point."
 *    greaterThanMaxError="The number entered is too large."
 *    groupingSeparator="<i>locale specified string or customized by user</i>."
 *    invalidCharError="The input contains invalid characters."
 *    invalidFormatCharsError="One of the formatting parameters is invalid."
 *    lessThanMinError="The amount entered is too small."
 *    localeUndefinedError="Locale is undefined."
 *    maxValue="NaN"
 *    minValue="NaN"
 *    negativeError="The amount may not be negative."
 *    negativeSymbolError="The negative symbol is repeated or not in right place."
 *    notAnIntegerError="The number must be an integer."
 *    parseError="The input string could not be parsed."
 *  /&gt;
 *  </pre>
 *
 *  @see spark.formatters.supportClasses.NumberFormatterBase
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
    private static const DIGITS_TYPE:String = "digitsType";
    private static const FRACTIONAL_DIGITS:String = "fractionalDigits";
    private static const GROUPING_SEPARATOR:String = "groupingSeparator";
    private static const NEGATIVE_SYMBOL:String = "negativeSymbol";

    // Used by inheritors.
    mx_internal static const NUMBER_VALIDATOR_TYPE:int = 1;
    mx_internal static const CURRENCY_VALIDATOR_TYPE:int = 2;
    private static const NEGATIVE_SYMBOLS:String = "-" + 
        String.fromCharCode(0x2212, 0xFE63, 0xFF0D);
    mx_internal static  const VALID_CHARS:String = DECIMAL_DIGITS + "(" 
         + ")" + NEGATIVE_SYMBOLS;

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
        _domain = NumberValidatorDomainType.REAL;
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
    private var _g11nWorkingInstance:Object = null;

    /**
     *  @private
     *  If the g11nWorkingInstance has not been defined. Call
     *  ensureStyleSource to ensure that there is a styleParent. If there is
     *  not a style parent, then this instance will be added as a style client
     *  to the topLevelApplication. As a side effect of this, the styleChanged
     *  method will be called and if there is a locale style defined for the
     *  topLevelApplication, the createWorkingInstance method will be
     *  executed creating a g11nWorkingInstance.
     */
    mx_internal function get g11nWorkingInstance ():Object
    {
        if (!_g11nWorkingInstance)
            ensureStyleSource();
        
        return _g11nWorkingInstance;
    }
    
    mx_internal function set g11nWorkingInstance (sparkFormatter:Object): void 
    {
        _g11nWorkingInstance = sparkFormatter;
    }
    
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
     *  <p>This property is initially set based on the locale style of the 
     *  validator object.</p>
     *
     *  <p>The default value is dependent on the locale and operating
     *  system.</p>
     *
     *  @throws TypeError if this property is assigned a null value.
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
    //  digitsType
    //----------------------------------
    
    [Bindable("change")]
    
    /**
     *  Defines the set of digit characters to be used when
     *  validating numbers.
     *
     *  <p>Different languages and regions use different sets of
     *  characters to represent the
     *  digits 0 through 9.  This property defines the set of digits
     *  to be used.</p>
     *
     *  <p>The value of this property represents the Unicode value for
     *  the zero digit of a decimal digit set.
     *  The valid values for this property are defined in the
     *  <code>NationalDigitsType</code> class.</p>
     *
     *  <p>The default value is dependent on the locale and operating
     *  system.</p>
     *
     *  @see flash.globalization.NationalDigitsType
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get digitsType():uint
    {
        return getBasicProperty(properties, DIGITS_TYPE);
    }
    
    public function set digitsType(value:uint):void
    {
        setBasicProperty(properties, DIGITS_TYPE, value);
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
     *  @see #NumberValidatorDomainType
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
     *  <p>The default value is dependent on the locale and operating
     *  system.</p>
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
     *  <p>The default value is dependent on the locale and operating
     *  system.</p>
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
     *  customizing of this property.</p>
     *
     *  <p>This property is set to a default value specified by the locale.</p>
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
    [Bindable("change")]
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
        if (decimalPointCountErrorOverride && 
            (decimalPointCountErrorOverride == value))
            return;
        
        decimalPointCountErrorOverride = value;

        _decimalPointCountError = value ? value :
              resourceManager.getString("validators", "decimalPointCountError");
        update();
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
    [Bindable("change")]
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
        if (fractionalDigitsErrorOverride && 
            (fractionalDigitsErrorOverride == value))
            return;
        
        fractionalDigitsErrorOverride = value;
        
        _fractionalDigitsError = value ? value :
            resourceManager.getString("validators", "fractionalDigitsError");
        update();
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
    [Bindable("change")]
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
        if (greaterThanMaxErrorOverride &&
            (greaterThanMaxErrorOverride == value))
            return;
        
        greaterThanMaxErrorOverride = value;

        _greaterThanMaxError = value ? value :
                   resourceManager.getString("validators", "exceedsMaxErrorNV");
        update();
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
    [Bindable("change")]
    /**
     *  Error message when the value contains invalid characters.
     *
     *  @default "The input contains invalid characters."
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
        if (invalidCharErrorOverride &&
            (invalidCharErrorOverride == value))
            return;
        
        invalidCharErrorOverride = value;
        
        _invalidCharError = value ? value :
            resourceManager.getString("validators", "invalidCharError");
        update();
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
    [Bindable("change")]
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
        if (invalidFormatCharsErrorOverride &&
            (invalidFormatCharsErrorOverride == value))
            return;
        
        invalidFormatCharsErrorOverride = value;
        
        _invalidFormatCharsError = value ? value :
            resourceManager.getString("validators", "invalidFormatCharsError");
        update();
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
    [Bindable("change")]
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
        if (lessThanMinErrorOverride &&
            (lessThanMinErrorOverride == value))
            return;
        
        lessThanMinErrorOverride = value;
        
        _lessThanMinError = value ? value :
            resourceManager.getString("validators", "lowerThanMinError");
        update();
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
    [Bindable("change")]
    
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
        if (localeUndefinedErrorOverride &&
            (localeUndefinedErrorOverride == value))
            return;
        
        localeUndefinedErrorOverride = value;
        
        _localeUndefinedError = value ? value :
            resourceManager.getString("validators", "localeUndefinedError");
        update();
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
    [Bindable("change")]

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
        if (negativeErrorOverride &&
            (negativeErrorOverride == value))
            return;
        
        negativeErrorOverride = value;

        _negativeError = value ? value :
                       resourceManager.getString("validators", "negativeError");
        update();
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
    [Bindable("change")]

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
        if (negativeSymbolErrorOverride &&
            (negativeSymbolErrorOverride == value))
            return;
        
        negativeSymbolErrorOverride = value;

        _negativeSymbolError = value ? value :
            resourceManager.getString("validators", "negativeSymbolError");
        update();
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
    [Bindable("change")]

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
        if (notAnIntegerErrorOverride &&
            (notAnIntegerErrorOverride == value))
            return;
        notAnIntegerErrorOverride = value;
        
        _notAnIntegerError = value ? value :
            resourceManager.getString("validators", "integerError");
        update();
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
    [Bindable("change")]

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
        if (parseErrorOverride &&
            (parseErrorOverride == value))
            return;
        
        parseErrorOverride = value;

        _parseError = value ? value :
            resourceManager.getString("validators", "parseError");
        update();
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
     *  <p>Create locale specific formatter object using localeStyle property.
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
     *  <p>This method gets the actual locale id name from the internal
     *  formatter object. If the formatter object is not available, returns
     *  "en-US" as the ultimate fallback locale id name.</p>
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
            // Flex binding allows a situation of getting actual locale id name
            // even before createWorkingInstance() is called.
        else
        {
            fallbackLastOperationStatus = 
                LastOperationStatus.LOCALE_UNDEFINED_ERROR;
            return undefined;
        }
    }

    /**
    *  @private
    *  get the index of first digit.
    */
    mx_internal function indexOfFirstDigit(input:String, len:int, 
                                           start:int=0):int
    {
        if (!input || !len)
            return -1;
        for (var i:int = start; i < len; i++)
        {
            var c0:int = input.charCodeAt(i);
            var c32:int = processSurrogates(input, c0, i, len);
            if (c32 == -1)
                return -1;
            if (isDigit(c32))
                return i;
            if (c0 != c32)
                i++;  // surrogate found. index increment for lower surrogate.
        }
        return -1;
    }

    /**
     *  @private
     *  get the index of last digit.
     */
    mx_internal function indexOfLastDigit(input:String, len:int, 
                                          end:int):int
    {
        if (!input || !len)
            return -1;
        for (var i:int = end; i >= 0; i--)
        {
            
            var c0:int = input.charCodeAt(i);
            var c32:int = processSurrogates(input, c0, i, len);
            if (c32 == -1)
                return -1;
            if (c0 != c32)
                i--;  // surrogate found. index decrement for lower surrogate.
            if (isDigit(c32))
                return i;
        }
        return -1;
    }

    /**
     *  @private
     */
    mx_internal function inputHasMultipleNegativeSymbols(input:String):Boolean
    {
        if (!input)
            return false;
        
        var nflag:Boolean = false;
        var gflag:Boolean = false;
        var i:int = 0;
        var c:String;
        
        if (negativeSymbol == decimalSeparator)
        {
            nflag = true;
        }
        else
        {
            for (i = 0; i < NEGATIVE_SYMBOLS.length; i++)
            {
                c = NEGATIVE_SYMBOLS.charAt(i);
                if (decimalSeparator == c)
                {
                    nflag = true;
                    break;
                }
            }
        }
        
        if (negativeSymbol == groupingSeparator)
        {
            gflag = true
        }
        else
        {
            for (i = 0; i < NEGATIVE_SYMBOLS.length; i++)
            {
                c = NEGATIVE_SYMBOLS.charAt(i);
                if (groupingSeparator == c)
                {
                    gflag = true;
                    break;
                }
            }
        }
        
        
        if (!nflag && !gflag && (input.indexOf(negativeSymbol) != 
                                input.lastIndexOf(negativeSymbol)))
        {
            return true;
        }
            
        var nsymbols:String = NEGATIVE_SYMBOLS + negativeSymbol;
        var ncount:int = 0;
        for (i = 0; i < input.length; i++)
        {
            c = input.charAt(i);
            if (nsymbols.indexOf(c) != -1)
                ncount++;
        }
        
        if (!gflag)
        {
            
            if (!nflag)
            {
                if (ncount > 1)
                    return true;
            }
            else
            {
                if (ncount > 2)
                    return true;
            }
        }
            
        return false;
    }

    /**
     *  @private
     */
    mx_internal function inputHasNegativeSymbol(input:String):Boolean
    {
        if (!input)
            return false;
        
        if (input.indexOf(negativeSymbol) != -1)
            return true;
            
        for (var i:int = 0; i < input.length; i++)
        {
            var c:String = input.charAt(i);
            if (NEGATIVE_SYMBOLS.indexOf(c) != -1)
                return true;
        }
        return false;
    }

    /**
     *  @private
     *  Check if it is a digit..
     */
    private function isDigit(codepoint:int):Boolean
    {
        if (GlobalizationUtils.isDigit(codepoint))
            return true;
        // Adding 9 may not be right always. But there is no way for user to
        // communicate the highest digit.
        if ((codepoint >= digitsType) && (codepoint <= digitsType + 9 ))
            return true;
        return false;
    }

    /**
     *  @private
     */
    mx_internal function isNegativeSymbol(input:String):Boolean
    {
        if (!input)
            return false;
        
        if (input == negativeSymbol)
            return true;
        for (var i:int = 0; i < NEGATIVE_SYMBOLS.length; i++)
        {
            var c:String = NEGATIVE_SYMBOLS.charAt(i);
            if (input == c)
                return true;
        }
        return false;
    }

    /**
     *  @private
     *  Load the error strings overrides.
     */
    mx_internal function loadChangedResources():void
    {
        decimalPointCountError = decimalPointCountErrorOverride;
        greaterThanMaxError = greaterThanMaxErrorOverride;
        notAnIntegerError = notAnIntegerErrorOverride;
        invalidCharError = invalidCharErrorOverride;
        invalidFormatCharsError = invalidFormatCharsErrorOverride;
        lessThanMinError = lessThanMinErrorOverride;
        negativeError = negativeErrorOverride;
        negativeSymbolError = negativeSymbolErrorOverride;
        fractionalDigitsError = fractionalDigitsErrorOverride;
        parseError = parseErrorOverride;
        localeUndefinedError = localeUndefinedError;
    }

    private function inputHasNoDigits(input:String):Boolean
    {
        if (!input)
            return false;
        
        for (var i:int; i < input.length; i++)
        {
            var c0:int = input.charCodeAt(i);
            var c1:int = processSurrogates(input, c0, i, input.length);
            if (c1 == -1)
                continue;
            if (c0 != c1)
                i++;
            if (isDigit(c1))
                return false;
        }
        return true;
    }
    /**
     *  @private
     */
     mx_internal function processSurrogates(input:String, c0:int, index:int, 
                                            len:int):int
     {
         var j:int = 0;
         var c1:int;
         if (GlobalizationUtils.isLeadingSurrogate(c0))
         {
            j = index + 1;
             if (j < len)
             {
                 c1 = input.charCodeAt(j);
                 if (GlobalizationUtils.isTrailingSurrogate(c1))
                     c0 = GlobalizationUtils.surrogateToUTF32(c0, c1);
                 else
                     return -1;
             }
             else
                 return -1;
         }
         else if (GlobalizationUtils.isTrailingSurrogate(c0))
         {
             j = index - 1;
             if (j >= 0)
             {
                 c1 = input.charCodeAt(j);
                 if (GlobalizationUtils.isLeadingSurrogate(c1))
                     c0 = GlobalizationUtils.surrogateToUTF32(c1, c0);
                 else
                     return -1;
             }
             else
                 return -1;
         }
         
         return c0;
     }

    /**
     *  @private
     *  Validate the number string portion after the decimal point.
     *
     *  <p>Checks that there are no errors in the number string after the
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
                                               results:Array, 
                                               negPosLeft:Boolean):Boolean
    {
        if (!input)
            return true;
        
        var dindex:int;
        if (negPosLeft)
            dindex = input.lastIndexOf(decimalSeparator);
        else
            dindex = input.indexOf(decimalSeparator);
        var c:String;
        var i:int;
        var c0:int;
        var c1:int;
        if (dindex == -1)
            return true;
        
        for (i = input.length; i > dindex; i--)
        {
            c0 = input.charCodeAt(i);
            c1 = processSurrogates(input, c0, i, eindex);
            if (c1 == -1)
                return false; //illegal surrogate
            if (isDigit(c1))
                break;
            if (c0 != c1)
                    i--; // digit was surrogate. increment string index.
        }
        var eindex:int = i;
        i = dindex + decimalSeparator.length;
        
        for (; i < eindex; i++)
        {
            c0 = input.charCodeAt(i);
            c1 = processSurrogates(input, c0, i, eindex);
                
            if ((c1 != -1) && isDigit(c1))
            {
                if (c0 != c1)
                    i++; // digit was surrogate. increment string index.
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
     *  <p>This method validates if a decimal number has correct number of
     *  fraction digits as specified by the <code>fractionalDigits</code>
     *  property. It also checks if a number is supposed to be integer, based
     *  on the <code>domain</code> property. For fraction digits error, it
     *  reports the "fractionalDigitsError" message as specified in the
     *  validator resources bundle. For integer error it reports the
     *  "integerError" message. If there is an error,
     *  this method returns <code>false</code>. Otherwise returns
     *  <code>true</code>.</p>
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
            var c0:int = input.charCodeAt(i);
            var c32:int = processSurrogates(input, c0, i, len);
            if (c32 == -1)
            {
                results.push(new ValidationResult(
                    true, baseField, "invalidChar", invalidCharError));
                return false;
            }

            if ((i < len) && isDigit(c32))
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
                c0 = input.charCodeAt(i);
                c32 = processSurrogates(input, c0, i, len);
                if (c32 == -1)
                {
                    results.push(new ValidationResult(
                        true, baseField, "invalidChar", invalidCharError));
                    return false;
                }
                if (c0 != c32)
                    i++; // surrogate found. increment index of lower surrogate.
                ++numDigitsAfterDecimal;
                // break at ) or - or currency string when validatng fractions.
                if (!isDigit(c32))
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
     *  Check if a number string contains invalid characters.
     *
     *  <p>This method validates if a number string has any characters other
     *  than the caller specified valid characters. Valid characters for numbers
     *  and currency comprise of digits, decimal separator, grouping separator,
     *  negative format characters, currency ISO code, currency symbol and white
     *  space. If any other character is found, then this method returns
     *  <code>false</code>. Otherwise returns <code>true</code>.</p>
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
    // TODO: The code to check for valid surrogates is repeated in many methods.
    // See if this can be optimized.
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
                var c0:int = c.charCodeAt(0);
                var c32:int = processSurrogates(input, c0, i, len);
                if (c32 == -1)
                    return true;
                else if (c0 != c32) // surrogate. increment string index.
                    i++;
                if (isDigit(c0))
                    continue;
                if (GlobalizationUtils.isWhiteSpace(c0))
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
     *  <p>This method validates if an input number string has right format
     *  and does not have multiple negative symbols.
     *  If there is an error, this method returns <code>false</code>. Otherwise
     *  returns <code>true</code>.</p>
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

        if (decimalSeparator == groupingSeparator)
        {
            results.push(new ValidationResult(
               true, baseField, "invalidFormatChars", invalidFormatCharsError));
            return false;
        }
        else if (inputHasNoDigits(input))
        {
            results.push(new ValidationResult(
                true, baseField, "parseError", parseError));
            return false;
        }
        else if (inputHasMultipleNegativeSymbols(input))
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
     *  <p>Checks if input number can be negative based on the
     *  <code>allowNegative</code> property. If <code>allowNegative</code> is
     *  false and number is negative, this method reports "negativeError" and
     *  returns <code>false</code>. Otherwise, returns <code>true</code>.</p>
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
     *  <p>This method validates if a number is in the range specified by the
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
