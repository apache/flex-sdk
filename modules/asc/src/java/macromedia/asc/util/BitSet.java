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
 * The methods in java.util.BitSet modify the internal values. The class does not offer methods
 * that return new values as BitSet. This simple class does that.
 * 
 * @author Clement Wong
 */
public final class BitSet
{
	private long[] bits;

	private BitSet(int nbits)
	{
		//Node.tally(this);
		if (nbits > 0)
			bits = new long[(nbits+63)>>6];
	}

	private BitSet(BitSet s)
	{
		this(size(s));
		if (size(s) > 0)
			System.arraycopy(s.bits,0,bits,0,bits.length);
	}
	
	public static BitSet and(BitSet a, BitSet b)
	{
		if (isEmpty(a) || isEmpty(b))
			return null;
		int minsize = size(a) < size(b) ? size(a) : size(b);
		int minlen = minsize>>6;
		BitSet t = new BitSet(minsize);
		for (int i=0; i < minlen; i++)
			t.bits[i] = a.bits[i] & b.bits[i];
		return t;
	}

	// this = this & ~s
	private void reset(BitSet r)
	{
		int minlen = (size(this) < size(r) ? size(this) : size(r))>>6;
		for (int i=0; i < minlen; i++)
			bits[i] &= ~r.bits[i];
	}
	
	public static BitSet or(BitSet a, BitSet b)
	{
		if (isEmpty(a)) return b;
		if (isEmpty(b)) return a;

		int minlen = (size(a) < size(b) ? size(a) : size(b))>>6;
		int maxlen = (size(a) > size(b) ? size(a) : size(b))>>6;
		BitSet t = new BitSet(maxlen<<6);
		for (int i=0; i < minlen; i++)
			t.bits[i] = a.bits[i] | b.bits[i];
		if (a.bits != null && a.bits.length > minlen)
			for (int i = a.bits.length-1; i >= minlen; i--)
				t.bits[i] = a.bits[i];
		else if (b.bits != null && b.bits.length > minlen)
			for (int i = b.bits.length-1; i >= minlen; i--)
				t.bits[i] = b.bits[i];
		return t;
	}
	
	// this = this | s
	private void set(BitSet s)
	{
		if (size(s) > size(this))
		{
			long[] b = new long[size(s)>>6];
			if (bits != null)
				System.arraycopy(bits,0,b,0,bits.length);
			bits = b;
		}
		if (s != null && s.bits != null)
			for (int i=s.bits.length-1; i >= 0; i--)
				bits[i] |= s.bits[i];
	}
	
	public static BitSet set(BitSet target, BitSet s)
	{
		if (size(s) > 0)
		{
			if (target == null)
				target = new BitSet(size(s));
			target.set(s);
		}
		return target;
	}
	
	public static BitSet reset_set(BitSet target, BitSet r, BitSet s)
	{
		if (target != null)
			target.reset(r);
		if (s != null)
		{
			if (target == null)
				target = new BitSet(size(s));
			target.set(s);
		}
		return target;
	}

	public static BitSet xor(BitSet a, BitSet b)
	{
		if (isEmpty(a)) return b;
		if (isEmpty(b)) return a;
		
		int minlen = (size(a) < size(b) ? size(a) : size(b))>>6;
		int maxlen = (size(a) > size(b) ? size(a) : size(b))>>6;
		BitSet t = new BitSet(maxlen<<6);
		for (int i=0; i < minlen; i++)
			t.bits[i] = a.bits[i] ^ b.bits[i];
		if (a.bits != null && a.bits.length > minlen)
			for (int i = a.bits.length-1; i >= minlen; i--)
				t.bits[i] = a.bits[i];
		else if (b.bits != null && b.bits.length > minlen)
			for (int i = b.bits.length-1; i >= minlen; i--)
				t.bits[i] = b.bits[i];
		return t;
	}
	
	public static boolean isEmpty(BitSet b)
	{
		return b == null || b.isEmpty();
	}

	private boolean isEmpty()
	{
		if (bits != null)
			for (int i=bits.length-1; i >= 0; i--)
				if (bits[i] != 0)
					return false;
		return true;
	}

