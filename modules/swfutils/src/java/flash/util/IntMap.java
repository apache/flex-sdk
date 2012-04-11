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

import java.util.Iterator;
import java.util.Map;
import java.util.NoSuchElementException;

/**
 * Implements a sparse mapping from int -> Object.  Iterators will
 * traverse from lowest to highest.  put() is O(1) if the key is
 * higher than any existing key; O(logN) if the key already exists,
 * and O(N) otherwise.  get() is an O(logN) binary search.
 *
 * @author Edwin Smith
 */
public class IntMap
{
    private int[] keys;
    private Object[] values;
    private int size;

    public IntMap()
    {
        this(10);
    }

    public IntMap(int capacity)
    {
        keys = new int[capacity];
        values = new Object[capacity];
    }

	public int capacity()
	{
		return keys.length;
	}

    private int find(int k)
    {
        int lo = 0;
        int hi = size-1;

        while (lo <= hi)
        {
            int i = (lo + hi)/2;
            int m = keys[i];
            if (k > m)
                lo = i + 1;
            else if (k < m)
                hi = i - 1;
            else
                return i; // key found
        }
        return -(lo + 1);  // key not found, low is the insertion point
    }

    public Object remove(int k)
    {
        Object old = null;
        int i = find(k);
        if (i >= 0)
        {
            old = values[i];
            System.arraycopy(keys, i+1, keys, i, size-i-1);
            System.arraycopy(values, i+1, values, i, size-i-1);
            size--;
        }
        return old;
    }

	public void clear()
	{
		size = 0;
	}

    public Object put(int k, Object v)
    {
        if (size == 0 || k > keys[size-1])
        {
            if (size == keys.length)
                grow();
            keys[size] = k;
            values[size] = v;
            size++;
            return null;
        }
        else
        {
            int i = find(k);
            if (i >= 0)
            {
                Object old = values[i];
                values[i] = v;
                return old;
            }
            else
            {
                i = -i - 1; // recover the insertion point
                if (size == keys.length)
                    grow();
                System.arraycopy(keys,i,keys,i+1,size-i);
                System.arraycopy(values,i,values,i+1,size-i);
                keys[i] = k;
                values[i] = v;
                size++;
                return null;
            }
        }
    }

    private void grow()
    {
        int[] newkeys = new int[size*2];
        System.arraycopy(keys,0,newkeys,0,size);
        keys = newkeys;

        Object[] newvalues = new Object[size*2];
        System.arraycopy(values,0,newvalues,0,size);
        values = newvalues;
    }

    public Object get(int k)
    {
        int i = find(k);
        return i >= 0 ? values[i] : null;
    }

    public boolean contains(int k)
    {
        return find(k) >= 0;
    }

	/** 
	 * A bit of an aberration from an academic point of view,
	 * but since this is an ordered Map, why not!
	 * 
	 * @return the element immediately following element k.
	 */
	public Object getNextAdjacent(int k)
	{
		int i = find(k);
		return ( (i >= 0) && (i+1 < size) ) ? values[i+1] : null;
	}

    public Iterator iterator()
    {
        return new Iterator()
        {
            private int i = 0;
            public boolean hasNext()
            {
                return i < size;
            }

            public Object next()
            {
                if (i >= size)
                {
                    throw new NoSuchElementException();
                }
                final int j = i++;
                return new Map.Entry()
                {
                    public Object getKey()
                    {
                        return new Integer(keys[j]);
                    }

                    public Object getValue()
                    {
                        return values[j];
                    }

                    public Object setValue(Object value)
                    {
                        Object old = values[j];
                        values[j] = value;
                        return old;
                    }
                };
            }

            public void remove()
            {
                System.arraycopy(keys, i, keys, i-1, size-i);
                System.arraycopy(values, i, values, i-1, size-i);
                size--;
            }
        };
    }

    public int size()
    {
        return size;
    }

	/** 
	 * @param ar must be of size size().
	 */
	public Object[] valuesToArray(Object[] ar)
	{
		System.arraycopy(values, 0, ar, 0, size);
		return ar;
	}

	public int[] keySetToArray()
	{
		int[] ar = new int[size()];
		System.arraycopy(keys, 0, ar, 0, size);
		return ar;
	}
}
