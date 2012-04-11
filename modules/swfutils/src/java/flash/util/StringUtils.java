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

package flash.util;

import java.util.StringTokenizer;
import java.io.File;

/**
 * String utilities which exist in JDK 1.4 but are unavailable in JDK 1.3
 * <p>
 * The jakarta oro package is used for regular expressions support.
 *
 * @author Cathy Murphy
 */
public class StringUtils
{
    /**
     * Splits this string based on the regular expression.
     *
     * @param input string to be split
     * @param regularExpression pattern used for matching
     * @return  Splits this string around matches of the given regular expression.
     */
    public static String[] split(String input, String regularExpression)
    {
        return input.split(regularExpression);
    }

    /**
     * Splits this string based on the regular expression.
     *
     * @param input string to be split
     * @param regularExpression pattern used for matching
     * @param limit maximum number of strings to return
     * @return  Splits this string around matches of the given regular expression.
     */
    public static String[] split(String input, String regularExpression, int limit)
    {
        return input.split(regularExpression, limit);
    }

    /**
     * Replaces the first substring of this string that matches the given <a
     * href="../util/regex/Pattern.html#sum">regular expression</a> with the
     * given replacement.
     *
     * @param   regex
     *          the regular expression to which this string is to be matched
     *
     * @return  The resulting <tt>String</tt>
     *
     * @throws  IllegalArgumentException
     *          if the regular expression's syntax is invalid
     *
     */

    public static String replaceFirst(String target, String regex, String replacement)
    {
        return target.replaceFirst(regex, replacement);
    }

	public static String[] splitPath(String paths)
	{
		// [paul] The natural thing for a Java/Linux guy is to
		// use ":" for ASCLASSPATH, but this makes using the
		// same web.xml file for Windows and Linux difficult,
		// so for Linux use File.pathSeparator and ";".
		if ( File.pathSeparator.equals(";") )
		{
			return StringUtils.split(paths, File.pathSeparator);
		}
		else
		{
			return StringUtils.split(paths, File.pathSeparator + "|;");
		}
	}

	public static String[] concat(String[] a, String[] b)
	{
		String[] c = new String[a.length+b.length];
		System.arraycopy(a, 0, c, 0, a.length);
		System.arraycopy(b, 0, c, a.length, b.length);
		return c;
	}

    // FIXME: replaceAll is often called with "[^A-Za-z0-9]" regularExpression.  Compiling an expression is
    // very expensive.  We should save the compilation of this expression and create a special method in here to use
    // instead of replaceAll

    /**
     * Replace all occurrences in the original string of the oldString with the newString.
     *
     * @param input string to be examined
     * @param regularExpression the string to be replaced
     * @param replacement the string to replace with
     * @return  string with all occurrences of oldString replaced with newString
     */
    public static String replaceAll(String input, String regularExpression, String replacement)
    {
        return input.replaceAll(regularExpression, replacement);
    }

    public static String substitute(String str, String from, String to)
    {
        if(from == null || from.equals("") || to == null)
            return str;

        int index = str.indexOf(from);

        if(index == -1)
            return str;

        StringBuilder buf = new StringBuilder(str.length());
        int lastIndex = 0;

        while(index != -1) {
            buf.append(str.substring(lastIndex, index));
            buf.append(to);
            lastIndex = index+from.length();
            index = str.indexOf(from, lastIndex);
        }

        // add in last chunk
        buf.append(str.substring(lastIndex));

        return buf.toString();
    }

    /**
     * Find the index of the first unescapped (using backslash) character
     * @param charToFind the character you're searching for
     * @param n the instance of the character to start searching from
     * @param s the string containing the character
     * @return the index of the character, -1 if not found
     */
    public static int findNthUnescaped(char charToFind, int n, String s)
    {
        char[] charArray = s.toCharArray();
        int count = 0;
        for (int i = 0; i < charArray.length; ++i)
        {
            if (i > 0 && charArray[i-1] == '\\') continue;
            if (charArray[i] == charToFind)
            {
                if (++count == n)
                {
                    return i;
                }
            }
        }
        //if we get out of the loop we didn't find the character
        return -1;
    }

    /**
     * Find the index of the next unescapped (using backslash) character
     * @param charToFind the character you're searching for
     * @param startIdx the index to start searching from
     * @param s the string containing the character
     * @return the index of the character, -1 if not found
     */
    public static int findNextUnescaped(char charToFind, int startIdx, String s)
    {
        if (startIdx >= s.length()) return -1;
        char[] charArray = s.toCharArray();
        for (int i = startIdx; i < charArray.length; ++i)
        {
            if (i > 0 && charArray[i-1] == '\\') continue;
            if (charArray[i] == charToFind)
            {
                return i;
            }
        }
        //if we get out of the loop we didn't find the character
        return -1;
    }

