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

import java.util.Collection;
import java.util.Set;
import java.util.SortedMap;
import java.util.TreeMap;
import java.util.Map.Entry;

/**
 * @author Jeff Dyer
 */
public final class Multinames extends TreeMap<String, Namespaces>
{
	private Multinames delegate;
	// used to track delegate mutation, not foolproof
	private int delegateSize;
	private boolean checkingDelegate;
	
	
	public Multinames()
	{
		super();
		delegate = this;
	}	

	// this is the API we use, it now implements copy-on-write semantics
	public void putAll(Multinames m) {
		if(size() == 0 && delegate == this) {
			delegate = m;
			delegateSize = m.size();
			return;
		} 
		checkDelegate();
		super.putAll(m);
	}

	private void checkDelegate()
	{
		if (delegate != this && !checkingDelegate)
		{
			if(delegate.size() != delegateSize)
				throw new RuntimeException("Optimization gone wrong, fix code.");
			checkingDelegate = true;
			super.putAll(delegate);
			checkingDelegate = false;
			delegate = this;
			delegateSize = 0;
		}
	}
	
	public void clear() {
		delegate = this;
		super.clear();
	}	

	public Namespaces put(String arg0, Namespaces arg1) {
		checkDelegate();
		return super.put(arg0, arg1);
	}

	public Namespaces remove(Object arg0) {
		checkDelegate();
		return super.remove(arg0);
	}

	// everything else is read only and doesn't need checkDelegate()
	
	public boolean containsKey(Object arg0) {
		return (this == delegate ? super.containsKey(arg0) : delegate.containsKey(arg0));
	}

	public boolean containsValue(Object arg0) {
		return (this == delegate ? super.containsKey(arg0) : delegate.containsKey(arg0));
	}

	public Set<Entry<String, Namespaces>> entrySet() {
		return (this == delegate ? super.entrySet() : delegate.entrySet());
	}

	public String firstKey() {
		return (this == delegate ? super.firstKey() : delegate.firstKey());
	}

	public Namespaces get(Object arg0) {
		return (this == delegate ? super.get(arg0) : delegate.get(arg0));
	}

	public SortedMap<String, Namespaces> headMap(String arg0) {
		return (this == delegate ? super.headMap(arg0) : delegate.headMap(arg0));
	}

	public Set<String> keySet() {
		return (this == delegate ? super.keySet() : delegate.keySet());
	}

	public String lastKey() {
		return (this == delegate ? super.lastKey() : delegate.lastKey());
	}

	public int size() {
		return (this == delegate ? super.size() : delegate.size());
	}

	public SortedMap<String, Namespaces> subMap(String arg0, String arg1) {
		return (this == delegate ? super.subMap(arg0, arg1) : delegate.subMap(arg0,arg1));
	}

	public SortedMap<String, Namespaces> tailMap(String arg0) {
		return (this == delegate ? super.tailMap(arg0) : delegate.tailMap(arg0) );
	}

	public Collection<Namespaces> values() {
		return (this == delegate ? super.values() : delegate.values());
	}
	
}
