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

public final class ByteList
{
	public ByteList(ByteList list)
	{
		this(list.size());
		System.arraycopy(list.a, 0, a, 0, list.size());
	}

	public ByteList()
	{
		this(10);
	}

	public ByteList(int size)
	{
		a = new byte[size];
		this.size = 0;
	}

	private byte[] a;
	private int size;

	public void add(byte value)
	{
		resize();
		a[size++] = value;
	}

	public void push_back(byte value)
	{
		resize();
		a[size++] = value;
	}
	
	public void addAll(byte[] bytes)
	{
		addAll(bytes, bytes.length);
	}

	public void addAll(ByteList list)
	{
		addAll(list.a, list.size);
	}

	private void addAll(byte[] array, int length)
	{
		resize(size + length);
		System.arraycopy(array, 0, a, size, length);
		size += length;
	}

	public void set(byte[] array, int length)
	{
		a = array;
		size = length;
	}
	
	public void set(int index, byte value)
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
            byte[] temp = new byte[newSize];
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

	public byte at(int index)
	{
		if (index < 0 || index >= size)
		{
			throw new ArrayIndexOutOfBoundsException(index);
		}
		return a[index];
	}

	public byte get(int index)
	{
		if (index < 0 || index >= size)
		{
			throw new ArrayIndexOutOfBoundsException(index);
		}
		return a[index];
	}

	public byte first()
	{
		return (size == 0) ? 0 : a[0];
	}

	public byte last()
	{
		return (size() == 0) ? 0 : a[size - 1];
	}

    public byte remove(int index)
    {
        byte value = get(index);
        if (index != size - 1)
        {
            System.arraycopy(a, index + 1, a, index, size - 1 - index);
        }
        size--;
        return value;
    }

    public byte remove(int index, int count)
    {
        byte value = get(index);
        if (index != size - 1)
        {
            System.arraycopy(a, index + count, a, index, size - count - index);
        }
        size -= count;
        return value;
    }

    public byte removeLast()
	{
		return (size() == 0) ? 0 : remove(size - 1);
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

	public byte[] toByteArray()
	{
		return toByteArray(true);
	}
	
	public byte[] toByteArray(boolean copy)
	{
		if (copy || a.length != size)
		{
			byte[] b = new byte[size];
			System.arraycopy(a, 0, b, 0, size);
			return b;
		}
		else
		{
			return a;
		}
	}

    public boolean equals(Object b)
    {
        if (this == b)
        {
            return true;
        }
        else if (b instanceof ByteList)
        {
            return equals((ByteList)b);
        }
        else
        {
            return false;
        }
    }

    public boolean equals(ByteList b)
    {
  		if (b == null)
        {
            return false;
        }

  		if (size != b.size)
 			return false;
  		else
  		{
              for(int x = 0; x < size; x++ )
              {
                  if (a[x] != b.a[x])
                      return false;
              }

 			return true;
		}
    }

	public int hashCode()
	{
		int hashCode = 1;
		for (int j = 0; j < size; j++)
		{
			hashCode = 31 * hashCode + a[j];
		}
		return hashCode;
	}

    /* If we decide to use a TreeMap instead of a HashMap in ActionBlockEmitter for managing the constant table,
       use this method in the comparator class.   */

	/*
    static public int compare(ByteList z, ByteList b)
    {
        if (z == null || b == null)
        {
            if (z == b)
               return 0;
            else if (z == null)
               return 1;
            return -1;
        }

        int zSize = z.size();
        int bSize = b.size();
  		if (zSize < bSize)
 			return -1;
  		else if (zSize > bSize)
  			return 1;
  		else
  		{
              for(int x = 0; x < zSize; x++ )
              {
                  if (z.a[x] < b.a[x])
                      return -1;
                  else if (z.a[x] > b.a[x])
                      return 1;
              }

 			return 0;
		}
    }
    */
}

