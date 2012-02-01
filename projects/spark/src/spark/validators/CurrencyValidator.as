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

package spark.validators
{

import flash.globalization.CurrencyParseResult;
import flash.globalization.NationalDigitsType;
import flash.globalization.NumberFormatter;

import mx.core.mx_internal;
import mx.formatters.IFormatter;
import mx.managers.ISystemManager;
import mx.managers.SystemManager;
import mx.validators.NumberValidatorDomainType;
import mx.validators.ValidationResult;

import spark.globalization.LastOperationStatus;
import spark.validators.supportClasses.NumberValidatorBase;
import spark.validators.supportClasses.GlobalizationUtils;
import spark.formatters.CurrencyFormatter;

use namespace mx_internal;

[ResourceBundle("validators")]

/**
 *  The <code>CurrencyValidator</code> class ensures that a String represents
 *  a valid currency amount according to the conventions of a locale.
 *
 *  This class uses the <code>locale</code> style for specifying the Locale ID.
 *
 *  <p>The validator can ensure that a currency string falls within a given
 *  range (specified by <code>minValue</code> and <code>maxValue</code>
 *  properties), is an integer (specified by <code>domain</code> property),
 *  is non-negative (specified by <code>allowNegative</code> property),
 *  correctly specifies negative and positive numbers,
 *  has the correct currency ISO code or currency symbol,
 *  and does not exceed the specified number of <code>fractionalDigits</code>.
 *  The validator sets default property values by making use of the 
 *  <code>flash.globalization.CurrencyFormatter</code> class and therefore the
 *  locale specific values are supplied by the operating system.</p>
 *
 *  <p>The <code>flash.globalization.CurrencyFormatter</code> class uses the
 *  underlying operating system to supply the locale specific data. In case
 *  the operating system does not provide currency formatting, this class
 *  provides fallback functionality.</p>
 *
 *  @mxml
 *
 *  <p>The <code>&lt;s:CurrencyValidator&gt;</code> tag
 *  inherits all of the tag attributes of its superclass,
 *  and adds the following tag attributes:</p>
 *
*  <pre>
 *  &lt;s:CurrencyValidator
 *    <strong>Properties</strong>
 *    currencyISOCode="<i>locale specified string or customized by user</i>."
 *    currencyStringError="Currency name is repeated or not correct."
 *    currencySymbol="<i>locale specified string or customized by user</i>."
 *    negativeCurrencyFormat="<i>locale specified string or customized by user</i>."
 *    negativeCurrencyFormatError="The negative format of the input currency is incorrect."
 *    positiveCurrencyFormat="<i>locale specified string or customized by user</i>."
 *    positiveCurrencyFormatError="The positive format of the input currency is incorrect."
 *  /&gt;
 *  </pre>
 *
 *    
 *  @includeExample examples/CurrencyValidatorExample1.mxml
 * 
 *  @see flash.globalization.CurrencyFormatter
 *
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class CurrencyValidator extends NumberValidatorBase
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class Constants
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private static const CURRENCY_SPACE_SEP:String = " ";
    private static const CURRENCY_ISOCODE_LEN:uint = 3;
    private static const CURRENCY_ISOCODE:String = "currencyISOCode";
    private static const CURRENCY_SYMBOL:String = "currencySymbol";
    private static const NEGATIVE_CURRENCY_FORMAT:String =
                                                    "negativeCurrencyFormat";
    private static const POSITIVE_CURRENCY_FORMAT:String =
                                                    "positiveCurrencyFormat";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructs a new <code>CurrencyValidator</code> object to validate
     *  numbers representing currency amounts according to
     *  the conventions of a given locale.
     *  <p>
     *  The locale for this class is supplied by the <code>locale</code>
     *  style property.
     *  The <code>locale</code> style can be set in several ways:
     *  </p>
     *  <ul>
     *  <li>
     *  Inheriting the style from a <code>UIComponent</code> by calling the
     *  <code>UIComponent</code>'s <code>addStyleClient</code> method.
     *  </li>
     *  <li>
     *  By using the class in an MXML declaration and inheriting the
     *  locale from the document that contains the declaration.
     *  </li>
     *  <pre>
     *  &lt;fx:Declarations&gt;
     *         &lt;s:CurrencyValidator id="cv" /&gt;
     *  &lt;/fx:Declarations&gt;
     *  </pre>
     *  <li>
     *  By using an MXML declaration and specifying the locale value
     *  in the list of assignments.
     *  </li>
     *  <pre>
     *  &lt;fx:Declarations&gt;
     *      &lt;s:CurrencyValidator id="cv_turkish" locale="tr-TR" /&gt;
     *  &lt;/fx:Declarations&gt;
     *  </pre>
     *  <li>
     *  Calling the setStyle method,
     *  For example: <code>cv.setStyle("locale", "tr-TR")</code>
     *  </li>
     *  </ul>
     *  <p>
     *  If the <code>locale</code> style is not set by one of the above 
     *  techniques, the instance of this class will be added as a 
     *  <code>StyleClient</code> to the <code>topLevelApplication</code> and 
     *  will therefore inherit the <code>locale</code> style from the 
     *  <code>topLevelApplication</code> object when the <code>locale</code> 
     *  dependent property getter or <code>locale</code> dependent method is 
     *  called.
     *  </p>         *
     *  <p>The properties related to the currency string format are set to
     *     default values based on the locale.</p>
     *
     *  <p><strong>NOTE:</strong> When a fallback locale is used, the currency
     *  properties are set to default values of en_US locale,
     *  and therefore might not match the currency for which the validation is
     *  intended.
     *  It is a good idea to
     *  examine the <code>currencySymbol</code> and <code>currencyISOCode</code>
     *  property values before validating a currency amount.
     *  </p>
     *
     *  @see flash.globalization.CurrencyFormatter#actualLocaleIDName
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function CurrencyValidator()
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  actualLocaleIDName
    //----------------------------------
    
    [Bindable("change")]
    
    /**
     *  @private
     *  The actual locale id name that is being used.
     *  @inheritDoc
     *
     *  @see flash.globalization.NumberFormatter.actualLocaleIDName
     *  @see #NumberFormatter()
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override public function get actualLocaleIDName():String
    {
        return getActualLocaleIDName(CURRENCY_VALIDATOR_TYPE);
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  currencyISOCode
    //----------------------------------

    /**
     *  @private
     */
    private var currencySymbolOverride:String;
    private var currencyISOCodeOverride:String;

    [Bindable("change")]

    /**
     *  The three letter ISO 4217 currency code for the locale
     *  being used.
     *
     *  <p>This property is used to validate the currency string or symbol 
     *  present in the input currency amounts using the <code>validate()</code>
     *  method.
     *  </p>
     *
     *  <p>This property is initialized by the constructor
     *  based on the actual locale that is used. When a fallback
     *  locale is used this property reflects the preferred, default
     *  currency code for the fallback locale.</p>
     *
     *  <p>The default value is dependent on the actual locale and 
     *  <code>operating system</code>.</p>
     *
     *  @see #validate()
     *  @see #currencySymbol
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get currencyISOCode():String
    {
        if (g11nWorkingInstance)
            return g11nWorkingInstance.currencyISOCode;

        if ((localeStyle === undefined) || (localeStyle === null))
        {
            fallbackLastOperationStatus
            = LastOperationStatus.LOCALE_UNDEFINED_ERROR;
            return undefined;
        }

        return properties.currencyISOCode;
    }

    public function set currencyISOCode(value:String):void
    {
        if (currencyISOCodeOverride && (currencyISOCodeOverride == value))
            return;

        currencyISOCodeOverride = value;

        if (g11nWorkingInstance)
        {
            g11nWorkingInstance.currencyISOCode = value;
        }
        else
        {
            if (!value)
                throw new ArgumentError();

            if (properties)
                properties.currencyISOCode = value;
            fallbackLastOperationStatus = LastOperationStatus.NO_ERROR;
        }

        update();
    }

    //----------------------------------
    //  currencySymbol
    //----------------------------------

    [Bindable("change")]

    /**
     *  The currency symbol or string for the locale being used.
     *
     *  <p>This property is used as the currency symbol when validating
     *  currency amounts using the <code>validate()</code> method.The 
     *  currency symbol or currency name in the validation string, 
     *  must match either the value of the <code>currencySymbol</code> property
     *  or the value of the <code>currencyISOCode</code> property. </p>
     *
     *  <p>This property is initialized by the constructor based on
     *  the actual locale that is used. When a fallback
     *  locale is used this property reflects the preferred, default
     *  currency symbol for the fallback locale.</p>
     *
     *  <p>The default value is dependent on the actual locale and 
     *  <code>operating system</code>.</p>
     *
     *  @see #format()
     *  @see #setCurrency()
     *  @see #formattingWithCurrencySymbolIsSafe()
     *  @see #currencyISOCode
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get currencySymbol():String
    {
        if (g11nWorkingInstance)
            return g11nWorkingInstance.currencySymbol;

        if ((localeStyle === undefined) || (localeStyle === null))
        {
            fallbackLastOperationStatus
            = LastOperationStatus.LOCALE_UNDEFINED_ERROR;
            return undefined;
        }

        return properties.currencySymbol;
    }

    public function set currencySymbol(value:String):void
    {
        if (currencySymbolOverride && (currencySymbolOverride == value))
            return;

        currencySymbolOverride = value;

        if (g11nWorkingInstance)
        {
            g11nWorkingInstance.currencySymbol = value;
        }
        else
        {
            if (!value)
                throw new ArgumentError();

            if (properties)
                properties.currencySymbol = value;
            fallbackLastOperationStatus = LastOperationStatus.NO_ERROR;
        }

        update();
    }

    //----------------------------------
    //  negativeCurrencyFormat
    //----------------------------------

    [Bindable("change")]
    [Inspectable(category="General",
                        enumeration="0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15")]

    /**
     *   A numeric value that indicates a validating pattern for negative
     *  currency amounts. This property defines the location of the
     *  currency symbol and the negative symbol or parentheses in
     *  relation to the numeric portion of the currency
     *  amount. This property is used to validate whether or not the input
     *  currency string follows this pattern for negative amounts.
     *
     *   <p>The value of this property must be one of the constants
     *  defined in the table below.
     *  </p>
     *
     *  <ul>
     *   <li>The '&#164;' symbol represents the location of the currencyISOCode
     *       or the currencySymbol in the currency string.
     *   </li>
     *   <li>The '-' character represents the location of the
     *       negativeNumberSymbol.</li>
     *   <li>The 'n' character represents the currency amount.</li>
     *  </ul>
     *
     *    <table class="innertable" border="0">
     *        <tr>
     *            <td>Negative currency format type</td>
     *            <td>Formatting pattern</td>
     *        </tr>
     *        <tr>
     *            <td>0</td>
     *            <td>(&#164;n)</td>
     *        </tr>
     *        <tr>
     *            <td>1</td>
     *            <td>-&#164;n</td>
     *        </tr>
     *        <tr>
     *            <td>2</td>
     *            <td>&#164;-n</td>
     *        </tr>
     *        <tr>
     *            <td>3</td>
     *            <td>&#164;n-</td>
     *        </tr>
     *        <tr>
     *            <td>4</td>
     *            <td>(n&#164;)</td>
     *        </tr>
     *        <tr>
     *            <td>5</td>
     *            <td>-n&#164;</td>
     *        </tr>
     *        <tr>
     *            <td>6</td>
     *            <td>n-&#164;</td>
     *        </tr>
     *        <tr>
     *            <td>7</td>
     *            <td>n&#164;-</td>
     *        </tr>
     *        <tr>
     *            <td>8</td>
     *            <td>-n &#164;</td>
     *        </tr>
     *        <tr>
     *            <td>9</td>
     *            <td>-&#164; n</td>
     *        </tr>
     *        <tr>
     *            <td>10</td>
     *            <td>n &#164;-</td>
     *        </tr>
     *        <tr>
     *            <td>11</td>
     *            <td>&#164; n-</td>
     *        </tr>
     *        <tr>
     *            <td>12</td>
     *            <td>&#164; -n</td>
     *        </tr>
     *        <tr>
     *            <td>13</td>
     *            <td>n- &#164;</td>
     *        </tr>
     *        <tr>
     *            <td>14</td>
     *            <td>(&#164; n)</td>
     *        </tr>
     *        <tr>
     *            <td>15</td>
     *            <td>(n &#164;)</td>
     *        </tr>
     *    </table>
     *
     *  <p>The default value is dependent on the actual locale and
     *  operating system.</p>
     *
     *  @throws ArgumentError if the assigned value is not between 0 and 15.
     *
     *  @see #format()
     *  @see #currencySymbol
     *  @see #negativeSymbol
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get negativeCurrencyFormat():uint
    {
        return getBasicProperty(properties, NEGATIVE_CURRENCY_FORMAT);
    }

    public function set negativeCurrencyFormat(value:uint):void
    {
        if (!g11nWorkingInstance)
        {
            if (15 < value)
                throw new TypeError();
        }

        setBasicProperty(properties, NEGATIVE_CURRENCY_FORMAT, value);
    }

    //----------------------------------
    //  positiveCurrencyFormat
    //----------------------------------

    [Bindable("change")]
    [Inspectable(category="General", enumeration="0,1,2,3")]

    /**
     *    A numeric value that indicates a validating pattern for positive
     *  currency amounts. This property defines the location of currency symbol
     *  relative to the numeric portion of the currency amount. This property
     *  is used to validate if the input currency string
     *  follows this pattern for positive amounts.
     *
     *   <p>The value of this property must be one of the constants
     *  defined in the table below.
     *  </p>
     *
     *  <ul>
     *   <li>The '&#164;' symbol represents the location of the
     *       <code>currencyISOCode</code> or the <code>currencySymbol</code>
     *       in the currency string.</li>
     *   <li>The 'n' character represents the location of the
     *       <code>currencyISOCode</code> or the <code>currencySymbol</code>
     *       in the currency string.</li>
     *  </ul>
     *
     *    <table class="innertable" border="0">
     *        <tr>
     *            <td>Positive currency format type</td>
     *            <td>Formatting pattern</td>
     *        </tr>
     *        <tr>
     *            <td>0</td>
     *            <td>&#164;n</td>
     *        </tr>
     *        <tr>
     *            <td>1</td>
     *            <td>n&#164;</td>
     *        </tr>
     *        <tr>
     *            <td>2</td>
     *            <td>&#164; n</td>
     *        </tr>
     *        <tr>
     *            <td>3</td>
     *            <td>n &#164;</td>
     *        </tr>
     *    </table>
     *
     *  <p>The default value is dependent on the actual locale and
     *  operating system.</p>
     *
     *  @throws ArgumentError if the assigned value is not between 0 and 3.
     *
     *  @see #currencySymbol
     *  @see #format()
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get positiveCurrencyFormat():uint
    {
        return getBasicProperty(properties, POSITIVE_CURRENCY_FORMAT);
    }

    public function set positiveCurrencyFormat(value:uint):void
    {
        if (!g11nWorkingInstance)
        {
            if (4 < value)
                throw new TypeError();
        }

        setBasicProperty(properties, POSITIVE_CURRENCY_FORMAT, value);
    }

    //--------------------------------------------------------------------------
    //
    //  Properties: Errors
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  currencyStringError
    //----------------------------------

    private var _currencyStringError:String;
    private var currencyStringErrorOverride:String;

    [Inspectable(category="Errors", defaultValue="null")]
    [Bindable("change")]

    /**
     *  Error message when the currency symbol or currency ISO code is repeated
     *  or is in the incorrect location.
     *
     *  @default "Currency name is repeated or not correct."
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get currencyStringError():String
    {
        return _currencyStringError;
    }

    public function set currencyStringError(value:String):void
    {
        if (currencyStringErrorOverride &&
            (currencyStringErrorOverride == value))
            return;
            
        currencyStringErrorOverride = value;

        _currencyStringError = value ? value :
                 resourceManager.getString("validators", "currencyStringError");
        update();
    }

    //----------------------------------
    //  negativeCurrencyFormatError
    //----------------------------------

    private var _negativeCurrencyFormatError:String;
    private var negativeCurrencyFormatErrorOverride:String;

    [Inspectable(category="Errors", defaultValue="null")]
    [Bindable("change")]
    /**
     *  Error message when the negative number format of the input currency
     *  string is incorrect.
     *
     *  @default "The negative format of the input currency is incorrect."
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get negativeCurrencyFormatError():String
    {
        return _negativeCurrencyFormatError;
    }

    public function set negativeCurrencyFormatError(value:String):void
    {
        if (negativeCurrencyFormatErrorOverride &&
            (negativeCurrencyFormatErrorOverride == value))
            return;
        
        negativeCurrencyFormatErrorOverride = value;

        _negativeCurrencyFormatError = value ? value :
         resourceManager.getString("validators", "negativeCurrencyFormatError");
        update();
    }

    //----------------------------------
    //  positiveCurrencyFormatError
    //----------------------------------

    private var _positiveCurrencyFormatError:String;
    private var positiveCurrencyFormatErrorOverride:String;

    [Inspectable(category="Errors", defaultValue="null")]
    [Bindable("change")]
    /**
     *  Error message when the positive currency number format is incorrect.
     *
     *  @default "The positive format of the input currency is incorrect."
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get positiveCurrencyFormatError():String
    {
        return _positiveCurrencyFormatError;
    }

    /**
     *  @private
     */
    public function set positiveCurrencyFormatError(value:String):void
    {
        if (positiveCurrencyFormatErrorOverride &&
            (positiveCurrencyFormatErrorOverride == value))
            return;
        
        positiveCurrencyFormatErrorOverride = value;

        _positiveCurrencyFormatError = value ? value :
         resourceManager.getString("validators", "positiveCurrencyFormatError");
        update();
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Load the error messages from the resource bundle.
     */
    override protected function resourcesChanged():void
    {
        super.resourcesChanged();
        loadChangedResources();
        negativeCurrencyFormatError = negativeCurrencyFormatErrorOverride;
        positiveCurrencyFormatError = positiveCurrencyFormatErrorOverride;
        currencyStringError = currencyStringErrorOverride;
    }
    
    /**
     *  @private
     *  Override of the base class <code>doValidation()</code> method
     *  to validate currency amount.
     *
     *  <p>You do not call this method directly;
     *  Flex calls it as part of performing a validation.
     *  If you create a custom Validator class, you must implement this
     *  method. </p>
     *
     *  @param value Object to validate.
     *
     *  @return An Array of ValidationResult objects, with one ValidationResult
     *  object for each field examined by the validator.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override protected function doValidation(value:Object):Array
    {
        var results:Array = super.doValidation(value);
        
        // Return if there are errors
        // or if the required property is set to <code>false</code> and
        // length is 0.
        var val:String = value ? String(value) : "";
        if (results.length > 0 || ((val.length == 0) && !required))
            return results;
        else
            return validateCurrency(value, null);
    }

    /**
     *  Create internal formatter object and initialize all properties.
     */
    override mx_internal function createWorkingInstance():void
    {
        createWorkingInstanceCore(CURRENCY_VALIDATOR_TYPE);
        if (g11nWorkingInstance)
        {
            if (currencySymbolOverride)
                g11nWorkingInstance.currencySymbol = currencySymbolOverride
            
            if (currencyISOCodeOverride)
                g11nWorkingInstance.currencyISOCode = currencyISOCodeOverride;
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    [Bindable("change")]

    /**
     *  Convenience method for calling a validator
     *  from within a custom validation function.
     *  Each of the standard Flex validators has a similar convenience method.
     *  Caller must check the <code>ValidationResult</code> objects in the
     *  returned array for validation status.
     *
     *  @param value A currency number string to validate.The number string can 
     *  use unicode minus symbols 0x2212, 0xFE63, 0xFF0D besides ascii minus.
     *
     *  @param baseField Text representation of the subfield
     *  specified in the <code>value</code> parameter.
     *  For example, if the <code>value</code> parameter specifies value.number,
     *  the <code>baseField</code> value is "number".
     *
     *  @return An Array of <code>ValidationResult</code> objects, with
     *  one <code>ValidationResult</code> object for each field examined by
     *  the validator.
     *
     *  @see mx.validators.ValidationResult
     *
     *  @see flash.globalization.CurrencyFormatter
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function validateCurrency(value:Object,
                                     baseField:String):Array
    {
        var results:Array = [];

        const inputStr:String = String(value);

        // if the input can be a null/empty, return no error.
        if (!inputStr)
            return results;

        // If spark formatter is null, no-go-forward. If spark formatter locale
        // id is null or last operationstatus has locale undefined, then also
        // no forward going situaion.
        // The spark formatter createion has a situation where it's localeid is
        // null but LasyOperationStatus is not set. TestLocaleUndef.mxml 
        // testcase has this situation.
        if ((!g11nWorkingInstance) || (!g11nWorkingInstance.actualLocaleIDName) 
            || (g11nWorkingInstance.lastOperationStatus == 
                LastOperationStatus.LOCALE_UNDEFINED_ERROR))
        {
            results.push(new ValidationResult(
                true, baseField, "localeUndefinedError",
                localeUndefinedError));
            return results;
        }

        // g11nWorkingInstance for a locale is available.
        // strip leading and trailing white spaces.
        const input:String =
            GlobalizationUtils.trim(inputStr);

        const len:int = input.length;

        // NumberValidatorBase has this method. Unlike flash globalization,
        // validator gives error if decimal and grouping separator are same.
        if (!validateCurrencyFormat(input, baseField, results))
        {
            return results;
        }
        const cf:spark.formatters.CurrencyFormatter =
            g11nWorkingInstance as spark.formatters.CurrencyFormatter;
        const cpdata:CurrencyParseResult = cf.parse(input);

        // parse() only returns PARSE_ERROR if it finds any error in input
        // string. If there is a PARSE_ERROR, validate the input
        // string further, detect and report the error.
        if (cf.lastOperationStatus == LastOperationStatus.PARSE_ERROR)
        {
            if (detectAndReportProblem(input, cpdata, results,
                                       baseField) == false)
            {
                return results;
            }
            else
            {
                results.push(new ValidationResult(
                    true, baseField, "parseError",
                    parseError));
                return results;
            }
        }
        // See if negative number is allowed.
        if (!validateNumberNegativity(cpdata.value, baseField, results))
            return results;

        if (!validateCurrencyString(cpdata, baseField, results))
            return results;

        const numStart:int = indexOfFirstDigit(input, len);
        const decimalSeparatorIndex:int =
            input.indexOf(decimalSeparator, numStart);
        // check if fraction digits exceed the limit.
        if (!validateFractionPart(input,
            decimalSeparatorIndex, baseField, results))
        {
            return results;
        }

        // Make sure the input is within the specified range.
        // check the range of the number.
        if (!validateNumberRange(cpdata.value, baseField, results))
            return results;

        return results;
    }

    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    private function checkMultipleDecimals(input:String,
                                           results:Array,
                                           baseField:String):Boolean
    {
        if (!input)
            return true;
        const len:int = input.length;
        
        if (!len)
            return true;
        // Saudi currency symbol has decimal symbol. So to establish multiple
        // decimals problem, only number string must be considered.
        const isoIndex:int = input.indexOf(currencySymbol);
        var startIndex:int = 0;
        var endIndex:int = len;
        var numStr:String = input;
        if (isoIndex != -1)
        {
            var digitIndex:int = indexOfFirstDigit(input, len);
            if (digitIndex != -1)
            {
                if (digitIndex > isoIndex) // isocode is before digits.
                    startIndex = digitIndex;
                else
                    endIndex = isoIndex - 1; // isocode is after digit start
                                             // or in  middle
                if ((startIndex >= 0) && (endIndex <= len))
                    numStr = input.substring(startIndex, endIndex);
            }
        }
        var negPosLeft:Boolean = false;
        if ((negativeCurrencyFormat <= 2) ||
            (negativeCurrencyFormat == 4) ||
            (negativeCurrencyFormat == 5) ||
            (negativeCurrencyFormat == 8) ||
            (negativeCurrencyFormat == 9) ||
            (negativeCurrencyFormat == 12) ||
            (negativeCurrencyFormat == 14) ||
            (negativeCurrencyFormat == 15))
        {
            negPosLeft = true;
        }
        
        // Make sure there's only one decimal point.
        if ((decimalSeparator != negativeSymbol) && 
            (numStr.indexOf(decimalSeparator) !=
            numStr.lastIndexOf(decimalSeparator)))
        {
            results.push(new ValidationResult(
                         true, baseField, "decimalPointCount",
                         decimalPointCountError));
            return false;
        }
        else if (!validateDecimalString(numStr, baseField, results, negPosLeft))
        {
            return false;
        }
        return true;
    }

    /**
     * @private
     */
    private function detectAndReportProblem(input:String,
                                            cpdata:CurrencyParseResult,
                                            results:Array,
                                            baseField:String):Boolean
    {
        const len:int = input.length;
        const inputIsNegative:Boolean =
            ((inputHasNegativeSymbol(input)) ||
            ((input.charAt(0) == "(") && (input.charAt(len-1) == ")")));
        const inputHasCurrencyStr:Boolean =
            ((input.indexOf(currencySymbol) != -1) ||
             (input.indexOf(currencyISOCode) != -1));
        // Check for invalid characters in input.
        // One of the negative format of number is enclosing in parenthesis.
        const validChars:String = VALID_CHARS +
            decimalSeparator + groupingSeparator + currencySymbol +
            currencyISOCode;

        // check for invalid chracters in the input string
        if (validateInputCharacters(input, len, validChars))
        {
            results.push(new ValidationResult(
                true, baseField, "invalidChar",
                invalidCharError));
            return false;
        }
        else if (!checkMultipleDecimals(input, results, baseField))
        {
            return false;
        }
        // Find the currency symbol if it exists,
        // then make sure that it's in the right place
        // and that there is only one.
        else if (input.indexOf(currencySymbol) !=
                 input.lastIndexOf(currencySymbol))
        {
            results.push(new ValidationResult(
                true, baseField, "currencyString",
                currencyStringError));
            return false;
        }
        else if (input.indexOf(currencyISOCode) !=
                 input.lastIndexOf(currencyISOCode))
        {
            results.push(new ValidationResult(
                true, baseField, "currencyString",
                currencyStringError));
            return false;
        }
        else if (inputIsNegative)
        {
            results.push(new ValidationResult(
                true, baseField, "negativeCurrencyFormat",
                negativeCurrencyFormatError));
            return false;
        }
        // An input like "0 1 2 3" should be parseError rather than
        // postiveCurrencyFormatError.
        else if (!inputIsNegative && inputHasCurrencyStr)
        {
            results.push(new ValidationResult(
                true, baseField, "positiveCurrencyFormat",
                positiveCurrencyFormatError));
            return false;
        }
        return true;
    }

    /**
     *  @private
     *  Validate the properties of validator. Some properties cannnot be same
     *  as others.
     */
    private function validateCurrencyFormat(input:String, baseField:String,
                                            results:Array):Boolean
    {
        if (!validateNumberFormat(input, results, baseField))
            return false;

        if ((currencyISOCode == decimalSeparator) ||
            (currencyISOCode == groupingSeparator) ||
            (isNegativeSymbol(currencyISOCode)))
        {
            results.push(new ValidationResult(
                true, baseField, "invalidFormatCharsError",
                invalidFormatCharsError));
            return false;
        }

        if ((currencySymbol == decimalSeparator) ||
            (currencySymbol == groupingSeparator) ||
            (isNegativeSymbol(currencySymbol)))
        {
            results.push(new ValidationResult(
                true, baseField, "invalidFormatCharsError",
                invalidFormatCharsError));
            return false;
        }
        return true;
    }

    /**
     *  @private
     *  Validate currency string. It must match either currency symbol or
     *  ISO code. If it is null or empty, it is OK per existing mx:Validator
     *  behaviour.
     */
    private function validateCurrencyString(cpdata:CurrencyParseResult,
                                            baseField:String,
                                            results:Array):Boolean
    {
        if (!cpdata.currencyString)
            return true;

        // flash globalization parse() method, appends a 0x200F (RTL mark)
        // to the end of currencystring for RTL locales. However it appends
        // this mark even for isocode which has no RTL characters like in
        // parsing "SAR‏ 12345678.78-". To make sure that everything works,
        // strip RTL mark and compare.

        var sCurString:String = cpdata.currencyString;
        if (sCurString.charCodeAt(sCurString.length - 1) == 0x200F)
            sCurString = sCurString.substring(0,
                                     cpdata.currencyString.length - 1);

        var sCurSym:String = currencySymbol;
        if (sCurSym.charCodeAt(sCurSym.length - 1) == 0x200F)
            sCurSym = sCurSym.substring(0, currencySymbol.length - 1);

        var sCurIso:String = currencyISOCode;
        if (sCurIso.charCodeAt(sCurIso.length - 1) == 0x200F)
            sCurIso = sCurIso.substring(0, currencyISOCode.length - 1);

        if ((sCurIso == sCurString) || (sCurSym == sCurString))
        {
            return true;
        }
        else
        {
            results.push(new ValidationResult(
                true, baseField, "currencyString",
                this.currencyStringError));
            return false;
        }
    }
   }

}

