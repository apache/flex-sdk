/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package flex2.compiler.mxml.lang;

import flex2.compiler.mxml.reflect.Type;
import flex2.compiler.mxml.reflect.TypeTable;
import flex2.compiler.mxml.rep.BindingExpression;
import flash.css.Descriptor;
import flash.util.StringUtils;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.xerces.util.XMLChar;

/**
 * MXML text parser, used to parse attribute values and text
 * content. Some utility functionality is also exposed in static
 * methods.
 */
public abstract class TextParser
{
    /**
     * valid percentage expressions are: [whitespace] positive-whole-or-decimal-number [whitespace] % [whitespace]
     */
    private static final Pattern percentagePattern = Pattern.compile("\\s*((\\d+)(.(\\d)+)?)\\s*%\\s*");

    /**
     * valid qualified names are series of 1 or more leading-alpha-or-_-followed-by-alphanumerics words, separated by dots
     */
    private static final Pattern qualifiedNamePattern = Pattern.compile("([a-zA-Z_]\\w*)(\\.([a-zA-Z_]\\w*))*");

    /**
     * valid AS RegExps are: / 0-or-more-of-anything / 0-or-more-flag chars. We leave pattern validation to ASC.
     */
    private static final Pattern regExpPattern = Pattern.compile("/.*/[gimsx]*");

    //  error codes
    public final static int Ok = 0;
    public final static int ErrTypeNotEmbeddable = 1;       //  @Embed in a bad spot
    public final static int ErrInvalidTextForType = 2;      //  can't make text work as a serialized instance of type
    public final static int ErrInvalidPercentage = 3;       //  malformed percentage expression
    public final static int ErrTypeNotSerializable = 4;     //  type doesn't have a text representation at all
    public final static int ErrPercentagesNotAllowed = 5;   //  percentage not allowed here
    public final static int ErrTypeNotContextRootable = 6;  //  @ContextRoot in a bad spot
    public final static int ErrUnrecognizedAtFunction = 7;  //  @huh?()
    public final static int ErrUndefinedContextRoot = 8;    //  context-root not defined
    public final static int ErrInvalidTwoWayBind  = 9;      //  malformed two-way binding expression
    
    //  processing flags
    public final static int FlagInCDATA = 1;
    public final static int FlagCollapseWhiteSpace = 2;
    public final static int FlagConvertColorNames = 4;
    public final static int FlagAllowPercentages = 8;
    public final static int FlagIgnoreBinding = 16;
    public final static int FlagIgnoreAtFunction = 32;
    public final static int FlagIgnoreArraySyntax = 64;
    public final static int FlagIgnoreAtFunctionEscape = 128;
    public final static int FlagRichTextContent = 256;

    private final TypeTable typeTable;
    private final boolean ignoreTwoWayBinding;
    
    public TextParser(TypeTable typeTable, int compatibilityVersion)
    {
        this.typeTable = typeTable;
        this.ignoreTwoWayBinding = compatibilityVersion == 0 ? false : compatibilityVersion < flex2.compiler.common.MxmlConfiguration.VERSION_4_0;
    }

    public TextParser(TypeTable typeTable)
    {
        this(typeTable, 0);
    }

    /**
     * called when an @ContextRoot has been recognized, in an ok spot. Handler should return a String
     * @param text original @ContextRoot expression, unmodified
     * @return whatever you want parse() to return
     */
    protected abstract String contextRoot(String text);

    /**
     * called when an @Clear has been recognized, in an ok spot. Handler should return a VO
     * @return whatever you want parse() to return
     */
    protected abstract Object clear();
    
    /**
     * called when an @Embed has been recognized, in an ok spot. Handler should return a VO
     * @param text original @Embed expression, unmodified
     * @param type
     * @return whatever you want parse() to return
     */
    protected abstract Object embed(String text, Type type);

    /**
     * called when an @Resource has been recognized, in an ok spot. Handler should return a VO
     * @param text original @Resource expression, unmodified
     * @param type
     * @return whatever you want parse() to return
     */
    protected abstract Object resource(String text, Type type);

    /**
     * called when a binding expression has been parsed. Handler should return a VO
     * @param converted converted binding expression
     * @return whatever you want parse() to return
     */
    protected abstract Object bindingExpression(String converted);
    protected abstract Object bindingExpression(String converted, boolean isTwoWay);

