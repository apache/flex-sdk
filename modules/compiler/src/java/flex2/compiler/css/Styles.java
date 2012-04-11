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

package flex2.compiler.css;

import flex2.compiler.Source;
import flex2.compiler.abc.MetaData;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

/**
 * Map of style names to metadata declarations
 * <p/>
 * Note: for now anyway, we simply point to the original
 * metadata. Higher-level wrappers are implemented by each compiler's
 * reflection package. But clearly, if we throw exceptions on
 * inequivalent adds (or generally do anything more than a straight,
 * low-level equality test when testing), then there's higher-level
 * awareness here, and we should factor out something like
 * mxml.reflect.TypeTable.StyleHelper to here.
 * <p/>
 * Note: both old [Style] and new [StyleProperty] metadata formats may
 * be stored.
 * <p/>
 *
 * @author Paul Reilly
 * @author Pete Farland
 */
public class Styles
{
    private static final String FORMAT = "format";
    private static final String COLOR = "Color";
    private static final String INHERIT = "inherit";
    private static final String YES = "yes";

	private Map<String, MetaData> declMap;
	private Map<String, Source> locationMap;

	public Styles(int preferredSize)
	{
		declMap = new HashMap<String, MetaData>(preferredSize);
		locationMap = new HashMap<String, Source>(preferredSize);
	}

	public Styles()
    {
		this(16);
	}

	public int size()
	{
		return declMap.size();
	}

	public void addStyle(String name, MetaData md, Source source)
			throws StyleConflictException
    {
		if (isInherit(md) ? isNonInheritingStyle(name) : isInheritingStyle(name))
			throw new StyleConflictException(name, locationMap.get(name));
		declMap.put(name, md);
        locationMap.put(name, source);
	}

	public void addStyles(Styles styles)
			throws StyleConflictException
    {
		for (Iterator i = styles.declMap.entrySet().iterator(); i.hasNext();)
        {
			Map.Entry e = (Map.Entry) i.next();
			String name = (String) e.getKey();
			addStyle(name, (MetaData) e.getValue(), styles.getLocation(name));
		}
	}

	public Source getLocation(String name)
    {
		return locationMap.get(name);
	}

	public MetaData getStyle(String name)
    {
		return declMap.get(name);
	}

	public boolean isInheritingStyle(String name)
    {
		MetaData md = getStyle(name);
		return md != null && isInherit(md);
	}

	public boolean isNonInheritingStyle(String name)
    {
		MetaData md = getStyle(name);
		return md != null && !isInherit(md);
	}

	private static boolean isInherit(MetaData md)
    {
		String inherit = md.getValue(INHERIT);
		return inherit != null && YES.equals(inherit);
	}

	public Iterator<String> getStyleNames()
	{
		return declMap.keySet().iterator();
	}

    public Set<String> getInheritingStyles()
    {
        Set<String> result = new HashSet<String>();
        Iterator<String> iterator = getStyleNames();

        while ( iterator.hasNext() )
        {
            String styleName = iterator.next();

            if (isInheritingStyle(styleName))
            {
                result.add(styleName);
            }
        }

        return result;
    }

	public void clear()
	{
		declMap.clear();
	}
}