    /**
     * Get rid of backslashes that were escaping the specified character
     * @param toClean
     * @return the cleaned string
     */
    public static String cleanupEscapedChar(char escapedChar, String toClean)
    {
        //if there's no char to begin with or no escape character we can just return the orig string
        if (toClean == null || toClean.indexOf(escapedChar) == -1 || toClean.indexOf('\\') == -1)
        {
            return toClean;
        }
        StringBuilder buf = new StringBuilder(toClean.length());
        char[] chars = toClean.toCharArray();
        for (int i = 0; i < chars.length - 1; ++i)
        {
            if (chars[i] != '\\' || chars[i+1] != escapedChar)
            {
                buf.append(chars[i]);
            }
        }
        buf.append(chars[chars.length - 1]);
        return buf.toString();
    }

    /**
     * Get rid of backslashes that were escaping the specified character
     * @param toClean
     * @return the cleaned string
     */
    public static String cleanupEscapedCharForXML(char escapedChar, String toClean)
    {
        //if there's no char to begin with or no escape character we can just return the orig string
        if (toClean == null || toClean.indexOf(escapedChar) == -1 || toClean.indexOf('\\') == -1)
        {
            return toClean;
        }
        StringBuilder buf = new StringBuilder(toClean.length());
        char[] chars = toClean.toCharArray();
        int i;
        for (i = 0; i < chars.length - 1; ++i)
        {
            if (chars[i] != '\\' || chars[i+1] != escapedChar)
            {
                buf.append(chars[i]);
            } else {
            	buf.append("&#x" + Integer.toString((chars[i+1]), 16) + ";");
            	i++;
            }
        }
        if (i == chars.length - 1) {
            buf.append(chars[chars.length - 1]);
        }
        
        return buf.toString();
    }
    
    public static int findClosingToken(char openToken, char closeToken, String s, int startIdx)
    {
        int closeIdx = startIdx + 1;
        int subTokenCount = 0;
        while (closeIdx < s.length())
        {
            char c = s.charAt(closeIdx);
            if (s.charAt(closeIdx - 1) == '\\')
            {
                ++closeIdx;
                continue;
            }
            if (c == openToken)
                ++subTokenCount;
            else if (c == closeToken)
                --subTokenCount;

            if (subTokenCount < 0) break;
            ++closeIdx;
        }
        return (closeIdx < s.length()) ? closeIdx : -1;
    }

    public static boolean findMatchWithWildcard(String str, String matchStr)
    {
        char [] src = str == null ? null : str.toCharArray();
        char [] pat = matchStr == null ? null : matchStr.toCharArray();
        return findMatchWithWildcard(src, pat);
    }

    /**
     * Sees if src equals pat, also allowing '*' and '?' as wildcards
     */
    public static boolean findMatchWithWildcard(char[] src, char[] pat)
    {
        if (src == null || pat == null)
            return false;

        // we consider an empty pattern to be a don't-match-anything pattern
        if (pat.length == 0)
            return false;

        if (src.length == 0)
            return (pat.length == 0 || (pat.length == 1 && (pat[0] == '*' || pat[0] == '?')));

        boolean star = false;

        int srcLen = src.length;
        int patLen = pat.length;
        int srcIdx = 0;
        int patIdx = 0;

        for( ; srcIdx < srcLen ; srcIdx++)
        {
            if (patIdx == patLen)
			{
				if (patLen < (srcLen - srcIdx))
					patIdx = 0; //Start the search again
				else
					return false;
			}

            char s = src[srcIdx];
            char m = pat[patIdx];

            switch(m)
            {
                case'*':
                    // star on the end
                    if(patIdx == pat.length-1)
                        return true;
                    star = true;
                    ++patIdx;
                    break;

                case '?':
                    ++patIdx;
                    break;

                default:
                    if(s != m)
                    {
                        if(!star)
						{
                            if (patLen < (srcLen - srcIdx))
								patIdx = 0; //Start the search again
							else
								return false;
						}
                    }
                    else
                    {
                        star = false;
                        ++patIdx;
                    }
                    break;
            }
        }

        if(patIdx < patLen)
            return false;

        return !star;
    }

	/**
	 * Counts the number of lines in the buffer.
	 *
	 * @param buffer
	 * @return
	 */
	public static final int countLines(String buffer)
	{
		int count = 0;
		int index = buffer.indexOf('\n');

		while ( index != -1 )
		{
			count++;
			index = buffer.indexOf('\n', index + 1);
		}

		return count;
	}

	/**
	 * <p>Entitize the given HTML buffer. This process will convert
	 * the following characters into HTML entities:
	 * <dir><pre>
	 * < to &lt;
	 * > to &gt;
	 * </pre></dir>
	 * @param buffer The HTML buffer
	 * @return The converted buffer
	 */
	public static String entitizeHtml(String buffer)
	{
		if (buffer == null) return buffer;

		StringBuilder sb = new StringBuilder();
		for (int i = 0; i < buffer.length(); i++)
		{
			char c = buffer.charAt(i);
			switch(c)
			{
			case '>':
				sb.append("&gt;");
				break;
			case '<':
				sb.append("&lt;");
				break;
			default:
				sb.append(c);
			}
		}
		return sb.toString();
	}

