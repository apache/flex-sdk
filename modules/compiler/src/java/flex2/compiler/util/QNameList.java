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

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.Set;

/**
 * This class represents a list of QNames.  It includes handy methods,
 * like contains(String, String), which allow performing collection
 * operations without having to create a new QName.
 *
 * @author Clement Wong
 */
public class QNameList extends ArrayList<QName>
{
	private static final long serialVersionUID = 3181098469098102598L;

    public QNameList()
	{
		super();
		key = new QName();
	}

	public QNameList(int size)
	{
		super(size);
		key = new QName();
	}

	private QName key;

	public void add(int index, QName obj)
	{
		if (!contains(obj))
		{
			super.add(index, obj);
		}
	}
	
	public boolean add(QName obj)
	{
		if (!contains(obj))
		{
			return super.add(obj);
		}
		
		return true;
	}

	public boolean addAll(int index, Collection<? extends QName> c)
	{
		if (c != null)
		{
			boolean result = false; int k = 0;
			for (Iterator<? extends QName> i = c.iterator(); i.hasNext();)
			{
				QName obj = i.next();
				if (!contains(obj))
				{
					super.add(index + k, obj);
					result = true;
					k++;
				}
			}
			return result;
		}
		else
		{
			return false;
		}
	}
	
	public boolean addAll(Collection<? extends QName> c)
	{
		if (c != null)
		{
			boolean result = false;
			for (Iterator<? extends QName> i = c.iterator(); i.hasNext();)
			{
				QName obj = i.next();
				if (!contains(obj))
				{
					super.add(obj);
					result = true;
				}
			}
			return result;
		}
		else
		{
			return false;
		}
	}
	
	public boolean contains(String ns, String name)
	{
		key.setNamespace(ns);
		key.setLocalPart(name);
		return contains(key);
	}

	public QName first()
	{
		return size() == 0 ? null : (QName) get(0);
	}

	public QName last()
	{
		return size() == 0 ? null : (QName) get(size() - 1);
	}

    public Set<String> getStringSet()
    {
        Set<String> set = new LinkedHashSet<String>(size());

	    for (int i = 0, s = size();i < s; i++)
	    {
		    set.add( get(i).toString() );
	    }

        assert set.size() == this.size();
        return set;
    }

    public String toString()
    {
        StringBuilder sb = new StringBuilder(20 * size());

	    for (int i = 0, s = size();i < s; i++)
	    {
		    sb.append( get(i).toString() );
		    if (i < s - 1)
		    {
			    sb.append(";");
		    }
	    }

        return sb.toString();
    }
}
