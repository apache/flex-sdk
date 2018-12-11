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

package mx.validators
{

import mx.resources.IResourceManager;
import mx.resources.ResourceManager;

[ResourceBundle("SharedResources")]
[ResourceBundle("validators")]

/**
 *  The DateValidator class validates that a String, Date, or Object contains a 
 *  proper date and matches a specified format. Users can enter a single 
 *  digit or two digits for month, day, and year. 
 *  By default, the validator ensures the following formats:
 *
 *  <ul>
 *    <li>The month is between 1 and 12 (or 0-11 for <code>Date</code> objects)</li>
 *    <li>The day is between 1 and 31</li>
 *    <li>The year is a number</li>
 *  </ul>
 *
 *  <p>You can specify the date in the DateValidator class in two ways:</p>
 *  <ul>
 *    <li>Single String containing the date - Use the <code>source</code>
 *    and <code>property</code> properties to specify the String.
 *    The String can contain digits and the formatting characters
 *    specified by the <code>allowedFormatChars</code> property,
 *    which include the "/\-. " characters. 
 *    By default, the input format of the date in a String field
 *    is "MM/DD/YYYY" where "MM" is the month, "DD" is the day,
 *    and "YYYY" is the year. 
 *    You can use the <code>inputFormat</code> property
 *    to specify a different format.</li>
 * 	  <li><code>Date</code> object.</li>
 *    <li>Object or multiple fields containing the day, month, and year.  
 *    Use all of the following properties to specify the day, month,
 *    and year inputs: <code>daySource</code>, <code>dayProperty</code>,
 *    <code>monthSource</code>, <code>monthProperty</code>,
 *    <code>yearSource</code>, and <code>yearProperty</code>.</li>
 *  </ul>
 *  
 *  @mxml
 *
 *  <p>The <code>&lt;mx:DateValidator&gt;</code> tag
 *  inherits all of the tag attributes of its superclass,
 *  and adds the following tag attributes:</p>  
 *  
 *  <pre>
 *  &lt;mx:DateValidator 
 *    allowedFormatChars="/\-. " 
 *    dayListener="<i>Object specified by daySource</i>"
 *    dayProperty="<i>No default</i>"
 *    daySource="<i>No default</i>"
 *    formatError= "Configuration error: Incorrect formatting string." 
 *    includeFormatInError="true|false"
 *    inputFormat="MM/DD/YYYY" 
 *    invalidCharError="The date contains invalid characters."
 *    monthListener="<i>Object specified by monthSource</i>"
 *    monthProperty="<i>No default</i>"
 *    monthSource="<i>No default</i>"
 *    validateAsString="true|false"
 *    wrongDayError="Enter a valid day for the month."
 *    wrongLengthError="Type the date in the format <i>inputFormat</i>." 
 *    wrongMonthError="Enter a month between 1 and 12."
 *    wrongYearError="Enter a year between 0 and 9999."
 *    yearListener="<i>Object specified by yearSource</i>"
 *    yearProperty="<i>No default</i>"
 *    yearSource="<i>No default</i>"
 *  /&gt;
 *  </pre>
 *  
 *  @includeExample examples/DateValidatorExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class DateValidator extends Validator
{
	include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  Convenience method for calling a validator
	 *  from within a custom validation function.
	 *  Each of the standard Flex validators has a similar convenience method.
	 *
	 *  @param validator The DateValidator instance.
	 *
	 *  @param value A field to validate.
	 *
	 *  @param baseField Text representation of the subfield
	 *  specified in the value parameter. 
	 *  For example, if the <code>value</code> parameter
	 *  specifies value.date, the <code>baseField</code> value is "date".
	 *
	 *  @return An Array of ValidationResult objects, with one ValidationResult 
	 *  object for each field examined by the validator. 
	 *
	 *  @see mx.validators.ValidationResult
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static function validateDate(validator:DateValidator,
									    value:Object,
										baseField:String):Array
	{
		var results:Array = [];
	
		// Resource-backed properties of the validator.
		var allowedFormatChars:String = validator.allowedFormatChars;
		var inputFormat:String = validator.inputFormat;
		var validateAsString:Boolean = validator.validateAsString;

		var resourceManager:IResourceManager = ResourceManager.getInstance();

		var validInput:String = DECIMAL_DIGITS + allowedFormatChars;
		
		var dateObj:Object = {day:"", month:"", year:""};
		
		var dayProp:String = baseField;
		var monthProp:String = baseField;
		var yearProp:String = baseField;
		
		var dateParts:Array = [];
		var formatParts:Array = [];
		
		var dayPart:String = "";
		var monthPart:String = "";
		var yearPart:String = "";

		var monthRequired:Boolean = false;
		var dayRequired:Boolean = false
		var yearRequired:Boolean = false;
		var valueIsString:Boolean = false;
		var foundMonth:Boolean = false;
		var foundYear:Boolean = false;
		
		var objValue:Object;
		var stringValue:Object;
	
		var n:int;
		var i:int;
		var temp:String;
		
		var part:int = -1;
		var lastFormatChar:String = "";
		var noSeperators:Boolean = true;
		
		n = inputFormat.length;
		for (i = 0; i < n; i++)
		{
			var formatChar:String = inputFormat.charAt(i);
			
			if (lastFormatChar != formatChar)
			{
				part++;
				formatParts[part] = "";
			}
			
			if (formatChar == "D" || formatChar == "d")
			{
				dayRequired = true;
				formatParts[part] += "D"
			}
			else if (formatChar == "M" || formatChar == "m")
			{
				monthRequired = true;
				formatParts[part] += "M"
			}
			else if (formatChar == "Y" || formatChar == "y")
			{
				yearRequired = true;
				formatParts[part] += "Y"
			}
			else if (allowedFormatChars.indexOf(formatChar) == -1)
			{
				results.push(new ValidationResult(
					true, baseField, "invalidChar", 
					validator.invalidCharError));
				return results;
			}
			else
			{
				noSeperators = false;
				formatParts[part] += formatChar;
			}
			
			lastFormatChar = formatChar;
		}
		
		if (value is String)
		{
			valueIsString = true;
			stringValue = String(value);
		}
		else if (value is Number)
		{
			valueIsString = true;
			stringValue = String(value);
		}
		else if (value is Date)
		{
			var date:Date = value as Date;
			objValue = {year: date.fullYear,
						month: date.month + 1,
						day: date.date};
		}
		else
		{
			objValue = value;
		}

		// Check if the validator is an object or a string.
		if (!validateAsString || !valueIsString)
		{
    		var baseFieldDot:String = baseField ? baseField + "." : "";
			dayProp = baseFieldDot + "day";
			yearProp = baseFieldDot + "year";
			monthProp = baseFieldDot + "month";
			
            if (validator.required && (!objValue.month || objValue.month == ""))
            {
                results.push(new ValidationResult(
					true, monthProp,"requiredField",
					validator.requiredFieldError));
            }
            else if (isNaN(objValue.month))
			{
				results.push(new ValidationResult(
					true, monthProp, "wrongMonth",
					validator.wrongMonthError));
			}
			else
			{
				monthRequired = true;
			}
			
            if (validator.required && (!objValue.year || objValue.year == ""))
            {
                results.push(new ValidationResult(
					true, yearProp, "requiredField",
					validator.requiredFieldError));
            }
            else if (isNaN(objValue.year))
			{
				results.push(new ValidationResult(
					true, yearProp, "wrongYear",
					validator.wrongYearError));
			}
			else
			{
				yearRequired = true;
			}
			
			var dayMissing:Boolean = (!objValue.day || objValue.day == "");
			var dayInvalid:Boolean = dayMissing || isNaN(objValue.day);
			var dayWrong:Boolean = !dayMissing && isNaN(objValue.day);
			var dayOptional:Boolean = yearRequired && monthRequired;			
			
			// If the validator is required and there is no day specified			
            if (validator.required && dayMissing)
            {
                results.push(new ValidationResult(
					true, dayProp, "requiredField",
					validator.requiredFieldError));
            }
			else if (!dayInvalid) // The day is valid (a number).
			{
				dayRequired = true;
			}
			else if (!dayOptional || dayWrong) // Day is not optional and is NaN.
			{
				results.push(new ValidationResult(
					true, dayProp, "wrongDay",
					validator.wrongDayError));
			}

			dateObj.month = objValue.month ? String(objValue.month) : "";
			dateObj.day = objValue.day ? String(objValue.day) : "";
			dateObj.year = objValue.year ? String(objValue.year) : "";
		}
		else
		{
			var result:ValidationResult = DateValidator.validateFormatString(
				validator, inputFormat, baseField);
			if (result != null)
			{
				results.push(result);
				return results;
			}
			else
			{
				var lastStringChar:String = "";
				lastFormatChar = "";
				n = stringValue.length;
				part = -1;
				for (i = 0; i < n; i++)
				{
					var stringChar:String = stringValue.charAt(i);
					var lastIsDigit:Boolean = (DECIMAL_DIGITS.indexOf(lastStringChar) >= 0)
						&& (lastStringChar != "");
					var curentIsDigit:Boolean = (DECIMAL_DIGITS.indexOf(stringChar) >= 0);
					
					formatChar = inputFormat.charAt(i);
					if (validInput.indexOf(stringChar) == -1)
					{
						results.push(new ValidationResult(
							true, baseField, "invalidChar", 
							validator.invalidCharError));
						return results;
					}
					else if (lastIsDigit != curentIsDigit)
					{
						part++;
						dateParts[part] = stringChar;
					}
					//  TODO will only work if month and day are not specified as single digits
					else if (lastFormatChar != formatChar && noSeperators)
					{
						part++;
						dateParts[part] = stringChar;
					}
					else
					{
						dateParts[part] += stringChar;
					}

					lastStringChar = stringChar;
					lastFormatChar = formatChar;
				}
				
				if (formatParts.length != dateParts.length)
				{
					results.push(new ValidationResult(
						true, baseField, "wrongLength", 
						validator.wrongLengthError
						+ (DateValidator._includeFormatInError?" " + inputFormat:"")));
					return results;
				}

				var j:int = 0;
				n = formatParts.length;
				for (part = 0; part < n; part++)
				{
					var mask:String = formatParts[part].charAt(0);

					if ( mask == "D")
					{
						dateObj.day = dateParts[part];
						dayPart = formatParts[part];
					}
					else if (mask == "M")
					{
						dateObj.month = dateParts[part];
						monthPart = formatParts[part];
					}
					else if (mask == "Y")
					{
						dateObj.year = dateParts[part];
						yearPart = formatParts[part];
					}
					else if (!noSeperators)
					{
						// separator part, we have valid separator characters just validate against
						// repeating separator values, validate now as we could have multiple separators
						if (dateParts[part].length != formatParts[part].length)
						{
							results.push(new ValidationResult(
								true, baseField, "wrongLength",
								validator.wrongLengthError
								+ (DateValidator._includeFormatInError?" " + inputFormat:"")));
							return results;
						}
					}
				}
				
				// DD or D format
				if ((dayRequired && dayPart.length == 2 && dateObj.day.length != 2)
					|| (dayRequired && dayPart.length == 1 && dateObj.day.length > 2))
				{
					results.push(new ValidationResult(
						true, baseField, "wrongLength", 
						validator.wrongLengthError
						+ (DateValidator._includeFormatInError?" " + inputFormat:"")));	
					return results;
				}
				// MM or M format
				if ((monthRequired && monthPart.length == 2 && dateObj.month.length != 2)
					|| (monthRequired && monthPart.length == 1 && dateObj.month.length > 2))
				{
					results.push(new ValidationResult(
						true, baseField, "wrongLength", 
						validator.wrongLengthError
						+ (DateValidator._includeFormatInError?" " + inputFormat:"")));
					return results;
				}
				// YY or YYYY format
				if ((yearRequired && yearPart.length == 2 && dateObj.year.length != 2)
					|| (yearRequired && yearPart.length == 4 && dateObj.year.length != 4))
				{
					results.push(new ValidationResult(
						true, baseField, "wrongLength", 
						validator.wrongLengthError
						+ (DateValidator._includeFormatInError?" " + inputFormat:"")));	
					return results;
				}
						
				if ((monthRequired && dateObj.month == "") ||
					(dayRequired && dateObj.day == "") ||
					(yearRequired && dateObj.year == ""))
				 {
				 	results.push(new ValidationResult(
						true, baseField, "wrongLength", 
						validator.wrongLengthError
						+ (DateValidator._includeFormatInError?" " + inputFormat:"")));
					return results;
				 }
			}
		}

		if (results.length > 0)
			return results;
		
		var monthNum:Number = Number(dateObj.month);
		var dayNum:Number = Number(dateObj.day);
		var yearNum:Number = Number(dateObj.year);

		if (monthNum > 12 || monthNum < 1)
		{
			results.push(new ValidationResult(
				true, monthProp, "wrongMonth",
				validator.wrongMonthError));
			return results;
		}

		var maxDay:Number = 31;

		if (monthNum == 4 || monthNum == 6 ||
			monthNum == 9 || monthNum == 11)
		{
			maxDay = 30;
		}
		else if (monthNum == 2)
		{
			if (yearNum % 4 > 0)
				maxDay = 28;
			else if (yearNum % 100 == 0 && yearNum % 400 > 0)
				maxDay = 28;
			else
				maxDay = 29;
		}

		if (dayRequired && (dayNum > maxDay || dayNum < 1))
		{
			results.push(new ValidationResult(
				true, dayProp, "wrongDay",
				validator.wrongDayError));
			return results;
		}

		if (yearRequired && (yearNum > 9999 || yearNum < 0))
		{
			results.push(new ValidationResult(
				true, yearProp, "wrongYear",
				validator.wrongYearError));
			return results;
		}

		return results;
	}

	/**
	 *  @private
	 */
	private static function validateFormatString(
								validator:DateValidator,
								format:String,
								baseField:String):ValidationResult
	{
		var monthCounter:Number = 0;
		var dayCounter:Number = 0;
		var yearCounter:Number = 0;
		
		var n:int = format.length;
		for (var i:int = 0; i < n; i++)
		{
			var mask:String = "" + format.substring(i, i + 1);
			
			// Check for upper and lower case to maintain backwards compatibility.
			if (mask == "m" || mask == "M")
				monthCounter++;
			else if (mask == "d" || mask == "D")
				dayCounter++;
			else if (mask == "y" || mask == "Y")
				yearCounter++;
		}

		if ((monthCounter >= 1 &&  monthCounter <= 2 &&
			 (yearCounter == 2 || yearCounter == 4)) ||
			(monthCounter >= 1 &&  monthCounter <= 2  && dayCounter >= 1 &&  dayCounter <= 2  &&
			 (yearCounter == 0 || yearCounter == 2 || yearCounter == 4)))
		{
			return null; // Passes format validation
		}
		else
		{
			return new ValidationResult(
				true, baseField, "format",
				validator.formatError);
		}
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
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function DateValidator()
	{
		super();
		
		subFields = [ "day", "month", "year" ];
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  actualListeners
	//----------------------------------

	/** 
	 *  @private
	 *  Returns either the listener or the source
	 *  for the day, month and year subfields.
	 */
	override protected function get actualListeners():Array
	{
		var results:Array = [];
	
		var dayResult:Object;
		if (_dayListener)
			dayResult = _dayListener;
		else if (_daySource)
			dayResult = _daySource;
			
		if (dayResult)
		{
			results.push(dayResult);
			if (dayResult is IValidatorListener)
				IValidatorListener(dayResult).validationSubField = "day";
		}
		
		var monthResult:Object;
		if (_monthListener)
			monthResult = _monthListener;
		else if (_monthSource)
			monthResult = _monthSource;
			
		if (monthResult)
		{
			results.push(monthResult);
			if (monthResult is IValidatorListener)
				IValidatorListener(monthResult).validationSubField = "month";
		}
		
		var yearResult:Object;
		if (_yearListener)
			yearResult = _yearListener;
		else if (_yearSource)
			yearResult = _yearSource;
			
		if (yearResult)
		{
			results.push(yearResult);
			if (yearResult is IValidatorListener)
				IValidatorListener(yearResult).validationSubField = "year";
		}
		
		if (results.length > 0 && listener)
			results.push(listener);
		else
			results = results.concat(super.actualListeners);
		
		return results;
	}	

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  allowedFormatChars
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the allowedFormatChars property.
	 */
	private var _allowedFormatChars:String;

    /**
	 *  @private
	 */
	private var allowedFormatCharsOverride:String;
	
	[Inspectable(category="General", defaultValue="null")]

	/** 
	 *  The set of formatting characters allowed for separating
	 *  the month, day, and year values.
	 *
	 *  @default "/\-. "
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get allowedFormatChars():String
	{
		return _allowedFormatChars;
	}

    /**
	 *  @private
	 */
	public function set allowedFormatChars(value:String):void
	{	
		if (value != null)
		{
			var n:int = value.length;
			for (var i:int = 0; i < n; i++)
			{
				if (DECIMAL_DIGITS.indexOf(value.charAt(i)) != -1)
				{
					var message:String = resourceManager.getString(
						"validators", "invalidFormatChars");
					throw new Error(message);
				}
			}
		}

		allowedFormatCharsOverride = value;

		_allowedFormatChars = value != null ?
							  value :
							  resourceManager.getString(
							      "validators",
								  "dateValidatorAllowedFormatChars");
	}

	//----------------------------------
	//  dayListener
	//----------------------------------
	
	/**
	 *  @private
	 *  Storage for the dayListener property.
	 */
	private var _dayListener:IValidatorListener;
	
	[Inspectable(category="General")]

	/** 
	 *  The component that listens for the validation result
	 *  for the day subfield.
	 *  If none is specified, use the value specified
	 *  for the <code>daySource</code> property.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get dayListener():IValidatorListener
	{
		return _dayListener;
	}
	
	/**
	 *  @private
	 */
	public function set dayListener(value:IValidatorListener):void
	{
		if (_dayListener == value)
			return;
			
		removeListenerHandler();	
			
		_dayListener = value;
		
		addListenerHandler();
	}
	
	//----------------------------------
	//  dayProperty
	//----------------------------------
	
	[Inspectable(category="General")]
	
	/**
	 *  Name of the day property to validate. 
	 *  This property is optional, but if you specify the
	 *  <code>daySource</code> property, you should also set this property.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var dayProperty:String;
	
	//----------------------------------
	//  daySource
	//----------------------------------
	
	/**
	 *  @private
	 *  Storage for the daySource property.
	 */
	private var _daySource:Object;
	
	[Inspectable(category="General")]

	/** 
	 *  Object that contains the value of the day field.
	 *  If you specify a value for this property, you must also
	 *  specify a value for the <code>dayProperty</code> property. 
	 *  Do not use this property if you set the <code>source</code> 
	 *  and <code>property</code> properties. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get daySource():Object
	{
		return _daySource;
	}
	
	/**
	 *  @private
	 */
	public function set daySource(value:Object):void
	{
		if (_daySource == value)
			return;
		
		if (value is String)
		{
			var message:String = resourceManager.getString(
				"validators", "DSAttribute", [ value ]);
			throw new Error(message);
		}
			
		removeListenerHandler();	
			
		_daySource = value;
		
		addListenerHandler();
	}
	
	//----------------------------------
	//  includeFormatInError
	//----------------------------------
	
	/**
	 *  @private
	 *  Storage for the includeFormatInError property.
	 * 
	 * Note needs to be static as validate methods are static.
	 */
	static private var _includeFormatInError:Boolean = true;

	
	[Inspectable(category="General", defaultValue="true")]
	
	/** 
	 *  If <code>true</code> the date format is shown in some
	 *  validation error messages. Setting to <code>false</code>
	 *  changes all DateValidators.
	 *
	 *  @default true
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion ApacheFlex 4.10
	 */
	public function get includeFormatInError():Boolean
	{
		return DateValidator._includeFormatInError;
	}
	
	/**
	 *  @private
	 */
	public function set includeFormatInError(value:Boolean):void
	{
		DateValidator._includeFormatInError = value;
	}
	
	//----------------------------------
	//  inputFormat
	//----------------------------------

    /**
	 *  @private
	 *  Storage for the inputFormat property.
	 */
	private var _inputFormat:String;
	
    /**
	 *  @private
	 */
	private var inputFormatOverride:String;
	
	[Inspectable(category="General", defaultValue="null")]

	/** 
	 *  The date format to validate the value against.
	 *  "MM" is the month, "DD" is the day, and "YYYY" is the year.
	 *  This String is case-sensitive.
	 *
	 *  @default "MM/DD/YYYY"
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get inputFormat():String
	{
		return _inputFormat;
	}

	/**
	 *  @private
	 */
	public function set inputFormat(value:String):void
	{
		inputFormatOverride = value;

		_inputFormat = value != null ?
					   value :
					   resourceManager.getString(
					      "SharedResources", "dateFormat");
	}

	//----------------------------------
	//  monthListener
	//----------------------------------		
	
	/**
	 *  @private
	 *  Storage for the monthListener property.
	 */
	private var _monthListener:IValidatorListener; 
	
	[Inspectable(category="General")]

	/** 
	 *  The component that listens for the validation result
	 *  for the month subfield. 
	 *  If none is specified, use the value specified
	 *  for the <code>monthSource</code> property.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get monthListener():IValidatorListener
	{
		return _monthListener;
	}
	
	/**
	 *  @private
	 */
	public function set monthListener(value:IValidatorListener):void
	{
		if (_monthListener == value)
			return;
			
		removeListenerHandler();	
			
		_monthListener = value;
		
		addListenerHandler();
	}
	
	//----------------------------------
	//  monthProperty
	//----------------------------------	

	[Inspectable(category="General")]

	/**
	 *  Name of the month property to validate. 
	 *  This property is optional, but if you specify the
	 *  <code>monthSource</code> property, you should also set this property.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var monthProperty:String;
		
	//----------------------------------
	//  monthSource
	//----------------------------------	
	
	/**
	 *  @private
	 *  Storage for the monthSource property.
	 */
	private var _monthSource:Object;
	
	[Inspectable(category="General")]

	/** 
	 *  Object that contains the value of the month field.
	 *  If you specify a value for this property, you must also specify
	 *  a value for the <code>monthProperty</code> property. 
	 *  Do not use this property if you set the <code>source</code> 
	 *  and <code>property</code> properties. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get monthSource():Object
	{
		return _monthSource;
	}
	
	/**
	 *  @private
	 */
	public function set monthSource(value:Object):void
	{
		if (_monthSource == value)
			return;
		
		if (value is String)
		{
			var message:String = resourceManager.getString(
				"validators", "MSAttribute", [ value ]);
			throw new Error(message);
		}
			
		removeListenerHandler();	
			
		_monthSource = value;
		
		addListenerHandler();
	}
		
	//----------------------------------
	//  validateAsString
	//----------------------------------

    /**
	 *  @private
	 *  Storage for the validateAsString property.
	 */
	private var _validateAsString:Object;
	
    /**
	 *  @private
	 */
	private var validateAsStringOverride:Object;
	
	[Inspectable(category="General", defaultValue="null")]

	/** 
	 *  Determines how to validate the value.
	 *  If set to <code>true</code>, the validator evaluates the value
	 *  as a String, unless the value has a <code>month</code>,
	 *  <code>day</code>, or <code>year</code> property.
	 *  If <code>false</code>, the validator evaluates the value
	 *  as a Date object. 
	 *
	 *  @default true	 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get validateAsString():Object
	{
		return _validateAsString;
	}

	/**
	 *  @private
	 */
	public function set validateAsString(value:Object):void
	{
		validateAsStringOverride = value;

		_validateAsString = value != null ?
							Boolean(value) :
							resourceManager.getBoolean(
								"validators", "validateAsString");
	}

	//----------------------------------
	//  yearListener
	//----------------------------------
	
	/**
	 *  @private
	 *  Storage for the yearListener property.
	 */
	private var _yearListener:IValidatorListener; 
	
	[Inspectable(category="General")]

	/** 
	 *  The component that listens for the validation result
	 *  for the year subfield. 
	 *  If none is specified, use the value specified
	 *  for the <code>yearSource</code> property.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get yearListener():IValidatorListener
	{
		return _yearListener;
	}
	
	/**
	 *  @private
	 */
	public function set yearListener(value:IValidatorListener):void
	{
		if (_yearListener == value)
			return;
			
		removeListenerHandler();	
			
		_yearListener = value;
		
		addListenerHandler();
	}
	
	//----------------------------------
	//  yearProperty
	//----------------------------------

	[Inspectable(category="General")]

	/**
	 *  Name of the year property to validate. 
	 *  This property is optional, but if you specify the
	 *  <code>yearSource</code> property, you should also set this property.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	 public var yearProperty:String;
	
	//----------------------------------
	//  yearSource
	//----------------------------------
	
	/**
	 *  @private
	 *  Storage for the yearSource property.
	 */
	private var _yearSource:Object;
	
	[Inspectable(category="General")]

	/** 
	 *  Object that contains the value of the year field.
	 *  If you specify a value for this property, you must also specify
	 *  a value for the <code>yearProperty</code> property. 
	 *  Do not use this property if you set the <code>source</code> 
	 *  and <code>property</code> properties. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get yearSource():Object
	{
		return _yearSource;
	}

	/**
	 *  @private
	 */
	public function set yearSource(value:Object):void
	{
		if (_yearSource == value)
			return;
		
		if (value is String)
		{
			var message:String = resourceManager.getString(
				"validators", "YSAttribute", [ value ]);
			throw new Error(message);
		}
			
		removeListenerHandler();	
			
		_yearSource = value;
		
		addListenerHandler();
	}
		
	//--------------------------------------------------------------------------
	//
	//  Properties: Errors
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  formatError
	//----------------------------------

    /**
	 *  @private
	 *  Storage for the formatError property.
	 */
	private var _formatError:String;
	
    /**
	 *  @private
	 */
	private var formatErrorOverride:String;
	
	[Inspectable(category="Errors", defaultValue="null")]

	/** 
	 *  Error message when the <code>inputFormat</code> property
	 *  is not in the correct format.
	 *
	 *  @default "Configuration error: Incorrect formatting string." 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get formatError():String
	{
		return _formatError;
	}

	/**
	 *  @private
	 */
	public function set formatError(value:String):void
	{
		formatErrorOverride = value;

		_formatError = value != null ?
					   value :
					   resourceManager.getString(
					       "validators", "formatError");
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
	private var invalidCharErrorOverride:String;
	
	[Inspectable(category="Errors", defaultValue="null")]

	/** 
	 *  Error message when there are invalid characters in the date.
	 *
	 *  @default "Invalid characters in your date."
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
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

		_invalidCharError = value != null ?
							value :
							resourceManager.getString(
							    "validators", "invalidCharErrorDV");
	}
	
	//----------------------------------
	//  wrongDayError
	//----------------------------------

    /**
	 *  @private
	 *  Storage for the wrongDayError property.
	 */
	private var _wrongDayError:String;
	
    /**
	 *  @private
	 */
	private var wrongDayErrorOverride:String;
	
	[Inspectable(category="Errors", defaultValue="null")]

	/** 
	 *  Error message when the day is invalid.
	 *
	 *  @default "Enter a valid day for the month." 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get wrongDayError():String
	{
		return _wrongDayError;
	}

	/**
	 *  @private
	 */
	public function set wrongDayError(value:String):void
	{
		wrongDayErrorOverride = value;

		_wrongDayError = value != null ?
						 value :
						 resourceManager.getString(
						     "validators", "wrongDayError");
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
	
	[Inspectable(category="Errors", defaultValue="null")]

	/** 
	 *  Error message when the length of the date
	 *  doesn't match that of the <code>inputFormat</code> property.
	 *
	 *  @default "Type the date in the format <i>inputFormat</i>." 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get wrongLengthError():String
	{
		return _wrongLengthError;
	}

	/**
	 *  @private
	 */
	public function set wrongLengthError(value:String):void
	{
		wrongLengthErrorOverride = value;

		_wrongLengthError = value != null ?
							value :
							resourceManager.getString(
							    "validators", "wrongLengthErrorDV");
	}

	//----------------------------------
	//  wrongMonthError
	//----------------------------------

    /**
	 *  @private
	 *  Storage for the wrongMonthError property.
	 */
	private var _wrongMonthError:String;
	
    /**
	 *  @private
	 */
	private var wrongMonthErrorOverride:String;
	
	[Inspectable(category="Errors", defaultValue="null")]

	/** 
	 *  Error message when the month is invalid.
	 *
	 *  @default "Enter a month between 1 and 12."
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function get wrongMonthError():String
	{
		return _wrongMonthError;
	}

	/**
	 *  @private
	 */
	public function set wrongMonthError(value:String):void
	{
		wrongMonthErrorOverride = value;

		_wrongMonthError = value != null ?
						   value :
						   resourceManager.getString(
						       "validators", "wrongMonthError");
	}
	
	//----------------------------------
	//  wrongYearError
	//----------------------------------

    /**
	 *  @private
	 *  Storage for the wrongYearError property.
	 */
	private var _wrongYearError:String;
	
    /**
	 *  @private
	 */
	private var wrongYearErrorOverride:String;
	
	[Inspectable(category="Errors", defaultValue="null")]

	/** 
	 *  Error message when the year is invalid.
	 *
	 *  @default "Enter a year between 0 and 9999."
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */	
	public function get wrongYearError():String
	{
		return _wrongYearError;
	}

	/**
	 *  @private
	 */
	public function set wrongYearError(value:String):void
	{
		wrongYearErrorOverride = value;

		_wrongYearError = value != null ?
						  value :
						  resourceManager.getString(
						      "validators", "wrongYearError");
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

    /**
	 *  @private    
     */
	override protected function resourcesChanged():void
	{
		super.resourcesChanged();

		allowedFormatChars = allowedFormatCharsOverride;
		inputFormat = inputFormatOverride;
		validateAsString = validateAsStringOverride;
				
		invalidCharError = invalidCharErrorOverride;
		wrongLengthError = wrongLengthErrorOverride;
		wrongMonthError = wrongMonthErrorOverride;
		wrongDayError = wrongDayErrorOverride;
		wrongYearError = wrongYearErrorOverride;
		formatError = formatErrorOverride;
	}

	/**
     *  Override of the base class <code>doValidation()</code> method
     *  to validate a date.
	 *
	 *  <p>You do not call this method directly;
	 *  Flex calls it as part of performing a validation.
	 *  If you create a custom validator class, you must implement this method. </p>
	 *
	 *  @param value Either a String or an Object to validate.
     *
	 *  @return An Array of ValidationResult objects, with one ValidationResult 
	 *  object for each field examined by the validator. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
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
		    return DateValidator.validateDate(this, value, null);
    }
	
	/**
	 *  @private
	 *  Grabs the data for the validator from three different sources.
	 */
	override protected function getValueFromSource():Object
	{
		var useValue:Boolean = false;
	
		var value:Object = {};
		
		if (daySource && dayProperty)
		{
			value.day = daySource[dayProperty];
			useValue = true;
		}
		
		if (monthSource && monthProperty)
		{
			value.month = monthSource[monthProperty];
			useValue = true;
		}
		
		if (yearSource && yearProperty)
		{
			value.year = yearSource[yearProperty];
			useValue = true;
		}
		
		return useValue ? value : super.getValueFromSource();
	}
}

}
