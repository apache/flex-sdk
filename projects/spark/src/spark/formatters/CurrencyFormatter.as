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

package spark.formatters
{

import flash.globalization.CurrencyFormatter;
import flash.globalization.CurrencyParseResult;
import flash.globalization.NationalDigitsType;

import mx.core.mx_internal;
import mx.formatters.IFormatter;

import spark.formatters.supportClasses.NumberBase;
import spark.globalization.LastOperationStatus;

use namespace mx_internal;

/**
 *  The CurrencyFormatter class provides locale-sensitive formatting
 *  and parsing of currency values. It can format currency amounts stored in
 *  <code>Number</code> objects.
 *
 *  <p>This class is a wrapper class around the
 *  <code>flash.globalization.CurrencyFormatter</code>. Therefore
 *  the locale-specific formatting
 *  is provided by the <code>flash.globalization.CurrencyFormatter</code>.
 *  However this CurrencyFormatter class can be used in mxml declartions,
 *  uses the locale style for the requested Locale ID name, and has
 *  methods and properties that are bindable.
 *  </p><p>
 *  The flash.globalization.CurrencyFormatter class uses the underlying
 *  operating system for the formatting functionality and
 *  to supply the locale specific data. On some operating systems,
 *  the flash.globalization classes are unsupported, this wrapper
 *  class provides a fallback functionality in this case.
 *  </p>
 *
 *  @see flash.globalization.CurrencyFormatter
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4.5
 */
public class CurrencyFormatter extends NumberBase implements IFormatter
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
    private static const CURRENCY_ISOCODE:String = "currencyISOCode";
    private static const CURRENCY_SYMBOL:String = "currencySymbol";
    private static const NEGATIVE_CURRENCY_FORMAT:String
                                                    = "negativeCurrencyFormat";
    private static const POSITIVE_CURRENCY_FORMAT:String
                                                    = "positiveCurrencyFormat";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructs a new CurrencyFormatter object to format numbers
     *  representing currency amounts according to
     *  the conventions of a given locale.
     *  <p>
     *  The locale for this class is supplied by the locale style. The
     *  locale style can be set in several ways:
     *  </p>
     *  <ul>
     *  <li>         *
     *  Inheriting the style from a UIComponent by calling the
     *  UIComponent's addStyleClient method.
     *  </li>
     *  <li>
     *  By using the class in an mxml declaration and inheriting the
     *  locale from the document that contains the declaration.
     *  </li>
     *  <listing version="3.0" >
     *  &lt;fx:Declarations&gt;
     *         &lt;s:StringTools id="st" /&gt;
     *  &lt;/fx:Declarations&gt;
     *  </listing>
     *  <li>
     *  By using an mxml declaration and specifying the locale value
     *  in the list of assignments.
     *  </li>
     *  <listing version="3.0" >
     *  &lt;fx:Declarations&gt;
     *      &lt;s:StringTools id="st_turkish" locale="tr-TR" /&gt;
     *  &lt;/fx:Declarations&gt;
     *  </listing>
     *  <li>
     *  Calling the setStyle method,
     *  e.g. <code>st.setStyle("locale", "tr-TR")</code>
     *  </li>
     *  </ul>
     *  <p>
     *  If the locale style is not set by one of the above techniques,
     *  the methods of this class that depend on the locale
     *  will throw an error.
     *  </p>         *
     *  <p>Certain properties such as the <code>currencySymbol</code>
     *  and <code>currencyISOCode</code> properties are set
     *  automatically based on the locale.</p>
     *
     *  <p><strong>NOTE: When a fallback locale is used the currency
     *  properties are set to default values,
     *  and therefore the <code>currencySymbol</code> or
     *  <code>currencyISOCode</code> properties might be given unexpected
     *  values. It is a good idea to examine the
     *  <code>currencySymbol</code> and <code>currencyISOCode</code>
     *  property values before formatting a currency amount.
     *  </strong></p>
     *
     *  @see actualLocaleIDName
     *
     *  @playerversion Flash 10.1
     *  @langversion 3.0
     *  @productversion Flex 4.5
     *  @productversion Flash CS5
     */
    public function CurrencyFormatter()
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private var currencySymbolOverride:String = null;

    /**
     *  @private
     */
    private var currencyISOCodeOverride:String = null;

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
     *  @inheritDoc
     *
     *  @see flash.globalization.CurrencyFormatter.actualLocaleIDName
     *  @see #CurrencyFormatter()
     *
     *  @playerversion Flash 10.1
     *  @langversion 3.0
     *  @productversion Flash CS5
     *  @productversion Flex 4.5
     */
    override public function get actualLocaleIDName():String
    {
        if (g11nWorkingInstance)
            return (g11nWorkingInstance
                as flash.globalization.CurrencyFormatter).actualLocaleIDName;

        if ((localeStyle === undefined) || (localeStyle === null))
        {
            fallbackLastOperationStatus
                                = LastOperationStatus.LOCALE_UNDEFINED_ERROR;
            return undefined;
        }

        fallbackLastOperationStatus = LastOperationStatus.NO_ERROR;

        return "en-US";
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  currencyISOCode
    //----------------------------------

    [Bindable("change")]

    /**
     *  The three letter ISO 4217 currency code for the actual locale
     *  being used.
     *
     *  <p>This code is used to determine the currency symbol or
     *  string when formatting currency amounts
     *  using the <code>format()</code> method with
     *  the <code>useCurrencySymbol</code> property set to
     *  <code>false</code>.</p>
     *
     *  <p>This property is initialized by the constructor
     *  based on the actual locale that is used. When a fallback
     *  locale is used this property reflects the preferred, default
     *  currency code for the fallback locale.</p>
     *
     *  @default dependent on the actual locale and operating system
     *
     *  @see #format()
     *  @see #currencySymbol
     *
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2
     *  @langversion 3.0
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
            g11nWorkingInstance.setCurrency(
                                    value, g11nWorkingInstance.currencySymbol);
        }
        else
        {
            if (!value)
                throw new TypeError();

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
     *  The currency symbol or string for the actual locale being used.
     *
     *  <p>This property is used as the currency symbol when formatting
     *  currency amounts using the <code>format()</code> method with
     *  the <code>withCurrencySymbol</code> parameter set to
     *  <code>true</code>.</p>
     *
     *  <p>This property is initialized by the constructor based on
     *  the actual locale that is used. When a fallback
     *  locale is used this property reflects the preferred, default
     *  currency symbol for the fallback locale.</p>
     *
     *  @default dependent on the actual locale and operating system
     *
     *  @see #format()
     *  @see #setCurrency()
     *  @see #formattingWithCurrencySymbolIsSafe
     *  @see #currencyISOCode
     *
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2
     *  @langversion 3.0
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
            g11nWorkingInstance.setCurrency(
                                g11nWorkingInstance.currencyISOCode, value);
        }
        else
        {
            if (!value)
                throw new TypeError();

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
     *   A numeric value that indicates a formatting pattern for negative
     *  currency amounts. This pattern defines the location of the
     *  currency symbol and the negative symbol or parentheses in
     *  relation to the numeric portion of the currency
     *  amount.
     *
     *   <p>The value of this property must be one of the constants
     *  defined in the table below.
     *  </p>
     *
     *  <p>The table below summarizes the possible formatting patterns
     *  for negative currency amounts. When a currency amount is formatted
     *  with the <code>format()</code> method:</p>
     *
     *  <ul>
     *   <li>The '&#164;' symbol is replaced with the value of the
     *       <code>currencyISOCode</code> or
     *       the <code>currencySymbol</code> property, depending on
     *       the value of the <code>withCurrencySymbol</code> parameter
     *       passed to the <code>format()</code> method;</li>
     *   <li>The '-' character is replaced with the value of the
     *       <code>negativeNumberSymbol</code> property;</li>
     *   <li>The 'n' character is replaced with the currency amount
     *       value that is passed to the <code>format()</code> method.</li>
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
     *  @default dependent on the actual locale and operating system
     *
     *  @throws ArgumentError if the assigned value is not between 0 and 15.
     *
     *  @see #format()
     *  @see #currencySymbol
     *  @see #negativeSymbol
     *
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2
     *  @langversion 3.0
     *  @productversion Flex 4.5
     */
    public function get negativeCurrencyFormat():int
    {
        return getBasicProperty(properties, NEGATIVE_CURRENCY_FORMAT);
    }

    public function set negativeCurrencyFormat(value:int):void
    {
        if (!g11nWorkingInstance)
        {
            if ((value < 0) || (15 < value))
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
     *    A numeric value that indicates a formatting pattern for positive
     *  currency amounts. This format defines the location of currency symbol
     *  relative to the numeric portion of the currency amount.
     *
     *   <p>The value of this property must be one of the constants
     *  defined in the table below.
     *  </p>
     *
     *  <p>The table below summarizes the possible formatting patterns
     *  for positive currency amounts.
     *  When a currency amount is formatted with the <code>format()</code>
     *  method:</p>
     *
     *  <ul>
     *   <li>The '&#164;' symbol is replaced with the value of the
     *       <code>currencyISOCode</code> or
     *       the <code>currencySymbol</code> property, depending on the
     *       value of the <code>withCurrencySymbol</code> parameter
     *       passed to the <code>format()</code> method;</li>
     *   <li>The 'n' character is replaced with the currency amount value
     *       that is passed to the <code>format()</code> method.</li>
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
     *  @throws ArgumentError if the assigned value is not between 0 and 3.
     *
     *  @default dependent on the actual locale and operating system
     *
     *  @see #currencySymbol
     *  @see #format()
     *
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2
     *  @langversion 3.0
     *  @productversion Flex 4.5
     */
    public function get positiveCurrencyFormat():int
    {
        return getBasicProperty(properties, POSITIVE_CURRENCY_FORMAT);
    }

    public function set positiveCurrencyFormat(value:int):void
    {
        if (!g11nWorkingInstance)
        {
            if ((value < 0) || (4 < value))
                throw new TypeError();
        }

        setBasicProperty(properties, POSITIVE_CURRENCY_FORMAT, value);
    }

    //----------------------------------
    //  useCurrencySymbol
    //----------------------------------

    /**
     *  @private
     */
    private var _useCurrencySymbol:Boolean = false;

    [Bindable("change")]

    /**
     *  Enables the use of the currencySymbol when formatting
     *  currency amounts.
     *
     *  <p>When the <code>withCurrencySymbol</code> property is
     *  set to <code>true</code>, the value of the
     *  <code>currencySymbol</code> property is used
     *  in the string returned by the format method.
     *  For example: <code>$ 123,456,789.22</code></p>
     *
     *  <p>When the <code>withCurrencySymbol</code> property is set to
     *  <code>false</code>, the value of the <code>currencyISOCode</code>
     *  property is used in the string returned by the format method.
     *  For example: <code>USD 123456789.22</code></p>
     *
     *  @default false
     *
     *  @see #formattingWithCurrencySymbolIsSafe
     *  @see #format
     *
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2
     *  @langversion 3.0
     *  @productversion Flex 4.5
     */
    public function get useCurrencySymbol():Boolean
    {
        return _useCurrencySymbol;
    }

    public function set useCurrencySymbol(value:Boolean):void
    {
        if (_useCurrencySymbol == value)
            return;

        _useCurrencySymbol = value;

        update();
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override mx_internal function createWorkingInstance():void
    {
        if ((localeStyle === undefined) || (localeStyle === null))
        {
            fallbackLastOperationStatus
                                = LastOperationStatus.LOCALE_UNDEFINED_ERROR;
            g11nWorkingInstance = null;
            properties = null;
            return;
        }

        if (enforceFallback)
        {
            fallbackInstantiate();
            g11nWorkingInstance = null;
            return;
        }

        g11nWorkingInstance
                    = new flash.globalization.CurrencyFormatter(localeStyle);
        if (g11nWorkingInstance &&
            (g11nWorkingInstance.lastOperationStatus
                                    != LastOperationStatus.UNSUPPORTED_ERROR))
        {
            properties = g11nWorkingInstance;
            propagateBasicProperties(g11nWorkingInstance);

            if (currencySymbolOverride)
            {
                g11nWorkingInstance.setCurrency(
                    g11nWorkingInstance.currencyISOCode,
                    currencySymbolOverride);
            }

            if (currencyISOCodeOverride)
            {
                g11nWorkingInstance.setCurrency(
                    currencyISOCodeOverride,
                    g11nWorkingInstance.currencySymbol);
            }

            return;
        }

        fallbackInstantiate();
        g11nWorkingInstance = null;

        if (fallbackLastOperationStatus == LastOperationStatus.NO_ERROR)
        {
            fallbackLastOperationStatus
                                = LastOperationStatus.USING_FALLBACK_WARNING;
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    [Bindable("change")]

    /**
     *  Creates a string representing a currency amount formatted
     *  according to the current properties of this CurrencyFormatter object,
     *  including the locale, currency symbol, and currency ISO code,
     *  useCurrencySymbol
     *
     *  <p>By default this method uses the <code>currencyISOCode</code>
     *  property to determine the currency symbol and other
     *  settings used when formatting.</p>
     *
     *  <p>Many countries and regions use the same currency symbols for
     *  different currencies.
     *  For example the United States, Australia, New Zealand, Canada,
     *  and Mexico all use the same dollar sign symbol ($) for local
     *  currency values. When the formatting currency differs
     *  from the user's local currency it is best to use the ISO code as
     *  the currency string.
     *  You can use the <code>formattingWithCurrencySymbolIsSafe()</code>
     *  method to test whether the ISO code of the
     *  currency to be formatted matches the <code>currencyISOCode</code>
     *  property of the formatter.
     *  </p>
     *
     *  <p>This method can format numbers of very large and very small
     *  magnitudes. However the number of significant digits is
     *  limited to the precision provided by the Number data type.
     *  </p>
     *
     *  @param value The numeric value to be formatted into a currency string.
     *  @param withCurrencySymbol When set to false the
     *  <code>currencyISOCode</code> property determines which
     *  currency string or symbol to use in the output string. When
     *  set to true, the current value of the
     *  <code>currencySymbol</code> property is used in the output string.
     *
     *  @example  In this example the requested locale is
     *  fr-CA French (Canada). The example assumes that this locale
     *  is supported in the user's operating system and therefore
     *  no fallback locale is used.
     *  For fr-CA the default currency is Canadian dollars with an
     *  ISO code of CAD. Therefore when formatting a currency
     *  with the default values, CAD is used as the currency symbol. When
     *  the <code>withCurrencySymbol</code> parameter is set to
     *  true the <code>currencySymbol</code>
     *  property is used to format the currency amount.
     *
     *  <listing version="3.0" >
     *  var cf:CurrencyFormatter = new CurrencyFormatter("fr-CA");
     *
     *  trace(cf.actualLocaleIDName);               // "fr-CA"
     *  trace(cf.currencyISOCode);                // "CAD"
     *  trace(cf.currencySymbol);                // "$"
     *
     *  trace(cf.format(1254.56));                // "1 254,56 CAD"
     *  trace(cf.format(1254.56, true));            // "1 254,56 $"
     *  </listing>
     *
     *  <p>The second example shows a method of formatting a currency
     *  amount in Canadian dollars using the default user's locale.
     *  The <code>formattingWithCurrencySymbolIsSafe()</code> method
     *  is used to test to see if the user's default currency is
     *  Canadian dollars and if so then the format method is used with
     *  the <code>withCurrencySymbol</code> parameter set to true.
     *  Otherwise the currency is set to Canadian dollars with
     *  a more descriptive currency symbol. The example shows how
     *  the currency would be formatted if the default locale was either
     *  French (Canada) or English (USA). </p>
     *
     *  <listing version="3.0" >
     *  var cf:CurrencyFormatter = new CurrencyFormatter(LocaleID.DEFAULT);
     *
     *  if (cf.formattingWithCurrencySymbolIsSafe("CAD")) {
     *   trace(cf.actualLocaleIDName);     // "fr-CA French (Canada)"
     *   trace(cf.format(1254.56, false)); // "1 254,56 $"
     *  }
     *  else {
     *   trace(cf.actualLocaleIDName);     // "en-US English (USA)"
     *   cf.setCurrency("CAD", "C$")
     *   trace(cf.format(1254.56, true));  // "C$ 1,254.56"
     *  }
     *  </listing>
     *
     *  @return A string containing the formatted currency value.
     *
     *  @see #currencySymbol
     *  @see #currencyISOCode
     *  @see #formattingWithCurrencySymbolIsSafe()
     *  @see #lastOperationStatus
     *  @see LastOperationStatus
     *
     *  @playerversion Flash 10.1
     *  @langversion 3.0
     *  @productversion Flex 4.5
     *  @productversion Flash CS5
     */
    public function format(value:Object):String
    {
        if (value == null)
            return null;

        const number:Number = Number(value);

        if (isNaN(number))
        {
            if (g11nWorkingInstance)
            {
                // Have g11nFormatter.lastOperationStatus property hold
                // ILLEGAL_ARGUMENT_ERROR value.
                (g11nWorkingInstance as
                    flash.globalization.CurrencyFormatter).fractionalDigits
                                                                        = -1;
            }
            else
            {
                fallbackLastOperationStatus
                                = LastOperationStatus.ILLEGAL_ARGUMENT_ERROR;
            }
            return errorText;
        }

        if (g11nWorkingInstance)
        {
            const g11nFormatter:flash.globalization.CurrencyFormatter =
                (g11nWorkingInstance as flash.globalization.CurrencyFormatter);

            const retVal:String = g11nFormatter.format(
                                                    number, useCurrencySymbol);

            return errorText && LastOperationStatus.isFatalError(
                        g11nFormatter.lastOperationStatus) ? errorText : retVal;
        }

        if ((localeStyle === undefined) || (localeStyle === null))
        {
            fallbackLastOperationStatus
                                = LastOperationStatus.LOCALE_UNDEFINED_ERROR;
            return errorText;
        }

        fallbackLastOperationStatus = LastOperationStatus.NO_ERROR;

        return (useCurrencySymbol ? currencySymbol : currencyISOCode)
                                + number.toFixed(properties.fractionalDigits);
    }

    [Bindable("change")]

    /**
     *  Determines whether the currently specified currency symbol can
     *  be used when formatting currency amounts.
     *
     *  <p>Many regions and countries use the same currency symbols.
     *  This method can be used to
     *  safeguard against the use of an ambiguous currency symbol, or
     *  a currency symbol or ISO code that
     *  is different than expected due to the use of a fallback locale.</p>
     *
     *  <p>A common use case for this method is to determine whether
     *  to show a local currency symbol (if the amount is formatted in
     *  the user's default currency), or a more specific ISO code
     *  string (if the amount is formatted in a currency
     *  different from the user's default).</p>
     *
     *  <p>This method compares the <code>requestedISOCode</code>
     *  parameter against the current <code>currencyISOCode</code> property,
     *  returning <code>true</code> if the strings are
     *  equal and <code>false</code> if they are not.
     *  When the strings are equal, using the <code>format()</code>
     *  method with the
     *  <code>useCurrencySymbol</code> property set to <code>true</code>
     *  results in a formatted currency value string
     *  with a unique currency symbol for the locale.
     *  If this method returns false, then using the <code>format()</code>
     *  method with the <code>useCurrencySymbol</code>
     *  property set to true could result in the use of an ambiguous
     *  or incorrect currency symbol.
     *  </p>
     *
     *  @param requestedISOCode A three letter ISO 4217 currency code
     *  (for example, USD for US dollars, EUR for Euros).
     *  Must contain three uppercase letters from A to Z.
     *
     *  @throws TypeError if the <code>requestedISOCode</code> parameter
     *  is null.
     *
     *  @return <code>true</code> if the <code>currencyISOCode</code>
     *  property matches the <code>requestedISOCode</code> parameter;
     *  otherwise <code>false</code>.
     *
     *  @see #currencySymbol
     *  @see #currencyISOCode
     *  @see #useCurrencySymbol
     *
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2
     *  @langversion 3.0
     *  @productversion Flex 4.5
     */
    public function formattingWithCurrencySymbolIsSafe(
                                                requestedISOCode:String):Boolean
    {
        if (g11nWorkingInstance)
        {
            return g11nWorkingInstance.formattingWithCurrencySymbolIsSafe(
                                                            requestedISOCode);
        }

        if ((localeStyle === undefined) || (localeStyle === null))
        {
            fallbackLastOperationStatus
                                = LastOperationStatus.LOCALE_UNDEFINED_ERROR;
            return undefined;
        }

        fallbackLastOperationStatus = LastOperationStatus.NO_ERROR;

        return requestedISOCode == currencyISOCode;
    }

    [Bindable("change")]

    /**
     *  Parses a string into a currency amount and a currency symbol.
     *
     *  <p>The parsing algorithm uses the value of the
     *  <code>decimalSeparator</code> property to determine the
     *  integral and fractional portion of the number. It uses the
     *  values of the <code>negativeCurrencyFormat</code> and
     *  <code>positiveCurrencyFormat</code> properties to determine
     *  the location of the currency symbol or string relative to the
     *  currency amount.For negative amounts the value of the
     *  <code>negativeCurrencyFormat</code> property determines the
     *  location of the negative symbol and whether parentheses are used.</p>
     *
     *  <p>If the order of the currency symbol, minus sign, and number in
     *  the input string does not match the pattern identified by the
     *  <code>negativeCurrencyFormat</code> and
     *  <code>positiveCurrencyFormat</code> properties, then:</p>
     *
     *  <ol>
     *   <li>The <code>value</code> property of the returned
     *       CurrencyParseResult object is set to <code>NaN</code>.</li>
     *   <li>The <code>currencyString</code> property of the returned
     *       CurrencyParseResult object is set to <code>null</code>.</li>
     *   <li>The <code>lastOperationStatus</code> property is set to
     *       indicate that parsing failed.</li>
     *  </ol>
     *
     *  <p>The input string may include space characters, which are
     *  ignored during the parsing.</p>
     *
     *  <p>Parsing can succeed even if there is no currency symbol.
     *  No validation is done of the portion of the string
     *  corresponding to the currency symbol. If there is no currency
     *  symbol or string, the <code>currencyString</code> property
     *  in the returned CurrencyParseResult object is set to an
     *  empty string.</p>
     *
     *
     *  @param inputString The input string to parse.
     *
     *  @return A CurrencyParseResult object containing the numeric
     *  value and the currency symbol or string.
     *
     *  @throws TypeError if the <code>inputString</code> parameter is null.
     *
     *  @see #decimalSeparator
     *  @see #negativeCurrencyFormat
     *  @see #positiveCurrencyFormat
     *  @see flash.globalization.CurrencyParseResult
     *
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2
     *  @langversion 3.0
     *  @productversion Flex 4.5
     */
    public  function parse(inputString:String):CurrencyParseResult
    {
        if (g11nWorkingInstance)
            return g11nWorkingInstance.parse(inputString);

        if ((localeStyle === undefined) || (localeStyle === null))
        {
            fallbackLastOperationStatus
                                = LastOperationStatus.LOCALE_UNDEFINED_ERROR;
            return undefined;
        }

        fallbackLastOperationStatus = LastOperationStatus.NO_ERROR;

        // TODO Implement some kind of simple parsing.
        return fallbackParseCurrency(inputString);
    }

    /**
     *  @copy spark.utils.Collator#getAvailableLocaleIDNames
     *
     *  @playerversion Flash 10.1
     *  @langversion 3.0
     *  @productversion Flash CS5
     *  @productversion Flex 4.5
     */
    static public function getAvailableLocaleIDNames():Vector.<String>
    {
        const locales:Vector.<String>
            = flash.globalization.CurrencyFormatter.getAvailableLocaleIDNames();

        return locales ? locales : new Vector.<String>["en-US"];
    }

    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------

    private function fallbackParseCurrency(parseString:String)
                                                            :CurrencyParseResult
    {
        return parseToCurrencyParseResult(parseString);
    }

    private function fallbackInstantiate():void
    {
        properties =
            {
                fractionalDigits: 0,
                useGrouping: false,
                groupingPattern: "3",
                digitsType: NationalDigitsType.EUROPEAN,
                decimalSeparator: ".",
                groupingSeparator: ",",
                negativeSymbol: "-",
                negativeCurrencyFormat: 0, // eg. ($123.45)
                positiveCurrencyFormat: 0, // eg. $123.45
                leadingZero: true,
                trailingZeros: false,
                currencyISOCode: "USD",
                currencySymbol: "$"
            };

        if (currencySymbolOverride)
            properties.currencySymbol = currencySymbolOverride;

        if (currencyISOCodeOverride)
            properties.currencyISOCode = currencyISOCodeOverride;

        propagateBasicProperties(properties);

        fallbackLastOperationStatus = LastOperationStatus.NO_ERROR;
    }
}
}
