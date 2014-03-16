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

package mx.utils
{
import flash.system.Capabilities;
import mx.core.IFlexModuleFactory;
import mx.core.mx_internal;
use namespace mx_internal;

[ExcludeClass]

/**
 *  @private
 *  Parser for CSS Media Query syntax.  Not a full-fledged parser.
 *  Doesn't report syntax errors, assumes you have your attributes
 *  and identifiers spelled correctly, etc.
 *  Media query parser now supports os-version selectors such as X, X.Y or X.Y.Z
 *  Note that version with 3 parts must be  quoted
Examples:
 (os-platform: "ios") AND (min-os-version: 7)
 (os-platform: "android") AND (min-os-version: "4.1.2")

 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.2
 *  @playerversion AIR 2.6
 *  @productversion Flex 4.5
 */ 
public class MediaQueryParser
{
    /**
     *  @private
     *  Table of known media types
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.6
     *  @productversion Flex 4.5
     */
     public static var platformMap:Object =
     {
         AND: "android",
         IOS: "ios",
         MAC: "macintosh",
         WIN: "windows",
         LNX: "linux",
         QNX: "qnx"
     }
    
     /**
      *  @private
      */
     private static var _instance:MediaQueryParser;
     
     /**
      *  Single shared instance of the parser
      * 
      *  @langversion 3.0
      *  @playerversion Flash 10.2
      *  @playerversion AIR 2.6
      *  @productversion Flex 4.5
      */
     public static function get instance():MediaQueryParser
     {
         return _instance;
     }
     
     /**
      *  @private
      */
     public static function set instance(value:MediaQueryParser):void
     {
         if (!_instance)
             _instance = value;
     }
     
     /**
     *  @private
     *  Constructor
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.6
     *  @productversion Flex 4.5
     */
    public function MediaQueryParser(moduleFactory:IFlexModuleFactory = null)
    {        
        applicationDpi = DensityUtil.getRuntimeDPI();
        if (moduleFactory)
        {
            if (moduleFactory.info()["applicationDPI"] != null)
                applicationDpi = moduleFactory.info()["applicationDPI"];
        }
        osPlatform = getPlatform();
        osVersion = getOSVersion();
    }
    
    /**
     *  Queries that were true
     */
    mx_internal var goodQueries:Object = {};
    
    /**
     *  Queries that were false
     */
    mx_internal var badQueries:Object = {};
    
    /**
     *  @private
     *  Main entry point.
     * 
     *  @param expression A syntactically correct CSS Media Query
     *  @returns true if valid for this media, false otherwise
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.6
     *  @productversion Flex 4.5
     */
    public function parse(expression:String):Boolean
    {
        // remove whitespace
        expression = StringUtil.trim(expression);
       
        // degenerate expressions
        if (expression == "") return true;
        
        // known queries
        if (goodQueries[expression]) return true;
        if (badQueries[expression]) return false;
                
        // force to lower case cuz case-insensitive
        var originalExpression:String = expression;
        expression = expression.toLowerCase();
        
        //TODO : be smart and do not do a lowercase to do this test
        if (expression == "all") return true;
        
        // get a list of queries.  If any pass then
        // we're good
        var mediaQueries:Array = expression.split(", ");
        var n:int = mediaQueries.length;
        for (var i:int = 0; i < n; i++)
        {
            var result:Boolean;
            var mediaQuery:String = mediaQueries[i];
            var notFlag:Boolean = false;
            // eat only
            if (mediaQuery.indexOf("only ") == 0)
                mediaQuery = mediaQuery.substr(5);
            // remember if this is a "not" expression
            if (mediaQuery.indexOf("not ") == 0)
            {
                notFlag = true;
                mediaQuery = mediaQuery.substr(4);
            }
            // get a list of the parts of the query.
            // it should be media type, optionally
            // followed by "and" followed by
            // optional media feature expressions
            var expressions:Array = tokenizeMediaQuery(mediaQuery);
            var numExpressions:int = expressions.length;
            if (expressions[0] == "all" || expressions[0] == type)
            {
                if (numExpressions == 1 && !notFlag)
                {
                    goodQueries[originalExpression] = true;
                    return true;                                            
                }
                // bail if "and" and no media features (invalid query)
                if (numExpressions == 2) return false;
                // kick off the type and "and"
                expressions.shift();
                expressions.shift();
                // see if the media features match
                result = evalExpressions(expressions);
                // early exit if it returned true;
                if ((result && !notFlag) || (!result && notFlag))
                {
                    goodQueries[originalExpression] = true;
                    return true;                    
                }
            }
            // if we didn't match on media type and we have a notFlag
            // then we match
            else if (notFlag)
            {
                goodQueries[originalExpression] = true;                
                return true;
            }
        }
        badQueries[originalExpression] = true;
        return false;
    }
    
    // break up the expression into pieces
    private function tokenizeMediaQuery(mediaQuery:String):Array
    {        
        var tokens:Array = [];
        // if leading off with "(" then 
        // "all and" is implied
		var pos:int = mediaQuery.indexOf("(");
        if (pos == 0)
        {
            tokens.push("all");
            tokens.push("and");
        }
		else if (pos == -1)
		{
			// no parens means the whole thing should
			// be the media type
			return [ mediaQuery ];
		}
        
        var parenLevel:int = 0;
        var inComment:Boolean = false;
        var n:int = mediaQuery.length;
        var expression:Array = [];
        // walk through each character looking for the pieces
        for (var i:int = 0; i < n; i++)
        {
            var c:String = mediaQuery.charAt(i);
            if (StringUtil.isWhitespace(c) && expression.length == 0)
            {
                // eat extra whitespace between tokens
                continue;
            }
            else
            {
                // this piece should be the media type
                if (c == '/' && i < n - 1 && mediaQuery.charAt(i + 1) == '*')
                {
                    inComment = true;
                    i++;
                    continue;
                }
                if (inComment)
                {
                    if (c == '*' && i < n - 1 && mediaQuery.charAt(i + 1) == '/')
                    {
                        inComment = false;
                        i++;
                    }
                    continue;
                }
                else if (c == "(")  // Not sure whether these should be in the “else” here?
                    parenLevel++;
                else if (c == ")")
                    parenLevel--;
                else
                {
                    expression.push(c);
                }
                
                // If we found whitespace and not in a paren, or just closed a paren,
                // then that's the end of an expression
                if (parenLevel == 0 && (StringUtil.isWhitespace(c) || (c == ")")))
                {
                    if (c != ")")
                        expression.length--;
                    tokens.push(expression.join(""));
                    expression.length = 0; // reset
                }
                
            }
        }
        return tokens;
    }
    
    // take a media feature expression and evaluate it
    private function evalExpressions(expressions:Array):Boolean
    {
        var n:int = expressions.length;
        for (var i:int = 0; i < n; i++)
        {
            var expr:String = expressions[i];
            // skip over "and"
            if (expr == "and")
                continue;
            
            // break into two pieces
            var parts:Array = expr.split(":");
            var key: String = parts[0];
            var min:Boolean = false;
            var max:Boolean = false;
            // look for min
            if (key.indexOf("min-") == 0)
            {
                min = true;
                key = key.substr(4);
            }
            // look for max
            else if (key.indexOf("max-") == 0)
            {
                max = true;
                key = key.substr(4);
            }
            // collapse hypens into camelcase
            if (key.indexOf("-") > 0)
                key = deHyphenate(key);
            // if only one part, then it only matters that this property exists
            if (parts.length == 1)
            {
                if (!(key in this))
                    return false;
            }
            // if two parts, then make sure the property exists and value matches
            if (parts.length == 2)
            {
                // if property doesn't exist, then bail
                if (!(key in this))
                    return false;
                var value: Object = normalize(parts[1], this[key]) ;
                var cmp: int = compareValues(this[key], value) ;
                // handle min (we don't check if min is allowed for this property)
                if (min)
                {
                   if (cmp < 0)
                       return false;
                }
                // handle max (we don't check if min is allowed for this property)
                else if (max)
                {
                    if (cmp > 0)
                        return false;
                }
                // bail if the value doesn't match
                else if (cmp != 0)
                {
                    return false;
                }
            }
            
        }
        // all parts matched so return true
        return true;
    }
    
    // strip off  unit if currentValue is Number or int
    //  now supports versions (X.Y.Z) and numbers with units
    private function normalize(s:String, currentValue: Object ):Object
    {
        var index:int;
        
        // strip leading white space
        if (s.charAt(0) == " ")
            s = s.substr(1);
        
        // for the numbers we currently handle, we
        // might find dpi or ppi on it, that we just strip off.
        // We don't handle dpcm yet.
        if (currentValue is Number)
        {
            index = s.indexOf("dpi");
            if (index != -1)
            {
                s = s.substr(0, index);
            }
            return Number(s);
        }
        else if (currentValue is int)
        {
            return int(s);
        }
        // string or CSS value
        // strip quotes of strings
        if (s.indexOf('"') == 0) {
            if (s.lastIndexOf('"') == s.length - 1)
                s = s.substr(1, s.length - 2);
            else
                s = s.substr(1);
        }
        //  string , return
         if (currentValue is String)
        {
             return s;
        }
        else if (currentValue is CssOsVersion) {
            return new CssOsVersion(s) ;
        }
        return s;
    }

    /**  @private
     * Compares current value with test values, using currentValue type to determine comparison function
     *  accepts number, int, string and CssOsVersion.
     *  Will accept LexicalUnit in the future
     *
     * @param currentValue
     * @param testValue
     * @return   -1 if currentValue < testValue, 1 if currentValue > testValue and 0 if equal
     */
    private function compareValues ( currentValue: Object, testValue: Object): int
    {
        if (currentValue is CssOsVersion)
           return CssOsVersion(currentValue).compareTo(CssOsVersion(testValue))  ;
        else // scalar compare operators
           if ( currentValue == testValue)
              return 0;
           else if ( currentValue < testValue)
             return -1;
           else
             return 1;
    }

    // collapse "-" to camelCase
    private function deHyphenate(s:String):String
    {
        var i:int = s.indexOf("-");
        while (i > 0)
        {
            var part:String = s.substr(i + 1);
            s = s.substr(0, i);
            var c:String = part.charAt(0);
            c = c.toUpperCase();
            s += c + part.substr(1);
            i = s.indexOf("-");
        }
        return s;
    }
    
    private function getPlatform():String
    {
        var s:String = Capabilities.version.substr(0, 3);
        // if there is a friendly name, then use it
        if (platformMap.hasOwnProperty(s))
            return platformMap[s] as String;
        
        // otherwise match against the 3 characters.
        // use lower case because match are case
        // insensitive and we lower case the entire
        // expression
        return s.toLowerCase();
    }

    /** @private
     * returns a CssOsVersion suitable for MediaQueryParser for the current device operating system version.
     * */
    private function getOSVersion():CssOsVersion {
		return  new CssOsVersion(Platform.osVersion) ;
    }

    // the type of the media
    public var type:String = "screen";
    
    // the resolution of the media
    public var applicationDpi:Number;
    
    // the platform of the media
    public var osPlatform:String;

    // the platform os version of the media
    public var osVersion: CssOsVersion;
    
}
}

