/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package flash.util;

import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.StringTokenizer;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class URLHelper
{
	private static Pattern URL_PATTERN = Pattern.compile("^(.*?)(\\?.*?)?(#.*)?$"); //$NON-NLS-1$

	/**
	 * Everything before the "query" part of the URL.  E.g. for
	 * "http://www.example.com/file?firstname=Bob&lastname=Smith#foo"
	 * this would be "http://www.example.com/file".
	 */
	private String m_everythingBeforeQuery;
	
	/**
	 * The "query" in a URL is the "?firstname=Bob&lastname=Smith" part.
	 * m_query contains the query (including "?"), or contains "" if the
	 * URL has no query.  Never null.
	 */
	private String m_query;
	
	/**
	 * The "fragment" in a URL is the "#foo" part at the end of a URL.
	 * m_fragment contains the fragment (including "#"), or contains "" if the
	 * URL has no fragment. Never null.
	 */
	private String m_fragment;

	public URLHelper(String url)
	{
		Matcher matcher = URL_PATTERN.matcher(url);

		if (!matcher.matches())
			throw new IllegalArgumentException(url);

		if (matcher.matches())
		{
			m_everythingBeforeQuery = matcher.group(1);

			m_query = matcher.group(2);
			if (m_query == null) m_query = ""; //$NON-NLS-1$

			m_fragment = matcher.group(3);
			if (m_fragment == null) m_fragment = ""; //$NON-NLS-1$
		}
	}

	/**
	 * Everything before the "query" part of the URL.  E.g. for
	 * "http://www.example.com/file?firstname=Bob&lastname=Smith#foo"
	 * this would be "http://www.example.com/file".
	 */
	public String getEverythingBeforeQuery()
	{
		return m_everythingBeforeQuery;
	}

	public void setEverythingBeforeQuery(String everythingBeforeQuery)
	{
		assertValidArguments(everythingBeforeQuery, getQuery(), getFragment());
		m_everythingBeforeQuery = everythingBeforeQuery;
	}

	/**
	 * Rturns the "query" portion of the URL, e.g. the
	 * "?firstname=Bob&lastname=Smith" part. m_query contains the query
	 * (including "?"), or "" if the URL has no query. Never null.
	 */
	public String getQuery()
	{
		return m_query;
	}

	/**
	 * Sets the "query" portion of the URL.  This must be either the
	 * empty string or a string that begins with "?".
	 */
	public void setQuery(String query)
	{
		// if there is a query, make sure it starts with "?"
		if (query.length() > 0 && query.charAt(0) != '?')
			query = "?" + query; //$NON-NLS-1$

		assertValidArguments(getEverythingBeforeQuery(), query, getFragment());

		m_query = query;
	}

	/**
	 * Returns the "fragment" portion of the URL, e.g. the "#foo" part, or
	 * "" if the URL has no fragment. Never null.
	 */
	public String getFragment()
	{
		return m_fragment;
	}

	/**
	 * Sets the "fragment" portion of the URL.  This must be either the
	 * empty string or a string that begins with "#".
	 * @param fragment
	 */
	public void setFragment(String fragment)
	{
		// if there is a fragment, make sure it starts with "#"
		if (fragment.length() > 0 && fragment.charAt(0) != '#')
			fragment = "#" + fragment; //$NON-NLS-1$

		assertValidArguments(getEverythingBeforeQuery(), getQuery(), fragment);
		m_fragment = fragment;
	}

	private static void assertValidArguments(String everythingBeforeQuery, String query, String fragment)
	{
		assert areArgumentsValid(everythingBeforeQuery, query, fragment);
	}

	/**
	 * This will test for various error conditions, e.g. a query string that
	 * contains "#" or has incorrect contents.
	 */
	private static boolean areArgumentsValid(String everythingBeforeQuery, String query, String fragment)
	{
		if (everythingBeforeQuery == null || query == null || fragment == null)
			return false;

		URLHelper newHelper = new URLHelper(everythingBeforeQuery + query + fragment);
		if (!newHelper.getEverythingBeforeQuery().equals(everythingBeforeQuery) ||
			!newHelper.getQuery().equals(query) ||
			!newHelper.getFragment().equals(fragment))
		{
			return false;
		}
		
		return true;
	}

	/**
	 * Returns the entire URL.
	 */
	public String getURL()
	{
		return m_everythingBeforeQuery + m_query + m_fragment;
	}

	/**
	 * Returns the query portion of the URL, broken up into individual key/value
	 * pairs. Does NOT unescape the keys and values.
	 */
    public LinkedHashMap<String, String> getParameterMap()
	{
		LinkedHashMap<String, String> map;

		StringTokenizer tokens = new StringTokenizer(getQuery(), "?&"); //$NON-NLS-1$
		// multiply by 2 to create a sufficiently large HashMap
		map = new LinkedHashMap<String, String>(tokens.countTokens() * 2);

		while (tokens.hasMoreElements())
		{
			String nameValuePair = tokens.nextToken();
			String name = nameValuePair;
			String value = ""; //$NON-NLS-1$
			int equalsIndex = nameValuePair.indexOf('=');
			if (equalsIndex != -1)
			{
				name = nameValuePair.substring(0, equalsIndex);
				if (name.length() > 0)
				{
					value = nameValuePair.substring(equalsIndex + 1);
				}
			}
			map.put(name, value);
		}

		return map;
	}

    /**
	 * Sets the query portion of the URL.
	 * 
	 * @param parameterMap
	 *            a key/value mapping; these must already be escaped!
	 */
    public void setParameterMap(Map<String,String> parameterMap)
	{
		if ((parameterMap != null) && (!parameterMap.isEmpty()))
		{
			StringBuilder queryString = new StringBuilder();

			Iterator<Map.Entry<String,String>> it = parameterMap.entrySet().iterator();
			while (it.hasNext())
			{
				Map.Entry<String,String> entry = it.next();
				String name = (String) entry.getKey();
				String value = String.valueOf(entry.getValue());
				queryString.append(name);
				if ((value != null) && (!value.equals(""))) //$NON-NLS-1$
				{
					queryString.append('=');
					queryString.append(value);
				}
				if (it.hasNext())
				{
					queryString.append('&');
				}
			}

			setQuery(queryString.toString());
		} else
		{
			setQuery(""); //$NON-NLS-1$
		}
	}

	// shortcut for converting spaces to %20 in URIs
	public static String escapeSpace(String uri)
	{
		return escapeCharacter(uri, ' ', "%20"); //$NON-NLS-1$
	}

	/**
	 * Locates characters 'c' in the scheme specific portion of a URI and
	 * translates them into 'to'
	 */
	public static String escapeCharacter(String uri, char c, String to)
	{
		StringBuilder sb = new StringBuilder();

		int size = uri.length();
		int at = uri.indexOf(':');
		int lastAt = 0;

		// skip the scheme
		if (at > -1)
		{
			for(int i=0; i<=at; i++)
				sb.append(uri.charAt(i));
			lastAt = ++at;
		}

		// while we have 'c's in uri
		while( (at = uri.indexOf(c, at)) > -1)
		{
			// original portion
			for(int i=lastAt; i<at; i++)
				sb.append(uri.charAt(i));

			// conversion
			sb.append(to);
			lastAt = ++at;  // advance to char after conversion
		}

		if (lastAt < size)
		{
			for(int i=lastAt; i<size; i++)
				sb.append(uri.charAt(i));
		}
		return sb.toString();
	}
}
