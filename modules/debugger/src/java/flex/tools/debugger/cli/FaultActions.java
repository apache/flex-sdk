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

package flex.tools.debugger.cli;

import java.util.HashMap;

/**
 * FaultActions proivdes a convenient wrapper for housing the user specified
 * behaviour for a set of faults (aka text strings)
 * 
 * The underlying data structure is a HashMap that maps strings (i.e. fault
 * names) to Integers.  The integers are used as bit fields for holding
 * the state of setting per fault.
 * 
 * Add new actions by calling addAction("name") 
 */
public class FaultActions
{
	HashMap<String, Integer> m_faults = new HashMap<String, Integer>();
	HashMap<String, String> m_description = new HashMap<String, String>();  // @todo should really use an object within the faults map for this 
	HashMap<String, Integer> m_actions = new HashMap<String, Integer>();

	int m_nextBitForAction = 0x1;  // the next bit to use for the action

	public FaultActions() {}

	Integer		get(String o)			{ return m_faults.get(o); }
	Integer		getAction(String o)		{ return m_actions.get(o); }
	void		put(String k, Integer v){ m_faults.put(k,v); }

	/* getters */
	public void			clear()					{ m_faults.clear(); }
	public int			size()					{ return m_faults.size(); }
	public Object[]     names()					{ return m_faults.keySet().toArray(); }
	public Object[]     actions()				{ return m_actions.keySet().toArray(); }
	public boolean		exists(String k)		{ return (get(k) == null) ? false : true;  }

	public void			putDescription(String k, String v)	{ m_description.put(k,v);	}
	public String		getDescription(String k)			{ return (m_description.get(k) == null) ? "" :  m_description.get(k);	} //$NON-NLS-1$

	/**
	 * Add a new fault to the table, with all actions disabled
	 */
	public void add(String k)				
	{ 
		put(k, new Integer(0)); 
	}

	/**
	 * Add a new action type to the table 
	 */
	public void addAction(String k)	
	{ 
		Integer v = new Integer(m_nextBitForAction++);
		m_actions.put(k,v); 
	}

	/**
	 * Check if the given fault has the action set or not 
	 */
	public boolean is(String fault, String action)
	{
		int mask  = getAction(action).intValue();
		int bits = get(fault).intValue();

		boolean set = ( (bits & mask) == mask ) ? true : false;
		return set;
	}

	/**
	 * Sets the action bits as appropriate for the given fault 
	 * and action 
	 */
	public int action(String fault, String action)
	{
		// first check if fault is legal
		Integer current = get(fault);
		if (current == null)
			throw new IllegalArgumentException(fault);			
		
		// check for no?
		boolean no = action.startsWith("no"); //$NON-NLS-1$
		if (no)
			action = action.substring(2);

		// do the search for action 
		Integer bit = getAction(action);
		if (bit == null)
			throw new IllegalArgumentException(action);

		// now do the math
		int old = current.intValue();
		int mask = bit.intValue();

		int n = (old & (~mask));  // turn it off
		n = (no) ? n : (n | mask); // leave it off or turn it on

		put(fault, new Integer(n));

		return n;
	}
}
