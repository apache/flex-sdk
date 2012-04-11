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

package macromedia.abc;

import macromedia.asc.util.IntegerPool;

import java.io.*;
import java.util.*;

/**
 * @author Clement Wong
 */
public class BytecodeBuffer
{
	public BytecodeBuffer(byte[] bytecodes)
	{
		this.bytecodes = bytecodes;
		size = bytecodes.length;
		pos = 0;
	}

	public BytecodeBuffer(String filename) throws IOException
	{
		BufferedInputStream in = null;
		try
		{
			in = new BufferedInputStream(new FileInputStream(filename));
			bytecodes = new byte[in.available()];
			in.read(bytecodes);
			size = bytecodes.length;
			pos = 0;
		}
		finally
		{
			if (in != null)
			{
				try
				{
					in.close();
				}
				catch (IOException ex)
				{
				}
			}
		}
	}

	public BytecodeBuffer(int preferredSize)
	{
		preferredSize = (preferredSize <= 0) ? 1000 : preferredSize;
		this.bytecodes = new byte[preferredSize];
		size = 0;
		pos = 0;
	}

	private byte[] bytecodes;
	private int pos, size;

	public void clear()
	{
		pos = 0;
		size = 0;
	}

	public int pos()
	{
		return pos;
	}

	public int size()
	{
		return size;
	}
	
	public void delete(int count)
	{
		size -= count;
	}

	public void writeS8(int v)
	{
		writeU8(v);
	}

	public void writeU8(int v)
	{
		resize(1);
		bytecodes[size++] = (byte) v;
	}
	
	public void writeU8(int pos, int v)
	{
		bytecodes[pos] = (byte) v;
	}

    public void writeU16(int v)
    {
	    resize(2);
	    bytecodes[size++] = (byte) v;
	    bytecodes[size++] = (byte) (v >> 8);
    }

	public void writeS24(int v)
	{
		writeU24(v);
	}

	public void writeS24(int pos, int v)
	{
		bytecodes[pos] = (byte) v;
		bytecodes[pos + 1] = (byte) (v >> 8);
		bytecodes[pos + 2] = (byte) (v >> 16);
	}

	public void writeU24(int v)
	{
		resize(3);
		bytecodes[size++] = (byte) v;
		bytecodes[size++] = (byte) (v >> 8);
		bytecodes[size++] = (byte) (v >> 16);
	}

	public void writeU32(long v)
	{
        if ( v < 128 && v > -1 )
        {
            resize(1);
            bytecodes[size++] = (byte) v;
        }
        else if ( v < 16384 && v > -1)
        {
            resize(2);
            bytecodes[size++] = (byte) ((v & 0x7F) | 0x80);
            bytecodes[size++] = (byte) ((v >> 7) & 0x7F);
        }
        else if ( v < 2097152 && v > -1)
        {
            resize(3);
            bytecodes[size++] = (byte) ((v & 0x7F) | 0x80);
            bytecodes[size++] = (byte) ((v >> 7) | 0x80);
            bytecodes[size++] = (byte) ((v >> 14) & 0x7F);
        }
        else if (  v < 268435456 && v > -1)
        {
            resize(4);
            bytecodes[size++] = (byte) ((v & 0x7F) | 0x80);
            bytecodes[size++] = (byte) (v >> 7 | 0x80);
            bytecodes[size++] = (byte) (v >> 14 | 0x80);
            bytecodes[size++] = (byte) ((v >> 21) & 0x7F);
        }
        else
        {
            resize(5);
            bytecodes[size++] = (byte) ((v & 0x7F) | 0x80);
            bytecodes[size++] = (byte) (v >> 7 | 0x80);
            bytecodes[size++] = (byte) (v >> 14 | 0x80);
            bytecodes[size++] = (byte) (v >> 21 | 0x80);
            bytecodes[size++] = (byte) ((v >> 28) & 0x0F );
        }
	}

	public void writeDouble(double v)
	{
		resize(8);
		// todo switch for endianness on Mac
		long bits = Double.doubleToLongBits(v);
		bytecodes[size++] = (byte) bits;
		bytecodes[size++] = (byte) (bits >> 8);
		bytecodes[size++] = (byte) (bits >> 16);
		bytecodes[size++] = (byte) (bits >> 24);
		bytecodes[size++] = (byte) (bits >> 32);
		bytecodes[size++] = (byte) (bits >> 40);
		bytecodes[size++] = (byte) (bits >> 48);
		bytecodes[size++] = (byte) (bits >> 56);
	}

	/**
	 * @param start - inclusive
	 * @param end - exclusive
	 */
	public void writeBytes(BytecodeBuffer b, int start, int end)
	{
		resize(end - start);
		for (int i = start; i < end; i++)
		{
			bytecodes[size++] = b.bytecodes[i];
		}
	}

	private void resize(int increment)
	{
		if (size + increment > bytecodes.length)
		{
			byte[] temp = new byte[bytecodes.length * 3 / 2 + 1];
			System.arraycopy(bytecodes, 0, temp, 0, bytecodes.length);
			bytecodes = temp;
		}
	}

	public int readU8()
	{
		int value = bytecodes[pos] & 0xff;
		pos++;
		return value;
	}
	
	public int readU8(int pos)
	{
		return bytecodes[pos] & 0xff;
	}

	public int readU16()
	{
		return readU8() | (readU8() << 8);
	}