	private static int size(BitSet s)
	{
		return (s != null && s.bits != null) ? s.bits.length<<6 : 0;
	}

	private boolean get(int index)
	{
		assert index >= 0;
		int i = index>>6;
		return bits != null && i < bits.length && (bits[i] & 1L<<(index&63)) != 0;
	}
	
	public static boolean get(BitSet b, int index)
	{
		return b != null && b.get(index);
	}
	
	public static BitSet set(BitSet target, int index, boolean value)
	{
		assert index >= 0;
		int i = index>>6;
		if (index >= size(target))
		{
			if (target == null)
				target = new BitSet(index+1);
			long[] b = new long[i+1];
			if (target.bits != null)
				System.arraycopy(target.bits,0,b,0,target.bits.length);
			target.bits = b;
		}
		if (value)
			target.bits[i] |= 1L << (index&63);
		else
			target.bits[i] &= ~(1L << (index&63));
		return target;
	}

	public static BitSet copy(BitSet s)
	{
		return s != null && !s.isEmpty() ? new BitSet(s) : null;
	}

	public boolean equals(Object obj)
	{
		if (!(obj instanceof BitSet))
			return false;
		return equals(this,(BitSet)obj);
	}
	
	public static boolean equals(BitSet a, BitSet b)
	{
		int minlen = (size(a) < size(b) ? size(a) : size(b))>>6;
		for (int i=0; i < minlen; i++)
			if (a.bits[i] != b.bits[i])
				return false;
		if (a != null && a.bits != null)
			for (int i=a.bits.length-1; i >= minlen; i--)
				if (a.bits[i] != 0)
					return false;
		if (b != null && b.bits != null)
			for (int i=b.bits.length-1; i >= minlen; i--)
				if (b.bits[i] != 0)
					return false;
		return true;
	}

    public int hashCode()
    {
    	int h = 0;
    	if (bits != null)
			for (int i=bits.length-1; i >= 0; i--)
				h ^= bits[i];
    	return h;
    }
    
    public static int and_count(BitSet a, BitSet b)
    {
		int minlen = (size(a) < size(b) ? size(a) : size(b))>>6;
    	int sum = 0;
    	for (int i=0; i < minlen; i++)
    		sum += bitCount(a.bits[i] & b.bits[i]);
    	return sum;
    }

    public static int count(BitSet s) 
    {
        int sum = 0;
        if (s != null && s.bits != null)
	    	for (int i=s.bits.length-1; i >= 0; i--)
	    		sum += bitCount(s.bits[i]);
        return sum;
    }

    /**
     * Returns the number of bits set in val.
     * For a derivation of this algorithm, see
     * "Algorithms and data structures with applications to 
     *  graphics and geometry", by Jurg Nievergelt and Klaus Hinrichs,
     *  Prentice Hall, 1993.
     */
    private static int bitCount(long val) 
    {
        val -= (val & 0xaaaaaaaaaaaaaaaaL) >>> 1;
        val =  (val & 0x3333333333333333L) + ((val >>> 2) & 0x3333333333333333L);
        val =  (val + (val >>> 4)) & 0x0f0f0f0f0f0f0f0fL;
        val += val >>> 8;     
        val += val >>> 16;    
        return ((int)(val) + (int)(val >>> 32)) & 0xff;
    }
    
    public String toString()
    {
    	StringBuilder b = new StringBuilder("{");
    	if (bits != null)
			for (int i=0, n=bits.length<<6; i < n; i++)
			{
				if ((bits[i>>6] & 1L<<(i&63)) != 0)
				{
					if (b.length() > 1)
						b.append(", ");
					b.append(i);
				}
			}
		b.append('}');
    	return b.toString();
    }
    