    /**
     * called to parse a binding expression.
     * @param text to parse
     * @param line being parsed
     * @return BindingExpression or null if not binding expression
     */
    protected abstract BindingExpression parseBindingExpression(String text, int line);
    
    /**
     * called when a valid percentage string has been parsed. Callback allows subs to do nasty stuff like
     * property-name swapping, etc.
     * @param pct canonicalized percentage string
     * @return whatever you want parse() to return
     */
    protected abstract Object percentage(String pct);

    /**
     * called when an array expression has been parsed. Handler should return a VO
     * @param entries Collection of parsed array entries
     * @param arrayElementType
     * @return whatever you want parse() to return
     */
    protected abstract Object array(Collection<Object> entries, Type arrayElementType);

    /**
     * called when a text value has been parsed for type Function. Handler normally returns the unmodified name
     */
    protected abstract Object functionText(String name);

    /**
     * called when a text value has been parsed for type Class. Handler normally returns the unmodified name
     * if type == Class; a Primitive if type is an instance factory.
     */
    protected abstract Object className(String name, Type type);

    /**
     * called on a parse error
     * @param error one of the constants defined in this interface
     * @param text erroneous text
     * @param type type for which parse was requested
     * @param arrayElementType
     */
    protected abstract void error(int error, String text, Type type, Type arrayElementType);

    /**
     * type-directed text parsing. Search order is:
     * 1. look for a binding expression, if applicable.
     * 2. then look for an embed.
     * 3. then look for a resource.
     * 4. if nothing is found above, attempt to deserialize a value of the specified type[arrayElementType]
     */
    protected Object parse(String text, Type type, Type arrayElementType, int flags)
    {
        if (!inCDATA(flags))
        {
            //  binding?
            if (!ignoreBinding(flags))
            {
                BindingExpression result = parseBindingExpression(text);
                if (result != null)
                {
                    return result;
                }
                else
                {
                    text = cleanupBindingEscapes(text);
                }
            }

            //  @func() ?
            if (!ignoreAtFunction(flags))
            {
                String atFunctionName = getAtFunctionName(text);
                if (atFunctionName != null)
                {
                    return parseAtFunction(atFunctionName, text, type, arrayElementType, flags);
                }
                else
                {
                    // SDK-18397 requires getting \@ and \\@ escapes to work
                    // again after two-way data-binding syntax was added.
                    // The following is called here in case the type is
                    // something other than String, but it then has to avoid
                    // parseString() from removing another slash from \\@.
                    // TODO: Re-work the escaping system in TextParser.
                    text = cleanupAtFunctionEscapes(text);
                    flags = flags | TextParser.FlagIgnoreAtFunctionEscape;
                }
            }
        }

        // If we have [RichTextContent] we treat the CDATA as a String and do
        // not test for any literal syntax
        if (isRichTextContent(flags))
        {
            String parsedString = parseString(text, flags);

            // Singleton coercion
            if (type == typeTable.arrayType)
            {
                return array(Collections.singleton((Object) parsedString), arrayElementType);
            }
            else
            {
                return parsedString;
            }
        }
        else
        {
            //  ordinary value
            return parseValue(text, type, arrayElementType, flags);
        }
    }