	public int readU32()
	{
	    int result = readU8();
	    if (0==(result & 0x00000080))
	        return result;
	    result = result & 0x0000007f | readU8()<<7;
	    if (0==(result & 0x00004000))
	        return result;
	    result = result & 0x00003fff | readU8()<<14;
	    if (0==(result & 0x00200000))
	        return result;
	    result = result & 0x001fffff | readU8()<<21;
	    if (0==(result & 0x10000000))
	        return result;
	    return   result & 0x0fffffff | readU8()<<28;
	}
	
	public long readU32(int pos)
	{
	    int result = readU8(pos++);
	    if (0==(result & 0x00000080))
	        return result;
	    result = result & 0x0000007f | readU8(pos++)<<7;
	    if (0==(result & 0x00004000))
	        return result;
	    result = result & 0x00003fff | readU8(pos++)<<14;
	    if (0==(result & 0x00200000))
	        return result;
	    result = result & 0x001fffff | readU8(pos++)<<21;
	    if (0==(result & 0x10000000))
	        return result;
	    return   result & 0x0fffffff | readU8(pos++)<<28;
	}

	public int readS8()
	{
		int value = bytecodes[pos];
		pos++;
		return value;
	}

	public int readS24()
	{
		return readU8() | (readU8() << 8) | (readS8() << 16);
	}

	public double readDouble()
	{
		long first = readU8() | (readU8() << 8) | (readU8() << 16) | (readU8() << 24);
		long second = readU8() | (readU8() << 8) | (readU8() << 16) | (readU8() << 24);
		return Double.longBitsToDouble(first&0xFFFFFFFFL | second<<32);
	}

	public byte[] readBytes(int length)
	{
		byte[] bytes = new byte[length];
		System.arraycopy(bytecodes, pos, bytes, 0, length);
		pos += length;
		return bytes;
	}

	public String readString(int length)
	{
		try
		{
			return new String(bytecodes, pos, length, "UTF8");
		}
		catch (UnsupportedEncodingException ex)
		{
			return null;
		}
	}

	public void close()
	{
		pos = 0;
	}

	public void skip(long length)
	{
		pos += length;
	}

    public void skipEntries(long entries)
    {
        for(long i = 0; i < entries; ++i)
        {
            readU32();
        }
    }

	public void seek(int pos)
	{
		this.pos = pos;
	}

	public boolean same(BytecodeBuffer b, int start1, int end1, int start2, int end2)
	{
		if ((end1 - start1) != (end2 - start2))
		{
			return false;
		}

		for (int i = start1, j = start2; i < end1;)
		{
			if (bytecodes[i] != b.bytecodes[j])
			{
				return false;
			}

			i++;
			j++;
		}

		return true;
	}

	public int hashCode(int start, int end)
	{
		long hash = 1234;

		for (int j = start; j < end; j++)
		{
			hash ^= bytecodes[j];
		}

		return (int) ((hash >> 32) ^ hash);
	}

	public void writeTo(OutputStream out) throws IOException
	{
		out.write(bytecodes, 0, size);
	}
	
	public int minorVersion()
	{
		return (bytecodes[0] & 0xff) | ((bytecodes[1] & 0xff) << 8);		
	}
}

class ByteArrayPool
{
	ByteArrayPool()
	{
		map = new HashMap();
		wrappers = new Stack();
		key = newByteArray();
	}

	protected Map map;
	Stack wrappers;
	private ByteArray key;

	ByteArray newByteArray()
	{
		return new ByteArray();
	}

	int store(BytecodeBuffer b, int start, int end)
	{
		ByteArray a = wrappers.isEmpty() ? null : (ByteArray) wrappers.pop();

		if (a == null)
		{
			a = newByteArray();
		}

		a.clear();
		a.b = b;
		a.start = start;
		a.end = end;
		a.init();

		Integer index = IntegerPool.getNumber(map.size() + 1);
		map.put(a, index);

		return index.intValue();
	}

	int contains(BytecodeBuffer b, int start, int end)
	{
		key.clear();
		key.b = b;
		key.start = start;
		key.end = end;
		key.hash = 0;
		key.init();

		Integer index = (Integer) map.get(key);
		return (index != null) ? index.intValue() : -1;
	}

	void clear()
	{
		for (Iterator i = map.keySet().iterator(); i.hasNext();)
		{
			ByteArray a = (ByteArray) i.next();
			a.clear();
			wrappers.push(a);
		}

		map.clear();
	}

	void writeTo(BytecodeBuffer b)
	{
		Map sortedMap = new TreeMap();

		for (Iterator i = map.keySet().iterator(); i.hasNext();)
		{
			Object key = i.next(); // ByteArray
			Object value = map.get(key); // Integer
			sortedMap.put(value, key);
		}

		b.writeU32((sortedMap.size() == 0) ? 0 : sortedMap.size() + 1);

		for (Iterator i = sortedMap.keySet().iterator(); i.hasNext();)
		{
			Integer index = (Integer) i.next();
			ByteArray a = (ByteArray) sortedMap.get(index);
			b.writeBytes(a.b, a.start, a.end);
		}
	}
}

class ByteArray
{
	BytecodeBuffer b;
	int start, end, hash;

	void clear()
	{
		b = null;
		start = 0;
		end = 0;
		hash = 0;
	}

	void init()
	{
		hash = b.hashCode(start, end);
	}

	public boolean equals(Object obj)
	{
		if (obj instanceof ByteArray)
		{
			ByteArray a = (ByteArray) obj;
			return b.same(a.b, start, end, a.start, a.end);
		}
		else
		{
			return false;
		}
	}

	public int hashCode()
	{
		return hash;
	}	
}

