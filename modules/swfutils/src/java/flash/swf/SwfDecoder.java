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
import java.io.IOException;
import java.io.InputStream;
import java.io.BufferedInputStream;
import java.io.UTFDataFormatException;

/**
 * A decoder for a whole SWF.
 *
 * @author Clement Wong
 */
public final class SwfDecoder extends BufferedInputStream
{
	private int offset;
	private int bitBuf;
	private int bitPos;
    int swfVersion;

    /**
     * create a decoder that reads directly from this byte array
     * @param b
     * @param swfVersion
     */
    public SwfDecoder(byte[] b, int swfVersion)
    {
        this((InputStream)null, swfVersion);
        buf = b;
        count = b.length;
        pos = 0;
    }

    /**
     * create a buffering decoder that reads from this unbuffered
     * input stream.  Since SwfDecoder is a BufferedInputStream,
     * it is not necessary to provide a BufferedInputStream for good
     * performance.
     * @param in
     * @param swfVersion
     */
    public SwfDecoder(InputStream in, int swfVersion)
	{
        super(in);
        this.swfVersion = swfVersion;
	}

    public SwfDecoder(InputStream in, int swfVersion, int offset)
    {
        this(in, swfVersion);
        this.offset = offset;
    }

	public void readFully(byte[] b) throws IOException
	{
		int remain = b.length;
		int off = 0;
		int count;
		while (remain > 0)
		{
			count = read(b, off, remain);
			if (count > 0)
			{
				off += count;
				remain -= count;
			}
			else
			{
				throw new SwfFormatException("couldn't read " + remain);
			}
		}
	}

    public int read() throws IOException
    {
        offset++;
        return super.read();
    }

    public int read(byte b[], int off, int len)
            throws IOException
    {
        int n = super.read(b,off,len);
        offset += n;
        return n;
    }

    public synchronized long skip(long len) throws IOException
    {
        long n = super.skip(len);
        offset += n;
        return n;
    }

    public float readFixed8() throws IOException
    {
        int val = readUI16();
        // FIXME: this doesn't consider sign of original 8.8 value
        return (float)(val / 256.0);
    }

    public int readUI8() throws IOException
	{
        if (pos<count)
        {
            offset++;
            return buf[pos++]&0xFF;
        }
        else if (in != null)
        {
            offset++;
            return super.read();
        }
        else
        {
            return -1;
        }
	}

	public int readUI16() throws IOException
	{
        syncBits();
        int i;
        if (count-pos >= 2)
        {
            i = buf[pos] & 0xFF | (buf[pos + 1] & 0xFF) << 8;
            pos += 2;
            offset += 2;
        }
        else if (in != null)
        {                                 
            i = super.read() | super.read()<<8;
            offset += 2;
        }
        else
        {
            return -1;
        }
        return i;
	}

	public long readUI32() throws IOException
	{
        long i = readSI32() & 0xFFFFFFFFL;
        return i;
	}

    public int readSI32() throws IOException
    {
        syncBits();
        int i;
        if (count - pos >= 4)
        {
            i = buf[pos] & 0xFF | (buf[pos + 1] & 0xFF) << 8 | (buf[pos + 2] & 0xFF) << 16 | buf[pos + 3] << 24;
            offset += 4;
            pos += 4;
        }
        else if (in != null)
        {
            i = super.read() | super.read() << 8 | super.read() << 16 | super.read() << 24;
            offset += 4;
        }
        else
        {
            i = -1;
        }
        return i;
    }

    public long read64() throws IOException
    {
        return (readUI32() & 0xFFFFFFFFL) | (readUI32() << 32);
    }

	public boolean readBit() throws IOException
	{
		return readUBits(1) != 0;
	}

	public int readUBits(int numBits) throws IOException
	{
		if (numBits == 0)
		{
			return 0;
		}

		int bitsLeft = numBits;
		int result = 0;

		if (bitPos == 0) //no value in the buffer - read a byte
		{
			bitBuf = readUI8();
			bitPos = 8;
		}

		while (true)
		{
			int shift = bitsLeft - bitPos;
			if (shift > 0)
			{
				// Consume the entire buffer
				result |= bitBuf << shift;
				bitsLeft -= bitPos;

				// Get the next byte from the input stream
				bitBuf = readUI8();
				bitPos = 8;
			}
			else
			{
				// Consume a portion of the buffer
				result |= bitBuf >> -shift;
				bitPos -= bitsLeft;
				bitBuf &= 0xff >> (8 - bitPos);	// mask off the consumed bits

//                if (print) System.out.println("  read"+numBits+" " + result);
				return result;
			}
		}
	}

	public int readSBits(int numBits) throws IOException
	{
		if (numBits > 32)
		{
			throw new SwfFormatException("Number of bits > 32");
		}

		int num = readUBits(numBits);
        int shift = 32-numBits;
        // sign extension
        num = (num << shift) >> shift;
		return num;
	}

	public int readSI16() throws IOException
	{
		return (short)readUI16();
	}

    public float readFloat() throws IOException
    {
        int bits = readSI32();
        return Float.intBitsToFloat( bits );  
    }

    private final ByteArrayOutputStream out = new ByteArrayOutputStream(256)
    {
        public byte[] toByteArray()
        {
            // don't bother copying the array
            return buf;
        }
    };

	public String readLengthString() throws IOException
	{
        int length = readUI8();
        byte[] b = new byte[length];
        readFully(b);

        // [paul] Flash Authoring and the player null terminate the
        // string, so ignore the last byte when constructing the String.
        if (swfVersion >= 6)
        {
            return new String(b, 0, length - 1, "UTF8").intern();
        }
        else
        {
            // use platform encoding
            return new String(b, 0, length - 1).intern();
        }
	}

	public String readString() throws IOException
	{
        if (swfVersion >= 6)
        {
		    return readUTF().intern();
        }
        else
        {
            int ch;
            while ((ch = readUI8()) > 0)
            {
                out.write(ch);
            }
            // use platform encoding
            String s = new String(out.toByteArray(), 0, out.size());
            out.reset();
            return s.intern();
        }
	}

    private String readUTF() throws IOException
    {
        StringBuilder b = new StringBuilder();
        int c, c2, c3;

        while ((c = readUI8()) > 0)
        {
            switch (c >> 4)
            {
            case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7:
                /* 0xxxxxxx*/
                b.append((char) c);
                break;

            case 12: case 13:
                /* 110x xxxx   10xx xxxx*/
                c2 = readUI8();
                if (c2 <= 0 || (c2 & 0xC0) != 0x80)
                    throw new UTFDataFormatException();
                b.append((char) ((c & 0x1F) << 6 | c2 & 0x3F));
                break;

            case 14:
                /* 1110 xxxx  10xx xxxx  10xx xxxx */
                c2 = readUI8();
                c3 = readUI8();
                if (c2 <= 0 || c3 <= 0 || ((c2 & 0xC0) != 0x80) || ((c3 & 0xC0) != 0x80))
                    throw new UTFDataFormatException();
                b.append((char) ((c & 0x0F) << 12 | (c2 & 0x3F) << 6 | c3 & 0x3F));
                break;

            default:
                /* 10xx xxxx,  1111 xxxx */
                throw new UTFDataFormatException();
            }
        }
        return b.toString();
    }


	public void syncBits()
	{
		bitPos = 0;
	}

	public int getOffset()
	{
		return offset;
	}
	
	private int markOffset;
	
	public void mark(int readlimit)
	{
		markOffset = offset;
		super.mark(readlimit);
	}
	
	public void reset() throws IOException
	{
		offset = markOffset;
		super.reset();
	}
	
}