	private static final byte nextBitTable[] = {
		0, 0, 1, 0, 2, 0, 1, 0, 
		3, 0, 1, 0, 2, 0, 1, 0, 
		4, 0, 1, 0, 2, 0, 1, 0, 
		3, 0, 1, 0, 2, 0, 1, 0, 
		5, 0, 1, 0, 2, 0, 1, 0, 
		3, 0, 1, 0, 2, 0, 1, 0, 
		4, 0, 1, 0, 2, 0, 1, 0, 
		3, 0, 1, 0, 2, 0, 1, 0, 
		6, 0, 1, 0, 2, 0, 1, 0, 
		3, 0, 1, 0, 2, 0, 1, 0, 
		4, 0, 1, 0, 2, 0, 1, 0, 
		3, 0, 1, 0, 2, 0, 1, 0, 
		5, 0, 1, 0, 2, 0, 1, 0, 
		3, 0, 1, 0, 2, 0, 1, 0, 
		4, 0, 1, 0, 2, 0, 1, 0, 
		3, 0, 1, 0, 2, 0, 1, 0, 
		7, 0, 1, 0, 2, 0, 1, 0, 
		3, 0, 1, 0, 2, 0, 1, 0, 
		4, 0, 1, 0, 2, 0, 1, 0, 
		3, 0, 1, 0, 2, 0, 1, 0, 
		5, 0, 1, 0, 2, 0, 1, 0, 
		3, 0, 1, 0, 2, 0, 1, 0, 
		4, 0, 1, 0, 2, 0, 1, 0, 
		3, 0, 1, 0, 2, 0, 1, 0, 
		6, 0, 1, 0, 2, 0, 1, 0, 
		3, 0, 1, 0, 2, 0, 1, 0, 
		4, 0, 1, 0, 2, 0, 1, 0, 
		3, 0, 1, 0, 2, 0, 1, 0, 
		5, 0, 1, 0, 2, 0, 1, 0, 
		3, 0, 1, 0, 2, 0, 1, 0, 
		4, 0, 1, 0, 2, 0, 1, 0, 
		3, 0, 1, 0, 2, 0, 1, 0 
	};

	public static int nextSetBitOld(BitSet s, int i)
	{
		assert i >= 0;
		if (s != null && s.bits != null)
	    	for (int n = s.bits.length<<6; i < n; i++)
	    		if ((s.bits[i>>6] & 1L<<(i&63)) != 0)
	    			return i;
		return -1;
	}
	
    public static int nextSetBit(BitSet s, int i)
    {
    	assert i >= 0;

    	if (s != null && s.bits != null)
    	{
    		int j = i>>6, n = s.bits.length;
			
			if (j < n)
			{
	    		long value = s.bits[j];
	    		    		
	    		// clear bits below i that are not of interest
	    		value &= ~((1L<<(i&63))-1L);
	    		
	    		for (;;)
	    		{
					if (value != 0)
					{
						if ((value&0xffffffffL) != 0)
						{
							if ((value&0xffff) != 0)
							{
								if ((value&0xff) != 0)
								{
									return nextBitTable[(int)(value&0xff)] + (j<<6);
								}
								else
								{
									return nextBitTable[(int)((value>>8)&0xff)] + 8 + (j<<6);
								}
							}
							else
							{
								if ((value&0xff0000) != 0)
								{
									return nextBitTable[(int)((value>>16)&0xff)] + 16 + (j<<6);
								}
								else
								{
									return nextBitTable[(int)((value>>24)&0xff)] + 24 + (j<<6);
								}							
							}
						}
						else
						{
							if ((value&0xffff00000000l) != 0)
							{
								if ((value&0xff00000000l) != 0)
								{
									return nextBitTable[(int)((value>>32)&0xff)] + 32 + (j<<6);
								}
								else
								{
									return nextBitTable[(int)((value>>40)&0xff)] + 40 + (j<<6);
								}
							}
							else
							{
								if ((value&0xff000000000000l) != 0)
								{
									return nextBitTable[(int)((value>>48)&0xff)] + 48 + (j<<6);
								}
								else
								{
									return nextBitTable[(int)((value>>56)&0xff)] + 56 + (j<<6);
								}							
							}	
						}
					}
						
					if (++j >= n)
					{
						break;
					}

					value = s.bits[j];
	    		}
			}
    	}
   	
    	return -1;
    }
}