/**
 * Support class for MediaQueryParser to store and compare versions such as X.Y.Z
 * Its mainly used in os-version  media selector.
 */
internal class CssOsVersion
{
     /* separator between version parts*/
    private static const SEPARATOR: String = ".";

    /** Contructor
     *   Returns an CssOsVersion with the
     * @param versionString
     */
    public function CssOsVersion(versionString: String = "")
    {
        var versionParts: Array = versionString.split(SEPARATOR);
        var l: int = versionParts.length;
        if (l >= 1)
            major = Number(versionParts[0]);
        if (l >= 2)
            minor = Number(versionParts[1]);
        if (l >= 3)
            revision = Number(versionParts[2]);
        // ignore remaining parts
    }

    /**
     *  major figure of the version.
     */
    public var major: int = 0;
    /**
     *  minor figure  of the version.
     */
    public var minor: int = 0;
    /**
     *  revision figure  of the version.
     */
    public var revision: int = 0;

    /**
     * Printable string of the version, as X.Y.Z
     * @return version as a string
     */
    public function toString(): String
    {
        return  major.toString() + SEPARATOR + minor.toString() + SEPARATOR + revision.toString();
    }

    /**
     *  Compares to another version.
     *
     *  @param other Second Version.
     *
     *  @return 0 if both versions are equal
     *  -1 if <code>this</code> is lower than <code>otherVersion</code>.
     *  1 if <code>this</code> is greater than <code>otherVersion</code>.
     *  @langversion 3.0
     *  @productversion Flex 4.13
     */
    public function compareTo(otherVersion: CssOsVersion): int
    {
        if (major > otherVersion.major)
            return 1;
        else if (major < otherVersion.major)
            return -1;
        else //major == other.major)
        {
            if (minor > otherVersion.minor)
                return 1;
            else if (minor < otherVersion.minor)
                return -1;
            else //minor == other.minor)
            {
                if (revision > otherVersion.revision)
                    return 1;
                else if (revision < otherVersion.revision)
                    return -1;
                else
                    return 0; // all equal
            }
        }
    }
}