    /**
     * Parses text and looks first for a two-way binding expression and then
     * for a one-way binding expression.  If a malformed two-way binding expression
     * is found, i.e. there is anything other than leading and trailing whitespace,
     * or nested bindings, an error is logged and null is returned.
     * @param s the string to be parsed
     * @return BindingExpression or null
     */
    protected BindingExpression parseBindingExpression(String s)
    {        
        int atIdx = -1;
        int openBraceIdx = -1;
        
        // Look for unescaped '@{'.  If found, string will be parsed as a two-way.
        if (!ignoreTwoWayBinding)
        {
            atIdx = StringUtils.findNextUnescaped('@', 0, s);
            if (atIdx >= 0)
            {
                openBraceIdx = StringUtils.findNextUnescaped('{', atIdx + 1, s);
                if (openBraceIdx != atIdx + 1)
                {
                    atIdx = -1;
                }
            }
        }
        
        // Not two-way bind, so look for one-way bind '{' from the start of the string.
        if (atIdx == -1)
        {
            openBraceIdx = StringUtils.findNextUnescaped('{', 0, s);
        }
        
        // Neither one or two-way binding expression.
        if (openBraceIdx == -1)
        {
            return null;
        }

        // this allows for nested binding expressions such as { foo {bar}}
        int closeBraceIdx = StringUtils.findClosingToken('{', '}', s, openBraceIdx);
        if (closeBraceIdx == -1)
        {
            // apparently an open token without the corresponding close token
            // is not considered an error
            return null;
        }

        // Handle two-way binding expressions here, i.e. '@{...}'
        if (atIdx >= 0)
        {
            // no lead, no tail other than whitespace (which technically makes this
            // an expression but one-way allows it and trims it so do the same here)
            if (!s.substring(0, atIdx).trim().equals("") || !s.substring(closeBraceIdx + 1).trim().equals(""))
            {
                error(ErrInvalidTwoWayBind, s, null, null);
                return null;                                                        
            }

            // must have content and no nested binding expressions
            String contents = s.substring(openBraceIdx + 1, closeBraceIdx);
            if (contents.length() == 0 || isBindingExpression(contents))
            {
                error(ErrInvalidTwoWayBind, s, null, null);
                return null;                                                        
            }
           
            //Don't include the braces (or parens since they will just get stripped).
            return (BindingExpression) bindingExpression(contents, true);
        }
        
        StringBuilder buf = new StringBuilder();
        
        //first attach the leading part of the string, all the way up to the opening brace
        //for one-way bind or at-symbol for two-way bind
        String lead = s.substring(0, openBraceIdx);

        //only if there was non-whitespace
        if (!lead.trim().equals(""))
        {
            String text = cleanupBindingEscapes(lead);
            text = cleanupAtFunctionEscapes(text);
            buf.append(StringUtils.formatString(text));
            buf.append(" + ");
        }
        
        //now loop, attaching the piece between braces and the next string if it exists
        while (openBraceIdx != -1)
        {
            //attach this { } (don't include the braces but do use parentheses to group the thing together)
            buf.append("(");
            String contents = s.substring(openBraceIdx + 1, closeBraceIdx);
            if (contents.trim().equals(""))
            {
                //  logWarning("Empty {} in binding expression.");
                contents = "''";
            }
            buf.append(contents);
            buf.append(")");
            //now see if there's a tail part to add
            int lastClose = closeBraceIdx;
            openBraceIdx = StringUtils.findNextUnescaped('{', lastClose, s);
            if (openBraceIdx != -1)
            {
                buf.append(" + ");
                closeBraceIdx = StringUtils.findClosingToken('{', '}', s, openBraceIdx);
                if (closeBraceIdx != -1)
                {
                    String text = cleanupBindingEscapes(s.substring(lastClose + 1, openBraceIdx));
                    text = cleanupAtFunctionEscapes(text);
                    buf.append(StringUtils.formatString(text));
                    buf.append(" + ");
                }
                else
                {
                    buf.append(StringUtils.formatString(s.substring(lastClose + 1)));
                    openBraceIdx = -1; //make sure to finish the loop
                }
            }
            else
            {
                String tail = s.substring(lastClose + 1);
                if (!tail.trim().equals(""))
                {
                    buf.append(" + ");
                    String text = cleanupBindingEscapes(tail);
                    text = cleanupAtFunctionEscapes(text);
                    buf.append(StringUtils.formatString(text));
                }
            }
        }

        return (BindingExpression) bindingExpression(buf.toString());
    }

