/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package flex.tools.debugger.cli;

import java.util.ArrayList;
import java.util.AbstractList;

/**
 * This class wraps a Nx2 array and provides a List interface
 * for each of the 2 columns of the array.
 *
 * Its main purpose is to provide the method elementsStartingWith()
 * which returns a ArrayList of index numbers for each element whose
 * String component matches the provided argument.
 */
public class StringIntArray extends AbstractList<Object>
{
	Object[]    m_ar;
	int			m_size = 0;
	double		m_growthRatio = 1.60;

	public StringIntArray(Object[] ar)
	{
		m_ar = ar;
		m_size = m_ar.length;
	}

	public StringIntArray()	{ this(10); }

	public StringIntArray(int size)
	{
		m_ar = new Object[size];
		m_size = 0;
	}

	@Override
	public Object		get(int at)				{ return m_ar[at];	}
	@Override
	public int			size()					{ return m_size; }

	public Object[]		getElement(int at)		{ return (Object[])get(at);	}
	public String		getString(int at)		{ return (String)getElement(at)[0]; }
	public Integer		getInteger(int at)		{ return (Integer)getElement(at)[1]; }
	public int			getInt(int at)			{ return getInteger(at).intValue(); }

	/**
	 * Sequentially walk through the entire list 
	 * matching the String components against the 
	 * given string 
	 */
	public ArrayList<Integer> elementsStartingWith(String s)
	{
		ArrayList<Integer> alist = new ArrayList<Integer>();
		for(int i=0; i<m_size; i++)
			if ( getString(i).startsWith(s) )
				alist.add( new Integer(i) );

		return alist;
	}

	@Override
	public void add(int at, Object e)
	{
		// make sure there is enough room in the array, then add the element 
		ensureCapacity(1);
		int size = size();

		// open a spot for the element and stick it in
//		System.out.println("add("+at+"), moving "+at+" to "+(at+1)+" for "+(size-at)+",size="+size);
		System.arraycopy(m_ar, at, m_ar, at+1, size-at);
		m_ar[at] = e;

		m_size++;
	}

	@Override
	public Object remove(int at)
	{
		int size = size();
		Object o = m_ar[at];

//		System.out.println("remove("+at+"), moving "+(at+1)+" to "+at+" for "+(size-at+1)+",size="+size);
		System.arraycopy(m_ar, at+1, m_ar, at, size-at+1);
		m_size--;

		return o;
	}

	void ensureCapacity(int amt)
	{
		int size = size();
		int newSize = amt+size;
		if (newSize > m_ar.length)
		{
			// we need a new array, compute a good size for it
			double growTo = m_ar.length * m_growthRatio;   // make bigger
			if (newSize > growTo)
				growTo += newSize + (newSize * m_growthRatio);

			Object[] nAr = new Object[(int)growTo+1];
			System.arraycopy(m_ar, 0, nAr, 0, m_ar.length);
			m_ar = nAr;
		}
	}
}