    public static String formatHtml(String buffer)
    {
        if (buffer == null) return buffer;

		StringBuilder sb = new StringBuilder();
		for (int i = 0; i < buffer.length(); i++)
		{
			char c = buffer.charAt(i);
			switch(c)
			{
			case '\n':
				sb.append("<br>");
				break;
//            case ' ':
//                sb.append("&nbsp;");
//                break;
			default:
				sb.append(c);
			}
		}
		return sb.toString();
    }

	/**
	 * character escaping.  For example, "\u0041-\u0043" returns "\\u0041-\\u0043".
	 *
	 * @param s
	 * @return a formatted string
	 */
	public static String formatString(String s)
	{
		StringBuilder result = new StringBuilder(s.length() + 2);

		result.append('"');
		for (int i = 0; i < s.length(); i++)
		{
			switch (s.charAt(i))
			{
			case '\\':
                // Leave unicode characters as is.
                if ((i + 1 < s.length()) && (s.charAt(i + 1) == 'u'))
                {
                    result.append("\\");
                }
                else
                {
                    result.append("\\\\");
                }
				break;
			case '"':
				result.append("\\\"");
				break;
			case '\b':
				result.append("\\b");
				break;
			case '\t':
				result.append("\\t");
				break;
			case '\f':
				result.append("\\f");
				break;
			case '\r':
				result.append("\\r");
				break;
			case '\n':
				result.append("\\n");
				break;
			default:
				if (s.charAt(i) < ' ')
				{
					result.append("\\x").append((int) s.charAt(i)).append("X");
				}
				else
				{
					result.append(s.charAt(i));
				}
			}
		}

		result.append('"');

		return result.toString();
	}

	/**
	 * character unescaping.  For example, "\u0041-\u0043" becomes "A-C".
	 *
	 * @param s a formatted String
	 * @return a unformated String
	 */
    public static String unformatString(String s)
    {
        StringBuffer result = new StringBuffer();
        int i = 0;

        while (i < s.length())
        {
            char c = s.charAt(i++);

            if ((c == '\\') && (i < s.length()))
            {
                c = s.charAt(i++);

                if ((c == 'u') && (i + 3 < s.length()))
                {
                    // Read the xxxx
                    int value = 0;

                    for (int j = 0; j < 4; j++)
                    {
                        c = s.charAt(i++);
                        int digit = Character.digit(c, 16);

                        if (digit != -1)
                        {
                            value = (value << 4) + digit;
                        }
                        else
                        {
                            throw new IllegalArgumentException("Malformed \\uxxxx encoding.");
                        }
                    }
                    result.append((char) value);
                }
                else if (c == 'u')
                {
                    result.append(c);
                }
                else
                {
                    result.append('\\');
                    result.append(c);
                }
            }
            else
            {
                result.append(c);
            }
        }

        return result.toString();
    }

	// Remove whitespace from the input string and return a string that contains
	// at most 1 'replacementChar' character between each word.
	//
	// Can be used to strip newlines, tabs, multiple spaces, etc between words
	// and replace them with a single space.
	// 
	// @param in input string
	// @param replacementChar character which replaces whitespace
	//
    public static String collapseWhitespace(String in, char replacementChar)
    {
        StringBuilder sb = new StringBuilder();
		int size = in.length();
		boolean lastWasSpace = true;
		int i = 0;
		while(i < size)
		{
			char c = in.charAt(i++);
			boolean ws = Character.isWhitespace(c);
			if (ws)
			{
				if (lastWasSpace)
					; // consume the character
				else
					sb.append(replacementChar);
				lastWasSpace = true;
			}
			else
			{
				sb.append(c);
				lastWasSpace = false;
			}
		}
        return sb.toString().trim();
    }

	public static boolean isEnumerationToken(String str, String target, String delimiter)
	{
		// C: indexOf() and startsWith() should be faster and create fewer objects...
		StringTokenizer t = new StringTokenizer(str, delimiter);
		while (t.hasMoreTokens())
		{
			if (t.nextToken().trim().equals(target))
			{
				return true;
			}
		}
		return false;
	}

    private static final char[] hexchars = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
    public static String hexDump( byte[] data )
    {
        int cur = 0;

        StringBuilder buf = new StringBuilder( 1024 );
        while (cur < data.length)
        {
            for (int i = 0; i < 16; ++i)
            {
                if (cur+i < data.length)
                {
                    buf.append( hexchars[(data[cur+i]>>4)&0xf] );
                    buf.append( hexchars[(data[cur+i]&0xf)] );
                }
                else
                {
                    buf.append( "xx" );
                }

                buf.append( (i==7)? '-':' ');
            }
            buf.append("  ");
            for (int i = 0; i < 16; ++i)
            {
                if (cur+i <data.length)
                {
                    if ((data[cur+i] >= ' ') && (data[cur+i] <= '~'))
                        buf.append((char)data[cur+i]);
                    else
                        buf.append('.');
                }
            }
            buf.append('\n');
            cur += 16;
       }
        return buf.toString();
    }
}
