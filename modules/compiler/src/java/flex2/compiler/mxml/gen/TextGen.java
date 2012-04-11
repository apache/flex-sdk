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

package flex2.compiler.mxml.gen;

import java.util.Iterator;

/**
 * This class contains a bunch of text generation utility methods.
 */
public class TextGen
{
	/**
	 * Enclose a string in double quotes. NOTE: does not encode embedded double quotes, hence the name.
	 */
	public static String quoteWord(String s)
	{
		return '\"' + s + '\"';
	}

	/**
	 * Takes iterator over String, and separator string, and returns a separated list as String, e.g.
	 * ["a","b","c"] and ", " -> "a, b, c"
	 */
	public static String toSepList(Iterator stringIter, String sep)
	{
		StringBuilder sb = new StringBuilder();

		if (stringIter.hasNext())
		{
			sb.append((String)stringIter.next());
		}

		while (stringIter.hasNext())
		{
			sb.append(sep);
			sb.append((String)stringIter.next());
		}

		return sb.toString();
	}

	/**
	 * ["a","b","c"] and ", " -> "a, b, c"
	 */
	public static String toCommaList(Iterator stringIter)
	{
		return toSepList(stringIter, ", ");
	}

	/**
	 * ["a","b","c"] and "<prefix>" -> "<prefix>a<prefix>b<prefix>c"
	 */
	public static String prefix(Iterator stringIter, String prefix)
	{
		StringBuilder sb = new StringBuilder();

		while (stringIter.hasNext())
		{
			sb.append(prefix);
			sb.append((String)stringIter.next());
		}

		return sb.toString();
	}

	/**
	 * "(s)" -> "s", others unchanged
	 */
	public static String stripParens(String sourceExpression)
	{
		if (sourceExpression.startsWith("(") && sourceExpression.endsWith(")"))
		{
			sourceExpression = sourceExpression.substring(1, sourceExpression.length() - 1);
		}
		return sourceExpression;
	}

}
