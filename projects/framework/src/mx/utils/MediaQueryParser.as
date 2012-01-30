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
        // force to lower case cuz case-insensitive
        expression = expression.toLowerCase();
        
        // degenerate expressions
        if (expression == "") return true;
        if (expression == "all") return true;

        if (goodQueries[expression]) return true;
        if (badQueries[expression]) return false;
        
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
                    goodQueries[expression] = true;
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
                    goodQueries[expression] = true;
                    return true;                    
                }
            }
            // if we didn't match on media type and we have a notFlag
            // then we match
            else if (notFlag)
            {
                goodQueries[expression] = true;                
                return true;
            }
        }
        badQueries[expression] = true;
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
            var min:Boolean = false;
            var max:Boolean = false;
            // look for min
            if (parts[0].indexOf("min-") == 0)
            {
                min = true;
                parts[0] = parts[0].substr(4);
            }
            // look for max
            else if (parts[0].indexOf("max-") == 0)
            {
                max = true;
                parts[0] = parts[0].substr(4);
            }
            // collapse hypens into camelcase
            if (parts[0].indexOf("-") > 0)
                parts[0] = deHyphenate(parts[0]);
            // if only one part, then it only matters that this property exists
            if (parts.length == 1)
            {
                if (!(parts[0] in this))
                    return false;
            }
            // if two parts, then make sure the property exists and value matches
            if (parts.length == 2)
            {
                // if property doesn't exist, then bail
                if (!(parts[0] in this))
                    return false;
                // handle min (we don't check if min is allowed for this property)
                if (min)
                {
                    if (this[parts[0]] < normalize(parts[1], typeof(this[parts[0]])))
                        return false;
                }
                // handle max (we don't check if min is allowed for this property)
                else if (max)
                {
                    if (this[parts[0]] > normalize(parts[1], typeof(this[parts[0]])))
                        return false;
                }
                // bail if the value doesn't match
                else if (this[parts[0]] != normalize(parts[1], typeof(this[parts[0]])))
                {
                    return false;
                }
            }
            
        }
        // all parts matched so return true
        return true;
    }
    
    // strip off metrics (maybe convert metrics some day)
    private function normalize(s:String, type:String):Object
    {
        var index:int;
        
        // strip leading white space
        if (s.charAt(0) == " ")
            s = s.substr(1);
        
        // for the numbers we currently handle, we
        // might find dpi or ppi on it, that we just strip off.
        // We don't handle dpcm yet.
        if (type == "number")
        {
            index = s.indexOf("dpi");
            if (index != -1)
            {
                s = s.substr(0, index);
            }
            return Number(s);
        }
        else if (type == "int")
        {
            return int(s);
        }
        else if (type == "string")
        {
            // strip quotes of strings
            if (s.indexOf('"') == 0)
            {
                if (s.lastIndexOf('"') == s.length - 1)
                    s = s.substr(1, s.length - 2);
                else
                    s = s.substr(1);
            }
        }
        
        return s;
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
    
    // the type of the media
    public var type:String = "screen";
    
    // the resolution of the media
    public var applicationDpi:Number;
    
    // the platform of the media
    public var osPlatform:String;
    
}

}
