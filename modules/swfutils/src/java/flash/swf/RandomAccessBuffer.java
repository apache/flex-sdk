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

package flash.swf;

import java.io.ByteArrayOutputStream;
import java.io.OutputStream;
import java.io.IOException;

/**
 * Extends ByteArrayOutputStream by adding support for a position.
 */
public class RandomAccessBuffer extends ByteArrayOutputStream
{
	protected int pos = 0;

    /**
     * Init an 1k buffer (BAOS default is 32 bytes, so this should be better)
     */
    public RandomAccessBuffer()
    {
        super(1024);
    }
    
    public RandomAccessBuffer(int bufferSize)
    {
        super(bufferSize);
    }
    
	final public int getPos()
	{
		return pos;
	}

	final public void setPos(int pos)
	{
		this.pos = pos;
	}

    // we override this so we can declare the signature w/out any exceptions
    final public synchronized void write(byte[] b)
    {
        this.write(b, 0, b.length);
    }

	final public synchronized void write(byte[] b, int off, int len)
	{
		if (pos > count)
		{
			byte[] zeros = new byte[pos - count];
			super.write(zeros, 0, zeros.length);
			pos = count;
		}
		else if (pos < count)
		{
			int overlap = Math.min(count - pos, len);
			System.arraycopy(b, off, buf, pos, overlap);
			pos += overlap;
			off += overlap;
			len -= overlap;
		}
		super.write(b, off, len);
		pos += len;
	}

	final public synchronized void readFully(byte[] bytes)
	{
		int len = bytes.length;
		if (pos+len > count)
		{
			throw new IndexOutOfBoundsException();
		}
		System.arraycopy(buf, pos, bytes, 0, len);
		pos += len;
	}

	final public synchronized void write(int b)
	{
		if (count > pos)
		{
			buf[pos++] = (byte) b;
		}
		else
		{
			super.write(b);
			pos++;
		}
	}

	public synchronized void reset()
	{
		super.reset();
		pos = 0;
	}

	public synchronized byte[] toByteArray()
	{
		count = pos;
		return super.toByteArray();
	}

	public synchronized void writeTo(OutputStream out) throws IOException
	{
		count = pos;
		super.writeTo(out);
	}

    public byte[] getByteArray()
    {
        return buf;
    }
}
