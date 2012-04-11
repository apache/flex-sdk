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

package macromedia.asc.util;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

/**
 * @author Clement Wong
 */
public class ObjectList<E> extends ArrayList<E>
{
	public ObjectList()
	{
		super(0);
	}

	public ObjectList(int size)
	{
		super(size);
	}

	public ObjectList(Collection<E> list)
	{
		super(list);
	}

	final public E first()
	{
		return (size() == 0) ? null : (E) get(0);
	}

	final public E last()
	{
		return (size() == 0) ? null : (E) get(size() - 1);
	}

	final public E removeLast()
	{
		return (size() == 0) ? null : (E) remove(size() - 1);
	}

    final public void push_back(E e)
    {
        add(e);
    }

    final public E back()
    {
        return last();
    }

	final public void resize(int s)
	{
		if (s > size())
		{
			for (int i = 0, n = s - size(); i < n; i++)
			{
				add(null);
			}
		}
	}

    final public void pop_back()
    {
        if (!isEmpty()) {
            remove(size()-1);
        }
    }

    final public E at(int i)
    {
        return get(i);
    }

	public boolean equals(Object o)
	{
		if (this == o)
		{
			return true;
		}

		if (!(o instanceof List))
		{
			return false;
		}

		List list = (List) o;
		if (list.size() != size())
		{
			return false;
		}

		for (int i = 0, size = size(); i < size; i++)
		{
			if (!get(i).equals(list.get(i)))
			{
				return false;
			}
		}

		return true;
	}
}
