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

package org.apache.flex.validators
{

import flash.globalization.Collator;
import flash.globalization.LocaleID;
import flash.globalization.StringTools;

import mx.resources.IResourceManager;
import mx.resources.ResourceManager;
import mx.validators.Validator;
import mx.validators.ValidationResult;

[ResourceBundle("apache")]

/**
 *  The PostCodeValidator class validates that a String
 *  has the correct length and format for a post code.
 *
 *  <p>Postcode formats consists of the letters C, N, A and spaces or hyphens
 *  <ul>
 *  <li>CC or C is the country code (required for some postcodes).</li>
 *	<li>N is a number 0-9.</li>
 *  <li>A is a letter A-Z or a-z.</li>
 *  </ul></p>
 *
 *  <p>Country codes one be one or two digits.</p>
 *
 *  <p>For example "NNNN" is a four digit numeric postcode, "CCNNNN" is country code
 *  followed by four digits and "AA NNNN" is two letters, followed by a space then
 *  followed by four digits.</p>
 *
 *  <p>More than one format can be specified by setting the <code>formats</code>
 *  property to an array of format Strings.</p>
 *
 *  <p>The validator can suggest postcode formats for small set of know locales by calling the
 *  <code>suggestFormat</code> method.</p>
 *
 *  <p>Postcodes can be further validated by setting the <code>extraValidation</code>
 *  property to a user defined method that performs further checking on the postcode
 *  digits.</p>
 *
 *  <p>Fullwidth numbers and letters are supported in postcodes by ignoring character
 *  width via the <code>flash.globalization.Collator</code> <code>equals</code> method.</p>
 *
 *  @mxml
 *
 *  <p>The <code>&lt;mx:PostCodeValidator&gt;</code> tag
 *  inherits all of the tag attributes of its superclass,
 *  and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;mx:PostCodeValidator
 *    countryCode="CC"
 *    format="NNNNN"
 *    formats="['NNNNN', 'NNNNN-NNNN']"
 *    wrongFromatError="The postcode code must be correctly formatted."
 *    invalidFormatError="The postcode format string is incorrect."
 *    invalidCharError="The postcode contains invalid characters."
 *    wrongLengthError="The postcode is the wrong length."
 *  /&gt;
 *  </pre>
 *
 *  @see org.apache.flex.formatters.PostCodeFormatter
 *
 *  @langversion 3.0
 *  @playerversion Flash 10.2
 *  @productversion ApacheFlex 4.8
 */
public class PostCodeValidator extends Validator
{
    include "../../../../core/Version.as";

	/**
	 * Name of the bundle file error resource strings can be found.
	 * Also defined in matadata tag [ResourceBundle("validators")]
	 */
	private static const BUNDLENAME:String = "validators";
	
    /**
     * Value <code>errorCode</code> of a ValidationResult is set to when
     * the postcode contains an invalid charater.
     */
    public static const ERROR_INVALID_CHAR:String = "invalidChar";

    /**
     * Value <code>errorCode</code> of a ValidationResult is set to when
     * the postcode is of the wrong length.
     */
    public static const ERROR_WRONG_LENGTH:String = "wrongLength";

    /**
     * Value <code>errorCode</code> of a ValidationResult is set to when
     * the postcode is of the wrong format.
     */
    public static const ERROR_WRONG_FORMAT:String = "wrongFormat";

    /**
     * Value <code>errorCode</code> of a ValidationResult is set to when
     * the format contains unknown format characters.
     */
    public static const ERROR_INCORRECT_FORMAT:String = "incorrectFormat";

    /**
     * Symbol used in postcode formats representing a single digit.
     */
    public static const FORMAT_NUMBER:String = "N";

    /**
     * Symbol used in postcode formats representing a single character.
     */
    public static const FORMAT_LETTER:String = "A";

    /**
     * Symbol used in postcode formats representing a letter of a country
     * code.
     */
    public static const FORMAT_COUNTRY_CODE:String = "C";

    /**
     * Valid spacer character in postcode formats.
     */
    public static const FORMAT_SPACERS:String = " -";

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Simulate String.indexOf but ignore wide characters.
     *  TODO move to StringValidator or Collator?
     *
     *  @return Index of char in string or -1 if char not in string.
     *
     */
    protected function indexOf(string:String, char:String):int
    {
        var length:int = string.length;
        var collate:Collator = new Collator(LocaleID.DEFAULT);

        collate.ignoreCharacterWidth = true;

        for (var i:int = 0; i < length; i++)
		{
            if (collate.equals(string.charAt(i), char))
                return i;
		}

        return -1;
    }

    /**
     *  @private
     *  Compares if two characters are equal ignoring wide characters.
     *  TODO move to StringValidator or Collator?
     *
     *  @return True is charA is the same as charB, false if they are not.
     *
     */
    protected function equals(charA:String, charB:String):Boolean
    {
        var collate:Collator = new Collator(LocaleID.DEFAULT);

        collate.ignoreCharacterWidth = true;

        return collate.equals(charA, charB);
    }

    /**
     *  @private
     *
     *  @param char to check
     *  @return True if the char is not a valid format character.
     *
     */
    protected function notFormatChar(char:String):Boolean
    {
        return indexOf(FORMAT_SPACERS, char) == -1 && char != FORMAT_NUMBER &&
            char != FORMAT_LETTER && char != FORMAT_COUNTRY_CODE;
    }

    /**
     *  @private
     *
     *  @param char to check
     *  @return True if the char is not a valid digit.
     *
     */
    protected function noDecimalDigits(char:String):Boolean
    {
        return indexOf(DECIMAL_DIGITS, char) == -1;
    }

    /**
     *  @private
     *
     *  @param char to check
     *  @return True if the char is not a valid letter.
     *
     */
    protected function noRomanLetters(char:String):Boolean
    {
        return indexOf(ROMAN_LETTERS, char) == -1;
    }

    /**
     *  @private
     *
     *  @param char to check
     *  @return True if the char is not a valid spacer.
     *
     */
    protected function noSpacers(char:String):Boolean
    {
        return indexOf(FORMAT_SPACERS, char) == -1;
    }

    /**
     *  @private
     *
     *  A wrong format ValidationResult is added to the results array
     *  if the extraValidation user supplied function returns an error.
     *  An error is added when there is a user defined issue with the
     *  supplied postCode.
     *
     */
    protected function userValidationResults(validator:PostCodeValidator, baseField:String,
                                             postCode:String, results:Array):void
    {
        if (validator && validator.extraValidation != null)
        {
            var extraError:String = validator.extraValidation(postCode);

            if (extraError)
                results.push(new ValidationResult(true, baseField, ERROR_WRONG_FORMAT, extraError));
        }
    }

    /**
     *  @private
     *
     *  Based on flags in the error object new ValidationResults are
     *  added the the results array.
     *
     *  Note that the only first ValidationResult is typically shown
     *  to the user in validation errors.
     *
     */
    protected function errorValidationResults(validator:PostCodeValidator, baseField:String,
                                              error:Object, results:Array):void
    {
        if (error)
        {
            if (error.incorrectFormat)
                results.push(new ValidationResult(true, baseField, ERROR_INCORRECT_FORMAT,
                                                  validator.incorrectFormatError));
            if (error.invalidChar)
                results.push(new ValidationResult(true, baseField, ERROR_INVALID_CHAR,
                                                  validator.invalidCharError));

            if (error.wrongLength)
                results.push(new ValidationResult(true, baseField, ERROR_WRONG_LENGTH,
                                                  validator.wrongLengthError));

            if (error.invalidFormat)
                results.push(new ValidationResult(true, baseField, ERROR_WRONG_FORMAT,
                                                  validator.wrongFormatError));
        }
    }

    /**
     *  @private
     *
     *  Check thats a postCode is valid and matches a certain format.
     *
     *  @return An error object containing flags for each type of error
     *  and an indication of invalidness (used later to sort errors).
     *
     */
    protected function checkPostCodeFormat(postCode:String, format:String,
                                           countryCode:String):Object
    {
        var invalidChar:Boolean;
        var invalidFormat:Boolean;
        var wrongLength:Boolean;
        var incorrectFormat:Boolean;
        var formatLength:int;
        var postCodeLength:int;
        var noChars:int;
        var countryIndex:int;

        if (format)
            formatLength = format.length;

        if (formatLength == 0)
            incorrectFormat = true;

        if (postCode)
            postCodeLength = postCode.length;

        noChars = Math.min(formatLength, postCodeLength);

        for (var postcodeIndex:int = 0; postcodeIndex < noChars; postcodeIndex++)
        {
            var char:String = postCode.charAt(postcodeIndex);
            var formatChar:String = format.charAt(postcodeIndex);

            if (postcodeIndex < postCodeLength)
                char = postCode.charAt(postcodeIndex);

            if (notFormatChar(formatChar))
                incorrectFormat = true;

            if (noDecimalDigits(char) && noRomanLetters(char) && noSpacers(char))
            {
                if (!countryCode || indexOf(countryCode, char) == -1)
                    invalidChar = true;
            }
            else if (formatChar == FORMAT_NUMBER && noDecimalDigits(char))
            {
                invalidFormat = true;
            }
            else if (formatChar == FORMAT_LETTER && noRomanLetters(char))
            {
                invalidFormat = true;
            }
            else if (formatChar == FORMAT_COUNTRY_CODE)
            {
                if (countryIndex >= 2 || !countryCode ||
                    !equals(char, countryCode.charAt(countryIndex)))
                    invalidFormat = true;
                countryIndex++;
            }
            else if (indexOf(FORMAT_SPACERS, formatChar) >= 0 && !equals(formatChar, char))
            {
                invalidFormat = true;
            }
        }

        wrongLength = (postCodeLength != formatLength);

        // We want invalid char and invalid format errors to show in preference
        // so give wrong length errors a higher value
        if (incorrectFormat || invalidFormat || invalidChar || wrongLength)
            return { invalidFormat: invalidFormat, incorrectFormat: incorrectFormat,
                     invalidChar: invalidChar, wrongLength: wrongLength,
                     invalidness: Number(invalidFormat) + Number(invalidChar) +
                        Number(incorrectFormat) + Number(wrongLength) * 1.5 };
        else
            return null;
    }

    /**
     *  Convenience method for calling a validator.
     *  Each of the standard Flex validators has a similar convenience method.
     *
     *  @param validator The PostCodeValidator instance.
     *
     *  @param value A field to validate.
     *
     *  @param baseField Text representation of the subfield
     *  specified in the <code>value</code> parameter.
     *  For example, if the <code>value</code> parameter specifies value.postCode,
     *  the <code>baseField</code> value is <code>"postCode"</code>.
     *
     *  @return An Array of ValidationResult objects, with one ValidationResult
     *  object for each field examined by the validator.
     *
     *  @see mx.validators.ValidationResult
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @productversion ApacheFlex 4.8
     */
    public static function validatePostCode(validator:PostCodeValidator, postCode:String,
                                            baseField:String):Array
    {
        var numberFormats:int;
        var errors:Array = [];
        var results:Array = [];

        if (!validator)
            return [];

        numberFormats = validator.formats.length;

        for (var formatIndex:int = 0; formatIndex < numberFormats; formatIndex++)
        {
            var error:Object =
                validator.checkPostCodeFormat(postCode, validator.formats[formatIndex],
                                              validator.countryCode);

            if (error)
            {
                errors.push(error);
            }
            else
            {
                errors = [];
                break;
            }
        }

        // return result with least number of errors
        errors.sortOn("invalidness", Array.NUMERIC);

        validator.userValidationResults(validator, baseField, postCode, results);

        // TODO return/remember closest format or place in results?
        validator.errorValidationResults(validator, baseField, errors[0], results);

        return results;
    }

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @productversion ApacheFlex 4.8
     */
    public function PostCodeValidator()
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  The two letter country code used in some postcode formats
     */
    private var _countryCode:String;

    /**
     *  @private
     *  An array of the postcode formats to check against.
     */
    private var _formats:Array = [];

    /**
     *  Valid postcode format that postcodes will be compaired against.
     *
     *  <p>The format string consists of the letters C, N, A and spaces
     *  or hyphens:
     *  <ul>
     *  <li>CC or C is country code (required for some postcodes).</li>
     *	<li>N is a number 0-9.</li>
     *  <li>A is a letter A-Z or a-z.</li>
     *  </ul></p>
     *
     *  @default null
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @productversion ApacheFlex 4.8
     */
    public function get format():String
    {
        if (_formats && _formats.length == 1)
            return _formats[0];

        return null;
    }

    /**
     *  @private
     */
    public function set format(value:String):void
    {
        if (value != null)
            _formats = [ value ];
        else
            _formats = [];
    }

    /**
     *  Optional 1 or 2 letter country code in postcode format
     *
     *  @default null
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @productversion ApacheFlex 4.8
     */
    public function get countryCode():String
    {
        return _countryCode;
    }

    /**
     *  @private
     */
    public function set countryCode(value:String):void
    {
        // Length is usually 2 character but can use 〒 in Japan
        if (value == null || value && value.length <= 2)
            _countryCode = value;
    }

    /**
     *  An array of valid format strings to compare postcodes against.
     *
     *  <p>Use for locales where more than one format is required.
     *  eg en_UK</p>
     *
     *  <p>See <code>format</code> for format of the format
     *  strings.</p>
     *
     *  @default []
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @productversion ApacheFlex 4.8
     */
    public function get formats():Array
    {
        return _formats;
    }

    /**
     *  @private
     */
    public function set formats(value:Array):void
    {
        _formats = value;
    }

    /**
     *  A user supplied method that performs further validation on a postcode.
     *
     *  <p>The user supplied method should have the following signature:
     *  <code>function validatePostcode(postcode:String):String</code></p>
     *
     *  <p>The method is passed the postcode to be validated and should
     *  return either:
     *  <ol>
     *  <li>A null string indicating the postcode is valid.</li>
     *  <li>A non empty string describing why the postcode is invalid.</li>
     *  </ol></p>
     *
     *  <p>The error string will be converted into a ValidationResult when
     *  doValidation is called by Flex as part of the normal validation
     *  process.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @productversion ApacheFlex 4.8
     */
    public var extraValidation:Function;

    //--------------------------------------------------------------------------
    //
    //  Properties: Errors
    //
    //--------------------------------------------------------------------------

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
    private var invalidCharErrorOverride:String;

    [Inspectable(category = "Errors", defaultValue = "null")]

    /**
     *  Error message when the post code contains invalid characters.
     *
     *  @default "The postcode code contains invalid characters."
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @productversion ApacheFlex 4.8
     */
    public function get invalidCharError():String
    {
        if (invalidCharErrorOverride)
            return invalidCharErrorOverride;

        return _invalidCharError;
    }

    /**
     *  @private
     */
    public function set invalidCharError(value:String):void
    {
        invalidCharErrorOverride = value;

        if (!value)
            _invalidCharError = resourceManager.getString(BUNDLENAME, "invalidCharPostcodeError");
    }


    //----------------------------------
    //  wrongLengthError
    //----------------------------------

    /**
     *  @private
     *  Storage for the wrongLengthError property.
     */
    private var _wrongLengthError:String;

    /**
     *  @private
     */
    private var wrongLengthErrorOverride:String;

    [Inspectable(category = "Errors", defaultValue = "null")]

    /**
     *  Error message for an invalid postcode.
     *
     *  @default "The postcode is invalid."
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @productversion ApacheFlex 4.8
     */
    public function get wrongLengthError():String
    {
        if (wrongLengthErrorOverride)
            return wrongLengthErrorOverride;

        return _wrongLengthError;
    }

    /**
     *  @private
     */
    public function set wrongLengthError(value:String):void
    {
        wrongLengthErrorOverride = value;

        if (!value)
            _wrongLengthError = resourceManager.getString(BUNDLENAME, "wrongLengthPostcodeError");
    }

    //----------------------------------
    //  wrongFormatError
    //----------------------------------

    /**
     *  @private
     *  Storage for the wrongFormatError property.
     */
    private var _wrongFormatError:String;

    /**
     *  @private
     */
    private var wrongFormatErrorOverride:String;

    [Inspectable(category = "Errors", defaultValue = "null")]

    /**
     *  Error message for an incorrectly formatted postcode.
     *
     *  @default "The postcode code must be correctly formatted."
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @productversion ApacheFlex 4.8
     */
    public function get wrongFormatError():String
    {
        if (wrongFormatErrorOverride)
            return wrongFormatErrorOverride;

        return _wrongFormatError;
    }

    /**
     *  @private
     */
    public function set wrongFormatError(value:String):void
    {
        wrongFormatErrorOverride = value;

        if (!value)
            _wrongFormatError = resourceManager.getString(BUNDLENAME, "wrongFormatPostcodeError");
    }

    //----------------------------------
    //  incorrectFormatError
    //----------------------------------

    /**
     *  @private
     *  Storage for the incorrectFormatError property.
     */
    private var _incorrectFormatError:String;

    /**
     *  @private
     */
    private var incorrectFormatErrorOverride:String;

    [Inspectable(category = "Errors", defaultValue = "null")]

    /**
     *  Error message for an incorrect format string.
     *
     *  @default "The postcode format string is incorrect"
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @productversion ApacheFlex 4.8
     */
    public function get incorrectFormatError():String
    {
        if (incorrectFormatErrorOverride)
            return incorrectFormatErrorOverride;

        return _incorrectFormatError;
    }

    /**
     *  @private
     */
    public function set incorrectFormatError(value:String):void
    {
        incorrectFormatErrorOverride = value;

        if (!value)
            _incorrectFormatError =
                resourceManager.getString(BUNDLENAME, "incorrectFormatPostcodeError");
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Changes error strings when the locale changes.
     */
    override protected function resourcesChanged():void
    {
        super.resourcesChanged();

        invalidCharError = invalidCharErrorOverride;
        wrongLengthError = wrongLengthErrorOverride;
        wrongFormatError = wrongFormatErrorOverride;
        incorrectFormatError = incorrectFormatErrorOverride;
    }

    /**
     *  Override of the base class <code>doValidation()</code> method
     *  to validate a postcode.
     *
     *  <p>You do not call this method directly;
     *  Flex calls it as part of performing a validation.
     *  If you create a custom Validator class, you must implement this method.</p>
     *
     *  @param value Object to validate.
     *
     *  @return An Array of ValidationResult objects, with one ValidationResult
     *  object for each field examined by the validator.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @productversion ApacheFlex 4.8
     */
    override protected function doValidation(value:Object):Array
    {
        var results:Array = super.doValidation(value);

        // Return if there are errors
        // or if the required property is set to false and length is 0.
        var val:String = value ? String(value) : "";
        if (results.length > 0 || ((val.length == 0) && !required))
            return results;
        else
            return PostCodeValidator.validatePostCode(this, val, null);
    }


    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Returns the region (usually country) from a locale string.
     *  If no loacle is provided the default locale is used.
     *
     *  @param locale locale to obtain region from.
     *  @return Region string.
     *
     */
    protected function getRegion(locale:String):String
    {
        var localeID:LocaleID;

        if (locale == null)
        {
            var tool:StringTools = new StringTools(LocaleID.DEFAULT);
            localeID = new LocaleID(tool.actualLocaleIDName);
        }
        else
        {
            localeID = new LocaleID(locale);
        }

        return localeID.getRegion();
    }
	
	/**
	 *  Sets the error strings to be from a another locale.
	 * 
	 *  <p>When validating other countries postcode you may want to set the
	 *  validation message to be from that country but not change the
	 *  applications locale.</p>
	 * 
	 * <p>To work the locale must be in the locale chain.</p>
	 *
	 *  @param locale locale to obtain region from.
	 * 
	 *  @return True if error message have been changed otherwise false.
	 *
	 */
	public function errorsToLocale(locale:String):Boolean
	{
		if (resourceManager.getResourceBundle(locale, BUNDLENAME) == null)
			return false;
		
		invalidCharErrorOverride =
			resourceManager.getString(BUNDLENAME, "invalidCharPostcodeError", null, locale);
		wrongLengthErrorOverride =
			resourceManager.getString(BUNDLENAME, "wrongLengthPostcodeError", null, locale);
		wrongFormatErrorOverride =
			resourceManager.getString(BUNDLENAME, "wrongFormatPostcodeError", null, locale);
		incorrectFormatErrorOverride =
			resourceManager.getString(BUNDLENAME, "incorrectFormatPostcodeError", null, locale);
		
		return true;
	}

    /**
     *  Sets the suggested postcode formats for a given <code>locale</code>.
     *
     *  <p>If no locale is supplied the default locale is used.</p>
     *
     *  <p>Currently only a limited set of locales are supported.</p>
     *
     *  @param locale Locale to obtain formats for.
	 *  @param changeError If true change error message to match local.
     *
     *  @return The suggested format (an array of strings) or an empty
     *  array if the locale is not supported.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @productversion ApacheFlex 4.8
     */
    public function suggestFormat(locale:String = null, changeErrors:Boolean = false):Array
    {
        var region:String = getRegion(locale);

        switch (region)
        {
            case "AU":
			case "CH":
            case "DK":
            case "NO":
                formats = [ "NNNN" ];
                break;
            case "BR":
                formats = [ "NNNNN-NNN" ];
                break;
            case "CN":
            case "DE":
                formats = [ "NNNNNN" ];
                break;
            case "CA":
                formats = [ "ANA NAN" ];
                break;
            case "ES":
            	formats = [ "NNNNN" ];
                break;
            case "FI":
            case "FR":
            case "IT":
            case "TW":
                formats = [ "NNNNN" ];
                break;
            case "GB":
                formats = [ "AN NAA", "ANN NAA", "AAN NAA", "ANA NAA", "AANN NAA", "AANA NAA" ];
                break;
            case "JP":
                formats = [ "NNNNNNN", "NNN-NNNN", "C NNNNNNN", "C NNN-NNNN" ];
                break;
            case "KR":
                formats = [ "NNNNNN", "NNN-NNN" ];
                break;
            case "NL":
                formats = [ "NNNN AA" ];
                break;
			case "PT":
				formats = [ "NNNN-NNN", "NNNN NNN", "NNNN" ];
				break;
            case "RU":
                formats = [ "NNNNNN" ];
                break;
            case "SE":
                formats = [ "NNNNN", "NNN NN" ];
                break;
            case "US":
                formats = [ "NNNNN", "NNNNN-NNNN" ];
                break;
            default:
                formats = [];
                break;
        }
		
		if (changeErrors)
			errorsToLocale(locale);

        return formats;
    }

    /**
     *  Sets the suggested country code for for a given <code>locale</code>.
     *
     *  <p>If no locale is supplied the default locale is used.</p>
     *
     *  <p>Currently only a limited set of locales are supported.</p>
     *
     *  @param Locale Locale to obtain country code for.
     *
     *  @return The suggested code or an null string if the
     *  locale is not supported or has no country code.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @productversion ApacheFlex 4.8
     */
    public function suggestCountryCode(locale:String = null):String
    {
        var region:String = getRegion(locale);

        if (region == "JP")
            countryCode = "〒";

        return countryCode;
    }
}

}