    /**
     * do type-directed deserialization of typed constant value from text
     * NOTE using equals() not isAssignableTo() for type testing - all tested classes are final as of 8/4/05
     * TODO assertions confirming type finality
     */
    private Object parseValue(String text, Type type, Type arrayElementType, int flags)
    {
        boolean isint = false, isuint = false;  //  temps

        Object result = null;

        if (type.equals(typeTable.noType) || type.equals(typeTable.objectType))
        {
            result = parseObject(text, arrayElementType, flags);
        }
        else if (type.equals(typeTable.stringType))
        {
            result = parseString(text, flags);
        }
        else if (type.equals(typeTable.numberType) ||
                (isint = type.equals(typeTable.intType)) ||
                (isuint = type.equals(typeTable.uintType)))
        {
            if (text.indexOf('%') >= 0)
            {
                if (allowPercentages(flags))
                {
                    if ((result = parsePercentage(text)) != null)
                    {
                        result = percentage((String)result);
                    }
                    else
                    {
                        result = new ParseError(ErrInvalidPercentage);
                    }
                }
                else
                {
                    result = new ParseError(ErrPercentagesNotAllowed);
                }
            }
            else
            {
                result = isint ? parseInt(text, flags) :
                        isuint ? parseUInt(text, flags) :
                        parseNumber(text, flags);
            }
        }
        else if (type.equals(typeTable.booleanType))
        {
            result = parseBoolean(text);
        }
        else if (type.equals(typeTable.regExpType))
        {
            result = parseRegExp(text);
        }
        else if (type.equals(typeTable.arrayType))
        {
            Collection<Object> c = parseArray(text, arrayElementType, true, flags);
            result = c != null ? array(c, arrayElementType) : null;
        }
        else if (type.equals(typeTable.functionType))
        {
            String f = parseFunction(text);
            result = f != null ? functionText(f) : null;
        }
        else if (acceptsClassRef(type))
        {
            String c = parseClassName(text);
            result = c != null ? className(c, type) : null;
        }
        else
        {
            result = new ParseError(ErrTypeNotSerializable);
        }

        //  handle/return

        if (result == null)
        {
            result = new ParseError(ErrInvalidTextForType);
        }

        if (result instanceof ParseError)
        {
            error(((ParseError)result).errno, text, type, arrayElementType);
            return null;
        }
        else
        {
            return result;
        }
    }

    /**
     *
     */
    private boolean acceptsClassRef(Type type)
    {
        return type.equals(typeTable.classType) || typeTable.getStandardDefs().isInstanceGenerator(type);
    }

    /**
     *
     */
    private Object parseObject(String text, Type arrayElementType, int flags)
    {
        String temp = text.trim();

        Object result;
        if ((result = parseBoolean(temp)) != null)
        {
            return result;
        }
        else if ((result = parseArray(temp, arrayElementType, false, flags)) != null)
        {
            @SuppressWarnings("unchecked")
            Collection<Object> res = (Collection<Object>)result;
            return array(res, arrayElementType);
        }
        else if ((result = parseNumber(temp, flags)) != null)
        {
            return result;
        }
        else
        {
            return text;
        }
    }

    /**
     *
     */
    protected Collection<Object> parseArray(String text, Type elementType, boolean coerceSingleton, int flags)
    {
        String trimmed = text.trim();

        if (ignoreArraySyntax(flags) || !isArray(trimmed))
        {
            if (coerceSingleton)
            {
                Object element = parseValue(text, elementType, typeTable.objectType, flags);
                return element != null ? Collections.singleton(element) : null;
            }
            else
            {
                return null;
            }
        }

        if (isEmptyArray(trimmed))
        {
            return Collections.emptyList();
        }

        Collection<Object> result = new ArrayList<Object>();
		StringBuilder buffer = new StringBuilder();
        char quoteChar = '\'';
        boolean inQuotes = false;

        for (int index = 1, length = trimmed.length(); index < length; index++)
        {
            char c = trimmed.charAt(index);

            switch (c)
            {
            case '[':
                if (inQuotes)
                {
                    buffer.append(c);
                }
                else
                {
                    //  TODO nested arrays?
                }
                break;
            case '"':
            case '\'':
                if (inQuotes)
                {
                    if (quoteChar == c)
                    {
                        inQuotes = false;
                    }
                    else
                    {
                        buffer.append(c);
                    }
                }
                else
                {
                    inQuotes = true;
                    quoteChar = c;
                }
                break;
            case ',':
            case ']':
                if (inQuotes)
                {
                    buffer.append(c);
                }
                else
                {
                    String elementText = buffer.toString().trim();
					buffer = new StringBuilder();

                    //  NOTE clear any special-processing flags, on the interpretation that they only apply to top-level scalars.
                    //  TODO multi-level typed arrays? :)
                    Object element = parseValue(elementText, elementType, typeTable.objectType, 0);
                    if (element != null)
                    {
                        result.add(element);
                    }
                    else
                    {
                        return null;
                    }
                }
                break;
            default:
                buffer.append(c);
            }
        }

        return result;
    }

    /**
     *
     */
    private boolean hasLeadingZeros(String s)
    {
        boolean result = false;
        int n = s.length();
        if (n > 1 && s.charAt(0) == '0' &&
            !(s.startsWith("0x") || s.startsWith("0X") || s.startsWith("0.")))
        {
            result = true;
        }
        return result;
    }

