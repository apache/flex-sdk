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

package org.apache.flex.formatters
{
import org.apache.flex.validators.PostCodeValidator;
	
import mx.events.ValidationResultEvent;
import mx.formatters.Formatter;
import mx.managers.ISystemManager;
import mx.managers.SystemManager;
import mx.validators.ValidationResult;

[ResourceBundle("apache")]

/**
 *  The PostCodeFormatter class formats a valid postcode
 *  based on a user set <code>formatString</code> or
 *  <code>formats</code> property.
 *
 *  <p>Postcode formats consists of the letters C, N, A and spaces or hyphens
 *  <ul>
 *  <li>CC or C is the country code (required for some postcodes).</li>
 *	<li>N is a number 0-9.</li>
 *  <li>A is a letter A-Z or a-z,</li>
 *  </ul></p>
 *
 *  <p>Country codes one be one or two digits.</p>
 *
 *  <p>For example "NNNN" is a four digit numeric postcode, "CCNNNN" is country code
 *  followed by four digits and "AA NNNN" is two letters, followed by a space then
 *  followed by four digits.</p>
 *
 *  <p>More than one format can be specified by setting the <code>formats</code>
 *  property to an array of format strings.</p>
 *
 *  <p>Spaces and hypens will be added if missing to format the postcode correctly.</p>
 *
 *  <p>If an error occurs, an empty String is returned and a String that
 *  describes the error is saved to the <code>error</code> property.
 *  The <code>error</code> property can have one of the following values:
 *  <ul>
 *    <li><code>"invalidFormat"</code> means the format constants an invalid
 *    character.</li>
 *    <li><code>"wrongFormat"</code> means the postcode has an invalid format.</li>
 *    <li><code>"wrongLength"</code> means the postcode is not a valid length.</li>
 *    <li><code>"invalidChar"</code> means the postcode contains an invalid
 *    character.</li>
 *  </ul></p>
 *
 *  <p>Fullwidth numbers and letters are supported in postcodes by ignoring character
 *  width via the <code>flash.globalization.Collator</code> <code>equals</code> method.</p>
 *
 *  @mxml
 *
 *  <p>The <code>&lt;mx:PostCodeFormatter&gt;</code> tag
 *  inherits all of the tag attributes of its superclass,
 *  and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;mx:PostCodeFormatter
 *    formatString="NNNNN"
 *    formats="['NNNNN', 'NNNNN-NNNN']"
 *  />
 *  </pre>
 *
 *  @see org.apache.flex.validators.PostCodeValidator
 * 
 *  @includeExample PostCodeValidationExample.mxml
 *
 *  @langversion 3.0
 *  @playerversion Flash 10.2
 *  @productversion ApacheFlex 4.8
 */
public class PostCodeFormatter extends Formatter
{
    include "../../../../core/Version.as";

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
    public function PostCodeFormatter()
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  formats
    //----------------------------------

    /**
     *  @private
     *  An array of the postcode formats to check against.
     */
    private var _formats:Array = [];


    [Inspectable(category = "General", defaultValue = "null")]

    /**
     *  Format string to format the postcode in.
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
    public function get formatString():String
    {
        if (_formats && _formats.length == 1)
            return _formats[0];

        return null;
    }

    /**
     *  @private
     */
    public function set formatString(value:String):void
    {
        if (value != null)
            _formats = [ value ];
        else
            _formats = [];
    }

    /**
     *  An array of format strings to format the postcode in.
     *
     *  <p>Use for locales where more than one format is required.
     *  eg en_UK</p>
     *
     *  <p>See <code>formatString</code> for format of the format
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

    //--------------------------------------------------------------------------
    //
    //  Overidden methods
    //
    //--------------------------------------------------------------------------

    /**
       *  Formats the value by using the format set in <code>formatString</code>
       *  or <code>formats</code>.
       *
       *  <p>If the value cannot be formatted this method returns an empty String
       *  and write a description of the error to the <code>error</code> property.</p>
       *
       *  @param value Value to format.
       *
       *  @return Formatted String. Empty if an error occurs. A description
       *  of the error condition is written to the <code>error</code> property.
       *
       *  @langversion 3.0
       *  @playerversion Flash 10.2
       *  @productversion ApacheFlex 4.8
       */
    override public function format(value:Object):String
    {
        var postCode:String = value as String;
        var formatted:String = "";
        var validator:PostCodeValidator = new PostCodeValidator();
        var errors:Array;

        error = "";

        validator.formats = formats;
        errors = PostCodeValidator.validatePostCode(validator, postCode, null);

        // Valid postcode no need for formatting
        if (errors.length == 0)
            return postCode ? postCode : "";

        // Check and add missing (or convert) padding characters
        for each (var format:String in formats)
        {
            var condensedPostcode:String = condensedFormat(postCode);
            var condensedFormat:String = condensedFormat(format);
            var char:String;
            var length:int = format.length;
            var condensedErrors:Array;

            validator.format = condensedFormat;

            condensedErrors = PostCodeValidator.validatePostCode(validator, condensedPostcode, null);

            if (condensedErrors.length == 0)
            {
                var pos:int = 0;

                for (var i:int = 0; i < length; i++)
                {
                    char = format.charAt(i);

                    if (PostCodeValidator.FORMAT_SPACERS.indexOf(char) >= 0)
                        formatted += char;
                    else
                        formatted += condensedPostcode.charAt(pos++);
                }

                //TODO may want to return the longest match?
                errors = [];
                break;
            }
        }

        if (errors.length > 0)
            error = (errors[0] as ValidationResult).errorCode;

        return formatted;
    }

    /**
     *  @private
     *
     *  Take a format or paostCode and strip all spacing characters
     *  out of it.
     *
     */
    protected function condensedFormat(postCode:String):String
    {
        var condensed:String = postCode;
        var length:int;

        if (postCode)
            length = postCode.length;

        for (var i:int = 0; i < length; i++)
        {
            var char:String = PostCodeValidator.FORMAT_SPACERS.charAt(i);

            condensed = condensed.split(char).join("");
        }

        return condensed;
    }

}
}
