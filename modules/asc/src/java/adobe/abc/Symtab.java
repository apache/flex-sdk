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

package adobe.abc;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

public class Symtab<E>
{
	private List<Name> names = new ArrayList<Name>();
	private List<E> values = new ArrayList<E>();
	
	E get(Name name)
	{
		if (name.nsset != null && name.name != null)
		{
			if (name.nsset.length == 1)
			{
				for (int i=0, n=names.size(); i < n; i++)
					if (0 == name.match(names.get(i)))
						return values.get(i);
			}
			else
			{
				for (Namespace ns : name.nsset)
				{
					E e = get(new Name(name.kind,ns,name.name));
					if (e != null)
						return e;
				}
			}
		}
		return null;
	}
	
	Name getName(Name n)
	{
		// return the matching name from the symbol table
		if (n.nsset.length > 1)
		{
			for (Namespace ns : n.nsset)
			{
				Name k = new Name(n.kind,ns,n.name);
				if (names.contains(k))
					return k;
			}
		}
		return n;
	}
	
	boolean contains(Name n)
	{
		return n != null && get(n) != null;
	}
	
	void put(Name n, E e)
	{
		assert(n.nsset.length == 1);
		names.add(n);
		values.add(e);
	}
	
	public String toString()
	{
		StringBuilder b = new StringBuilder();
		b.append('[');
		for (int i=0, n=size(); i < n; i++)
		{
			b.append(names.get(i)).append('=').append(values.get(i));
			if (i+1 < n)
				b.append(", ");
		}
		b.append(']');
		return b.toString();
	}
	
	public Collection<E> values()
	{
		return values;
	}
	
	int size()
	{
		return names.size();
	}
}