    /**
     * We accept 0x and # prefixes.
     */
    private Integer parseInt(String s, int flags)
    {
        if (convertColorNames(flags))
        {
            String c = Descriptor.convertColorName(s);
            if (c != null)
            {
                s = c;
            }
        }

        try
        {
            // Don't parse int's with leading zeros, which are not octal.
            // For example, a MA zip code, 02127.
            if (hasLeadingZeros(s))
            {
                return null;
            }
            else
            {
                return Integer.decode(s);
            }
        }
        catch (NumberFormatException e)
        {
            return null;
        }
    }

    /**
     *
     */
    private Long parseUInt(String s, int flags)
    {
        if (convertColorNames(flags))
        {
            String c = Descriptor.convertColorName(s);
            if (c != null)
            {
                s = c;
            }
        }

        try
        {
            // Don't parse uint's with leading zeros, which are not octal.
            // For example, a MA zip code, 02127.
            if (hasLeadingZeros(s))
            {
                return null;
            }
            else
            {
                Long l = Long.decode(s);
                long val = l.longValue();
                return (val == java.lang.Math.abs(val) && val <= 0xffffffffL) ? l : null;
            }
        }
        catch (NumberFormatException e)
        {
            return null;
        }
    }

    /**
     *
     */
    private Number parseNumber(String s, int flags)
    {
        // Don't parse Number's with leading zeros, which are not octal.
        // For example, a MA zip code, 02127.
        if (hasLeadingZeros(s))
        {
            return null;
        }

        Integer integer = parseInt(s, flags);
        if (integer != null)
        {
            return integer;
        }
        else
        {
            try
            {
                return Double.valueOf(s);
            }
            catch (NumberFormatException e)
            {
                return null;
            }
        }
    }

    /**
     *
     */
    private String parseString(String text, int flags)
    {
        if (collapseWhiteSpace(flags) && !inCDATA(flags))
        {
            text = StringUtils.collapseWhitespace(text, ' ');
        }

        if (!ignoreAtFunctionEscape(flags)
                && (text.length() > 1 && text.charAt(0) == '\\' && "\\@".indexOf(text.charAt(1)) >= 0))
        {
            //  '\' is being used to begin the string with a literal '\' or '@'
            //  NOTE: currently, we only attach special meaning to "@name(...)" when it begins a string.
            text = text.substring(1);
        }

        return text;
    }
    
   /**
    * Static helper to parse simple comma delimited string list. Supports with 
    * or without array notation ('[',']').
    */
   public static Collection<String> parseStringList(String text)
   {
       if (text != null)
       {
           String trimmed = text.trim();
           
           if (!isArray(trimmed))
           {
               text = "[" + text + "]";
           }
           else if (isEmptyArray(trimmed))
           {
               return Collections.emptyList();
           }
       }
       else
       {
           text = "";
       }

       Collection<String> result = new ArrayList<String>();
       StringBuilder buffer = new StringBuilder();
       char quoteChar = '\'';
       boolean inQuotes = false;

       for (int index = 1, length = text.length(); index < length; index++)
       {
           char c = text.charAt(index);

           switch (c)
           {
           case '[':
               if (inQuotes)
                   buffer.append(c);
               break;
           case '"':
           case '\'':
               if (inQuotes)
               {
                   if (quoteChar == c)
                       inQuotes = false;
                   else
                       buffer.append(c);
               }
               else
               {
                   inQuotes = true;
                   quoteChar = c;
               }
               break;
           case ',':
           case ']':
               if (inQuotes)
               {
                   buffer.append(c);
               }
               else
               {
                   String elementText = buffer.toString().trim();
                   buffer = new StringBuilder();
                   result.add(elementText);
               }
               break;
           default:
               buffer.append(c);
           }
       }

       return result;
   }

    /**
     *
     */
    private static Boolean parseBoolean(String text)
    {
        // If we get false, make sure its because the user specified 'false'
        Boolean b = Boolean.valueOf(StringUtils.collapseWhitespace(text, ' '));
        return b.booleanValue() || text.equalsIgnoreCase("false") ? b : null;
    }

