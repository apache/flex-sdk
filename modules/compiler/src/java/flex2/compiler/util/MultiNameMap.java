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

package flex2.compiler.util;

import java.util.*;

/**
 * This class represents a map of MultiNames to QNames.
 *
 * @author Clement Wong
 */
//TODO This class should just extend HashMap, it doesn't need to be an adapter
public class MultiNameMap
{
	public MultiNameMap()
	{
		s = null;
		key = null;
	}

	public MultiNameMap(int size)
	{
		this();
		preferredSize = size;
	}

	private HashMap<MultiName, QName> s;
	private MultiName key;
	private int preferredSize;

	public boolean containsKey(String[] ns, String name)
	{
		if (s == null) return false;

		if (key == null)
		{
			key = new MultiName(ns, name);
		}
		else
		{
			key.namespaceURI = ns;
			key.localPart = name;
		}

		return s.containsKey(key);
	}

	public void putAll(MultiNameMap c)
	{
		if (c.s == null) return;

		if (s == null)
		{
			s = new HashMap<MultiName, QName>(preferredSize);
		}

		s.putAll(c.s);
	}

	public QName put(MultiName key, QName value)
	{
		if (s == null)
		{
			s = new HashMap<MultiName, QName>(preferredSize);
		}

		return s.put(key, value);
	}

	public QName get(MultiName key)
	{
		if (s != null)
		{
			return s.get(key);
		}
		else
		{
			return null;
		}
	}

	public Set<Map.Entry<MultiName, QName>> entrySet()
	{
		if (s != null)
		{
			return s.entrySet();
		}
		else
		{
			return Collections.emptySet();
		}
	}

	public Set<MultiName> keySet()
	{
		if (s != null)
		{
			return s.keySet();
		}
		else
		{
			return Collections.emptySet();
		}
	}

	public Collection<QName> values()
	{
		if (s != null)
		{
			return s.values();
		}
		else
		{
			return Collections.emptySet();
		}
	}

	public int size()
	{
		return s == null ? 0 : s.size();
	}

	public void clear()
	{
		if (s != null)
		{
			s.clear();
		}
	}
	
	public String toString()
	{
		return s == null ? "" : s.toString();
	}
}


