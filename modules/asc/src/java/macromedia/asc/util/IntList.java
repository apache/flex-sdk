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

/**
 * Don't use java.util.ArrayList<Integer>. Store int directly.
 * 
 * @author Clement Wong
 */
public final class IntList
{
	public IntList(IntList list)
	{
		this(list.size());
		System.arraycopy(list.a, 0, a, 0, list.size());
        this.size = list.size;
	}

	public IntList()
	{
		this(10);
	}

	public IntList(int size)
	{
		a = new int[size];
		this.size = 0;
	}

	private int[] a;
	private int size;

	public void add(int value)
	{
		resize();
		a[size++] = value;
	}
	
	public void push_back(int value)
	{
		add(value);
	}

	public void addAll(int[] numbers)
	{
		addAll(numbers, numbers.length);
	}

	public void addAll(IntList list)
	{
		addAll(list.a, list.size);
	}

	private void addAll(int[] array, int length)
	{
		resize(size + length);
		System.arraycopy(array, 0, a, size, length);
		size += length;
	}

	public void set(int index, int value)
	{
		resize();
		a[index] = value;
		if (index >= size)
		{
			size = index + 1;
		}
	}

	public void resize(int s)
	{
        if (s > a.length)
        {
            int newSize = a.length * 3 / 2 + 1;
            if (newSize < s)
            {
                newSize = s;
            }
            int[] temp = new int[newSize];
            System.arraycopy(a, 0, temp, 0, size);
            a = temp;
        }
	}

	private void resize()
	{
		if (size == a.length)
		{
			resize(size * 3 / 2 + 1);
		}
	}

	public int get(int index)
	{
		if (index < 0 || index >= size)
		{
			throw new ArrayIndexOutOfBoundsException(index);
		}
		return a[index];
	}
	
	public int at(int index)
	{
		return get(index);
	}

	public int first()
	{
		return (size == 0) ? 0 : a[0];
	}

	public int last()
	{
		return (size == 0) ? 0 : a[size - 1];
	}

    public int back()
    {
        return last();
    }

	public int remove(int index)
	{
		int value = get(index);
		if (index != size - 1)
		{
			System.arraycopy(a, index + 1, a, index, size - 1 - index);
		}
		size--;
		return value;
	}

	public int removeLast()
	{
		return (size == 0) ? 0 : remove(size - 1);
	}

	public void remove(int start, int end)
	{
		// start is inclusive. end is exclusive
		if (start == end)
		{
			remove(start);
		}
		else if (start > end)
		{
			// do nothing
		}
		else
		{
			start = (start < 0) ? 0 : start;
			end = (end > size) ? size : end;
			int[] temp = new int[size];
			System.arraycopy(a, 0, temp, 0, start);
			System.arraycopy(a, end, temp, start, size - end);
			a = temp;
			size -= (end - start);
		}
	}

	public void clear()
	{
		size = 0;
	}

	public int size()
	{
		return size;
	}

	public boolean isEmpty()
	{
		return size == 0;
	}

    public int pop_back()
    {
        int e = get(size()-1);
        remove(size()-1);
        return e;
    }

	public int[] toArray()
	{
		int[] temp = new int[size];
		System.arraycopy(a, 0, temp, 0, size);
		return temp;
	}
}