    /**
     *
     */
    private static String parseRegExp(String text)
    {
        Matcher m = regExpPattern.matcher(text);
        return m.matches() ? m.group(0) : null;
    }

    /**
     * NOTE returns canonicalized percentage expression in a String - not the percentage itself
     */
    private static String parsePercentage(String text)
    {
        Matcher m = percentagePattern.matcher(text);
        return m.matches() ? m.group(1) + '%' : null;
    }

    /**
     * TODO there was a TODO in 1.5 about parsing source code... ?
     */
    private static String parseFunction(String text)
    {
        return text.trim();
    }

    /**
     *
     */
    public static String parseClassName(String text)
    {
        String name = text.trim();
        return isQualifiedName(name) ? name : null;
    }

    /**
     *
     */
    private static class ParseError
    {
        final int errno;
        ParseError(final int errno) { this.errno = errno; }
    }
    
    

    /**
     * flag extraction
     */
    private static final boolean inCDATA(int flags) { return (flags & FlagInCDATA) == FlagInCDATA; }
    private static final boolean collapseWhiteSpace(int flags) { return (flags & FlagCollapseWhiteSpace) == FlagCollapseWhiteSpace; }
    private static final boolean convertColorNames(int flags) { return (flags & FlagConvertColorNames) == FlagConvertColorNames; }
    private static final boolean allowPercentages(int flags) { return (flags & FlagAllowPercentages) == FlagAllowPercentages; }
    private static final boolean ignoreBinding(int flags) { return (flags & FlagIgnoreBinding) == FlagIgnoreBinding; }
    private static final boolean ignoreAtFunction(int flags) { return (flags & FlagIgnoreAtFunction) == FlagIgnoreAtFunction; }
    private static final boolean ignoreArraySyntax(int flags) { return (flags & FlagIgnoreArraySyntax) == FlagIgnoreArraySyntax; }
    private static final boolean ignoreAtFunctionEscape(int flags) { return (flags & FlagIgnoreAtFunctionEscape) == FlagIgnoreAtFunctionEscape; }
    private static final boolean isRichTextContent(int flags) { return (flags & FlagRichTextContent) == FlagRichTextContent; }

    /**
     * TODO make private
     * Get rid of backslashes that were escaping curly braces
     * @param toClean
     * @return the cleaned string
     */
    public static String cleanupBindingEscapes(String toClean)
    {
        toClean = StringUtils.cleanupEscapedChar('{', toClean);
        toClean = StringUtils.cleanupEscapedChar('}', toClean);
        return toClean;
    }

    /**
     * TODO make private
     * Get rid of backslashes that were escaping at-functions
     * @param toClean
     * @return the cleaned string
    */
    public static String cleanupAtFunctionEscapes(String toClean)
    {
        toClean = StringUtils.cleanupEscapedChar('@', toClean);
        return toClean;
    }

    /**
     * TODO make private
     * replace backslashes for curly braces with &#7d; &#7b;
     * @param toClean
     * @return the cleaned string
     */
    public static String replaceBindingEscapesForE4X(String toClean)
    {
        toClean = StringUtils.cleanupEscapedCharForXML('{', toClean);
        toClean = StringUtils.cleanupEscapedCharForXML('}', toClean);
        toClean = StringUtils.cleanupEscapedCharForXML('@', toClean);
        return toClean;
    }
    
    /**
     * Determine if string s contains matching unescaped '{' and '} characters.
     * This could represent either a one-way or two-way ('@{' and '}') expression.
     * @param s
     * @return true if s is either a one-way or two-way data binding expression
     */
    public static boolean isBindingExpression(String s)
    {
        int openBraceIdx = StringUtils.findNthUnescaped('{', 1, s);
        if (openBraceIdx == -1)
        {
            return false;
        }

        int closeBraceIdx = StringUtils.findClosingToken('{', '}', s, openBraceIdx);
        if (closeBraceIdx == -1)
        {
            return false;
        }

        return true;
    }

    /**
     * Returns true if s contains unquoted '@{ }' sequence but it still may
     * not be a legal two-way bind expression if there are nested or multiple binds,
     * or leading and trailing text around the sequence.
     * @param s
     * @return boolean
     */
    public static boolean isTwoWayBindingExpression(String s)
    {
        int openBraceIdx = StringUtils.findNthUnescaped('{', 1, s);
        if (openBraceIdx == -1 || openBraceIdx == 0)
        {
            return false;
        }

        int atIdx = StringUtils.findNthUnescaped('@', 1, s);
        if (atIdx != openBraceIdx - 1)
        {
            return false;
        }

        int closeBraceIdx = StringUtils.findClosingToken('{', '}', s, openBraceIdx);
        if (closeBraceIdx == -1)
        {
            return false;
        }

        return true;
    }

    /**
     * 
     */
    //TODO ideally private ...
    public static String getAtFunctionName(String value)
    {
        value = value.trim();

        if (value.length() > 1 && value.charAt(0) == '@')
        {
            int openParen = value.indexOf('(');

            // A function must have an open paren and a close paren after the open paren.
            if (openParen > 1 && value.indexOf(')') > openParen)
            {
                return value.substring(1, openParen);
            }
        }

        return null;
    }

    /**
     *
     */
    private Object parseAtFunction(String functionName, String text, Type type, Type arrayElementType, int flags)
    {
        Object result = null;

        if ("Embed".equals(functionName))
        {
            // @Embed requires that lvalue accept String or Class
            if (typeTable.stringType.isAssignableTo(type) || acceptsClassRef(type))
            {
                result = embed(text, type);
            }
            else
            {
                error(ErrTypeNotEmbeddable, text, type, arrayElementType);
            }
        }
        else if ("ContextRoot".equals(functionName))
        {
            // @ContextRoot requires a String lvalue
            if (typeTable.stringType.isAssignableTo(type))
            {
                result = contextRoot(text);
            }
            else
            {
                error(ErrTypeNotContextRootable, text, type, arrayElementType);
            }
        }
        else if ("Resource".equals(functionName))
        {
            result = resource(text, type);
        }
        else if ("Clear".equals(functionName))
        {
            result = clear();
        }
        else
        {
            error(ErrUnrecognizedAtFunction, text, type, arrayElementType);
        }

        return result;
    }

    /**
     *
     */
    protected static boolean isArray(String text)
    {
        assert text.equals(text.trim());
        boolean result = true;

        if ((text.length() < 2) ||
            (text.charAt(0) != '[') ||
            (text.charAt(text.length() - 1) != ']'))
        {
            result = false;
        }

        return result;
    }

    private static boolean isEmptyArray(String text)
    {
        assert text.equals(text.trim());
        boolean result = false;

        if (isArray(text) && text.substring(1, text.length() - 1).trim().length() == 0)
        {
            result = true;
        }

        return result;
    }

    /**
     * test if this is a valid identifier, and is not an actionscript keyword.
     */
    public static boolean isValidIdentifier(String id)
    {
        if (id.length() == 0 || !isIdentifierFirstChar(id.charAt(0)))
        {
            return false;
        }

        for (int i=1; i < id.length(); i++)
        {
            if (!isIdentifierChar(id.charAt(i)))
            {
                return false;
            }
        }

        if (StandardDefs.isReservedWord(id))
        {
            return false;
        }

        return true;
    }
    
    /**
     * test if this is a valid state identifier, essentially must be a valid
     * XML attribute name *without* : or . character within.
     */
    public static boolean isValidStateIdentifier(String id)
    {
        if (id != null)
        {
            for (int i=0; i < id.length(); i++)
            {
                if (!isIdentifierChar(id.charAt(i)))
                {
                    return false;
                }
            }
        
            if (!XMLChar.isValidName(id))
            {
                return false;
            }

            return true;
        }
        return false;
    }
    
    /**
     * Used to detect scoped attributes.
     */
    public static boolean isScopedName(String name)
    {
        return name.indexOf('.') != -1;
    }
	
    /**
     * Helper used to decompose a scoped name.
     */
    public static String[] analyzeScopedName(String name)
    {
        String[] results = name.split("\\.");                           
        return (results.length != 2) ? null : results;
    }

    /**
     *
     */
    private static boolean isIdentifierFirstChar(char ch)
    {
        return Character.isJavaIdentifierStart(ch);
    }

    /**
     *
     */
    private static boolean isIdentifierChar(int ch)
    {
        return ch != -1 && Character.isJavaIdentifierPart((char)ch);
    }

    /**
     *
     */
    private static boolean isQualifiedName(String text)
    {
        return qualifiedNamePattern.matcher(text).matches() && !StandardDefs.isReservedWord(text);
    }
}
